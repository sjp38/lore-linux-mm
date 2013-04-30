Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 190146B00BC
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 05:18:39 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v2 03/13] page_alloc, mem-hotplug: Improve movablecore to {en|dis}able using SRAT.
Date: Tue, 30 Apr 2013 17:21:13 +0800
Message-Id: <1367313683-10267-4-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1367313683-10267-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1367313683-10267-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, tj@kernel.org, laijs@cn.fujitsu.com, davem@davemloft.net, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

The Hot-Pluggable Fired in SRAT specified which memory ranges are hotpluggable.
We will arrange hotpluggable memory as ZONE_MOVABLE for users who want to use
memory hotplug functionality. But this will cause NUMA performance decreased
because kernel cannot use ZONE_MOVABLE.

So we improve movablecore boot option to allow those who want to use memory
hotplug functionality to enable using SRAT info to arrange movable memory.

Users can specify "movablecore=acpi" in kernel commandline to enable this
functionality.

For those who don't use memory hotplug or who don't want to lose their NUMA
performance, just don't specify anything. The kernel will work as before.

Suggested-by: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 include/linux/memory_hotplug.h |    3 +++
 mm/page_alloc.c                |   13 +++++++++++++
 2 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index b6a3be7..18fe2a3 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -33,6 +33,9 @@ enum {
 	ONLINE_MOVABLE,
 };
 
+/* Enable/disable SRAT in movablecore boot option */
+extern bool movablecore_enable_srat;
+
 /*
  * pgdat resizing functions
  */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f368db4..b9ea143 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -208,6 +208,8 @@ static unsigned long __initdata required_kernelcore;
 static unsigned long __initdata required_movablecore;
 static unsigned long __meminitdata zone_movable_pfn[MAX_NUMNODES];
 
+bool __initdata movablecore_enable_srat = false;
+
 /* movable_zone is the "real" zone pages in ZONE_MOVABLE are taken from */
 int movable_zone;
 EXPORT_SYMBOL(movable_zone);
@@ -5025,6 +5027,12 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
 	}
 }
 
+static void __init cmdline_movablecore_srat(char *p)
+{
+	if (p && !strcmp(p, "acpi"))
+		movablecore_enable_srat = true;
+}
+
 static int __init cmdline_parse_core(char *p, unsigned long *core)
 {
 	unsigned long long coremem;
@@ -5055,6 +5063,11 @@ static int __init cmdline_parse_kernelcore(char *p)
  */
 static int __init cmdline_parse_movablecore(char *p)
 {
+	cmdline_movablecore_srat(p);
+
+	if (movablecore_enable_srat)
+		return 0;
+
 	return cmdline_parse_core(p, &required_movablecore);
 }
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
