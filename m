Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 28FD68D0069
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 02:50:06 -0500 (EST)
Received: by fxm12 with SMTP id 12so1537043fxm.14
        for <linux-mm@kvack.org>; Thu, 20 Jan 2011 23:50:03 -0800 (PST)
From: Michal Simek <monstr@monstr.eu>
Subject: [PATCH] mm: System without MMU do not need pte_mkwrite
Date: Fri, 21 Jan 2011 08:49:56 +0100
Message-Id: <1295596196-8233-2-git-send-email-monstr@monstr.eu>
In-Reply-To: <1295596196-8233-1-git-send-email-monstr@monstr.eu>
References: <1295596196-8233-1-git-send-email-monstr@monstr.eu>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Michal Simek <monstr@monstr.eu>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

The patch "thp: export maybe_mkwrite"
(sha1 14fd403f2146f740942d78af4e0ee59396ad8eab)
break systems without MMU.

Error log:
  CC      arch/microblaze/mm/init.o
In file included from include/linux/mman.h:14,
                 from arch/microblaze/mm/consistent.c:24:
include/linux/mm.h: In function 'maybe_mkwrite':
include/linux/mm.h:482: error: implicit declaration of function 'pte_mkwrite'
include/linux/mm.h:482: error: incompatible types in assignment

Signed-off-by: Michal Simek <monstr@monstr.eu>
CC: Andrea Arcangeli <aarcange@redhat.com>
CC: Linus Torvalds <torvalds@linux-foundation.org>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Rik van Riel <riel@redhat.com>
CC: Ingo Molnar <mingo@elte.hu>
---
 include/linux/mm.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 956a355..f6385fc 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -470,6 +470,7 @@ static inline void set_compound_order(struct page *page, unsigned long order)
 	page[1].lru.prev = (void *)order;
 }
 
+#ifdef CONFIG_MMU
 /*
  * Do pte_mkwrite, but only if the vma says VM_WRITE.  We do this when
  * servicing faults for write access.  In the normal case, do always want
@@ -482,6 +483,7 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
 		pte = pte_mkwrite(pte);
 	return pte;
 }
+#endif
 
 /*
  * Multiple processes may "see" the same page. E.g. for untouched
-- 
1.5.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
