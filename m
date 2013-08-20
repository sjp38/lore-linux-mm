Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 129E06B003B
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 13:13:07 -0400 (EDT)
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH 7/7] drivers: base: refactor add_memory_section() to add_memory_block()
Date: Tue, 20 Aug 2013 12:13:03 -0500
Message-Id: <1377018783-26756-7-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1377018783-26756-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1377018783-26756-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Dave Hansen <dave@sr71.net>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Yinghai Lu <yinghai@kernel.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

Right now memory_dev_init() maintains the memory block pointer
between iterations of add_memory_section().  This is nasty.

This patch refactors add_memory_section() to become add_memory_block().
The refactoring pulls the section scanning out of memory_dev_init()
and simplifies the signature.

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 drivers/base/memory.c | 48 +++++++++++++++++++++---------------------------
 1 file changed, 21 insertions(+), 27 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 7d9d3bc..021283a 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -602,32 +602,31 @@ static int init_memory_block(struct memory_block **memory,
 	return ret;
 }
 
-static int add_memory_section(struct mem_section *section,
-			struct memory_block **mem_p)
+static int add_memory_block(int base_section_nr)
 {
-	struct memory_block *mem = NULL;
-	int scn_nr = __section_nr(section);
-	int ret = 0;
-
-	if (mem_p && *mem_p) {
-		if (scn_nr >= (*mem_p)->start_section_nr &&
-		    scn_nr <= (*mem_p)->end_section_nr) {
-			mem = *mem_p;
-		}
-	}
+	struct memory_block *mem;
+	int i, ret, section_count = 0, section_nr;
 
-	if (mem)
-		mem->section_count++;
-	else {
-		ret = init_memory_block(&mem, section, MEM_ONLINE);
-		/* store memory_block pointer for next loop */
-		if (!ret && mem_p)
-			*mem_p = mem;
+	for (i = base_section_nr;
+	     (i < base_section_nr + sections_per_block) && i < NR_MEM_SECTIONS;
+	     i++) {
+		if (!present_section_nr(i))
+			continue;
+		if (section_count == 0)
+			section_nr = i;
+		section_count++;
 	}
 
-	return ret;
+	if (section_count == 0)
+		return 0;
+	ret = init_memory_block(&mem, __nr_to_section(section_nr), MEM_ONLINE);
+	if (ret)
+		return ret;
+	mem->section_count = section_count;
+	return 0;
 }
 
+
 /*
  * need an interface for the VM to add new memory regions,
  * but without onlining it.
@@ -733,7 +732,6 @@ int __init memory_dev_init(void)
 	int ret;
 	int err;
 	unsigned long block_sz;
-	struct memory_block *mem = NULL;
 
 	ret = subsys_system_register(&memory_subsys, memory_root_attr_groups);
 	if (ret)
@@ -747,12 +745,8 @@ int __init memory_dev_init(void)
 	 * during boot and have been initialized
 	 */
 	mutex_lock(&mem_sysfs_mutex);
-	for (i = 0; i < NR_MEM_SECTIONS; i++) {
-		if (!present_section_nr(i))
-			continue;
-		/* don't need to reuse memory_block if only one per block */
-		err = add_memory_section(__nr_to_section(i),
-				 (sections_per_block == 1) ? NULL : &mem);
+	for (i = 0; i < NR_MEM_SECTIONS; i += sections_per_block) {
+		err = add_memory_block(i);
 		if (!ret)
 			ret = err;
 	}
-- 
1.8.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
