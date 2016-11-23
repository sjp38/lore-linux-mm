Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 85EBC6B0268
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 13:45:12 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 3so47680245pgd.3
        for <linux-mm@kvack.org>; Wed, 23 Nov 2016 10:45:12 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id c1si35034433pfl.126.2016.11.23.10.45.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Nov 2016 10:45:11 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH 5/6] dax: add tracepoints to dax_pmd_load_hole()
Date: Wed, 23 Nov 2016 11:44:21 -0700
Message-Id: <1479926662-21718-6-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1479926662-21718-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1479926662-21718-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

Add tracepoints to dax_pmd_load_hole(), following the same logging
conventions as the tracepoints in dax_iomap_pmd_fault().

Here is an example PMD fault showing the new tracepoints:

read_big-1393  [007] ....    32.133809: dax_pmd_fault: shared mapping read
address 0x10400000 vm_start 0x10200000 vm_end 0x10600000 pgoff 0x200
max_pgoff 0x1400

read_big-1393  [007] ....    32.134067: dax_pmd_load_hole: shared mapping
read address 0x10400000 zero_page ffffea0002b98000 radix_entry 0x1e

read_big-1393  [007] ....    32.134069: dax_pmd_fault_done: shared mapping
read address 0x10400000 vm_start 0x10200000 vm_end 0x10600000 pgoff 0x200
max_pgoff 0x1400 NOPAGE

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/dax.c                      | 13 +++++++++----
 include/trace/events/fs_dax.h | 32 ++++++++++++++++++++++++++++++++
 2 files changed, 41 insertions(+), 4 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 1aa7616..2824414 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -1269,32 +1269,37 @@ static int dax_pmd_load_hole(struct vm_area_struct *vma, pmd_t *pmd,
 	struct address_space *mapping = vma->vm_file->f_mapping;
 	unsigned long pmd_addr = address & PMD_MASK;
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
+	trace_dax_pmd_load_hole(vma, address, zero_page, ret);
 	return VM_FAULT_NOPAGE;
+
+fallback:
+	trace_dax_pmd_load_hole_fallback(vma, address, zero_page, ret);
+	return VM_FAULT_FALLBACK;
 }
 
 int dax_iomap_pmd_fault(struct vm_area_struct *vma, unsigned long address,
diff --git a/include/trace/events/fs_dax.h b/include/trace/events/fs_dax.h
index f9ed4eb..8814b1a 100644
--- a/include/trace/events/fs_dax.h
+++ b/include/trace/events/fs_dax.h
@@ -54,6 +54,38 @@ DEFINE_EVENT(dax_pmd_fault_class, name, \
 DEFINE_PMD_FAULT_EVENT(dax_pmd_fault);
 DEFINE_PMD_FAULT_EVENT(dax_pmd_fault_done);
 
+DECLARE_EVENT_CLASS(dax_pmd_load_hole_class,
+	TP_PROTO(struct vm_area_struct *vma, unsigned long address,
+		struct page *zero_page, void *radix_entry),
+	TP_ARGS(vma, address, zero_page, radix_entry),
+	TP_STRUCT__entry(
+		__field(unsigned long, vm_flags)
+		__field(unsigned long, address)
+		__field(struct page *, zero_page)
+		__field(void *, radix_entry)
+	),
+	TP_fast_assign(
+		__entry->vm_flags = vma->vm_flags;
+		__entry->address = address;
+		__entry->zero_page = zero_page;
+		__entry->radix_entry = radix_entry;
+	),
+	TP_printk("%s mapping read address %#lx zero_page %p radix_entry %#lx",
+		__entry->vm_flags & VM_SHARED ? "shared" : "private",
+		__entry->address,
+		__entry->zero_page,
+		(unsigned long)__entry->radix_entry
+	)
+)
+
+#define DEFINE_PMD_LOAD_HOLE_EVENT(name) \
+DEFINE_EVENT(dax_pmd_load_hole_class, name, \
+	TP_PROTO(struct vm_area_struct *vma, unsigned long address, \
+		struct page *zero_page, void *radix_entry), \
+	TP_ARGS(vma, address, zero_page, radix_entry))
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
