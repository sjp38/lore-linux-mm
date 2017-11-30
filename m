Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0FA196B0069
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 05:36:35 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id h12so3175909oti.8
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 02:36:35 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id r44si1358539ote.142.2017.11.30.02.36.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 30 Nov 2017 02:36:34 -0800 (PST)
Subject: Re: [PATCH v18 07/10] virtio-balloon: VIRTIO_BALLOON_F_SG
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1511963726-34070-1-git-send-email-wei.w.wang@intel.com>
	<1511963726-34070-8-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1511963726-34070-8-git-send-email-wei.w.wang@intel.com>
Message-Id: <201711301935.EHF86450.MSFLOOHFJtFOQV@I-love.SAKURA.ne.jp>
Date: Thu, 30 Nov 2017 19:35:55 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wei.w.wang@intel.com
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

Wei Wang wrote:
> +static inline int xb_set_page(struct virtio_balloon *vb,
> +			       struct page *page,
> +			       unsigned long *pfn_min,
> +			       unsigned long *pfn_max)
> +{
> +	unsigned long pfn = page_to_pfn(page);
> +	int ret;
> +
> +	*pfn_min = min(pfn, *pfn_min);
> +	*pfn_max = max(pfn, *pfn_max);
> +
> +	do {
> +		ret = xb_preload_and_set_bit(&vb->page_xb, pfn,
> +					     GFP_NOWAIT | __GFP_NOWARN);

It is a bit of pity that __GFP_NOWARN here is applied to only xb_preload().
Memory allocation by xb_set_bit() will after all emit warnings. Maybe

  xb_init(&vb->page_xb);
  vb->page_xb.gfp_mask |= __GFP_NOWARN;

is tolerable? Or, unconditionally apply __GFP_NOWARN at xb_init()?

  static inline void xb_init(struct xb *xb)
  {
          INIT_RADIX_TREE(&xb->xbrt, IDR_RT_MARKER | GFP_NOWAIT);
  }

> +	} while (unlikely(ret == -EAGAIN));
> +
> +	return ret;
> +}
> +



> @@ -172,11 +283,18 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
>  	vb->num_pfns = 0;
>  
>  	while ((page = balloon_page_pop(&pages))) {
> +		if (use_sg) {
> +			if (xb_set_page(vb, page, &pfn_min, &pfn_max) < 0) {
> +				__free_page(page);
> +				break;

You cannot "break;" without consuming all pages in "pages".

> +			}
> +		} else {
> +			set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
> +		}
> +
>  		balloon_page_enqueue(&vb->vb_dev_info, page);
>  
>  		vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE;
> -
> -		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
>  		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
>  		if (!virtio_has_feature(vb->vdev,
>  					VIRTIO_BALLOON_F_DEFLATE_ON_OOM))



> @@ -212,9 +334,12 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
>  	struct page *page;
>  	struct balloon_dev_info *vb_dev_info = &vb->vb_dev_info;
>  	LIST_HEAD(pages);
> +	bool use_sg = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_SG);

You can pass use_sg as an argument to leak_balloon(). Then, you won't
need to define leak_balloon_sg_oom(). Since xbitmap allocation does not
use __GFP_DIRECT_RECLAIM, it is safe to reuse leak_balloon() for OOM path.
Just be sure to pass use_sg == false because memory allocation for
use_sg == true likely fails when called from OOM path. (But trying
use_sg == true for OOM path and then fallback to use_sg == false is not bad?)

> +	unsigned long pfn_max = 0, pfn_min = ULONG_MAX;
>  
> -	/* We can only do one array worth at a time. */
> -	num = min(num, ARRAY_SIZE(vb->pfns));
> +	/* Traditionally, we can only do one array worth at a time. */
> +	if (!use_sg)
> +		num = min(num, ARRAY_SIZE(vb->pfns));
>  
>  	mutex_lock(&vb->balloon_lock);
>  	/* We can't release more pages than taken */



> diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
> index 343d7dd..37780a7 100644
> --- a/include/uapi/linux/virtio_balloon.h
> +++ b/include/uapi/linux/virtio_balloon.h
> @@ -34,6 +34,7 @@
>  #define VIRTIO_BALLOON_F_MUST_TELL_HOST	0 /* Tell before reclaiming pages */
>  #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
>  #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
> +#define VIRTIO_BALLOON_F_SG		3 /* Use sg instead of PFN lists */

Want more explicit comment that PFN lists will be used on OOM and therefore
the host side must be prepared for both sg and PFN lists even if negotiated?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
