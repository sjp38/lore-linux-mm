Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 2D30D6B0009
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 16:57:53 -0500 (EST)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 28 Feb 2013 14:57:52 -0700
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id E4D0019D8046
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 14:57:46 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1SLve9M031302
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 14:57:41 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1SLvYCu017184
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 14:57:35 -0700
Received: from kernel.stglabs.ibm.com (kernel.stglabs.ibm.com [9.114.214.19])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id r1SLvXM7017114
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 14:57:33 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 23/24] x86/mm/numa: when dnuma is enabled, use memlayout to handle memory hotplug's physaddr_to_nid.
Date: Thu, 28 Feb 2013 13:57:26 -0800
Message-Id: <1362088647-19726-3-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1362088647-19726-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1362088647-19726-1-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: Cody P Schafer <cody@linux.vnet.ibm.com>, David Hansen <dave@linux.vnet.ibm.com>

When a memlayout is tracked (ie: CONFIG_DYNAMIC_NUMA is enabled), rather
than iterate over numa_meminfo, a lookup can be done using memlayout.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 arch/x86/mm/numa.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index a2a8dd5..1ed76d5 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -28,7 +28,7 @@ struct pglist_data *node_data[MAX_NUMNODES] __read_mostly;
 EXPORT_SYMBOL(node_data);
 
 static struct numa_meminfo numa_meminfo
-#ifndef CONFIG_MEMORY_HOTPLUG
+#if !defined(CONFIG_MEMORY_HOTPLUG) || defined(CONFIG_DYNAMIC_NUMA)
 __initdata
 #endif
 ;
@@ -832,7 +832,7 @@ EXPORT_SYMBOL(cpumask_of_node);
 
 #endif	/* !CONFIG_DEBUG_PER_CPU_MAPS */
 
-#ifdef CONFIG_MEMORY_HOTPLUG
+#if defined(CONFIG_MEMORY_HOTPLUG) && !defined(CONFIG_DYNAMIC_NUMA)
 int memory_add_physaddr_to_nid(u64 start)
 {
 	struct numa_meminfo *mi = &numa_meminfo;
-- 
1.8.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
