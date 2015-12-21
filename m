Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id D0E1D6B0009
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 12:27:40 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id cy9so20582559pac.0
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 09:27:40 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id fk10si4978896pab.187.2015.12.21.09.27.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Dec 2015 09:27:40 -0800 (PST)
Received: by mail-pa0-x22d.google.com with SMTP id wq6so102583219pac.1
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 09:27:39 -0800 (PST)
From: Daniel Cashman <dcashman@android.com>
Subject: [PATCH v7 2/4] arm: mm: support ARCH_MMAP_RND_BITS.
Date: Mon, 21 Dec 2015 09:26:55 -0800
Message-Id: <1450718817-7082-3-git-send-email-dcashman@android.com>
In-Reply-To: <1450718817-7082-2-git-send-email-dcashman@android.com>
References: <1450718817-7082-1-git-send-email-dcashman@android.com>
 <1450718817-7082-2-git-send-email-dcashman@android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux@arm.linux.org.uk, akpm@linux-foundation.org, keescook@chromium.org, mingo@kernel.org, linux-arm-kernel@lists.infradead.org, corbet@lwn.net, dzickus@redhat.com, ebiederm@xmission.com, xypron.glpk@gmx.de, jpoimboe@redhat.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mgorman@suse.de, tglx@linutronix.de, rientjes@google.com, linux-mm@kvack.org, linux-doc@vger.kernel.org, salyzyn@android.com, jeffv@google.com, nnk@google.com, catalin.marinas@arm.com, will.deacon@arm.com, hpa@zytor.com, x86@kernel.org, hecmargi@upv.es, bp@suse.de, dcashman@google.com, arnd@arndb.de, jonathanh@nvidia.com, Daniel Cashman <dcashman@android.com>

From: dcashman <dcashman@google.com>

arm: arch_mmap_rnd() uses a hard-code value of 8 to generate the
random offset for the mmap base address.  This value represents a
compromise between increased ASLR effectiveness and avoiding
address-space fragmentation. Replace it with a Kconfig option, which
is sensibly bounded, so that platform developers may choose where to
place this compromise. Keep 8 as the minimum acceptable value.

Signed-off-by: Daniel Cashman <dcashman@android.com>
---
 arch/arm/Kconfig   | 9 +++++++++
 arch/arm/mm/mmap.c | 3 +--
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 34e1569..a1b8ca1 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -35,6 +35,7 @@ config ARM
 	select HAVE_ARCH_BITREVERSE if (CPU_32v7M || CPU_32v7) && !CPU_32v6
 	select HAVE_ARCH_JUMP_LABEL if !XIP_KERNEL && !CPU_ENDIAN_BE32
 	select HAVE_ARCH_KGDB if !CPU_ENDIAN_BE32
+	select HAVE_ARCH_MMAP_RND_BITS if MMU
 	select HAVE_ARCH_SECCOMP_FILTER if (AEABI && !OABI_COMPAT)
 	select HAVE_ARCH_TRACEHOOK
 	select HAVE_BPF_JIT
@@ -308,6 +309,14 @@ config MMU
 	  Select if you want MMU-based virtualised addressing space
 	  support by paged memory management. If unsure, say 'Y'.
 
+config ARCH_MMAP_RND_BITS_MIN
+	default 8
+
+config ARCH_MMAP_RND_BITS_MAX
+	default 14 if PAGE_OFFSET=0x40000000
+	default 15 if PAGE_OFFSET=0x80000000
+	default 16
+
 #
 # The "ARM system type" choice list is ordered alphabetically by option
 # text.  Please add new entries in the option alphabetic order.
diff --git a/arch/arm/mm/mmap.c b/arch/arm/mm/mmap.c
index 407dc78..4b4058d 100644
--- a/arch/arm/mm/mmap.c
+++ b/arch/arm/mm/mmap.c
@@ -173,8 +173,7 @@ unsigned long arch_mmap_rnd(void)
 {
 	unsigned long rnd;
 
-	/* 8 bits of randomness in 20 address space bits */
-	rnd = (unsigned long)get_random_int() % (1 << 8);
+	rnd = (unsigned long)get_random_int() & ((1 << mmap_rnd_bits) - 1);
 
 	return rnd << PAGE_SHIFT;
 }
-- 
2.6.0.rc2.230.g3dd15c0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
