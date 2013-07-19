Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id E997D6B0031
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 14:45:09 -0400 (EDT)
From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH 1/1] Drivers: base: memory: Export symbols for onlining memory blocks
Date: Fri, 19 Jul 2013 12:23:05 -0700
Message-Id: <1374261785-1615-1-git-send-email-kys@microsoft.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com, andi@firstfloor.org, akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyuki@gmail.com, mhocko@suse.cz, hannes@cmpxchg.org, yinghan@google.com, jasowang@redhat.com, kay@vrfy.org
Cc: "K. Y. Srinivasan" <kys@microsoft.com>

The current machinery for hot-adding memory requires having udev
rules to bring the memory segments online. Export the necessary functionality
to to bring the memory segment online without involving user space code. 

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/base/memory.c  |    5 ++++-
 include/linux/memory.h |    4 ++++
 2 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 2b7813e..a8204ac 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -328,7 +328,7 @@ static int __memory_block_change_state_uevent(struct memory_block *mem,
 	return ret;
 }
 
-static int memory_block_change_state(struct memory_block *mem,
+int memory_block_change_state(struct memory_block *mem,
 		unsigned long to_state, unsigned long from_state_req,
 		int online_type)
 {
@@ -341,6 +341,8 @@ static int memory_block_change_state(struct memory_block *mem,
 
 	return ret;
 }
+EXPORT_SYMBOL(memory_block_change_state);
+
 static ssize_t
 store_mem_state(struct device *dev,
 		struct device_attribute *attr, const char *buf, size_t count)
@@ -540,6 +542,7 @@ struct memory_block *find_memory_block(struct mem_section *section)
 {
 	return find_memory_block_hinted(section, NULL);
 }
+EXPORT_SYMBOL(find_memory_block);
 
 static struct attribute *memory_memblk_attrs[] = {
 	&dev_attr_phys_index.attr,
diff --git a/include/linux/memory.h b/include/linux/memory.h
index 85c31a8..8e3ede5 100644
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -115,6 +115,10 @@ extern void unregister_memory_notifier(struct notifier_block *nb);
 extern int register_memory_isolate_notifier(struct notifier_block *nb);
 extern void unregister_memory_isolate_notifier(struct notifier_block *nb);
 extern int register_new_memory(int, struct mem_section *);
+extern int memory_block_change_state(struct memory_block *mem,
+		unsigned long to_state, unsigned long from_state_req,
+		int online_type);
+
 #ifdef CONFIG_MEMORY_HOTREMOVE
 extern int unregister_memory_section(struct mem_section *);
 #endif
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
