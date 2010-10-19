Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 719556B0071
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 06:15:08 -0400 (EDT)
Date: Tue, 19 Oct 2010 12:15:05 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH] fix error reporting in move_pages syscall
Message-ID: <20101019101505.GG10207@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

vma returned by find_vma does not necessary include given address. If
this happens code tries to follow page outside of any vma and returns
ENOENT instead of EFAULT.

Signed-off-by: Gleb Natapov <gleb@redhat.com>
diff --git a/mm/migrate.c b/mm/migrate.c
index 38e7cad..b91a253 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -841,7 +841,7 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 
 		err = -EFAULT;
 		vma = find_vma(mm, pp->addr);
-		if (!vma || !vma_migratable(vma))
+		if (!vma || pp->addr < vma->vm_start || !vma_migratable(vma))
 			goto set_status;
 
 		page = follow_page(vma, pp->addr, FOLL_GET);
@@ -1005,7 +1005,7 @@ static void do_pages_stat_array(struct mm_struct *mm, unsigned long nr_pages,
 		int err = -EFAULT;
 
 		vma = find_vma(mm, addr);
-		if (!vma)
+		if (!vma || addr < vma->vm_start)
 			goto set_status;
 
 		page = follow_page(vma, addr, 0);
--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
