Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 8F4D56B0032
	for <linux-mm@kvack.org>; Mon, 16 Feb 2015 06:27:59 -0500 (EST)
Received: by pdjy10 with SMTP id y10so34694295pdj.6
        for <linux-mm@kvack.org>; Mon, 16 Feb 2015 03:27:59 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id iw5si700657pbb.30.2015.02.16.03.27.58
        for <linux-mm@kvack.org>;
        Mon, 16 Feb 2015 03:27:58 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 3/4] mm: move gup() -> posix mlock() error conversion out of __mm_populate
Date: Mon, 16 Feb 2015 13:27:53 +0200
Message-Id: <1424086074-200683-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1424086074-200683-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1424086074-200683-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This is praparation to moving mm_populate()-related code out of
mm/mlock.c.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Linus Torvalds <torvalds@linux-foundation.org>
Acked-by: David Rientjes <rientjes@google.com>
---
 mm/mlock.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index c3ea18323034..9fbe611b1e93 100644
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
+		return __mlock_posix_error_return(error);
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
