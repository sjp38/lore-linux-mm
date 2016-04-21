Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 487FB6B0297
	for <linux-mm@kvack.org>; Thu, 21 Apr 2016 03:05:56 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id vv3so97863262pab.2
        for <linux-mm@kvack.org>; Thu, 21 Apr 2016 00:05:56 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id rl12si1995338pab.36.2016.04.21.00.05.55
        for <linux-mm@kvack.org>;
        Thu, 21 Apr 2016 00:05:55 -0700 (PDT)
Date: Thu, 21 Apr 2016 03:06:25 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v3 0/2] Align mmap address for DAX pmd mappings
Message-ID: <20160421070625.GB29068@linux.intel.com>
References: <1460652511-19636-1-git-send-email-toshi.kani@hpe.com>
 <20160415220531.c7b55adb5b26eb749fae3186@linux-foundation.org>
 <20160418202610.GA17889@quack2.suse.cz>
 <20160419182347.GA29068@linux.intel.com>
 <571844A1.5080703@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <571844A1.5080703@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, dan.j.williams@intel.com, viro@zeniv.linux.org.uk, ross.zwisler@linux.intel.com, kirill.shutemov@linux.intel.com, david@fromorbit.com, tytso@mit.edu, adilger.kernel@dilger.ca, linux-nvdimm@ml01.01.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Apr 20, 2016 at 11:10:25PM -0400, Toshi Kani wrote:
> How about moving the function (as is) to mm/huge_memory.c, rename it to
> get_hugepage_unmapped_area(), which is defined to NULL in huge_mm.h
> when TRANSPARENT_HUGEPAGE is unset?

Great idea.  Perhaps it should look something like this?

unsigned long thp_get_unmapped_area(struct file *filp, unsigned long addr,
                unsigned long len, unsigned long pgoff, unsigned long flags)
{
        loff_t off, off_end, off_pmd;
        unsigned long len_pmd, addr_pmd;

        if (addr)
                goto out;
        if (IS_DAX(filp->f_mapping->host) && !IS_ENABLED(CONFIG_FS_DAX_PMD))
                goto out;
        /* Kirill, please fill in the right condition here for THP pagecache */

        off = (loff_t)pgoff << PAGE_SHIFT;
        off_end = off + len;
        off_pmd = round_up(off, PMD_SIZE);      /* pmd-aligned start offset */

        if ((off_end <= off_pmd) || ((off_end - off_pmd) < PMD_SIZE))
                goto out;

        len_pmd = len + PMD_SIZE;
        if ((off + len_pmd) < off)
                goto out;

        addr_pmd = current->mm->get_unmapped_area(filp, NULL, len_pmd,
                                                pgoff, flags);
        if (!IS_ERR_VALUE(addr_pmd)) {
                addr_pmd += (off - addr_pmd) & (PMD_SIZE - 1);
                return addr_pmd;
        }
 out:
        return current->mm->get_unmapped_area(filp, addr, len, pgoff, flags);
}

 - I deleted the check for filp == NULL.  It can't be NULL ... this is a
   file_operation ;-)
 - Why is len_pmd len + PMD_SIZE instead of round_up(len, PMD_SIZE)?
 - I'm still in two minds about passing 'addr' to the first call to
   get_unmapped_area() instead of NULL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
