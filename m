Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 15EB86B006C
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 17:01:23 -0400 (EDT)
Received: by ghbg15 with SMTP id g15so1239613ghb.2
        for <linux-mm@kvack.org>; Mon, 09 Jul 2012 14:01:22 -0700 (PDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH 2/7] memcg: remove MEMCG_NR_FILE_MAPPED
References: <1340880885-5427-1-git-send-email-handai.szj@taobao.com>
	<1340881111-5576-1-git-send-email-handai.szj@taobao.com>
Date: Mon, 09 Jul 2012 14:01:21 -0700
Message-ID: <xr93ehok1wf2.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, yinghan@google.com, akpm@linux-foundation.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

On Thu, Jun 28 2012, Sha Zhengju wrote:

> From: Sha Zhengju <handai.szj@taobao.com>
>
> While accounting memcg page stat, it's not worth to use MEMCG_NR_FILE_MAPPED
> as an extra layer of indirection because of the complexity and presumed
> performance overhead. We can use MEM_CGROUP_STAT_FILE_MAPPED directly.
>
> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
> ---
>  include/linux/memcontrol.h |   25 +++++++++++++++++--------
>  mm/memcontrol.c            |   24 +-----------------------
>  mm/rmap.c                  |    4 ++--
>  3 files changed, 20 insertions(+), 33 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 83e7ba9..20b0f2d 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -27,9 +27,18 @@ struct page_cgroup;
>  struct page;
>  struct mm_struct;
>  
> -/* Stats that can be updated by kernel. */
> -enum mem_cgroup_page_stat_item {
> -	MEMCG_NR_FILE_MAPPED, /* # of pages charged as file rss */
> +/*
> + * Statistics for memory cgroup.
> + */
> +enum mem_cgroup_stat_index {
> +	/*
> +	 * For MEM_CONTAINER_TYPE_ALL, usage = pagecache + rss.
> +	 */
> +	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
> +	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
> +	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
> +	MEM_CGROUP_STAT_SWAP, /* # of pages, swapped out */
> +	MEM_CGROUP_STAT_NSTATS,
>  };

Nit.  Moving mem_cgroup_stat_index from memcontrol.c to memcontrol.h is
fine with me.  But this does increase the distance between related
defintions of definition mem_cgroup_stat_index and
mem_cgroup_stat_names.  These two lists have to be kept in sync.  So it
might help to add a comment to both indicating their relationship so we
don't accidentally modify the enum without updating the dependent string
table.

Otherwise, looks good.

Reviewed-by: Greg Thelen <gthelen@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
