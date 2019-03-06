Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D494AC43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:52:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 80C8E20684
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:52:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 80C8E20684
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 24C548E001F; Wed,  6 Mar 2019 10:52:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D6478E0015; Wed,  6 Mar 2019 10:52:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 09EC58E001F; Wed,  6 Mar 2019 10:52:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id CFD7F8E0015
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 10:52:42 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id 203so10143331qke.7
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 07:52:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=JiW1DshD3jPhWd4ff8xKJyYancTHEzbJFr24dtVc7Mo=;
        b=UKtpKkQNLa4i9LPSs9ZCSueisBbnzvdnGtfHhgLxHdfTlzOqEPDRn7eV0gK4lvthDl
         gkddMiaLPc6D4jrnCmKE5KYT5S2kv7f7rM6ufucHzIDzm2yhmXnpKqn1Uiy4PuX0HPuV
         TKqbE3z5qYCXTCFwleYxhbDUMZBB8DAqboJDigGozb3bcmhl3hycY07tnD1wAOrrf0f/
         TcUo8G8M46b8RCilXo5FrKipZ71NCE44QObHxCtSs/iCGSMNKVA8+v3pgdTjvYfBKK7n
         3w00rVU1KsnRK+p700MdWCaJoJnvmnhoAoJVD4qHB+T8UQ5SOVk5OomhggjtIn3RJvkX
         5HHg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVRxYDCMdOaKqdJqvQi+Kvl5/ZYIwroe6c1s/4qg8ZlwLsRku/z
	3bVoOB1MlmMnYrPEMjhRrdCvi+7wDJo5hFK3kAONtALEs5sLYxvIPciXn1HFrX/cLTsCcqxemuF
	QJJeBttCu9gWn8NlKhndiW0Wiizm4ldr6ZPTcnDivoci0dBka4zJsarZFRPvdTRLaaQ==
X-Received: by 2002:ac8:38b3:: with SMTP id f48mr6362546qtc.125.1551887562599;
        Wed, 06 Mar 2019 07:52:42 -0800 (PST)
X-Google-Smtp-Source: APXvYqzbv7bD9IySHQiff390xFDa+hEI/tvci6s5ufIX4q2OEjcZZqi8xcmOzm8eXMmdbxnxUJfn
X-Received: by 2002:ac8:38b3:: with SMTP id f48mr6362449qtc.125.1551887561137;
        Wed, 06 Mar 2019 07:52:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551887561; cv=none;
        d=google.com; s=arc-20160816;
        b=JDGtUTSaYhGoJIdNHxuMqgGl/kod9JEiOAmuldYfDp9IsK0V2/Z+iDFsbbsU79xFpq
         Z1iKlUTHfBcTecbNWiUxGI/ZACeEy2vp7nF/lV7IwVVnzd3cXdFODnb+bnGcgdNUmHkP
         bZC6i5sSlzY53ASSwXG80twQEAP4GP8p7oU5AyzVAR8x9mYZApGwl9jLjsqWCdl45MzX
         9BL+X50bolcn/TukCJdxXdaq4XNtFBbWCqXCDWzwyg1UN+CUMdwUZSlYfi/NWRUhNO+w
         lUDMlAZ6wEzEMMK8AqGZawhXG92meynrjvYS0OL9vfrGZ5DvWWSFKR+y/FxP3MMhBeU9
         E4og==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=JiW1DshD3jPhWd4ff8xKJyYancTHEzbJFr24dtVc7Mo=;
        b=DyaHMLkN/M/robefJJ423hzTYTZesxlPV7PAGsU5uP7uklqM8Ppnv4+OCJFx384XA+
         QdAdAE8v7ZVxR+/F4farwRJy5hcDlQ2oSjkR3j/JUufQm6s1XSWJM5lkSv7R8ji7xKL0
         ObhUbVK3o8Onk5eT2owuSo4OJDnNNT7qQYnJ1eBJzQ1GRgt4YzYFkr7+y4R9NFlt5a6j
         iZqmpzS+MedCt8MPP2btGjhuMrgHPXXIkvPADy5SR8HoE76Y39tqLSshWzX3CvQ187Jn
         tgbngNJlRc/6fyNXYWGwL+KlVdLmc7kEj4pdFuoMDEfMra0n3RnxJ+OnnXLfXunvmAcf
         a5TQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n21si516952qki.15.2019.03.06.07.52.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 07:52:41 -0800 (PST)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 34F0AE6A74;
	Wed,  6 Mar 2019 15:52:40 +0000 (UTC)
Received: from virtlab420.virt.lab.eng.bos.redhat.com (virtlab420.virt.lab.eng.bos.redhat.com [10.19.152.148])
	by smtp.corp.redhat.com (Postfix) with ESMTP id DBE1960139;
	Wed,  6 Mar 2019 15:52:29 +0000 (UTC)
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
Cc: Nitesh Narayan Lal <nitesh@redhat.com>
Subject: [RFC][QEMU Patch] KVM: Enable QEMU to free the pages hinted by the guest
Date: Wed,  6 Mar 2019 10:52:20 -0500
Message-Id: <20190306155220.12944-1-nitesh@redhat.com>
In-Reply-To: <20190306155048.12868-1-nitesh@redhat.com>
References: <20190306155048.12868-1-nitesh@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Wed, 06 Mar 2019 15:52:40 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch enables QEMU to perform MADVISE_DONTNEED on the pages
reported by the guest.

Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>
---
 hw/virtio/trace-events                        |  1 +
 hw/virtio/virtio-balloon.c                    | 90 +++++++++++++++++++
 include/hw/virtio/virtio-balloon.h            |  2 +-
 .../standard-headers/linux/virtio_balloon.h   |  1 +
 4 files changed, 93 insertions(+), 1 deletion(-)

diff --git a/hw/virtio/trace-events b/hw/virtio/trace-events
index 07bcbe9e85..e3ab66f126 100644
--- a/hw/virtio/trace-events
+++ b/hw/virtio/trace-events
@@ -46,3 +46,4 @@ virtio_balloon_handle_output(const char *name, uint64_t gpa) "section name: %s g
 virtio_balloon_get_config(uint32_t num_pages, uint32_t actual) "num_pages: %d actual: %d"
 virtio_balloon_set_config(uint32_t actual, uint32_t oldactual) "actual: %d oldactual: %d"
 virtio_balloon_to_target(uint64_t target, uint32_t num_pages) "balloon target: 0x%"PRIx64" num_pages: %d"
+virtio_balloon_hinting_request(unsigned long pfn, unsigned int num_pages) "Guest page hinting request: %lu num_pages: %d"
diff --git a/hw/virtio/virtio-balloon.c b/hw/virtio/virtio-balloon.c
index a12677d4d5..7ab1471017 100644
--- a/hw/virtio/virtio-balloon.c
+++ b/hw/virtio/virtio-balloon.c
@@ -33,6 +33,13 @@
 
 #define BALLOON_PAGE_SIZE  (1 << VIRTIO_BALLOON_PFN_SHIFT)
 
+struct guest_pages {
+	unsigned long pfn;
+	unsigned int order;
+};
+
+void page_hinting_request(uint64_t addr, uint32_t len);
+
 static void balloon_page(void *addr, int deflate)
 {
     if (!qemu_balloon_is_inhibited()) {
@@ -207,6 +214,85 @@ static void balloon_stats_set_poll_interval(Object *obj, Visitor *v,
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
+    unsigned long pfn, pfn_end;
+    uint64_t gpaddr_to_free;
+    void * temp_addr = gpa2hva(&mr, addr, &local_err);
+
+    if (local_err) {
+        error_report_err(local_err);
+        return;
+    }
+    guest_obj = temp_addr;
+    while (i < len) {
+        pfn = guest_obj[i].pfn;
+	pfn_end = guest_obj[i].pfn + (1 << guest_obj[i].order) - 1;
+	trace_virtio_balloon_hinting_request(pfn,(1 << guest_obj[i].order));
+	while (pfn <= pfn_end) {
+	        gpaddr_to_free = pfn << VIRTIO_BALLOON_PFN_SHIFT;
+	        hvaddr_to_free = gpa2hva(&mr, gpaddr_to_free, &local_err);
+	        if (local_err) {
+			error_report_err(local_err);
+		        return;
+		}
+		ret = qemu_madvise((void *)hvaddr_to_free, 4096, QEMU_MADV_DONTNEED);
+		if (ret == -1)
+		    printf("\n%d:%s Error: Madvise failed with error:%d\n", __LINE__, __func__, ret);
+		pfn++;
+	}
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
+    page_hinting_request(temp_addr, temp_len);
+    virtqueue_push(vq, elem, t_size);
+    virtio_notify(vdev, vq);
+    g_free(elem);
+}
+
 static void virtio_balloon_handle_output(VirtIODevice *vdev, VirtQueue *vq)
 {
     VirtIOBalloon *s = VIRTIO_BALLOON(vdev);
@@ -376,6 +462,7 @@ static uint64_t virtio_balloon_get_features(VirtIODevice *vdev, uint64_t f,
     VirtIOBalloon *dev = VIRTIO_BALLOON(vdev);
     f |= dev->host_features;
     virtio_add_feature(&f, VIRTIO_BALLOON_F_STATS_VQ);
+    virtio_add_feature(&f, VIRTIO_BALLOON_F_HINTING);
     return f;
 }
 
@@ -445,6 +532,7 @@ static void virtio_balloon_device_realize(DeviceState *dev, Error **errp)
     s->ivq = virtio_add_queue(vdev, 128, virtio_balloon_handle_output);
     s->dvq = virtio_add_queue(vdev, 128, virtio_balloon_handle_output);
     s->svq = virtio_add_queue(vdev, 128, virtio_balloon_receive_stats);
+    s->hvq = virtio_add_queue(vdev, 128, virtio_balloon_page_hinting);
 
     reset_stats(s);
 }
@@ -488,6 +576,8 @@ static void virtio_balloon_instance_init(Object *obj)
 
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
2.17.2

