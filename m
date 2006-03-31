Received: from imr2.americas.sgi.com (imr2.americas.sgi.com [198.149.16.18])
	by omx1.americas.sgi.com (8.12.10/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k2VMk6nx023098
	for <linux-mm@kvack.org>; Fri, 31 Mar 2006 16:46:06 -0600
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by imr2.americas.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id k2VN3w7p22253033
	for <linux-mm@kvack.org>; Fri, 31 Mar 2006 15:03:58 -0800 (PST)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id k2VMk5nB30867430
	for <linux-mm@kvack.org>; Fri, 31 Mar 2006 14:46:05 -0800 (PST)
Received: from christoph (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1FPSNZ-0002DB-00
	for <linux-mm@kvack.org>; Fri, 31 Mar 2006 14:46:05 -0800
Date: Fri, 31 Mar 2006 14:44:33 -0800 (PST)
From: Christoph Lameter <christoph@engr.sgi.com>
Subject: Avoid excessive time spend on concurrent slab shrinking
Message-ID: <Pine.LNX.4.64.0603311441400.8465@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.64.0603311445560.8489@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org, nickpiggin@yahoo.com.au
Cc: linux-mm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

We experienced that concurrent slab shrinking on 2.6.16 can slow down a
system excessively due to lock contention. Slab shrinking is a global
operation so it does not make sense for multiple slab shrink operations
to be ongoing at the same time. The single shrinking task can perform the
shrinking for all nodes and processors in the system. Introduce an atomic
counter that works in the same was as in shrink_zone to limit concurrent
shrinking.

Also calculate the time it took to do the shrinking and wait at least twice
that time before doing it again. If we are spending excessive time 
on slab shrinking then we need to pause for some time to insure that the 
system is capable of archiving other tasks.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.16/mm/vmscan.c
===================================================================
--- linux-2.6.16.orig/mm/vmscan.c	2006-03-19 21:53:29.000000000 -0800
+++ linux-2.6.16/mm/vmscan.c	2006-03-31 14:38:18.000000000 -0800
@@ -130,6 +130,8 @@ static long total_memory;
 
 static LIST_HEAD(shrinker_list);
 static DECLARE_RWSEM(shrinker_rwsem);
+static atomic_t active_shrinkers;
+static unsigned long next_slab_shrink;
 
 /*
  * Add a shrinker callback to be called from the vm
@@ -187,12 +189,18 @@ int shrink_slab(unsigned long scanned, g
 {
 	struct shrinker *shrinker;
 	int ret = 0;
+	unsigned long shrinkstart;
 
 	if (scanned == 0)
 		scanned = SWAP_CLUSTER_MAX;
 
-	if (!down_read_trylock(&shrinker_rwsem))
-		return 1;	/* Assume we'll be able to shrink next time */
+	if (atomic_read(&active_shrinkers) ||
+		time_before(jiffies, next_slab_shrink) ||
+		!down_read_trylock(&shrinker_rwsem))
+			/* Assume we'll be able to shrink next time */
+			return 1;
+	atomic_inc(&active_shrinkers);
+	shrinkstart = jiffies;
 
 	list_for_each_entry(shrinker, &shrinker_list, list) {
 		unsigned long long delta;
@@ -239,6 +247,12 @@ int shrink_slab(unsigned long scanned, g
 
 		shrinker->nr += total_scan;
 	}
+	/*
+	 * If slab shrinking took a long time then lets at least wait
+	 * twice as long as it took before we do it again.
+	 */
+	next_slab_shrink = jiffies + 2 * (jiffies - shrinkstart);
+	atomic_dec(&active_shrinkers);
 	up_read(&shrinker_rwsem);
 	return ret;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
