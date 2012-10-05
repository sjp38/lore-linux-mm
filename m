Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 1757F6B0069
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 05:29:20 -0400 (EDT)
Date: Fri, 5 Oct 2012 10:29:12 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC] vmevent: Implement pressure attribute
Message-ID: <20121005092912.GA29125@suse.de>
References: <20121004110524.GA1821@lizard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121004110524.GA1821@lizard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: Pekka Enberg <penberg@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, Colin Cross <ccross@android.com>, Arve Hj?nnev?g <arve@android.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Thu, Oct 04, 2012 at 04:05:24AM -0700, Anton Vorontsov wrote:
> Hi all,
> 
> This is just an RFC so far. It's an attempt to implement Mel Gorman's idea
> of detecting and measuring memory pressure by calculating the ratio of
> scanned vs. reclaimed pages in a given time frame.
> 

Thanks for this.

> The implemented approach can notify userland about two things:
> 
> - Constantly rising number of scanned pages shows that Linux is busy w/
>   rehashing pages in general. The more we scan, the more it's obvious that
>   we're out of unused pages, and we're draining caches. By itself it's not
>   critical, but for apps that want to maintain caches level (like Android)
>   it's quite useful. The notifications are ratelimited by a specified
>   amount of scanned pages.
> 

This is tricky but yes, a "constantly rising" increase of scanning can
be of note. It's important to remember that a stready-streamer such as
video playback can have a constant rate of scanning, but it's not
indicative of a problem and it should not necessarily raise an event to
userspace.

There should be three distinct stages that we're trying to spot.

kswapd scanning rate rising, direct reclaim scanning 0
kswapd scanning rate rising or levelling off, direct reclaim scanning
kswapd scanning rate levelling, direct reclaim levelling, efficiency dropping

Detecting all three is not critical for notification to be useful but
it's probably the ideal.

Either way, I prefer attempting something like this a lot more than
firing a notification because free memory is low!

> - Next, we calculate pressure using '100 - reclaimed/scanned * 100'
>   formula. The value shows (in percents) how efficiently the kernel
>   reclaims pages.

Surely that is measuring inefficiency? Efficiency as measured by MMTests
looks something like

efficiency = steal * 100 / scan;

>   If we take number of scanned pages and think of them as
>   a time scale, then these percents basically would show us how much of
>   the time Linux is spending to find reclaimable pages.

I see what you're trying to do and it's not "time" as such but it's
certainly related.

> 0% means that
>   every page is a candidate for reclaim, 100% means that MM is not
>   recliaming at all, it spends all the time scanning and desperately
>   trying to find something to reclaim. The more time we're at the high
>   percentage level, the more chances that we'll OOM soon.
> 

And I like the metric but not the name - mostly because we've used the
term "reclaim efficiency" to mean the opposite in the past. Ok, I'm
biased because it's how MM Tests defines it and how I described it in
some patches but I'd still prefer that notification use the same value
or at least rename it if it's another value.

For your current definition how about "Reclaim inefficiency" or "Reclaim
wastage"?

"Reclaim inefficiency is the percentage of scans of pages that were not
reclaimed"

"Reclaim wastage refers to the time spent by the kernel uselessly
scanning pages"

> So, if we fail to find a page in a reasonable time frame, we're obviously
> in trouble, no matter how much reclaimable memory we actually have --
> we're too slow, and so we'd better free something.
> 

This is of course the decision that is being punted to userspace to
co-operate with the VM. With userspace co-operation pages may be discarded
instead of swapped.

> Although it must be noted that the pressure factor might be affected by
> reclaimable vs. non-reclaimable pages "fragmentation" in an LRU. If
> there's a "hole" of reclaimable memory in an almost-OOMed system, the
> factor will drop temporary. On the other hand, it just shows how
> efficiently Linux is keeping the lists, it might be pretty inefficient,
> and the factor will show it.
> 
> Some more notes:
> 
> - Although the scheme sounds good, I noticed that reclaimer 'priority'
>   level (i.e. scanning depth) better responds to pressure (it's more
>   smooth), and so far I'm not sure how to make the original idea to work
>   on a par w/ sc->priority level.
> 

While I'm not against the idea of using priority, I'm more wary of it.
Priority can be artifically kept low in some circumstances and I worry
that big changes in its meaning would mean that notification is
unpredictable between some kernel releases. I could be totally wrong
here of course but it is a concern.

Directly comparing the approaches would be hard but I guess you could
measure things like the rate events fired (easy) and preferably some way of
detecting false positives (hard).

> - I have an idea, which I might want to try some day. Currently, the
>   pressure callback is hooked into the inactive list reclaim path, it's
>   the last step in the 'to be reclaimed' page's life time. But we could
>   measure 'active -> inactive' migration speed, i.e. pages deactivation
>   rate. Or we could measure inactive/active LRU size ratio, ideally
>   behaving system would try to keep the ratio near 1, and it'll be close
>   to 0 when inactive list is getting short (for anon LRU it'd be not 1,
>   but zone->inactive_ratio actually).
> 

It's potentially interesting but bear in mind that some system calls
that deactive a bunch of pages like fadvise(DONTNEED) of dirty pages
might confuse this.

> diff --git a/include/linux/vmevent.h b/include/linux/vmevent.h
> index b1c4016..1397ade 100644
> --- a/include/linux/vmevent.h
> +++ b/include/linux/vmevent.h
> @@ -10,6 +10,7 @@ enum {
>  	VMEVENT_ATTR_NR_AVAIL_PAGES	= 1UL,
>  	VMEVENT_ATTR_NR_FREE_PAGES	= 2UL,
>  	VMEVENT_ATTR_NR_SWAP_PAGES	= 3UL,
> +	VMEVENT_ATTR_PRESSURE		= 4UL,
>  
>  	VMEVENT_ATTR_MAX		/* non-ABI */
>  };

I don't care about this as such but do you think you'll want high pressure
and low pressure notifications in the future or is that overkill?

low, shrink cache
high, processes consider exiting

or something, dunno really.

> @@ -46,6 +47,11 @@ struct vmevent_attr {
>  	__u64			value;
>  
>  	/*
> +	 * Some attributes accept two configuration values.
> +	 */
> +	__u64			value2;
> +
> +	/*
>  	 * Type of profiled attribute from VMEVENT_ATTR_XXX
>  	 */
>  	__u32			type;
> @@ -97,4 +103,34 @@ struct vmevent_event {
>  	struct vmevent_attr	attrs[];
>  };
>  
> +#ifdef __KERNEL__
> +
> +struct mem_cgroup;
> +
> +extern void __vmevent_pressure(struct mem_cgroup *memcg,
> +			       ulong scanned,
> +			       ulong reclaimed);
> +
> +static inline void vmevent_pressure(struct mem_cgroup *memcg,
> +				    ulong scanned,
> +				    ulong reclaimed)
> +{
> +	if (!scanned)
> +		return;
> +
> +	if (IS_BUILTIN(CONFIG_MEMCG) && memcg) {
> +		/*
> +		 * The vmevent API reports system pressure, for per-cgroup
> +		 * pressure, we'll chain cgroups notifications, this is to
> +		 * be implemented.
> +		 *
> +		 * memcg_vm_pressure(target_mem_cgroup, scanned, reclaimed);
> +		 */
> +		return;
> +	}

Ok, maybe the memcg people will be able to help with how these notifications
should be chained. I do not think it should be considered a blocker for
merging anyway.

> +	__vmevent_pressure(memcg, scanned, reclaimed);
> +}
> +
> +#endif
> +
>  #endif /* _LINUX_VMEVENT_H */
> diff --git a/mm/vmevent.c b/mm/vmevent.c
> index d643615..12d0131 100644
> --- a/mm/vmevent.c
> +++ b/mm/vmevent.c
> @@ -4,6 +4,7 @@
>  #include <linux/vmevent.h>
>  #include <linux/syscalls.h>
>  #include <linux/workqueue.h>
> +#include <linux/interrupt.h>
>  #include <linux/file.h>
>  #include <linux/list.h>
>  #include <linux/poll.h>
> @@ -30,6 +31,25 @@ struct vmevent_watch {
>  	wait_queue_head_t		waitq;
>  };
>  

/* vmevent for watching VM pressure */
> +struct vmevent_pwatcher {
> +	struct vmevent_watch *watch;
> +	struct vmevent_attr *attr;
> +	struct vmevent_attr *samp;
> +	struct list_head node;
> +
> +	uint scanned;
> +	uint reclaimed;
> +	uint window;
> +};
> +
> +static LIST_HEAD(vmevent_pwatchers);
> +static DEFINE_SPINLOCK(vmevent_pwatchers_lock);
> +

Comment that the lock protects the list of current watchers of pressure
and is taken during watcher registration and deregisteration.

> +static uint vmevent_scanned;
> +static uint vmevent_reclaimed;
> +static uint vmevent_minwin = UINT_MAX; /* Smallest window in the list. */
> +static DEFINE_SPINLOCK(vmevent_pressure_lock);
> +

It's an RFC so do not consider this a slam but it may need fixing.

The vmevent_pressure_lock protects the vmevent_scanned, vmevent_reclaimed
etc from concurrent modification but this happens on every
shrink_inactive_list(). On small machines, this will not be a problem
but on big machines, this is not going to scale at all. It could in fact
force all reclaim to globally synchronise on this lock.

One possibility would be to make these per-cpu and lockless when
incrementing the counters. When they reach a threshold, take the lock
and update a central counter. It would introduce the problem that you
suffer from per-cpu counter drift so it's not perfectly
straight-forward.

Another possibility to consider is that you sample the vmstat counters
in the zone from vmevent_pressure and measure the difference from the
last read. That might be harder to get accurate figures from though.

>  typedef u64 (*vmevent_attr_sample_fn)(struct vmevent_watch *watch,
>  				      struct vmevent_attr *attr);
>  
> @@ -141,6 +161,10 @@ static bool vmevent_match(struct vmevent_watch *watch)
>  		struct vmevent_attr *samp = &watch->sample_attrs[i];
>  		u64 val;
>  
> +		/* Pressure is event-driven, not polled */
> +		if (attr->type == VMEVENT_ATTR_PRESSURE)
> +			continue;
> +
>  		val = vmevent_sample_attr(watch, attr);
>  		if (!ret && vmevent_match_attr(attr, val))
>  			ret = 1;
> @@ -204,6 +228,94 @@ static void vmevent_start_timer(struct vmevent_watch *watch)
>  	vmevent_schedule_watch(watch);
>  }
>  
> +static ulong vmevent_calc_pressure(struct vmevent_pwatcher *pw)
> +{
> +	uint win = pw->window;
> +	uint s = pw->scanned;
> +	uint r = pw->reclaimed;
> +	ulong p;
> +
> +	/*
> +	 * We calculate the ratio (in percents) of how many pages were
> +	 * scanned vs. reclaimed in a given time frame (window). Note that
> +	 * time is in VM reclaimer's "ticks", i.e. number of pages
> +	 * scanned. This makes it possible set desired reaction time and
> +	 * serves as a ratelimit.
> +	 */
> +	p = win - (r * win / s);
> +	p = p * 100 / win;
> +
> +	pr_debug("%s: %3lu  (s: %6u  r: %6u)\n", __func__, p, s, r);
> +
> +	return p;
> +}

Ok.

> +
> +static void vmevent_match_pressure(struct vmevent_pwatcher *pw)
> +{
> +	struct vmevent_watch *watch = pw->watch;
> +	struct vmevent_attr *attr = pw->attr;
> +	ulong val;
> +
> +	val = vmevent_calc_pressure(pw);
> +
> +	/* Next round. */
> +	pw->scanned = 0;
> +	pw->reclaimed = 0;
> +
> +	if (!vmevent_match_attr(attr, val))
> +		return;
> +

So, it's not commented on but if there is a brief spike in reclaim
inefficiency due to slow storage then this might prematurely fire
because there is no attempt to level off spikes.

To deal with this you would need to smooth out these spikes by
considering multiple window sizes and only firing when all are hit. This
does not necessaarily need to be visible to userspace because you could
select the additional window sizes based on the size of the initial
window.

I also do not think that this problem needs to be fixed in the initial
version because I could be wrong about it being a problem. It would be nice
if it was documented in the comments though so if bug reports reports show
up about caches shrinking too quickly because the event fires prematurely
there is an idea in place on how to fix it.

> +	pw->samp->value = val;
> +
> +	atomic_set(&watch->pending, 1);
> +	wake_up(&watch->waitq);
> +}
> +
> +static void vmevent_pressure_tlet_fn(ulong data)
> +{
> +	struct vmevent_pwatcher *pw;
> +	uint s;
> +	uint r;
> +
> +	if (!vmevent_scanned)
> +		return;
> +
> +	spin_lock(&vmevent_pressure_lock);
> +	s = vmevent_scanned;
> +	r = vmevent_reclaimed;
> +	vmevent_scanned = 0;
> +	vmevent_reclaimed = 0;
> +	spin_unlock(&vmevent_pressure_lock);
> +

Same as before, the pressure pool and reclaim contend for the same lock
which is less than ideal.

> +	rcu_read_lock();
> +	list_for_each_entry_rcu(pw, &vmevent_pwatchers, node) {
> +		pw->scanned += s;
> +		pw->reclaimed += r;
> +		if (pw->scanned >= pw->window)
> +			vmevent_match_pressure(pw);
> +	}
> +	rcu_read_unlock();

RCU seems overkill here. Protect it with the normal spinlock but use
trylock here and abort the poll if the lock cannot be acquired. At worst
a few polls will be missed while an event notifier is being registered.

> +}
> +static DECLARE_TASKLET(vmevent_pressure_tlet, vmevent_pressure_tlet_fn, 0);
> +

Why a tasklet? What fires it? How often?

> +void __vmevent_pressure(struct mem_cgroup *memcg,
> +			ulong scanned,
> +			ulong reclaimed)
> +{
> +	if (vmevent_minwin == UINT_MAX)
> +		return;
> +
> +	spin_lock_bh(&vmevent_pressure_lock);
> +
> +	vmevent_scanned += scanned;
> +	vmevent_reclaimed += reclaimed;
> +
> +	if (vmevent_scanned >= vmevent_minwin)
> +		tasklet_schedule(&vmevent_pressure_tlet);
> +
> +	spin_unlock_bh(&vmevent_pressure_lock);
> +}
> +
>  static unsigned int vmevent_poll(struct file *file, poll_table *wait)
>  {
>  	struct vmevent_watch *watch = file->private_data;
> @@ -259,12 +371,40 @@ out:
>  	return ret;
>  }
>  
> +static void vmevent_release_pwatcher(struct vmevent_watch *watch)
> +{
> +	struct vmevent_pwatcher *pw;
> +	struct vmevent_pwatcher *tmp;
> +	struct vmevent_pwatcher *del = NULL;
> +	int last = 1;
> +
> +	spin_lock(&vmevent_pwatchers_lock);
> +
> +	list_for_each_entry_safe(pw, tmp, &vmevent_pwatchers, node) {
> +		if (pw->watch != watch) {
> +			vmevent_minwin = min(pw->window, vmevent_minwin);
> +			last = 0;
> +			continue;
> +		}
> +		WARN_ON(del);
> +		list_del_rcu(&pw->node);
> +		del = pw;
> +	}
> +
> +	if (last)
> +		vmevent_minwin = UINT_MAX;
> +
> +	spin_unlock(&vmevent_pwatchers_lock);
> +	synchronize_rcu();
> +	kfree(del);

So again I think the RCU is overkill and could be protected by a plain
spinlock. At least I would be surprised if pwatcher register/release was
a frequent operation.

> +}
> +
>  static int vmevent_release(struct inode *inode, struct file *file)
>  {
>  	struct vmevent_watch *watch = file->private_data;
>  
>  	cancel_delayed_work_sync(&watch->work);
> -
> +	vmevent_release_pwatcher(watch);
>  	kfree(watch);
>  
>  	return 0;
> @@ -289,6 +429,36 @@ static struct vmevent_watch *vmevent_watch_alloc(void)
>  	return watch;
>  }
>  
> +static int vmevent_setup_pwatcher(struct vmevent_watch *watch,
> +				  struct vmevent_attr *attr,
> +				  struct vmevent_attr *samp)
> +{
> +	struct vmevent_pwatcher *pw;
> +
> +	if (attr->type != VMEVENT_ATTR_PRESSURE)
> +		return 0;
> +
> +	if (!attr->value2)
> +		return -EINVAL;
> +
> +	pw = kzalloc(sizeof(*pw), GFP_KERNEL);
> +	if (!pw)
> +		return -ENOMEM;
> +
> +	pw->watch = watch;
> +	pw->attr = attr;
> +	pw->samp = samp;
> +	pw->window = (attr->value2 + PAGE_SIZE - 1) / PAGE_SIZE;
> +
> +	vmevent_minwin = min(pw->window, vmevent_minwin);
> +
> +	spin_lock(&vmevent_pwatchers_lock);
> +	list_add_rcu(&pw->node, &vmevent_pwatchers);
> +	spin_unlock(&vmevent_pwatchers_lock);
> +
> +	return 0;
> +}
> +
>  static int vmevent_setup_watch(struct vmevent_watch *watch)
>  {
>  	struct vmevent_config *config = &watch->config;
> @@ -302,6 +472,7 @@ static int vmevent_setup_watch(struct vmevent_watch *watch)
>  		struct vmevent_attr *attr = &config->attrs[i];
>  		size_t size;
>  		void *new;
> +		int ret;
>  
>  		if (attr->type >= VMEVENT_ATTR_MAX)
>  			continue;
> @@ -322,6 +493,12 @@ static int vmevent_setup_watch(struct vmevent_watch *watch)
>  
>  		watch->config_attrs[nr] = attr;
>  
> +		ret = vmevent_setup_pwatcher(watch, attr, &attrs[nr]);
> +		if (ret) {
> +			kfree(attrs);
> +			return ret;
> +		}
> +
>  		nr++;
>  	}
>  
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 99b434b..f4dd1e0 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -20,6 +20,7 @@
>  #include <linux/init.h>
>  #include <linux/highmem.h>
>  #include <linux/vmstat.h>
> +#include <linux/vmevent.h>
>  #include <linux/file.h>
>  #include <linux/writeback.h>
>  #include <linux/blkdev.h>
> @@ -1334,6 +1335,9 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  		nr_scanned, nr_reclaimed,
>  		sc->priority,
>  		trace_shrink_flags(file));
> +
> +	vmevent_pressure(sc->target_mem_cgroup, nr_scanned, nr_reclaimed);
> +
>  	return nr_reclaimed;
>  }
>  

Very broadly speaking I think this will work better in practice than plain
"low memory notification" which I expect fires too often. There are some
things that need fixing up, some comments and some clarifications but I
think they can be addressed. The firing on spikes might be a problem in
the future but it can be fixed without changing the user-visible API.

Thanks Anton.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
