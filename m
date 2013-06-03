Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id CCB5C6B0002
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 09:49:10 -0400 (EDT)
Date: Mon, 3 Jun 2013 09:48:43 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCHv12 2/4] zbud: add to mm/
Message-ID: <20130603134843.GO6893@phenom.dumpdata.com>
References: <1369067168-12291-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1369067168-12291-3-git-send-email-sjenning@linux.vnet.ibm.com>
 <20130528145911.bd484cbb0bb7a27c1623c520@linux-foundation.org>
 <20130529154500.GB428@cerebellum>
 <20130529113434.b2ced4cc1e66c7a0a520d908@linux-foundation.org>
 <20130529204236.GD428@cerebellum>
 <20130529134835.58dd89774f47205da4a06202@linux-foundation.org>
 <754ae8a0-23af-4c87-953f-d608cba84191@default>
 <20130529142904.ace2a29b90a9076d0ee251fd@linux-foundation.org>
 <20130530174344.GA15837@medulla>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130530174344.GA15837@medulla>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, Heesub Shin <heesub.shin@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Thu, May 30, 2013 at 12:43:44PM -0500, Seth Jennings wrote:
> On Wed, May 29, 2013 at 02:29:04PM -0700, Andrew Morton wrote:
> > On Wed, 29 May 2013 14:09:02 -0700 (PDT) Dan Magenheimer <dan.magenheimer@oracle.com> wrote:
> > 
> > > > memory_failure() is merely an example of a general problem: code which
> > > > reads from the memmap[] array and expects its elements to be of type
> > > > `struct page'.  Other examples might be memory hotplugging, memory leak
> > > > checkers etc.  I have vague memories of out-of-tree patches
> > > > (bigphysarea?) doing this as well.
> > > > 
> > > > It's a general problem to which we need a general solution.
> > > 
> > > <Obi-tmem Kenobe slowly materializes... "use the force, Luke!">
> > > 
> > > One could reasonably argue that any code that makes incorrect
> > > assumptions about the contents of a struct page structure is buggy
> > > and should be fixed.
> > 
> > Well it has type "struct page" and all code has a right to expect the
> > contents to match that type.
> > 
> > >  Isn't the "general solution" already described
> > > in the following comment, excerpted from include/linux/mm.h, which
> > > implies that "scribbling on existing pageframes" [carefully], is fine?
> > > (And, if not, shouldn't that comment be fixed, or am I misreading
> > > it?)
> > > 
> > > <start excerpt>
> > >  * For the non-reserved pages, page_count(page) denotes a reference count.
> > >  *   page_count() == 0 means the page is free. page->lru is then used for
> > >  *   freelist management in the buddy allocator.
> > >  *   page_count() > 0  means the page has been allocated.
> > 
> > Well kinda maybe.  How all the random memmap-peekers handle this I do
> > not know.  Setting PageReserved is a big hammer which should keep other
> > little paws out of there, although I guess it's abusive of whatever
> > PageReserved is supposed to mean.
> > 
> > It's what we used to call a variant record.  The tag is page.flags and
> > the protocol is, umm,
> > 
> > PageReserved: doesn't refer to a page at all - don't touch
> > PageSlab: belongs to slab or slub
> > !PageSlab: regular kernel/user/pagecache page
> 
> In the !PageSlab case, the page _count has to be considered to determine if the
> page is a free page or if it is an allocated non-slab page.
> 
> So looking at the fields that need to remained untouched in the struct page for
> the memmap-peekers, they are
> - page->flags
> - page->_count
> 
> Is this correct?
> 
> > 
> > Are there any more?
> > 
> > So what to do here?  How about
> > 
> > - Position the zbud fields within struct page via the preferred
> >   means: editing its definition.
> > 
> > - Decide upon and document the means by which the zbud variant is tagged
> 
> I'm not sure if there is going to be a way to tag zbud pages in particular
> without using a page flag.  However, if we can tag it as a non-slab allocated
> kernel page with no userspace mappings, that could be sufficient.  I think this
> can be done with:
> 
> !PageSlab(p) && page_count(p) > 0 && page_mapcount(p) <= 0
> 
> An alternative is to set PG_slab for zbud pages then we get all the same
> treatment as slab pages, which is basically what we want. Setting PG_slab
> also conveys that no assumption can be made about the contents of _mapcount.
> 
> However, a memmap-peeker could call slab functions on the page which obviously
> won't be under the control of the slab allocator. Afaict though, it doesn't
> seem that any of them do this since there aren't any functions in the slab
> allocator API that take raw struct pages.  The worst I've seen is calling
> shrink_slab in an effort to get the slab allocator to free up the page.

And does it error out properly on non-slab-pages-but-have-PG_slab set?
> 
> In summary, I think that maintaining a positive page->_count and setting
> PG_slab on zbud pages should provide safety against existing memmap-peekers.
> 
> Do you agree?

The page_>_count will thwart memmap-peeker from fiddling around right?

> 
> Seth
> 
> > 
> > - Demonstrate how this is safe against existing memmap-peekers
> > 
> > - Do all this without consuming another page flag :)
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
