Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id B87E96B000E
	for <linux-mm@kvack.org>; Tue, 22 May 2018 12:41:15 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id a5-v6so12335981plp.8
        for <linux-mm@kvack.org>; Tue, 22 May 2018 09:41:15 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id o7-v6si13330016pgc.381.2018.05.22.09.41.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 09:41:14 -0700 (PDT)
Subject: Re: [PATCH v2 3/4] mm: add find_alloc_contig_pages() interface
References: <20180503232935.22539-1-mike.kravetz@oracle.com>
 <20180503232935.22539-4-mike.kravetz@oracle.com>
 <eaa40ac0-365b-fd27-e096-b171ed28888f@suse.cz>
 <57dfd52c-22a5-5546-f8f3-848f21710cc1@oracle.com>
From: Reinette Chatre <reinette.chatre@intel.com>
Message-ID: <c7972da1-a908-7550-7253-9de9a963174c@intel.com>
Date: Tue, 22 May 2018 09:41:09 -0700
MIME-Version: 1.0
In-Reply-To: <57dfd52c-22a5-5546-f8f3-848f21710cc1@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>

On 5/21/2018 4:48 PM, Mike Kravetz wrote:
> On 05/21/2018 01:54 AM, Vlastimil Babka wrote:
>> On 05/04/2018 01:29 AM, Mike Kravetz wrote:
>>> +/**
>>> + * find_alloc_contig_pages() -- attempt to find and allocate a contiguous
>>> + *				range of pages
>>> + * @nr_pages:	number of pages to find/allocate
>>> + * @gfp:	gfp mask used to limit search as well as during compaction
>>> + * @nid:	target node
>>> + * @nodemask:	mask of other possible nodes
>>> + *
>>> + * Pages can be freed with a call to free_contig_pages(), or by manually
>>> + * calling __free_page() for each page allocated.
>>> + *
>>> + * Return: pointer to 'order' pages on success, or NULL if not successful.
>>> + */
>>> +struct page *find_alloc_contig_pages(unsigned long nr_pages, gfp_t gfp,
>>> +					int nid, nodemask_t *nodemask)
>>> +{
>>> +	unsigned long i, alloc_order, order_pages;
>>> +	struct page *pages;
>>> +
>>> +	/*
>>> +	 * Underlying allocators perform page order sized allocations.
>>> +	 */
>>> +	alloc_order = get_count_order(nr_pages);
>>
>> So if takes arbitrary nr_pages but convert it to order anyway? I think
>> that's rather suboptimal and wasteful... e.g. a range could be skipped
>> because some of the pages added by rounding cannot be migrated away.
> 
> Yes.  My idea with this series was to use existing allocators which are
> all order based.  Let me think about how to do allocation for arbitrary
> number of allocations.
> - For less than MAX_ORDER size we rely on the buddy allocator, so we are
>   pretty much stuck with order sized allocation.  However, allocations of
>   this size are not really interesting as you can call existing routines
>   directly.
> - For sizes greater than MAX_ORDER, we know that the allocation size will
>   be at least pageblock sized.  So, the isolate/migrate scheme can still
>   be used for full pageblocks.  We can then use direct migration for the
>   remaining pages.  This does complicate things a bit.
> 
> I'm guessing that most (?all?) allocations will be order based.  The use
> cases I am aware of (hugetlbfs, Intel Cache Pseudo-Locking, RDMA) are all
> order based.  However, as commented in previous version taking arbitrary
> nr_pages makes interface more future proof.
> 

I noticed this Cache Pseudo-Locking statement and would like to clarify.
I have not been following this thread in detail so I would like to
apologize first if my comments are out of context.

Currently the Cache Pseudo-Locking allocations are order based because I
assumed it was required by the allocator. The contiguous regions needed
by Cache Pseudo-Locking will not always be order based - instead it is
based on the granularity of the cache allocation. One example is a
platform with 55MB L3 cache that can be divided into 20 equal portions.
To support Cache Pseudo-Locking on this platform we need to be able to
allocate contiguous regions at increments of 2816KB (the size of each
portion). In support of this example platform regions needed would thus
be 2816KB, 5632KB, 8448KB, etc.

Regards,

Reinette
