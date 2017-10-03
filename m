Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2DC346B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 08:03:22 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id y192so22473144pgd.0
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 05:03:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c79si9590413pfe.388.2017.10.03.05.03.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Oct 2017 05:03:20 -0700 (PDT)
Date: Tue, 3 Oct 2017 14:03:18 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 15/15] afs: Use find_get_pages_range_tag()
Message-ID: <20171003120318.GI11879@quack2.suse.cz>
References: <20170927160334.29513-1-jack@suse.cz>
 <20170927160334.29513-16-jack@suse.cz>
 <ea1aa003-aaff-a17c-5a2c-28ed3c97a588@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ea1aa003-aaff-a17c-5a2c-28ed3c97a588@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, David Howells <dhowells@redhat.com>, linux-afs@lists.infradead.org

On Fri 29-09-17 17:46:45, Daniel Jordan wrote:
> On 09/27/2017 12:03 PM, Jan Kara wrote:
> >Use find_get_pages_range_tag() in afs_writepages_region() as we are
> >interested only in pages from given range. Remove unnecessary code after
> >this conversion.
> >
> >CC: David Howells <dhowells@redhat.com>
> >CC: linux-afs@lists.infradead.org
> >Signed-off-by: Jan Kara <jack@suse.cz>
> >---
> >  fs/afs/write.c | 11 ++---------
> >  1 file changed, 2 insertions(+), 9 deletions(-)
> >
> >diff --git a/fs/afs/write.c b/fs/afs/write.c
> >index 106e43db1115..d62a6b54152d 100644
> >--- a/fs/afs/write.c
> >+++ b/fs/afs/write.c
> >@@ -497,20 +497,13 @@ static int afs_writepages_region(struct address_space *mapping,
> >  	_enter(",,%lx,%lx,", index, end);
> >  	do {
> >-		n = find_get_pages_tag(mapping, &index, PAGECACHE_TAG_DIRTY,
> >-				       1, &page);
> >+		n = find_get_pages_range_tag(mapping, &index, end,
> >+					PAGECACHE_TAG_DIRTY, 1, &page);
> >  		if (!n)
> >  			break;
> >  		_debug("wback %lx", page->index);
> >-		if (page->index > end) {
> >-			*_next = index;
> >-			put_page(page);
> >-			_leave(" = 0 [%lx]", *_next);
> >-			return 0;
> >-		}
> >-
> >  		/* at this point we hold neither mapping->tree_lock nor lock on
> >  		 * the page itself: the page may be truncated or invalidated
> >  		 * (changing page->mapping to NULL), or even swizzled back from
> 
> There's also one other caller of find_get_pages_tag that could be converted,
> wdata_alloc_and_fillpages.  Since the 256 max mentioned in the comment below
> no longer seems to apply, maybe something like this?:

Yeah, added a patch doing something like this.

> diff --git a/fs/cifs/file.c b/fs/cifs/file.c
> index 92fdf9c35de2..4dbd24231e8a 100644
> --- a/fs/cifs/file.c
> +++ b/fs/cifs/file.c
> @@ -1963,31 +1963,14 @@ wdata_alloc_and_fillpages(pgoff_t tofind, struct
> address_space *mapping,
>                           pgoff_t end, pgoff_t *index,
>                           unsigned int *found_pages)
>  {
> -       unsigned int nr_pages;
> -       struct page **pages;
> -       struct cifs_writedata *wdata;
> -
> -       wdata = cifs_writedata_alloc((unsigned int)tofind,
> -                                    cifs_writev_complete);
> +       struct cifs_writedata *wdata =
> cifs_writedata_alloc((unsigned)tofind,
> + cifs_writev_complete);
>         if (!wdata)
>                 return NULL;
> 
> -       /*
> -        * find_get_pages_tag seems to return a max of 256 on each
> -        * iteration, so we must call it several times in order to
> -        * fill the array or the wsize is effectively limited to
> -        * 256 * PAGE_SIZE.
> -        */
> -       *found_pages = 0;
> -       pages = wdata->pages;
> -       do {
> -               nr_pages = find_get_pages_tag(mapping, index,
> -                                             PAGECACHE_TAG_DIRTY, tofind,
> -                                             pages);
> -               *found_pages += nr_pages;
> -               tofind -= nr_pages;
> -               pages += nr_pages;
> -       } while (nr_pages && tofind && *index <= end);
> +       *found_pages = find_get_pages_range_tag(mapping, index, end,
> +                                               PAGECACHE_TAG_DIRTY, tofind,
> +                                               wdata->pages);
> 
>         return wdata;
>  }
> 
> Otherwise the set looks good, so for the whole thing,
> 
> Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>

Thanks for review!

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
