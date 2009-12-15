Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 78FE76B0047
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 18:56:15 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBFNuBgB005916
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 16 Dec 2009 08:56:11 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 364D645DE70
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 08:56:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0098045DE6E
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 08:56:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DC1721DB803B
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 08:56:10 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7BA561DB8040
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 08:56:10 +0900 (JST)
Date: Wed, 16 Dec 2009 08:53:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [mmotm][PATCH 1/5] clean up mm_counter
Message-Id: <20091216085305.d7b46376.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091216082529.8fc0d3c4.minchan.kim@barrios-desktop>
References: <20091215180904.c307629f.kamezawa.hiroyu@jp.fujitsu.com>
	<20091215181116.ee2c31f7.kamezawa.hiroyu@jp.fujitsu.com>
	<20091216082529.8fc0d3c4.minchan.kim@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, cl@linux-foundation.org, Lee.Schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On Wed, 16 Dec 2009 08:25:29 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Tue, 15 Dec 2009 18:11:16 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > Now, per-mm statistics counter is defined by macro in sched.h
> > 
> > This patch modifies it to
> >   - defined in mm.h as inlinf functions
> >   - use array instead of macro's name creation.
> > 
> > This patch is for reducing patch size in future patch to modify
> > implementation of per-mm counter.
> > 
> > Changelog: 2009/12/14
> >  - added a struct rss_stat instead of bare counters.
> >  - use memset instead of for() loop.
> >  - rewrite macros into static inline functions.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  fs/proc/task_mmu.c       |    4 -
> >  include/linux/mm.h       |  104 +++++++++++++++++++++++++++++++++++++++++++++++
> >  include/linux/mm_types.h |   33 +++++++++-----
> >  include/linux/sched.h    |   54 ------------------------
> >  kernel/fork.c            |    3 -
> >  kernel/tsacct.c          |    1 
> >  mm/filemap_xip.c         |    2 
> >  mm/fremap.c              |    2 
> >  mm/memory.c              |   56 +++++++++++++++----------
> >  mm/oom_kill.c            |    4 -
> >  mm/rmap.c                |   10 ++--
> >  mm/swapfile.c            |    2 
> >  12 files changed, 174 insertions(+), 101 deletions(-)
> > 
> > Index: mmotm-2.6.32-Dec8-pth/include/linux/mm.h
> > ===================================================================
> > --- mmotm-2.6.32-Dec8-pth.orig/include/linux/mm.h
> > +++ mmotm-2.6.32-Dec8-pth/include/linux/mm.h
> > @@ -868,6 +868,110 @@ extern int mprotect_fixup(struct vm_area
> >   */
> >  int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
> >  			  struct page **pages);
> > +/*
> > + * per-process(per-mm_struct) statistics.
> > + */
> > +#if USE_SPLIT_PTLOCKS
> > +/*
> > + * The mm counters are not protected by its page_table_lock,
> > + * so must be incremented atomically.
> > + */
> > +static inline void set_mm_counter(struct mm_struct *mm, int member, long value)
> > +{
> > +	atomic_long_set(&mm->rss_stat.count[member], value);
> > +}
> 
> I can't find mm->rss_stat in this patch.
> Maybe it's part of next patch. 

It's in mm_types.h

@@ -223,11 +233,6 @@ struct mm_struct {
 						 * by mmlist_lock
 						 */
 
-	/* Special counters, in some configurations protected by the
-	 * page_table_lock, in other configurations by being atomic.
-	 */
-	mm_counter_t _file_rss;
-	mm_counter_t _anon_rss;
 
 	unsigned long hiwater_rss;	/* High-watermark of RSS usage */
 	unsigned long hiwater_vm;	/* High-water virtual memory usage */
@@ -240,6 +245,12 @@ struct mm_struct {
 
 	unsigned long saved_auxv[AT_VECTOR_SIZE]; /* for /proc/PID/auxv */
 
+	/*
+	 * Special counters, in some configurations protected by the
+	 * page_table_lock, in other configurations by being atomic.
+	 */
+	struct mm_rss_stat rss_stat;
+
 	struct linux_binfmt *binfmt;

Moved to some bytes higher address for avoiding false sharing storm
of mmap_sem..


> Otherwise, Looks good to me. 
> 
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> 

Thank you for all your help for this series.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
