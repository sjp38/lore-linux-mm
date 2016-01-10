Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 22938828F3
	for <linux-mm@kvack.org>; Sun, 10 Jan 2016 09:02:10 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id u188so186176751wmu.1
        for <linux-mm@kvack.org>; Sun, 10 Jan 2016 06:02:10 -0800 (PST)
Received: from mail-wm0-x233.google.com (mail-wm0-x233.google.com. [2a00:1450:400c:c09::233])
        by mx.google.com with ESMTPS id k8si14980003wmd.56.2016.01.10.06.02.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Jan 2016 06:02:09 -0800 (PST)
Received: by mail-wm0-x233.google.com with SMTP id f206so183523269wmf.0
        for <linux-mm@kvack.org>; Sun, 10 Jan 2016 06:02:08 -0800 (PST)
Message-ID: <5692645E.5080304@plexistor.com>
Date: Sun, 10 Jan 2016 16:02:06 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: [PATCH 1/2] mm: Allow single pagefault on mmap-write with VM_MIXEDMAP
References: <569263BA.5060503@plexistor.com>
In-Reply-To: <569263BA.5060503@plexistor.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>


Until now vma->vm_page_prot defines how a page/pfn is inserted into
the page table (see vma_wants_writenotify in mm/mmap.c).

Which meant that it was always inserted with read-only under the
assumption that we want to be notified when write access occurs.
This is not always true and adds an unnecessary page-fault on
every new mmap-write.

This patch adds a more granular approach and lets the fault handler
decide how it wants to map the mixmap pfn.

The old vm_insert_mixed() now receives a new pgprot_t prot and is
renamed to: vm_insert_mixed_prot().
A new inline vm_insert_mixed() is defined which is a wrapper over
vm_insert_mixed_prot(), with the vma->vm_page_prot default as before,
so to satisfy all current users.

CC: Andrew Morton <akpm@linux-foundation.org>
CC: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
CC: Oleg Nesterov <oleg@redhat.com>
CC: Mel Gorman <mgorman@suse.de>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: Matthew Wilcox <willy@linux.intel.com>
CC: linux-mm@kvack.org (open list:MEMORY MANAGEMENT)

Reviewed-by: Yigal Korman <yigal@plexistor.com>
Signed-off-by: Boaz Harrosh <boaz@plexistor.com>
---
 include/linux/mm.h |  8 +++++++-
 mm/memory.c        | 10 +++++-----
 2 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 80001de..46a9a19 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2108,8 +2108,14 @@ int remap_pfn_range(struct vm_area_struct *, unsigned long addr,
 int vm_insert_page(struct vm_area_struct *, unsigned long addr, struct page *);
 int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn);
+int vm_insert_mixed_prot(struct vm_area_struct *vma, unsigned long addr,
+			 unsigned long pfn, pgprot_t prot);
+static inline
 int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
-			unsigned long pfn);
+		    unsigned long pfn)
+{
+	return vm_insert_mixed_prot(vma, addr, pfn, vma->vm_page_prot);
+}
 int vm_iomap_memory(struct vm_area_struct *vma, phys_addr_t start, unsigned long len);
 
 
diff --git a/mm/memory.c b/mm/memory.c
index deb679c..c716913 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1589,8 +1589,8 @@ int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 }
 EXPORT_SYMBOL(vm_insert_pfn);
 
-int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
-			unsigned long pfn)
+int vm_insert_mixed_prot(struct vm_area_struct *vma, unsigned long addr,
+			 unsigned long pfn, pgprot_t prot)
 {
 	BUG_ON(!(vma->vm_flags & VM_MIXEDMAP));
 
@@ -1608,11 +1608,11 @@ int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 		struct page *page;
 
 		page = pfn_to_page(pfn);
-		return insert_page(vma, addr, page, vma->vm_page_prot);
+		return insert_page(vma, addr, page, prot);
 	}
-	return insert_pfn(vma, addr, pfn, vma->vm_page_prot);
+	return insert_pfn(vma, addr, pfn, prot);
 }
-EXPORT_SYMBOL(vm_insert_mixed);
+EXPORT_SYMBOL(vm_insert_mixed_prot);
 
 /*
  * maps a range of physical memory into the requested pages. the old
-- 
1.9.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
