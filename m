Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 58EA26B004D
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 00:35:09 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6G4Z9rY015442
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 16 Jul 2009 13:35:09 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0540845DE5B
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 13:35:09 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id BDA7E45DE53
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 13:35:08 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7DE731DB805F
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 13:35:08 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C97D81DB8063
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 13:35:07 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] add isolate pages vmstat
In-Reply-To: <20090715201657.b01edccd.akpm@linux-foundation.org>
References: <20090716095344.9D10.A69D9226@jp.fujitsu.com> <20090715201657.b01edccd.akpm@linux-foundation.org>
Message-Id: <20090716132639.9D31.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 16 Jul 2009 13:35:07 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> > reproduce way
> > -----------------------
> > % ./hackbench 140 process 1000
> >    => OOM occur
> > 
> > active_anon:146 inactive_anon:0 isolated_anon:49245
> >  active_file:79 inactive_file:18 isolated_file:113
> >  unevictable:0 dirty:0 writeback:0 unstable:0 buffer:39
> >  free:370 slab_reclaimable:309 slab_unreclaimable:5492
> >  mapped:53 shmem:15 pagetables:28140 bounce:0
> > 
> > @@ -1164,6 +1170,9 @@ static unsigned long shrink_inactive_lis
> >  				spin_lock_irq(&zone->lru_lock);
> >  			}
> >  		}
> > +		__mod_zone_page_state(zone, NR_ISOLATED_ANON, -nr_anon);
> > +		__mod_zone_page_state(zone, NR_ISOLATED_FILE, -nr_file);
> > +
> >    	} while (nr_scanned < max_scan);
> 
> This is a non-trivial amount of extra stuff.  Do we really need it?

In general, Administrator really hate large amount unaccounted memory.
Recent msgctl11 discussion, We faced it isolate pages about 1/3 system 
memory.
Ahtough Rik's patch is applied, vmscan can isolate >1GB memory.

That's my point.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
