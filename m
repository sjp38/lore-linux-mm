Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 7C1E5900138
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 08:17:29 -0400 (EDT)
Date: Thu, 18 Aug 2011 20:17:14 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH v9 12/13] memcg: create support routines for page
 writeback
Message-ID: <20110818121714.GA1883@localhost>
References: <1313597705-6093-1-git-send-email-gthelen@google.com>
 <1313597705-6093-13-git-send-email-gthelen@google.com>
 <20110818103803.c2617804.kamezawa.hiroyu@jp.fujitsu.com>
 <20110818023610.GA12514@localhost>
 <20110818101248.GA12426@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110818101248.GA12426@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <david@fromorbit.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <andrea@betterlinux.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, "Li, Shaohua" <shaohua.li@intel.com>, "Shi, Alex" <alex.shi@intel.com>, "Chen, Tim C" <tim.c.chen@intel.com>

On Thu, Aug 18, 2011 at 06:12:48PM +0800, Jan Kara wrote:
> On Thu 18-08-11 10:36:10, Wu Fengguang wrote:
> > Subject: squeeze max-pause area and drop pass-good area
> > Date: Tue Aug 16 13:37:14 CST 2011
> > 
> > Remove the pass-good area introduced in ffd1f609ab10 ("writeback:
> > introduce max-pause and pass-good dirty limits") and make the
> > max-pause area smaller and safe.
> > 
> > This fixes ~30% performance regression in the ext3 data=writeback
> > fio_mmap_randwrite_64k/fio_mmap_randrw_64k test cases, where there are
> > 12 JBOD disks, on each disk runs 8 concurrent tasks doing reads+writes.
> > 
> > Using deadline scheduler also has a regression, but not that big as
> > CFQ, so this suggests we have some write starvation.
> > 
> > The test logs show that
> > 
> > - the disks are sometimes under utilized
> > 
> > - global dirty pages sometimes rush high to the pass-good area for
> >   several hundred seconds, while in the mean time some bdi dirty pages
> >   drop to very low value (bdi_dirty << bdi_thresh).
> >   Then suddenly the global dirty pages dropped under global dirty
> >   threshold and bdi_dirty rush very high (for example, 2 times higher
> >   than bdi_thresh). During which time balance_dirty_pages() is not
> >   called at all.
> > 
> > So the problems are
> > 
> > 1) The random writes progress so slow that they break the assumption of
> > the max-pause logic that "8 pages per 200ms is typically more than
> > enough to curb heavy dirtiers".
> > 
> > 2) The max-pause logic ignored task_bdi_thresh and thus opens the
> >    possibility for some bdi's to over dirty pages, leading to
> >    (bdi_dirty >> bdi_thresh) and then (bdi_thresh >> bdi_dirty) for others.
> > 
> > 3) The higher max-pause/pass-good thresholds somehow leads to some bad
> >    swing of dirty pages.
> > 
> > The fix is to allow the task to slightly dirty over task_bdi_thresh, but
> > no way to exceed bdi_dirty and/or global dirty_thresh.
> > 
> > Tests show that it fixed the JBOD regression completely (both behavior
> > and performance), while still being able to cut down large pause times
> > in balance_dirty_pages() for single-disk cases.
> > 
> > Reported-by: Li Shaohua <shaohua.li@intel.com>
> > Tested-by: Li Shaohua <shaohua.li@intel.com>
> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > ---
> >  include/linux/writeback.h |   11 -----------
> >  mm/page-writeback.c       |   15 ++-------------
> >  2 files changed, 2 insertions(+), 24 deletions(-)
> > 
> > --- linux.orig/mm/page-writeback.c	2011-08-18 09:52:59.000000000 +0800
> > +++ linux/mm/page-writeback.c	2011-08-18 10:28:57.000000000 +0800
> > @@ -786,21 +786,10 @@ static void balance_dirty_pages(struct a
> >  		 * 200ms is typically more than enough to curb heavy dirtiers;
> >  		 * (b) the pause time limit makes the dirtiers more responsive.
> >  		 */
> > -		if (nr_dirty < dirty_thresh +
> > -			       dirty_thresh / DIRTY_MAXPAUSE_AREA &&
> > +		if (nr_dirty < dirty_thresh &&
> > +		    bdi_dirty < (task_bdi_thresh + bdi_thresh) / 2 &&
> >  		    time_after(jiffies, start_time + MAX_PAUSE))
> >  			break;
>   This looks definitely much safer than the original patch since we now
> always observe global dirty limit.

Yeah.

> I just wonder: We have throttled the
> task because bdi_nr_reclaimable > task_bdi_thresh.

Not necessarily. It's possible (bdi_nr_reclaimable < task_bdi_thresh)
for the whole loop. And the 200ms pause that trigger the above test
may totally come from the io_schedule_timeout() calls.

> Now in practice there
> should be some pages under writeback and this task should have submitted
> even more just a while ago. So the condition
>   bdi_dirty < (task_bdi_thresh + bdi_thresh) / 2

I guess the writeback_inodes_wb() call is irrelevant for the above
test, because writeback_inodes_wb() transfers reclaimable pages to
writeback pages, with the total bdi_dirty value staying the same.
Not to mention the fact that both the bdi_dirty and bdi_nr_reclaimable
variables have not been updated between writeback_inodes_wb() and the
max-pause test.

> looks still relatively weak. Shouldn't there be
>   bdi_nr_reclaimable < (task_bdi_thresh + bdi_thresh) / 2?

That's much easier condition to satisfy..

> Since bdi_nr_reclaimable is really the number we want to limit...
> Alternatively, I could see also a reason for
>   bdi_dirty < task_bdi_thresh
> which leaves the task pages under writeback as the pausing area. But since
> these are not really well limited, I'd prefer my first suggestion.

Thanks,
Fengguang

> > -		/*
> > -		 * pass-good area. When some bdi gets blocked (eg. NFS server
> > -		 * not responding), or write bandwidth dropped dramatically due
> > -		 * to concurrent reads, or dirty threshold suddenly dropped and
> > -		 * the dirty pages cannot be brought down anytime soon (eg. on
> > -		 * slow USB stick), at least let go of the good bdi's.
> > -		 */
> > -		if (nr_dirty < dirty_thresh +
> > -			       dirty_thresh / DIRTY_PASSGOOD_AREA &&
> > -		    bdi_dirty < bdi_thresh)
> > -			break;
> >  
> >  		/*
> >  		 * Increase the delay for each loop, up to our previous
> > --- linux.orig/include/linux/writeback.h	2011-08-16 23:34:27.000000000 +0800
> > +++ linux/include/linux/writeback.h	2011-08-18 09:53:03.000000000 +0800
> > @@ -12,15 +12,6 @@
> >   *
> >   *	(thresh - thresh/DIRTY_FULL_SCOPE, thresh)
> >   *
> > - * The 1/16 region above the global dirty limit will be put to maximum pauses:
> > - *
> > - *	(limit, limit + limit/DIRTY_MAXPAUSE_AREA)
> > - *
> > - * The 1/16 region above the max-pause region, dirty exceeded bdi's will be put
> > - * to loops:
> > - *
> > - *	(limit + limit/DIRTY_MAXPAUSE_AREA, limit + limit/DIRTY_PASSGOOD_AREA)
> > - *
> >   * Further beyond, all dirtier tasks will enter a loop waiting (possibly long
> >   * time) for the dirty pages to drop, unless written enough pages.
> >   *
> > @@ -31,8 +22,6 @@
> >   */
> >  #define DIRTY_SCOPE		8
> >  #define DIRTY_FULL_SCOPE	(DIRTY_SCOPE / 2)
> > -#define DIRTY_MAXPAUSE_AREA		16
> > -#define DIRTY_PASSGOOD_AREA		8
> >  
> >  /*
> >   * 4MB minimal write chunk size
> -- 
> Jan Kara <jack@suse.cz>
> SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
