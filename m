Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5E20F6B02D4
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 17:11:26 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id d185so72395066pgc.2
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 14:11:26 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id w26si4753350pfj.91.2017.01.19.14.11.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jan 2017 14:11:25 -0800 (PST)
Subject: [PATCH v3 07/12] mm: fix register_new_memory() zone type detection
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 19 Jan 2017 14:07:19 -0800
Message-ID: <148486363923.19694.16803321290568634521.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <148486359570.19694.18265063120757801811.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <148486359570.19694.18265063120757801811.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, linux-nvdimm@lists.01.org, Logan Gunthorpe <logang@deltatee.com>, linux-kernel@vger.kernel.org, Stephen Bates <stephen.bates@microsemi.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>

In preparation for sub-section memory hotplug support, remove a
dependency on ->section_mem_map being populated. In SPARSEMEM_VMEMMAP=y
configurations pfn_to_page() does not use ->section_mem_map. The
sub-section hotplug support relies on this fact and skips initializing
it. Without ->section_mem_map populated, or aligned to section boundary,
conversions of mem_section instances to zones is not possible.

So, this removes a false dependency on a structure field that will only
be valid in the SPARSEMEM_VMEMMAP=n case, and only used for
pfn_to_page() (and similar) operations.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Stephen Bates <stephen.bates@microsemi.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/base/memory.c  |   26 +++++++++-----------------
 include/linux/memory.h |    4 ++--
 mm/memory_hotplug.c    |    4 ++--
 3 files changed, 13 insertions(+), 21 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 8ab8ea1253e6..be0c4e860188 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -685,24 +685,16 @@ static int add_memory_block(int base_section_nr)
 	return 0;
 }
 
-static bool is_zone_device_section(struct mem_section *ms)
-{
-	struct page *page;
-
-	page = sparse_decode_mem_map(ms->section_mem_map, __section_nr(ms));
-	return is_zone_device_page(page);
-}
-
 /*
  * need an interface for the VM to add new memory regions,
  * but without onlining it.
  */
-int register_new_memory(int nid, struct mem_section *section)
+int register_new_memory(struct zone *zone, int nid, struct mem_section *section)
 {
 	int ret = 0;
 	struct memory_block *mem;
 
-	if (is_zone_device_section(section))
+	if (is_dev_zone(zone))
 		return 0;
 
 	mutex_lock(&mem_sysfs_mutex);
@@ -736,14 +728,11 @@ unregister_memory(struct memory_block *memory)
 	device_unregister(&memory->dev);
 }
 
-static int remove_memory_section(unsigned long node_id,
-			       struct mem_section *section, int phys_device)
+static int remove_memory_section(struct zone *zone, unsigned long node_id,
+		struct mem_section *section, int phys_device)
 {
 	struct memory_block *mem;
 
-	if (is_zone_device_section(section))
-		return 0;
-
 	mutex_lock(&mem_sysfs_mutex);
 	mem = find_memory_block(section);
 	unregister_mem_sect_under_nodes(mem, __section_nr(section));
@@ -758,12 +747,15 @@ static int remove_memory_section(unsigned long node_id,
 	return 0;
 }
 
-int unregister_memory_section(struct mem_section *section)
+int unregister_memory_section(struct zone *zone, struct mem_section *section)
 {
+	if (is_dev_zone(zone))
+		return 0;
+
 	if (!present_section(section))
 		return -EINVAL;
 
-	return remove_memory_section(0, section, 0);
+	return remove_memory_section(zone, 0, section, 0);
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
diff --git a/include/linux/memory.h b/include/linux/memory.h
index 093607f90b91..301dfb03ecb7 100644
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -108,12 +108,12 @@ extern int register_memory_notifier(struct notifier_block *nb);
 extern void unregister_memory_notifier(struct notifier_block *nb);
 extern int register_memory_isolate_notifier(struct notifier_block *nb);
 extern void unregister_memory_isolate_notifier(struct notifier_block *nb);
-extern int register_new_memory(int, struct mem_section *);
+extern int register_new_memory(struct zone *, int, struct mem_section *);
 extern int memory_block_change_state(struct memory_block *mem,
 				     unsigned long to_state,
 				     unsigned long from_state_req);
 #ifdef CONFIG_MEMORY_HOTREMOVE
-extern int unregister_memory_section(struct mem_section *);
+extern int unregister_memory_section(struct zone *, struct mem_section *);
 #endif
 extern int memory_dev_init(void);
 extern int memory_notify(unsigned long val, void *v);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index a73a1fcaa181..684addad9708 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -516,7 +516,7 @@ static int __meminit __add_section(int nid, struct zone *zone,
 	if (ret < 0)
 		return ret;
 
-	return register_new_memory(nid, __pfn_to_section(phys_start_pfn));
+	return register_new_memory(zone, nid, __pfn_to_section(phys_start_pfn));
 }
 
 /*
@@ -783,7 +783,7 @@ static int __remove_section(struct zone *zone, struct mem_section *ms,
 	if (!valid_section(ms))
 		return ret;
 
-	ret = unregister_memory_section(ms);
+	ret = unregister_memory_section(zone, ms);
 	if (ret)
 		return ret;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
