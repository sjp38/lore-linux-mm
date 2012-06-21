Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id AD8966B005D
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 00:48:05 -0400 (EDT)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Wed, 20 Jun 2012 22:48:03 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id C06FB3E40048
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 04:47:29 +0000 (WET)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5L4lUUV187966
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 22:47:30 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5L4lTwU003083
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 22:47:30 -0600
Date: Thu, 21 Jun 2012 12:47:25 +0800
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/buddy: get the allownodes for dump at once
Message-ID: <20120621044725.GA20379@shangw>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1339662910-25774-1-git-send-email-shangw@linux.vnet.ibm.com>
 <alpine.DEB.2.00.1206201815100.3702@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1206201815100.3702@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, linux-mm@kvack.org, minchan@kernel.org, mgorman@suse.de, akpm@linux-foundation.org

>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 7892f84..211004e 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -2765,11 +2765,19 @@ out:
>>   */
>>  void show_free_areas(unsigned int filter)
>>  {
>> -	int cpu;
>> +	int nid, cpu;
>> +	nodemask_t allownodes;
>>  	struct zone *zone;
>>  
>
>I saw this added to the -mm tree today, but it has to be nacked with 
>apologies for not seeing the patch on the mailing list earlier.
>

Thanks, David.

>show_free_areas() is called by the oom killer, so we know two things: it 
>can be called potentially very deep in the callchain and current is out of 
>memory.  Both are killers for this patch since you're allocating 
>nodemask_t on the stack here which could cause an overflow and because you 
>can't easily fix that case with NODEMASK_ALLOC() since it allocates slab 
>with GFP_KERNEL when we we're oom, which would simply suppress vital 
>meminfo from being shown.
>

I'm not sure it's the possible to resolve the concerns with "static" here
since "allownodes" will be cleared for each call to show_free_areas().

	static nodemask_t allownodes;

Thanks,
Gavin 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
