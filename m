Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id F23536B0038
	for <linux-mm@kvack.org>; Wed,  8 Oct 2014 02:52:32 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id fp1so6375124pdb.35
        for <linux-mm@kvack.org>; Tue, 07 Oct 2014 23:52:32 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id hg4si1559697pbc.83.2014.10.07.23.52.30
        for <linux-mm@kvack.org>
        (version=TLSv1.1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 07 Oct 2014 23:52:31 -0700 (PDT)
Message-ID: <5434DEBD.8040607@synopsys.com>
Date: Wed, 8 Oct 2014 12:20:37 +0530
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/8] mm: replace remap_file_pages() syscall with emulation
References: <1399387052-31660-1-git-send-email-kirill.shutemov@linux.intel.com> <1399387052-31660-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1399387052-31660-2-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, peterz@infradead.org, mingo@kernel.org

Hi Kirill,

Due to broken PAGE_FILE on arc, I was giving this emulation patch a try and it
seems we need a minor fix to this patch. I know this is not slated for merge soon,
but u can add the fix nevertheless and my Tested-by:

Problem showed up with Ingo Korb's remap-demo.c test case from [1]

[1] https://lkml.org/lkml/2014/7/14/335

On Tuesday 06 May 2014 08:07 PM, Kirill A. Shutemov wrote:
> remap_file_pages(2) was invented to be able efficiently map parts of
> huge file into limited 32-bit virtual address space such as in database
> workloads.
> 
> Nonlinear mappings are pain to support and it seems there's no
> legitimate use-cases nowadays since 64-bit systems are widely available.
> 
> Let's drop it and get rid of all these special-cased code.
> 
> The patch replaces the syscall with emulation which creates new VMA on
> each remap.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---

....
> -}
> diff --git a/mm/mmap.c b/mm/mmap.c
> index b1202cf81f4b..4106fc833f56 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2579,6 +2579,74 @@ SYSCALL_DEFINE2(munmap, unsigned long, addr, size_t, len)
>  	return vm_munmap(addr, len);
>  }
>  
> +
> +/*
> + * Emulation of deprecated remap_file_pages() syscall.
> + */
> +SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
> +		unsigned long, prot, unsigned long, pgoff, unsigned long, flags)
> +{
> +
> +	struct mm_struct *mm = current->mm;
> +	struct vm_area_struct *vma;
> +	unsigned long populate;
> +	int ret = -EINVAL;
> +
> +	printk_once(KERN_WARNING "%s (%d) calls remap_file_pages(2) which is "
> +			"deprecated and no longer supported by kernel in "
> +			"an efficient way.\n"
> +			"Note that emulated remap_file_pages(2) can "
> +			"potentially create a lot of mappings. "
> +			"Consider increasing vm.max_map_count.\n",
> +			current->comm, current->pid);
> +
> +	if (prot)
> +		return ret;
> +	start = start & PAGE_MASK;
> +	size = size & PAGE_MASK;
> +
> +	if (start + size <= start)
> +		return ret;
> +
> +	/* Does pgoff wrap? */
> +	if (pgoff + (size >> PAGE_SHIFT) < pgoff)
> +		return ret;
> +
> +	down_write(&mm->mmap_sem);
> +	vma = find_vma(mm, start);
> +
> +	if (!vma || !(vma->vm_flags & VM_SHARED))
> +		goto out;
> +
> +	if (start < vma->vm_start || start + size > vma->vm_end)
> +		goto out;
> +
> +	if (pgoff == linear_page_index(vma, start)) {
> +		ret = 0;
> +		goto out;
> +	}
> +
> +	prot |= vma->vm_flags & VM_READ ? PROT_READ : 0;
> +	prot |= vma->vm_flags & VM_WRITE ? PROT_WRITE : 0;
> +	prot |= vma->vm_flags & VM_EXEC ? PROT_EXEC : 0;
> +
> +	flags &= MAP_POPULATE;
> +	flags |= MAP_SHARED | MAP_FIXED;
> +	if (vma->vm_flags & VM_LOCKED) {
> +		flags |= MAP_LOCKED;
> +		/* drop PG_Mlocked flag for over-mapped range */
> +		munlock_vma_pages_range(vma, start, start + size);
> +	}
> +
> +	ret = do_mmap_pgoff(vma->vm_file, start, size,
> +			prot, flags, pgoff, &populate);
> +	if (populate)
> +		mm_populate(ret, populate);
> +out:
> +	up_write(&mm->mmap_sem);

On success needs to return 0, not mapped addr.

	if (!IS_ERR_VALUE(ret))
		ret = 0;

> +	return ret;
> +}
> +

Thx,
-Vineet

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
