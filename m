Date: Sun, 18 Jun 2006 12:11:43 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] rfc: fix splice mapping race?
Message-ID: <20060618101143.GE14452@wotan.suse.de>
References: <20060618094157.GD14452@wotan.suse.de> <1150624965.28517.55.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1150624965.28517.55.camel@lappy>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@engr.sgi.com>, Jens Axboe <axboe@suse.de>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, Jun 18, 2006 at 12:02:45PM +0200, Peter Zijlstra wrote:
> > In page migration, detect the missing mapping early and bail out if
> > that is the case: the page is not going to get un-truncated, so
> > retrying is just a waste of time.
> > 
> > Signed-off-by: Nick Piggin <npiggin@suse.de>
> 
> Looks sane, except the change in migrate (comment there). I like the
> remove_mapping() pre-conditions.

Thanks.

> > --- linux-2.6.orig/mm/migrate.c
> > +++ linux-2.6/mm/migrate.c
> > @@ -136,9 +136,13 @@ static int swap_page(struct page *page)
> >  {
> >  	struct address_space *mapping = page_mapping(page);
> >  
> > -	if (page_mapped(page) && mapping)
> > +	if (!mapping)
> > +		return -EINVAL; /* page truncated. signal permanent failure */
> 
> Here, I think you need to unlock the page too.

Bah, yes thanks... I'll post an updated patch after others have
had time to comment.

Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
