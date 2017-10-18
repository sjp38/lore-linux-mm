Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 16BE86B0069
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 06:44:31 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u27so3851465pgn.3
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 03:44:31 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f10si7643361pln.470.2017.10.18.03.44.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Oct 2017 03:44:30 -0700 (PDT)
Date: Wed, 18 Oct 2017 12:44:28 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 7/7] mm: Batch radix tree operations when truncating pages
Message-ID: <20171018104428.GB32403@quack2.suse.cz>
References: <20171010151937.26984-1-jack@suse.cz>
 <20171010151937.26984-8-jack@suse.cz>
 <20171017160521.33ca85c45431c355833daa63@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171017160521.33ca85c45431c355833daa63@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel@vger.kernel.org

On Tue 17-10-17 16:05:21, Andrew Morton wrote:
> On Tue, 10 Oct 2017 17:19:37 +0200 Jan Kara <jack@suse.cz> wrote:
> 
> > --- a/mm/truncate.c
> > +++ b/mm/truncate.c
> > @@ -294,6 +294,14 @@ void truncate_inode_pages_range(struct address_space *mapping,
> >  	while (index < end && pagevec_lookup_entries(&pvec, mapping, index,
> >  			min(end - index, (pgoff_t)PAGEVEC_SIZE),
> >  			indices)) {
> > +		/*
> > +		 * Pagevec array has exceptional entries and we may also fail
> > +		 * to lock some pages. So we store pages that can be deleted
> > +		 * in an extra array.
> > +		 */
> > +		struct page *pages[PAGEVEC_SIZE];
> > +		int batch_count = 0;
> 
> OK, but we could still use a new pagevec here.  Then
> delete_from_page_cache_batch() and page_cache_tree_delete_batch() would
> take one less argument.

Originally, I didn't want to manually construct new pagevec outside of
pagevec code. But now I see there are clean helpers for that. I'll send you
a patch to fold. Thanks for the suggestion!

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
