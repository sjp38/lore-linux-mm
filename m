Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id F34A16B00A3
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 19:26:45 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id uo5so308930pbc.23
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 16:26:45 -0700 (PDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 26 Sep 2013 09:26:41 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id C69392CE8040
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:26:37 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8PNQQFf9896340
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:26:26 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8PNQagm026581
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:26:37 +1000
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v4 38/40] mm: Add a mechanism to queue work to the
 kmempowerd kthread
Date: Thu, 26 Sep 2013 04:52:26 +0530
Message-ID: <20130925232224.26184.9597.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Now that we have a dedicated kthread in place to perform targeted region
evacuation, add and export a mechanism to queue work to the kthread.

Adding work to kmempowerd is very simple: just set the bits corresponding
to the region numbers that we want to evacuate, and queue the work item
to the kthread.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 mm/compaction.c |   26 ++++++++++++++++++++++++++
 mm/internal.h   |    3 +++
 2 files changed, 29 insertions(+)

diff --git a/mm/compaction.c b/mm/compaction.c
index 0511eae..b56be89 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1271,6 +1271,32 @@ int evacuate_mem_region(struct zone *z, struct zone_mem_region *zmr)
 #define nr_zone_region_bits	MAX_NR_ZONE_REGIONS
 static DECLARE_BITMAP(mpwork_mask, nr_zone_region_bits);
 
+void queue_mempower_work(struct pglist_data *pgdat, struct zone *zone,
+			 int region_id)
+{
+	struct mempower_work *mpwork;
+	unsigned long flags;
+
+	mpwork = &zone->mempower_work;
+	spin_lock_irqsave(&mpwork->lock, flags);
+	set_bit(region_id, mpwork->mempower_mask);
+	spin_unlock_irqrestore(&mpwork->lock, flags);
+
+	/*
+	 * The kmempowerd kthread will never miss the work we assign it,
+	 * due to the way queue_kthread_work() and kthread_worker_fn()
+	 * synchronize with each other. If the work is currently executing,
+	 * it gets requeued; but if it is pending, the kthread will naturally
+	 * process it in the future. Eitherway, it will notice and process
+	 * all the work submitted to it, and won't prematurely go to sleep.
+	 *
+	 * Note: The bits set in the mempower_mask represent the actual
+	 * "work" for the kthread. The work-struct is just a container used
+	 * to communicate that work to the kthread.
+	 */
+	queue_kthread_work(&pgdat->mempower_worker, &mpwork->work);
+}
+
 static void kmempowerd(struct kthread_work *work)
 {
 	struct mempower_work *mpwork;
diff --git a/mm/internal.h b/mm/internal.h
index acb50f8..3fbc9f6 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -181,6 +181,9 @@ int compact_range(struct compact_control *cc, struct aggression_control *ac,
 		  struct free_page_control *fc, unsigned long start,
 		  unsigned long end);
 
+void queue_mempower_work(struct pglist_data *pgdat, struct zone *zone,
+			 int region_id);
+
 #endif
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
