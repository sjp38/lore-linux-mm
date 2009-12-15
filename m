Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 34ABE6B0044
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 18:31:27 -0500 (EST)
Received: by yxe10 with SMTP id 10so437427yxe.12
        for <linux-mm@kvack.org>; Tue, 15 Dec 2009 15:31:24 -0800 (PST)
Date: Wed, 16 Dec 2009 08:25:29 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [mmotm][PATCH 1/5] clean up mm_counter
Message-Id: <20091216082529.8fc0d3c4.minchan.kim@barrios-desktop>
In-Reply-To: <20091215181116.ee2c31f7.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091215180904.c307629f.kamezawa.hiroyu@jp.fujitsu.com>
	<20091215181116.ee2c31f7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, cl@linux-foundation.org, minchan.kim@gmail.com, Lee.Schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, 15 Dec 2009 18:11:16 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Now, per-mm statistics counter is defined by macro in sched.h
> 
> This patch modifies it to
>   - defined in mm.h as inlinf functions
>   - use array instead of macro's name creation.
> 
> This patch is for reducing patch size in future patch to modify
> implementation of per-mm counter.
> 
> Changelog: 2009/12/14
>  - added a struct rss_stat instead of bare counters.
>  - use memset instead of for() loop.
>  - rewrite macros into static inline functions.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  fs/proc/task_mmu.c       |    4 -
>  include/linux/mm.h       |  104 +++++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/mm_types.h |   33 +++++++++-----
>  include/linux/sched.h    |   54 ------------------------
>  kernel/fork.c            |    3 -
>  kernel/tsacct.c          |    1 
>  mm/filemap_xip.c         |    2 
>  mm/fremap.c              |    2 
>  mm/memory.c              |   56 +++++++++++++++----------
>  mm/oom_kill.c            |    4 -
>  mm/rmap.c                |   10 ++--
>  mm/swapfile.c            |    2 
>  12 files changed, 174 insertions(+), 101 deletions(-)
> 
> Index: mmotm-2.6.32-Dec8-pth/include/linux/mm.h
> ===================================================================
> --- mmotm-2.6.32-Dec8-pth.orig/include/linux/mm.h
> +++ mmotm-2.6.32-Dec8-pth/include/linux/mm.h
> @@ -868,6 +868,110 @@ extern int mprotect_fixup(struct vm_area
>   */
>  int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
>  			  struct page **pages);
> +/*
> + * per-process(per-mm_struct) statistics.
> + */
> +#if USE_SPLIT_PTLOCKS
> +/*
> + * The mm counters are not protected by its page_table_lock,
> + * so must be incremented atomically.
> + */
> +static inline void set_mm_counter(struct mm_struct *mm, int member, long value)
> +{
> +	atomic_long_set(&mm->rss_stat.count[member], value);
> +}

I can't find mm->rss_stat in this patch.
Maybe it's part of next patch. 
It could break bisect.

Otherwise, Looks good to me. 

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
