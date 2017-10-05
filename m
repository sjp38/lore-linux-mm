Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E01D56B0033
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 03:15:49 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e26so17650866pfd.4
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 00:15:49 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id i87si12870218pfi.397.2017.10.05.00.15.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Oct 2017 00:15:47 -0700 (PDT)
Date: Thu, 5 Oct 2017 00:15:45 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v4 4/5] cramfs: add mmap support
Message-ID: <20171005071545.GA23364@infradead.org>
References: <20171001083052.GB17116@infradead.org>
 <nycvar.YSQ.7.76.1710011805070.5407@knanqh.ubzr>
 <CAFLxGvzfQrvU-8w7F26mez6fCQD+iS_qRJpLSU+2DniEGouEfA@mail.gmail.com>
 <nycvar.YSQ.7.76.1710021931270.5407@knanqh.ubzr>
 <20171003145732.GA8890@infradead.org>
 <nycvar.YSQ.7.76.1710031107290.5407@knanqh.ubzr>
 <20171003153659.GA31600@infradead.org>
 <nycvar.YSQ.7.76.1710031137580.5407@knanqh.ubzr>
 <20171004072553.GA24620@infradead.org>
 <nycvar.YSQ.7.76.1710041608460.1693@knanqh.ubzr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <nycvar.YSQ.7.76.1710041608460.1693@knanqh.ubzr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Cc: Christoph Hellwig <hch@infradead.org>, Richard Weinberger <richard.weinberger@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-embedded@vger.kernel.org" <linux-embedded@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Chris Brandt <Chris.Brandt@renesas.com>

On Wed, Oct 04, 2017 at 04:47:52PM -0400, Nicolas Pitre wrote:
> The only downside so far is the lack of visibility from user space to 
> confirm it actually works as intended. With the vma splitting approach 
> you clearly see what gets directly mapped in /proc/*/maps thanks to 
> remap_pfn_range() storing the actual physical address in vma->vm_pgoff. 
> With VM_MIXEDMAP things are no longer visible. Any opinion for the best 
> way to overcome this?

Add trace points that allow you to trace it using trace-cmd, perf
or just tracefs?

> 
> Anyway, here's a replacement for patch 4/5 below:

This looks much better, and is about 100 lines less than the previous
version.  More (mostly cosmetic) comments below:

> +	blockptrs = (u32 *)(sbi->linear_virt_addr + OFFSET(inode) + pgoff*4);

missing psaces around the *

>
> +	blockaddr = blockptrs[0] & ~CRAMFS_BLK_FLAGS;
> +	i = 0;
> +	do {
> +		u32 expect = blockaddr + i * (PAGE_SIZE >> 2);

There are a lot of magic numbers in here.  It seems like that's standard
for cramfs, but if you really plan to bring it back to live it would be
create to sort that out..



> +		expect |= CRAMFS_BLK_FLAG_DIRECT_PTR|CRAMFS_BLK_FLAG_UNCOMPRESSED;

Too long line.

Just turn this into:

		 u32 expect = blockaddr + i * (PAGE_SIZE >> 2) |
		 		CRAMFS_BLK_FLAG_DIRECT_PTR |
				CRAMFS_BLK_FLAG_UNCOMPRESSED;

and it will be a lot more readable.

> +static int cramfs_physmem_mmap(struct file *file, struct vm_area_struct *vma)
> +{
> +	struct inode *inode = file_inode(file);
> +	struct super_block *sb = inode->i_sb;
> +	struct cramfs_sb_info *sbi = CRAMFS_SB(sb);
> +	unsigned int pages, vma_pages, max_pages, offset;
> +	unsigned long address;
> +	char *fail_reason;
> +	int ret;
> +
> +	if (!IS_ENABLED(CONFIG_MMU))
> +		return vma->vm_flags & (VM_SHARED | VM_MAYSHARE) ? 0 : -ENOSYS;

Given that you have a separate #ifndef CONFIG_MMU section below just
have a separate implementation of cramfs_physmem_mmap for it, which
makes the code a lot more obvious.

> +	/* Could COW work here? */
> +	fail_reason = "vma is writable";
> +	if (vma->vm_flags & VM_WRITE)
> +		goto fail;

The fail_reaosn is a rather unusable style, is there any good reason
why you need it here?  We generall don't add a debug printk for every
pssible failure case.

> +	vma_pages = (vma->vm_end - vma->vm_start + PAGE_SIZE - 1) >> PAGE_SHIFT;

Just use vma_pages - the defintion is different, but given that vm_end
and vm_stat must be page aligned anyway it should not make a difference.

> +	if (pages > max_pages - vma->vm_pgoff)
> +		pages = max_pages - vma->vm_pgoff;

Use min() or min_t().

> +	/* Don't map the last page if it contains some other data */
> +	if (unlikely(vma->vm_pgoff + pages == max_pages)) {
> +		unsigned int partial = offset_in_page(inode->i_size);
> +		if (partial) {
> +			char *data = sbi->linear_virt_addr + offset;
> +			data += (max_pages - 1) * PAGE_SIZE + partial;
> +			while ((unsigned long)data & 7)
> +				if (*data++ != 0)
> +					goto nonzero;
> +			while (offset_in_page(data)) {
> +				if (*(u64 *)data != 0) {
> +					nonzero:
> +					pr_debug("mmap: %s: last page is shared\n",
> +						 file_dentry(file)->d_name.name);
> +					pages--;
> +					break;
> +				}
> +				data += 8;
> +			}

The nonzer label is in a rather unusual space, both having weird
indentation and being in the middle of the loop.

It seems like this whole partial section should just go into a little
helper where the nonzero case is at the end of said helper to make it
readable.  Also lots of magic numbers again, and generally a little
too much magic for the code to be easily understandable: why do you
operate on pointers casted to longs, increment in 8-byte steps?
Why is offset_in_page used for an operation that doesn't operate on
struct page at all?  Any reason you can't just use memchr_inv?

> +	if (!pages) {
> +		fail_reason = "no suitable block remaining";
> +		goto fail;
> +	} else if (pages != vma_pages) {

No if else please if you goto a different label, that just confuses the
user.

> +		/*
> +		 * Let's create a mixed map if we can't map it all.
> +		 * The normal paging machinery will take care of the
> +		 * unpopulated vma via cramfs_readpage().
> +		 */
> +		int i;
> +		vma->vm_flags |= VM_MIXEDMAP;
> +		for (i = 0; i < pages; i++) {
> +			unsigned long vaddr = vma->vm_start + i*PAGE_SIZE;
> +			pfn_t pfn = phys_to_pfn_t(address + i*PAGE_SIZE, PFN_DEV);
> +			ret = vm_insert_mixed(vma, vaddr, pfn);

Please use spaces around the * operator, and don't use overly long
lines.

A local variable might help doing that in a readnable way:

			unsigned long off = i * PAGE_SIZE;

			ret = vm_insert_mixed(vma, vma->vm_start + off,
					phys_to_pfn_t(address + off, PFN_DEV);

> +	/* We failed to do a direct map, but normal paging is still possible */
> +	vma->vm_ops = &generic_file_vm_ops;

Maybe let the mixedmap case fall through to this instead of having
a duplicate vm_ops assignment.

> +static unsigned cramfs_physmem_mmap_capabilities(struct file *file)
> +{
> +	return NOMMU_MAP_COPY | NOMMU_MAP_DIRECT | NOMMU_MAP_READ | NOMMU_MAP_EXEC;

Too long line.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
