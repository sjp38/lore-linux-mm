Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 40D016B004A
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 10:32:42 -0400 (EDT)
Message-ID: <4E26E705.8050704@parallels.com>
Date: Wed, 20 Jul 2011 18:32:37 +0400
From: Konstantin Khlebnikov <khlebnikov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm-slab: allocate kmem_cache with __GFP_REPEAT
References: <20110720121612.28888.38970.stgit@localhost6> <alpine.DEB.2.00.1107201611010.3528@tiger> <4E26D7EA.3000902@parallels.com> <alpine.DEB.2.00.1107201638520.4921@tiger> <alpine.DEB.2.00.1107200852590.32737@router.home> <20110720142018.GL5349@suse.de>
In-Reply-To: <20110720142018.GL5349@suse.de>
Content-Type: text/plain; charset="ISO-8859-15"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Matt Mackall <mpm@selenic.com>

Mel Gorman wrote:
> On Wed, Jul 20, 2011 at 08:54:10AM -0500, Christoph Lameter wrote:
>> On Wed, 20 Jul 2011, Pekka Enberg wrote:
>>
>>> On Wed, 20 Jul 2011, Konstantin Khlebnikov wrote:
>>>>> The changelog isn't that convincing, really. This is kmem_cache_create()
>>>>> so I'm surprised we'd ever get NULL here in practice. Does this fix some
>>>>> problem you're seeing? If this is really an issue, I'd blame the page
>>>>> allocator as GFP_KERNEL should just work.
>>>>
>>>> nf_conntrack creates separate slab-cache for each net-namespace,
>>>> this patch of course not eliminates the chance of failure, but makes it more
>>>> acceptable.
>>>
>>> I'm still surprised you are seeing failures. mm/slab.c hasn't changed
>>> significantly in a long time. Why hasn't anyone reported this before? I'd
>>> still be inclined to shift the blame to the page allocator... Mel, Christoph?
>>
>> There was a lot of recent fiddling with the reclaim logic. Maybe some of
>> those changes caused the problem?
>>
>
> It's more likely that creating new slabs while under memory pressure
> significant enough to fail an order-4 allocation is a situation that is
> rarely tested.
>
> What kernel version did this failure occur on? What was the system doing
> at the time of failure? Can the page allocation failure message be
> posted?
>

I catch this on our rhel6-openvz kernel, and yes it very patchy,
but I don't see any reasons why this cannot be reproduced on mainline kernel.

there was abount ten containers with random stuff, node already do intensive swapout but still alive,
in this situation starting new containers sometimes (1 per 1000) fails due to kmem_cache_create failures in nf_conntrack,
there no other messages except:
Unable to create nf_conn slab cache
and some
nf_conntrack: falling back to vmalloc.
(it try allocates huge hash table and do it via vmalloc if kmalloc fails)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
