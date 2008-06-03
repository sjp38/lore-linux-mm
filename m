From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH] Optimize page_remove_rmap for anon pages
Date: Tue, 3 Jun 2008 18:29:13 +1000
References: <1212069392.16984.25.camel@localhost> <200806030957.49069.nickpiggin@yahoo.com.au> <1212480363.7746.19.camel@localhost>
In-Reply-To: <1212480363.7746.19.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200806031829.14150.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: schwidefsky@de.ibm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tuesday 03 June 2008 18:06, Martin Schwidefsky wrote:
> On Tue, 2008-06-03 at 09:57 +1000, Nick Piggin wrote:
>
> First of all: thanks for looking into this. Games with the dirty bit are
> scary and any change needs careful consideration.
>
> > I don't know if it is that simple, is it?
>
> It should be analog to the fact that for the two place the page_zap_rmap
> function is supposed to be used the pte dirty bit isn't checked as well.

pte dirty bit is checked in zap_pte_range. In do_wp_page, the pte dirty
bit is not checked because it cannot have been dirtied via that mapping.
However, this may not necessarily be true in the s390 case where it might
be dirtied by _another_ mapping which has subsequently exited but not
propogated the physical dirty bit (I don't know, but I'm just wary about
it).


> > I don't know how you are guaranteeing the given page ceases to exist.
> > Even checking for the last mapper of the page (which you don't appear
> > to do anyway) isn't enough because there could be a swapcount, in which
> > case you should still have to mark the page as dirty.
> >
> > For example (I think, unless s390 somehow propogates the dirty page
> > bit some other way that I've missed), wouldn't the following break:
> >
> > process p1 allocates anonymous page A
> > p1 dirties A
> > p1 forks p2, A now has a mapcount of 2
> > p2 VM_LOCKs A (something to prevent it being swapped)
> > page reclaim unmaps p1's pte, fails on p2
> > p2 exits, page_dirty does not get checked because of this patch
> > page has mapcount 0, PG_dirty is clear
> > Page reclaim can drop it without writing it to swap
>
> Indeed, this would break. Even without the VM_LOCK there is a race of
> try_to_unmap vs. process exit.
>
> > As far as the general idea goes, it might be possible to avoid the
> > check somehow, but you'd want to be pretty sure of yourself before
> > diverging the s390 path further from the common code base, no?
>
> I don't want to diverge more than necessary. But the performance gains
> of the SSKE/ISKE avoidance makes it worthwhile for s390, no?

I guess it's worth exploring.


> > The "easy" way to do it might be just unconditionally mark the page
> > as dirty in this path (if the pte was writeable), so you can avoid
> > the page_test_dirty check and be sure of not missing the dirty bit.
>
> Hmm, but then an mprotect() can change the pte to read-ony and we'd miss
> the dirty bit again. Back to the drawing board.

Hmm, I guess you _could_ set_page_dirty in mprotect.


> By the way there is another SSKE I want to get rid of: __SetPageUptodate
> does a page_clear_dirty(). For all uses of __SetPageUptodate the page
> will be dirty after the application did its first write. To clear the
> page dirty bit only to have it set again shortly after doesn't make much
> sense to me. Has there been any particular reason for the
> page_clear_dirty in __SetPageUptodate ?

I guess it is just to match SetPageUptodate. Not all __SetPageUptodate
paths may necessarily dirty the page, FWIW.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
