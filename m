Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id D8FE26B0036
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 13:13:06 -0400 (EDT)
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH 3/7] drivers: base: use device get/put functions
Date: Tue, 20 Aug 2013 12:12:59 -0500
Message-Id: <1377018783-26756-3-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1377018783-26756-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1377018783-26756-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Dave Hansen <dave@sr71.net>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Yinghai Lu <yinghai@kernel.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

Use the [get|put]_device functions for ref'ing the memory block device
rather than the kobject functions which should be hidden away by the
device layer.

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 drivers/base/memory.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index e771e2b..a77753c 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -616,14 +616,14 @@ static int add_memory_section(int nid, struct mem_section *section,
 			if (scn_nr >= (*mem_p)->start_section_nr &&
 			    scn_nr <= (*mem_p)->end_section_nr) {
 				mem = *mem_p;
-				kobject_get(&mem->dev.kobj);
+				get_device(&mem->dev);
 			}
 	} else
 		mem = find_memory_block(section);
 
 	if (mem) {
 		mem->section_count++;
-		kobject_put(&mem->dev.kobj);
+		put_device(&mem->dev);
 	} else {
 		ret = init_memory_block(&mem, section, state);
 		/* store memory_block pointer for next loop */
@@ -663,7 +663,7 @@ unregister_memory(struct memory_block *memory)
 	BUG_ON(memory->dev.bus != &memory_subsys);
 
 	/* drop the ref. we got in remove_memory_block() */
-	kobject_put(&memory->dev.kobj);
+	put_device(&memory->dev);
 	device_unregister(&memory->dev);
 }
 
@@ -680,7 +680,7 @@ static int remove_memory_block(unsigned long node_id,
 	if (mem->section_count == 0)
 		unregister_memory(mem);
 	else
-		kobject_put(&mem->dev.kobj);
+		put_device(&mem->dev);
 
 	mutex_unlock(&mem_sysfs_mutex);
 	return 0;
-- 
1.8.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
