Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 76F0F6B0089
	for <linux-mm@kvack.org>; Sun, 10 Jun 2012 23:41:53 -0400 (EDT)
Received: from /spool/local
	by e5.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Sun, 10 Jun 2012 23:41:51 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id C683338C8059
	for <linux-mm@kvack.org>; Sun, 10 Jun 2012 23:41:49 -0400 (EDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5B3fneN180516
	for <linux-mm@kvack.org>; Sun, 10 Jun 2012 23:41:49 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5B3fmh0032325
	for <linux-mm@kvack.org>; Sun, 10 Jun 2012 21:41:48 -0600
Date: Mon, 11 Jun 2012 12:41:46 +0900
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/buddy: fix default NUMA nodes
Message-ID: <20120611034146.GB27200@shangw>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1339254687-13447-1-git-send-email-shangw@linux.vnet.ibm.com>
 <alpine.DEB.2.00.1206101350540.25986@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1206101350540.25986@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, linux-mm@kvack.org, hannes@cmpxchg.org, akpm@linux-foundation.org

>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 7892f84..dda83c5 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -2474,6 +2474,7 @@ struct page *
>>  __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>>  			struct zonelist *zonelist, nodemask_t *nodemask)
>>  {
>> +	nodemask_t *preferred_nodemask = nodemask ? : &cpuset_current_mems_allowed;
>>  	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
>>  	struct zone *preferred_zone;
>>  	struct page *page = NULL;
>> @@ -2501,19 +2502,18 @@ retry_cpuset:
>>  	cpuset_mems_cookie = get_mems_allowed();
>>  
>>  	/* The preferred zone is used for statistics later */
>> -	first_zones_zonelist(zonelist, high_zoneidx,
>> -				nodemask ? : &cpuset_current_mems_allowed,
>> +	first_zones_zonelist(zonelist, high_zoneidx, preferred_nodemask,
>>  				&preferred_zone);
>>  	if (!preferred_zone)
>>  		goto out;
>>  
>>  	/* First allocation attempt */
>> -	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
>> -			zonelist, high_zoneidx, ALLOC_WMARK_LOW|ALLOC_CPUSET,
>> +	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, preferred_nodemask,
>> +			order, zonelist, high_zoneidx, ALLOC_WMARK_LOW|ALLOC_CPUSET,
>>  			preferred_zone, migratetype);
>>  	if (unlikely(!page))
>> -		page = __alloc_pages_slowpath(gfp_mask, order,
>> -				zonelist, high_zoneidx, nodemask,
>> +		page = __alloc_pages_slowpath(gfp_mask, order, zonelist,
>> +				high_zoneidx, preferred_nodemask,
>>  				preferred_zone, migratetype);
>>  
>>  	trace_mm_page_alloc(page, order, gfp_mask, migratetype);
>
>Nack, this is wrong.  The nodemask passed to first_zones_zonelist() is 
>only for statistics and is correct as written.  The nodemask passed to 
>get_page_from_freelist() constrains the iteration to only those nodes 
>which would be done over cpuset_current_mems_allowed with your patch if a 
>NULL nodemask is passed into the page allocator (meaning it has a default 
>mempolicy).  Allocations on non-cpuset nodes are allowed in some 
>contexts, see cpuset_zone_allowed_softwall(), so this would cause a 
>regression.
>

Thanks, David. I think you're correct. Please ignore/drop the code change :-)

Thanks,
Gavin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
