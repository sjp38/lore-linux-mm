Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2DC8B6B026B
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 13:45:14 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id x23so47590310pgx.6
        for <linux-mm@kvack.org>; Wed, 23 Nov 2016 10:45:14 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id c1si35034433pfl.126.2016.11.23.10.45.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Nov 2016 10:45:13 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH 6/6] dax: add tracepoints to dax_pmd_insert_mapping()
Date: Wed, 23 Nov 2016 11:44:22 -0700
Message-Id: <1479926662-21718-7-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1479926662-21718-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1479926662-21718-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

Add tracepoints to dax_pmd_insert_mapping(), following the same logging
conventions as the tracepoints in dax_iomap_pmd_fault().

Here is an example PMD fault showing the new tracepoints:

big-1544  [006] ....    48.153479: dax_pmd_fault: shared mapping write
address 0x10505000 vm_start 0x10200000 vm_end 0x10700000 pgoff 0x200
max_pgoff 0x1400

big-1544  [006] ....    48.155230: dax_pmd_insert_mapping: shared mapping
write address 0x10505000 length 0x200000 pfn 0x100600 DEV|MAP radix_entry
0xc000e

big-1544  [006] ....    48.155266: dax_pmd_fault_done: shared mapping write
address 0x10505000 vm_start 0x10200000 vm_end 0x10700000 pgoff 0x200
max_pgoff 0x1400 NOPAGE

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/dax.c                      | 10 +++++++---
 include/linux/pfn_t.h         |  6 ++++++
 include/trace/events/fs_dax.h | 42 ++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 55 insertions(+), 3 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 2824414..d6ba4a3 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -1236,10 +1236,10 @@ static int dax_pmd_insert_mapping(struct vm_area_struct *vma, pmd_t *pmd,
 		.size = PMD_SIZE,
 	};
 	long length = dax_map_atomic(bdev, &dax);
-	void *ret;
+	void *ret = NULL;
 
 	if (length < 0) /* dax_map_atomic() failed */
-		return VM_FAULT_FALLBACK;
+		goto fallback;
 	if (length < PMD_SIZE)
 		goto unmap_fallback;
 	if (pfn_t_to_pfn(dax.pfn) & PG_PMD_COLOUR)
@@ -1252,13 +1252,17 @@ static int dax_pmd_insert_mapping(struct vm_area_struct *vma, pmd_t *pmd,
 	ret = dax_insert_mapping_entry(mapping, vmf, *entryp, dax.sector,
 			RADIX_DAX_PMD);
 	if (IS_ERR(ret))
-		return VM_FAULT_FALLBACK;
+		goto fallback;
 	*entryp = ret;
 
+	trace_dax_pmd_insert_mapping(vma, address, write, length, dax.pfn, ret);
 	return vmf_insert_pfn_pmd(vma, address, pmd, dax.pfn, write);
 
 unmap_fallback:
 	dax_unmap_atomic(bdev, &dax);
+fallback:
+	trace_dax_pmd_insert_mapping_fallback(vma, address, write, length,
+			dax.pfn, ret);
 	return VM_FAULT_FALLBACK;
 }
 
diff --git a/include/linux/pfn_t.h b/include/linux/pfn_t.h
index a3d90b9..033fc7b 100644
--- a/include/linux/pfn_t.h
+++ b/include/linux/pfn_t.h
@@ -15,6 +15,12 @@
 #define PFN_DEV (1ULL << (BITS_PER_LONG_LONG - 3))
 #define PFN_MAP (1ULL << (BITS_PER_LONG_LONG - 4))
 
+#define PFN_FLAGS_TRACE \
+	{ PFN_SG_CHAIN,	"SG_CHAIN" }, \
+	{ PFN_SG_LAST,	"SG_LAST" }, \
+	{ PFN_DEV,	"DEV" }, \
+	{ PFN_MAP,	"MAP" }
+
 static inline pfn_t __pfn_to_pfn_t(unsigned long pfn, u64 flags)
 {
 	pfn_t pfn_t = { .val = pfn | (flags & PFN_FLAGS_MASK), };
diff --git a/include/trace/events/fs_dax.h b/include/trace/events/fs_dax.h
index 8814b1a..a03f820 100644
--- a/include/trace/events/fs_dax.h
+++ b/include/trace/events/fs_dax.h
@@ -87,6 +87,48 @@ DEFINE_EVENT(dax_pmd_load_hole_class, name, \
 DEFINE_PMD_LOAD_HOLE_EVENT(dax_pmd_load_hole);
 DEFINE_PMD_LOAD_HOLE_EVENT(dax_pmd_load_hole_fallback);
 
+DECLARE_EVENT_CLASS(dax_pmd_insert_mapping_class,
+	TP_PROTO(struct vm_area_struct *vma, unsigned long address, int write,
+		long length, pfn_t pfn, void *radix_entry),
+	TP_ARGS(vma, address, write, length, pfn, radix_entry),
+	TP_STRUCT__entry(
+		__field(unsigned long, vm_flags)
+		__field(unsigned long, address)
+		__field(int, write)
+		__field(long, length)
+		__field(u64, pfn_val)
+		__field(void *, radix_entry)
+	),
+	TP_fast_assign(
+		__entry->vm_flags = vma->vm_flags;
+		__entry->address = address;
+		__entry->write = write;
+		__entry->length = length;
+		__entry->pfn_val = pfn.val;
+		__entry->radix_entry = radix_entry;
+	),
+	TP_printk("%s mapping %s address %#lx length %#lx pfn %#llx %s"
+		" radix_entry %#lx",
+		__entry->vm_flags & VM_SHARED ? "shared" : "private",
+		__entry->write ? "write" : "read",
+		__entry->address,
+		__entry->length,
+		__entry->pfn_val & ~PFN_FLAGS_MASK,
+		__print_flags(__entry->pfn_val & PFN_FLAGS_MASK, "|",
+			PFN_FLAGS_TRACE),
+		(unsigned long)__entry->radix_entry
+	)
+)
+
+#define DEFINE_PMD_INSERT_MAPPING_EVENT(name) \
+DEFINE_EVENT(dax_pmd_insert_mapping_class, name, \
+	TP_PROTO(struct vm_area_struct *vma, unsigned long address, \
+		int write, long length, pfn_t pfn, void *radix_entry), \
+	TP_ARGS(vma, address, write, length, pfn, radix_entry))
+
+DEFINE_PMD_INSERT_MAPPING_EVENT(dax_pmd_insert_mapping);
+DEFINE_PMD_INSERT_MAPPING_EVENT(dax_pmd_insert_mapping_fallback);
+
 #endif /* _TRACE_FS_DAX_H */
 
 /* This part must be outside protection */
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
