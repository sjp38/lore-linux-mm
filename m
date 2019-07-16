Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 303B7C76195
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 16:08:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D7E7B2054F
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 16:08:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D7E7B2054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 731F48E0008; Tue, 16 Jul 2019 12:08:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E1D18E0006; Tue, 16 Jul 2019 12:08:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F8698E0008; Tue, 16 Jul 2019 12:08:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3F3C48E0006
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 12:08:05 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id x1so17315213qkn.6
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 09:08:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=kriQ/DDLXYtzbKhA6eLvBkCMA2RVUFaJKBmy/A/kCX4=;
        b=oKS1Pnx5/ADlxVQBXr0HhIiegHJtVL3dUUcFh/0Oe5+4UckG36ooNvS1djbARqXc/C
         T7VeX+ZjPFWkPcMzFxXNjiutkt+f8B4SjLki106HDn4/BiPa+UlqTymuljL/IJSZaC+n
         hzXTy2/ChJrsMUq1C1SYlD04m8k14nuTHiU7QfR/ZCsXg/YiFe5QQn0WKGavi5DhBvOz
         JO6NNRm5tLPh2ody0RHV/Kabp1e95sjZL31QnLGgWHNmDIyvvv82dCN+6P1OOHT+R1VS
         O9CtlEAcU7xV5tcA2Oszx0vU/Dz1XKRz+uh3Hbzk+vwzZxd3FLYeAr8X7Ntyd4jQ1DkC
         X5yg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXALzMsBTaRUoYLIW0C538uH39qOMm/aWoHAeTYpGA1Oa65o5tX
	5hzJ4xi6JnsfpX5kBRcN4HplWwFPwnb+8vgCBOoiuD3U36HuCGYE/wRFnxerAaT4OLwU+WrIHZp
	jpEZarfWWo/G/yiBb/foT/WpSjM/oqVHga/XPocKwfTuBu+glJCJknbwEtrddde7BpQ==
X-Received: by 2002:a05:620a:1413:: with SMTP id d19mr21605973qkj.341.1563293284938;
        Tue, 16 Jul 2019 09:08:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxnzDx0/KThni7VPzNiNg8nzF35WKmWK0AKdkyMbKxTuoL2SLPGZKQTbi+NdbmFnrbP5de8
X-Received: by 2002:a05:620a:1413:: with SMTP id d19mr21605874qkj.341.1563293283749;
        Tue, 16 Jul 2019 09:08:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563293283; cv=none;
        d=google.com; s=arc-20160816;
        b=1Fnw+1McTK9GSW8RY33cnWzVJktWd7ugHMB1T7qykO49EOmKfxSh4BX/QfuQXQqUUM
         2qjDYuutVSlp1+NAe6ZQf4lTrrYTUjqfUILI3CJu/dmByFmthu5/SFWDlpD0uT3d73NS
         azE3Z3d0j7UvZSk3Od/M7gCOmVK75ceUv/klUojI//b66EeZGMlKf0itkQ7w8BkDd9/6
         MlkvJjNuBwCeOOe5sPhrTjKY7Nc3uHepHCMR+FXhIE4n2jtNlPX9ei+zsTViz1vhx2n2
         fyTJ6SUS0vqVADBAdLhjk0com0Gi00FqhkVlQbt1Ryhpj1EEyjyVuDvuPE/F4S1+VY8P
         /Y/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=kriQ/DDLXYtzbKhA6eLvBkCMA2RVUFaJKBmy/A/kCX4=;
        b=Sdhz2rPj6fXsIole93ilAk2a8LgK/V+h9kyuVHezT0m6HuK5tL0K4tpTR6mrUiyuiE
         nZt0LTkxFtlJaOpGz/PCF78B06XlIQ8pQoKeMAClJfMJ0R5+l3TXsHNMtOlUaQaHw7pD
         xrAGp1J8VvsEZPwjcaxPGXCuzmAGBJu7VxjH1amGng+Ws4q5B5lPAThn85Xo7lUDRiZq
         +Mfl9g0to1KtLgWeW9+rPW+DF5XOdr5EAJC+2y6wq6uj+j6VFIlKDnonvWxdMIwMevOS
         PjwDTpK73Ta2xR+A44SjHKrW5Sqq+YtrFNwmJ76axrXp7KQb+7ZdPL5LuNJ/fZ5jcFlQ
         eFYw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g130si12506029qkb.213.2019.07.16.09.08.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 09:08:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BE6862D1CE;
	Tue, 16 Jul 2019 16:08:02 +0000 (UTC)
Received: from redhat.com (ovpn-122-108.rdu2.redhat.com [10.10.122.108])
	by smtp.corp.redhat.com (Postfix) with SMTP id 6CE901001B00;
	Tue, 16 Jul 2019 16:07:48 +0000 (UTC)
Date: Tue, 16 Jul 2019 12:07:46 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>,
	David Hildenbrand <david@redhat.com>,
	Dave Hansen <dave.hansen@intel.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Yang Zhang <yang.zhang.wz@gmail.com>, pagupta@redhat.com,
	Rik van Riel <riel@surriel.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	lcapitulino@redhat.com, wei.w.wang@intel.com,
	Andrea Arcangeli <aarcange@redhat.com>,
	Paolo Bonzini <pbonzini@redhat.com>, dan.j.williams@intel.com,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>
Subject: Re: [PATCH v1 6/6] virtio-balloon: Add support for aerating memory
 via hinting
Message-ID: <20190716115535-mutt-send-email-mst@kernel.org>
References: <20190619222922.1231.27432.stgit@localhost.localdomain>
 <20190619223338.1231.52537.stgit@localhost.localdomain>
 <20190716055017-mutt-send-email-mst@kernel.org>
 <CAKgT0Uc-2k9o7pjtf-GFAgr83c7RM-RTJ8-OrEzFv92uz+MTDw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKgT0Uc-2k9o7pjtf-GFAgr83c7RM-RTJ8-OrEzFv92uz+MTDw@mail.gmail.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Tue, 16 Jul 2019 16:08:02 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 16, 2019 at 08:37:06AM -0700, Alexander Duyck wrote:
> On Tue, Jul 16, 2019 at 2:55 AM Michael S. Tsirkin <mst@redhat.com> wrote:
> >
> > On Wed, Jun 19, 2019 at 03:33:38PM -0700, Alexander Duyck wrote:
> > > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > >
> > > Add support for aerating memory using the hinting feature provided by
> > > virtio-balloon. Hinting differs from the regular balloon functionality in
> > > that is is much less durable than a standard memory balloon. Instead of
> > > creating a list of pages that cannot be accessed the pages are only
> > > inaccessible while they are being indicated to the virtio interface. Once
> > > the interface has acknowledged them they are placed back into their
> > > respective free lists and are once again accessible by the guest system.
> > >
> > > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > ---
> > >  drivers/virtio/Kconfig              |    1
> > >  drivers/virtio/virtio_balloon.c     |  110 ++++++++++++++++++++++++++++++++++-
> > >  include/uapi/linux/virtio_balloon.h |    1
> > >  3 files changed, 108 insertions(+), 4 deletions(-)
> > >
> > > diff --git a/drivers/virtio/Kconfig b/drivers/virtio/Kconfig
> > > index 023fc3bc01c6..9cdaccf92c3a 100644
> > > --- a/drivers/virtio/Kconfig
> > > +++ b/drivers/virtio/Kconfig
> > > @@ -47,6 +47,7 @@ config VIRTIO_BALLOON
> > >       tristate "Virtio balloon driver"
> > >       depends on VIRTIO
> > >       select MEMORY_BALLOON
> > > +     select AERATION
> > >       ---help---
> > >        This driver supports increasing and decreasing the amount
> > >        of memory within a KVM guest.
> > > diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> > > index 44339fc87cc7..91f1e8c9017d 100644
> > > --- a/drivers/virtio/virtio_balloon.c
> > > +++ b/drivers/virtio/virtio_balloon.c
> > > @@ -18,6 +18,7 @@
> > >  #include <linux/mm.h>
> > >  #include <linux/mount.h>
> > >  #include <linux/magic.h>
> > > +#include <linux/memory_aeration.h>
> > >
> > >  /*
> > >   * Balloon device works in 4K page units.  So each page is pointed to by
> > > @@ -26,6 +27,7 @@
> > >   */
> > >  #define VIRTIO_BALLOON_PAGES_PER_PAGE (unsigned)(PAGE_SIZE >> VIRTIO_BALLOON_PFN_SHIFT)
> > >  #define VIRTIO_BALLOON_ARRAY_PFNS_MAX 256
> > > +#define VIRTIO_BALLOON_ARRAY_HINTS_MAX       32
> > >  #define VIRTBALLOON_OOM_NOTIFY_PRIORITY 80
> > >
> > >  #define VIRTIO_BALLOON_FREE_PAGE_ALLOC_FLAG (__GFP_NORETRY | __GFP_NOWARN | \
> > > @@ -45,6 +47,7 @@ enum virtio_balloon_vq {
> > >       VIRTIO_BALLOON_VQ_DEFLATE,
> > >       VIRTIO_BALLOON_VQ_STATS,
> > >       VIRTIO_BALLOON_VQ_FREE_PAGE,
> > > +     VIRTIO_BALLOON_VQ_HINTING,
> > >       VIRTIO_BALLOON_VQ_MAX
> > >  };
> > >
> > > @@ -54,7 +57,8 @@ enum virtio_balloon_config_read {
> > >
> > >  struct virtio_balloon {
> > >       struct virtio_device *vdev;
> > > -     struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *free_page_vq;
> > > +     struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *free_page_vq,
> > > +                                                             *hinting_vq;
> > >
> > >       /* Balloon's own wq for cpu-intensive work items */
> > >       struct workqueue_struct *balloon_wq;
> > > @@ -103,9 +107,21 @@ struct virtio_balloon {
> > >       /* Synchronize access/update to this struct virtio_balloon elements */
> > >       struct mutex balloon_lock;
> > >
> > > -     /* The array of pfns we tell the Host about. */
> > > -     unsigned int num_pfns;
> > > -     __virtio32 pfns[VIRTIO_BALLOON_ARRAY_PFNS_MAX];
> > > +
> > > +     union {
> > > +             /* The array of pfns we tell the Host about. */
> > > +             struct {
> > > +                     unsigned int num_pfns;
> > > +                     __virtio32 pfns[VIRTIO_BALLOON_ARRAY_PFNS_MAX];
> > > +             };
> > > +             /* The array of physical addresses we are hinting on */
> > > +             struct {
> > > +                     unsigned int num_hints;
> > > +                     __virtio64 hints[VIRTIO_BALLOON_ARRAY_HINTS_MAX];
> > > +             };
> > > +     };
> > > +
> > > +     struct aerator_dev_info a_dev_info;
> > >
> > >       /* Memory statistics */
> > >       struct virtio_balloon_stat stats[VIRTIO_BALLOON_S_NR];
> > > @@ -151,6 +167,68 @@ static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
> > >
> > >  }
> > >
> > > +static u64 page_to_hints_pa_order(struct page *page)
> > > +{
> > > +     unsigned char order;
> > > +     dma_addr_t pa;
> > > +
> > > +     BUILD_BUG_ON((64 - VIRTIO_BALLOON_PFN_SHIFT) >=
> > > +                  (1 << VIRTIO_BALLOON_PFN_SHIFT));
> > > +
> > > +     /*
> > > +      * Record physical page address combined with page order.
> > > +      * Order will never exceed 64 - VIRTIO_BALLON_PFN_SHIFT
> > > +      * since the size has to fit into a 64b value. So as long
> > > +      * as VIRTIO_BALLOON_SHIFT is greater than this combining
> > > +      * the two values should be safe.
> > > +      */
> > > +     pa = page_to_phys(page);
> > > +     order = page_private(page) +
> > > +             PAGE_SHIFT - VIRTIO_BALLOON_PFN_SHIFT;
> > > +
> > > +     return (u64)(pa | order);
> > > +}
> > > +
> > > +void virtballoon_aerator_react(struct aerator_dev_info *a_dev_info)
> > > +{
> > > +     struct virtio_balloon *vb = container_of(a_dev_info,
> > > +                                             struct virtio_balloon,
> > > +                                             a_dev_info);
> > > +     struct virtqueue *vq = vb->hinting_vq;
> > > +     struct scatterlist sg;
> > > +     unsigned int unused;
> > > +     struct page *page;
> > > +
> > > +     mutex_lock(&vb->balloon_lock);
> > > +
> > > +     vb->num_hints = 0;
> > > +
> > > +     list_for_each_entry(page, &a_dev_info->batch, lru) {
> > > +             vb->hints[vb->num_hints++] =
> > > +                             cpu_to_virtio64(vb->vdev,
> > > +                                             page_to_hints_pa_order(page));
> > > +     }
> > > +
> > > +     /* We shouldn't have been called if there is nothing to process */
> > > +     if (WARN_ON(vb->num_hints == 0))
> > > +             goto out;
> > > +
> > > +     sg_init_one(&sg, vb->hints,
> > > +                 sizeof(vb->hints[0]) * vb->num_hints);
> > > +
> > > +     /*
> > > +      * We should always be able to add one buffer to an
> > > +      * empty queue.
> > > +      */
> > > +     virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL);
> > > +     virtqueue_kick(vq);
> > > +
> > > +     /* When host has read buffer, this completes via balloon_ack */
> > > +     wait_event(vb->acked, virtqueue_get_buf(vq, &unused));
> > > +out:
> > > +     mutex_unlock(&vb->balloon_lock);
> > > +}
> > > +
> > >  static void set_page_pfns(struct virtio_balloon *vb,
> > >                         __virtio32 pfns[], struct page *page)
> > >  {
> > > @@ -475,6 +553,7 @@ static int init_vqs(struct virtio_balloon *vb)
> > >       names[VIRTIO_BALLOON_VQ_DEFLATE] = "deflate";
> > >       names[VIRTIO_BALLOON_VQ_STATS] = NULL;
> > >       names[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
> > > +     names[VIRTIO_BALLOON_VQ_HINTING] = NULL;
> > >
> > >       if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
> > >               names[VIRTIO_BALLOON_VQ_STATS] = "stats";
> > > @@ -486,11 +565,19 @@ static int init_vqs(struct virtio_balloon *vb)
> > >               callbacks[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
> > >       }
> > >
> > > +     if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING)) {
> > > +             names[VIRTIO_BALLOON_VQ_HINTING] = "hinting_vq";
> > > +             callbacks[VIRTIO_BALLOON_VQ_HINTING] = balloon_ack;
> > > +     }
> > > +
> > >       err = vb->vdev->config->find_vqs(vb->vdev, VIRTIO_BALLOON_VQ_MAX,
> > >                                        vqs, callbacks, names, NULL, NULL);
> > >       if (err)
> > >               return err;
> > >
> > > +     if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING))
> > > +             vb->hinting_vq = vqs[VIRTIO_BALLOON_VQ_HINTING];
> > > +
> > >       vb->inflate_vq = vqs[VIRTIO_BALLOON_VQ_INFLATE];
> > >       vb->deflate_vq = vqs[VIRTIO_BALLOON_VQ_DEFLATE];
> > >       if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
> > > @@ -929,12 +1016,24 @@ static int virtballoon_probe(struct virtio_device *vdev)
> > >               if (err)
> > >                       goto out_del_balloon_wq;
> > >       }
> > > +
> > > +     vb->a_dev_info.react = virtballoon_aerator_react;
> > > +     vb->a_dev_info.capacity = VIRTIO_BALLOON_ARRAY_HINTS_MAX;
> > > +     if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING)) {
> > > +             err = aerator_startup(&vb->a_dev_info);
> > > +             if (err)
> > > +                     goto out_unregister_shrinker;
> > > +     }
> > > +
> > >       virtio_device_ready(vdev);
> > >
> > >       if (towards_target(vb))
> > >               virtballoon_changed(vdev);
> > >       return 0;
> > >
> > > +out_unregister_shrinker:
> > > +     if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
> > > +             virtio_balloon_unregister_shrinker(vb);
> > >  out_del_balloon_wq:
> > >       if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT))
> > >               destroy_workqueue(vb->balloon_wq);
> > > @@ -963,6 +1062,8 @@ static void virtballoon_remove(struct virtio_device *vdev)
> > >  {
> > >       struct virtio_balloon *vb = vdev->priv;
> > >
> > > +     if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING))
> > > +             aerator_shutdown();
> > >       if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
> > >               virtio_balloon_unregister_shrinker(vb);
> > >       spin_lock_irq(&vb->stop_update_lock);
> > > @@ -1032,6 +1133,7 @@ static int virtballoon_validate(struct virtio_device *vdev)
> > >       VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
> > >       VIRTIO_BALLOON_F_FREE_PAGE_HINT,
> > >       VIRTIO_BALLOON_F_PAGE_POISON,
> > > +     VIRTIO_BALLOON_F_HINTING,
> > >  };
> > >
> > >  static struct virtio_driver virtio_balloon_driver = {
> > > diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
> > > index a1966cd7b677..2b0f62814e22 100644
> > > --- a/include/uapi/linux/virtio_balloon.h
> > > +++ b/include/uapi/linux/virtio_balloon.h
> > > @@ -36,6 +36,7 @@
> > >  #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM      2 /* Deflate balloon on OOM */
> > >  #define VIRTIO_BALLOON_F_FREE_PAGE_HINT      3 /* VQ to report free pages */
> > >  #define VIRTIO_BALLOON_F_PAGE_POISON 4 /* Guest is using page poisoning */
> > > +#define VIRTIO_BALLOON_F_HINTING     5 /* Page hinting virtqueue */
> > >
> > >  /* Size of a PFN in the balloon interface. */
> > >  #define VIRTIO_BALLOON_PFN_SHIFT 12
> >
> >
> >
> > The approach here is very close to what on-demand hinting that is
> > already upstream does.
> >
> > This should have resulted in a most of the code being shared
> > but this does not seem to happen here.
> >
> > Can we unify the code in some way?
> > It can still use a separate feature flag, but there are things
> > I like very much about current hinting code, such as
> > using s/g instead of passing PFNs in a buffer.
> >
> > If this doesn't work could you elaborate on why?
> 
> As far as sending a scatter gather that shouldn't be too much of an
> issue, however I need to double check that I will still be able to
> keep the completions as a single block.
> 
> One significant spot where the "VIRTIO_BALLOON_F_FREE_PAGE_HINT" code
> and my code differs. My code is processing a fixed discreet block of
> pages at a time, whereas the FREE_PAGE_HINT code is slurping up all
> available high-order memory and stuffing it into a giant balloon and
> has more of a streaming setup as it doesn't return things until either
> forced to by the shrinker or once it has processed all available
> memory.

This is what I am saying. Having watched that patchset being developed,
I think that's simply because processing blocks required mm core
changes, which Wei was not up to pushing through.


If we did

	while (1) {
		alloc_pages
		add_buf
		get_buf
		free_pages
	}

We'd end up passing the same page to balloon again and again.

So we end up reserving lots of memory with alloc_pages instead.

What I am saying is that now that you are developing
infrastructure to iterate over free pages,
FREE_PAGE_HINT should be able to use it too.
Whether that's possible might be a good indication of
whether the new mm APIs make sense.

> The basic idea with the bubble hinting was to essentially create mini
> balloons. As such I had based the code off of the balloon inflation
> code. The only spot where it really differs is that I needed the
> ability to pass higher order pages so I tweaked thinks and passed
> "hints" instead of "pfns".

And that is fine. But there isn't really such a big difference with
FREE_PAGE_HINT except FREE_PAGE_HINT triggers upon host request and not
in response to guest load.

-- 
MST

