Date: Thu, 31 May 2007 23:30:46 +0200
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [RFC 1/4] CONFIG_STABLE: Define it
Message-ID: <20070531213046.GA27923@uranus.ravnborg.org>
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
> So something like this:
> 
> diff -puN Makefile~a Makefile
> --- a/Makefile~a
> +++ a/Makefile
> @@ -3,6 +3,7 @@ PATCHLEVEL = 6
>  SUBLEVEL = 22
>  EXTRAVERSION = -rc3
>  NAME = Jeff Thinks I Should Change This, But To What?
> +DEVEL_KERNEL = 1

Could we name this: KERNELDEVEL to fit with current naming convention?
Alternative: KERNEL_DEVEL

Maybe a little comment that this is mirrored as a CONFIG_ symbol?

>  
>  # *DOCUMENTATION*
>  # To see a list of typical targets execute "make help"
> @@ -320,7 +321,7 @@ AFLAGS          := -D__ASSEMBLY__
>  KERNELRELEASE = $(shell cat include/config/kernel.release 2> /dev/null)
>  KERNELVERSION = $(VERSION).$(PATCHLEVEL).$(SUBLEVEL)$(EXTRAVERSION)
>  
> -export VERSION PATCHLEVEL SUBLEVEL KERNELRELEASE KERNELVERSION
> +export VERSION PATCHLEVEL SUBLEVEL KERNELRELEASE KERNELVERSION DEVEL_KERNEL
>  export ARCH CONFIG_SHELL HOSTCC HOSTCFLAGS CROSS_COMPILE AS LD CC
>  export CPP AR NM STRIP OBJCOPY OBJDUMP MAKE AWK GENKSYMS PERL UTS_MACHINE
>  export HOSTCXX HOSTCXXFLAGS LDFLAGS_MODULE CHECK CHECKFLAGS
> diff -puN scripts/kconfig/symbol.c~a scripts/kconfig/symbol.c
> --- a/scripts/kconfig/symbol.c~a
> +++ a/scripts/kconfig/symbol.c
> @@ -68,6 +68,15 @@ void sym_init(void)
>  	if (p)
>  		sym_add_default(sym, p);
>  
> +	sym = sym_lookup("DEVEL_KERNEL", 0);
> +	sym->type = S_BOOLEAN;
> +	sym->flags |= SYMBOL_AUTO;
> +	p = getenv("DEVEL_KERNEL");
> +	if (p && atoi(p))
> +		sym_add_default(sym, "y");
> +	else
> +		sym_add_default(sym, "n");
> +

		sym_set_tristate_value(sym, yes);
	else
		sym_set_tristate_value(sym, no);

should do the trick (untested).

	Sam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
