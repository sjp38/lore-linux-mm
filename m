Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8944A8D003B
	for <linux-mm@kvack.org>; Sat, 26 Mar 2011 21:57:24 -0400 (EDT)
Date: Sat, 26 Mar 2011 20:57:18 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: Disable the lockless allocator
In-Reply-To: <alpine.DEB.2.00.1103262028170.1004@router.home>
Message-ID: <alpine.DEB.2.00.1103262054410.1373@router.home>
References: <alpine.DEB.2.00.1103221635400.4521@tiger> <20110324142146.GA11682@elte.hu> <alpine.DEB.2.00.1103240940570.32226@router.home> <AANLkTikb8rtSX5hQG6MQF4quymFUuh5Tw97TcpB0YfwS@mail.gmail.com> <20110324172653.GA28507@elte.hu> <20110324185258.GA28370@elte.hu>
 <alpine.LFD.2.00.1103242005530.31464@localhost6.localdomain6> <20110324192247.GA5477@elte.hu> <AANLkTinBwM9egao496WnaNLAPUxhMyJmkusmxt+ARtnV@mail.gmail.com> <20110326112725.GA28612@elte.hu> <20110326114736.GA8251@elte.hu> <1301161507.2979.105.camel@edumazet-laptop>
 <alpine.DEB.2.00.1103261406420.24195@router.home> <alpine.DEB.2.00.1103261428200.25375@router.home> <alpine.DEB.2.00.1103261440160.25375@router.home> <AANLkTinTzKQkRcE2JvP_BpR0YMj82gppAmNo7RqgftCG@mail.gmail.com>
 <alpine.DEB.2.00.1103262028170.1004@router.home>
MIME-Version: 1.0
Content-Type: MULTIPART/Mixed; BOUNDARY=0015177407b69c6eb6049f6a184f
Content-ID: <alpine.DEB.2.00.1103262028171.1004@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--0015177407b69c6eb6049f6a184f
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <alpine.DEB.2.00.1103262028172.1004@router.home>

But then the same fix must also be used in the asm code or the fallback
(turns out that the fallback is always used in kmem_cache_init since
the instruction patching comes later).

Patch boots fine both in UP and SMP mode




Subject: percpu: Omit segment prefix in the UP case for cmpxchg_double

Omit the segment prefix in the UP case. GS is not used then
and we will generate segfaults if cmpxchg16b is used otherwise.

Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Christoph Lameter <cl@linux.com>

 arch/x86/include/asm/percpu.h |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

Index: linux-2.6/arch/x86/include/asm/percpu.h
===================================================================
--- linux-2.6.orig/arch/x86/include/asm/percpu.h	2011-03-26 20:43:03.994089001 -0500
+++ linux-2.6/arch/x86/include/asm/percpu.h	2011-03-26 20:43:22.414089004 -0500
@@ -45,7 +45,7 @@
 #include <linux/stringify.h>

 #ifdef CONFIG_SMP
-#define __percpu_arg(x)		"%%"__stringify(__percpu_seg)":%P" #x
+#define __percpu_prefix		"%%"__stringify(__percpu_seg)":"
 #define __my_cpu_offset		percpu_read(this_cpu_off)

 /*
@@ -62,9 +62,11 @@
 	(typeof(*(ptr)) __kernel __force *)tcp_ptr__;	\
 })
 #else
-#define __percpu_arg(x)		"%P" #x
+#define __percpu_prefix		""
 #endif

+#define __percpu_arg(x)		__percpu_prefix "%P" #x
+
 /*
  * Initialized pointers to per-cpu variables needed for the boot
  * processor need to use these macros to get the proper address
@@ -516,11 +518,11 @@
 	typeof(o2) __n2 = n2;						\
 	typeof(o2) __dummy;						\
 	alternative_io("call this_cpu_cmpxchg16b_emu\n\t" P6_NOP4,	\
-		       "cmpxchg16b %%gs:(%%rsi)\n\tsetz %0\n\t",	\
+		       "cmpxchg16b " __percpu_prefix "(%%rsi)\n\tsetz %0\n\t",	\
 		       X86_FEATURE_CX16,				\
 		       ASM_OUTPUT2("=a"(__ret), "=d"(__dummy)),		\
 		       "S" (&pcp1), "b"(__n1), "c"(__n2),		\
-		       "a"(__o1), "d"(__o2));				\
+		       "a"(__o1), "d"(__o2) : "memory");		\
 	__ret;								\
 })

Index: linux-2.6/arch/x86/lib/cmpxchg16b_emu.S
===================================================================
--- linux-2.6.orig/arch/x86/lib/cmpxchg16b_emu.S	2011-03-26 20:43:57.384089004 -0500
+++ linux-2.6/arch/x86/lib/cmpxchg16b_emu.S	2011-03-26 20:48:42.684088999 -0500
@@ -10,6 +10,12 @@
 #include <asm/frame.h>
 #include <asm/dwarf2.h>

+#ifdef CONFIG_SMP
+#define SEG_PREFIX %gs:
+#else
+#define SEG_PREFIX
+#endif
+
 .text

 /*
@@ -37,13 +43,13 @@
 	pushf
 	cli

-	cmpq %gs:(%rsi), %rax
+	cmpq SEG_PREFIX(%rsi), %rax
 	jne not_same
-	cmpq %gs:8(%rsi), %rdx
+	cmpq SEG_PREFIX 8(%rsi), %rdx
 	jne not_same

-	movq %rbx, %gs:(%rsi)
-	movq %rcx, %gs:8(%rsi)
+	movq %rbx, SEG_PREFIX(%rsi)
+	movq %rcx, SEG_PREFIX 8(%rsi)

 	popf
 	mov $1, %al
--0015177407b69c6eb6049f6a184f
Content-Type: TEXT/X-PATCH; CHARSET=US-ASCII; NAME=patch.diff
Content-Transfer-Encoding: BASE64
Content-ID: <alpine.DEB.2.00.1103262028173.1004@router.home>
Content-Description: 
Content-Disposition: ATTACHMENT; FILENAME=patch.diff

IGFyY2gveDg2L2luY2x1ZGUvYXNtL3BlcmNwdS5oIHwgICAxMCArKysrKystLS0tCiAxIGZpbGVz
IGNoYW5nZWQsIDYgaW5zZXJ0aW9ucygrKSwgNCBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9h
cmNoL3g4Ni9pbmNsdWRlL2FzbS9wZXJjcHUuaCBiL2FyY2gveDg2L2luY2x1ZGUvYXNtL3BlcmNw
dS5oCmluZGV4IGEwOWUxZjAuLmQ0NzViNDMgMTAwNjQ0Ci0tLSBhL2FyY2gveDg2L2luY2x1ZGUv
YXNtL3BlcmNwdS5oCisrKyBiL2FyY2gveDg2L2luY2x1ZGUvYXNtL3BlcmNwdS5oCkBAIC00NSw3
ICs0NSw3IEBACiAjaW5jbHVkZSA8bGludXgvc3RyaW5naWZ5Lmg+CiAKICNpZmRlZiBDT05GSUdf
U01QCi0jZGVmaW5lIF9fcGVyY3B1X2FyZyh4KQkJIiUlIl9fc3RyaW5naWZ5KF9fcGVyY3B1X3Nl
ZykiOiVQIiAjeAorI2RlZmluZSBfX3BlcmNwdV9wcmVmaXgJCSIlJSJfX3N0cmluZ2lmeShfX3Bl
cmNwdV9zZWcpIjoiCiAjZGVmaW5lIF9fbXlfY3B1X29mZnNldAkJcGVyY3B1X3JlYWQodGhpc19j
cHVfb2ZmKQogCiAvKgpAQCAtNjIsOSArNjIsMTEgQEAKIAkodHlwZW9mKCoocHRyKSkgX19rZXJu
ZWwgX19mb3JjZSAqKXRjcF9wdHJfXzsJXAogfSkKICNlbHNlCi0jZGVmaW5lIF9fcGVyY3B1X2Fy
Zyh4KQkJIiVQIiAjeAorI2RlZmluZSBfX3BlcmNwdV9wcmVmaXgJCSIiCiAjZW5kaWYKIAorI2Rl
ZmluZSBfX3BlcmNwdV9hcmcoeCkJCV9fcGVyY3B1X3ByZWZpeCAiJVAiICN4CisKIC8qCiAgKiBJ
bml0aWFsaXplZCBwb2ludGVycyB0byBwZXItY3B1IHZhcmlhYmxlcyBuZWVkZWQgZm9yIHRoZSBi
b290CiAgKiBwcm9jZXNzb3IgbmVlZCB0byB1c2UgdGhlc2UgbWFjcm9zIHRvIGdldCB0aGUgcHJv
cGVyIGFkZHJlc3MKQEAgLTUxNiwxMSArNTE4LDExIEBAIGRvIHsJCQkJCQkJCQlcCiAJdHlwZW9m
KG8yKSBfX24yID0gbjI7CQkJCQkJXAogCXR5cGVvZihvMikgX19kdW1teTsJCQkJCQlcCiAJYWx0
ZXJuYXRpdmVfaW8oImNhbGwgdGhpc19jcHVfY21weGNoZzE2Yl9lbXVcblx0IiBQNl9OT1A0LAlc
Ci0JCSAgICAgICAiY21weGNoZzE2YiAlJWdzOiglJXJzaSlcblx0c2V0eiAlMFxuXHQiLAlcCisJ
CSAgICAgICAiY21weGNoZzE2YiAiIF9fcGVyY3B1X3ByZWZpeCAiKCUlcnNpKVxuXHRzZXR6ICUw
XG5cdCIsCVwKIAkJICAgICAgIFg4Nl9GRUFUVVJFX0NYMTYsCQkJCVwKIAkJICAgICAgIEFTTV9P
VVRQVVQyKCI9YSIoX19yZXQpLCAiPWQiKF9fZHVtbXkpKSwJCVwKIAkJICAgICAgICJTIiAoJnBj
cDEpLCAiYiIoX19uMSksICJjIihfX24yKSwJCVwKLQkJICAgICAgICJhIihfX28xKSwgImQiKF9f
bzIpKTsJCQkJXAorCQkgICAgICAgImEiKF9fbzEpLCAiZCIoX19vMikgOiAibWVtb3J5Iik7CQlc
CiAJX19yZXQ7CQkJCQkJCQlcCiB9KQogCg==
--0015177407b69c6eb6049f6a184f--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
