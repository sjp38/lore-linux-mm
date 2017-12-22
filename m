Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 711566B0038
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 03:48:27 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id v63so12153079oif.7
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 00:48:27 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n6si4640027otb.65.2017.12.22.00.48.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Dec 2017 00:48:26 -0800 (PST)
From: Baoquan He <bhe@redhat.com>
Subject: [PATCH] mm/sparse.c: Wrong allocation for mem_section
Date: Fri, 22 Dec 2017 16:48:18 +0800
Message-Id: <1513932498-20350-1-git-send-email-bhe@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Baoquan He <bhe@redhat.com>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Atsushi Kumagai <ats-kumagai@wm.jp.nec.com>, linux-mm@kvack.org

In commit

  83e3c48729 "mm/sparsemem: Allocate mem_section at runtime for CONFIG_SPARSEMEM_EXTREME=y"

mem_section is allocated at runtime to save memory. While it allocates
the first dimension of array with sizeof(struct mem_section). It costs 
extra memory, should be sizeof(struct mem_section*).

Fix it.

Signed-off-by: Baoquan He <bhe@redhat.com>
Tested-by: Dave Young <dyoung@redhat.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Atsushi Kumagai <ats-kumagai@wm.jp.nec.com>
Cc: linux-mm@kvack.org

---
 mm/sparse.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 7a5dacaa06e3..2609aba121e8 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -211,7 +211,7 @@ void __init memory_present(int nid, unsigned long start, unsigned long end)
 	if (unlikely(!mem_section)) {
 		unsigned long size, align;
 
-		size = sizeof(struct mem_section) * NR_SECTION_ROOTS;
+		size = sizeof(struct mem_section*) * NR_SECTION_ROOTS;
 		align = 1 << (INTERNODE_CACHE_SHIFT);
 		mem_section = memblock_virt_alloc(size, align);
 	}
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
