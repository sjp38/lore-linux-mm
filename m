Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C8FFC6B004F
	for <linux-mm@kvack.org>; Sun,  5 Jul 2009 14:07:18 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n65BV4sR004398
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 5 Jul 2009 20:31:04 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C196245DE51
	for <linux-mm@kvack.org>; Sun,  5 Jul 2009 20:31:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8CC5545DE4E
	for <linux-mm@kvack.org>; Sun,  5 Jul 2009 20:31:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5AFEB1DB8041
	for <linux-mm@kvack.org>; Sun,  5 Jul 2009 20:31:03 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0284C1DB803F
	for <linux-mm@kvack.org>; Sun,  5 Jul 2009 20:31:03 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/5] add buffer cache information to show_free_areas()
In-Reply-To: <20090705112159.GB1898@localhost>
References: <20090705182337.08F9.A69D9226@jp.fujitsu.com> <20090705112159.GB1898@localhost>
Message-Id: <20090705202503.0914.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sun,  5 Jul 2009 20:31:02 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> On Sun, Jul 05, 2009 at 05:24:07PM +0800, KOSAKI Motohiro wrote:
> > Subject: [PATCH] add buffer cache information to show_free_areas()
> > 
> > When administrator analysis memory shortage reason from OOM log, They
> > often need to know rest number of cache like pages.
> 
> nr_blockdev_pages() pages are also accounted in NR_FILE_PAGES.

Yes, I know.

> > Then, show_free_areas() shouldn't only display page cache, but also it
> > should display buffer cache.
> 
> So if we are to add this, I'd suggest to put it close to the total
> pagecache line:
> 
>         printk("%ld total pagecache pages\n", global_page_state(NR_FILE_PAGES));
> +       printk("%ld blkdev pagecache pages\n", nr_blockdev_pages());

but this is intensional. May I explain why I choose non verbose area?
In typical workload, buffer-pages doesn't consume so many pages. then
I feel that your idea is too verbose output. In addition, if buffer-pages are much,
Administrator want to know other I/O related vmstat at the same time.

Then, I choose current position.


Thanks.



> 
> Thanks,
> Fengguang
> 
> > 
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > ---
> >  mm/page_alloc.c |    3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> > Index: b/mm/page_alloc.c
> > ===================================================================
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2118,7 +2118,7 @@ void show_free_areas(void)
> >  	printk("Active_anon:%lu active_file:%lu inactive_anon:%lu\n"
> >  		" inactive_file:%lu"
> >  		" unevictable:%lu"
> > -		" dirty:%lu writeback:%lu unstable:%lu\n"
> > +		" dirty:%lu writeback:%lu buffer:%lu unstable:%lu\n"
> >  		" free:%lu slab_reclaimable:%lu slab_unreclaimable:%lu\n"
> >  		" mapped:%lu pagetables:%lu bounce:%lu\n",
> >  		global_page_state(NR_ACTIVE_ANON),
> > @@ -2128,6 +2128,7 @@ void show_free_areas(void)
> >  		global_page_state(NR_UNEVICTABLE),
> >  		global_page_state(NR_FILE_DIRTY),
> >  		global_page_state(NR_WRITEBACK),
> > +		K(nr_blockdev_pages()),
> >  		global_page_state(NR_UNSTABLE_NFS),
> >  		global_page_state(NR_FREE_PAGES),
> >  		global_page_state(NR_SLAB_RECLAIMABLE),
> > 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
