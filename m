Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id D33BC6B0137
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 02:12:04 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Tue, 26 Jun 2012 02:12:03 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 2C2656E8049
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 02:11:51 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5Q6BoKw218320
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 02:11:50 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5Q6Bo7t018384
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 03:11:50 -0300
Date: Tue, 26 Jun 2012 14:11:47 +0800
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/5] mm/sparse: fix possible memory leak
Message-ID: <20120626061147.GB9483@shangw>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1340466776-4976-1-git-send-email-shangw@linux.vnet.ibm.com>
 <1340466776-4976-3-git-send-email-shangw@linux.vnet.ibm.com>
 <20120625154851.GD19810@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120625154851.GD19810@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org

>> With CONFIG_SPARSEMEM_EXTREME, the root memory section descriptors
>> are allocated by slab or bootmem allocator. Also, the descriptors
>> might have been allocated and initialized by others. However, the
>> memory chunk allocated in current implementation wouldn't be put
>> into the available pool if others have allocated memory chunk for
>> that.
>
>Who is others? I assume that we can race in hotplug because other than
>that this is an early initialization code. How can others race?
>

I'm sorry that I don't have the real bug against the issue. I just
catch it when reading the source code :-)

I do agree with you that the trace is possiblly introduced by the
hotplug case.

>> The patch introduces addtional function sparse_index_free() to
>> deallocate the memory chunk if the root memory section descriptor
>> has been initialized by others.
>
>The fix itself looks correct but I do not see how this happens...
>
>> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
>> ---
>>  mm/sparse.c |   19 +++++++++++++++++++
>>  1 file changed, 19 insertions(+)
>> 
>> diff --git a/mm/sparse.c b/mm/sparse.c
>> index ce50c8b..bae8f2d 100644
>> --- a/mm/sparse.c
>> +++ b/mm/sparse.c
>> @@ -86,6 +86,22 @@ static struct mem_section noinline __init_refok *sparse_index_alloc(int nid)
>>  	return section;
>>  }
>>  
>> +static void noinline __init_refok sparse_index_free(struct mem_section *section,
>> +						    int nid)
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
>> +}
>> +
>>  static int __meminit sparse_index_init(unsigned long section_nr, int nid)
>>  {
>>  	static DEFINE_SPINLOCK(index_init_lock);
>> @@ -113,6 +129,9 @@ static int __meminit sparse_index_init(unsigned long section_nr, int nid)
>>  	mem_section[root] = section;
>>  out:
>>  	spin_unlock(&index_init_lock);
>> +	if (ret == -EEXIST)
>> +		sparse_index_free(section, nid);
>
>Maybe a generic if (ret) would be more appropriate.
>

I will do it in next revision :-)

Thanks,
Gavin

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
