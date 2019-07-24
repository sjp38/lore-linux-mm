Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8386C76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 21:39:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A50CD21850
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 21:39:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A50CD21850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FE3D8E000E; Wed, 24 Jul 2019 17:39:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2AE608E0002; Wed, 24 Jul 2019 17:39:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 176E98E000E; Wed, 24 Jul 2019 17:39:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id EBD8C8E0002
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 17:39:06 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id l9so42546627qtu.12
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 14:39:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=28a4qMc4GebGixyPVlXegsBCWlKTvaQ82BrqmXv24hI=;
        b=FpZKXVgzSdod+x1D2z+0YSXRbBY0aDzHRoH9MNXTnNoA0y4bYUX6Z3d5gi8f/3klnJ
         lUAYf0s4LrMgersd2rLPdxoj3jqYWcJL5GSD+PT4sVrLCHOtDPcXj95XHZnCOE0jWZeC
         Wyd+8Qha4CkV7Q0l45btXzNvj2FrOFRcyMMOD+J4VeowQJfm7VTs3aY14SigXN/cCcfK
         qQLSg/wA+bgq+0FpyrKq61F+qHdcz8sh0e7I+3zOrCSIvbYBqXxQSKSV/3Yv7jyQuthr
         7F9w2ESceT2abYCenv0qbqKbtFCUmb70XV4+yeOUFX1oPX7eIG6KQ/aGJlbyf/s16tgW
         sCRQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVHXTEDHKueK2SIBHqSAuPRlBApCi+/H0zx3dp3vKc7bBIyJDNu
	BDtQMYEzvo8m8LJz/cdUuWkuMGv/ed84U6jbsOczR2PGXKDKTMGvMvkFbMKVoxaM/eayUh1LH3V
	M/cyJs1DNKWPOnToQzOssLtXkgzIETxRB7c7sE8h94WpoVx07okG1UDyMD1vXauuTGw==
X-Received: by 2002:a05:620a:4:: with SMTP id j4mr55734044qki.269.1564004346686;
        Wed, 24 Jul 2019 14:39:06 -0700 (PDT)
X-Received: by 2002:a05:620a:4:: with SMTP id j4mr55734013qki.269.1564004346027;
        Wed, 24 Jul 2019 14:39:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564004346; cv=none;
        d=google.com; s=arc-20160816;
        b=s/sM/4tBI5rL6XXT9Qu3BVlVO3uzoJLeWp/8hT5kMkBN2V+5OtU9eS50XbGGZOleNi
         Qm7FdvjK7LNN2mJTuTaP4zskARuea2eK5PoFpJWEVNNNUaOi24QCOfyv2FprawtIHvgy
         +QkkidSThtcBH9kaCQw3A+llgVE48tEBjJ7NXqVrnf9zJ5dwUnl8oPZ9Dy0W4pr4/1KL
         SOVOjdHGm5sCPAdckTcgEqY6c/SvEPDtJG6TMP55xXKl2jZbjNi5LZWrmJa8uDnjVBs2
         whwvYnZYJqxJsxl4yEHoVg80wcQyUZqu0o0jZpOtJ5mfVROMhjhUC1dx+9p6E0sS4p4N
         7Yjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=28a4qMc4GebGixyPVlXegsBCWlKTvaQ82BrqmXv24hI=;
        b=v5PxZBSROW0i38z7lmbal9tUo0lhvSDRT+GiNpZgFYg6BylDDvwTiMAN6v+JzstmHP
         Nw4PF+85tUszliHdLGF+9G+GHUZ3AygWPKV52ki6On29+7i7FsAwjbWSuATMSnXDPhfr
         uYyR0EctJlawhRo3N5iFNeqV+wx5s57kTcYVEcZRMtTrri1nYdVc2s1vDZ7oTQxp7cNc
         UXV6FyKrGCUhCzR7SzFKDbQLo4+h2RRnEcBAiSMHHt/oBZzyL1JufxwGBqsc+s1j/TWA
         nh5AZ8FZ52hFsUvRQAi05vpi8Py/ilBx+b65foNjaHBoN2f6FiJZcnxBLlNDOAOBwOxt
         U3zQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p21sor26691625qkj.181.2019.07.24.14.39.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 14:39:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqx5Vviay06G4wTpmKw6r6Rmn4S1f6AcbU39ZWHwDn0ZM/RIONGYIejuWx0pfdZo4Js4cYM76A==
X-Received: by 2002:a37:6944:: with SMTP id e65mr51570295qkc.119.1564004345710;
        Wed, 24 Jul 2019 14:39:05 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id g2sm21591961qti.68.2019.07.24.14.39.00
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 24 Jul 2019 14:39:04 -0700 (PDT)
Date: Wed, 24 Jul 2019 17:38:57 -0400
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
Message-ID: <20190724173403-mutt-send-email-mst@kernel.org>
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

BTW I wonder about migration here.  When we migrate we lose all hints
right?  Well destination could be smarter, detect that page is full of
0s and just map a zero page. Then we don't need a hint as such - but I
don't think it's done like that ATM.


I also wonder about interaction with deflate.  ATM deflate will add
pages to the free list, then balloon will come right back and report
them as free.


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

