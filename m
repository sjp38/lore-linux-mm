Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A607C43613
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 22:37:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A1C062085A
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 22:37:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LZXgUEf2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A1C062085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 33B866B0003; Wed, 19 Jun 2019 18:37:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2EB748E0002; Wed, 19 Jun 2019 18:37:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D9D78E0001; Wed, 19 Jun 2019 18:37:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id F0E776B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 18:37:17 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id h3so1451813iob.20
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 15:37:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=rcB09Esy94C7aChcgEU5ub/5hCFzSMInAKoZyHyAl/0=;
        b=dlXq/1tgkdzpiDfZHqcn9t6/lV8PgH2P42v1uH0vDOsqN7ocWwg0t3q/LMMoHpNlbA
         JYyTqk9Cnc1LGRQ7LRdiQ8hW2pjCePk36OUHKYnLkFS7JKrmCFKF7qx8pL6dHtUewKVy
         MHp+2MhXaVeyMaAcEjordu2GAeyxRBV7eveAwtPUCEfZGiYLXJGG8cbSeTAY2VA8R+vE
         Pj8Gbk1CHoCcTMoAb2jGatSDhWSeTWgrV2SqiWUR6pg80BXM9IfytlJXmWIUxmL6L1pt
         ah6o04TiPv5r8YQbuRZnWNMS0VasPb5zxzMZPIqnKn049oTnsNrO/XATIke8U8EM9Dtm
         w5nA==
X-Gm-Message-State: APjAAAVNuTvuO9Fmtf7ggYYbM6ztkvTOL+aosn8CYbWqFOPSY41OPAc7
	Xtw38Ce3I2h5umo25O3EDMhcgYFzIJvSEDjDn1W1QVaBLj1rl9i2cPE1JhnSr27RXiCQKO/nvj3
	5ngG/i9DmSwBHj9+tDzydzGgWQwsjnc57ryVAWHD3Sa5ICS3qbRk79FLfHCpA3PRdvg==
X-Received: by 2002:a6b:1494:: with SMTP id 142mr91201977iou.72.1560983837675;
        Wed, 19 Jun 2019 15:37:17 -0700 (PDT)
X-Received: by 2002:a6b:1494:: with SMTP id 142mr91201911iou.72.1560983836740;
        Wed, 19 Jun 2019 15:37:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560983836; cv=none;
        d=google.com; s=arc-20160816;
        b=JgHJqEIgtSKYTDRHOHqVGPMRsMyNd/Mg6QV9EQ7Gu0yz5jE6rOO9D8IMXWmhNY9yMq
         gcgMBvvPbcvMLK+6gBgWNCNq1c05xe2Obh1wy9BNd4CgVMNUrmsVOtn4rgXpVlo5ZDtk
         4WJ01MQGcRrqAxp7Lq0yW5l/wfVxkfnXjjnZAlBzJOsQnCVlKl7X/aymziZ933Ml9K9q
         Jk+mc47lEblBtsC64YHDQLzZ9h04RYQGFiH16d/yN8OKzAroUZEUprC2f8jWpUD01R/s
         n0+FQk+YGODIpfMc7DNEF11KgTVrmz2g+jBGZEgf/fWPOmK8K5xsszkrg461cNgVfABa
         JbjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=rcB09Esy94C7aChcgEU5ub/5hCFzSMInAKoZyHyAl/0=;
        b=rXH+GEcExb+vRbho9OOmgrZ4Fo86qlDyORdngTFlifYGDyguUE36DHOluvLXHc715E
         FKVP/KMv6cFt/IWwXyczQpJjt3rpnUQZ2JV98CvlLQ4Qtxzf0hqWoy+zIPqRwhXZOcC3
         rVP+8k3IpNkqbsdo5x3X8RDUz41SklyP9Qk1vlr/OTxq5MihDkcBIu1YRIlI8ja5lqjY
         7sRf6Se2VDBF+iXjO3/vLUs1TJo3WpdoHMy0KHHSvLIsx3RRrzf7gkEaWjZkE1E79pjv
         hAlloHybhRDb21T4XqO9Jm3G2RGBo97wb3uGLxxfjpuKurbREKxrbvCuxKMC4bqJsoII
         y/Jg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=LZXgUEf2;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m187sor15383965ioa.46.2019.06.19.15.37.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 15:37:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=LZXgUEf2;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=rcB09Esy94C7aChcgEU5ub/5hCFzSMInAKoZyHyAl/0=;
        b=LZXgUEf2jH6LL8isvS0SoC4yM3DSuvpULKrmFDjMu5bU+6TBb6nAYRPQUz8lFzWJRu
         gyysj5UuzA6V4jGjWO5zNOTav1bATCNgO6vHJf+3rbOsVHmDV+rZYOjL+bZ5P+qROwJm
         s74ZcJhFwkjUZuhCn6r5GqKbzxBT/Cnfxtn/FeIz0L6Q7rX2oGA1ocFb+R7Vyx450ARN
         qoqQ4guMuYV/KkCfiNhOv3R/xCkdx3vDwN+dOnLI6cgMj5k9m1mkUHIX2rAgTC82c4J+
         ahIHc2oUFLBsdpgxhZ4NgyplBSEiPkGsYiI8Z9ucSQSIuPw83S267tsWnRgYHx71aNYN
         awIQ==
X-Google-Smtp-Source: APXvYqzfCZXJ6ZYmgDdjSyNXw8kk4GtmA9Co/QnObvMoQH5mbGA51G3bhAlOwrkVwB/hMuhvFYspKg==
X-Received: by 2002:a5e:8f08:: with SMTP id c8mr2859494iok.52.1560983836332;
        Wed, 19 Jun 2019 15:37:16 -0700 (PDT)
Received: from localhost.localdomain (50-126-100-225.drr01.csby.or.frontiernet.net. [50.126.100.225])
        by smtp.gmail.com with ESMTPSA id v25sm15377416ioh.25.2019.06.19.15.37.14
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 15:37:15 -0700 (PDT)
Subject: [PATCH v1 QEMU] QEMU: Provide a interface for hinting based off of
 the balloon infrastructure
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
Date: Wed, 19 Jun 2019 15:37:13 -0700
Message-ID: <20190619223535.1403.32612.stgit@localhost.localdomain>
In-Reply-To: <20190619222922.1231.27432.stgit@localhost.localdomain>
References: <20190619222922.1231.27432.stgit@localhost.localdomain>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alexander Duyck <alexander.h.duyck@linux.intel.com>

Add support for what I am referring to as "bubble hinting". Basically the
idea is to function very similar to how the balloon works in that we
basically end up madvising the page as not being used. However we don't
really need to bother with any deflate type logic since the page will be
faulted back into the guest when it is read or written to.

This is meant to be a simplification of the existing balloon interface
to use for providing hints to what memory needs to be freed. I am assuming
this is safe to do as the deflate logic does not actually appear to do very
much other than tracking what subpages have been released and which ones
haven't.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 hw/virtio/trace-events                          |    1 
 hw/virtio/virtio-balloon.c                      |   73 +++++++++++++++++++++++
 include/hw/virtio/virtio-balloon.h              |    2 -
 include/standard-headers/linux/virtio_balloon.h |    1 
 4 files changed, 76 insertions(+), 1 deletion(-)

diff --git a/hw/virtio/trace-events b/hw/virtio/trace-events
index e28ba48da621..b56daf460769 100644
--- a/hw/virtio/trace-events
+++ b/hw/virtio/trace-events
@@ -46,6 +46,7 @@ virtio_balloon_handle_output(const char *name, uint64_t gpa) "section name: %s g
 virtio_balloon_get_config(uint32_t num_pages, uint32_t actual) "num_pages: %d actual: %d"
 virtio_balloon_set_config(uint32_t actual, uint32_t oldactual) "actual: %d oldactual: %d"
 virtio_balloon_to_target(uint64_t target, uint32_t num_pages) "balloon target: 0x%"PRIx64" num_pages: %d"
+virtio_bubble_handle_output(const char *name, uint64_t gpa, uint64_t size) "section name: %s gpa: 0x%" PRIx64 " size: %" PRIx64
 
 # virtio-mmio.c
 virtio_mmio_read(uint64_t offset) "virtio_mmio_read offset 0x%" PRIx64
diff --git a/hw/virtio/virtio-balloon.c b/hw/virtio/virtio-balloon.c
index 2112874055fb..93ee165d2db2 100644
--- a/hw/virtio/virtio-balloon.c
+++ b/hw/virtio/virtio-balloon.c
@@ -328,6 +328,75 @@ static void balloon_stats_set_poll_interval(Object *obj, Visitor *v,
     balloon_stats_change_timer(s, 0);
 }
 
+static void bubble_inflate_page(VirtIOBalloon *balloon,
+                                MemoryRegion *mr, hwaddr offset, size_t size)
+{
+    void *addr = memory_region_get_ram_ptr(mr) + offset;
+    ram_addr_t ram_offset;
+    size_t rb_page_size;
+    RAMBlock *rb;
+
+    rb = qemu_ram_block_from_host(addr, false, &ram_offset);
+    rb_page_size = qemu_ram_pagesize(rb);
+
+    /* For now we will simply ignore unaligned memory regions */
+    if ((ram_offset | size) & (rb_page_size - 1))
+        return;
+
+    ram_block_discard_range(rb, ram_offset, size);
+}
+
+static void virtio_bubble_handle_output(VirtIODevice *vdev, VirtQueue *vq)
+{
+    VirtIOBalloon *s = VIRTIO_BALLOON(vdev);
+    VirtQueueElement *elem;
+    MemoryRegionSection section;
+
+    for (;;) {
+        size_t offset = 0;
+	uint64_t pa_order;
+
+        elem = virtqueue_pop(vq, sizeof(VirtQueueElement));
+        if (!elem) {
+            return;
+        }
+
+        while (iov_to_buf(elem->out_sg, elem->out_num, offset, &pa_order, 8) == 8) {
+            hwaddr pa = virtio_ldq_p(vdev, &pa_order);
+            size_t size = 1ul << (VIRTIO_BALLOON_PFN_SHIFT + (pa & 0xFF));
+
+            pa -= pa & 0xFF;
+            offset += 8;
+
+            if (qemu_balloon_is_inhibited())
+                continue;
+
+            section = memory_region_find(get_system_memory(), pa, size);
+            if (!section.mr) {
+                trace_virtio_balloon_bad_addr(pa);
+                continue;
+            }
+
+            if (!memory_region_is_ram(section.mr) ||
+                memory_region_is_rom(section.mr) ||
+                memory_region_is_romd(section.mr)) {
+                trace_virtio_balloon_bad_addr(pa);
+            } else {
+                trace_virtio_bubble_handle_output(memory_region_name(section.mr),
+                                                  pa, size);
+                bubble_inflate_page(s, section.mr,
+                                    section.offset_within_region, size);
+            }
+
+            memory_region_unref(section.mr);
+        }
+
+        virtqueue_push(vq, elem, offset);
+        virtio_notify(vdev, vq);
+        g_free(elem);
+    }
+}
+
 static void virtio_balloon_handle_output(VirtIODevice *vdev, VirtQueue *vq)
 {
     VirtIOBalloon *s = VIRTIO_BALLOON(vdev);
@@ -694,6 +763,7 @@ static uint64_t virtio_balloon_get_features(VirtIODevice *vdev, uint64_t f,
     VirtIOBalloon *dev = VIRTIO_BALLOON(vdev);
     f |= dev->host_features;
     virtio_add_feature(&f, VIRTIO_BALLOON_F_STATS_VQ);
+    virtio_add_feature(&f, VIRTIO_BALLOON_F_HINTING);
 
     return f;
 }
@@ -780,6 +850,7 @@ static void virtio_balloon_device_realize(DeviceState *dev, Error **errp)
     s->ivq = virtio_add_queue(vdev, 128, virtio_balloon_handle_output);
     s->dvq = virtio_add_queue(vdev, 128, virtio_balloon_handle_output);
     s->svq = virtio_add_queue(vdev, 128, virtio_balloon_receive_stats);
+    s->hvq = virtio_add_queue(vdev, 128, virtio_bubble_handle_output);
 
     if (virtio_has_feature(s->host_features,
                            VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
@@ -875,6 +946,8 @@ static void virtio_balloon_instance_init(Object *obj)
 
     object_property_add(obj, "guest-stats", "guest statistics",
                         balloon_stats_get_all, NULL, NULL, s, NULL);
+    object_property_add(obj, "guest-page-hinting", "guest page hinting",
+                        NULL, NULL, NULL, s, NULL);
 
     object_property_add(obj, "guest-stats-polling-interval", "int",
                         balloon_stats_get_poll_interval,
diff --git a/include/hw/virtio/virtio-balloon.h b/include/hw/virtio/virtio-balloon.h
index 1afafb12f6bc..dd6d4d0e45fd 100644
--- a/include/hw/virtio/virtio-balloon.h
+++ b/include/hw/virtio/virtio-balloon.h
@@ -44,7 +44,7 @@ enum virtio_balloon_free_page_report_status {
 
 typedef struct VirtIOBalloon {
     VirtIODevice parent_obj;
-    VirtQueue *ivq, *dvq, *svq, *free_page_vq;
+    VirtQueue *ivq, *dvq, *svq, *hvq, *free_page_vq;
     uint32_t free_page_report_status;
     uint32_t num_pages;
     uint32_t actual;
diff --git a/include/standard-headers/linux/virtio_balloon.h b/include/standard-headers/linux/virtio_balloon.h
index 9375ca2a70de..f9e3e8256261 100644
--- a/include/standard-headers/linux/virtio_balloon.h
+++ b/include/standard-headers/linux/virtio_balloon.h
@@ -36,6 +36,7 @@
 #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
 #define VIRTIO_BALLOON_F_FREE_PAGE_HINT	3 /* VQ to report free pages */
 #define VIRTIO_BALLOON_F_PAGE_POISON	4 /* Guest is using page poisoning */
+#define VIRTIO_BALLOON_F_HINTING	5 /* Page hinting virtqueue */
 
 /* Size of a PFN in the balloon interface. */
 #define VIRTIO_BALLOON_PFN_SHIFT 12

