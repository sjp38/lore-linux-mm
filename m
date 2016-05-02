Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id E9CB56B025E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 09:19:46 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id j8so140402510lfd.0
        for <linux-mm@kvack.org>; Mon, 02 May 2016 06:19:46 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id be7si34105983wjb.175.2016.05.02.06.19.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 02 May 2016 06:19:45 -0700 (PDT)
Date: Mon, 2 May 2016 15:19:43 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 13/18] dax: Make huge page handling depend of
 CONFIG_BROKEN
Message-ID: <20160502131943.GG17362@quack2.suse.cz>
References: <1461015341-20153-1-git-send-email-jack@suse.cz>
 <1461015341-20153-14-git-send-email-jack@suse.cz>
 <20160429195340.GG5888@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160429195340.GG5888@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>

On Fri 29-04-16 13:53:40, Ross Zwisler wrote:
> On Mon, Apr 18, 2016 at 11:35:36PM +0200, Jan Kara wrote:
> > Currently the handling of huge pages for DAX is racy. For example the
> > following can happen:
> > 
> > CPU0 (THP write fault)			CPU1 (normal read fault)
> > 
> > __dax_pmd_fault()			__dax_fault()
> >   get_block(inode, block, &bh, 0) -> not mapped
> > 					get_block(inode, block, &bh, 0)
> > 					  -> not mapped
> >   if (!buffer_mapped(&bh) && write)
> >     get_block(inode, block, &bh, 1) -> allocates blocks
> >   truncate_pagecache_range(inode, lstart, lend);
> > 					dax_load_hole();
> > 
> > This results in data corruption since process on CPU1 won't see changes
> > into the file done by CPU0.
> > 
> > The race can happen even if two normal faults race however with THP the
> > situation is even worse because the two faults don't operate on the same
> > entries in the radix tree and we want to use these entries for
> > serialization. So make THP support in DAX code depend on CONFIG_BROKEN
> > for now.
> > 
> > Signed-off-by: Jan Kara <jack@suse.cz>
> > ---
> >  fs/dax.c            | 2 +-
> >  include/linux/dax.h | 2 +-
> >  2 files changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/fs/dax.c b/fs/dax.c
> > index d7addfab2094..388327f56fa8 100644
> > --- a/fs/dax.c
> > +++ b/fs/dax.c
> > @@ -707,7 +707,7 @@ int dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
> >  }
> >  EXPORT_SYMBOL_GPL(dax_fault);
> >  
> > -#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> > +#if defined(CONFIG_TRANSPARENT_HUGEPAGE) && defined(CONFIG_BROKEN)
> >  /*
> >   * The 'colour' (ie low bits) within a PMD of a page offset.  This comes up
> >   * more often than one might expect in the below function.
> > diff --git a/include/linux/dax.h b/include/linux/dax.h
> > index 7c45ac7ea1d1..0591f4853228 100644
> > --- a/include/linux/dax.h
> > +++ b/include/linux/dax.h
> > @@ -23,7 +23,7 @@ static inline struct page *read_dax_sector(struct block_device *bdev,
> >  }
> >  #endif
> >  
> > -#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> > +#if defined(CONFIG_TRANSPARENT_HUGEPAGE) && defined(CONFIG_BROKEN)
> >  int dax_pmd_fault(struct vm_area_struct *, unsigned long addr, pmd_t *,
> >  				unsigned int flags, get_block_t);
> >  int __dax_pmd_fault(struct vm_area_struct *, unsigned long addr, pmd_t *,
> > -- 
> > 2.6.6
> 
> Ah, sorry, I think by "make PMD depend on CONFIG_BROKEN" Dan & I meant this:
> 
> diff --git a/fs/Kconfig b/fs/Kconfig
> index 6725f59..b8fcb41 100644
> --- a/fs/Kconfig
> +++ b/fs/Kconfig
> @@ -52,6 +52,7 @@ config FS_DAX_PMD
>         depends on FS_DAX
>         depends on ZONE_DEVICE
>         depends on TRANSPARENT_HUGEPAGE
> +       depends on BROKEN
>  
>  endif # BLOCK
> 
> This has the benefit that you have only one place to quickly reenable PMD code
> if/when we want to work on it.

OK, makes sense. I've changed this.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
