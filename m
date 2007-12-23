Date: Sun, 23 Dec 2007 07:54:46 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: fix PageUptodate memory ordering bug
Message-ID: <20071223065446.GB29288@wotan.suse.de>
References: <20071218012632.GA23110@wotan.suse.de> <20071222005737.2675c33b.akpm@linux-foundation.org> <Pine.LNX.4.64.0712221152370.7460@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0712221152370.7460@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-arch@vger.kernel.org, rmk@arm.linux.org.uk, James.Bottomley@HansenPartnership.com
List-ID: <linux-mm.kvack.org>

On Sat, Dec 22, 2007 at 12:14:42PM +0000, Hugh Dickins wrote:
> On Sat, 22 Dec 2007, Andrew Morton wrote:
> > On Tue, 18 Dec 2007 02:26:32 +0100 Nick Piggin <npiggin@suse.de> wrote:
> > 
> > > After running SetPageUptodate, preceeding stores to the page contents to
> > > actually bring it uptodate may not be ordered with the store to set the page
> > > uptodate.
> > > 
> > > Therefore, another CPU which checks PageUptodate is true, then reads the
> > > page contents can get stale data.
> > > 
> > > Fix this by having an smp_wmb before SetPageUptodate, and smp_rmb after
> > > PageUptodate.
> > > 
> > > Many places that test PageUptodate, do so with the page locked, and this
> > > would be enough to ensure memory ordering in those places if SetPageUptodate
> > > were only called while the page is locked. Unfortunately that is not always
> > > the case for some filesystems, but it could be an idea for the future.
> > > 
> > > One thing I like about it is that it brings the handling of anonymous page
> > > uptodateness in line with that of file backed page management, by marking anon
> > > pages as uptodate when they _are_ uptodate, rather than when our implementation
> > > requires that they be marked as such.
> 
> Nick, you're welcome to make that a separate, less controversial patch,
> to send in ahead.  Though I think the last time this came around, I hit
> one of your BUGs in testing shmem.c swapout or swapin or swapoff:
> something missing there that I've lost the record of - please do
> try testing that, maybe it's already fixed this time around.

I've given it some hours in your patented swapping kbuild-on-ext2-on-loop-on-tmpfs
stress testing (including swapoff). Haven't seen a problem as yet (except the tmpfs
swapin deadlock, which I've been patching out).

But if you see anything, please let me know...


> > >  #ifdef CONFIG_S390
> > > +	page_clear_dirty(page);
> > > +#endif
> > > +}
> 
> That's an odd little extract, since page_clear_dirty only does anything
> on s390.

Ah yeah, we could just get rid of the ifdef. Although I don't mind it too much,
as it kind of helps the reader match the other ifdef there...

 
> > For an overall 0.5% increase in the i386 size of several core mm files.  If
> > you don't blow us up on the spot, you'll slowly bleed us to death.
> > 
> > Can it be improved?
> 
> I do wish it could be.
> 
> I never find the time to give it the thought it needs; and any criticism
> I make is probably unjust, probably patiently answered by Nick on a
> previous round.
> 
> I'm never convinced that SetPageUptodate is the right place for
> this: what's wrong with doing it in those page copying functions?
> Or flush_dcache_page?

There are various places we _could_ do it, but I think PG_uptodate macros
are logically the best, without being too intrusive.

Let me explain. Normally I think the convention would be to open-code the
barriers in the callees (ie. between memset(); SetPageUptodate();, and
if (PageUptodate()) { read from page }).

However I think that would require going through quite a bit of code (including
filesystems) to audit. So I think having them in these macros is pretty
reasonable, and amounts to less thinking required by others.

Why don't I like doing it in page copying functions? Just because there are more
and more varied uses. I can't think of any reasons to rather do it in the page
copying functions, and some reasons against.

flush_dcache_page? Well this bug really is a problem ordering stores to the
page with store to page flags against loads from the same; nothing to do with
cache aliasing. So putting the smp_wmb in flush_dcache_page leaves you without
a natural complement to put the smp_rmb. Although it could be done, I think it
makes it more tangled than having the ordering done in the macros.  We also
only need to order the *initial* stores which bring the page uptodate, rather
than for each store, in the case of flush_dcache_page.


>  Don't we need different kinds of barrier
> according to how the data got into the page (by DMA or not)?

I had thought of that (my previous patch had an XXX: help...) for this
very issue. Without actually knowing what the underlying architecture does,
I "concluded" that it should be done somewhere down at the block layer. I
think it would be silly for the block layer to signal completion if the
results are still incoherent with the CPU cache... but if the experts have
a different opinion, then this needs to be solved with another call anyway
(not in the page uptodate macros and it's not exactly a memory ordering issue).
eg. direct IO reads would have the same DMA cache synchronisation before it
completes to userspace, and this is completely independent of PG_uptodate...

> Doesn't that enter territory discussed down the years between
> James Bottomley and Russell King?  Worth CC'ing them the original?

... but since you bring this up again, I think that would be worthwhile. In
the interest of maintaining this thread I'll just link the original:

http://marc.info/?l=linux-mm&m=119794127303483&w=2

The question is this:

Must read from net/disk/etc into page P.
Device DMAs into P, signals completion

CPU0: handles completion, store to ram to mark P uptodate

CPU0/1: load from ram sees P uptodate, load from P must only see uptodate data

Are we guaranteed to get uptodate data from above the block layer, or do we
need to do anything special?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
