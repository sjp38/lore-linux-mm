Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 226406B0038
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 08:42:15 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id c85so15013969wmi.6
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 05:42:15 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id iz4si825567wjb.132.2017.01.09.05.42.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Jan 2017 05:42:13 -0800 (PST)
Date: Mon, 9 Jan 2017 14:42:10 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/8] mm: introduce memalloc_nofs_{save,restore} API
Message-ID: <20170109134210.GI7495@dhcp22.suse.cz>
References: <20170106141107.23953-1-mhocko@kernel.org>
 <20170106141107.23953-4-mhocko@kernel.org>
 <86dbce74-a532-2f98-6a63-4dbad77b2aa1@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <86dbce74-a532-2f98-6a63-4dbad77b2aa1@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, djwong@kernel.org, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>

On Mon 09-01-17 14:04:21, Vlastimil Babka wrote:
[...]
> > +static inline unsigned int memalloc_nofs_save(void)
> > +{
> > +	unsigned int flags = current->flags & PF_MEMALLOC_NOFS;
> > +	current->flags |= PF_MEMALLOC_NOFS;
> 
> So this is not new, as same goes for memalloc_noio_save, but I've
> noticed that e.g. exit_signal() does tsk->flags |= PF_EXITING;
> So is it possible that there's a r-m-w hazard here?

exit_signals operates on current and all task_struct::flags should be
used only on the current.
[...]

> > @@ -3029,7 +3029,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
> >  	int nid;
> >  	struct scan_control sc = {
> >  		.nr_to_reclaim = max(nr_pages, SWAP_CLUSTER_MAX),
> > -		.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
> > +		.gfp_mask = (current_gfp_context(gfp_mask) & GFP_RECLAIM_MASK) |
> 
> So this function didn't do memalloc_noio_flags() before? Is it a bug
> that should be fixed separately or at least mentioned? Because that
> looks like a functional change...

We didn't need it. Kmem charges are opt-in and current all of them
support GFP_IO. The LRU pages are not charged in NOIO context either.
We need it now because there will be callers to charge GFP_KERNEL while
being inside the NOFS scope.

Now that you have opened this I have noticed that the code is wrong
here because GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK would overwrite
the removed GFP_FS. I guess it would be better and less error prone
to move the current_gfp_context part into the direct reclaim entry -
do_try_to_free_pages - and put the comment like this
---
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 4ea6b610f20e..df7975185f11 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2756,6 +2756,13 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 	int initial_priority = sc->priority;
 	unsigned long total_scanned = 0;
 	unsigned long writeback_threshold;
+
+	/*
+	 * Make sure that the gfp context properly handles scope gfp mask.
+	 * This might weaken the reclaim context (e.g. make it GFP_NOFS or
+	 * GFP_NOIO).
+	 */
+	sc->gfp_mask = current_gfp_context(sc->gfp_mask);
 retry:
 	delayacct_freepages_start();
 
@@ -2949,7 +2956,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 	unsigned long nr_reclaimed;
 	struct scan_control sc = {
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
-		.gfp_mask = (gfp_mask = current_gfp_context(gfp_mask)),
+		.gfp_mask = gfp_mask,
 		.reclaim_idx = gfp_zone(gfp_mask),
 		.order = order,
 		.nodemask = nodemask,
@@ -3029,8 +3036,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 	int nid;
 	struct scan_control sc = {
 		.nr_to_reclaim = max(nr_pages, SWAP_CLUSTER_MAX),
-		.gfp_mask = (current_gfp_context(gfp_mask) & GFP_RECLAIM_MASK) |
-				(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK),
+		.gfp_mask = GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK,
 		.reclaim_idx = MAX_NR_ZONES - 1,
 		.target_mem_cgroup = memcg,
 		.priority = DEF_PRIORITY,
@@ -3723,7 +3729,7 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 	int classzone_idx = gfp_zone(gfp_mask);
 	struct scan_control sc = {
 		.nr_to_reclaim = max(nr_pages, SWAP_CLUSTER_MAX),
-		.gfp_mask = (gfp_mask = current_gfp_context(gfp_mask)),
+		.gfp_mask = gfp_mask,
 		.order = order,
 		.priority = NODE_RECLAIM_PRIORITY,
 		.may_writepage = !!(node_reclaim_mode & RECLAIM_WRITE),
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
