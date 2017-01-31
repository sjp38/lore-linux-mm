Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E9C356B0069
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 09:22:53 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id c73so514279678pfb.7
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 06:22:53 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id q9si10681937plk.87.2017.01.31.06.22.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jan 2017 06:22:52 -0800 (PST)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0VEIxk8114695
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 09:22:52 -0500
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com [125.16.236.9])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28asa0fxfk-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 09:22:51 -0500
Received: from localhost
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 31 Jan 2017 19:52:48 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id B63373940064
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 19:52:46 +0530 (IST)
Received: from d28av06.in.ibm.com (d28av06.in.ibm.com [9.184.220.48])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0VEMklS8847426
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 19:52:46 +0530
Received: from d28av06.in.ibm.com (localhost [127.0.0.1])
	by d28av06.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0VEMjDo011756
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 19:52:46 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [RFC] cpuset: Enable changing of top_cpuset's mems_allowed nodemask
Date: Tue, 31 Jan 2017 19:52:37 +0530
In-Reply-To: <20170130203003.dm2ydoi3e6cbbwcj@suse.de>
References: <20170130203003.dm2ydoi3e6cbbwcj@suse.de>
Message-Id: <20170131142237.27097-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

At present, top_cpuset.mems_allowed is same as node_states[N_MEMORY] and it
cannot be changed at the runtime. Maximum possible node_states[N_MEMORY]
also gets reflected in top_cpuset.effective_mems interface. It prevents some
one from removing or restricting memory placement which will be applicable
system wide on a given memory node through cpuset mechanism which might be
limiting. This solves the problem by enabling update_nodemask() function to
accept changes to top_cpuset.mems_allowed as well. Once changed, it also
updates the value of top_cpuset.effective_mems. Updates all it's task's
mems_allowed nodemask as well. It calls cpuset_inc() to make sure cpuset
is accounted for in the buddy allocator through cpusets_enabled() check.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
Tested for

* Enforcement of changed top_cpuset.mems_allowed
* Global mems_allowed cannot be changed till there are other
  cpusets present underneath the top root cpuset. I guess it
  is expected.

 kernel/cpuset.c | 21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index b308888..e8c105a 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1210,15 +1210,6 @@ static int update_nodemask(struct cpuset *cs, struct cpuset *trialcs,
 	int retval;
 
 	/*
-	 * top_cpuset.mems_allowed tracks node_stats[N_MEMORY];
-	 * it's read-only
-	 */
-	if (cs == &top_cpuset) {
-		retval = -EACCES;
-		goto done;
-	}
-
-	/*
 	 * An empty mems_allowed is ok iff there are no tasks in the cpuset.
 	 * Since nodelist_parse() fails on an empty mask, we special case
 	 * that parsing.  The validate_change() call ensures that cpusets
@@ -1232,7 +1223,7 @@ static int update_nodemask(struct cpuset *cs, struct cpuset *trialcs,
 			goto done;
 
 		if (!nodes_subset(trialcs->mems_allowed,
-				  top_cpuset.mems_allowed)) {
+				  node_states[N_MEMORY])) {
 			retval = -EINVAL;
 			goto done;
 		}
@@ -1250,6 +1241,16 @@ static int update_nodemask(struct cpuset *cs, struct cpuset *trialcs,
 	cs->mems_allowed = trialcs->mems_allowed;
 	spin_unlock_irq(&callback_lock);
 
+	if (cs == &top_cpuset) {
+		spin_lock_irq(&callback_lock);
+		cs->effective_mems = trialcs->mems_allowed;
+		spin_unlock_irq(&callback_lock);
+
+		update_tasks_nodemask(cs);
+		cpuset_inc();
+		goto done;
+	}
+
 	/* use trialcs->mems_allowed as a temp variable */
 	update_nodemasks_hier(cs, &trialcs->mems_allowed);
 done:
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
