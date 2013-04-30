Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 672706B014B
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 18:00:55 -0400 (EDT)
Received: by mail-da0-f53.google.com with SMTP id n34so424106dal.40
        for <linux-mm@kvack.org>; Tue, 30 Apr 2013 15:00:54 -0700 (PDT)
Date: Tue, 30 Apr 2013 15:00:50 -0700
From: Kent Overstreet <koverstreet@google.com>
Subject: Re: [PATCH v4 17/31] drivers: convert shrinkers to new count/scan API
Message-ID: <20130430220050.GK9931@google.com>
References: <1367018367-11278-1-git-send-email-glommer@openvz.org>
 <1367018367-11278-18-git-send-email-glommer@openvz.org>
 <20130430215355.GN6415@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130430215355.GN6415@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <dchinner@redhat.com>, intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, devel@driverdev.osuosl.org, Dan Magenheimer <dan.magenheimer@oracle.com>

On Tue, Apr 30, 2013 at 10:53:55PM +0100, Mel Gorman wrote:
> On Sat, Apr 27, 2013 at 03:19:13AM +0400, Glauber Costa wrote:
> > diff --git a/drivers/md/bcache/btree.c b/drivers/md/bcache/btree.c
> > index 03e44c1..8b9c1a6 100644
> > --- a/drivers/md/bcache/btree.c
> > +++ b/drivers/md/bcache/btree.c
> > @@ -599,11 +599,12 @@ static int mca_reap(struct btree *b, struct closure *cl, unsigned min_order)
> >  	return 0;
> >  }
> >  
> > -static int bch_mca_shrink(struct shrinker *shrink, struct shrink_control *sc)
> > +static long bch_mca_scan(struct shrinker *shrink, struct shrink_control *sc)
> >  {
> >  	struct cache_set *c = container_of(shrink, struct cache_set, shrink);
> >  	struct btree *b, *t;
> >  	unsigned long i, nr = sc->nr_to_scan;
> > +	long freed = 0;
> >  
> >  	if (c->shrinker_disabled)
> >  		return 0;
> 
> -1 if shrinker disabled?
> 
> Otherwise if the shrinker is disabled we ultimately hit this loop in
> shrink_slab_one()

My memory is very hazy on this stuff, but I recall there being another
loop that'd just spin if we always returned -1.

(It might've been /proc/sys/vm/drop_caches, or maybe that was another
bug..)

But 0 should certainly be safe - if we're always returning 0, then we're
claiming we don't have anything to shrink.

> do {
> 	ret = shrinker->scan_objects(shrinker, sc);
> 	if (ret == -1)
> 		break
> 	....
>         count_vm_events(SLABS_SCANNED, batch_size);
>         total_scan -= batch_size;
> 
>         cond_resched();
> } while (total_scan >= batch_size);
> 
> which won't break as such but we busy loop until total_scan drops and
> account for SLABS_SCANNED incorrectly.
> 
> More using of mutex_lock in here which means that multiple direct reclaimers
> will contend on each other. bch_mca_shrink() checks for __GFP_WAIT but an
> atomic caller does not direct reclaim so it'll always try and contend.
> 
> > @@ -611,12 +612,6 @@ static int bch_mca_shrink(struct shrinker *shrink, struct shrink_control *sc)
> >  	if (c->try_harder)
> >  		return 0;
> >  
> > -	/*
> > -	 * If nr == 0, we're supposed to return the number of items we have
> > -	 * cached. Not allowed to return -1.
> > -	 */
> > -	if (!nr)
> > -		return mca_can_free(c) * c->btree_pages;
> >  
> >  	/* Return -1 if we can't do anything right now */
> >  	if (sc->gfp_mask & __GFP_WAIT)
> > @@ -629,14 +624,14 @@ static int bch_mca_shrink(struct shrinker *shrink, struct shrink_control *sc)
> >  
> >  	i = 0;
> >  	list_for_each_entry_safe(b, t, &c->btree_cache_freeable, list) {
> > -		if (!nr)
> > +		if (freed >= nr)
> >  			break;
> >  
> >  		if (++i > 3 &&
> >  		    !mca_reap(b, NULL, 0)) {
> >  			mca_data_free(b);
> >  			rw_unlock(true, b);
> > -			--nr;
> > +			freed++;
> >  		}
> >  	}
> >  
> > @@ -647,7 +642,7 @@ static int bch_mca_shrink(struct shrinker *shrink, struct shrink_control *sc)
> >  	if (list_empty(&c->btree_cache))
> >  		goto out;
> >  
> > -	for (i = 0; nr && i < c->bucket_cache_used; i++) {
> > +	for (i = 0; i < c->bucket_cache_used; i++) {
> >  		b = list_first_entry(&c->btree_cache, struct btree, list);
> >  		list_rotate_left(&c->btree_cache);
> >  
> > @@ -656,14 +651,20 @@ static int bch_mca_shrink(struct shrinker *shrink, struct shrink_control *sc)
> >  			mca_bucket_free(b);
> >  			mca_data_free(b);
> >  			rw_unlock(true, b);
> > -			--nr;
> > +			freed++;
> >  		} else
> >  			b->accessed = 0;
> >  	}
> >  out:
> > -	nr = mca_can_free(c) * c->btree_pages;
> >  	mutex_unlock(&c->bucket_lock);
> > -	return nr;
> > +	return freed;
> > +}
> > +
> > +static long bch_mca_count(struct shrinker *shrink, struct shrink_control *sc)
> > +{
> > +	struct cache_set *c = container_of(shrink, struct cache_set, shrink);
> > +
> > +	return mca_can_free(c) * c->btree_pages;
> >  }
> >  
> >  void bch_btree_cache_free(struct cache_set *c)
> > @@ -732,7 +733,8 @@ int bch_btree_cache_alloc(struct cache_set *c)
> >  		c->verify_data = NULL;
> >  #endif
> >  
> > -	c->shrink.shrink = bch_mca_shrink;
> > +	c->shrink.count_objects = bch_mca_count;
> > +	c->shrink.scan_objects = bch_mca_scan;
> >  	c->shrink.seeks = 4;
> >  	c->shrink.batch = c->btree_pages * 2;
> >  	register_shrinker(&c->shrink);
> > diff --git a/drivers/md/bcache/sysfs.c b/drivers/md/bcache/sysfs.c
> > index 4d9cca4..fa8d048 100644
> > --- a/drivers/md/bcache/sysfs.c
> > +++ b/drivers/md/bcache/sysfs.c
> > @@ -535,7 +535,7 @@ STORE(__bch_cache_set)
> >  		struct shrink_control sc;
> >  		sc.gfp_mask = GFP_KERNEL;
> >  		sc.nr_to_scan = strtoul_or_return(buf);
> > -		c->shrink.shrink(&c->shrink, &sc);
> > +		c->shrink.scan_objects(&c->shrink, &sc);
> >  	}
> >  
> >  	sysfs_strtoul(congested_read_threshold_us,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
