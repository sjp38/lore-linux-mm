Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f44.google.com (mail-lf0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id 1352F6B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 06:01:41 -0500 (EST)
Received: by lfdl133 with SMTP id l133so45149289lfd.2
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 03:01:40 -0800 (PST)
Received: from mail-lf0-x22d.google.com (mail-lf0-x22d.google.com. [2a00:1450:4010:c07::22d])
        by mx.google.com with ESMTPS id h7si1568772lbd.91.2015.12.02.03.01.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 03:01:39 -0800 (PST)
Received: by lfs39 with SMTP id 39so43085288lfs.3
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 03:01:38 -0800 (PST)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: Re: [PATCH 1/2] mm, printk: introduce new format string for flags
References: <20151125143010.GI27283@dhcp22.suse.cz>
	<1448899821-9671-1-git-send-email-vbabka@suse.cz>
Date: Wed, 02 Dec 2015 12:01:36 +0100
In-Reply-To: <1448899821-9671-1-git-send-email-vbabka@suse.cz> (Vlastimil
	Babka's message of "Mon, 30 Nov 2015 17:10:20 +0100")
Message-ID: <87io4hi06n.fsf@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>

On Mon, Nov 30 2015, Vlastimil Babka <vbabka@suse.cz> wrote:

> In mm we use several kinds of flags bitfields that are sometimes printed for
> debugging purposes, or exported to userspace via sysfs. To make them easier to
> interpret independently on kernel version and config, we want to dump also the
> symbolic flag names. So far this has been done with repeated calls to
> pr_cont(), which is unreliable on SMP, and not usable for e.g. sysfs export.
>
> To get a more reliable and universal solution, this patch extends printk()
> format string for pointers to handle the page flags (%pgp), gfp_flags (%pgg)
> and vma flags (%pgv). Existing users of dump_flag_names() are converted and
> simplified.
>
> It would be possible to pass flags by value instead of pointer, but the %p
> format string for pointers already has extensions for various kernel
> structures, so it's a good fit, and the extra indirection in a non-critical
> path is negligible.
>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>
> ---
> I'm sending it on top of the page_owner series, as it's already in mmotm.
> But to reduce churn (in case this approach is accepted), I can later
> incorporate it and resend it whole.
>
>  Documentation/printk-formats.txt |  14 ++++
>  include/linux/mmdebug.h          |   5 +-
>  lib/vsprintf.c                   |  31 ++++++++
>  mm/debug.c                       | 150 ++++++++++++++++++++++-----------------
>  mm/oom_kill.c                    |   5 +-
>  mm/page_alloc.c                  |   5 +-
>  mm/page_owner.c                  |   5 +-
>  7 files changed, 140 insertions(+), 75 deletions(-)

I'd prefer to have the formatting code in vsprintf.c, so that we'd avoid
having to call vsnprintf recursively (and repeatedly - not that this is
going to be used in hot paths, but if the box is going down it might be
nice to get the debug info out a few thousand cycles earlier). That'll
also make it easier to avoid the bugs below.


> diff --git a/Documentation/printk-formats.txt b/Documentation/printk-formats.txt
> index b784c270105f..4b5156e74b09 100644
> --- a/Documentation/printk-formats.txt
> +++ b/Documentation/printk-formats.txt
> @@ -292,6 +292,20 @@ Raw pointer value SHOULD be printed with %p. The kernel supports
>  
>  	Passed by reference.
>  
> +Flags bitfields such as page flags, gfp_flags:
> +
> +	%pgp	0x1fffff8000086c(referenced|uptodate|lru|active|private)
> +	%pgg	0x24202c4(GFP_USER|GFP_DMA32|GFP_NOWARN)
> +	%pgv	0x875(read|exec|mayread|maywrite|mayexec|denywrite)
> +

I think it would be better (and more flexible) if %pg* only stood for
printing the | chain of strings. Let people pass the flags twice if they
also want the numeric value; then they're also able to choose 0-padding
and whatnot, can use other kinds of parentheses, etc., etc. So

  pr_emerg("flags: 0x%08lu [%pgp]\n", printflags, &printflags)


> +	For printing raw values of flags bitfields together with symbolic
> +	strings that would construct the value. The type of flags is given by
> +	the third character. Currently supported are [p]age flags, [g]fp_flags
> +	and [v]ma_flags. The flag names and print order depends on the
> +	particular type.
> +
> +	Passed by reference.
> +
>  Network device features:
>  
>  	%pNF	0x000000000000c000
> diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
> index 3b77fab7ad28..e6518df259ca 100644
> --- a/include/linux/mmdebug.h
> +++ b/include/linux/mmdebug.h
> @@ -2,6 +2,7 @@
>  #define LINUX_MM_DEBUG_H 1
>  
>  #include <linux/stringify.h>
> +#include <linux/types.h>
>  
>  struct page;
>  struct vm_area_struct;
> @@ -10,7 +11,9 @@ struct mm_struct;
>  extern void dump_page(struct page *page, const char *reason);
>  extern void dump_page_badflags(struct page *page, const char *reason,
>  			       unsigned long badflags);
> -extern void dump_gfpflag_names(unsigned long gfp_flags);
> +extern char *format_page_flags(unsigned long flags, char *buf, char *end);
> +extern char *format_vma_flags(unsigned long flags, char *buf, char *end);
> +extern char *format_gfp_flags(gfp_t gfp_flags, char *buf, char*end);
>  void dump_vma(const struct vm_area_struct *vma);
>  void dump_mm(const struct mm_struct *mm);
>  
> diff --git a/lib/vsprintf.c b/lib/vsprintf.c
> index f9cee8e1233c..41cd122bd307 100644
> --- a/lib/vsprintf.c
> +++ b/lib/vsprintf.c
> @@ -31,6 +31,7 @@
>  #include <linux/dcache.h>
>  #include <linux/cred.h>
>  #include <net/addrconf.h>
> +#include <linux/mmdebug.h>
>  
>  #include <asm/page.h>		/* for PAGE_SIZE */
>  #include <asm/sections.h>	/* for dereference_function_descriptor() */
> @@ -1361,6 +1362,29 @@ char *clock(char *buf, char *end, struct clk *clk, struct printf_spec spec,
>  	}
>  }
>  
> +static noinline_for_stack
> +char *flags_string(char *buf, char *end, void *flags_ptr,
> +			struct printf_spec spec, const char *fmt)
> +{
> +	unsigned long flags;
> +	gfp_t gfp_flags;
> +
> +	switch (fmt[1]) {
> +	case 'p':
> +		flags = *(unsigned long *)flags_ptr;
> +		return format_page_flags(flags, buf, end);
> +	case 'v':
> +		flags = *(unsigned long *)flags_ptr;
> +		return format_vma_flags(flags, buf, end);
> +	case 'g':
> +		gfp_flags = *(gfp_t *)flags_ptr;
> +		return format_gfp_flags(gfp_flags, buf, end);
> +	default:
> +		WARN_ONCE(1, "Unsupported flags modifier: %c\n", fmt[1]);
> +		return 0;
> +	}
> +}
> +

That return 0 aka return NULL will lead to an oops when the next thing
is printed. Did you mean 'return buf;'? 


>  int kptr_restrict __read_mostly;
>  
>  /*
> @@ -1448,6 +1472,11 @@ int kptr_restrict __read_mostly;
>   * - 'Cn' For a clock, it prints the name (Common Clock Framework) or address
>   *        (legacy clock framework) of the clock
>   * - 'Cr' For a clock, it prints the current rate of the clock
> + * - 'g' For flags to be printed as a collection of symbolic strings that would
> + *       construct the specific value. Supported flags given by option:
> + *       p page flags (see struct page) given as pointer to unsigned long
> + *       g gfp flags (GFP_* and __GFP_*) given as pointer to gfp_t
> + *       v vma flags (VM_*) given as pointer to unsigned long
>   *
>   * ** Please update also Documentation/printk-formats.txt when making changes **
>   *
> @@ -1600,6 +1629,8 @@ char *pointer(const char *fmt, char *buf, char *end, void *ptr,
>  		return dentry_name(buf, end,
>  				   ((const struct file *)ptr)->f_path.dentry,
>  				   spec, fmt);
> +	case 'g':
> +		return flags_string(buf, end, ptr, spec, fmt);
>  	}
>  	spec.flags |= SMALL;
>  	if (spec.field_width == -1) {
> diff --git a/mm/debug.c b/mm/debug.c
> index 2fdf0999e6f9..a092111920e7 100644
> --- a/mm/debug.c
> +++ b/mm/debug.c
> @@ -59,40 +59,109 @@ static const struct trace_print_flags pageflag_names[] = {
>  #endif
>  };
>  
> +static const struct trace_print_flags vmaflags_names[] = {
> +	{VM_READ,			"read"		},
> +	{VM_WRITE,			"write"		},
> +	{VM_EXEC,			"exec"		},
> +	{VM_SHARED,			"shared"	},
> +	{VM_MAYREAD,			"mayread"	},
> +	{VM_MAYWRITE,			"maywrite"	},
> +	{VM_MAYEXEC,			"mayexec"	},
> +	{VM_MAYSHARE,			"mayshare"	},
> +	{VM_GROWSDOWN,			"growsdown"	},
> +	{VM_PFNMAP,			"pfnmap"	},
> +	{VM_DENYWRITE,			"denywrite"	},
> +	{VM_LOCKONFAULT,		"lockonfault"	},
> +	{VM_LOCKED,			"locked"	},
> +	{VM_IO,				"io"		},
> +	{VM_SEQ_READ,			"seqread"	},
> +	{VM_RAND_READ,			"randread"	},
> +	{VM_DONTCOPY,			"dontcopy"	},
> +	{VM_DONTEXPAND,			"dontexpand"	},
> +	{VM_ACCOUNT,			"account"	},
> +	{VM_NORESERVE,			"noreserve"	},
> +	{VM_HUGETLB,			"hugetlb"	},
> +#if defined(CONFIG_X86)
> +	{VM_PAT,			"pat"		},
> +#elif defined(CONFIG_PPC)
> +	{VM_SAO,			"sao"		},
> +#elif defined(CONFIG_PARISC) || defined(CONFIG_METAG) || defined(CONFIG_IA64)
> +	{VM_GROWSUP,			"growsup"	},
> +#elif !defined(CONFIG_MMU)
> +	{VM_MAPPED_COPY,		"mappedcopy"	},
> +#else
> +	{VM_ARCH_1,			"arch_1"	},
> +#endif
> +	{VM_DONTDUMP,			"dontdump"	},
> +#ifdef CONFIG_MEM_SOFT_DIRTY
> +	{VM_SOFTDIRTY,			"softdirty"	},
> +#endif
> +	{VM_MIXEDMAP,			"mixedmap"	},
> +	{VM_HUGEPAGE,			"hugepage"	},
> +	{VM_NOHUGEPAGE,			"nohugepage"	},
> +	{VM_MERGEABLE,			"mergeable"	},
> +};
> +
>  static const struct trace_print_flags gfpflag_names[] = {
>  	__def_gfpflag_names
>  };
>  
> -static void dump_flag_names(unsigned long flags,
> -			const struct trace_print_flags *names, int count)
> +static char *format_flag_names(unsigned long flags, unsigned long mask_out,
> +		const struct trace_print_flags *names, int count,
> +		char *buf, char *end)
>  {
>  	const char *delim = "";
>  	unsigned long mask;
>  	int i;
>  
> -	pr_cont("(");
> +	buf += snprintf(buf, end - buf, "%#lx(", flags);

Sorry, you can't do it like this. The buf you've been passed from inside
vsnprintf may be beyond end, so end-buf is a negative number which will
(get converted to a huge positive size_t and) trigger a WARN_ONCE and
get you a return value of 0.


> +	flags &= ~mask_out;
>  
>  	for (i = 0; i < count && flags; i++) {
> +		if (buf >= end)
> +			break;

Even if you fix the above, this is also wrong. We have to return the
length of the string that would be generated if there was room enough,
so we cannot make an early return like this. As I said above, the
easiest way to do that is to do it inside vsprintf.c, where we have
e.g. string() available. So I'd do something like


char *format_flags(char *buf, char *end, unsigned long flags,
                   const struct trace_print_flags *names)
{
  unsigned long mask;
  const struct printf_spec strspec = {/* appropriate defaults*/}
  const struct printf_spec numspec = {/* appropriate defaults*/}

  for ( ; flags && names->mask; names++) {
    mask = names->mask;
    if ((flags & mask) != mask)
      continue;
    flags &= ~mask;
    buf = string(buf, end, names->name, strspec);
    if (flags) {
      if (buf < end)
        *buf = '|';
      buf++;
    }
  }
  if (flags)
    buf = number(buf, end, flags, numspec);
  return buf;
}

[where I've assumed that the trace_print_flags array is terminated with
an entry with 0 mask. Passing its length is also possible, but maybe a
little awkward if the arrays are defined in mm/ and contents depend on
.config.] 

Then flags_string() would call this directly with an appropriate array
for names, and we avoid the individual tiny helper
functions. flags_string() can still do the mask_out thing for page
flags, especially when/if the numeric and string representations are not
done at the same time.

Rasmus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
