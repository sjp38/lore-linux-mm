Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D3ADF6B0275
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 16:32:01 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id y138so19108006wme.7
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 13:32:01 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id ge9si4662823wjd.123.2016.10.26.13.32.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 13:32:00 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id DE2721C17BD
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 21:31:59 +0100 (IST)
Date: Wed, 26 Oct 2016 21:31:58 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: CONFIG_VMAP_STACK, on-stack struct, and wake_up_bit
Message-ID: <20161026203158.GD2699@techsingularity.net>
References: <CAHc6FU4e5sueLi7pfeXnSbuuvnc5PaU3xo5Hnn=SvzmQ+ZOEeg@mail.gmail.com>
 <CALCETrUt+4ojyscJT1AFN5Zt3mKY0rrxcXMBOUUJzzLMWXFXHg@mail.gmail.com>
 <CA+55aFzB2C0aktFZW3GquJF6dhM1904aDPrv4vdQ8=+mWO7jcg@mail.gmail.com>
 <CA+55aFww1iLuuhHw=iYF8xjfjGj8L+3oh33xxUHjnKKnsR-oHg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CA+55aFww1iLuuhHw=iYF8xjfjGj8L+3oh33xxUHjnKKnsR-oHg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>, Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Bob Peterson <rpeterso@redhat.com>, Steven Whitehouse <swhiteho@redhat.com>, linux-mm <linux-mm@kvack.org>

On Wed, Oct 26, 2016 at 10:15:30AM -0700, Linus Torvalds wrote:
> On Wed, Oct 26, 2016 at 9:32 AM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> >
> > Quite frankly, I think the solution is to just rip out all the insane
> > zone crap.
> 
> IOW, something like the attached.
> 
> Advantage:
> 
>  - just look at the number of garbage lines removed!  21
> insertions(+), 182 deletions(-)
> 
>  - it will actually speed up even the current case for all common
> situations: no idiotic extra indirections that will take extra cache
> misses
> 
>  - because the bit_wait_table array is now denser (256 entries is
> about 6kB of data on 64-bit with no spinlock debugging, so ~100
> cachelines), maybe it gets fewer cache misses too
> 
>  - we know how to handle the page_waitqueue contention issue, and it
> has nothing to do with the stupid NUMA zones
> 
> The only case you actually get real page wait activity is IO, and I
> suspect that hashing it out over ~100 cachelines will be more than
> sufficient to avoid excessive contention, plus it's a cache-miss vs an
> IO, so nobody sane cares.
> 

IO wait activity is not all that matters. We hit the lock/unlock paths
during a lot of operations like reclaim.

False sharing is possible with either the new or old scheme so it's
irrelevant. There will be some remote NUMA cache misses which may be made
worse by false sharing. In the reclaim case, the bulk of those are hit
by kswapd. Kswapd itself doesn't care but there may be increased NUMA
traffic. By the time you hit direct reclaim, a remote cache miss is not
going to be the end of the world.

> Guys, holler if you hate this, but I think it's realistically the only
> sane solution to the "wait queue on stack" issue.
> 

Hate? No.

It's not clear cut that NUMA remote accesses will be a problem. A remote
cache miss may or may not be more expensive than multiple calculations,
virt->page calculations and chasing pointers to lookup the zone and the
table. It's multiple potential local misses versus one remote.

Even if NUMA conflicts are a problem then 256 entries gives 96 cache
lines. For pages only, the hash routine could partition table space into
max(96, nr_online_nodes) partitions. It wouldn't be perfect as wait_table_t
does not align well with cache line sizes so there would be collisions
on the boundary but it'd be close enough. It would require page_waitqueue
use a different hashing function so it's not simple but it's possible if
someone is sufficiently motivated and found a workload that matters.

There is some question whether the sizing will lead to more collisions and
spurious wakeups. There is no way to predict how much of an issue that is
but I suspect a lot of those happen during reclaim anyway. If collisions
are a problem then the table could be dynamically sized in the similar
way the inode and dcache hash tables are.

I didn't test this as I don't have a machine available right now.  The bulk
of what you removed was related to hotplug but the result looks hotplug safe.
So I've only Two minor nits only and a general caution to watch for increased
collisions and spurious wakeups with a minor caution about remote access
penalties.

> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 7f2ae99e5daf..0f088f3a2fed 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -440,33 +440,7 @@ struct zone {
>  	seqlock_t		span_seqlock;
>  #endif
>  
> -	/*
> -	 * wait_table		-- the array holding the hash table
> -	 * wait_table_hash_nr_entries	-- the size of the hash table array
> -	 * wait_table_bits	-- wait_table_size == (1 << wait_table_bits)
> -	 *
> -	 * The purpose of all these is to keep track of the people
> -	 * waiting for a page to become available and make them
> -	 * runnable again when possible. The trouble is that this
> -	 * consumes a lot of space, especially when so few things
> -	 * wait on pages at a given time. So instead of using
> -	 * per-page waitqueues, we use a waitqueue hash table.
> -	 *
> -	 * The bucket discipline is to sleep on the same queue when
> -	 * colliding and wake all in that wait queue when removing.
> -	 * When something wakes, it must check to be sure its page is
> -	 * truly available, a la thundering herd. The cost of a
> -	 * collision is great, but given the expected load of the
> -	 * table, they should be so rare as to be outweighed by the
> -	 * benefits from the saved space.
> -	 *
> -	 * __wait_on_page_locked() and unlock_page() in mm/filemap.c, are the
> -	 * primary users of these fields, and in mm/page_alloc.c
> -	 * free_area_init_core() performs the initialization of them.
> -	 */
> -	wait_queue_head_t	*wait_table;
> -	unsigned long		wait_table_hash_nr_entries;
> -	unsigned long		wait_table_bits;
> +	int initialized;
>  
>  	/* Write-intensive fields used from the page allocator */
>  	ZONE_PADDING(_pad1_)

zone_is_initialized is mostly the domain of hotplug. A potential cleanup
is to use a page flag and shrink the size of zone slightly. Nothing to
panic over.

> @@ -546,7 +520,7 @@ static inline bool zone_spans_pfn(const struct zone *zone, unsigned long pfn)
>  
>  static inline bool zone_is_initialized(struct zone *zone)
>  {
> -	return !!zone->wait_table;
> +	return zone->initialized;
>  }
>  
>  static inline bool zone_is_empty(struct zone *zone)
> diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> index 94732d1ab00a..42d4027f9e26 100644
> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> @@ -7515,11 +7515,27 @@ static struct kmem_cache *task_group_cache __read_mostly;
>  DECLARE_PER_CPU(cpumask_var_t, load_balance_mask);
>  DECLARE_PER_CPU(cpumask_var_t, select_idle_mask);
>  
> +#define WAIT_TABLE_BITS 8
> +#define WAIT_TABLE_SIZE (1 << WAIT_TABLE_BITS)
> +static wait_queue_head_t bit_wait_table[WAIT_TABLE_SIZE] __cacheline_aligned;
> +
> +wait_queue_head_t *bit_waitqueue(void *word, int bit)
> +{
> +	const int shift = BITS_PER_LONG == 32 ? 5 : 6;
> +	unsigned long val = (unsigned long)word << shift | bit;
> +
> +	return bit_wait_table + hash_long(val, WAIT_TABLE_BITS);
> +}
> +EXPORT_SYMBOL(bit_waitqueue);
> +

Minor nit that it's unfortunate this moved to the scheduler core. It
wouldn't have been a complete disaster to add a page_waitqueue_init() or
something similar after sched_init.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
