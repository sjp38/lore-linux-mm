Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 3719D6B008C
	for <linux-mm@kvack.org>; Tue, 11 Sep 2012 22:04:20 -0400 (EDT)
Received: by qady1 with SMTP id y1so934172qad.14
        for <linux-mm@kvack.org>; Tue, 11 Sep 2012 19:04:19 -0700 (PDT)
Date: Tue, 11 Sep 2012 19:03:38 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 09/12] thp: introduce khugepaged_prealloc_page and
 khugepaged_alloc_page
In-Reply-To: <5028E20C.3080607@linux.vnet.ibm.com>
Message-ID: <alpine.LSU.2.00.1209111807030.21798@eggly.anvils>
References: <5028E12C.70101@linux.vnet.ibm.com> <5028E20C.3080607@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Mon, 13 Aug 2012, Xiao Guangrong wrote:

> They are used to abstract the difference between NUMA enabled and NUMA disabled
> to make the code more readable
> 
> Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
> ---
>  mm/huge_memory.c |  166 ++++++++++++++++++++++++++++++++----------------------
>  1 files changed, 98 insertions(+), 68 deletions(-)

Hmm, that in itself is not necessarily an improvement.

I'm a bit sceptical about this patch,
thp-introduce-khugepaged_prealloc_page-and-khugepaged_alloc_page.patch
in last Thursday's mmotm 2012-09-06-16-46.

What brought me to look at it was hitting "BUG at mm/huge_memory.c:1842!"
running tmpfs kbuild swapping load (with memcg's memory.limit_in_bytes
forcing out to swap), while I happened to have CONFIG_NUMA=y.

That's the VM_BUG_ON(*hpage) on entry to khugepaged_alloc_page().

(If I'm honest, I'll admit I have Michel's "interval trees for anon rmap"
patches in on top, and so the line number was actually shifted to 1839:
but I don't believe his patches were in any way involved here, and
indeed I've not yet found a problem with them: they look very good.)

I expect the BUG could quite easily be fixed up by making another call
to khugepaged_prealloc_page() from somewhere to free up the hpage;
but forgive me if I dislike using "prealloc" to free.

I do agree with you that the several CONFIG_NUMA ifdefs dotted around
mm/huge_memory.c are regrettable, but I'm not at all sure that you're
improving the situation with this patch, which gives misleading names
to functions and moves the mmap_sem upping out of line.

I think you need to revisit it: maybe not go so far (leaving a few
CONFIG_NUMAs behind, if they're not too bad), or maybe go further
(add a separate function for freeing in the NUMA case, instead of
using "prealloc").  I don't know what's best: have a play and see.

That's what I was intending to write yesterday.  But overnight I
was running with this 9/12 backed out (I think 10,11,12 should be
independent), and found "BUG at mm/huge_memory.c:1835!" this morning.

That's the VM_BUG_ON(*hpage) below #else in collapse_huge_page()
when 9/12 is reverted.

So maybe 9/12 is just obscuring what was already a BUG, either earlier
in your series or elsewhere in mmotm (I've never seen it on 3.6-rc or
earlier releases, nor without CONFIG_NUMA).  I've not spent any time
looking for it, maybe it's obvious - can you spot and fix it?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
