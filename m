Received: from cthulhu.engr.sgi.com (cthulhu.engr.sgi.com [192.26.80.2])
	by omx2.sgi.com (8.12.11/8.12.9/linux-outbound_gateway-1.1) with ESMTP id j620Wgl1017174
	for <linux-mm@kvack.org>; Fri, 1 Jul 2005 17:32:42 -0700
Date: Fri, 1 Jul 2005 15:41:29 -0700 (PDT)
From: Ray Bryant <raybry@sgi.com>
Message-Id: <20050701224129.542.64783.62715@jackhammer.engr.sgi.com>
In-Reply-To: <20050701224038.542.60558.44109@jackhammer.engr.sgi.com>
References: <20050701224038.542.60558.44109@jackhammer.engr.sgi.com>
Subject: [PATCH 2.6.13-rc1 8/11] mm: manual page migration-rc4 -- sys_migrate_pages-migration-selection-rc4.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>, Dave Hansen <haveblue@us.ibm.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andi Kleen <ak@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, Nathan Scott <nathans@sgi.com>, Ray Bryant <raybry@austin.rr.com>, lhms-devel@lists.sourceforge.net, Ray Bryant <raybry@sgi.com>, Paul Jackson <pj@sgi.com>, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

This patch allows a process to override the default kernel memory
migration policy (invoked via migrate_pages()) on a mapped file
by mapped file basis.

The default policy is to migrate all anonymous VMAs and all other
VMAs that have the VM_WRITE bit set.  (See the patch:
	sys_migrate_pages-migration-selection-rc4.patch
for details on how the default policy is implemented.)

This policy does not cause the program executable or any mapped
user data files that are mapped R/O to be migrated.  These problems
can be detected and fixed in the user-level migration application,
but that user code needs an interface to do the "fix".  This patch
supplies that interface via an extension to the mbind() system call.

The interface is as follows:

mbind(start, length, 0, 0, 0, MPOL_MF_DO_MMIGRATE)
mbind(start, length, 0, 0, 0, MPOL_MF_DO_NOT_MMIGRATE)

These calls override the default kernel policy in
favor of the policy specified.  These call cause the bits
AS_DO_MMIGRATTE (or AS_DO_NOT_MMIGRATE) to be set in the
memory object pointed to by the VMA at the specified addresses
in the current process's address space.  Setting such a "deep"
attribute is required so that the modification can be seen by
all address spaces that map the object.

The bits set by the above call are "sticky" in the sense that
they will remain set so long as the memory object exists.  To
return the migration policy for that memory object to its
default setting is done by the following system call:

mbind(start, length, 0, 0, 0, MPOL_MF_MMIGRATE_DEFAULT)

The system call:

get_mempolicy(&policy, NULL, 0, (int *)start, (long) MPOL_F_MMIGRATE)

returns the policy migration bits from the memory object in the bottom
two bits of "policy".

Typical use by the user-level manual page migration code would
be to:

(1)  Identify the file name whose migration policy needs modified.
(2)  Open and mmap() the file into the current address space.
(3)  Issue the appropriate mbind() call from the above list.
(4)  (Assuming a successful return), unmap() and close the file.

Signed-off-by: Ray Bryant <raybry@sgi.com>

 mmigrate.c |   31 ++++++++++++++++++++++---------
 1 files changed, 22 insertions(+), 9 deletions(-)

Index: linux-2.6.12-rc5-mhp1-page-migration-export/mm/mmigrate.c
===================================================================
--- linux-2.6.12-rc5-mhp1-page-migration-export.orig/mm/mmigrate.c	2005-06-24 07:40:32.000000000 -0700
+++ linux-2.6.12-rc5-mhp1-page-migration-export/mm/mmigrate.c	2005-06-24 07:44:12.000000000 -0700
@@ -601,25 +601,38 @@ migrate_vma(struct task_struct *task, st
 	unsigned long vaddr;
 	int rc, count = 0, nr_busy;
 	LIST_HEAD(pglist);
+	struct address_space *as = NULL;
 
-	/* can't migrate mlock()'d pages */
-	if (vma->vm_flags & VM_LOCKED)
+	/* can't migrate these kinds of VMAs */
+	if ((vma->vm_flags & VM_LOCKED) || (vma->vm_flags & VM_IO))
 		return 0;
 
+ 	/* we always migrate anonymous pages */
+ 	if (!vma->vm_file)
+ 		goto do_migrate;
+ 	as = vma->vm_file->f_mapping;
+ 	/* we have to have both AS_DO_MMIGRATE and AS_DO_MOT_MMIGRATE to
+ 	 * give user space full ability to override the kernel's default
+ 	 * migration decisions */
+ 	if (test_bit(AS_DO_MMIGRATE, &as->flags))
+ 		goto do_migrate;
+ 	if (test_bit(AS_DO_NOT_MMIGRATE, &as->flags))
+ 		return 0;
+ 	if (!(vma->vm_flags & VM_WRITE))
+		return 0;
+
+do_migrate:
 	/* update the vma mempolicy, if needed */
 	rc = migrate_vma_policy(vma, node_map);
 	if (rc < 0)
 		return rc;
-	/*
-	 * gather all of the pages to be migrated from this vma into pglist
-	 */
+
+	/* gather all of the pages to be migrated from this vma into pglist */
 	spin_lock(&mm->page_table_lock);
  	for (vaddr = vma->vm_start; vaddr < vma->vm_end; vaddr += PAGE_SIZE) {
 		page = follow_page(mm, vaddr, 0);
-		/*
-		 * follow_page has been known to return pages with zero mapcount
-		 * and NULL mapping.  Skip those pages as well
-		 */
+		/* follow_page has been known to return pages with zero mapcount
+		 * and NULL mapping.  Skip those pages as well */
 		if (!page || !page_mapcount(page))
 			continue;
 

-- 
Best Regards,
Ray
-----------------------------------------------
Ray Bryant                       raybry@sgi.com
The box said: "Requires Windows 98 or better",
           so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
