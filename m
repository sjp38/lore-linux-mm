Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 854F86B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 07:51:55 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id m101so35698883ioi.0
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 04:51:55 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id h132si5044922ita.44.2016.07.19.04.51.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Jul 2016 04:51:54 -0700 (PDT)
Message-ID: <578E126A.7080001@huawei.com>
Date: Tue, 19 Jul 2016 19:43:38 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/hugetlb: fix race when migrate pages.
References: <1468897140-43471-1-git-send-email-zhongjiang@huawei.com> <20160719091724.GD9490@dhcp22.suse.cz> <578DF872.3050507@huawei.com> <20160719111003.GG9486@dhcp22.suse.cz>
In-Reply-To: <20160719111003.GG9486@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, qiuxishi@huawei.com, linux-mm@kvack.org

On 2016/7/19 19:10, Michal Hocko wrote:
> On Tue 19-07-16 17:52:50, zhong jiang wrote:
>> On 2016/7/19 17:17, Michal Hocko wrote:
> [...]
>>> OK, so this states the problem. Although it would be helpful to be
>>> specific about which BUG has triggered because the above line doesn't
>>> match any in the current code. I assume this is 
>>>
>>> BUG_ON(pte && !pte_none(*pte) && !pte_huge(*pte))
>>>
>>> in huge_pte_alloc. Now the changelog is silent about what the actual
>>> problem is and what is the fix. Could you add this information please?
>>   Yes, it hit this BUG_ON() you had mentioned.  The pmd share function enable,  when
>>   I run online-offline memory , That will lead to pte_huge() return false.  beacuse
>>  it refer to the pmd may be ongoing  migration.
> OK, I see. But is the proposed fix correct? AFAIU you are retrying the
> VMA walk and nothing really prevents huge_pte_offset returning the same
> spte, right?
>  
   oh, I mistaked.  we should not repeat, it should directly  skip to end. 
  diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 6384dfd..baba196 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4213,7 +4213,7 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
        struct vm_area_struct *svma;
        unsigned long saddr;
        pte_t *spte = NULL;
-       pte_t *pte;
+       pte_t *pte, entry;
        spinlock_t *ptl;

        if (!vma_shareable(vma, addr))
@@ -4240,6 +4240,11 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)

        ptl = huge_pte_lockptr(hstate_vma(vma), mm, spte);
        spin_lock(ptl);
+       entry = huge_ptep_get(spte);
+       if (is_hugetlb_entry_migration(entry) ||
+                       is_hugetlb_entry_hwpoisoned(entry)) {
+               goto end;
+       }
        if (pud_none(*pud)) {
                pud_populate(mm, pud,
                                (pmd_t *)((unsigned long)spte & PAGE_MASK));
@@ -4247,6 +4252,7 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
                put_page(virt_to_page(spte));
                mm_dec_nr_pmds(mm);
        }
+end:
        spin_unlock(ptl);
 out:
        pte = (pte_t *)pmd_alloc(mm, pud, addr);

>>  Thanks
>>  zhong jiang
>>>> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
>>>> ---
>>>>  mm/hugetlb.c | 9 ++++++++-
>>>>  1 file changed, 8 insertions(+), 1 deletion(-)
>>>>
>>>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>>>> index 6384dfd..1b54d7a 100644
>>>> --- a/mm/hugetlb.c
>>>> +++ b/mm/hugetlb.c
>>>> @@ -4213,13 +4213,14 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
>>>>  	struct vm_area_struct *svma;
>>>>  	unsigned long saddr;
>>>>  	pte_t *spte = NULL;
>>>> -	pte_t *pte;
>>>> +	pte_t *pte, entry;
>>>>  	spinlock_t *ptl;
>>>>  
>>>>  	if (!vma_shareable(vma, addr))
>>>>  		return (pte_t *)pmd_alloc(mm, pud, addr);
>>>>  
>>>>  	i_mmap_lock_write(mapping);
>>>> +retry:
>>>>  	vma_interval_tree_foreach(svma, &mapping->i_mmap, idx, idx) {
>>>>  		if (svma == vma)
>>>>  			continue;
>>>> @@ -4240,6 +4241,12 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
>>>>  
>>>>  	ptl = huge_pte_lockptr(hstate_vma(vma), mm, spte);
>>>>  	spin_lock(ptl);
>>>> +	entry = huge_ptep_get(spte);
>>>> + 	if (is_hugetlb_entry_migration(entry) || 
>>>> +			is_hugetlb_entry_hwpoisoned(entry)) {
>>>> +		spin_unlock(ptl);
>>>> +		goto retry;
>>>> +	}	
>>>>  	if (pud_none(*pud)) {
>>>>  		pud_populate(mm, pud,
>>>>  				(pmd_t *)((unsigned long)spte & PAGE_MASK));
>>>> -- 
>>>> 1.8.3.1
>>>>
>>>> --
>>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>>> see: http://www.linux-mm.org/ .
>>>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
