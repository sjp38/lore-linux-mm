Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id E571B6B012E
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 02:27:44 -0400 (EDT)
Received: by iagk10 with SMTP id k10so2488853iag.14
        for <linux-mm@kvack.org>; Wed, 12 Sep 2012 23:27:44 -0700 (PDT)
Date: Wed, 12 Sep 2012 23:27:04 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 09/12] thp: introduce khugepaged_prealloc_page and
 khugepaged_alloc_page
In-Reply-To: <50500360.5020700@linux.vnet.ibm.com>
Message-ID: <alpine.LSU.2.00.1209122316200.7831@eggly.anvils>
References: <5028E12C.70101@linux.vnet.ibm.com> <5028E20C.3080607@linux.vnet.ibm.com> <alpine.LSU.2.00.1209111807030.21798@eggly.anvils> <50500360.5020700@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, 12 Sep 2012, Xiao Guangrong wrote:
> On 09/12/2012 10:03 AM, Hugh Dickins wrote:
> 
> > What brought me to look at it was hitting "BUG at mm/huge_memory.c:1842!"
> > running tmpfs kbuild swapping load (with memcg's memory.limit_in_bytes
> > forcing out to swap), while I happened to have CONFIG_NUMA=y.
> > 
> > That's the VM_BUG_ON(*hpage) on entry to khugepaged_alloc_page().
> 
> > 
> > So maybe 9/12 is just obscuring what was already a BUG, either earlier
> > in your series or elsewhere in mmotm (I've never seen it on 3.6-rc or
> > earlier releases, nor without CONFIG_NUMA).  I've not spent any time
> > looking for it, maybe it's obvious - can you spot and fix it?
> 
> Hugh,
> 
> I think i have already found the reason,

Great, thank you.

> if i am correct, the bug was existing before my patch.

Before your patchset?  Are you sure of that?

> 
> Could you please try below patch?

I put it on this morning, and ran load all day without a crash:
I think you indeed found the cause.

> And, could please allow me to fix the bug first,
> then post another patch to improve the things you dislike?

Good plan.

I've not yet glanced at your 2/3 and 3/3, I'm afraid.
I think akpm has helpfully included just 1/3 in the new mmotm.

> 
> Subject: [PATCH] thp: fix forgetting to reset the page alloc indicator
> 
> If NUMA is enabled, the indicator is not reset if the previous page
> request is failed, then it will trigger the BUG_ON in khugepaged_alloc_page
> 
> Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
> ---
>  mm/huge_memory.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index e366ca5..66d2bc6 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1825,6 +1825,7 @@ static bool khugepaged_prealloc_page(struct page **hpage, bool *wait)
>  			return false;
> 
>  		*wait = false;
> +		*hpage = NULL;
>  		khugepaged_alloc_sleep();
>  	} else if (*hpage) {
>  		put_page(*hpage);

The unshown line just below this is

		*hpage = NULL;

I do wish you would take the "*hpage = NULL;" out of if and else blocks
and place it once below both.

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
