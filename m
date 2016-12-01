Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 56C82280254
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 11:38:04 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id q10so104785324pgq.7
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 08:38:04 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id 1si769098pll.154.2016.12.01.08.38.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 08:38:03 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v3 4/5] dax: add tracepoints to dax_pmd_load_hole()
Date: Thu,  1 Dec 2016 09:37:50 -0700
Message-Id: <1480610271-23699-5-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1480610271-23699-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1480610271-23699-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

Add tracepoints to dax_pmd_load_hole(), following the same logging
conventions as the tracepoints in dax_iomap_pmd_fault().

Here is an example PMD fault showing the new tracepoints:

read_big-1478  [004] ....   238.242188: xfs_filemap_pmd_fault: dev 259:0
ino 0x1003

read_big-1478  [004] ....   238.242191: dax_pmd_fault: dev 259:0 ino 0x1003
shared ALLOW_RETRY|KILLABLE|USER address 0x10400000 vm_start 0x10200000
vm_end 0x10600000 pgoff 0x200 max_pgoff 0x1400

read_big-1478  [004] ....   238.242390: dax_pmd_load_hole: dev 259:0 ino
0x1003 shared address 0x10400000 zero_page ffffea0002c20000 radix_entry
0x1e

read_big-1478  [004] ....   238.242392: dax_pmd_fault_done: dev 259:0 ino
0x1003 shared ALLOW_RETRY|KILLABLE|USER address 0x10400000 vm_start
0x10200000 vm_end 0x10600000 pgoff 0x200 max_pgoff 0x1400 NOPAGE

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 fs/dax.c                      | 14 ++++++++++----
 include/trace/events/fs_dax.h | 42 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 52 insertions(+), 4 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 360995a..61b3080 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -1269,33 +1269,39 @@ static int dax_pmd_load_hole(struct vm_area_struct *vma, pmd_t *pmd,
 {
 	struct address_space *mapping = vma->vm_file->f_mapping;
 	unsigned long pmd_addr = address & PMD_MASK;
+	struct inode *inode = mapping->host;
 	struct page *zero_page;
+	void *ret = NULL;
 	spinlock_t *ptl;
 	pmd_t pmd_entry;
-	void *ret;
 
 	zero_page = mm_get_huge_zero_page(vma->vm_mm);
 
 	if (unlikely(!zero_page))
-		return VM_FAULT_FALLBACK;
+		goto fallback;
 
 	ret = dax_insert_mapping_entry(mapping, vmf, *entryp, 0,
 			RADIX_DAX_PMD | RADIX_DAX_HZP);
 	if (IS_ERR(ret))
-		return VM_FAULT_FALLBACK;
+		goto fallback;
 	*entryp = ret;
 
 	ptl = pmd_lock(vma->vm_mm, pmd);
 	if (!pmd_none(*pmd)) {
 		spin_unlock(ptl);
-		return VM_FAULT_FALLBACK;
+		goto fallback;
 	}
 
 	pmd_entry = mk_pmd(zero_page, vma->vm_page_prot);
 	pmd_entry = pmd_mkhuge(pmd_entry);
 	set_pmd_at(vma->vm_mm, pmd_addr, pmd, pmd_entry);
 	spin_unlock(ptl);
+	trace_dax_pmd_load_hole(inode, vma, address, zero_page, ret);
 	return VM_FAULT_NOPAGE;
+
+fallback:
+	trace_dax_pmd_load_hole_fallback(inode, vma, address, zero_page, ret);
+	return VM_FAULT_FALLBACK;
 }
 
 int dax_iomap_pmd_fault(struct vm_area_struct *vma, unsigned long address,
diff --git a/include/trace/events/fs_dax.h b/include/trace/events/fs_dax.h
index 58b0b56..43f1263 100644
--- a/include/trace/events/fs_dax.h
+++ b/include/trace/events/fs_dax.h
@@ -61,6 +61,48 @@ DEFINE_EVENT(dax_pmd_fault_class, name, \
 DEFINE_PMD_FAULT_EVENT(dax_pmd_fault);
 DEFINE_PMD_FAULT_EVENT(dax_pmd_fault_done);
 
+DECLARE_EVENT_CLASS(dax_pmd_load_hole_class,
+	TP_PROTO(struct inode *inode, struct vm_area_struct *vma,
+		unsigned long address, struct page *zero_page,
+		void *radix_entry),
+	TP_ARGS(inode, vma, address, zero_page, radix_entry),
+	TP_STRUCT__entry(
+		__field(unsigned long, ino)
+		__field(unsigned long, vm_flags)
+		__field(unsigned long, address)
+		__field(struct page *, zero_page)
+		__field(void *, radix_entry)
+		__field(dev_t, dev)
+	),
+	TP_fast_assign(
+		__entry->dev = inode->i_sb->s_dev;
+		__entry->ino = inode->i_ino;
+		__entry->vm_flags = vma->vm_flags;
+		__entry->address = address;
+		__entry->zero_page = zero_page;
+		__entry->radix_entry = radix_entry;
+	),
+	TP_printk("dev %d:%d ino %#lx %s address %#lx zero_page %p "
+			"radix_entry %#lx",
+		MAJOR(__entry->dev),
+		MINOR(__entry->dev),
+		__entry->ino,
+		__entry->vm_flags & VM_SHARED ? "shared" : "private",
+		__entry->address,
+		__entry->zero_page,
+		(unsigned long)__entry->radix_entry
+	)
+)
+
+#define DEFINE_PMD_LOAD_HOLE_EVENT(name) \
+DEFINE_EVENT(dax_pmd_load_hole_class, name, \
+	TP_PROTO(struct inode *inode, struct vm_area_struct *vma, \
+		unsigned long address, struct page *zero_page, \
+		void *radix_entry), \
+	TP_ARGS(inode, vma, address, zero_page, radix_entry))
+
+DEFINE_PMD_LOAD_HOLE_EVENT(dax_pmd_load_hole);
+DEFINE_PMD_LOAD_HOLE_EVENT(dax_pmd_load_hole_fallback);
 
 #endif /* _TRACE_FS_DAX_H */
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
