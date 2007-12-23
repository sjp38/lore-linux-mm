Date: Sun, 23 Dec 2007 08:15:29 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: fix PageUptodate memory ordering bug
Message-ID: <20071223071529.GC29288@wotan.suse.de>
References: <20071218012632.GA23110@wotan.suse.de> <20071222005737.2675c33b.akpm@linux-foundation.org> <20071223055730.GA29288@wotan.suse.de> <20071222223234.7f0fbd8a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071222223234.7f0fbd8a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sat, Dec 22, 2007 at 10:32:34PM -0800, Andrew Morton wrote:
> On Sun, 23 Dec 2007 06:57:30 +0100 Nick Piggin <npiggin@suse.de> wrote:
> 
> > > > +static inline void SetNewPageUptodate(struct page *page)
> > > > +{
> > > > +	smp_wmb();
> > > > +	__set_bit(PG_uptodate, &(page)->flags);
> > > 
> > > argh.  Put the pin back in that thing before you hurt someone.
> > > 
> > > Sigh.  I guess it's fairly clear but it could do with a big fat warning
> > > over it before you go and kill someone.
> > 
> > Hmm, perhaps it should use the more conventional __SetPageUptodate. I had
> > named it SetNewPageUptodate in an earlier version of the ptach which was
> > slightly different.
> 
> It's a death trap.  __GFP_UPTODATE might be safer, dunno.

It's like natural selection for VM developers that don't know their page lifetime
rules ;)

GFP_UPTODATE can't be done, because we're not only talking about zeroed pages
here.


> > > For an overall 0.5% increase in the i386 size of several core mm files.  If
> > > you don't blow us up on the spot, you'll slowly bleed us to death.
> > > 
> > > Can it be improved?
> > 
> > At first glance you'd think that, loads being in order on i386, it should be
> > a noop, but we actually still require a barrier to be technically correct
> > (even on i386). Which increases the size of some otherwise unchanged files.
> > 
> > Adding a few SetNewPageUptodates adds the rest, I guess. The alternative would
> > be to have more open coded smp_wmb()s around. I like this way much better.
> 
> That's just speculation.  Please find out why such a small patch caused
> such a large code size increase and see if it can be fixed.

It's not actually increasing size by that much here... hmm, do you have
CONFIG_X86_PPRO_FENCE defined, by any chance?

It looks like this gets defined by default for i386, and also probably for
distro configs. Linus? This is a fairly heavy hammer for such an unlikely bug on
such a small number of systems (that admittedly doesn't even fix the bug in all
cases anyway). It's not only heavy for my proposed patch, but it also halves the
speed of spinlocks. Can we have some special config option for this instead? 


> > Given the amount of crap that's "pending", I'd be surprised if I was the one
> > who bleeds us to death with bugfixes ;)
> 
> Please consider spending some time reviewing other people's crap.

Fixing existing bugs is important too. Granted this doesn't seem to be a pressing
issue, but it's a bug. But I do review too.

 
> > But if you'd rather see some speedups,
> > I could certainly rustle something up.
> > 
> > Anyway, thanks for picking it up. That's already tripled the amount of feedback
> > it hsa got ;)
> 
> Rather than expecting others to review yours (not singling you out - you
> just had good timing).

By crap, I wasn't referring to bugfixes. But if you have any bugfixes in my area
in -mm that need review, I can take a look, sure. Actually I always try to read
mm/ bugfixes that go by, though I often don't have anything extra to say.


> I didn't actually include the patch in -mm due to Hugh's comments.

How about my counter-comments? :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
