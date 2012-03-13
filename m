Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 0CD826B0083
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 01:36:58 -0400 (EDT)
Received: by laah2 with SMTP id h2so6192laa.2
        for <linux-mm@kvack.org>; Mon, 12 Mar 2012 22:36:57 -0700 (PDT)
From: Avery Pennarun <apenwarr@gmail.com>
Subject: [PATCH 4/5] printk: use alloc_bootmem() instead of memblock_alloc().
Date: Tue, 13 Mar 2012 01:36:40 -0400
Message-Id: <1331617001-20906-5-git-send-email-apenwarr@gmail.com>
In-Reply-To: <1331617001-20906-1-git-send-email-apenwarr@gmail.com>
References: <1331617001-20906-1-git-send-email-apenwarr@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Josh Triplett <josh@joshtriplett.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "David S. Miller" <davem@davemloft.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Fabio M. Di Nitto" <fdinitto@redhat.com>, Avery Pennarun <apenwarr@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Olaf Hering <olaf@aepfle.de>, Paul Gortmaker <paul.gortmaker@windriver.com>, Tejun Heo <tj@kernel.org>, "H. Peter Anvin" <hpa@linux.intel.com>, Yinghai LU <yinghai@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

The code in setup_log_buf() had two memory allocation branches, depending
on the value of 'early'.  If early==1, it would use memblock_alloc(); if
early==0, it would use alloc_bootmem_nopanic().

bootmem should already configured by the time setup_log_buf(early=1) is
called, so there's no reason to have the separation.  Furthermore, on
arches with nobootmem, memblock_alloc is essentially the same as
alloc_bootmem anyway.  x86 is one such arch, and also the only one
that uses early=1.

Signed-off-by: Avery Pennarun <apenwarr@gmail.com>
---
 kernel/printk.c |   13 +------------
 1 files changed, 1 insertions(+), 12 deletions(-)

diff --git a/kernel/printk.c b/kernel/printk.c
index 32690a0..bf96a7d 100644
--- a/kernel/printk.c
+++ b/kernel/printk.c
@@ -31,7 +31,6 @@
 #include <linux/smp.h>
 #include <linux/security.h>
 #include <linux/bootmem.h>
-#include <linux/memblock.h>
 #include <linux/syscalls.h>
 #include <linux/kexec.h>
 #include <linux/kdb.h>
@@ -195,17 +194,7 @@ void __init setup_log_buf(int early)
 	if (!new_log_buf_len)
 		return;
 
-	if (early) {
-		unsigned long mem;
-
-		mem = memblock_alloc(new_log_buf_len, PAGE_SIZE);
-		if (!mem)
-			return;
-		new_log_buf = __va(mem);
-	} else {
-		new_log_buf = alloc_bootmem_nopanic(new_log_buf_len);
-	}
-
+	new_log_buf = alloc_bootmem_nopanic(new_log_buf_len);
 	if (unlikely(!new_log_buf)) {
 		pr_err("log_buf_len: %ld bytes not available\n",
 			new_log_buf_len);
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
