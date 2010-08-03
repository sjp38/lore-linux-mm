Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8D1246008E4
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 00:24:18 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o734T1U9007762
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 3 Aug 2010 13:29:01 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 74E1145DE52
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 13:29:01 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 512A345DE4E
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 13:29:01 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 24A2F1DB8017
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 13:29:01 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A4C721DB8014
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 13:28:57 +0900 (JST)
Date: Tue, 3 Aug 2010 13:24:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mm 4/5] memcg generic file stat accounting interface.
Message-Id: <20100803132403.ef7f50ed.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100803040304.GG3863@balbir.in.ibm.com>
References: <20100802191113.05c982e4.kamezawa.hiroyu@jp.fujitsu.com>
	<20100802191715.63ce81ed.kamezawa.hiroyu@jp.fujitsu.com>
	<20100803040304.GG3863@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, vgoyal@redhat.com, m-ikeda@ds.jp.nec.com, gthelen@google.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Aug 2010 09:33:04 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-08-02 19:17:15]:
> 
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > Preparing for adding new status arounf file caches.(dirty, writeback,etc..)
> > Using a unified macro and more generic names.
> > All counters will have the same rule for updating.
> > 
> > Changelog:
> >  - clean up and moved mem_cgroup_stat_index to header file.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  include/linux/memcontrol.h  |   23 ++++++++++++++++++++++
> >  include/linux/page_cgroup.h |   12 +++++------
> >  mm/memcontrol.c             |   46 ++++++++++++++++++--------------------------
> >  3 files changed, 48 insertions(+), 33 deletions(-)
> > 
> > Index: mmotm-0727/include/linux/memcontrol.h
> > ===================================================================
> > --- mmotm-0727.orig/include/linux/memcontrol.h
> > +++ mmotm-0727/include/linux/memcontrol.h
> > @@ -25,6 +25,29 @@ struct page_cgroup;
> >  struct page;
> >  struct mm_struct;
> > 
> > +/*
> > + * Per-cpu Statistics for memory cgroup.
> > + */
> > +enum mem_cgroup_stat_index {
> > +	/*
> > +	 * For MEM_CONTAINER_TYPE_ALL, usage = pagecache + rss.
> > +	 */
> > +	MEM_CGROUP_STAT_CACHE,		/* # of pages charged as cache */
> > +	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
> > +	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
> > +	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
> > +	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
> > +	MEM_CGROUP_EVENTS,	/* incremented at every  pagein/pageout */
> > +	MEM_CGROUP_ON_MOVE,   /* A check for locking move account/status */
> > +	/* About file-stat please see memcontrol.h */
> 
> Isn't this memcontrol.h?
> 
Ahhhh, it's a garbae. sorry.

> > +	MEM_CGROUP_FSTAT_BASE,
> > +	MEM_CGROUP_FSTAT_FILE_MAPPED = MEM_CGROUP_FSTAT_BASE,
> > +	MEM_CGROUP_FSTAT_END,
> > +	MEM_CGROUP_STAT_NSTATS = MEM_CGROUP_FSTAT_END,
> > +};
> > +
> > +#define MEMCG_FSTAT_IDX(idx)	((idx) - MEM_CGROUP_FSTAT_BASE)
> > +
> >  extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
> >  					struct list_head *dst,
> >  					unsigned long *scanned, int order,
> > Index: mmotm-0727/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-0727.orig/mm/memcontrol.c
> > +++ mmotm-0727/mm/memcontrol.c
> > @@ -74,24 +74,6 @@ static int really_do_swap_account __init
> >  #define THRESHOLDS_EVENTS_THRESH (7) /* once in 128 */
> >  #define SOFTLIMIT_EVENTS_THRESH (10) /* once in 1024 */
> > 
> > -/*
> > - * Statistics for memory cgroup.
> > - */
> > -enum mem_cgroup_stat_index {
> > -	/*
> > -	 * For MEM_CONTAINER_TYPE_ALL, usage = pagecache + rss.
> > -	 */
> > -	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
> > -	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
> > -	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
> > -	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
> > -	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
> > -	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
> > -	MEM_CGROUP_EVENTS,	/* incremented at every  pagein/pageout */
> > -	MEM_CGROUP_ON_MOVE,   /* A check for locking move account/status */
> > -
> > -	MEM_CGROUP_STAT_NSTATS,
> > -};
> > 
> >  struct mem_cgroup_stat_cpu {
> >  	s64 count[MEM_CGROUP_STAT_NSTATS];
> > @@ -1512,7 +1494,8 @@ bool mem_cgroup_handle_oom(struct mem_cg
> >   * Currently used to update mapped file statistics, but the routine can be
> >   * generalized to update other statistics as well.
> >   */
> > -void mem_cgroup_update_file_mapped(struct page *page, int val)
> > +static void
> > +mem_cgroup_update_file_stat(struct page *page, unsigned int idx, int val)
> >  {
> >  	struct mem_cgroup *mem;
> >  	struct page_cgroup *pc;
> > @@ -1536,11 +1519,11 @@ void mem_cgroup_update_file_mapped(struc
> >  	if (unlikely(!PageCgroupUsed(pc)))
> >  		goto done;
> >  	if (val > 0) {
> > -		this_cpu_inc(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> > -		SetPageCgroupFileMapped(pc);
> > +		this_cpu_inc(mem->stat->count[idx]);
> > +		set_bit(fflag_idx(MEMCG_FSTAT_IDX(idx)), &pc->flags);
> 
> Do we use the bit in pc->flags, otherwise is there an advantage of
> creating a separate index for the other stats the block I/O needs?
> 
??? using pc->flags.

use SetPageFileMapped() etc.. and drop this patch ?
I don't want to add swtich(idx) to call SetPageFileMapped() etc.


Thanks,
-Kmae


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
