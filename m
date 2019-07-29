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
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD36BC433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 20:21:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59C2220657
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 20:21:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GGTyfCF9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59C2220657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E519C8E0003; Mon, 29 Jul 2019 16:21:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DDB818E0002; Mon, 29 Jul 2019 16:21:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C7B828E0003; Mon, 29 Jul 2019 16:21:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id A66228E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 16:21:45 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id v3so68774318ios.4
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 13:21:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=n8DLn2LYXdUmw+h/HTxf60HAiTkzuB3IJKREzqD9s/Q=;
        b=QMIQrkDhLGy3Zj2ggKZWbIw9UeVp3dz0/UPYvReIexSaQWvRpDV4irdSNe6RW45tx4
         SZFdo9IMnrGdhvOoukDgFx8oBLTuYoy0FV6VoQrNBSh/wf8aCUC21nF58H1S7H4Qswd+
         NSXwbK7CaUc/Lb04nzDYLiVQeOuFTZXChohLJJFx0AweXJ7LT9b9or/zclNGpGM7H8UP
         7jkREed8UnjS7HYas0q8Mw/PZYMYbpu9hZ1cXnVCTIZsQZIS0+0uUFYDD1rqVt1uN6Q5
         aAO8+u+F/fO2OH2oW59203rZNCP34oxFuBWXHY3+mzPRkB2D8b4N/+JJjSOOQR4InIJd
         hLnA==
X-Gm-Message-State: APjAAAXZUgfC4faKTOQ5RrX85gvqS8iBEk9oaW7jUADMh9EROicti4Gn
	3jL3cF424DKG95NxiOnGT4LUk0WWI5HHPH3rXW5cJwz+HDlw4tcl93sYM0epfn66tAfvS1Vqc5e
	Yuler1cGP+MuuPDMwKqk0Vq/Ht5Ay3XR9DLJX9siYGQ1TifM4fnSQ8bc8bIMiF02bgQ==
X-Received: by 2002:a6b:3883:: with SMTP id f125mr31127906ioa.109.1564431705365;
        Mon, 29 Jul 2019 13:21:45 -0700 (PDT)
X-Received: by 2002:a6b:3883:: with SMTP id f125mr31127829ioa.109.1564431704301;
        Mon, 29 Jul 2019 13:21:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564431704; cv=none;
        d=google.com; s=arc-20160816;
        b=I8wdDPV65lWRoQWLwr6mmHHMwprU2N8CNK2YIsHsJApWfcWf+ua7SReSlgtepHvXXF
         s/gU/Vgbz/7RbD7voeQYr8ZMokjauOkb75kyYws5j2tABlrrmynKLdXTlGy4l8Nbh1mx
         Cqsm3vzXsHjqamM3WfUJ8zNrV37wWqeiR22BayFxhC/ndd/xfCst94+PxgI4CW6HZISB
         RjHNh/VvD0KYU6me3D/fYEKIuZkIZHqBP7ioMzCqHBAfFwfAStxBV+zUufn7Zc0FZ11q
         fTeVnLOeaxoiXo3hDozgPbG1VUDp7prao8mNE7pn9J3+u0FxVyNROlWVw6C3U+g10dL5
         gFDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=n8DLn2LYXdUmw+h/HTxf60HAiTkzuB3IJKREzqD9s/Q=;
        b=Zh3fK8dGgkwqPEwWepyyHuEj+gLjzSPLcTwvmLXXzzv5QD6yGRNk/VKWC2ya8x7WLB
         a+pqZpi93IJqltTHCZOG6+shgHHHKN6E1lrMIwQEAC3TcHK4+dN2rlmybBxmPbJWf/QV
         3EaNA1l+Olr3+O+t4PnkzXCuq1ZtJn7ebc/gka2OgfinjhKb5x8FnqUD4X6olu/W/vQr
         MAe65ghqHIjF6BNd3c74FhyTwnBTw3LYpUwJzb2e2LBlbKyjVzQMD8gsa7KuO2HnuUM2
         nqVAhS29Gg7RAaI7BXsNYqFC7ASW+CL3waTAp9mJRXEo7Oj9lI3vaRqU3esijWvKPnFJ
         w4Bw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GGTyfCF9;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q2sor42494861ioh.2.2019.07.29.13.21.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Jul 2019 13:21:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GGTyfCF9;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=n8DLn2LYXdUmw+h/HTxf60HAiTkzuB3IJKREzqD9s/Q=;
        b=GGTyfCF9D1FXaYL8c9rffDjQhmiB9H+lZHKurCJJWlWcM94Z5Fb77cuFxpP5VfSbp5
         usHdNLO5tsbiqmPLgb20qjML8n5I9r/osRbZoPxf4AwssfBgDC3tzMd2exoqknwVVUWV
         CmJStdkK1tqgayauq/V3rm+zlQ/rC43PJBT/56F2XZ7eY1+dp0PmLcUbdahyCFZmBhpV
         1AaiALzUgCpIVF0/w7C99Wi4iBzTN7FlxlrnzW3+/+tXK+bteJsEjADGUIQxUKVAwl/9
         VDP3mR4K+GS10yshXjHrEGe1F6DZXw7z+lOnpzC8Z+axHXt5z8qgcJgeS+mMtn2J4Mys
         dxBw==
X-Google-Smtp-Source: APXvYqwJIHzXroHCiBp0LszY7ioYxcPydX2pjUCjfRzyByJnT47TA51DeKVUdrS0xVLduo1P5eJyHyqlxUFd41i8TPI=
X-Received: by 2002:a6b:901:: with SMTP id t1mr29552549ioi.42.1564431703764;
 Mon, 29 Jul 2019 13:21:43 -0700 (PDT)
MIME-Version: 1.0
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
 <20190724171050.7888.62199.stgit@localhost.localdomain> <20190724150224-mutt-send-email-mst@kernel.org>
 <6218af96d7d55935f2cf607d47680edc9b90816e.camel@linux.intel.com>
 <ee5387b1-89af-daf4-8492-8139216c6dcf@redhat.com> <20190724164023-mutt-send-email-mst@kernel.org>
 <CAKgT0Ud6jPpsvJWFAMSnQXAXeNZb116kR7D2Xb7U-7BOtctK_Q@mail.gmail.com> <20190729151805-mutt-send-email-mst@kernel.org>
In-Reply-To: <20190729151805-mutt-send-email-mst@kernel.org>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Mon, 29 Jul 2019 13:21:32 -0700
Message-ID: <CAKgT0Ufq9RE_4B5bdsYyEf65WJkZsDHMD+MEJVJyev22+J3XAg@mail.gmail.com>
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

On Mon, Jul 29, 2019 at 12:25 PM Michael S. Tsirkin <mst@redhat.com> wrote:
>
> On Mon, Jul 29, 2019 at 09:58:04AM -0700, Alexander Duyck wrote:
> > On Wed, Jul 24, 2019 at 1:42 PM Michael S. Tsirkin <mst@redhat.com> wrote:
> > >
> > > On Wed, Jul 24, 2019 at 04:29:27PM -0400, Nitesh Narayan Lal wrote:
> > > >
> > > > On 7/24/19 4:18 PM, Alexander Duyck wrote:
> > > > > On Wed, 2019-07-24 at 15:02 -0400, Michael S. Tsirkin wrote:
> > > > >> On Wed, Jul 24, 2019 at 10:12:10AM -0700, Alexander Duyck wrote:
> > > > >>> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > > >>>
> > > > >>> Add support for what I am referring to as "bubble hinting". Basically the
> > > > >>> idea is to function very similar to how the balloon works in that we
> > > > >>> basically end up madvising the page as not being used. However we don't
> > > > >>> really need to bother with any deflate type logic since the page will be
> > > > >>> faulted back into the guest when it is read or written to.
> > > > >>>
> > > > >>> This is meant to be a simplification of the existing balloon interface
> > > > >>> to use for providing hints to what memory needs to be freed. I am assuming
> > > > >>> this is safe to do as the deflate logic does not actually appear to do very
> > > > >>> much other than tracking what subpages have been released and which ones
> > > > >>> haven't.
> > > > >>>
> > > > >>> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > > >>> ---
> > > > >>>  hw/virtio/virtio-balloon.c                      |   40 +++++++++++++++++++++++
> > > > >>>  include/hw/virtio/virtio-balloon.h              |    2 +
> > > > >>>  include/standard-headers/linux/virtio_balloon.h |    1 +
> > > > >>>  3 files changed, 42 insertions(+), 1 deletion(-)
> > > > >>>
> > > > >>> diff --git a/hw/virtio/virtio-balloon.c b/hw/virtio/virtio-balloon.c
> > > > >>> index 2112874055fb..70c0004c0f88 100644
> > > > >>> --- a/hw/virtio/virtio-balloon.c
> > > > >>> +++ b/hw/virtio/virtio-balloon.c
> > > > >>> @@ -328,6 +328,39 @@ static void balloon_stats_set_poll_interval(Object *obj, Visitor *v,
> > > > >>>      balloon_stats_change_timer(s, 0);
> > > > >>>  }
> > > > >>>
> > > > >>> +static void virtio_bubble_handle_output(VirtIODevice *vdev, VirtQueue *vq)
> > > > >>> +{
> > > > >>> +    VirtQueueElement *elem;
> > > > >>> +
> > > > >>> +    while ((elem = virtqueue_pop(vq, sizeof(VirtQueueElement)))) {
> > > > >>> +         unsigned int i;
> > > > >>> +
> > > > >>> +        for (i = 0; i < elem->in_num; i++) {
> > > > >>> +            void *addr = elem->in_sg[i].iov_base;
> > > > >>> +            size_t size = elem->in_sg[i].iov_len;
> > > > >>> +            ram_addr_t ram_offset;
> > > > >>> +            size_t rb_page_size;
> > > > >>> +            RAMBlock *rb;
> > > > >>> +
> > > > >>> +            if (qemu_balloon_is_inhibited())
> > > > >>> +                continue;
> > > > >>> +
> > > > >>> +            rb = qemu_ram_block_from_host(addr, false, &ram_offset);
> > > > >>> +            rb_page_size = qemu_ram_pagesize(rb);
> > > > >>> +
> > > > >>> +            /* For now we will simply ignore unaligned memory regions */
> > > > >>> +            if ((ram_offset | size) & (rb_page_size - 1))
> > > > >>> +                continue;
> > > > >>> +
> > > > >>> +            ram_block_discard_range(rb, ram_offset, size);
> > > > >> I suspect this needs to do like the migration type of
> > > > >> hinting and get disabled if page poisoning is in effect.
> > > > >> Right?
> > > > > Shouldn't something like that end up getting handled via
> > > > > qemu_balloon_is_inhibited, or did I miss something there? I assumed cases
> > > > > like that would end up setting qemu_balloon_is_inhibited to true, if that
> > > > > isn't the case then I could add some additional conditions. I would do it
> > > > > in about the same spot as the qemu_balloon_is_inhibited check.
> > > > I don't think qemu_balloon_is_inhibited() will take care of the page poisoning
> > > > situations.
> > > > If I am not wrong we may have to look to extend VIRTIO_BALLOON_F_PAGE_POISON
> > > > support as per Michael's suggestion.
> > >
> > >
> > > BTW upstream qemu seems to ignore VIRTIO_BALLOON_F_PAGE_POISON ATM.
> > > Which is probably a bug.
> > > Wei, could you take a look pls?
> >
> > So I was looking at sorting out this for the unused page reporting
> > that I am working on and it occurred to me that I don't think we can
> > do the free page hinting if any sort of poison validation is present.
> > The problem is that free page hinting simply stops the page from being
> > migrated. As a result if there was stale data present it will just
> > leave it there instead of zeroing it or writing it to alternating 1s
> > and 0s.
>
> stale data where? on source or on destination?
> do you mean the case where memory was corrupted?
>

Actually I am getting my implementation and this one partially mixed
up again. I was thinking that the page just gets put back. However it
doesn't. Instead free_pages is called. As such it is going to dirty
the page by poisoning it as soon as the hinting is complete.

In some ways it is worse because I think page poisoning combined with
free page hinting will make the VM nearly unusable because it will be
burning cycles allocating all memory, and then poisoning all those
pages on free. So it will be populating the dirty bitmap with all free
memory each time it goes through and attempts to determine what memory
is free.

> >
> > Also it looks like the VIRTIO_BALLOON_F_PAGE_POISON feature is
> > assuming that 0 means that page poisoning is disabled,
> > when in reality
> > it might just mean we are using the value zero to poison pages instead
> > of the 0xaa pattern. As such I think there are several cases where we
> > could incorrectly flag the pages with the hint and result in the
> > migrated guest reporting pages that contain non-poison values.
> >
>
>
> Well guest has this code:
> static int virtballoon_validate(struct virtio_device *vdev)
> {
>         if (!page_poisoning_enabled())
>                 __virtio_clear_bit(vdev, VIRTIO_BALLOON_F_PAGE_POISON);
>
>         __virtio_clear_bit(vdev, VIRTIO_F_IOMMU_PLATFORM);
>         return 0;
> }
>
> So it seems that host can figure out what is going on easily enough.
> What did I miss?

Okay. So it is clearing that feature bit. I didn't see that part.
However that leads to the question of where we should be setting that
feature bit in the QEMU side of things. I was looking at setting that
bit in virtio_balloon_get_features(). Would that be the appropriate
place to set that so that the feature flag is reset when we are
changing OSes or rebooting the guest?

> > The zero assumption works for unused page reporting since we will be
> > zeroing out the page when it is faulted back into the guest, however
> > the same doesn't work for the free page hint since it is simply
> > skipping the migration of the recently dirtied page.
>
> Right but the dirtied page is normally full of 0 since that is the
> poison value, if we just leave it there we still get 0s, right?

So for the unused page reporting which I am working on we can still
hint the page away since it will be 0s, and us returning the pages
doesn't alter the page data. However for the free page hinting I don't
think we can.

With page poisoning and free page hinting I am thinking we should just
disable the free page hinting as I don't see how there can be any
advantage to it if page poisoning is enbled. Basically the thing that
makes the hinting "safe" will sabotage it since for every page we
don't migrate we will also be marking as dirty for the next iteration
through migration. As such we are just pushing the migration of any
free pages until the VM has stopped since the VM will just keep
dirtying the free pages until it stops hinting.

