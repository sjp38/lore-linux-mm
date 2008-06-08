Date: Sun, 8 Jun 2008 16:22:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm 13/25] Noreclaim LRU Infrastructure
Message-Id: <20080608162208.a2683a6c.akpm@linux-foundation.org>
In-Reply-To: <20080608173244.0ac4ad9b@bree.surriel.com>
References: <20080606202838.390050172@redhat.com>
	<20080606202859.291472052@redhat.com>
	<20080606180506.081f686a.akpm@linux-foundation.org>
	<20080608163413.08d46427@bree.surriel.com>
	<20080608135704.a4b0dbe1.akpm@linux-foundation.org>
	<20080608173244.0ac4ad9b@bree.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Sun, 8 Jun 2008 17:32:44 -0400 Rik van Riel <riel@redhat.com> wrote:

> On Sun, 8 Jun 2008 13:57:04 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > > > > From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
> > > 
> > > > > The noreclaim infrastructure is enabled by a new mm Kconfig option
> > > > > [CONFIG_]NORECLAIM_LRU.
> > > > 
> > > > Having a config option for this really sucks, and needs extra-special
> > > > justification, rather than none.
> > > 
> > > I believe the justification is that it uses a page flag.
> > > 
> > > PG_noreclaim would be the 20th page flag used, meaning there are
> > > 4 more free if 8 bits are used for zone and node info, which would
> > > give 6 bits for NODE_SHIFT or 64 NUMA nodes - probably overkill
> > > for 32 bit x86.

This feature isn't available on 32-bit cpus is it?

> > > If you want I'll get rid of CONFIG_NORECLAIM_LRU and make everything
> > > just compile in always.
> > 
> > Seems unlikely to be useful?  The only way in which this would be an
> > advantage if if we hae some other feature which also needs a page flag
> > but which will never be concurrently enabled with this one.

^^this?

> > > Please let me know what your preference is.
> > 
> > Don't use another page flag?
> 
> I don't see how that would work.  We need a way to identify
> the status of the page.

We'll run out one day.  Then we will have little choice but to increase
the size of the pageframe.

This is a direct downside of adding more lru lists.

The this-is-64-bit-only problem really sucks, IMO.  We still don't know
the reason for that decision.  Presumably it was because we've already
run out of page flags?  If so, the time for the larger pageframe is
upon us.

> > > > > +#ifdef CONFIG_NORECLAIM_LRU
> > > > > +	PG_noreclaim,		/* Page is "non-reclaimable"  */
> > > > > +#endif
> > > > 
> > > > I fear that we're messing up the terminology here.
> > > > 
> > > > Go into your 2.6.25 tree and do `grep -i reclaimable */*.c'.  The term
> > > > already means a few different things, but in the vmscan context,
> > > > "reclaimable" means that the page is unreferenced, clean and can be
> > > > stolen.  "reclaimable" also means a lot of other things, and we just
> > > > made that worse.
> > > > 
> > > > Can we think of a new term which uniquely describes this new concept
> > > > and use that, rather than flogging the old horse?
> > > 
> > > Want to reuse the BSD term "pinned" instead?
> > 
> > mm, "pinned" in Linuxland means "someone took a ref on it to prevent it
> > from being reclaimed".
> > 
> > As a starting point: what, in your english-language-paragraph-length
> > words, does this flag mean?
> 
> "Cannot be reclaimed because someone has it locked in memory
> through mlock, or the page belongs to something that cannot
> be evicted like ramfs."

Ray's "unevictable" sounds good.  It's not a term we've used elsewhere.

It's all a bit arbitrary, but it's just a label which maps onto a
concept and if we all honour that mapping carefully in our code and
writings, VM maintenance becomes that bit easier.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
