Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id B385F8D0001
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 12:49:14 -0400 (EDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH] mm/hotplug: Verify hotplug memory range
Date: Thu,  8 Aug 2013 10:47:40 -0600
Message-Id: <1375980460-28311-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave@sr71.net, isimatu.yasuaki@jp.fujitsu.com, tangchen@cn.fujitsu.com, vasilis.liaskovitis@profitbricks.com, Toshi Kani <toshi.kani@hp.com>

add_memory() and remove_memory() can only handle a memory range aligned
with section.  There are problems when an unaligned range is added and
then deleted as follows:

 - add_memory() with an unaligned range succeeds, but __add_pages()
   called from add_memory() adds a whole section of pages even though
   a given memory range is less than the section size.
 - remove_memory() to the added unaligned range hits BUG_ON() in
   __remove_pages().

This patch changes add_memory() and remove_memory() to check if a given
memory range is aligned with section at the beginning.  As the result,
add_memory() fails with -EINVAL when a given range is unaligned, and
does not add such memory range.  This prevents remove_memory() to be
called with an unaligned range as well.  Note that remove_memory() has
to use BUG_ON() since this function cannot fail.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 mm/memory_hotplug.c |   22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index ca1dd3a..ac182de 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1069,6 +1069,22 @@ out:
 	return ret;
 }
 
+static int check_hotplug_memory_range(u64 start, u64 size)
+{
+	u64 start_pfn = start >> PAGE_SHIFT;
+	u64 nr_pages = size >> PAGE_SHIFT;
+
+	/* Memory range must be aligned with section */
+	if ((start_pfn & ~PAGE_SECTION_MASK) ||
+	    (nr_pages % PAGES_PER_SECTION) || (!nr_pages)) {
+		pr_err("Unsupported hotplug range: start 0x%llx, size 0x%llx\n",
+				start, size);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
 /* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG */
 int __ref add_memory(int nid, u64 start, u64 size)
 {
@@ -1078,6 +1094,10 @@ int __ref add_memory(int nid, u64 start, u64 size)
 	struct resource *res;
 	int ret;
 
+	ret = check_hotplug_memory_range(start, size);
+	if (ret)
+		return ret;
+
 	lock_memory_hotplug();
 
 	res = register_memory_resource(start, size);
@@ -1786,6 +1806,8 @@ void __ref remove_memory(int nid, u64 start, u64 size)
 {
 	int ret;
 
+	BUG_ON(check_hotplug_memory_range(start, size));
+
 	lock_memory_hotplug();
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
