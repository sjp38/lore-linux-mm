Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8B1CE6B0069
	for <linux-mm@kvack.org>; Sat, 21 Oct 2017 23:21:41 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id q4so14898317oic.12
        for <linux-mm@kvack.org>; Sat, 21 Oct 2017 20:21:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t16si1241775oih.239.2017.10.21.20.21.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 21 Oct 2017 20:21:40 -0700 (PDT)
Date: Sun, 22 Oct 2017 06:21:38 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v1 2/3] virtio-balloon: deflate up to oom_pages on OOM
Message-ID: <20171022062119-mutt-send-email-mst@kernel.org>
References: <1508500466-21165-1-git-send-email-wei.w.wang@intel.com>
 <1508500466-21165-3-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1508500466-21165-3-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: penguin-kernel@I-love.SAKURA.ne.jp, mhocko@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org

On Fri, Oct 20, 2017 at 07:54:25PM +0800, Wei Wang wrote:
> The current implementation only deflates 256 pages even when a user
> specifies more than that via the oom_pages module param. This patch
> enables the deflating of up to oom_pages pages if there are enough
> inflated pages.
> 
> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

This seems reasonable. Does this by itself help?


> ---
>  drivers/virtio/virtio_balloon.c | 14 +++++++++-----
>  1 file changed, 9 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index 1ecd15a..ab55cf8 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -43,8 +43,8 @@
>  #define OOM_VBALLOON_DEFAULT_PAGES 256
>  #define VIRTBALLOON_OOM_NOTIFY_PRIORITY 80
>  
> -static int oom_pages = OOM_VBALLOON_DEFAULT_PAGES;
> -module_param(oom_pages, int, S_IRUSR | S_IWUSR);
> +static unsigned int oom_pages = OOM_VBALLOON_DEFAULT_PAGES;
> +module_param(oom_pages, uint, 0600);
>  MODULE_PARM_DESC(oom_pages, "pages to free on OOM");
>  
>  #ifdef CONFIG_BALLOON_COMPACTION
> @@ -359,16 +359,20 @@ static int virtballoon_oom_notify(struct notifier_block *self,
>  {
>  	struct virtio_balloon *vb;
>  	unsigned long *freed;
> -	unsigned num_freed_pages;
> +	unsigned int npages = oom_pages;
>  
>  	vb = container_of(self, struct virtio_balloon, nb);
>  	if (!virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
>  		return NOTIFY_OK;
>  
>  	freed = parm;
> -	num_freed_pages = leak_balloon(vb, oom_pages);
> +
> +	/* Don't deflate more than the number of inflated pages */
> +	while (npages && atomic64_read(&vb->num_pages))
> +		npages -= leak_balloon(vb, npages);
> +
>  	update_balloon_size(vb);
> -	*freed += num_freed_pages;
> +	*freed += oom_pages - npages;
>  
>  	return NOTIFY_OK;
>  }
> -- 
> 2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
