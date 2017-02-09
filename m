Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id EB5E56B0387
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 05:11:03 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id 67so19518529ioh.1
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 02:11:03 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id o124si4360425itc.58.2017.02.09.02.11.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Feb 2017 02:11:03 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v19A9nJk033978
	for <linux-mm@kvack.org>; Thu, 9 Feb 2017 05:11:02 -0500
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28g8kgft79-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 09 Feb 2017 05:11:02 -0500
Received: from localhost
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 9 Feb 2017 20:10:58 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id D2CCA3578058
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 21:10:55 +1100 (EST)
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v19AAlFC28180692
	for <linux-mm@kvack.org>; Thu, 9 Feb 2017 21:10:55 +1100
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v19AANdZ012297
	for <linux-mm@kvack.org>; Thu, 9 Feb 2017 21:10:23 +1100
Subject: Re: [PATCH 3/3] mm: Enable Buddy allocation isolation for CDM nodes
References: <20170208140148.16049-1-khandual@linux.vnet.ibm.com>
 <20170208140148.16049-4-khandual@linux.vnet.ibm.com>
 <8ef1de25-d4fd-482c-c55e-df93d0730484@suse.cz>
 <8982ccfc-3b96-89bd-60e6-471971aee609@linux.vnet.ibm.com>
 <dcfb962d-9832-8a82-d540-d259869ac9ec@suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 9 Feb 2017 15:39:58 +0530
MIME-Version: 1.0
In-Reply-To: <dcfb962d-9832-8a82-d540-d259869ac9ec@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Message-Id: <81ae434a-0c67-c11a-e052-8b33b39c2152@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

On 02/09/2017 02:18 PM, Vlastimil Babka wrote:
> On 02/09/2017 06:05 AM, Anshuman Khandual wrote:
>> On 02/08/2017 10:48 PM, Vlastimil Babka wrote:
>>> On 02/08/2017 03:01 PM, Anshuman Khandual wrote:
>>>> This implements allocation isolation for CDM nodes in buddy
>>>> allocator by
>>>> discarding CDM memory zones all the time except in the cases where the
>>>> gfp
>>>> flag has got __GFP_THISNODE or the nodemask contains CDM nodes in cases
>>>> where it is non NULL (explicit allocation request in the kernel or user
>>>> process MPOL_BIND policy based requests).
>>>>
>>>> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
>>>> ---
>>>>  mm/page_alloc.c | 19 +++++++++++++++++++
>>>>  1 file changed, 19 insertions(+)
>>>>
>>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>>> index 40908de..7d8c82a 100644
>>>> --- a/mm/page_alloc.c
>>>> +++ b/mm/page_alloc.c
>>>> @@ -64,6 +64,7 @@
>>>>  #include <linux/page_owner.h>
>>>>  #include <linux/kthread.h>
>>>>  #include <linux/memcontrol.h>
>>>> +#include <linux/node.h>
>>>>
>>>>  #include <asm/sections.h>
>>>>  #include <asm/tlbflush.h>
>>>> @@ -2908,6 +2909,24 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned
>>>> int order, int alloc_flags,
>>>>          struct page *page;
>>>>          unsigned long mark;
>>>>
>>>> +        /*
>>>> +         * CDM nodes get skipped if the requested gfp flag
>>>> +         * does not have __GFP_THISNODE set or the nodemask
>>>> +         * does not have any CDM nodes in case the nodemask
>>>> +         * is non NULL (explicit allocation requests from
>>>> +         * kernel or user process MPOL_BIND policy which has
>>>> +         * CDM nodes).
>>>> +         */
>>>> +        if (is_cdm_node(zone->zone_pgdat->node_id)) {
>>>> +            if (!(gfp_mask & __GFP_THISNODE)) {
>>>> +                if (!ac->nodemask)
>>>> +                    continue;
>>>> +
>>>> +                if (!nodemask_has_cdm(*ac->nodemask))
>>>> +                    continue;
>>>
>>> nodemask_has_cdm() looks quite expensive, combined with the loop here
>>> that's O(n^2). But I don't understand why you need it. If there is no
>>> cdm node in the nodemask, then we never reach this code with a cdm node,
>>> because the zonelist iterator already checks the nodemask? Am I missing
>>> something?
>>
>> A CDM zone can be selected during zonelist iteration if
>>
>>     (1) If nodemask is NULL (where all zones are eligible)
>>
>>         (1) Skip it if __GFP_THISNODE is not mentioned
>>         (2) Pick it if __GFP_THISNODE is mentioned
>>
>>     (2) If nodemask has CDM (where CDM zones are eligible)
>>
>>         (1) Pick it if nodemask has CDM
>>         (2) Pick it if __GFP_THISNODE is mentioned
>>
>> (1) (1) Enforces the primary isolation
>> (2) (1) Is the only option which could be O(n^2) as the worst case
>>
>> Checking for both the zone being a CDM zone and the nodemask containing
>> CDM node has to happen together for (2) (1). But we dont run into this
>> option unless we have first checked if request contains __GFP_THISNODE
>> and that nodemask is really a non NULL value. Hence the number cases
>> getting into (2) (1) should be less. IIUC only the user space MPOL_BIND
>> ones will come here.
> 
> Maybe I'm still missing something, but when you do nodemask_has_cdm()
> above then we already passed "if (!ac->nodemask) continue" which means
> ac->nodemask is not null, which means the zonelist iterator already did
> the filtering on ac->nodemask, and if this zone passed the filter and
> it's a cdm zone, then it has to be set in the nodemask?

Hmm, think you are right. Then I can drop the last check there. Will test
it out. Thanks for pointing this out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
