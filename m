Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id D4C126B0032
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 12:12:16 -0500 (EST)
Received: by pdjz10 with SMTP id z10so5528309pdj.12
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 09:12:16 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id ki9si1249487pdb.160.2015.02.11.09.12.15
        for <linux-mm@kvack.org>;
        Wed, 11 Feb 2015 09:12:15 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 3/4] mm: move gup() -> posix mlock() error conversion out of __mm_populate
Date: Wed, 11 Feb 2015 19:12:07 +0200
Message-Id: <1423674728-214192-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1423674728-214192-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1423674728-214192-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This is praparation to moving mm_populate()-related code out of
mm/mlock.c.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/mlock.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index c3ea18323034..0837fdb26047 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -712,7 +712,6 @@ int __mm_populate(unsigned long start, unsigned long len, int ignore_errors)
 				ret = 0;
 				continue;	/* continue at next VMA */
 			}
-			ret = __mlock_posix_error_return(ret);
 			break;
 		}
 		nend = nstart + ret * PAGE_SIZE;
@@ -750,9 +749,13 @@ SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
 		error = do_mlock(start, len, 1);
 
 	up_write(&current->mm->mmap_sem);
-	if (!error)
-		error = __mm_populate(start, len, 0);
-	return error;
+	if (error)
+		return error;
+
+	error = __mm_populate(start, len, 0);
+	if (error)
+		return  __mlock_posix_error_return(error);
+	return 0;
 }
 
 SYSCALL_DEFINE2(munlock, unsigned long, start, size_t, len)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
