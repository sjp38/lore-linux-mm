Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 130A06B0038
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 12:52:51 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id y71so122162441pgd.0
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 09:52:51 -0800 (PST)
Received: from mail.zytor.com (torg.zytor.com. [2001:1868:205::12])
        by mx.google.com with ESMTPS id i1si3582915pld.88.2016.12.15.09.52.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Dec 2016 09:52:49 -0800 (PST)
In-Reply-To: <20161215143944.ruxr6r3b2atg4tnf@pd.tnic>
References: <20161208162150.148763-1-kirill.shutemov@linux.intel.com> <20161208162150.148763-17-kirill.shutemov@linux.intel.com> <20161208200505.c6xiy56oufg6d24m@pd.tnic> <CA+55aFzgp+6c6RhgYvEjor=_+ewMeYL4XY4BqER5HMUknXBDCA@mail.gmail.com> <20161208202013.uutsny6avn5gimwq@pd.tnic> <b393a48a-6e8b-6427-373c-2825641fea99@zytor.com> <BD4BD1C9-F6FD-4905-9B09-059284FD2713@alien8.de> <20161215143944.ruxr6r3b2atg4tnf@pd.tnic>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain;
 charset=UTF-8
Subject: Re: [RFC, PATCHv1 15/28] x86: detect 5-level paging support
From: hpa@zytor.com
Date: Thu, 15 Dec 2016 09:52:12 -0800
Message-ID: <E77F6B05-4F69-4C02-90B4-A8A6D0D392DE@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On December 15, 2016 6:39:44 AM PST, Borislav Petkov <bp@alien8.de> wrote:
>On Wed, Dec 14, 2016 at 12:07:54AM +0100, Boris Petkov wrote:
>> Thus I was thinking of adding a build-time check for the gcc version
>> but that might turn out to be more code in the end than those ugly
>> ifnc clauses.
>
>IOW, something like this. I did this just to try to see whether it is
>doable. And it does work - gcc 4.8 and 4.9 -m32 cannot preserve the PIC
>register - actually the inline asm fails building due to impossible
>constraints.
>
>However, so many lines changed just to save the ifnc, meh, I dunno...
>
>---
> arch/x86/boot/compressed/Makefile |  8 ++++++
> arch/x86/boot/cpuflags.c          | 14 ++++++++--
>scripts/gcc-clobber-pic.sh        | 58
>+++++++++++++++++++++++++++++++++++++++
> 3 files changed, 77 insertions(+), 3 deletions(-)
> create mode 100755 scripts/gcc-clobber-pic.sh
>
>diff --git a/arch/x86/boot/compressed/Makefile
>b/arch/x86/boot/compressed/Makefile
>index 34d9e15857c3..705fc2ab3fd6 100644
>--- a/arch/x86/boot/compressed/Makefile
>+++ b/arch/x86/boot/compressed/Makefile
>@@ -35,6 +35,14 @@ KBUILD_CFLAGS += -mno-mmx -mno-sse
> KBUILD_CFLAGS += $(call cc-option,-ffreestanding)
> KBUILD_CFLAGS += $(call cc-option,-fno-stack-protector)
> 
>+# check whether inline asm clobbers the PIC register
>+ifeq ($(CONFIG_X86_32),y)
>+ifeq ($(shell $(CONFIG_SHELL) $(srctree)/scripts/gcc-clobber-pic.sh
>$(CC) -m32),n)
>+	KBUILD_CFLAGS += -DCC_PRESERVES_PIC
>+	KBUILD_AFLAGS += -DCC_PRESERVES_PIC
>+endif
>+endif
>+
> KBUILD_AFLAGS  := $(KBUILD_CFLAGS) -D__ASSEMBLY__
> GCOV_PROFILE := n
> UBSAN_SANITIZE :=n
>diff --git a/arch/x86/boot/cpuflags.c b/arch/x86/boot/cpuflags.c
>index 6687ab953257..913c3f5ab3a0 100644
>--- a/arch/x86/boot/cpuflags.c
>+++ b/arch/x86/boot/cpuflags.c
>@@ -70,11 +70,19 @@ int has_eflag(unsigned long mask)
> # define EBX_REG "=b"
> #endif
> 
>+#if defined(__i386__) && defined(__PIC__) &&
>!defined(CC_PRESERVES_PIC)
>+# define SAVE_PIC ".ifnc %%ebx, %3;  movl %%ebx, %3; .endif\n\t"
>+# define SWAP_PIC ".ifnc %%ebx, %3; xchgl %%ebx, %3; .endif\n\t"
>+#else
>+# define SAVE_PIC
>+# define SWAP_PIC
>+#endif
>+
> static inline void cpuid(u32 id, u32 *a, u32 *b, u32 *c, u32 *d)
> {
>-	asm volatile(".ifnc %%ebx,%3 ; movl  %%ebx,%3 ; .endif	\n\t"
>-		     "cpuid					\n\t"
>-		     ".ifnc %%ebx,%3 ; xchgl %%ebx,%3 ; .endif	\n\t"
>+	asm volatile(SAVE_PIC
>+		     "cpuid\n\t"
>+		     SWAP_PIC
> 		    : "=a" (*a), "=c" (*c), "=d" (*d), EBX_REG (*b)
> 		    : "a" (id)
> 	);
>diff --git a/scripts/gcc-clobber-pic.sh b/scripts/gcc-clobber-pic.sh
>new file mode 100755
>index 000000000000..7ff10edf9b08
>--- /dev/null
>+++ b/scripts/gcc-clobber-pic.sh
>@@ -0,0 +1,58 @@
>+#!/bin/bash -x
>+err=0
>+O=$(mktemp)
>+cat << "END" | $@ -fPIC -x c - -o $O >/dev/null 2>&1 || err=1
>+int some_global_var, some_other_global_var;
>+
>+typedef unsigned int u32;
>+
>+void __attribute__((noinline)) foo(void)
>+{
>+	asm volatile("# some crap just so that we don't get optimized away");
>+
>+	some_other_global_var = 43;
>+}
>+
>+static inline void cpuid(u32 id, u32 *a, u32 *b, u32 *c, u32 *d)
>+{
>+        asm volatile("cpuid"
>+                    : "=a" (*a), "=b" (*b), "=c" (*c), "=d" (*d)
>+                    : "a" (id), "2" (*c)
>+		    : "si", "di"
>+        );
>+
>+	some_global_var = 42;
>+	foo();
>+}
>+
>+int main(void)
>+{
>+	u32 a, b, c = 0, d;
>+
>+	cpuid(0x1, &a, &b, &c, &d);
>+
>+	/*
>+	 * Make sure foo() gets actually called and not optimized away due to
>+	 * miscompilation.
>+	 */
>+	if (some_global_var == 42 && some_other_global_var == 43)
>+		return 0;
>+	else
>+		return 1;
>+}
>+END
>+
>+if (( $err ));
>+then
>+	exit 1
>+fi
>+
>+chmod u+x $O
>+$O
>+
>+if ! (( $? ));
>+then
>+	echo "n"
>+fi
>+
>+rm -f $O

This really is only worthwhile if it ends up producing better code, but I doubt it.
-- 
Sent from my Android device with K-9 Mail. Please excuse my brevity.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
