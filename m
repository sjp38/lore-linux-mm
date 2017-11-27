Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1CDA46B0253
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 05:22:56 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id k84so16832955pfj.18
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 02:22:56 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id f5si22927835pgn.126.2017.11.27.02.22.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 02:22:55 -0800 (PST)
Date: Mon, 27 Nov 2017 11:22:41 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [patch V2 5/5] x86/kaiser: Add boottime disable switch
Message-ID: <20171127102241.oj225ycxkc7rfvft@hirez.programming.kicks-ass.net>
References: <20171126231403.657575796@linutronix.de>
 <20171126232414.645128754@linutronix.de>
 <20171127094846.gl6zo3rftiyucvny@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171127094846.gl6zo3rftiyucvny@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

On Mon, Nov 27, 2017 at 10:48:46AM +0100, Peter Zijlstra wrote:
> On Mon, Nov 27, 2017 at 12:14:08AM +0100, Thomas Gleixner wrote:
> > KAISER comes with overhead. The most expensive part is the CR3 switching in
> > the entry code.
> > 
> > Add a command line parameter which allows to disable KAISER at boot time.
> > 
> > Most code pathes simply check a variable, but the entry code uses a static
> > branch. The other code pathes cannot use a static branch because they are
> > used before jump label patching is possible. Not an issue as the code
> > pathes are not so performance sensitive as the entry/exit code.
> > 
> > This makes KAISER depend on JUMP_LABEL and on a GCC which supports
> > it, but that's a resonable requirement.
> > 
> > The PGD allocation is still 8k when CONFIG_KAISER is enabled. This can be
> > addressed on top of this.
> 
> So in patch 15 Andy notes that we should probably also disable the
> SYSCALL trampoline when we disable KAISER.
> 
>   https://lkml.kernel.org/r/20171124172411.19476-16-mingo@kernel.org

Could be a simple as this.. but I've not tested.


diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
index f4f4ab8525bd..1be393a97421 100644
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -1442,7 +1442,10 @@ void syscall_init(void)
 		(entry_SYSCALL_64_trampoline - _entry_trampoline);
 
 	wrmsr(MSR_STAR, 0, (__USER32_CS << 16) | __KERNEL_CS);
-	wrmsrl(MSR_LSTAR, SYSCALL64_entry_trampoline);
+	if (kaiser_enabled)
+		wrmsrl(MSR_LSTAR, SYSCALL64_entry_trampoline);
+	else
+		wrmsrl(MSR_LSTAR, (unsigned long)entry_SYSCALL_64);
 
 #ifdef CONFIG_IA32_EMULATION
 	wrmsrl(MSR_CSTAR, (unsigned long)entry_SYSCALL_compat);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
