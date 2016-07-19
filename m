Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id ECE676B0253
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 08:06:17 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id i64so38824256ith.2
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 05:06:17 -0700 (PDT)
Received: from szxga03-in.huawei.com ([119.145.14.66])
        by mx.google.com with ESMTPS id q130si2088632oif.124.2016.07.19.05.06.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Jul 2016 05:06:17 -0700 (PDT)
Message-ID: <578E1760.6000005@huawei.com>
Date: Tue, 19 Jul 2016 20:04:48 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/hugetlb: fix race when migrate pages.
References: <1468897140-43471-1-git-send-email-zhongjiang@huawei.com> <20160719091724.GD9490@dhcp22.suse.cz> <578DF872.3050507@huawei.com> <20160719111003.GG9486@dhcp22.suse.cz> <578E126A.7080001@huawei.com> <20160719115952.GI9486@dhcp22.suse.cz>
In-Reply-To: <20160719115952.GI9486@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, qiuxishi@huawei.com, linux-mm@kvack.org

On 2016/7/19 19:59, Michal Hocko wrote:
> On Tue 19-07-16 19:43:38, zhong jiang wrote:
> [...]
>>   diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index 6384dfd..baba196 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -4213,7 +4213,7 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
>>         struct vm_area_struct *svma;
>>         unsigned long saddr;
>>         pte_t *spte = NULL;
>> -       pte_t *pte;
>> +       pte_t *pte, entry;
>>         spinlock_t *ptl;
>>
>>         if (!vma_shareable(vma, addr))
>> @@ -4240,6 +4240,11 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
>>
>>         ptl = huge_pte_lockptr(hstate_vma(vma), mm, spte);
>>         spin_lock(ptl);
>> +       entry = huge_ptep_get(spte);
>> +       if (is_hugetlb_entry_migration(entry) ||
>> +                       is_hugetlb_entry_hwpoisoned(entry)) {
>> +               goto end;
>> +       }
>>         if (pud_none(*pud)) {
>>                 pud_populate(mm, pud,
>>                                 (pmd_t *)((unsigned long)spte & PAGE_MASK));
>> @@ -4247,6 +4252,7 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
>>                 put_page(virt_to_page(spte));
>>                 mm_dec_nr_pmds(mm);
>>         }
>> +end:
> out_unlock:
>
> would be more readable. Could you retest the patch, respin the changelog
> to explain what, why and how to fix it and repost again, please?
>
>>         spin_unlock(ptl);
>>  out:
>>         pte = (pte_t *)pmd_alloc(mm, pud, addr);
 ok ,  I will modify it later in v2.  thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
