Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 0C9E36B0253
	for <linux-mm@kvack.org>; Thu,  2 May 2013 05:37:48 -0400 (EDT)
Date: Thu, 2 May 2013 10:37:44 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v4 17/31] drivers: convert shrinkers to new count/scan API
Message-ID: <20130502093744.GJ11497@suse.de>
References: <1367018367-11278-1-git-send-email-glommer@openvz.org>
 <1367018367-11278-18-git-send-email-glommer@openvz.org>
 <20130430215355.GN6415@suse.de>
 <20130430220050.GK9931@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130430220050.GK9931@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kent Overstreet <koverstreet@google.com>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <dchinner@redhat.com>, intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, devel@driverdev.osuosl.org, Dan Magenheimer <dan.magenheimer@oracle.com>

On Tue, Apr 30, 2013 at 03:00:50PM -0700, Kent Overstreet wrote:
> On Tue, Apr 30, 2013 at 10:53:55PM +0100, Mel Gorman wrote:
> > On Sat, Apr 27, 2013 at 03:19:13AM +0400, Glauber Costa wrote:
> > > diff --git a/drivers/md/bcache/btree.c b/drivers/md/bcache/btree.c
> > > index 03e44c1..8b9c1a6 100644
> > > --- a/drivers/md/bcache/btree.c
> > > +++ b/drivers/md/bcache/btree.c
> > > @@ -599,11 +599,12 @@ static int mca_reap(struct btree *b, struct closure *cl, unsigned min_order)
> > >  	return 0;
> > >  }
> > >  
> > > -static int bch_mca_shrink(struct shrinker *shrink, struct shrink_control *sc)
> > > +static long bch_mca_scan(struct shrinker *shrink, struct shrink_control *sc)
> > >  {
> > >  	struct cache_set *c = container_of(shrink, struct cache_set, shrink);
> > >  	struct btree *b, *t;
> > >  	unsigned long i, nr = sc->nr_to_scan;
> > > +	long freed = 0;
> > >  
> > >  	if (c->shrinker_disabled)
> > >  		return 0;
> > 
> > -1 if shrinker disabled?
> > 
> > Otherwise if the shrinker is disabled we ultimately hit this loop in
> > shrink_slab_one()
> 
> My memory is very hazy on this stuff, but I recall there being another
> loop that'd just spin if we always returned -1.
> 
> (It might've been /proc/sys/vm/drop_caches, or maybe that was another
> bug..)
> 

It might be worth chasing down what that bug was and fixing it.

> But 0 should certainly be safe - if we're always returning 0, then we're
> claiming we don't have anything to shrink.
> 

It won't crash, but in Glauber's current code, it'll call you a few more
times uselessly and the scanned statistics become misleading. I think
Glauber/Dave's series is a big improvement over what we currently have
and it would be nice to get it ironed out.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
