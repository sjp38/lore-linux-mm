Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id E28C66B0068
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 07:16:53 -0400 (EDT)
Received: by pbbrq2 with SMTP id rq2so5591848pbb.14
        for <linux-mm@kvack.org>; Fri, 28 Sep 2012 04:16:53 -0700 (PDT)
From: raghu.prabhu13@gmail.com
Subject: [PATCH] mm: Avoid section mismatch warning for memblock_type_name.
Date: Fri, 28 Sep 2012 16:46:44 +0530
Message-Id: <be1027442539398a9cdce6284d1e2534a27644ae.1348829645.git.rprabhu@wnohang.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: tj@kernel.org, benh@kernel.crashing.org, akpm@linux-foundation.org, Raghavendra D Prabhu <rprabhu@wnohang.net>

From: Raghavendra D Prabhu <rprabhu@wnohang.net>

Following section mismatch warning is thrown during build;

    WARNING: vmlinux.o(.text+0x32408f): Section mismatch in reference from the function memblock_type_name() to the variable .meminit.data:memblock
    The function memblock_type_name() references
    the variable __meminitdata memblock.
    This is often because memblock_type_name lacks a __meminitdata
    annotation or the annotation of memblock is wrong.

This is because memblock_type_name makes reference to memblock variable with
attribute __meminitdata. Hence, the warning (even if the function is inline).

Signed-off-by: Raghavendra D Prabhu <rprabhu@wnohang.net>
---
 mm/memblock.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 82aa349..8e7fb1f 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -41,7 +41,8 @@ static int memblock_memory_in_slab __initdata_memblock = 0;
 static int memblock_reserved_in_slab __initdata_memblock = 0;
 
 /* inline so we don't get a warning when pr_debug is compiled out */
-static inline const char *memblock_type_name(struct memblock_type *type)
+static inline __init_memblock
+		const char *memblock_type_name(struct memblock_type *type)
 {
 	if (type == &memblock.memory)
 		return "memory";
-- 
1.7.12.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
