Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 590486B0036
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 19:18:15 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id ld10so470107pab.22
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 16:18:15 -0700 (PDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 26 Sep 2013 04:47:57 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id EBA981258053
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:48:08 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8PNKGdv33095736
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:50:16 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8PNHsfF015458
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:47:55 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v4 01/40] mm: Introduce memory regions data-structure to
 capture region boundaries within nodes
Date: Thu, 26 Sep 2013 04:43:48 +0530
Message-ID: <20130925231346.26184.65521.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The memory within a node can be divided into regions of memory that can be
independently power-managed. That is, chunks of memory can be transitioned
(manually or automatically) to low-power states based on the frequency of
references to that region. For example, if a memory chunk is not referenced
for a given threshold amount of time, the hardware (memory controller) can
decide to put that piece of memory into a content-preserving low-power state.
And of course, on the next reference to that chunk of memory, it will be
transitioned back to full-power for read/write operations.

So, the Linux MM can take advantage of this feature by managing the available
memory with an eye towards power-savings - ie., by keeping the memory
allocations/references consolidated to a minimum no. of such power-manageable
memory regions. In order to do so, the first step is to teach the MM about
the boundaries of these regions - and to capture that info, we introduce a new
data-structure called "Memory Regions".

[Also, the concept of memory regions could potentially be extended to work
with different classes of memory like PCM (Phase Change Memory) etc and
hence, it is not limited to just power management alone].

We already sub-divide a node's memory into zones, based on some well-known
constraints. So the question is, where do we fit in memory regions in this
hierarchy. Instead of artificially trying to fit it into the hierarchy one
way or the other, we choose to simply capture the region boundaries in a
parallel data-structure, since most likely the region boundaries won't
naturally fit inside the zone boundaries or vice-versa.

But of course, memory regions are sub-divisions *within* a node, so it makes
sense to keep the data-structures in the node's struct pglist_data. (Thus
this placement makes memory regions parallel to zones in that node).

Once we capture the region boundaries in the memory regions data-structure,
we can influence MM decisions at various places, such as page allocation,
reclamation etc, in order to perform power-aware memory management.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 include/linux/mmzone.h |   12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index bd791e4..d3288b0 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -35,6 +35,8 @@
  */
 #define PAGE_ALLOC_COSTLY_ORDER 3
 
+#define MAX_NR_NODE_REGIONS	512
+
 enum {
 	MIGRATE_UNMOVABLE,
 	MIGRATE_RECLAIMABLE,
@@ -708,6 +710,14 @@ struct node_active_region {
 extern struct page *mem_map;
 #endif
 
+struct node_mem_region {
+	unsigned long start_pfn;
+	unsigned long end_pfn;
+	unsigned long present_pages;
+	unsigned long spanned_pages;
+	struct pglist_data *pgdat;
+};
+
 /*
  * The pg_data_t structure is used in machines with CONFIG_DISCONTIGMEM
  * (mostly NUMA machines?) to denote a higher-level memory zone than the
@@ -724,6 +734,8 @@ typedef struct pglist_data {
 	struct zone node_zones[MAX_NR_ZONES];
 	struct zonelist node_zonelists[MAX_ZONELISTS];
 	int nr_zones;
+	struct node_mem_region node_regions[MAX_NR_NODE_REGIONS];
+	int nr_node_regions;
 #ifdef CONFIG_FLAT_NODE_MEM_MAP	/* means !SPARSEMEM */
 	struct page *node_mem_map;
 #ifdef CONFIG_MEMCG

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
