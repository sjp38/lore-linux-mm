Date: Thu, 18 May 2006 11:21:42 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060518182142.20734.92595.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060518182111.20734.5489.sendpatchset@schroedinger.engr.sgi.com>
References: <20060518182111.20734.5489.sendpatchset@schroedinger.engr.sgi.com>
Subject: [RFC 6/6] page migration: Support a vma migration function
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@osdl.org, bls@sgi.com, jes@sgi.com, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <clameter@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hooks for calling vma specific migration functions

With this patch a vma may define a vma->vm_ops->migrate function.
That function may perform page migration on its own (some vmas may
not contain page structs and therefore cannot be handled by regular
page migration. Pages in a vma may require special preparatory
treatment before migration is possible etc) . Only mmap_sem is
held when the migration function is called. The migrate() function
gets passed two sets of nodemasks describing the source and the target
of the migration. The flags parameter either contains

MPOL_MF_MOVE	which means that only pages used exclusively by
		the specified mm should be moved

or

MPOL_MF_MOVE_ALL which means that pages shared with other processes
		should also be moved.

The migration function returns 0 on success or an error condition.
An error condition will prevent regular page migration from occurring.

On its own this patch cannot be included since there are no users
for this functionality. But it seems that the uncached allocator
will need this functionality at some point.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc4-mm1/mm/mempolicy.c
===================================================================
--- linux-2.6.17-rc4-mm1.orig/mm/mempolicy.c	2006-05-18 10:28:46.290423356 -0700
+++ linux-2.6.17-rc4-mm1/mm/mempolicy.c	2006-05-18 10:28:51.629936158 -0700
@@ -631,6 +631,10 @@ int do_migrate_pages(struct mm_struct *m
 
   	down_read(&mm->mmap_sem);
 
+	err = migrate_vmas(mm, from_nodes, to_nodes, flags);
+	if (err)
+		goto out;
+
 /*
  * Find a 'source' bit set in 'tmp' whose corresponding 'dest'
  * bit in 'to' is not also set in 'tmp'.  Clear the found 'source'
@@ -690,7 +694,7 @@ int do_migrate_pages(struct mm_struct *m
 		if (err < 0)
 			break;
 	}
-
+out:
 	up_read(&mm->mmap_sem);
 	if (err < 0)
 		return err;
Index: linux-2.6.17-rc4-mm1/mm/migrate.c
===================================================================
--- linux-2.6.17-rc4-mm1.orig/mm/migrate.c	2006-05-18 10:28:46.289446854 -0700
+++ linux-2.6.17-rc4-mm1/mm/migrate.c	2006-05-18 10:36:56.930910584 -0700
@@ -894,3 +894,23 @@ out2:
 }
 #endif
 
+/*
+ * Call migration functions in the vma_ops that may prepare
+ * memory in a vm for migration. migration functions may perform
+ * the migration for vmas that do not have an underlying page struct.
+ */
+int migrate_vmas(struct mm_struct *mm, const nodemask_t *to,
+	const nodemask_t *from, unsigned long flags)
+{
+ 	struct vm_area_struct *vma;
+ 	int err = 0;
+
+ 	for(vma = mm->mmap; vma->vm_next && !err; vma = vma->vm_next) {
+ 		if (vma->vm_ops && vma->vm_ops->migrate) {
+ 			err = vma->vm_ops->migrate(vma, to, from, flags);
+ 			if (err)
+ 				break;
+ 		}
+ 	}
+ 	return err;
+}
Index: linux-2.6.17-rc4-mm1/include/linux/mm.h
===================================================================
--- linux-2.6.17-rc4-mm1.orig/include/linux/mm.h	2006-05-15 15:40:12.355514333 -0700
+++ linux-2.6.17-rc4-mm1/include/linux/mm.h	2006-05-18 10:38:35.269541654 -0700
@@ -209,6 +209,8 @@ struct vm_operations_struct {
 	int (*set_policy)(struct vm_area_struct *vma, struct mempolicy *new);
 	struct mempolicy *(*get_policy)(struct vm_area_struct *vma,
 					unsigned long addr);
+	int (*migrate)(struct vm_area_struct *vma, const nodemask_t *from,
+		const nodemask_t *to, unsigned long flags);
 #endif
 };
 
Index: linux-2.6.17-rc4-mm1/include/linux/migrate.h
===================================================================
--- linux-2.6.17-rc4-mm1.orig/include/linux/migrate.h	2006-05-18 10:28:46.291399858 -0700
+++ linux-2.6.17-rc4-mm1/include/linux/migrate.h	2006-05-18 10:37:43.795193223 -0700
@@ -16,7 +16,9 @@ extern int fail_migrate_page(struct addr
 			struct page *, struct page *);
 
 extern int migrate_prep(void);
-
+extern int migrate_vmas(struct mm_struct *mm,
+		const nodemask_t *from, const nodemask_t *to,
+		unsigned long flags);
 #else
 
 static inline int isolate_lru_page(struct page *p, struct list_head *list)
@@ -30,6 +32,13 @@ static inline int migrate_pages_to(struc
 
 static inline int migrate_prep(void) { return -ENOSYS; }
 
+static inline int migrate_vmas(struct mm_struct *mm,
+		const nodemask_t *from, const nodemask_t *to,
+		unsigned long flags)
+{
+	return -ENOSYS;
+}
+
 /* Possible settings for the migrate_page() method in address_operations */
 #define migrate_page NULL
 #define fail_migrate_page NULL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
