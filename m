Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id F38C76B0287
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:39:47 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id yr2so58627816wjc.4
        for <linux-mm@kvack.org>; Sun, 29 Jan 2017 19:39:47 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id y4si11729127wmy.33.2017.01.29.19.39.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Jan 2017 19:39:46 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0U3YJZt187150
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:39:45 -0500
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
	by mx0b-001b2d01.pphosted.com with ESMTP id 289954dk8u-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:39:45 -0500
Received: from localhost
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 30 Jan 2017 13:39:42 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 32B5D3578053
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:39:39 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0U3dVDB28704954
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:39:39 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0U3d6dA022883
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:39:07 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [DEBUG 19/21] mm: Add migrate_virtual_range migration interface
Date: Mon, 30 Jan 2017 09:06:00 +0530
In-Reply-To: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
Message-Id: <20170130033602.12275-20-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

Currently there is no interface to be called by a driver for user process
virtual range migration. This adds one function and exports to be then
used by drivers.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 include/linux/mempolicy.h |  2 ++
 mm/mempolicy.c            | 45 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 47 insertions(+)

diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index ff0c6bc..b07d6dc 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -153,6 +153,8 @@ extern bool init_nodemask_of_mempolicy(nodemask_t *mask);
 extern bool mempolicy_nodemask_intersects(struct task_struct *tsk,
 				const nodemask_t *mask);
 extern unsigned int mempolicy_slab_node(void);
+extern int migrate_virtual_range(int pid, unsigned long vaddr,
+			unsigned long size, int nid);
 
 extern enum zone_type policy_zone;
 
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 4482140..13cd5eb 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2919,3 +2919,48 @@ void mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol)
 		p += scnprintf(p, buffer + maxlen - p, ":%*pbl",
 			       nodemask_pr_args(&nodes));
 }
+
+/*
+ * migrate_virtual_range - migrate all pages of a process faulted within
+ * a virtual address range to a specified node. This function is also
+ * exported to be used by device drivers dealing with CDM memory.
+ *
+ * @pid:	Process ID of the target process
+ * @start:	Start address of virtual range
+ * @end:	End address of virtual range
+ * @nid:	Target node for migration
+ *
+ * Returns number of pages that were not migrated in case of failure else
+ * returns 0 when its successful.
+ */
+int migrate_virtual_range(int pid, unsigned long start,
+			unsigned long end, int nid)
+{
+	struct mm_struct *mm;
+	int ret = 0;
+
+	LIST_HEAD(mlist);
+
+	if ((!start) || (!end)) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	rcu_read_lock();
+	mm = find_task_by_vpid(pid)->mm;
+	rcu_read_unlock();
+
+	down_write(&mm->mmap_sem);
+	queue_pages_range(mm, start, end, &node_states[N_MEMORY],
+			MPOL_MF_MOVE_ALL | MPOL_MF_DISCONTIG_OK, &mlist);
+	if (!list_empty(&mlist)) {
+		ret = migrate_pages(&mlist, new_node_page, NULL,
+					nid, MIGRATE_SYNC, MR_NUMA_MISPLACED);
+		if (ret)
+			putback_movable_pages(&mlist);
+	}
+	up_write(&mm->mmap_sem);
+out:
+	return ret;
+}
+EXPORT_SYMBOL(migrate_virtual_range);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
