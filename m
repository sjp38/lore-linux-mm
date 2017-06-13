Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 184DF6B0279
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 17:06:33 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id w184so37841742ith.2
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 14:06:33 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id n66si11556674ith.99.2017.06.13.14.06.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jun 2017 14:06:32 -0700 (PDT)
Date: Tue, 13 Jun 2017 15:06:30 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 1/2] mm: improve readability of
 transparent_hugepage_enabled()
Message-ID: <20170613210630.GA5135@linux.intel.com>
References: <149713136649.17377.3742583729924020371.stgit@dwillia2-desk3.amr.corp.intel.com>
 <149713137177.17377.6712234218256825718.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <149713137177.17377.6712234218256825718.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, hch@lst.de, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Sat, Jun 10, 2017 at 02:49:31PM -0700, Dan Williams wrote:
> Turn the macro into a static inline and rewrite the condition checks for
> better readability in preparation for adding another condition.
> 
> Cc: Jan Kara <jack@suse.cz>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  include/linux/huge_mm.h |   35 ++++++++++++++++++++++++-----------
>  1 file changed, 24 insertions(+), 11 deletions(-)
> 
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index a3762d49ba39..c4706e2c3358 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -85,14 +85,26 @@ extern struct kobj_attribute shmem_enabled_attr;
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
> +	if (transparent_hugepage_flags & (1 << TRANSPARENT_HUGEPAGE_FLAG))
> +		return true;
> +
> +	if (transparent_hugepage_flags
> +			& (1 << TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG))
> +		/* check vma flags */;
> +	else
> +		return false;
> +
> +	if ((vma->vm_flags & (VM_HUGEPAGE | VM_NOHUGEPAGE)) == VM_HUGEPAGE
> +			&& !is_vma_temporary_stack(vma))
> +		return true;
> +
> +	return false;
> +}

I don't think that these are equivalent.  Here is the logic from the macro,
with whitespace added so things are more readable:

#define transparent_hugepage_enabled(__vma)
(
	(
	  transparent_hugepage_flags & (1<<TRANSPARENT_HUGEPAGE_FLAG)

	  ||

	  (
	    transparent_hugepage_flags & (1<<TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG)

	    &&

	    ((__vma)->vm_flags & VM_HUGEPAGE)
	  )
	)
	 
	 &&

	 !((__vma)->vm_flags & VM_NOHUGEPAGE)
	 
	 &&

	 !is_vma_temporary_stack(__vma)
)

So, if the VM_NOHUGEPAGE flag is set or if the vma is for a temporary stack,
we always bail.  Also, we only care about the VM_HUGEPAGE flag in the presence
of TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG.

I think this static inline is logically equivalent (untested):

static inline bool transparent_hugepage_enabled(struct vm_area_struct *vma)
{
	if ((vma->vm_flags & VM_NOHUGEPAGE) || is_vma_temporary_stack(vma))
		return false;

	if (transparent_hugepage_flags & (1 << TRANSPARENT_HUGEPAGE_FLAG))
		return true;

	if ((transparent_hugepage_flags &
				(1 << TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG))
			&& vma->vm_flags & VM_HUGEPAGE)
		return true;

	return false;
}

The ordering of the checks is different, but we're not using && or || to
short-circuit checks with side effects, so I think it is more readable and
should be fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
