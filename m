Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id A7F4B6B01FE
	for <linux-mm@kvack.org>; Wed,  1 May 2013 18:41:07 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Wed, 1 May 2013 16:41:05 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 3341A19D8043
	for <linux-mm@kvack.org>; Wed,  1 May 2013 16:40:58 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r41Mf38r265024
	for <linux-mm@kvack.org>; Wed, 1 May 2013 16:41:03 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r41Mf3LO011862
	for <linux-mm@kvack.org>; Wed, 1 May 2013 16:41:03 -0600
Message-ID: <518199FE.7060908@linux.vnet.ibm.com>
Date: Wed, 01 May 2013 15:41:02 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] memory_hotplug: use pgdat_resize_lock() when updating
 node_present_pages
References: <1367446635-12856-1-git-send-email-cody@linux.vnet.ibm.com> <1367446635-12856-5-git-send-email-cody@linux.vnet.ibm.com> <alpine.DEB.2.02.1305011530050.8804@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1305011530050.8804@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 05/01/2013 03:30 PM, David Rientjes wrote:
> On Wed, 1 May 2013, Cody P Schafer wrote:
>
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index a221fac..0bdca10 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -915,6 +915,7 @@ static void node_states_set_node(int node, struct memory_notify *arg)
>>
>>   int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_type)
>>   {
>> +	unsigned long flags;
>>   	unsigned long onlined_pages = 0;
>>   	struct zone *zone;
>>   	int need_zonelists_rebuild = 0;
>> @@ -993,7 +994,11 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>>
>>   	zone->managed_pages += onlined_pages;
>>   	zone->present_pages += onlined_pages;
>> +
>> +	pgdat_resize_lock(zone->zone_pgdat, &flags);
>>   	zone->zone_pgdat->node_present_pages += onlined_pages;
>> +	pgdat_resize_unlock(zone->zone_pgdat, &flags);
>> +
>>   	if (onlined_pages) {
>>   		node_states_set_node(zone_to_nid(zone), &arg);
>>   		if (need_zonelists_rebuild)
>
> Why?  You can't get a partial read of a word-sized data structure.
>

Guaranteed to be stable means that if I'm a reader and 
pgdat_resize_lock(), node_present_pages had better not change at all 
until I pgdat_resize_unlock().

If nothing needs this guarantee, we should change the rules of 
pgdat_resize_lock(). I played it safe and went with following the 
existing rules.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
