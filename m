Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 480E06B00E7
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 04:17:16 -0500 (EST)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 1 Mar 2012 09:09:25 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q219HC9S1347712
	for <linux-mm@kvack.org>; Thu, 1 Mar 2012 20:17:12 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q219HBWi004758
	for <linux-mm@kvack.org>; Thu, 1 Mar 2012 20:17:12 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V2 9/9] memcg: Add memory controller documentation for hugetlb management
Date: Thu,  1 Mar 2012 14:46:20 +0530
Message-Id: <1330593380-1361-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1330593380-1361-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1330593380-1361-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 Documentation/cgroups/memory.txt |   28 ++++++++++++++++++++++++++++
 1 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index 4c95c00..f98d9af 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -43,6 +43,7 @@ Features:
  - usage threshold notifier
  - oom-killer disable knob and oom-notifier
  - Root cgroup has no limit controls.
+ - resource accounting for non reclaimable resources like HugeTLB pages
 
  Kernel memory support is work in progress, and the current version provides
  basically functionality. (See Section 2.7)
@@ -75,6 +76,12 @@ Brief summary of control files.
  memory.kmem.tcp.limit_in_bytes  # set/show hard limit for tcp buf memory
  memory.kmem.tcp.usage_in_bytes  # show current tcp buf memory allocation
 
+
+ memory.hugetlb.<hugepagesize>.limit_in_bytes     # set/show limit of "hugepagesize" hugetlb usage
+ memory.hugetlb.<hugepagesize>.max_usage_in_bytes # show max "hugepagesize" hugetlb  usage recorded
+ memory.hugetlb.<hugepagesize>.usage_in_bytes     # show current res_counter usage for "hugepagesize" hugetlb
+						  # see 5.7 for details
+
 1. History
 
 The memory controller has a long history. A request for comments for the memory
@@ -279,6 +286,14 @@ per cgroup, instead of globally.
 
 * tcp memory pressure: sockets memory pressure for the tcp protocol.
 
+2.8 Non reclaim resouce management
+
+This helps in enforcing limit on non reclaimable pages like HugeTLB pages.
+For non reclaim resource, enforcing limit during actual page allocation
+doesn't make sense. Hence this extension enforce limit during mmap(2).
+This enables application to fall back to alternative allocation methods
+such as allocations using normal page size when HugeTLB allocation fails.
+
 3. User Interface
 
 0. Configuration
@@ -287,6 +302,7 @@ a. Enable CONFIG_CGROUPS
 b. Enable CONFIG_RESOURCE_COUNTERS
 c. Enable CONFIG_CGROUP_MEM_RES_CTLR
 d. Enable CONFIG_CGROUP_MEM_RES_CTLR_SWAP (to use swap extension)
+f. Enable CONFIG_MEM_RES_CTLR_NORECLAIM (to use non reclaim extension)
 
 1. Prepare the cgroups (see cgroups.txt, Why are cgroups needed?)
 # mount -t tmpfs none /sys/fs/cgroup
@@ -510,6 +526,18 @@ unevictable=<total anon pages> N0=<node 0 pages> N1=<node 1 pages> ...
 
 And we have total = file + anon + unevictable.
 
+5.7 non reclaimable resource control files
+For a system supporting two hugepage size (16M and 16G) the control
+files include:
+
+ memory.hugetlb.16GB.limit_in_bytes
+ memory.hugetlb.16GB.max_usage_in_bytes
+ memory.hugetlb.16GB.usage_in_bytes
+ memory.hugetlb.16MB.limit_in_bytes
+ memory.hugetlb.16MB.max_usage_in_bytes
+ memory.hugetlb.16MB.usage_in_bytes
+
+
 6. Hierarchy support
 
 The memory controller supports a deep hierarchy and hierarchical accounting.
-- 
1.7.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
