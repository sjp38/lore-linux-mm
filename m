Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6E4386B46DF
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 10:57:39 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id l65-v6so1264423pge.17
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 07:57:39 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y186-v6si1170766pfg.246.2018.08.28.07.57.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 Aug 2018 07:57:38 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 01/10] cramfs: Convert to use vmf_insert_mixed
Date: Tue, 28 Aug 2018 07:57:19 -0700
Message-Id: <20180828145728.11873-2-willy@infradead.org>
In-Reply-To: <20180828145728.11873-1-willy@infradead.org>
References: <20180828145728.11873-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

cramfs is the only remaining user of vm_insert_mixed; convert it.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 fs/cramfs/inode.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/cramfs/inode.c b/fs/cramfs/inode.c
index f408994fc632..b72449c19cd1 100644
--- a/fs/cramfs/inode.c
+++ b/fs/cramfs/inode.c
@@ -417,10 +417,15 @@ static int cramfs_physmem_mmap(struct file *file, struct vm_area_struct *vma)
 		 */
 		int i;
 		vma->vm_flags |= VM_MIXEDMAP;
-		for (i = 0; i < pages && !ret; i++) {
+		for (i = 0; i < pages; i++) {
+			vm_fault_t vmf;
 			unsigned long off = i * PAGE_SIZE;
 			pfn_t pfn = phys_to_pfn_t(address + off, PFN_DEV);
-			ret = vm_insert_mixed(vma, vma->vm_start + off, pfn);
+			vmf = vmf_insert_mixed(vma, vma->vm_start + off, pfn);
+			if (vmf & VM_FAULT_ERROR) {
+				pages = i;
+				break;
+			}
 		}
 	}
 
-- 
2.18.0
