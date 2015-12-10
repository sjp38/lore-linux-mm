Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id DD86482F77
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 22:51:31 -0500 (EST)
Received: by igcto18 with SMTP id to18so4910953igc.0
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 19:51:31 -0800 (PST)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.232])
        by mx.google.com with ESMTP id e96si17167436ioi.206.2015.12.09.19.51.30
        for <linux-mm@kvack.org>;
        Wed, 09 Dec 2015 19:51:30 -0800 (PST)
Date: Wed, 9 Dec 2015 22:51:28 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v2 1/3] mm, printk: introduce new format string for flags
Message-ID: <20151210035128.GA7814@home.goodmis.org>
References: <87io4hi06n.fsf@rasmusvillemoes.dk>
 <1449242195-16374-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1449242195-16374-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Ingo Molnar <mingo@kernel.org>

I should have been Cc'd on this as I'm the maintainer of a few of the files
here that is being modified.

On Fri, Dec 04, 2015 at 04:16:33PM +0100, Vlastimil Babka wrote:
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
> [linux@rasmusvillemoes.dk: lots of good implementation suggestions]
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Sasha Levin <sasha.levin@oracle.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Michal Hocko <mhocko@suse.cz>
> ---
> Should hopefully apply to mmots (release mmotm doesn't have the 3 -fix patches yet?)
> 
>  Documentation/printk-formats.txt |  14 ++++
>  include/linux/mmdebug.h          |   7 +-
>  include/linux/trace_events.h     |  10 ---
>  include/linux/tracepoint.h       |  10 +++
>  lib/vsprintf.c                   |  75 ++++++++++++++++++++++
>  mm/debug.c                       | 135 ++++++++++++++-------------------------
>  mm/oom_kill.c                    |   5 +-
>  mm/page_alloc.c                  |   5 +-
>  mm/page_owner.c                  |   6 +-
>  9 files changed, 160 insertions(+), 107 deletions(-)
> 
> diff --git a/Documentation/printk-formats.txt b/Documentation/printk-formats.txt
> index b784c270105f..8b6ab00fcfc9 100644
> --- a/Documentation/printk-formats.txt
> +++ b/Documentation/printk-formats.txt
> @@ -292,6 +292,20 @@ Raw pointer value SHOULD be printed with %p. The kernel supports
>  
>  	Passed by reference.
>  
> +Flags bitfields such as page flags, gfp_flags:
> +
> +	%pgp	referenced|uptodate|lru|active|private
> +	%pgg	GFP_USER|GFP_DMA32|GFP_NOWARN
> +	%pgv	read|exec|mayread|maywrite|mayexec|denywrite
> +
> +	For printing flags bitfields as a collection of symbolic constants that
> +	would construct the value. The type of flags is given by the third
> +	character. Currently supported are [p]age flags, [g]fp_flags and
> +	[v]ma_flags. The flag names and print order depends on the particular
> +	type.
> +
> +	Passed by reference.
> +
>  Network device features:
>  
>  	%pNF	0x000000000000c000
> diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
> index 3b77fab7ad28..2c8286cf162e 100644
> --- a/include/linux/mmdebug.h
> +++ b/include/linux/mmdebug.h
> @@ -2,15 +2,20 @@
>  #define LINUX_MM_DEBUG_H 1
>  
>  #include <linux/stringify.h>
> +#include <linux/types.h>
> +#include <linux/tracepoint.h>
>  
>  struct page;
>  struct vm_area_struct;
>  struct mm_struct;
>  
> +extern const struct trace_print_flags pageflag_names[];
> +extern const struct trace_print_flags vmaflag_names[];
> +extern const struct trace_print_flags gfpflag_names[];
> +
>  extern void dump_page(struct page *page, const char *reason);
>  extern void dump_page_badflags(struct page *page, const char *reason,
>  			       unsigned long badflags);
> -extern void dump_gfpflag_names(unsigned long gfp_flags);
>  void dump_vma(const struct vm_area_struct *vma);
>  void dump_mm(const struct mm_struct *mm);
>  
> diff --git a/include/linux/trace_events.h b/include/linux/trace_events.h
> index 429fdfc3baf5..d91404f89ff2 100644
> --- a/include/linux/trace_events.h
> +++ b/include/linux/trace_events.h
> @@ -15,16 +15,6 @@ struct tracer;
>  struct dentry;
>  struct bpf_prog;
>  
> -struct trace_print_flags {
> -	unsigned long		mask;
> -	const char		*name;
> -};
> -
> -struct trace_print_flags_u64 {
> -	unsigned long long	mask;
> -	const char		*name;
> -};
> -

Ingo took some patches from Andi Kleen that creates a tracepoint-defs.h file
If anything, these should be moved there. That code is currently in tip.

-- Steve

>  const char *trace_print_flags_seq(struct trace_seq *p, const char *delim,
>  				  unsigned long flags,
>  				  const struct trace_print_flags *flag_array);
> diff --git a/include/linux/tracepoint.h b/include/linux/tracepoint.h
> index 7834a8a8bf1e..a5d0ab46724d 100644
> --- a/include/linux/tracepoint.h
> +++ b/include/linux/tracepoint.h
> @@ -43,6 +43,16 @@ struct trace_enum_map {
>  	unsigned long		enum_value;
>  };
>  
> +struct trace_print_flags {
> +	unsigned long		mask;
> +	const char		*name;
> +};
> +
> +struct trace_print_flags_u64 {
> +	unsigned long long	mask;
> +	const char		*name;
> +};
> +
>  #define TRACEPOINT_DEFAULT_PRIO	10
>  
>  extern int
> diff --git a/lib/vsprintf.c b/lib/vsprintf.c
> index f9cee8e1233c..9a0697b14ea3 100644
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
> @@ -1361,6 +1362,73 @@ char *clock(char *buf, char *end, struct clk *clk, struct printf_spec spec,
>  	}
>  }
>  
> +static
> +char *format_flags(char *buf, char *end, unsigned long flags,
> +					const struct trace_print_flags *names)
> +{
> +	unsigned long mask;
> +	const struct printf_spec strspec = {
> +		.field_width = -1,
> +		.precision = -1,
> +	};
> +	const struct printf_spec numspec = {
> +		.flags = SPECIAL|SMALL,
> +		.field_width = -1,
> +		.precision = -1,
> +		.base = 16,
> +	};
> +
> +	for ( ; flags && (names->mask || names->name); names++) {
> +		mask = names->mask;
> +		if ((flags & mask) != mask)
> +			continue;
> +
> +		buf = string(buf, end, names->name, strspec);
> +
> +		flags &= ~mask;
> +		if (flags) {
> +			if (buf < end)
> +				*buf = '|';
> +			buf++;
> +		}
> +	}
> +
> +	if (flags)
> +		buf = number(buf, end, flags, numspec);
> +
> +	return buf;
> +}
> +
> +static noinline_for_stack
> +char *flags_string(char *buf, char *end, void *flags_ptr,
> +			struct printf_spec spec, const char *fmt)
> +{
> +	unsigned long flags;
> +	const struct trace_print_flags *names;
> +
> +	switch (fmt[1]) {
> +	case 'p':
> +		flags = *(unsigned long *)flags_ptr;
> +		/* Remove zone id */
> +		flags &= (1UL << NR_PAGEFLAGS) - 1;
> +		names = pageflag_names;
> +		break;
> +	case 'v':
> +		flags = *(unsigned long *)flags_ptr;
> +		names = vmaflag_names;
> +		break;
> +	case 'g':
> +		flags = *(gfp_t *)flags_ptr;
> +		names = gfpflag_names;
> +		break;
> +	default:
> +		WARN_ONCE(1, "Unsupported flags modifier: %c\n", fmt[1]);
> +		return buf;
> +	}
> +
> +	return format_flags(buf, end, flags, names);
> +}
> +
>  int kptr_restrict __read_mostly;
>  
>  /*
> @@ -1448,6 +1516,11 @@ int kptr_restrict __read_mostly;
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
> @@ -1600,6 +1673,8 @@ char *pointer(const char *fmt, char *buf, char *end, void *ptr,
>  		return dentry_name(buf, end,
>  				   ((const struct file *)ptr)->f_path.dentry,
>  				   spec, fmt);
> +	case 'g':
> +		return flags_string(buf, end, ptr, spec, fmt);
>  	}
>  	spec.flags |= SMALL;
>  	if (spec.field_width == -1) {
> diff --git a/mm/debug.c b/mm/debug.c
> index 9416524839d8..c42bb4c13c2d 100644
> --- a/mm/debug.c
> +++ b/mm/debug.c
> @@ -23,7 +23,7 @@ char *migrate_reason_names[MR_TYPES] = {
>  	"cma",
>  };
>  
> -static const struct trace_print_flags pageflag_names[] = {
> +const struct trace_print_flags pageflag_names[] = {
>  	{1UL << PG_locked,		"locked"	},
>  	{1UL << PG_error,		"error"		},
>  	{1UL << PG_referenced,		"referenced"	},
> @@ -57,86 +57,10 @@ static const struct trace_print_flags pageflag_names[] = {
>  	{1UL << PG_young,		"young"		},
>  	{1UL << PG_idle,		"idle"		},
>  #endif
> +	{0,				NULL		},
>  };
>  
> -static const struct trace_print_flags gfpflag_names[] = {
> -	__def_gfpflag_names
> -};
> -
> -static void dump_flag_names(unsigned long flags,
> -			const struct trace_print_flags *names, int count)
> -{
> -	const char *delim = "";
> -	unsigned long mask;
> -	int i;
> -
> -	pr_cont("(");
> -
> -	for (i = 0; i < count && flags; i++) {
> -
> -		mask = names[i].mask;
> -		if ((flags & mask) != mask)
> -			continue;
> -
> -		flags &= ~mask;
> -		pr_cont("%s%s", delim, names[i].name);
> -		delim = "|";
> -	}
> -
> -	/* check for left over flags */
> -	if (flags)
> -		pr_cont("%s%#lx", delim, flags);
> -
> -	pr_cont(")\n");
> -}
> -
> -void dump_gfpflag_names(unsigned long gfp_flags)
> -{
> -	dump_flag_names(gfp_flags, gfpflag_names, ARRAY_SIZE(gfpflag_names));
> -}
> -
> -void dump_page_badflags(struct page *page, const char *reason,
> -		unsigned long badflags)
> -{
> -	unsigned long printflags = page->flags;
> -
> -	pr_emerg("page:%p count:%d mapcount:%d mapping:%p index:%#lx",
> -		  page, atomic_read(&page->_count), page_mapcount(page),
> -		  page->mapping, page->index);
> -	if (PageCompound(page))
> -		pr_cont(" compound_mapcount: %d", compound_mapcount(page));
> -	pr_cont("\n");
> -	BUILD_BUG_ON(ARRAY_SIZE(pageflag_names) != __NR_PAGEFLAGS);
> -
> -	pr_emerg("flags: %#lx", printflags);
> -	/* remove zone id */
> -	printflags &= (1UL << NR_PAGEFLAGS) - 1;
> -	dump_flag_names(printflags, pageflag_names, ARRAY_SIZE(pageflag_names));
> -
> -	if (reason)
> -		pr_alert("page dumped because: %s\n", reason);
> -	if (page->flags & badflags) {
> -		printflags = page->flags & badflags;
> -		pr_alert("bad because of flags: %#lx:", printflags);
> -		dump_flag_names(printflags, pageflag_names,
> -						ARRAY_SIZE(pageflag_names));
> -	}
> -#ifdef CONFIG_MEMCG
> -	if (page->mem_cgroup)
> -		pr_alert("page->mem_cgroup:%p\n", page->mem_cgroup);
> -#endif
> -}
> -
> -void dump_page(struct page *page, const char *reason)
> -{
> -	dump_page_badflags(page, reason, 0);
> -	dump_page_owner(page);
> -}
> -EXPORT_SYMBOL(dump_page);
> -
> -#ifdef CONFIG_DEBUG_VM
> -
> -static const struct trace_print_flags vmaflags_names[] = {
> +const struct trace_print_flags vmaflag_names[] = {
>  	{VM_READ,			"read"		},
>  	{VM_WRITE,			"write"		},
>  	{VM_EXEC,			"exec"		},
> @@ -177,22 +101,61 @@ static const struct trace_print_flags vmaflags_names[] = {
>  	{VM_HUGEPAGE,			"hugepage"	},
>  	{VM_NOHUGEPAGE,			"nohugepage"	},
>  	{VM_MERGEABLE,			"mergeable"	},
> +	{0,				NULL		},
> +};
> +
> +const struct trace_print_flags gfpflag_names[] = {
> +	__def_gfpflag_names,
> +	{0, NULL},
>  };
>  
> +void dump_page_badflags(struct page *page, const char *reason,
> +		unsigned long badflags)
> +{
> +	unsigned long printflags = page->flags;
> +
> +	pr_emerg("page:%p count:%d mapcount:%d mapping:%p index:%#lx\n",
> +		  page, atomic_read(&page->_count), page_mapcount(page),
> +		  page->mapping, page->index);
> +	BUILD_BUG_ON(ARRAY_SIZE(pageflag_names) != __NR_PAGEFLAGS + 1);
> +
> +	pr_emerg("flags: %#lx(%pgp)\n", printflags, &printflags);
> +
> +	if (reason)
> +		pr_alert("page dumped because: %s\n", reason);
> +	if (page->flags & badflags) {
> +		printflags = page->flags & badflags;
> +		pr_alert("bad because of flags: %#lx(%pgp)\n", printflags,
> +								&printflags);
> +	}
> +#ifdef CONFIG_MEMCG
> +	if (page->mem_cgroup)
> +		pr_alert("page->mem_cgroup:%p\n", page->mem_cgroup);
> +#endif
> +}
> +
> +void dump_page(struct page *page, const char *reason)
> +{
> +	dump_page_badflags(page, reason, 0);
> +	dump_page_owner(page);
> +}
> +EXPORT_SYMBOL(dump_page);
> +
> +#ifdef CONFIG_DEBUG_VM
> +
>  void dump_vma(const struct vm_area_struct *vma)
>  {
>  	pr_emerg("vma %p start %p end %p\n"
>  		"next %p prev %p mm %p\n"
>  		"prot %lx anon_vma %p vm_ops %p\n"
> -		"pgoff %lx file %p private_data %p\n",
> +		"pgoff %lx file %p private_data %p\n"
> +		"flags: %#lx(%pgv)\n",
>  		vma, (void *)vma->vm_start, (void *)vma->vm_end, vma->vm_next,
>  		vma->vm_prev, vma->vm_mm,
>  		(unsigned long)pgprot_val(vma->vm_page_prot),
>  		vma->anon_vma, vma->vm_ops, vma->vm_pgoff,
> -		vma->vm_file, vma->vm_private_data);
> -	pr_emerg("flags: %#lx", vma->vm_flags);
> -	dump_flag_names(vma->vm_flags, vmaflags_names,
> -						ARRAY_SIZE(vmaflags_names));
> +		vma->vm_file, vma->vm_private_data,
> +		vma->vm_flags, &vma->vm_flags);
>  }
>  EXPORT_SYMBOL(dump_vma);
>  
> @@ -263,9 +226,7 @@ void dump_mm(const struct mm_struct *mm)
>  		""		/* This is here to not have a comma! */
>  		);
>  
> -	pr_emerg("def_flags: %#lx", mm->def_flags);
> -	dump_flag_names(mm->def_flags, vmaflags_names,
> -					ARRAY_SIZE(vmaflags_names));
> +	pr_emerg("def_flags: %#lx(%pgv)\n", mm->def_flags, &mm->def_flags);
>  }
>  
>  #endif		/* CONFIG_DEBUG_VM */
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 542d56c93209..07bba5a46b47 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -387,10 +387,9 @@ static void dump_header(struct oom_control *oc, struct task_struct *p,
>  			struct mem_cgroup *memcg)
>  {
>  	pr_warning("%s invoked oom-killer: order=%d, oom_score_adj=%hd, "
> -			"gfp_mask=0x%x",
> +			"gfp_mask=%#x(%pgg)\n",
>  		current->comm, oc->order, current->signal->oom_score_adj,
> -		oc->gfp_mask);
> -	dump_gfpflag_names(oc->gfp_mask);
> +		oc->gfp_mask, &oc->gfp_mask);
>  
>  	cpuset_print_current_mems_allowed();
>  	dump_stack();
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d6d7c97c0b28..bd94c7465dea 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2711,9 +2711,8 @@ void warn_alloc_failed(gfp_t gfp_mask, unsigned int order, const char *fmt, ...)
>  		va_end(args);
>  	}
>  
> -	pr_warn("%s: page allocation failure: order:%u, mode:0x%x",
> -		current->comm, order, gfp_mask);
> -	dump_gfpflag_names(gfp_mask);
> +	pr_warn("%s: page allocation failure: order:%u, mode:%#x(%pgg)\n",
> +		current->comm, order, gfp_mask, &gfp_mask);
>  	dump_stack();
>  	if (!should_suppress_show_mem())
>  		show_mem(filter);
> diff --git a/mm/page_owner.c b/mm/page_owner.c
> index f4acd2452c35..313251f36d86 100644
> --- a/mm/page_owner.c
> +++ b/mm/page_owner.c
> @@ -208,9 +208,9 @@ void __dump_page_owner(struct page *page)
>  		return;
>  	}
>  
> -	pr_alert("page allocated via order %u, migratetype %s, gfp_mask 0x%x",
> -			page_ext->order, migratetype_names[mt], gfp_mask);
> -	dump_gfpflag_names(gfp_mask);
> +	pr_alert("page allocated via order %u, migratetype %s, "
> +			"gfp_mask %#x(%pgg)\n", page_ext->order,
> +			migratetype_names[mt], gfp_mask, &gfp_mask);
>  	print_stack_trace(&trace, 0);
>  
>  	if (page_ext->last_migrate_reason != -1)
> -- 
> 2.6.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
