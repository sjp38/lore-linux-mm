Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id 355826B004D
	for <linux-mm@kvack.org>; Fri, 14 Mar 2014 19:32:42 -0400 (EDT)
Received: by mail-ee0-f45.google.com with SMTP id d17so1910953eek.18
        for <linux-mm@kvack.org>; Fri, 14 Mar 2014 16:32:41 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out.inet.fi. [195.156.147.13])
        by mx.google.com with ESMTP id 43si5457221eei.115.2014.03.14.16.32.40
        for <linux-mm@kvack.org>;
        Fri, 14 Mar 2014 16:32:40 -0700 (PDT)
Date: Sat, 15 Mar 2014 01:32:33 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC PATCH] Support map_pages() for DAX
Message-ID: <20140314233233.GA8310@node.dhcp.inet.fi>
References: <1394838199-29102-1-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1394838199-29102-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: willy@linux.intel.com, kirill.shutemov@linux.intel.com, david@fromorbit.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Mar 14, 2014 at 05:03:19PM -0600, Toshi Kani wrote:
> +void dax_map_pages(struct vm_area_struct *vma, struct vm_fault *vmf,
> +		get_block_t get_block)
> +{
> +	struct file *file = vma->vm_file;
> +	struct inode *inode = file_inode(file);
> +	struct buffer_head bh;
> +	struct address_space *mapping = file->f_mapping;
> +	unsigned long vaddr = (unsigned long)vmf->virtual_address;
> +	pgoff_t pgoff = vmf->pgoff;
> +	sector_t block;
> +	pgoff_t size;
> +	unsigned long pfn;
> +	pte_t *pte = vmf->pte;
> +	int error;
> +
> +	while (pgoff < vmf->max_pgoff) {
> +		size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
> +		if (pgoff >= size)
> +			return;
> +
> +		memset(&bh, 0, sizeof(bh));
> +		block = (sector_t)pgoff << (PAGE_SHIFT - inode->i_blkbits);
> +		bh.b_size = PAGE_SIZE;
> +		error = get_block(inode, block, &bh, 0);
> +		if (error || bh.b_size < PAGE_SIZE)
> +			goto next;
> +
> +		if (!buffer_mapped(&bh) || buffer_unwritten(&bh) ||
> +		    buffer_new(&bh))
> +			goto next;
> +
> +		/* Recheck i_size under i_mmap_mutex */
> +		mutex_lock(&mapping->i_mmap_mutex);

NAK. Have you tested this with lockdep enabled?

->map_pages() called with page table lock taken and ->i_mmap_mutex
should be taken before it. It seems we need to take ->i_mmap_mutex in
do_read_fault() before calling ->map_pages().

Side note: I'm sceptical about whole idea to use i_mmap_mutux to protect
against truncate. It will not scale good enough comparing lock_page()
with its granularity.

> +		size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
> +		if (unlikely(pgoff >= size)) {
> +			mutex_unlock(&mapping->i_mmap_mutex);
> +			return;
> +		}
> +
> +		error = dax_get_pfn(inode, &bh, &pfn);
> +		if (error > 0)
> +			dax_set_pte(vma, vaddr, pfn, pte);
> +
> +		mutex_unlock(&mapping->i_mmap_mutex);
> +next:
> +		vaddr += PAGE_SIZE;
> +		pgoff++;
> +		pte++;
> +	}
> +}
> +EXPORT_SYMBOL_GPL(dax_map_pages);

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
