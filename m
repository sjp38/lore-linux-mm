Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2BC7C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 21:31:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 88FBA20657
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 21:31:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Y21BzpwZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 88FBA20657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 23BDD8E0003; Wed,  6 Mar 2019 16:31:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1ED158E0002; Wed,  6 Mar 2019 16:31:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1045B8E0003; Wed,  6 Mar 2019 16:31:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id DB16A8E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 16:31:09 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id 68so10764153iov.7
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 13:31:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ECTPCfgZaf/q6OslBRVwg5/A6wyE+SZLjVIdlnaBcgI=;
        b=gColCMTKX8iNH1QQnTpBkEsLSZLC+OU58rCKGDKO+XTi2vMXb8PnvXjqhBGkkE84Jc
         f3kKtJ5LAuQTbVGUME4MqWCGEmcdLo5nWcwC+b5FfvFwNfFdLLwZDxdyBrZKHN8HoyaR
         IWpkSrs2mJHuCEJ2P5LZxXzHkkL/rn+7wJ8iQt7Hqga+nBXPeYvfVE4ptkFZmx/femH6
         ClasMs9MwxngaGJri0kBQbH45ge5DbpRypKjjX2k5db/eeSabXBnYYyCTLsvX8/Cv/KQ
         E7Loj6bOSZYOAmR3pZdutGxmRLprTIl77emDqRR/9Stl2mzRv/x9LfgjO4fAaNTtGM0Y
         b5DA==
X-Gm-Message-State: APjAAAVQHv9dIlX9TMNFlAfPzN5AoDYpc6Q3jOF1glNap+sCRQDPMN0U
	8X9lX1yQP92BXvf09DSynwjl0B5jdYUIx/dcWyNCpBLiL4L+wTLNAK3wZzV/XSON/XjhAeSMM5X
	QYARAQsc+cF0+4iJ4v7HjfudzzUPeeBxPPjUB6YZK0C4LALX06ANSHQvFTcTpXMTOYRJdRyis2h
	yK4XmVevC4nrw2sMTIYAuwWxsDzijd6KDeozUP+aGnuwRaLDMaTUpnVHGOg2eJw6bqhCa3hRuWn
	TeqPUqRwRcCdCXCjrtIoSf06OUPbyRsot6JChkVNWIsba5vcvrvw0L1wKYvZWqwZZ0ACI/5jA/W
	TWp+nqiCC4WoxFX2mM/+QdNK1b+YeMGMooPJgOlfEpI6nlgG3VAUJqqxXKCc1lESJj3oDXPUdnN
	D
X-Received: by 2002:a24:2251:: with SMTP id o78mr3694631ito.134.1551907869615;
        Wed, 06 Mar 2019 13:31:09 -0800 (PST)
X-Received: by 2002:a24:2251:: with SMTP id o78mr3694570ito.134.1551907868481;
        Wed, 06 Mar 2019 13:31:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551907868; cv=none;
        d=google.com; s=arc-20160816;
        b=HdZ44ofavKMrEwIVArKHeoMxS5XZoc5eWehULcvH0BivZm8yYh6mdGGufeCzBWccjq
         cJt4TFgP1yJaUyLmOMKxwMYamL4Eg/3Psgedw6q0SqRlDvTRmlKYLq+BWfWleQClHhPw
         ruG79axyi3TEXyUTHZczeT8f49urRg1PkcSrTwoJVe2qYA2kCjRwoFCSJHcyITrY3iE7
         4hvTvZvAZFBpr8KDfsRvA15zxRiOkD6WqFF/q6x3z66t+EaNGpQ6v1GsmbZPcxk4/4Vz
         YCAaBGUE6Wjvnrgp150mfSMtk8C8QwXpm2FqKTaT/mv+H+pxdBtLUxXyYhwgrmRtT4BH
         K+9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ECTPCfgZaf/q6OslBRVwg5/A6wyE+SZLjVIdlnaBcgI=;
        b=qt8V6XxwACRV7Mx1kQ9vwoRfoKNcabM7c7LY1tKXO6qt7rPTbunsMmR0MFOAZMJgvs
         QRoMusFgEfej25t9xSn/v/EKj2GxZu4g7FC7s/5U19anyzS/1BHOTLKBdY0Ly93eNBuK
         f/aPGlFA3ROiQTptGWBJKfjDIgejb3AL6JgDm3toWeFXTf5lxoIyGV/iUUlQxQwQWx3F
         WYCe+jM0vq46t4XfzD1lV5FzHLf3Par4sfikVnsIhC2RTKJUqe5bFsrwnV6BnDv4cEm6
         sOy7/Tk9vGUIlysi9Y2cUX8oga22IWu6y71MWh85IBmuRuHHW5rZP9letUW/Y/IWKBvN
         Ia1g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Y21BzpwZ;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v9sor1554938iod.121.2019.03.06.13.31.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Mar 2019 13:31:08 -0800 (PST)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Y21BzpwZ;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ECTPCfgZaf/q6OslBRVwg5/A6wyE+SZLjVIdlnaBcgI=;
        b=Y21BzpwZI0MiddBJDbWgPxbJA9Lez2FU3Ks0vpx0tfDzSI3qD8OsLzD7Azkt88+rIX
         XnP0fCSoYep2ys1/DzAGdcd784XaK5lI/02v9kwTLduExJb7+OhXyKiHp39cE3+SUbLD
         ltWFLyKkHC/rAqi+dg3jUDqq3eLdCxAUWDMjNqKKGY0D8rw4acDVWwoitYVhkA81GrsK
         1qjgRP+Z+WvsiH7xYrOPvAyJWj4zBhq+beCMPynEYVKbCnklz1UinGKwqMYQw8ZJsCwO
         gODbkKMOWM2bimSMCDbTry/yPpdsP81l9WOPbBH4XEbbLNGYiKfr2gc7fy4/uJ4TGRde
         IFaA==
X-Google-Smtp-Source: APXvYqyjGdnxxxLRK4n4UMvMi3e5AUYrt6rTzHYghAkfXr6FqMOq2pk2Jrf/gYUv9qVJ6MYUtw/TqPPvMDtNSKsUd+Y=
X-Received: by 2002:a6b:f70a:: with SMTP id k10mr4782690iog.68.1551907867874;
 Wed, 06 Mar 2019 13:31:07 -0800 (PST)
MIME-Version: 1.0
References: <20190306155048.12868-1-nitesh@redhat.com> <20190306155048.12868-4-nitesh@redhat.com>
In-Reply-To: <20190306155048.12868-4-nitesh@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Wed, 6 Mar 2019 13:30:56 -0800
Message-ID: <CAKgT0Udrzo4Ddx4UsJr+x-kgEVJpzQf_PhtAmoShSU8PPDOZEQ@mail.gmail.com>
Subject: Re: [RFC][Patch v9 3/6] KVM: Enables the kernel to report isolated pages
To: Nitesh Narayan Lal <nitesh@redhat.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com, 
	pagupta@redhat.com, wei.w.wang@intel.com, 
	Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>, 
	David Hildenbrand <david@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, dodgen@google.com, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com, 
	Andrea Arcangeli <aarcange@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 6, 2019 at 7:51 AM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
>
> This patch enables the kernel to report the isolated pages
> to the host via virtio balloon driver.
> In order to do so a new virtuqeue (hinting_vq) is added to the
> virtio balloon driver. As the host responds back after freeing
> the pages, all the isolated pages are returned back to the buddy
> via __free_one_page().
>
> Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>

I ran into a few build issues due to this patch. Comments below.

> ---
>  drivers/virtio/virtio_balloon.c     | 72 ++++++++++++++++++++++++++++-
>  include/linux/page_hinting.h        |  4 ++
>  include/uapi/linux/virtio_balloon.h |  8 ++++
>  virt/kvm/page_hinting.c             | 18 ++++++--
>  4 files changed, 98 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> index 728ecd1eea30..cfe7574b5204 100644
> --- a/drivers/virtio/virtio_balloon.c
> +++ b/drivers/virtio/virtio_balloon.c
> @@ -57,13 +57,15 @@ enum virtio_balloon_vq {
>         VIRTIO_BALLOON_VQ_INFLATE,
>         VIRTIO_BALLOON_VQ_DEFLATE,
>         VIRTIO_BALLOON_VQ_STATS,
> +       VIRTIO_BALLOON_VQ_HINTING,
>         VIRTIO_BALLOON_VQ_FREE_PAGE,
>         VIRTIO_BALLOON_VQ_MAX
>  };
>
>  struct virtio_balloon {
>         struct virtio_device *vdev;
> -       struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *free_page_vq;
> +       struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *free_page_vq,
> +                                                               *hinting_vq;
>
>         /* Balloon's own wq for cpu-intensive work items */
>         struct workqueue_struct *balloon_wq;
> @@ -122,6 +124,56 @@ static struct virtio_device_id id_table[] = {
>         { 0 },
>  };
>
> +#ifdef CONFIG_KVM_FREE_PAGE_HINTING
> +int virtballoon_page_hinting(struct virtio_balloon *vb,
> +                            void *hinting_req,
> +                            int entries)
> +{
> +       struct scatterlist sg;
> +       struct virtqueue *vq = vb->hinting_vq;
> +       int err;
> +       int unused;
> +       struct virtio_balloon_hint_req *hint_req;
> +       u64 gpaddr;
> +
> +       hint_req = kmalloc(sizeof(struct virtio_balloon_hint_req), GFP_KERNEL);
> +       while (virtqueue_get_buf(vq, &unused))
> +               ;
> +
> +       gpaddr = virt_to_phys(hinting_req);
> +       hint_req->phys_addr = cpu_to_virtio64(vb->vdev, gpaddr);
> +       hint_req->count = cpu_to_virtio32(vb->vdev, entries);
> +       sg_init_one(&sg, hint_req, sizeof(struct virtio_balloon_hint_req));
> +       err = virtqueue_add_outbuf(vq, &sg, 1, hint_req, GFP_KERNEL);
> +       if (!err)
> +               virtqueue_kick(vb->hinting_vq);
> +       else
> +               kfree(hint_req);
> +       return err;
> +}
> +
> +static void hinting_ack(struct virtqueue *vq)
> +{
> +       int len = sizeof(struct virtio_balloon_hint_req);
> +       struct virtio_balloon_hint_req *hint_req = virtqueue_get_buf(vq, &len);
> +       void *v_addr = phys_to_virt(hint_req->phys_addr);
> +
> +       release_buddy_pages(v_addr, hint_req->count);
> +       kfree(hint_req);
> +}
> +

You use release_buddy_pages here, but never exported it in the call
down below. Since this can be built as a module and I believe the page
hinting can be built either into the kernel or as a seperate module
shouldn't you be exporting it?

> +static void enable_hinting(struct virtio_balloon *vb)
> +{
> +       request_hypercall = (void *)&virtballoon_page_hinting;
> +       balloon_ptr = vb;
> +}
> +
> +static void disable_hinting(void)
> +{
> +       balloon_ptr = NULL;
> +}
> +#endif
> +
>  static u32 page_to_balloon_pfn(struct page *page)
>  {
>         unsigned long pfn = page_to_pfn(page);
> @@ -481,6 +533,7 @@ static int init_vqs(struct virtio_balloon *vb)
>         names[VIRTIO_BALLOON_VQ_DEFLATE] = "deflate";
>         names[VIRTIO_BALLOON_VQ_STATS] = NULL;
>         names[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
> +       names[VIRTIO_BALLOON_VQ_HINTING] = NULL;
>
>         if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
>                 names[VIRTIO_BALLOON_VQ_STATS] = "stats";
> @@ -492,11 +545,18 @@ static int init_vqs(struct virtio_balloon *vb)
>                 callbacks[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
>         }
>
> +       if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING)) {
> +               names[VIRTIO_BALLOON_VQ_HINTING] = "hinting_vq";
> +               callbacks[VIRTIO_BALLOON_VQ_HINTING] = hinting_ack;
> +       }
>         err = vb->vdev->config->find_vqs(vb->vdev, VIRTIO_BALLOON_VQ_MAX,
>                                          vqs, callbacks, names, NULL, NULL);
>         if (err)
>                 return err;
>
> +       if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING))
> +               vb->hinting_vq = vqs[VIRTIO_BALLOON_VQ_HINTING];
> +
>         vb->inflate_vq = vqs[VIRTIO_BALLOON_VQ_INFLATE];
>         vb->deflate_vq = vqs[VIRTIO_BALLOON_VQ_DEFLATE];
>         if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
> @@ -908,6 +968,11 @@ static int virtballoon_probe(struct virtio_device *vdev)
>                 if (err)
>                         goto out_del_balloon_wq;
>         }
> +
> +#ifdef CONFIG_KVM_FREE_PAGE_HINTING
> +       if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING))
> +               enable_hinting(vb);
> +#endif
>         virtio_device_ready(vdev);
>
>         if (towards_target(vb))
> @@ -950,6 +1015,10 @@ static void virtballoon_remove(struct virtio_device *vdev)
>         cancel_work_sync(&vb->update_balloon_size_work);
>         cancel_work_sync(&vb->update_balloon_stats_work);
>
> +#ifdef CONFIG_KVM_FREE_PAGE_HINTING
> +       if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING))
> +               disable_hinting();
> +#endif
>         if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
>                 cancel_work_sync(&vb->report_free_page_work);
>                 destroy_workqueue(vb->balloon_wq);
> @@ -1009,6 +1078,7 @@ static unsigned int features[] = {
>         VIRTIO_BALLOON_F_MUST_TELL_HOST,
>         VIRTIO_BALLOON_F_STATS_VQ,
>         VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
> +       VIRTIO_BALLOON_F_HINTING,
>         VIRTIO_BALLOON_F_FREE_PAGE_HINT,
>         VIRTIO_BALLOON_F_PAGE_POISON,
>  };
> diff --git a/include/linux/page_hinting.h b/include/linux/page_hinting.h
> index d554a2581826..a32af8851081 100644
> --- a/include/linux/page_hinting.h
> +++ b/include/linux/page_hinting.h
> @@ -11,6 +11,8 @@
>  #define HINTING_THRESHOLD      128
>  #define FREE_PAGE_HINTING_MIN_ORDER    (MAX_ORDER - 1)
>
> +extern void *balloon_ptr;
> +
>  void guest_free_page_enqueue(struct page *page, int order);
>  void guest_free_page_try_hinting(void);
>  extern int __isolate_free_page(struct page *page, unsigned int order);
> @@ -18,3 +20,5 @@ extern void __free_one_page(struct page *page, unsigned long pfn,
>                             struct zone *zone, unsigned int order,
>                             int migratetype);
>  void release_buddy_pages(void *obj_to_free, int entries);
> +extern int (*request_hypercall)(void *balloon_ptr,
> +                               void *hinting_req, int entries);
> diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
> index a1966cd7b677..a7e909d77447 100644
> --- a/include/uapi/linux/virtio_balloon.h
> +++ b/include/uapi/linux/virtio_balloon.h
> @@ -29,6 +29,7 @@
>  #include <linux/virtio_types.h>
>  #include <linux/virtio_ids.h>
>  #include <linux/virtio_config.h>
> +#include <linux/page_hinting.h>
>
>  /* The feature bitmap for virtio balloon */
>  #define VIRTIO_BALLOON_F_MUST_TELL_HOST        0 /* Tell before reclaiming pages */

So I am pretty sure that this isn't valid. You have a file in
include/uapi/linux referencing one in include/linux. As such when the
userspace headers are built off of this they cannot access the kernel
include file.

> @@ -36,6 +37,7 @@
>  #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM        2 /* Deflate balloon on OOM */
>  #define VIRTIO_BALLOON_F_FREE_PAGE_HINT        3 /* VQ to report free pages */
>  #define VIRTIO_BALLOON_F_PAGE_POISON   4 /* Guest is using page poisoning */
> +#define VIRTIO_BALLOON_F_HINTING       5 /* Page hinting virtqueue */
>
>  /* Size of a PFN in the balloon interface. */
>  #define VIRTIO_BALLOON_PFN_SHIFT 12
> @@ -108,4 +110,10 @@ struct virtio_balloon_stat {
>         __virtio64 val;
>  } __attribute__((packed));
>
> +#ifdef CONFIG_KVM_FREE_PAGE_HINTING
> +struct virtio_balloon_hint_req {
> +       __virtio64 phys_addr;
> +       __virtio64 count;
> +};
> +#endif
>  #endif /* _LINUX_VIRTIO_BALLOON_H */
> diff --git a/virt/kvm/page_hinting.c b/virt/kvm/page_hinting.c
> index 9885b372b5a9..eb0c0ddfe990 100644
> --- a/virt/kvm/page_hinting.c
> +++ b/virt/kvm/page_hinting.c
> @@ -31,11 +31,16 @@ struct guest_isolated_pages {
>         unsigned int order;
>  };
>
> -void release_buddy_pages(void *obj_to_free, int entries)
> +int (*request_hypercall)(void *balloon_ptr, void *hinting_req, int entries);
> +EXPORT_SYMBOL(request_hypercall);
> +void *balloon_ptr;
> +EXPORT_SYMBOL(balloon_ptr);
> +

Why are you using a standard EXPORT_SYMBOL here instead of
EXPORT_SYMBOL_GPL? It seems like these are core functions that can
impact the memory allocator. It might make more sense to use
EXPORT_SYMBOL_GPL.

> +void release_buddy_pages(void *hinting_req, int entries)
>  {
>         int i = 0;
>         int mt = 0;
> -       struct guest_isolated_pages *isolated_pages_obj = obj_to_free;
> +       struct guest_isolated_pages *isolated_pages_obj = hinting_req;
>
>         while (i < entries) {
>                 struct page *page = pfn_to_page(isolated_pages_obj[i].pfn);

See my comment above, I am pretty sure you need to be exporting this.
I had to change this in order to be able to build.

