Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id CEDAF6B0062
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 09:43:55 -0400 (EDT)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Mon, 2 Jul 2012 07:43:51 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q62DfJfB124478
	for <linux-mm@kvack.org>; Mon, 2 Jul 2012 07:41:35 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q62DesbK005368
	for <linux-mm@kvack.org>; Mon, 2 Jul 2012 07:40:54 -0600
Date: Mon, 2 Jul 2012 21:40:53 +0800
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 2/3] mm/sparse: fix possible memory leak
Message-ID: <20120702134053.GA23800@shangw>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1341221337-4826-1-git-send-email-shangw@linux.vnet.ibm.com>
 <1341221337-4826-2-git-send-email-shangw@linux.vnet.ibm.com>
 <20120702094331.GC8050@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120702094331.GC8050@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, linux-mm@kvack.org, dave@linux.vnet.ibm.com, rientjes@google.com, akpm@linux-foundation.org

On Mon, Jul 02, 2012 at 11:43:31AM +0200, Michal Hocko wrote:
>On Mon 02-07-12 17:28:56, Gavin Shan wrote:
>> sparse_index_init() is designed to be safe if two copies of it race.  It
>> uses "index_init_lock" to ensure that, even in the case of a race, only
>> one CPU will manage to do:
>> 
>> 	mem_section[root] = section;
>> 
>> However, in the case where two copies of sparse_index_init() _do_ race,
>> the one that loses the race will leak the "section" that
>> sparse_index_alloc() allocated for it.  This patch fixes that leak.
>
>I would still like to hear how we can possibly race in this code path.
>I've thought that memory onlining is done from a single CPU.
>

Hi Michael, how about to use the following changelog? :-)

-----

sparse_index_init() is designed to be safe if two copies of it race.  It
uses "index_init_lock" to ensure that, even in the case of a race, only
one CPU will manage to do:

mem_section[root] = section;

However, in the case where two copies of sparse_index_init() _do_ race,
which is probablly caused by making online for multiple memory sections
that depend on same entry of array mem_section[] simultaneously from
different CPUs. The one that loses the race will leak the "section" that
sparse_index_alloc() allocated for it. This patch fixes that leak.

-----

Thanks,
Gavin

>> 
>> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
>> ---
>>  mm/sparse.c |   17 +++++++++++++++++
>>  1 file changed, 17 insertions(+)
>> 
>> diff --git a/mm/sparse.c b/mm/sparse.c
>> index 781fa04..a6984d9 100644
>> --- a/mm/sparse.c
>> +++ b/mm/sparse.c
>> @@ -75,6 +75,20 @@ static struct mem_section noinline __init_refok *sparse_index_alloc(int nid)
>>  	return section;
>>  }
>>  
>> +static inline void __meminit sparse_index_free(struct mem_section *section)
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
>> +		free_bootmem(virt_to_phys(section), size);
>> +}
>> +
>>  static int __meminit sparse_index_init(unsigned long section_nr, int nid)
>>  {
>>  	static DEFINE_SPINLOCK(index_init_lock);
>> @@ -102,6 +116,9 @@ static int __meminit sparse_index_init(unsigned long section_nr, int nid)
>>  	mem_section[root] = section;
>>  out:
>>  	spin_unlock(&index_init_lock);
>> +	if (ret)
>> +		sparse_index_free(section);
>> +
>>  	return ret;
>>  }
>>  #else /* !SPARSEMEM_EXTREME */
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
