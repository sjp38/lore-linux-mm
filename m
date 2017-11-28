Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 882136B026E
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 23:10:29 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id l138so13612677oib.0
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 20:10:29 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 7si11589155otf.215.2017.11.27.20.10.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 20:10:28 -0800 (PST)
From: Josh Poimboeuf <jpoimboe@redhat.com>
Subject: [PATCH 1/2] x86/mm/kaiser: Remove unused user-mapped page-aligned section
Date: Mon, 27 Nov 2017 22:10:12 -0600
Message-Id: <666935452d5eef100464b7314be90fccd65e795c.1511842148.git.jpoimboe@redhat.com>
In-Reply-To: <cover.1511842148.git.jpoimboe@redhat.com>
References: <cover.1511842148.git.jpoimboe@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

The '.data..percpu..user_mapped..page_aligned' section isn't used
anywhere.  Remove it and its related macros.

Signed-off-by: Josh Poimboeuf <jpoimboe@redhat.com>
---
 include/asm-generic/vmlinux.lds.h |  2 --
 include/linux/percpu-defs.h       | 10 ----------
 2 files changed, 12 deletions(-)

diff --git a/include/asm-generic/vmlinux.lds.h b/include/asm-generic/vmlinux.lds.h
index e12168936d3f..386f8846d9e9 100644
--- a/include/asm-generic/vmlinux.lds.h
+++ b/include/asm-generic/vmlinux.lds.h
@@ -831,8 +831,6 @@
 	. = ALIGN(cacheline);						\
 	*(.data..percpu..user_mapped)					\
 	*(.data..percpu..user_mapped..shared_aligned)			\
-	. = ALIGN(PAGE_SIZE);						\
-	*(.data..percpu..user_mapped..page_aligned)			\
 	VMLINUX_SYMBOL(__per_cpu_user_mapped_end) = .;			\
 	. = ALIGN(PAGE_SIZE);						\
 	*(.data..percpu..page_aligned)					\
diff --git a/include/linux/percpu-defs.h b/include/linux/percpu-defs.h
index 752513674295..40ea19ccf1ec 100644
--- a/include/linux/percpu-defs.h
+++ b/include/linux/percpu-defs.h
@@ -182,16 +182,6 @@
 #define DEFINE_PER_CPU_PAGE_ALIGNED(type, name)				\
 	DEFINE_PER_CPU_SECTION(type, name, "..page_aligned")		\
 	__aligned(PAGE_SIZE)
-/*
- * Declaration/definition used for per-CPU variables that must be page aligned and need to be mapped in user mode.
- */
-#define DECLARE_PER_CPU_PAGE_ALIGNED_USER_MAPPED(type, name)		\
-	DECLARE_PER_CPU_SECTION(type, name, USER_MAPPED_SECTION"..page_aligned") \
-	__aligned(PAGE_SIZE)
-
-#define DEFINE_PER_CPU_PAGE_ALIGNED_USER_MAPPED(type, name)		\
-	DEFINE_PER_CPU_SECTION(type, name, USER_MAPPED_SECTION"..page_aligned") \
-	__aligned(PAGE_SIZE)
 
 /*
  * Declaration/definition used for per-CPU variables that must be read mostly.
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
