Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id E2DC66B03E3
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 01:34:33 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id y77so4580016wrb.22
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 22:34:33 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id o51si880755wrb.203.2017.04.05.22.34.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Apr 2017 22:34:32 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v365TJvf097936
	for <linux-mm@kvack.org>; Thu, 6 Apr 2017 01:34:31 -0400
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com [125.16.236.6])
	by mx0b-001b2d01.pphosted.com with ESMTP id 29nc4dyfx1-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 06 Apr 2017 01:34:30 -0400
Received: from localhost
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 6 Apr 2017 11:04:27 +0530
Received: from d28av06.in.ibm.com (d28av06.in.ibm.com [9.184.220.48])
	by d28relay07.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v365X6Ub9699580
	for <linux-mm@kvack.org>; Thu, 6 Apr 2017 11:03:06 +0530
Received: from d28av06.in.ibm.com (localhost [127.0.0.1])
	by d28av06.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v365YPRN021142
	for <linux-mm@kvack.org>; Thu, 6 Apr 2017 11:04:25 +0530
Subject: Re: [PATCH] mm, memory_hotplug: fix devm_memremap_pages() after
 memory_hotplug rework
References: <20170404165144.29791-1-jglisse@redhat.com>
 <a9d6e8d2-7bd9-abf1-9323-d175f10f7559@linux.vnet.ibm.com>
 <20170405104958.GI6035@dhcp22.suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 6 Apr 2017 11:04:20 +0530
MIME-Version: 1.0
In-Reply-To: <20170405104958.GI6035@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Message-Id: <12d241cc-b992-4576-c420-860bd5fd59d4@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>

On 04/05/2017 04:19 PM, Michal Hocko wrote:
> On Wed 05-04-17 16:05:23, Anshuman Khandual wrote:
>> On 04/04/2017 10:21 PM, Jerome Glisse wrote:
>>> Just a trivial fix.
>>>
>>> Signed-off-by: Jerome Glisse <jglisse@redhat.com>
>>> Cc: Michal Hocko <mhocko@suse.com>
>>> Cc: Dan Williams <dan.j.williams@intel.com>
>>> ---
>>>  kernel/memremap.c | 3 ++-
>>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/kernel/memremap.c b/kernel/memremap.c
>>> index faa9276..bbbe646 100644
>>> --- a/kernel/memremap.c
>>> +++ b/kernel/memremap.c
>>> @@ -366,7 +366,8 @@ void *devm_memremap_pages(struct device *dev, struct resource *res,
>>>  	error = arch_add_memory(nid, align_start, align_size);
>>>  	if (!error)
>>>  		move_pfn_range_to_zone(&NODE_DATA(nid)->node_zones[ZONE_DEVICE],
>>> -				align_start, align_size);
>>> +					align_start >> PAGE_SHIFT,
>>> +					align_size >> PAGE_SHIFT);
>>
>> All this while it was taking up addresses instead of PFNs ? Then
>> how it was working correctly before ?
> 
> Because this code was embeded inside the arch_add_memory which did the
> translation properly. See arch_add_memory implementations.

Got your point. Checked both mainline kernel and mmotm branch
v4.11-rc5-mmotm-2017-04-04-15-00, in both the places the code
snippet seems to be different than here. For example arch_add
_memory has the following signature instead.

arch_add_memory(nid, align_start, align_size, true);

and I dont see move_pfn_range_to_zone() at all. Which tree/
branch this patch is against ?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
