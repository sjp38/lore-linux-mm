Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f54.google.com (mail-yh0-f54.google.com [209.85.213.54])
	by kanga.kvack.org (Postfix) with ESMTP id 774E26B0036
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 04:04:38 -0500 (EST)
Received: by mail-yh0-f54.google.com with SMTP id z12so3500256yhz.27
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 01:04:38 -0800 (PST)
Received: from mail-pd0-x22b.google.com (mail-pd0-x22b.google.com [2607:f8b0:400e:c02::22b])
        by mx.google.com with ESMTPS id b7si12014559yhm.160.2013.12.16.01.04.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 01:04:37 -0800 (PST)
Received: by mail-pd0-f171.google.com with SMTP id z10so5066380pdj.30
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 01:04:36 -0800 (PST)
Date: Mon, 16 Dec 2013 01:04:13 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: mm: ptl is not bloated if it fits in pointer
Message-ID: <alpine.LNX.2.00.1312160053530.3066@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

It's silly to force the 64-bit CONFIG_GENERIC_LOCKBREAK architectures
to kmalloc eight bytes for an indirect page table lock: the lock needs
to fit in the space that a pointer to it would occupy, not into an int.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 kernel/bounds.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- 3.13-rc4/kernel/bounds.c	2013-11-22 15:40:37.452192638 -0800
+++ linux/kernel/bounds.c	2013-12-15 14:34:36.304485959 -0800
@@ -22,6 +22,6 @@ void foo(void)
 #ifdef CONFIG_SMP
 	DEFINE(NR_CPUS_BITS, ilog2(CONFIG_NR_CPUS));
 #endif
-	DEFINE(BLOATED_SPINLOCKS, sizeof(spinlock_t) > sizeof(int));
+	DEFINE(BLOATED_SPINLOCKS, sizeof(spinlock_t) > sizeof(spinlock_t *));
 	/* End of constants */
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
