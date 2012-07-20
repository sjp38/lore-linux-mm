Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 87D866B0068
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 07:18:16 -0400 (EDT)
Received: by bkcjc3 with SMTP id jc3so3642514bkc.14
        for <linux-mm@kvack.org>; Fri, 20 Jul 2012 04:18:14 -0700 (PDT)
From: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Subject: [RFC PATCH] memory-hotplug: Add memblock_state notifier
Date: Fri, 20 Jul 2012 13:18:08 +0200
Message-Id: <1342783088-29970-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com
Cc: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>

hot-remove initiated by acpi_memhotplug driver tries to offline pages and then
remove section/sysfs files in remove_memory(). remove_memory() will only proceed
if is_memblk_offline() returns true, i.e. only if the corresponding memblock
is in MEM_OFFLINE state. However, the memblock state is currently only updated
if the offlining has been initiated from the sysfs interface (echo offline >
/sys/devices/system/memory/memoryXX/state). The acpi hot-remove codepath does
not use the sysfs interface but directly calls offline_pages. So remove_memory()
will always fail, even if offline_pages has succeeded.

This patch solves this by registering a memblock_state notifier function in the
memory_notify chain. This will change state of memblocks independently of sysfs
usage.

The patch is based on work-in-progress patches for memory hot-remove, see:
http://lwn.net/Articles/507244/

Signed-off-by: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
---
 drivers/base/memory.c |   37 +++++++++++++++++++++++++++++++++++++
 1 files changed, 37 insertions(+), 0 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 8981568..4095f3f 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -706,6 +706,42 @@ int unregister_memory_section(struct mem_section *section)
 	return remove_memory_block(0, section, 0);
 }
 
+static int memblock_state_notifier_nb(struct notifier_block *nb, unsigned long
+		val, void *v)
+{
+	struct memory_notify *arg = (struct memory_notify *)v;
+	struct memory_block *mem = NULL;
+	struct mem_section *ms;
+	unsigned long section_nr;
+
+	section_nr = pfn_to_section_nr(arg->start_pfn);
+	ms = __nr_to_section(section_nr);
+	mem = find_memory_block(ms);
+	if (!mem)
+		goto out;
+
+	switch (val) {
+	case MEM_GOING_OFFLINE:
+	case MEM_OFFLINE:
+	case MEM_GOING_ONLINE:
+	case MEM_ONLINE:
+	case MEM_CANCEL_ONLINE:
+	case MEM_CANCEL_OFFLINE:
+		mem->state = val;
+		break;
+	default:
+		printk(KERN_WARNING "invalid memblock state\n");
+		break;
+	}
+out:
+	return NOTIFY_OK;
+}
+
+static struct notifier_block memblock_state_nb = {
+	.notifier_call = memblock_state_notifier_nb,
+	.priority = 0
+};
+
 /*
  * Initialize the sysfs support for memory devices...
  */
@@ -724,6 +760,7 @@ int __init memory_dev_init(void)
 	block_sz = get_memory_block_size();
 	sections_per_block = block_sz / MIN_MEMORY_BLOCK_SIZE;
 
+	register_memory_notifier(&memblock_state_nb);
 	/*
 	 * Create entries for memory sections that were found
 	 * during boot and have been initialized
-- 
1.7.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
