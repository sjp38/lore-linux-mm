Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B206C76186
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 21:37:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1FE6920C01
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 21:37:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Vz+ggA29"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1FE6920C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9AB308E0006; Mon, 29 Jul 2019 17:37:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 983B38E0002; Mon, 29 Jul 2019 17:37:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 871018E0006; Mon, 29 Jul 2019 17:37:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 677268E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 17:37:40 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id r27so68952096iob.14
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 14:37:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=5cCIss0pU8KiL1WOCYgq6SrmvzURzIys2UArJ6GdY2k=;
        b=tBdS5wZzD2wQjSNuUy4KKCvQGI6CDkOSNiKxC7ERqjn9Yr+kfxM2XYLRwg7kBiMK6b
         IzkTcbYBw9PQ+4F6e/B7VCjt1jBVusG8mWeYTSNPIIfjfKSbbmqA/ck0B6YFmPK9JSQC
         IEDXwRqbkj7mPbGcEi+vA8ObQ3l5zI1DYnolFKIAK6h1R5jEUxOUnFWyvMzURUfrHQPw
         sWs4gVmmQl9LiWbd/S8uj8aUZbrb8mnx7gezO+QQpgRJ+tRRjCFuwVsStPMwmx0hBcKZ
         iPLrHPY/gbVxh1CenOQ3Jk4mlKcWQtIb2xsr7pVjnCERBa6OEcobuVcenzWg+pYeVoDt
         5rIQ==
X-Gm-Message-State: APjAAAUm/j3RnuTU9HDdaMAt87E6EToccJiEHcPOMTV28Jsm66KKJYXw
	UnAwZQdPY5cTRJ1gH4nNlCiP7Ej1dalyLAGyosV7cCrdJjFVFlq4AhRp4dqHFyGqN9f6k+vuaQs
	l9k/OFvzdjDlJt/63BTPOZ+l3NlwkavjYWrHap7aJiSRkZydePzCZiNAwZmnsylt3nw==
X-Received: by 2002:a05:6602:22cc:: with SMTP id e12mr40746742ioe.192.1564436260118;
        Mon, 29 Jul 2019 14:37:40 -0700 (PDT)
X-Received: by 2002:a05:6602:22cc:: with SMTP id e12mr40746606ioe.192.1564436258252;
        Mon, 29 Jul 2019 14:37:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564436258; cv=none;
        d=google.com; s=arc-20160816;
        b=ksyUCObi0CSqdXVC67YG8tDCwS7sGDJy9WHJqT8whwFl3ATNhGA52qzTJFjSlSjiHU
         GlkoNOiGkMGgSgbVOz12EKalZIUX0UDC3a45jtjQwKO4knkyfvFlidJAM4Ue1ejBuKv+
         XK106jUqzYNA146sXC2Kzxbw+vMRoGax77piTMN98J19fa+XrUePBVXohE7uPaWSGK5s
         6+qmctY1y3SGrIEckJbYcAs8xr8AvX2C96iSOb5ey9B64Mw3X9m7Qz6CsEE7IEr4LhTq
         FwQ41u1tCtiVaKfVpHYfA/E5yGRDpH56vhdh8KjPEDAuZJAumCWGcRwAjaAJLogd7DKx
         NZ5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=5cCIss0pU8KiL1WOCYgq6SrmvzURzIys2UArJ6GdY2k=;
        b=XYgZ7jsR1BbWqIewVXY7YIAXjKW++t15vcM3sZfgzXJxDQ4RylHDR7XUGyTDV3aVhq
         nekQS16s13NQgjAlKSr9NxESKpz/sv6jYHIZNedpX0cUwBhL5irwJ5/8R1M/xk1GWp8p
         dO3EkZEBUA/ML4Ea0BNFIMOlBTeoxhxHMT4xClUpv9ydUj7RisUedtyboGYXbZoqP42s
         CTsxn6864oKDCzO8g7CCcF6P0QhaqwsI+05eJ7AsQ/3vwMlN0EEFYaiHptl5XkUJDekI
         c+5deq9yY8/jczE9qRWLXJ3lkOB/QPFBZDxrr4NbYZ4iecAkIRHLqRtm4yLsmom+0OQh
         RNiw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Vz+ggA29;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w13sor40882948iop.80.2019.07.29.14.37.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Jul 2019 14:37:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Vz+ggA29;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=5cCIss0pU8KiL1WOCYgq6SrmvzURzIys2UArJ6GdY2k=;
        b=Vz+ggA29aLJ48naPv3uVKqtuppaCpQ/kdYIpM0wb6c+Qi7sGykFaQRbRVSnOQkH2BL
         u1oq67k2Y3VZJ+DMR8P1t0ARnKG1DTJjjrOvPPkwKOVBJZBXwJBQ1bJlj+dqsd1lgQdZ
         InuDzNcrfv39Jj+o07XwV0tQRWrfiqi1eafRZs5GmfYwS0nVIzKb2YkDHQbLGhx0eJ2F
         O5TjiRzSZ3IPL3Xh8QNphxCwPzk7zVzpXdubW85mcAdo3dhCBM2G9fNLzt6DijA66f/9
         FNESZra1vJheRLUzTrvGaZwPxiYQ2HuPge83FMGnfr0pfA5IloMB6Xt0bO4yy5xroaSi
         3chA==
X-Google-Smtp-Source: APXvYqwD23fVr0zS/hJPKXGQ25v0gjbF/tFuxkk1ZMc570Q8iffL2hFloWKw4n+ABGA4U5+2kfsuCVK5M/Q+Cllvb1s=
X-Received: by 2002:a6b:6409:: with SMTP id t9mr36763195iog.270.1564436257764;
 Mon, 29 Jul 2019 14:37:37 -0700 (PDT)
MIME-Version: 1.0
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
 <20190724171050.7888.62199.stgit@localhost.localdomain> <20190724150224-mutt-send-email-mst@kernel.org>
 <6218af96d7d55935f2cf607d47680edc9b90816e.camel@linux.intel.com>
 <ee5387b1-89af-daf4-8492-8139216c6dcf@redhat.com> <20190724164023-mutt-send-email-mst@kernel.org>
 <CAKgT0Ud6jPpsvJWFAMSnQXAXeNZb116kR7D2Xb7U-7BOtctK_Q@mail.gmail.com>
 <20190729151805-mutt-send-email-mst@kernel.org> <CAKgT0Ufq9RE_4B5bdsYyEf65WJkZsDHMD+MEJVJyev22+J3XAg@mail.gmail.com>
 <20190729163053-mutt-send-email-mst@kernel.org>
In-Reply-To: <20190729163053-mutt-send-email-mst@kernel.org>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Mon, 29 Jul 2019 14:37:26 -0700
Message-ID: <CAKgT0UfxQb2aLiTKz5JeHt76R8WFQcnVg_wq1wxJV_1UhbPJMg@mail.gmail.com>
Subject: Re: [PATCH v2 QEMU] virtio-balloon: Provide a interface for "bubble hinting"
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: wei.w.wang@intel.com, Nitesh Narayan Lal <nitesh@redhat.com>, 
	Alexander Duyck <alexander.h.duyck@linux.intel.com>, kvm list <kvm@vger.kernel.org>, 
	David Hildenbrand <david@redhat.com>, Dave Hansen <dave.hansen@intel.com>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Yang Zhang <yang.zhang.wz@gmail.com>, pagupta@redhat.com, 
	Rik van Riel <riel@surriel.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, lcapitulino@redhat.com, 
	Andrea Arcangeli <aarcange@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, dan.j.williams@intel.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 29, 2019 at 1:49 PM Michael S. Tsirkin <mst@redhat.com> wrote:
>
> On Mon, Jul 29, 2019 at 01:21:32PM -0700, Alexander Duyck wrote:
> > On Mon, Jul 29, 2019 at 12:25 PM Michael S. Tsirkin <mst@redhat.com> wrote:
> > >
> > > On Mon, Jul 29, 2019 at 09:58:04AM -0700, Alexander Duyck wrote:
> > > > On Wed, Jul 24, 2019 at 1:42 PM Michael S. Tsirkin <mst@redhat.com> wrote:
> > > > >
> > > > > On Wed, Jul 24, 2019 at 04:29:27PM -0400, Nitesh Narayan Lal wrote:
> > > > > >
> > > > > > On 7/24/19 4:18 PM, Alexander Duyck wrote:
> > > > > > > On Wed, 2019-07-24 at 15:02 -0400, Michael S. Tsirkin wrote:
> > > > > > >> On Wed, Jul 24, 2019 at 10:12:10AM -0700, Alexander Duyck wrote:
> > > > > > >>> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > > > > >>>
> > > > > > >>> Add support for what I am referring to as "bubble hinting". Basically the
> > > > > > >>> idea is to function very similar to how the balloon works in that we
> > > > > > >>> basically end up madvising the page as not being used. However we don't
> > > > > > >>> really need to bother with any deflate type logic since the page will be
> > > > > > >>> faulted back into the guest when it is read or written to.
> > > > > > >>>
> > > > > > >>> This is meant to be a simplification of the existing balloon interface
> > > > > > >>> to use for providing hints to what memory needs to be freed. I am assuming
> > > > > > >>> this is safe to do as the deflate logic does not actually appear to do very
> > > > > > >>> much other than tracking what subpages have been released and which ones
> > > > > > >>> haven't.
> > > > > > >>>
> > > > > > >>> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > > > > >>> ---
> > > > > > >>>  hw/virtio/virtio-balloon.c                      |   40 +++++++++++++++++++++++
> > > > > > >>>  include/hw/virtio/virtio-balloon.h              |    2 +
> > > > > > >>>  include/standard-headers/linux/virtio_balloon.h |    1 +
> > > > > > >>>  3 files changed, 42 insertions(+), 1 deletion(-)
> > > > > > >>>
> > > > > > >>> diff --git a/hw/virtio/virtio-balloon.c b/hw/virtio/virtio-balloon.c
> > > > > > >>> index 2112874055fb..70c0004c0f88 100644
> > > > > > >>> --- a/hw/virtio/virtio-balloon.c
> > > > > > >>> +++ b/hw/virtio/virtio-balloon.c
> > > > > > >>> @@ -328,6 +328,39 @@ static void balloon_stats_set_poll_interval(Object *obj, Visitor *v,
> > > > > > >>>      balloon_stats_change_timer(s, 0);
> > > > > > >>>  }
> > > > > > >>>
> > > > > > >>> +static void virtio_bubble_handle_output(VirtIODevice *vdev, VirtQueue *vq)
> > > > > > >>> +{
> > > > > > >>> +    VirtQueueElement *elem;
> > > > > > >>> +
> > > > > > >>> +    while ((elem = virtqueue_pop(vq, sizeof(VirtQueueElement)))) {
> > > > > > >>> +         unsigned int i;
> > > > > > >>> +
> > > > > > >>> +        for (i = 0; i < elem->in_num; i++) {
> > > > > > >>> +            void *addr = elem->in_sg[i].iov_base;
> > > > > > >>> +            size_t size = elem->in_sg[i].iov_len;
> > > > > > >>> +            ram_addr_t ram_offset;
> > > > > > >>> +            size_t rb_page_size;
> > > > > > >>> +            RAMBlock *rb;
> > > > > > >>> +
> > > > > > >>> +            if (qemu_balloon_is_inhibited())
> > > > > > >>> +                continue;
> > > > > > >>> +
> > > > > > >>> +            rb = qemu_ram_block_from_host(addr, false, &ram_offset);
> > > > > > >>> +            rb_page_size = qemu_ram_pagesize(rb);
> > > > > > >>> +
> > > > > > >>> +            /* For now we will simply ignore unaligned memory regions */
> > > > > > >>> +            if ((ram_offset | size) & (rb_page_size - 1))
> > > > > > >>> +                continue;
> > > > > > >>> +
> > > > > > >>> +            ram_block_discard_range(rb, ram_offset, size);
> > > > > > >> I suspect this needs to do like the migration type of
> > > > > > >> hinting and get disabled if page poisoning is in effect.
> > > > > > >> Right?
> > > > > > > Shouldn't something like that end up getting handled via
> > > > > > > qemu_balloon_is_inhibited, or did I miss something there? I assumed cases
> > > > > > > like that would end up setting qemu_balloon_is_inhibited to true, if that
> > > > > > > isn't the case then I could add some additional conditions. I would do it
> > > > > > > in about the same spot as the qemu_balloon_is_inhibited check.
> > > > > > I don't think qemu_balloon_is_inhibited() will take care of the page poisoning
> > > > > > situations.
> > > > > > If I am not wrong we may have to look to extend VIRTIO_BALLOON_F_PAGE_POISON
> > > > > > support as per Michael's suggestion.
> > > > >
> > > > >
> > > > > BTW upstream qemu seems to ignore VIRTIO_BALLOON_F_PAGE_POISON ATM.
> > > > > Which is probably a bug.
> > > > > Wei, could you take a look pls?
> > > >
> > > > So I was looking at sorting out this for the unused page reporting
> > > > that I am working on and it occurred to me that I don't think we can
> > > > do the free page hinting if any sort of poison validation is present.
> > > > The problem is that free page hinting simply stops the page from being
> > > > migrated. As a result if there was stale data present it will just
> > > > leave it there instead of zeroing it or writing it to alternating 1s
> > > > and 0s.
> > >
> > > stale data where? on source or on destination?
> > > do you mean the case where memory was corrupted?
> > >
> >
> > Actually I am getting my implementation and this one partially mixed
> > up again. I was thinking that the page just gets put back. However it
> > doesn't. Instead free_pages is called. As such it is going to dirty
> > the page by poisoning it as soon as the hinting is complete.
> >
> > In some ways it is worse because I think page poisoning combined with
> > free page hinting will make the VM nearly unusable because it will be
> > burning cycles allocating all memory, and then poisoning all those
> > pages on free. So it will be populating the dirty bitmap with all free
> > memory each time it goes through and attempts to determine what memory
> > is free.
>
> Right, it does make it useless.
>
> I really consider this a bug: page should be given to hypervisor after
> it's poisoned. Then at least with 0 poison we could just mark it clean.
> For non-zero poison, we could think about adding kvm APIs for
> aggressively mapping all freed pages to a single non-zero one with COW.
>
> I guess it's prudent to sacrifice another feature bit if/when
> we fix it properly, saving a feature bit isn't worth
> the risk that someone shipped a guest like this.
>
> But it does show why just using alloc/free for hinting isn't
> as great an idea as it seems on the surface.

What I think I can do for now is address this partially in QEMU. What
I will do is just return without starting the free page hinting in
virtio_balloon_free_page_start() if VIRTIO_BALLOON_F_PAGE_POISON is
set.

> > > >
> > > > Also it looks like the VIRTIO_BALLOON_F_PAGE_POISON feature is
> > > > assuming that 0 means that page poisoning is disabled,
> > > > when in reality
> > > > it might just mean we are using the value zero to poison pages instead
> > > > of the 0xaa pattern. As such I think there are several cases where we
> > > > could incorrectly flag the pages with the hint and result in the
> > > > migrated guest reporting pages that contain non-poison values.
> > > >
> > >
> > >
> > > Well guest has this code:
> > > static int virtballoon_validate(struct virtio_device *vdev)
> > > {
> > >         if (!page_poisoning_enabled())
> > >                 __virtio_clear_bit(vdev, VIRTIO_BALLOON_F_PAGE_POISON);
> > >
> > >         __virtio_clear_bit(vdev, VIRTIO_F_IOMMU_PLATFORM);
> > >         return 0;
> > > }
> > >
> > > So it seems that host can figure out what is going on easily enough.
> > > What did I miss?
> >
> > Okay. So it is clearing that feature bit. I didn't see that part.
> > However that leads to the question of where we should be setting that
> > feature bit in the QEMU side of things. I was looking at setting that
> > bit in virtio_balloon_get_features(). Would that be the appropriate
> > place to set that so that the feature flag is reset when we are
> > changing OSes or rebooting the guest?
>
> We have
>     DEFINE_PROP_BIT("free-page-hint", VirtIOBalloon, host_features,
>                     VIRTIO_BALLOON_F_FREE_PAGE_HINT, false),
> and poison should be there, too.

I don't think we want it to be user configurable though, do we? It
seems like it should be set if either free-page-hint or
unused-page-reporting are enabled. Then the guest can disable it on
its end if poisoning is not present.

> > > > The zero assumption works for unused page reporting since we will be
> > > > zeroing out the page when it is faulted back into the guest, however
> > > > the same doesn't work for the free page hint since it is simply
> > > > skipping the migration of the recently dirtied page.
> > >
> > > Right but the dirtied page is normally full of 0 since that is the
> > > poison value, if we just leave it there we still get 0s, right?
> >
> > So for the unused page reporting which I am working on we can still
> > hint the page away since it will be 0s, and us returning the pages
> > doesn't alter the page data. However for the free page hinting I don't
> > think we can.
> >
> > With page poisoning and free page hinting I am thinking we should just
> > disable the free page hinting as I don't see how there can be any
> > advantage to it if page poisoning is enbled. Basically the thing that
> > makes the hinting "safe" will sabotage it since for every page we
> > don't migrate we will also be marking as dirty for the next iteration
> > through migration. As such we are just pushing the migration of any
> > free pages until the VM has stopped since the VM will just keep
> > dirtying the free pages until it stops hinting.
>
>
> Right this was discussed at the time for non-zero poison.
>
> For hinting, my argument was simple: the reason it's useless is contained
> within the hypervisor. So don't put the logic in the guest:
> hypervisor can see poison is set and not request hints from guest.

Agreed. What I am going to do is store off the config value to a value
local to the vdev when the config is written from the guest and the
VIRTIO_BALLOON_F_PAGE_POISON value is set.

Like I mentioned above I will just disable the free page hinting
functionality by just not having the hypervisor request hinting if
page poisoning is set. I will just drop the reports from the guest
when the poison value is non-zero.

> For reporting, as you say it works with 0s and we can thinkably
> make it work with non-0s down the road.
> Until we do we can always have the hypervisor do something like
>
>         if (poisoning && poison != 0)
>                 return;
>         madvise(MADV_FREE);

Agreed.

