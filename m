Date: Fri, 22 Oct 2004 01:20:59 +0200
From: Andrea Arcangeli <andrea@novell.com>
Subject: Re: [PATCH] zap_pte_range should not mark non-uptodate pages dirty
Message-ID: <20041021232059.GE8756@dualathlon.random>
References: <1098393346.7157.112.camel@localhost> <20041021144531.22dd0d54.akpm@osdl.org> <20041021223613.GA8756@dualathlon.random> <20041021160233.68a84971.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041021160233.68a84971.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: shaggy@austin.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Oct 21, 2004 at 04:02:33PM -0700, Andrew Morton wrote:
> Andrea Arcangeli <andrea@novell.com> wrote:
> >
> > On Thu, Oct 21, 2004 at 02:45:31PM -0700, Andrew Morton wrote:
> > > Maybe we should revisit invalidate_inode_pages2().  It used to be an
> > > invariant that "pages which are mapped into process address space are
> > > always uptodate".  We broke that (good) invariant and we're now seeing
> > > some fallout.  There may be more.
> > 
> > such invariant doesn't exists since 2.4.10. There's no way to get mmaps
> > reload data from disk without breaking such an invariant.
> 
> There are at least two ways:
> 
> a) Set a new page flag in invalidate, test+clear that at fault time

What's the point of adding a new page flag when the invariant
!PageUptodate && page_mapcount(page) already provides the information?

I turned a condition that previously was impossible, and it made such
condition useful as another useful invariant, instead of a BUG_ON
invariant. The BUG itself guarantees us nobody was using it for other
purposes, infact invalidate_inode_pages2 is what triggered this in the
first place.

> b) shoot down all pte's mapping the locked page at invalidate time, mark the
>    page not uptodate.

invalidate should run fast, I didn't enforce coherency or it'd hurt too
much the O_DIRECT write if something is mapped, we only allow buffered
read against O_DIRECT write to work coherently, the mmap coherency has
never been provided to avoid having to search for vmas in the prio_tree
for every single write to an inode.

> The latter is complex but has the advantage of fixing the current
> half-assed situation wherein existing mmaps are seeing invalidated data.

that's a feature not a bug since 2.4.10. Nobody ever asked for such
coherency, all we provide is read against write or read against read
(write against write only with both writes O_DIRECT or both writes
buffered). mmaps are ignored by O_DIRECT, mmaps don't crash the kernel
(well modulo the PageReserved check added in 2.6) but that's all.

> We could just remove the BUG in mpage_writepage() (which I assume is the
> one which was being hit) but we might still have a not uptodate page with
> uptodate buffers and I suspect that the kernel will either go BUG there
> instead or will bring the page uptodate again without performing any I/O. 
> But I haven't checked that.

how can this be related to mmapped pages? Isn't this only an issue
with invalidate_inode_pages2? I agree we miss an invalidate of the bh
there. the mpage_readpage not using bh coupled with the page-size
alignment enforced by the 2.4 O_DIRECT API (not like 2.6 that uses
hardblocksize alignment) probably helps a lot in hiding this I guess.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
