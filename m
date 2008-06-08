Date: Sun, 8 Jun 2008 16:34:13 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH -mm 13/25] Noreclaim LRU Infrastructure
Message-ID: <20080608163413.08d46427@bree.surriel.com>
In-Reply-To: <20080606180506.081f686a.akpm@linux-foundation.org>
References: <20080606202838.390050172@redhat.com>
	<20080606202859.291472052@redhat.com>
	<20080606180506.081f686a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, 6 Jun 2008 18:05:06 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:
> On Fri, 06 Jun 2008 16:28:51 -0400
> Rik van Riel <riel@redhat.com> wrote:
> 
> > 
> > From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>

> > The noreclaim infrastructure is enabled by a new mm Kconfig option
> > [CONFIG_]NORECLAIM_LRU.
> 
> Having a config option for this really sucks, and needs extra-special
> justification, rather than none.

I believe the justification is that it uses a page flag.

PG_noreclaim would be the 20th page flag used, meaning there are
4 more free if 8 bits are used for zone and node info, which would
give 6 bits for NODE_SHIFT or 64 NUMA nodes - probably overkill
for 32 bit x86.

If you want I'll get rid of CONFIG_NORECLAIM_LRU and make everything
just compile in always.

Please let me know what your preference is.
 
> > --- linux-2.6.26-rc2-mm1.orig/include/linux/page-flags.h	2008-05-29 16:21:04.000000000 -0400
> > +++ linux-2.6.26-rc2-mm1/include/linux/page-flags.h	2008-06-06 16:05:15.000000000 -0400
> > @@ -94,6 +94,9 @@ enum pageflags {
> >  	PG_reclaim,		/* To be reclaimed asap */
> >  	PG_buddy,		/* Page is free, on buddy lists */
> >  	PG_swapbacked,		/* Page is backed by RAM/swap */
> > +#ifdef CONFIG_NORECLAIM_LRU
> > +	PG_noreclaim,		/* Page is "non-reclaimable"  */
> > +#endif
> 
> I fear that we're messing up the terminology here.
> 
> Go into your 2.6.25 tree and do `grep -i reclaimable */*.c'.  The term
> already means a few different things, but in the vmscan context,
> "reclaimable" means that the page is unreferenced, clean and can be
> stolen.  "reclaimable" also means a lot of other things, and we just
> made that worse.
> 
> Can we think of a new term which uniquely describes this new concept
> and use that, rather than flogging the old horse?

Want to reuse the BSD term "pinned" instead?

> > +/**
> > + * add_page_to_noreclaim_list
> > + * @page:  the page to be added to the noreclaim list
> > + *
> > + * Add page directly to its zone's noreclaim list.  To avoid races with
> > + * tasks that might be making the page reclaimble while it's not on the
> > + * lru, we want to add the page while it's locked or otherwise "invisible"
> > + * to other tasks.  This is difficult to do when using the pagevec cache,
> > + * so bypass that.
> > + */
> 
> How does a task "make a page reclaimable"?  munlock()?  fsync()? 
> exit()?
> 
> Choice of terminology matters...

Lee?  Kosaki-san?
 

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
