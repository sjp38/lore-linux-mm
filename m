Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNWANTED_LANGUAGE_BODY autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69820C74A35
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 19:53:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1DD4D20645
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 19:53:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1DD4D20645
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C4FA88E0091; Wed, 10 Jul 2019 15:53:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C013B8E0032; Wed, 10 Jul 2019 15:53:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF06D8E0091; Wed, 10 Jul 2019 15:53:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7AA458E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 15:53:43 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id s22so3275531qtb.22
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 12:53:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=QtrGFbT4anigahWIKxNA+P3H9ibtX5/8LwxD72NgsM8=;
        b=lwu3ZVdGxSTqJLkf6A3vXRK7IjNUhn7KvbflgJEJFEBIGEJ+ztZ7b98gO8N4wCgEp/
         tMx+H7WRab+ru/MVhHG3VGmDYFa8nineO3QoBUDQEoN7eu/nuTXCtk6gPMj9slg2kqM4
         nKi16x5tmpH6POJyliMJlVBPiitjsqxyBkKqBmUHu/vXANcA0PVxTG39VSFdjF1bIZ2C
         dUm7VKDwzSy8vk7ZNpFRK/VXaKJGeYMUjV2+/MkvDsbBfS9ppdR0FDewJi2ppq4yQIOl
         g39HqdDXbiHbvyeEkiAUVxReiNuiaZQkz3yEVnpm7G+4T7GoYpPRJgAGsCrecGtXgPUf
         5v8Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXZASJyEeh8rqTdZrt1bhljdhL9T2UPkD/T5psCo4VbeYsk14RQ
	nlt0MovfD2U2X3lSLEKE/Jd9IXycLFBsHSjSAFe3oMwUfMB+cLStA4TertpDVi3gW7BKO1HqSy5
	30c6hSahJY4x9rfAVp7Djmi9ZENqnKYQDEgtV3GnzWvdwSi0tfEesep3wSKdydhXsCw==
X-Received: by 2002:ac8:70d1:: with SMTP id g17mr25812006qtp.124.1562788423120;
        Wed, 10 Jul 2019 12:53:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxq3HhztBr6riCx2TXMy4gYRyxIQYNMSrzrYLBlHsshJjGdpSpkR5C83qjWCHuhy0IoIkqB
X-Received: by 2002:ac8:70d1:: with SMTP id g17mr25811941qtp.124.1562788421810;
        Wed, 10 Jul 2019 12:53:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562788421; cv=none;
        d=google.com; s=arc-20160816;
        b=MB0n6ppJWGbkvkF3B41OU09Qpjncud2pgNf+BDEG1tPHU1nNMUPixgukpZbHLFaURJ
         SbAdM8rBa5qfXCk9kHOc2QT3Hk98kHaJDqQaVaNtOXi9OM2bSMZNjtTXTOponYqSSMB4
         z3m2unVNAJDHViHJNStm2HWafWOSJoTv70hEukwJet5Tgz+lDeOOKrKhSyXPuMte/KAY
         UO8HAimgkenPV5mK+rJkBaL4t+Yqe7Bd922ntDuOwzLP4w98DsNMu888HuaN/EnJYYJ/
         hy1p4nr7nvGEJrD4Xx9SQ4ODobNMj/DR7vFUVkj6t2auAqGxKOYg7COhF+c7U5wYN2AR
         dOhg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from;
        bh=QtrGFbT4anigahWIKxNA+P3H9ibtX5/8LwxD72NgsM8=;
        b=y7h665j53Me7fJijjrF+lDvE1rUOc3JBmBemSykFAIBAIP4m0G/mYhm0aTSQYp+ZAA
         nCb+jMcNNwMQ9TD2v21Wp+saySlzPLwXej4JnzWdUctAdDs+FqEQ2XKQjMkHxizt0HBA
         luNR+3qumOtGS16B0dZ0PkAYjVze4x4X49t3VErIHv+edCOy0X6/HfHGKXEfWc8O7RTN
         2Qz28q0a2V1Ty7uN5lDEhmTpxhqtiiKbn6wiBG9/cwLezq7M4fGIRal/qNEMojqQnpTe
         ATX4+JUw0pwy5K6pHYoLZg7UyyYMQq7DKAJVwaKIL1jfHsjTVJA8xZ4L/567O2RPfG/T
         oD4w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b11si2263384qkg.179.2019.07.10.12.53.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jul 2019 12:53:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A8BDF81E15;
	Wed, 10 Jul 2019 19:53:40 +0000 (UTC)
Received: from virtlab512.virt.lab.eng.bos.redhat.com (virtlab512.virt.lab.eng.bos.redhat.com [10.19.152.206])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 3BE1A19C69;
	Wed, 10 Jul 2019 19:53:19 +0000 (UTC)
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	pbonzini@redhat.com,
	lcapitulino@redhat.com,
	pagupta@redhat.com,
	wei.w.wang@intel.com,
	yang.zhang.wz@gmail.com,
	riel@surriel.com,
	david@redhat.com,
	mst@redhat.com,
	dodgen@google.com,
	konrad.wilk@oracle.com,
	dhildenb@redhat.com,
	aarcange@redhat.com,
	alexander.duyck@gmail.com,
	john.starks@microsoft.com,
	dave.hansen@intel.com,
	mhocko@suse.com
Subject: [QEMU Patch] virtio-baloon: Support for page hinting
Date: Wed, 10 Jul 2019 15:53:03 -0400
Message-Id: <20190710195303.19690-1-nitesh@redhat.com>
In-Reply-To: <20190710195158.19640-1-nitesh@redhat.com>
References: <20190710195158.19640-1-nitesh@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Wed, 10 Jul 2019 19:53:40 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Enables QEMU to perform madvise free on the memory range reported
by the vm.

Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>
---
 hw/virtio/trace-events                        |  1 +
 hw/virtio/virtio-balloon.c                    | 59 +++++++++++++++++++
 include/hw/virtio/virtio-balloon.h            |  2 +-
 include/qemu/osdep.h                          |  7 +++
 .../standard-headers/linux/virtio_balloon.h   |  1 +
 5 files changed, 69 insertions(+), 1 deletion(-)

diff --git a/hw/virtio/trace-events b/hw/virtio/trace-events
index e28ba48da6..f703a22d36 100644
--- a/hw/virtio/trace-events
+++ b/hw/virtio/trace-events
@@ -46,6 +46,7 @@ virtio_balloon_handle_output(const char *name, uint64_t gpa) "section name: %s g
 virtio_balloon_get_config(uint32_t num_pages, uint32_t actual) "num_pages: %d actual: %d"
 virtio_balloon_set_config(uint32_t actual, uint32_t oldactual) "actual: %d oldactual: %d"
 virtio_balloon_to_target(uint64_t target, uint32_t num_pages) "balloon target: 0x%"PRIx64" num_pages: %d"
+virtio_balloon_hinting_request(unsigned long pfn, unsigned int num_pages) "Guest page hinting request PFN:%lu size: %d"
 
 # virtio-mmio.c
 virtio_mmio_read(uint64_t offset) "virtio_mmio_read offset 0x%" PRIx64
diff --git a/hw/virtio/virtio-balloon.c b/hw/virtio/virtio-balloon.c
index 2112874055..5d186707b5 100644
--- a/hw/virtio/virtio-balloon.c
+++ b/hw/virtio/virtio-balloon.c
@@ -34,6 +34,9 @@
 
 #define BALLOON_PAGE_SIZE  (1 << VIRTIO_BALLOON_PFN_SHIFT)
 
+#define VIRTIO_BALLOON_PAGE_HINTING_MAX_PAGES	16
+void free_mem_range(uint64_t addr, uint64_t len);
+
 struct PartiallyBalloonedPage {
     RAMBlock *rb;
     ram_addr_t base;
@@ -328,6 +331,58 @@ static void balloon_stats_set_poll_interval(Object *obj, Visitor *v,
     balloon_stats_change_timer(s, 0);
 }
 
+void free_mem_range(uint64_t addr, uint64_t len)
+{
+    int ret = 0;
+    void *hvaddr_to_free;
+    MemoryRegionSection mrs = memory_region_find(get_system_memory(),
+                                                 addr, 1);
+    if (!mrs.mr) {
+	warn_report("%s:No memory is mapped at address 0x%lu", __func__, addr);
+        return;
+    }
+
+    if (!memory_region_is_ram(mrs.mr) && !memory_region_is_romd(mrs.mr)) {
+	warn_report("%s:Memory at address 0x%s is not RAM:0x%lu", __func__,
+		    HWADDR_PRIx, addr);
+        memory_region_unref(mrs.mr);
+        return;
+    }
+
+    hvaddr_to_free = qemu_map_ram_ptr(mrs.mr->ram_block, mrs.offset_within_region);
+    trace_virtio_balloon_hinting_request(addr, len);
+    ret = qemu_madvise(hvaddr_to_free,len, QEMU_MADV_FREE);
+    if (ret == -1) {
+	warn_report("%s: Madvise failed with error:%d", __func__, ret);
+    }
+}
+
+static void virtio_balloon_handle_page_hinting(VirtIODevice *vdev,
+					       VirtQueue *vq)
+{
+    VirtQueueElement *elem;
+    size_t offset = 0;
+    uint64_t gpa, len;
+    elem = virtqueue_pop(vq, sizeof(VirtQueueElement));
+    if (!elem) {
+        return;
+    }
+    /* For pending hints which are < max_pages(16), 'gpa != 0' ensures that we
+     * only read the buffer which holds a valid PFN value.
+     * TODO: Find a better way to do this.
+     */
+    while (iov_to_buf(elem->out_sg, elem->out_num, offset, &gpa, 8) == 8 && gpa != 0) {
+	offset += 8;
+	offset += iov_to_buf(elem->out_sg, elem->out_num, offset, &len, 8);
+	if (!qemu_balloon_is_inhibited()) {
+	    free_mem_range(gpa, len);
+	}
+    }
+    virtqueue_push(vq, elem, offset);
+    virtio_notify(vdev, vq);
+    g_free(elem);
+}
+
 static void virtio_balloon_handle_output(VirtIODevice *vdev, VirtQueue *vq)
 {
     VirtIOBalloon *s = VIRTIO_BALLOON(vdev);
@@ -694,6 +749,7 @@ static uint64_t virtio_balloon_get_features(VirtIODevice *vdev, uint64_t f,
     VirtIOBalloon *dev = VIRTIO_BALLOON(vdev);
     f |= dev->host_features;
     virtio_add_feature(&f, VIRTIO_BALLOON_F_STATS_VQ);
+    virtio_add_feature(&f, VIRTIO_BALLOON_F_HINTING);
 
     return f;
 }
@@ -780,6 +836,7 @@ static void virtio_balloon_device_realize(DeviceState *dev, Error **errp)
     s->ivq = virtio_add_queue(vdev, 128, virtio_balloon_handle_output);
     s->dvq = virtio_add_queue(vdev, 128, virtio_balloon_handle_output);
     s->svq = virtio_add_queue(vdev, 128, virtio_balloon_receive_stats);
+    s->hvq = virtio_add_queue(vdev, 128, virtio_balloon_handle_page_hinting);
 
     if (virtio_has_feature(s->host_features,
                            VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
@@ -875,6 +932,8 @@ static void virtio_balloon_instance_init(Object *obj)
 
     object_property_add(obj, "guest-stats", "guest statistics",
                         balloon_stats_get_all, NULL, NULL, s, NULL);
+    object_property_add(obj, "guest-page-hinting", "guest page hinting",
+                        NULL, NULL, NULL, s, NULL);
 
     object_property_add(obj, "guest-stats-polling-interval", "int",
                         balloon_stats_get_poll_interval,
diff --git a/include/hw/virtio/virtio-balloon.h b/include/hw/virtio/virtio-balloon.h
index 1afafb12f6..a58b24fdf2 100644
--- a/include/hw/virtio/virtio-balloon.h
+++ b/include/hw/virtio/virtio-balloon.h
@@ -44,7 +44,7 @@ enum virtio_balloon_free_page_report_status {
 
 typedef struct VirtIOBalloon {
     VirtIODevice parent_obj;
-    VirtQueue *ivq, *dvq, *svq, *free_page_vq;
+    VirtQueue *ivq, *dvq, *svq, *free_page_vq, *hvq;
     uint32_t free_page_report_status;
     uint32_t num_pages;
     uint32_t actual;
diff --git a/include/qemu/osdep.h b/include/qemu/osdep.h
index af2b91f0b8..bb9207e7f4 100644
--- a/include/qemu/osdep.h
+++ b/include/qemu/osdep.h
@@ -360,6 +360,11 @@ void qemu_anon_ram_free(void *ptr, size_t size);
 #else
 #define QEMU_MADV_REMOVE QEMU_MADV_INVALID
 #endif
+#ifdef MADV_FREE
+#define QEMU_MADV_FREE MADV_FREE
+#else
+#define QEMU_MADV_FREE QEMU_MADV_INVALID
+#endif
 
 #elif defined(CONFIG_POSIX_MADVISE)
 
@@ -373,6 +378,7 @@ void qemu_anon_ram_free(void *ptr, size_t size);
 #define QEMU_MADV_HUGEPAGE  QEMU_MADV_INVALID
 #define QEMU_MADV_NOHUGEPAGE  QEMU_MADV_INVALID
 #define QEMU_MADV_REMOVE QEMU_MADV_INVALID
+#define QEMU_MADV_FREE QEMU_MADV_INVALID
 
 #else /* no-op */
 
@@ -386,6 +392,7 @@ void qemu_anon_ram_free(void *ptr, size_t size);
 #define QEMU_MADV_HUGEPAGE  QEMU_MADV_INVALID
 #define QEMU_MADV_NOHUGEPAGE  QEMU_MADV_INVALID
 #define QEMU_MADV_REMOVE QEMU_MADV_INVALID
+#define QEMU_MADV_FREE QEMU_MADV_INVALID
 
 #endif
 
diff --git a/include/standard-headers/linux/virtio_balloon.h b/include/standard-headers/linux/virtio_balloon.h
index 9375ca2a70..f9e3e82562 100644
--- a/include/standard-headers/linux/virtio_balloon.h
+++ b/include/standard-headers/linux/virtio_balloon.h
@@ -36,6 +36,7 @@
 #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
 #define VIRTIO_BALLOON_F_FREE_PAGE_HINT	3 /* VQ to report free pages */
 #define VIRTIO_BALLOON_F_PAGE_POISON	4 /* Guest is using page poisoning */
+#define VIRTIO_BALLOON_F_HINTING	5 /* Page hinting virtqueue */
 
 /* Size of a PFN in the balloon interface. */
 #define VIRTIO_BALLOON_PFN_SHIFT 12
-- 
2.21.0

