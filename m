Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id B90FA6B000D
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 05:00:46 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id g13-v6so1668266pgv.11
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 02:00:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x5-v6si10530687pgc.210.2018.07.30.02.00.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jul 2018 02:00:45 -0700 (PDT)
Date: Mon, 30 Jul 2018 11:00:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 2/2] virtio_balloon: replace oom notifier with shrinker
Message-ID: <20180730090041.GC24267@dhcp22.suse.cz>
References: <1532683495-31974-1-git-send-email-wei.w.wang@intel.com>
 <1532683495-31974-3-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1532683495-31974-3-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, mst@redhat.com, akpm@linux-foundation.org

On Fri 27-07-18 17:24:55, Wei Wang wrote:
> The OOM notifier is getting deprecated to use for the reasons mentioned
> here by Michal Hocko: https://lkml.org/lkml/2018/7/12/314
> 
> This patch replaces the virtio-balloon oom notifier with a shrinker
> to release balloon pages on memory pressure.

It would be great to document the replacement. This is not a small
change...

> In addition, the bug in the replaced virtballoon_oom_notify that only
> VIRTIO_BALLOON_ARRAY_PFNS_MAX (i.e 256) balloon pages can be freed
> though the user has specified more than that number is fixed in the
> shrinker_scan function.
> 
> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  drivers/virtio/virtio_balloon.c | 115 +++++++++++++++++++++++-----------------
>  1 file changed, 65 insertions(+), 50 deletions(-)
> 
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index 9356a1a..6b2229b 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -27,7 +27,6 @@
>  #include <linux/slab.h>
>  #include <linux/module.h>
>  #include <linux/balloon_compaction.h>
> -#include <linux/oom.h>
>  #include <linux/wait.h>
>  #include <linux/mm.h>
>  #include <linux/mount.h>
> @@ -40,12 +39,12 @@
>   */
>  #define VIRTIO_BALLOON_PAGES_PER_PAGE (unsigned)(PAGE_SIZE >> VIRTIO_BALLOON_PFN_SHIFT)
>  #define VIRTIO_BALLOON_ARRAY_PFNS_MAX 256
> -#define OOM_VBALLOON_DEFAULT_PAGES 256
> +#define DEFAULT_BALLOON_PAGES_TO_SHRINK 256
>  #define VIRTBALLOON_OOM_NOTIFY_PRIORITY 80
>  
> -static int oom_pages = OOM_VBALLOON_DEFAULT_PAGES;
> -module_param(oom_pages, int, S_IRUSR | S_IWUSR);
> -MODULE_PARM_DESC(oom_pages, "pages to free on OOM");
> +static unsigned long balloon_pages_to_shrink = DEFAULT_BALLOON_PAGES_TO_SHRINK;
> +module_param(balloon_pages_to_shrink, ulong, 0600);
> +MODULE_PARM_DESC(balloon_pages_to_shrink, "pages to free on memory presure");
>  
>  #ifdef CONFIG_BALLOON_COMPACTION
>  static struct vfsmount *balloon_mnt;
> @@ -86,8 +85,8 @@ struct virtio_balloon {
>  	/* Memory statistics */
>  	struct virtio_balloon_stat stats[VIRTIO_BALLOON_S_NR];
>  
> -	/* To register callback in oom notifier call chain */
> -	struct notifier_block nb;
> +	/* To register a shrinker to shrink memory upon memory pressure */
> +	struct shrinker shrinker;
>  };
>  
>  static struct virtio_device_id id_table[] = {
> @@ -365,38 +364,6 @@ static void update_balloon_size(struct virtio_balloon *vb)
>  		      &actual);
>  }
>  
> -/*
> - * virtballoon_oom_notify - release pages when system is under severe
> - *			    memory pressure (called from out_of_memory())
> - * @self : notifier block struct
> - * @dummy: not used
> - * @parm : returned - number of freed pages
> - *
> - * The balancing of memory by use of the virtio balloon should not cause
> - * the termination of processes while there are pages in the balloon.
> - * If virtio balloon manages to release some memory, it will make the
> - * system return and retry the allocation that forced the OOM killer
> - * to run.
> - */
> -static int virtballoon_oom_notify(struct notifier_block *self,
> -				  unsigned long dummy, void *parm)
> -{
> -	struct virtio_balloon *vb;
> -	unsigned long *freed;
> -	unsigned num_freed_pages;
> -
> -	vb = container_of(self, struct virtio_balloon, nb);
> -	if (!virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
> -		return NOTIFY_OK;
> -
> -	freed = parm;
> -	num_freed_pages = leak_balloon(vb, oom_pages);
> -	update_balloon_size(vb);
> -	*freed += num_freed_pages;
> -
> -	return NOTIFY_OK;
> -}
> -
>  static void update_balloon_stats_func(struct work_struct *work)
>  {
>  	struct virtio_balloon *vb;
> @@ -548,6 +515,54 @@ static struct file_system_type balloon_fs = {
>  
>  #endif /* CONFIG_BALLOON_COMPACTION */
>  
> +static unsigned long virtio_balloon_shrinker_scan(struct shrinker *shrinker,
> +						  struct shrink_control *sc)
> +{
> +	unsigned long pages_to_free = balloon_pages_to_shrink,
> +		      pages_freed = 0;
> +	struct virtio_balloon *vb = container_of(shrinker,
> +					struct virtio_balloon, shrinker);
> +
> +	/*
> +	 * One invocation of leak_balloon can deflate at most
> +	 * VIRTIO_BALLOON_ARRAY_PFNS_MAX balloon pages, so we call it
> +	 * multiple times to deflate pages till reaching
> +	 * balloon_pages_to_shrink pages.
> +	 */
> +	while (vb->num_pages && pages_to_free) {
> +		pages_to_free = balloon_pages_to_shrink - pages_freed;
> +		pages_freed += leak_balloon(vb, pages_to_free);
> +	}
> +	update_balloon_size(vb);
> +
> +	return pages_freed / VIRTIO_BALLOON_PAGES_PER_PAGE;
> +}
> +
> +static unsigned long virtio_balloon_shrinker_count(struct shrinker *shrinker,
> +						   struct shrink_control *sc)
> +{
> +	struct virtio_balloon *vb = container_of(shrinker,
> +					struct virtio_balloon, shrinker);
> +
> +	return min_t(unsigned long, vb->num_pages, balloon_pages_to_shrink) /
> +	       VIRTIO_BALLOON_PAGES_PER_PAGE;
> +}
> +
> +static void virtio_balloon_unregister_shrinker(struct virtio_balloon *vb)
> +{
> +	unregister_shrinker(&vb->shrinker);
> +}
> +
> +static int virtio_balloon_register_shrinker(struct virtio_balloon *vb)
> +{
> +	vb->shrinker.scan_objects = virtio_balloon_shrinker_scan;
> +	vb->shrinker.count_objects = virtio_balloon_shrinker_count;
> +	vb->shrinker.batch = 0;
> +	vb->shrinker.seeks = DEFAULT_SEEKS;
> +
> +	return register_shrinker(&vb->shrinker);
> +}
> +
>  static int virtballoon_probe(struct virtio_device *vdev)
>  {
>  	struct virtio_balloon *vb;
> @@ -580,17 +595,10 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  	if (err)
>  		goto out_free_vb;
>  
> -	vb->nb.notifier_call = virtballoon_oom_notify;
> -	vb->nb.priority = VIRTBALLOON_OOM_NOTIFY_PRIORITY;
> -	err = register_oom_notifier(&vb->nb);
> -	if (err < 0)
> -		goto out_del_vqs;
> -
>  #ifdef CONFIG_BALLOON_COMPACTION
>  	balloon_mnt = kern_mount(&balloon_fs);
>  	if (IS_ERR(balloon_mnt)) {
>  		err = PTR_ERR(balloon_mnt);
> -		unregister_oom_notifier(&vb->nb);
>  		goto out_del_vqs;
>  	}
>  
> @@ -599,13 +607,20 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  	if (IS_ERR(vb->vb_dev_info.inode)) {
>  		err = PTR_ERR(vb->vb_dev_info.inode);
>  		kern_unmount(balloon_mnt);
> -		unregister_oom_notifier(&vb->nb);
>  		vb->vb_dev_info.inode = NULL;
>  		goto out_del_vqs;
>  	}
>  	vb->vb_dev_info.inode->i_mapping->a_ops = &balloon_aops;
>  #endif
> -
> +	/*
> +	 * We continue to use VIRTIO_BALLOON_F_DEFLATE_ON_OOM to decide if a
> +	 * shrinker needs to be registered to relieve memory pressure.
> +	 */
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_DEFLATE_ON_OOM)) {
> +		err = virtio_balloon_register_shrinker(vb);
> +		if (err)
> +			goto out_del_vqs;
> +	}
>  	virtio_device_ready(vdev);
>  
>  	if (towards_target(vb))
> @@ -637,8 +652,8 @@ static void virtballoon_remove(struct virtio_device *vdev)
>  {
>  	struct virtio_balloon *vb = vdev->priv;
>  
> -	unregister_oom_notifier(&vb->nb);
> -
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
> +		virtio_balloon_unregister_shrinker(vb);
>  	spin_lock_irq(&vb->stop_update_lock);
>  	vb->stop_update = true;
>  	spin_unlock_irq(&vb->stop_update_lock);
> -- 
> 2.7.4

-- 
Michal Hocko
SUSE Labs
