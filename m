Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 638C56B005D
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 13:57:01 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so6139790pbb.14
        for <linux-mm@kvack.org>; Fri, 27 Jul 2012 10:57:00 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [RESEND PATCH 2/4 v3] mm: fix possible incorrect return value of migrate_pages() syscall
Date: Sat, 28 Jul 2012 02:55:01 +0900
Message-Id: <1343411703-2720-2-git-send-email-js1304@gmail.com>
In-Reply-To: <1343411703-2720-1-git-send-email-js1304@gmail.com>
References: <Yes>
 <1343411703-2720-1-git-send-email-js1304@gmail.com>
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
Acked-by: Michal Nazarewicz <mina86@mina86.com>

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
