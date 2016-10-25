Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 139266B026B
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 10:51:24 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id z82so215359847qkb.7
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 07:51:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p20si13713640qki.47.2016.10.25.07.51.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Oct 2016 07:51:23 -0700 (PDT)
From: Josh Poimboeuf <jpoimboe@redhat.com>
Subject: [PATCH 4/4] mm: remove kernel address exposure in free_reserved_area()
Date: Tue, 25 Oct 2016 09:51:14 -0500
Message-Id: <6836ff90c45b71d38e5d4405aec56fa9e5d1d4b2.1477405374.git.jpoimboe@redhat.com>
In-Reply-To: <cover.1477405374.git.jpoimboe@redhat.com>
References: <cover.1477405374.git.jpoimboe@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org

Linus suggested we try to remove some of the low-hanging fruit related
to kernel address exposure in dmesg.  The only leaks I see on my local
system are:

  Freeing SMP alternatives memory: 32K (ffffffff9e309000 - ffffffff9e311000)
  Freeing initrd memory: 10588K (ffffa0b736b42000 - ffffa0b737599000)
  Freeing unused kernel memory: 3592K (ffffffff9df87000 - ffffffff9e309000)
  Freeing unused kernel memory: 1352K (ffffa0b7288ae000 - ffffa0b728a00000)
  Freeing unused kernel memory: 632K (ffffa0b728d62000 - ffffa0b728e00000)

Linus says:

  "I suspect we should just remove [the addresses in the 'Freeing'
   messages]. I'm sure they are useful in theory, but I suspect they
   were more useful back when the whole "free init memory" was
   originally done.

   These days, if we have a use-after-free, I suspect the init-mem
   situation is the easiest situation by far. Compared to all the dynamic
   allocations which are much more likely to show it anyway. So having
   debug output for that case is likely not all that productive."

With this patch the freeing messages now look like this:

  Freeing SMP alternatives memory: 32K
  Freeing initrd memory: 10588K
  Freeing unused kernel memory: 3592K
  Freeing unused kernel memory: 1352K
  Freeing unused kernel memory: 632K

Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm@kvack.org
Signed-off-by: Josh Poimboeuf <jpoimboe@redhat.com>
---
 mm/page_alloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2b3bf67..3f63973 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6508,8 +6508,8 @@ unsigned long free_reserved_area(void *start, void *end, int poison, char *s)
 	}
 
 	if (pages && s)
-		pr_info("Freeing %s memory: %ldK (%p - %p)\n",
-			s, pages << (PAGE_SHIFT - 10), start, end);
+		pr_info("Freeing %s memory: %ldK\n",
+			s, pages << (PAGE_SHIFT - 10));
 
 	return pages;
 }
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
