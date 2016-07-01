From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 1/6] x86: fix duplicated X86_BUG(9) macro
Date: Fri, 1 Jul 2016 11:23:01 +0200
Message-ID: <20160701092300.GD4593@pd.tnic>
References: <20160701001209.7DA24D1C@viggo.jf.intel.com>
 <20160701001210.AA77B917@viggo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160701001210.AA77B917@viggo.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, ak@linux.intel.com, mhocko@suse.com, dave.hansen@linux.intel.com, luto@kernel.org, stable@vger.kernel.org
List-Id: linux-mm.kvack.org

On Thu, Jun 30, 2016 at 05:12:10PM -0700, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> epufeatures.h currently defines X86_BUG(9) twice on 32-bit:
> 
> 	#define X86_BUG_NULL_SEG        X86_BUG(9) /* Nulling a selector preserves the base */
> 	...
> 	#ifdef CONFIG_X86_32
> 	#define X86_BUG_ESPFIX          X86_BUG(9) /* "" IRET to 16-bit SS corrupts ESP/RSP high bits */
> 	#endif
> 
> I think what happened was that this added the X86_BUG_ESPFIX, but
> in an #ifdef below most of the bugs:
> 
> 	[58a5aac5] x86/entry/32: Introduce and use X86_BUG_ESPFIX instead of paravirt_enabled
> 
> Then this came along and added X86_BUG_NULL_SEG, but collided
> with the earlier one that did the bug below the main block
> defining all the X86_BUG()s.
> 
> 	[7a5d6704] x86/cpu: Probe the behavior of nulling out a segment at boot time
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Acked-by: Andy Lutomirski <luto@kernel.org>
> Cc: stable@vger.kernel.org
> ---
> 
>  b/arch/x86/include/asm/cpufeatures.h |    6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff -puN arch/x86/include/asm/cpufeatures.h~knl-leak-10-fix-x86-bugs-macros arch/x86/include/asm/cpufeatures.h
> --- a/arch/x86/include/asm/cpufeatures.h~knl-leak-10-fix-x86-bugs-macros	2016-06-30 17:10:41.215185869 -0700
> +++ b/arch/x86/include/asm/cpufeatures.h	2016-06-30 17:10:41.218186005 -0700
> @@ -301,10 +301,6 @@
>  #define X86_BUG_FXSAVE_LEAK	X86_BUG(6) /* FXSAVE leaks FOP/FIP/FOP */
>  #define X86_BUG_CLFLUSH_MONITOR	X86_BUG(7) /* AAI65, CLFLUSH required before MONITOR */
>  #define X86_BUG_SYSRET_SS_ATTRS	X86_BUG(8) /* SYSRET doesn't fix up SS attrs */
> -#define X86_BUG_NULL_SEG	X86_BUG(9) /* Nulling a selector preserves the base */
> -#define X86_BUG_SWAPGS_FENCE	X86_BUG(10) /* SWAPGS without input dep on GS */
> -
> -
>  #ifdef CONFIG_X86_32
>  /*
>   * 64-bit kernels don't use X86_BUG_ESPFIX.  Make the define conditional

So I'd remove the "#ifdef CONFIG_X86_32" ifdeffery too and make that bit
unconditional - so what, we have enough free bits. But I'd leave the
comment to still avoid the confusion :)

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
