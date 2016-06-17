Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id D91FC6B0005
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 07:23:43 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id b13so125635985pat.3
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 04:23:43 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id n8si16540828paw.216.2016.06.17.04.23.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Jun 2016 04:23:42 -0700 (PDT)
Message-ID: <5763DC85.8080707@huawei.com>
Date: Fri, 17 Jun 2016 19:18:29 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix account pmd page to the process
References: <1466076971-24609-1-git-send-email-zhongjiang@huawei.com> <20160616154214.GA12284@dhcp22.suse.cz>
In-Reply-To: <20160616154214.GA12284@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2016/6/16 23:42, Michal Hocko wrote:
> On Thu 16-06-16 19:36:11, zhongjiang wrote:
>> From: zhong jiang <zhongjiang@huawei.com>
>>
>> when a process acquire a pmd table shared by other process, we
>> increase the account to current process. otherwise, a race result
>> in other tasks have set the pud entry. so it no need to increase it.
>>
>> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
>> ---
>>  mm/hugetlb.c | 5 ++---
>>  1 file changed, 2 insertions(+), 3 deletions(-)
>>
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index 19d0d08..3b025c5 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -4189,10 +4189,9 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
>>  	if (pud_none(*pud)) {
>>  		pud_populate(mm, pud,
>>  				(pmd_t *)((unsigned long)spte & PAGE_MASK));
>> -	} else {
>> +	} else 
>>  		put_page(virt_to_page(spte));
>> -		mm_inc_nr_pmds(mm);
>> -	}
> The code is quite puzzling but is this correct? Shouldn't we rather do
> mm_dec_nr_pmds(mm) in that path to undo the previous inc?
  Yes, you are right. I will modify it in V2.
 
  Thanks
  zhongjiang
>
>> +
>>  	spin_unlock(ptl);
>>  out:
>>  	pte = (pte_t *)pmd_alloc(mm, pud, addr);
>> -- 
>> 1.8.3.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
