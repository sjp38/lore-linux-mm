Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E0D06600309
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 05:18:24 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAUAIKSX021550
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 30 Nov 2009 19:18:21 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 98A8045DE68
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 19:18:20 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 65F2C45DE64
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 19:18:20 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 236391DB8041
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 19:18:20 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EBCC5EF8003
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 19:18:18 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH-RFC] cfq: Disable low_latency by default for 2.6.32
In-Reply-To: <20091127121627.GL13095@csn.ul.ie>
References: <20091127143307.A7E1.A69D9226@jp.fujitsu.com> <20091127121627.GL13095@csn.ul.ie>
Message-Id: <20091130190711.5BFF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 30 Nov 2009 19:18:18 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Corrado Zoccolo <czoccolo@gmail.com>, Jens Axboe <jens.axboe@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Fri, Nov 27, 2009 at 02:58:26PM +0900, KOSAKI Motohiro wrote:
> > > > <SNIP>
> > > > low_latency was tested on other scenarios:
> > > > http://lkml.indiana.edu/hypermail/linux/kernel/0910.0/01410.html
> > > > http://linux.derkeiler.com/Mailing-Lists/Kernel/2009-11/msg04855.html
> > > > where it improved actual and perceived performance, so disabling it
> > > > completely may not be good.
> > > > 
> > > 
> > > It may not indeed.
> > > 
> > > In case you mean a partial disabling of cfq_latency, I'm try the
> > > following patch. The intention is to disable the low_latency logic if
> > > kswapd is at work and presumably needs clean pages. Alternative
> > > suggestions welcome.
> > 
> > I like treat vmscan writeout as special. because
> >   - vmscan use various process context. but it doesn't write own process's page.
> >     IOW, it doesn't so match cfq's io fairness logic.
> >   - plus, the above mean vmscan writeout doesn't need good i/o latency.
> 
> While it might not need good latency as such, it does need pages to be
> clean because direct reclaim has trouble cleaning pages in its own
> behalf.

Well.
if direct reclaim need lumpy reclaim, you are right.

In no lupy case, vmscan start pageout and move the page list tail typically.
cleaned page will be used by another task.

---------------------------------------------------------------------------------------
static unsigned long shrink_page_list(struct list_head *page_list,
                                      struct list_head *freed_pages_list,
                                        struct scan_control *sc,
                                        enum pageout_io sync_writeback)
{
(snip)
                        switch (pageout(page, mapping, sync_writeback)) {
                        case PAGE_KEEP:
                                goto keep_locked;
                        case PAGE_ACTIVATE:
                                goto activate_locked;
                        case PAGE_SUCCESS:
                                if (PageWriteback(page) || PageDirty(page))
                                        goto keep;                                     ///////  HERE
---------------------------------------------------------------------------------------



> >   - vmscan maintain page granularity lru list. It mean vmscan makes awful
> >     seekful I/O. it assume block-layer buffered much i/o request.
> >   - plus, the above mena vmscan. writeout need good io throughput. otherwise
> >     system might cause hangup.
> > 
> > However, I don't think kswapd_awake is good choice. because
> >   - zone reclaim run before kswapd wakeup. iow, this patch doesn't solve hpc machine.
> >     btw, some Core i7 box (at least, Intel's reference box) also use zone reclaim.
> 
> Good point.
> 
> >   - On large (many memory node) machine, one of much kswapd always run.
> > 
> 
> Also true.
> 
> > 
> > Instead, PF_MEMALLOC is good idea?
> 
> It doesn't work out either because a process with PF_MEMALLOC is in
> direct reclaim and like kswapd, it may not be able to clean the pages at
> all, let alone in a small period of time.

please forget this idea ;)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
