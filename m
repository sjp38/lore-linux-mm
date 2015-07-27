Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 63C286B0255
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 11:47:48 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so145954992wib.1
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 08:47:48 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j2si14672121wiz.27.2015.07.27.08.47.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 27 Jul 2015 08:47:47 -0700 (PDT)
Subject: Re: [RFC v2 1/4] mm: make alloc_pages_exact_node pass __GFP_THISNODE
References: <1437749126-25867-1-git-send-email-vbabka@suse.cz>
 <20150727153900.GA31432@cmpxchg.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55B652A0.3070208@suse.cz>
Date: Mon, 27 Jul 2015 17:47:44 +0200
MIME-Version: 1.0
In-Reply-To: <20150727153900.GA31432@cmpxchg.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On 07/27/2015 05:39 PM, Johannes Weiner wrote:
> On Fri, Jul 24, 2015 at 04:45:23PM +0200, Vlastimil Babka wrote:
>> @@ -310,11 +326,18 @@ static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
>>   	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
>>   }
>>
>> +/*
>> + * Allocate pages, restricting the allocation to the node given as nid. The
>> + * node must be valid and online. This is achieved by adding __GFP_THISNODE
>> + * to gfp_mask.
>> + */
>>   static inline struct page *alloc_pages_exact_node(int nid, gfp_t gfp_mask,
>>   						unsigned int order)
>>   {
>>   	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES || !node_online(nid));
>>
>> +	gfp_mask |= __GFP_THISNODE;
>> +
>>   	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
>>   }
>
> The "exact" name is currently ambiguous within the allocator API, and
> it's bad that we have _exact_node() and _exact_nid() with entirely
> different meanings. It'd be good to make "thisnode" refer to specific
> and exclusive node requests, and "exact" to mean page allocation
> chunks that are not in powers of two.

Ugh, good point.

> Would you consider renaming this function to alloc_pages_thisnode() as
> part of this series?

Sure, let's do it properly while at it. Yet "thisnode" is somewhat 
misleading name as it might imply the cpu's local node. The same applies 
to __GFP_THISNODE. So maybe find a better name for both? restrict_node? 
single_node?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
