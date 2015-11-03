Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 56D776B0254
	for <linux-mm@kvack.org>; Tue,  3 Nov 2015 13:10:20 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so25006919pab.0
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 10:10:20 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id qb9si1076340pac.90.2015.11.03.10.10.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Nov 2015 10:10:19 -0800 (PST)
Received: by padhx2 with SMTP id hx2so17165533pad.1
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 10:10:19 -0800 (PST)
From: Daniel Cashman <dcashman@android.com>
Subject: [PATCH v2 2/2] arm: mm: support ARCH_MMAP_RND_BITS.
Date: Tue,  3 Nov 2015 10:10:04 -0800
Message-Id: <1446574204-15567-2-git-send-email-dcashman@android.com>
In-Reply-To: <1446574204-15567-1-git-send-email-dcashman@android.com>
References: <1446574204-15567-1-git-send-email-dcashman@android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux@arm.linux.org.uk, akpm@linux-foundation.org, keescook@chromium.org, mingo@kernel.org, linux-arm-kernel@lists.infradead.org, corbet@lwn.net, dzickus@redhat.com, ebiederm@xmission.com, xypron.glpk@gmx.de, jpoimboe@redhat.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mgorman@suse.de, tglx@linutronix.de, rientjes@google.com, linux-mm@kvack.org, linux-doc@vger.kernel.org, salyzyn@android.com, jeffv@google.com, nnk@google.com, dcashman <dcashman@google.com>

From: dcashman <dcashman@google.com>

arm: arch_mmap_rnd() uses a hard-code value of 8 to generate the
random offset for the mmap base address.  This value represents a
compromise between increased ASLR effectiveness and avoiding
address-space fragmentation. Replace it with a Kconfig option, which
is sensibly bounded, so that platform developers may choose where to
place this compromise. Keep 8 as the minimum acceptable value.

Signed-off-by: Daniel Cashman <dcashman@google.com>
---
Changes in v2:
  - Changed arch/arm/Kconfig and arch/arm/mm/mmap.c to reflect changes
  in [PATCH v2 1/2], specifically the movement of variables to global
  rather than arch-specific files.

 arch/arm/Kconfig   | 10 ++++++++++
 arch/arm/mm/mmap.c |  3 +--
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 639411f..47d7561 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -35,6 +35,7 @@ config ARM
 	select HAVE_ARCH_BITREVERSE if (CPU_32v7M || CPU_32v7) && !CPU_32v6
 	select HAVE_ARCH_JUMP_LABEL if !XIP_KERNEL && !CPU_ENDIAN_BE32
 	select HAVE_ARCH_KGDB if !CPU_ENDIAN_BE32
+	select HAVE_ARCH_MMAP_RND_BITS
 	select HAVE_ARCH_SECCOMP_FILTER if (AEABI && !OABI_COMPAT)
 	select HAVE_ARCH_TRACEHOOK
 	select HAVE_BPF_JIT
@@ -306,6 +307,15 @@ config MMU
 	  Select if you want MMU-based virtualised addressing space
 	  support by paged memory management. If unsure, say 'Y'.
 
+config ARCH_MMAP_RND_BITS_MIN
+	default 8
+
+config ARCH_MMAP_RND_BITS_MAX
+	default 14 if MMU && PAGE_OFFSET=0x40000000
+	default 15 if MMU && PAGE_OFFSET=0x80000000
+	default 16 if MMU
+	default 8
+
 #
 # The "ARM system type" choice list is ordered alphabetically by option
 # text.  Please add new entries in the option alphabetic order.
diff --git a/arch/arm/mm/mmap.c b/arch/arm/mm/mmap.c
index 407dc78..c938693 100644
--- a/arch/arm/mm/mmap.c
+++ b/arch/arm/mm/mmap.c
@@ -173,8 +173,7 @@ unsigned long arch_mmap_rnd(void)
 {
 	unsigned long rnd;
 
-	/* 8 bits of randomness in 20 address space bits */
-	rnd = (unsigned long)get_random_int() % (1 << 8);
+	rnd = (unsigned long)get_random_int() % (1 << mmap_rnd_bits);
 
 	return rnd << PAGE_SHIFT;
 }
-- 
2.6.0.rc2.230.g3dd15c0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
