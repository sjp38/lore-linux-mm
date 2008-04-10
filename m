Date: Thu, 10 Apr 2008 12:00:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 05/18] SLUB: Slab defrag core
Message-Id: <20080410120042.dc66f4f7.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0804101126280.12367@schroedinger.engr.sgi.com>
References: <20080404230158.365359425@sgi.com>
	<20080404230226.847485429@sgi.com>
	<20080407231129.3c044ba1.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0804081401350.31230@schroedinger.engr.sgi.com>
	<20080408141135.de5a6350.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0804081416060.31490@schroedinger.engr.sgi.com>
	<20080408142505.4bfc7a4d.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0804081441350.31620@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0804101126280.12367@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, mel@skynet.ie, andi@firstfloor.org, npiggin@suse.de, riel@redhat.com, penberg@cs.helsinki.fi
List-ID: <linux-mm.kvack.org>

On Thu, 10 Apr 2008 11:28:35 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> Here is a patch that gets rid of the timer and instead works with the 
> fuzzy notion of the "objects" freed returned from the shrinkers. We add 
> those up per node or globally and if they are greater than 100 we call 
> into defrag.
> 
> Do we need to have an additional knob to set the level at which defrag 
> triggers from reclaim? I just used 100.

It's just for batching purposes, no?  My (dated) experience is that
batching of soemthing as large as 100x makes a tremendous efficiency
difference and that we'll never need to think about this again.  So subject
to suitable performance testing I'd say let it be.

> +
> +	/*
> +	 * "ret" doesnt really contain the freed object count. The shrinkers
> +	 * fake it. Gotta go with what we are getting though.
> +	 *
> +	 * Handling of the freed object counter is also racy. If we get the
> +	 * wrong counts then we may unnecessarily do a defrag pass or defer
> +	 * one. "ret" is already faked. So this is just increasing
> +	 * the already existing fuzziness to get some notion as to when
> +	 * to initiate slab defrag which will hopefully be okay.
> +	 */
> +	if (zone) {
> +		/* balance_pgdat running on a zone so we only scan one node */
> +		zone->slab_objects_freed += ret;
> +		if (zone->slab_objects_freed > 100 && (gfp_mask & __GFP_FS)) {
> +			zone->slab_objects_freed = 0;
> +			kmem_cache_defrag(zone_to_nid(zone));
> +		}
> +	} else {
> +		static unsigned long global_objects_freed = 0;

Wanna buy a patch-checking script?  It's real cheap!

> +		/* Direct (and thus global) reclaim. Scan all nodes */
> +		global_objects_freed += ret;
> +		if (global_objects_freed > 100 && (gfp_mask & __GFP_FS)) {

I guess overflow here are rather improbable - It would be somewhat odd if
we freed >4G objects in a row with !__GFP_FS.

> +			global_objects_freed = 0;
> +			kmem_cache_defrag(-1);
> +		}
> +	}
>  	return ret;
>  }
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
