Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 7F95D6B025E
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 12:53:09 -0500 (EST)
Received: by pfcc203 with SMTP id c203so7498049pfc.1
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 09:53:09 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id a1si2438342pas.56.2015.12.11.09.53.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Dec 2015 09:53:07 -0800 (PST)
Received: by pacwq6 with SMTP id wq6so68563709pac.1
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 09:53:07 -0800 (PST)
From: Daniel Cashman <dcashman@android.com>
Subject: [PATCH v6 1/4] mm: mmap: Add new /proc tunable for mmap_base ASLR.
Date: Fri, 11 Dec 2015 09:52:15 -0800
Message-Id: <1449856338-30984-2-git-send-email-dcashman@android.com>
In-Reply-To: <1449856338-30984-1-git-send-email-dcashman@android.com>
References: <1449856338-30984-1-git-send-email-dcashman@android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux@arm.linux.org.uk, akpm@linux-foundation.org, keescook@chromium.org, mingo@kernel.org, linux-arm-kernel@lists.infradead.org, corbet@lwn.net, dzickus@redhat.com, ebiederm@xmission.com, xypron.glpk@gmx.de, jpoimboe@redhat.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mgorman@suse.de, tglx@linutronix.de, rientjes@google.com, linux-mm@kvack.org, linux-doc@vger.kernel.org, salyzyn@android.com, jeffv@google.com, nnk@google.com, catalin.marinas@arm.com, will.deacon@arm.com, hpa@zytor.com, x86@kernel.org, hecmargi@upv.es, bp@suse.de, dcashman@google.com, arnd@arndb.de, jonathanh@nvidia.com, Daniel Cashman <dcashman@android.com>

From: dcashman <dcashman@google.com>

ASLR  only uses as few as 8 bits to generate the random offset for the
mmap base address on 32 bit architectures. This value was chosen to
prevent a poorly chosen value from dividing the address space in such
a way as to prevent large allocations. This may not be an issue on all
platforms. Allow the specification of a minimum number of bits so that
platforms desiring greater ASLR protection may determine where to place
the trade-off.

Signed-off-by: Daniel Cashman <dcashman@android.com>
---
 Documentation/sysctl/vm.txt | 29 +++++++++++++++++++
 arch/Kconfig                | 68 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/mm.h          | 11 ++++++++
 kernel/sysctl.c             | 22 +++++++++++++++
 mm/mmap.c                   | 12 ++++++++
 5 files changed, 142 insertions(+)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index f72370b..ee763f3 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -42,6 +42,8 @@ Currently, these files are in /proc/sys/vm:
 - min_slab_ratio
 - min_unmapped_ratio
 - mmap_min_addr
+- mmap_rnd_bits
+- mmap_rnd_compat_bits
 - nr_hugepages
 - nr_overcommit_hugepages
 - nr_trim_pages         (only if CONFIG_MMU=n)
@@ -485,6 +487,33 @@ against future potential kernel bugs.
 
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
+/proc/sys/vm/mmap_rnd_bits tunable
+
+==============================================================
+
+mmap_rnd_compat_bits:
+
+This value can be used to select the number of bits to use to
+determine the random offset to the base address of vma regions
+resulting from mmap allocations for applications run in
+compatibility mode on architectures which support tuning address
+space randomization.  This value will be bounded by the
+architecture's minimum and maximum supported values.
+
+This value can be changed after boot using the
+/proc/sys/vm/mmap_rnd_compat_bits tunable
+
+==============================================================
+
 nr_hugepages
 
 Change the minimum size of the hugepage pool.
diff --git a/arch/Kconfig b/arch/Kconfig
index 4e949e5..ba1b626 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -511,6 +511,74 @@ config ARCH_HAS_ELF_RANDOMIZE
 	  - arch_mmap_rnd()
 	  - arch_randomize_brk()
 
+config HAVE_ARCH_MMAP_RND_BITS
+	bool
+	help
+	  An arch should select this symbol if it supports setting a variable
+	  number of bits for use in establishing the base address for mmap
+	  allocations, has MMU enabled and provides values for both:
+	  - ARCH_MMAP_RND_BITS_MIN
+	  - ARCH_MMAP_RND_BITS_MAX
+
+config ARCH_MMAP_RND_BITS_MIN
+	int
+
+config ARCH_MMAP_RND_BITS_MAX
+	int
+
+config ARCH_MMAP_RND_BITS_DEFAULT
+	int
+
+config ARCH_MMAP_RND_BITS
+	int "Number of bits to use for ASLR of mmap base address" if EXPERT
+	range ARCH_MMAP_RND_BITS_MIN ARCH_MMAP_RND_BITS_MAX
+	default ARCH_MMAP_RND_BITS_DEFAULT if ARCH_MMAP_RND_BITS_DEFAULT
+	default ARCH_MMAP_RND_BITS_MIN
+	depends on HAVE_ARCH_MMAP_RND_BITS
+	help
+	  This value can be used to select the number of bits to use to
+	  determine the random offset to the base address of vma regions
+	  resulting from mmap allocations. This value will be bounded
+	  by the architecture's minimum and maximum supported values.
+
+	  This value can be changed after boot using the
+	  /proc/sys/vm/mmap_rnd_bits tunable
+
+config HAVE_ARCH_MMAP_RND_COMPAT_BITS
+	bool
+	help
+	  An arch should select this symbol if it supports running applications
+	  in compatibility mode, supports setting a variable number of bits for
+	  use in establishing the base address for mmap allocations, has MMU
+	  enabled and provides values for both:
+	  - ARCH_MMAP_RND_COMPAT_BITS_MIN
+	  - ARCH_MMAP_RND_COMPAT_BITS_MAX
+
+config ARCH_MMAP_RND_COMPAT_BITS_MIN
+	int
+
+config ARCH_MMAP_RND_COMPAT_BITS_MAX
+	int
+
+config ARCH_MMAP_RND_COMPAT_BITS_DEFAULT
+	int
+
+config ARCH_MMAP_RND_COMPAT_BITS
+	int "Number of bits to use for ASLR of mmap base address for compatible applications" if EXPERT
+	range ARCH_MMAP_RND_COMPAT_BITS_MIN ARCH_MMAP_RND_COMPAT_BITS_MAX
+	default ARCH_MMAP_RND_COMPAT_BITS_DEFAULT if ARCH_MMAP_RND_COMPAT_BITS_DEFAULT
+	default ARCH_MMAP_RND_COMPAT_BITS_MIN
+	depends on HAVE_ARCH_MMAP_RND_COMPAT_BITS
+	help
+	  This value can be used to select the number of bits to use to
+	  determine the random offset to the base address of vma regions
+	  resulting from mmap allocations for compatible applications This
+	  value will be bounded by the architecture's minimum and maximum
+	  supported values.
+
+	  This value can be changed after boot using the
+	  /proc/sys/vm/mmap_rnd_compat_bits tunable
+
 config HAVE_COPY_THREAD_TLS
 	bool
 	help
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 00bad77..6f6dd6e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -51,6 +51,17 @@ extern int sysctl_legacy_va_layout;
 #define sysctl_legacy_va_layout 0
 #endif
 
+#ifdef CONFIG_HAVE_ARCH_MMAP_RND_BITS
+extern const int mmap_rnd_bits_min;
+extern const int mmap_rnd_bits_max;
+extern int mmap_rnd_bits __read_mostly;
+#endif
+#ifdef CONFIG_HAVE_ARCH_MMAP_RND_COMPAT_BITS
+extern const int mmap_rnd_compat_bits_min;
+extern const int mmap_rnd_compat_bits_max;
+extern int mmap_rnd_compat_bits __read_mostly;
+#endif
+
 #include <asm/page.h>
 #include <asm/pgtable.h>
 #include <asm/processor.h>
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index dc6858d..d5e7e24 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1568,6 +1568,28 @@ static struct ctl_table vm_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_doulongvec_minmax,
 	},
+#ifdef CONFIG_HAVE_ARCH_MMAP_RND_BITS
+	{
+		.procname	= "mmap_rnd_bits",
+		.data		= &mmap_rnd_bits,
+		.maxlen		= sizeof(mmap_rnd_bits),
+		.mode		= 0600,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= (void *)&mmap_rnd_bits_min,
+		.extra2		= (void *)&mmap_rnd_bits_max,
+	},
+#endif
+#ifdef CONFIG_HAVE_ARCH_MMAP_RND_COMPAT_BITS
+	{
+		.procname	= "mmap_rnd_compat_bits",
+		.data		= &mmap_rnd_compat_bits,
+		.maxlen		= sizeof(mmap_rnd_compat_bits),
+		.mode		= 0600,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= (void *)&mmap_rnd_compat_bits_min,
+		.extra2		= (void *)&mmap_rnd_compat_bits_max,
+	},
+#endif
 	{ }
 };
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 2ce04a6..fe3816c 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -58,6 +58,18 @@
 #define arch_rebalance_pgtables(addr, len)		(addr)
 #endif
 
+#ifdef CONFIG_HAVE_ARCH_MMAP_RND_BITS
+const int mmap_rnd_bits_min = CONFIG_ARCH_MMAP_RND_BITS_MIN;
+const int mmap_rnd_bits_max = CONFIG_ARCH_MMAP_RND_BITS_MAX;
+int mmap_rnd_bits __read_mostly = CONFIG_ARCH_MMAP_RND_BITS;
+#endif
+#ifdef CONFIG_HAVE_ARCH_MMAP_RND_COMPAT_BITS
+const int mmap_rnd_compat_bits_min = CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MIN;
+const int mmap_rnd_compat_bits_max = CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MAX;
+int mmap_rnd_compat_bits __read_mostly = CONFIG_ARCH_MMAP_RND_COMPAT_BITS;
+#endif
+
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
