Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 3BFA46B0074
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 05:05:51 -0400 (EDT)
Message-ID: <51ADAE20.3020500@parallels.com>
Date: Tue, 4 Jun 2013 13:06:40 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v7 19/34] drivers: convert shrinkers to new count/scan
 API
References: <1368994047-5997-1-git-send-email-glommer@openvz.org> <1368994047-5997-20-git-send-email-glommer@openvz.org> <20130603200331.GK2291@google.com>
In-Reply-To: <20130603200331.GK2291@google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kent Overstreet <koverstreet@google.com>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, Dave Chinner <david@fromorbit.com>, hughd@google.com, Dave Chinner <dchinner@redhat.com>, Daniel Vetter <daniel.vetter@ffwll.ch>, =?ISO-8859-1?Q?Arve_Hj=F8nnev=E5g?= <arve@android.com>, John Stultz <john.stultz@linaro.org>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Thomas Hellstrom <thellstrom@vmware.com>

On 06/04/2013 12:03 AM, Kent Overstreet wrote:
> On Mon, May 20, 2013 at 12:07:12AM +0400, Glauber Costa wrote:
>> From: Dave Chinner <dchinner@redhat.com>
>>
>> Convert the driver shrinkers to the new API. Most changes are
>> compile tested only because I either don't have the hardware or it's
>> staging stuff.
> 
> Sorry for not getting to this sooner. Before reviewing the bcache
> changes, a high level comment:
> 
> One of my issues when implementing the shrinker for bcache is that the
> shrinker API has no notion of how big the cached objects are. There
> seems to be an unspoken assumption that objects are page sized - or
> maybe they're at most page sized? I dunno.
> 

Yes, I have considered this myself. I believe there is no assumption at
all that the objects are page sized - most of them actually aren't - so
you might be misunderstanding something. The problem here, is that at
some point we need to decide how many objects to shrink and to make such
decision we take into account the number of LRU pages to scan - that
one, of course, page sized.

This is not the only problem we have with shrinkers. Specially during
direct reclaim, flushing your dear bcache entries will do nothing for a
workload that is hungry for kvm mmu entries. And yet, we'll free them
because we either scan all shrinkers or we don't.

So yes, we could put *a lot* more intelligence in this process, but the
first hurdle of course, is that since this is all a bit heuristic, it is
hard to predict what and where from exactly do we want to free.


> Anyways, this was a source of no small amount of consternation and
> frustration and bugs, and still makes things more fragile and uglier
> than they should be - bcache btree nodes are typically on the order of a
> quarter megabyte, and they're potentially variable sized too (though not
> in practice yet and maybe never).
> 

I would be happy to discuss that further in a separate thread, but that
might be due to a misunderstanding about page-sizedness assumptions. The
filesystem shrinkers, by far the most important one (dentries, inodes,
fs_objects) have no such assumption whatsoever and they have been
working all right.


> Have you given any thought to whether this is fixable? IMO it might
> improve the shrinker API and various implementations as a whole if
> instead of objects everything just talked about some amount of memory in
> bytes.
> 

Yes, I believe this is fixable, but the amount of memory in bytes,
although it could be an improvement, is not really what matters. What
really matters is the cost to recreate the object, no its size.

> We might still need some notion of object size to deal with trying to
> free a smaller amount of memory than a given shrinker's object size (but
> perhaps not if the core shrinker code kept a running total of the
> difference between amount of memory asked to free/memory actually
> freed).
> 
> Also, this would mean we could tell userspace how much memory is in the
> various caches (and potentially freeable), there's no sane way for
> userspace to figure this out today.
> 
> Thoughts?
> 
Above =)

About userspace, I dunno. I am not sure if anything more fine grained
than "drop all caches" - that we already have, would do any good. Any
use case you have for that?


>> diff --git a/drivers/md/bcache/btree.c b/drivers/md/bcache/btree.c
>> index 36688d6..e305f96 100644
>> --- a/drivers/md/bcache/btree.c
>> +++ b/drivers/md/bcache/btree.c
>> @@ -599,24 +599,12 @@ static int mca_reap(struct btree *b, struct closure *cl, unsigned min_order)
>>  	return 0;
>>  }
>>  
>> -static int bch_mca_shrink(struct shrinker *shrink, struct shrink_control *sc)
>> +static long bch_mca_scan(struct shrinker *shrink, struct shrink_control *sc)
>>  {
>>  	struct cache_set *c = container_of(shrink, struct cache_set, shrink);
>>  	struct btree *b, *t;
>>  	unsigned long i, nr = sc->nr_to_scan;
>> -
>> -	if (c->shrinker_disabled)
>> -		return 0;
>> -
>> -	if (c->try_harder)
>> -		return 0;
> 
> This is a behaviour change - after your patch, we only check for
> c->shrinker_disabled or c->try_harder when counting objects, not
> freeing them.
> 

No, this is not. Look at vmscan.c (after the API change)

        max_pass = shrinker->count_objects(shrinker, shrinkctl);
        WARN_ON(max_pass < 0);
        if (max_pass <= 0)
                return 0;

The "return 0" statement means that if there are no objects, the scan
phase won't exist. It will never be called. Part of the reason for such
confusion is that we had the same call for both count and shrink, and
that leads to misunderstandings. It is one of the things we are trying
to fix here.

In any case, the adequate return value for the scan phase in a situation
like that would be -1, not 0.



> So there's a potential race if one of them (c->try_harder would be the
> important one, that means allocating memory for a btree node failed so
> there's a thread that's reclaiming from the btree cache in order to
> allocate a new btree node) is flipped in between the two calls. That
> should be no big deal, though i'm a tiny bit uncomfortable about it.
> 
Ok, so what you are telling me is that it is possible for those values
to *not* be 0 during the count phase, but then arrive in the scan phase
and have flipped in between?

If that is the case then yes, you are right. But we need to return -1,
not 0. (The difference is that 0 in the scan phase will keep looping,
while -1 will break immediately)

So I will add the following fix:

+	if (c->shrinker_disabled)
+		return -1;
+
+	if (c->try_harder)
+		return -1;


> There's a second user visible change - previously, c->shrinker_disabled
> (controlled via userspace through sysfs) would have the side effect of
> disabling prune_cache (called via sysfs) - your patch changes that. It
> probably makes more sense your way but it ought to be noted somewhere.
> 

Sorry, I am not sure I follow you.
It is because we no longer test for shrinker_disabled on scan?

If so, that should be fixing by returning -1 on scan, right ?

>> -
>> -	/*
>> -	 * If nr == 0, we're supposed to return the number of items we have
>> -	 * cached. Not allowed to return -1.
>> -	 */
>> -	if (!nr)
>> -		return mca_can_free(c) * c->btree_pages;
>> +	long freed = 0;
>>  
>>  	/* Return -1 if we can't do anything right now */
>>  	if (sc->gfp_mask & __GFP_WAIT)
>> @@ -629,14 +617,14 @@ static int bch_mca_shrink(struct shrinker *shrink, struct shrink_control *sc)
>>  
>>  	i = 0;
>>  	list_for_each_entry_safe(b, t, &c->btree_cache_freeable, list) {
>> -		if (!nr)
>> +		if (freed >= nr)
>>  			break;
>>  
>>  		if (++i > 3 &&
>>  		    !mca_reap(b, NULL, 0)) {
>>  			mca_data_free(b);
>>  			rw_unlock(true, b);
>> -			--nr;
>> +			freed++;
>>  		}
>>  	}
>>  
>> @@ -647,7 +635,7 @@ static int bch_mca_shrink(struct shrinker *shrink, struct shrink_control *sc)
>>  	if (list_empty(&c->btree_cache))
>>  		goto out;
>>  
>> -	for (i = 0; nr && i < c->bucket_cache_used; i++) {
>> +	for (i = 0; i < c->bucket_cache_used; i++) {
> 
> This is a bug (but it's probably more my fault for writing it too subtly
> in the first place): previously, we broke out of the loop when nr
> reached 0 (and we'd freed all the objects we were asked to).
> 
> After your change it doesn't break out of the loop until trying to free
> _everything_ - which will break things very badly since this causes us
> to free our reserve. You'll want a if (freed >= nr) break; like you
> added in the previous loop.
> 
You are right, we will fix this.

> (The reserve should be documented here too though, I'll write a patch
> for that...)
> 
>>  		b = list_first_entry(&c->btree_cache, struct btree, list);
>>  		list_rotate_left(&c->btree_cache);
>>  
>> @@ -656,14 +644,26 @@ static int bch_mca_shrink(struct shrinker *shrink, struct shrink_control *sc)
>>  			mca_bucket_free(b);
>>  			mca_data_free(b);
>>  			rw_unlock(true, b);
>> -			--nr;
>> +			freed++;
>>  		} else
>>  			b->accessed = 0;
>>  	}
>>  out:
>> -	nr = mca_can_free(c) * c->btree_pages;
>>  	mutex_unlock(&c->bucket_lock);
>> -	return nr;
>> +	return freed;
>> +}
>> +
>> +static long bch_mca_count(struct shrinker *shrink, struct shrink_control *sc)
>> +{
>> +	struct cache_set *c = container_of(shrink, struct cache_set, shrink);
>> +
>> +	if (c->shrinker_disabled)
>> +		return 0;
>> +
>> +	if (c->try_harder)
>> +		return 0;
>> +
>> +	return mca_can_free(c) * c->btree_pages;
>>  }
>>  
>>  void bch_btree_cache_free(struct cache_set *c)
>> @@ -732,7 +732,8 @@ int bch_btree_cache_alloc(struct cache_set *c)
>>  		c->verify_data = NULL;
>>  #endif
>>  
>> -	c->shrink.shrink = bch_mca_shrink;
>> +	c->shrink.count_objects = bch_mca_count;
>> +	c->shrink.scan_objects = bch_mca_scan;
>>  	c->shrink.seeks = 4;
>>  	c->shrink.batch = c->btree_pages * 2;
>>  	register_shrinker(&c->shrink);
>> diff --git a/drivers/md/bcache/sysfs.c b/drivers/md/bcache/sysfs.c
>> index 4d9cca4..fa8d048 100644
>> --- a/drivers/md/bcache/sysfs.c
>> +++ b/drivers/md/bcache/sysfs.c
>> @@ -535,7 +535,7 @@ STORE(__bch_cache_set)
>>  		struct shrink_control sc;
>>  		sc.gfp_mask = GFP_KERNEL;
>>  		sc.nr_to_scan = strtoul_or_return(buf);
>> -		c->shrink.shrink(&c->shrink, &sc);
>> +		c->shrink.scan_objects(&c->shrink, &sc);
>>  	}
>>  
>>  	sysfs_strtoul(congested_read_threshold_us,
> 
> The rest of the changes look good.
> 
> As long as you're looking at the code (and complaining about the quality
> of the various shrinkers :P), if you've got any suggestions/specific
> complaints about the bcache shrinker I'll see what I can do to improve
> it.
> 
Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
