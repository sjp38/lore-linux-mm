Date: Sat, 22 Jan 2005 08:26:43 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [patch] [rfc] kill ugly get_memcfg_numa #define
Message-ID: <216870000.1106411202@[10.10.2.4]>
In-Reply-To: <E1Cs74T-0004YD-00@kernel.beaverton.ibm.com>
References: <E1Cs74T-0004YD-00@kernel.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> I've been confused by this:
> 
>       #define get_memcfg_numa get_memcfg_numa_flat
> 
> for the last time.  Later in the same file, there's this function:
> 
> 	static inline void get_memcfg_numa(void)
> 	{
> 	#ifdef CONFIG_X86_NUMAQ
> 	        if (get_memcfg_numaq())
> 	                return;
> 	#elif CONFIG_ACPI_SRAT
> 	        if (get_memcfg_from_srat())
> 	                return;
> 	#endif
> 
> 	        get_memcfg_numa_flat();
> 	}
> 
> Every time I look at it, my brain takes a few seconds to process
> what is going on and figure out how it isn't a recursive definition.
> That's added up to a large amount of time over the years.
> 
> So, make it safe to include asm/numaq.h and asm/srat.h from
> anywhere, and give them null definitions for their get_memcfg_*()
> functions when the config options are off.
> 
> This also gets rid of the multi-level #define that caused a little
> stink on the mailing list recently.

Mmm. I see it's ugly right now. But I'm not convinced that just calling
them all and defining them everywhere is any better. If we're cleaning 
it up, why not ditch this function altogether:
 
>  /*
>   * This allows any one NUMA architecture to be compiled
>   * for, and still fall back to the flat function if it
>   * fails.
>   */
>  static inline void get_memcfg_numa(void)
>  {
> -#ifdef CONFIG_X86_NUMAQ
>  	if (get_memcfg_numaq())
>  		return;
> -#elif CONFIG_ACPI_SRAT
>  	if (get_memcfg_from_srat())
>  		return;
> -#endif
>  
>  	get_memcfg_numa_flat();
>  }

And just have each place define get_memcfg_numa() directly, and ditch 
the switcher function? Calling them all seems counter-intuitive, and
harder to read. 

include/asm-i386/numaq.h is already wrapped in #ifdef CONFIG_X86_NUMAQ,
so just doing the equiv for include/asm-i386/srat.h (instead of #error)
should allow you to do this bit of your patch:

-#ifdef CONFIG_NUMA
-	#ifdef CONFIG_X86_NUMAQ
-		#include <asm/numaq.h>
-	#else	/* summit or generic arch */
-		#include <asm/srat.h>
-	#endif
-#else /* !CONFIG_NUMA */
-	#define get_memcfg_numa get_memcfg_numa_flat
+#include <asm/numaq.h> /* for get_memcfg_numaq() */
+#include <asm/srat.h>  /* for get_memcfg_from_srat() */

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
