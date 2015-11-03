Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 22F716B0253
	for <linux-mm@kvack.org>; Tue,  3 Nov 2015 13:10:10 -0500 (EST)
Received: by pasz6 with SMTP id z6so25185919pas.2
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 10:10:09 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id se6si1142490pbc.7.2015.11.03.10.10.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Nov 2015 10:10:09 -0800 (PST)
Received: by pasz6 with SMTP id z6so25185601pas.2
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 10:10:09 -0800 (PST)
From: Daniel Cashman <dcashman@android.com>
Subject: [PATCH v2 1/2] mm: mmap: Add new /proc tunable for mmap_base ASLR.
Date: Tue,  3 Nov 2015 10:10:03 -0800
Message-Id: <1446574204-15567-1-git-send-email-dcashman@android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux@arm.linux.org.uk, akpm@linux-foundation.org, keescook@chromium.org, mingo@kernel.org, linux-arm-kernel@lists.infradead.org, corbet@lwn.net, dzickus@redhat.com, ebiederm@xmission.com, xypron.glpk@gmx.de, jpoimboe@redhat.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mgorman@suse.de, tglx@linutronix.de, rientjes@google.com, linux-mm@kvack.org, linux-doc@vger.kernel.org, salyzyn@android.com, jeffv@google.com, nnk@google.com, dcashman <dcashman@google.com>

From: dcashman <dcashman@google.com>

ASLR currently only uses 8 bits to generate the random offset for the
mmap base address on 32 bit architectures. This value was chosen to
prevent a poorly chosen value from dividing the address space in such
a way as to prevent large allocations. This may not be an issue on all
platforms. Allow the specification of a minimum number of bits so that
platforms desiring greater ASLR protection may determine where to place
the trade-off.

Signed-off-by: Daniel Cashman <dcashman@google.com>
---
Changes in v2:
  - Added HAVE_ARCH_MMAP_RND_BITS as Kconfig boolean selector.
  - Moved ARCH_MMAP_RND_BITS_MIN, ARCH_MMAP_RND_BITS_MAX, and
  ARCH_MMAP_RND_BITS declarations to arch/Kconfig instead of relying
  soley on arch-specific Kconfigs.
  - Moved definition of mmap_rnd_bits_min, mmap_rnd_bits_max and
  mmap_rnd_bits to mm/mmap.c instead of relying solely on arch-specific
  code.

 Documentation/sysctl/kernel.txt | 14 ++++++++++++++
 arch/Kconfig                    | 29 +++++++++++++++++++++++++++++
 include/linux/mm.h              |  6 ++++++
 kernel/sysctl.c                 | 11 +++++++++++
 mm/mmap.c                       |  6 ++++++
 5 files changed, 66 insertions(+)

diff --git a/Documentation/sysctl/kernel.txt b/Documentation/sysctl/kernel.txt
index 6fccb69..0d4ca53 100644
--- a/Documentation/sysctl/kernel.txt
+++ b/Documentation/sysctl/kernel.txt
@@ -41,6 +41,7 @@ show up in /proc/sys/kernel:
 - kptr_restrict
 - kstack_depth_to_print       [ X86 only ]
 - l2cr                        [ PPC only ]
+- mmap_rnd_bits
 - modprobe                    ==> Documentation/debugging-modules.txt
 - modules_disabled
 - msg_next_id		      [ sysv ipc ]
@@ -391,6 +392,19 @@ This flag controls the L2 cache of G3 processor boards. If
 
 ==============================================================
 
+mmap_rnd_bits:
+
+This value can be used to select the number of bits to use to
+determine the random offset to the base address of vma regions
+resulting from mmap allocations on architectures which support
+tuning address space randomization.  This value will be bounded
+by the architecture's minimum and maximum supported values.
+
+This value can be changed after boot using the
+/proc/sys/kernel/mmap_rnd_bits tunable
+
+==============================================================
+
 modules_disabled:
 
 A toggle value indicating if modules are allowed to be loaded
diff --git a/arch/Kconfig b/arch/Kconfig
index 4e949e5..2133973 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -511,6 +511,35 @@ config ARCH_HAS_ELF_RANDOMIZE
 	  - arch_mmap_rnd()
 	  - arch_randomize_brk()
 
+config HAVE_ARCH_MMAP_RND_BITS
+	bool
+	help
+	  An arch should select this symbol if it supports setting a variable
+	  number of bits for use in establishing the base address for mmap
+	  allocations and provides values for both:
+	  - ARCH_MMAP_RND_BITS_MIN
+	  - ARCH_MMAP_RND_BITS_MAX
+
+config ARCH_MMAP_RND_BITS_MIN
+	int
+
+config ARCH_MMAP_RND_BITS_MAX
+	int
+
+config ARCH_MMAP_RND_BITS
+	int "Number of bits to use for ASLR of mmap base address" if EXPERT
+	range ARCH_MMAP_RND_BITS_MIN ARCH_MMAP_RND_BITS_MAX
+	default ARCH_MMAP_RND_BITS_MIN
+	depends on HAVE_ARCH_MMAP_RND_BITS
+	help
+	  This value can be used to select the number of bits to use to
+	  determine the random offset to the base address of vma regions
+	  resulting from mmap allocations. This value will be bounded
+	  by the architecture's minimum and maximum supported values.
+
+	  This value can be changed after boot using the
+	  /proc/sys/kernel/mmap_rnd_bits tunable
+
 config HAVE_COPY_THREAD_TLS
 	bool
 	help
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 80001de..ee209c1 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -51,6 +51,12 @@ extern int sysctl_legacy_va_layout;
 #define sysctl_legacy_va_layout 0
 #endif
 
+#ifdef CONFIG_HAVE_ARCH_MMAP_RND_BITS
+extern int mmap_rnd_bits_min;
+extern int mmap_rnd_bits_max;
+extern int mmap_rnd_bits;
+#endif
+
 #include <asm/page.h>
 #include <asm/pgtable.h>
 #include <asm/processor.h>
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index e69201d..276da8b 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1139,6 +1139,17 @@ static struct ctl_table kern_table[] = {
 		.proc_handler	= timer_migration_handler,
 	},
 #endif
+#ifdef CONFIG_HAVE_ARCH_MMAP_RND_BITS
+	{
+		.procname	= "mmap_rnd_bits",
+		.data		= &mmap_rnd_bits,
+		.maxlen		= sizeof(mmap_rnd_bits),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &mmap_rnd_bits_min,
+		.extra2		= &mmap_rnd_bits_max,
+	},
+#endif
 	{ }
 };
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 79bcc9f..264aa8e 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -58,6 +58,12 @@
 #define arch_rebalance_pgtables(addr, len)		(addr)
 #endif
 
+#ifdef CONFIG_HAVE_ARCH_MMAP_RND_BITS
+int mmap_rnd_bits_min = CONFIG_ARCH_MMAP_RND_BITS_MIN;
+int mmap_rnd_bits_max = CONFIG_ARCH_MMAP_RND_BITS_MAX;
+int mmap_rnd_bits = CONFIG_ARCH_MMAP_RND_BITS;
+#endif
+
 static void unmap_region(struct mm_struct *mm,
 		struct vm_area_struct *vma, struct vm_area_struct *prev,
 		unsigned long start, unsigned long end);
-- 
2.6.0.rc2.230.g3dd15c0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
