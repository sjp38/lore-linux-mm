Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1AC1C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 22:11:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 84AA8216C8
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 22:11:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 84AA8216C8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 218368E0003; Mon, 29 Jul 2019 18:11:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F08A8E0002; Mon, 29 Jul 2019 18:11:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1062A8E0003; Mon, 29 Jul 2019 18:11:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id E411E8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 18:11:36 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id m25so56336634qtn.18
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 15:11:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=ALqlLhg7YVLING1D36Gu74QDTz3FR0Y+jcw5/H0ey+0=;
        b=UdKbLwdKNbCggdTirqMHRLJrhbm/AgKLgAsS9aAXUFgJD+7M52EmiLm4CP6s8jbAxg
         +b9tqTL4aW9cFFDcnt/M/j5WtzeDRFmjpyZPlwDhFFTWxwCo3MTmWuxm55HDrHwYjwei
         xcT0UIEGt6VyfcCpaM/UW3tokAFafs3qzib6x0JbtQhTX1/ADWjxoxTJ+f7jb+RsEM8d
         XxAGkVRSnYR9lyhwoNg4d1yIa1yDr6Y9lucc6/pOrtNffizodgbf9fff2dcLpnS4/Egm
         d98WMTTP2lXLOhMFbkramQ2Y3dMB0JqK9UUFru5PdRxpuQljDVuAUxkLliEScMH89wJ2
         MVeQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU5DkxTIDlWGRBQb1jBW6X05KztfyF9NfCallEuzgugBUxw0u9j
	nyaJhYadxb0KXeSYAyy5dhEe40ITHPs6ehn6nZi2tPzHyhgPOqMqun9a5R7+jA5k46yCNFF6KUY
	XAYdgrWc/REIVIHb0ymLEbA88oYnK7emqerbRbHjGmMTsgUaBtWkwoYSQch77akEgKQ==
X-Received: by 2002:a0c:d0f6:: with SMTP id b51mr77929569qvh.225.1564438296661;
        Mon, 29 Jul 2019 15:11:36 -0700 (PDT)
X-Received: by 2002:a0c:d0f6:: with SMTP id b51mr77929493qvh.225.1564438295447;
        Mon, 29 Jul 2019 15:11:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564438295; cv=none;
        d=google.com; s=arc-20160816;
        b=uzbny3VOPSxL8iMFMEFLPQirLlaQJL5sWIIeMnRKWmFekm69VU0UfEma9djmyPHKGw
         zFWmI4Aq6jokYGSX4ipWr6g7A0YSJy00KSIe28zjEscdHjG6f3zqrHU1n11MCwQAXjtr
         +mCYWvbA3NWsY66V7SV1Ww04AgsIsKBNelmN/JgN1Nzam8YLt/BRt5HBb1n8cymoSQeA
         Wf6xNu8j1me+4X84NQqvS0J3hcbJVX34x74VoV+hLx5x8/tfJS0gtsps1fNkO7iSJ7Ra
         ZLEoTzY3bLtRd9WKDB7SBoAYi3FeqOhvpv83AYfdhef6tdQYU0iBv8yaLW4cjUN1e/qq
         ZrcQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=ALqlLhg7YVLING1D36Gu74QDTz3FR0Y+jcw5/H0ey+0=;
        b=EtsZVwsko3D9mLYpqplwHObhHe3ZoVCF77ZGcaDElm87bKVXPjh7bxfU9tc/i9ixCY
         ODUEs5bmMAF7dlyRlHL+vwzagC2pZEYhjT2SyhDiFsphurgrvxVJsQaQmhDv5rxWPUda
         7XvNUld0UT9gcycpRNqk5PrJG8Ji/h+F7xvh07e1S8lvW+9XwixPALVwCpFKzcFEG04R
         rn8Nf7sI6tb/F5wmhD6LzayF2VptYDXEQ1yq5tknYAaIRWKzICXq8rAvSAy417L4DD56
         SM894FINRMLQ5ZjMtnX8dzKqUG3suI/hFPRvDqKFhpyUcvwUfxUNMeFjXFggXxo1HEN7
         libA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w13sor82414329qta.62.2019.07.29.15.11.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Jul 2019 15:11:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqxJ0s6j/+aW7uhUJ7Ou5tiS0KDhEtIRqfl6oc0MOrCIsIfMaaGujQ6r+wGU4kSPuTh7F5lDQQ==
X-Received: by 2002:ac8:6898:: with SMTP id m24mr78017676qtq.362.1564438295068;
        Mon, 29 Jul 2019 15:11:35 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id y3sm30240363qtj.46.2019.07.29.15.11.28
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 15:11:33 -0700 (PDT)
Date: Mon, 29 Jul 2019 18:11:26 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: wei.w.wang@intel.com, Nitesh Narayan Lal <nitesh@redhat.com>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	kvm list <kvm@vger.kernel.org>,
	David Hildenbrand <david@redhat.com>,
	Dave Hansen <dave.hansen@intel.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Yang Zhang <yang.zhang.wz@gmail.com>, pagupta@redhat.com,
	Rik van Riel <riel@surriel.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	lcapitulino@redhat.com, Andrea Arcangeli <aarcange@redhat.com>,
	Paolo Bonzini <pbonzini@redhat.com>, dan.j.williams@intel.com
Subject: Re: [PATCH v2 QEMU] virtio-balloon: Provide a interface for "bubble
 hinting"
Message-ID: <20190729180806-mutt-send-email-mst@kernel.org>
References: <20190724171050.7888.62199.stgit@localhost.localdomain>
 <20190724150224-mutt-send-email-mst@kernel.org>
 <6218af96d7d55935f2cf607d47680edc9b90816e.camel@linux.intel.com>
 <ee5387b1-89af-daf4-8492-8139216c6dcf@redhat.com>
 <20190724164023-mutt-send-email-mst@kernel.org>
 <CAKgT0Ud6jPpsvJWFAMSnQXAXeNZb116kR7D2Xb7U-7BOtctK_Q@mail.gmail.com>
 <20190729151805-mutt-send-email-mst@kernel.org>
 <CAKgT0Ufq9RE_4B5bdsYyEf65WJkZsDHMD+MEJVJyev22+J3XAg@mail.gmail.com>
 <20190729163053-mutt-send-email-mst@kernel.org>
 <CAKgT0UfxQb2aLiTKz5JeHt76R8WFQcnVg_wq1wxJV_1UhbPJMg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKgT0UfxQb2aLiTKz5JeHt76R8WFQcnVg_wq1wxJV_1UhbPJMg@mail.gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 29, 2019 at 02:37:26PM -0700, Alexander Duyck wrote:
> On Mon, Jul 29, 2019 at 1:49 PM Michael S. Tsirkin <mst@redhat.com> wrote:
> >
> > On Mon, Jul 29, 2019 at 01:21:32PM -0700, Alexander Duyck wrote:
> > > On Mon, Jul 29, 2019 at 12:25 PM Michael S. Tsirkin <mst@redhat.com> wrote:
> > > >
> > > > On Mon, Jul 29, 2019 at 09:58:04AM -0700, Alexander Duyck wrote:
> > > > > On Wed, Jul 24, 2019 at 1:42 PM Michael S. Tsirkin <mst@redhat.com> wrote:
> > > > > >
> > > > > > On Wed, Jul 24, 2019 at 04:29:27PM -0400, Nitesh Narayan Lal wrote:
> > > > > > >
> > > > > > > On 7/24/19 4:18 PM, Alexander Duyck wrote:
> > > > > > > > On Wed, 2019-07-24 at 15:02 -0400, Michael S. Tsirkin wrote:
> > > > > > > >> On Wed, Jul 24, 2019 at 10:12:10AM -0700, Alexander Duyck wrote:
> > > > > > > >>> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > > > > > >>>
> > > > > > > >>> Add support for what I am referring to as "bubble hinting". Basically the
> > > > > > > >>> idea is to function very similar to how the balloon works in that we
> > > > > > > >>> basically end up madvising the page as not being used. However we don't
> > > > > > > >>> really need to bother with any deflate type logic since the page will be
> > > > > > > >>> faulted back into the guest when it is read or written to.
> > > > > > > >>>
> > > > > > > >>> This is meant to be a simplification of the existing balloon interface
> > > > > > > >>> to use for providing hints to what memory needs to be freed. I am assuming
> > > > > > > >>> this is safe to do as the deflate logic does not actually appear to do very
> > > > > > > >>> much other than tracking what subpages have been released and which ones
> > > > > > > >>> haven't.
> > > > > > > >>>
> > > > > > > >>> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > > > > > >>> ---
> > > > > > > >>>  hw/virtio/virtio-balloon.c                      |   40 +++++++++++++++++++++++
> > > > > > > >>>  include/hw/virtio/virtio-balloon.h              |    2 +
> > > > > > > >>>  include/standard-headers/linux/virtio_balloon.h |    1 +
> > > > > > > >>>  3 files changed, 42 insertions(+), 1 deletion(-)
> > > > > > > >>>
> > > > > > > >>> diff --git a/hw/virtio/virtio-balloon.c b/hw/virtio/virtio-balloon.c
> > > > > > > >>> index 2112874055fb..70c0004c0f88 100644
> > > > > > > >>> --- a/hw/virtio/virtio-balloon.c
> > > > > > > >>> +++ b/hw/virtio/virtio-balloon.c
> > > > > > > >>> @@ -328,6 +328,39 @@ static void balloon_stats_set_poll_interval(Object *obj, Visitor *v,
> > > > > > > >>>      balloon_stats_change_timer(s, 0);
> > > > > > > >>>  }
> > > > > > > >>>
> > > > > > > >>> +static void virtio_bubble_handle_output(VirtIODevice *vdev, VirtQueue *vq)
> > > > > > > >>> +{
> > > > > > > >>> +    VirtQueueElement *elem;
> > > > > > > >>> +
> > > > > > > >>> +    while ((elem = virtqueue_pop(vq, sizeof(VirtQueueElement)))) {
> > > > > > > >>> +         unsigned int i;
> > > > > > > >>> +
> > > > > > > >>> +        for (i = 0; i < elem->in_num; i++) {
> > > > > > > >>> +            void *addr = elem->in_sg[i].iov_base;
> > > > > > > >>> +            size_t size = elem->in_sg[i].iov_len;
> > > > > > > >>> +            ram_addr_t ram_offset;
> > > > > > > >>> +            size_t rb_page_size;
> > > > > > > >>> +            RAMBlock *rb;
> > > > > > > >>> +
> > > > > > > >>> +            if (qemu_balloon_is_inhibited())
> > > > > > > >>> +                continue;
> > > > > > > >>> +
> > > > > > > >>> +            rb = qemu_ram_block_from_host(addr, false, &ram_offset);
> > > > > > > >>> +            rb_page_size = qemu_ram_pagesize(rb);
> > > > > > > >>> +
> > > > > > > >>> +            /* For now we will simply ignore unaligned memory regions */
> > > > > > > >>> +            if ((ram_offset | size) & (rb_page_size - 1))
> > > > > > > >>> +                continue;
> > > > > > > >>> +
> > > > > > > >>> +            ram_block_discard_range(rb, ram_offset, size);
> > > > > > > >> I suspect this needs to do like the migration type of
> > > > > > > >> hinting and get disabled if page poisoning is in effect.
> > > > > > > >> Right?
> > > > > > > > Shouldn't something like that end up getting handled via
> > > > > > > > qemu_balloon_is_inhibited, or did I miss something there? I assumed cases
> > > > > > > > like that would end up setting qemu_balloon_is_inhibited to true, if that
> > > > > > > > isn't the case then I could add some additional conditions. I would do it
> > > > > > > > in about the same spot as the qemu_balloon_is_inhibited check.
> > > > > > > I don't think qemu_balloon_is_inhibited() will take care of the page poisoning
> > > > > > > situations.
> > > > > > > If I am not wrong we may have to look to extend VIRTIO_BALLOON_F_PAGE_POISON
> > > > > > > support as per Michael's suggestion.
> > > > > >
> > > > > >
> > > > > > BTW upstream qemu seems to ignore VIRTIO_BALLOON_F_PAGE_POISON ATM.
> > > > > > Which is probably a bug.
> > > > > > Wei, could you take a look pls?
> > > > >
> > > > > So I was looking at sorting out this for the unused page reporting
> > > > > that I am working on and it occurred to me that I don't think we can
> > > > > do the free page hinting if any sort of poison validation is present.
> > > > > The problem is that free page hinting simply stops the page from being
> > > > > migrated. As a result if there was stale data present it will just
> > > > > leave it there instead of zeroing it or writing it to alternating 1s
> > > > > and 0s.
> > > >
> > > > stale data where? on source or on destination?
> > > > do you mean the case where memory was corrupted?
> > > >
> > >
> > > Actually I am getting my implementation and this one partially mixed
> > > up again. I was thinking that the page just gets put back. However it
> > > doesn't. Instead free_pages is called. As such it is going to dirty
> > > the page by poisoning it as soon as the hinting is complete.
> > >
> > > In some ways it is worse because I think page poisoning combined with
> > > free page hinting will make the VM nearly unusable because it will be
> > > burning cycles allocating all memory, and then poisoning all those
> > > pages on free. So it will be populating the dirty bitmap with all free
> > > memory each time it goes through and attempts to determine what memory
> > > is free.
> >
> > Right, it does make it useless.
> >
> > I really consider this a bug: page should be given to hypervisor after
> > it's poisoned. Then at least with 0 poison we could just mark it clean.
> > For non-zero poison, we could think about adding kvm APIs for
> > aggressively mapping all freed pages to a single non-zero one with COW.
> >
> > I guess it's prudent to sacrifice another feature bit if/when
> > we fix it properly, saving a feature bit isn't worth
> > the risk that someone shipped a guest like this.
> >
> > But it does show why just using alloc/free for hinting isn't
> > as great an idea as it seems on the surface.
> 
> What I think I can do for now is address this partially in QEMU. What
> I will do is just return without starting the free page hinting in
> virtio_balloon_free_page_start() if VIRTIO_BALLOON_F_PAGE_POISON is
> set.
> 
> > > > >
> > > > > Also it looks like the VIRTIO_BALLOON_F_PAGE_POISON feature is
> > > > > assuming that 0 means that page poisoning is disabled,
> > > > > when in reality
> > > > > it might just mean we are using the value zero to poison pages instead
> > > > > of the 0xaa pattern. As such I think there are several cases where we
> > > > > could incorrectly flag the pages with the hint and result in the
> > > > > migrated guest reporting pages that contain non-poison values.
> > > > >
> > > >
> > > >
> > > > Well guest has this code:
> > > > static int virtballoon_validate(struct virtio_device *vdev)
> > > > {
> > > >         if (!page_poisoning_enabled())
> > > >                 __virtio_clear_bit(vdev, VIRTIO_BALLOON_F_PAGE_POISON);
> > > >
> > > >         __virtio_clear_bit(vdev, VIRTIO_F_IOMMU_PLATFORM);
> > > >         return 0;
> > > > }
> > > >
> > > > So it seems that host can figure out what is going on easily enough.
> > > > What did I miss?
> > >
> > > Okay. So it is clearing that feature bit. I didn't see that part.
> > > However that leads to the question of where we should be setting that
> > > feature bit in the QEMU side of things. I was looking at setting that
> > > bit in virtio_balloon_get_features(). Would that be the appropriate
> > > place to set that so that the feature flag is reset when we are
> > > changing OSes or rebooting the guest?
> >
> > We have
> >     DEFINE_PROP_BIT("free-page-hint", VirtIOBalloon, host_features,
> >                     VIRTIO_BALLOON_F_FREE_PAGE_HINT, false),
> > and poison should be there, too.
> 
> I don't think we want it to be user configurable though, do we? It
> seems like it should be set if either free-page-hint or
> unused-page-reporting are enabled. Then the guest can disable it on
> its end if poisoning is not present.


Oh right. So it can be in virtio_balloon_get_features then, sorry.  We
still do need to make it conditional on a property (internal one,
starting with "x-") for machine compat reasons.



> > > > > The zero assumption works for unused page reporting since we will be
> > > > > zeroing out the page when it is faulted back into the guest, however
> > > > > the same doesn't work for the free page hint since it is simply
> > > > > skipping the migration of the recently dirtied page.
> > > >
> > > > Right but the dirtied page is normally full of 0 since that is the
> > > > poison value, if we just leave it there we still get 0s, right?
> > >
> > > So for the unused page reporting which I am working on we can still
> > > hint the page away since it will be 0s, and us returning the pages
> > > doesn't alter the page data. However for the free page hinting I don't
> > > think we can.
> > >
> > > With page poisoning and free page hinting I am thinking we should just
> > > disable the free page hinting as I don't see how there can be any
> > > advantage to it if page poisoning is enbled. Basically the thing that
> > > makes the hinting "safe" will sabotage it since for every page we
> > > don't migrate we will also be marking as dirty for the next iteration
> > > through migration. As such we are just pushing the migration of any
> > > free pages until the VM has stopped since the VM will just keep
> > > dirtying the free pages until it stops hinting.
> >
> >
> > Right this was discussed at the time for non-zero poison.
> >
> > For hinting, my argument was simple: the reason it's useless is contained
> > within the hypervisor. So don't put the logic in the guest:
> > hypervisor can see poison is set and not request hints from guest.
> 
> Agreed. What I am going to do is store off the config value to a value
> local to the vdev when the config is written from the guest and the
> VIRTIO_BALLOON_F_PAGE_POISON value is set.
> 
> Like I mentioned above I will just disable the free page hinting
> functionality by just not having the hypervisor request hinting if
> page poisoning is set. I will just drop the reports from the guest
> when the poison value is non-zero.

Makes sense. In fact this part is a bugfix, and if you
can post it quickly I'll try to fast track it into 4.1
(might be too late for that, we'll see).

> > For reporting, as you say it works with 0s and we can thinkably
> > make it work with non-0s down the road.
> > Until we do we can always have the hypervisor do something like
> >
> >         if (poisoning && poison != 0)
> >                 return;
> >         madvise(MADV_FREE);
> 
> Agreed.

