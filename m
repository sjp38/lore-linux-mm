Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D81826B5121
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 01:23:16 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c18so565790edt.23
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 22:23:16 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g44si645662edc.151.2018.11.28.22.23.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Nov 2018 22:23:15 -0800 (PST)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wAT6Ifqf020665
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 01:23:14 -0500
Received: from e12.ny.us.ibm.com (e12.ny.us.ibm.com [129.33.205.202])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2p2a5a9gs2-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 01:23:13 -0500
Received: from localhost
	by e12.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Thu, 29 Nov 2018 06:23:13 -0000
Subject: Re: [PATCH V2 4/5] mm/hugetlb: Add prot_modify_start/commit sequence
 for hugetlb update
References: <20181128143438.29458-1-aneesh.kumar@linux.ibm.com>
 <20181128143438.29458-5-aneesh.kumar@linux.ibm.com>
 <20181128141051.ff38f23023f652759b06f828@linux-foundation.org>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Thu, 29 Nov 2018 11:53:06 +0530
MIME-Version: 1.0
In-Reply-To: <20181128141051.ff38f23023f652759b06f828@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <d7ee1b8c-2f45-f430-b413-9d511e7d78c4@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On 11/29/18 3:40 AM, Andrew Morton wrote:
> On Wed, 28 Nov 2018 20:04:37 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> wrote:
> 
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> 
> Some explanation of the motivation would be useful.

I will update the commit message.


> 
>>   include/linux/hugetlb.h | 18 ++++++++++++++++++
>>   mm/hugetlb.c            |  8 +++++---
>>   2 files changed, 23 insertions(+), 3 deletions(-)
>>
>> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
>> index 087fd5f48c91..e2a3b0c854eb 100644
>> --- a/include/linux/hugetlb.h
>> +++ b/include/linux/hugetlb.h
>> @@ -543,6 +543,24 @@ static inline void set_huge_swap_pte_at(struct mm_struct *mm, unsigned long addr
>>   	set_huge_pte_at(mm, addr, ptep, pte);
>>   }
>>   #endif
>> +
>> +#ifndef huge_ptep_modify_prot_start
>> +static inline pte_t huge_ptep_modify_prot_start(struct vm_area_struct *vma,
>> +						unsigned long addr, pte_t *ptep)
>> +{
>> +	return huge_ptep_get_and_clear(vma->vm_mm, addr, ptep);
>> +}
>> +#endif
> 
> #define huge_ptep_modify_prot_start huge_ptep_modify_prot_start
> 
>> +#ifndef huge_ptep_modify_prot_commit
>> +static inline void huge_ptep_modify_prot_commit(struct vm_area_struct *vma,
>> +						unsigned long addr, pte_t *ptep,
>> +						pte_t old_pte, pte_t pte)
>> +{
>> +	set_huge_pte_at(vma->vm_mm, addr, ptep, pte);
>> +}
>> +#endif
> 
> #define huge_ptep_modify_prot_commit huge_ptep_modify_prot_commit
> 
> 

Will update.

-aneesh
