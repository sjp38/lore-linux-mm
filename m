Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFE85C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 15:19:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 64C2820665
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 15:19:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Dj0y3Gbz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 64C2820665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 015E56B0007; Mon, 12 Aug 2019 11:19:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F08E66B000E; Mon, 12 Aug 2019 11:19:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E1EAE6B0010; Mon, 12 Aug 2019 11:19:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0040.hostedemail.com [216.40.44.40])
	by kanga.kvack.org (Postfix) with ESMTP id BD1C06B0007
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 11:19:04 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 64DCF180AD7C1
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 15:19:04 +0000 (UTC)
X-FDA: 75814133808.28.loss42_14edcc8b8e532
X-HE-Tag: loss42_14edcc8b8e532
X-Filterd-Recvd-Size: 7711
Received: from mail-ot1-f68.google.com (mail-ot1-f68.google.com [209.85.210.68])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 15:19:03 +0000 (UTC)
Received: by mail-ot1-f68.google.com with SMTP id g17so9192567otl.2
        for <linux-mm@kvack.org>; Mon, 12 Aug 2019 08:19:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=g61UWX1fk8nOjgoG5gZ42LwxR/PoBHmYKeb7M1oSMlU=;
        b=Dj0y3Gbz+HzorEQLnZ8bag7EZHZpsiF+HrWRA2zvhJXLrllUnKYhmr8PlbAC2W6WqA
         boPOsG8b1w8cwUSyNQQTzh1VI/79rscI1R7EpIm0MraDHmGtLdif4TBa20FYcGqu9D7z
         ry1UpJluYg6Z84ewqK3CZ4glmBdwxmgBqbtPp9xc+jMv4QfueJzeI8Zr9clvPRZVIkVD
         V4nn6qDJmxkkGDu6DbwSWET0zF1i2ljW35L6A1snPP9BhnUI105N9lCYMK67XhpKeuIz
         8E/2eDsyERtkhIMu5MYjjoia5+KIBPP11YWegrDM2fsenbtb1d5sCJkGZDg2Vi5FYC14
         6O1g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=g61UWX1fk8nOjgoG5gZ42LwxR/PoBHmYKeb7M1oSMlU=;
        b=QVvynvd+Eg5oWN7uWkDKEqgX8Vg2T6uXHHmNtEAVZLB2VmML1xBBIWJSOlLQwVOx+g
         rvD8CiyNeJ/JVloKTod7n3Qmpq71cgbW66DVddp7zACY0kNWEn5rqrIZR2dghtbqUoA/
         PdbyV7UZ+M19x40l4upUv4EFYEcJqivSGHV3APC99E9tdP+WFn6OI+sCBrn2mAMCVJ5g
         ARjjUqZXq4vaFKK+OcnIIR7YRYr0vcUWS3L6iHBsYQjG7IHyK81gcUouKALmZFKU89mR
         c25fY2CsGGoYEIWI02UW8Z+mN62fm8ypQJ9uJT0b8BbJ9gREyRB4dBZki6cU4tJRs0CR
         AD5g==
X-Gm-Message-State: APjAAAXVYRklKRFc2NCbtnb3c/0F5FkhVZMGDwxVMmyVCG+3oPb+97Z8
	6Dn+81DLriRYYjow9gQLvEi0JBxwnWJy7CnHOFFlhr+d
X-Google-Smtp-Source: APXvYqy67a3lTSjf7Vx2s1uiVtCzZ0/KxkgABAzojCEpEbXpH78z314N2AUzoDA5i2GXWUhxi/1pMLbS2hj7YG4ncrk=
X-Received: by 2002:a5e:8c11:: with SMTP id n17mr33482356ioj.64.1565623142785;
 Mon, 12 Aug 2019 08:19:02 -0700 (PDT)
MIME-Version: 1.0
References: <20190812131235.27244-1-nitesh@redhat.com> <20190812131357.27312-1-nitesh@redhat.com>
 <20190812131357.27312-2-nitesh@redhat.com>
In-Reply-To: <20190812131357.27312-2-nitesh@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Mon, 12 Aug 2019 08:18:51 -0700
Message-ID: <CAKgT0Uc8kGwX8VwU2b51qVuh2z5eZQ6XhSnYMryTVa_pKHCvew@mail.gmail.com>
Subject: Re: [QEMU Patch 2/2] virtio-balloon: support for handling page reporting
To: Nitesh Narayan Lal <nitesh@redhat.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	linux-mm <linux-mm@kvack.org>, virtio-dev@lists.oasis-open.org, 
	Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com, pagupta@redhat.com, 
	wei.w.wang@intel.com, Yang Zhang <yang.zhang.wz@gmail.com>, 
	Rik van Riel <riel@surriel.com>, David Hildenbrand <david@redhat.com>, 
	"Michael S. Tsirkin" <mst@redhat.com>, dodgen@google.com, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com, 
	Andrea Arcangeli <aarcange@redhat.com>, john.starks@microsoft.com, 
	Dave Hansen <dave.hansen@intel.com>, Michal Hocko <mhocko@suse.com>, cohuck@redhat.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 12, 2019 at 6:14 AM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
>
> Page reporting is a feature which enables the virtual machine to report
> chunk of free pages to the hypervisor.
> This patch enables QEMU to process these reports from the VM and discard the
> unused memory range.
>
> Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>
> ---
>  hw/virtio/virtio-balloon.c         | 41 ++++++++++++++++++++++++++++++
>  include/hw/virtio/virtio-balloon.h |  2 +-
>  2 files changed, 42 insertions(+), 1 deletion(-)
>
> diff --git a/hw/virtio/virtio-balloon.c b/hw/virtio/virtio-balloon.c
> index 25de154307..1132e47ee0 100644
> --- a/hw/virtio/virtio-balloon.c
> +++ b/hw/virtio/virtio-balloon.c
> @@ -320,6 +320,39 @@ static void balloon_stats_set_poll_interval(Object *obj, Visitor *v,
>      balloon_stats_change_timer(s, 0);
>  }
>
> +static void virtio_balloon_handle_reporting(VirtIODevice *vdev, VirtQueue *vq)
> +{
> +    VirtQueueElement *elem;
> +
> +    while ((elem = virtqueue_pop(vq, sizeof(VirtQueueElement)))) {
> +        unsigned int i;
> +
> +        for (i = 0; i < elem->in_num; i++) {
> +            void *gaddr = elem->in_sg[i].iov_base;
> +            size_t size = elem->in_sg[i].iov_len;
> +            ram_addr_t ram_offset;
> +            size_t rb_page_size;
> +           RAMBlock *rb;
> +
> +            if (qemu_balloon_is_inhibited())
> +                continue;
> +
> +            rb = qemu_ram_block_from_host(gaddr, false, &ram_offset);
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

No offense, but I am a bit annoyed. If you are going to copy my code
you should at least keep up with the fixes. You are missing all of the
stuff to handle the poison value. If you are going to just duplicate
my setup you might as well have just pulled the QEMU patches from the
last submission I did. Then this would have at least has the fix for
the page poisoning. Also it wouldn't hurt to mention that you are
basing it off of the patch set I submitted since it hasn't been
accepted yet.

>  static void virtio_balloon_handle_output(VirtIODevice *vdev, VirtQueue *vq)
>  {
>      VirtIOBalloon *s = VIRTIO_BALLOON(vdev);
> @@ -792,6 +825,12 @@ static void virtio_balloon_device_realize(DeviceState *dev, Error **errp)
>      s->dvq = virtio_add_queue(vdev, 128, virtio_balloon_handle_output);
>      s->svq = virtio_add_queue(vdev, 128, virtio_balloon_receive_stats);
>
> +    if (virtio_has_feature(s->host_features,
> +                           VIRTIO_BALLOON_F_REPORTING)) {
> +        s->reporting_vq = virtio_add_queue(vdev, 16,
> +                                          virtio_balloon_handle_reporting);
> +    }
> +
>      if (virtio_has_feature(s->host_features,
>                             VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
>          s->free_page_vq = virtio_add_queue(vdev, VIRTQUEUE_MAX_SIZE,
> @@ -912,6 +951,8 @@ static Property virtio_balloon_properties[] = {
>       * is disabled, resulting in QEMU 3.1 migration incompatibility.  This
>       * property retains this quirk for QEMU 4.1 machine types.
>       */
> +    DEFINE_PROP_BIT("free-page-reporting", VirtIOBalloon, host_features,
> +                    VIRTIO_BALLOON_F_REPORTING, true),
>      DEFINE_PROP_BOOL("qemu-4-0-config-size", VirtIOBalloon,
>                       qemu_4_0_config_size, false),
>      DEFINE_PROP_LINK("iothread", VirtIOBalloon, iothread, TYPE_IOTHREAD,
> diff --git a/include/hw/virtio/virtio-balloon.h b/include/hw/virtio/virtio-balloon.h
> index d1c968d237..15a05e6435 100644
> --- a/include/hw/virtio/virtio-balloon.h
> +++ b/include/hw/virtio/virtio-balloon.h
> @@ -42,7 +42,7 @@ enum virtio_balloon_free_page_report_status {
>
>  typedef struct VirtIOBalloon {
>      VirtIODevice parent_obj;
> -    VirtQueue *ivq, *dvq, *svq, *free_page_vq;
> +    VirtQueue *ivq, *dvq, *svq, *free_page_vq, *reporting_vq;
>      uint32_t free_page_report_status;
>      uint32_t num_pages;
>      uint32_t actual;
> --
> 2.21.0
>q

