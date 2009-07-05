Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CE89C6B005A
	for <linux-mm@kvack.org>; Sun,  5 Jul 2009 13:58:30 -0400 (EDT)
Date: Sun, 5 Jul 2009 21:02:00 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/5] add NR_ANON_PAGES to OOM log
Message-ID: <20090705130200.GA6585@localhost>
References: <20090705182533.0902.A69D9226@jp.fujitsu.com> <20090705121308.GC5252@localhost> <20090705211739.091D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090705211739.091D.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sun, Jul 05, 2009 at 08:21:20PM +0800, KOSAKI Motohiro wrote:
> > On Sun, Jul 05, 2009 at 05:26:18PM +0800, KOSAKI Motohiro wrote:
> > > Subject: [PATCH] add NR_ANON_PAGES to OOM log
> > > 
> > > show_free_areas can display NR_FILE_PAGES, but it can't display
> > > NR_ANON_PAGES.
> > > 
> > > this patch fix its inconsistency.
> > > 
> > > 
> > > Reported-by: Wu Fengguang <fengguang.wu@gmail.com>
> > > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > > ---
> > >  mm/page_alloc.c |    1 +
> > >  1 file changed, 1 insertion(+)
> > > 
> > > Index: b/mm/page_alloc.c
> > > ===================================================================
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -2216,6 +2216,7 @@ void show_free_areas(void)
> > >  		printk("= %lukB\n", K(total));
> > >  	}
> > >  
> > > +	printk("%ld total anon pages\n", global_page_state(NR_ANON_PAGES));
> > >  	printk("%ld total pagecache pages\n", global_page_state(NR_FILE_PAGES));
> > 
> > Can we put related items together, ie. this looks more friendly:
> > 
> >         Anon:XXX active_anon:XXX inactive_anon:XXX
> >         File:XXX active_file:XXX inactive_file:XXX
> 
> hmmm. Actually NR_ACTIVE_ANON + NR_INACTIVE_ANON != NR_ANON_PAGES.
> tmpfs pages are accounted as FILE, but it is stay in anon lru.

Right, that's exactly the reason I propose to put them together: to
make the number of tmpfs pages obvious.

> I think your proposed format easily makes confusion. this format cause to
> imazine Anon = active_anon + inactive_anon.

Yes it may confuse normal users :(

> At least, we need to use another name, I think.

Hmm I find it hard to work out a good name.

But instead, it may be a good idea to explicitly compute the tmpfs
pages, because the excessive use of tmpfs pages could be a common
reason of OOM.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
