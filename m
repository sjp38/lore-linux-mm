Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 51EA05F0001
	for <linux-mm@kvack.org>; Sat, 11 Apr 2009 08:05:23 -0400 (EDT)
References: <m1skkf761y.fsf@fess.ebiederm.org>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 11 Apr 2009 05:05:23 -0700
In-Reply-To: <m1skkf761y.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Sat\, 11 Apr 2009 05\:01\:29 -0700")
Message-ID: <m1iqlb75vg.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Subject: [RFC][PATCH 2/9] mm: Implement generic support for revoking a mapping.
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>


Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/mm.h |    2 ++
 mm/memory.c        |    9 +++++++++
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 96d8342..3fcbb8e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -807,6 +807,8 @@ static inline void unmap_shared_mapping_range(struct address_space *mapping,
 
 extern int vmtruncate(struct inode * inode, loff_t offset);
 extern int vmtruncate_range(struct inode * inode, loff_t offset, loff_t end);
+
+extern struct vm_operations_struct revoked_vm_ops;
 extern void remap_file_mappings(struct file *file, struct vm_operations_struct *vm_ops);
 
 #ifdef CONFIG_MMU
diff --git a/mm/memory.c b/mm/memory.c
index dcd0a3c..f68c84e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2378,6 +2378,15 @@ out:
 	spin_lock(&mapping->i_mmap_lock);
 }
 
+static int revoked_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
+{
+	return VM_FAULT_SIGBUS;
+}
+
+struct vm_operations_struct revoked_vm_ops = {
+	.fault	= revoked_fault,
+};
+
 void remap_file_mappings(struct file *file, struct vm_operations_struct *vm_ops)
 {
 	/* After file->f_ops has been changed update the vmas */
-- 
1.6.1.2.350.g88cc

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
