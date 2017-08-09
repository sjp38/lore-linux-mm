Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 42C8D6B02FA
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 16:43:05 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id y206so747065wmd.1
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 13:43:05 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l197si391952wmg.133.2017.08.09.13.43.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Aug 2017 13:43:03 -0700 (PDT)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 3.18 61/92] mm/page_alloc: Remove kernel address exposure in free_reserved_area()
Date: Wed,  9 Aug 2017 13:37:29 -0700
Message-Id: <20170809202158.029630560@linuxfoundation.org>
In-Reply-To: <20170809202155.435709888@linuxfoundation.org>
References: <20170809202155.435709888@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, Kees Cook <keescook@google.com>

3.18-stable review patch.  If anyone has any objections, please let me know.

------------------

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
Cc: Kees Cook <keescook@google.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 mm/page_alloc.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5467,8 +5467,8 @@ unsigned long free_reserved_area(void *s
 	}
 
 	if (pages && s)
-		pr_info("Freeing %s memory: %ldK (%p - %p)\n",
-			s, pages << (PAGE_SHIFT - 10), start, end);
+		pr_info("Freeing %s memory: %ldK\n",
+			s, pages << (PAGE_SHIFT - 10));
 
 	return pages;
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
