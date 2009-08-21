Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8CBB46B00A2
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 11:41:08 -0400 (EDT)
Date: Fri, 21 Aug 2009 19:22:28 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH] mm: remove unnecessary loop inside
	shrink_inactive_list()
Message-ID: <20090821112228.GA6457@localhost>
References: <20090820024929.GA19793@localhost> <20090820025209.GA24387@localhost> <20090820031723.GA25673@localhost> <2f11576a0908210409p3f1551a4i194887abbad94e9b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <2f11576a0908210409p3f1551a4i194887abbad94e9b@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Avi Kivity <avi@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 21, 2009 at 07:09:17PM +0800, KOSAKI Motohiro wrote:
> 2009/8/20 Wu Fengguang <fengguang.wu@intel.com>:
> > shrink_inactive_list() won't be called to scan too much pages
> > (unless in hibernation code which is fine) or too few pages (ie.
> > batching is taken care of by the callers). A So we can just remove the
> > big loop and isolate the exact number of pages requested.
> >
> > Just a RFC, and a scratch patch to show the basic idea.
> > Please kindly NAK quick if you don't like it ;)
> 
> Hm, I think this patch taks only cleanups. right?
> if so, I don't find any objection reason.

Mostly cleanups, but one behavior change here: 

> > - A  A  A  A  A  A  A  nr_taken = sc->isolate_pages(sc->swap_cluster_max,
> > + A  A  A  A  A  A  A  nr_taken = sc->isolate_pages(nr_to_scan,
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  &page_list, &nr_scan, sc->order, mode,
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A zone, sc->mem_cgroup, 0, file);

The new behavior is to scan exactly the number of pages that
shrink_zone() or other callers tell it. It won't try to "round it up"
to 32 pages. This new behavior is in line with shrink_active_list()'s
current status as well as shrink_zone()'s expectation.

shrink_zone() may still submit scan requests for <32 pages, which is
suboptimal. I'll try to eliminate that totally with more patches.

> > A  A  A  A  A  A  A  A nr_active = clear_active_flags(&page_list, count);
> > @@ -1093,7 +1095,6 @@ static unsigned long shrink_inactive_lis
> >
> > A  A  A  A  A  A  A  A spin_unlock_irq(&zone->lru_lock);
> >
> > - A  A  A  A  A  A  A  nr_scanned += nr_scan;
> > A  A  A  A  A  A  A  A nr_freed = shrink_page_list(&page_list, sc, PAGEOUT_IO_ASYNC);
> >
> > A  A  A  A  A  A  A  A /*
> > @@ -1117,7 +1118,7 @@ static unsigned long shrink_inactive_lis
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A PAGEOUT_IO_SYNC);
> > A  A  A  A  A  A  A  A }
> >
> > - A  A  A  A  A  A  A  nr_reclaimed += nr_freed;
> > + A  A  A  A  A  A  A  nr_reclaimed = nr_freed;
> 
> maybe, nr_freed can be removed perfectly. it have the same meaning as
> nr_reclaimed.

Yes, good spot!

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
