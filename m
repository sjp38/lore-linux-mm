Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 92D756B034B
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 14:16:47 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id k201so29128906qke.6
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 11:16:47 -0800 (PST)
Received: from mail-qt0-x241.google.com (mail-qt0-x241.google.com. [2607:f8b0:400d:c0d::241])
        by mx.google.com with ESMTPS id a19si3405879qkc.247.2016.12.20.11.16.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 11:16:46 -0800 (PST)
Received: by mail-qt0-x241.google.com with SMTP id n6so24115544qtd.0
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 11:16:46 -0800 (PST)
Subject: [PATCH 2/2] mm/memory_hotplug: set magic number to page->freelsit
 instead of page->lru.next
References: <7fd4b8b0-e305-1c6a-51ea-d5459c77d923@gmail.com>
From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Message-ID: <426dc997-1566-e977-a707-8855008d1d87@gmail.com>
Date: Tue, 20 Dec 2016 14:16:42 -0500
MIME-Version: 1.0
In-Reply-To: <7fd4b8b0-e305-1c6a-51ea-d5459c77d923@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org

To identify that pages of page table are allocated from bootmem
allocator, magic number sets to page->lru.next. But page->lru
list is initialized in reserve_bootmem_region(). So when calling
free_pagetable(), the function cannot find the magic number of
pages. And free_pagetable() frees the pages by free_reserved_page()
not put_page_bootmem().

But if the pages are allocated from bootmem allocator and used as
page table, the pages have private flag. So before freeing the
pages, we should clear the private flag by put_page_bootmem().

Before applying the commit 7bfec6f47bb0 ("mm, page_alloc: check
multiple page fields with a single branch"), we could find the
following visible issue:

  BUG: Bad page state in process kworker/u1024:1
  page:ffffea103cfd8040 count:0 mapcount:0 mappi
  flags: 0x6fffff80000800(private)
  page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
  bad because of flags: 0x800(private)
  <snip>
  Call Trace:
  [...] dump_stack+0x63/0x87
  [...] bad_page+0x114/0x130
  [...] free_pages_prepare+0x299/0x2d0
  [...] free_hot_cold_page+0x31/0x150
  [...] __free_pages+0x25/0x30
  [...] free_pagetable+0x6f/0xb4
  [...] remove_pagetable+0x379/0x7ff
  [...] vmemmap_free+0x10/0x20
  [...] sparse_remove_one_section+0x149/0x180
  [...] __remove_pages+0x2e9/0x4f0
  [...] arch_remove_memory+0x63/0xc0
  [...] remove_memory+0x8c/0xc0
  [...] acpi_memory_device_remove+0x79/0xa5
  [...] acpi_bus_trim+0x5a/0x8d
  [...] acpi_bus_trim+0x38/0x8d
  [...] acpi_device_hotplug+0x1b7/0x418
  [...] acpi_hotplug_work_fn+0x1e/0x29
  [...] process_one_work+0x152/0x400
  [...] worker_thread+0x125/0x4b0
  [...] ? __schedule+0x345/0x960
  [...] ? rescuer_thread+0x380/0x380
  [...] kthread+0xd8/0xf0
  [...] ret_from_fork+0x22/0x40
  [...] ? kthread_park+0x60/0x60

And the issue still silently occurs.

Until freeing the pages of page table allocated from bootmem allocator,
the page->freelist is never used. So the patch sets magic number to
page->freelist instead of page->lru.next.

Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
---
  arch/x86/mm/init_64.c | 2 +-
  mm/memory_hotplug.c   | 4 ++--
  mm/sparse.c           | 2 +-
  3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 963895f..b35e525 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -679,7 +679,7 @@ static void __meminit free_pagetable(struct page *page, int order)
  	if (PageReserved(page)) {
  		__ClearPageReserved(page);

-		magic = (unsigned long)page->lru.next;
+		magic = (unsigned long)page->freelist;
  		if (magic == SECTION_INFO || magic == MIX_SECTION_INFO) {
  			while (nr_pages--)
  				put_page_bootmem(page++);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index e43142c1..7e4047d 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -179,7 +179,7 @@ static void release_memory_resource(struct resource *res)
  void get_page_bootmem(unsigned long info,  struct page *page,
  		      unsigned long type)
  {
-	page->lru.next = (struct list_head *) type;
+	page->freelist = (void *) type;
  	SetPagePrivate(page);
  	set_page_private(page, info);
  	page_ref_inc(page);
@@ -189,7 +189,7 @@ void put_page_bootmem(struct page *page)
  {
  	unsigned long type;

-	type = (unsigned long) page->lru.next;
+	type = (unsigned long) page->freelist;
  	BUG_ON(type < MEMORY_HOTPLUG_MIN_BOOTMEM_TYPE ||
  	       type > MEMORY_HOTPLUG_MAX_BOOTMEM_TYPE);

diff --git a/mm/sparse.c b/mm/sparse.c
index c62b366..862e609 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -662,7 +662,7 @@ static void free_map_bootmem(struct page *memmap)
  		>> PAGE_SHIFT;

  	for (i = 0; i < nr_pages; i++, page++) {
-		magic = (unsigned long) page->lru.next;
+		magic = (unsigned long) page->freelist;

  		BUG_ON(magic == NODE_INFO);

-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
