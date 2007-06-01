Date: Fri, 1 Jun 2007 22:25:56 +0200
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [RFC 1/4] CONFIG_STABLE: Define it
Message-ID: <20070601202556.GB4232@uranus.ravnborg.org>
References: <20070531002047.702473071@sgi.com> <20070531003012.302019683@sgi.com> <20070531141147.423ad5e3.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070531141147.423ad5e3.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: clameter@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Roman Zippel <zippel@linux-m68k.org>
List-ID: <linux-mm.kvack.org>

> 
> With the following behaviour:
> 
> DEVEL_KERNEL = 0 in Makefile:
> 
> 	DEVEL_KERNEL=n in Kconfig
> 	CONFIG_DEVEL_KERNEL is not set in cpp
> 
> DEVEL_KERNEL = 1 in Makefile:
> 
> 	DEVEL_KERNEL=y in Kconfig
> 	CONFIG_DEVEL_KERNEL is set in cpp
> 
> however the above patch doesn't do this correctly and I got bored of
> fiddling with it.  Help?

My first try below.
It does the kconfig stuff as expected.
But the CONFIG_KERNEL_DEVEL is NOT updated unless you
touch .config (or in other ways change the config).

I did not see an easy way to fix that - Roman?

I only had to add SYMBOL_VALID as falg to get it working - but it 
took me a while to figure out. Somehow all the comments describing the
data structures for kconfig has got lost.

	Sam

diff --git a/Makefile b/Makefile
index 562a909..362668c 100644
--- a/Makefile
+++ b/Makefile
@@ -3,6 +3,7 @@ PATCHLEVEL = 6
 SUBLEVEL = 22
 EXTRAVERSION = -rc3
 NAME = Jeff Thinks I Should Change This, But To What?
+KERNEL_DEVEL = 
 
 # *DOCUMENTATION*
 # To see a list of typical targets execute "make help"
@@ -320,7 +321,7 @@ AFLAGS          := -D__ASSEMBLY__
 KERNELRELEASE = $(shell cat include/config/kernel.release 2> /dev/null)
 KERNELVERSION = $(VERSION).$(PATCHLEVEL).$(SUBLEVEL)$(EXTRAVERSION)
 
-export VERSION PATCHLEVEL SUBLEVEL KERNELRELEASE KERNELVERSION
+export VERSION PATCHLEVEL SUBLEVEL KERNELRELEASE KERNELVERSION KERNEL_DEVEL
 export ARCH CONFIG_SHELL HOSTCC HOSTCFLAGS CROSS_COMPILE AS LD CC
 export CPP AR NM STRIP OBJCOPY OBJDUMP MAKE AWK GENKSYMS PERL UTS_MACHINE
 export HOSTCXX HOSTCXXFLAGS LDFLAGS_MODULE CHECK CHECKFLAGS
diff --git a/arch/i386/Kconfig b/arch/i386/Kconfig
index 8770a5d..5373d58 100644
--- a/arch/i386/Kconfig
+++ b/arch/i386/Kconfig
@@ -91,6 +91,14 @@ source "init/Kconfig"
 
 menu "Processor type and features"
 
+config MY_KERNEL_DEVEL
+	bool "Needs Kernel devel"
+	depends on KERNEL_DEVEL
+
+config MY_KERNEL_DEVEL2
+	bool "Do not need kernel devel"
+	depends on !KERNEL_DEVEL
+
 source "kernel/time/Kconfig"
 
 config SMP
diff --git a/scripts/kconfig/symbol.c b/scripts/kconfig/symbol.c
index c35dcc5..fb4d5b8 100644
--- a/scripts/kconfig/symbol.c
+++ b/scripts/kconfig/symbol.c
@@ -68,6 +68,15 @@ void sym_init(void)
 	if (p)
 		sym_add_default(sym, p);
 
+	sym = sym_lookup("KERNEL_DEVEL", 0);
+	sym->type = S_BOOLEAN;
+	sym->flags |= SYMBOL_VALID|SYMBOL_AUTO;
+	p = getenv("KERNEL_DEVEL");
+	if (p && atoi(p))
+		sym_add_default(sym, "y");
+	else
+		sym_add_default(sym, "n");
+
 	sym = sym_lookup("UNAME_RELEASE", 0);
 	sym->type = S_STRING;
 	sym->flags |= SYMBOL_AUTO;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
