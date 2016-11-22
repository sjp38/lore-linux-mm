Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A888C6B0267
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 09:20:03 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id y71so30653226pgd.0
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 06:20:03 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f90si28672379pfj.5.2016.11.22.06.20.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Nov 2016 06:20:02 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAMEItf5144961
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 09:20:02 -0500
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com [202.81.31.142])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26vpp6p025-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 09:20:02 -0500
Received: from localhost
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 23 Nov 2016 00:20:00 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id ADB693578052
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 01:19:57 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAMEJv017733562
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 01:19:57 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAMEJvhJ015590
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 01:19:57 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [RFC 2/4] mm/cpuset: Exclude coherent device memory nodes from mems_allowed
Date: Tue, 22 Nov 2016 19:49:38 +0530
In-Reply-To: <1479824388-30446-1-git-send-email-khandual@linux.vnet.ibm.com>
References: <1479824388-30446-1-git-send-email-khandual@linux.vnet.ibm.com>
Message-Id: <1479824388-30446-3-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com

Task's mems_allowed decides the final node mask of nodes from which memory
can be allocated irrespective of the process or VMA based memory policy.
Coherent device memory nodes should not be used for any user space memory
allocation, hence they should not be part of any mems_allowed mask in user
space to begin with. This adds a new function system_ram() which computes
system RAM only node mask and excludes all the coherent memory nodes on the
platform. This resultant system RAM node mask is used instead of N_MEMORY
node mask during cpuset update and mems_allowed initialization. It achieves
isolation of the coherent device memory node from userspace allocations.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 include/linux/mm.h   |  1 +
 include/linux/node.h | 12 ++++++++++++
 kernel/cpuset.c      | 12 +++++++-----
 3 files changed, 20 insertions(+), 5 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index a92c8d7..c40b454 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -446,6 +446,7 @@ static inline int put_page_testzero(struct page *page)
 	return page_ref_dec_and_test(page);
 }
 
+
 /*
  * Try to grab a ref unless the page has a refcount of zero, return false if
  * that is the case.
diff --git a/include/linux/node.h b/include/linux/node.h
index fc319de..99978f9 100644
--- a/include/linux/node.h
+++ b/include/linux/node.h
@@ -87,4 +87,16 @@ static inline void register_hugetlbfs_with_node(node_registration_func_t reg,
 static inline int arch_check_node_cdm(int nid) {return 0;}
 #endif
 
+static inline nodemask_t ram_nodemask(void)
+{
+#ifdef CONFIG_COHERENT_DEVICE
+	nodemask_t ram_nodes;
+
+	nodes_clear(ram_nodes);
+	nodes_andnot(ram_nodes, node_states[N_MEMORY], node_states[N_COHERENT_DEVICE]);
+	return ram_nodes;
+#else
+	return node_states[N_MEMORY];
+#endif
+}
 #endif /* _LINUX_NODE_H_ */
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 29f815d..bdbe847 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -364,9 +364,11 @@ static void guarantee_online_cpus(struct cpuset *cs, struct cpumask *pmask)
  */
 static void guarantee_online_mems(struct cpuset *cs, nodemask_t *pmask)
 {
-	while (!nodes_intersects(cs->effective_mems, node_states[N_MEMORY]))
+	nodemask_t ram_nodes = ram_nodemask();
+
+	while (!nodes_intersects(cs->effective_mems, ram_nodes))
 		cs = parent_cs(cs);
-	nodes_and(*pmask, cs->effective_mems, node_states[N_MEMORY]);
+	nodes_and(*pmask, cs->effective_mems, ram_nodes);
 }
 
 /*
@@ -2301,7 +2303,7 @@ static void cpuset_hotplug_workfn(struct work_struct *work)
 
 	/* fetch the available cpus/mems and find out which changed how */
 	cpumask_copy(&new_cpus, cpu_active_mask);
-	new_mems = node_states[N_MEMORY];
+	new_mems = ram_nodemask();
 
 	cpus_updated = !cpumask_equal(top_cpuset.effective_cpus, &new_cpus);
 	mems_updated = !nodes_equal(top_cpuset.effective_mems, new_mems);
@@ -2393,11 +2395,11 @@ static int cpuset_track_online_nodes(struct notifier_block *self,
 void __init cpuset_init_smp(void)
 {
 	cpumask_copy(top_cpuset.cpus_allowed, cpu_active_mask);
-	top_cpuset.mems_allowed = node_states[N_MEMORY];
+	top_cpuset.mems_allowed = ram_nodemask();
 	top_cpuset.old_mems_allowed = top_cpuset.mems_allowed;
 
 	cpumask_copy(top_cpuset.effective_cpus, cpu_active_mask);
-	top_cpuset.effective_mems = node_states[N_MEMORY];
+	top_cpuset.effective_mems = ram_nodemask();
 
 	register_hotmemory_notifier(&cpuset_track_online_nodes_nb);
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
