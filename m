Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 283866B005C
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 08:34:57 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so957962pbb.14
        for <linux-mm@kvack.org>; Tue, 17 Jul 2012 05:34:56 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 2/4 v2] mm: fix possible incorrect return value of migrate_pages() syscall
Date: Tue, 17 Jul 2012 21:33:33 +0900
Message-Id: <1342528415-2291-2-git-send-email-js1304@gmail.com>
In-Reply-To: <1342528415-2291-1-git-send-email-js1304@gmail.com>
References: <Yes>
 <1342528415-2291-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Lameter <cl@linux.com>

do_migrate_pages() can return the number of pages not migrated.
Because migrate_pages() syscall return this value directly,
migrate_pages() syscall may return the number of pages not migrated.
In fail case in migrate_pages() syscall, we should return error value.
So change err to -EBUSY

Additionally, Correct comment above do_migrate_pages()

Signed-off-by: Joonsoo Kim <js1304@gmail.com>
Cc: Sasha Levin <levinsasha928@gmail.com>
Cc: Christoph Lameter <cl@linux.com>

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 1d771e4..0732729 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -948,7 +948,7 @@ static int migrate_to_node(struct mm_struct *mm, int source, int dest,
  * Move pages between the two nodesets so as to preserve the physical
  * layout as much as possible.
  *
- * Returns the number of page that could not be moved.
+ * Returns error or the number of pages not migrated.
  */
 int do_migrate_pages(struct mm_struct *mm, const nodemask_t *from,
 		     const nodemask_t *to, int flags)
@@ -1382,6 +1382,8 @@ SYSCALL_DEFINE4(migrate_pages, pid_t, pid, unsigned long, maxnode,
 
 	err = do_migrate_pages(mm, old, new,
 		capable(CAP_SYS_NICE) ? MPOL_MF_MOVE_ALL : MPOL_MF_MOVE);
+	if (err > 0)
+		err = -EBUSY;
 
 	mmput(mm);
 out:
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
