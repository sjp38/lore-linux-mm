Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0426CC74A51
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 08:49:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B02F121537
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 08:49:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B02F121537
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4663E8E00AC; Thu, 11 Jul 2019 04:49:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 416B28E0032; Thu, 11 Jul 2019 04:49:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2B81B8E00AC; Thu, 11 Jul 2019 04:49:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f72.google.com (mail-ua1-f72.google.com [209.85.222.72])
	by kanga.kvack.org (Postfix) with ESMTP id EC9A58E0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 04:49:32 -0400 (EDT)
Received: by mail-ua1-f72.google.com with SMTP id s1so935676uao.2
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 01:49:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=uzboYqu/EnutsUfDvdzc2QGLrZgrkC1MIL9crIUqBoM=;
        b=FrZtIMNmRjV1fx/812Lwy9hCFlh3iXdvg14HBCE+yDbNuRcMSmLqz15cWsKPmyWkpd
         Z1U2e0mIjhr4PKOWgIqjE6lzoeSAZJzL7x7SyJfUUKfLGp4bKG0O+bssr18Na6QrthoD
         nmI8vAOSi/OimToIoFPum59i0rgzxv/0S8GoEK/bGFmD9DIBLudRxzVkcXxPZvDWkuUv
         J1L3kZ9WtT4fGXZU31i2LZymr53LpIRO1Q4WmKmYUpN4TG7DxfrSSx23Kg87i0ghVKQr
         KyrjsQZT3mfu03EocDEkrZl7791lvvadR2mcV6jK2G+PC0+1om0mC9DFGf0xcOJ0iq6M
         dsew==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of cohuck@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=cohuck@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX0j9K3o2+x41tzlyt6DopR4ARvjFYoiEBhBB4J6jHtlFnc8yt3
	66ygcyFT8CuLWJcgH3H5UlSSGpFJ3QeM5v6AURsi5dYB1eUGxTW2FTISy4+T9U7ZxaJ0ZbudqwY
	An+Rzm64DE290OI0FXpw0r3U4qdAnLlfrppW10O8DahpO4cc/+/EuU1Dpx2rfDGDNIw==
X-Received: by 2002:a67:edcf:: with SMTP id e15mr2485845vsp.75.1562834972638;
        Thu, 11 Jul 2019 01:49:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyp6FWlBncMvBHopJ4gSA5rjwP3zKi8SZCvHDphE55A7XKE/dA5FjLVweDbHCwbV4Y8/rmT
X-Received: by 2002:a67:edcf:: with SMTP id e15mr2485790vsp.75.1562834971989;
        Thu, 11 Jul 2019 01:49:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562834971; cv=none;
        d=google.com; s=arc-20160816;
        b=yy2rs14mwwp8zeyLnmt2dYXM8W8JJW+c66t4A/fuJKQ09saUIm+vxQm1ZjoF7B5uLp
         fbjemenWSGFx8DWZXtgIuzDqUiUM21dRMGWNEinusSvJsCu56jx7tSU9DuuxUUhkJg4/
         d2t9L/Pkhxgk5dTjnkpgAMBoc/B8muOOomLwgEiNTn+07WXwYnwlwwG7RbHY7f2jo5VE
         9W8ULF+kHi0z+pupr5+7vKHsmXLomDpRI8T6AFl+go2iQBvamA5mmp4adQtIf5PJk4EQ
         o7JSOOSQKrmAW0AD4+N6wuk6L/k02W4K8AAY9duqVB2YJzQ34J+uJ/qiIdNdenGVqKw6
         8fgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=uzboYqu/EnutsUfDvdzc2QGLrZgrkC1MIL9crIUqBoM=;
        b=Ab6HJHVHPL1gcB4+xrxOnNK3AZ4DZ+g5UeNREqE998AVU4qOl4+hFRhB5lfZQbPWkL
         DppFFbtWMuebhqowykMzdndl7a+FFiWgL/+mDKuTPB+NMX00PTO1O4EQ7YdOgzA6FYAA
         MA515ksMCK2efI8Kd9jD7YQY63ixDFMxHGeEd/Yio4izKQ4qZ/+PsHk+teEEvksxEpN6
         6JtkdPSv63ZgMBRNkWtHKn3PBGW5V+6YW+G+3xS78odXKw6S7RU0wdoVOGKuBskf1OgU
         H4IhrvADrFLdNN0Ef587EwpiYI/KjsYUF5dkNSL80M/5Dp+S5lCvko4K10Xwo+eQ0aKm
         5ZHw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of cohuck@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=cohuck@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y23si1219633vsn.156.2019.07.11.01.49.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 01:49:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of cohuck@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of cohuck@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=cohuck@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 13A2D81F07;
	Thu, 11 Jul 2019 08:49:30 +0000 (UTC)
Received: from gondolin (ovpn-117-213.ams2.redhat.com [10.36.117.213])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 324321001B05;
	Thu, 11 Jul 2019 08:49:15 +0000 (UTC)
Date: Thu, 11 Jul 2019 10:49:12 +0200
From: Cornelia Huck <cohuck@redhat.com>
To: Nitesh Narayan Lal <nitesh@redhat.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 pbonzini@redhat.com, lcapitulino@redhat.com, pagupta@redhat.com,
 wei.w.wang@intel.com, yang.zhang.wz@gmail.com, riel@surriel.com,
 david@redhat.com, mst@redhat.com, dodgen@google.com,
 konrad.wilk@oracle.com, dhildenb@redhat.com, aarcange@redhat.com,
 alexander.duyck@gmail.com, john.starks@microsoft.com,
 dave.hansen@intel.com, mhocko@suse.com
Subject: Re: [QEMU Patch] virtio-baloon: Support for page hinting
Message-ID: <20190711104912.2cd79aeb.cohuck@redhat.com>
In-Reply-To: <20190710195303.19690-1-nitesh@redhat.com>
References: <20190710195158.19640-1-nitesh@redhat.com>
	<20190710195303.19690-1-nitesh@redhat.com>
Organization: Red Hat GmbH
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Thu, 11 Jul 2019 08:49:31 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 10 Jul 2019 15:53:03 -0400
Nitesh Narayan Lal <nitesh@redhat.com> wrote:


$SUBJECT: s/baloon/balloon/

> Enables QEMU to perform madvise free on the memory range reported
> by the vm.

[No comments on the actual functionality; just some stuff I noticed.]

> 
> Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>
> ---
>  hw/virtio/trace-events                        |  1 +
>  hw/virtio/virtio-balloon.c                    | 59 +++++++++++++++++++
>  include/hw/virtio/virtio-balloon.h            |  2 +-
>  include/qemu/osdep.h                          |  7 +++
>  .../standard-headers/linux/virtio_balloon.h   |  1 +
>  5 files changed, 69 insertions(+), 1 deletion(-)
> 

(...)

> diff --git a/hw/virtio/virtio-balloon.c b/hw/virtio/virtio-balloon.c
> index 2112874055..5d186707b5 100644
> --- a/hw/virtio/virtio-balloon.c
> +++ b/hw/virtio/virtio-balloon.c
> @@ -34,6 +34,9 @@
>  
>  #define BALLOON_PAGE_SIZE  (1 << VIRTIO_BALLOON_PFN_SHIFT)
>  
> +#define VIRTIO_BALLOON_PAGE_HINTING_MAX_PAGES	16
> +void free_mem_range(uint64_t addr, uint64_t len);
> +
>  struct PartiallyBalloonedPage {
>      RAMBlock *rb;
>      ram_addr_t base;
> @@ -328,6 +331,58 @@ static void balloon_stats_set_poll_interval(Object *obj, Visitor *v,
>      balloon_stats_change_timer(s, 0);
>  }
>  
> +void free_mem_range(uint64_t addr, uint64_t len)
> +{
> +    int ret = 0;
> +    void *hvaddr_to_free;
> +    MemoryRegionSection mrs = memory_region_find(get_system_memory(),
> +                                                 addr, 1);
> +    if (!mrs.mr) {
> +	warn_report("%s:No memory is mapped at address 0x%lu", __func__, addr);

Indentation seems to be off here (also in other places; please double
check.)

> +        return;
> +    }
> +
> +    if (!memory_region_is_ram(mrs.mr) && !memory_region_is_romd(mrs.mr)) {
> +	warn_report("%s:Memory at address 0x%s is not RAM:0x%lu", __func__,
> +		    HWADDR_PRIx, addr);
> +        memory_region_unref(mrs.mr);
> +        return;
> +    }
> +
> +    hvaddr_to_free = qemu_map_ram_ptr(mrs.mr->ram_block, mrs.offset_within_region);
> +    trace_virtio_balloon_hinting_request(addr, len);
> +    ret = qemu_madvise(hvaddr_to_free,len, QEMU_MADV_FREE);
> +    if (ret == -1) {
> +	warn_report("%s: Madvise failed with error:%d", __func__, ret);
> +    }
> +}
> +
> +static void virtio_balloon_handle_page_hinting(VirtIODevice *vdev,
> +					       VirtQueue *vq)
> +{
> +    VirtQueueElement *elem;
> +    size_t offset = 0;
> +    uint64_t gpa, len;
> +    elem = virtqueue_pop(vq, sizeof(VirtQueueElement));
> +    if (!elem) {
> +        return;
> +    }
> +    /* For pending hints which are < max_pages(16), 'gpa != 0' ensures that we
> +     * only read the buffer which holds a valid PFN value.
> +     * TODO: Find a better way to do this.
> +     */
> +    while (iov_to_buf(elem->out_sg, elem->out_num, offset, &gpa, 8) == 8 && gpa != 0) {
> +	offset += 8;
> +	offset += iov_to_buf(elem->out_sg, elem->out_num, offset, &len, 8);
> +	if (!qemu_balloon_is_inhibited()) {
> +	    free_mem_range(gpa, len);
> +	}
> +    }
> +    virtqueue_push(vq, elem, offset);
> +    virtio_notify(vdev, vq);
> +    g_free(elem);
> +}
> +
>  static void virtio_balloon_handle_output(VirtIODevice *vdev, VirtQueue *vq)
>  {
>      VirtIOBalloon *s = VIRTIO_BALLOON(vdev);
> @@ -694,6 +749,7 @@ static uint64_t virtio_balloon_get_features(VirtIODevice *vdev, uint64_t f,
>      VirtIOBalloon *dev = VIRTIO_BALLOON(vdev);
>      f |= dev->host_features;
>      virtio_add_feature(&f, VIRTIO_BALLOON_F_STATS_VQ);
> +    virtio_add_feature(&f, VIRTIO_BALLOON_F_HINTING);

I don't think you can add this unconditionally if you want to keep this
migratable. This should be done via a property (as for deflate-on-oom
and free-page-hint) so it can be turned off in compat machines.

>  
>      return f;
>  }
> @@ -780,6 +836,7 @@ static void virtio_balloon_device_realize(DeviceState *dev, Error **errp)
>      s->ivq = virtio_add_queue(vdev, 128, virtio_balloon_handle_output);
>      s->dvq = virtio_add_queue(vdev, 128, virtio_balloon_handle_output);
>      s->svq = virtio_add_queue(vdev, 128, virtio_balloon_receive_stats);
> +    s->hvq = virtio_add_queue(vdev, 128, virtio_balloon_handle_page_hinting);

This should probably be conditional in the same way as the free page hint
queue (also see above).

>  
>      if (virtio_has_feature(s->host_features,
>                             VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
> @@ -875,6 +932,8 @@ static void virtio_balloon_instance_init(Object *obj)
>  
>      object_property_add(obj, "guest-stats", "guest statistics",
>                          balloon_stats_get_all, NULL, NULL, s, NULL);
> +    object_property_add(obj, "guest-page-hinting", "guest page hinting",
> +                        NULL, NULL, NULL, s, NULL);

This object does not have any accessors; what purpose does it serve?

>  
>      object_property_add(obj, "guest-stats-polling-interval", "int",
>                          balloon_stats_get_poll_interval,

(...)

> diff --git a/include/standard-headers/linux/virtio_balloon.h b/include/standard-headers/linux/virtio_balloon.h
> index 9375ca2a70..f9e3e82562 100644
> --- a/include/standard-headers/linux/virtio_balloon.h
> +++ b/include/standard-headers/linux/virtio_balloon.h
> @@ -36,6 +36,7 @@
>  #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
>  #define VIRTIO_BALLOON_F_FREE_PAGE_HINT	3 /* VQ to report free pages */
>  #define VIRTIO_BALLOON_F_PAGE_POISON	4 /* Guest is using page poisoning */
> +#define VIRTIO_BALLOON_F_HINTING	5 /* Page hinting virtqueue */
>  
>  /* Size of a PFN in the balloon interface. */
>  #define VIRTIO_BALLOON_PFN_SHIFT 12

Please split off any update to these headers into a separate patch, so
that it can be replaced by a proper headers update when it is merged.

