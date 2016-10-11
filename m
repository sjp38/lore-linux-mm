Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8659D6B0038
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 17:53:53 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id p80so20415986lfp.6
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 14:53:53 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id k18si3151886lfg.123.2016.10.11.14.53.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Oct 2016 14:53:52 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id l131so2715476lfl.0
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 14:53:51 -0700 (PDT)
Date: Wed, 12 Oct 2016 00:53:49 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3 13/41] truncate: make sure invalidate_mapping_pages()
 can discard huge pages
Message-ID: <20161011215349.GC27110@node.shutemov.name>
References: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
 <20160915115523.29737-14-kirill.shutemov@linux.intel.com>
 <20161011155815.GM6952@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161011155815.GM6952@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Tue, Oct 11, 2016 at 05:58:15PM +0200, Jan Kara wrote:
> On Thu 15-09-16 14:54:55, Kirill A. Shutemov wrote:
> > invalidate_inode_page() has expectation about page_count() of the page
> > -- if it's not 2 (one to caller, one to radix-tree), it will not be
> > dropped. That condition almost never met for THPs -- tail pages are
> > pinned to the pagevec.
> > 
> > Let's drop them, before calling invalidate_inode_page().
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  mm/truncate.c | 11 +++++++++++
> >  1 file changed, 11 insertions(+)
> > 
> > diff --git a/mm/truncate.c b/mm/truncate.c
> > index a01cce450a26..ce904e4b1708 100644
> > --- a/mm/truncate.c
> > +++ b/mm/truncate.c
> > @@ -504,10 +504,21 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
> >  				/* 'end' is in the middle of THP */
> >  				if (index ==  round_down(end, HPAGE_PMD_NR))
> >  					continue;
> > +				/*
> > +				 * invalidate_inode_page() expects
> > +				 * page_count(page) == 2 to drop page from page
> > +				 * cache -- drop tail pages references.
> > +				 */
> > +				get_page(page);
> > +				pagevec_release(&pvec);
> 
> I'm not quite sure why this is needed. When you have multiorder entry in
> the radix tree for your huge page, then you should not get more entries in
> the pagevec for your huge page. What do I miss?

For compatibility reason find_get_entries() (which is called by
pagevec_lookup_entries()) collects all subpages of huge page in the range
(head/tails). See patch [07/41]

So huge page, which is fully in the range it will be pinned up to
PAGEVEC_SIZE times.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
