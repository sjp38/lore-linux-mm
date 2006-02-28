Date: Tue, 28 Feb 2006 12:13:27 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: vDSO vs. mm : problems with ppc vdso
In-Reply-To: <20060227224739.70ecfd08.akpm@osdl.org>
Message-ID: <Pine.LNX.4.61.0602281150520.6712@goblin.wat.veritas.com>
References: <1141105154.3767.27.camel@localhost.localdomain>
 <20060227215416.2bfc1e18.akpm@osdl.org> <1141106896.3767.34.camel@localhost.localdomain>
 <20060227222055.4d877f16.akpm@osdl.org> <1141108220.3767.43.camel@localhost.localdomain>
 <20060227224739.70ecfd08.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linux-mm@kvack.org, paulus@samba.org, nickpiggin@yahoo.com.au, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

On Mon, 27 Feb 2006, Andrew Morton wrote:
> Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
> >
> > > > I'll send the patch as a reply to this message.
> >  > 
> >  > Please copy linux-arch.
> > 
> >  Did that.
> 
> You did not, you meanie.

I couldn't see linux-arch in there either.  I won't comment on the patch
as there are others with a _much_ better grasp of the 32-on-64 issues.
But yes, something like that is long overdue, it's been a recurrent
hassle not to have any indication in the mm.

> >  > > pages in could be a problem ?
> >  > 
> >  > It sounds just like a sound card DMA buffer to me - that's a solved
> >  > problem?  (Well, we keep unsolving it, but it's a relatively common
> >  > pattern).
> > 
> >  Might be ... though I though the later had VM_RESERVED or some similar
> >  thing ... the trick with that vma is that i don't want any of these
> >  things to allow for COW ... But yeah, it _looks_ like it will just work
> >  (well... it appears to work so far anyway....)
> 
> Hugh's the man - he loves that stuff.

And here I am, limping along behind - wild applause as I enter the ring!

Ben, I agree completely with Andrew, you should be just fine with that
vma.  I've noticed it in the past when checking users of insert_vm_struct,
and saw no problem with it.  Andi copied that code to use in x86_64 a few
months back; and Fedora have something similar on i386 (though they use
install_page rather than nopage, and so have to patch install_page to
cope with !vma->vm_file).

Pages with NULL page->mapping pass through page_add_file_rmap and
page_remove_rmap without causing any stir, and nobody puts them on
the LRU anyway, and (in your case - one day we might worry more about
sound's case) you've only got one lot of these pages so we're not in
the least interested in freeing them under memory pressure.  It is a
surprising case, but plenty of other examples of it: sleep soundly.

(But I didn't understand your comment "i don't want any of these things
to allow for COW" - I thought that was just what you are allowing for.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
