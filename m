Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 372B06B0039
	for <linux-mm@kvack.org>; Thu,  9 May 2013 17:18:34 -0400 (EDT)
Message-ID: <518C12D6.4060003@parallels.com>
Date: Fri, 10 May 2013 01:19:18 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 17/31] drivers: convert shrinkers to new count/scan
 API
References: <1368079608-5611-1-git-send-email-glommer@openvz.org> <1368079608-5611-18-git-send-email-glommer@openvz.org> <20130509135209.GZ11497@suse.de>
In-Reply-To: <20130509135209.GZ11497@suse.de>
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, hughd@google.com, Greg Thelen <gthelen@google.com>, linux-fsdevel@vger.kernel.org, Dave Chinner <dchinner@redhat.com>, Daniel Vetter <daniel.vetter@ffwll.ch>, Kent Overstreet <koverstreet@google.com>, Arve Hj?nnev?g <arve@android.com>, John Stultz <john.stultz@linaro.org>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Thomas Hellstrom <thellstrom@vmware.com>

> 
> Last time I complained about some of the shrinker implementations but
> I'm not expecting them to be fixed in this series. However I still have
> questions about where -1 should be returned that I don't think were
> addressed so I'll repeat them.
> 

Note that the series try to keep the same behavior as we had before.
(modulo mistakes, spotting them are mostly welcome)

So if we are changing any of this, maybe better done in a separate patch?

>> @@ -4472,3 +4470,36 @@ i915_gem_inactive_shrink(struct shrinker *shrinker, struct shrink_control *sc)
>>  		mutex_unlock(&dev->struct_mutex);
>>  	return cnt;
>>  }
>> +static long
>> +i915_gem_inactive_scan(struct shrinker *shrinker, struct shrink_control *sc)
>> +{
>> +	struct drm_i915_private *dev_priv =
>> +		container_of(shrinker,
>> +			     struct drm_i915_private,
>> +			     mm.inactive_shrinker);
>> +	struct drm_device *dev = dev_priv->dev;
>> +	int nr_to_scan = sc->nr_to_scan;
>> +	long freed;
>> +	bool unlock = true;
>> +
>> +	if (!mutex_trylock(&dev->struct_mutex)) {
>> +		if (!mutex_is_locked_by(&dev->struct_mutex, current))
>> +			return 0;
>> +
> 
> return -1 if it's about preventing potential deadlocks?
> 
>> +		if (dev_priv->mm.shrinker_no_lock_stealing)
>> +			return 0;
>> +
> 
> same?
> 

My general opinion is that this one should not use the shrinker
interface, but rather the one-shot one. But that is up to the i915 people.

If shrinkers are to be maintained for whatever reason, I agree with you
-1 would be better. It basically means "give up", while 0 will try to
keep scanning. It is my understanding that in those situations, we would
like to give up and let the process already holding the lock to proceed.

>>
>> diff --git a/drivers/md/bcache/btree.c b/drivers/md/bcache/btree.c
>> index 03e44c1..8b9c1a6 100644
>> --- a/drivers/md/bcache/btree.c
>> +++ b/drivers/md/bcache/btree.c
>> @@ -599,11 +599,12 @@ static int mca_reap(struct btree *b, struct closure *cl, unsigned min_order)
>>  	return 0;
>>  }
>>  
>> -static int bch_mca_shrink(struct shrinker *shrink, struct shrink_control *sc)
>> +static long bch_mca_scan(struct shrinker *shrink, struct shrink_control *sc)
>>  {
>>  	struct cache_set *c = container_of(shrink, struct cache_set, shrink);
>>  	struct btree *b, *t;
>>  	unsigned long i, nr = sc->nr_to_scan;
>> +	long freed = 0;
>>  
>>  	if (c->shrinker_disabled)
>>  		return 0;
> 
> -1 if shrinker disabled?
> 
> Otherwise if the shrinker is disabled we ultimately hit this loop in
> shrink_slab_one()
>

> do {
>         ret = shrinker->scan_objects(shrinker, sc);
>         if (ret == -1)
>                 break
>         ....
>         count_vm_events(SLABS_SCANNED, batch_size);
>         total_scan -= batch_size;
> 
>         cond_resched();
> } while (total_scan >= batch_size);
> 
> which won't break as such but we busy loop until total_scan drops and
> account for SLABS_SCANNED incorrectly.
> 

Same thing as above, I believe -1 is a superior return code for this
situation. That one, however, I may be able to reshuffle myself. That
test can live in bch_mca_count instead of bch_mca_scan. That way we will
provide a count of 0, and then not ever reach scan.

>> <SNIP>
>>
>> +	if (min_score_adj == OOM_SCORE_ADJ_MAX + 1) {
>> +		lowmem_print(5, "lowmem_scan %lu, %x, return 0\n",
>> +			     sc->nr_to_scan, sc->gfp_mask);
>> +		return 0;
>>  	}
>> +
>>  	selected_oom_score_adj = min_score_adj;
>>  
>>  	rcu_read_lock();
> 
> I wasn't convinced by Kent's answer on this one at all but the impact of
> getting it right is a lot less than the other two.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
