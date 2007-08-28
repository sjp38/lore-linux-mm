Date: Tue, 28 Aug 2007 14:54:19 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: RFC:  Noreclaim with "Keep Mlocked Pages off the LRU"
In-Reply-To: <1188312766.5079.77.camel@localhost>
Message-ID: <Pine.LNX.4.64.0708281448440.17464@schroedinger.engr.sgi.com>
References: <20070823041137.GH18788@wotan.suse.de>  <1187988218.5869.64.camel@localhost>
 <20070827013525.GA23894@wotan.suse.de>  <1188225247.5952.41.camel@localhost>
 <20070828000648.GB14109@wotan.suse.de> <1188312766.5079.77.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Nick Piggin <npiggin@suse.de>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 28 Aug 2007, Lee Schermerhorn wrote:

> I didn't think I was special casing mlocked pages.  I wanted to treat
> all !page_reclaimable() pages the same--i.e., put them on the noreclaim
> list.

I think that is the right approach. Do not forget that ramfs and other 
ram based filesystems create unmapped unreclaimable pages.

> Well, no.  Depending on the reason for !reclaimable, the page would go
> on the noreclaim list or just be dropped--special handling.  More
> importantly [for me], we still have to handle them specially in
> migration, dumping them back onto the LRU so that we can arbitrate
> access.  If I'm ever successful in getting automatic/lazy page migration
> +replication accepted, I don't want that overhead in
> auto-migration/replication.

Right. I posted a patch a week ago that generalized LRU handling and would 
allow the adding of additional lists as needed by such an approach.


> If we're willing to live with this [increased rmap scans on mlocked
> pages], we might be able to dispense with the mlock count altogether.
> Just a single flag [somewhere--doesn't need to be in page flags member]
> to indicate mlocked for page_reclaimable().  munmap()/munlock() could
> reset the bit and put the page back on the [in]active list.  If some
> other vma has it locked, we'll catch it on next attempt to unmap.

You need a page flag to indicate the fact that the page is on the 
unreclaimable list.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
