Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id ECAA66B0253
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 14:28:19 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 194so162465499pgd.7
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 11:28:19 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id v22si4935177pfj.172.2017.02.07.11.28.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Feb 2017 11:28:18 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH] mm: Tighten up the fault path a little
Date: Tue,  7 Feb 2017 11:28:12 -0800
Message-Id: <20170207192812.5281-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

The round_up() macro generates a couple of unnecessary instructions
in this usage:

    48cd:       49 8b 47 50             mov    0x50(%r15),%rax
    48d1:       48 83 e8 01             sub    $0x1,%rax
    48d5:       48 0d ff 0f 00 00       or     $0xfff,%rax
    48db:       48 83 c0 01             add    $0x1,%rax
    48df:       48 c1 f8 0c             sar    $0xc,%rax
    48e3:       48 39 c3                cmp    %rax,%rbx
    48e6:       72 2e                   jb     4916 <filemap_fault+0x96>

If we change round_up() to ((x) + __round_mask(x, y)) & ~__round_mask(x, y)
then GCC can see through it and remove the mask (because that would be
dead code given the subsequent shift):

    48cd:       49 8b 47 50             mov    0x50(%r15),%rax
    48d1:       48 05 ff 0f 00 00       add    $0xfff,%rax
    48d7:       48 c1 e8 0c             shr    $0xc,%rax
    48db:       48 39 c3                cmp    %rax,%rbx
    48de:       72 2e                   jb     490e <filemap_fault+0x8e>

But that's problematic because we'd evaluate 'y' twice.  Converting
round_up into an inline function prevents it from being used in other
definitions.  The easiest thing to do is just change these three usages
of round_up to use DIV_ROUND_UP.  Also add an unlikely() because GCC's
heuristic is wrong in this case.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 mm/filemap.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 9d91622371d9..acd0fc7a4f62 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2191,12 +2191,12 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	struct file_ra_state *ra = &file->f_ra;
 	struct inode *inode = mapping->host;
 	pgoff_t offset = vmf->pgoff;
+	pgoff_t max_off;
 	struct page *page;
-	loff_t size;
 	int ret = 0;
 
-	size = round_up(i_size_read(inode), PAGE_SIZE);
-	if (offset >= size >> PAGE_SHIFT)
+	max_off = DIV_ROUND_UP(i_size_read(inode), PAGE_SIZE);
+	if (unlikely(offset >= max_off))
 		return VM_FAULT_SIGBUS;
 
 	/*
@@ -2245,8 +2245,8 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	 * Found the page and have a reference on it.
 	 * We must recheck i_size under page lock.
 	 */
-	size = round_up(i_size_read(inode), PAGE_SIZE);
-	if (unlikely(offset >= size >> PAGE_SHIFT)) {
+	max_off = DIV_ROUND_UP(i_size_read(inode), PAGE_SIZE);
+	if (unlikely(offset >= max_off)) {
 		unlock_page(page);
 		put_page(page);
 		return VM_FAULT_SIGBUS;
@@ -2312,7 +2312,7 @@ void filemap_map_pages(struct vm_fault *vmf,
 	struct file *file = vmf->vma->vm_file;
 	struct address_space *mapping = file->f_mapping;
 	pgoff_t last_pgoff = start_pgoff;
-	loff_t size;
+	unsigned long max_idx;
 	struct page *head, *page;
 
 	rcu_read_lock();
@@ -2358,8 +2358,8 @@ void filemap_map_pages(struct vm_fault *vmf,
 		if (page->mapping != mapping || !PageUptodate(page))
 			goto unlock;
 
-		size = round_up(i_size_read(mapping->host), PAGE_SIZE);
-		if (page->index >= size >> PAGE_SHIFT)
+		max_idx = DIV_ROUND_UP(i_size_read(mapping->host), PAGE_SIZE);
+		if (page->index >= max_idx)
 			goto unlock;
 
 		if (file->f_ra.mmap_miss > 0)
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
