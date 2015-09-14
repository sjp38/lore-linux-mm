Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id E28146B025B
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 09:22:30 -0400 (EDT)
Received: by obbzf10 with SMTP id zf10so52448517obb.2
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 06:22:30 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q126si1889685oia.45.2015.09.14.06.22.29
        for <linux-mm@kvack.org>;
        Mon, 14 Sep 2015 06:22:30 -0700 (PDT)
Date: Mon, 14 Sep 2015 14:22:30 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: LTP regressions due to 6dc296e7df4c ("mm: make sure all file
 VMAs have ->vm_ops set")
Message-ID: <20150914132230.GD23878@arm.com>
References: <20150914105346.GB23878@arm.com>
 <20150914115800.06242CE@black.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150914115800.06242CE@black.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: "oleg@redhat.com" <oleg@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "luto@amacapital.net" <luto@amacapital.net>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "mingo@elte.hu" <mingo@elte.hu>, "minchan@kernel.org" <minchan@kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Sep 14, 2015 at 12:57:59PM +0100, Kirill A. Shutemov wrote:
> Will Deacon wrote:
> > Your patch 6dc296e7df4c ("mm: make sure all file VMAs have ->vm_ops set")
> > causes some mmap regressions in LTP, which appears to use a MAP_PRIVATE
> > mmap of /dev/zero as a way to get anonymous pages in some of its tests
> > (specifically mmap10 [1]).
> > 
> > Dead simple reproducer below. Is this change in behaviour intentional?
> 
> Ouch. Of couse it's a bug.
> 
> Fix is below. I don't really like it, but I cannot find any better
> solution.

Brill, thanks for the quick response! I agree that the fix isn't very
nice. Maybe moving the mmap_zero test into a helper would make it more
palatable?

> From 97be4458fd63758b0c233e528bf952d1cd26428e Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Mon, 14 Sep 2015 14:44:32 +0300
> Subject: [PATCH] mm: fix mmap(MAP_PRIVATE) on /dev/zero
> 
> In attempt to make mm less fragile I've screwed up setting up anonymous
> mappings by mmap() on /dev/zero.
> 
> Here's the fix.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Fixes: 6dc296e7df4c ("mm: make sure all file VMAs have ->vm_ops set")
> Reported-by: Will Deacon <will.deacon@arm.com>

FWIW:

  Tested-by: Will Deacon <will.deacon@arm.com>

Cheers,

Will

> ---
>  drivers/char/mem.c | 2 +-
>  include/linux/mm.h | 1 +
>  mm/mmap.c          | 6 ++++--
>  3 files changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/char/mem.c b/drivers/char/mem.c
> index 6b1721f978c2..c8fe3af4de29 100644
> --- a/drivers/char/mem.c
> +++ b/drivers/char/mem.c
> @@ -651,7 +651,7 @@ static ssize_t read_iter_zero(struct kiocb *iocb, struct iov_iter *iter)
>  	return written;
>  }
>  
> -static int mmap_zero(struct file *file, struct vm_area_struct *vma)
> +int mmap_zero(struct file *file, struct vm_area_struct *vma)
>  {
>  #ifndef CONFIG_MMU
>  	return -ENOSYS;
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 91c08f6f0dc9..5e152e9588ec 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1066,6 +1066,7 @@ extern void pagefault_out_of_memory(void);
>  extern void show_free_areas(unsigned int flags);
>  extern bool skip_free_areas_node(unsigned int flags, int nid);
>  
> +int mmap_zero(struct file *file, struct vm_area_struct *vma);
>  int shmem_zero_setup(struct vm_area_struct *);
>  #ifdef CONFIG_SHMEM
>  bool shmem_mapping(struct address_space *mapping);
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 971dd2cb77d2..7960fd206a2f 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -612,7 +612,9 @@ static unsigned long count_vma_pages_range(struct mm_struct *mm,
>  void __vma_link_rb(struct mm_struct *mm, struct vm_area_struct *vma,
>  		struct rb_node **rb_link, struct rb_node *rb_parent)
>  {
> -	WARN_ONCE(vma->vm_file && !vma->vm_ops, "missing vma->vm_ops");
> +	WARN_ONCE(vma->vm_file && !vma->vm_ops &&
> +			vma->vm_file->f_op->mmap != mmap_zero,
> +			"missing vma->vm_ops");
>  
>  	/* Update tracking information for the gap following the new vma. */
>  	if (vma->vm_next)
> @@ -1639,7 +1641,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
>  		WARN_ON_ONCE(addr != vma->vm_start);
>  
>  		/* All file mapping must have ->vm_ops set */
> -		if (!vma->vm_ops) {
> +		if (!vma->vm_ops && file->f_op->mmap != &mmap_zero) {
>  			static const struct vm_operations_struct dummy_ops = {};
>  			vma->vm_ops = &dummy_ops;
>  		}
> -- 
> 2.5.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
