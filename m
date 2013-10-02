Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id CD6DA6B0038
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 10:29:02 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id xa7so949402pbc.31
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 07:29:02 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 16/26] mm: Provide get_user_pages_unlocked()
Date: Wed,  2 Oct 2013 16:27:57 +0200
Message-Id: <1380724087-13927-17-git-send-email-jack@suse.cz>
In-Reply-To: <1380724087-13927-1-git-send-email-jack@suse.cz>
References: <1380724087-13927-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Jan Kara <jack@suse.cz>

Provide a wrapper for get_user_pages() which takes care of acquiring and
releasing mmap_sem. Using this function reduces amount of places in
which we deal with mmap_sem.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/linux/mm.h | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 8b6e55ee8855..70031ead06a5 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1031,6 +1031,20 @@ long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		    struct vm_area_struct **vmas);
 int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			struct page **pages);
+static inline long
+get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
+		 	unsigned long start, unsigned long nr_pages,
+			int write, int force, struct page **pages)
+{
+	long ret;
+
+	down_read(&mm->mmap_sem);
+	ret = get_user_pages(tsk, mm, start, nr_pages, write, force, pages,
+			     NULL);
+	up_read(&mm->mmap_sem);
+	return ret;
+}
+
 struct kvec;
 int get_kernel_pages(const struct kvec *iov, int nr_pages, int write,
 			struct page **pages);
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
