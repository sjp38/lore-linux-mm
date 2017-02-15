Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E96B34405B1
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 15:58:46 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id z61so7072489wrc.6
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 12:58:46 -0800 (PST)
Received: from mail-wr0-x244.google.com (mail-wr0-x244.google.com. [2a00:1450:400c:c0c::244])
        by mx.google.com with ESMTPS id 43si6477327wrk.228.2017.02.15.12.58.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Feb 2017 12:58:45 -0800 (PST)
Received: by mail-wr0-x244.google.com with SMTP id k90so32522511wrc.3
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 12:58:45 -0800 (PST)
From: Nicolai Stange <nicstange@gmail.com>
Subject: [RFC 1/3] sparse-vmemmap: let vmemmap_populate_basepages() cover the whole range
Date: Wed, 15 Feb 2017 21:58:24 +0100
Message-Id: <20170215205826.13356-2-nicstange@gmail.com>
In-Reply-To: <20170215205826.13356-1-nicstange@gmail.com>
References: <20170215205826.13356-1-nicstange@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Nicolai Stange <nicstange@gmail.com>

vmemmap_populate_basepages() takes two memory addresses, start and end,
and attempts to populate the page range covering it.

Due to the way this is done, namely by means of a

  for (addr = start; addr < end; addr += PAGE_SIZE) {
     ...
  }

loop, this misses the last necessary page in case of

  start % PAGE_SIZE > end % PAGE_SIZE.

On x86, Kasan's initizalization in arch/x86/mm/kasan_init_64.c (ab)uses
the arch-provided vmemmap_populate() for shadow memory population.
The start and end addresses passed aren't necessarily page aligned.

With commit 7b79d10a2d64 ("mm: convert kmalloc_section_memmap() to
populate_section_memmap()"), the x86 specific vmemmap_populate() sometimes
uses the aforementioned vmemmap_populate_basepages(). This results in
non-populated shadow memory:

  BUG: unable to handle kernel paging request at ffffed0017b4d000
  IP: memset_erms+0x9/0x10
  [...]
  Call Trace:
   ? kasan_free_pages+0x50/0x60
   free_hot_cold_page+0x382/0x9e0
   [...]
   __free_pages+0xe8/0x100
   [...]
   __free_pages_bootmem+0x1c9/0x202
   ? page_alloc_init_late+0x3a/0x3a
   ? kmemleak_free_part+0x42/0x150
   free_bootmem_late+0x5f/0x7d
   efi_free_boot_services+0x10d/0x233
   [...]

Fix this by making vmemmap_populate_basepages() round the start argument
down to a multiple of PAGE_SIZE such that the above condition can never
hold.

Signed-off-by: Nicolai Stange <nicstange@gmail.com>
---
 mm/sparse-vmemmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index 8679d4a81b98..d45bd2714a2b 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -223,7 +223,7 @@ pgd_t * __meminit vmemmap_pgd_populate(unsigned long addr, int node)
 int __meminit vmemmap_populate_basepages(unsigned long start,
 					 unsigned long end, int node)
 {
-	unsigned long addr = start;
+	unsigned long addr = start & ~(PAGE_SIZE - 1);
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
-- 
2.11.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
