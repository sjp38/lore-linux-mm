Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id F1BC36B00FC
	for <linux-mm@kvack.org>; Fri, 13 Apr 2012 05:59:05 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so3014591bkw.14
        for <linux-mm@kvack.org>; Fri, 13 Apr 2012 02:59:04 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH 2/2] mm: fix NULL ptr dereference in move_pages
Date: Fri, 13 Apr 2012 08:58:22 -0400
Message-Id: <1334321902-7143-2-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1334321902-7143-1-git-send-email-levinsasha928@gmail.com>
References: <1334321902-7143-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, akpm@linux-foundation.org
Cc: hughd@google.com, dave@linux.vnet.ibm.com, ebiederm@xmission.com, davej@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

Commit 3268c63 ("mm: fix move/migrate_pages() race on task struct") has added
an odd construct where 'mm' is checked for being NULL, and if it is, it would
get dereferenced anyways by mput()ing it.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 mm/migrate.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 51c08a0..1107238 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1388,14 +1388,14 @@ SYSCALL_DEFINE6(move_pages, pid_t, pid, unsigned long, nr_pages,
 	mm = get_task_mm(task);
 	put_task_struct(task);
 
-	if (mm) {
-		if (nodes)
-			err = do_pages_move(mm, task_nodes, nr_pages, pages,
-					    nodes, status, flags);
-		else
-			err = do_pages_stat(mm, nr_pages, pages, status);
-	} else
-		err = -EINVAL;
+	if (!mm)
+		return -EINVAL;
+
+	if (nodes)
+		err = do_pages_move(mm, task_nodes, nr_pages, pages,
+				    nodes, status, flags);
+	else
+		err = do_pages_stat(mm, nr_pages, pages, status);
 
 	mmput(mm);
 	return err;
-- 
1.7.8.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
