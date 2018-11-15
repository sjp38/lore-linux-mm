Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4712D6B000D
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 03:38:55 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id y2so6396214plr.8
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 00:38:55 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id n15-v6si26885651pgc.143.2018.11.15.00.38.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 00:38:54 -0800 (PST)
Date: Thu, 15 Nov 2018 16:38:47 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: [PATCH] mm/swap: use nr_node_ids for avail_lists in swap_info_struct
Message-ID: <20181115083847.GA11129@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
Cc: Vasily Averin <vvs@virtuozzo.com>, Michal Hocko <mhocko@suse.com>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>

Since commit a2468cc9bfdf ("swap: choose swap device according to
numa node"), avail_lists field of swap_info_struct is changed to
an array with MAX_NUMNODES elements. This made swap_info_struct
size increased to 40KiB and needs an order-4 page to hold it.

This is not optimal in that:
1 Most systems have way less than MAX_NUMNODES(1024) nodes so it
  is a waste of memory;
2 It could cause swapon failure if the swap device is swapped on
  after system has been running for a while, due to no order-4
  page is available as pointed out by Vasily Averin.

Solve the above two issues by using nr_node_ids(which is the actual
possible node number the running system has) for avail_lists instead
of MAX_NUMNODES.

nr_node_ids is unknown at compile time so can't be directly used
when declaring this array. What I did here is to declare avail_lists
as zero element array and allocate space for it when allocating
space for swap_info_struct. The reason why keep using array but
not pointer is plist_for_each_entry needs the field to be part
of the struct, so pointer will not work.

This patch is on top of Vasily Averin's fix commit. I think the
use of kvzalloc for swap_info_struct is still needed in case
nr_node_ids is really big on some systems.

Cc: Vasily Averin <vvs@virtuozzo.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Huang Ying <ying.huang@intel.com>
Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
 include/linux/swap.h | 11 ++++++++++-
 mm/swapfile.c        |  3 ++-
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index d8a07a4f171d..3d3630b3f63d 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -233,7 +233,6 @@ struct swap_info_struct {
 	unsigned long	flags;		/* SWP_USED etc: see above */
 	signed short	prio;		/* swap priority of this type */
 	struct plist_node list;		/* entry in swap_active_head */
-	struct plist_node avail_lists[MAX_NUMNODES];/* entry in swap_avail_heads */
 	signed char	type;		/* strange name for an index */
 	unsigned int	max;		/* extent of the swap_map */
 	unsigned char *swap_map;	/* vmalloc'ed array of usage counts */
@@ -274,6 +273,16 @@ struct swap_info_struct {
 					 */
 	struct work_struct discard_work; /* discard worker */
 	struct swap_cluster_list discard_clusters; /* discard clusters list */
+	struct plist_node avail_lists[0]; /*
+					   * entries in swap_avail_heads, one
+					   * entry per node.
+					   * Must be last as the number of the
+					   * array is nr_node_ids, which is not
+					   * a fixed value so have to allocate
+					   * dynamically.
+					   * And it has to be an array so that
+					   * plist_for_each_* can work.
+					   */
 };
 
 #ifdef CONFIG_64BIT
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 8688ae65ef58..6e06821623f6 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2812,8 +2812,9 @@ static struct swap_info_struct *alloc_swap_info(void)
 	struct swap_info_struct *p;
 	unsigned int type;
 	int i;
+	int size = sizeof(*p) + nr_node_ids * sizeof(struct plist_node);
 
-	p = kvzalloc(sizeof(*p), GFP_KERNEL);
+	p = kvzalloc(size, GFP_KERNEL);
 	if (!p)
 		return ERR_PTR(-ENOMEM);
 
-- 
2.17.2
