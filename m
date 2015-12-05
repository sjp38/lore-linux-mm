Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id BC2006B0258
	for <linux-mm@kvack.org>; Sat,  5 Dec 2015 03:25:05 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so98463674pac.3
        for <linux-mm@kvack.org>; Sat, 05 Dec 2015 00:25:05 -0800 (PST)
Received: from e28smtp03.in.ibm.com (e28smtp03.in.ibm.com. [122.248.162.3])
        by mx.google.com with ESMTPS id 28si25312981pfk.134.2015.12.05.00.25.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 05 Dec 2015 00:25:04 -0800 (PST)
Received: from localhost
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 5 Dec 2015 13:55:01 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 5EC10394005C
	for <linux-mm@kvack.org>; Sat,  5 Dec 2015 13:54:53 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id tB58OqZX131480
	for <linux-mm@kvack.org>; Sat, 5 Dec 2015 13:54:52 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id tB58OpCY021148
	for <linux-mm@kvack.org>; Sat, 5 Dec 2015 13:54:52 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] mm: thp: introduce thp_mmu_gather to pin tail pages during MMU gather
In-Reply-To: <20151123160302.GX5078@redhat.com>
References: <1447938052-22165-1-git-send-email-aarcange@redhat.com> <1447938052-22165-2-git-send-email-aarcange@redhat.com> <20151119162255.b73e9db832501b40e1850c1a@linux-foundation.org> <20151123160302.GX5078@redhat.com>
Date: Sat, 05 Dec 2015 13:54:51 +0530
Message-ID: <87poyl5mlo.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, "\\\"Kirill A. Shutemov\\\"" <kirill@shutemov.name>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>

Andrea Arcangeli <aarcange@redhat.com> writes:

> On Thu, Nov 19, 2015 at 04:22:55PM -0800, Andrew Morton wrote:
>> On Thu, 19 Nov 2015 14:00:51 +0100 Andrea Arcangeli <aarcange@redhat.com> wrote:
>> 
>> > This theoretical SMP race condition was found with source review. No
>> > real life app could be affected as the result of freeing memory while
>> > accessing it is either undefined or it's a workload the produces no
>> > information.
>> > 
>> > For something to go wrong because the SMP race condition triggered,
>> > it'd require a further tiny window within the SMP race condition
>> > window. So nothing bad is happening in practice even if the SMP race
>> > condition triggers. It's still better to apply the fix to have the
>> > math guarantee.
>> > 
>> > The fix just adds a thp_mmu_gather atomic_t counter to the THP pages,
>> > so split_huge_page can elevate the tail page count accordingly and
>> > leave the tail page freeing task to whoever elevated thp_mmu_gather.
>> > 
>> 
>> This is a pretty nasty patch :( We now have random page*'s with bit 0
>> set floating around in mmu_gather.__pages[].  It assumes/requires that
>
> Yes, and bit 0 is only relevant for the mmu_gather structure and its
> users.
>
>> nobody uses those pages until they hit release_pages().  And the tlb
>> flushing code is pretty twisty, with various Kconfig and arch dependent
>> handlers.
>
> I already reviewed all callers and the mmu_gather freeing path for all
> archs to be sure they all take the two paths that I updated in order
> to free the pages. They call free_page_and_swap_cache or
> free_pages_and_swap_cache.
>
> The freeing is using common code VM functions, and it shouldn't
> improvise calling put_page() manually, the freeing has to take care of
> collecting the swapcache if needed etc... it has to deal with VM
> details the arch is not aware about.


But it is still lot of really complicated code. 

>
>> Is there no nicer way?
>
> We can grow the size of the mmu_gather to keep track that the page was
> THP before the pmd_lock was dropped, in a separate bit from the struct
> page pointer, but it'll take more memory.
>
> This bit 0 looks a walk in the park if compared to the bit 0 in
> page->compound_head that was just introduced. The compound_head bit 0
> isn't only visible to the mmu_gather users (which should never try to
> mess with the page pointer themself) and it collides with lru/next,
> rcu_head.next users.
>
> If you prefer me to enlarge the mmu_gather structure I can do that.
>

If we can update mmu_gather to track the page size of the pages, that
will also help some archs to better implement tlb_flush(struct
mmu_gather *). Right now arch/powerpc/mm/tlb_nohash.c does flush the tlb
mapping for the entire mm_struct. 

we can also make sure that we do a force flush when we are trying to
gather pages of different size. So one instance of mmu_gather will end
up gathering pages of specific size only ?


> 1 bit of extra information needs to be extracted before dropping the
> pmd_lock in zap_huge_pmd() and it has to be available in
> release_pages(), to know if the tail pages needs an explicit put_page
> or not. It's basically a bit in the local stack, except it's not in
> the local stack because it is an array of pages, so it needs many
> bits and it's stored in the mmu_gather along the page.
>
> Aside from the implementation of bit 0, I can't think of a simpler
> design that provides for the same performance and low locking overhead
> (this patch actually looks like an optimization when it's not helping
> to prevent the race, because to fix the race I had to reduce the
> number of times the lru_lock is taken in release_pages).
>
>> > +/*
>> > + * free_trans_huge_page_list() is used to free the pages returned by
>> > + * trans_huge_page_release() (if still PageTransHuge()) in
>> > + * release_pages().
>> > + */
>> 
>> There is no function trans_huge_page_release().
>
> Oops I updated the function name but not the comment... thanks!
> Andrea
>
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index f7ae08f..2810322 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -225,9 +225,8 @@ static inline int trans_huge_mmu_gather_count(struct page *page)
>  }
>  
>  /*
> - * free_trans_huge_page_list() is used to free the pages returned by
> - * trans_huge_page_release() (if still PageTransHuge()) in
> - * release_pages().
> + * free_trans_huge_page_list() is used to free THP pages (if still
> + * PageTransHuge()) in release_pages().
>   */
>  extern void free_trans_huge_page_list(struct list_head *list);
>  
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
