Message-Id: <20080926173313.526291890@twins.programming.kicks-ass.net>
Date: Fri, 26 Sep 2008 19:32:22 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 3/4] futex: use fast_gup()
References: <20080926173219.885155151@twins.programming.kicks-ass.net>
Content-Disposition: inline; filename=futex-fast_gup.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>, Eric Dumazet <dada1@cosmosbay.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Change the get_user_pages() call with fast_gup() which doesn't require holding
the mmap_sem thereby removing the mmap_sem from all fast paths.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 kernel/futex.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

Index: linux-2.6/kernel/futex.c
===================================================================
--- linux-2.6.orig/kernel/futex.c
+++ linux-2.6/kernel/futex.c
@@ -232,9 +232,7 @@ static int get_futex_key(u32 __user *uad
 	}
 
 again:
-	down_read(&mm->mmap_sem);
-	err = get_user_pages(current, mm, address, 1, 0, 0, &page, NULL);
-	up_read(&mm->mmap_sem);
+	err = get_user_pages_fast(address, 1, 0, &page);
 	if (err < 0)
 		return err;
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
