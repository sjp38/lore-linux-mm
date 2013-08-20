Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id D42736B0033
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 13:13:06 -0400 (EDT)
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH 5/7] drivers: base: reduce add_memory_section() for boot-time only
Date: Tue, 20 Aug 2013 12:13:01 -0500
Message-Id: <1377018783-26756-5-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1377018783-26756-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1377018783-26756-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Dave Hansen <dave@sr71.net>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Yinghai Lu <yinghai@kernel.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

Now that add_memory_section() is only called from boot time, reduce
the logic and remove the enum.

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 drivers/base/memory.c  | 41 ++++++++++++++---------------------------
 include/linux/memory.h |  1 -
 2 files changed, 14 insertions(+), 28 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 05a90ba..a695164 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -602,40 +602,29 @@ static int init_memory_block(struct memory_block **memory,
 	return ret;
 }
 
-static int add_memory_section(int nid, struct mem_section *section,
-			struct memory_block **mem_p,
-			unsigned long state, enum mem_add_context context)
+static int add_memory_section(struct mem_section *section,
+			struct memory_block **mem_p)
 {
 	struct memory_block *mem = NULL;
 	int scn_nr = __section_nr(section);
 	int ret = 0;
 
-	if (context == BOOT) {
-		/* same memory block ? */
-		if (mem_p && *mem_p)
-			if (scn_nr >= (*mem_p)->start_section_nr &&
-			    scn_nr <= (*mem_p)->end_section_nr) {
-				mem = *mem_p;
-				get_device(&mem->dev);
-			}
-	} else
-		mem = find_memory_block(section);
+	if (mem_p && *mem_p) {
+		if (scn_nr >= (*mem_p)->start_section_nr &&
+		    scn_nr <= (*mem_p)->end_section_nr) {
+			mem = *mem_p;
+			get_device(&mem->dev);
+		}
+	}
 
 	if (mem) {
 		mem->section_count++;
 		put_device(&mem->dev);
 	} else {
-		ret = init_memory_block(&mem, section, state);
+		ret = init_memory_block(&mem, section, MEM_ONLINE);
 		/* store memory_block pointer for next loop */
-		if (!ret && context == BOOT)
-			if (mem_p)
-				*mem_p = mem;
-	}
-
-	if (!ret) {
-		if (context == HOTPLUG &&
-		    mem->section_count == sections_per_block)
-			ret = register_mem_sect_under_node(mem, nid);
+		if (!ret && mem_p)
+			*mem_p = mem;
 	}
 
 	return ret;
@@ -764,10 +753,8 @@ int __init memory_dev_init(void)
 		if (!present_section_nr(i))
 			continue;
 		/* don't need to reuse memory_block if only one per block */
-		err = add_memory_section(0, __nr_to_section(i),
-				 (sections_per_block == 1) ? NULL : &mem,
-					 MEM_ONLINE,
-					 BOOT);
+		err = add_memory_section(__nr_to_section(i),
+				 (sections_per_block == 1) ? NULL : &mem);
 		if (!ret)
 			ret = err;
 	}
diff --git a/include/linux/memory.h b/include/linux/memory.h
index 85c31a8..4c89fb0 100644
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -125,7 +125,6 @@ extern struct memory_block *find_memory_block_hinted(struct mem_section *,
 							struct memory_block *);
 extern struct memory_block *find_memory_block(struct mem_section *);
 #define CONFIG_MEM_BLOCK_SIZE	(PAGES_PER_SECTION<<PAGE_SHIFT)
-enum mem_add_context { BOOT, HOTPLUG };
 #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-- 
1.8.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
