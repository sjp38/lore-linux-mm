Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id D7E316B0034
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 13:13:06 -0400 (EDT)
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH 1/7] drivers: base: move mutex lock out of add_memory_section()
Date: Tue, 20 Aug 2013 12:12:57 -0500
Message-Id: <1377018783-26756-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Dave Hansen <dave@sr71.net>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Yinghai Lu <yinghai@kernel.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

There is no point in releasing the mutex for each section that is added
during boot time.  Just hold it over the entire initialization loop.

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 drivers/base/memory.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 2b7813e..278bb3da 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -613,8 +613,6 @@ static int add_memory_section(int nid, struct mem_section *section,
 	int scn_nr = __section_nr(section);
 	int ret = 0;
 
-	mutex_lock(&mem_sysfs_mutex);
-
 	if (context == BOOT) {
 		/* same memory block ? */
 		if (mem_p && *mem_p)
@@ -643,7 +641,6 @@ static int add_memory_section(int nid, struct mem_section *section,
 			ret = register_mem_sect_under_node(mem, nid);
 	}
 
-	mutex_unlock(&mem_sysfs_mutex);
 	return ret;
 }
 
@@ -653,7 +650,13 @@ static int add_memory_section(int nid, struct mem_section *section,
  */
 int register_new_memory(int nid, struct mem_section *section)
 {
-	return add_memory_section(nid, section, NULL, MEM_OFFLINE, HOTPLUG);
+	int ret;
+
+	mutex_lock(&mem_sysfs_mutex);
+	ret = add_memory_section(nid, section, NULL, MEM_OFFLINE, HOTPLUG);
+	mutex_unlock(&mem_sysfs_mutex);
+
+	return ret;
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
@@ -746,6 +749,7 @@ int __init memory_dev_init(void)
 	 * Create entries for memory sections that were found
 	 * during boot and have been initialized
 	 */
+	mutex_lock(&mem_sysfs_mutex);
 	for (i = 0; i < NR_MEM_SECTIONS; i++) {
 		if (!present_section_nr(i))
 			continue;
@@ -757,6 +761,7 @@ int __init memory_dev_init(void)
 		if (!ret)
 			ret = err;
 	}
+	mutex_unlock(&mem_sysfs_mutex);
 
 out:
 	if (ret)
-- 
1.8.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
