Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 21CFF6B0253
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 02:59:21 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 83so106295560pfx.1
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 23:59:21 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j63si2121148pfg.51.2016.11.16.23.59.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Nov 2016 23:59:20 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAH7xDKD010918
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 02:59:19 -0500
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26s8jbr5s6-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 02:59:19 -0500
Received: from localhost
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 17 Nov 2016 17:59:16 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id C12492BB0057
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 18:59:12 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAH7xCZO62324792
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 18:59:12 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAH7xCfj024872
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 18:59:12 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [DRAFT 1/2] mm/cpuset: Exclude CDM nodes from each task's mems_allowed node mask
Date: Thu, 17 Nov 2016 13:29:08 +0530
In-Reply-To: <582D5F02.6010705@linux.vnet.ibm.com>
References: <582D5F02.6010705@linux.vnet.ibm.com>
Message-Id: <1479369549-13309-1-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com

task->mems_allowed decides the final node mask of nodes from which memory
can be allocated irrespective of process or VMA based memory policy. CDM
nodes should not be used for any user space memory allocation, hence they
should not be part of any mems_allowed mask in user space to begin with.
This adds a function system_ram() which computes system RAM only nodes
and excludes all the CDM nodes on the platform. This resultant system RAM
nodemask is used instead of N_MEMORY mask during cpuset and mems_allowed
initialization. This achieves isolation of the coherent device memory
from userspace allocations.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
This completely isolates CDM nodes from user space allocations. Hence
explicit allocation to the CDM nodes would not be possible any more.
To again enable explicit allocation capability from user space, cpuset
needs to be changed to accommodate CDM nodes into task's mems_allowed.

 include/linux/mm.h |  9 +++++++++
 kernel/cpuset.c    | 12 +++++++-----
 2 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index a92c8d7..f338492 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -446,6 +446,15 @@ static inline int put_page_testzero(struct page *page)
 	return page_ref_dec_and_test(page);
 }
 
+static inline nodemask_t system_ram(void)
+{
+	nodemask_t ram_nodes;
+
+	nodes_clear(ram_nodes);
+	nodes_andnot(ram_nodes, node_states[N_MEMORY], node_states[N_COHERENT_DEVICE]);
+	return ram_nodes;
+}
+
 /*
  * Try to grab a ref unless the page has a refcount of zero, return false if
  * that is the case.
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 29f815d..78c6fa3 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -364,9 +364,11 @@ static void guarantee_online_cpus(struct cpuset *cs, struct cpumask *pmask)
  */
 static void guarantee_online_mems(struct cpuset *cs, nodemask_t *pmask)
 {
-	while (!nodes_intersects(cs->effective_mems, node_states[N_MEMORY]))
+	nodemask_t nodes = system_ram();
+
+	while (!nodes_intersects(cs->effective_mems, nodes))
 		cs = parent_cs(cs);
-	nodes_and(*pmask, cs->effective_mems, node_states[N_MEMORY]);
+	nodes_and(*pmask, cs->effective_mems, nodes);
 }
 
 /*
@@ -2301,7 +2303,7 @@ static void cpuset_hotplug_workfn(struct work_struct *work)
 
 	/* fetch the available cpus/mems and find out which changed how */
 	cpumask_copy(&new_cpus, cpu_active_mask);
-	new_mems = node_states[N_MEMORY];
+	new_mems = system_ram();
 
 	cpus_updated = !cpumask_equal(top_cpuset.effective_cpus, &new_cpus);
 	mems_updated = !nodes_equal(top_cpuset.effective_mems, new_mems);
@@ -2393,11 +2395,11 @@ static int cpuset_track_online_nodes(struct notifier_block *self,
 void __init cpuset_init_smp(void)
 {
 	cpumask_copy(top_cpuset.cpus_allowed, cpu_active_mask);
-	top_cpuset.mems_allowed = node_states[N_MEMORY];
+	top_cpuset.mems_allowed = system_ram();
 	top_cpuset.old_mems_allowed = top_cpuset.mems_allowed;
 
 	cpumask_copy(top_cpuset.effective_cpus, cpu_active_mask);
-	top_cpuset.effective_mems = node_states[N_MEMORY];
+	top_cpuset.effective_mems = system_ram();
 
 	register_hotmemory_notifier(&cpuset_track_online_nodes_nb);
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
