Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EFBBCC3A5A2
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 14:13:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9681E23402
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 14:13:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GwzYwTSi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9681E23402
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FD646B0005; Tue,  3 Sep 2019 10:13:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2DEBE6B0006; Tue,  3 Sep 2019 10:13:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1EB456B0007; Tue,  3 Sep 2019 10:13:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0144.hostedemail.com [216.40.44.144])
	by kanga.kvack.org (Postfix) with ESMTP id F14A66B0005
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 10:13:46 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 8D02D181AC9BA
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 14:13:46 +0000 (UTC)
X-FDA: 75893802852.10.copy16_3bd9dc63f14f
X-HE-Tag: copy16_3bd9dc63f14f
X-Filterd-Recvd-Size: 10487
Received: from mail-io1-f67.google.com (mail-io1-f67.google.com [209.85.166.67])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 14:13:45 +0000 (UTC)
Received: by mail-io1-f67.google.com with SMTP id x4so36108570iog.13
        for <linux-mm@kvack.org>; Tue, 03 Sep 2019 07:13:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Y/VL+PK0aa7I0TUMW6S0h1e2db0cJYFyho+B7GBvI98=;
        b=GwzYwTSiPE7hY1aHgKJnz9pezIkSHDijyqXQyYTSugckr8scV4I8dkc1ZOxY4cS6/n
         MnBX1ZWOkEFM30Z8JnKT0FudX3lStl5DS9bS6cHeWjQVF6LRovZRLBJmaeZPrdgCuwrt
         rA+nbe7NeADRj5v9jNLrPg9OZ1Or3SBd3eTw7z5m2H/c8Y2WgczrrT65Fy+pTn6bmxSA
         6RILUSshYtPnGBxTiVBjMtEMS0Ikr7qSHJyWm6yO6+nIUdhuVktMh31qPYknUuFbfTaw
         mshIz4m/pNnss5HQL/7tLfTVKdv8qlNhtjXrd7adlxr4RBppFEYLb+v43mTMGOk3LXHG
         Vpcg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=Y/VL+PK0aa7I0TUMW6S0h1e2db0cJYFyho+B7GBvI98=;
        b=DB8Gz7xcFptHiix9pgo6zWDjVdTnwseKaGcmh9yYtz5O9gZazfTa0N9Z5FZuHahlgV
         BuaTnlvZpjF814oWSTAFeGBLpoMQ4TUUJZ+02s6sQ5BPIMamakuut6c015zOAXG3R/2s
         EJGS/+uO0dedI7nfHOcanLnVRaZvGMvToDCgm2BjwMzHVbJJGr+iEZ5UlV2FdOIzHyxY
         Z42V8gYUd09xqPj2vDK2DDPjEGMjRQR/MmwI5cXVwEBwAB11XBB/5HjSSz6IJhAoOYKm
         Kn2nDxZms74aaDg/1vR91gweqqutFcrIGDHpesB68vqeqxRYFcF3SBiB4EVCqIScQaqP
         X9xQ==
X-Gm-Message-State: APjAAAUvGxKLPduWEVsW9SIoYhTlZdDmcRmVSuudn0rP0eCkeAU9KhJP
	chJKOWhGNfTwH5zqldlUu6Hj5H9HyChva2ZvB/s=
X-Google-Smtp-Source: APXvYqwn0spCMIfJkxs1b43ts9V9mY6LvVn3Y5MjwOEMgObF3Hu8yinoT5tXr1xnME1F645J0W7swYVHJ563jc5M0GM=
X-Received: by 2002:a6b:fc02:: with SMTP id r2mr19977135ioh.15.1567520024575;
 Tue, 03 Sep 2019 07:13:44 -0700 (PDT)
MIME-Version: 1.0
References: <20190812213158.22097.30576.stgit@localhost.localdomain>
 <20190812213356.22097.20751.stgit@localhost.localdomain> <20190903032759-mutt-send-email-mst@kernel.org>
In-Reply-To: <20190903032759-mutt-send-email-mst@kernel.org>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 3 Sep 2019 07:13:32 -0700
Message-ID: <CAKgT0UfFU3oT5kKZk999XfrM6oducTizcUL5xpDWmMG=oP04ow@mail.gmail.com>
Subject: Re: [PATCH v5 6/6] virtio-balloon: Add support for providing unused
 page reports to host
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>, 
	David Hildenbrand <david@redhat.com>, Dave Hansen <dave.hansen@intel.com>, 
	LKML <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>, 
	Michal Hocko <mhocko@kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Andrew Morton <akpm@linux-foundation.org>, virtio-dev@lists.oasis-open.org, 
	Oscar Salvador <osalvador@suse.de>, Yang Zhang <yang.zhang.wz@gmail.com>, 
	Pankaj Gupta <pagupta@redhat.com>, Rik van Riel <riel@surriel.com>, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, lcapitulino@redhat.com, 
	"Wang, Wei W" <wei.w.wang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, 
	Paolo Bonzini <pbonzini@redhat.com>, Dan Williams <dan.j.williams@intel.com>, 
	Alexander Duyck <alexander.h.duyck@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 3, 2019 at 12:32 AM Michael S. Tsirkin <mst@redhat.com> wrote:
>
> On Mon, Aug 12, 2019 at 02:33:56PM -0700, Alexander Duyck wrote:
> > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> >
> > Add support for the page reporting feature provided by virtio-balloon.
> > Reporting differs from the regular balloon functionality in that is is
> > much less durable than a standard memory balloon. Instead of creating a
> > list of pages that cannot be accessed the pages are only inaccessible
> > while they are being indicated to the virtio interface. Once the
> > interface has acknowledged them they are placed back into their respective
> > free lists and are once again accessible by the guest system.
> >
> > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > ---
> >  drivers/virtio/Kconfig              |    1 +
> >  drivers/virtio/virtio_balloon.c     |   65 +++++++++++++++++++++++++++++++++++
> >  include/uapi/linux/virtio_balloon.h |    1 +
> >  3 files changed, 67 insertions(+)
> >
> > diff --git a/drivers/virtio/Kconfig b/drivers/virtio/Kconfig
> > index 078615cf2afc..4b2dd8259ff5 100644
> > --- a/drivers/virtio/Kconfig
> > +++ b/drivers/virtio/Kconfig
> > @@ -58,6 +58,7 @@ config VIRTIO_BALLOON
> >       tristate "Virtio balloon driver"
> >       depends on VIRTIO
> >       select MEMORY_BALLOON
> > +     select PAGE_REPORTING
> >       ---help---
> >        This driver supports increasing and decreasing the amount
> >        of memory within a KVM guest.
> > diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> > index 2c19457ab573..52f9eeda1877 100644
> > --- a/drivers/virtio/virtio_balloon.c
> > +++ b/drivers/virtio/virtio_balloon.c
> > @@ -19,6 +19,7 @@
> >  #include <linux/mount.h>
> >  #include <linux/magic.h>
> >  #include <linux/pseudo_fs.h>
> > +#include <linux/page_reporting.h>
> >
> >  /*
> >   * Balloon device works in 4K page units.  So each page is pointed to by
> > @@ -37,6 +38,9 @@
> >  #define VIRTIO_BALLOON_FREE_PAGE_SIZE \
> >       (1 << (VIRTIO_BALLOON_FREE_PAGE_ORDER + PAGE_SHIFT))
> >
> > +/*  limit on the number of pages that can be on the reporting vq */
> > +#define VIRTIO_BALLOON_VRING_HINTS_MAX       16
> > +
> >  #ifdef CONFIG_BALLOON_COMPACTION
> >  static struct vfsmount *balloon_mnt;
> >  #endif
> > @@ -46,6 +50,7 @@ enum virtio_balloon_vq {
> >       VIRTIO_BALLOON_VQ_DEFLATE,
> >       VIRTIO_BALLOON_VQ_STATS,
> >       VIRTIO_BALLOON_VQ_FREE_PAGE,
> > +     VIRTIO_BALLOON_VQ_REPORTING,
> >       VIRTIO_BALLOON_VQ_MAX
> >  };
> >
> > @@ -113,6 +118,10 @@ struct virtio_balloon {
> >
> >       /* To register a shrinker to shrink memory upon memory pressure */
> >       struct shrinker shrinker;
> > +
> > +     /* Unused page reporting device */
> > +     struct virtqueue *reporting_vq;
> > +     struct page_reporting_dev_info ph_dev_info;
> >  };
> >
> >  static struct virtio_device_id id_table[] = {
> > @@ -152,6 +161,32 @@ static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
> >
> >  }
> >
> > +void virtballoon_unused_page_report(struct page_reporting_dev_info *ph_dev_info,
> > +                                 unsigned int nents)
> > +{
> > +     struct virtio_balloon *vb =
> > +             container_of(ph_dev_info, struct virtio_balloon, ph_dev_info);
> > +     struct virtqueue *vq = vb->reporting_vq;
> > +     unsigned int unused, err;
> > +
> > +     /* We should always be able to add these buffers to an empty queue. */
> > +     err = virtqueue_add_inbuf(vq, ph_dev_info->sg, nents, vb,
> > +                               GFP_NOWAIT | __GFP_NOWARN);
> > +
> > +     /*
> > +      * In the extremely unlikely case that something has changed and we
> > +      * are able to trigger an error we will simply display a warning
> > +      * and exit without actually processing the pages.
> > +      */
> > +     if (WARN_ON(err))
> > +             return;
> > +
> > +     virtqueue_kick(vq);
> > +
> > +     /* When host has read buffer, this completes via balloon_ack */
> > +     wait_event(vb->acked, virtqueue_get_buf(vq, &unused));
> > +}
> > +
> >  static void set_page_pfns(struct virtio_balloon *vb,
> >                         __virtio32 pfns[], struct page *page)
> >  {
> > @@ -476,6 +511,7 @@ static int init_vqs(struct virtio_balloon *vb)
> >       names[VIRTIO_BALLOON_VQ_DEFLATE] = "deflate";
> >       names[VIRTIO_BALLOON_VQ_STATS] = NULL;
> >       names[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
> > +     names[VIRTIO_BALLOON_VQ_REPORTING] = NULL;
> >
> >       if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
> >               names[VIRTIO_BALLOON_VQ_STATS] = "stats";
> > @@ -487,11 +523,19 @@ static int init_vqs(struct virtio_balloon *vb)
> >               callbacks[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
> >       }
> >
> > +     if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_REPORTING)) {
> > +             names[VIRTIO_BALLOON_VQ_REPORTING] = "reporting_vq";
> > +             callbacks[VIRTIO_BALLOON_VQ_REPORTING] = balloon_ack;
> > +     }
> > +
> >       err = vb->vdev->config->find_vqs(vb->vdev, VIRTIO_BALLOON_VQ_MAX,
> >                                        vqs, callbacks, names, NULL, NULL);
> >       if (err)
> >               return err;
> >
> > +     if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_REPORTING))
> > +             vb->reporting_vq = vqs[VIRTIO_BALLOON_VQ_REPORTING];
> > +
> >       vb->inflate_vq = vqs[VIRTIO_BALLOON_VQ_INFLATE];
> >       vb->deflate_vq = vqs[VIRTIO_BALLOON_VQ_DEFLATE];
> >       if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
> > @@ -931,12 +975,30 @@ static int virtballoon_probe(struct virtio_device *vdev)
> >               if (err)
> >                       goto out_del_balloon_wq;
> >       }
> > +
> > +     vb->ph_dev_info.report = virtballoon_unused_page_report;
> > +     if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_REPORTING)) {
> > +             unsigned int capacity;
> > +
> > +             capacity = min_t(unsigned int,
> > +                              virtqueue_get_vring_size(vb->reporting_vq) - 1,
> > +                              VIRTIO_BALLOON_VRING_HINTS_MAX);
>
> Hmm why - 1 exactly?
> This might end up being 0 in the unusual configuration of vq size 1.
> Also, VIRTIO_BALLOON_VRING_HINTS_MAX is a power of 2 but
> virtqueue_get_vring_size(vb->reporting_vq) - 1 won't
> be if we are using split rings - donnu if that matters.

Is a vq size of 1 valid? Does that mean you can use that 1 descriptor?

Odds are I probably misunderstood the ring config in the other hinting
implementation. Looking it over now I guess it was adding one
additional entry for a command header and that was why it was
reserving one additional slot. I can update the code to drop the "- 1"
if the ring is capable of being fully utilized.

Thanks.

- Alex

