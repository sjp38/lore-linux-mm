Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id A03436B0254
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 12:40:29 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so48108048pab.0
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 09:40:29 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id u63si5918549pfa.181.2015.12.02.09.40.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 09:40:28 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so48107691pab.0
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 09:40:28 -0800 (PST)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.0 \(3094\))
Subject: Re: [PATCH 1/2] mm, printk: introduce new format string for flags
From: yalin wang <yalin.wang2010@gmail.com>
In-Reply-To: <1448899821-9671-1-git-send-email-vbabka@suse.cz>
Date: Wed, 2 Dec 2015 09:40:26 -0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <4EAD2C33-D0E4-4DEB-92E5-9C0457E8635C@gmail.com>
References: <20151125143010.GI27283@dhcp22.suse.cz> <1448899821-9671-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Rasmus Villemoes <linux@rasmusvillemoes.dk>


> On Nov 30, 2015, at 08:10, Vlastimil Babka <vbabka@suse.cz> wrote:
>=20
> In mm we use several kinds of flags bitfields that are sometimes =
printed for
> debugging purposes, or exported to userspace via sysfs. To make them =
easier to
> interpret independently on kernel version and config, we want to dump =
also the
> symbolic flag names. So far this has been done with repeated calls to
> pr_cont(), which is unreliable on SMP, and not usable for e.g. sysfs =
export.
>=20
> To get a more reliable and universal solution, this patch extends =
printk()
> format string for pointers to handle the page flags (%pgp), gfp_flags =
(%pgg)
> and vma flags (%pgv). Existing users of dump_flag_names() are =
converted and
> simplified.
>=20
> It would be possible to pass flags by value instead of pointer, but =
the %p
> format string for pointers already has extensions for various kernel
> structures, so it's a good fit, and the extra indirection in a =
non-critical
> path is negligible.
>=20
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>
> ---
> I'm sending it on top of the page_owner series, as it's already in =
mmotm.
> But to reduce churn (in case this approach is accepted), I can later
> incorporate it and resend it whole.
>=20
> Documentation/printk-formats.txt |  14 ++++
> include/linux/mmdebug.h          |   5 +-
> lib/vsprintf.c                   |  31 ++++++++
> mm/debug.c                       | 150 =
++++++++++++++++++++++-----------------
> mm/oom_kill.c                    |   5 +-
> mm/page_alloc.c                  |   5 +-
> mm/page_owner.c                  |   5 +-
> 7 files changed, 140 insertions(+), 75 deletions(-)
>=20
> diff --git a/Documentation/printk-formats.txt =
b/Documentation/printk-formats.txt
> index b784c270105f..4b5156e74b09 100644
> --- a/Documentation/printk-formats.txt
> +++ b/Documentation/printk-formats.txt
> @@ -292,6 +292,20 @@ Raw pointer value SHOULD be printed with %p. The =
kernel supports
>=20
> 	Passed by reference.
>=20
> +Flags bitfields such as page flags, gfp_flags:
> +
> +	%pgp	0x1fffff8000086c(referenced|uptodate|lru|active|private)
> +	%pgg	0x24202c4(GFP_USER|GFP_DMA32|GFP_NOWARN)
> +	%pgv	0x875(read|exec|mayread|maywrite|mayexec|denywrite)
> +
> +	For printing raw values of flags bitfields together with =
symbolic
> +	strings that would construct the value. The type of flags is =
given by
> +	the third character. Currently supported are [p]age flags, =
[g]fp_flags
> +	and [v]ma_flags. The flag names and print order depends on the
> +	particular type.
> +
> +	Passed by reference.
> +
> Network device features:
>=20
> 	%pNF	0x000000000000c000
> diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
> index 3b77fab7ad28..e6518df259ca 100644
> --- a/include/linux/mmdebug.h
> +++ b/include/linux/mmdebug.h
> @@ -2,6 +2,7 @@
> #define LINUX_MM_DEBUG_H 1
>=20
> #include <linux/stringify.h>
> +#include <linux/types.h>
>=20
> struct page;
> struct vm_area_struct;
> @@ -10,7 +11,9 @@ struct mm_struct;
> extern void dump_page(struct page *page, const char *reason);
> extern void dump_page_badflags(struct page *page, const char *reason,
> 			       unsigned long badflags);
> -extern void dump_gfpflag_names(unsigned long gfp_flags);
> +extern char *format_page_flags(unsigned long flags, char *buf, char =
*end);
> +extern char *format_vma_flags(unsigned long flags, char *buf, char =
*end);
> +extern char *format_gfp_flags(gfp_t gfp_flags, char *buf, char*end);
> void dump_vma(const struct vm_area_struct *vma);
> void dump_mm(const struct mm_struct *mm);
>=20
> diff --git a/lib/vsprintf.c b/lib/vsprintf.c
> index f9cee8e1233c..41cd122bd307 100644
> --- a/lib/vsprintf.c
> +++ b/lib/vsprintf.c
> @@ -31,6 +31,7 @@
> #include <linux/dcache.h>
> #include <linux/cred.h>
> #include <net/addrconf.h>
> +#include <linux/mmdebug.h>
>=20
> #include <asm/page.h>		/* for PAGE_SIZE */
> #include <asm/sections.h>	/* for dereference_function_descriptor() =
*/
> @@ -1361,6 +1362,29 @@ char *clock(char *buf, char *end, struct clk =
*clk, struct printf_spec spec,
> 	}
> }
>=20
> +static noinline_for_stack
> +char *flags_string(char *buf, char *end, void *flags_ptr,
> +			struct printf_spec spec, const char *fmt)
> +{
> +	unsigned long flags;
> +	gfp_t gfp_flags;
> +
> +	switch (fmt[1]) {
> +	case 'p':
> +		flags =3D *(unsigned long *)flags_ptr;
> +		return format_page_flags(flags, buf, end);
> +	case 'v':
> +		flags =3D *(unsigned long *)flags_ptr;
> +		return format_vma_flags(flags, buf, end);
> +	case 'g':
> +		gfp_flags =3D *(gfp_t *)flags_ptr;
> +		return format_gfp_flags(gfp_flags, buf, end);
> +	default:
> +		WARN_ONCE(1, "Unsupported flags modifier: %c\n", =
fmt[1]);
> +		return 0;
> +	}
> +}
> +
> int kptr_restrict __read_mostly;
>=20
> /*
> @@ -1448,6 +1472,11 @@ int kptr_restrict __read_mostly;
>  * - 'Cn' For a clock, it prints the name (Common Clock Framework) or =
address
>  *        (legacy clock framework) of the clock
>  * - 'Cr' For a clock, it prints the current rate of the clock
> + * - 'g' For flags to be printed as a collection of symbolic strings =
that would
> + *       construct the specific value. Supported flags given by =
option:
> + *       p page flags (see struct page) given as pointer to unsigned =
long
> + *       g gfp flags (GFP_* and __GFP_*) given as pointer to gfp_t
> + *       v vma flags (VM_*) given as pointer to unsigned long
>  *
>  * ** Please update also Documentation/printk-formats.txt when making =
changes **
>  *
> @@ -1600,6 +1629,8 @@ char *pointer(const char *fmt, char *buf, char =
*end, void *ptr,
> 		return dentry_name(buf, end,
> 				   ((const struct file =
*)ptr)->f_path.dentry,
> 				   spec, fmt);
> +	case 'g':
> +		return flags_string(buf, end, ptr, spec, fmt);
> 	}
> 	spec.flags |=3D SMALL;
> 	if (spec.field_width =3D=3D -1) {
> diff --git a/mm/debug.c b/mm/debug.c
> index 2fdf0999e6f9..a092111920e7 100644
> --- a/mm/debug.c
> +++ b/mm/debug.c
> @@ -59,40 +59,109 @@ static const struct trace_print_flags =
pageflag_names[] =3D {
> #endif
> };
>=20
> +static const struct trace_print_flags vmaflags_names[] =3D {
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
> +#elif defined(CONFIG_PARISC) || defined(CONFIG_METAG) || =
defined(CONFIG_IA64)
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
> static const struct trace_print_flags gfpflag_names[] =3D {
> 	__def_gfpflag_names
> };
>=20
> -static void dump_flag_names(unsigned long flags,
> -			const struct trace_print_flags *names, int =
count)
> +static char *format_flag_names(unsigned long flags, unsigned long =
mask_out,
> +		const struct trace_print_flags *names, int count,
> +		char *buf, char *end)
> {
> 	const char *delim =3D "";
> 	unsigned long mask;
> 	int i;
>=20
> -	pr_cont("(");
> +	buf +=3D snprintf(buf, end - buf, "%#lx(", flags);
> +
> +	flags &=3D ~mask_out;
>=20
> 	for (i =3D 0; i < count && flags; i++) {
> +		if (buf >=3D end)
> +			break;
>=20
> 		mask =3D names[i].mask;
> 		if ((flags & mask) !=3D mask)
> 			continue;
>=20
> 		flags &=3D ~mask;
> -		pr_cont("%s%s", delim, names[i].name);
> +		buf +=3D snprintf(buf, end - buf, "%s%s", delim, =
names[i].name);
> 		delim =3D "|";
> 	}
>=20
> 	/* check for left over flags */
> -	if (flags)
> -		pr_cont("%s%#lx", delim, flags);
> +	if (flags && (buf < end))
> +		buf +=3D snprintf(buf, end - buf, "%s%#lx", delim, =
flags);
> +
> +	if (buf < end) {
> +		*buf =3D ')';
> +		buf++;
> +	}
>=20
> -	pr_cont(")\n");
> +	return buf;
> }
>=20
> -void dump_gfpflag_names(unsigned long gfp_flags)
> +char *format_page_flags(unsigned long flags, char *buf, char *end)
> {
> -	dump_flag_names(gfp_flags, gfpflag_names, =
ARRAY_SIZE(gfpflag_names));
> +	/* remove zone id */
> +	unsigned long mask =3D (1UL << NR_PAGEFLAGS) - 1;
> +
> +	return format_flag_names(flags, ~mask, pageflag_names,
> +					ARRAY_SIZE(pageflag_names), buf, =
end);
> +}
> +
> +char *format_vma_flags(unsigned long flags, char *buf, char *end)
> +{
> +	return format_flag_names(flags, 0, vmaflags_names,
> +					ARRAY_SIZE(vmaflags_names), buf, =
end);
> +}
> +
> +char *format_gfp_flags(gfp_t gfp_flags, char *buf, char *end)
> +{
> +	return format_flag_names(gfp_flags, 0, gfpflag_names,
> +					ARRAY_SIZE(gfpflag_names), buf, =
end);
> }
>=20
> void dump_page_badflags(struct page *page, const char *reason,
> @@ -108,18 +177,15 @@ void dump_page_badflags(struct page *page, const =
char *reason,
> 	pr_cont("\n");
> 	BUILD_BUG_ON(ARRAY_SIZE(pageflag_names) !=3D __NR_PAGEFLAGS);
>=20
> -	pr_emerg("flags: %#lx", printflags);
> +	pr_emerg("flags: %pgp\n", &printflags);
> 	/* remove zone id */
> 	printflags &=3D (1UL << NR_PAGEFLAGS) - 1;
> -	dump_flag_names(printflags, pageflag_names, =
ARRAY_SIZE(pageflag_names));
>=20
> 	if (reason)
> 		pr_alert("page dumped because: %s\n", reason);
> 	if (page->flags & badflags) {
> 		printflags =3D page->flags & badflags;
> -		pr_alert("bad because of flags: %#lx:", printflags);
> -		dump_flag_names(printflags, pageflag_names,
> -						=
ARRAY_SIZE(pageflag_names));
> +		pr_alert("bad because of flags: %pgp\n", &printflags);
> 	}
> #ifdef CONFIG_MEMCG
> 	if (page->mem_cgroup)
> @@ -136,63 +202,19 @@ EXPORT_SYMBOL(dump_page);
>=20
> #ifdef CONFIG_DEBUG_VM
>=20
> -static const struct trace_print_flags vmaflags_names[] =3D {
> -	{VM_READ,			"read"		},
> -	{VM_WRITE,			"write"		},
> -	{VM_EXEC,			"exec"		},
> -	{VM_SHARED,			"shared"	},
> -	{VM_MAYREAD,			"mayread"	},
> -	{VM_MAYWRITE,			"maywrite"	},
> -	{VM_MAYEXEC,			"mayexec"	},
> -	{VM_MAYSHARE,			"mayshare"	},
> -	{VM_GROWSDOWN,			"growsdown"	},
> -	{VM_PFNMAP,			"pfnmap"	},
> -	{VM_DENYWRITE,			"denywrite"	},
> -	{VM_LOCKONFAULT,		"lockonfault"	},
> -	{VM_LOCKED,			"locked"	},
> -	{VM_IO,				"io"		},
> -	{VM_SEQ_READ,			"seqread"	},
> -	{VM_RAND_READ,			"randread"	},
> -	{VM_DONTCOPY,			"dontcopy"	},
> -	{VM_DONTEXPAND,			"dontexpand"	},
> -	{VM_ACCOUNT,			"account"	},
> -	{VM_NORESERVE,			"noreserve"	},
> -	{VM_HUGETLB,			"hugetlb"	},
> -#if defined(CONFIG_X86)
> -	{VM_PAT,			"pat"		},
> -#elif defined(CONFIG_PPC)
> -	{VM_SAO,			"sao"		},
> -#elif defined(CONFIG_PARISC) || defined(CONFIG_METAG) || =
defined(CONFIG_IA64)
> -	{VM_GROWSUP,			"growsup"	},
> -#elif !defined(CONFIG_MMU)
> -	{VM_MAPPED_COPY,		"mappedcopy"	},
> -#else
> -	{VM_ARCH_1,			"arch_1"	},
> -#endif
> -	{VM_DONTDUMP,			"dontdump"	},
> -#ifdef CONFIG_MEM_SOFT_DIRTY
> -	{VM_SOFTDIRTY,			"softdirty"	},
> -#endif
> -	{VM_MIXEDMAP,			"mixedmap"	},
> -	{VM_HUGEPAGE,			"hugepage"	},
> -	{VM_NOHUGEPAGE,			"nohugepage"	},
> -	{VM_MERGEABLE,			"mergeable"	},
> -};
> -
> void dump_vma(const struct vm_area_struct *vma)
> {
> 	pr_emerg("vma %p start %p end %p\n"
> 		"next %p prev %p mm %p\n"
> 		"prot %lx anon_vma %p vm_ops %p\n"
> -		"pgoff %lx file %p private_data %p\n",
> +		"pgoff %lx file %p private_data %p\n"
> +		"flags: %pgv\n",
> 		vma, (void *)vma->vm_start, (void *)vma->vm_end, =
vma->vm_next,
> 		vma->vm_prev, vma->vm_mm,
> 		(unsigned long)pgprot_val(vma->vm_page_prot),
> 		vma->anon_vma, vma->vm_ops, vma->vm_pgoff,
> -		vma->vm_file, vma->vm_private_data);
> -	pr_emerg("flags: %#lx", vma->vm_flags);
> -	dump_flag_names(vma->vm_flags, vmaflags_names,
> -						=
ARRAY_SIZE(vmaflags_names));
> +		vma->vm_file, vma->vm_private_data,
> +		&vma->vm_flags);
> }
> EXPORT_SYMBOL(dump_vma);
>=20
> @@ -263,9 +285,7 @@ void dump_mm(const struct mm_struct *mm)
> 		""		/* This is here to not have a comma! */
> 		);
>=20
> -	pr_emerg("def_flags: %#lx", mm->def_flags);
> -	dump_flag_names(mm->def_flags, vmaflags_names,
> -					ARRAY_SIZE(vmaflags_names));
> +	pr_emerg("def_flags: %pgv\n", &mm->def_flags);
> }
>=20
> #endif		/* CONFIG_DEBUG_VM */
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 542d56c93209..63a68b62ee68 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -387,10 +387,9 @@ static void dump_header(struct oom_control *oc, =
struct task_struct *p,
> 			struct mem_cgroup *memcg)
> {
> 	pr_warning("%s invoked oom-killer: order=3D%d, =
oom_score_adj=3D%hd, "
> -			"gfp_mask=3D0x%x",
> +			"gfp_mask=3D%pgg\n",
> 		current->comm, oc->order, =
current->signal->oom_score_adj,
> -		oc->gfp_mask);
> -	dump_gfpflag_names(oc->gfp_mask);
> +		&oc->gfp_mask);
>=20
> 	cpuset_print_current_mems_allowed();
> 	dump_stack();
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 80349acd8c17..77d2c75f80e4 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2711,9 +2711,8 @@ void warn_alloc_failed(gfp_t gfp_mask, unsigned =
int order, const char *fmt, ...)
> 		va_end(args);
> 	}
>=20
> -	pr_warn("%s: page allocation failure: order:%u, mode:0x%x",
> -		current->comm, order, gfp_mask);
> -	dump_gfpflag_names(gfp_mask);
> +	pr_warn("%s: page allocation failure: order:%u, mode:%pgg\n",
> +		current->comm, order, &gfp_mask);
> 	dump_stack();
> 	if (!should_suppress_show_mem())
> 		show_mem(filter);
> diff --git a/mm/page_owner.c b/mm/page_owner.c
> index f4acd2452c35..ff862b6d12da 100644
> --- a/mm/page_owner.c
> +++ b/mm/page_owner.c
> @@ -208,9 +208,8 @@ void __dump_page_owner(struct page *page)
> 		return;
> 	}
>=20
> -	pr_alert("page allocated via order %u, migratetype %s, gfp_mask =
0x%x",
> -			page_ext->order, migratetype_names[mt], =
gfp_mask);
> -	dump_gfpflag_names(gfp_mask);
> +	pr_alert("page allocated via order %u, migratetype %s, gfp_mask =
%pgg\n",
> +			page_ext->order, migratetype_names[mt], =
&gfp_mask);
> 	print_stack_trace(&trace, 0);
>=20
> 	if (page_ext->last_migrate_reason !=3D -1)
> --=20
> 2.6.3
>=20
i am thinking why not make %pg* to be more generic ?
not restricted to only GFP / vma flags / page flags .
so could we change format like this ?
define a flag spec struct to include flag and trace_print_flags and some =
other option :
typedef struct {=20
unsigned long flag;
struct trace_print_flags *flags;
unsigned long option; } flag_sec;
flag_sec my_flag;
in printk we only pass like this :
printk(=E2=80=9C%pg\n=E2=80=9D, &my_flag) ;
then it can print any flags defined by user .
more useful for other drivers to use .

Thanks









=20



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
