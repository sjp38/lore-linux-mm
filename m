Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id E35C36B026F
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 23:10:31 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id u22so17051004otd.13
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 20:10:31 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r22si11150375oie.55.2017.11.27.20.10.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 20:10:31 -0800 (PST)
From: Josh Poimboeuf <jpoimboe@redhat.com>
Subject: [PATCH 2/2] x86/mm/kaiser: Don't map the IRQ stack in user space
Date: Mon, 27 Nov 2017 22:10:13 -0600
Message-Id: <17ffd1c6e87772d110f96f8ff6c8e74f681258c8.1511842148.git.jpoimboe@redhat.com>
In-Reply-To: <cover.1511842148.git.jpoimboe@redhat.com>
References: <cover.1511842148.git.jpoimboe@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

The '.data..percpu..first' section, which contains the IRQ software
stack, is included in the percpu user-mapped data area.

The IRQ stack is a software stack which is switched to *after* the CR3
switch, so it doesn't make sense to map it in user space.

Unmap it, and make sure the user-mapped area is page-aligned so it can
be mapped cleanly.

Fixes: 7d1b4c99a605 ("x86/mm/kaiser: Introduce user-mapped per-CPU areas")
Signed-off-by: Josh Poimboeuf <jpoimboe@redhat.com>
---
 include/asm-generic/vmlinux.lds.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/asm-generic/vmlinux.lds.h b/include/asm-generic/vmlinux.lds.h
index 386f8846d9e9..45d2fbb081c6 100644
--- a/include/asm-generic/vmlinux.lds.h
+++ b/include/asm-generic/vmlinux.lds.h
@@ -826,9 +826,9 @@
  */
 #define PERCPU_INPUT(cacheline)						\
 	VMLINUX_SYMBOL(__per_cpu_start) = .;				\
-	VMLINUX_SYMBOL(__per_cpu_user_mapped_start) = .;		\
 	*(.data..percpu..first)						\
-	. = ALIGN(cacheline);						\
+	. = ALIGN(PAGE_SIZE);						\
+	VMLINUX_SYMBOL(__per_cpu_user_mapped_start) = .;		\
 	*(.data..percpu..user_mapped)					\
 	*(.data..percpu..user_mapped..shared_aligned)			\
 	VMLINUX_SYMBOL(__per_cpu_user_mapped_end) = .;			\
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
