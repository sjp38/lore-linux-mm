Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 5387A6B0038
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 16:52:42 -0400 (EDT)
Received: by wicmv11 with SMTP id mv11so78184726wic.0
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 13:52:42 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dk2si69126wib.80.2015.07.24.13.52.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Jul 2015 13:52:40 -0700 (PDT)
Message-ID: <55B2A596.1010101@suse.cz>
Date: Fri, 24 Jul 2015 22:52:38 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC v2 1/4] mm: make alloc_pages_exact_node pass __GFP_THISNODE
References: <1437749126-25867-1-git-send-email-vbabka@suse.cz> <alpine.DEB.2.10.1507241301400.5215@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1507241301400.5215@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On 24.7.2015 22:08, David Rientjes wrote:
> On Fri, 24 Jul 2015, Vlastimil Babka wrote:
> 
>> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
>> index 15928f0..c50848e 100644
>> --- a/include/linux/gfp.h
>> +++ b/include/linux/gfp.h
>> @@ -300,6 +300,22 @@ __alloc_pages(gfp_t gfp_mask, unsigned int order,
>>  	return __alloc_pages_nodemask(gfp_mask, order, zonelist, NULL);
>>  }
>>  
>> +/*
>> + * An optimized version of alloc_pages_node(), to be only used in places where
>> + * the overhead of the check for nid == -1 could matter.
> 
> We don't actually check for nid == -1, or nid == NUMA_NO_NODE, in any of 
> the functions.  I would just state that nid must be valid and possible to 
> allocate from when passed to this function.

OK

>> + */
>> +static inline struct page *
>> +__alloc_pages_node(int nid, gfp_t gfp_mask, unsigned int order)
>> +{
>> +	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES || !node_online(nid));
>> +
>> +	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
>> +}
>> +
>> +/*
>> + * Allocate pages, preferring the node given as nid. When nid equals -1,
>> + * prefer the current CPU's node.
>> + */
> 
> We've done quite a bit of work to refer only to NUMA_NO_NODE, so we'd like 
> to avoid hardcoded -1 anywhere we can.

OK

>>  static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
>>  						unsigned int order)
>>  {
>> @@ -310,11 +326,18 @@ static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
>>  	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
>>  }
>>  
>> +/*
>> + * Allocate pages, restricting the allocation to the node given as nid. The
>> + * node must be valid and online. This is achieved by adding __GFP_THISNODE
>> + * to gfp_mask.
> 
> Not sure we need to point out that __GPF_THISNODE does this, it stands out 
> pretty well in the function already :)

Right.

>> + */
>>  static inline struct page *alloc_pages_exact_node(int nid, gfp_t gfp_mask,
>>  						unsigned int order)
>>  {
>>  	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES || !node_online(nid));
>>  
>> +	gfp_mask |= __GFP_THISNODE;
>> +
>>  	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
>>  }
>>  
> [snip]
> 
> I assume you looked at the collapse_huge_page() case and decided that it 
> needs no modification since the gfp mask is used later for other calls?

Yeah. Not that the memcg charge parts would seem to care about __GFP_THISNODE,
though.

>> diff --git a/mm/migrate.c b/mm/migrate.c
>> index f53838f..d139222 100644
>> --- a/mm/migrate.c
>> +++ b/mm/migrate.c
>> @@ -1554,10 +1554,8 @@ static struct page *alloc_misplaced_dst_page(struct page *page,
>>  	struct page *newpage;
>>  
>>  	newpage = alloc_pages_exact_node(nid,
>> -					 (GFP_HIGHUSER_MOVABLE |
>> -					  __GFP_THISNODE | __GFP_NOMEMALLOC |
>> -					  __GFP_NORETRY | __GFP_NOWARN) &
>> -					 ~GFP_IOFS, 0);
>> +				(GFP_HIGHUSER_MOVABLE | __GFP_NOMEMALLOC |
>> +				 __GFP_NORETRY | __GFP_NOWARN) & ~GFP_IOFS, 0);
>>  
>>  	return newpage;
>>  }
> [snip]
> 
> What about the alloc_pages_exact_node() in new_page_node()?

Oops, seems I missed that one. So the API seems ok otherwise?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
