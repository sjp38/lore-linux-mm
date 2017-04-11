Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8FDE76B0390
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 07:46:22 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id i5so55142331pfc.15
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 04:46:22 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id e9si16599520plk.170.2017.04.11.04.46.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Apr 2017 04:46:21 -0700 (PDT)
Date: Tue, 11 Apr 2017 14:46:16 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 3/8] x86/boot/64: Add support of additional page table
 level during early boot
Message-ID: <20170411114616.otx2f6aw5lcvfc2o@black.fi.intel.com>
References: <20170406140106.78087-1-kirill.shutemov@linux.intel.com>
 <20170406140106.78087-4-kirill.shutemov@linux.intel.com>
 <20170411070203.GA14621@gmail.com>
 <20170411105106.4zgbzuu4s4267zyv@node.shutemov.name>
 <20170411112845.GA15212@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170411112845.GA15212@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Andy Lutomirski <luto@amacapital.net>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Apr 11, 2017 at 01:28:45PM +0200, Ingo Molnar wrote:
> 
> * Kirill A. Shutemov <kirill@shutemov.name> wrote:
> 
> > On Tue, Apr 11, 2017 at 09:02:03AM +0200, Ingo Molnar wrote:
> > > I realize that you had difficulties converting this to C, but it's not going to 
> > > get any easier in the future either, with one more paging mode/level added!
> > > 
> > > If you are stuck on where it breaks I'd suggest doing it gradually: first add a 
> > > trivial .c, build and link it in and call it separately. Then once that works, 
> > > move functionality from asm to C step by step and test it at every step.
> > 
> > I've described the specific issue with converting this code to C in cover
> > letter: how to make compiler to generate 32-bit code for a specific
> > function or translation unit, without breaking linking afterwards (-m32
> > break it).
> 
> Have you tried putting it into a separate .c file, and building it 32-bit?

Yes, I have. The patch below fails linking:

ld: i386 architecture of input file `arch/x86/boot/compressed/head64.o' is incompatible with i386:x86-64 output

> 
> I think arch/x86/entry/vdso/Makefile contains an example of how to build 32-bit 
> code even on 64-bit kernels.

I'll look closer (building proccess it's rather complicated), but my
understanding is that VDSO is stand-alone binary and doesn't really links
with the rest of the kernel, rather included as blob, no?

Andy, may be you have an idea?

diff --git a/arch/x86/boot/compressed/Makefile b/arch/x86/boot/compressed/Makefile
index 44163e8c3868..8c1acacf408e 100644
--- a/arch/x86/boot/compressed/Makefile
+++ b/arch/x86/boot/compressed/Makefile
@@ -76,6 +76,8 @@ vmlinux-objs-$(CONFIG_EARLY_PRINTK) += $(obj)/early_serial_console.o
 vmlinux-objs-$(CONFIG_RANDOMIZE_BASE) += $(obj)/kaslr.o
 ifdef CONFIG_X86_64
 	vmlinux-objs-$(CONFIG_RANDOMIZE_BASE) += $(obj)/pagetable.o
+	vmlinux-objs-y += $(obj)/head64.o
+$(obj)/head64.o: KBUILD_CFLAGS := -m32 -D__KERNEL__ -O2
 endif
 
 $(obj)/eboot.o: KBUILD_CFLAGS += -fshort-wchar -mno-red-zone
diff --git a/arch/x86/boot/compressed/head64.c b/arch/x86/boot/compressed/head64.c
new file mode 100644
index 000000000000..42e1d64a15f4
--- /dev/null
+++ b/arch/x86/boot/compressed/head64.c
@@ -0,0 +1,3 @@
+void __startup32(void)
+{
+}
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
