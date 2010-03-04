Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D54DA6B007B
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 11:19:06 -0500 (EST)
Date: Thu, 4 Mar 2010 11:18:28 -0500
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH -mmotm 4/4] memcg: dirty pages instrumentation
Message-ID: <20100304161828.GC18786@redhat.com>
References: <1267699215-4101-1-git-send-email-arighi@develer.com> <1267699215-4101-5-git-send-email-arighi@develer.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1267699215-4101-5-git-send-email-arighi@develer.com>
Sender: owner-linux-mm@kvack.org
To: Andrea Righi <arighi@develer.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 04, 2010 at 11:40:15AM +0100, Andrea Righi wrote:

[..]
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 5a0f8f3..c5d14ea 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -137,13 +137,16 @@ static struct prop_descriptor vm_dirties;
>   */
>  static int calc_period_shift(void)
>  {
> +	struct dirty_param dirty_param;
>  	unsigned long dirty_total;
>  
> -	if (vm_dirty_bytes)
> -		dirty_total = vm_dirty_bytes / PAGE_SIZE;
> +	get_dirty_param(&dirty_param);
> +
> +	if (dirty_param.dirty_bytes)
> +		dirty_total = dirty_param.dirty_bytes / PAGE_SIZE;
>  	else
> -		dirty_total = (vm_dirty_ratio * determine_dirtyable_memory()) /
> -				100;
> +		dirty_total = (dirty_param.dirty_ratio *
> +				determine_dirtyable_memory()) / 100;
>  	return 2 + ilog2(dirty_total - 1);
>  }
>  
> @@ -408,41 +411,46 @@ static unsigned long highmem_dirtyable_memory(unsigned long total)
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
> +	if (mem_cgroup_has_dirty_limit())
> +		return memory + 1;

Should above be?
	if (!mem_cgroup_has_dirty_limit())
		return memory + 1;

Vivek

> +	memcg_memory = mem_cgroup_page_stat(MEMCG_NR_DIRTYABLE_PAGES);
> +	return min((unsigned long)memcg_memory, memory + 1);
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
