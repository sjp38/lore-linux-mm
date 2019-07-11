Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE405C742A1
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 22:36:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6666C20872
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 22:36:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="giKONUdZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6666C20872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF5E08E00FD; Thu, 11 Jul 2019 18:36:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA7188E00DB; Thu, 11 Jul 2019 18:36:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B6E318E00FD; Thu, 11 Jul 2019 18:36:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 94D4F8E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 18:36:21 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id s9so8353807iob.11
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 15:36:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=XGbYxpgADiFUW/V0IvgQ/ffdWslTKgPikSuk1woxxJY=;
        b=YziDc3b90y5TcjGwsgEGXLMllEoZ0n3p0MpsSqFhBwjP10BfjxdCWIKoK+WVXW4hxG
         U8LLGWaJKsgrSyzZVob7mX5gEB2cAhls1zJ96xJOiw3hKB/J7mXL9PifZgTbE7wFYRVI
         zxy3RJ/hboXuXF8956Sjopq/4D5Ch8RZ75RPahJMPmMdjGeO4oSkfCw8fFjlZIbZwmwc
         an95Pz8W2kT6cdRWGvKosYX7g/Amb4IcCvzxbO2CSqLJ6TGFuJk3zUm4wTFsZ7qlmK+A
         LkN9uZ1DphunqkncC10FAmdL0/ztYNXHVn+L17EsU03oyWM2hMv0rxW81CiNQSDbXPB8
         sdBw==
X-Gm-Message-State: APjAAAUQfa2EUm/VmnPx0rF+0Xc3/yVZmoww9BQBw3uVzC+K2KgC9z4W
	nZ78fXBf1nHlpuXKau2Yip5TeOV9hfewPq2z8TF680t8qZQTD7A15IsdbhPMUhNIAmMix79E0JT
	/p9FpH+ts7lGAq/YGccZi5JftnSjkQuRRpAb5Bm7TZSwN5Ag/mR6/hdh79JYhld83Bw==
X-Received: by 2002:a6b:7606:: with SMTP id g6mr7061652iom.288.1562884581320;
        Thu, 11 Jul 2019 15:36:21 -0700 (PDT)
X-Received: by 2002:a6b:7606:: with SMTP id g6mr7061584iom.288.1562884580315;
        Thu, 11 Jul 2019 15:36:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562884580; cv=none;
        d=google.com; s=arc-20160816;
        b=lfB17R/OJaHU/AWCrsLT+K97bISQXbRGj3CMyOQk/xjw6RdjNImiR/0u/6LoV2rGVP
         OEVfesLvqINy6/ozu/HD3F2cS/2Qy4WE3GyPXnFBoz1xIHLV+34qNSubpBJzcRMnQIXg
         IYC3YNCxQb1FBbFZy5ePC4RaxDgrK5Zu/oXkBwIEFOnM3s8Zoflvizk3/ViilO0nyW6V
         m/ZuXCfU5SzfPuThCPx+9AXqT1OBlli6T/anHvZZXgmUMgQO5bs3kkRCxfifI2iuys22
         dV3JXJEVdwKIk4HZiI+X3hXc9e/GXjhuDOYy2EXHMrb9pPTmWJOzDx4b2/3lN0eUUocw
         vgJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=XGbYxpgADiFUW/V0IvgQ/ffdWslTKgPikSuk1woxxJY=;
        b=iENQCP0FasminkdHFYaY2jGm4SmBTHicVYB5zCRZUOkAAW9xQTpmpo/ACJFpAcDwBS
         MTZ9w3L88YQjnZDMjI0xje7wXWuMXaAmvZHHwXgwlXr5E0Jos30uDqvy17gkpIuE06LP
         vupjDWw4BEwDk+bpbd+mTgohZxB8CiSaPtCsfaNIk6GX3j0zWRM0LVvY+FKMaEP0mhAp
         SyJhDCiUOnWLAHLghPVZw4pdp+01sP3ryhgk6hJbVhvJt8KQK5WLwdvRXmgMjDUsWz6u
         bSsnPvzExadnxxSfUawJgDP0CGNmA6GHXKdc1IWM4p2kg8MWLx2AckxjQRBKtfPZR7W5
         UTvA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=giKONUdZ;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q9sor5624517iog.65.2019.07.11.15.36.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Jul 2019 15:36:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=giKONUdZ;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=XGbYxpgADiFUW/V0IvgQ/ffdWslTKgPikSuk1woxxJY=;
        b=giKONUdZk+h//k+ASGHs65mEmPS7nCToBHnCpwURuqzREmqTaXCnM93NHmce9j0Nmj
         GB638zx+YKQE2POzEefS2gTqX3IkzXwYsV2rGbaML/Nl7XVh4wLFF7n2ce4kd3mYnapu
         Rs34zLwvuP9qNrMrkBBnWnLTeu0KOqvjE2cT4cateqqw5GlysBvykZRZn7rnb7jJtY7g
         nTu0TThFUF/CmBB7ajDnfsJ1uAqvxc+d1wV6UHP3vGMU4GLeZx9hL7UmtmrqZX49bLV7
         w7dq0B5NVvepIfJAg2dFPDf1CaKcfzbBL7wqmVbh5gtIyh2j69ZDgz9ZknE0kj0ekEhh
         dGKw==
X-Google-Smtp-Source: APXvYqwJrt4afd3bDAw5Uc8yK5/zGmoGIAKhlF0WEgpjra0ERTYFrLXiOfFyk1FMetvyKKxAKiC4/bDBQmHRH1NaD9o=
X-Received: by 2002:a6b:6409:: with SMTP id t9mr55131iog.270.1562884579704;
 Thu, 11 Jul 2019 15:36:19 -0700 (PDT)
MIME-Version: 1.0
References: <20190710195158.19640-1-nitesh@redhat.com> <20190710195303.19690-1-nitesh@redhat.com>
 <20190711141036-mutt-send-email-mst@kernel.org> <00f4d486-e4e8-c796-5b4f-c0e8b6b74dc2@redhat.com>
In-Reply-To: <00f4d486-e4e8-c796-5b4f-c0e8b6b74dc2@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Thu, 11 Jul 2019 15:36:08 -0700
Message-ID: <CAKgT0UfZPCHsUu22cEKsCYE5jcWhCM-rKRU2TKA5VjvCZjsbdQ@mail.gmail.com>
Subject: Re: [QEMU Patch] virtio-baloon: Support for page hinting
To: Nitesh Narayan Lal <nitesh@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, kvm list <kvm@vger.kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com, pagupta@redhat.com, 
	wei.w.wang@intel.com, Yang Zhang <yang.zhang.wz@gmail.com>, 
	Rik van Riel <riel@surriel.com>, David Hildenbrand <david@redhat.com>, dodgen@google.com, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com, 
	Andrea Arcangeli <aarcange@redhat.com>, john.starks@microsoft.com, 
	Dave Hansen <dave.hansen@intel.com>, Michal Hocko <mhocko@suse.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 11, 2019 at 12:06 PM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
>
>
> On 7/11/19 2:55 PM, Michael S. Tsirkin wrote:
> > On Wed, Jul 10, 2019 at 03:53:03PM -0400, Nitesh Narayan Lal wrote:
> >> Enables QEMU to perform madvise free on the memory range reported
> >> by the vm.
> >>
> >> Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>
> > Missing second "l" in the subject :)
> >
> >> ---
> >>  hw/virtio/trace-events                        |  1 +
> >>  hw/virtio/virtio-balloon.c                    | 59 +++++++++++++++++++
> >>  include/hw/virtio/virtio-balloon.h            |  2 +-
> >>  include/qemu/osdep.h                          |  7 +++
> >>  .../standard-headers/linux/virtio_balloon.h   |  1 +
> >>  5 files changed, 69 insertions(+), 1 deletion(-)
> >>
> >> diff --git a/hw/virtio/trace-events b/hw/virtio/trace-events
> >> index e28ba48da6..f703a22d36 100644
> >> --- a/hw/virtio/trace-events
> >> +++ b/hw/virtio/trace-events
> >> @@ -46,6 +46,7 @@ virtio_balloon_handle_output(const char *name, uint64_t gpa) "section name: %s g
> >>  virtio_balloon_get_config(uint32_t num_pages, uint32_t actual) "num_pages: %d actual: %d"
> >>  virtio_balloon_set_config(uint32_t actual, uint32_t oldactual) "actual: %d oldactual: %d"
> >>  virtio_balloon_to_target(uint64_t target, uint32_t num_pages) "balloon target: 0x%"PRIx64" num_pages: %d"
> >> +virtio_balloon_hinting_request(unsigned long pfn, unsigned int num_pages) "Guest page hinting request PFN:%lu size: %d"
> >>
> >>  # virtio-mmio.c
> >>  virtio_mmio_read(uint64_t offset) "virtio_mmio_read offset 0x%" PRIx64
> >> diff --git a/hw/virtio/virtio-balloon.c b/hw/virtio/virtio-balloon.c
> >> index 2112874055..5d186707b5 100644
> >> --- a/hw/virtio/virtio-balloon.c
> >> +++ b/hw/virtio/virtio-balloon.c
> >> @@ -34,6 +34,9 @@
> >>
> >>  #define BALLOON_PAGE_SIZE  (1 << VIRTIO_BALLOON_PFN_SHIFT)
> >>
> >> +#define VIRTIO_BALLOON_PAGE_HINTING_MAX_PAGES       16
> >> +void free_mem_range(uint64_t addr, uint64_t len);
> >> +
> >>  struct PartiallyBalloonedPage {
> >>      RAMBlock *rb;
> >>      ram_addr_t base;
> >> @@ -328,6 +331,58 @@ static void balloon_stats_set_poll_interval(Object *obj, Visitor *v,
> >>      balloon_stats_change_timer(s, 0);
> >>  }
> >>
> >> +void free_mem_range(uint64_t addr, uint64_t len)
> >> +{
> >> +    int ret = 0;
> >> +    void *hvaddr_to_free;
> >> +    MemoryRegionSection mrs = memory_region_find(get_system_memory(),
> >> +                                                 addr, 1);
> >> +    if (!mrs.mr) {
> >> +    warn_report("%s:No memory is mapped at address 0x%lu", __func__, addr);
> >> +        return;
> >> +    }
> >> +
> >> +    if (!memory_region_is_ram(mrs.mr) && !memory_region_is_romd(mrs.mr)) {
> >> +    warn_report("%s:Memory at address 0x%s is not RAM:0x%lu", __func__,
> >> +                HWADDR_PRIx, addr);
> >> +        memory_region_unref(mrs.mr);
> >> +        return;
> >> +    }
> >> +
> >> +    hvaddr_to_free = qemu_map_ram_ptr(mrs.mr->ram_block, mrs.offset_within_region);
> >> +    trace_virtio_balloon_hinting_request(addr, len);
> >> +    ret = qemu_madvise(hvaddr_to_free,len, QEMU_MADV_FREE);
> >> +    if (ret == -1) {
> >> +    warn_report("%s: Madvise failed with error:%d", __func__, ret);
> >> +    }
> >> +}
> >> +
> >> +static void virtio_balloon_handle_page_hinting(VirtIODevice *vdev,
> >> +                                           VirtQueue *vq)
> >> +{
> >> +    VirtQueueElement *elem;
> >> +    size_t offset = 0;
> >> +    uint64_t gpa, len;
> >> +    elem = virtqueue_pop(vq, sizeof(VirtQueueElement));
> >> +    if (!elem) {
> >> +        return;
> >> +    }
> >> +    /* For pending hints which are < max_pages(16), 'gpa != 0' ensures that we
> >> +     * only read the buffer which holds a valid PFN value.
> >> +     * TODO: Find a better way to do this.
> > Indeed. In fact, what is wrong with passing the gpa as
> > part of the element itself?
> There are two values which I need to read 'gpa' and 'len'. I will have
> to check how to pass them both as part of the element.
> But, I will look into it.

One advantage of doing it as a scatter-gather list being passed via
the element is that you only get one completion. If you are going to
do an element per page then you will need to somehow identify if the
entire ring has been processed or not before you free your local page
list.

> >> +     */
> >> +    while (iov_to_buf(elem->out_sg, elem->out_num, offset, &gpa, 8) == 8 && gpa != 0) {
> >> +    offset += 8;
> >> +    offset += iov_to_buf(elem->out_sg, elem->out_num, offset, &len, 8);
> >> +    if (!qemu_balloon_is_inhibited()) {
> >> +        free_mem_range(gpa, len);
> >> +    }
> >> +    }
> >> +    virtqueue_push(vq, elem, offset);
> >> +    virtio_notify(vdev, vq);
> >> +    g_free(elem);
> >> +}
> >> +
> >>  static void virtio_balloon_handle_output(VirtIODevice *vdev, VirtQueue *vq)
> >>  {
> >>      VirtIOBalloon *s = VIRTIO_BALLOON(vdev);
> >> @@ -694,6 +749,7 @@ static uint64_t virtio_balloon_get_features(VirtIODevice *vdev, uint64_t f,
> >>      VirtIOBalloon *dev = VIRTIO_BALLOON(vdev);
> >>      f |= dev->host_features;
> >>      virtio_add_feature(&f, VIRTIO_BALLOON_F_STATS_VQ);
> >> +    virtio_add_feature(&f, VIRTIO_BALLOON_F_HINTING);
> >>
> >>      return f;
> >>  }
> >> @@ -780,6 +836,7 @@ static void virtio_balloon_device_realize(DeviceState *dev, Error **errp)
> >>      s->ivq = virtio_add_queue(vdev, 128, virtio_balloon_handle_output);
> >>      s->dvq = virtio_add_queue(vdev, 128, virtio_balloon_handle_output);
> >>      s->svq = virtio_add_queue(vdev, 128, virtio_balloon_receive_stats);
> >> +    s->hvq = virtio_add_queue(vdev, 128, virtio_balloon_handle_page_hinting);
> >>
> >>      if (virtio_has_feature(s->host_features,
> >>                             VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
> >> @@ -875,6 +932,8 @@ static void virtio_balloon_instance_init(Object *obj)
> >>
> >>      object_property_add(obj, "guest-stats", "guest statistics",
> >>                          balloon_stats_get_all, NULL, NULL, s, NULL);
> >> +    object_property_add(obj, "guest-page-hinting", "guest page hinting",
> >> +                        NULL, NULL, NULL, s, NULL);
> >>
> >>      object_property_add(obj, "guest-stats-polling-interval", "int",
> >>                          balloon_stats_get_poll_interval,
> >> diff --git a/include/hw/virtio/virtio-balloon.h b/include/hw/virtio/virtio-balloon.h
> >> index 1afafb12f6..a58b24fdf2 100644
> >> --- a/include/hw/virtio/virtio-balloon.h
> >> +++ b/include/hw/virtio/virtio-balloon.h
> >> @@ -44,7 +44,7 @@ enum virtio_balloon_free_page_report_status {
> >>
> >>  typedef struct VirtIOBalloon {
> >>      VirtIODevice parent_obj;
> >> -    VirtQueue *ivq, *dvq, *svq, *free_page_vq;
> >> +    VirtQueue *ivq, *dvq, *svq, *free_page_vq, *hvq;
> >>      uint32_t free_page_report_status;
> >>      uint32_t num_pages;
> >>      uint32_t actual;
> >> diff --git a/include/qemu/osdep.h b/include/qemu/osdep.h
> >> index af2b91f0b8..bb9207e7f4 100644
> >> --- a/include/qemu/osdep.h
> >> +++ b/include/qemu/osdep.h
> >> @@ -360,6 +360,11 @@ void qemu_anon_ram_free(void *ptr, size_t size);
> >>  #else
> >>  #define QEMU_MADV_REMOVE QEMU_MADV_INVALID
> >>  #endif
> >> +#ifdef MADV_FREE
> >> +#define QEMU_MADV_FREE MADV_FREE
> >> +#else
> >> +#define QEMU_MADV_FREE QEMU_MADV_INVALID
> >> +#endif
> >>
> >>  #elif defined(CONFIG_POSIX_MADVISE)
> >>
> >> @@ -373,6 +378,7 @@ void qemu_anon_ram_free(void *ptr, size_t size);
> >>  #define QEMU_MADV_HUGEPAGE  QEMU_MADV_INVALID
> >>  #define QEMU_MADV_NOHUGEPAGE  QEMU_MADV_INVALID
> >>  #define QEMU_MADV_REMOVE QEMU_MADV_INVALID
> >> +#define QEMU_MADV_FREE QEMU_MADV_INVALID
> >>
> >>  #else /* no-op */
> >>
> >> @@ -386,6 +392,7 @@ void qemu_anon_ram_free(void *ptr, size_t size);
> >>  #define QEMU_MADV_HUGEPAGE  QEMU_MADV_INVALID
> >>  #define QEMU_MADV_NOHUGEPAGE  QEMU_MADV_INVALID
> >>  #define QEMU_MADV_REMOVE QEMU_MADV_INVALID
> >> +#define QEMU_MADV_FREE QEMU_MADV_INVALID
> >>
> >>  #endif
> >>
> >> diff --git a/include/standard-headers/linux/virtio_balloon.h b/include/standard-headers/linux/virtio_balloon.h
> >> index 9375ca2a70..f9e3e82562 100644
> >> --- a/include/standard-headers/linux/virtio_balloon.h
> >> +++ b/include/standard-headers/linux/virtio_balloon.h
> >> @@ -36,6 +36,7 @@
> >>  #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM     2 /* Deflate balloon on OOM */
> >>  #define VIRTIO_BALLOON_F_FREE_PAGE_HINT     3 /* VQ to report free pages */
> >>  #define VIRTIO_BALLOON_F_PAGE_POISON        4 /* Guest is using page poisoning */
> >> +#define VIRTIO_BALLOON_F_HINTING    5 /* Page hinting virtqueue */
> >>
> >>  /* Size of a PFN in the balloon interface. */
> >>  #define VIRTIO_BALLOON_PFN_SHIFT 12
> >> --
> >> 2.21.0
> --
> Thanks
> Nitesh
>

