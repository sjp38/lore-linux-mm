Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B69506B004D
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 07:16:34 -0500 (EST)
Date: Fri, 27 Nov 2009 12:16:28 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH-RFC] cfq: Disable low_latency by default for 2.6.32
Message-ID: <20091127121627.GL13095@csn.ul.ie>
References: <4e5e476b0911260547r33424098v456ed23203a61dd@mail.gmail.com> <20091126141738.GE13095@csn.ul.ie> <20091127143307.A7E1.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20091127143307.A7E1.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Corrado Zoccolo <czoccolo@gmail.com>, Jens Axboe <jens.axboe@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Nov 27, 2009 at 02:58:26PM +0900, KOSAKI Motohiro wrote:
> > > <SNIP>
> > > low_latency was tested on other scenarios:
> > > http://lkml.indiana.edu/hypermail/linux/kernel/0910.0/01410.html
> > > http://linux.derkeiler.com/Mailing-Lists/Kernel/2009-11/msg04855.html
> > > where it improved actual and perceived performance, so disabling it
> > > completely may not be good.
> > > 
> > 
> > It may not indeed.
> > 
> > In case you mean a partial disabling of cfq_latency, I'm try the
> > following patch. The intention is to disable the low_latency logic if
> > kswapd is at work and presumably needs clean pages. Alternative
> > suggestions welcome.
> 
> I like treat vmscan writeout as special. because
>   - vmscan use various process context. but it doesn't write own process's page.
>     IOW, it doesn't so match cfq's io fairness logic.
>   - plus, the above mean vmscan writeout doesn't need good i/o latency.

While it might not need good latency as such, it does need pages to be
clean because direct reclaim has trouble cleaning pages in its own
behalf.

>   - vmscan maintain page granularity lru list. It mean vmscan makes awful
>     seekful I/O. it assume block-layer buffered much i/o request.
>   - plus, the above mena vmscan. writeout need good io throughput. otherwise
>     system might cause hangup.
> 
> However, I don't think kswapd_awake is good choice. because
>   - zone reclaim run before kswapd wakeup. iow, this patch doesn't solve hpc machine.
>     btw, some Core i7 box (at least, Intel's reference box) also use zone reclaim.

Good point.

>   - On large (many memory node) machine, one of much kswapd always run.
> 

Also true.

> 
> Instead, PF_MEMALLOC is good idea?
> 

It doesn't work out either because a process with PF_MEMALLOC is in
direct reclaim and like kswapd, it may not be able to clean the pages at
all, let alone in a small period of time.

> 
> Subject: [PATCH] cfq: Do not limit the async queue depth while memory reclaim
> 
> Not-Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> (I haven't test this)
> ---
>  block/cfq-iosched.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
> index aa1e953..9546f64 100644
> --- a/block/cfq-iosched.c
> +++ b/block/cfq-iosched.c
> @@ -1308,7 +1308,8 @@ static bool cfq_may_dispatch(struct cfq_data *cfqd, struct cfq_queue *cfqq)
>  	 * We also ramp up the dispatch depth gradually for async IO,
>  	 * based on the last sync IO we serviced
>  	 */
> -	if (!cfq_cfqq_sync(cfqq) && cfqd->cfq_latency) {
> +	if (!cfq_cfqq_sync(cfqq) && cfqd->cfq_latency &&
> +	    !(current->flags & PF_MEMALLOC)) {
>  		unsigned long last_sync = jiffies - cfqd->last_end_sync_rq;
>  		unsigned int depth;
>  
> -- 
> 1.6.5.2
> 
> 
> 
> 
> 
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
