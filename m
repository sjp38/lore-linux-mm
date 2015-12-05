Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 031FD6B0257
	for <linux-mm@kvack.org>; Sat,  5 Dec 2015 15:00:52 -0500 (EST)
Received: by wmec201 with SMTP id c201so104982156wme.1
        for <linux-mm@kvack.org>; Sat, 05 Dec 2015 12:00:51 -0800 (PST)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id n9si26507997wjq.229.2015.12.05.12.00.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Dec 2015 12:00:50 -0800 (PST)
Received: by wmww144 with SMTP id w144so98583343wmw.1
        for <linux-mm@kvack.org>; Sat, 05 Dec 2015 12:00:50 -0800 (PST)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: Re: [PATCH v2 1/3] mm, printk: introduce new format string for flags
References: <87io4hi06n.fsf@rasmusvillemoes.dk>
	<1449242195-16374-1-git-send-email-vbabka@suse.cz>
Date: Sat, 05 Dec 2015 21:00:48 +0100
In-Reply-To: <1449242195-16374-1-git-send-email-vbabka@suse.cz> (Vlastimil
	Babka's message of "Fri, 4 Dec 2015 16:16:33 +0100")
Message-ID: <87h9jwr7gv.fsf@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>

On Fri, Dec 04 2015, Vlastimil Babka <vbabka@suse.cz> wrote:

> In mm we use several kinds of flags bitfields that are sometimes printed for
> debugging purposes, or exported to userspace via sysfs. To make them easier to
> interpret independently on kernel version and config, we want to dump also the
> symbolic flag names. So far this has been done with repeated calls to
> pr_cont(), which is unreliable on SMP, and not usable for e.g. sysfs export.
>
> To get a more reliable and universal solution, this patch extends printk()
> format string for pointers to handle the page flags (%pgp), gfp_flags (%pgg)
> and vma flags (%pgv).

Hm, with that $subject, I'd expect the patch to touch little beyond
lib/vsprintf.c and Documentation/printk-formats.txt (plus whatever might
be needed to make the name arrays accessible).

> Existing users of dump_flag_names() are converted and simplified.

If you do a respin, please do that part in a separate patch. That would
make it a lot easier to review.

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

It should probably be emphasized that %pgp and %pgv expect (unsigned
long*), while %pgg expect (gfp_t*), just as you do in vsprintf.c.

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

How much header bloat does it cause by making all users of mmdebug.h
also include tracepoint.h? Couldn't we put the struct definition in
types.h instead?

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

Why test both ->mask and ->name? I could imagine some constant being
#defined to 0 due to some CONFIG_* (and stuff that tested "flag & THAT"
would then get compiled away), so maybe ->mask is insufficient. But
->name will always be non-NULL for all but the sentinel entry, right?

> +		mask = names->mask;
> +		if ((flags & mask) != mask)
> +			continue;

And if we have some constant which is 0, this will then actually cause
us to print the corresponding string. Do we want that? If not we should
have a "if (!mask) continue;". And how helpful are these strings really
if their meaning might be .config dependent?

> +		buf = string(buf, end, names->name, strspec);

So string() is robust against a NULL string (printing the string
"(null)"), but that seems silly to rely on. So I'd strongly lean towards
making the loop condition just test ->name.

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

Even if the user passed a field width (which is extremely unlikely), we
wouldn't honour it, so there's no reason to pass on the spec. But maybe
gcc realizes that.


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

OK.

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

OK.

I looked briefly at the conversions in mm/ and they seemed fine, but
others are more qualified to comment on that part.

Oh, and while I remember, citing from the end of printk-format.txt:

  If you add other %p extensions, please extend lib/test_printf.c with
  one or more test cases, if at all feasible.

Maybe I shouldn't have put that note at the end :)

Rasmus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
