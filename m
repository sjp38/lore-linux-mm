Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 5F5E96B004A
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 09:28:22 -0400 (EDT)
Message-ID: <4E26D7EA.3000902@parallels.com>
Date: Wed, 20 Jul 2011 17:28:10 +0400
From: Konstantin Khlebnikov <khlebnikov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm-slab: allocate kmem_cache with __GFP_REPEAT
References: <20110720121612.28888.38970.stgit@localhost6> <alpine.DEB.2.00.1107201611010.3528@tiger>
In-Reply-To: <alpine.DEB.2.00.1107201611010.3528@tiger>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Matt Mackall <mpm@selenic.com>, "mgorman@suse.de" <mgorman@suse.de>

Pekka Enberg wrote:
> On Wed, 20 Jul 2011, Konstantin Khlebnikov wrote:
>> Order of sizeof(struct kmem_cache) can be bigger than PAGE_ALLOC_COSTLY_ORDER,
>> thus there is a good chance of unsuccessful allocation.
>> With __GFP_REPEAT buddy-allocator will reclaim/compact memory more aggressively.
>>
>> Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
>> ---
>> mm/slab.c |    2 +-
>> 1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/mm/slab.c b/mm/slab.c
>> index d96e223..53bddc8 100644
>> --- a/mm/slab.c
>> +++ b/mm/slab.c
>> @@ -2304,7 +2304,7 @@ kmem_cache_create (const char *name, size_t size, size_t align,
>> 		gfp = GFP_NOWAIT;
>>
>> 	/* Get cache's description obj. */
>> -	cachep = kmem_cache_zalloc(&cache_cache, gfp);
>> +	cachep = kmem_cache_zalloc(&cache_cache, gfp | __GFP_REPEAT);
>> 	if (!cachep)
>> 		goto oops;
>
> The changelog isn't that convincing, really. This is kmem_cache_create()
> so I'm surprised we'd ever get NULL here in practice. Does this fix some
> problem you're seeing? If this is really an issue, I'd blame the page
> allocator as GFP_KERNEL should just work.

nf_conntrack creates separate slab-cache for each net-namespace,
this patch of course not eliminates the chance of failure, but makes it more acceptable.

struct kmem_size for slub is more compact, it uses pecpu-pointers instead of dumb NR_CPUS-size array.
probably better to fix this side...

>
>   			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
