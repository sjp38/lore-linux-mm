Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f50.google.com (mail-qa0-f50.google.com [209.85.216.50])
	by kanga.kvack.org (Postfix) with ESMTP id 64B9D6B0035
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 14:51:19 -0400 (EDT)
Received: by mail-qa0-f50.google.com with SMTP id cm18so2504667qab.37
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 11:51:19 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id lo1si1384358qcb.9.2014.08.29.11.51.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Aug 2014 11:51:18 -0700 (PDT)
Date: Fri, 29 Aug 2014 14:51:10 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 1/3] Introduce dump_vma
Message-ID: <20140829185110.GA12774@nhori.bos.redhat.com>
References: <1409324059-28692-1-git-send-email-sasha.levin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1409324059-28692-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, khlebnikov@openvz.org, riel@redhat.com, mgorman@suse.de, mhocko@suse.cz, hughd@google.com, vbabka@suse.cz, walken@google.com, minchan@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Aug 29, 2014 at 10:54:17AM -0400, Sasha Levin wrote:
> Introduce a helper to dump information about a VMA, this also
> makes dump_page_flags more generic and re-uses that so the
> output looks very similar to dump_page:
> 
> [   61.903437] vma ffff88070f88be00 start 00007fff25970000 end 00007fff25992000
> [   61.903437] next ffff88070facd600 prev ffff88070face400 mm ffff88070fade000
> [   61.903437] prot 8000000000000025 anon_vma ffff88070fa1e200 vm_ops           (null)
> [   61.903437] pgoff 7ffffffdd file           (null) private_data           (null)
> [   61.909129] flags: 0x100173(read|write|mayread|maywrite|mayexec|growsdown|account)
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

# checkpatch.pl shows warnings on using printk(KERN_ALERT), but there
# are many other lines using printk in this file, so it should be done
# as a whole in a separate patch.

Thanks,
Naoya Horiguchi

> ---
>  include/linux/mmdebug.h |    2 ++
>  mm/page_alloc.c         |   77 +++++++++++++++++++++++++++++++++++++++++------
>  2 files changed, 70 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
> index 2f348d0..dfb9333 100644
> --- a/include/linux/mmdebug.h
> +++ b/include/linux/mmdebug.h
> @@ -4,10 +4,12 @@
>  #include <linux/stringify.h>
>  
>  struct page;
> +struct vm_area_struct;
>  
>  extern void dump_page(struct page *page, const char *reason);
>  extern void dump_page_badflags(struct page *page, const char *reason,
>  			       unsigned long badflags);
> +void dump_vma(const struct vm_area_struct *vma);
>  
>  #ifdef CONFIG_DEBUG_VM
>  #define VM_BUG_ON(cond) BUG_ON(cond)
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index f86023b..add97b8 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6628,27 +6628,26 @@ static const struct trace_print_flags pageflag_names[] = {
>  #endif
>  };
>  
> -static void dump_page_flags(unsigned long flags)
> +static void dump_flags(unsigned long flags,
> +			const struct trace_print_flags *names, int count)
>  {
>  	const char *delim = "";
>  	unsigned long mask;
>  	int i;
>  
> -	BUILD_BUG_ON(ARRAY_SIZE(pageflag_names) != __NR_PAGEFLAGS);
> -
> -	printk(KERN_ALERT "page flags: %#lx(", flags);
> +	printk(KERN_ALERT "flags: %#lx(", flags);
>  
>  	/* remove zone id */
>  	flags &= (1UL << NR_PAGEFLAGS) - 1;
>  
> -	for (i = 0; i < ARRAY_SIZE(pageflag_names) && flags; i++) {
> +	for (i = 0; i < count && flags; i++) {
>  
> -		mask = pageflag_names[i].mask;
> +		mask = names[i].mask;
>  		if ((flags & mask) != mask)
>  			continue;
>  
>  		flags &= ~mask;
> -		printk("%s%s", delim, pageflag_names[i].name);
> +		printk("%s%s", delim, names[i].name);
>  		delim = "|";
>  	}
>  
> @@ -6666,12 +6665,14 @@ void dump_page_badflags(struct page *page, const char *reason,
>  	       "page:%p count:%d mapcount:%d mapping:%p index:%#lx\n",
>  		page, atomic_read(&page->_count), page_mapcount(page),
>  		page->mapping, page->index);
> -	dump_page_flags(page->flags);
> +	BUILD_BUG_ON(ARRAY_SIZE(pageflag_names) != __NR_PAGEFLAGS);
> +	dump_flags(page->flags, pageflag_names, ARRAY_SIZE(pageflag_names));
>  	if (reason)
>  		pr_alert("page dumped because: %s\n", reason);
>  	if (page->flags & badflags) {
>  		pr_alert("bad because of flags:\n");
> -		dump_page_flags(page->flags & badflags);
> +		dump_flags(page->flags & badflags,
> +				pageflag_names, ARRAY_SIZE(pageflag_names));
>  	}
>  	mem_cgroup_print_bad_page(page);
>  }
> @@ -6681,3 +6682,61 @@ void dump_page(struct page *page, const char *reason)
>  	dump_page_badflags(page, reason, 0);
>  }
>  EXPORT_SYMBOL(dump_page);
> +
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
> +	{VM_LOCKED,			"locked"	},
> +	{VM_IO,				"io"		},
> +	{VM_SEQ_READ,			"seqread"	},
> +	{VM_RAND_READ,			"randread"	},
> +	{VM_DONTCOPY,			"dontcopy"	},
> +	{VM_DONTEXPAND,			"dontexpand"	},
> +	{VM_ACCOUNT,			"account"	},
> +	{VM_NORESERVE,			"noreserve"	},
> +	{VM_HUGETLB,			"hugetlb"	},
> +	{VM_NONLINEAR,			"nonlinear"	},
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
> +void dump_vma(const struct vm_area_struct *vma)
> +{
> +	printk(KERN_ALERT
> +		"vma %p start %p end %p\n"
> +		"next %p prev %p mm %p\n"
> +		"prot %lx anon_vma %p vm_ops %p\n"
> +		"pgoff %lx file %p private_data %p\n",
> +		vma, (void *)vma->vm_start, (void *)vma->vm_end, vma->vm_next,
> +		vma->vm_prev, vma->vm_mm, vma->vm_page_prot.pgprot,
> +		vma->anon_vma, vma->vm_ops, vma->vm_pgoff,
> +		vma->vm_file, vma->vm_private_data);
> +	dump_flags(vma->vm_flags, vmaflags_names, ARRAY_SIZE(vmaflags_names));
> +}
> +EXPORT_SYMBOL(dump_vma);
> -- 
> 1.7.10.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
