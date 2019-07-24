Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF17AC76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 19:47:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A3945217D4
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 19:47:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A3945217D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 39F9D6B0007; Wed, 24 Jul 2019 15:47:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 32A248E0002; Wed, 24 Jul 2019 15:47:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C9146B000A; Wed, 24 Jul 2019 15:47:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id E6F416B0007
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 15:47:27 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id b139so40212251qkc.21
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 12:47:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=zQFfFaN4S19jIM07tkNyIGV4UlSrkqk8y/x0NsRJHfo=;
        b=Nbp0rkm85J0OoHsGQUDZw5I+U5/SDjpdN0T6C2xP5rtMf2PzwsikrS65xhT6ijG4fd
         KkxROsYUdE8yxtp3GAfLjRM+bvoTuezJQQpC49nztrSi0NK9SzXlvd85Qi/Lj/N9cp6a
         w3cs72sHDCJ83ruHQQ0edm3AY9i1Xy3LRsSJ20K6jRobjWEv8RvW4+cFcQJbRNVDzXII
         qaoMr8mFFU2i+bch34Qy5WQWPQjHjm4YmmkbPxDTJE0PakzYN7DeBjmzHduwNH4XdREc
         HwQQ1wz1Ux98H79HKoujM3Z320ZSVmYoan70BlUcc2YEHlFN5IuW4oXA8iDjATtRYpAV
         vJ9w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX0IcbjpSBYmez9rvBoQ5uIH/8YaUArX6E0KcZScPumeiPwLSlQ
	7LxnNbTd9DvLDtlRv+qTI9JEjzm9baxO6Y6gpGkDc1iLwZpiXfxb+aylMyyft2+cdk0jWARJMr9
	hUz9UFA5fFORNbRRj50w/VZNIiE5tja9fMUzoV27Ze3mwbJENUNqpMCopbdLJcURARg==
X-Received: by 2002:a05:620a:102e:: with SMTP id a14mr56749570qkk.7.1563997647663;
        Wed, 24 Jul 2019 12:47:27 -0700 (PDT)
X-Received: by 2002:a05:620a:102e:: with SMTP id a14mr56749554qkk.7.1563997646710;
        Wed, 24 Jul 2019 12:47:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563997646; cv=none;
        d=google.com; s=arc-20160816;
        b=ngBo9naD0NTx+E6dvhpkt4xBt0WqjXM/5GC4seEGhJBtJ1xg1Z14bpy1vSl8PXz6Zq
         A4qKVfLfBuvf6diofhYBGGEGxNi52WKOziTMQtZ4M6vWaynQD31GkpStWVuvC0Otn3Iz
         0BCOT8FpzFWZkSc0jUas2occzAUAS9aGQo/xE9NHuE1fmx0twZNlerImoaJ4Yp99Wvvx
         JOoqpYrMbvMuPMYt1/5K21ZMubjgTU3TjOR2zuAMw+wduvk/pa2FH2u0ZhY+hWwN11O0
         P5CLVHuzBRRUWyDP3v8BhEB0c1XeVc7pR0Kx6r1DEV1pP898yKzx9DZvehPgkP6KcDHj
         3R9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=zQFfFaN4S19jIM07tkNyIGV4UlSrkqk8y/x0NsRJHfo=;
        b=JrNJrZ8D11f4Ffx+dR1ktJbzBp1fFjhW0hQI/RHE4s8qtY0LmcUo/vYYIYln0r+p2b
         W7YW/WrOQ8AGXE3b1i5k/gNtKG4LRjhu/I8dM5X0A4roHknXdQNqglosCPnKQ0mGheif
         JphMpvuxJbYuGI8sNIRZTOZLSwPMnop95434l3Bm5I5xc3Cfjx2YLzVBhLsXDbf4SnJ2
         Gty7U2HydJBci1kWYSb7piVjTfCklC+vOP5gdp5sr73TFPepJvrhwRfa1bMLtCc4LvIS
         rnSrwh6Mw5P0sU53PfLW44uIVr/PddP5/03yWxt5cAjQ4ntxKgJ5LXTGORsR6MdIeGjQ
         dgKg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p23sor40079694qve.39.2019.07.24.12.47.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 12:47:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqw2dwpoJegyks6v2Bb6MSdjFwoLUS2vTs3LkTq1TKtkmQD76uS9WlH9tR7ttNVa1xL82b37Ag==
X-Received: by 2002:ad4:55a9:: with SMTP id f9mr60419979qvx.133.1563997646338;
        Wed, 24 Jul 2019 12:47:26 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id t197sm20634053qke.2.2019.07.24.12.47.20
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 24 Jul 2019 12:47:25 -0700 (PDT)
Date: Wed, 24 Jul 2019 15:47:18 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Nitesh Narayan Lal <nitesh@redhat.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	pbonzini@redhat.com, lcapitulino@redhat.com, pagupta@redhat.com,
	wei.w.wang@intel.com, yang.zhang.wz@gmail.com, riel@surriel.com,
	david@redhat.com, dodgen@google.com, konrad.wilk@oracle.com,
	dhildenb@redhat.com, aarcange@redhat.com, alexander.duyck@gmail.com,
	john.starks@microsoft.com, dave.hansen@intel.com, mhocko@suse.com
Subject: Re: [RFC][Patch v11 2/2] virtio-balloon: page_hinting: reporting to
 the host
Message-ID: <20190724153951-mutt-send-email-mst@kernel.org>
References: <20190710195158.19640-1-nitesh@redhat.com>
 <20190710195158.19640-3-nitesh@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190710195158.19640-3-nitesh@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 10, 2019 at 03:51:58PM -0400, Nitesh Narayan Lal wrote:
> Enables the kernel to negotiate VIRTIO_BALLOON_F_HINTING feature with the
> host. If it is available and page_hinting_flag is set to true, page_hinting
> is enabled and its callbacks are configured along with the max_pages count
> which indicates the maximum number of pages that can be isolated and hinted
> at a time. Currently, only free pages of order >= (MAX_ORDER - 2) are
> reported. To prevent any false OOM max_pages count is set to 16.
> 
> By default page_hinting feature is enabled and gets loaded as soon
> as the virtio-balloon driver is loaded. However, it could be disabled
> by writing the page_hinting_flag which is a virtio-balloon parameter.
> 
> Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>
> ---
>  drivers/virtio/Kconfig              |  1 +
>  drivers/virtio/virtio_balloon.c     | 91 ++++++++++++++++++++++++++++-
>  include/uapi/linux/virtio_balloon.h | 11 ++++
>  3 files changed, 102 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/virtio/Kconfig b/drivers/virtio/Kconfig
> index 023fc3bc01c6..dcc0cb4269a5 100644
> --- a/drivers/virtio/Kconfig
> +++ b/drivers/virtio/Kconfig
> @@ -47,6 +47,7 @@ config VIRTIO_BALLOON
>  	tristate "Virtio balloon driver"
>  	depends on VIRTIO
>  	select MEMORY_BALLOON
> +	select PAGE_HINTING
>  	---help---
>  	 This driver supports increasing and decreasing the amount
>  	 of memory within a KVM guest.
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index 44339fc87cc7..1fb0eb0b2c20 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -18,6 +18,7 @@
>  #include <linux/mm.h>
>  #include <linux/mount.h>
>  #include <linux/magic.h>
> +#include <linux/page_hinting.h>
>  
>  /*
>   * Balloon device works in 4K page units.  So each page is pointed to by
> @@ -35,6 +36,12 @@
>  /* The size of a free page block in bytes */
>  #define VIRTIO_BALLOON_FREE_PAGE_SIZE \
>  	(1 << (VIRTIO_BALLOON_FREE_PAGE_ORDER + PAGE_SHIFT))
> +/* Number of isolated pages to be reported to the host at a time.
> + * TODO:
> + * 1. Set it via host.
> + * 2. Find an optimal value for this.
> + */
> +#define PAGE_HINTING_MAX_PAGES	16
>  
>  #ifdef CONFIG_BALLOON_COMPACTION
>  static struct vfsmount *balloon_mnt;
> @@ -45,6 +52,7 @@ enum virtio_balloon_vq {
>  	VIRTIO_BALLOON_VQ_DEFLATE,
>  	VIRTIO_BALLOON_VQ_STATS,
>  	VIRTIO_BALLOON_VQ_FREE_PAGE,
> +	VIRTIO_BALLOON_VQ_HINTING,
>  	VIRTIO_BALLOON_VQ_MAX
>  };
>  
> @@ -54,7 +62,8 @@ enum virtio_balloon_config_read {
>  
>  struct virtio_balloon {
>  	struct virtio_device *vdev;
> -	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *free_page_vq;
> +	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *free_page_vq,
> +			 *hinting_vq;
>  
>  	/* Balloon's own wq for cpu-intensive work items */
>  	struct workqueue_struct *balloon_wq;
> @@ -112,6 +121,9 @@ struct virtio_balloon {
>  
>  	/* To register a shrinker to shrink memory upon memory pressure */
>  	struct shrinker shrinker;
> +
> +	/* Array object pointing at the isolated pages ready for hinting */
> +	struct isolated_memory isolated_pages[PAGE_HINTING_MAX_PAGES];
>  };
>  
>  static struct virtio_device_id id_table[] = {
> @@ -119,6 +131,66 @@ static struct virtio_device_id id_table[] = {
>  	{ 0 },
>  };
>  
> +static struct page_hinting_config page_hinting_conf;
> +bool page_hinting_flag = true;
> +struct virtio_balloon *hvb;
> +module_param(page_hinting_flag, bool, 0444);
> +MODULE_PARM_DESC(page_hinting_flag, "Enable page hinting");
> +
> +static int page_hinting_report(void)
> +{
> +	struct virtqueue *vq = hvb->hinting_vq;
> +	struct scatterlist sg;
> +	int err = 0, unused;
> +
> +	mutex_lock(&hvb->balloon_lock);
> +	sg_init_one(&sg, hvb->isolated_pages, sizeof(hvb->isolated_pages[0]) *
> +		    PAGE_HINTING_MAX_PAGES);
> +	err = virtqueue_add_outbuf(vq, &sg, 1, hvb, GFP_KERNEL);

In Alex's patch, I really like it that he's passing pages as sg
entries. IMHO that's both cleaner and allows seamless
support for arbitrary page sizes.

In particular ....

> +	if (!err)
> +		virtqueue_kick(hvb->hinting_vq);
> +	wait_event(hvb->acked, virtqueue_get_buf(vq, &unused));
> +	mutex_unlock(&hvb->balloon_lock);
> +	return err;
> +}
> +
> +void hint_pages(struct list_head *pages)
> +{
> +	struct device *dev = &hvb->vdev->dev;
> +	struct page *page, *next;
> +	int idx = 0, order, err;
> +	unsigned long pfn;
> +
> +	list_for_each_entry_safe(page, next, pages, lru) {
> +		pfn = page_to_pfn(page);
> +		order = page_private(page);
> +		hvb->isolated_pages[idx].phys_addr = pfn << PAGE_SHIFT;
> +		hvb->isolated_pages[idx].size = (1 << order) * PAGE_SIZE;
> +		idx++;

... passing native endian-ness values to host creates pain for
cross-endian configurations.

> +	}
> +	err = page_hinting_report();
> +	if (err < 0)
> +		dev_err(dev, "Failed to hint pages, err = %d\n", err);
> +}
> +
> +static void page_hinting_init(struct virtio_balloon *vb)
> +{
> +	struct device *dev = &vb->vdev->dev;
> +	int err;
> +
> +	page_hinting_conf.hint_pages = hint_pages;
> +	page_hinting_conf.max_pages = PAGE_HINTING_MAX_PAGES;
> +	err = page_hinting_enable(&page_hinting_conf);
> +	if (err < 0) {
> +		dev_err(dev, "Failed to enable page-hinting, err = %d\n", err);

It would be nicer to disable the feature bit then, or fail probe
completely.

> +		page_hinting_flag = false;
> +		page_hinting_conf.hint_pages = NULL;
> +		page_hinting_conf.max_pages = 0;
> +		return;
> +	}
> +	hvb = vb;
> +}
> +
>  static u32 page_to_balloon_pfn(struct page *page)
>  {
>  	unsigned long pfn = page_to_pfn(page);
> @@ -475,6 +547,7 @@ static int init_vqs(struct virtio_balloon *vb)
>  	names[VIRTIO_BALLOON_VQ_DEFLATE] = "deflate";
>  	names[VIRTIO_BALLOON_VQ_STATS] = NULL;
>  	names[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
> +	names[VIRTIO_BALLOON_VQ_HINTING] = NULL;
>  
>  	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
>  		names[VIRTIO_BALLOON_VQ_STATS] = "stats";
> @@ -486,11 +559,18 @@ static int init_vqs(struct virtio_balloon *vb)
>  		callbacks[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
>  	}
>  
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING)) {
> +		names[VIRTIO_BALLOON_VQ_HINTING] = "hinting_vq";
> +		callbacks[VIRTIO_BALLOON_VQ_HINTING] = balloon_ack;
> +	}
>  	err = vb->vdev->config->find_vqs(vb->vdev, VIRTIO_BALLOON_VQ_MAX,
>  					 vqs, callbacks, names, NULL, NULL);
>  	if (err)
>  		return err;
>  
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING))
> +		vb->hinting_vq = vqs[VIRTIO_BALLOON_VQ_HINTING];
> +
>  	vb->inflate_vq = vqs[VIRTIO_BALLOON_VQ_INFLATE];
>  	vb->deflate_vq = vqs[VIRTIO_BALLOON_VQ_DEFLATE];
>  	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
> @@ -929,6 +1009,9 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  		if (err)
>  			goto out_del_balloon_wq;
>  	}
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING) &&
> +	    page_hinting_flag)
> +		page_hinting_init(vb);
>  	virtio_device_ready(vdev);
>  
>  	if (towards_target(vb))
> @@ -976,6 +1059,10 @@ static void virtballoon_remove(struct virtio_device *vdev)
>  		destroy_workqueue(vb->balloon_wq);
>  	}
>  
> +	if (!page_hinting_flag) {
> +		hvb = NULL;
> +		page_hinting_disable();
> +	}
>  	remove_common(vb);
>  #ifdef CONFIG_BALLOON_COMPACTION
>  	if (vb->vb_dev_info.inode)
> @@ -1030,8 +1117,10 @@ static unsigned int features[] = {
>  	VIRTIO_BALLOON_F_MUST_TELL_HOST,
>  	VIRTIO_BALLOON_F_STATS_VQ,
>  	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
> +	VIRTIO_BALLOON_F_HINTING,
>  	VIRTIO_BALLOON_F_FREE_PAGE_HINT,
>  	VIRTIO_BALLOON_F_PAGE_POISON,
> +	VIRTIO_BALLOON_F_HINTING,
>  };
>  
>  static struct virtio_driver virtio_balloon_driver = {
> diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
> index a1966cd7b677..29eed0ec83d3 100644
> --- a/include/uapi/linux/virtio_balloon.h
> +++ b/include/uapi/linux/virtio_balloon.h
> @@ -36,6 +36,8 @@
>  #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
>  #define VIRTIO_BALLOON_F_FREE_PAGE_HINT	3 /* VQ to report free pages */
>  #define VIRTIO_BALLOON_F_PAGE_POISON	4 /* Guest is using page poisoning */
> +/* TODO: Find a better name to avoid any confusion with FREE_PAGE_HINT */
> +#define VIRTIO_BALLOON_F_HINTING	5 /* Page hinting virtqueue */
>  
>  /* Size of a PFN in the balloon interface. */
>  #define VIRTIO_BALLOON_PFN_SHIFT 12
> @@ -108,4 +110,13 @@ struct virtio_balloon_stat {
>  	__virtio64 val;
>  } __attribute__((packed));
>  
> +/*
> + * struct isolated_memory- holds the pages which will be reported to the host.
> + * @phys_add:	physical address associated with a page.
> + * @size:	total size of memory to be reported.
> + */
> +struct isolated_memory {
> +	__virtio64 phys_addr;
> +	__virtio64 size;
> +};
>  #endif /* _LINUX_VIRTIO_BALLOON_H */
> -- 
> 2.21.0

