Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0133C6B0071
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 18:19:17 -0500 (EST)
Date: Thu, 2 Dec 2010 15:19:01 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: make ioremap_prot() take a pgprot.
Message-Id: <20101202151901.e34e4e62.akpm@linux-foundation.org>
In-Reply-To: <20101102203102.GA12723@linux-sh.org>
References: <20101102203102.GA12723@linux-sh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Paul Mundt <lethal@linux-sh.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>, Chris Metcalf <cmetcalf@tilera.com>, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 3 Nov 2010 05:31:03 +0900
Paul Mundt <lethal@linux-sh.org> wrote:

> The current definition of ioremap_prot() takes an unsigned long for the
> page flags and then converts to/from a pgprot as necessary. This is
> unfortunately not sufficient for the SH-X2 TLB case which has a 64-bit
> pgprot and a 32-bit unsigned long.
> 
> An inspection of the tree shows that tile and cris also have their
> own equivalent routines that are using the pgprot_t but do not set
> HAVE_IOREMAP_PROT, both of which could trivially be adapted.
> 
> After cris/tile are updated there would also be enough critical mass to
> move the powerpc devm_ioremap_prot() in to the generic lib/devres.c.

In file included from sound/drivers/mpu401/mpu401_uart.c:31:
arch/x86/include/asm/io.h:199: error: syntax error before 'pgprot_t'
arch/x86/include/asm/io.h:199: warning: function declaration isn't a prototype

because asm/io.h now needs asm/pgtable.h for pgprot_t.

I tried that:

--- a/arch/powerpc/include/asm/io.h~mm-make-ioremap_prot-take-a-pgprot-fix
+++ a/arch/powerpc/include/asm/io.h
@@ -27,6 +27,7 @@ extern int check_legacy_ioport(unsigned 
 #include <asm/synch.h>
 #include <asm/delay.h>
 #include <asm/mmu.h>
+#include <asm/pgtable.h>
 
 #include <asm-generic/iomap.h>
 
--- a/arch/x86/include/asm/io.h~mm-make-ioremap_prot-take-a-pgprot-fix
+++ a/arch/x86/include/asm/io.h
@@ -40,6 +40,7 @@
 #include <linux/compiler.h>
 #include <asm-generic/int-ll64.h>
 #include <asm/page.h>
+#include <asm/pgtable.h>
 
 #include <xen/xen.h>
 
and it blew up because pgtable.h needs spinlock.h for spinlock_t.

Gave up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
