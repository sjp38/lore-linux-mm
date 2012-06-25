Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id A67866B0375
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 13:01:42 -0400 (EDT)
Received: from /spool/local
	by e1.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Mon, 25 Jun 2012 13:01:36 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 2EBED38C9DC5
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 12:35:56 -0400 (EDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5PGZj9414876694
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 12:35:46 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5PGZZDo001783
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 10:35:35 -0600
Date: Tue, 26 Jun 2012 00:35:22 +0800
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/5] mm/sparse: check size of struct mm_section
Message-ID: <20120625163522.GA5476@shangw>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1340466776-4976-1-git-send-email-shangw@linux.vnet.ibm.com>
 <20120625160322.GE19810@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120625160322.GE19810@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org

>> Platforms like PPC might need two level mem_section for SPARSEMEM
>> with enabled CONFIG_SPARSEMEM_EXTREME. On the other hand, the
>> memory section descriptor might be allocated from bootmem allocator
>> with PAGE_SIZE alignment. In order to fully utilize the memory chunk
>> allocated from bootmem allocator, it'd better to assure memory
>> sector descriptor won't run across the boundary (PAGE_SIZE).
>
>Why? The memory is continuous, right?
>

Yes, the memory is conginous and the capacity of specific entry
in mem_section[NR_SECTION_ROOTS] has been defined as follows:


#define SECTIONS_PER_ROOT       (PAGE_SIZE / sizeof (struct mem_section))

Also, the memory is prone to be allocated from bootmem by function
alloc_bootmem_node(), which has PAGE_SIZE alignment. So I think it's
reasonable to introduce the extra check here from my personal view :-)

Thanks,
Gavin

>> 
>> The patch introduces the check on size of "struct mm_section" to
>> assure that.
>> 
>> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
>> ---
>>  mm/sparse.c |    9 +++++++++
>>  1 file changed, 9 insertions(+)
>> 
>> diff --git a/mm/sparse.c b/mm/sparse.c
>> index 6a4bf91..afd0998 100644
>> --- a/mm/sparse.c
>> +++ b/mm/sparse.c
>> @@ -63,6 +63,15 @@ static struct mem_section noinline __init_refok *sparse_index_alloc(int nid)
>>  	unsigned long array_size = SECTIONS_PER_ROOT *
>>  				   sizeof(struct mem_section);
>>  
>> +	/*
>> +	 * The root memory section descriptor might be allocated
>> +	 * from bootmem, which has minimal memory chunk requirement
>> +	 * of page. In order to fully utilize the memory, the sparse
>> +	 * memory section descriptor shouldn't run across the boundary
>> +	 * that bootmem allocator has.
>> +	 */
>> +	BUILD_BUG_ON(PAGE_SIZE % sizeof(struct mem_section));
>> +
>>  	if (slab_is_available()) {
>>  		if (node_state(nid, N_HIGH_MEMORY))
>>  			section = kmalloc_node(array_size, GFP_KERNEL, nid);
>> -- 
>> 1.7.9.5
>> 
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
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
