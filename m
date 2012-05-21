Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id DC98D6B0081
	for <linux-mm@kvack.org>; Mon, 21 May 2012 05:40:49 -0400 (EDT)
Message-ID: <4FBA0D25.8040203@parallels.com>
Date: Mon, 21 May 2012 13:38:45 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC] Common code 00/12] Sl[auo]b: Common functionality V2
References: <20120518161906.207356777@linux.com>
In-Reply-To: <20120518161906.207356777@linux.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Joonsoo Kim <js1304@gmail.com>, Alex Shi <alex.shi@intel.com>

On 05/18/2012 08:19 PM, Christoph Lameter wrote:
> V1->V2:
> - Incorporate glommers feedback.
> - Add 2 more patches dealing with common code in kmem_cache_destroy
>
> This is a series of patches that extracts common functionality from
> slab allocators into a common code base. The intend is to standardize
> as much as possible of the allocator behavior while keeping the
> distinctive features of each allocator which are mostly due to their
> storage format and serialization approaches.
>
> This patchset makes a beginning by extracting common functionality in
> kmem_cache_create() and kmem_cache_destroy(). However, there are
> numerous other areas where such work could be beneficial:
>
> 1. Extract the sysfs support from SLUB and make it common. That way
>     all allocators have a common sysfs API and are handleable in the same
>     way regardless of the allocator chose.
>
> 2. Extract the error reporting and checking from SLUB and make
>     it available for all allocators. This means that all allocators
>     will gain the resiliency and error handling capabilties.
>
> 3. Extract the memory hotplug and cpu hotplug handling. It seems that
>     SLAB may be more sophisticated here. Having common code here will
>     make it easier to maintain the special code.
>
> 4. Extract the aliasing capability of SLUB. This will enable fast
>     slab creation without creating too many additional slab caches.
>     The arrays of caches of varying sizes in numerous subsystems
>     do not cause the creation of numerous slab caches. Storage
>     density is increased and the cache footprint is reduced.
>
> Ultimately it is to be hoped that the special code for each allocator
> shrinks to a mininum. This will also make it easier to make modification
> to allocators.
>
> In the far future one could envision that the current allocators will
> just become storage algorithms that can be chosen based on the need of
> the subsystem. F.e.
>
> Cpu cache dependend performance		= Bonwick allocator (SLAB)
> Minimal cycle count and cache footprint	= SLUB
> Maximum storage density			= K&R allocator (SLOB)
>
> But that could be controversial and inefficient if indirect calls are needed.

While we're at it, can one of my patches for consistent name string 
handling among caches be applied?

Once you guys reach a decision about what is the best behavior: 
strdup'ing it in all caches, or not strduping it for the slub, I can 
provide an updated patch that also updates the slob accordingly.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
