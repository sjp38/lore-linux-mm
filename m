Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4239A6B007E
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 12:48:03 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id n63so129527992ywf.3
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 09:48:03 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id n24si27199561qki.131.2016.06.16.09.48.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jun 2016 09:48:02 -0700 (PDT)
Subject: Re: [PATCH] mm: fix account pmd page to the process
References: <1466076971-24609-1-git-send-email-zhongjiang@huawei.com>
 <20160616154214.GA12284@dhcp22.suse.cz>
 <20160616154324.GN6836@dhcp22.suse.cz>
 <71df66ac-df29-9542-bfa9-7c94f374df5b@oracle.com>
 <20160616163119.GP6836@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <bf76cc6c-a0da-98f9-4a89-0bb6161f5adf@oracle.com>
Date: Thu, 16 Jun 2016 09:47:46 -0700
MIME-Version: 1.0
In-Reply-To: <20160616163119.GP6836@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: zhongjiang <zhongjiang@huawei.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

On 06/16/2016 09:31 AM, Michal Hocko wrote:
> On Thu 16-06-16 09:05:23, Mike Kravetz wrote:
>> On 06/16/2016 08:43 AM, Michal Hocko wrote:
>>> [It seems that this patch has been sent several times and this
>>> particular copy didn't add Kirill who has added this code CC him now]
>>>
>>> On Thu 16-06-16 17:42:14, Michal Hocko wrote:
>>>> On Thu 16-06-16 19:36:11, zhongjiang wrote:
>>>>> From: zhong jiang <zhongjiang@huawei.com>
>>>>>
>>>>> when a process acquire a pmd table shared by other process, we
>>>>> increase the account to current process. otherwise, a race result
>>>>> in other tasks have set the pud entry. so it no need to increase it.
>>>>>
>>>>> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
>>>>> ---
>>>>>  mm/hugetlb.c | 5 ++---
>>>>>  1 file changed, 2 insertions(+), 3 deletions(-)
>>>>>
>>>>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>>>>> index 19d0d08..3b025c5 100644
>>>>> --- a/mm/hugetlb.c
>>>>> +++ b/mm/hugetlb.c
>>>>> @@ -4189,10 +4189,9 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
>>>>>  	if (pud_none(*pud)) {
>>>>>  		pud_populate(mm, pud,
>>>>>  				(pmd_t *)((unsigned long)spte & PAGE_MASK));
>>>>> -	} else {
>>>>> +	} else 
>>>>>  		put_page(virt_to_page(spte));
>>>>> -		mm_inc_nr_pmds(mm);
>>>>> -	}
>>>>
>>>> The code is quite puzzling but is this correct? Shouldn't we rather do
>>>> mm_dec_nr_pmds(mm) in that path to undo the previous inc?
>>
>> I agree that the code is quite puzzling. :(
>>
>> However, if this were an issue I would have expected to see some reports.
>> Oracle DB makes use of this feature (shared page tables) and if the pmd
>> count is wrong we would catch it in check_mm() at exit time.
>>
>> Upon closer examination, I believe the code in question is never executed.
>> Note the callers of huge_pmd_share.  The calling code looks like:
>>
>>                         if (want_pmd_share() && pud_none(*pud))
>>                                 pte = huge_pmd_share(mm, addr, pud);
>>                         else
>>                                 pte = (pte_t *)pmd_alloc(mm, pud, addr);
>>
>> Therefore, we do not call huge_pmd_share unless pud_none(*pud).  The
>> code in question is only executed when !pud_none(*pud).
> 
> My understanding is that the check is needed after we retake page lock
> because we might have raced with other thread. But it's been quite some
> time since I've looked at hugetlb locking and page table sharing code.

That is correct, we could have raced. Duh!

In the case of a race, the other thread would have incremented the
PMD count already.  Your suggestion of decrementing pmd count in
this case seems to be the correct approach.  But, I need to think
about this some more.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
