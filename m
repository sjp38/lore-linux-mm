Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B07376B0007
	for <linux-mm@kvack.org>; Sat, 21 Apr 2018 13:03:47 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id n5so3560281pgq.3
        for <linux-mm@kvack.org>; Sat, 21 Apr 2018 10:03:47 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z3sor2474323pfe.102.2018.04.21.10.03.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 21 Apr 2018 10:03:46 -0700 (PDT)
Date: Sat, 21 Apr 2018 22:35:40 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH] mm: memory: Introduce new vmf_insert_mixed_mkwrite
Message-ID: <20180421170540.GA17849@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com, minchan@kernel.org, ying.huang@intel.com, ross.zwisler@linux.intel.com, willy@infradead.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org

vm_insert_mixed_mkwrite() has inefficiency when it
returns err, driver has to convert err to vm_fault_t
type. With new vmf_insert_mixed_mkwrite we can handle
this limitation.

As of now vm_insert_mixed_mkwrite() is only getting
invoked from fs/dax.c, so this change has to go first
in linus tree before changes in dax.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
---
 include/linux/mm.h |  4 ++--
 mm/memory.c        | 15 +++++++++++----
 2 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1ac1f06..9fe441c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2423,8 +2423,8 @@ int vm_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn, pgprot_t pgprot);
 int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 			pfn_t pfn);
-int vm_insert_mixed_mkwrite(struct vm_area_struct *vma, unsigned long addr,
-			pfn_t pfn);
+vm_fault_t vmf_insert_mixed_mkwrite(struct vm_area_struct *vma,
+		unsigned long addr, pfn_t pfn);
 int vm_iomap_memory(struct vm_area_struct *vma, phys_addr_t start, unsigned long len);
 
 static inline vm_fault_t vmf_insert_page(struct vm_area_struct *vma,
diff --git a/mm/memory.c b/mm/memory.c
index 01f5464..721cfd5 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1955,12 +1955,19 @@ int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 }
 EXPORT_SYMBOL(vm_insert_mixed);
 
-int vm_insert_mixed_mkwrite(struct vm_area_struct *vma, unsigned long addr,
-			pfn_t pfn)
+vm_fault_t vmf_insert_mixed_mkwrite(struct vm_area_struct *vma,
+		unsigned long addr, pfn_t pfn)
 {
-	return __vm_insert_mixed(vma, addr, pfn, true);
+	int err;
+
+	err =  __vm_insert_mixed(vma, addr, pfn, true);
+	if (err == -ENOMEM)
+		return VM_FAULT_OOM;
+	if (err < 0 && err != -EBUSY)
+		return VM_FAULT_SIGBUS;
+	return VM_FAULT_NOPAGE;
 }
-EXPORT_SYMBOL(vm_insert_mixed_mkwrite);
+EXPORT_SYMBOL(vmf_insert_mixed_mkwrite);
 
 /*
  * maps a range of physical memory into the requested pages. the old
-- 
1.9.1
