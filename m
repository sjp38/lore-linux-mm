Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C3B186B0038
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 07:07:15 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v88so1361933wrb.22
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 04:07:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x12sor3377419edi.45.2017.11.03.04.07.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 03 Nov 2017 04:07:14 -0700 (PDT)
Date: Fri, 3 Nov 2017 14:07:11 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 00/23] KAISER: unmap most of the kernel from userspace
 page tables
Message-ID: <20171103110711.ifzl4czmam7rluhu@node.shutemov.name>
References: <20171031223146.6B47C861@viggo.jf.intel.com>
 <20171101085424.cwvc4nrrdhvjc3su@gmail.com>
 <d7cb1705-5ef0-5f6e-b1cf-e3f28e998477@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d7cb1705-5ef0-5f6e-b1cf-e3f28e998477@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>, borisBrian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Thomas Garnier <thgarnie@google.com>, Kees Cook <keescook@google.com>

On Wed, Nov 01, 2017 at 03:14:11PM -0700, Dave Hansen wrote:
> On 11/01/2017 01:54 AM, Ingo Molnar wrote:
> > Beyond the inevitable cavalcade of (solvable) problems that will pop up during 
> > review, one major item I'd like to see addressed is runtime configurability: it 
> > should be possible to switch between a CR3-flushing and a regular syscall and page 
> > table model on the admin level, without restarting the kernel and apps. Distros 
> > really, really don't want to double the number of kernel variants they have.
> > 
> > The 'Kaiser off' runtime switch doesn't have to be as efficient as 
> > CONFIG_KAISER=n, at least initialloy, but at minimum it should avoid the most 
> > expensive page table switching paths in the syscall entry codepaths.
> 
> Due to popular demand, I went and implemented this today.  It's not the
> prettiest code I ever wrote, but it's pretty small.
> 
> Just in case anyone wants to play with it, I threw a snapshot of it up here:
> 
> > https://git.kernel.org/pub/scm/linux/kernel/git/daveh/x86-kaiser.git/log/?h=kaiser-dynamic-414rc6-20171101
> 
> I ran some quick tests.  When CONFIG_KAISER=y, but "echo 0 >
> kaiser-enabled", the tests that I ran were within the noise vs. a
> vanilla kernel, and that's with *zero* optimization.

It doesn't compile with KASLR enabled :P

Fixup:

diff --git a/arch/x86/boot/compressed/pagetable.c b/arch/x86/boot/compressed/pagetable.c
index f1aa43854bed..7be5fdd77a3f 100644
--- a/arch/x86/boot/compressed/pagetable.c
+++ b/arch/x86/boot/compressed/pagetable.c
@@ -35,6 +35,10 @@
 /* Used by pgtable.h asm code to force instruction serialization. */
 unsigned long __force_order;
 
+#ifdef CONFIG_KAISER
+int kaiser_enabled = 1;
+#endif
+
 /* Used to track our page table allocation area. */
 struct alloc_pgt_data {
 	unsigned char *pgt_buf;
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
