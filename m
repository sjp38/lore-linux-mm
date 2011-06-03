Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 9D48C6B004A
	for <linux-mm@kvack.org>; Fri,  3 Jun 2011 19:09:44 -0400 (EDT)
Date: Sat, 4 Jun 2011 01:09:39 +0200
From: Andrea Righi <arighi@develer.com>
Subject: Re: [PATCH v8 03/12] memcg: add mem_cgroup_mark_inode_dirty()
Message-ID: <20110603230939.GA2073@thinkpad>
References: <1307117538-14317-1-git-send-email-gthelen@google.com>
 <1307117538-14317-4-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1307117538-14317-4-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Vivek Goyal <vgoyal@redhat.com>, Dave Chinner <david@fromorbit.com>

On Fri, Jun 03, 2011 at 09:12:09AM -0700, Greg Thelen wrote:
...
> diff --git a/fs/inode.c b/fs/inode.c
> index ce61a1b..9ecb0bb 100644
> --- a/fs/inode.c
> +++ b/fs/inode.c
> @@ -228,6 +228,9 @@ int inode_init_always(struct super_block *sb, struct inode *inode)
>  	mapping->assoc_mapping = NULL;
>  	mapping->backing_dev_info = &default_backing_dev_info;
>  	mapping->writeback_index = 0;
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +	mapping->i_memcg = 0;
> +#endif

It won't change too much, since it's always 0, but shouldn't we use
I_MEMCG_SHARED by default?

>  
>  	/*
>  	 * If the block_device provides a backing_dev_info for client
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 29c02f6..deabca3 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -645,6 +645,9 @@ struct address_space {
>  	spinlock_t		private_lock;	/* for use by the address_space */
>  	struct list_head	private_list;	/* ditto */
>  	struct address_space	*assoc_mapping;	/* ditto */
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +	unsigned short		i_memcg;	/* css_id of memcg dirtier */
> +#endif
>  } __attribute__((aligned(sizeof(long))));
>  	/*
>  	 * On most architectures that alignment is already the case; but
> @@ -652,6 +655,12 @@ struct address_space {
>  	 * of struct page's "mapping" pointer be used for PAGE_MAPPING_ANON.
>  	 */
>  
> +/*
> + * When an address_space is shared by multiple memcg dirtieres, then i_memcg is
> + * set to this special, wildcard, css_id value (zero).
> + */
> +#define I_MEMCG_SHARED 0
> +
>  struct block_device {
>  	dev_t			bd_dev;  /* not a kdev_t - it's a search key */
>  	int			bd_openers;
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 77e47f5..14b6d67 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -103,6 +103,8 @@ mem_cgroup_prepare_migration(struct page *page,
>  extern void mem_cgroup_end_migration(struct mem_cgroup *mem,
>  	struct page *oldpage, struct page *newpage, bool migration_ok);
>  
> +void mem_cgroup_mark_inode_dirty(struct inode *inode);
> +
>  /*
>   * For memory reclaim.
>   */
> @@ -273,6 +275,10 @@ static inline void mem_cgroup_end_migration(struct mem_cgroup *mem,
>  {
>  }
>  
> +static inline void mem_cgroup_mark_inode_dirty(struct inode *inode)
> +{
> +}
> +
>  static inline int mem_cgroup_get_reclaim_priority(struct mem_cgroup *mem)
>  {
>  	return 0;
> diff --git a/include/trace/events/memcontrol.h b/include/trace/events/memcontrol.h
> new file mode 100644
> index 0000000..781ef9fc
> --- /dev/null
> +++ b/include/trace/events/memcontrol.h
> @@ -0,0 +1,32 @@
> +#undef TRACE_SYSTEM
> +#define TRACE_SYSTEM memcontrol
> +
> +#if !defined(_TRACE_MEMCONTROL_H) || defined(TRACE_HEADER_MULTI_READ)
> +#define _TRACE_MEMCONTROL_H
> +
> +#include <linux/types.h>
> +#include <linux/tracepoint.h>
> +
> +TRACE_EVENT(mem_cgroup_mark_inode_dirty,
> +	TP_PROTO(struct inode *inode),
> +
> +	TP_ARGS(inode),
> +
> +	TP_STRUCT__entry(
> +		__field(unsigned long, ino)
> +		__field(unsigned short, css_id)
> +		),
> +
> +	TP_fast_assign(
> +		__entry->ino = inode->i_ino;
> +		__entry->css_id =
> +			inode->i_mapping ? inode->i_mapping->i_memcg : 0;
> +		),
> +
> +	TP_printk("ino=%ld css_id=%d", __entry->ino, __entry->css_id)
> +)
> +
> +#endif /* _TRACE_MEMCONTROL_H */
> +
> +/* This part must be outside protection */
> +#include <trace/define_trace.h>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index bf642b5..e83ef74 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -54,6 +54,9 @@
>  
>  #include <trace/events/vmscan.h>
>  
> +#define CREATE_TRACE_POINTS
> +#include <trace/events/memcontrol.h>
> +
>  struct cgroup_subsys mem_cgroup_subsys __read_mostly;
>  #define MEM_CGROUP_RECLAIM_RETRIES	5
>  struct mem_cgroup *root_mem_cgroup __read_mostly;
> @@ -1122,6 +1125,27 @@ static int calc_inactive_ratio(struct mem_cgroup *memcg, unsigned long *present_
>  	return inactive_ratio;
>  }
>  
> +/*
> + * Mark the current task's memcg as the memcg associated with inode.  Note: the
> + * recorded cgroup css_id is not guaranteed to remain correct.  The current task
> + * may be moved to another cgroup.  The memcg may also be deleted before the
> + * caller has time to use the i_memcg.
> + */
> +void mem_cgroup_mark_inode_dirty(struct inode *inode)
> +{
> +	struct mem_cgroup *mem;
> +	unsigned short id;
> +
> +	rcu_read_lock();
> +	mem = mem_cgroup_from_task(current);
> +	id = mem ? css_id(&mem->css) : 0;

Ditto.

> +	rcu_read_unlock();
> +
> +	inode->i_mapping->i_memcg = id;
> +
> +	trace_mem_cgroup_mark_inode_dirty(inode);
> +}
> +
>  int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg)
>  {
>  	unsigned long active;
> -- 
> 1.7.3.1

Thanks,
-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
