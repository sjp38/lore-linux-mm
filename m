Date: Wed, 22 Jun 2005 09:39:48 -0700 (PDT)
From: Ray Bryant <raybry@sgi.com>
Message-Id: <20050622163947.25515.52176.79100@tomahawk.engr.sgi.com>
In-Reply-To: <20050622163908.25515.49944.65860@tomahawk.engr.sgi.com>
References: <20050622163908.25515.49944.65860@tomahawk.engr.sgi.com>
Subject: [PATCH 2.6.12-rc5 6/10] mm: manual page migration-rc3 -- add-mempolicy-control-rc3.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>, Andi Kleen <ak@suse.de>, Dave Hansen <haveblue@us.ibm.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Christoph Hellwig <hch@infradead.org>, Ray Bryant <raybry@austin.rr.com>, linux-mm <linux-mm@kvack.org>, lhms-devel@lists.sourceforge.net, Ray Bryant <raybry@sgi.com>, Paul Jackson <pj@sgi.com>, Nathan Scott <nathans@sgi.com>
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

Note well that this interface allows the memory migration process
to modify the migration policy on a file-by-file basis for all proceses
that mmap() the specified file.  This has two implications:

(1)  All VMAs that map to the specified memory object will have
     the same migration policy applied.   There is no way to
     specify a distinct migration policy for one of the VMAs that
     map the file.

(2)  The migration policy for anonymous memory cannot be changed,
     since there is no memory object (where the migration policy
     bits are stored) in that case.

To date, we have yet to identify any case where these restrictions
would need to be overcome in the manual page migration case.

Signed-off-by:  Ray Bryant <raybry@sgi.com>
--

 include/linux/mempolicy.h |   18 +++++++++
 include/linux/pagemap.h   |    4 ++
 mm/mempolicy.c            |   84 ++++++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 103 insertions(+), 3 deletions(-)

Index: linux-2.6.12-rc5-mhp1-page-migration-export/mm/mempolicy.c
===================================================================
--- linux-2.6.12-rc5-mhp1-page-migration-export.orig/mm/mempolicy.c	2005-06-13 11:47:46.000000000 -0700
+++ linux-2.6.12-rc5-mhp1-page-migration-export/mm/mempolicy.c	2005-06-13 12:20:12.000000000 -0700
@@ -76,6 +76,7 @@
 #include <linux/init.h>
 #include <linux/compat.h>
 #include <linux/mempolicy.h>
+#include <linux/pagemap.h>
 #include <asm/tlbflush.h>
 #include <asm/uaccess.h>
 
@@ -354,6 +355,54 @@ static int mbind_range(struct vm_area_st
 	return err;
 }
 
+static int mbind_migration_policy(struct mm_struct *mm, unsigned long start,
+				  unsigned long end, unsigned flags)
+{
+	struct vm_area_struct *first, *vma;
+	struct address_space *as;
+	int err = 0;
+
+	/* only one of these bits may be set */
+	if (hweight_long(flags & (MPOL_MF_MMIGRATE_MASK)) > 1)
+		return -EINVAL;
+
+	down_read(&mm->mmap_sem);
+	first = find_vma(mm, start);
+	if (!first) {
+		err = -EFAULT;
+		goto out;
+	}
+	for (vma = first; vma && vma->vm_start < end; vma = vma->vm_next) {
+		if (!vma->vm_file)
+			continue;
+		as = vma->vm_file->f_mapping;
+		BUG_ON(!as);
+		switch (flags & MPOL_MF_MMIGRATE_MASK) {
+		case MPOL_MF_DO_MMIGRATE:
+			/* only one of these bits may be set */
+			if (test_bit(AS_DO_NOT_MMIGRATE, &as->flags))
+				clear_bit(AS_DO_NOT_MMIGRATE, &as->flags);
+			set_bit(AS_DO_MMIGRATE, &as->flags);
+			break;
+		case MPOL_MF_DO_NOT_MMIGRATE:
+			/* only one of these bits may be set */
+			if (test_bit(AS_DO_MMIGRATE, &as->flags))
+				clear_bit(AS_DO_MMIGRATE, &as->flags);
+			set_bit(AS_DO_NOT_MMIGRATE, &as->flags);
+			break;
+		case MPOL_MF_MMIGRATE_DEFAULT:
+			clear_bit(AS_DO_MMIGRATE, &as->flags);
+			clear_bit(AS_DO_NOT_MMIGRATE, &as->flags);
+			break;
+		default:
+			BUG();
+		}
+	}
+out:
+	up_read(&mm->mmap_sem);
+	return err;
+}
+
 /* Change policy for a memory range */
 asmlinkage long sys_mbind(unsigned long start, unsigned long len,
 			  unsigned long mode,
@@ -367,7 +416,7 @@ asmlinkage long sys_mbind(unsigned long 
 	DECLARE_BITMAP(nodes, MAX_NUMNODES);
 	int err;
 
-	if ((flags & ~(unsigned long)(MPOL_MF_STRICT)) || mode > MPOL_MAX)
+	if ((flags & ~(unsigned long)(MPOL_MF_MASK)) || mode > MPOL_MAX)
 		return -EINVAL;
 	if (start & ~PAGE_MASK)
 		return -EINVAL;
@@ -380,6 +429,12 @@ asmlinkage long sys_mbind(unsigned long 
 	if (end == start)
 		return 0;
 
+	if (flags & MPOL_MF_MMIGRATE_MASK)
+		return mbind_migration_policy(mm, start, end, flags);
+
+	if (mode == MPOL_DEFAULT)
+		flags &= ~MPOL_MF_STRICT;
+
 	err = get_nodes(nodes, nmask, maxnode, mode);
 	if (err)
 		return err;
@@ -492,17 +547,40 @@ asmlinkage long sys_get_mempolicy(int __
 	struct vm_area_struct *vma = NULL;
 	struct mempolicy *pol = current->mempolicy;
 
-	if (flags & ~(unsigned long)(MPOL_F_NODE|MPOL_F_ADDR))
+	if (flags & ~(unsigned long)(MPOL_F_MASK))
 		return -EINVAL;
+	if ((flags & (MPOL_F_NODE | MPOL_F_ADDR)) &&
+	    (flags & MPOL_F_MMIGRATE))
+	    	return -EINVAL;
 	if (nmask != NULL && maxnode < MAX_NUMNODES)
 		return -EINVAL;
-	if (flags & MPOL_F_ADDR) {
+	if ((flags & MPOL_F_ADDR) || (flags & MPOL_F_MMIGRATE)) {
 		down_read(&mm->mmap_sem);
 		vma = find_vma_intersection(mm, addr, addr+1);
 		if (!vma) {
 			up_read(&mm->mmap_sem);
 			return -EFAULT;
 		}
+		if (flags & MPOL_F_MMIGRATE) {
+			struct address_space *as;
+			err = 0;
+			if (!vma->vm_file) {
+				err = -EINVAL;
+				goto out;
+			}
+			as = vma->vm_file->f_mapping;
+			BUG_ON(!as);
+			pval = 0;
+			if (test_bit(AS_DO_MMIGRATE, &as->flags))
+				pval |= MPOL_MF_DO_MMIGRATE;
+			if (test_bit(AS_DO_NOT_MMIGRATE, &as->flags))
+				pval |= MPOL_MF_DO_NOT_MMIGRATE;
+			if (policy && put_user(pval, policy)) {
+				err = -EFAULT;
+				goto out;
+			}
+			goto out;
+		}
 		if (vma->vm_ops && vma->vm_ops->get_policy)
 			pol = vma->vm_ops->get_policy(vma, addr);
 		else
Index: linux-2.6.12-rc5-mhp1-page-migration-export/include/linux/mempolicy.h
===================================================================
--- linux-2.6.12-rc5-mhp1-page-migration-export.orig/include/linux/mempolicy.h	2005-06-13 11:47:46.000000000 -0700
+++ linux-2.6.12-rc5-mhp1-page-migration-export/include/linux/mempolicy.h	2005-06-13 11:48:53.000000000 -0700
@@ -19,9 +19,27 @@
 /* Flags for get_mem_policy */
 #define MPOL_F_NODE	(1<<0)	/* return next IL mode instead of node mask */
 #define MPOL_F_ADDR	(1<<1)	/* look up vma using address */
+#define MPOL_F_MMIGRATE (1<<2)  /* return migration policy flags */
+
+#define MPOL_F_MASK (MPOL_F_NODE | MPOL_F_ADDR | MPOL_F_MMIGRATE)
 
 /* Flags for mbind */
 #define MPOL_MF_STRICT	(1<<0)	/* Verify existing pages in the mapping */
+/* FUTURE USE           (1<<1)  RESERVE for MPOL_MF_MOVE */
+/* Flags to set the migration policy for a memory range
+ * By default the kernel will memory migrate all writable VMAs
+ * (this includes anonymous memory) and the program exectuable.
+ * For non-anonymous memory, the user can change the default
+ * actions using the following flags to mbind:
+ */
+#define MPOL_MF_DO_MMIGRATE      (1<<2) /* migrate pages of this mem object */
+#define MPOL_MF_DO_NOT_MMIGRATE  (1<<3) /* don't migrate any of these pages */
+#define MPOL_MF_MMIGRATE_DEFAULT (1<<4) /* reset back to kernel default */
+
+#define MPOL_MF_MASK (MPOL_MF_STRICT | MPOL_MF_DO_MMIGRATE | \
+		      MPOL_MF_DO_NOT_MMIGRATE | MPOL_MF_MMIGRATE_DEFAULT)
+#define MPOL_MF_MMIGRATE_MASK (MPOL_MF_DO_MMIGRATE |       \
+		      MPOL_MF_DO_NOT_MMIGRATE | MPOL_MF_MMIGRATE_DEFAULT)
 
 #ifdef __KERNEL__
 
Index: linux-2.6.12-rc5-mhp1-page-migration-export/include/linux/pagemap.h
===================================================================
--- linux-2.6.12-rc5-mhp1-page-migration-export.orig/include/linux/pagemap.h	2005-06-13 11:47:46.000000000 -0700
+++ linux-2.6.12-rc5-mhp1-page-migration-export/include/linux/pagemap.h	2005-06-13 11:48:53.000000000 -0700
@@ -19,6 +19,10 @@
 #define	AS_EIO		(__GFP_BITS_SHIFT + 0)	/* IO error on async write */
 #define AS_ENOSPC	(__GFP_BITS_SHIFT + 1)	/* ENOSPC on async write */
 
+/* (manual) memory migration control flags.  set via mbind() in mempolicy.c */
+#define AS_DO_MMIGRATE     (__GFP_BITS_SHIFT + 2)  /* migrate pages */
+#define AS_DO_NOT_MMIGRATE (__GFP_BITS_SHIFT + 3)  /* don't migrate any pages */
+
 static inline unsigned int __nocast mapping_gfp_mask(struct address_space * mapping)
 {
 	return mapping->flags & __GFP_BITS_MASK;

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
