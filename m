Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0F42F6B0253
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 09:09:32 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id l5so168680372ioa.0
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 06:09:32 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTP id h13si3180468oib.90.2016.06.17.06.09.30
        for <linux-mm@kvack.org>;
        Fri, 17 Jun 2016 06:09:31 -0700 (PDT)
Message-ID: <5763F576.7080307@huawei.com>
Date: Fri, 17 Jun 2016 21:04:54 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix account pmd page to the process
References: <1466164575-13578-1-git-send-email-zhongjiang@huawei.com> <20160617122109.GE21670@dhcp22.suse.cz>
In-Reply-To: <20160617122109.GE21670@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: mike.kravetz@oracle.com, akpm@linux-foundation.org, kirill@shutemov.name, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2016/6/17 20:21, Michal Hocko wrote:
> On Fri 17-06-16 19:56:15, zhongjiang wrote:
>> From: zhong jiang <zhongjiang@huawei.com>
>>
>> hen a process acquire a pmd table shared by other process, we
>> increase the account to current process. otherwise, a race result
>> in other tasks have set the pud entry. so it no need to increase it.
> I have really hard time to understand (well even to parse) the
> changelog. What do you think about the following?
> "
> huge_pmd_share accounts the number of pmds incorrectly when it races
> with a parallel pud instantiation. vma_interval_tree_foreach will
> increase the counter but then has to recheck the pud with the pte lock
> held and the back off path should drop the increment. The previous
> code would lead to an elevated pmd count which shouldn't be very
> harmful (check_mm() might complain and oom_badness() might be marginally
> confused) but this is worth fixing.
>
> "
  Yes, it is better , thanks.
> But please note that I am still not 100% sure the race is real.
   we can not completely rule out the possibility of  race,  such implementation is common
    in the kernel.   The stability of the kernel will be guaranteed.
  
   Thanks
    zhongjiang
 
>> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
>> ---
>>  mm/hugetlb.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index 19d0d08..3072857 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -4191,7 +4191,7 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
>>  				(pmd_t *)((unsigned long)spte & PAGE_MASK));
>>  	} else {
>>  		put_page(virt_to_page(spte));
>> -		mm_inc_nr_pmds(mm);
>> +		mm_dec_nr_pmds(mm);
>>  	}
>>  	spin_unlock(ptl);
>>  out:
>> -- 
>> 1.8.3.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
