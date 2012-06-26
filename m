Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 4A4956B0144
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 03:15:04 -0400 (EDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Tue, 26 Jun 2012 01:15:03 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 4276819D804A
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 07:14:37 +0000 (WET)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5Q7E9lI174830
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 01:14:24 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5Q7DrU2017930
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 01:13:53 -0600
Date: Tue, 26 Jun 2012 15:13:50 +0800
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/5] mm/sparse: optimize sparse_index_alloc
Message-ID: <20120626071350.GA22907@shangw>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1340466776-4976-1-git-send-email-shangw@linux.vnet.ibm.com>
 <1340466776-4976-2-git-send-email-shangw@linux.vnet.ibm.com>
 <20120625153035.GB19810@tiehlicka.suse.cz>
 <20120626060735.GA9483@shangw>
 <20120626070421.GA6713@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120626070421.GA6713@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org

On Tue, Jun 26, 2012 at 09:04:21AM +0200, Michal Hocko wrote:
>On Tue 26-06-12 14:07:35, Gavin Shan wrote:
>> >> With CONFIG_SPARSEMEM_EXTREME, the two level of memory section
>> >> descriptors are allocated from slab or bootmem. When allocating
>> >> from slab, let slab allocator to clear the memory chunk. However,
>> >> the memory chunk from bootmem allocator, we have to clear that
>> >> explicitly.
>> >
>> >I am sorry but I do not see how this optimize the current code. What is
>> >the difference between slab doing memset and doing it explicitly for all
>> >cases?
>> >
>> 
>> Yeah, I do agree it won't do much optimization here. However, I'm wandering
>> if I can remove the whole peice of code doing memset(setion, 0, array_size)
>> since it seems that alloc_bootmem_node() also clears the allocated memory
>> chunk :-)
>
>Yes, alloc_bootem_node clears the memory (strange, I thought it doesn't
>do that), so the memset is really not necessary after s/kmalloc/kzalloc/.
>

Thanks for the confirm, Michal. Let me remove it in next revision :-)

Thanks,
Gavin

>> 
>> Please correct me if I'm wrong about alloc_bootmem_node() :-)
>> 
>> Thanks,
>> Gavin
>> 
>> >> 
>> >> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
>> >> ---
>> >>  mm/sparse.c |   12 ++++++------
>> >>  1 file changed, 6 insertions(+), 6 deletions(-)
>> >> 
>> >> diff --git a/mm/sparse.c b/mm/sparse.c
>> >> index afd0998..ce50c8b 100644
>> >> --- a/mm/sparse.c
>> >> +++ b/mm/sparse.c
>> >> @@ -74,14 +74,14 @@ static struct mem_section noinline __init_refok *sparse_index_alloc(int nid)
>> >>  
>> >>  	if (slab_is_available()) {
>> >>  		if (node_state(nid, N_HIGH_MEMORY))
>> >> -			section = kmalloc_node(array_size, GFP_KERNEL, nid);
>> >> +			section = kzalloc_node(array_size, GFP_KERNEL, nid);
>> >>  		else
>> >> -			section = kmalloc(array_size, GFP_KERNEL);
>> >> -	} else
>> >> +			section = kzalloc(array_size, GFP_KERNEL);
>> >> +	} else {
>> >>  		section = alloc_bootmem_node(NODE_DATA(nid), array_size);
>> >> -
>> >> -	if (section)
>> >> -		memset(section, 0, array_size);
>> >> +		if (section)
>> >> +			memset(section, 0, array_size);
>> >> +	}
>> >>  
>> >>  	return section;
>> >>  }
>> >> -- 
>> >> 1.7.9.5
>> >> 
>> >> --
>> >> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> >> the body to majordomo@kvack.org.  For more info on Linux MM,
>> >> see: http://www.linux-mm.org/ .
>> >> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>> >
>> >-- 
>> >Michal Hocko
>> >SUSE Labs
>> >SUSE LINUX s.r.o.
>> >Lihovarska 1060/12
>> >190 00 Praha 9    
>> >Czech Republic
>> >
>> >--
>> >To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> >the body to majordomo@kvack.org.  For more info on Linux MM,
>> >see: http://www.linux-mm.org/ .
>> >Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>> >
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
