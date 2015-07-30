Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f172.google.com (mail-yk0-f172.google.com [209.85.160.172])
	by kanga.kvack.org (Postfix) with ESMTP id 40B446B025A
	for <linux-mm@kvack.org>; Thu, 30 Jul 2015 13:04:24 -0400 (EDT)
Received: by ykax123 with SMTP id x123so39166046yka.1
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 10:04:24 -0700 (PDT)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id t123si1305303ywe.6.2015.07.30.10.04.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Jul 2015 10:04:19 -0700 (PDT)
From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv3 01/10] mm: memory hotplug with an existing resource
Date: Thu, 30 Jul 2015 18:03:03 +0100
Message-ID: <1438275792-5726-2-git-send-email-david.vrabel@citrix.com>
In-Reply-To: <1438275792-5726-1-git-send-email-david.vrabel@citrix.com>
References: <1438275792-5726-1-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org
Cc: David Vrabel <david.vrabel@citrix.com>, linux-mm@kvack.org, Konrad
 Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Daniel Kiper <daniel.kiper@oracle.com>, Andrew Morton <akpm@linux-foundation.org>

Add add_memory_resource() to add memory using an existing "System RAM"
resource.  This is useful if the memory region is being located by
finding a free resource slot with allocate_resource().

Xen guests will make use of this in their balloon driver to hotplug
arbitrary amounts of memory in response to toolstack requests.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/memory_hotplug.h |  2 ++
 mm/memory_hotplug.c            | 28 +++++++++++++++++++++-------
 2 files changed, 23 insertions(+), 7 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 6ffa0ac..c76d371 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -11,6 +11,7 @@ struct zone;
 struct pglist_data;
 struct mem_section;
 struct memory_block;
+struct resource;
 
 #ifdef CONFIG_MEMORY_HOTPLUG
 
@@ -266,6 +267,7 @@ static inline void remove_memory(int nid, u64 start, u64 size) {}
 extern int walk_memory_range(unsigned long start_pfn, unsigned long end_pfn,
 		void *arg, int (*func)(struct memory_block *, void *));
 extern int add_memory(int nid, u64 start, u64 size);
+extern int add_memory_resource(int nid, struct resource *resource);
 extern int zone_for_memory(int nid, u64 start, u64 size, int zone_default);
 extern int arch_add_memory(int nid, u64 start, u64 size);
 extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 003dbe4..169770a 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1224,23 +1224,21 @@ int zone_for_memory(int nid, u64 start, u64 size, int zone_default)
 }
 
 /* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG */
-int __ref add_memory(int nid, u64 start, u64 size)
+int __ref add_memory_resource(int nid, struct resource *res)
 {
+	u64 start, size;
 	pg_data_t *pgdat = NULL;
 	bool new_pgdat;
 	bool new_node;
-	struct resource *res;
 	int ret;
 
+	start = res->start;
+	size = resource_size(res);
+
 	ret = check_hotplug_memory_range(start, size);
 	if (ret)
 		return ret;
 
-	res = register_memory_resource(start, size);
-	ret = -EEXIST;
-	if (!res)
-		return ret;
-
 	{	/* Stupid hack to suppress address-never-null warning */
 		void *p = NODE_DATA(nid);
 		new_pgdat = !p;
@@ -1290,6 +1288,22 @@ out:
 	mem_hotplug_done();
 	return ret;
 }
+EXPORT_SYMBOL_GPL(add_memory_resource);
+
+int __ref add_memory(int nid, u64 start, u64 size)
+{
+	struct resource *res;
+	int ret;
+
+	res = register_memory_resource(start, size);
+	if (!res)
+		return -EEXIST;
+
+	ret = add_memory_resource(nid, res);
+	if (ret < 0)
+		release_memory_resource(res);
+	return ret;
+}
 EXPORT_SYMBOL_GPL(add_memory);
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
