Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 078D76B0032
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 05:42:15 -0400 (EDT)
Received: by mail-ie0-f178.google.com with SMTP id u16so8914090iet.23
        for <linux-mm@kvack.org>; Tue, 18 Jun 2013 02:42:15 -0700 (PDT)
Message-ID: <1371548521.2984.6.camel@ThinkPad-T5421>
Subject: Re: [PATCH v11 25/25] list_lru: dynamically adjust node arrays
From: Li Zhong <lizhongfs@gmail.com>
Reply-To: lizhongfs@gmail.com
Date: Tue, 18 Jun 2013 17:42:01 +0800
In-Reply-To: <1370550898-26711-26-git-send-email-glommer@openvz.org>
References: <1370550898-26711-1-git-send-email-glommer@openvz.org>
	 <1370550898-26711-26-git-send-email-glommer@openvz.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, mgorman@suse.de, david@fromorbit.com, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suze.cz, hannes@cmpxchg.org, hughd@google.com, gthelen@google.com, Dave Chinner <dchinner@redhat.com>

On Fri, 2013-06-07 at 00:34 +0400, Glauber Costa wrote:
> We currently use a compile-time constant to size the node array for the
> list_lru structure. Due to this, we don't need to allocate any memory at
> initialization time. But as a consequence, the structures that contain
> embedded list_lru lists can become way too big (the superblock for
> instance contains two of them).
> 
> This patch aims at ameliorating this situation by dynamically allocating
> the node arrays with the firmware provided nr_node_ids.
> 
> Signed-off-by: Glauber Costa <glommer@openvz.org>
> Cc: Dave Chinner <dchinner@redhat.com>
> Cc: Mel Gorman <mgorman@suse.de>
> ---
>  fs/super.c               | 11 +++++++++--
>  fs/xfs/xfs_buf.c         |  6 +++++-
>  fs/xfs/xfs_qm.c          | 10 ++++++++--
>  include/linux/list_lru.h | 13 ++-----------
>  mm/list_lru.c            | 14 +++++++++++++-
>  5 files changed, 37 insertions(+), 17 deletions(-)
> 
> diff --git a/fs/super.c b/fs/super.c
> index 85a6104..1b6ef7b 100644
> --- a/fs/super.c
> +++ b/fs/super.c
> @@ -199,8 +199,12 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags)
>  		INIT_HLIST_NODE(&s->s_instances);
>  		INIT_HLIST_BL_HEAD(&s->s_anon);
>  		INIT_LIST_HEAD(&s->s_inodes);
> -		list_lru_init(&s->s_dentry_lru);
> -		list_lru_init(&s->s_inode_lru);
> +
> +		if (list_lru_init(&s->s_dentry_lru))
> +			goto err_out;
> +		if (list_lru_init(&s->s_inode_lru))
> +			goto err_out_dentry_lru;
> +
>  		INIT_LIST_HEAD(&s->s_mounts);
>  		init_rwsem(&s->s_umount);
>  		lockdep_set_class(&s->s_umount, &type->s_umount_key);
> @@ -240,6 +244,9 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags)
>  	}
>  out:
>  	return s;
> +
> +err_out_dentry_lru:
> +	list_lru_destroy(&s->s_dentry_lru);
>  err_out:
>  	security_sb_free(s);
>  #ifdef CONFIG_SMP

It seems we also need to call list_lru_destroy() in destroy_super()? 
like below:
 
-----------
diff --git a/fs/super.c b/fs/super.c
index b79e732..06ee3af 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -269,6 +269,8 @@ err_out:
  */
 static inline void destroy_super(struct super_block *s)
 {
+	list_lru_destroy(&s->s_inode_lru);
+	list_lru_destroy(&s->s_dentry_lru);
 #ifdef CONFIG_SMP
 	free_percpu(s->s_files);
 #endif
-----------

Thanks, Zhong

> diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
> index c3f8ea9..9c2b656 100644
> --- a/fs/xfs/xfs_buf.c
> +++ b/fs/xfs/xfs_buf.c
> @@ -1591,6 +1591,7 @@ xfs_free_buftarg(
>  	struct xfs_mount	*mp,
>  	struct xfs_buftarg	*btp)
>  {
> +	list_lru_destroy(&btp->bt_lru);
>  	unregister_shrinker(&btp->bt_shrinker);
>  
>  	if (mp->m_flags & XFS_MOUNT_BARRIER)
> @@ -1665,9 +1666,12 @@ xfs_alloc_buftarg(
>  	if (!btp->bt_bdi)
>  		goto error;
>  
> -	list_lru_init(&btp->bt_lru);
>  	if (xfs_setsize_buftarg_early(btp, bdev))
>  		goto error;
> +
> +	if (list_lru_init(&btp->bt_lru))
> +		goto error;
> +
>  	btp->bt_shrinker.count_objects = xfs_buftarg_shrink_count;
>  	btp->bt_shrinker.scan_objects = xfs_buftarg_shrink_scan;
>  	btp->bt_shrinker.seeks = DEFAULT_SEEKS;
> diff --git a/fs/xfs/xfs_qm.c b/fs/xfs/xfs_qm.c
> index bd6c12a..b840000 100644
> --- a/fs/xfs/xfs_qm.c
> +++ b/fs/xfs/xfs_qm.c
> @@ -781,11 +781,18 @@ xfs_qm_init_quotainfo(
>  
>  	qinf = mp->m_quotainfo = kmem_zalloc(sizeof(xfs_quotainfo_t), KM_SLEEP);
>  
> +	if ((error = list_lru_init(&qinf->qi_lru))) {
> +		kmem_free(qinf);
> +		mp->m_quotainfo = NULL;
> +		return error;
> +	}
> +
>  	/*
>  	 * See if quotainodes are setup, and if not, allocate them,
>  	 * and change the superblock accordingly.
>  	 */
>  	if ((error = xfs_qm_init_quotainos(mp))) {
> +		list_lru_destroy(&qinf->qi_lru);
>  		kmem_free(qinf);
>  		mp->m_quotainfo = NULL;
>  		return error;
> @@ -795,8 +802,6 @@ xfs_qm_init_quotainfo(
>  	INIT_RADIX_TREE(&qinf->qi_gquota_tree, GFP_NOFS);
>  	mutex_init(&qinf->qi_tree_lock);
>  
> -	list_lru_init(&qinf->qi_lru);
> -
>  	/* mutex used to serialize quotaoffs */
>  	mutex_init(&qinf->qi_quotaofflock);
>  
> @@ -884,6 +889,7 @@ xfs_qm_destroy_quotainfo(
>  	qi = mp->m_quotainfo;
>  	ASSERT(qi != NULL);
>  
> +	list_lru_destroy(&qi->qi_lru);
>  	unregister_shrinker(&qi->qi_shrinker);
>  
>  	if (qi->qi_uquotaip) {
> diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
> index 2fe13e1..ff57503 100644
> --- a/include/linux/list_lru.h
> +++ b/include/linux/list_lru.h
> @@ -27,20 +27,11 @@ struct list_lru_node {
>  } ____cacheline_aligned_in_smp;
>  
>  struct list_lru {
> -	/*
> -	 * Because we use a fixed-size array, this struct can be very big if
> -	 * MAX_NUMNODES is big. If this becomes a problem this is fixable by
> -	 * turning this into a pointer and dynamically allocating this to
> -	 * nr_node_ids. This quantity is firwmare-provided, and still would
> -	 * provide room for all nodes at the cost of a pointer lookup and an
> -	 * extra allocation. Because that allocation will most likely come from
> -	 * a different slab cache than the main structure holding this
> -	 * structure, we may very well fail.
> -	 */
> -	struct list_lru_node	node[MAX_NUMNODES];
> +	struct list_lru_node	*node;
>  	nodemask_t		active_nodes;
>  };
>  
> +void list_lru_destroy(struct list_lru *lru);
>  int list_lru_init(struct list_lru *lru);
>  
>  /**
> diff --git a/mm/list_lru.c b/mm/list_lru.c
> index 2822817..700d322 100644
> --- a/mm/list_lru.c
> +++ b/mm/list_lru.c
> @@ -8,6 +8,7 @@
>  #include <linux/module.h>
>  #include <linux/mm.h>
>  #include <linux/list_lru.h>
> +#include <linux/slab.h>
>  
>  bool list_lru_add(struct list_lru *lru, struct list_head *item)
>  {
> @@ -162,9 +163,14 @@ unsigned long list_lru_dispose_all(struct list_lru *lru,
>  int list_lru_init(struct list_lru *lru)
>  {
>  	int i;
> +	size_t size = sizeof(*lru->node) * nr_node_ids;
> +
> +	lru->node = kzalloc(size, GFP_KERNEL);
> +	if (!lru->node)
> +		return -ENOMEM;
>  
>  	nodes_clear(lru->active_nodes);
> -	for (i = 0; i < MAX_NUMNODES; i++) {
> +	for (i = 0; i < nr_node_ids; i++) {
>  		spin_lock_init(&lru->node[i].lock);
>  		INIT_LIST_HEAD(&lru->node[i].list);
>  		lru->node[i].nr_items = 0;
> @@ -172,3 +178,9 @@ int list_lru_init(struct list_lru *lru)
>  	return 0;
>  }
>  EXPORT_SYMBOL_GPL(list_lru_init);
> +
> +void list_lru_destroy(struct list_lru *lru)
> +{
> +	kfree(lru->node);
> +}
> +EXPORT_SYMBOL_GPL(list_lru_destroy);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
