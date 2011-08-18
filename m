Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2DFCD900138
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 03:25:25 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 3E7D23EE0B5
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 16:25:21 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2682445DEB3
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 16:25:21 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D87145DE7E
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 16:25:21 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 005851DB8037
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 16:25:21 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B18611DB803C
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 16:25:20 +0900 (JST)
Date: Thu, 18 Aug 2011 16:17:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v9 11/13] writeback: make background writeback cgroup
 aware
Message-Id: <20110818161751.9be5f1f9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <xr93r54jtcsf.fsf@gthelen.mtv.corp.google.com>
References: <1313597705-6093-1-git-send-email-gthelen@google.com>
	<1313597705-6093-12-git-send-email-gthelen@google.com>
	<20110818102344.110829ce.kamezawa.hiroyu@jp.fujitsu.com>
	<xr93r54jtcsf.fsf@gthelen.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <andrea@betterlinux.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>

On Thu, 18 Aug 2011 00:10:56 -0700
Greg Thelen <gthelen@google.com> wrote:

> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:
> 
> > On Wed, 17 Aug 2011 09:15:03 -0700
> > Greg Thelen <gthelen@google.com> wrote:
> >
> >> When the system is under background dirty memory threshold but some
> >> cgroups are over their background dirty memory thresholds, then only
> >> writeback inodes associated with the over-limit cgroups.
> >> 
> >> In addition to checking if the system dirty memory usage is over the
> >> system background threshold, over_bground_thresh() now checks if any
> >> cgroups are over their respective background dirty memory thresholds.
> >> 
> >> If over-limit cgroups are found, then the new
> >> wb_writeback_work.for_cgroup field is set to distinguish between system
> >> and memcg overages.  The new wb_writeback_work.shared_inodes field is
> >> also set.  Inodes written by multiple cgroup are marked owned by
> >> I_MEMCG_SHARED rather than a particular cgroup.  Such shared inodes
> >> cannot easily be attributed to a cgroup, so per-cgroup writeback
> >> (futures version of wakeup_flusher_threads and balance_dirty_pages)
> >> performs suboptimally in the presence of shared inodes.  Therefore,
> >> write shared inodes when performing cgroup background writeback.
> >> 
> >> If performing cgroup writeback, move_expired_inodes() skips inodes that
> >> do not contribute dirty pages to the cgroup being written back.
> >> 
> >> After writing some pages, wb_writeback() will call
> >> mem_cgroup_writeback_done() to update the set of over-bg-limits memcg.
> >> 
> >> This change also makes wakeup_flusher_threads() memcg aware so that
> >> per-cgroup try_to_free_pages() is able to operate more efficiently
> >> without having to write pages of foreign containers.  This change adds a
> >> mem_cgroup parameter to wakeup_flusher_threads() to allow callers,
> >> especially try_to_free_pages() and foreground writeback from
> >> balance_dirty_pages(), to specify a particular cgroup to write inodes
> >> from.
> >> 
> >> Signed-off-by: Greg Thelen <gthelen@google.com>
> >> ---
> >> Changelog since v8:
> >> 
> >> - Added optional memcg parameter to __bdi_start_writeback(),
> >>   bdi_start_writeback(), wakeup_flusher_threads(), writeback_inodes_wb().
> >> 
> >> - move_expired_inodes() now uses pass in struct wb_writeback_work instead of
> >>   struct writeback_control.
> >> 
> >> - Added comments to over_bground_thresh().
> >> 
> >>  fs/buffer.c               |    2 +-
> >>  fs/fs-writeback.c         |   96 +++++++++++++++++++++++++++++++++-----------
> >>  fs/sync.c                 |    2 +-
> >>  include/linux/writeback.h |    6 ++-
> >>  mm/backing-dev.c          |    3 +-
> >>  mm/page-writeback.c       |    3 +-
> >>  mm/vmscan.c               |    3 +-
> >>  7 files changed, 84 insertions(+), 31 deletions(-)
> >> 
> >> diff --git a/fs/buffer.c b/fs/buffer.c
> >> index dd0220b..da1fb23 100644
> >> --- a/fs/buffer.c
> >> +++ b/fs/buffer.c
> >> @@ -293,7 +293,7 @@ static void free_more_memory(void)
> >>  	struct zone *zone;
> >>  	int nid;
> >>  
> >> -	wakeup_flusher_threads(1024);
> >> +	wakeup_flusher_threads(1024, NULL);
> >>  	yield();
> >>  
> >>  	for_each_online_node(nid) {
> >> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> >> index e91fb82..ba55336 100644
> >> --- a/fs/fs-writeback.c
> >> +++ b/fs/fs-writeback.c
> >> @@ -38,10 +38,14 @@ struct wb_writeback_work {
> >>  	struct super_block *sb;
> >>  	unsigned long *older_than_this;
> >>  	enum writeback_sync_modes sync_mode;
> >> +	unsigned short memcg_id;	/* If non-zero, then writeback specified
> >> +					 * cgroup. */
> >>  	unsigned int tagged_writepages:1;
> >>  	unsigned int for_kupdate:1;
> >>  	unsigned int range_cyclic:1;
> >>  	unsigned int for_background:1;
> >> +	unsigned int for_cgroup:1;	/* cgroup writeback */
> >> +	unsigned int shared_inodes:1;	/* write inodes spanning cgroups */
> >>  
> >>  	struct list_head list;		/* pending work list */
> >>  	struct completion *done;	/* set if the caller waits */
> >> @@ -114,9 +118,12 @@ static void bdi_queue_work(struct backing_dev_info *bdi,
> >>  	spin_unlock_bh(&bdi->wb_lock);
> >>  }
> >>  
> >> +/*
> >> + * @memcg is optional.  If set, then limit writeback to the specified cgroup.
> >> + */
> >>  static void
> >>  __bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages,
> >> -		      bool range_cyclic)
> >> +		      bool range_cyclic, struct mem_cgroup *memcg)
> >>  {
> >>  	struct wb_writeback_work *work;
> >>  
> >> @@ -136,6 +143,8 @@ __bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages,
> >>  	work->sync_mode	= WB_SYNC_NONE;
> >>  	work->nr_pages	= nr_pages;
> >>  	work->range_cyclic = range_cyclic;
> >> +	work->memcg_id = memcg ? css_id(mem_cgroup_css(memcg)) : 0;
> >> +	work->for_cgroup = memcg != NULL;
> >>  
> >
> >
> > I couldn't find a patch for mem_cgroup_css(NULL). Is it in patch 1-10 ?
> > Other parts seems ok to me.
> >
> >
> > Thanks,
> > -Kame
> 
> Mainline commit d324236b3333e87c8825b35f2104184734020d35 adds
> mem_cgroup_css() to memcontrol.c.  The above code does not call
> mem_cgroup_css() with a NULL parameter due to the 'memcg ? ...' check.
> So I do not think any additional changes to mem_cgroup_css() are needed.
> Am I missing your point?
> 

I thought you need
==
struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *mem)
{
+	if (!mem)
+		return NULL;
       return &mem->css;
}
==
And
==
unsigned short css_id(struct cgroup_subsys_state *css)
{
        struct css_id *cssid;

+	if (!css)
		return 0;
}
==



Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
