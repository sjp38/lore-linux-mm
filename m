Date: Fri, 18 Apr 2008 11:28:43 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.25-mm1: not looking good
Message-ID: <20080418092842.GB20661@elte.hu>
References: <20080417160331.b4729f0c.akpm@linux-foundation.org> <20080417224908.67cec814@laptopd505.fenrus.org> <20080417231038.72363123.akpm@linux-foundation.org> <20080418071945.GA18044@elte.hu> <20080418002858.de236663.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080418002858.de236663.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Arjan van de Ven <arjan@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, James Morris <jmorris@namei.org>, Stephen Smalley <sds@tycho.nsa.gov>
List-ID: <linux-mm.kvack.org>

* Andrew Morton <akpm@linux-foundation.org> wrote:

> > > A #warning sounds more appropriate.
> > 
> > this warning is telling the user that the security feature that got 
> > enabled in the .config is completely, 100% not working due to using 
> > a stack-protector-incapable GCC.
> 
> I doubt if anyone will care much.

you noticed it ;-) Distro maintainers will notice it too if it pops up 
when something breaks StackProtector. Normal user might not notice. (but 
normal user might not notice a few hundred guest roots either)

but ... the real thing that made it slip into your config was that it 
was default-enabled in x86/latest - the patch below should fix that.

we need the warning: it could have caught the toplevel Makefile change 
last October that broke StackProtector completely. So no, we wont be and 
cannot be silent about this anymore - we need and now have an end-to-end 
test about it.

	Ingo

------------------>
Subject: stackprotector: non default
From: Ingo Molnar <mingo@elte.hu>
Date: Fri Apr 18 11:13:17 CEST 2008

Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 arch/x86/Kconfig |    1 -
 1 file changed, 1 deletion(-)

Index: linux-x86.q/arch/x86/Kconfig
===================================================================
--- linux-x86.q.orig/arch/x86/Kconfig
+++ linux-x86.q/arch/x86/Kconfig
@@ -1146,7 +1146,6 @@ config CC_STACKPROTECTOR
 	bool "Enable -fstack-protector buffer overflow detection (EXPERIMENTAL)"
 	depends on X86_64
 	select CC_STACKPROTECTOR_ALL
-	default y
 	help
           This option turns on the -fstack-protector GCC feature. This
 	  feature puts, at the beginning of functions, a canary value on

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
