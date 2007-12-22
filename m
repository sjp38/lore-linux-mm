Date: Sat, 22 Dec 2007 12:14:42 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] mm: fix PageUptodate memory ordering bug
In-Reply-To: <20071222005737.2675c33b.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0712221152370.7460@blonde.wat.veritas.com>
References: <20071218012632.GA23110@wotan.suse.de>
 <20071222005737.2675c33b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Sat, 22 Dec 2007, Andrew Morton wrote:
> On Tue, 18 Dec 2007 02:26:32 +0100 Nick Piggin <npiggin@suse.de> wrote:
> 
> > After running SetPageUptodate, preceeding stores to the page contents to
> > actually bring it uptodate may not be ordered with the store to set the page
> > uptodate.
> > 
> > Therefore, another CPU which checks PageUptodate is true, then reads the
> > page contents can get stale data.
> > 
> > Fix this by having an smp_wmb before SetPageUptodate, and smp_rmb after
> > PageUptodate.
> > 
> > Many places that test PageUptodate, do so with the page locked, and this
> > would be enough to ensure memory ordering in those places if SetPageUptodate
> > were only called while the page is locked. Unfortunately that is not always
> > the case for some filesystems, but it could be an idea for the future.
> > 
> > One thing I like about it is that it brings the handling of anonymous page
> > uptodateness in line with that of file backed page management, by marking anon
> > pages as uptodate when they _are_ uptodate, rather than when our implementation
> > requires that they be marked as such.

Nick, you're welcome to make that a separate, less controversial patch,
to send in ahead.  Though I think the last time this came around, I hit
one of your BUGs in testing shmem.c swapout or swapin or swapoff:
something missing there that I've lost the record of - please do
try testing that, maybe it's already fixed this time around.

> > Doing allows us to get rid of the
> > smp_wmb's in the page copying functions, which were especially added for
> > anonymous pages for an analogous memory ordering problem, and are now handled
> > with the same code as the PageUptodate memory ordering problem.
> > 
> > Introduce a SetNewPageUptodate for these anonymous pages: it contains non
> > atomic bitops so as not to introduce too much overhead into these paths.
> > 
> 
> hrm.
> 
> > +static inline void SetNewPageUptodate(struct page *page)
> > +{
> > +	smp_wmb();
> > +	__set_bit(PG_uptodate, &(page)->flags);
> 
> argh.  Put the pin back in that thing before you hurt someone.
> 
> Sigh.  I guess it's fairly clear but it could do with a big fat warning
> over it before you go and kill someone.
> 
> Because if this little hand grenade gets used in the wrong place, it will
> cause a horrid, horrid data-corrupting bug which might take us literally
> years to hunt down and fix.
> 
> >  #ifdef CONFIG_S390
> > +	page_clear_dirty(page);
> > +#endif
> > +}

That's an odd little extract, since page_clear_dirty only does anything
on s390.

> For an overall 0.5% increase in the i386 size of several core mm files.  If
> you don't blow us up on the spot, you'll slowly bleed us to death.
> 
> Can it be improved?

I do wish it could be.

I never find the time to give it the thought it needs; and any criticism
I make is probably unjust, probably patiently answered by Nick on a
previous round.

I'm never convinced that SetPageUptodate is the right place for
this: what's wrong with doing it in those page copying functions?
Or flush_dcache_page?  Don't we need different kinds of barrier
according to how the data got into the page (by DMA or not)?
Doesn't that enter territory discussed down the years between
James Bottomley and Russell King?  Worth CC'ing them the original?

Let me fall silent for a few days...

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
