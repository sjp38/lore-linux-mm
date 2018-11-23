Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id D47BE6B2EA3
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 07:37:49 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id 98so11470810qkp.22
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 04:37:49 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z8si2646589qto.268.2018.11.23.04.37.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 04:37:48 -0800 (PST)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH v1] mm/memory_hotplug: drop "online" parameter from add_memory_resource()
Date: Fri, 23 Nov 2018 13:37:40 +0100
Message-Id: <20181123123740.27652-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org, David Hildenbrand <david@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Stefano Stabellini <sstabellini@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Oscar Salvador <osalvador@suse.de>, Pavel Tatashin <pasha.tatashin@oracle.com>, Michal Hocko <mhocko@suse.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Arun KS <arunks@codeaurora.org>, Mathieu Malaterre <malat@debian.org>, Stephen Rothwell <sfr@canb.auug.org.au>

User space should always be in charge of how to online memory and
if memory should be onlined automatically in the kernel. Let's drop the
parameter to overwrite this - XEN passes memhp_auto_online, just like
add_memory(), so we can directly use that instead internally.

Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Stefano Stabellini <sstabellini@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: David Hildenbrand <david@redhat.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Arun KS <arunks@codeaurora.org>
Cc: Mathieu Malaterre <malat@debian.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/xen/balloon.c          | 2 +-
 include/linux/memory_hotplug.h | 2 +-
 mm/memory_hotplug.c            | 6 +++---
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index 12148289debd..81ba448166cd 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -397,7 +397,7 @@ static enum bp_state reserve_additional_memory(void)
 	mutex_unlock(&balloon_mutex);
 	/* add_memory_resource() requires the device_hotplug lock */
 	lock_device_hotplug();
-	rc = add_memory_resource(nid, resource, memhp_auto_online);
+	rc = add_memory_resource(nid, resource);
 	unlock_device_hotplug();
 	mutex_lock(&balloon_mutex);
 
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 84e9ae205930..ebc99f29aeae 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -326,7 +326,7 @@ extern int walk_memory_range(unsigned long start_pfn, unsigned long end_pfn,
 		void *arg, int (*func)(struct memory_block *, void *));
 extern int __add_memory(int nid, u64 start, u64 size);
 extern int add_memory(int nid, u64 start, u64 size);
-extern int add_memory_resource(int nid, struct resource *resource, bool online);
+extern int add_memory_resource(int nid, struct resource *resource);
 extern int arch_add_memory(int nid, u64 start, u64 size,
 		struct vmem_altmap *altmap, bool want_memblock);
 extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 7b4317ae8318..7b64bbf645c3 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1096,7 +1096,7 @@ static int online_memory_block(struct memory_block *mem, void *arg)
  *
  * we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG
  */
-int __ref add_memory_resource(int nid, struct resource *res, bool online)
+int __ref add_memory_resource(int nid, struct resource *res)
 {
 	u64 start, size;
 	bool new_node = false;
@@ -1151,7 +1151,7 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
 	mem_hotplug_done();
 
 	/* online pages if requested */
-	if (online)
+	if (memhp_auto_online)
 		walk_memory_range(PFN_DOWN(start), PFN_UP(start + size - 1),
 				  NULL, online_memory_block);
 
@@ -1175,7 +1175,7 @@ int __ref __add_memory(int nid, u64 start, u64 size)
 	if (IS_ERR(res))
 		return PTR_ERR(res);
 
-	ret = add_memory_resource(nid, res, memhp_auto_online);
+	ret = add_memory_resource(nid, res);
 	if (ret < 0)
 		release_memory_resource(res);
 	return ret;
-- 
2.17.2
