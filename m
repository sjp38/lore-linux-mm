Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNWANTED_LANGUAGE_BODY autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 806DAC282CE
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 17:04:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 367E0274BA
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 17:04:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 367E0274BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C0B886B0288; Mon,  3 Jun 2019 13:04:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BBC416B028A; Mon,  3 Jun 2019 13:04:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A5E096B028B; Mon,  3 Jun 2019 13:04:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 795646B0288
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 13:04:56 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id w110so9244010otb.10
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 10:04:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=XCi1shg9mS6pZNHeutsN7l/1FOaYjdQNy8Jsjq0ERiE=;
        b=eqbKf6iUJ5OADe5WWxELgbdj4QL/f0TNAkj5SBBbsRgbxyfeXtFve/wqVX1AqOx/uj
         i6+9BR8fxGlfoujqJdYyMnOk367lroggBqESicBwUcrZq6lWzcsReKkx2OutsOtDJOf4
         a9G04rcRgi5NYzHHGvOsg35htLT0McFeFQzd1YVeuO82qVgRevip/AIE9xtRDirMTgT8
         zv/pn51//r4LoXA13SoDtz0GPSEDIj8hTTEhELmE319QZxst3AsOKmRxk/n9TEkxnlfy
         orGPWBSoKjbsfl6kZVMCuGCn81lxJ3nyd94gb1MsY0v+k2L74ZYwKZN1DTA1WldDJ0v8
         O5+A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVaUbR6OP7R65Ty96aTspEjT9n9ycKEg6sXFHwj8H2TeVR7Rtdo
	S6i9ta4bSEX+APBGfovvSrHJAIk5WGdG8zFo/nPs8YovYF0gNzW7kUPcHTlDvZELVzLO48xb6OM
	Z5vqMb7CPETEZHY27wtYQidWg7pB1pEINy8MSyEjcf+K3cQednX3inLENK4toPO1h5Q==
X-Received: by 2002:aca:b2d6:: with SMTP id b205mr1660715oif.159.1559581496036;
        Mon, 03 Jun 2019 10:04:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwBYrSPxNWKLXw6t4Tn+RimV2i97oAnt3tnjiWkg4Hl5LdMUkw6wvkqR7qiubGgJEGbrYSa
X-Received: by 2002:aca:b2d6:: with SMTP id b205mr1660672oif.159.1559581495165;
        Mon, 03 Jun 2019 10:04:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559581495; cv=none;
        d=google.com; s=arc-20160816;
        b=Yihh7JwxP+dvhAS3tNOFY9LQPmjoSezy/YrsUuJLVRSX+Y5AqyPYwdyyvrwHhwzpWW
         fBps3jVV3ZYkmtkj7UG0JmNvWGCzdPlQuI3FMBN5QgoAVbwXxuo5nI52UinZy9fDrZLu
         3L6UOo4c7rNIKoTLJ62DH+fxtIe1NsgiELU+yEkY8h4ANnfxVcNOKBSBe3XLLz4HvXZ2
         A1T25npEIERX5kWCvjX3FRllu+jE9z0Edj/gRFLNPVY80ypRVJ1xAavts2ZYoFVWO9TG
         O1y3fUAQlIXNGE12CSW9Yz4v1NHgntw8eMZzO7jkmbA93igs6ztrdENNrH5RIigO2X/7
         wEAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from;
        bh=XCi1shg9mS6pZNHeutsN7l/1FOaYjdQNy8Jsjq0ERiE=;
        b=bJGJf8pc4BzHm+pQ4VOIfHbDzgNO0WUcucwIrQOH6pavWRYAiDFRP9JfaXKiW+nsQP
         sPsf6G7zXptu9fOqkCuwtMmD6LssejwuK8NNF3xoICN4B8ft2f616CTMMrjG5OwPUXEp
         7bjXn1LcBrnaiuJxAJZzPFqy09naiTGUUCO0pwdtpNzbadW72KwwB4Nx3CNgVFKPK/M/
         utDfAtZN+UwpX2BmKb8LlFTSZP5r07haZKV7yhA9ThJ+SiZ04naZS+zpdLD7f/aPbi6E
         joq96dkoQQ7jIpsux2M2NjtWdVnbP+x1N/ldPiTXIHo5mJzh2qrdxmD8afq/37F13GGR
         J68A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i129si7711623oia.63.2019.06.03.10.04.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 10:04:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C937B89C42;
	Mon,  3 Jun 2019 17:04:39 +0000 (UTC)
Received: from virtlab512.virt.lab.eng.bos.redhat.com (virtlab512.virt.lab.eng.bos.redhat.com [10.19.152.206])
	by smtp.corp.redhat.com (Postfix) with ESMTP id BC4E16090E;
	Mon,  3 Jun 2019 17:04:32 +0000 (UTC)
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
	alexander.duyck@gmail.com
Subject: [QEMU PATCH] KVM: Support for page hinting
Date: Mon,  3 Jun 2019 13:04:32 -0400
Message-Id: <20190603170432.1195-1-nitesh@redhat.com>
In-Reply-To: <20190603170306.49099-1-nitesh@redhat.com>
References: <20190603170306.49099-1-nitesh@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Mon, 03 Jun 2019 17:04:53 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Enables QEMU to call madvise on the pages which are reported
by the guest kernel.

Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>
---
 hw/virtio/trace-events                        |  1 +
 hw/virtio/virtio-balloon.c                    | 85 +++++++++++++++++++
 include/hw/virtio/virtio-balloon.h            |  2 +-
 include/qemu/osdep.h                          |  7 ++
 .../standard-headers/linux/virtio_balloon.h   |  1 +
 5 files changed, 95 insertions(+), 1 deletion(-)

diff --git a/hw/virtio/trace-events b/hw/virtio/trace-events
index 07bcbe9e85..015565785c 100644
--- a/hw/virtio/trace-events
+++ b/hw/virtio/trace-events
@@ -46,3 +46,4 @@ virtio_balloon_handle_output(const char *name, uint64_t gpa) "section name: %s g
 virtio_balloon_get_config(uint32_t num_pages, uint32_t actual) "num_pages: %d actual: %d"
 virtio_balloon_set_config(uint32_t actual, uint32_t oldactual) "actual: %d oldactual: %d"
 virtio_balloon_to_target(uint64_t target, uint32_t num_pages) "balloon target: 0x%"PRIx64" num_pages: %d"
+virtio_balloon_hinting_request(unsigned long pfn, unsigned int num_pages) "Guest page hinting request: %lu size: %d"
diff --git a/hw/virtio/virtio-balloon.c b/hw/virtio/virtio-balloon.c
index a12677d4d5..cbb630279c 100644
--- a/hw/virtio/virtio-balloon.c
+++ b/hw/virtio/virtio-balloon.c
@@ -33,6 +33,13 @@
 
 #define BALLOON_PAGE_SIZE  (1 << VIRTIO_BALLOON_PFN_SHIFT)
 
+struct guest_pages {
+	uint64_t phys_addr;
+	uint32_t len;
+};
+
+void page_hinting_request(uint64_t addr, uint32_t len);
+
 static void balloon_page(void *addr, int deflate)
 {
     if (!qemu_balloon_is_inhibited()) {
@@ -207,6 +214,80 @@ static void balloon_stats_set_poll_interval(Object *obj, Visitor *v,
     balloon_stats_change_timer(s, 0);
 }
 
+static void *gpa2hva(MemoryRegion **p_mr, hwaddr addr, Error **errp)
+{
+    MemoryRegionSection mrs = memory_region_find(get_system_memory(),
+                                                 addr, 1);
+
+    if (!mrs.mr) {
+        error_setg(errp, "No memory is mapped at address 0x%" HWADDR_PRIx, addr);
+        return NULL;
+    }
+
+    if (!memory_region_is_ram(mrs.mr) && !memory_region_is_romd(mrs.mr)) {
+        error_setg(errp, "Memory at address 0x%" HWADDR_PRIx "is not RAM", addr);
+        memory_region_unref(mrs.mr);
+        return NULL;
+    }
+
+    *p_mr = mrs.mr;
+    return qemu_map_ram_ptr(mrs.mr->ram_block, mrs.offset_within_region);
+}
+
+void page_hinting_request(uint64_t addr, uint32_t len)
+{
+    Error *local_err = NULL;
+    MemoryRegion *mr = NULL;
+    int ret = 0;
+    struct guest_pages *guest_obj;
+    int i = 0;
+    void *hvaddr_to_free;
+    uint64_t gpaddr_to_free;
+    void * temp_addr = gpa2hva(&mr, addr, &local_err);
+
+    if (local_err) {
+        error_report_err(local_err);
+        return;
+    }
+    guest_obj = temp_addr;
+    while (i < len) {
+	gpaddr_to_free = guest_obj[i].phys_addr;
+	trace_virtio_balloon_hinting_request(gpaddr_to_free,guest_obj[i].len);
+	hvaddr_to_free = gpa2hva(&mr, gpaddr_to_free, &local_err);
+	if (local_err) {
+		error_report_err(local_err);
+		return;
+	}
+	ret = qemu_madvise((void *)hvaddr_to_free, guest_obj[i].len, QEMU_MADV_FREE);
+	if (ret == -1)
+	    printf("\n%d:%s Error: Madvise failed with error:%d\n", __LINE__, __func__, ret);
+	i++;
+    }
+}
+
+static void virtio_balloon_page_hinting(VirtIODevice *vdev, VirtQueue *vq)
+{
+    VirtQueueElement *elem = NULL;
+    uint64_t temp_addr;
+    uint32_t temp_len;
+    size_t size, t_size = 0;
+
+    elem = virtqueue_pop(vq, sizeof(VirtQueueElement));
+    if (!elem) {
+	printf("\npop error\n");
+	return;
+    }
+    size = iov_to_buf(elem->out_sg, elem->out_num, 0, &temp_addr, sizeof(temp_addr));
+    t_size += size;
+    size = iov_to_buf(elem->out_sg, elem->out_num, 8, &temp_len, sizeof(temp_len));
+    t_size += size;
+    if (!qemu_balloon_is_inhibited())
+	    page_hinting_request(temp_addr, temp_len);
+    virtqueue_push(vq, elem, t_size);
+    virtio_notify(vdev, vq);
+    g_free(elem);
+}
+
 static void virtio_balloon_handle_output(VirtIODevice *vdev, VirtQueue *vq)
 {
     VirtIOBalloon *s = VIRTIO_BALLOON(vdev);
@@ -376,6 +457,7 @@ static uint64_t virtio_balloon_get_features(VirtIODevice *vdev, uint64_t f,
     VirtIOBalloon *dev = VIRTIO_BALLOON(vdev);
     f |= dev->host_features;
     virtio_add_feature(&f, VIRTIO_BALLOON_F_STATS_VQ);
+    virtio_add_feature(&f, VIRTIO_BALLOON_F_HINTING);
     return f;
 }
 
@@ -445,6 +527,7 @@ static void virtio_balloon_device_realize(DeviceState *dev, Error **errp)
     s->ivq = virtio_add_queue(vdev, 128, virtio_balloon_handle_output);
     s->dvq = virtio_add_queue(vdev, 128, virtio_balloon_handle_output);
     s->svq = virtio_add_queue(vdev, 128, virtio_balloon_receive_stats);
+    s->hvq = virtio_add_queue(vdev, 128, virtio_balloon_page_hinting);
 
     reset_stats(s);
 }
@@ -488,6 +571,8 @@ static void virtio_balloon_instance_init(Object *obj)
 
     object_property_add(obj, "guest-stats", "guest statistics",
                         balloon_stats_get_all, NULL, NULL, s, NULL);
+    object_property_add(obj, "guest-page-hinting", "guest page hinting",
+                        NULL, NULL, NULL, s, NULL);
 
     object_property_add(obj, "guest-stats-polling-interval", "int",
                         balloon_stats_get_poll_interval,
diff --git a/include/hw/virtio/virtio-balloon.h b/include/hw/virtio/virtio-balloon.h
index e0df3528c8..774498a6ca 100644
--- a/include/hw/virtio/virtio-balloon.h
+++ b/include/hw/virtio/virtio-balloon.h
@@ -32,7 +32,7 @@ typedef struct virtio_balloon_stat_modern {
 
 typedef struct VirtIOBalloon {
     VirtIODevice parent_obj;
-    VirtQueue *ivq, *dvq, *svq;
+    VirtQueue *ivq, *dvq, *svq, *hvq;
     uint32_t num_pages;
     uint32_t actual;
     uint64_t stats[VIRTIO_BALLOON_S_NR];
diff --git a/include/qemu/osdep.h b/include/qemu/osdep.h
index 840af09cb0..4d632933a9 100644
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
index 4dbb7dc6c0..f50c0d95ea 100644
--- a/include/standard-headers/linux/virtio_balloon.h
+++ b/include/standard-headers/linux/virtio_balloon.h
@@ -34,6 +34,7 @@
 #define VIRTIO_BALLOON_F_MUST_TELL_HOST	0 /* Tell before reclaiming pages */
 #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
 #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
+#define VIRTIO_BALLOON_F_HINTING	5 /* Page hinting virtqueue */
 
 /* Size of a PFN in the balloon interface. */
 #define VIRTIO_BALLOON_PFN_SHIFT 12
-- 
2.21.0

