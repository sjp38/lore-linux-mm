Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id 65C816B0036
	for <linux-mm@kvack.org>; Sat,  3 May 2014 19:37:53 -0400 (EDT)
Received: by mail-ee0-f49.google.com with SMTP id e53so4144767eek.22
        for <linux-mm@kvack.org>; Sat, 03 May 2014 16:37:52 -0700 (PDT)
Received: from mail.sigma-star.at (mail.sigma-star.at. [95.130.255.111])
        by mx.google.com with ESMTP id x46si5839125eea.89.2014.05.03.16.37.51
        for <linux-mm@kvack.org>;
        Sat, 03 May 2014 16:37:51 -0700 (PDT)
From: Richard Weinberger <richard@nod.at>
Subject: [PATCH] mm: Fix force_flush behavior in zap_pte_range()
Date: Sun,  4 May 2014 01:37:27 +0200
Message-Id: <1399160247-32093-1-git-send-email-richard@nod.at>
In-Reply-To: <alpine.LSU.2.11.1404161239320.6778@eggly.anvils>
References: <alpine.LSU.2.11.1404161239320.6778@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Richard Weinberger <richard@nod.at>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, toralf.foerster@gmx.de

Commit 1cf35d47 (mm: split 'tlb_flush_mmu()' into tlb flushing and memory freeing parts)
accidently changed the behavior of the force_flush variable.
Before the patch it was set by __tlb_remove_page(). Now it is only set to 1
if __tlb_remove_page() returns false but never set back to 0 if __tlb_remove_page()
returns true. And therefore the flush happens now too often.
This patch restores the old behavior.

Fixes BUG: Bad rss-counter state ...
and
kernel BUG at mm/filemap.c:202!

Reported-by: Dave Jones <davej@redhat.com>
Reported-by: toralf.foerster@gmx.de
Cc: Dave Jones <davej@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Sasha Levin <sasha.levin@oracle.com>
Cc: Hugh Dickins <hughd@google.com> 
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: toralf.foerster@gmx.de
Signed-off-by: Richard Weinberger <richard@nod.at>
---
 mm/memory.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 037b812..585885b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1148,10 +1148,10 @@ again:
 			page_remove_rmap(page);
 			if (unlikely(page_mapcount(page) < 0))
 				print_bad_pte(vma, addr, ptent, page);
-			if (unlikely(!__tlb_remove_page(tlb, page))) {
-				force_flush = 1;
+			force_flush = !__tlb_remove_page(tlb, page);
+			if (force_flush)
 				break;
-			}
+
 			continue;
 		}
 		/*
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
