Date: Fri, 24 Feb 2006 17:42:00 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: [RFC] sys_migrate_pages: Allow the specification of migration options
Message-ID: <Pine.LNX.4.64.0602241728300.24858@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ak@suse.de, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

Andi, 

Andrew suggested to add another parameter to sys_migrate_pages in an 
earlier thread. We discussed a patch that made sys_migrate_pages 
move all pages of a process when invoked as root. Here is an alternate 
patch adding a parameter that would give root control if migrate_pages 
will move pages referenced only by the specified process or all 
referenced pages.

This would break numactl and require another update cycle. What would you 
prefer? And if we do this could be get all of the functionality into 
SLES10 in time?



Currently sys_migrate_pages only moves pages belonging to a process.
This is okay when invoked from a regular user. But if invoked from
root it would be nice to have other options. This patch adds a flag
argument (comparable to mbind()) where one could specify MPOL_MOVE_ALL
to migrate all pages (do_migrate_pages already has that parameter).

However, doing that will break the current code for libnuma and migratepages
as well as require an update of the documentation in the numactl package.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.16-rc4/mm/mempolicy.c
===================================================================
--- linux-2.6.16-rc4.orig/mm/mempolicy.c	2006-02-24 16:20:53.000000000 -0800
+++ linux-2.6.16-rc4/mm/mempolicy.c	2006-02-24 17:17:02.000000000 -0800
@@ -890,7 +890,7 @@ asmlinkage long sys_set_mempolicy(int mo
 
 asmlinkage long sys_migrate_pages(pid_t pid, unsigned long maxnode,
 		const unsigned long __user *old_nodes,
-		const unsigned long __user *new_nodes)
+		const unsigned long __user *new_nodes, int flags)
 {
 	struct mm_struct *mm;
 	struct task_struct *task;
@@ -899,6 +899,12 @@ asmlinkage long sys_migrate_pages(pid_t 
 	nodemask_t task_nodes;
 	int err;
 
+	/*
+	 * Check for invalid flags
+	 */
+	if (flags & ~(MPOL_MF_MOVE_ALL | MPOL_MF_MOVE))
+		return -EINVAL;
+
 	err = get_nodes(&old, old_nodes, maxnode);
 	if (err)
 		return err;
@@ -940,7 +946,14 @@ asmlinkage long sys_migrate_pages(pid_t 
 		goto out;
 	}
 
-	err = do_migrate_pages(mm, &old, &new, MPOL_MF_MOVE);
+	/* Only a superuser can specify MPOL_MF_MOVE_ALL) */
+	if (!capable(CAP_SYS_ADMIN) && (flags & MPOL_MF_MOVE_ALL)) {
+		err = -EPERM;
+		goto out;
+	}
+
+	err = do_migrate_pages(mm, &old, &new,
+		flags & (MPOL_MF_MOVE_ALL|MPOL_MF_MOVE));
 out:
 	mmput(mm);
 	return err;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
