Date: Thu, 5 Apr 2007 11:17:33 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] Free up page->private for compound pages
In-Reply-To: <Pine.LNX.4.64.0704051522510.24160@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0704051117110.9800@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0704042016490.7885@schroedinger.engr.sgi.com>
 <20070405033648.GG11192@wotan.suse.de> <Pine.LNX.4.64.0704042037550.8745@schroedinger.engr.sgi.com>
 <20070405035741.GH11192@wotan.suse.de> <Pine.LNX.4.64.0704042102570.12297@schroedinger.engr.sgi.com>
 <20070405042502.GI11192@wotan.suse.de> <Pine.LNX.4.64.0704042132170.14005@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0704051522510.24160@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, dgc@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, 5 Apr 2007, Hugh Dickins wrote:

> >  static inline int page_count(struct page *page)
> >  {
> > -	if (unlikely(PageCompound(page)))
> > -		page = (struct page *)page_private(page);
> > -	return atomic_read(&page->_count);
> > +	return atomic_read(&compound_head(page)->_count);
> >  }
> 
> No, you don't want anyone looking at the page_count of a page
> currently under reclaim, or doing a get_page on it, to go veering
> off through its page->private (page->first_page comes from another
> of your patches, not in -mm).  Looks like you need to add a test for
> PageCompound in compound_head (what a surprise!), unfortunately.

Hmmm... Thus we should really have separate page flag and not overload it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
