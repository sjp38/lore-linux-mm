Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id C1C956B003B
	for <linux-mm@kvack.org>; Thu,  9 May 2013 09:52:15 -0400 (EDT)
Date: Thu, 9 May 2013 14:52:09 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v5 17/31] drivers: convert shrinkers to new count/scan API
Message-ID: <20130509135209.GZ11497@suse.de>
References: <1368079608-5611-1-git-send-email-glommer@openvz.org>
 <1368079608-5611-18-git-send-email-glommer@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1368079608-5611-18-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, hughd@google.com, Greg Thelen <gthelen@google.com>, linux-fsdevel@vger.kernel.org, Dave Chinner <dchinner@redhat.com>, Daniel Vetter <daniel.vetter@ffwll.ch>, Kent Overstreet <koverstreet@google.com>, Arve Hj?nnev?g <arve@android.com>, John Stultz <john.stultz@linaro.org>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Thomas Hellstrom <thellstrom@vmware.com>

On Thu, May 09, 2013 at 10:06:34AM +0400, Glauber Costa wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> Convert the driver shrinkers to the new API. Most changes are
> compile tested only because I either don't have the hardware or it's
> staging stuff.
> 
> FWIW, the md and android code is pretty good, but the rest of it
> makes me want to claw my eyes out.  The amount of broken code I just
> encountered is mind boggling.  I've added comments explaining what
> is broken, but I fear that some of the code would be best dealt with
> by being dragged behind the bike shed, burying in mud up to it's
> neck and then run over repeatedly with a blunt lawn mower.
> 
> Special mention goes to the zcache/zcache2 drivers. They can't
> co-exist in the build at the same time, they are under different
> menu options in menuconfig, they only show up when you've got the
> right set of mm subsystem options configured and so even compile
> testing is an exercise in pulling teeth.  And that doesn't even take
> into account the horrible, broken code...
> 
> [ glommer: fixes for i915, android lowmem, zcache, bcache ]
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> Signed-off-by: Glauber Costa <glommer@openvz.org>
> CC: Daniel Vetter <daniel.vetter@ffwll.ch>
> CC: Kent Overstreet <koverstreet@google.com>
> CC: Arve Hjonnevag <arve@android.com>
> CC: John Stultz <john.stultz@linaro.org>
> CC: David Rientjes <rientjes@google.com>
> CC: Jerome Glisse <jglisse@redhat.com>
> CC: Thomas Hellstrom <thellstrom@vmware.com>

Last time I complained about some of the shrinker implementations but
I'm not expecting them to be fixed in this series. However I still have
questions about where -1 should be returned that I don't think were
addressed so I'll repeat them.

> @@ -4472,3 +4470,36 @@ i915_gem_inactive_shrink(struct shrinker *shrinker, struct shrink_control *sc)
>  		mutex_unlock(&dev->struct_mutex);
>  	return cnt;
>  }
> +static long
> +i915_gem_inactive_scan(struct shrinker *shrinker, struct shrink_control *sc)
> +{
> +	struct drm_i915_private *dev_priv =
> +		container_of(shrinker,
> +			     struct drm_i915_private,
> +			     mm.inactive_shrinker);
> +	struct drm_device *dev = dev_priv->dev;
> +	int nr_to_scan = sc->nr_to_scan;
> +	long freed;
> +	bool unlock = true;
> +
> +	if (!mutex_trylock(&dev->struct_mutex)) {
> +		if (!mutex_is_locked_by(&dev->struct_mutex, current))
> +			return 0;
> +

return -1 if it's about preventing potential deadlocks?

> +		if (dev_priv->mm.shrinker_no_lock_stealing)
> +			return 0;
> +

same?

> +		unlock = false;
> +	}
> +
> +	freed = i915_gem_purge(dev_priv, nr_to_scan);
> +	if (freed < nr_to_scan)
> +		freed += __i915_gem_shrink(dev_priv, nr_to_scan,
> +							false);
> +	if (freed < nr_to_scan)
> +		freed += i915_gem_shrink_all(dev_priv);
> +
> +	if (unlock)
> +		mutex_unlock(&dev->struct_mutex);
> +	return freed;
> +}
>
> <SNIP>
>
> diff --git a/drivers/md/bcache/btree.c b/drivers/md/bcache/btree.c
> index 03e44c1..8b9c1a6 100644
> --- a/drivers/md/bcache/btree.c
> +++ b/drivers/md/bcache/btree.c
> @@ -599,11 +599,12 @@ static int mca_reap(struct btree *b, struct closure *cl, unsigned min_order)
>  	return 0;
>  }
>  
> -static int bch_mca_shrink(struct shrinker *shrink, struct shrink_control *sc)
> +static long bch_mca_scan(struct shrinker *shrink, struct shrink_control *sc)
>  {
>  	struct cache_set *c = container_of(shrink, struct cache_set, shrink);
>  	struct btree *b, *t;
>  	unsigned long i, nr = sc->nr_to_scan;
> +	long freed = 0;
>  
>  	if (c->shrinker_disabled)
>  		return 0;

-1 if shrinker disabled?

Otherwise if the shrinker is disabled we ultimately hit this loop in
shrink_slab_one()

do {
        ret = shrinker->scan_objects(shrinker, sc);
        if (ret == -1)
                break
        ....
        count_vm_events(SLABS_SCANNED, batch_size);
        total_scan -= batch_size;

        cond_resched();
} while (total_scan >= batch_size);

which won't break as such but we busy loop until total_scan drops and
account for SLABS_SCANNED incorrectly.

> <SNIP>
>
> +	if (min_score_adj == OOM_SCORE_ADJ_MAX + 1) {
> +		lowmem_print(5, "lowmem_scan %lu, %x, return 0\n",
> +			     sc->nr_to_scan, sc->gfp_mask);
> +		return 0;
>  	}
> +
>  	selected_oom_score_adj = min_score_adj;
>  
>  	rcu_read_lock();

I wasn't convinced by Kent's answer on this one at all but the impact of
getting it right is a lot less than the other two.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
