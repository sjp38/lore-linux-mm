Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5740728089F
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 03:48:22 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 89so7615119wrr.1
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 00:48:22 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q4si916938wma.39.2017.02.09.00.48.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Feb 2017 00:48:20 -0800 (PST)
Subject: Re: [PATCH 3/3] mm: Enable Buddy allocation isolation for CDM nodes
References: <20170208140148.16049-1-khandual@linux.vnet.ibm.com>
 <20170208140148.16049-4-khandual@linux.vnet.ibm.com>
 <8ef1de25-d4fd-482c-c55e-df93d0730484@suse.cz>
 <8982ccfc-3b96-89bd-60e6-471971aee609@linux.vnet.ibm.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <dcfb962d-9832-8a82-d540-d259869ac9ec@suse.cz>
Date: Thu, 9 Feb 2017 09:48:18 +0100
MIME-Version: 1.0
In-Reply-To: <8982ccfc-3b96-89bd-60e6-471971aee609@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

On 02/09/2017 06:05 AM, Anshuman Khandual wrote:
> On 02/08/2017 10:48 PM, Vlastimil Babka wrote:
>> On 02/08/2017 03:01 PM, Anshuman Khandual wrote:
>>> This implements allocation isolation for CDM nodes in buddy allocator by
>>> discarding CDM memory zones all the time except in the cases where the
>>> gfp
>>> flag has got __GFP_THISNODE or the nodemask contains CDM nodes in cases
>>> where it is non NULL (explicit allocation request in the kernel or user
>>> process MPOL_BIND policy based requests).
>>>
>>> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
>>> ---
>>>  mm/page_alloc.c | 19 +++++++++++++++++++
>>>  1 file changed, 19 insertions(+)
>>>
>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>> index 40908de..7d8c82a 100644
>>> --- a/mm/page_alloc.c
>>> +++ b/mm/page_alloc.c
>>> @@ -64,6 +64,7 @@
>>>  #include <linux/page_owner.h>
>>>  #include <linux/kthread.h>
>>>  #include <linux/memcontrol.h>
>>> +#include <linux/node.h>
>>>
>>>  #include <asm/sections.h>
>>>  #include <asm/tlbflush.h>
>>> @@ -2908,6 +2909,24 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned
>>> int order, int alloc_flags,
>>>          struct page *page;
>>>          unsigned long mark;
>>>
>>> +        /*
>>> +         * CDM nodes get skipped if the requested gfp flag
>>> +         * does not have __GFP_THISNODE set or the nodemask
>>> +         * does not have any CDM nodes in case the nodemask
>>> +         * is non NULL (explicit allocation requests from
>>> +         * kernel or user process MPOL_BIND policy which has
>>> +         * CDM nodes).
>>> +         */
>>> +        if (is_cdm_node(zone->zone_pgdat->node_id)) {
>>> +            if (!(gfp_mask & __GFP_THISNODE)) {
>>> +                if (!ac->nodemask)
>>> +                    continue;
>>> +
>>> +                if (!nodemask_has_cdm(*ac->nodemask))
>>> +                    continue;
>>
>> nodemask_has_cdm() looks quite expensive, combined with the loop here
>> that's O(n^2). But I don't understand why you need it. If there is no
>> cdm node in the nodemask, then we never reach this code with a cdm node,
>> because the zonelist iterator already checks the nodemask? Am I missing
>> something?
>
> A CDM zone can be selected during zonelist iteration if
>
> 	(1) If nodemask is NULL (where all zones are eligible)
>
> 		(1) Skip it if __GFP_THISNODE is not mentioned
> 		(2) Pick it if __GFP_THISNODE is mentioned
>
> 	(2) If nodemask has CDM (where CDM zones are eligible)
>
> 		(1) Pick it if nodemask has CDM
> 		(2) Pick it if __GFP_THISNODE is mentioned
>
> (1) (1) Enforces the primary isolation
> (2) (1) Is the only option which could be O(n^2) as the worst case
>
> Checking for both the zone being a CDM zone and the nodemask containing
> CDM node has to happen together for (2) (1). But we dont run into this
> option unless we have first checked if request contains __GFP_THISNODE
> and that nodemask is really a non NULL value. Hence the number cases
> getting into (2) (1) should be less. IIUC only the user space MPOL_BIND
> ones will come here.

Maybe I'm still missing something, but when you do nodemask_has_cdm() above then 
we already passed "if (!ac->nodemask) continue" which means ac->nodemask is not 
null, which means the zonelist iterator already did the filtering on 
ac->nodemask, and if this zone passed the filter and it's a cdm zone, then it 
has to be set in the nodemask?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
