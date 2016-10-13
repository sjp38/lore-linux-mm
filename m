Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id C7E526B0260
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 08:08:49 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id n3so47881821lfn.5
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 05:08:49 -0700 (PDT)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id n138si8216900lfn.413.2016.10.13.05.08.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Oct 2016 05:08:47 -0700 (PDT)
Received: by mail-lf0-x241.google.com with SMTP id x23so6628946lfi.1
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 05:08:47 -0700 (PDT)
Date: Thu, 13 Oct 2016 15:08:44 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3 17/41] filemap: handle huge pages in
 filemap_fdatawait_range()
Message-ID: <20161013120844.GA2906@node>
References: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
 <20160915115523.29737-18-kirill.shutemov@linux.intel.com>
 <20161013094441.GC26241@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161013094441.GC26241@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Thu, Oct 13, 2016 at 11:44:41AM +0200, Jan Kara wrote:
> On Thu 15-09-16 14:54:59, Kirill A. Shutemov wrote:
> > We writeback whole huge page a time.
> 
> This is one of the things I don't understand. Firstly I didn't see where
> changes of writeback like this would happen (maybe they come later).
> Secondly I'm not sure why e.g. writeback should behave atomically wrt huge
> pages. Is this because radix-tree multiorder entry tracks dirtiness for us
> at that granularity?

We track dirty/writeback on per-compound pages: meaning we have one
dirty/writeback flag for whole compound page, not on every individual
4k subpage. The same story for radix-tree tags.

> BTW, can you also explain why do we need multiorder entries? What do
> they solve for us?

It helps us having coherent view on tags in radix-tree: no matter which
index we refer from the range huge page covers we will get the same
answer on which tags set.

> I'm sorry for these basic questions but I'd just like to understand how is
> this supposed to work...
> 
> 								Honza
> 
> 
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  mm/filemap.c | 5 +++++
> >  1 file changed, 5 insertions(+)
> > 
> > diff --git a/mm/filemap.c b/mm/filemap.c
> > index 05b42d3e5ed8..53da93156e60 100644
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -372,9 +372,14 @@ static int __filemap_fdatawait_range(struct address_space *mapping,
> >  			if (page->index > end)
> >  				continue;
> >  
> > +			page = compound_head(page);
> >  			wait_on_page_writeback(page);
> >  			if (TestClearPageError(page))
> >  				ret = -EIO;
> > +			if (PageTransHuge(page)) {
> > +				index = page->index + HPAGE_PMD_NR;
> > +				i += index - pvec.pages[i]->index - 1;
> > +			}
> >  		}
> >  		pagevec_release(&pvec);
> >  		cond_resched();
> > -- 
> > 2.9.3
> > 
> > 
> -- 
> Jan Kara <jack@suse.com>
> SUSE Labs, CR
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
