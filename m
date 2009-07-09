Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 49A546B009A
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 22:06:15 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n692JGTZ021484
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 9 Jul 2009 11:19:16 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2035E45DE54
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 11:19:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F379C45DE64
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 11:19:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C94AE18001
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 11:19:08 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 25A29E18006
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 11:19:07 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/5] add isolate pages vmstat
In-Reply-To: <alpine.DEB.1.10.0907071248560.5124@gentwo.org>
References: <20090707101855.0C63.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.0907071248560.5124@gentwo.org>
Message-Id: <20090709111458.238C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  9 Jul 2009 11:19:06 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> On Tue, 7 Jul 2009, KOSAKI Motohiro wrote:
> 
> > +++ b/include/linux/mmzone.h
> > @@ -100,6 +100,8 @@ enum zone_stat_item {
> >  	NR_BOUNCE,
> >  	NR_VMSCAN_WRITE,
> >  	NR_WRITEBACK_TEMP,	/* Writeback using temporary buffers */
> > +	NR_ISOLATED_ANON,	/* Temporary isolated pages from anon lru */
> > +	NR_ISOLATED_FILE,	/* Temporary isolated pages from file lru */
> 
> LRU counters are rarer in use then the counters used for dirty pages etc.
> 
> Could you move the counters for reclaim into a separate cacheline?
> 

Current definition is here.

dirty pages and other frequently used counter stay in first cache line.
NR_ISOLATED_(ANON|FILE) and other unfrequently used counter stay in second
cache line.

Do you mean we shouldn't use zone_stat_item for it?


---------------------------------------------------------
enum zone_stat_item {
        /* First 128 byte cacheline (assuming 64 bit words) */
        NR_FREE_PAGES,
        NR_LRU_BASE,
        NR_INACTIVE_ANON = NR_LRU_BASE, /* must match order of LRU_[IN]ACTIVE */
        NR_ACTIVE_ANON,         /*  "     "     "   "       "         */
        NR_INACTIVE_FILE,       /*  "     "     "   "       "         */
        NR_ACTIVE_FILE,         /*  "     "     "   "       "         */
        NR_UNEVICTABLE,         /*  "     "     "   "       "         */
        NR_MLOCK,               /* mlock()ed pages found and moved off LRU */
        NR_ANON_PAGES,  /* Mapped anonymous pages */
        NR_FILE_MAPPED, /* pagecache pages mapped into pagetables.
                           only modified from process context */
        NR_FILE_PAGES,
        NR_FILE_DIRTY,
        NR_WRITEBACK,
        NR_SLAB_RECLAIMABLE,
        NR_SLAB_UNRECLAIMABLE,
        NR_PAGETABLE,           /* used for pagetables */
        NR_KERNEL_STACK,
        /* Second 128 byte cacheline */
        NR_UNSTABLE_NFS,        /* NFS unstable pages */
        NR_BOUNCE,
        NR_VMSCAN_WRITE,
        NR_WRITEBACK_TEMP,      /* Writeback using temporary buffers */
        NR_ISOLATED_ANON,       /* Temporary isolated pages from anon lru */
        NR_ISOLATED_FILE,       /* Temporary isolated pages from file lru */
        NR_SHMEM,               /* shmem pages (included tmpfs/GEM pages) */
#ifdef CONFIG_NUMA
        NUMA_HIT,               /* allocated in intended node */
        NUMA_MISS,              /* allocated in non intended node */
        NUMA_FOREIGN,           /* was intended here, hit elsewhere */
        NUMA_INTERLEAVE_HIT,    /* interleaver preferred this zone */
        NUMA_LOCAL,             /* allocation from local node */
        NUMA_OTHER,             /* allocation from other node */
#endif
        NR_VM_ZONE_STAT_ITEMS };





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
