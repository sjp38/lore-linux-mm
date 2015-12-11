Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 09AD26B0260
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 12:53:22 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so68764726pac.3
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 09:53:21 -0800 (PST)
Received: from mail-pf0-x233.google.com (mail-pf0-x233.google.com. [2607:f8b0:400e:c00::233])
        by mx.google.com with ESMTPS id hh1si2440690pac.44.2015.12.11.09.53.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Dec 2015 09:53:20 -0800 (PST)
Received: by pfd5 with SMTP id 5so7791918pfd.2
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 09:53:20 -0800 (PST)
From: Daniel Cashman <dcashman@android.com>
Subject: [PATCH v6 3/4] arm64: mm: support ARCH_MMAP_RND_BITS.
Date: Fri, 11 Dec 2015 09:52:17 -0800
Message-Id: <1449856338-30984-4-git-send-email-dcashman@android.com>
In-Reply-To: <1449856338-30984-3-git-send-email-dcashman@android.com>
References: <1449856338-30984-1-git-send-email-dcashman@android.com>
 <1449856338-30984-2-git-send-email-dcashman@android.com>
 <1449856338-30984-3-git-send-email-dcashman@android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux@arm.linux.org.uk, akpm@linux-foundation.org, keescook@chromium.org, mingo@kernel.org, linux-arm-kernel@lists.infradead.org, corbet@lwn.net, dzickus@redhat.com, ebiederm@xmission.com, xypron.glpk@gmx.de, jpoimboe@redhat.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mgorman@suse.de, tglx@linutronix.de, rientjes@google.com, linux-mm@kvack.org, linux-doc@vger.kernel.org, salyzyn@android.com, jeffv@google.com, nnk@google.com, catalin.marinas@arm.com, will.deacon@arm.com, hpa@zytor.com, x86@kernel.org, hecmargi@upv.es, bp@suse.de, dcashman@google.com, arnd@arndb.de, jonathanh@nvidia.com, Daniel Cashman <dcashman@android.com>

From: dcashman <dcashman@google.com>

arm64: arch_mmap_rnd() uses STACK_RND_MASK to generate the
random offset for the mmap base address.  This value represents a
compromise between increased ASLR effectiveness and avoiding
address-space fragmentation. Replace it with a Kconfig option, which
is sensibly bounded, so that platform developers may choose where to
place this compromise. Keep default values as new minimums.

Signed-off-by: Daniel Cashman <dcashman@android.com>
---
 arch/arm64/Kconfig   | 33 +++++++++++++++++++++++++++++++++
 arch/arm64/mm/mmap.c |  8 ++++++--
 2 files changed, 39 insertions(+), 2 deletions(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 871f217..0cc9c24 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -51,6 +51,8 @@ config ARM64
 	select HAVE_ARCH_JUMP_LABEL
 	select HAVE_ARCH_KASAN if SPARSEMEM_VMEMMAP && !(ARM64_16K_PAGES && ARM64_VA_BITS_48)
 	select HAVE_ARCH_KGDB
+	select HAVE_ARCH_MMAP_RND_BITS
+	select HAVE_ARCH_MMAP_RND_COMPAT_BITS if COMPAT
 	select HAVE_ARCH_SECCOMP_FILTER
 	select HAVE_ARCH_TRACEHOOK
 	select HAVE_BPF_JIT
@@ -104,6 +106,37 @@ config ARCH_PHYS_ADDR_T_64BIT
 config MMU
 	def_bool y
 
+config ARCH_MMAP_RND_BITS_MIN
+       default 14 if ARM64_64K_PAGES
+       default 16 if ARM64_16K_PAGES
+       default 18
+
+# max bits determined by the following formula:
+#  VA_BITS - PAGE_SHIFT - 3
+config ARCH_MMAP_RND_BITS_MAX
+       default 19 if ARM64_VA_BITS=36
+       default 20 if ARM64_64K_PAGES && ARM64_VA_BITS=39
+       default 22 if ARM64_16K_PAGES && ARM64_VA_BITS=39
+       default 24 if ARM64_VA_BITS=39
+       default 23 if ARM64_64K_PAGES && ARM64_VA_BITS=42
+       default 25 if ARM64_16K_PAGES && ARM64_VA_BITS=42
+       default 27 if ARM64_VA_BITS=42
+       default 30 if ARM64_VA_BITS=47
+       default 29 if ARM64_64K_PAGES && ARM64_VA_BITS=48
+       default 31 if ARM64_16K_PAGES && ARM64_VA_BITS=48
+       default 33 if ARM64_VA_BITS=48
+       default 15 if ARM64_64K_PAGES
+       default 17 if ARM64_16K_PAGES
+       default 18
+
+config ARCH_MMAP_RND_COMPAT_BITS_MIN
+       default 7 if ARM64_64K_PAGES
+       default 9 if ARM64_16K_PAGES
+       default 11
+
+config ARCH_MMAP_RND_COMPAT_BITS_MAX
+       default 16
+
 config NO_IOPORT_MAP
 	def_bool y if !PCI
 
diff --git a/arch/arm64/mm/mmap.c b/arch/arm64/mm/mmap.c
index ed17747..e59a75a 100644
--- a/arch/arm64/mm/mmap.c
+++ b/arch/arm64/mm/mmap.c
@@ -51,8 +51,12 @@ unsigned long arch_mmap_rnd(void)
 {
 	unsigned long rnd;
 
-	rnd = (unsigned long)get_random_int() & STACK_RND_MASK;
-
+#ifdef CONFIG_COMPAT
+	if (test_thread_flag(TIF_32BIT))
+		rnd = (unsigned long)get_random_int() % (1 << mmap_rnd_compat_bits);
+	else
+#endif
+		rnd = (unsigned long)get_random_int() % (1 << mmap_rnd_bits);
 	return rnd << PAGE_SHIFT;
 }
 
-- 
2.6.0.rc2.230.g3dd15c0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
