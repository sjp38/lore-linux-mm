Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 938476B004D
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 19:34:26 -0400 (EDT)
Subject: [PATCH] Cgroup: Fix memory accounting scalability in
 shrink_page_list
From: Tim Chen <tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 19 Jul 2012 16:34:26 -0700
Message-ID: <1342740866.13492.50.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "andi.kleen" <andi.kleen@intel.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

Hi,

I noticed in a multi-process parallel files reading benchmark I ran on a
8 socket machine,  throughput slowed down by a factor of 8 when I ran
the benchmark within a cgroup container.  I traced the problem to the
following code path (see below) when we are trying to reclaim memory
from file cache.  The res_counter_uncharge function is called on every
page that's reclaimed and created heavy lock contention.  The patch
below allows the reclaimed pages to be uncharged from the resource
counter in batch and recovered the regression. 

Tim

     40.67%           usemem  [kernel.kallsyms]                   [k] _raw_spin_lock
                      |
                      --- _raw_spin_lock
                         |
                         |--92.61%-- res_counter_uncharge
                         |          |
                         |          |--100.00%-- __mem_cgroup_uncharge_common
                         |          |          |
                         |          |          |--100.00%-- mem_cgroup_uncharge_cache_page
                         |          |          |          __remove_mapping
                         |          |          |          shrink_page_list
                         |          |          |          shrink_inactive_list
                         |          |          |          shrink_mem_cgroup_zone
                         |          |          |          shrink_zone
                         |          |          |          do_try_to_free_pages
                         |          |          |          try_to_free_pages
                         |          |          |          __alloc_pages_nodemask
                         |          |          |          alloc_pages_current


---
Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 33dc256..aac5672 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -779,6 +779,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
 	cond_resched();
 
+	mem_cgroup_uncharge_start();
 	while (!list_empty(page_list)) {
 		enum page_references references;
 		struct address_space *mapping;
@@ -1026,6 +1027,7 @@ keep_lumpy:
 
 	list_splice(&ret_pages, page_list);
 	count_vm_events(PGACTIVATE, pgactivate);
+	mem_cgroup_uncharge_end();
 	*ret_nr_dirty += nr_dirty;
 	*ret_nr_writeback += nr_writeback;
 	return nr_reclaimed;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
