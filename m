Subject: Re: 0-order allocation problem
References: <Pine.LNX.4.33.0108151304340.2714-100000@penguin.transmeta.com>
	<20010816082419Z16176-1232+379@humbolt.nl.linux.org>
	<20010816112631.N398@redhat.com>
	<20010816121237Z16445-1231+1188@humbolt.nl.linux.org>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 16 Aug 2001 09:35:50 -0600
In-Reply-To: <20010816121237Z16445-1231+1188@humbolt.nl.linux.org>
Message-ID: <m1itfoow4p.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, Hugh Dickins <hugh@veritas.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Daniel Phillips <phillips@bonn-fries.net> writes:

> On August 16, 2001 12:26 pm, Stephen C. Tweedie wrote:
> > Hi,
> > 
> > On Thu, Aug 16, 2001 at 10:30:35AM +0200, Daniel Phillips wrote:
> > 
> > > because the use count is overloaded.  So how about adding a PG_pinned
> > > flag, and users need to set it for any page they intend to pin.
> > 
> > It needs to be a count, not a flag (consider multiple mlock() calls
> > from different processes, or multiple direct IO writeouts from the
> > same memory to disk.)  
> 
> Yes, the question is how to do this without adding a yet another field
> to struct page.

atomic_add(&page->count, 65536);  Basically you can add the high bits.  
But we only need the count seperate so that when a page becomes
demand freeable we can remove it from the global unfreeable page count.
But please let's not call a non-freeable page pinned.  We already use that
term for pages that are temporarily pinned for I/O.  And pinning in my mind
is not a permanent situation.

Actually except for mlock on a user space page we can use only a single bit,
so it might make more sense on the munlock case to walk the list of vma's
and see if the page is still mlocked somewhere else.

Something like:
if (test_bit(&page->flags, PG_Unfreeable)) {
        if (page->mapping && (page->mapping->i_mmap || page->mapping->i_mmap_shared)) {
                /* walk page->mapping->i_mmap & page->mapping->i_mmap->i_mmap_shared */
                /* if the page is no longer mlocked clear PG_Unfreeable */
	} else {
                clear_bit(&page->flags, PG_Unfreeable);
        }
	if (!test_bit(&page->flags, PG_Unfreeable)) {
		atomic_dec(&unfreeable_pages);
		/* Actually because of the limited range of the atomic
                 * types we probably need a spinlock...
		 */
        }       
}


kmalloc, the slab cache, and the inode cache are where we get most of
the pages that aren't freeable.  And since those cases don't mmap the
pages it shouldn't be too much overhead in the common cases.

Additionally if we do have a variant on free_page that only does the
tests for unlocking when we know we are freeing something from a
locked vma, we should be able to keep the overhead down quite nicely.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
