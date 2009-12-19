Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0335F6B0047
	for <linux-mm@kvack.org>; Sat, 19 Dec 2009 01:44:18 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBJ6iFYF014410
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 19 Dec 2009 15:44:16 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A9E1C45DE4F
	for <linux-mm@kvack.org>; Sat, 19 Dec 2009 15:44:15 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8935045DE4E
	for <linux-mm@kvack.org>; Sat, 19 Dec 2009 15:44:15 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E3101DB803B
	for <linux-mm@kvack.org>; Sat, 19 Dec 2009 15:44:15 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 181151DB803C
	for <linux-mm@kvack.org>; Sat, 19 Dec 2009 15:44:12 +0900 (JST)
Message-ID: <b4bc03c186ec13918aed7421ced4aea7.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <4B2C4BE3.3030104@gmail.com>
References: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>
    <20091216101107.GA15031@basil.fritz.box>
    <20091216191312.f4655dac.kamezawa.hiroyu@jp.fujitsu.com>
    <20091216102806.GC15031@basil.fritz.box>
    <28c262360912160231r18db8478sf41349362360cab8@mail.gmail.com>
    <20091216193315.14a508d5.kamezawa.hiroyu@jp.fujitsu.com>
    <20091218093849.8ba69ad9.kamezawa.hiroyu@jp.fujitsu.com>
    <20091218094513.490f27b4.kamezawa.hiroyu@jp.fujitsu.com>
    <4B2C4BE3.3030104@gmail.com>
Date: Sat, 19 Dec 2009 15:44:11 +0900 (JST)
Subject: Re: [RFC 3/4] lockless vma caching
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Minchan Kim wrote:
>
>
> KAMEZAWA Hiroyuki wrote:
>> For accessing vma in lockless style, some modification for vma lookup is
>> required. Now, rb-tree is used and it doesn't allow read while
>> modification.
>>
>> This is a trial to caching vma rather than diving into rb-tree. The last
>> fault vma is cached to pgd's page->cached_vma field. And, add reference
>> count
>> and waitqueue to vma.
>>
>> The accessor will have to do
>>
>> 	vma = lookup_vma_cache(mm, address);
>> 	if (vma) {
>> 		if (mm_check_version(mm) && /* no write lock at this point ? */
>> 		    (vma->vm_start <= address) && (vma->vm_end > address))
>> 			goto found_vma; /* start speculative job */
>> 		else
>> 			vma_release_cache(vma);
>> 		vma = NULL;
>> 	}
>> 	vma = find_vma();
>> found_vma:
>> 	....do some jobs....
>> 	vma_release_cache(vma);
>>
>> Maybe some more consideration for invalidation point is necessary.
>>
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> ---
>>  include/linux/mm.h       |   20 +++++++++
>>  include/linux/mm_types.h |    5 ++
>>  mm/memory.c              |   14 ++++++
>>  mm/mmap.c                |  102
>> +++++++++++++++++++++++++++++++++++++++++++++--
>>  mm/page_alloc.c          |    1
>>  5 files changed, 138 insertions(+), 4 deletions(-)
>>
>> Index: mmotm-mm-accessor/include/linux/mm.h
>> ===================================================================
>> --- mmotm-mm-accessor.orig/include/linux/mm.h
>> +++ mmotm-mm-accessor/include/linux/mm.h
>> @@ -763,6 +763,26 @@ unsigned long unmap_vmas(struct mmu_gath
>>  		unsigned long end_addr, unsigned long *nr_accounted,
>>  		struct zap_details *);
>>
>> +struct vm_area_struct *lookup_vma_cache(struct mm_struct *mm,
>> +		unsigned long address);
>> +void invalidate_vma_cache(struct mm_struct *mm,
>> +		struct vm_area_struct *vma);
>> +void wait_vmas_cache_range(struct vm_area_struct *vma, unsigned long
>> end);
>> +
>> +static inline void vma_hold(struct vm_area_struct *vma)
> Nitpick:
> How about static inline void vma_cache_[get/put] naming?
>
Hmm. yes, put/get is popular name for this kind of counters.
Why I don't use put/get name is that this counter's purpose is
for helping cache. So, I avoided popular name.
I may change my mind in the next version ;)

>> +{
>> +	atomic_inc(&vma->cache_access);
>> +}
>> +
>> +void __vma_release(struct vm_area_struct *vma);
>> +static inline void vma_release(struct vm_area_struct *vma)
>> +{
>> +	if (atomic_dec_and_test(&vma->cache_access)) {
>> +		if (waitqueue_active(&vma->cache_wait))
>> +			__vma_release(vma);
>> +	}
>> +}
>> +
>>  /**
>>   * mm_walk - callbacks for walk_page_range
>>   * @pgd_entry: if set, called for each non-empty PGD (top-level) entry
>> Index: mmotm-mm-accessor/include/linux/mm_types.h
>> ===================================================================
>> --- mmotm-mm-accessor.orig/include/linux/mm_types.h
>> +++ mmotm-mm-accessor/include/linux/mm_types.h
>> @@ -12,6 +12,7 @@
>>  #include <linux/completion.h>
>>  #include <linux/cpumask.h>
>>  #include <linux/page-debug-flags.h>
>> +#include <linux/wait.h>
>>  #include <asm/page.h>
>>  #include <asm/mmu.h>
>>
>> @@ -77,6 +78,7 @@ struct page {
>>  	union {
>>  		pgoff_t index;		/* Our offset within mapping. */
>>  		void *freelist;		/* SLUB: freelist req. slab lock */
>> +		void *cache;
>
> Let's add annotation "/* vm_area_struct cache when the page is used as
> page table */".
>
ok.

>
>>  	};
>>  	struct list_head lru;		/* Pageout list, eg. active_list
>>  					 * protected by zone->lru_lock !
>> @@ -180,6 +182,9 @@ struct vm_area_struct {
>>  	void * vm_private_data;		/* was vm_pte (shared mem) */
>>  	unsigned long vm_truncate_count;/* truncate_count or restart_addr */
>>
>> +	atomic_t cache_access;
>> +	wait_queue_head_t cache_wait;
>> +
>>  #ifndef CONFIG_MMU
>>  	struct vm_region *vm_region;	/* NOMMU mapping region */
>>  #endif
>> Index: mmotm-mm-accessor/mm/memory.c
>> ===================================================================
>> --- mmotm-mm-accessor.orig/mm/memory.c
>> +++ mmotm-mm-accessor/mm/memory.c
>> @@ -145,6 +145,14 @@ void pmd_clear_bad(pmd_t *pmd)
>>  	pmd_clear(pmd);
>>  }
>>
>
> Let's put the note here. "The caller needs to hold the pte lock"
>
Sure.

>> +static void update_vma_cache(pmd_t *pmd, struct vm_area_struct *vma)
>> +{
>> +	struct page *page;
>> +	/* ptelock is held */
>> +	page = pmd_page(*pmd);
>> +	page->cache = vma;
>> +}
>> +
>>  /*
>>   * Note: this doesn't free the actual pages themselves. That
>>   * has been handled earlier when unmapping all the memory regions.
>> @@ -2118,6 +2126,7 @@ reuse:
>>  		if (ptep_set_access_flags(vma, address, page_table, entry,1))
>>  			update_mmu_cache(vma, address, entry);
>>  		ret |= VM_FAULT_WRITE;
>> +		update_vma_cache(pmd, vma);
>>  		goto unlock;
>>  	}
>>
> ..
> <snip>
> ..
>
>> Index: mmotm-mm-accessor/mm/page_alloc.c
>> ===================================================================
>> --- mmotm-mm-accessor.orig/mm/page_alloc.c
>> +++ mmotm-mm-accessor/mm/page_alloc.c
>> @@ -698,6 +698,7 @@ static int prep_new_page(struct page *pa
>>
>>  	set_page_private(page, 0);
>>  	set_page_refcounted(page);
>> +	page->cache = NULL;
>
> Is here is proper place to initialize page->cache?
> It cause unnecessary overhead about not pmd page.
>
> How about pmd_alloc?
>
The macro pmd_xxx was complicated and scattered over headers,
so I clear it here.
But yes, you're right. I'll do so when I write a patch, not-for-trial.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
