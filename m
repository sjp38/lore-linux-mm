Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AAE91440D2B
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 14:31:28 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id r6so8422680pfj.14
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 11:31:28 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id c4si9090045pgt.539.2017.11.10.11.31.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Nov 2017 11:31:27 -0800 (PST)
Subject: [PATCH 06/30] x86, kaiser: introduce user-mapped per-cpu areas
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 10 Nov 2017 11:31:08 -0800
References: <20171110193058.BECA7D88@viggo.jf.intel.com>
In-Reply-To: <20171110193058.BECA7D88@viggo.jf.intel.com>
Message-Id: <20171110193108.64CF4EF1@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

These patches are based on work from a team at Graz University of
Technology posted here: https://github.com/IAIK/KAISER

The KAISER approach keeps two copies of the page tables: one for running
in the kernel and one for running userspace.  But, there are a few
structures that are needed for switching in and out of the kernel and
a good subset of *those* are per-cpu data.

This patch creates a new kind of per-cpu data that is mapped and
can be used no matter which copy of the page tables is active.
Users of this new section will be forthcoming.

Thanks to Hugh Dickins for cleanups to this code.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
Cc: Richard Fellner <richard.fellner@student.tugraz.at>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: x86@kernel.org
---

 b/include/asm-generic/vmlinux.lds.h |    7 +++++++
 b/include/linux/percpu-defs.h       |   30 ++++++++++++++++++++++++++++++
 2 files changed, 37 insertions(+)

diff -puN include/asm-generic/vmlinux.lds.h~kaiser-prep-user-mapped-percpu include/asm-generic/vmlinux.lds.h
--- a/include/asm-generic/vmlinux.lds.h~kaiser-prep-user-mapped-percpu	2017-11-10 11:22:07.802244953 -0800
+++ b/include/asm-generic/vmlinux.lds.h	2017-11-10 11:22:07.807244953 -0800
@@ -807,7 +807,14 @@
  */
 #define PERCPU_INPUT(cacheline)						\
 	VMLINUX_SYMBOL(__per_cpu_start) = .;				\
+	VMLINUX_SYMBOL(__per_cpu_user_mapped_start) = .;		\
 	*(.data..percpu..first)						\
+	. = ALIGN(cacheline);						\
+	*(.data..percpu..user_mapped)					\
+	*(.data..percpu..user_mapped..shared_aligned)			\
+	. = ALIGN(PAGE_SIZE);						\
+	*(.data..percpu..user_mapped..page_aligned)			\
+	VMLINUX_SYMBOL(__per_cpu_user_mapped_end) = .;			\
 	. = ALIGN(PAGE_SIZE);						\
 	*(.data..percpu..page_aligned)					\
 	. = ALIGN(cacheline);						\
diff -puN include/linux/percpu-defs.h~kaiser-prep-user-mapped-percpu include/linux/percpu-defs.h
--- a/include/linux/percpu-defs.h~kaiser-prep-user-mapped-percpu	2017-11-10 11:22:07.804244953 -0800
+++ b/include/linux/percpu-defs.h	2017-11-10 11:22:07.807244953 -0800
@@ -35,6 +35,12 @@
 
 #endif
 
+#ifdef CONFIG_KAISER
+#define USER_MAPPED_SECTION "..user_mapped"
+#else
+#define USER_MAPPED_SECTION ""
+#endif
+
 /*
  * Base implementations of per-CPU variable declarations and definitions, where
  * the section in which the variable is to be placed is provided by the
@@ -115,6 +121,12 @@
 #define DEFINE_PER_CPU(type, name)					\
 	DEFINE_PER_CPU_SECTION(type, name, "")
 
+#define DECLARE_PER_CPU_USER_MAPPED(type, name)				\
+	DECLARE_PER_CPU_SECTION(type, name, USER_MAPPED_SECTION)
+
+#define DEFINE_PER_CPU_USER_MAPPED(type, name)				\
+	DEFINE_PER_CPU_SECTION(type, name, USER_MAPPED_SECTION)
+
 /*
  * Declaration/definition used for per-CPU variables that must come first in
  * the set of variables.
@@ -144,6 +156,14 @@
 	DEFINE_PER_CPU_SECTION(type, name, PER_CPU_SHARED_ALIGNED_SECTION) \
 	____cacheline_aligned_in_smp
 
+#define DECLARE_PER_CPU_SHARED_ALIGNED_USER_MAPPED(type, name)		\
+	DECLARE_PER_CPU_SECTION(type, name, USER_MAPPED_SECTION PER_CPU_SHARED_ALIGNED_SECTION) \
+	____cacheline_aligned_in_smp
+
+#define DEFINE_PER_CPU_SHARED_ALIGNED_USER_MAPPED(type, name)		\
+	DEFINE_PER_CPU_SECTION(type, name, USER_MAPPED_SECTION PER_CPU_SHARED_ALIGNED_SECTION) \
+	____cacheline_aligned_in_smp
+
 #define DECLARE_PER_CPU_ALIGNED(type, name)				\
 	DECLARE_PER_CPU_SECTION(type, name, PER_CPU_ALIGNED_SECTION)	\
 	____cacheline_aligned
@@ -162,6 +182,16 @@
 #define DEFINE_PER_CPU_PAGE_ALIGNED(type, name)				\
 	DEFINE_PER_CPU_SECTION(type, name, "..page_aligned")		\
 	__aligned(PAGE_SIZE)
+/*
+ * Declaration/definition used for per-CPU variables that must be page aligned and need to be mapped in user mode.
+ */
+#define DECLARE_PER_CPU_PAGE_ALIGNED_USER_MAPPED(type, name)		\
+	DECLARE_PER_CPU_SECTION(type, name, USER_MAPPED_SECTION"..page_aligned") \
+	__aligned(PAGE_SIZE)
+
+#define DEFINE_PER_CPU_PAGE_ALIGNED_USER_MAPPED(type, name)		\
+	DEFINE_PER_CPU_SECTION(type, name, USER_MAPPED_SECTION"..page_aligned") \
+	__aligned(PAGE_SIZE)
 
 /*
  * Declaration/definition used for per-CPU variables that must be read mostly.
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
