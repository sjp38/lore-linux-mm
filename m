Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id EE8206B0254
	for <linux-mm@kvack.org>; Tue,  1 Sep 2015 09:12:49 -0400 (EDT)
Received: by wicmc4 with SMTP id mc4so32655248wic.0
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 06:12:49 -0700 (PDT)
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com. [209.85.212.180])
        by mx.google.com with ESMTPS id bu5si3116408wib.62.2015.09.01.06.12.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Sep 2015 06:12:46 -0700 (PDT)
Received: by wicmc4 with SMTP id mc4so32653507wic.0
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 06:12:46 -0700 (PDT)
Message-ID: <55E5A44A.1050206@plexistor.com>
Date: Tue, 01 Sep 2015 16:12:42 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH] dax, pmem: add support for msync
References: <1441047584-14664-1-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1441047584-14664-1-git-send-email-ross.zwisler@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@osdl.org>, x86@kernel.org, linux-nvdimm@lists.01.org, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 08/31/2015 09:59 PM, Ross Zwisler wrote:
> For DAX msync we just need to flush the given range using
> wb_cache_pmem(), which is now a public part of the PMEM API.
> 
> The inclusion of <linux/dax.h> in fs/dax.c was done to make checkpatch
> happy.  Previously it was complaining about a bunch of undeclared
> functions that could be made static.
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> ---
> This patch is based on libnvdimm-for-next from our NVDIMM tree:
> 
> https://git.kernel.org/cgit/linux/kernel/git/nvdimm/nvdimm.git/
> 
> with some DAX patches on top.  The baseline tree can be found here:
> 
> https://github.com/01org/prd/tree/dax_msync
> ---
>  arch/x86/include/asm/pmem.h | 13 +++++++------
>  fs/dax.c                    | 17 +++++++++++++++++
>  include/linux/dax.h         |  1 +
>  include/linux/pmem.h        | 22 +++++++++++++++++++++-
>  mm/msync.c                  | 10 +++++++++-
>  5 files changed, 55 insertions(+), 8 deletions(-)
> 
> diff --git a/arch/x86/include/asm/pmem.h b/arch/x86/include/asm/pmem.h
> index d8ce3ec..85c07b2 100644
> --- a/arch/x86/include/asm/pmem.h
> +++ b/arch/x86/include/asm/pmem.h
> @@ -67,18 +67,19 @@ static inline void arch_wmb_pmem(void)
>  }
>  
>  /**
> - * __arch_wb_cache_pmem - write back a cache range with CLWB
> - * @vaddr:	virtual start address
> + * arch_wb_cache_pmem - write back a cache range with CLWB
> + * @addr:	virtual start address
>   * @size:	number of bytes to write back
>   *
>   * Write back a cache range using the CLWB (cache line write back)
>   * instruction.  This function requires explicit ordering with an
> - * arch_wmb_pmem() call.  This API is internal to the x86 PMEM implementation.
> + * arch_wmb_pmem() call.
>   */
> -static inline void __arch_wb_cache_pmem(void *vaddr, size_t size)
> +static inline void arch_wb_cache_pmem(void __pmem *addr, size_t size)
>  {
>  	u16 x86_clflush_size = boot_cpu_data.x86_clflush_size;
>  	unsigned long clflush_mask = x86_clflush_size - 1;
> +	void *vaddr = (void __force *)addr;
>  	void *vend = vaddr + size;
>  	void *p;
>  
> @@ -115,7 +116,7 @@ static inline size_t arch_copy_from_iter_pmem(void __pmem *addr, size_t bytes,
>  	len = copy_from_iter_nocache(vaddr, bytes, i);
>  
>  	if (__iter_needs_pmem_wb(i))
> -		__arch_wb_cache_pmem(vaddr, bytes);
> +		arch_wb_cache_pmem(addr, bytes);
>  
>  	return len;
>  }
> @@ -138,7 +139,7 @@ static inline void arch_clear_pmem(void __pmem *addr, size_t size)
>  	else
>  		memset(vaddr, 0, size);
>  
> -	__arch_wb_cache_pmem(vaddr, size);
> +	arch_wb_cache_pmem(addr, size);
>  }
>  
>  static inline bool __arch_has_wmb_pmem(void)
> diff --git a/fs/dax.c b/fs/dax.c
> index fbe18b8..ed6aec1 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -17,6 +17,7 @@
>  #include <linux/atomic.h>
>  #include <linux/blkdev.h>
>  #include <linux/buffer_head.h>
> +#include <linux/dax.h>
>  #include <linux/fs.h>
>  #include <linux/genhd.h>
>  #include <linux/highmem.h>
> @@ -25,6 +26,7 @@
>  #include <linux/mutex.h>
>  #include <linux/pmem.h>
>  #include <linux/sched.h>
> +#include <linux/sizes.h>
>  #include <linux/uio.h>
>  #include <linux/vmstat.h>
>  
> @@ -753,3 +755,18 @@ int dax_truncate_page(struct inode *inode, loff_t from, get_block_t get_block)
>  	return dax_zero_page_range(inode, from, length, get_block);
>  }
>  EXPORT_SYMBOL_GPL(dax_truncate_page);
> +
> +void dax_sync_range(unsigned long addr, size_t len)
> +{
> +	while (len) {
> +		size_t chunk_len = min_t(size_t, SZ_1G, len);
> +

Where does the  SZ_1G come from is it because you want to do cond_resched()
every 1G bytes so not to get stuck for a long time?

It took me a while to catch, At first I thought it might be do to wb_cache_pmem()
limitations. Would you put a comment in the next iteration?

> +		wb_cache_pmem((void __pmem *)addr, chunk_len);
> +		len -= chunk_len;
> +		addr += chunk_len;
> +		if (len)
> +			cond_resched();
> +	}
> +	wmb_pmem();
> +}
> +EXPORT_SYMBOL_GPL(dax_sync_range);
> diff --git a/include/linux/dax.h b/include/linux/dax.h
> index b415e52..504b33f 100644
> --- a/include/linux/dax.h
> +++ b/include/linux/dax.h
> @@ -14,6 +14,7 @@ int dax_fault(struct vm_area_struct *, struct vm_fault *, get_block_t,
>  		dax_iodone_t);
>  int __dax_fault(struct vm_area_struct *, struct vm_fault *, get_block_t,
>  		dax_iodone_t);
> +void dax_sync_range(unsigned long addr, size_t len);
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  int dax_pmd_fault(struct vm_area_struct *, unsigned long addr, pmd_t *,
>  				unsigned int flags, get_block_t, dax_iodone_t);
> diff --git a/include/linux/pmem.h b/include/linux/pmem.h
> index 85f810b3..aa29ebb 100644
> --- a/include/linux/pmem.h
> +++ b/include/linux/pmem.h
> @@ -53,12 +53,18 @@ static inline void arch_clear_pmem(void __pmem *addr, size_t size)
>  {
>  	BUG();

See below

>  }
> +
> +static inline void arch_wb_cache_pmem(void __pmem *addr, size_t size)
> +{
> +	BUG();

There is a clflush_cache_range() defined for generic use. On ADR systems (even without pcommit)
this works perfectly and is persistent. why not use that in the generic case?

Also all the above and below can be implements via this one.

One usage of pmem is overlooked by all this API. The use of DRAM as pmem, across a VM
or cross reboot. you have a piece of memory exposed as pmem to the subsytem which survives
past the boot of that system. The CPU cache still needs flushing in this case.
(People are already using this for logs and crash dumps)

So all arches including all x86 variants can have a working generic implementation
that will work, based on clflush_cache_range()

I'll work on this ASAP and send patches ...

> +}
>  #endif
>  
>  /*
>   * Architectures that define ARCH_HAS_PMEM_API must provide
>   * implementations for arch_memcpy_to_pmem(), arch_wmb_pmem(),
> - * arch_copy_from_iter_pmem(), arch_clear_pmem() and arch_has_wmb_pmem().
> + * arch_copy_from_iter_pmem(), arch_clear_pmem(), arch_wb_cache_pmem()
> + * and arch_has_wmb_pmem().
>   */
>  static inline void memcpy_from_pmem(void *dst, void __pmem const *src, size_t size)
>  {
> @@ -202,4 +208,18 @@ static inline void clear_pmem(void __pmem *addr, size_t size)
>  	else
>  		default_clear_pmem(addr, size);
>  }
> +
> +/**
> + * wb_cache_pmem - write back a range of cache lines
> + * @vaddr:	virtual start address
> + * @size:	number of bytes to write back
> + *
> + * Write back the cache lines starting at 'vaddr' for 'size' bytes.
> + * This function requires explicit ordering with an wmb_pmem() call.
> + */
> +static inline void wb_cache_pmem(void __pmem *addr, size_t size)
> +{
> +	if (arch_has_pmem_api())
> +		arch_wb_cache_pmem(addr, size);
> +}
>  #endif /* __PMEM_H__ */
> diff --git a/mm/msync.c b/mm/msync.c
> index bb04d53..2a4739c 100644
> --- a/mm/msync.c
> +++ b/mm/msync.c
> @@ -7,6 +7,7 @@
>  /*
>   * The msync() system call.
>   */
> +#include <linux/dax.h>
>  #include <linux/fs.h>
>  #include <linux/mm.h>
>  #include <linux/mman.h>
> @@ -59,6 +60,7 @@ SYSCALL_DEFINE3(msync, unsigned long, start, size_t, len, int, flags)
>  	for (;;) {
>  		struct file *file;
>  		loff_t fstart, fend;
> +		unsigned long range_len;
>  
>  		/* Still start < end. */
>  		error = -ENOMEM;
> @@ -77,10 +79,16 @@ SYSCALL_DEFINE3(msync, unsigned long, start, size_t, len, int, flags)
>  			error = -EBUSY;
>  			goto out_unlock;
>  		}
> +
> +		range_len = min(end, vma->vm_end) - start;
> +
> +		if (vma_is_dax(vma))
> +			dax_sync_range(start, range_len);
> +

Ye no I hate this. (No need to touch mm)

All we need to do is define a dax_fsync()

dax FS registers a special dax vector for ->fsync() that vector
needs to call dax_fsync(); first as part of its fsync operation.
Then dax_fsync() is:

dax_fsync()
{
	/* we always write with sync so only fsync if the file mmap'ed */
	if (mapping_mapped(inode->i_mapping) == 0)
		return 0;

	dax_sync_range(start, range_len);
}

Thanks
Boaz

>  		file = vma->vm_file;
>  		fstart = (start - vma->vm_start) +
>  			 ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
> -		fend = fstart + (min(end, vma->vm_end) - start) - 1;
> +		fend = fstart + range_len - 1;
>  		start = vma->vm_end;
>  		if ((flags & MS_SYNC) && file &&
>  				(vma->vm_flags & VM_SHARED)) {
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
