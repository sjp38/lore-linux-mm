Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 883456B0078
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 08:49:04 -0500 (EST)
Received: from e35131.upc-e.chello.nl ([213.93.35.131] helo=dyad.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1NmST8-00068e-Fv
	for linux-mm@kvack.org; Tue, 02 Mar 2010 13:49:02 +0000
Subject: Re: [PATCH -mmotm 3/3] memcg: dirty pages instrumentation
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1267478620-5276-4-git-send-email-arighi@develer.com>
References: <1267478620-5276-1-git-send-email-arighi@develer.com>
	 <1267478620-5276-4-git-send-email-arighi@develer.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 02 Mar 2010 14:48:56 +0100
Message-ID: <1267537736.25158.54.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Righi <arighi@develer.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Trond Myklebust <trond.myklebust@fys.uio.no>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-03-01 at 22:23 +0100, Andrea Righi wrote:
> Apply the cgroup dirty pages accounting and limiting infrastructure to
> the opportune kernel functions.
> 
> Signed-off-by: Andrea Righi <arighi@develer.com>
> ---

> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 5a0f8f3..d83f41c 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -137,13 +137,14 @@ static struct prop_descriptor vm_dirties;
>   */
>  static int calc_period_shift(void)
>  {
> -	unsigned long dirty_total;
> +	unsigned long dirty_total, dirty_bytes;
>  
> -	if (vm_dirty_bytes)
> -		dirty_total = vm_dirty_bytes / PAGE_SIZE;
> +	dirty_bytes = mem_cgroup_dirty_bytes();
> +	if (dirty_bytes)

So you don't think 0 is a valid max dirty amount?

> +		dirty_total = dirty_bytes / PAGE_SIZE;
>  	else
> -		dirty_total = (vm_dirty_ratio * determine_dirtyable_memory()) /
> -				100;
> +		dirty_total = (mem_cgroup_dirty_ratio() *
> +				determine_dirtyable_memory()) / 100;
>  	return 2 + ilog2(dirty_total - 1);
>  }
>  
> @@ -408,14 +409,16 @@ static unsigned long highmem_dirtyable_memory(unsigned long total)
>   */
>  unsigned long determine_dirtyable_memory(void)
>  {
> -	unsigned long x;
> -
> -	x = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages();
> +	unsigned long memory;
> +	s64 memcg_memory;
>  
> +	memory = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages();
>  	if (!vm_highmem_is_dirtyable)
> -		x -= highmem_dirtyable_memory(x);
> -
> -	return x + 1;	/* Ensure that we never return 0 */
> +		memory -= highmem_dirtyable_memory(memory);
> +	memcg_memory = mem_cgroup_page_stat(MEMCG_NR_DIRTYABLE_PAGES);
> +	if (memcg_memory < 0)

And here you somehow return negative?

> +		return memory + 1;
> +	return min((unsigned long)memcg_memory, memory + 1);
>  }
>  
>  void
> @@ -423,26 +426,28 @@ get_dirty_limits(unsigned long *pbackground, unsigned long *pdirty,
>  		 unsigned long *pbdi_dirty, struct backing_dev_info *bdi)
>  {
>  	unsigned long background;
> -	unsigned long dirty;
> +	unsigned long dirty, dirty_bytes, dirty_background;
>  	unsigned long available_memory = determine_dirtyable_memory();
>  	struct task_struct *tsk;
>  
> -	if (vm_dirty_bytes)
> -		dirty = DIV_ROUND_UP(vm_dirty_bytes, PAGE_SIZE);
> +	dirty_bytes = mem_cgroup_dirty_bytes();
> +	if (dirty_bytes)

zero not valid again

> +		dirty = DIV_ROUND_UP(dirty_bytes, PAGE_SIZE);
>  	else {
>  		int dirty_ratio;
>  
> -		dirty_ratio = vm_dirty_ratio;
> +		dirty_ratio = mem_cgroup_dirty_ratio();
>  		if (dirty_ratio < 5)
>  			dirty_ratio = 5;
>  		dirty = (dirty_ratio * available_memory) / 100;
>  	}
>  
> -	if (dirty_background_bytes)
> -		background = DIV_ROUND_UP(dirty_background_bytes, PAGE_SIZE);
> +	dirty_background = mem_cgroup_dirty_background_bytes();
> +	if (dirty_background)

idem

> +		background = DIV_ROUND_UP(dirty_background, PAGE_SIZE);
>  	else
> -		background = (dirty_background_ratio * available_memory) / 100;
> -
> +		background = (mem_cgroup_dirty_background_ratio() *
> +					available_memory) / 100;
>  	if (background >= dirty)
>  		background = dirty / 2;
>  	tsk = current;
> @@ -508,9 +513,13 @@ static void balance_dirty_pages(struct address_space *mapping,
>  		get_dirty_limits(&background_thresh, &dirty_thresh,
>  				&bdi_thresh, bdi);
>  
> -		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
> +		nr_reclaimable = mem_cgroup_page_stat(MEMCG_NR_RECLAIM_PAGES);
> +		nr_writeback = mem_cgroup_page_stat(MEMCG_NR_WRITEBACK);
> +		if ((nr_reclaimable < 0) || (nr_writeback < 0)) {
> +			nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
>  					global_page_state(NR_UNSTABLE_NFS);

??? why would a page_state be negative.. I see you return -ENOMEM on !
cgroup, but how can one specify no dirty limit with this compiled in?

> -		nr_writeback = global_page_state(NR_WRITEBACK);
> +			nr_writeback = global_page_state(NR_WRITEBACK);
> +		}
>  
>  		bdi_nr_reclaimable = bdi_stat(bdi, BDI_DIRTY);
>  		if (bdi_cap_account_unstable(bdi)) {
> @@ -611,10 +620,12 @@ static void balance_dirty_pages(struct address_space *mapping,
>  	 * In normal mode, we start background writeout at the lower
>  	 * background_thresh, to keep the amount of dirty memory low.
>  	 */
> +	nr_reclaimable = mem_cgroup_page_stat(MEMCG_NR_RECLAIM_PAGES);
> +	if (nr_reclaimable < 0)
> +		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
> +				global_page_state(NR_UNSTABLE_NFS);

Again..

>  	if ((laptop_mode && pages_written) ||
> -	    (!laptop_mode && ((global_page_state(NR_FILE_DIRTY)
> -			       + global_page_state(NR_UNSTABLE_NFS))
> -					  > background_thresh)))
> +	    (!laptop_mode && (nr_reclaimable > background_thresh)))
>  		bdi_start_writeback(bdi, NULL, 0);
>  }
>  
> @@ -678,6 +689,8 @@ void throttle_vm_writeout(gfp_t gfp_mask)
>  	unsigned long dirty_thresh;
>  
>          for ( ; ; ) {
> +		unsigned long dirty;
> +
>  		get_dirty_limits(&background_thresh, &dirty_thresh, NULL, NULL);
>  
>                  /*
> @@ -686,10 +699,14 @@ void throttle_vm_writeout(gfp_t gfp_mask)
>                   */
>                  dirty_thresh += dirty_thresh / 10;      /* wheeee... */
>  
> -                if (global_page_state(NR_UNSTABLE_NFS) +
> -			global_page_state(NR_WRITEBACK) <= dirty_thresh)
> -                        	break;
> -                congestion_wait(BLK_RW_ASYNC, HZ/10);
> +
> +		dirty = mem_cgroup_page_stat(MEMCG_NR_DIRTY_WRITEBACK_PAGES);
> +		if (dirty < 0)
> +			dirty = global_page_state(NR_UNSTABLE_NFS) +
> +				global_page_state(NR_WRITEBACK);

and again..

> +		if (dirty <= dirty_thresh)
> +			break;
> +		congestion_wait(BLK_RW_ASYNC, HZ/10);
>  
>  		/*
>  		 * The caller might hold locks which can prevent IO completion

This is ugly and broken.. I thought you'd agreed to something like:

 if (mem_cgroup_has_dirty_limit(cgroup))
   use mem_cgroup numbers
 else
   use global numbers

That allows for a 0 dirty limit (which should work and basically makes
all io synchronous).

Also, I'd put each of those in a separate function, like:

unsigned long reclaimable_pages(cgroup)
{
  if (mem_cgroup_has_dirty_limit(cgroup))
    return mem_cgroup_page_stat(MEMCG_NR_RECLAIM_PAGES);
  
  return global_page_state(NR_FILE_DIRTY) + global_page_state(NR_NFS_UNSTABLE);
}

Which raises another question, you should probably rebase on top of
Trond's patches, which removes BDI_RECLAIMABLE, suggesting you also
loose MEMCG_NR_RECLAIM_PAGES in favour of the DIRTY+UNSTABLE split.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
