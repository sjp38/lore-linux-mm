Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E2DCE6B0253
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 18:44:45 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id i88so57567098pfk.3
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 15:44:45 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 123si33509685pgj.89.2016.11.07.15.44.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 15:44:45 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uA7NiJBb018261
	for <linux-mm@kvack.org>; Mon, 7 Nov 2016 18:44:44 -0500
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26k17r6jp0-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 07 Nov 2016 18:44:44 -0500
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Mon, 7 Nov 2016 16:44:43 -0700
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: [PATCH v6 2/4] mm: remove x86-only restriction of movable_node
Date: Mon,  7 Nov 2016 17:44:34 -0600
In-Reply-To: <1478562276-25539-1-git-send-email-arbab@linux.vnet.ibm.com>
References: <1478562276-25539-1-git-send-email-arbab@linux.vnet.ibm.com>
Message-Id: <1478562276-25539-3-git-send-email-arbab@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Andrew Morton <akpm@linux-foundation.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, devicetree@vger.kernel.org, Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Stewart Smith <stewart@linux.vnet.ibm.com>, Alistair Popple <apopple@au1.ibm.com>, Balbir Singh <bsingharora@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org

In commit c5320926e370 ("mem-hotplug: introduce movable_node boot
option"), the memblock allocation direction is changed to bottom-up and
then back to top-down like this:

1. memblock_set_bottom_up(true), called by cmdline_parse_movable_node().
2. memblock_set_bottom_up(false), called by x86's numa_init().

Even though (1) occurs in generic mm code, it is wrapped by #ifdef
CONFIG_MOVABLE_NODE, which depends on X86_64.

This means that when we extend CONFIG_MOVABLE_NODE to non-x86 arches,
things will be unbalanced. (1) will happen for them, but (2) will not.

This toggle was added in the first place because x86 has a delay between
adding memblocks and marking them as hotpluggable. Since other arches do
this marking either immediately or not at all, they do not require the
bottom-up toggle.

So, resolve things by moving (1) from cmdline_parse_movable_node() to
x86's setup_arch(), immediately after the movable_node parameter has
been parsed.

Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
---
 Documentation/kernel-parameters.txt |  2 +-
 arch/x86/kernel/setup.c             | 24 ++++++++++++++++++++++++
 mm/memory_hotplug.c                 | 20 --------------------
 3 files changed, 25 insertions(+), 21 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 37babf9..adcccd5 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -2401,7 +2401,7 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			that the amount of memory usable for all allocations
 			is not too small.
 
-	movable_node	[KNL,X86] Boot-time switch to enable the effects
+	movable_node	[KNL] Boot-time switch to enable the effects
 			of CONFIG_MOVABLE_NODE=y. See mm/Kconfig for details.
 
 	MTD_Partition=	[MTD]
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 9c337b0..4cfba94 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -985,6 +985,30 @@ void __init setup_arch(char **cmdline_p)
 
 	parse_early_param();
 
+#ifdef CONFIG_MEMORY_HOTPLUG
+	/*
+	 * Memory used by the kernel cannot be hot-removed because Linux
+	 * cannot migrate the kernel pages. When memory hotplug is
+	 * enabled, we should prevent memblock from allocating memory
+	 * for the kernel.
+	 *
+	 * ACPI SRAT records all hotpluggable memory ranges. But before
+	 * SRAT is parsed, we don't know about it.
+	 *
+	 * The kernel image is loaded into memory at very early time. We
+	 * cannot prevent this anyway. So on NUMA system, we set any
+	 * node the kernel resides in as un-hotpluggable.
+	 *
+	 * Since on modern servers, one node could have double-digit
+	 * gigabytes memory, we can assume the memory around the kernel
+	 * image is also un-hotpluggable. So before SRAT is parsed, just
+	 * allocate memory near the kernel image to try the best to keep
+	 * the kernel away from hotpluggable memory.
+	 */
+	if (movable_node_is_enabled())
+		memblock_set_bottom_up(true);
+#endif
+
 	x86_report_nx();
 
 	/* after early param, so could get panic from serial */
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index cad4b91..e43142c1 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1727,26 +1727,6 @@ static bool can_offline_normal(struct zone *zone, unsigned long nr_pages)
 static int __init cmdline_parse_movable_node(char *p)
 {
 #ifdef CONFIG_MOVABLE_NODE
-	/*
-	 * Memory used by the kernel cannot be hot-removed because Linux
-	 * cannot migrate the kernel pages. When memory hotplug is
-	 * enabled, we should prevent memblock from allocating memory
-	 * for the kernel.
-	 *
-	 * ACPI SRAT records all hotpluggable memory ranges. But before
-	 * SRAT is parsed, we don't know about it.
-	 *
-	 * The kernel image is loaded into memory at very early time. We
-	 * cannot prevent this anyway. So on NUMA system, we set any
-	 * node the kernel resides in as un-hotpluggable.
-	 *
-	 * Since on modern servers, one node could have double-digit
-	 * gigabytes memory, we can assume the memory around the kernel
-	 * image is also un-hotpluggable. So before SRAT is parsed, just
-	 * allocate memory near the kernel image to try the best to keep
-	 * the kernel away from hotpluggable memory.
-	 */
-	memblock_set_bottom_up(true);
 	movable_node_enabled = true;
 #else
 	pr_warn("movable_node option not supported\n");
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
