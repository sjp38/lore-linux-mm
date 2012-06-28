Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id E3F8E6B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 02:17:07 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Thu, 28 Jun 2012 00:17:07 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 879933E4005B
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 06:17:00 +0000 (WET)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5S6H1eW056346
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 00:17:01 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5S6GxU5015518
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 00:17:00 -0600
Date: Thu, 28 Jun 2012 14:16:58 +0800
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2/3] mm/sparse: fix possible memory leak
Message-ID: <20120628061658.GA27958@shangw>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1340814968-2948-1-git-send-email-shangw@linux.vnet.ibm.com>
 <1340814968-2948-2-git-send-email-shangw@linux.vnet.ibm.com>
 <alpine.DEB.2.00.1206271501240.22985@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1206271501240.22985@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, linux-mm@kvack.org, mhocko@suse.cz, dave@linux.vnet.ibm.com, hannes@cmpxchg.org, akpm@linux-foundation.org

>> diff --git a/mm/sparse.c b/mm/sparse.c
>> index 781fa04..a803599 100644
>> --- a/mm/sparse.c
>> +++ b/mm/sparse.c
>> @@ -75,6 +75,22 @@ static struct mem_section noinline __init_refok *sparse_index_alloc(int nid)
>>  	return section;
>>  }
>>  
>> +static void noinline __init_refok sparse_index_free(struct mem_section *section,
>> +						    int nid)
>
>noinline is unecessary, this is only referenced from sparse_index_init() 
>and it's perfectly legimitate to inline.  Also, this should be __meminit 
>and not __init.
>

Thanks for your comments. I'll change it into "inline __meminit" in next version :-)

>> +{
>> +	unsigned long size = SECTIONS_PER_ROOT *
>> +			     sizeof(struct mem_section);
>> +
>> +	if (!section)
>> +		return;
>> +
>> +	if (slab_is_available())
>> +		kfree(section);
>> +	else
>> +		free_bootmem_node(NODE_DATA(nid),
>> +			virt_to_phys(section), size);
>
>Did you check what happens here if !node_state(nid, N_HIGH_MEMORY)?
>

I'm sorry that I'm not catching your point. Please explain for more
if necessary.

I'm not sure you're talking about "kfree(section);" since the memory
chunk is allocated either by kzalloc_node() or kzalloc().

Thanks,
Gavin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
