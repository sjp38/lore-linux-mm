Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 68A5D6B0089
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 09:25:56 -0400 (EDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 30 Aug 2013 07:25:55 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 830F019D8043
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 07:25:53 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7UDPrlY125480
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 07:25:53 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7UDSjPs019038
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 07:28:46 -0600
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 25/35] mm: Fix vmstat to also account for freepages in
 the region allocator
Date: Fri, 30 Aug 2013 18:51:50 +0530
Message-ID: <20130830132143.4947.71496.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com>
References: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, dave@sr71.net, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Currently vmstat considers only the freepages present in the buddy freelists
of the page allocator. But with the newly introduced region allocator in
place, freepages could be present in the region allocator as well. So teach
vmstat to take them into consideration when reporting free memory.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 mm/vmstat.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 924babc..8cb7a10 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -829,6 +829,8 @@ static void frag_show_print(struct seq_file *m, pg_data_t *pgdat,
 {
 	int i, order, t;
 	struct free_area *area;
+	struct free_area_region *reg_area;
+	struct region_allocator *reg_alloc;
 
 	seq_printf(m, "Node %d, zone %8s \n", pgdat->node_id, zone->name);
 
@@ -845,6 +847,12 @@ static void frag_show_print(struct seq_file *m, pg_data_t *pgdat,
 				nr_free +=
 					area->free_list[t].mr_list[i].nr_free;
 			}
+
+			/* Add up freepages in the region allocator as well */
+			reg_alloc = &zone->region_allocator;
+			reg_area = &reg_alloc->region[i].region_area[order];
+			nr_free += reg_area->nr_free;
+
 			seq_printf(m, "%6lu ", nr_free);
 		}
 		seq_putc(m, '\n');

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
