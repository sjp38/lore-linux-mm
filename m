Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9B6176B004F
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 22:50:54 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n612qTec019700
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 1 Jul 2009 11:52:29 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C65945DE62
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 11:52:29 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EEBE445DE55
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 11:52:28 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CF6231DB8041
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 11:52:28 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 70BCA1DB803E
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 11:52:28 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v2] Show kernel stack usage to /proc/meminfo and OOM log
In-Reply-To: <alpine.DEB.2.00.0906301858270.7103@chino.kir.corp.google.com>
References: <20090701103622.85CD.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.0906301858270.7103@chino.kir.corp.google.com>
Message-Id: <20090701112345.85D0.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  1 Jul 2009 11:52:27 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Christoph Lameter <cl@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, David Howells <dhowells@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, linux-mm@kvack.org, "elladan@eskimo.com" <elladan@eskimo.com>, "Barnes, Jesse" <jesse.barnes@intel.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

> On Wed, 1 Jul 2009, KOSAKI Motohiro wrote:
> 
> > Subject: [PATCH] Show kernel stack usage to /proc/meminfo and OOM log
> > 
> > if the system have a lot of thread, kernel stack consume unignorable large size
> > memory.
> > IOW, it make a lot of unaccountable memory.
> > 
> > Tons unaccountable memory bring to harder analyse memory related trouble.
> > 
> > Then, kernel stack account is useful.
> > 
> > 
> 
> I know this is the second revision of the patch, apologies for not 
> responding to the first.

Thanks, good review.

> 
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > ---
> >  fs/proc/meminfo.c      |    2 ++
> >  include/linux/mmzone.h |    3 ++-
> >  kernel/fork.c          |   12 ++++++++++++
> >  mm/page_alloc.c        |    6 ++++--
> >  mm/vmstat.c            |    1 +
> >  5 files changed, 21 insertions(+), 3 deletions(-)
> > 
> > Index: b/fs/proc/meminfo.c
> > ===================================================================
> > --- a/fs/proc/meminfo.c
> > +++ b/fs/proc/meminfo.c
> > @@ -85,6 +85,7 @@ static int meminfo_proc_show(struct seq_
> >  		"SReclaimable:   %8lu kB\n"
> >  		"SUnreclaim:     %8lu kB\n"
> >  		"PageTables:     %8lu kB\n"
> > +		"KernelStack     %8lu kB\n"
> 
> Missing :.

Grr, thanks. Will fix.

> 
> >  #ifdef CONFIG_QUICKLIST
> >  		"Quicklists:     %8lu kB\n"
> >  #endif
> > @@ -129,6 +130,7 @@ static int meminfo_proc_show(struct seq_
> >  		K(global_page_state(NR_SLAB_RECLAIMABLE)),
> >  		K(global_page_state(NR_SLAB_UNRECLAIMABLE)),
> >  		K(global_page_state(NR_PAGETABLE)),
> > +		K(global_page_state(NR_KERNEL_STACK)),
> >  #ifdef CONFIG_QUICKLIST
> >  		K(quicklist_total_size()),
> >  #endif
> > Index: b/include/linux/mmzone.h
> > ===================================================================
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -94,10 +94,11 @@ enum zone_stat_item {
> >  	NR_SLAB_RECLAIMABLE,
> >  	NR_SLAB_UNRECLAIMABLE,
> >  	NR_PAGETABLE,		/* used for pagetables */
> > +	NR_KERNEL_STACK,
> > +	/* Second 128 byte cacheline */
> >  	NR_UNSTABLE_NFS,	/* NFS unstable pages */
> >  	NR_BOUNCE,
> >  	NR_VMSCAN_WRITE,
> > -	/* Second 128 byte cacheline */
> >  	NR_WRITEBACK_TEMP,	/* Writeback using temporary buffers */
> >  #ifdef CONFIG_NUMA
> >  	NUMA_HIT,		/* allocated in intended node */
> > Index: b/kernel/fork.c
> > ===================================================================
> > --- a/kernel/fork.c
> > +++ b/kernel/fork.c
> > @@ -137,9 +137,18 @@ struct kmem_cache *vm_area_cachep;
> >  /* SLAB cache for mm_struct structures (tsk->mm) */
> >  static struct kmem_cache *mm_cachep;
> >  
> > +static void account_kernel_stack(struct thread_info *ti, int on)
> > +{
> > +	struct zone *zone = page_zone(virt_to_page(ti));
> > +	int pages = THREAD_SIZE / PAGE_SIZE;
> > +
> > +	mod_zone_page_state(zone, NR_KERNEL_STACK, on ? pages : -pages);
> > +}
> > +
> >  void free_task(struct task_struct *tsk)
> >  {
> >  	prop_local_destroy_single(&tsk->dirties);
> > +	account_kernel_stack(tsk->stack, 0);
> 
> I think it would be better to do
> 
> 	#define THREAD_PAGES	(THREAD_SIZE / PAGE_SIZE)
> 
> since it's currently unused and then
> 
> 	struct zone *zone = page_zone(virt_to_page(tsk->stack));
> 	mod_zone_page_state(zone, NR_KERNEL_STACK, THREAD_PAGES);
> 
> in free_task() and
> 
> 	struct zone *zone = page_zone(virt_to_page(ti));
> 	mod_zone_page_state(zone, NR_KERNEL_STACK, -THREAD_PAGES);
> 
> in dup_task_struct().

maybe, gcc makes same code. then I keep current code. because
"struct zone *zone = page_zone(virt_to_page(tsk->stack))" line is a bit 
complicate statement and I don't hope sprinkle it.

> 
> >  	free_thread_info(tsk->stack);
> >  	rt_mutex_debug_task_free(tsk);
> >  	ftrace_graph_exit_task(tsk);
> > @@ -255,6 +264,9 @@ static struct task_struct *dup_task_stru
> >  	tsk->btrace_seq = 0;
> >  #endif
> >  	tsk->splice_pipe = NULL;
> > +
> > +	account_kernel_stack(ti, 1);
> > +
> >  	return tsk;
> >  
> >  out:
> > Index: b/mm/page_alloc.c
> > ===================================================================
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2119,7 +2119,8 @@ void show_free_areas(void)
> >  		" inactive_file:%lu"
> >  		" unevictable:%lu"
> >  		" dirty:%lu writeback:%lu unstable:%lu\n"
> > -		" free:%lu slab:%lu mapped:%lu pagetables:%lu bounce:%lu\n",
> > +		" free:%lu slab:%lu mapped:%lu pagetables:%lu bounce:%lu\n"
> > +		" kernel_stack:%lu\n",
> 
> Does kernel_stack really need to be printed on its own line?

Well, my another patch (Makes slab pages field in show_free_areas() separate two field)
already used full space of previous line. new line is really needed.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
