Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id CF7D56B0093
	for <linux-mm@kvack.org>; Tue, 11 Sep 2012 22:35:53 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Wed, 12 Sep 2012 12:33:54 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q8C2QRcG29425896
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 12:26:28 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q8C2Zf04013043
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 12:35:43 +1000
Message-ID: <504FF4FA.80409@linux.vnet.ibm.com>
Date: Wed, 12 Sep 2012 10:35:38 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 09/12] thp: introduce khugepaged_prealloc_page and khugepaged_alloc_page
References: <5028E12C.70101@linux.vnet.ibm.com> <5028E20C.3080607@linux.vnet.ibm.com> <alpine.LSU.2.00.1209111807030.21798@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1209111807030.21798@eggly.anvils>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On 09/12/2012 10:03 AM, Hugh Dickins wrote:
> On Mon, 13 Aug 2012, Xiao Guangrong wrote:
> 
>> They are used to abstract the difference between NUMA enabled and NUMA disabled
>> to make the code more readable
>>
>> Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
>> ---
>>  mm/huge_memory.c |  166 ++++++++++++++++++++++++++++++++----------------------
>>  1 files changed, 98 insertions(+), 68 deletions(-)
> 
> Hmm, that in itself is not necessarily an improvement.
> 
> I'm a bit sceptical about this patch,
> thp-introduce-khugepaged_prealloc_page-and-khugepaged_alloc_page.patch
> in last Thursday's mmotm 2012-09-06-16-46.
> 
> What brought me to look at it was hitting "BUG at mm/huge_memory.c:1842!"
> running tmpfs kbuild swapping load (with memcg's memory.limit_in_bytes
> forcing out to swap), while I happened to have CONFIG_NUMA=y.
> 
> That's the VM_BUG_ON(*hpage) on entry to khugepaged_alloc_page().

I will look into it, thanks for your point it out.

> 
> (If I'm honest, I'll admit I have Michel's "interval trees for anon rmap"
> patches in on top, and so the line number was actually shifted to 1839:
> but I don't believe his patches were in any way involved here, and
> indeed I've not yet found a problem with them: they look very good.)
> 
> I expect the BUG could quite easily be fixed up by making another call
> to khugepaged_prealloc_page() from somewhere to free up the hpage;
> but forgive me if I dislike using "prealloc" to free.
> 
> I do agree with you that the several CONFIG_NUMA ifdefs dotted around
> mm/huge_memory.c are regrettable, but I'm not at all sure that you're
> improving the situation with this patch, which gives misleading names
> to functions and moves the mmap_sem upping out of line.
> 
> I think you need to revisit it: maybe not go so far (leaving a few
> CONFIG_NUMAs behind, if they're not too bad), or maybe go further
> (add a separate function for freeing in the NUMA case, instead of
> using "prealloc").  I don't know what's best: have a play and see.

Sorry for that, i will find a better way to do this.

> 
> That's what I was intending to write yesterday.  But overnight I
> was running with this 9/12 backed out (I think 10,11,12 should be
> independent), and found "BUG at mm/huge_memory.c:1835!" this morning.
> 
> That's the VM_BUG_ON(*hpage) below #else in collapse_huge_page()
> when 9/12 is reverted.
> 
> So maybe 9/12 is just obscuring what was already a BUG, either earlier
> in your series or elsewhere in mmotm (I've never seen it on 3.6-rc or
> earlier releases, nor without CONFIG_NUMA).  I've not spent any time
> looking for it, maybe it's obvious - can you spot and fix it?

Sure, will fix it as soon as possible. Thanks!


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
