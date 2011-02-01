Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5C5D18D0041
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 06:21:53 -0500 (EST)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH 1/2] Allow GUP to fail instead of waiting on a page.
Date: Tue,  1 Feb 2011 13:21:46 +0200
Message-Id: <1296559307-14637-2-git-send-email-gleb@redhat.com>
In-Reply-To: <1296559307-14637-1-git-send-email-gleb@redhat.com>
References: <1296559307-14637-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: avi@redhat.com, mtosatti@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

GUP user may want to try to acquire a reference to a page if it is already
in memory, but not if IO, to bring it in, is needed. For example KVM may
tell vcpu to schedule another guest process if current one is trying to
access swapped out page. Meanwhile, the page will be swapped in and the
guest process, that depends on it, will be able to run again.

This patch adds FAULT_FLAG_RETRY_NOWAIT (suggested by Linus) and
FOLL_NOWAIT follow_page flags. FAULT_FLAG_RETRY_NOWAIT, when used in
conjunction with VM_FAULT_ALLOW_RETRY, indicates to handle_mm_fault that
it shouldn't drop mmap_sem and wait on a page, but return VM_FAULT_RETRY
instead.

Signed-off-by: Gleb Natapov <gleb@redhat.com>
CC: Linus Torvalds <torvalds@linux-foundation.org>
CC: Rik van Riel <riel@redhat.com>
CC: Hugh Dickins <hughd@google.com>
CC: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/mm.h |    2 ++
 mm/filemap.c       |    6 ++++--
 mm/memory.c        |    5 ++++-
 3 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 9c3a7c8..fa5e562 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -151,6 +151,7 @@ extern pgprot_t protection_map[16];
 #define FAULT_FLAG_NONLINEAR	0x02	/* Fault was via a nonlinear mapping */
 #define FAULT_FLAG_MKWRITE	0x04	/* Fault was mkwrite of existing pte */
 #define FAULT_FLAG_ALLOW_RETRY	0x08	/* Retry fault if blocking */
+#define FAULT_FLAG_RETRY_NOWAIT	0x10	/* Don't drop mmap_sem and wait when retrying */
 
 /*
  * This interface is used by x86 PAT code to identify a pfn mapping that is
@@ -1532,6 +1533,7 @@ struct page *follow_page(struct vm_area_struct *, unsigned long address,
 #define FOLL_GET	0x04	/* do get_page on page */
 #define FOLL_DUMP	0x08	/* give error on hole if it would be zero */
 #define FOLL_FORCE	0x10	/* get_user_pages read/write w/o permission */
+#define FOLL_NOWAIT	0x20	/* return if disk transfer is needed */
 #define FOLL_MLOCK	0x40	/* mark page as mlocked */
 #define FOLL_SPLIT	0x80	/* don't return transhuge pages, split them */
 #define FOLL_HWPOISON	0x100	/* check page is hwpoisoned */
diff --git a/mm/filemap.c b/mm/filemap.c
index 83a45d3..312b6eb 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -621,8 +621,10 @@ int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
 		__lock_page(page);
 		return 1;
 	} else {
-		up_read(&mm->mmap_sem);
-		wait_on_page_locked(page);
+		if (!(flags & FAULT_FLAG_RETRY_NOWAIT)) {
+			up_read(&mm->mmap_sem);
+			wait_on_page_locked(page);
+		}
 		return 0;
 	}
 }
diff --git a/mm/memory.c b/mm/memory.c
index e7c9a99..a52a3e6 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1569,6 +1569,8 @@ int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 					fault_flags |= FAULT_FLAG_WRITE;
 				if (nonblocking)
 					fault_flags |= FAULT_FLAG_ALLOW_RETRY;
+				if (foll_flags & FOLL_NOWAIT)
+					fault_flags |= (FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_RETRY_NOWAIT);
 
 				ret = handle_mm_fault(mm, vma, start,
 							fault_flags);
@@ -1595,7 +1597,8 @@ int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 					tsk->min_flt++;
 
 				if (ret & VM_FAULT_RETRY) {
-					*nonblocking = 0;
+					if (nonblocking)
+						*nonblocking = 0;
 					return i;
 				}
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
