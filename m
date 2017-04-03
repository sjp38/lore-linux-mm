Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 647CE6B0038
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 09:13:31 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id n4so103006050oia.5
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 06:13:31 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50130.outbound.protection.outlook.com. [40.107.5.130])
        by mx.google.com with ESMTPS id z2si6556754otc.177.2017.04.03.06.13.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 03 Apr 2017 06:13:30 -0700 (PDT)
Subject: Re: [PATCH] mm/zswap: fix potential deadlock in
 zswap_frontswap_store()
References: <20170331153009.11397-1-aryabinin@virtuozzo.com>
 <CALvZod5rnV5ZjKYxFwPDX8NcRQKJfwN-iWyVD-Mm4+fKten1+A@mail.gmail.com>
 <20170403084729.GG24661@dhcp22.suse.cz>
 <c4e8b895-260c-9b47-4531-5fac5cefa77c@virtuozzo.com>
 <20170403124544.GN24661@dhcp22.suse.cz>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <0908e647-d60b-4340-e6d2-4f6023663401@virtuozzo.com>
Date: Mon, 3 Apr 2017 16:14:51 +0300
MIME-Version: 1.0
In-Reply-To: <20170403124544.GN24661@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Shakeel Butt <shakeelb@google.com>, Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>



On 04/03/2017 03:45 PM, Michal Hocko wrote:
> On Mon 03-04-17 15:37:07, Andrey Ryabinin wrote:
>>
>>
>> On 04/03/2017 11:47 AM, Michal Hocko wrote:
>>> On Fri 31-03-17 10:00:30, Shakeel Butt wrote:
>>>> On Fri, Mar 31, 2017 at 8:30 AM, Andrey Ryabinin
>>>> <aryabinin@virtuozzo.com> wrote:
>>>>> zswap_frontswap_store() is called during memory reclaim from
>>>>> __frontswap_store() from swap_writepage() from shrink_page_list().
>>>>> This may happen in NOFS context, thus zswap shouldn't use __GFP_FS,
>>>>> otherwise we may renter into fs code and deadlock.
>>>>> zswap_frontswap_store() also shouldn't use __GFP_IO to avoid recursion
>>>>> into itself.
>>>>>
>>>>
>>>> Is it possible to enter fs code (or IO) from zswap_frontswap_store()
>>>> other than recursive memory reclaim? However recursive memory reclaim
>>>> is protected through PF_MEMALLOC task flag. The change seems fine but
>>>> IMHO reasoning needs an update. Adding Michal for expert opinion.
>>>
>>> Yes this is true. 
>>
>> Actually, no. I think we have a bug in allocator which may lead to
>> recursive direct reclaim.
>>
>> E.g. for costly order allocations (or order > 0 &&
>> ac->migratetype != MIGRATE_MOVABLE) with __GFP_NOMEMALLOC
>> (gfp_pfmemalloc_allowed() returns false) __alloc_pages_slowpath()
>> may call __alloc_pages_direct_compact() and unconditionally clear
>> PF_MEMALLOC:
> 
> Not sure what is the bug here. __GFP_NOMEMALLOC is supposed to inhibit
> PF_MEMALLOC. And we do not recurse to the reclaim path. We only do the
> compaction. Or what am I missing?
> 

The bug here is that __alloc_pages_direct_compact() will *unconditionally* clear PF_MEMALLOC.
So if we already under direct reclaim (so PF_MEMALLOC was already set) __alloc_pages_direct_compact()
will clear that PF_MEMALLOC. If compaction failed we may go into direct reclaim again because
the following following if in __alloc_pages_slowpath() is false:

	/* Avoid recursion of direct reclaim */
	if (current->flags & PF_MEMALLOC)
		goto nopage;

	/* Try direct reclaim and then allocating */
	page = __alloc_pages_direct_reclaim(gfp_mask, order, alloc_flags, ac,



So, recursion might look like this:

alloc_pages()
    __perform_reclaim()
	current->flags |= PF_MEMALLOC;
	try_to_free_pages()
		alloc_pages(__GFP_NONMEMALLOC):
			__alloc_pages_direct_compact():
				current->flags &= ~PF_MEMALLOC;

			if (current->flags & PF_MEMALLOC) //now it's false
				goto nopage;

			__alloc_pages_direct_reclaim()
					__perform_reclaim()
					
					

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
