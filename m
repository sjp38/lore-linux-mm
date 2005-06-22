Date: Wed, 22 Jun 2005 09:39:54 -0700 (PDT)
From: Ray Bryant <raybry@sgi.com>
Message-Id: <20050622163954.25515.63565.55012@tomahawk.engr.sgi.com>
In-Reply-To: <20050622163908.25515.49944.65860@tomahawk.engr.sgi.com>
References: <20050622163908.25515.49944.65860@tomahawk.engr.sgi.com>
Subject: [PATCH 2.6.12-rc5 7/10] mm: manual page migration-rc3 -- sys_migrate_pages-migration-selection-rc3.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andi Kleen <ak@suse.de>, Dave Hansen <haveblue@us.ibm.com>
Cc: Christoph Hellwig <hch@infradead.org>, Ray Bryant <raybry@austin.rr.com>, linux-mm <linux-mm@kvack.org>, lhms-devel@lists.sourceforge.net, Ray Bryant <raybry@sgi.com>, Paul Jackson <pj@sgi.com>, Nathan Scott <nathans@sgi.com>
List-ID: <linux-mm.kvack.org>

This patch implements the default kernel "policy" for deciding
which VMAs are to be migrated.  The default policy is:

(1)  Migrate all anonymous VMAs
(2)  Migrate all VMAs that have VM_WRITE set in vm_flags.

This is correct policy for almost all VMAs.  However, there are
a couple of cases where the above policy may need to be modified.
The mbind() interface added in the patch

	add-mempolicy-control-rc3.patch

allows user space code to modify the default policy for mapped
files on a file-by-file basis.

This patch also adds the migrate_pages() side of the support
for the mbind() policy override system call.

Signed-off-by:  Ray Bryant <raybry@sgi.com>
--

 mmigrate.c |   29 ++++++++++++++++++++---------
 1 files changed, 20 insertions(+), 9 deletions(-)

Index: linux-2.6.12-rc5-mhp1-page-migration-export/mm/mmigrate.c
===================================================================
--- linux-2.6.12-rc5-mhp1-page-migration-export.orig/mm/mmigrate.c	2005-06-13 11:12:51.000000000 -0700
+++ linux-2.6.12-rc5-mhp1-page-migration-export/mm/mmigrate.c	2005-06-13 11:12:58.000000000 -0700
@@ -601,21 +601,32 @@ migrate_vma(struct task_struct *task, st
 	unsigned long vaddr;
 	int count = 0, nr_busy;
 	LIST_HEAD(page_list);
+	struct address_space *as = NULL;
 
-	/* can't migrate mlock()'d pages */
-	if (vma->vm_flags & VM_LOCKED)
+	if ((vma->vm_flags & VM_LOCKED) || (vma->vm_flags & VM_IO))
 		return 0;
 
-	/*
-	 * gather all of the pages to be migrated from this vma into page_list
-	 */
+	/* we always migrate anonymous pages */
+	if (!vma->vm_file)
+		goto do_migrate;
+	as = vma->vm_file->f_mapping;
+	/* we have to have both AS_DO_MMIGRATE and AS_DO_MOT_MMIGRATE to
+	 * give user space full ability to override the kernel's default
+	 * migration decisions */
+	if (test_bit(AS_DO_MMIGRATE, &as->flags))
+		goto do_migrate;
+	if (test_bit(AS_DO_NOT_MMIGRATE, &as->flags))
+		return 0;
+	if (!(vma->vm_flags & VM_WRITE))
+		return 0;
+
+	/* gather the pages to be migrated from this vma into page_list */
+do_migrate:
 	spin_lock(&mm->page_table_lock);
  	for (vaddr = vma->vm_start; vaddr < vma->vm_end; vaddr += PAGE_SIZE) {
 		page = follow_page(mm, vaddr, 0);
-		/*
-		 * follow_page has been known to return pages with zero mapcount
-		 * and NULL mapping.  Skip those pages as well
-		 */
+		/* follow_page has been known to return pages with zero mapcount
+		 * and NULL mapping.  Skip those pages as well */
 		if (page && page_mapcount(page)) {
 			if (node_map[page_to_nid(page)] >= 0) {
 				if (steal_page_from_lru(page_zone(page), page,

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
