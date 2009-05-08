Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2F76F6B0089
	for <linux-mm@kvack.org>; Fri,  8 May 2009 16:11:47 -0400 (EDT)
Date: Fri, 8 May 2009 13:06:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] videobuf-dma-contig: zero copy USERPTR support V3
Message-Id: <20090508130658.813e29c1.akpm@linux-foundation.org>
In-Reply-To: <20090508085310.31326.38083.sendpatchset@rx1.opensource.se>
References: <20090508085310.31326.38083.sendpatchset@rx1.opensource.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Magnus Damm <magnus.damm@gmail.com>
Cc: linux-media@vger.kernel.org, mchehab@infradead.org, hverkuil@xs4all.nl, linux-mm@kvack.org, lethal@linux-sh.org, hannes@cmpxchg.org
List-ID: <linux-mm.kvack.org>

On Fri, 08 May 2009 17:53:10 +0900
Magnus Damm <magnus.damm@gmail.com> wrote:

> From: Magnus Damm <damm@igel.co.jp>
> 
> This is V3 of the V4L2 videobuf-dma-contig USERPTR zero copy patch.
> 
> Since videobuf-dma-contig is designed to handle physically contiguous
> memory, this patch modifies the videobuf-dma-contig code to only accept
> a user space pointer to physically contiguous memory. For now only
> VM_PFNMAP vmas are supported, so forget hotplug.
> 
> On SuperH Mobile we use this with our sh_mobile_ceu_camera driver
> together with various multimedia accelerator blocks that are exported to
> user space using UIO. The UIO kernel code exports physically contiguous
> memory to user space and lets the user space application mmap() this memory
> and pass a pointer using the USERPTR interface for V4L2 zero copy operation.
> 
> With this approach we support zero copy capture, hardware scaling and
> various forms of hardware encoding and decoding.
> 
> Signed-off-by: Magnus Damm <damm@igel.co.jp>
> ---
> 
>  Needs the following patches (Thanks to Johannes Weiner and akpm):
>  - mm-introduce-follow_pte.patch
>  - mm-use-generic-follow_pte-in-follow_phys.patch
>  - mm-introduce-follow_pfn.patch

I'l plan to merge this and the above three into 2.6.31-rc1 unless it
all gets shot down.

> +static int videobuf_dma_contig_user_get(struct videobuf_dma_contig_memory *mem,
> +					struct videobuf_buffer *vb)
> +{
> +	struct mm_struct *mm = current->mm;
> +	struct vm_area_struct *vma;
> +	unsigned long prev_pfn, this_pfn;
> +	unsigned long pages_done, user_address;
> +	int ret;
> +
> +	mem->size = PAGE_ALIGN(vb->size);
> +	mem->is_userptr = 0;
> +	ret = -EINVAL;
> +
> +	down_read(&mm->mmap_sem);
> +
> +	vma = find_vma(mm, vb->baddr);
> +	if (!vma)
> +		goto out_up;
> +
> +	if ((vb->baddr + mem->size) > vma->vm_end)
> +		goto out_up;
> +
> +	pages_done = 0;
> +	prev_pfn = 0; /* kill warning */
> +	user_address = vb->baddr;
> +
> +	while (pages_done < (mem->size >> PAGE_SHIFT)) {
> +		ret = follow_pfn(vma, user_address, &this_pfn);
> +		if (ret)
> +			break;
> +
> +		if (pages_done == 0)
> +			mem->dma_handle = this_pfn << PAGE_SHIFT;
> +		else if (this_pfn != (prev_pfn + 1))
> +			ret = -EFAULT;
> +
> +		if (ret)
> +			break;
> +
> +		prev_pfn = this_pfn;
> +		user_address += PAGE_SIZE;
> +		pages_done++;
> +	}
> +
> +	if (!ret)
> +		mem->is_userptr = 1;
> +
> + out_up:
> +	up_read(&current->mm->mmap_sem);
> +
> +	return ret;
> +}

If this function really so obvious and trivial that it is best to merge
it without any documentation at all?  Has it been made as easy for
others to maintain as we can possibly make it?

What does it do, how does it do it and why does it do it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
