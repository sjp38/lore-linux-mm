Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id F0F046B0033
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 03:00:40 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e26so23170266pfd.4
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 00:00:40 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id b75si554042pfk.343.2017.10.06.00.00.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Oct 2017 00:00:39 -0700 (PDT)
Date: Fri, 6 Oct 2017 00:00:38 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v5 4/5] cramfs: add mmap support
Message-ID: <20171006070038.GA29142@infradead.org>
References: <20171006024531.8885-1-nicolas.pitre@linaro.org>
 <20171006024531.8885-5-nicolas.pitre@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171006024531.8885-5-nicolas.pitre@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-embedded@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Brandt <Chris.Brandt@renesas.com>

> +	/* Don't map the last page if it contains some other data */
> +	if (unlikely(pgoff + pages == max_pages)) {
> +		unsigned int partial = offset_in_page(inode->i_size);
> +		if (partial) {
> +			char *data = sbi->linear_virt_addr + offset;
> +			data += (max_pages - 1) * PAGE_SIZE + partial;
> +			if (memchr_inv(data, 0, PAGE_SIZE - partial) != NULL) {
> +				pr_debug("mmap: %s: last page is shared\n",
> +					 file_dentry(file)->d_name.name);
> +				pages--;
> +			}
> +		}
> +	}

Why is pgoff + pages == max_pages marked unlikely?  Mapping the whole
file seems like a perfectly normal and likely case to me..

Also if this was my code I'd really prefer to move this into a helper:

static bool cramfs_mmap_last_page_is_shared(struct inode *inode, int offset)
{
	unsigned int partial = offset_in_page(inode->i_size);
	char *data = CRAMFS_SB(inode->i_sb)->linear_virt_addr + offset +
			(inode->i_size & PAGE_MASK);

	return memchr_inv(data + partial, 0, PAGE_SIZE - partial);
}

	if (pgoff + pages == max_pages && offset_in_page(inode->i_size)	&&
	    cramfs_mmap_last_page_is_shared(inode, offset))
		pages--;

as that's much more readable and the function name provides a good
documentation of what is going on.

> +	if (pages != vma_pages(vma)) {

here is how I would turn this around:

	if (!pages)
		goto done;

	if (pages == vma_pages(vma)) {
		remap_pfn_range();
		goto done;
	}

	...
	for (i = 0; i < pages; i++) {
		...
		vm_insert_mixed();
		nr_mapped++;
	}


done:
	pr_debug("mapped %d out ouf %d\n", ..);
	if (pages != vma_pages(vma))
		vma->vm_ops = &generic_file_vm_ops;
	return 0;
}

In fact we probably could just set the vm_ops unconditionally, they
just wouldn't be called, but that might be more confusing then helpful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
