Date: Wed, 15 Oct 2008 06:37:18 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: page allocator minor speedup
Message-ID: <20081015043718.GB24613@wotan.suse.de>
References: <20080818122428.GA9062@wotan.suse.de> <20080818122957.GE9062@wotan.suse.de> <Pine.LNX.4.64.0810141612170.17476@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0810141612170.17476@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Oct 14, 2008 at 04:52:03PM +0100, Hugh Dickins wrote:
> On Mon, 18 Aug 2008, Nick Piggin wrote:
> 
> > Now that we don't put a ZERO_PAGE in the pagetables any more, and the
> > "remove PageReserved from core mm" patch has had a long time to mature,
> > let's remove the page reserved logic from the allocator.
> > 
> > This saves several branches and about 100 bytes in some important paths.
> > 
> > Signed-off-by: Nick Piggin <npiggin@suse.de>
> 
> As usual, I'm ever so slightly on the slow side... sorry.
> I'm afraid I disagree with mm-page-allocator-minor-speedup.patch.

That's OK. I never really cared to rush things into merge. And
a thoughtful review is never too late IMO.
 

> I'm perfectly happy with bringing PG_reserved into "PAGE_FLAGS"
> and not special-casing it there.  My problem with your patch is
> that we ought to be retaining the several branches and 100 bytes
> of code, extending them to _every_ case of a "bad state" page.
> So that any such suspect page is taken out of circulation (needs
> count forced to 1, whatever it was before?), so the system can
> then proceed a little more safely.
 
Hmm. I don't entirely disagree. Although would that change logically
come after this one? Or is it annoying to have to re-add some of the
logic to drop pages?

One thing that I am slightly sad about is that mm/ fastpaths are
largely lumped with detecting this stuff. These days I'd say most
or all bugs seen in these checks are due to bad hardware or bugs
or memory scribbles probably from other parts of the kernel.

And the thing is, we only check maybe a couple of % of all memory
if we're just checking some page flags and ptes... why not take
a crc of the struct dentry on each modification, and recheck it
before subsequently using or modifying it? ;) How about radix tree
nodes? or any other data structure.


> That would go hand-in-hand with removing the page_remove_rmap()
> BUG() and reworking the info shown there.  I think it's fair to
> say that none of the "Eeek!" messaging added in the last couple
> of years has actually shed any light; but it's still worth having
> a special message there, because the "bad page state" ones are
> liable to follow too late, when most of the info has been lost.

No, only really helpful when developing mm or driver code I think
(which would suggest it should be DEBUG_VM, however I agree it could
be a bit more of a special case and enabled on production kernels
especially if the messages can be made more useful).


> As in one of the old debug patches I had, I'd like to print out
> the actual pte and _its_ physical address, info not currently to
> hand within page_remove_rmap() - they might sometimes correspond
> to that "BIOS corrupting low 64kB" issue, for example.  Shown in
> such a way that kerneloops.org is sure to report them.
> 
> As you can see, I've not quite got around to doing that yet...
> but mm-page-allocator-minor-speedup.patch takes us in the wrong
> direction.
> 
> I expect we're going to have our usual "Hugh wants to spot page
> table corruption" versus "Nick wants to cut overhead" fight!
> As we had over the pfn_valid in vm_normal_page - I think I lost
> that one, the HAVE_PTE_SPECIAL VM_BUG_ON neuters its usefulness.

Hmm... I don't mind so much, especially if you're planning other
improvements to the code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
