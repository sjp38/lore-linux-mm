Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id AE3536B0047
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 02:57:02 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o956v0K1027547
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 5 Oct 2010 15:57:00 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D6BE745DE4E
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 15:56:59 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id AFF8945DE4F
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 15:56:59 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E1B21DB8051
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 15:56:59 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 38AD21DB804E
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 15:56:59 +0900 (JST)
Date: Tue, 5 Oct 2010 15:51:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 03/10] memcg: create extensible page stat update
 routines
Message-Id: <20101005155142.847b1529.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1286175485-30643-4-git-send-email-gthelen@google.com>
References: <1286175485-30643-1-git-send-email-gthelen@google.com>
	<1286175485-30643-4-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Sun,  3 Oct 2010 23:57:58 -0700
Greg Thelen <gthelen@google.com> wrote:

> Replace usage of the mem_cgroup_update_file_mapped() memcg
> statistic update routine with two new routines:
> * mem_cgroup_inc_page_stat()
> * mem_cgroup_dec_page_stat()
> 
> As before, only the file_mapped statistic is managed.  However,
> these more general interfaces allow for new statistics to be
> more easily added.  New statistics are added with memcg dirty
> page accounting.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>
> Signed-off-by: Andrea Righi <arighi@develer.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

a nitpick. see below.

> ---
>  include/linux/memcontrol.h |   31 ++++++++++++++++++++++++++++---
>  mm/memcontrol.c            |   17 ++++++++---------
>  mm/rmap.c                  |    4 ++--
>  3 files changed, 38 insertions(+), 14 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 159a076..7c7bec4 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -25,6 +25,11 @@ struct page_cgroup;
>  struct page;
>  struct mm_struct;
>  
> +/* Stats that can be updated by kernel. */
> +enum mem_cgroup_write_page_stat_item {
> +	MEMCG_NR_FILE_MAPPED, /* # of pages charged as file rss */
> +};
> +
>  extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
>  					struct list_head *dst,
>  					unsigned long *scanned, int order,
> @@ -121,7 +126,22 @@ static inline bool mem_cgroup_disabled(void)
>  	return false;
>  }
>  
> -void mem_cgroup_update_file_mapped(struct page *page, int val);
> +void mem_cgroup_update_page_stat(struct page *page,
> +				 enum mem_cgroup_write_page_stat_item idx,
> +				 int val);
> +
> +static inline void mem_cgroup_inc_page_stat(struct page *page,
> +				enum mem_cgroup_write_page_stat_item idx)
> +{
> +	mem_cgroup_update_page_stat(page, idx, 1);
> +}
> +
> +static inline void mem_cgroup_dec_page_stat(struct page *page,
> +				enum mem_cgroup_write_page_stat_item idx)
> +{
> +	mem_cgroup_update_page_stat(page, idx, -1);
> +}
> +
>  unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
>  						gfp_t gfp_mask);
>  u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
> @@ -293,8 +313,13 @@ mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
>  {
>  }
>  
> -static inline void mem_cgroup_update_file_mapped(struct page *page,
> -							int val)
> +static inline void mem_cgroup_inc_page_stat(struct page *page,
> +				enum mem_cgroup_write_page_stat_item idx)
> +{
> +}
> +
> +static inline void mem_cgroup_dec_page_stat(struct page *page,
> +				enum mem_cgroup_write_page_stat_item idx)
>  {
>  }
>  
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 512cb12..f4259f4 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1592,7 +1592,9 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
>   * possibility of race condition. If there is, we take a lock.
>   */
>  
> -static void mem_cgroup_update_file_stat(struct page *page, int idx, int val)
> +void mem_cgroup_update_page_stat(struct page *page,
> +				 enum mem_cgroup_write_page_stat_item idx,
> +				 int val)
>  {
>  	struct mem_cgroup *mem;
>  	struct page_cgroup *pc = lookup_page_cgroup(page);
> @@ -1615,30 +1617,27 @@ static void mem_cgroup_update_file_stat(struct page *page, int idx, int val)
>  			goto out;
>  	}
>  
> -	this_cpu_add(mem->stat->count[idx], val);
> -
>  	switch (idx) {
> -	case MEM_CGROUP_STAT_FILE_MAPPED:
> +	case MEMCG_NR_FILE_MAPPED:
>  		if (val > 0)
>  			SetPageCgroupFileMapped(pc);
>  		else if (!page_mapped(page))
>  			ClearPageCgroupFileMapped(pc);
> +		idx = MEM_CGROUP_STAT_FILE_MAPPED;
>  		break;
>  	default:
>  		BUG();
>  	}
>  
> +	this_cpu_add(mem->stat->count[idx], val);
> +

Why you move this_cpu_add() placement ?
(This placement is ok but I just wonder..)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
