Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D776C6B006A
	for <linux-mm@kvack.org>; Mon,  6 Jul 2009 21:31:38 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n672CZCr004564
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 7 Jul 2009 11:12:37 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 618C645DE54
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 11:12:35 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 30A6345DE4E
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 11:12:35 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1894E1DB803C
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 11:12:35 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B8077E18002
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 11:12:34 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/5] add isolate pages vmstat
In-Reply-To: <20090707104806.6706ac4a.minchan.kim@barrios-desktop>
References: <20090707101855.0C63.A69D9226@jp.fujitsu.com> <20090707104806.6706ac4a.minchan.kim@barrios-desktop>
Message-Id: <20090707111030.0C69.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  7 Jul 2009 11:12:33 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> It looks good to me. 
> Thanks for your effort. I added my review sign. :)
> 
> Let remain one side note. 
> This accounting feature results from direct reclaim bomb. 
> If we prevent direct reclaim bomb, I think this feature can be removed. 

Hmmm. I disagree.
isolated pages can become more than >1GB on server systems.
Who want >1GB unaccountable memory?



> 
> As I know, Rik or Wu is making patch for throttling direct reclaim. 
> 
> On Tue,  7 Jul 2009 10:19:53 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > > > > Index: b/mm/vmscan.c
> > > > > ===================================================================
> > > > > --- a/mm/vmscan.c
> > > > > +++ b/mm/vmscan.c
> > > > > @@ -1082,6 +1082,7 @@ static unsigned long shrink_inactive_lis
> > > > >  						-count[LRU_ACTIVE_ANON]);
> > > > >  		__mod_zone_page_state(zone, NR_INACTIVE_ANON,
> > > > >  						-count[LRU_INACTIVE_ANON]);
> > > > > +		__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, nr_taken);
> > > > 
> > > > Lumpy can reclaim file + anon anywhere.  
> > > > How about using count[NR_LRU_LISTS]?
> > > 
> > > Ah yes, good catch.
> > 
> > Fixed.
> > 
> > Subject: [PATCH] add isolate pages vmstat
> > 
> > If the system have plenty threads or processes, concurrent reclaim can
> > isolate very much pages.
> > Unfortunately, current /proc/meminfo and OOM log can't show it.
> > 
> > This patch provide the way of showing this information.
> > 
> > 
> > reproduce way
> > -----------------------
> > % ./hackbench 140 process 1000
> >    => couse OOM
> > 
> > Active_anon:146 active_file:41 inactive_anon:0
> >  inactive_file:0 unevictable:0
> >  isolated_anon:49245 isolated_file:113
> >  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> >  dirty:0 writeback:0 buffer:49 unstable:0
> >  free:184 slab_reclaimable:276 slab_unreclaimable:5492
> >  mapped:87 pagetables:28239 bounce:0
> > 
> > 
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> 
> -- 
> Kind regards,
> Minchan Kim
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
