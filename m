Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7D5A86B004D
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 06:36:04 -0400 (EDT)
Date: Mon, 29 Jun 2009 11:37:06 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: BUG: Bad page state [was: Strange oopses in 2.6.30]
Message-ID: <20090629103706.GA5065@csn.ul.ie>
References: <1245686553.7799.102.camel@lts-notebook> <20090622205308.GG3981@csn.ul.ie> <20090623200846.223C.A69D9226@jp.fujitsu.com> <20090629084114.GA28597@csn.ul.ie> <20090629101819.GA2052@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090629101819.GA2052@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Jiri Slaby <jirislaby@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 29, 2009 at 12:18:19PM +0200, Johannes Weiner wrote:
> On Mon, Jun 29, 2009 at 09:41:14AM +0100, Mel Gorman wrote:
> > I see the unconditionoal clearing of the flag was merged since but even
> > that might be too heavy handed as we are making a locked bit operation
> > on every page free. That's unfortunate overhead to incur on every page
> > free to handle a situation that should not be occurring at all.
> 
> Linus was probably quick to merge it as istr several people hitting
> bad_page() triggering.  We should get rid of the locked op, I was just
> not 100% sure and chose the safer version.
> 

And I have no problem with the decision. Leaving it as it was would have
caused a storm of bug reports, all similar.

> > > > +		WARN_ONCE(1, KERN_WARNING
> > > > +			"Sloppy page flags set process %s at pfn:%05lx\n"
> > > > +			"page:%p flags:%p\n",
> > > > +			current->comm, page_to_pfn(page),
> > > > +			page, (void *)page->flags);
> [...]
> > > > +		page->flags &= ~PAGE_FLAGS_WARN_AT_FREE;
> > > > +	}
> > > > +
> > > >  	if (unlikely(page_mapcount(page) |
> > > >  		(page->mapping != NULL)  |
> > > >  		(atomic_read(&page->_count) != 0) |
> > > 
> > > Howerver, I like this patch concept. this warning is useful and meaningful IMHO.
> > > 
> > 
> > This is a version that is based on top of current mainline that just
> > displays the warning. However, I think we should consider changing
> > TestClearPageMlocked() back to PageMlocked() and only clearing the flags
> > when the unusual condition is encountered.
> 
> I have a diff at home that makes this an unlocked
> __TestClearPageMlocked(), would you be okay with this?
> 

It'd be an improvement for sure. Post it and I'll take a look.

My preference is still to clear the flag only when found to be erroneously set
and print a warning once but that's because it was the patch I put together
so I'm biased :)

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
