Date: Wed, 7 Nov 2007 10:34:42 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 12/23] SLUB: Trigger defragmentation from memory reclaim
In-Reply-To: <20071107092822.GC6243@cataract>
Message-ID: <Pine.LNX.4.64.0711071032460.9857@schroedinger.engr.sgi.com>
References: <20071107011130.382244340@sgi.com> <20071107011229.423714790@sgi.com>
 <20071107092822.GC6243@cataract>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes-kernel@saeurebad.de>
Cc: akpm@linux-foundatin.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

On Wed, 7 Nov 2007, Johannes Weiner wrote:

> > @@ -210,6 +218,8 @@ unsigned long shrink_slab(unsigned long
> >                 shrinker->nr += total_scan;
> >         }
> >         up_read(&shrinker_rwsem);
> > +       if (gfp_mask & __GFP_FS)
> > +               kmem_cache_defrag(zone ? zone_to_nid(zone) : -1);
> >         return ret;
> >  }
> 
> What about the objects that kmem_cache_defrag() releases?  Shouldn't
> they be counted too?
> 
>      ret += kmem_cache_defrag(...)
> 
> Or am I overseeing something here?

kmem_cache_defrag returns the number of pages that were released by defrag 
actions.

shrink_slab returns the number of objects released by the shrinkers. 
kmem_cache_defrag has no way of knowing how many objects where released by 
the kick methods. The kick method may have chosen to reallocate the 
object.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
