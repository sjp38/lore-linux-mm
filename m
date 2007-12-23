Date: Sun, 23 Dec 2007 06:57:30 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: fix PageUptodate memory ordering bug
Message-ID: <20071223055730.GA29288@wotan.suse.de>
References: <20071218012632.GA23110@wotan.suse.de> <20071222005737.2675c33b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071222005737.2675c33b.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Sat, Dec 22, 2007 at 12:57:37AM -0800, Andrew Morton wrote:
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
> > requires that they be marked as such. Doing allows us to get rid of the
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

Hmm, perhaps it should use the more conventional __SetPageUptodate. I had
named it SetNewPageUptodate in an earlier version of the ptach which was
slightly different.

 
> Because if this little hand grenade gets used in the wrong place, it will
> cause a horrid, horrid data-corrupting bug which might take us literally
> years to hunt down and fix.

Yeah, like the other non-atomic bitops. I guess we just have to make sure
they're used correctly... they really make a big difference to performance.

I guess the memory ordering bug would take years to hunt down and fix too,
OTOH I guess it would probably be the powerpc guys, rather than you or I,
that have to debug it ;)


> >  #ifdef CONFIG_S390
> 
> > +	page_clear_dirty(page);
> > +#endif
> > +}
> 
> 
> For an overall 0.5% increase in the i386 size of several core mm files.  If
> you don't blow us up on the spot, you'll slowly bleed us to death.
> 
> Can it be improved?

At first glance you'd think that, loads being in order on i386, it should be
a noop, but we actually still require a barrier to be technically correct
(even on i386). Which increases the size of some otherwise unchanged files.

Adding a few SetNewPageUptodates adds the rest, I guess. The alternative would
be to have more open coded smp_wmb()s around. I like this way much better.

Given the amount of crap that's "pending", I'd be surprised if I was the one
who bleeds us to death with bugfixes ;) But if you'd rather see some speedups,
I could certainly rustle something up.

Anyway, thanks for picking it up. That's already tripled the amount of feedback
it hsa got ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
