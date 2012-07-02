Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 973366B0068
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 09:36:04 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Mon, 2 Jul 2012 09:36:02 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q62DWpSq10682502
	for <linux-mm@kvack.org>; Mon, 2 Jul 2012 09:32:59 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q62DSYKo028173
	for <linux-mm@kvack.org>; Mon, 2 Jul 2012 07:28:35 -0600
Date: Mon, 2 Jul 2012 21:28:32 +0800
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 2/3] mm/sparse: fix possible memory leak
Message-ID: <20120702132832.GA18567@shangw>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1341221337-4826-1-git-send-email-shangw@linux.vnet.ibm.com>
 <1341221337-4826-2-git-send-email-shangw@linux.vnet.ibm.com>
 <alpine.DEB.2.00.1207020404120.14758@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1207020404120.14758@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, linux-mm@kvack.org, dave@linux.vnet.ibm.com, mhocko@suse.cz, akpm@linux-foundation.org

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
>
>Eek, does that work?
>

David, I think it's working fine. If my understanding is wrong, please
correct me. Thanks a lot :-)

The "section" allocated from the bootmem allocator might take following
function call path. In the function alloc_bootmem_core(), all online nodes
will be checked for the memory allocation. So we could have memory allocated
from different node other than the specified one to alloc_bootmem_node()

alloc_bootmem_node(nid, size)
__alloc_bootmem_node()
___alloc_bootmem_node_nopanic()
alloc_bootmem_core()

On the other hand, function free_bootmem() checks which node the memory
block belongs to and then free it into that node. That looks reasonable.

Thanks,
Gavin 

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
