Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id C6CC36B0032
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 13:13:06 -0400 (EDT)
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH 4/7] drivers: base: unshare add_memory_section() from hotplug
Date: Tue, 20 Aug 2013 12:13:00 -0500
Message-Id: <1377018783-26756-4-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1377018783-26756-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1377018783-26756-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Dave Hansen <dave@sr71.net>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Yinghai Lu <yinghai@kernel.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

add_memory_section() is currently called from both boot time and run
time via hotplug and there is a lot of nastiness to allow for shared
code including an enum parameter to convey the calling context to
add_memory_section().

This patch is the first step in breaking up the messy code sharing by
pulling the hotplug path for add_memory_section() directly into
register_new_memory().

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 drivers/base/memory.c | 19 ++++++++++++++++---
 1 file changed, 16 insertions(+), 3 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index a77753c..05a90ba 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -647,12 +647,25 @@ static int add_memory_section(int nid, struct mem_section *section,
  */
 int register_new_memory(int nid, struct mem_section *section)
 {
-	int ret;
+	int ret = 0;
+	struct memory_block *mem;
 
 	mutex_lock(&mem_sysfs_mutex);
-	ret = add_memory_section(nid, section, NULL, MEM_OFFLINE, HOTPLUG);
-	mutex_unlock(&mem_sysfs_mutex);
 
+	mem = find_memory_block(section);
+	if (mem) {
+		mem->section_count++;
+		put_device(&mem->dev);
+	} else {
+		ret = init_memory_block(&mem, section, MEM_OFFLINE);
+		if (ret)
+			goto out;
+	}
+
+	if (mem->section_count == sections_per_block)
+		ret = register_mem_sect_under_node(mem, nid);
+out:
+	mutex_unlock(&mem_sysfs_mutex);
 	return ret;
 }
 
-- 
1.8.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
