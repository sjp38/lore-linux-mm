Return-Path: <linux-kernel-owner@vger.kernel.org>
Date: Wed, 26 Dec 2018 12:53:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/1] mm/page_alloc: add a warning about high order
 allocations
Message-ID: <20181226115355.GJ16738@dhcp22.suse.cz>
References: <20181225153927.2873-1-khorenko@virtuozzo.com>
 <20181225153927.2873-2-khorenko@virtuozzo.com>
 <20181226084051.GH16738@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181226084051.GH16738@dhcp22.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
To: Konstantin Khorenko <khorenko@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Luis Chamberlain <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>
List-ID: <linux-mm.kvack.org>

On Wed 26-12-18 09:40:51, Michal Hocko wrote:
> Appart from general comments as a reply to the cover (btw. this all
> should be in the changelog because this is the _why_ part of the
> justification which should be _always_ part of the changelog).
> 
> On Tue 25-12-18 18:39:27, Konstantin Khorenko wrote:
> [...]
> > +config WARN_HIGH_ORDER
> > +	bool "Enable complains about high order memory allocations"
> > +	depends on !LOCKDEP
> 
> Why?
> 
> > +	default n
> > +	help
> > +	  Enables warnings on high order memory allocations. This allows to
> > +	  determine users of large memory chunks and rework them to decrease
> > +	  allocation latency. Note, some debug options make kernel structures
> > +	  fat.
> > +
> > +config WARN_HIGH_ORDER_LEVEL
> > +	int "Define page order level considered as too high"
> > +	depends on WARN_HIGH_ORDER
> > +	default 3
> > +	help
> > +	  Defines page order starting which the system to complain about.
> > +	  Default is current PAGE_ALLOC_COSTLY_ORDER.
> > +
> >  config HWPOISON_INJECT
> >  	tristate "HWPoison pages injector"
> >  	depends on MEMORY_FAILURE && DEBUG_KERNEL && PROC_FS
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index e95b5b7c9c3d..258892adb861 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -4341,6 +4341,30 @@ static inline void finalise_ac(gfp_t gfp_mask, struct alloc_context *ac)
> >  					ac->high_zoneidx, ac->nodemask);
> >  }
> >  
> > +#ifdef CONFIG_WARN_HIGH_ORDER
> > +int warn_order = CONFIG_WARN_HIGH_ORDER_LEVEL;
> > +
> > +/*
> > + * Complain if we allocate a high order page unless there is a __GFP_NOWARN
> > + * flag provided.
> > + *
> > + * Shuts up after 32 complains.
> > + */
> > +static __always_inline void warn_high_order(int order, gfp_t gfp_mask)
> > +{
> > +	static atomic_t warn_count = ATOMIC_INIT(32);
> > +
> > +	if (order >= warn_order && !(gfp_mask & __GFP_NOWARN))
> > +		WARN(atomic_dec_if_positive(&warn_count) >= 0,
> > +		     "order %d >= %d, gfp 0x%x\n",
> > +		     order, warn_order, gfp_mask);
> > +}
> 
> We do have ratelimit functionality, so why cannot you use it?
> 
> > +#else
> > +static __always_inline void warn_high_order(int order, gfp_t gfp_mask)
> > +{
> > +}
> > +#endif
> > +
> >  /*
> >   * This is the 'heart' of the zoned buddy allocator.
> >   */
> > @@ -4361,6 +4385,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
> >  		WARN_ON_ONCE(!(gfp_mask & __GFP_NOWARN));
> >  		return NULL;
> >  	}
> > +	warn_high_order(order, gfp_mask);
> >  
> >  	gfp_mask &= gfp_allowed_mask;
> >  	alloc_mask = gfp_mask;
> 
> Why do you warn about all allocations in the hot path? I thought you
> want to catch expensive allocations so I would assume that you would
> stick that into a slow path after we are not able to allocate anything
> after the first round of compaction.
> 
> Also do you want to warn about opportunistic GFP_NOWAIT allocations that
> have a reasonable fallback?

And forgot to mention other opportunistic allocations like THP of
course.
-- 
Michal Hocko
SUSE Labs
