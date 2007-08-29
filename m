Subject: Re: RFC:  Noreclaim with "Keep Mlocked Pages off the LRU"
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0708281448440.17464@schroedinger.engr.sgi.com>
References: <20070823041137.GH18788@wotan.suse.de>
	 <1187988218.5869.64.camel@localhost> <20070827013525.GA23894@wotan.suse.de>
	 <1188225247.5952.41.camel@localhost> <20070828000648.GB14109@wotan.suse.de>
	 <1188312766.5079.77.camel@localhost>
	 <Pine.LNX.4.64.0708281448440.17464@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 29 Aug 2007 10:40:50 -0400
Message-Id: <1188398451.5121.9.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-08-28 at 14:54 -0700, Christoph Lameter wrote:
> On Tue, 28 Aug 2007, Lee Schermerhorn wrote:
> 
> > I didn't think I was special casing mlocked pages.  I wanted to treat
> > all !page_reclaimable() pages the same--i.e., put them on the noreclaim
> > list.
> 
> I think that is the right approach. Do not forget that ramfs and other 
> ram based filesystems create unmapped unreclaimable pages.

They don't go on the LRU lists now, do they?  The primary function of
the noreclaim infrastructure is to hide non-reclaimable pages that would
otherwise go on the [in]active lists from vmscan.  So, if pages used by
the ram base file systems don't go onto the LRU, we probably don't need
to put them on the noreclaim list which is conceptually another LRU
list.

That being said, the lumpy reclaim patch tries to reclaim pages that are
contiguous to other pages being reclaimed when trying to free higher
order pages.  I'll have to check to see if it tries to reclaim pages
that might be used by ram/tmp/... fs.

> 
> > Well, no.  Depending on the reason for !reclaimable, the page would go
> > on the noreclaim list or just be dropped--special handling.  More
> > importantly [for me], we still have to handle them specially in
> > migration, dumping them back onto the LRU so that we can arbitrate
> > access.  If I'm ever successful in getting automatic/lazy page migration
> > +replication accepted, I don't want that overhead in
> > auto-migration/replication.
> 
> Right. I posted a patch a week ago that generalized LRU handling and would 
> allow the adding of additional lists as needed by such an approach.

Which one was that? 

> 
> 
> > If we're willing to live with this [increased rmap scans on mlocked
> > pages], we might be able to dispense with the mlock count altogether.
> > Just a single flag [somewhere--doesn't need to be in page flags member]
> > to indicate mlocked for page_reclaimable().  munmap()/munlock() could
> > reset the bit and put the page back on the [in]active list.  If some
> > other vma has it locked, we'll catch it on next attempt to unmap.
> 
> You need a page flag to indicate the fact that the page is on the 
> unreclaimable list.

Yes, I have that now--PG_noreclaim.  In my prototype, I'm using a high
order bit unavailable to 32-bit archs, because all of the others are
used right now.  This is one of my unresolved issues.  PageNoreclaim()
is like, but mutually exclusive to, PageActive()--it tells us which LRU
list the page is on.

Thanks,
Lee



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
