Message-ID: <40221255.5020306@pobox.com>
Date: Thu, 05 Feb 2004 04:52:21 -0500
From: Jeff Garzik <jgarzik@pobox.com>
MIME-Version: 1.0
Subject: [PATCH] via crypto beginnings
References: <20040205014405.5a2cf529.akpm@osdl.org>
In-Reply-To: <20040205014405.5a2cf529.akpm@osdl.org>
Content-Type: multipart/mixed;
 boundary="------------080503090706090302020505"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------080503090706090302020505
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.2/2.6.2-mm1/
> 
> 
> - Merged some page reclaim fixes from Nick and Nikita.  These yield some
>   performance improvements in low memory and heavy paging situations.
> 
> - Various random fixes.
> 
> 
> 
> Changes since 2.6.2-rc3-mm1:


Did you see this one?  I could have sworn I sent via crypto stuff, but 
I've been scatterbrained recently.

	Jeff



--------------080503090706090302020505
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch"

diff -Nru a/arch/i386/kernel/cpu/centaur.c b/arch/i386/kernel/cpu/centaur.c
--- a/arch/i386/kernel/cpu/centaur.c	Thu Feb  5 04:51:15 2004
+++ b/arch/i386/kernel/cpu/centaur.c	Thu Feb  5 04:51:15 2004
@@ -246,7 +246,15 @@
 	lo&=~0x1C0;	/* blank bits 8-6 */
 	wrmsr(MSR_IDT_MCR_CTRL, lo, hi);
 }
-#endif
+#endif /* CONFIG_X86_OOSTORE */
+
+#define ACE_PRESENT	(1 << 6)
+#define ACE_ENABLED	(1 << 7)
+#define ACE_FCR		(1 << 28)	/* MSR_VIA_FCR */
+
+#define RNG_PRESENT	(1 << 2)
+#define RNG_ENABLED	(1 << 3)
+#define RNG_ENABLE	(1 << 6)	/* MSR_VIA_RNG */
 
 static void __init init_c3(struct cpuinfo_x86 *c)
 {
@@ -254,6 +262,24 @@
 
 	/* Test for Centaur Extended Feature Flags presence */
 	if (cpuid_eax(0xC0000000) >= 0xC0000001) {
+		u32 tmp = cpuid_edx(0xC0000001);
+
+		/* enable ACE unit, if present and disabled */
+		if ((tmp & (ACE_PRESENT | ACE_ENABLED)) == ACE_PRESENT) {
+			rdmsr (MSR_VIA_FCR, lo, hi);
+			lo |= ACE_FCR;		/* enable ACE unit */
+			wrmsr (MSR_VIA_FCR, lo, hi);
+			printk(KERN_INFO "CPU: Enabled ACE h/w crypto\n");
+		}
+
+		/* enable RNG unit, if present and disabled */
+		if ((tmp & (RNG_PRESENT | RNG_ENABLED)) == RNG_PRESENT) {
+			rdmsr (MSR_VIA_RNG, lo, hi);
+			lo |= RNG_ENABLE;	/* enable RNG unit */
+			wrmsr (MSR_VIA_RNG, lo, hi);
+			printk(KERN_INFO "CPU: Enabled h/w RNG\n");
+		}
+
 		/* store Centaur Extended Feature Flags as
 		 * word 5 of the CPU capability bit array
 		 */
diff -Nru a/arch/i386/kernel/cpu/proc.c b/arch/i386/kernel/cpu/proc.c
--- a/arch/i386/kernel/cpu/proc.c	Thu Feb  5 04:51:15 2004
+++ b/arch/i386/kernel/cpu/proc.c	Thu Feb  5 04:51:15 2004
@@ -50,7 +50,7 @@
 		NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 
 		/* VIA/Cyrix/Centaur-defined */
-		NULL, NULL, "xstore", NULL, NULL, NULL, NULL, NULL,
+		NULL, NULL, "rng", "rng_en", NULL, NULL, "ace", "ace_en",
 		NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 		NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 		NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
diff -Nru a/drivers/char/hw_random.c b/drivers/char/hw_random.c
--- a/drivers/char/hw_random.c	Thu Feb  5 04:51:15 2004
+++ b/drivers/char/hw_random.c	Thu Feb  5 04:51:15 2004
@@ -454,11 +454,7 @@
 
 static void via_cleanup(void)
 {
-	u32 lo, hi;
-
-	rdmsr(MSR_VIA_RNG, lo, hi);
-	lo &= ~VIA_RNG_ENABLE;
-	wrmsr(MSR_VIA_RNG, lo, hi);
+	/* do nothing */
 }
 
 
diff -Nru a/include/asm-i386/cpufeature.h b/include/asm-i386/cpufeature.h
--- a/include/asm-i386/cpufeature.h	Thu Feb  5 04:51:15 2004
+++ b/include/asm-i386/cpufeature.h	Thu Feb  5 04:51:15 2004
@@ -76,6 +76,9 @@
 
 /* VIA/Cyrix/Centaur-defined CPU features, CPUID level 0xC0000001, word 5 */
 #define X86_FEATURE_XSTORE	(5*32+ 2) /* on-CPU RNG present (xstore insn) */
+#define X86_FEATURE_XSTORE_EN	(5*32+ 3) /* on-CPU RNG enabled */
+#define X86_FEATURE_XCRYPT	(5*32+ 6) /* on-CPU crypto (xcrypt insn) */
+#define X86_FEATURE_XCRYPT_EN	(5*32+ 7) /* on-CPU crypto enabled */
 
 
 #define cpu_has(c, bit)		test_bit(bit, (c)->x86_capability)
@@ -101,6 +104,7 @@
 #define cpu_has_cyrix_arr	boot_cpu_has(X86_FEATURE_CYRIX_ARR)
 #define cpu_has_centaur_mcr	boot_cpu_has(X86_FEATURE_CENTAUR_MCR)
 #define cpu_has_xstore		boot_cpu_has(X86_FEATURE_XSTORE)
+#define cpu_has_xcrypt		boot_cpu_has(X86_FEATURE_XCRYPT)
 
 #endif /* __ASM_I386_CPUFEATURE_H */
 

--------------080503090706090302020505--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
