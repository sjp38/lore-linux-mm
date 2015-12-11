Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 7FF9B6B0254
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 17:28:16 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so71806010pac.3
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 14:28:16 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d5si3758219pas.82.2015.12.11.14.28.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Dec 2015 14:28:15 -0800 (PST)
Date: Fri, 11 Dec 2015 14:28:14 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/6] mm: Add a vm_special_mapping .fault method
Message-Id: <20151211142814.25cc806e3f5180d525ee807e@linux-foundation.org>
In-Reply-To: <4e911d2752d3b9e52d7496e46b389fc630cdc3a8.1449803537.git.luto@kernel.org>
References: <cover.1449803537.git.luto@kernel.org>
	<4e911d2752d3b9e52d7496e46b389fc630cdc3a8.1449803537.git.luto@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andy Lutomirski <luto@amacapital.net>

On Thu, 10 Dec 2015 19:21:42 -0800 Andy Lutomirski <luto@kernel.org> wrote:

> From: Andy Lutomirski <luto@amacapital.net>
> 
> Requiring special mappings to give a list of struct pages is
> inflexible: it prevents sane use of IO memory in a special mapping,
> it's inefficient (it requires arch code to initialize a list of
> struct pages, and it requires the mm core to walk the entire list
> just to figure out how long it is), and it prevents arch code from
> doing anything fancy when a special mapping fault occurs.
> 
> Add a .fault method as an alternative to filling in a .pages array.
> 
> ...
>
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -568,10 +568,27 @@ static inline void clear_tlb_flush_pending(struct mm_struct *mm)
>  }
>  #endif
>  
> +struct vm_fault;
> +
>  struct vm_special_mapping
>  {

We may as well fix the code layout while we're in there.

> -	const char *name;
> +	const char *name;	/* The name, e.g. "[vdso]". */
> +
> +	/*
> +	 * If .fault is not provided, this is points to a

s/is//

> +	 * NULL-terminated array of pages that back the special mapping.
> +	 *
> +	 * This must not be NULL unless .fault is provided.
> +	 */
>  	struct page **pages;
> +
> +	/*
> +	 * If non-NULL, then this is called to resolve page faults
> +	 * on the special mapping.  If used, .pages is not checked.
> +	 */
> +	int (*fault)(const struct vm_special_mapping *sm,
> +		     struct vm_area_struct *vma,
> +		     struct vm_fault *vmf);
>  };
>  
>  enum tlb_flush_reason {
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 2ce04a649f6b..f717453b1a57 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -3030,11 +3030,16 @@ static int special_mapping_fault(struct vm_area_struct *vma,
>  	pgoff_t pgoff;
>  	struct page **pages;
>  
> -	if (vma->vm_ops == &legacy_special_mapping_vmops)
> +	if (vma->vm_ops == &legacy_special_mapping_vmops) {
>  		pages = vma->vm_private_data;
> -	else
> -		pages = ((struct vm_special_mapping *)vma->vm_private_data)->
> -			pages;
> +	} else {
> +		struct vm_special_mapping *sm = vma->vm_private_data;
> +
> +		if (sm->fault)
> +			return sm->fault(sm, vma, vmf);
> +
> +		pages = sm->pages;
> +	}
>  
>  	for (pgoff = vmf->pgoff; pgoff && *pages; ++pages)
>  		pgoff--;

Otherwise looks OK.  I'll assume this will be merged via an x86 tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
