Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id CB69B6B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 21:20:10 -0400 (EDT)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Thu, 28 Jun 2012 19:20:10 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5T1K6Nd289616
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 19:20:06 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5T1K48T024410
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 19:20:05 -0600
Date: Fri, 29 Jun 2012 09:20:00 +0800
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 1/3] mm/sparse: optimize sparse_index_alloc
Message-ID: <20120629012000.GA10542@shangw>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1340814968-2948-1-git-send-email-shangw@linux.vnet.ibm.com>
 <20120628125243.GB16042@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120628125243.GB16042@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, linux-mm@kvack.org, dave@linux.vnet.ibm.com, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org

>> With CONFIG_SPARSEMEM_EXTREME, the two level of memory section
>> descriptors are allocated from slab or bootmem. When allocating
>> from slab, let slab/bootmem allocator to clear the memory chunk.
>> We needn't clear that explicitly.
>> 
>> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
>> Reviewed-by: Michal Hocko <mhocko@suse.cz>
>
>Well, I don't remember to give my r-b but now you have it official
>(please do not do that in future)

Ok. I thought anybody gave comments should be put into r-b list, which
is wrong. I won't do it and thanks for your comments :-)

>Reviewed-by: Michal Hocko <mhocko@suse.cz>

Thanks, Michal.

Gavin

>
>> ---
>>  mm/sparse.c |   10 ++++------
>>  1 file changed, 4 insertions(+), 6 deletions(-)
>> 
>> diff --git a/mm/sparse.c b/mm/sparse.c
>> index 6a4bf91..781fa04 100644
>> --- a/mm/sparse.c
>> +++ b/mm/sparse.c
>> @@ -65,14 +65,12 @@ static struct mem_section noinline __init_refok *sparse_index_alloc(int nid)
>>  
>>  	if (slab_is_available()) {
>>  		if (node_state(nid, N_HIGH_MEMORY))
>> -			section = kmalloc_node(array_size, GFP_KERNEL, nid);
>> +			section = kzalloc_node(array_size, GFP_KERNEL, nid);
>>  		else
>> -			section = kmalloc(array_size, GFP_KERNEL);
>> -	} else
>> +			section = kzalloc(array_size, GFP_KERNEL);
>> +	} else {
>>  		section = alloc_bootmem_node(NODE_DATA(nid), array_size);
>> -
>> -	if (section)
>> -		memset(section, 0, array_size);
>> +	}
>>  
>>  	return section;
>>  }
>> -- 
>> 1.7.9.5
>> 
>
>-- 
>Michal Hocko
>SUSE Labs
>SUSE LINUX s.r.o.
>Lihovarska 1060/12
>190 00 Praha 9    
>Czech Republic
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
