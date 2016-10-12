Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8479A6B0069
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 02:43:30 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id z189so3765324wmb.5
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 23:43:30 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w17si8655393wjd.36.2016.10.11.23.43.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Oct 2016 23:43:29 -0700 (PDT)
Date: Wed, 12 Oct 2016 08:43:20 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCHv3 13/41] truncate: make sure invalidate_mapping_pages()
 can discard huge pages
Message-ID: <20161012064320.GA13896@quack2.suse.cz>
References: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
 <20160915115523.29737-14-kirill.shutemov@linux.intel.com>
 <20161011155815.GM6952@quack2.suse.cz>
 <20161011215349.GC27110@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161011215349.GC27110@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Wed 12-10-16 00:53:49, Kirill A. Shutemov wrote:
> On Tue, Oct 11, 2016 at 05:58:15PM +0200, Jan Kara wrote:
> > On Thu 15-09-16 14:54:55, Kirill A. Shutemov wrote:
> > > invalidate_inode_page() has expectation about page_count() of the page
> > > -- if it's not 2 (one to caller, one to radix-tree), it will not be
> > > dropped. That condition almost never met for THPs -- tail pages are
> > > pinned to the pagevec.
> > > 
> > > Let's drop them, before calling invalidate_inode_page().
> > > 
> > > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > ---
> > >  mm/truncate.c | 11 +++++++++++
> > >  1 file changed, 11 insertions(+)
> > > 
> > > diff --git a/mm/truncate.c b/mm/truncate.c
> > > index a01cce450a26..ce904e4b1708 100644
> > > --- a/mm/truncate.c
> > > +++ b/mm/truncate.c
> > > @@ -504,10 +504,21 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
> > >  				/* 'end' is in the middle of THP */
> > >  				if (index ==  round_down(end, HPAGE_PMD_NR))
> > >  					continue;
> > > +				/*
> > > +				 * invalidate_inode_page() expects
> > > +				 * page_count(page) == 2 to drop page from page
> > > +				 * cache -- drop tail pages references.
> > > +				 */
> > > +				get_page(page);
> > > +				pagevec_release(&pvec);
> > 
> > I'm not quite sure why this is needed. When you have multiorder entry in
> > the radix tree for your huge page, then you should not get more entries in
> > the pagevec for your huge page. What do I miss?
> 
> For compatibility reason find_get_entries() (which is called by
> pagevec_lookup_entries()) collects all subpages of huge page in the range
> (head/tails). See patch [07/41]
> 
> So huge page, which is fully in the range it will be pinned up to
> PAGEVEC_SIZE times.

Yeah, I see. But then won't it be cleaner to provide iteration method that
would add to pagevec each radix tree entry (regardless of its order) only
once and then use it in places where we care? Instead of strange dances
like you do here?

Ultimately we could convert all the places to use these new iteration
methods but I don't see that as immediately necessary and maybe there are
places where getting all the subpages in the pagevec actually makes life
simpler for us (please point me if you know about such place).

On a somewhat unrelated note: I've noticed that you don't invalidate
a huge page when only part of it should be invalidated. That actually
breaks some assumptions filesystems make. In particular direct IO code
assumes that if you do

	filemap_write_and_wait_range(inode, start, end);
	invalidate_inode_pages2_range(inode, start, end);

all the page cache covering start-end *will* be invalidated. Your skipping
of partial pages breaks this assumption and thus can bring consistency
issues (e.g. write done using direct IO won't be seen by following buffered
read).

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
