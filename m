Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 0577A6B00E9
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 06:22:26 -0500 (EST)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 20 Feb 2012 11:16:11 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1KBH6wE2449540
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 22:17:06 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1KBMK4a020262
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 22:22:21 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V1 9/9] hugetlbfs: Add HugeTLB controller documentation
Date: Mon, 20 Feb 2012 16:51:42 +0530
Message-Id: <1329736902-26870-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1329736902-26870-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1329736902-26870-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 Documentation/cgroups/hugetlb.txt |   54 +++++++++++++++++++++++++++++++++++++
 1 files changed, 54 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/cgroups/hugetlb.txt

diff --git a/Documentation/cgroups/hugetlb.txt b/Documentation/cgroups/hugetlb.txt
new file mode 100644
index 0000000..722aa8e
--- /dev/null
+++ b/Documentation/cgroups/hugetlb.txt
@@ -0,0 +1,54 @@
+HugeTLB controller
+-----------------
+
+The HugetTLB controller is used to group tasks using cgroups and
+limit the HugeTLB pages used by these groups of tasks. HugetTLB cgroup
+enforce the limit during mmap(2). This enables application to fall back
+to allocation using smaller page size if the cgroup resource limit prevented
+them from allocating HugeTLB pages.
+
+
+The HugetTLB controller supports multi-hierarchy groups and task migration
+across cgroups.
+
+HugeTLB groups can be created by first mounting the cgroup filesystem.
+
+# mount -t cgroup -o hugetlb none /sys/fs/cgroup
+
+With the above step, the initial or the root HugeTLB cgroup becomes
+visible at /sys/fs/cgroup. At bootup, this group includes all the tasks in
+the system. /sys/fs/cgroup/tasks lists the tasks in this cgroup. HugeTLB
+cgroup create seperate limit, usage and max_usage files for each huge page
+size supported. An example listing is given below
+
+hugetlb.16GB.limit_in_bytes
+hugetlb.16GB.max_usage_in_bytes
+hugetlb.16GB.usage_in_bytes
+hugetlb.16MB.limit_in_bytes
+hugetlb.16MB.max_usage_in_bytes
+hugetlb.16MB.usage_in_bytes
+
+/sys/fs/cgroup/hugetlb.<pagesize>.usage_in_bytes  gives the HugeTLB usage
+by this group which is essentially the total size HugeTLB pages obtained
+by all the tasks in the system.
+
+New cgroup can be created under root HugeTLB cgroup /sys/fs/cgroup
+
+# cd /sys/fs/cgroup
+# mkdir g1
+# echo $$ > g1/tasks
+
+The above steps create a new group g1 and move the current shell
+process (bash) into it. 16MB HugeTLB pages consumed by this bash and its
+children can be obtained from g1/hugetlb.16MB.usage_in_bytes and the same
+is accumulated in /sys/fs/cgroup/hugetlb.16MB.usage_in_bytes.
+
+We can limit the usage of 16MB hugepage by a hugeTLB cgroup using
+hugetlb.16MB.limit_in_bytes
+
+# echo 16M > /sys/fs/cgroup/g1/hugetlb.16MB.limit_in_bytes
+# hugectl  --heap=16M /root/heap
+libhugetlbfs: WARNING: New heap segment map at 0x20000000000 failed: Cannot allocate memory
+# echo -1 > /sys/fs/cgroup/g1/hugetlb.16MB.limit_in_bytes
+# hugectl  --heap=16M /root/heap
+#
-- 
1.7.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
