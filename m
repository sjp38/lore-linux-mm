Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 0C77D6B0078
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 19:23:20 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so312316pbb.28
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 16:23:20 -0700 (PDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 26 Sep 2013 04:53:14 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 05FC71258051
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:53:26 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8PNNAB530343192
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:53:10 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8PNNB4h008641
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 04:53:12 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v4 23/40] mm: Fix vmstat to also account for freepages in
 the region allocator
Date: Thu, 26 Sep 2013 04:49:05 +0530
Message-ID: <20130925231903.26184.23956.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
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
index bb44d30..4dc103e 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -868,6 +868,8 @@ static void frag_show_print(struct seq_file *m, pg_data_t *pgdat,
 {
 	int i, order, t;
 	struct free_area *area;
+	struct free_area_region *reg_area;
+	struct region_allocator *reg_alloc;
 
 	seq_printf(m, "Node %d, zone %8s \n", pgdat->node_id, zone->name);
 
@@ -884,6 +886,12 @@ static void frag_show_print(struct seq_file *m, pg_data_t *pgdat,
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
