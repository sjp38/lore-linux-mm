Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id EAC406B0005
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 08:30:12 -0400 (EDT)
Date: Tue, 9 Apr 2013 22:30:08 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2 02/28] vmscan: take at least one pass with shrinkers
Message-ID: <20130409123008.GM17758@dastard>
References: <1364548450-28254-1-git-send-email-glommer@parallels.com>
 <1364548450-28254-3-git-send-email-glommer@parallels.com>
 <20130408084202.GA21654@lge.com>
 <51628412.6050803@parallels.com>
 <20130408090131.GB21654@lge.com>
 <51628877.5000701@parallels.com>
 <20130409005547.GC21654@lge.com>
 <20130409012931.GE17758@dastard>
 <20130409020505.GA4218@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130409020505.GA4218@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, hughd@google.com, yinghan@google.com, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>

On Tue, Apr 09, 2013 at 11:05:05AM +0900, Joonsoo Kim wrote:
> On Tue, Apr 09, 2013 at 11:29:31AM +1000, Dave Chinner wrote:
> > On Tue, Apr 09, 2013 at 09:55:47AM +0900, Joonsoo Kim wrote:
> > > lowmemkiller makes spare memory via killing a task.
> > > 
> > > Below is code from lowmem_shrink() in lowmemorykiller.c
> > > 
> > >         for (i = 0; i < array_size; i++) {
> > >                 if (other_free < lowmem_minfree[i] &&
> > >                     other_file < lowmem_minfree[i]) {
> > >                         min_score_adj = lowmem_adj[i];
> > >                         break;
> > >                 }   
> > >         } 
> > 
> > I don't think you understand what the current lowmemkiller shrinker
> > hackery actually does.
> > 
> >         rem = global_page_state(NR_ACTIVE_ANON) +
> >                 global_page_state(NR_ACTIVE_FILE) +
> >                 global_page_state(NR_INACTIVE_ANON) +
> >                 global_page_state(NR_INACTIVE_FILE);
> >         if (sc->nr_to_scan <= 0 || min_score_adj == OOM_SCORE_ADJ_MAX + 1) {
> >                 lowmem_print(5, "lowmem_shrink %lu, %x, return %d\n",
> >                              sc->nr_to_scan, sc->gfp_mask, rem);
> >                 return rem;
> >         }
> > 
> > So, when nr_to_scan == 0 (i.e. the count phase), the shrinker is
> > going to return a count of active/inactive pages in the cache. That
> > is almost always going to be non-zero, and almost always be > 1000
> > because of the minimum working set needed to run the system.
> > Even after applying the seek count adjustment, total_scan is almost
> > always going to be larger than the shrinker default batch size of
> > 128, and that means this shrinker will almost always run at least
> > once per shrink_slab() call.
> 
> I don't think so.
> Yes, lowmem_shrink() return number of (in)active lru pages
> when nr_to_scan is 0. And in shrink_slab(), we divide it by lru_pages.
> lru_pages can vary where shrink_slab() is called, anyway, perhaps this
> logic makes total_scan below 128.

"perhaps"


There is no "perhaps" here - there is *zero* guarantee of the
behaviour you are claiming the lowmem killer shrinker is dependent
on with the existing shrinker infrastructure. So, lets say we have:

	nr_pages_scanned = 1000
	lru_pages = 100,000

Your shrinker is going to return 100,000 when nr_to_scan = 0. So,
we have:

	batch_size = SHRINK_BATCH = 128
	max_pass= 100,000

	total_scan = shrinker->nr_in_batch = 0
	delta = 4 * 1000 / 32 = 128
	delta = 128 * 100,000 = 12,800,000
	delta = 12,800,000 / 100,001 = 127
	total_scan += delta = 127

Assuming the LRU pages count does not change(*), nr_pages_scanned is
irrelevant and delta always comes in 1 count below the batch size,
and the shrinker is not called. The remainder is then:

	shrinker->nr_in_batch += total_scan = 127

(*) the lru page count will change, because reclaim and shrinkers
run concurrently, and so we can't even make a simple contrived case
where delta is consistently < batch_size here.

Anyway, the next time the shrinker is entered, we start with:

	total_scan = shrinker->nr_in_batch = 127
	.....
	total_scan += delta = 254

	<shrink once, total scan -= batch_size = 126>

	shrinker->nr_in_batch += total_scan = 126

And so on for all the subsequent shrink_slab calls....

IOWs, this algorithm effectively causes the shrinker to be called
127 times out of 128 in this arbitrary scenario. It does not behave
as you are assuming it to, and as such any code based on those
assumptions is broken....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
