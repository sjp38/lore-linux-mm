Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 442256B007E
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 16:47:16 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id d19so123899101lfb.0
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 13:47:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k11si567342wmg.101.2016.04.18.13.47.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Apr 2016 13:47:14 -0700 (PDT)
Date: Mon, 18 Apr 2016 22:47:08 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v3 1/2] dax: add dax_get_unmapped_area for pmd mappings
Message-ID: <20160418204708.GB17889@quack2.suse.cz>
References: <1460652511-19636-1-git-send-email-toshi.kani@hpe.com>
 <1460652511-19636-2-git-send-email-toshi.kani@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1460652511-19636-2-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, viro@zeniv.linux.org.uk, willy@linux.intel.com, ross.zwisler@linux.intel.com, kirill.shutemov@linux.intel.com, david@fromorbit.com, jack@suse.cz, tytso@mit.edu, adilger.kernel@dilger.ca, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 14-04-16 10:48:30, Toshi Kani wrote:
> +
> +/**
> + * dax_get_unmapped_area - handle get_unmapped_area for a DAX file
> + * @filp: The file being mmap'd, if not NULL
> + * @addr: The mmap address. If NULL, the kernel assigns the address
> + * @len: The mmap size in bytes
> + * @pgoff: The page offset in the file where the mapping starts from.
> + * @flags: The mmap flags
> + *
> + * This function can be called by a filesystem for get_unmapped_area().
> + * When a target file is a DAX file, it aligns the mmap address at the
> + * beginning of the file by the pmd size.
> + */
> +unsigned long dax_get_unmapped_area(struct file *filp, unsigned long addr,
> +		unsigned long len, unsigned long pgoff, unsigned long flags)
> +{
> +	unsigned long off, off_end, off_pmd, len_pmd, addr_pmd;

I think we need to use 'loff_t' for the offsets for things to work on
32-bits.

> +	if (!IS_ENABLED(CONFIG_FS_DAX_PMD) ||
> +	    !filp || addr || !IS_DAX(filp->f_mapping->host))
> +		goto out;
> +
> +	off = pgoff << PAGE_SHIFT;

And here we need to type to loff_t before the shift...

> +	off_end = off + len;
> +	off_pmd = round_up(off, PMD_SIZE);  /* pmd-aligned offset */
> +
> +	if ((off_end <= off_pmd) || ((off_end - off_pmd) < PMD_SIZE))

None of these parenthesis is actually needed (and IMHO they make the code
less readable, not more).

> +		goto out;
> +
> +	len_pmd = len + PMD_SIZE;
> +	if ((off + len_pmd) < off)
> +		goto out;
> +
> +	addr_pmd = current->mm->get_unmapped_area(filp, addr, len_pmd,
> +						  pgoff, flags);
> +	if (!IS_ERR_VALUE(addr_pmd)) {
> +		addr_pmd += (off - addr_pmd) & (PMD_SIZE - 1);
> +		return addr_pmd;

Otherwise the patch looks good to me.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
