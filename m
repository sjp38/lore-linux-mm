Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 86EA96B0261
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 12:53:33 -0500 (EST)
Received: by pfd5 with SMTP id 5so7794226pfd.2
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 09:53:33 -0800 (PST)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id fm8si2439274pad.29.2015.12.11.09.53.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Dec 2015 09:53:32 -0800 (PST)
Received: by padhk6 with SMTP id hk6so28616966pad.2
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 09:53:32 -0800 (PST)
From: Daniel Cashman <dcashman@android.com>
Subject: [PATCH v6 4/4] x86: mm: support ARCH_MMAP_RND_BITS.
Date: Fri, 11 Dec 2015 09:52:18 -0800
Message-Id: <1449856338-30984-5-git-send-email-dcashman@android.com>
In-Reply-To: <1449856338-30984-4-git-send-email-dcashman@android.com>
References: <1449856338-30984-1-git-send-email-dcashman@android.com>
 <1449856338-30984-2-git-send-email-dcashman@android.com>
 <1449856338-30984-3-git-send-email-dcashman@android.com>
 <1449856338-30984-4-git-send-email-dcashman@android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux@arm.linux.org.uk, akpm@linux-foundation.org, keescook@chromium.org, mingo@kernel.org, linux-arm-kernel@lists.infradead.org, corbet@lwn.net, dzickus@redhat.com, ebiederm@xmission.com, xypron.glpk@gmx.de, jpoimboe@redhat.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mgorman@suse.de, tglx@linutronix.de, rientjes@google.com, linux-mm@kvack.org, linux-doc@vger.kernel.org, salyzyn@android.com, jeffv@google.com, nnk@google.com, catalin.marinas@arm.com, will.deacon@arm.com, hpa@zytor.com, x86@kernel.org, hecmargi@upv.es, bp@suse.de, dcashman@google.com, arnd@arndb.de, jonathanh@nvidia.com, Daniel Cashman <dcashman@android.com>

From: dcashman <dcashman@google.com>

x86: arch_mmap_rnd() uses hard-coded values, 8 for 32-bit and 28 for
64-bit, to generate the random offset for the mmap base address.
This value represents a compromise between increased ASLR
effectiveness and avoiding address-space fragmentation. Replace it
with a Kconfig option, which is sensibly bounded, so that platform
developers may choose where to place this compromise. Keep default
values as new minimums.

Signed-off-by: Daniel Cashman <dcashman@android.com>
---
 arch/x86/Kconfig   | 16 ++++++++++++++++
 arch/x86/mm/mmap.c | 12 ++++++------
 2 files changed, 22 insertions(+), 6 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index db3622f..bdc67d2 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -82,6 +82,8 @@ config X86
 	select HAVE_ARCH_KASAN			if X86_64 && SPARSEMEM_VMEMMAP
 	select HAVE_ARCH_KGDB
 	select HAVE_ARCH_KMEMCHECK
+	select HAVE_ARCH_MMAP_RND_BITS		if MMU
+	select HAVE_ARCH_MMAP_RND_COMPAT_BITS	if MMU && COMPAT
 	select HAVE_ARCH_SECCOMP_FILTER
 	select HAVE_ARCH_SOFT_DIRTY		if X86_64
 	select HAVE_ARCH_TRACEHOOK
@@ -183,6 +185,20 @@ config HAVE_LATENCYTOP_SUPPORT
 config MMU
 	def_bool y
 
+config ARCH_MMAP_RND_BITS_MIN
+       default 28 if 64BIT
+       default 8
+
+config ARCH_MMAP_RND_BITS_MAX
+	default 32 if 64BIT
+	default 16
+
+config ARCH_MMAP_RND_COMPAT_BITS_MIN
+	default 8
+
+config ARCH_MMAP_RND_COMPAT_BITS_MAX
+	default 16
+
 config SBUS
 	bool
 
diff --git a/arch/x86/mm/mmap.c b/arch/x86/mm/mmap.c
index 844b06d..647fecf 100644
--- a/arch/x86/mm/mmap.c
+++ b/arch/x86/mm/mmap.c
@@ -69,14 +69,14 @@ unsigned long arch_mmap_rnd(void)
 {
 	unsigned long rnd;
 
-	/*
-	 *  8 bits of randomness in 32bit mmaps, 20 address space bits
-	 * 28 bits of randomness in 64bit mmaps, 40 address space bits
-	 */
 	if (mmap_is_ia32())
-		rnd = (unsigned long)get_random_int() % (1<<8);
+#ifdef CONFIG_COMPAT
+		rnd = (unsigned long)get_random_int() % (1 << mmap_rnd_compat_bits);
+#else
+		rnd = (unsigned long)get_random_int() % (1 << mmap_rnd_bits);
+#endif
 	else
-		rnd = (unsigned long)get_random_int() % (1<<28);
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
