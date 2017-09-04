Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8B8FC6B0491
	for <linux-mm@kvack.org>; Mon,  4 Sep 2017 04:21:59 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id n33so3875178wrn.6
        for <linux-mm@kvack.org>; Mon, 04 Sep 2017 01:21:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b8sor770574wrf.5.2017.09.04.01.21.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Sep 2017 01:21:58 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/2] mm, memory_hotplug: remove timeout from __offline_memory
Date: Mon,  4 Sep 2017 10:21:48 +0200
Message-Id: <20170904082148.23131-3-mhocko@kernel.org>
In-Reply-To: <20170904082148.23131-1-mhocko@kernel.org>
References: <20170904082148.23131-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

We have a hardcoded 120s timeout after which the memory offline fails
basically since the hot remove has been introduced. This is essentially
a policy implemented in the kernel. Moreover there is no way to adjust
the timeout and so we are sometimes facing memory offline failures if
the system is under a heavy memory pressure or very intensive CPU
workload on large machines.

It is not very clear what purpose the timeout actually serves. The
offline operation is interruptible by a signal so if userspace wants
some timeout based termination this can be done trivially by sending a
signal.

If there is a strong usecase to do this from the kernel then we should
do it properly and have a it tunable from the userspace with the timeout
disabled by default along with the explanation who uses it and for what
purporse.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/memory_hotplug.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index c9dcbe6d2ac6..b8a85c11360e 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1593,9 +1593,9 @@ static void node_states_clear_node(int node, struct memory_notify *arg)
 }
 
 static int __ref __offline_pages(unsigned long start_pfn,
-		  unsigned long end_pfn, unsigned long timeout)
+		  unsigned long end_pfn)
 {
-	unsigned long pfn, nr_pages, expire;
+	unsigned long pfn, nr_pages;
 	long offlined_pages;
 	int ret, node;
 	unsigned long flags;
@@ -1633,12 +1633,8 @@ static int __ref __offline_pages(unsigned long start_pfn,
 		goto failed_removal;
 
 	pfn = start_pfn;
-	expire = jiffies + timeout;
 repeat:
 	/* start memory hot removal */
-	ret = -EBUSY;
-	if (time_after(jiffies, expire))
-		goto failed_removal;
 	ret = -EINTR;
 	if (signal_pending(current))
 		goto failed_removal;
@@ -1711,7 +1707,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
 /* Must be protected by mem_hotplug_begin() or a device_lock */
 int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
 {
-	return __offline_pages(start_pfn, start_pfn + nr_pages, 120 * HZ);
+	return __offline_pages(start_pfn, start_pfn + nr_pages);
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
