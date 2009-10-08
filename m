Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id F36136B004D
	for <linux-mm@kvack.org>; Thu,  8 Oct 2009 19:51:18 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n98NpGdg013761
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 9 Oct 2009 08:51:16 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EFB7145DE55
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 08:51:15 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CFA1C45DE4F
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 08:51:15 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B2C5A1DB803B
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 08:51:15 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 27D091DB8038
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 08:51:15 +0900 (JST)
Date: Fri, 9 Oct 2009 08:48:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] memcg: coalescing uncharge at unmap and truncation
 (fixed coimpile bug)
Message-Id: <20091009084853.26975150.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091008151710.1216a615.akpm@linux-foundation.org>
References: <20091002135531.3b5abf5c.kamezawa.hiroyu@jp.fujitsu.com>
	<20091002140126.61d15e5e.kamezawa.hiroyu@jp.fujitsu.com>
	<4AC5A1FA.1080208@ct.jp.nec.com>
	<20091002160213.32ae2bb5.kamezawa.hiroyu@jp.fujitsu.com>
	<20091008151710.1216a615.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nis@tyo205.gate.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Thu, 8 Oct 2009 15:17:10 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Fri, 2 Oct 2009 16:02:13 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> >
> > ...
> >
> > In massive parallel enviroment, res_counter can be a performance bottleneck.
> > One strong techinque to reduce lock contention is reducing calls by
> > coalescing some amount of calls into one.
> > 
> > Considering charge/uncharge chatacteristic,
> > 	- charge is done one by one via demand-paging.
> > 	- uncharge is done by
> > 		- in chunk at munmap, truncate, exit, execve...
> > 		- one by one via vmscan/paging.
> > 
> > It seems we have a chance in uncharge at unmap/truncation.
> > 
> > This patch is a for coalescing uncharge. For avoiding scattering memcg's
> > structure to functions under /mm, this patch adds memcg batch uncharge
> > information to the task. 
> > 
> > The degree of coalescing depends on callers
> >   - at invalidate/trucate... pagevec size
> >   - at unmap ....ZAP_BLOCK_SIZE
> > (memory itself will be freed in this degree.)
> > Then, we'll not coalescing too much.
> > 
> >
> > ...
> >
> > +static void
> > +__do_uncharge(struct mem_cgroup *mem, const enum charge_type ctype)
> > +{
> > +	struct memcg_batch_info *batch = NULL;
> > +	bool uncharge_memsw = true;
> > +	/* If swapout, usage of swap doesn't decrease */
> > +	if (!do_swap_account || ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
> > +		uncharge_memsw = false;
> > +	/*
> > +	 * do_batch > 0 when unmapping pages or inode invalidate/truncate.
> > +	 * In those cases, all pages freed continously can be expected to be in
> > +	 * the same cgroup and we have chance to coalesce uncharges.
> > +	 * And, we do uncharge one by one if this is killed by OOM.
> > +	 */
> > +	if (!current->memcg_batch.do_batch || test_thread_flag(TIF_MEMDIE))
> > +		goto direct_uncharge;
> > +
> > +	batch = &current->memcg_batch;
> > +	/*
> > +	 * In usual, we do css_get() when we remember memcg pointer.
> > +	 * But in this case, we keep res->usage until end of a series of
> > +	 * uncharges. Then, it's ok to ignore memcg's refcnt.
> > +	 */
> > +	if (!batch->memcg)
> > +		batch->memcg = mem;
> > +	/*
> > +	 * In typical case, batch->memcg == mem. This means we can
> > +	 * merge a series of uncharges to an uncharge of res_counter.
> > +	 * If not, we uncharge res_counter ony by one.
> > +	 */
> > +	if (batch->memcg != mem)
> > +		goto direct_uncharge;
> > +	/* remember freed charge and uncharge it later */
> > +	batch->pages += PAGE_SIZE;
> 
> ->pages is really confusingly named.  It doesn't count pages, it counts
> bytes!
> 
> We could call it `bytes', but perhaps charge_bytes would be more
> communicative?
> 
Ah, I agree. I'll change this "bytes".

> > +/*
> > + * batch_start/batch_end is called in unmap_page_range/invlidate/trucate.
> > + * In that cases, pages are freed continuously and we can expect pages
> > + * are in the same memcg. All these calls itself limits the number of
> > + * pages freed at once, then uncharge_start/end() is called properly.
> > + */
> > +
> > +void mem_cgroup_uncharge_start(void)
> > +{
> > +	if (!current->memcg_batch.do_batch) {
> > +		current->memcg_batch.memcg = NULL;
> > +		current->memcg_batch.pages = 0;
> > +		current->memcg_batch.memsw = 0;
> 
> what's memsw?
> 
Ah, memccontol.c uses "memsw" in several parts.

For example, memory usage interface to user is shown as

   memory.usage_in_bytes

memory+swap usage interface to suer is shown as

    memory.memsw.usage_in_bytes.

But, Hmm, this is visible from sched.c then...

  memsw_bytes or memory_and_swap_bytes ?



> > +	}
> > +	current->memcg_batch.do_batch++;
> > +}
> > +
> >
> > ...
> >
> > +#ifdef CONFIG_CGROUP_MEM_RES_CTLR /* memcg uses this to do batch job */
> > +	struct memcg_batch_info {
> > +		int do_batch;
> > +		struct mem_cgroup *memcg;
> > +		long pages, memsw;
> > +	} memcg_batch;
> > +#endif
> 
> I find the most valuable documetnation is that which is devoted to the
> data structures.  This one didn't get any :(
> 
> Negative values of `pages' and `memsw' are meaningless, so it would be
> better to give them an unsigned type.  That matches the
> res_counter_charge() expectations also.
> 
Agreed. I'll rewrite this part with appropriate comments.
Thank you for pointing out.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
