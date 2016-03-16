Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id EBCB66B0005
	for <linux-mm@kvack.org>; Wed, 16 Mar 2016 10:27:35 -0400 (EDT)
Received: by mail-pf0-f171.google.com with SMTP id u190so77252332pfb.3
        for <linux-mm@kvack.org>; Wed, 16 Mar 2016 07:27:35 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id f11si5475654pat.133.2016.03.16.07.27.34
        for <linux-mm@kvack.org>;
        Wed, 16 Mar 2016 07:27:35 -0700 (PDT)
Date: Wed, 16 Mar 2016 17:27:29 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: Page migration issue with UBIFS
Message-ID: <20160316142729.GA125481@black.fi.intel.com>
References: <56E8192B.5030008@nod.at>
 <20160315151727.GA16462@node.shutemov.name>
 <56E82B18.9040807@nod.at>
 <20160315153744.GB28522@infradead.org>
 <56E8985A.1020509@nod.at>
 <20160316142156.GA23595@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160316142156.GA23595@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Richard Weinberger <richard@nod.at>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Boris Brezillon <boris.brezillon@free-electrons.com>, Maxime Ripard <maxime.ripard@free-electrons.com>, David Gstir <david@sigma-star.at>, Dave Chinner <david@fromorbit.com>, Artem Bityutskiy <dedekind1@gmail.com>, Alexander Kaplan <alex@nextthing.co>

On Wed, Mar 16, 2016 at 05:21:56PM +0300, Kirill A. Shutemov wrote:
> On Wed, Mar 16, 2016 at 12:18:50AM +0100, Richard Weinberger wrote:
> > Am 15.03.2016 um 16:37 schrieb Christoph Hellwig:
> > > On Tue, Mar 15, 2016 at 04:32:40PM +0100, Richard Weinberger wrote:
> > >>> Or if ->page_mkwrite() was called, why the page is not dirty?
> > >>
> > >> BTW: UBIFS does not implement ->migratepage(), could this be a problem?
> > > 
> > > This might be the reason.  I can't reall make sense of
> > > buffer_migrate_page, but it seems to migrate buffer_head state to
> > > the new page.
> > > 
> > > I'd love to know why CMA even tries to migrate pages that don't have a
> > > ->migratepage method, this seems incredibly dangerous to me.
> > 
> > FYI, with a dummy ->migratepage() which returns only -EINVAL UBIFS does no
> > longer explode upon page migration.
> > Tomorrow I'll do more tests to make sure.
> 
> Could you check if something like this would fix the issue.
> Completely untested.
> 
> diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
> index 065c88f8e4b8..9da34120dc5e 100644
> --- a/fs/ubifs/file.c
> +++ b/fs/ubifs/file.c
> @@ -52,6 +52,7 @@
>  #include "ubifs.h"
>  #include <linux/mount.h>
>  #include <linux/slab.h>
> +#include <linux/migrate.h>
>  
>  static int read_block(struct inode *inode, void *addr, unsigned int block,
>  		      struct ubifs_data_node *dn)
> @@ -1452,6 +1453,20 @@ static int ubifs_set_page_dirty(struct page *page)
>  	return ret;
>  }
>  
> +static int ubifs_migrate_page(struct address_space *mapping,
> +		struct page *newpage, struct page *page, enum migrate_mode mode)
> +{
> +	if (PagePrivate(page)) {
> +		SetPagePrivate(newpage);
> +		__set_page_dirty_nobuffers(newpage);
> +	}
> +
> +	if (PageChecked(page))
> +		SetPageChecked(newpage);

These two lines are redundant, migrate_page_copy() would do this for us.

> +
> +	return migrate_page(mapping, newpage, page, mode);
> +}
> +
>  static int ubifs_releasepage(struct page *page, gfp_t unused_gfp_flags)
>  {
>  	/*
> @@ -1591,6 +1606,7 @@ const struct address_space_operations ubifs_file_address_operations = {
>  	.write_end      = ubifs_write_end,
>  	.invalidatepage = ubifs_invalidatepage,
>  	.set_page_dirty = ubifs_set_page_dirty,
> +	.migratepage	= ubifs_migrate_page,
>  	.releasepage    = ubifs_releasepage,
>  };
>  
> -- 
>  Kirill A. Shutemov

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
