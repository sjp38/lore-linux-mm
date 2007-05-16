Date: Wed, 16 May 2007 12:47:54 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [rfc] optimise unlock_page
In-Reply-To: <Pine.LNX.4.64.0705161946170.28185@blonde.wat.veritas.com>
Message-ID: <alpine.LFD.0.98.0705161242520.3890@woody.linux-foundation.org>
References: <20070508225012.GF20174@wotan.suse.de>
 <Pine.LNX.4.64.0705091950080.2909@blonde.wat.veritas.com>
 <20070510033736.GA19196@wotan.suse.de> <Pine.LNX.4.64.0705101935590.18496@blonde.wat.veritas.com>
 <20070511085424.GA15352@wotan.suse.de> <Pine.LNX.4.64.0705111357120.3350@blonde.wat.veritas.com>
 <20070513033210.GA3667@wotan.suse.de> <Pine.LNX.4.64.0705130535410.3015@blonde.wat.veritas.com>
 <20070513065246.GA15071@wotan.suse.de> <Pine.LNX.4.64.0705161838080.16762@blonde.wat.veritas.com>
 <20070516181847.GD5883@wotan.suse.de>
 <Pine.LNX.4.64.0705161946170.28185@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <npiggin@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-arch@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Wed, 16 May 2007, Hugh Dickins wrote:

> On Wed, 16 May 2007, Nick Piggin wrote:
> > On Wed, May 16, 2007 at 06:54:15PM +0100, Hugh Dickins wrote:
> > > On Sun, 13 May 2007, Nick Piggin wrote:
> > > > 
> > > > Well I think so, but not completely sure.
> > > 
> > > That's not quite enough to convince me!
> > 
> > I did ask Linus, and he was very sure it works.
> 
> Good, that's very encouraging.

Note that our default spinlocks _depend_ on a bog-standard store just 
working as an unlock, so this wouldn't even be anything half-way new:

	static inline void __raw_spin_unlock(raw_spinlock_t *lock)
	{
		asm volatile("movb $1,%0" : "+m" (lock->slock) :: "memory");
	}

There are some Opteron errata (and a really old P6 bug) wrt this, but they 
are definitely CPU bugs, and we haven't really worked out what the Opteron 
solution should be (the bug is apparently pretty close to impossible to 
trigger in practice, so it's not been a high priority).

> > The other option of moving the bit into ->mapping hopefully avoids all
> > the issues, and would probably be a little faster again on the P4, at the
> > expense of being a more intrusive (but it doesn't look too bad, at first
> > glance)...
> 
> Hmm, I'm so happy with PG_swapcache in there, that I'm reluctant to
> cede it to your PG_locked, though I can't deny your use should take
> precedence.  Perhaps we could enforce 8-byte alignment of struct
> address_space and struct anon_vma to make both bits available
> (along with the anon bit).

We probably could. It should be easy enough to mark "struct address_space" 
to be 8-byte aligned.

> But I think you may not be appreciating how intrusive PG_locked
> will be.  There are many references to page->mapping (often ->host)
> throughout fs/ : when we keep anon/swap flags in page->mapping, we
> know the filesystems will never see those bits set in their pages,
> so no page_mapping-like conversion is needed; just a few places in
> common code need to adapt.

You're right, it could be really painful. We'd have to rename the field, 
and use some inline function to access it (which masks off the low bits).

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
