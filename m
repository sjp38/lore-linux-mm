Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB46AC76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 19:03:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 65E8621926
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 19:03:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65E8621926
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EBD5C8E0008; Wed, 24 Jul 2019 15:03:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E94B18E0003; Wed, 24 Jul 2019 15:03:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D5D7F8E0008; Wed, 24 Jul 2019 15:03:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id B4AC68E0003
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 15:03:05 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id h47so42310295qtc.20
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 12:03:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=p/O/eoxQhBRc771PITXPNeSklEhzUdVEBJF9ZJTsHJ8=;
        b=aBwRxWRIU91CqUcXUMknkW+w70CwQx4rY6NSFbpfGJQ4m5bOMIBmUJuJmiqWPZ4Lsw
         FtIub7ju4sW488CtJ6FgmJpkzvSEppnZH3jojpKzwysdCKUG3MBsvI1i1qV5zIlEnvwi
         1QQpuNxJ+WPy5n8V4g+jX1zBm9sXq67r5rai+R1jZRsEuqodRGLOI/Lr9jvfaNvAqwOH
         FVB4+nSzEONn/qXC/Ia5tJpMX4hujEgs92Bt7fs90xozD3upTqs16xoAp4R+f7P+0/5z
         /8yBR5THoUfBDxJYLlwktpN5fU+s6K4PP4veCUG2vuP9SU0PAA/gTQFeUr4YJAGEvWwt
         I6hA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXMqjv3s/o4Vs2iyyv+3kdqDLMQ5ZerltnRWgkfauIyB5clZcjE
	XsGD0w2LA1bOBiJCMoyFJ1IqfoQpw+CfwXKhF2VOxAzKA3vs6QF33enhGSwIoqtGb9X0z9ysu+p
	u7PS5jtqZeszUMARwgA8jn47WOzt5JTF+6dV16+0D8jaZCdnkTj0ad9v+FeRuZcAnVw==
X-Received: by 2002:a0c:e508:: with SMTP id l8mr61838639qvm.198.1563994985493;
        Wed, 24 Jul 2019 12:03:05 -0700 (PDT)
X-Received: by 2002:a0c:e508:: with SMTP id l8mr61838587qvm.198.1563994984857;
        Wed, 24 Jul 2019 12:03:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563994984; cv=none;
        d=google.com; s=arc-20160816;
        b=NesG+rNnRd5tZq1BiFfLywAJRU6qAPMJn13kcigbtYzrppT+Psef8mGEtcgfCD2vyK
         z5Thf6Qf2okIeXseQB1JM7LWYVLztPNqPgPjBKE3OvPtxvWU7ZNVoPV36hNW3v2GCtgd
         vNYUNP1UE2Yj037DOvngY9z//gYEgZxzuIAsvnZ1s5SbxTAPeb3zRM3Lc2rmojHJBDVp
         /AOls8H18It/aaeQ1g0zRTorMV6lu+D7ov7kSgMeJ+xv6IDFRiXgv0yYYLL64KCt25lK
         FP9PFYOS+ak8A4UPHYipMxv4cn5OMMZFwibnJUlvbSgSxWKH7G7yShUspdV8EKSLIRXV
         rTWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=p/O/eoxQhBRc771PITXPNeSklEhzUdVEBJF9ZJTsHJ8=;
        b=jd7L1gJk3+ajaPBirZH6oDflNgx1NKNHfKU2CQZ91E7zNmeFgflYZlw8gn8+IUNVfk
         UyxIaHs/TR5X4zmsW3VPtlyzjjql2fpwnSC3NJ/i6va8dLWw3oK+lrI8SkUTK9Us7UXK
         KFwqP/5XvbmM3SvB6nOv8/jAvWk6cf6e+WqNi29RqPH2Nx0t+6PAOx8hx6jMwbSpIkKL
         453xpHQi3EOsyYvmPLZFjwt2cL3t8q7bWYylE+CEtAvRC2hTkGg7XmdcRN71N96b4ROD
         VIrjy2+bOuYgGx0o32CFg0iHfktxZXCbgS+xPXJk+p+qgyHayK23BO3iu1pv5YPsKn0/
         FDZg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v5sor61960285qtk.73.2019.07.24.12.03.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 12:03:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqxLYZw8rlw3oqXg+jJiwN6HmesmFY8Q4kNnFppIrK1HvwN2j54BYbLPwLmiMExxvUpkuvzfMw==
X-Received: by 2002:ac8:1ba9:: with SMTP id z38mr59884346qtj.176.1563994984575;
        Wed, 24 Jul 2019 12:03:04 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id v1sm21056496qkj.19.2019.07.24.12.02.59
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 24 Jul 2019 12:03:03 -0700 (PDT)
Date: Wed, 24 Jul 2019 15:02:56 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com,
	dave.hansen@intel.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, akpm@linux-foundation.org,
	yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
	konrad.wilk@oracle.com, lcapitulino@redhat.com,
	wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com,
	dan.j.williams@intel.com, alexander.h.duyck@linux.intel.com
Subject: Re: [PATCH v2 QEMU] virtio-balloon: Provide a interface for "bubble
 hinting"
Message-ID: <20190724150224-mutt-send-email-mst@kernel.org>
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
 <20190724171050.7888.62199.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190724171050.7888.62199.stgit@localhost.localdomain>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 10:12:10AM -0700, Alexander Duyck wrote:
> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> 
> Add support for what I am referring to as "bubble hinting". Basically the
> idea is to function very similar to how the balloon works in that we
> basically end up madvising the page as not being used. However we don't
> really need to bother with any deflate type logic since the page will be
> faulted back into the guest when it is read or written to.
> 
> This is meant to be a simplification of the existing balloon interface
> to use for providing hints to what memory needs to be freed. I am assuming
> this is safe to do as the deflate logic does not actually appear to do very
> much other than tracking what subpages have been released and which ones
> haven't.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> ---
>  hw/virtio/virtio-balloon.c                      |   40 +++++++++++++++++++++++
>  include/hw/virtio/virtio-balloon.h              |    2 +
>  include/standard-headers/linux/virtio_balloon.h |    1 +
>  3 files changed, 42 insertions(+), 1 deletion(-)
> 
> diff --git a/hw/virtio/virtio-balloon.c b/hw/virtio/virtio-balloon.c
> index 2112874055fb..70c0004c0f88 100644
> --- a/hw/virtio/virtio-balloon.c
> +++ b/hw/virtio/virtio-balloon.c
> @@ -328,6 +328,39 @@ static void balloon_stats_set_poll_interval(Object *obj, Visitor *v,
>      balloon_stats_change_timer(s, 0);
>  }
>  
> +static void virtio_bubble_handle_output(VirtIODevice *vdev, VirtQueue *vq)
> +{
> +    VirtQueueElement *elem;
> +
> +    while ((elem = virtqueue_pop(vq, sizeof(VirtQueueElement)))) {
> +    	unsigned int i;
> +
> +        for (i = 0; i < elem->in_num; i++) {
> +            void *addr = elem->in_sg[i].iov_base;
> +            size_t size = elem->in_sg[i].iov_len;
> +            ram_addr_t ram_offset;
> +            size_t rb_page_size;
> +            RAMBlock *rb;
> +
> +            if (qemu_balloon_is_inhibited())
> +                continue;
> +
> +            rb = qemu_ram_block_from_host(addr, false, &ram_offset);
> +            rb_page_size = qemu_ram_pagesize(rb);
> +
> +            /* For now we will simply ignore unaligned memory regions */
> +            if ((ram_offset | size) & (rb_page_size - 1))
> +                continue;
> +
> +            ram_block_discard_range(rb, ram_offset, size);

I suspect this needs to do like the migration type of
hinting and get disabled if page poisoning is in effect.
Right?

> +        }
> +
> +        virtqueue_push(vq, elem, 0);
> +        virtio_notify(vdev, vq);
> +        g_free(elem);
> +    }
> +}
> +
>  static void virtio_balloon_handle_output(VirtIODevice *vdev, VirtQueue *vq)
>  {
>      VirtIOBalloon *s = VIRTIO_BALLOON(vdev);
> @@ -782,6 +815,11 @@ static void virtio_balloon_device_realize(DeviceState *dev, Error **errp)
>      s->svq = virtio_add_queue(vdev, 128, virtio_balloon_receive_stats);
>  
>      if (virtio_has_feature(s->host_features,
> +                           VIRTIO_BALLOON_F_HINTING)) {
> +        s->hvq = virtio_add_queue(vdev, 128, virtio_bubble_handle_output);
> +    }
> +
> +    if (virtio_has_feature(s->host_features,
>                             VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
>          s->free_page_vq = virtio_add_queue(vdev, VIRTQUEUE_MAX_SIZE,
>                                             virtio_balloon_handle_free_page_vq);
> @@ -897,6 +935,8 @@ static Property virtio_balloon_properties[] = {
>                      VIRTIO_BALLOON_F_DEFLATE_ON_OOM, false),
>      DEFINE_PROP_BIT("free-page-hint", VirtIOBalloon, host_features,
>                      VIRTIO_BALLOON_F_FREE_PAGE_HINT, false),
> +    DEFINE_PROP_BIT("guest-page-hinting", VirtIOBalloon, host_features,
> +                    VIRTIO_BALLOON_F_HINTING, true),
>      DEFINE_PROP_LINK("iothread", VirtIOBalloon, iothread, TYPE_IOTHREAD,
>                       IOThread *),
>      DEFINE_PROP_END_OF_LIST(),
> diff --git a/include/hw/virtio/virtio-balloon.h b/include/hw/virtio/virtio-balloon.h
> index 1afafb12f6bc..a58b24fdf29d 100644
> --- a/include/hw/virtio/virtio-balloon.h
> +++ b/include/hw/virtio/virtio-balloon.h
> @@ -44,7 +44,7 @@ enum virtio_balloon_free_page_report_status {
>  
>  typedef struct VirtIOBalloon {
>      VirtIODevice parent_obj;
> -    VirtQueue *ivq, *dvq, *svq, *free_page_vq;
> +    VirtQueue *ivq, *dvq, *svq, *free_page_vq, *hvq;
>      uint32_t free_page_report_status;
>      uint32_t num_pages;
>      uint32_t actual;
> diff --git a/include/standard-headers/linux/virtio_balloon.h b/include/standard-headers/linux/virtio_balloon.h
> index 9375ca2a70de..f9e3e8256261 100644
> --- a/include/standard-headers/linux/virtio_balloon.h
> +++ b/include/standard-headers/linux/virtio_balloon.h
> @@ -36,6 +36,7 @@
>  #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
>  #define VIRTIO_BALLOON_F_FREE_PAGE_HINT	3 /* VQ to report free pages */
>  #define VIRTIO_BALLOON_F_PAGE_POISON	4 /* Guest is using page poisoning */
> +#define VIRTIO_BALLOON_F_HINTING	5 /* Page hinting virtqueue */
>  
>  /* Size of a PFN in the balloon interface. */
>  #define VIRTIO_BALLOON_PFN_SHIFT 12

