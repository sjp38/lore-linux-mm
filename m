Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 128BA680DC6
	for <linux-mm@kvack.org>; Sun,  4 Oct 2015 02:18:56 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so144879113pac.0
        for <linux-mm@kvack.org>; Sat, 03 Oct 2015 23:18:55 -0700 (PDT)
Received: from m50-132.163.com (m50-132.163.com. [123.125.50.132])
        by mx.google.com with ESMTP id wk1si21486202pbc.139.2015.10.03.23.18.50
        for <linux-mm@kvack.org>;
        Sat, 03 Oct 2015 23:18:55 -0700 (PDT)
From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH 3/3] mm/nommu: drop unlikely behind BUG_ON()
Date: Sun,  4 Oct 2015 14:18:03 +0800
Message-Id: <45bf632d263280847a2a894017c62b7f2a71eda1.1443937856.git.geliangtang@163.com>
In-Reply-To: <a89c7bef0699c3d3f5e592c58ff3f0a4db482b69.1443937856.git.geliangtang@163.com>
References: <a89c7bef0699c3d3f5e592c58ff3f0a4db482b69.1443937856.git.geliangtang@163.com>
In-Reply-To: <cf38aa69e23adb31ebb4c9d80384dabe9b91b75e.1443937856.git.geliangtang@163.com>
References: <a89c7bef0699c3d3f5e592c58ff3f0a4db482b69.1443937856.git.geliangtang@163.com> <cf38aa69e23adb31ebb4c9d80384dabe9b91b75e.1443937856.git.geliangtang@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Davidlohr Bueso <dave@stgolabs.net>, Joonsoo Kim <js1304@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Paul Gortmaker <paul.gortmaker@windriver.com>, Leon Romanovsky <leon@leon.nu>, Oleg Nesterov <oleg@redhat.com>
Cc: Geliang Tang <geliangtang@163.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

BUG_ON() already contain an unlikely compiler flag. Drop it.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 mm/nommu.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/nommu.c b/mm/nommu.c
index 1e0f168..92be862 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -578,16 +578,16 @@ static noinline void validate_nommu_regions(void)
 		return;
 
 	last = rb_entry(lastp, struct vm_region, vm_rb);
-	BUG_ON(unlikely(last->vm_end <= last->vm_start));
-	BUG_ON(unlikely(last->vm_top < last->vm_end));
+	BUG_ON(last->vm_end <= last->vm_start);
+	BUG_ON(last->vm_top < last->vm_end);
 
 	while ((p = rb_next(lastp))) {
 		region = rb_entry(p, struct vm_region, vm_rb);
 		last = rb_entry(lastp, struct vm_region, vm_rb);
 
-		BUG_ON(unlikely(region->vm_end <= region->vm_start));
-		BUG_ON(unlikely(region->vm_top < region->vm_end));
-		BUG_ON(unlikely(region->vm_start < last->vm_top));
+		BUG_ON(region->vm_end <= region->vm_start);
+		BUG_ON(region->vm_top < region->vm_end);
+		BUG_ON(region->vm_start < last->vm_top);
 
 		lastp = p;
 	}
-- 
2.5.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
