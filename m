Date: Fri, 20 Apr 2007 15:06:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] lazy freeing of memory through MADV_FREE
Message-Id: <20070420150618.179d31a4.akpm@linux-foundation.org>
In-Reply-To: <462932BE.4020005@redhat.com>
References: <46247427.6000902@redhat.com>
	<20070420135715.f6e8e091.akpm@linux-foundation.org>
	<462932BE.4020005@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 20 Apr 2007 17:38:06 -0400
Rik van Riel <riel@redhat.com> wrote:

> Andrew Morton wrote:
> 
> > I've also merged Nick's "mm: madvise avoid exclusive mmap_sem".
> > 
> > - Nick's patch also will help this problem.  It could be that your patch
> >   no longer offers a 2x speedup when combined with Nick's patch.
> > 
> >   It could well be that the combination of the two is even better, but it
> >   would be nice to firm that up a bit.  
> 
> I'll test that.

Thanks.

> >   I do go on about that.  But we're adding page flags at about one per
> >   year, and when we run out we're screwed - we'll need to grow the
> >   pageframe.
> 
> If you want, I can take a look at folding this into the
> ->mapping pointer.  I can guarantee you it won't be
> pretty, though :)

Well, let's see how fugly it ends up looking?

> > - I need to update your patch for Nick's patch.  Please confirm that
> >   down_read(mmap_sem) is sufficient for MADV_FREE.
> 
> It is.  MADV_FREE needs no more protection than MADV_DONTNEED.
> 
> > Stylistic nit:
> > 
> >> +	if (PageLazyFree(page) && !migration) {
> >> +		/* There is new data in the page.  Reinstate it. */
> >> +		if (unlikely(pte_dirty(pteval))) {
> >> +			set_pte_at(mm, address, pte, pteval);
> >> +			ret = SWAP_FAIL;
> >> +			goto out_unmap;
> >> +		}
> > 
> > The comment should be inside the second `if' statement.  As it is, It
> > looks like we reinstate the page if (PageLazyFree(page) && !migration).
> 
> Want me to move it?

I did that, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
