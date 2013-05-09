Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 23C2B6B0038
	for <linux-mm@kvack.org>; Thu,  9 May 2013 17:15:27 -0400 (EDT)
Date: Thu, 9 May 2013 18:15:19 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [RFC 2/2] virtio_balloon: auto-ballooning support
Message-ID: <20130509211516.GC16446@optiplex.redhat.com>
References: <1368111229-29847-1-git-send-email-lcapitulino@redhat.com>
 <1368111229-29847-3-git-send-email-lcapitulino@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1368111229-29847-3-git-send-email-lcapitulino@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, riel@redhat.com, mst@redhat.com, amit.shah@redhat.com, anton@enomsg.org

On Thu, May 09, 2013 at 10:53:49AM -0400, Luiz Capitulino wrote:
> Automatic ballooning consists of dynamically adjusting the guest's
> balloon according to memory pressure in the host and in the guest.
> 
> This commit implements the guest side of automatic balloning, which
> basically consists of registering a shrinker callback with the kernel,
> which will try to deflate the guest's balloon by the amount of pages
> being requested. The shrinker callback is only registered if the host
> supports the VIRTIO_BALLOON_F_AUTO_BALLOON feature bit.
> 
> Automatic inflate is performed by the host.
> 
> Here are some numbers. The test-case is to run 35 VMs (1G of RAM each)
> in parallel doing a kernel build. Host has 32GB of RAM and 16GB of swap.
> SWAP IN and SWAP OUT correspond to the number of pages swapped in and
> swapped out, respectively.
> 
> Auto-ballooning disabled:
> 
> RUN  TIME(s)  SWAP IN  SWAP OUT
> 
> 1    634      930980   1588522
> 2    610      627422   1362174
> 3    649      1079847  1616367
> 4    543      953289   1635379
> 5    642      913237   1514000
> 
> Auto-ballooning enabled:
> 
> RUN  TIME(s)  SWAP IN  SWAP OUT
> 
> 1    629      901      12537
> 2    624      981      18506
> 3    626      573      9085
> 4    631      2250     42534
> 5    627      1610     20808
> 
> Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>
> ---

Nice work Luiz! Just allow me a silly question, though. Since your shrinker
doesn't change the balloon target size, as soon as the shrink round finishes the
balloon will re-inflate again, won't it? Doesn't this cause a sort of "balloon
thrashing" scenario, if both guest and host are suffering from memory pressure?


The rest I have for the moment, are only nitpicks :)


>  drivers/virtio/virtio_balloon.c     | 55 +++++++++++++++++++++++++++++++++++++
>  include/uapi/linux/virtio_balloon.h |  1 +
>  2 files changed, 56 insertions(+)
> 
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index 9d5fe2b..f9dcae8 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -71,6 +71,9 @@ struct virtio_balloon
>  	/* Memory statistics */
>  	int need_stats_update;
>  	struct virtio_balloon_stat stats[VIRTIO_BALLOON_S_NR];
> +
> +	/* Memory shrinker */
> +	struct shrinker shrinker;
>  };
>  
>  static struct virtio_device_id id_table[] = {
> @@ -126,6 +129,7 @@ static void set_page_pfns(u32 pfns[], struct page *page)
>  		pfns[i] = page_to_balloon_pfn(page) + i;
>  }
>  
> +/* This function should be called with vb->balloon_mutex held */
>  static void fill_balloon(struct virtio_balloon *vb, size_t num)
>  {
>  	struct balloon_dev_info *vb_dev_info = vb->vb_dev_info;
> @@ -166,6 +170,7 @@ static void release_pages_by_pfn(const u32 pfns[], unsigned int num)
>  	}
>  }
>  
> +/* This function should be called with vb->balloon_mutex held */
>  static void leak_balloon(struct virtio_balloon *vb, size_t num)
>  {
>  	struct page *page;
> @@ -285,6 +290,45 @@ static void update_balloon_size(struct virtio_balloon *vb)
>  			      &actual, sizeof(actual));
>  }
>  
> +static unsigned long balloon_get_nr_pages(const struct virtio_balloon *vb)
> +{
> +	return vb->num_pages / VIRTIO_BALLOON_PAGES_PER_PAGE;
> +}
> +
> +static int balloon_shrinker(struct shrinker *shrinker,struct shrink_control *sc)
> +{
> +	unsigned int nr_pages, new_target;
> +	struct virtio_balloon *vb;
> +
> +	vb = container_of(shrinker, struct virtio_balloon, shrinker);
> +	if (!mutex_trylock(&vb->balloon_lock)) {
> +		return -1;
> +	}
> +
> +	nr_pages = balloon_get_nr_pages(vb);
> +	if (!sc->nr_to_scan || !nr_pages) {
> +		goto out;
> +	}
> +
> +	/*
> +	 * If the current balloon size is greater than the number of
> +	 * pages being reclaimed by the kernel, deflate only the needed
> +	 * amount. Otherwise deflate everything we have.
> +	 */
> +	new_target = 0;
> +	if (nr_pages > sc->nr_to_scan) {
> +		new_target = nr_pages - sc->nr_to_scan;
> +	}
> +

CodingStyle: you don't need the curly-braces for all these single staments above



> +	leak_balloon(vb, new_target);
> +	update_balloon_size(vb);
> +	nr_pages = balloon_get_nr_pages(vb);
> +
> +out:
> +	mutex_unlock(&vb->balloon_lock);
> +	return nr_pages;
> +}
> +
>  static int balloon(void *_vballoon)
>  {
>  	struct virtio_balloon *vb = _vballoon;
> @@ -471,6 +515,13 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  		goto out_del_vqs;
>  	}
>  
> +	memset(&vb->shrinker, 0, sizeof(vb->shrinker));
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_AUTO_BALLOON)) {
> +		vb->shrinker.shrink = balloon_shrinker;
> +		vb->shrinker.seeks = DEFAULT_SEEKS;
> +		register_shrinker(&vb->shrinker);
> +	}
> +
>  	return 0;
>  
>  out_del_vqs:
> @@ -487,6 +538,9 @@ out:
>  
>  static void remove_common(struct virtio_balloon *vb)
>  {
> +	if (vb->shrinker.shrink)
> +		unregister_shrinker(&vb->shrinker);
> +
>  	/* There might be pages left in the balloon: free them. */
>  	mutex_lock(&vb->balloon_lock);
>  	while (vb->num_pages)
> @@ -543,6 +597,7 @@ static int virtballoon_restore(struct virtio_device *vdev)
>  static unsigned int features[] = {
>  	VIRTIO_BALLOON_F_MUST_TELL_HOST,
>  	VIRTIO_BALLOON_F_STATS_VQ,
> +	VIRTIO_BALLOON_F_AUTO_BALLOON,
>  };
>  
>  static struct virtio_driver virtio_balloon_driver = {
> diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
> index 5e26f61..bd378a4 100644
> --- a/include/uapi/linux/virtio_balloon.h
> +++ b/include/uapi/linux/virtio_balloon.h
> @@ -31,6 +31,7 @@
>  /* The feature bitmap for virtio balloon */
>  #define VIRTIO_BALLOON_F_MUST_TELL_HOST	0 /* Tell before reclaiming pages */
>  #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
> +#define VIRTIO_BALLOON_F_AUTO_BALLOON	2 /* Automatic ballooning */
>  
>  /* Size of a PFN in the balloon interface. */
>  #define VIRTIO_BALLOON_PFN_SHIFT 12
> -- 
> 1.8.1.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
