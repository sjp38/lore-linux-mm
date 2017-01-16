Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 51A6F6B0038
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 14:09:40 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 194so95096092pgd.7
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 11:09:40 -0800 (PST)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id z128si22435484pfz.92.2017.01.16.11.09.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jan 2017 11:09:39 -0800 (PST)
Subject: Re: [PATCH 1/6] mm: introduce kv[mz]alloc helpers
References: <20170112153717.28943-1-mhocko@kernel.org>
 <20170112153717.28943-2-mhocko@kernel.org>
 <bf1815ec-766a-77f2-2823-c19abae5edb3@nvidia.com>
 <20170116084717.GA13641@dhcp22.suse.cz>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <0ca8a212-c651-7915-af25-23925e1c1cc3@nvidia.com>
Date: Mon, 16 Jan 2017 11:09:37 -0800
MIME-Version: 1.0
In-Reply-To: <20170116084717.GA13641@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Anatoly Stepanov <astepanov@cloudlinux.com>, Paolo Bonzini <pbonzini@redhat.com>, Mike Snitzer <snitzer@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, Theodore Ts'o <tytso@mit.edu>



On 01/16/2017 12:47 AM, Michal Hocko wrote:
> On Sun 15-01-17 20:34:13, John Hubbard wrote:
>>
>>
>> On 01/12/2017 07:37 AM, Michal Hocko wrote:
> [...]
>>> diff --git a/mm/util.c b/mm/util.c
>>> index 3cb2164f4099..7e0c240b5760 100644
>>> --- a/mm/util.c
>>> +++ b/mm/util.c
>>> @@ -324,6 +324,48 @@ unsigned long vm_mmap(struct file *file, unsigned long addr,
>>>  }
>>>  EXPORT_SYMBOL(vm_mmap);
>>>
>>> +/**
>>> + * kvmalloc_node - allocate contiguous memory from SLAB with vmalloc fallback
>>
>> Hi Michal,
>>
>> How about this wording instead:
>>
>> kvmalloc_node - attempt to allocate physically contiguous memory, but upon
>> failure, fall back to non-contiguous (vmalloc) allocation.
>
> OK, why not.
>
>>> + * @size: size of the request.
>>> + * @flags: gfp mask for the allocation - must be compatible (superset) with GFP_KERNEL.
>>> + * @node: numa node to allocate from
>>> + *
>>> + * Uses kmalloc to get the memory but if the allocation fails then falls back
>>> + * to the vmalloc allocator. Use kvfree for freeing the memory.
>>> + *
>>> + * Reclaim modifiers - __GFP_NORETRY, __GFP_REPEAT and __GFP_NOFAIL are not supported
>>
>> Is that "Reclaim modifiers" line still true, or is it a leftover from an
>> earlier approach? I am having trouble reconciling it with rest of the
>> patchset, because:
>>
>> a) the flags argument below is effectively passed on to either kmalloc_node
>> (possibly adding, but not removing flags), or to __vmalloc_node_flags.
>
> The above only says thos are _unsupported_ - in other words the behavior
> is not defined. Even if flags are passed down to kmalloc resp. vmalloc
> it doesn't mean they are used that way.  Remember that vmalloc uses
> some hardcoded GFP_KERNEL allocations.  So while I could be really
> strict about this and mask away these flags I doubt this is worth the
> additional code.

I do wonder about passing those flags through to kmalloc. Maybe it is worth stripping out 
__GFP_NORETRY and __GFP_NOFAIL, after all. It provides some insulation from any future changes to 
the implementation of kmalloc, and it also makes the documentation more believable.

>
>> b) In patch 6/6, you are in fact passing in __GFP_REPEAT to the wrappers
>> (kvzalloc, for example), and again, only adding, not removing flags.
>
> Patch 2 adds a support for __GFP_REPEAT and updates the above line as
> well.

OK, I see.

>
>>> + */
>>> +void *kvmalloc_node(size_t size, gfp_t flags, int node)
>>> +{
>>> +	gfp_t kmalloc_flags = flags;
>>> +	void *ret;
>>> +
>>> +	/*
>>> +	 * vmalloc uses GFP_KERNEL for some internal allocations (e.g page tables)
>>> +	 * so the given set of flags has to be compatible.
>>> +	 */
>>> +	WARN_ON_ONCE((flags & GFP_KERNEL) != GFP_KERNEL);
>>> +
>>> +	/*
>>> +	 * Make sure that larger requests are not too disruptive - no OOM
>>> +	 * killer and no allocation failure warnings as we have a fallback
>>> +	 */
>>> +	if (size > PAGE_SIZE)
>>> +		kmalloc_flags |= __GFP_NORETRY | __GFP_NOWARN;
>>> +
>>> +	ret = kmalloc_node(size, kmalloc_flags, node);
>>
>> Along those lines (dealing with larger requests), is there any value in
>> picking some threshold value, and going straight to vmalloc if size is
>> greater than that threshold?
>
> I am not a fan of thresholds. PAGE_ALLOC_COSTLY_ORDER which is
> internally used by the page allocator has turned out to be a major pain.
> I do not want to repeat the same mistake again here. Besides that you
> could hard find a "one suits all" value so it would have to be a part of
> the API. If we ever grow users who would really like to do something
> like that then a specialized API should be added.

Thanks for explaining, and the note about the pain of dealing with PAGE_ALLOC_COSTLY_ORDER is 
especially interesting. Sounds good, then.

thanks
john h

>
>> It's less flexible and might even require
>> occasional maintenance over the years, but it would save some time on *some*
>> systems in some cases...OK, I think I just talked myself out of the whole
>> idea. But I still want to put the question out there, because I think others
>> may also ask it, and I'd like to hear a more experienced opinion.
>
>
> --
> Michal Hocko
> SUSE Labs
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
