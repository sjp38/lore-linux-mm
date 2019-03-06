Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A038C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 18:39:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E67022063F
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 18:39:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fdUrwiVK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E67022063F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 949148E0004; Wed,  6 Mar 2019 13:39:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D28D8E0002; Wed,  6 Mar 2019 13:39:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 79AB38E0004; Wed,  6 Mar 2019 13:39:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0B0F88E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 13:39:07 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id d8so2973217lja.5
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 10:39:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=vigpWUQ8b8ts8VnG7T2zXXh6BV/41RiIXHkYKoNiGk8=;
        b=UiU7kXsopuWdFWdmjDRBZ6Uc+69Vn5MuQCW2S/F+fKjSCw8WdKkp0UCCaDYoh5e/Gl
         6CwMWXuE0znaKRIndRcKhqa9BISLvytd2j1bMuw19ZLV/YwM2w7N/cAiLX9Aqzuap3f7
         npyFFDZcak0sX3ApAOE2rCIIiU41XY6uzxSuiul0OXz4dvhP0l4siIhA/WnqyHmdzk7j
         GUQQM94RP/JYDvHCyRjF84+F0B6moLrJ3WDtpShbDFzYi5mv6mKkJSC20D2NTYUJ0agS
         FLhshQl6YJ2ZAXJeC0OgOSbqOw/TPOKYmuLU+IiCYGSPLpaco+xNR2k+Nk8qH3Jgglee
         EYBw==
X-Gm-Message-State: APjAAAWWsU1QJuNSk/TF1+w7jwYQX5QirRwtr6iGJdmkjCh9G486N/Cx
	5trfdOuycEexlpqZXaTweso7Ju34oFNb8tcKu6EFAH43pB3DYkBSpc0BjdgvZTIRheh1q9Qdka/
	gChc/aCl4IIBywhrYNi3xb0QkxJdVqXjyg9zyp+wyOU10ribQu417EwTqSP3ErHYusq3Kc6TgaE
	XrYi5gMnUfhpyx7fkpGcJNUnARfFrhoSDHquuVAnFqXvnb5OH77GYqibCpiKPIQ1DT6B2t27TWC
	yQmmGEc2diORE92T/NWRiWUYlQ6cVv6lCUnbSuaKv/uuoaO+KITtwI6NuHcPwUzJYVAMfDAFxlV
	uqekVmdu2Ugs17BeumTWhtahDcM2AF6r1nmYTIPOCJompp7+h5dN6lVLEHRAZqPZSXAVqb6P4Gh
	O
X-Received: by 2002:a2e:6358:: with SMTP id x85mr3156304ljb.167.1551897546040;
        Wed, 06 Mar 2019 10:39:06 -0800 (PST)
X-Received: by 2002:a2e:6358:: with SMTP id x85mr3156266ljb.167.1551897544983;
        Wed, 06 Mar 2019 10:39:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551897544; cv=none;
        d=google.com; s=arc-20160816;
        b=uol8ncw0WDgUHqNSK7cxFZ7H49WvWk+NvWwTGRiEFrx+/psvEJapGDZg44Ydl0Qbz9
         EP/julRpDQ/qvNxzJ/ehlrN5D8njEVXZYdq9Qr509iisgsYWYYDpxmDT8/HU6a74jgtW
         n3mfrVbs9wtMvJVeuuLKtsSYdue7N+s/y+cGaOB4y++MyD1vOGjTJZnEV0Sv7NlUpsS9
         eBWYLHaUx/wlN/ZWA54lBL9auPidVNgUtHW5OEqfzPiKwnkcYpQhAIFRAy8mK7LTn76J
         fxEJs0yEbsGnmeHZH4fSSh+0rT3RAkYDxuONL8IFK0XTB4Q1IsYnP3LIEa2RmZTHi0KJ
         PC9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=vigpWUQ8b8ts8VnG7T2zXXh6BV/41RiIXHkYKoNiGk8=;
        b=d1SIIJJjGunEgwIPXJ2SoFpiaD76kmIH6OFxf/5GaGeUMBGFNBd2aGzTA3ejO6bipp
         q1ZQYgR4tcuPvLxoWEPEi6TcRBI8qc3TvpLg8eTXszKmySMSdPc55SyMv5I72kMiCHVB
         g7sJ5oycyAIxHyzc1VXhHHb9U8121f4GKyeguszM01hFs9OoQ92chlQUbohQW0org6M3
         vQ8n9N1Q+M4l4NDXU2Z0HEHDKAJAhrqrel7KD6cetiKaNzwWu23uowI//XeJRykyG5Xx
         0GVNADtoIFxSwvYF8WZ6r9crETO2AYmWA2nDl6JyycL5BHsQGaTPpVhs+eZrEDvv6L6A
         +kCA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fdUrwiVK;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l16sor735737lfk.27.2019.03.06.10.39.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Mar 2019 10:39:04 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fdUrwiVK;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=vigpWUQ8b8ts8VnG7T2zXXh6BV/41RiIXHkYKoNiGk8=;
        b=fdUrwiVKOg3psmVOsSEaNyWNbrHb8Q9vKwwRZrruHP5Taqb7IDVF6sQ2UioRDHkUl0
         yjMyrVqps5gSidmdj6DOHcz01f35lp8U8oeA3d3OXBhuPmWX82K4vtJM61pTN+UE7bQD
         0jQqsT8QhK2TY78TuV4W2OCUSVKJfeXN3pSgLa4x6BivGSt88dADFnz7zSGKf12ZJbTM
         dITs31ad2MVcvi+GUsLHa3CHev06QBISbLPneb3stElcuPObgvps7oIxQPjsr88cS+w+
         VknfWXZN8TcY4gZqqYXUlC1UxQPcnKREVqluZ9NeN11gASoCu+JFhpOsjj3jS9lxUK6D
         Kcvw==
X-Google-Smtp-Source: APXvYqzdy5JrzhP2r4sE9XnCletcfwxiDYBr0+FDfBBB+Ul6LWnXBwPUR5SafkYeck3dJUWAJ6H7Yh4XOW3jCwP5eoc=
X-Received: by 2002:ac2:41cb:: with SMTP id d11mr4748618lfi.3.1551897544583;
 Wed, 06 Mar 2019 10:39:04 -0800 (PST)
MIME-Version: 1.0
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com> <1551856692-3384-5-git-send-email-jasowang@redhat.com>
In-Reply-To: <1551856692-3384-5-git-send-email-jasowang@redhat.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Thu, 7 Mar 2019 00:13:24 +0530
Message-ID: <CAFqt6zYynfCn_SG6w98dHMA5rS6euPb+ihXtQcALE47K0LQb7g@mail.gmail.com>
Subject: Re: [RFC PATCH V2 4/5] vhost: introduce helpers to get the size of
 metadata area
To: Jason Wang <jasowang@redhat.com>
Cc: mst@redhat.com, kvm@vger.kernel.org, 
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org, 
	linux-kernel@vger.kernel.org, peterx@redhat.com, 
	Linux-MM <linux-mm@kvack.org>, aarcange@redhat.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 6, 2019 at 12:48 PM Jason Wang <jasowang@redhat.com> wrote:
>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Is the change log left with any particular reason ?
> ---
>  drivers/vhost/vhost.c | 46 ++++++++++++++++++++++++++++------------------
>  1 file changed, 28 insertions(+), 18 deletions(-)
>
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index 2025543..1015464 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -413,6 +413,27 @@ static void vhost_dev_free_iovecs(struct vhost_dev *dev)
>                 vhost_vq_free_iovecs(dev->vqs[i]);
>  }
>
> +static size_t vhost_get_avail_size(struct vhost_virtqueue *vq, int num)
> +{
> +       size_t event = vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX) ? 2 : 0;
> +
> +       return sizeof(*vq->avail) +
> +              sizeof(*vq->avail->ring) * num + event;
> +}
> +
> +static size_t vhost_get_used_size(struct vhost_virtqueue *vq, int num)
> +{
> +       size_t event = vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX) ? 2 : 0;
> +
> +       return sizeof(*vq->used) +
> +              sizeof(*vq->used->ring) * num + event;
> +}
> +
> +static size_t vhost_get_desc_size(struct vhost_virtqueue *vq, int num)
> +{
> +       return sizeof(*vq->desc) * num;
> +}
> +
>  void vhost_dev_init(struct vhost_dev *dev,
>                     struct vhost_virtqueue **vqs, int nvqs, int iov_limit)
>  {
> @@ -1253,13 +1274,9 @@ static bool vq_access_ok(struct vhost_virtqueue *vq, unsigned int num,
>                          struct vring_used __user *used)
>
>  {
> -       size_t s = vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX) ? 2 : 0;
> -
> -       return access_ok(desc, num * sizeof *desc) &&
> -              access_ok(avail,
> -                        sizeof *avail + num * sizeof *avail->ring + s) &&
> -              access_ok(used,
> -                       sizeof *used + num * sizeof *used->ring + s);
> +       return access_ok(desc, vhost_get_desc_size(vq, num)) &&
> +              access_ok(avail, vhost_get_avail_size(vq, num)) &&
> +              access_ok(used, vhost_get_used_size(vq, num));
>  }
>
>  static void vhost_vq_meta_update(struct vhost_virtqueue *vq,
> @@ -1311,22 +1328,18 @@ static bool iotlb_access_ok(struct vhost_virtqueue *vq,
>
>  int vq_meta_prefetch(struct vhost_virtqueue *vq)
>  {
> -       size_t s = vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX) ? 2 : 0;
>         unsigned int num = vq->num;
>
>         if (!vq->iotlb)
>                 return 1;
>
>         return iotlb_access_ok(vq, VHOST_ACCESS_RO, (u64)(uintptr_t)vq->desc,
> -                              num * sizeof(*vq->desc), VHOST_ADDR_DESC) &&
> +                              vhost_get_desc_size(vq, num), VHOST_ADDR_DESC) &&
>                iotlb_access_ok(vq, VHOST_ACCESS_RO, (u64)(uintptr_t)vq->avail,
> -                              sizeof *vq->avail +
> -                              num * sizeof(*vq->avail->ring) + s,
> +                              vhost_get_avail_size(vq, num),
>                                VHOST_ADDR_AVAIL) &&
>                iotlb_access_ok(vq, VHOST_ACCESS_WO, (u64)(uintptr_t)vq->used,
> -                              sizeof *vq->used +
> -                              num * sizeof(*vq->used->ring) + s,
> -                              VHOST_ADDR_USED);
> +                              vhost_get_used_size(vq, num), VHOST_ADDR_USED);
>  }
>  EXPORT_SYMBOL_GPL(vq_meta_prefetch);
>
> @@ -1343,13 +1356,10 @@ bool vhost_log_access_ok(struct vhost_dev *dev)
>  static bool vq_log_access_ok(struct vhost_virtqueue *vq,
>                              void __user *log_base)
>  {
> -       size_t s = vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX) ? 2 : 0;
> -
>         return vq_memory_access_ok(log_base, vq->umem,
>                                    vhost_has_feature(vq, VHOST_F_LOG_ALL)) &&
>                 (!vq->log_used || log_access_ok(log_base, vq->log_addr,
> -                                       sizeof *vq->used +
> -                                       vq->num * sizeof *vq->used->ring + s));
> +                                 vhost_get_used_size(vq, vq->num)));
>  }
>
>  /* Can we start vq? */
> --
> 1.8.3.1
>

