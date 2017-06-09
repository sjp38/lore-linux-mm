Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C944B6B0279
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 05:17:13 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g78so23209059pfg.4
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 02:17:13 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id 31si513663pli.289.2017.06.09.02.17.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Jun 2017 02:17:12 -0700 (PDT)
Message-ID: <593A6775.10203@huawei.com>
Date: Fri, 9 Jun 2017 17:16:37 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] mm: migrate: Stabilise page count when migrating
 transparent hugepages
References: <1496771916-28203-1-git-send-email-will.deacon@arm.com> <1496771916-28203-4-git-send-email-will.deacon@arm.com> <33165470-21b8-15d2-b952-a7bbf74ee83d@suse.cz> <20170608120721.GA10295@arm.com>
In-Reply-To: <20170608120721.GA10295@arm.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mark.rutland@arm.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, Punit.Agrawal@arm.com, mgorman@suse.de, steve.capper@arm.com

On 2017/6/8 20:07, Will Deacon wrote:
> On Thu, Jun 08, 2017 at 12:52:07PM +0200, Vlastimil Babka wrote:
>> On 06/06/2017 07:58 PM, Will Deacon wrote:
>>> When migrating a transparent hugepage, migrate_misplaced_transhuge_page
>>> guards itself against a concurrent fastgup of the page by checking that
>>> the page count is equal to 2 before and after installing the new pmd.
>>>
>>> If the page count changes, then the pmd is reverted back to the original
>>> entry, however there is a small window where the new (possibly writable)
>>> pmd is installed and the underlying page could be written by userspace.
>>> Restoring the old pmd could therefore result in loss of data.
>>>
>>> This patch fixes the problem by freezing the page count whilst updating
>>> the page tables, which protects against a concurrent fastgup without the
>>> need to restore the old pmd in the failure case (since the page count can
>>> no longer change under our feet).
>>>
>>> Cc: Mel Gorman <mgorman@suse.de>
>>> Signed-off-by: Will Deacon <will.deacon@arm.com>
>>> ---
>>>  mm/migrate.c | 15 ++-------------
>>>  1 file changed, 2 insertions(+), 13 deletions(-)
>>>
>>> diff --git a/mm/migrate.c b/mm/migrate.c
>>> index 89a0a1707f4c..8b21f1b1ec6e 100644
>>> --- a/mm/migrate.c
>>> +++ b/mm/migrate.c
>>> @@ -1913,7 +1913,6 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
>>>  	int page_lru = page_is_file_cache(page);
>>>  	unsigned long mmun_start = address & HPAGE_PMD_MASK;
>>>  	unsigned long mmun_end = mmun_start + HPAGE_PMD_SIZE;
>>> -	pmd_t orig_entry;
>>>  
>>>  	/*
>>>  	 * Rate-limit the amount of data that is being migrated to a node.
>>> @@ -1956,8 +1955,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
>>>  	/* Recheck the target PMD */
>>>  	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
>>>  	ptl = pmd_lock(mm, pmd);
>>> -	if (unlikely(!pmd_same(*pmd, entry) || page_count(page) != 2)) {
>>> -fail_putback:
>>> +	if (unlikely(!pmd_same(*pmd, entry) || !page_ref_freeze(page, 2))) {
>>>  		spin_unlock(ptl);
>>>  		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
>>>  
>>> @@ -1979,7 +1977,6 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
>>>  		goto out_unlock;
>>>  	}
>>>  
>>> -	orig_entry = *pmd;
>>>  	entry = mk_huge_pmd(new_page, vma->vm_page_prot);
>>>  	entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
>>>  
>>> @@ -1996,15 +1993,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
>> There's a comment above this:
>>
>>        /*
>>          * Clear the old entry under pagetable lock and establish the new PTE.
>>          * Any parallel GUP will either observe the old page blocking on the
>>          * page lock, block on the page table lock or observe the new page.
>>          * The SetPageUptodate on the new page and page_add_new_anon_rmap
>>          * guarantee the copy is visible before the pagetable update.
>>          */
>>
>> Is it still correct? Didn't the freezing prevent some of the cases above?
> I don't think the comment needs to change, the freezing is just doing
> correctly what the code tried to do before. Granted, the blocking might come
> about because of the count momentarily being set to 0 (and
> page_cache_add_speculative bailing), but that's just fastGUP implementation
> details, I think.
 I think it should be hold off the speculative , but the fastgup by userspace.
>>>  	set_pmd_at(mm, mmun_start, pmd, entry);
>>>  	update_mmu_cache_pmd(vma, address, &entry);
>>>  
>>> -	if (page_count(page) != 2) {
>> BTW, how did the old code recognize that page count would increase and then
>> decrease back?
> I'm not sure that case matters because the inc/dec would happen before the
> new PMD is put in place (otherwise it wouldn't be reachable via the
> fastGUP).
>
> Will
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
> .
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
