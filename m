Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4C4146B0038
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 08:36:51 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id e188so101370614oif.18
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 05:36:51 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50112.outbound.protection.outlook.com. [40.107.5.112])
        by mx.google.com with ESMTPS id 34si6507231otr.209.2017.04.03.05.36.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 03 Apr 2017 05:36:50 -0700 (PDT)
Subject: Re: [PATCH] mm/zswap: fix potential deadlock in
 zswap_frontswap_store()
References: <20170331153009.11397-1-aryabinin@virtuozzo.com>
 <CALvZod5rnV5ZjKYxFwPDX8NcRQKJfwN-iWyVD-Mm4+fKten1+A@mail.gmail.com>
 <20170403084729.GG24661@dhcp22.suse.cz>
 <c4e8b895-260c-9b47-4531-5fac5cefa77c@virtuozzo.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <eea593fd-c59d-cad0-936b-c012df1abadd@virtuozzo.com>
Date: Mon, 3 Apr 2017 15:38:08 +0300
MIME-Version: 1.0
In-Reply-To: <c4e8b895-260c-9b47-4531-5fac5cefa77c@virtuozzo.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Shakeel Butt <shakeelb@google.com>
Cc: Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>



On 04/03/2017 03:37 PM, Andrey Ryabinin wrote:
> 
> 
> On 04/03/2017 11:47 AM, Michal Hocko wrote:
>> On Fri 31-03-17 10:00:30, Shakeel Butt wrote:
>>> On Fri, Mar 31, 2017 at 8:30 AM, Andrey Ryabinin
>>> <aryabinin@virtuozzo.com> wrote:
>>>> zswap_frontswap_store() is called during memory reclaim from
>>>> __frontswap_store() from swap_writepage() from shrink_page_list().
>>>> This may happen in NOFS context, thus zswap shouldn't use __GFP_FS,
>>>> otherwise we may renter into fs code and deadlock.
>>>> zswap_frontswap_store() also shouldn't use __GFP_IO to avoid recursion
>>>> into itself.
>>>>
>>>
>>> Is it possible to enter fs code (or IO) from zswap_frontswap_store()
>>> other than recursive memory reclaim? However recursive memory reclaim
>>> is protected through PF_MEMALLOC task flag. The change seems fine but
>>> IMHO reasoning needs an update. Adding Michal for expert opinion.
>>
>> Yes this is true. 
> 
> Actually, no. I think we have a bug in allocator which may lead to recursive direct reclaim.
> 
> E.g. for costly order allocations (or order > 0 && ac->migratetype != MIGRATE_MOVABLE)
> with __GFP_NOMEMALLOC (gfp_pfmemalloc_allowed() returns false)
> __alloc_pages_slowpath() may call __alloc_pages_direct_compact() and unconditionally clear PF_MEMALLOC:
> 
> __alloc_pages_direct_compact():
> ...
> 	current->flags |= PF_MEMALLOC;
> 	*compact_result = try_to_compact_pages(gfp_mask, order, alloc_flags, ac,
> 									prio);
> 	current->flags &= ~PF_MEMALLOC;
> 
> 
> 
> And later in __alloc_pages_slowpath():
> 
> 	/* Avoid recursion of direct reclaim */
> 	if (current->flags & PF_MEMALLOC)        <=== false
> 		goto nopage;
> 
> 	/* Try direct reclaim and then allocating */
> 	page = __alloc_pages_direct_reclaim(gfp_mask, order, alloc_flags, ac,
> 							&did_some_progress);
> 


Seems it was broken by

a8161d1ed6098506303c65b3701dedba876df42a
Author: Vlastimil Babka <vbabka@suse.cz>
Date:   Thu Jul 28 15:49:19 2016 -0700

    mm, page_alloc: restructure direct compaction handling in slowpath

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
