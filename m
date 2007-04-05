Date: Thu, 5 Apr 2007 11:58:52 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] Free up page->private for compound pages
In-Reply-To: <Pine.LNX.4.64.0704051919490.17494@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0704051152500.10694@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0704042016490.7885@schroedinger.engr.sgi.com>
 <20070405033648.GG11192@wotan.suse.de> <Pine.LNX.4.64.0704042037550.8745@schroedinger.engr.sgi.com>
 <20070405035741.GH11192@wotan.suse.de> <Pine.LNX.4.64.0704042102570.12297@schroedinger.engr.sgi.com>
 <20070405042502.GI11192@wotan.suse.de> <Pine.LNX.4.64.0704042132170.14005@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0704051522510.24160@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0704051117110.9800@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0704051919490.17494@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, dgc@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, 5 Apr 2007, Hugh Dickins wrote:

> > > off through its page->private (page->first_page comes from another
> > > of your patches, not in -mm).  Looks like you need to add a test for

Yes its in mm. See the slub patches.

> > > PageCompound in compound_head (what a surprise!), unfortunately.
> > 
> > Hmmm... Thus we should really have separate page flag and not overload it?
> 
> Of course that would be more efficient, but is it really something
> we'd want to be spending a page flag on?  And it's mainly a codesize
> thing, the initial unlikely(PageCompound) tests should keep the main
> paths as fast as before, shouldn't they?

I am not so much worried about performance but more about the availability 
of the page->private field of compound pages.

> But I did wonder whether you could do it differently, but not setting
> PageCompound on the first struct page of the compound at all - that
> one doesn't need the compound page adjustment, of course, which is
> your whole point.

Have not thought about it being a performance improvement. Good point 
though.
 
> Then in those places which really need to know the first is compounded,
> test something like PageCompound(page+1) instead.  "something like"
> because that particular test won't work nicely for the very last
> struct page in a ... node? (sorry, I don't know the right terminology:
> the last struct page in a mem_map-like array).

The last page in a MAX_ORDER block may have issues. In particular if its 
the last MAX_ORDER block in a zone. This going to make sparsemem go 
ballistic.

> But if that ends up peppering the code with PageCompound(page) ||
> PageCompound(page+1) expressions on fast paths, it'd be a whole lot
> worse than the PageCompound(page) && PageTail(page) we're envisaging.

Not sure exactly what you are saying.

The initial proposal was to have


1. Headpage		PageCompound

2. Tail page		PageCompound & PageTail

The PageCompound on each page is necessary for various I/O paths that 
check for compound pages and refuse to do certain things (like dirtying 
etc).

The tail marking is advantages because it exactly marks a page that is

1. Compound

2. Not the head of the compound page

Thus is easy and fast to establish the need to lookup the head page of a 
compound page.

I think we cannot overload the page flag after all because of the page 
count issue you pointed out. Guess I should be cleaning up my 
initial patch and repost it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
