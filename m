Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10C8DC433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 16:58:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ABE3B206E0
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 16:58:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qmwBJoRI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ABE3B206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A3D38E0005; Mon, 29 Jul 2019 12:58:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 154458E0002; Mon, 29 Jul 2019 12:58:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 042438E0005; Mon, 29 Jul 2019 12:58:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id D75228E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 12:58:17 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id v11so68153614iop.7
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 09:58:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=DMJX6exOwqjooLEn9qtJXN6JS2y5xnQ/2H7xPTrhJ28=;
        b=HAa7e26n/mVJ7Mxu82WCxh9+Fy3oZaDmkSCwBJh1fjZHp5W40VkpN3iE40K8Q60kOG
         oZtGNgObq3OopLwGOttLHeMgmkoh+m6+1wpR6whLWf18n2mKqA2jbr48scK/rOaehZbn
         dMrrd/zg2oVL47Bxs2BCVpC+zbWCBR+Y+lsjaLGCSg81FZ4xY2ps1G6rP4knC8DB5sZX
         hVYy92yPuL4qIXNrSzxHSdvPojMycPFYPjEkSZ3ALwBZPNRWLEVLfXXA0Yk7TSZygfel
         Qra6ePDsUuNO96RvKgTpZ3S/S/Ttcrk20JOZm07CdNc944Sr4Ro3C3hQVZwU58C+EKKr
         /WYQ==
X-Gm-Message-State: APjAAAXSxfHmz0Jscvp2+GIYsnJElaENcUV/Om6m2v1Bu1aidXcvZus7
	dVVln/yr2axq8FBkIxB2UGallvBB3cTpx72h5hREPoRLY9yL94wuk+F6s4WxgX4uDk3E7qBwrGW
	tITTq/b4Z9eGUkqHCqwj8WfTk4VXYZIup5HaqgvEv3KimvBgL/Pr77Tt2hfn8jSlb2w==
X-Received: by 2002:a5d:8416:: with SMTP id i22mr76757687ion.248.1564419497576;
        Mon, 29 Jul 2019 09:58:17 -0700 (PDT)
X-Received: by 2002:a5d:8416:: with SMTP id i22mr76757630ion.248.1564419496610;
        Mon, 29 Jul 2019 09:58:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564419496; cv=none;
        d=google.com; s=arc-20160816;
        b=lZPN//uKxn26brs4388aTeQLBYmIjoNMdzSfgaeOdOrLIBqV+zYmSWiNyYPubCnwf1
         NhqTaG1+VRKIiV0JoalIBvNrwszYn5gBSwOTXR2vK5A61gnaXdqpKi7DltK+rSL530Dh
         q+JgQM1WcVB80kZjGmsEKnNqMh/e7H00/sLBXkrHOodLGzT/wK89/8Yg4iysB+llEXZD
         vej1C5hpKNCxQoYsQSqKJZJyB1vyL6j0S6+01jpmw1lPjntlvTSlLUnz+A93XPbhh9Ad
         xGOzfKYrt+D7d/9uPtShkxvHRu4zNsmqGmCYKLE2kn7igmIQr7TrIVWBOQgcuwQiucM9
         bVHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=DMJX6exOwqjooLEn9qtJXN6JS2y5xnQ/2H7xPTrhJ28=;
        b=fkJDWO8k7x3qkk+OaN0CcL9pOtU2xDGlJcm7ZtdJOW8oJt0NG9N9I3LGMuESzRPTJ6
         LXj64HM4C50UkF3uzlGHR+LaUaU0NQUtF7RbdGIYF0rLImz26V2rslzpUPHsoPzvPd5j
         3hy/IkhChdQdbOXDFDw78BEiS6LLVkOf5GpZY9n9JMLbPUHiCAblzn6xhWMbp2nUMKhZ
         7KRjeASqeTjQmHZgzhVUG8DMd99wvd18MnyD0JteqtOBfZ8lL9z+Q5n45JcgHP1zz/YM
         YQ12E+CnrYqkCY56j6/A6Z663zTCDvwktqLTTfCuzkEn8L3zrhq24amq2VdKCQuaaope
         lFwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qmwBJoRI;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a17sor41403209iot.95.2019.07.29.09.58.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Jul 2019 09:58:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qmwBJoRI;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=DMJX6exOwqjooLEn9qtJXN6JS2y5xnQ/2H7xPTrhJ28=;
        b=qmwBJoRInh23civEWJdNICjdMLoR9BUo4NN/Jr86tkcVeVrkU8KIGkSHwi5irmcRPP
         //4n9GJj5Y4+FnXDmYBTTPKxGApkHqgo65J6IGPXJlcCq78kIwGwAwelULdRAmOMY0wj
         2jocJCfs/d9EId682irXl8YPuCk5umHMvx2eMUnRwkfBu/fBd6mQy3KuQt0NxpkLbO9W
         YOVEhLnvLQfQO0RnpPtADN/mblkeyeUlPNcWyZOlmbzLjSafTngOlIL+SV4V+pIbh3EV
         3SwJBZ+dMeUWV+Bvl+whJ+X+UegiEFARHumJQ/VGnj75FFt4AgYcDgpK34RtNtgdtb9r
         fSWQ==
X-Google-Smtp-Source: APXvYqztFG7YMJz0zsHEI3iKX0c4uGDWIt8CrgE8B+fv9wr+8aZKn7VtfZzuBhrEkz5ALTKWzWmFtnQpnC24Mw8lh00=
X-Received: by 2002:a5d:9dc7:: with SMTP id 7mr48452689ioo.237.1564419495894;
 Mon, 29 Jul 2019 09:58:15 -0700 (PDT)
MIME-Version: 1.0
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
 <20190724171050.7888.62199.stgit@localhost.localdomain> <20190724150224-mutt-send-email-mst@kernel.org>
 <6218af96d7d55935f2cf607d47680edc9b90816e.camel@linux.intel.com>
 <ee5387b1-89af-daf4-8492-8139216c6dcf@redhat.com> <20190724164023-mutt-send-email-mst@kernel.org>
In-Reply-To: <20190724164023-mutt-send-email-mst@kernel.org>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Mon, 29 Jul 2019 09:58:04 -0700
Message-ID: <CAKgT0Ud6jPpsvJWFAMSnQXAXeNZb116kR7D2Xb7U-7BOtctK_Q@mail.gmail.com>
Subject: Re: [PATCH v2 QEMU] virtio-balloon: Provide a interface for "bubble hinting"
To: "Michael S. Tsirkin" <mst@redhat.com>, wei.w.wang@intel.com
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>, 
	kvm list <kvm@vger.kernel.org>, David Hildenbrand <david@redhat.com>, 
	Dave Hansen <dave.hansen@intel.com>, LKML <linux-kernel@vger.kernel.org>, 
	linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Yang Zhang <yang.zhang.wz@gmail.com>, pagupta@redhat.com, 
	Rik van Riel <riel@surriel.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, lcapitulino@redhat.com, 
	Andrea Arcangeli <aarcange@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, dan.j.williams@intel.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 1:42 PM Michael S. Tsirkin <mst@redhat.com> wrote:
>
> On Wed, Jul 24, 2019 at 04:29:27PM -0400, Nitesh Narayan Lal wrote:
> >
> > On 7/24/19 4:18 PM, Alexander Duyck wrote:
> > > On Wed, 2019-07-24 at 15:02 -0400, Michael S. Tsirkin wrote:
> > >> On Wed, Jul 24, 2019 at 10:12:10AM -0700, Alexander Duyck wrote:
> > >>> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > >>>
> > >>> Add support for what I am referring to as "bubble hinting". Basically the
> > >>> idea is to function very similar to how the balloon works in that we
> > >>> basically end up madvising the page as not being used. However we don't
> > >>> really need to bother with any deflate type logic since the page will be
> > >>> faulted back into the guest when it is read or written to.
> > >>>
> > >>> This is meant to be a simplification of the existing balloon interface
> > >>> to use for providing hints to what memory needs to be freed. I am assuming
> > >>> this is safe to do as the deflate logic does not actually appear to do very
> > >>> much other than tracking what subpages have been released and which ones
> > >>> haven't.
> > >>>
> > >>> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > >>> ---
> > >>>  hw/virtio/virtio-balloon.c                      |   40 +++++++++++++++++++++++
> > >>>  include/hw/virtio/virtio-balloon.h              |    2 +
> > >>>  include/standard-headers/linux/virtio_balloon.h |    1 +
> > >>>  3 files changed, 42 insertions(+), 1 deletion(-)
> > >>>
> > >>> diff --git a/hw/virtio/virtio-balloon.c b/hw/virtio/virtio-balloon.c
> > >>> index 2112874055fb..70c0004c0f88 100644
> > >>> --- a/hw/virtio/virtio-balloon.c
> > >>> +++ b/hw/virtio/virtio-balloon.c
> > >>> @@ -328,6 +328,39 @@ static void balloon_stats_set_poll_interval(Object *obj, Visitor *v,
> > >>>      balloon_stats_change_timer(s, 0);
> > >>>  }
> > >>>
> > >>> +static void virtio_bubble_handle_output(VirtIODevice *vdev, VirtQueue *vq)
> > >>> +{
> > >>> +    VirtQueueElement *elem;
> > >>> +
> > >>> +    while ((elem = virtqueue_pop(vq, sizeof(VirtQueueElement)))) {
> > >>> +         unsigned int i;
> > >>> +
> > >>> +        for (i = 0; i < elem->in_num; i++) {
> > >>> +            void *addr = elem->in_sg[i].iov_base;
> > >>> +            size_t size = elem->in_sg[i].iov_len;
> > >>> +            ram_addr_t ram_offset;
> > >>> +            size_t rb_page_size;
> > >>> +            RAMBlock *rb;
> > >>> +
> > >>> +            if (qemu_balloon_is_inhibited())
> > >>> +                continue;
> > >>> +
> > >>> +            rb = qemu_ram_block_from_host(addr, false, &ram_offset);
> > >>> +            rb_page_size = qemu_ram_pagesize(rb);
> > >>> +
> > >>> +            /* For now we will simply ignore unaligned memory regions */
> > >>> +            if ((ram_offset | size) & (rb_page_size - 1))
> > >>> +                continue;
> > >>> +
> > >>> +            ram_block_discard_range(rb, ram_offset, size);
> > >> I suspect this needs to do like the migration type of
> > >> hinting and get disabled if page poisoning is in effect.
> > >> Right?
> > > Shouldn't something like that end up getting handled via
> > > qemu_balloon_is_inhibited, or did I miss something there? I assumed cases
> > > like that would end up setting qemu_balloon_is_inhibited to true, if that
> > > isn't the case then I could add some additional conditions. I would do it
> > > in about the same spot as the qemu_balloon_is_inhibited check.
> > I don't think qemu_balloon_is_inhibited() will take care of the page poisoning
> > situations.
> > If I am not wrong we may have to look to extend VIRTIO_BALLOON_F_PAGE_POISON
> > support as per Michael's suggestion.
>
>
> BTW upstream qemu seems to ignore VIRTIO_BALLOON_F_PAGE_POISON ATM.
> Which is probably a bug.
> Wei, could you take a look pls?

So I was looking at sorting out this for the unused page reporting
that I am working on and it occurred to me that I don't think we can
do the free page hinting if any sort of poison validation is present.
The problem is that free page hinting simply stops the page from being
migrated. As a result if there was stale data present it will just
leave it there instead of zeroing it or writing it to alternating 1s
and 0s.

Also it looks like the VIRTIO_BALLOON_F_PAGE_POISON feature is
assuming that 0 means that page poisoning is disabled, when in reality
it might just mean we are using the value zero to poison pages instead
of the 0xaa pattern. As such I think there are several cases where we
could incorrectly flag the pages with the hint and result in the
migrated guest reporting pages that contain non-poison values.

The zero assumption works for unused page reporting since we will be
zeroing out the page when it is faulted back into the guest, however
the same doesn't work for the free page hint since it is simply
skipping the migration of the recently dirtied page.

