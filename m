Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CE76C76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 19:02:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F1A37217D4
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 19:02:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1A37217D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A2A0A8E0007; Wed, 24 Jul 2019 15:02:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DA9B8E0003; Wed, 24 Jul 2019 15:02:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F0968E0007; Wed, 24 Jul 2019 15:02:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7055D8E0003
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 15:02:11 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id c1so40110513qkl.7
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 12:02:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=ZTWS8N0ZYovAWvxUKcFKwuBIdI+nBoZkPAQur8PGkGY=;
        b=TUs8RriyuZDS3pkXhxDVoRojzhwxqQ80vih/1g9CERgyGzsGnsRk/3feIyD+gxD5iF
         efgSulHAv/74Q65OPy3HQbYw8oTDrbV4Df2Xq1nIT2TiPsjOJOHw6m/Vy+NJz1V4a79Q
         t7goBUmp82IXPLhEqqIfVZ5k5IaeQLgYFcyxvHSt0R8hOtE31AlUSuN13rgwc1KrMqlj
         14qkkG/cRduajfBqwydxHEd6H7D7fjAdJQ7Mq8GM11GLLSup2zIFs6tHMM9geFmDuFtz
         yO84n07TlU+NYgsuipC58Q0rqIAk9dLAfPUXL0MbOLrSrULmONm0IRx6JfXSwqevC8Vy
         EPfw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW40JjPc59vRzmo9+4v5Ayj2H2hGtk8V+LaG6UvebUrPxZNKfeR
	4BiXExekCS8ApCWl42in/aE6Iot4rce6wfTWnyqp4vqULOBklHBhZTOfYkhOpfypgHrxzd1dOjM
	71uUt8AslztammEeKpEFdqIJuEC9o+htaRg1KkBFXC5aKa9VbVpyYJ/5c7LIVyyLs1w==
X-Received: by 2002:a05:620a:15a5:: with SMTP id f5mr55062993qkk.45.1563994931196;
        Wed, 24 Jul 2019 12:02:11 -0700 (PDT)
X-Received: by 2002:a05:620a:15a5:: with SMTP id f5mr55062935qkk.45.1563994930359;
        Wed, 24 Jul 2019 12:02:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563994930; cv=none;
        d=google.com; s=arc-20160816;
        b=IYcP3ebyYMDsnidQYMoc9Ymfz3u3x0hGLTGJqFGXG2tMxv1AZgwoFrbsYY7XfequgH
         CfspVIBq5QQslGKyCl8TR+Kgwyrc1gHRHK+ZLp+UYle8TBZhGdDdhCREBK1wNZ7Luv5E
         0BYP7EZ0XbxXp16TkEwVKt+ybAf/l1ZI2pawlDY+yEiPEAkqq8IA2BZEBN6QjH0Urq0t
         WWqKFEfpL6WbO7eUizKunvaSuJDOdc5PfflatbTc8CAnF/FctBdSJj/URQwjjkB1gyIt
         M+XEpiF2Du3jqxzD1kDtTG95xfDMIKYn4dKpooCxmvjQYuyRUTbEOgXyjbQY+pYJh32I
         lVzg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=ZTWS8N0ZYovAWvxUKcFKwuBIdI+nBoZkPAQur8PGkGY=;
        b=OwKK4VWQniB3YCOX6G1kEMYm7LkFc0WjBmXqlg1WukKt2xcKH5x4Qvb1l5grgfLa+t
         ore2PnBmzlK9iQV3cV0+4zniXsEe1NN5POZ3BNzCU3XvxR76hJ9IfdZjydDR8ECCB3pl
         y/TQYC55ayolyLY1QH9oTKotSwSusTZMx1m6F0hfhMTE05AxtCij/kuO0IDfZZ0crIUY
         s5KtG59N+YdTY+oAcbj1xc9I9gu1Q3KTydfKeZeT0frSfr7ErnaonJcw1vLgbHj7uvFr
         sUY1YI8fhTP2c9rQfltZU1O/8Z8n36ILhI62Ug2XnYb902L8ZrTVi5AxT80TisfD98li
         b5UQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z1sor27138811qkl.179.2019.07.24.12.02.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 12:02:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwRtlm/ak/lFZ3jrdogeKnDeTPB9p/8f2vOBtnnv4oQjSUmOnbiWlS/vaf8DuMEsegAll/NrA==
X-Received: by 2002:a37:743:: with SMTP id 64mr54363029qkh.175.1563994930046;
        Wed, 24 Jul 2019 12:02:10 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id u16sm24131691qte.32.2019.07.24.12.02.03
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 24 Jul 2019 12:02:08 -0700 (PDT)
Date: Wed, 24 Jul 2019 15:02:00 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com,
	dave.hansen@intel.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, akpm@linux-foundation.org,
	yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
	konrad.wilk@oracle.com, lcapitulino@redhat.com,
	wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com,
	dan.j.williams@intel.com, alexander.h.duyck@linux.intel.com
Subject: Re: [PATCH v2 5/5] virtio-balloon: Add support for providing page
 hints to host
Message-ID: <20190724143902-mutt-send-email-mst@kernel.org>
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
 <20190724170514.6685.17161.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190724170514.6685.17161.stgit@localhost.localdomain>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 10:05:14AM -0700, Alexander Duyck wrote:
> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> 
> Add support for the page hinting feature provided by virtio-balloon.
> Hinting differs from the regular balloon functionality in that is is
> much less durable than a standard memory balloon. Instead of creating a
> list of pages that cannot be accessed the pages are only inaccessible
> while they are being indicated to the virtio interface. Once the
> interface has acknowledged them they are placed back into their respective
> free lists and are once again accessible by the guest system.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>

Looking at the design, it seems that hinted pages can immediately be
reused. I wonder how we can efficiently support this
with kvm when poisoning is in effect. Of course we can just
ignore the poison. However it seems cleaner to
1. verify page is poisoned with the correct value
2. fill the page with the correct value on fault

Requirement 2 requires some kind of madvise that
will save the poison e.g. in the VMA.

Not a blocker for sure ... 


> ---
>  drivers/virtio/Kconfig              |    1 +
>  drivers/virtio/virtio_balloon.c     |   47 +++++++++++++++++++++++++++++++++++
>  include/uapi/linux/virtio_balloon.h |    1 +
>  3 files changed, 49 insertions(+)
> 
> diff --git a/drivers/virtio/Kconfig b/drivers/virtio/Kconfig
> index 078615cf2afc..d45556ae1f81 100644
> --- a/drivers/virtio/Kconfig
> +++ b/drivers/virtio/Kconfig
> @@ -58,6 +58,7 @@ config VIRTIO_BALLOON
>  	tristate "Virtio balloon driver"
>  	depends on VIRTIO
>  	select MEMORY_BALLOON
> +	select PAGE_HINTING
>  	---help---
>  	 This driver supports increasing and decreasing the amount
>  	 of memory within a KVM guest.
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index 226fbb995fb0..dee9f8f3ad09 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -19,6 +19,7 @@
>  #include <linux/mount.h>
>  #include <linux/magic.h>
>  #include <linux/pseudo_fs.h>
> +#include <linux/page_hinting.h>
>  
>  /*
>   * Balloon device works in 4K page units.  So each page is pointed to by
> @@ -27,6 +28,7 @@
>   */
>  #define VIRTIO_BALLOON_PAGES_PER_PAGE (unsigned)(PAGE_SIZE >> VIRTIO_BALLOON_PFN_SHIFT)
>  #define VIRTIO_BALLOON_ARRAY_PFNS_MAX 256
> +#define VIRTIO_BALLOON_ARRAY_HINTS_MAX	32
>  #define VIRTBALLOON_OOM_NOTIFY_PRIORITY 80
>  
>  #define VIRTIO_BALLOON_FREE_PAGE_ALLOC_FLAG (__GFP_NORETRY | __GFP_NOWARN | \
> @@ -46,6 +48,7 @@ enum virtio_balloon_vq {
>  	VIRTIO_BALLOON_VQ_DEFLATE,
>  	VIRTIO_BALLOON_VQ_STATS,
>  	VIRTIO_BALLOON_VQ_FREE_PAGE,
> +	VIRTIO_BALLOON_VQ_HINTING,
>  	VIRTIO_BALLOON_VQ_MAX
>  };
>  
> @@ -113,6 +116,10 @@ struct virtio_balloon {
>  
>  	/* To register a shrinker to shrink memory upon memory pressure */
>  	struct shrinker shrinker;
> +
> +	/* Unused page hinting device */
> +	struct virtqueue *hinting_vq;
> +	struct page_hinting_dev_info ph_dev_info;
>  };
>  
>  static struct virtio_device_id id_table[] = {
> @@ -152,6 +159,22 @@ static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
>  
>  }
>  
> +void virtballoon_page_hinting_react(struct page_hinting_dev_info *ph_dev_info,
> +				    unsigned int num_hints)
> +{
> +	struct virtio_balloon *vb =
> +		container_of(ph_dev_info, struct virtio_balloon, ph_dev_info);
> +	struct virtqueue *vq = vb->hinting_vq;
> +	unsigned int unused;
> +
> +	/* We should always be able to add these buffers to an empty queue. */


can be an out of memory condition, and then ...

> +	virtqueue_add_inbuf(vq, ph_dev_info->sg, num_hints, vb, GFP_KERNEL);
> +	virtqueue_kick(vq);

... this will block forever.

> +	/* When host has read buffer, this completes via balloon_ack */
> +	wait_event(vb->acked, virtqueue_get_buf(vq, &unused));

However below I suggest limiting capacity which will solve
this problem for you.



> +}
> +
>  static void set_page_pfns(struct virtio_balloon *vb,
>  			  __virtio32 pfns[], struct page *page)
>  {
> @@ -476,6 +499,7 @@ static int init_vqs(struct virtio_balloon *vb)
>  	names[VIRTIO_BALLOON_VQ_DEFLATE] = "deflate";
>  	names[VIRTIO_BALLOON_VQ_STATS] = NULL;
>  	names[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
> +	names[VIRTIO_BALLOON_VQ_HINTING] = NULL;
>  
>  	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
>  		names[VIRTIO_BALLOON_VQ_STATS] = "stats";
> @@ -487,11 +511,19 @@ static int init_vqs(struct virtio_balloon *vb)
>  		callbacks[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
>  	}
>  
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING)) {
> +		names[VIRTIO_BALLOON_VQ_HINTING] = "hinting_vq";
> +		callbacks[VIRTIO_BALLOON_VQ_HINTING] = balloon_ack;
> +	}
> +
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
> @@ -924,12 +956,24 @@ static int virtballoon_probe(struct virtio_device *vdev)
>  		if (err)
>  			goto out_del_balloon_wq;
>  	}
> +
> +	vb->ph_dev_info.react = virtballoon_page_hinting_react;
> +	vb->ph_dev_info.capacity = VIRTIO_BALLOON_ARRAY_HINTS_MAX;

As explained above I think you should limit this by vq size.
Otherwise virtqueue add buf might fail.
In fact by struct spec reading you need to limit it
anyway otherwise it will fail unconditionally.
In practice on most hypervisors it will typically work ...

> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING)) {
> +		err = page_hinting_startup(&vb->ph_dev_info);
> +		if (err)
> +			goto out_unregister_shrinker;
> +	}
> +
>  	virtio_device_ready(vdev);
>  
>  	if (towards_target(vb))
>  		virtballoon_changed(vdev);
>  	return 0;
>  
> +out_unregister_shrinker:
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
> +		virtio_balloon_unregister_shrinker(vb);
>  out_del_balloon_wq:
>  	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT))
>  		destroy_workqueue(vb->balloon_wq);
> @@ -958,6 +1002,8 @@ static void virtballoon_remove(struct virtio_device *vdev)
>  {
>  	struct virtio_balloon *vb = vdev->priv;
>  
> +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING))
> +		page_hinting_shutdown(&vb->ph_dev_info);
>  	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
>  		virtio_balloon_unregister_shrinker(vb);
>  	spin_lock_irq(&vb->stop_update_lock);
> @@ -1027,6 +1073,7 @@ static int virtballoon_validate(struct virtio_device *vdev)
>  	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
>  	VIRTIO_BALLOON_F_FREE_PAGE_HINT,
>  	VIRTIO_BALLOON_F_PAGE_POISON,
> +	VIRTIO_BALLOON_F_HINTING,
>  };
>  
>  static struct virtio_driver virtio_balloon_driver = {
> diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
> index a1966cd7b677..2b0f62814e22 100644
> --- a/include/uapi/linux/virtio_balloon.h
> +++ b/include/uapi/linux/virtio_balloon.h
> @@ -36,6 +36,7 @@
>  #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
>  #define VIRTIO_BALLOON_F_FREE_PAGE_HINT	3 /* VQ to report free pages */
>  #define VIRTIO_BALLOON_F_PAGE_POISON	4 /* Guest is using page poisoning */
> +#define VIRTIO_BALLOON_F_HINTING	5 /* Page hinting virtqueue */
>  
>  /* Size of a PFN in the balloon interface. */
>  #define VIRTIO_BALLOON_PFN_SHIFT 12

