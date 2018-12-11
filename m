Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E1E378E0095
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 10:18:19 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id b3so7121089edi.0
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 07:18:19 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id c17-v6si410561ejp.239.2018.12.11.07.18.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 07:18:18 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wBBFDe2K081125
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 10:18:16 -0500
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2pafbx9eqm-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 10:18:15 -0500
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zaslonko@linux.bm.com>;
	Tue, 11 Dec 2018 15:18:14 -0000
Subject: Re: [PATCH 1/1] mm, memory_hotplug: Initialize struct pages for the
 full memory section
References: <20181210130712.30148-1-zaslonko@linux.ibm.com>
 <20181210130712.30148-2-zaslonko@linux.ibm.com>
 <20181210132451.GO1286@dhcp22.suse.cz>
 <bcf681ea-7944-0a16-fbd4-c79ab176e638@linux.bm.com>
 <20181210162410.GT1286@dhcp22.suse.cz>
From: Zaslonko Mikhail <zaslonko@linux.bm.com>
Date: Tue, 11 Dec 2018 16:18:02 +0100
MIME-Version: 1.0
In-Reply-To: <20181210162410.GT1286@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <97b60ec7-2b95-91e5-80a6-aeae305cc696@linux.bm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Zaslonko Mikhail <zaslonko@linux.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pavel.Tatashin@microsoft.com, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, gerald.schaefer@de.ibm.com



On 10.12.2018 19:19, Michal Hocko wrote:
> On Mon 10-12-18 16:45:37, Zaslonko Mikhail wrote:
>> Hello,
>>
>> On 10.12.2018 14:24, Michal Hocko wrote:
> [...]
>>> Why do we need to restrict this to the highest zone? In other words, why
>>> cannot we do what I was suggesting earlier [1]. What does prevent other
>>> zones to have an incomplete section boundary?
>>
>> Well, as you were also suggesting earlier: 'If we do not have a zone which
>> spans the rest of the section'. I'm not sure how else we should verify that.
> 
> I am not sure I follow here. Why cannot we simply drop end_pfn check and
> keep the rest?
> 
>> Moreover, I was able to recreate the problem only with the highest zone
>> (memory end is not on the section boundary).
> 
> What exactly prevents exactmap memmap to generate these unfinished zones?

Probably you're right. I'm re-sending the patch V2.

> 
>>> [1] http://lkml.kernel.org/r/20181105183533.GQ4361@dhcp22.suse.cz
>>>
>>>> Signed-off-by: Mikhail Zaslonko <zaslonko@linux.ibm.com>
>>>> Reviewed-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
>>>> Cc: <stable@vger.kernel.org>
>>>> ---
>>>>  mm/page_alloc.c | 15 +++++++++++++++
>>>>  1 file changed, 15 insertions(+)
>>>>
>>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>>> index 2ec9cc407216..41ef5508e5f1 100644
>>>> --- a/mm/page_alloc.c
>>>> +++ b/mm/page_alloc.c
>>>> @@ -5542,6 +5542,21 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>>>>  			cond_resched();
>>>>  		}
>>>>  	}
>>>> +#ifdef CONFIG_SPARSEMEM
>>>> +	/*
>>>> +	 * If there is no zone spanning the rest of the section
>>>> +	 * then we should at least initialize those pages. Otherwise we
>>>> +	 * could blow up on a poisoned page in some paths which depend
>>>> +	 * on full sections being initialized (e.g. memory hotplug).
>>>> +	 */
>>>> +	if (end_pfn == max_pfn) {
>>>> +		while (end_pfn % PAGES_PER_SECTION) {
>>>> +			__init_single_page(pfn_to_page(end_pfn), end_pfn, zone,
>>>> +					   nid);
>>>> +			end_pfn++;
>>>> +		}
>>>> +	}
>>>> +#endif
>>>>  }
>>>>  
>>>>  #ifdef CONFIG_ZONE_DEVICE
>>>> -- 
>>>> 2.16.4
>>>
>>
>> Thanks,
>> Mikhail Zaslonko
> 
