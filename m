Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5A36E6B026E
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:38:02 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id v77so65366679wmv.5
        for <linux-mm@kvack.org>; Sun, 29 Jan 2017 19:38:02 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id w130si11716521wmf.21.2017.01.29.19.38.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Jan 2017 19:38:01 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0U3YPbX082453
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:38:00 -0500
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
	by mx0a-001b2d01.pphosted.com with ESMTP id 289he1j3mb-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:37:59 -0500
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 30 Jan 2017 13:37:56 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id A60C32CE8054
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:37:55 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0U3bljH28508266
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:37:55 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0U3bNc6020367
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:37:23 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [RFC V2 06/12] mm: Exclude CDM nodes from task->mems_allowed and root cpuset
Date: Mon, 30 Jan 2017 09:05:47 +0530
In-Reply-To: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
Message-Id: <20170130033602.12275-7-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

Task struct's mems_allowed element decides the final nodemask from which
memory can be allocated in the task context irrespective any applicable
memory policy. CDM nodes should not be used for user allocations, its one
of the overall requirements of it's isolation. So they should not be part
of any task's mems_allowed nodemask. System RAM nodemask is used instead
of node_states[N_MEMORY] nodemask during mems_allowed initialization and
it's update during memory hotlugs.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 kernel/cpuset.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index be75f3f..4e1df26 100644
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
@@ -2303,7 +2305,7 @@ static void cpuset_hotplug_workfn(struct work_struct *work)
 
 	/* fetch the available cpus/mems and find out which changed how */
 	cpumask_copy(&new_cpus, cpu_active_mask);
-	new_mems = node_states[N_MEMORY];
+	new_mems = ram_nodemask();
 
 	cpus_updated = !cpumask_equal(top_cpuset.effective_cpus, &new_cpus);
 	mems_updated = !nodes_equal(top_cpuset.effective_mems, new_mems);
@@ -2395,11 +2397,11 @@ static struct notifier_block cpuset_track_online_nodes_nb = {
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
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
