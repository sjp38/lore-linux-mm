Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id AF11D900017
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 18:06:52 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id lj1so1883954pab.32
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 15:06:52 -0700 (PDT)
Received: from homiemail-a38.g.dreamhost.com (homie.mail.dreamhost.com. [208.97.132.208])
        by mx.google.com with ESMTP id fz2si5161333pdb.100.2014.10.24.15.06.51
        for <linux-mm@kvack.org>;
        Fri, 24 Oct 2014 15:06:51 -0700 (PDT)
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH 07/10] mm/memory-failure: share the i_mmap_rwsem
Date: Fri, 24 Oct 2014 15:06:17 -0700
Message-Id: <1414188380-17376-8-git-send-email-dave@stgolabs.net>
In-Reply-To: <1414188380-17376-1-git-send-email-dave@stgolabs.net>
References: <1414188380-17376-1-git-send-email-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hughd@google.com, riel@redhat.com, mgorman@suse.de, peterz@infradead.org, mingo@kernel.org, linux-kernel@vger.kernel.org, dbueso@suse.de, linux-mm@kvack.org, Davidlohr Bueso <dave@stgolabs.net>

No brainer conversion: collect_procs_file() only schedules
a process for later kill, share the lock, similarly to
the anon vma variant.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 mm/memory-failure.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 13708cf..ce7b0ec 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -466,7 +466,7 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
 	struct task_struct *tsk;
 	struct address_space *mapping = page->mapping;
 
-	i_mmap_lock_write(mapping);
+	i_mmap_lock_read(mapping);
 	read_lock(&tasklist_lock);
 	for_each_process(tsk) {
 		pgoff_t pgoff = page_to_pgoff(page);
@@ -488,7 +488,7 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
 		}
 	}
 	read_unlock(&tasklist_lock);
-	i_mmap_unlock_write(mapping);
+	i_mmap_unlock_read(mapping);
 }
 
 /*
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
