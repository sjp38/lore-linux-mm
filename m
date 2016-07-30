Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 60CE56B0253
	for <linux-mm@kvack.org>; Sat, 30 Jul 2016 02:35:33 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id o124so159473791pfg.1
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 23:35:33 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id 80si22721759pfo.201.2016.07.29.23.35.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 29 Jul 2016 23:35:32 -0700 (PDT)
Message-ID: <579C4A2E.4080009@huawei.com>
Date: Sat, 30 Jul 2016 14:33:18 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: + mm-hugetlb-fix-race-when-migrate-pages.patch added to -mm tree
References: <578eb28b.YbRUDGz5RloTVlrE%akpm@linux-foundation.org> <20160721074340.GA26398@dhcp22.suse.cz> <20160729112707.GB8031@dhcp22.suse.cz>
In-Reply-To: <20160729112707.GB8031@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, qiuxishi@huawei.com, vbabka@suse.cz, mm-commits@vger.kernel.org, Mike Kravetz <mike.kravetz@oracle.com>, Naoya
 Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org

On 2016/7/29 19:27, Michal Hocko wrote:
> On Thu 21-07-16 09:43:40, Michal Hocko wrote:
>> We have further discussed the patch and I believe it is not correct. See [1].
>> I am proposing the following alternative.
> Andrew, please drop the mm-hugetlb-fix-race-when-migrate-pages.patch. It
> is clearly racy. Whether the BUG_ON update is really the right and
> sufficient fix is not 100% clear yet and we are waiting for Zhong Jiang
> testing.
  The issue is very hard  to recur.   Without attaching any patch to kernel code. up to now,
   it still not happens to it.

  Thanks
  zhongjiang
>> [1] http://lkml.kernel.org/r/20160720132431.GM11249@dhcp22.suse.cz
>> ---
>> From b1e9b3214f1859fdf7d134cdcb56f5871933539c Mon Sep 17 00:00:00 2001
>> From: Michal Hocko <mhocko@suse.com>
>> Date: Thu, 21 Jul 2016 09:28:13 +0200
>> Subject: [PATCH] mm, hugetlb: fix huge_pte_alloc BUG_ON
>>
>> Zhong Jiang has reported a BUG_ON from huge_pte_alloc hitting when he
>> runs his database load with memory online and offline running in
>> parallel. The reason is that huge_pmd_share might detect a shared pmd
>> which is currently migrated and so it has migration pte which is
>> !pte_huge.
>>
>> There doesn't seem to be any easy way to prevent from the race and in
>> fact seeing the migration swap entry is not harmful. Both callers of
>> huge_pte_alloc are prepared to handle them. copy_hugetlb_page_range
>> will copy the swap entry and make it COW if needed. hugetlb_fault will
>> back off and so the page fault is retries if the page is still under
>> migration and waits for its completion in hugetlb_fault.
>>
>> That means that the BUG_ON is wrong and we should update it. Let's
>> simply check that all present ptes are pte_huge instead.
>>
>> Reported-by: zhongjiang <zhongjiang@huawei.com>
>> Signed-off-by: Michal Hocko <mhocko@suse.com>
>> ---
>>  mm/hugetlb.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index 34379d653aa3..31dd2b8b86b3 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -4303,7 +4303,7 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
>>  				pte = (pte_t *)pmd_alloc(mm, pud, addr);
>>  		}
>>  	}
>> -	BUG_ON(pte && !pte_none(*pte) && !pte_huge(*pte));
>> +	BUG_ON(pte && pte_present(*pte) && !pte_huge(*pte));
>>  
>>  	return pte;
>>  }
>> -- 
>> 2.8.1
>>
>> -- 
>> Michal Hocko
>> SUSE Labs


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
