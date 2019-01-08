Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id B83258E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 14:32:18 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id d3so2590728pgv.23
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 11:32:18 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d92si1065322pld.45.2019.01.08.11.32.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 11:32:17 -0800 (PST)
From: Sasha Levin <sashal@kernel.org>
Subject: [PATCH AUTOSEL 4.19 95/97] mm/swap: use nr_node_ids for avail_lists in swap_info_struct
Date: Tue,  8 Jan 2019 14:29:44 -0500
Message-Id: <20190108192949.122407-95-sashal@kernel.org>
In-Reply-To: <20190108192949.122407-1-sashal@kernel.org>
References: <20190108192949.122407-1-sashal@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc: Aaron Lu <aaron.lu@intel.com>, Vasily Averin <vvs@virtuozzo.com>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Sasha Levin <sashal@kernel.org>, linux-mm@kvack.org

From: Aaron Lu <aaron.lu@intel.com>

[ Upstream commit 66f71da9dd38af17dc17209cdde7987d4679a699 ]

Since a2468cc9bfdf ("swap: choose swap device according to numa node"),
avail_lists field of swap_info_struct is changed to an array with
MAX_NUMNODES elements.  This made swap_info_struct size increased to 40KiB
and needs an order-4 page to hold it.

This is not optimal in that:
1 Most systems have way less than MAX_NUMNODES(1024) nodes so it
  is a waste of memory;
2 It could cause swapon failure if the swap device is swapped on
  after system has been running for a while, due to no order-4
  page is available as pointed out by Vasily Averin.

Solve the above two issues by using nr_node_ids(which is the actual
possible node number the running system has) for avail_lists instead of
MAX_NUMNODES.

nr_node_ids is unknown at compile time so can't be directly used when
declaring this array.  What I did here is to declare avail_lists as zero
element array and allocate space for it when allocating space for
swap_info_struct.  The reason why keep using array but not pointer is
plist_for_each_entry needs the field to be part of the struct, so pointer
will not work.

This patch is on top of Vasily Averin's fix commit.  I think the use of
kvzalloc for swap_info_struct is still needed in case nr_node_ids is
really big on some systems.

Link: http://lkml.kernel.org/r/20181115083847.GA11129@intel.com
Signed-off-by: Aaron Lu <aaron.lu@intel.com>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: Vasily Averin <vvs@virtuozzo.com>
Cc: Huang Ying <ying.huang@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 include/linux/swap.h | 11 ++++++++++-
 mm/swapfile.c        |  3 ++-
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 8e2c11e692ba..77221c16733a 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -232,7 +232,6 @@ struct swap_info_struct {
 	unsigned long	flags;		/* SWP_USED etc: see above */
 	signed short	prio;		/* swap priority of this type */
 	struct plist_node list;		/* entry in swap_active_head */
-	struct plist_node avail_lists[MAX_NUMNODES];/* entry in swap_avail_heads */
 	signed char	type;		/* strange name for an index */
 	unsigned int	max;		/* extent of the swap_map */
 	unsigned char *swap_map;	/* vmalloc'ed array of usage counts */
@@ -273,6 +272,16 @@ struct swap_info_struct {
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
index 8810a6d7d67f..08ba73eaaba2 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2819,8 +2819,9 @@ static struct swap_info_struct *alloc_swap_info(void)
 	struct swap_info_struct *p;
 	unsigned int type;
 	int i;
+	int size = sizeof(*p) + nr_node_ids * sizeof(struct plist_node);
 
-	p = kvzalloc(sizeof(*p), GFP_KERNEL);
+	p = kvzalloc(size, GFP_KERNEL);
 	if (!p)
 		return ERR_PTR(-ENOMEM);
 
-- 
2.19.1
