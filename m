Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 0C09E82F64
	for <linux-mm@kvack.org>; Wed, 28 Oct 2015 17:26:35 -0400 (EDT)
Received: by pacfv9 with SMTP id fv9so18576090pac.3
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 14:26:34 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id tc1si42329463pac.120.2015.10.28.14.26.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Oct 2015 14:26:34 -0700 (PDT)
Received: by padhy1 with SMTP id hy1so11912666pad.0
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 14:26:34 -0700 (PDT)
From: Daniel Cashman <dcashman@android.com>
Subject: [PATCH 2/2] arm: mm: support ARCH_MMAP_RND_BITS.
Date: Wed, 28 Oct 2015 14:25:20 -0700
Message-Id: <1446067520-31806-2-git-send-email-dcashman@android.com>
In-Reply-To: <1446067520-31806-1-git-send-email-dcashman@android.com>
References: <1446067520-31806-1-git-send-email-dcashman@android.com>
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
 arch/arm/Kconfig   | 24 ++++++++++++++++++++++++
 arch/arm/mm/mmap.c |  7 +++++--
 2 files changed, 29 insertions(+), 2 deletions(-)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 639411f..d61e7e2 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -306,6 +306,30 @@ config MMU
 	  Select if you want MMU-based virtualised addressing space
 	  support by paged memory management. If unsure, say 'Y'.
 
+config ARCH_MMAP_RND_BITS_MIN
+	int
+	default 8
+
+config ARCH_MMAP_RND_BITS_MAX
+	int
+	default 14 if MMU && PAGE_OFFSET=0x40000000
+	default 15 if MMU && PAGE_OFFSET=0x80000000
+	default 16 if MMU
+	default 8
+
+config ARCH_MMAP_RND_BITS
+	int "Number of bits to use for ASLR of mmap base address" if EXPERT
+	range ARCH_MMAP_RND_BITS_MIN ARCH_MMAP_RND_BITS_MAX
+	default ARCH_MMAP_RND_BITS_MIN
+	help
+	  This value can be used to select the number of bits to use to
+	  determine the random offset to the base address of vma regions
+	  resulting from mmap allocations. This value will be bounded
+	  by the architecture's minimum and maximum supported values.
+
+	  This value can be changed after boot using the
+	  /proc/sys/kernel/mmap_rnd_bits tunable
+
 #
 # The "ARM system type" choice list is ordered alphabetically by option
 # text.  Please add new entries in the option alphabetic order.
diff --git a/arch/arm/mm/mmap.c b/arch/arm/mm/mmap.c
index 407dc78..73ca3a7 100644
--- a/arch/arm/mm/mmap.c
+++ b/arch/arm/mm/mmap.c
@@ -11,6 +11,10 @@
 #include <linux/random.h>
 #include <asm/cachetype.h>
 
+int mmap_rnd_bits_min = CONFIG_ARCH_MMAP_RND_BITS_MIN;
+int mmap_rnd_bits_max = CONFIG_ARCH_MMAP_RND_BITS_MAX;
+int mmap_rnd_bits = CONFIG_ARCH_MMAP_RND_BITS;
+
 #define COLOUR_ALIGN(addr,pgoff)		\
 	((((addr)+SHMLBA-1)&~(SHMLBA-1)) +	\
 	 (((pgoff)<<PAGE_SHIFT) & (SHMLBA-1)))
@@ -173,8 +177,7 @@ unsigned long arch_mmap_rnd(void)
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
