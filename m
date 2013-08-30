Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 7B58E6B003B
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 09:18:49 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 30 Aug 2013 07:18:48 -0600
Received: from b01cxnp23032.gho.pok.ibm.com (b01cxnp23032.gho.pok.ibm.com [9.57.198.27])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 7B2F5C90048
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 09:18:45 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp23032.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7UDIjLk18546796
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 13:18:45 GMT
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7UDIiZB006916
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 09:18:45 -0400
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 03/35] mm: Introduce memory regions data-structure to
 capture region boundaries within nodes
Date: Fri, 30 Aug 2013 18:44:49 +0530
Message-ID: <20130830131446.4947.13150.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com>
References: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, dave@sr71.net, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
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
index af4a3b7..4246620 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -35,6 +35,8 @@
  */
 #define PAGE_ALLOC_COSTLY_ORDER 3
 
+#define MAX_NR_NODE_REGIONS	256
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
