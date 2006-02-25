Date: Fri, 24 Feb 2006 16:17:44 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Fix sys_migrate_pages: Move all pages when invoked from root
Message-ID: <Pine.LNX.4.64.0602241616540.24013@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Currently sys_migrate_pages only moves pages belonging to a process.
This is okay when invoked from a regular user. But if invoked from
root it should move all pages as documented in the migrate_pages manpage.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.16-rc4/mm/mempolicy.c
===================================================================
--- linux-2.6.16-rc4.orig/mm/mempolicy.c	2006-02-24 14:32:02.000000000 -0800
+++ linux-2.6.16-rc4/mm/mempolicy.c	2006-02-24 15:44:24.000000000 -0800
@@ -940,7 +940,8 @@ asmlinkage long sys_migrate_pages(pid_t 
 		goto out;
 	}
 
-	err = do_migrate_pages(mm, &old, &new, MPOL_MF_MOVE);
+	err = do_migrate_pages(mm, &old, &new,
+		capable(CAP_SYS_ADMIN) ? MPOL_MF_MOVE_ALL : MPOL_MF_MOVE);
 out:
 	mmput(mm);
 	return err;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
