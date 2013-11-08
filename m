Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 408666B020C
	for <linux-mm@kvack.org>; Fri,  8 Nov 2013 18:43:25 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id q10so2802200pdj.27
        for <linux-mm@kvack.org>; Fri, 08 Nov 2013 15:43:24 -0800 (PST)
Received: from psmtp.com ([74.125.245.116])
        by mx.google.com with SMTP id ws5si8465611pab.64.2013.11.08.15.43.22
        for <linux-mm@kvack.org>;
        Fri, 08 Nov 2013 15:43:24 -0800 (PST)
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [PATCH 15/24] mm/lib/cpumask: Use memblock apis for early memory allocations
Date: Fri, 8 Nov 2013 18:41:51 -0500
Message-ID: <1383954120-24368-16-git-send-email-santosh.shilimkar@ti.com>
In-Reply-To: <1383954120-24368-1-git-send-email-santosh.shilimkar@ti.com>
References: <1383954120-24368-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Santosh Shilimkar <santosh.shilimkar@ti.com>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

Switch to memblock interfaces for early memory allocator instead of
bootmem allocator. No functional change in beahvior than what it is
in current code from bootmem users points of view.

Archs already converted to NO_BOOTMEM now directly use memblock
interfaces instead of bootmem wrappers build on top of memblock. And the
archs which still uses bootmem, these new apis just fallback to exiting
bootmem APIs.

Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>

Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
---
 lib/cpumask.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/cpumask.c b/lib/cpumask.c
index d327b87..44e492e 100644
--- a/lib/cpumask.c
+++ b/lib/cpumask.c
@@ -140,7 +140,7 @@ EXPORT_SYMBOL(zalloc_cpumask_var);
  */
 void __init alloc_bootmem_cpumask_var(cpumask_var_t *mask)
 {
-	*mask = alloc_bootmem(cpumask_size());
+	*mask = memblock_virt_alloc(cpumask_size());
 }
 
 /**
@@ -161,6 +161,6 @@ EXPORT_SYMBOL(free_cpumask_var);
  */
 void __init free_bootmem_cpumask_var(cpumask_var_t mask)
 {
-	free_bootmem(__pa(mask), cpumask_size());
+	memblock_free_early(__pa(mask), cpumask_size());
 }
 #endif
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
