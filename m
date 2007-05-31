Date: Thu, 31 May 2007 14:11:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC 1/4] CONFIG_STABLE: Define it
Message-Id: <20070531141147.423ad5e3.akpm@linux-foundation.org>
In-Reply-To: <20070531003012.302019683@sgi.com>
References: <20070531002047.702473071@sgi.com>
	<20070531003012.302019683@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sam Ravnborg <sam@ravnborg.org>, Roman Zippel <zippel@linux-m68k.org>
List-ID: <linux-mm.kvack.org>

On Wed, 30 May 2007 17:20:48 -0700
clameter@sgi.com wrote:

> Introduce CONFIG_STABLE to control checks only useful for development.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> ---
>  init/Kconfig |    7 +++++++
>  1 file changed, 7 insertions(+)
> 
> Index: slub/init/Kconfig
> ===================================================================
> --- slub.orig/init/Kconfig	2007-05-30 16:35:05.000000000 -0700
> +++ slub/init/Kconfig	2007-05-30 16:35:45.000000000 -0700
> @@ -65,6 +65,13 @@ endmenu
>  
>  menu "General setup"
>  
> +config STABLE
> +	bool "Stable kernel"
> +	help
> +	  If the kernel is configured to be a stable kernel then various
> +	  checks that are only of interest to kernel development will be
> +	  omitted.
> +
>  config LOCALVERSION
>  	string "Local version - append to kernel release"
>  	help

OK, but I think it'd be better if this knob was at line 6 of ./Makefile so
that Linus remembers to turn it on and off at appropriate times.  Also, I
suspect that we want it available within Kconfig expressions as well as
within cpp expressions.

So something like this:

diff -puN Makefile~a Makefile
--- a/Makefile~a
+++ a/Makefile
@@ -3,6 +3,7 @@ PATCHLEVEL = 6
 SUBLEVEL = 22
 EXTRAVERSION = -rc3
 NAME = Jeff Thinks I Should Change This, But To What?
+DEVEL_KERNEL = 1
 
 # *DOCUMENTATION*
 # To see a list of typical targets execute "make help"
@@ -320,7 +321,7 @@ AFLAGS          := -D__ASSEMBLY__
 KERNELRELEASE = $(shell cat include/config/kernel.release 2> /dev/null)
 KERNELVERSION = $(VERSION).$(PATCHLEVEL).$(SUBLEVEL)$(EXTRAVERSION)
 
-export VERSION PATCHLEVEL SUBLEVEL KERNELRELEASE KERNELVERSION
+export VERSION PATCHLEVEL SUBLEVEL KERNELRELEASE KERNELVERSION DEVEL_KERNEL
 export ARCH CONFIG_SHELL HOSTCC HOSTCFLAGS CROSS_COMPILE AS LD CC
 export CPP AR NM STRIP OBJCOPY OBJDUMP MAKE AWK GENKSYMS PERL UTS_MACHINE
 export HOSTCXX HOSTCXXFLAGS LDFLAGS_MODULE CHECK CHECKFLAGS
diff -puN scripts/kconfig/symbol.c~a scripts/kconfig/symbol.c
--- a/scripts/kconfig/symbol.c~a
+++ a/scripts/kconfig/symbol.c
@@ -68,6 +68,15 @@ void sym_init(void)
 	if (p)
 		sym_add_default(sym, p);
 
+	sym = sym_lookup("DEVEL_KERNEL", 0);
+	sym->type = S_BOOLEAN;
+	sym->flags |= SYMBOL_AUTO;
+	p = getenv("DEVEL_KERNEL");
+	if (p && atoi(p))
+		sym_add_default(sym, "y");
+	else
+		sym_add_default(sym, "n");
+
 	sym = sym_lookup("UNAME_RELEASE", 0);
 	sym->type = S_STRING;
 	sym->flags |= SYMBOL_AUTO;
_


With the following behaviour:

DEVEL_KERNEL = 0 in Makefile:

	DEVEL_KERNEL=n in Kconfig
	CONFIG_DEVEL_KERNEL is not set in cpp

DEVEL_KERNEL = 1 in Makefile:

	DEVEL_KERNEL=y in Kconfig
	CONFIG_DEVEL_KERNEL is set in cpp

however the above patch doesn't do this correctly and I got bored of
fiddling with it.  Help?
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
