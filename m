Date: Sat, 22 Dec 2007 22:32:34 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm: fix PageUptodate memory ordering bug
Message-Id: <20071222223234.7f0fbd8a.akpm@linux-foundation.org>
In-Reply-To: <20071223055730.GA29288@wotan.suse.de>
References: <20071218012632.GA23110@wotan.suse.de>
	<20071222005737.2675c33b.akpm@linux-foundation.org>
	<20071223055730.GA29288@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Sun, 23 Dec 2007 06:57:30 +0100 Nick Piggin <npiggin@suse.de> wrote:

> > > +static inline void SetNewPageUptodate(struct page *page)
> > > +{
> > > +	smp_wmb();
> > > +	__set_bit(PG_uptodate, &(page)->flags);
> > 
> > argh.  Put the pin back in that thing before you hurt someone.
> > 
> > Sigh.  I guess it's fairly clear but it could do with a big fat warning
> > over it before you go and kill someone.
> 
> Hmm, perhaps it should use the more conventional __SetPageUptodate. I had
> named it SetNewPageUptodate in an earlier version of the ptach which was
> slightly different.

It's a death trap.  __GFP_UPTODATE might be safer, dunno.

> ...
>
> > For an overall 0.5% increase in the i386 size of several core mm files.  If
> > you don't blow us up on the spot, you'll slowly bleed us to death.
> > 
> > Can it be improved?
> 
> At first glance you'd think that, loads being in order on i386, it should be
> a noop, but we actually still require a barrier to be technically correct
> (even on i386). Which increases the size of some otherwise unchanged files.
> 
> Adding a few SetNewPageUptodates adds the rest, I guess. The alternative would
> be to have more open coded smp_wmb()s around. I like this way much better.

That's just speculation.  Please find out why such a small patch caused
such a large code size increase and see if it can be fixed.

> Given the amount of crap that's "pending", I'd be surprised if I was the one
> who bleeds us to death with bugfixes ;)

Please consider spending some time reviewing other people's crap.

> But if you'd rather see some speedups,
> I could certainly rustle something up.
> 
> Anyway, thanks for picking it up. That's already tripled the amount of feedback
> it hsa got ;)

Rather than expecting others to review yours (not singling you out - you
just had good timing).

I didn't actually include the patch in -mm due to Hugh's comments.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
