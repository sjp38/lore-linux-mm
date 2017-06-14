Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id BA5BF6B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 12:54:21 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id n18so1710356wra.11
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 09:54:21 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z79si542604wmz.9.2017.06.14.09.54.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Jun 2017 09:54:20 -0700 (PDT)
Subject: Re: [PATCH v2 1/2] mm: improve readability of
 transparent_hugepage_enabled()
References: <149739530052.20686.9000645746376519779.stgit@dwillia2-desk3.amr.corp.intel.com>
 <149739530612.20686.14760671150202647861.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <e944ba00-3139-8da0-a1f9-642be9300c7c@suse.cz>
Date: Wed, 14 Jun 2017 18:53:40 +0200
MIME-Version: 1.0
In-Reply-To: <149739530612.20686.14760671150202647861.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: Jan Kara <jack@suse.cz>, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, hch@lst.de, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 06/14/2017 01:08 AM, Dan Williams wrote:
> Turn the macro into a static inline and rewrite the condition checks for
> better readability in preparation for adding another condition.
> 
> Cc: Jan Kara <jack@suse.cz>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> [ross: fix logic to make conversion equivalent]
> Acked-by: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Reviewed-by: Vlastimil Babka <vbabka@suse.cz>

vbabka@gusiac:~/wrk/cbmc> cbmc test-thp.c
CBMC version 5.3 64-bit x86_64 linux
Parsing test-thp.c
file <command-line> line 0: <command-line>:0:0: warning:
"__STDC_VERSION__" redefined
file <command-line> line 0: <built-in>: note: this is the location of
the previous definition
Converting
Type-checking test-thp
file test-thp.c line 75 function main: function `assert' is not declared
Generating GOTO Program
Adding CPROVER library
Function Pointer Removal
Partial Inlining
Generic Property Instrumentation
Starting Bounded Model Checking
size of program expression: 171 steps
simple slicing removed 3 assignments
Generated 1 VCC(s), 1 remaining after simplification
Passing problem to propositional reduction
converting SSA
Running propositional reduction
Post-processing
Solving with MiniSAT 2.2.0 with simplifier
4899 variables, 13228 clauses
SAT checker: negated claim is UNSATISFIABLE, i.e., holds
Runtime decision procedure: 0.008s
VERIFICATION SUCCESSFUL

(and yeah, the v1 version fails :)

> ---
>  include/linux/huge_mm.h |   32 +++++++++++++++++++++-----------
>  1 file changed, 21 insertions(+), 11 deletions(-)
> 
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index a3762d49ba39..c8119e856eb1 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -85,14 +85,23 @@ extern struct kobj_attribute shmem_enabled_attr;
>  
>  extern bool is_vma_temporary_stack(struct vm_area_struct *vma);
>  
> -#define transparent_hugepage_enabled(__vma)				\
> -	((transparent_hugepage_flags &					\
> -	  (1<<TRANSPARENT_HUGEPAGE_FLAG) ||				\
> -	  (transparent_hugepage_flags &					\
> -	   (1<<TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG) &&			\
> -	   ((__vma)->vm_flags & VM_HUGEPAGE))) &&			\
> -	 !((__vma)->vm_flags & VM_NOHUGEPAGE) &&			\
> -	 !is_vma_temporary_stack(__vma))
> +extern unsigned long transparent_hugepage_flags;
> +
> +static inline bool transparent_hugepage_enabled(struct vm_area_struct *vma)
> +{
> +	if ((vma->vm_flags & VM_NOHUGEPAGE) || is_vma_temporary_stack(vma))
> +		return false;
> +
> +	if (transparent_hugepage_flags & (1 << TRANSPARENT_HUGEPAGE_FLAG))
> +		return true;
> +
> +	if (transparent_hugepage_flags &
> +				(1 << TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG))
> +		return !!(vma->vm_flags & VM_HUGEPAGE);
> +
> +	return false;
> +}
> +
>  #define transparent_hugepage_use_zero_page()				\
>  	(transparent_hugepage_flags &					\
>  	 (1<<TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG))
> @@ -104,8 +113,6 @@ extern bool is_vma_temporary_stack(struct vm_area_struct *vma);
>  #define transparent_hugepage_debug_cow() 0
>  #endif /* CONFIG_DEBUG_VM */
>  
> -extern unsigned long transparent_hugepage_flags;
> -
>  extern unsigned long thp_get_unmapped_area(struct file *filp,
>  		unsigned long addr, unsigned long len, unsigned long pgoff,
>  		unsigned long flags);
> @@ -223,7 +230,10 @@ void mm_put_huge_zero_page(struct mm_struct *mm);
>  
>  #define hpage_nr_pages(x) 1
>  
> -#define transparent_hugepage_enabled(__vma) 0
> +static inline bool transparent_hugepage_enabled(struct vm_area_struct *vma)
> +{
> +	return false;
> +}
>  
>  static inline void prep_transhuge_page(struct page *page) {}
>  
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
