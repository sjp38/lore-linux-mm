Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9D2CC6B005A
	for <linux-mm@kvack.org>; Mon,  6 Jul 2009 19:27:35 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6707q2g027178
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 7 Jul 2009 09:07:52 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C036945DE51
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 09:07:51 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9264945DE4E
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 09:07:51 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 699761DB8041
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 09:07:51 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A0CA1DB8038
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 09:07:51 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/5] add isolate pages vmstat
In-Reply-To: <20090707090120.1e71a060.minchan.kim@barrios-desktop>
References: <20090706204412.0C5D.A69D9226@jp.fujitsu.com> <20090707090120.1e71a060.minchan.kim@barrios-desktop>
Message-Id: <20090707090509.0C60.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  7 Jul 2009 09:07:50 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

>  
> > ============ CUT HERE ===============
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
> > ---
> >  drivers/base/node.c    |    4 ++++
> >  fs/proc/meminfo.c      |    4 ++++
> >  include/linux/mmzone.h |    2 ++
> >  mm/page_alloc.c        |   10 ++++++++--
> >  mm/vmscan.c            |    5 +++++
> >  mm/vmstat.c            |    3 ++-
> >  6 files changed, 25 insertions(+), 3 deletions(-)
> > 
> > Index: b/fs/proc/meminfo.c
> > ===================================================================
> > --- a/fs/proc/meminfo.c
> > +++ b/fs/proc/meminfo.c
> > @@ -65,6 +65,8 @@ static int meminfo_proc_show(struct seq_
> >  		"Active(file):   %8lu kB\n"
> >  		"Inactive(file): %8lu kB\n"
> >  		"Unevictable:    %8lu kB\n"
> > +		"Isolated(anon): %8lu kB\n"
> > +		"Isolated(file): %8lu kB\n"
> >  		"Mlocked:        %8lu kB\n"
> >  #ifdef CONFIG_HIGHMEM
> >  		"HighTotal:      %8lu kB\n"
> > @@ -109,6 +111,8 @@ static int meminfo_proc_show(struct seq_
> >  		K(pages[LRU_ACTIVE_FILE]),
> >  		K(pages[LRU_INACTIVE_FILE]),
> >  		K(pages[LRU_UNEVICTABLE]),
> > +		K(global_page_state(NR_ISOLATED_ANON)),
> > +		K(global_page_state(NR_ISOLATED_FILE)),
> >  		K(global_page_state(NR_MLOCK)),
> >  #ifdef CONFIG_HIGHMEM
> >  		K(i.totalhigh),
> > Index: b/include/linux/mmzone.h
> > ===================================================================
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -100,6 +100,8 @@ enum zone_stat_item {
> >  	NR_BOUNCE,
> >  	NR_VMSCAN_WRITE,
> >  	NR_WRITEBACK_TEMP,	/* Writeback using temporary buffers */
> > +	NR_ISOLATED_ANON,	/* Temporary isolated pages from anon lru */
> > +	NR_ISOLATED_FILE,	/* Temporary isolated pages from file lru */
> >  #ifdef CONFIG_NUMA
> >  	NUMA_HIT,		/* allocated in intended node */
> >  	NUMA_MISS,		/* allocated in non intended node */
> > Index: b/mm/page_alloc.c
> > ===================================================================
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2116,8 +2116,8 @@ void show_free_areas(void)
> >  	}
> >  
> >  	printk("Active_anon:%lu active_file:%lu inactive_anon:%lu\n"
> > -		" inactive_file:%lu"
> > -		" unevictable:%lu"
> > +		" inactive_file:%lu unevictable:%lu\n"
> > +		" isolated_anon:%lu isolated_file:%lu\n"
> >  		" dirty:%lu writeback:%lu buffer:%lu unstable:%lu\n"
> >  		" free:%lu slab_reclaimable:%lu slab_unreclaimable:%lu\n"
> >  		" mapped:%lu pagetables:%lu bounce:%lu\n",
> > @@ -2126,6 +2126,8 @@ void show_free_areas(void)
> >  		global_page_state(NR_INACTIVE_ANON),
> >  		global_page_state(NR_INACTIVE_FILE),
> >  		global_page_state(NR_UNEVICTABLE),
> > +		global_page_state(NR_ISOLATED_ANON),
> > +		global_page_state(NR_ISOLATED_FILE),
> >  		global_page_state(NR_FILE_DIRTY),
> >  		global_page_state(NR_WRITEBACK),
> >  		nr_blockdev_pages(),
> > @@ -2151,6 +2153,8 @@ void show_free_areas(void)
> >  			" active_file:%lukB"
> >  			" inactive_file:%lukB"
> >  			" unevictable:%lukB"
> > +			" isolated(anon):%lukB"
> > +			" isolated(file):%lukB"
> >  			" present:%lukB"
> >  			" mlocked:%lukB"
> >  			" dirty:%lukB"
> > @@ -2176,6 +2180,8 @@ void show_free_areas(void)
> >  			K(zone_page_state(zone, NR_ACTIVE_FILE)),
> >  			K(zone_page_state(zone, NR_INACTIVE_FILE)),
> >  			K(zone_page_state(zone, NR_UNEVICTABLE)),
> > +			K(zone_page_state(zone, NR_ISOLATED_ANON)),
> > +			K(zone_page_state(zone, NR_ISOLATED_FILE)),
> >  			K(zone->present_pages),
> >  			K(zone_page_state(zone, NR_MLOCK)),
> >  			K(zone_page_state(zone, NR_FILE_DIRTY)),
> > Index: b/mm/vmscan.c
> > ===================================================================
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1082,6 +1082,7 @@ static unsigned long shrink_inactive_lis
> >  						-count[LRU_ACTIVE_ANON]);
> >  		__mod_zone_page_state(zone, NR_INACTIVE_ANON,
> >  						-count[LRU_INACTIVE_ANON]);
> > +		__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, nr_taken);
> 
> Lumpy can reclaim file + anon anywhere.  
> How about using count[NR_LRU_LISTS]?

Ah yes, good catch.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
