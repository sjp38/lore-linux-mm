Date: Tue, 6 May 2008 11:51:38 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 2/2] fix SMP data race in pagetable setup vs walking
Message-ID: <20080506095138.GE10141@wotan.suse.de>
References: <20080505112021.GC5018@wotan.suse.de> <20080505121240.GD5018@wotan.suse.de> <alpine.LFD.1.10.0805050828120.32269@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.10.0805050828120.32269@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, linux-arch@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Paul McKenney <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, May 05, 2008 at 08:32:30AM -0700, Linus Torvalds wrote:
> 
> 
> On Mon, 5 May 2008, Nick Piggin wrote:
> > 
> > Index: linux-2.6/include/asm-x86/pgtable_32.h
> > ===================================================================
> > --- linux-2.6.orig/include/asm-x86/pgtable_32.h
> > +++ linux-2.6/include/asm-x86/pgtable_32.h
> > @@ -133,7 +133,12 @@ extern int pmd_bad(pmd_t pmd);
> >   * pgd_offset() returns a (pgd_t *)
> >   * pgd_index() is used get the offset into the pgd page's array of pgd_t's;
> >   */
> > -#define pgd_offset(mm, address) ((mm)->pgd + pgd_index((address)))
> > +#define pgd_offset(mm, address)						\
> > +({									\
> > +	pgd_t *ret = ((mm)->pgd + pgd_index((address)));		\
> > +	smp_read_barrier_depends(); /* see mm/memory.c:__pte_alloc */	\
> > +	ret;								\
> > +})
> 
> Is there some fundamental reason this needs to be a macro?
> 
> It is really ugly, and it would be much nicer to make this an inline 
> function if at all possible.
> 
> Yeah, maybe it requires some more #include's, but ..
> 
> (Especially since it apparently gets worse, and the pgd load needs a 
> ACCESS_ONCE() too - the code generated is the same, but the source gets 
> more and more involved)

Hmm, I remember trying this a while back (though not for this exact
patch) and running into depend issues. Seems like Hugh does as well.
And include dependency problems are not trivial to test for so I didn't
want to introduce bugs with the fix.

 
> That said, I *also* think that it's sad that you do this at all, since 
> smp_read_barrier_depends() is a no-op on x86, so why should we have it in 
> an x86-specific header file?
> 
> In short, I think the fixes are real, but the patch itself is really just 
> confusing things for no apparent good reason.

Right. As the comment says, the x86 stuff is kind of a "reference"
implementation, although if you prefer it isn't there, then I I can
easily just make it alpha only.

The x86 code (and all other archs) would I guess still need the ACCESS_ONCE
modifications. If we agree that this pointer reloading issue is one that
must be handled in our C code.. I don't know if I really like that idea.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
