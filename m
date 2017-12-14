Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 21DA46B0261
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 08:30:45 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id c67so3436044qkj.19
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 05:30:45 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id y196si3699555qky.74.2017.12.14.05.30.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 05:30:44 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vBEDT8Kn134682
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 08:30:44 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2eus24394b-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 08:30:43 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 14 Dec 2017 13:30:40 -0000
Subject: Re: [PATCH V2] mm/mprotect: Add a cond_resched() inside
 change_pmd_range()
References: <20171214111426.25912-1-khandual@linux.vnet.ibm.com>
 <20171214112928.GH16951@dhcp22.suse.cz>
 <28e54a80-73d9-76aa-31d5-f71375f14b96@linux.vnet.ibm.com>
 <20171214130435.GL16951@dhcp22.suse.cz>
 <cc03168b-dd53-73e7-88fd-717eba6e6ce0@linux.vnet.ibm.com>
 <20171214132753.GN16951@dhcp22.suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 14 Dec 2017 19:00:36 +0530
MIME-Version: 1.0
In-Reply-To: <20171214132753.GN16951@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <988a79ce-2803-85e7-d810-b4b2d4ba6b26@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

On 12/14/2017 06:57 PM, Michal Hocko wrote:
> On Thu 14-12-17 18:50:41, Anshuman Khandual wrote:
>> On 12/14/2017 06:34 PM, Michal Hocko wrote:
>>> On Thu 14-12-17 18:25:54, Anshuman Khandual wrote:
>>>> On 12/14/2017 04:59 PM, Michal Hocko wrote:
>>>>> On Thu 14-12-17 16:44:26, Anshuman Khandual wrote:
>>>>>> diff --git a/mm/mprotect.c b/mm/mprotect.c
>>>>>> index ec39f73..43c29fa 100644
>>>>>> --- a/mm/mprotect.c
>>>>>> +++ b/mm/mprotect.c
>>>>>> @@ -196,6 +196,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
>>>>>>  		this_pages = change_pte_range(vma, pmd, addr, next, newprot,
>>>>>>  				 dirty_accountable, prot_numa);
>>>>>>  		pages += this_pages;
>>>>>> +		cond_resched();
>>>>>>  	} while (pmd++, addr = next, addr != end);
>>>>>>  
>>>>>>  	if (mni_start)
>>>>> this is not exactly what I meant. See how change_huge_pmd does continue.
>>>>> That's why I mentioned zap_pmd_range which does goto next...
>>>> I might be still missing something but is this what you meant ?
>>> yes, except
>>>
>>>> Here we will give cond_resched() cover to the THP backed pages
>>>> as well.
>>> but there is still 
>>> 		if (!is_swap_pmd(*pmd) && !pmd_trans_huge(*pmd) && !pmd_devmap(*pmd)
>>> 				&& pmd_none_or_clear_bad(pmd))
>>> 			continue;
>>>
>>> so we won't have scheduling point on pmd holes. Maybe this doesn't
>>> matter, I haven't checked but why should we handle those differently?
>>
>> May be because it is not spending much time for those entries which
>> can really trigger stalls, hence they dont need scheduling points.
>> In case of zap_pmd_range(), it was spending time either in
>> __split_huge_pmd() or zap_huge_pmd() hence deserved a scheduling point.
> 
> As I've said, I haven't thought much about that but the discrepancy just
> hit my eyes. So if there is not a really good reason I would rather use
> goto next consistently.

Sure, will respin with the changes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
