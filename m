Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id EED7D6B0092
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 09:54:07 -0400 (EDT)
Received: by ewy9 with SMTP id 9so777541ewy.14
        for <linux-mm@kvack.org>; Wed, 20 Jul 2011 06:54:04 -0700 (PDT)
Date: Wed, 20 Jul 2011 16:53:56 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH] mm-slab: allocate kmem_cache with __GFP_REPEAT
In-Reply-To: <4E26DD25.4010707@parallels.com>
Message-ID: <alpine.DEB.2.00.1107201653080.4921@tiger>
References: <20110720121612.28888.38970.stgit@localhost6> <alpine.DEB.2.00.1107201611010.3528@tiger> <4E26D7EA.3000902@parallels.com> <alpine.DEB.2.00.1107201638520.4921@tiger> <4E26DD25.4010707@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Matt Mackall <mpm@selenic.com>, "mgorman@suse.de" <mgorman@suse.de>

On Wed, 20 Jul 2011, Konstantin Khlebnikov wrote:
>>>> The changelog isn't that convincing, really. This is kmem_cache_create()
>>>> so I'm surprised we'd ever get NULL here in practice. Does this fix some
>>>> problem you're seeing? If this is really an issue, I'd blame the page
>>>> allocator as GFP_KERNEL should just work.
>>> 
>>> nf_conntrack creates separate slab-cache for each net-namespace,
>>> this patch of course not eliminates the chance of failure, but makes it 
>>> more
>>> acceptable.
>> 
>> I'm still surprised you are seeing failures. mm/slab.c hasn't changed
>> significantly in a long time. Why hasn't anyone reported this before? I'd
>> still be inclined to shift the blame to the page allocator... Mel,
>> Christoph?
>> 
>> On Wed, 20 Jul 2011, Konstantin Khlebnikov wrote:
>>> struct kmem_size for slub is more compact, it uses pecpu-pointers instead 
>>> of
>>> dumb NR_CPUS-size array.
>>> probably better to fix this side...
>> 
>> So how big is 'struct kmem_cache' for your configuration anyway? Fixing
>> the per-cpu data structures would be nice but I'm guessing it'll be
>> slightly painful for mm/slab.c.
>
> With NR_CPUS=4096 and MAX_NUMNODES=512 its over 9k!
> so it require order-4 page, meanwhile PAGE_ALLOC_COSTLY_ORDER is 3

That's somewhat sad. I suppose I can just merge your patch unless other 
people object to it. I'd like a v2 with better changelog though.

 			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
