Date: Tue, 18 Mar 2008 09:45:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 3/8] mm: rotate_reclaimable_page() cleanup
Message-Id: <20080318094541.7f19bfe4.akpm@linux-foundation.org>
In-Reply-To: <E1JbaQk-0005iw-67@pomaz-ex.szeredi.hu>
References: <20080317191908.123631326@szeredi.hu>
	<20080317191944.208962764@szeredi.hu>
	<1205839896.8514.344.camel@twins>
	<E1JbaQk-0005iw-67@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: peterz@infradead.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 Mar 2008 12:56:34 +0100 Miklos Szeredi <miklos@szeredi.hu> wrote:

> > > -int rotate_reclaimable_page(struct page *page)
> > > +void  rotate_reclaimable_page(struct page *page)
> > >  {
> > > -	struct pagevec *pvec;
> > > -	unsigned long flags;
> > > -
> > > -	if (PageLocked(page))
> > > -		return 1;
> > > -	if (PageDirty(page))
> > > -		return 1;
> > > -	if (PageActive(page))
> > > -		return 1;
> > > -	if (!PageLRU(page))
> > > -		return 1;
> > 
> > Might be me, but I find the above easier to read than

Me too, but (believe it or not) sometimes I will eschew comment ;)

> > > +	if (!PageLocked(page) && !PageDirty(page) && !PageActive(page) &&
> > > +	    PageLRU(page)) {
> > >  
> 
> Matter of taste, returning from a middle of a function is generally to
> be avoided (unless not).

Avoiding multiple returns is more than a matter of taste: the practice is a
source of code bloat, resource leaks and locking errors.

But we do do it quite commonly at the start of the function when checking the
arguments, before the function has actually altered anything.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
