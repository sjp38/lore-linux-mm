Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 3962D6B0044
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 17:46:14 -0500 (EST)
Date: Wed, 7 Nov 2012 14:46:12 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v6 25/29] memcg/sl[au]b: shrink dead caches
Message-Id: <20121107144612.e822986f.akpm@linux-foundation.org>
In-Reply-To: <509A2849.9090509@parallels.com>
References: <1351771665-11076-1-git-send-email-glommer@parallels.com>
	<1351771665-11076-26-git-send-email-glommer@parallels.com>
	<20121105164813.2eba5ecb.akpm@linux-foundation.org>
	<509A0A04.2030503@parallels.com>
	<20121106231627.3610c908.akpm@linux-foundation.org>
	<509A2849.9090509@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On Wed, 7 Nov 2012 10:22:17 +0100
Glauber Costa <glommer@parallels.com> wrote:

> >>> container synchronously.  If those objects are normally left floating
> >>> around in an allocated but reclaimable state then we can address that
> >>> by synchronously freeing them if their container has been destroyed.
> >>>
> >>> Or something like that.  If it's something else then fine, but not this.
> >>>
> >>> What do we need to do to fix this?
> >>>
> >> The original patch had a unlikely() test in the free path, conditional
> >> on whether or not the cache is dead, that would then call this is the
> >> cache would now be empty.
> >>
> >> I got several requests to remove it and change it to something like
> >> this, because that is a fast path (I myself think an unlikely branch is
> >> not that bad)
> >>
> >> If you think such a test is acceptable, I can bring it back and argue in
> >> the basis of "akpm made me do it!". But meanwhile I will give this extra
> >> though to see if there is any alternative way I can do it...
> > 
> > OK, thanks, please do take a look at it.
> > 
> > I'd be interested in seeing the old version of the patch which had this
> > test-n-branch.  Perhaps there's some trick we can pull to lessen its cost.
> > 
> Attached.
> 
> This is the last version that used it (well, I believe it is). There is
> other unrelated things in this patch, that I got rid of. Look for
> kmem_cache_verify_dead().
> 
> In a summary, all calls to the free function would as a last step do:
> kmem_cache_verify_dead() that would either be an empty placeholder, or:
> 
> +static inline void kmem_cache_verify_dead(struct kmem_cache *s)
> +{
> +       if (unlikely(s->memcg_params.dead))
> +               schedule_work(&s->memcg_params.cache_shrinker);
> +}

hm, a few things.

What's up with kmem_cache_shrink?  It's global and exported to modules
but its only external caller is some weird and hopelessly poorly
documented site down in drivers/acpi/osl.c.  slab and slob implement
kmem_cache_shrink() *only* for acpi!  wtf?  Let's work out what acpi is
trying to actually do there, then do it properly, then killkillkill!

Secondly, as slab and slub (at least) have the ability to shed cached
memory, why aren't they hooked into the core cache-shinking machinery. 
After all, it's called "shrink_slab"!


If we can fix all that up then I wonder whether this particular patch
needs to exist at all.  If the kmem_cache is no longer used then we
can simply leave it floating around in memory and the regular cache
shrinking code out of shrink_slab() will clean up any remaining pages. 
The kmem_cache itself can be reclaimed via another shrinker, if
necessary?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
