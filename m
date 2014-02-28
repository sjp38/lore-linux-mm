Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 341DD6B0071
	for <linux-mm@kvack.org>; Fri, 28 Feb 2014 12:56:32 -0500 (EST)
Received: by mail-ob0-f170.google.com with SMTP id uz6so4260863obc.1
        for <linux-mm@kvack.org>; Fri, 28 Feb 2014 09:56:32 -0800 (PST)
Received: from g5t1625.atlanta.hp.com (g5t1625.atlanta.hp.com. [15.192.137.8])
        by mx.google.com with ESMTPS id ws6si4172063oeb.6.2014.02.28.09.56.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 28 Feb 2014 09:56:31 -0800 (PST)
Message-ID: <1393609771.6784.83.camel@misato.fc.hp.com>
Subject: Re: [PATCH v6 07/22] Replace the XIP page fault handler with the
 DAX page fault handler
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 28 Feb 2014 10:49:31 -0700
In-Reply-To: <1393337918-28265-8-git-send-email-matthew.r.wilcox@intel.com>
References: <1393337918-28265-1-git-send-email-matthew.r.wilcox@intel.com>
	 <1393337918-28265-8-git-send-email-matthew.r.wilcox@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, willy@linux.intel.com

On Tue, 2014-02-25 at 09:18 -0500, Matthew Wilcox wrote:
> Instead of calling aops->get_xip_mem from the fault handler, the
> filesystem passes a get_block_t that is used to find the appropriate
> blocks.
 :
> +static int do_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
> +			get_block_t get_block)
> +{
> +	struct file *file = vma->vm_file;
> +	struct inode *inode = file_inode(file);
> +	struct address_space *mapping = file->f_mapping;
> +	struct buffer_head bh;
> +	unsigned long vaddr = (unsigned long)vmf->virtual_address;
> +	sector_t block;
> +	pgoff_t size;
> +	unsigned long pfn;
> +	int error;
> +
> +	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
> +	if (vmf->pgoff >= size)
> +		return VM_FAULT_SIGBUS;
> +
> +	memset(&bh, 0, sizeof(bh));
> +	block = (sector_t)vmf->pgoff << (PAGE_SHIFT - inode->i_blkbits);
> +	bh.b_size = PAGE_SIZE;
> +	error = get_block(inode, block, &bh, 0);
> +	if (error || bh.b_size < PAGE_SIZE)
> +		return VM_FAULT_SIGBUS;

I am learning the code and have some questions.  The original code,
xip_file_fault(), jumps to found: and calls vm_insert_mixed() when
get_xip_mem(,,0,,) succeeded.  If get_xip_mem() returns -ENODATA, it
calls either get_xip_mem(,,1,,) or xip_sparse_page().  In this new
function, it looks to me that get_block(,,,0) returns 0 for both cases
(success and -ENODATA previously), which are dealt in the same way.  Is
that right?  If so, is there any reason for the change?  Also, isn't it
possible to call get_block(,,,1) even if get_block(,,,0) found a block?

Thanks,
-Toshi

> +
> +	if (!buffer_written(&bh) && !vmf->cow_page) {
> +		if (vmf->flags & FAULT_FLAG_WRITE) {
> +			error = get_block(inode, block, &bh, 1);
> +			if (error || bh.b_size < PAGE_SIZE)
> +				return VM_FAULT_SIGBUS;
> +		} else {
> +			return dax_load_hole(mapping, vmf);
> +		}
> +	}
> +


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
