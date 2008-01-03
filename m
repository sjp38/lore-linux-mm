Date: Thu, 3 Jan 2008 02:08:31 +0100
From: Andrea Arcangeli <andrea@cpushare.com>
Subject: Re: [PATCH 10 of 24] stop useless vm trashing while we wait the
	TIF_MEMDIE task to exit
Message-ID: <20080103010831.GL30939@v2.random>
References: <edb3af3e0d4f2c083c8d.1187786937@v2.random> <alpine.DEB.0.9999.0709211208140.11391@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.0.9999.0709211208140.11391@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Fri, Sep 21, 2007 at 12:10:23PM -0700, David Rientjes wrote:
> On Wed, 22 Aug 2007, Andrea Arcangeli wrote:
> 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1028,6 +1028,8 @@ static unsigned long shrink_zone(int pri
> >  		nr_inactive = 0;
> >  
> >  	while (nr_active || nr_inactive) {
> > +		if (is_VM_OOM())
> > +			break;
> >  		if (nr_active) {
> >  			nr_to_scan = min(nr_active,
> >  					(unsigned long)sc->swap_cluster_max);
> 
> This will need to use the new OOM zone-locking interface.  shrink_zones() 
> accepts struct zone** as one of its formals so while traversing each zone 
> this would simply become a test of zone_is_oom_locked(*z).

yes I changed this with zone_is_oom_locked. same logic as before, to
spend the time in schedule_timeout while the system tries to solve the
oom condition instead of trashing the whole cpu caches over the lru.

> 
> > @@ -1138,6 +1140,17 @@ unsigned long try_to_free_pages(struct z
> >  	}
> >  
> >  	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
> > +		if (is_VM_OOM()) {
> > +			if (!test_thread_flag(TIF_MEMDIE)) {
> > +				/* get out of the way */
> > +				schedule_timeout_interruptible(1);
> > +				/* don't waste cpu if we're still oom */
> > +				if (is_VM_OOM())
> > +					goto out;
> > +			} else
> > +				goto out;
> > +		}
> > +
> >  		sc.nr_scanned = 0;
> >  		if (!priority)
> >  			disable_swap_token();
> > 
> 
> Same as above, and it becomes trivial since try_to_free_pages() also 
> accepts a struct zone** formal.

yes, converted this too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
