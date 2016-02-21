Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8AEA66B0253
	for <linux-mm@kvack.org>; Sun, 21 Feb 2016 12:06:19 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id c200so140114479wme.0
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 09:06:19 -0800 (PST)
Received: from mail-wm0-x22e.google.com (mail-wm0-x22e.google.com. [2a00:1450:400c:c09::22e])
        by mx.google.com with ESMTPS id s10si27416538wmf.41.2016.02.21.09.06.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Feb 2016 09:06:18 -0800 (PST)
Received: by mail-wm0-x22e.google.com with SMTP id b205so127416391wmb.1
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 09:06:18 -0800 (PST)
Message-ID: <56C9EE87.2080106@plexistor.com>
Date: Sun, 21 Feb 2016 19:06:15 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: [RFC 2/2] dax: Support MAP_PMEM_AWARE mmap flag
References: <56C9EDCF.8010007@plexistor.com>
In-Reply-To: <56C9EDCF.8010007@plexistor.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dave Chinner <david@fromorbit.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, Arnd Bergmann <arnd@arndb.de>


It is possible that applications like nvml is aware that
it is working with pmem, and is already doing movnt instructions
and cl_flushes to keep data persistent.

It is not enough that these applications do not call m/fsync,
in current code we already pay extra locking and resources in
the radix tree on every write page-fault even before we call
m/fsync.

Such application can do an mmap call with the new MAP_PMEM_AWARE
flag, and for these mmap pointers flushing will not be maintained.
This will not hurt any other legacy applications that do regular
mmap and memcpy for these applications even if working on the same
file, even legacy libraries in the same process space that do mmap
calls will have their pagefaults accounted for. Since this is per
vma.

CC: Dan Williams <dan.j.williams@intel.com>
CC: Ross Zwisler <ross.zwisler@linux.intel.com>
CC: Matthew Wilcox <willy@linux.intel.com>
CC: linux-nvdimm <linux-nvdimm@ml01.01.org>
Signed-off-by: Boaz Harrosh <boaz@plexistor.com>
---
 fs/dax.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 64e3fc1..f8aec85 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -579,10 +579,12 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
 	}
 	dax_unmap_atomic(bdev, &dax);
 
-	error = dax_radix_entry(mapping, vmf->pgoff, dax.sector, false,
+	if (!(vma->vm_flags & VM_PMEM_AWARE)) {
+		error = dax_radix_entry(mapping, vmf->pgoff, dax.sector, false,
 			vmf->flags & FAULT_FLAG_WRITE);
-	if (error)
-		goto out;
+		if (error)
+			goto out;
+	}
 
 	error = vm_insert_mixed_rw(vma, vaddr, dax.pfn,
 				     0 != (vmf->flags & FAULT_FLAG_WRITE));
@@ -984,7 +986,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 		 * entry completely on the initial read and just wait until
 		 * the write to insert a dirty entry.
 		 */
-		if (write) {
+		if (write && !(vma->vm_flags & VM_PMEM_AWARE)) {
 			error = dax_radix_entry(mapping, pgoff, dax.sector,
 					true, true);
 			if (error) {
@@ -1065,7 +1067,9 @@ int dax_pfn_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	 * saves us from having to make a call to get_block() here to look
 	 * up the sector.
 	 */
-	dax_radix_entry(file->f_mapping, vmf->pgoff, NO_SECTOR, false, true);
+	if (!(vma->vm_flags & VM_PMEM_AWARE))
+		dax_radix_entry(file->f_mapping, vmf->pgoff, NO_SECTOR, false,
+				true);
 	return VM_FAULT_NOPAGE;
 }
 EXPORT_SYMBOL_GPL(dax_pfn_mkwrite);
-- 
1.9.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
