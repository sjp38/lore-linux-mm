Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 7BF086B003A
	for <linux-mm@kvack.org>; Fri, 14 Mar 2014 20:06:04 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id bj1so3299610pad.31
        for <linux-mm@kvack.org>; Fri, 14 Mar 2014 17:06:04 -0700 (PDT)
Received: from g2t2352.austin.hp.com (g2t2352.austin.hp.com. [15.217.128.51])
        by mx.google.com with ESMTPS id iu9si3924413pac.125.2014.03.14.17.05.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 14 Mar 2014 17:05:59 -0700 (PDT)
Message-ID: <1394841524.6784.213.camel@misato.fc.hp.com>
Subject: Re: [RFC PATCH] Support map_pages() for DAX
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 14 Mar 2014 17:58:44 -0600
In-Reply-To: <20140314233233.GA8310@node.dhcp.inet.fi>
References: <1394838199-29102-1-git-send-email-toshi.kani@hp.com>
	 <20140314233233.GA8310@node.dhcp.inet.fi>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: willy@linux.intel.com, kirill.shutemov@linux.intel.com, david@fromorbit.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 2014-03-15 at 01:32 +0200, Kirill A. Shutemov wrote:
> On Fri, Mar 14, 2014 at 05:03:19PM -0600, Toshi Kani wrote:
> > +void dax_map_pages(struct vm_area_struct *vma, struct vm_fault *vmf,
> > +		get_block_t get_block)
> > +{
> > +	struct file *file = vma->vm_file;
> > +	struct inode *inode = file_inode(file);
> > +	struct buffer_head bh;
> > +	struct address_space *mapping = file->f_mapping;
> > +	unsigned long vaddr = (unsigned long)vmf->virtual_address;
> > +	pgoff_t pgoff = vmf->pgoff;
> > +	sector_t block;
> > +	pgoff_t size;
> > +	unsigned long pfn;
> > +	pte_t *pte = vmf->pte;
> > +	int error;
> > +
> > +	while (pgoff < vmf->max_pgoff) {
> > +		size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
> > +		if (pgoff >= size)
> > +			return;
> > +
> > +		memset(&bh, 0, sizeof(bh));
> > +		block = (sector_t)pgoff << (PAGE_SHIFT - inode->i_blkbits);
> > +		bh.b_size = PAGE_SIZE;
> > +		error = get_block(inode, block, &bh, 0);
> > +		if (error || bh.b_size < PAGE_SIZE)
> > +			goto next;
> > +
> > +		if (!buffer_mapped(&bh) || buffer_unwritten(&bh) ||
> > +		    buffer_new(&bh))
> > +			goto next;
> > +
> > +		/* Recheck i_size under i_mmap_mutex */
> > +		mutex_lock(&mapping->i_mmap_mutex);
> 
> NAK. Have you tested this with lockdep enabled?
>
> ->map_pages() called with page table lock taken and ->i_mmap_mutex
> should be taken before it. It seems we need to take ->i_mmap_mutex in
> do_read_fault() before calling ->map_pages().

Thanks for pointing this out! I will make sure to test with lockdep next
time.

> Side note: I'm sceptical about whole idea to use i_mmap_mutux to protect
> against truncate. It will not scale good enough comparing lock_page()
> with its granularity.

I see.  I will think about it as well.  

Thanks,
-Toshi



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
