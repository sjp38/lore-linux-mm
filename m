Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 45F6A6B02AB
	for <linux-mm@kvack.org>; Wed, 23 May 2018 11:12:16 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id z10-v6so2466921qto.11
        for <linux-mm@kvack.org>; Wed, 23 May 2018 08:12:16 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 81-v6si1014080qkg.280.2018.05.23.08.12.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 May 2018 08:12:15 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH v1 03/10] kasan: prepare for online/offline of different start/size
Date: Wed, 23 May 2018 17:11:44 +0200
Message-Id: <20180523151151.6730-4-david@redhat.com>
In-Reply-To: <20180523151151.6730-1-david@redhat.com>
References: <20180523151151.6730-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, David Hildenbrand <david@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com

The memory notifier has an important restriction right now: it only
works if offline_pages() is called with the same parameters as
online_pages().

To overcome this restriction, let's handle it per section. We could do
it in smaller granularity, but then we get more vm_area overhead and
cannot check that cleanly for actual online parts.

A section is marked online as soon as at least one page is online.
Similarly, a section is marked offline as soon as all pages are offline.

So handling it on a per-section basis allows us to be more flexible. We
asssume here, that a section is not split between boot and hotplug
memory.

Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Potapenko <glider@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: kasan-dev@googlegroups.com
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/kasan/kasan.c | 107 ++++++++++++++++++++++++++++++-----------------
 1 file changed, 69 insertions(+), 38 deletions(-)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index a8b85706e2d6..901601a562a9 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -827,62 +827,93 @@ static bool shadow_mapped(unsigned long addr)
 	return !pte_none(*pte);
 }
 
-static int __meminit kasan_mem_notifier(struct notifier_block *nb,
-			unsigned long action, void *data)
+static void kasan_offline_pages(unsigned long start_pfn, unsigned long nr_pages)
 {
-	struct memory_notify *mem_data = data;
-	unsigned long nr_shadow_pages, start_kaddr, shadow_start;
-	unsigned long shadow_end, shadow_size;
+	unsigned long start = SECTION_ALIGN_DOWN(start_pfn);
+	unsigned long end = SECTION_ALIGN_UP(start_pfn + nr_pages);
+	unsigned long pfn;
 
-	nr_shadow_pages = mem_data->nr_pages >> KASAN_SHADOW_SCALE_SHIFT;
-	start_kaddr = (unsigned long)pfn_to_kaddr(mem_data->start_pfn);
-	shadow_start = (unsigned long)kasan_mem_to_shadow((void *)start_kaddr);
-	shadow_size = nr_shadow_pages << PAGE_SHIFT;
-	shadow_end = shadow_start + shadow_size;
+	for (pfn = start; pfn < end; pfn += PAGES_PER_SECTION) {
+		void *addr, *shadow_start;
+		struct vm_struct *vm;
 
-	if (WARN_ON(mem_data->nr_pages % KASAN_SHADOW_SCALE_SIZE) ||
-		WARN_ON(start_kaddr % (KASAN_SHADOW_SCALE_SIZE << PAGE_SHIFT)))
-		return NOTIFY_BAD;
+		/* still online? nothing to do then */
+		if (online_section_nr(pfn_to_section_nr(pfn)))
+			continue;
 
-	switch (action) {
-	case MEM_GOING_ONLINE: {
-		void *ret;
+		addr = pfn_to_kaddr(pfn);
+		shadow_start = kasan_mem_to_shadow(addr);
+
+		/*
+		 * Only hot-added memory has a vm_area. Freeing shadow mapped
+		 * during boot would be tricky, so we'll just have to keep it.
+		 */
+		vm = find_vm_area(shadow_start);
+		if (vm)
+			vfree(shadow_start);
+	}
+}
+
+static int kasan_online_pages(unsigned long start_pfn, unsigned long nr_pages)
+{
+	unsigned long start = SECTION_ALIGN_DOWN(start_pfn);
+	unsigned long end = SECTION_ALIGN_UP(start_pfn + nr_pages);
+	unsigned long pfn;
+
+	for (pfn = start; pfn < end; pfn += PAGES_PER_SECTION) {
+		unsigned long shadow_start, shadow_size;
+		void *addr, *ret;
+
+		/* already online? nothing to do then */
+		if (online_section_nr(pfn_to_section_nr(pfn)))
+			continue;
+
+		addr = pfn_to_kaddr(pfn);
+		shadow_size = (PAGES_PER_SECTION << PAGE_SHIFT) >>
+			      KASAN_SHADOW_SCALE_SHIFT;
+		shadow_start = (unsigned long)kasan_mem_to_shadow(addr);
 
 		/*
 		 * If shadow is mapped already than it must have been mapped
-		 * during the boot. This could happen if we onlining previously
+		 * during boot. This could happen if we're onlining previously
 		 * offlined memory.
 		 */
 		if (shadow_mapped(shadow_start))
-			return NOTIFY_OK;
+			continue;
 
 		ret = __vmalloc_node_range(shadow_size, PAGE_SIZE, shadow_start,
-					shadow_end, GFP_KERNEL,
-					PAGE_KERNEL, VM_NO_GUARD,
-					pfn_to_nid(mem_data->start_pfn),
-					__builtin_return_address(0));
+					   shadow_start + shadow_size,
+					   GFP_KERNEL, PAGE_KERNEL, VM_NO_GUARD,
+					   pfn_to_nid(pfn),
+					   __builtin_return_address(0));
 		if (!ret)
-			return NOTIFY_BAD;
-
+			goto out_free;
 		kmemleak_ignore(ret);
-		return NOTIFY_OK;
 	}
-	case MEM_CANCEL_ONLINE:
-	case MEM_OFFLINE: {
-		struct vm_struct *vm;
+	return 0;
+out_free:
+	kasan_offline_pages(start_pfn, nr_pages);
+	return -ENOMEM;
+}
 
-		/*
-		 * Only hot-added memory have vm_area. Freeing shadow
-		 * mapped during boot would be tricky, so we'll just
-		 * have to keep it.
-		 */
-		vm = find_vm_area((void *)shadow_start);
-		if (vm)
-			vfree((void *)shadow_start);
-	}
+static int __meminit kasan_mem_notifier(struct notifier_block *nb,
+			unsigned long action, void *data)
+{
+	struct memory_notify *mem_data = data;
+	int ret = 0;
+
+	switch (action) {
+	case MEM_GOING_ONLINE:
+		ret = kasan_online_pages(mem_data->start_pfn,
+					 mem_data->nr_pages);
+		break;
+	case MEM_CANCEL_ONLINE:
+	case MEM_OFFLINE:
+		kasan_offline_pages(mem_data->start_pfn, mem_data->nr_pages);
+		break;
 	}
 
-	return NOTIFY_OK;
+	return notifier_from_errno(ret);
 }
 
 static int __init kasan_memhotplug_init(void)
-- 
2.17.0
