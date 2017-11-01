Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 226A76B0038
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 17:21:24 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id z3so1900106wme.21
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 14:21:24 -0700 (PDT)
Received: from 1wt.eu (wtarreau.pck.nerim.net. [62.212.114.60])
        by mx.google.com with ESMTP id q14si1447304wre.60.2017.11.01.14.21.22
        for <linux-mm@kvack.org>;
        Wed, 01 Nov 2017 14:21:22 -0700 (PDT)
From: Willy Tarreau <w@1wt.eu>
Subject: [PATCH 3.10 011/139] mm/page_alloc: Remove kernel address exposure in free_reserved_area()
Date: Wed,  1 Nov 2017 22:17:11 +0100
Message-Id: <1509571159-4405-12-git-send-email-w@1wt.eu>
In-Reply-To: <1509571159-4405-1-git-send-email-w@1wt.eu>
References: <1509571159-4405-1-git-send-email-w@1wt.eu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org, linux@roeck-us.net
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, Willy Tarreau <w@1wt.eu>

From: Josh Poimboeuf <jpoimboe@redhat.com>

commit adb1fe9ae2ee6ef6bc10f3d5a588020e7664dfa7 upstream.

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
Signed-off-by: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/6836ff90c45b71d38e5d4405aec56fa9e5d1d4b2.1477405374.git.jpoimboe@redhat.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Willy Tarreau <w@1wt.eu>
---
 mm/page_alloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4e89275..829ee76 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5177,8 +5177,8 @@ unsigned long free_reserved_area(unsigned long start, unsigned long end,
 	}
 
 	if (pages && s)
-		pr_info("Freeing %s memory: %ldK (%lx - %lx)\n",
-			s, pages << (PAGE_SHIFT - 10), start, end);
+		pr_info("Freeing %s memory: %ldK\n",
+			s, pages << (PAGE_SHIFT - 10));
 
 	return pages;
 }
-- 
2.8.0.rc2.1.gbe9624a

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
