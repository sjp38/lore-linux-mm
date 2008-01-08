Date: Tue, 8 Jan 2008 20:24:25 +0100
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH 01/10] percpu: Use a kconfig variable to signal arch specific percpu setup
Message-ID: <20080108192425.GB26491@uranus.ravnborg.org>
References: <20080108021142.585467000@sgi.com> <20080108021142.835662000@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080108021142.835662000@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: travis@sgi.com
Cc: mingo@elte.hu, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 07, 2008 at 06:11:43PM -0800, travis@sgi.com wrote:
> V1->V2:
> - Use def_bool as suggested by Randy.
> 
> The use of the __GENERIC_PERCPU is a bit problematic since arches
> may want to run their own percpu setup while using the generic
> percpu definitions. Replace it through a kconfig variable.
> 
> 
> 
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Andi Kleen <ak@suse.de>
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> Signed-off-by: Mike Travis <travis@sgi.com>
> 
> ---
>  arch/ia64/Kconfig            |    3 +++
>  arch/powerpc/Kconfig         |    3 +++
>  arch/sparc64/Kconfig         |    3 +++
>  arch/x86/Kconfig             |    3 +++
>  include/asm-generic/percpu.h |    1 -
>  include/asm-s390/percpu.h    |    2 --
>  include/asm-x86/percpu_32.h  |    2 --
>  init/main.c                  |    4 ++--
>  8 files changed, 14 insertions(+), 7 deletions(-)
> 
> --- a/arch/ia64/Kconfig
> +++ b/arch/ia64/Kconfig
> @@ -80,6 +80,9 @@ config GENERIC_TIME_VSYSCALL
>  	bool
>  	default y
>  
> +config ARCH_SETS_UP_PER_CPU_AREA
> +	def_bool y
> +
>  config DMI
>  	bool
>  	default y
> --- a/arch/powerpc/Kconfig
> +++ b/arch/powerpc/Kconfig
> @@ -42,6 +42,9 @@ config GENERIC_HARDIRQS
>  	bool
>  	default y
>  
> +config ARCH_SETS_UP_PER_CPU_AREA
> +	def_bool PPC64
> +
>  config IRQ_PER_CPU
>  	bool
>  	default y

Please do not create one variable per arch to enable this functionality.
Define one common variable and name it:
config HAVE_SETUP_PER_CPU_AREA

and then for the arch's that supports it you select this symbol.
For X86 it would look like:

 config X86
+	select HAVE_SETUP_PER_CPU_AREA


This is the recommended methiond today - albeit not widely used yet.

	Sam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
