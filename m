From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: SLUB defrag pull request?
Date: Mon, 13 Oct 2008 23:54:30 +1100
References: <1223883004.31587.15.camel@penberg-laptop> <1223883164.31587.16.camel@penberg-laptop> <Pine.LNX.4.64.0810131227120.20511@blonde.site>
In-Reply-To: <Pine.LNX.4.64.0810131227120.20511@blonde.site>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200810132354.30789.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, cl@linux-foundation.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Monday 13 October 2008 22:42, Hugh Dickins wrote:
> On Mon, 13 Oct 2008, Pekka Enberg wrote:
> > On Mon, 2008-10-13 at 10:30 +0300, Pekka Enberg wrote:
> > > Hi Christoph,
> > >
> > > (I'm ccing Andrew and Hugh as well in case they want to chip in.)
>
> Thanks for the headsup: and I've taken the liberty of adding Nick too,
> it would be good to have his input.

Thanks. I get too easily bored with picking nits, and high level design
review is not very highly valued, but I'll throw in my 2c anyway since
I've been asked :) May as well cc some lists.

I think it's a pretty reasonable thing to do. I was always slightly
irritated by the design, maybe due to the topsy turvy issue... you
almost want the subsystems to be able to use the struct pages to
queue into their own LRU algorithms, and then queue the unreferenced
objects off those struct pages, turning it back around the right way.


> > > I'm planning to send a pull request of SLUB defrag today. Is there
> > > anything in particular you would like to be mentioned in the email to
> > > Linus?
>
> I do fear that it'll introduce some hard-to-track-down bugs, either
> in itself or in the subsystems it's defragging, because it's coming
> at them from a new angle (isn't it?).

In many cases, yes it seems to. And some of the approaches even if
they work now seem like they *might* cause problematic constraints
in the design... Have Al and Christoph reviewed the dentry and inode
patches?


> But I've no evidence for that, it's just my usual personal FUD, and
> I'm really rather impressed with how well it appears to be working.
> Just allow me to say "I told you so" when the first bug appears ;)

I've only looked closely at the buffer_head defrag part of the patch so
far, and it looks like there is a real problem there. The problem is that
pages are not always pinned until after buffer heads are freed. So it is
possible to "get" a page that has since been freed and reallocated for
something else. Boom? In the comments, I see assertions that "this is OK",
but not much analysis of what concurrency is possible and why it is safe.

A nasty, conceptual problem unfortunately that I'm worried about is that
now there is a lot more potential for concurrency from the moment the
data structure is allocated. Obviously this is why the ctor is needed,
but there are a lot of codepaths leading to allocations of these objects.
Have they all been audited for concurrency issues? For example, I see
there is buffer head defragmenting, and I see there is ext3 defragmenting,
but alloc_buffer_head calls from various filesystems don't seem to have
been touched. Presumably they have been looked at, but there is no
indication of why they are OK?

As a broad question, is such an additional concurrency constraint reasonable?

Another high level kind of issue is the efficiency of this thing. It can
take locks very frequently in some cases.


> May I repeat that question overlooked from when I sent my 1/3 fix?
> I'm wondering whether kick_buffers() ought to check PageLRU: I've no
> evidence it's needed, but coming to writepage() or try_to_free_buffers()
> from this direction (by virtue of having a buffer_head in a partial slab
> page) is new, and I worry it might cause some ordering problem; whereas
> if the page is PageLRU, then it is already fair game for such reclaim.

Hmm, I don't see an immediate problem there, but it could be an issue.
Have filesystem developers been made aware of the change and OKed it?


> I believe (not necessarily correctly!) that Andrew is tied up with the
> Linux Foundation's End User conference in NY today and tomorrow.  I'd
> be happier if you waited for his goahead before asking Linus to pull.
> As I recall, he was unhappy with Christoph adding such a feature to
> SLUB and not SLAB while it's still undecided which way we go.

The problem with this approach is that it relies on being able to lock
out access from freeing an object purely from the slab layer. SLAB
cannot do this because it has a per-cpu frontend queue that cannot be
blocked by another CPU. It would involve adding atomic operations in
the SLAB fastpath, or somehow IPIing all CPUs during defrag operations.

AFAIKS, all my concerns, including SLAB, would be addressed if we would
be able to instead group reclaimable objects into pages, and reclaim them
by managing lists of pages.


> I cannot remember where we stand in relation to the odd test where
> SLUB performs or performed worse.  I think it is true to say that the
> vast majority of developers would prefer to go forward with SLUB than
> SLAB.  There was a time when I was very perturbed by SLUB's reliance
> on higher order allocations, but have noticed nothing to protest
> about since it became less profligate and more adaptive.  And I do
> think it's a bit unfair to ask Christoph to enhance his competition!

SLAB unfortunately is still significantly faster than SLUB in some
important workloads. I am also a little worried about SLUB's higher
order allocations, but won't harp on about that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
