Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id D9AAA830A8
	for <linux-mm@kvack.org>; Thu, 21 Apr 2016 20:22:04 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id zy2so132015128pac.1
        for <linux-mm@kvack.org>; Thu, 21 Apr 2016 17:22:04 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id m5si3332298pfm.117.2016.04.21.17.22.03
        for <linux-mm@kvack.org>;
        Thu, 21 Apr 2016 17:22:03 -0700 (PDT)
Date: Thu, 21 Apr 2016 20:22:36 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v3 0/2] Align mmap address for DAX pmd mappings
Message-ID: <20160422002236.GE29068@linux.intel.com>
References: <1460652511-19636-1-git-send-email-toshi.kani@hpe.com>
 <20160415220531.c7b55adb5b26eb749fae3186@linux-foundation.org>
 <20160418202610.GA17889@quack2.suse.cz>
 <20160419182347.GA29068@linux.intel.com>
 <571844A1.5080703@hpe.com>
 <20160421070625.GB29068@linux.intel.com>
 <57193658.9020803@oracle.com>
 <571965AB.9070707@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <571965AB.9070707@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Jan Kara <jack@suse.cz>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "david@fromorbit.com" <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "adilger.kernel@dilger.ca" <adilger.kernel@dilger.ca>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>

On Thu, Apr 21, 2016 at 07:43:39PM -0400, Toshi Kani wrote:
> On 4/21/2016 4:21 PM, Mike Kravetz wrote:
> >Might want to keep the future possibility of PUD_SIZE THP in mind?
> 
> Yes, this is why the func name does not say 'pmd'. It can be extended to
> support
> PUD_SIZE in future.

Sure ... but what does that look like?  I think it should look a little
like this:

unsigned long __thp_get_unmapped_area(struct file *filp, unsigned long len,
                        loff_t off, unsigned long flags, unsigned long size);
{
        unsigned long addr;
        loff_t off_end = off + len;
        loff_t off_align = round_up(off, size);
        unsigned long len_size;

        if ((off_end <= off_align) || ((off_end - off_align) < size))
                return NULL;

        len_size = len + size;
        if ((len_size < len) || (off + len_size) < off)
                return NULL;

        addr = current->mm->get_unmapped_area(filp, NULL, len_size,
                                                off >> PAGE_SHIFT, flags);
        if (IS_ERR_VALUE(addr))
                return NULL;
 
        addr += (off - addr) & (size - 1);
        return addr;
}

unsigned long thp_get_unmapped_area(struct file *filp, unsigned long addr,
                unsigned long len, unsigned long pgoff, unsigned long flags)
{
        loff_t off = (loff_t)pgoff << PAGE_SHIFT;

        if (addr)
                goto out;
        if (IS_DAX(filp->f_mapping->host) && !IS_ENABLED(CONFIG_FS_DAX_PMD))
                goto out;
        /* Kirill, please fill in the right condition here for THP pagecache */

        addr = __thp_get_unmapped_area(filp, len, off, flags, PUD_SIZE);
        if (addr)
                return addr;
        addr = __thp_get_unmapped_area(filp, len, off, flags, PMD_SIZE);
        if (addr)
                return addr;

 out:
        return current->mm->get_unmapped_area(filp, addr, len, pgoff, flags);
}

By the way, I added an extra check here, when we add len and size
(PMD_SIZE in the original), we need to make sure that doesn't wrap.
NB: I'm not even compiling these suggestions, just throwing them out
here as ideas to be criticised.

Also, len_size is a stupid name, but I can't think of a better one.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
