Date: Thu, 19 Jun 2008 12:39:49 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Can get_user_pages( ,write=1, force=1, ) result in a read-only
 pte and _count=2?
In-Reply-To: <200806191331.32056.nickpiggin@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0806191209370.7324@blonde.site>
References: <20080618164158.GC10062@sgi.com> <20080618203300.GA10123@sgi.com>
 <Pine.LNX.4.64.0806182209320.16252@blonde.site> <200806191331.32056.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Robin Holt <holt@sgi.com>, Ingo Molnar <mingo@elte.hu>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Jun 2008, Nick Piggin wrote:
> On Thursday 19 June 2008 07:46, Hugh Dickins wrote:
> 
> > contain COWs - I used to rail against it for that reason, but in the
> > end did an audit and couldn't find any place where that violation of
> > our assumptions actually mattered enough to get so excited.
> 
> Still, they're slightly troublesome, as our get_user_pages problems
> demonstrate :)

Indeed, but fighting Linus over them does get tiring.  (And now's
not the time for another fight, after Oleg's ZERO_PAGE discovery!)

> > -				if (ret & VM_FAULT_WRITE)
> > +				if ((ret & VM_FAULT_WRITE) &&
> > +				    !(vma->vm_flags & VM_WRITE))
> >  					foll_flags &= ~FOLL_WRITE;

> Hmm, doesn't this give the same problem for !VM_WRITE vmas? If you
> called get_user_pages again, isn't that going to cause another COW
> on the already-COWed page that we're hoping to write into?

Sure, if it fixes any issue at all (now very much in doubt),
it only fixes it for writing to VM_WRITE vmas; but that should
be the only case normal people are concerned with - and Robin's
userspace is trying to write to the page, so it better have VM_WRITE.

> (not sure
> about mprotect either, could that be used to make the vma writeable
> afterwards and then write to it?)

Er, yes, but I didn't get the point you were trying to make there.

> 
> I would rather (if my reading of the code is correct) make the
> trylock page into a full lock_page. The indeterminism of the trylock
> has always bugged me anyway... Shouldn't that cause a swap page not
> to get reCOWed if we have the only mapping to it?
> 
> If the lock_page cost bothers you, we could do a quick unlocked check
> on page_mapcount > 1 before taking the lock (which would also avoid
> the extra atomic ops and barriers in many cases where the page really
> is shared)

That indeterminism has certainly bothered me too.  There was another
interesting case which it interfered with, a year or two back.  I'll
have to search mboxes later to locate it.

We do have page table lock at that point, so it gets a bit tedious
(like the page_mkwrite case) to use lock_page there: more overhead
than just that of the lock_page.

I've had a quick look at my collection of uncompleted/unpublished
swap patches, and here's a hunk from one of them which is trying
to address that point.  But I'll have to look back and see what
else this depends upon.

-		if (!TestSetPageLocked(old_page)) {
-			reuse = can_share_swap_page(old_page);
-			unlock_page(old_page);
+		if (page_mapcount(old_page) == 1) {
+			extern int page_swapcount(struct page *);
+			if (!PageSwapCache(old_page))
+				reuse = 1;
+			else if (!TestSetPageLocked(old_page)) {
+				reuse = !page_is_shared(old_page);
+				unlock_page(old_page);
+			} else if (!page_swapcount(old_page))
+				reuse = 1;

I probably won't get back to this today.  And there are also good
reasons in -mm for me to check back on all these swapcount issues.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
