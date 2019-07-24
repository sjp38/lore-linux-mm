Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9AE8FC7618F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 17:14:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5421421911
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 17:14:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="aySNiRYG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5421421911
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CEC558E0009; Wed, 24 Jul 2019 13:14:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C9D718E0005; Wed, 24 Jul 2019 13:14:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B63E18E0009; Wed, 24 Jul 2019 13:14:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 97E638E0005
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 13:14:20 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id x17so51380733iog.8
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 10:14:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=ZIoj43NJHCuwdBLKiuQJ9FmxjncTWPcR2MlEt+h7o+U=;
        b=o+Ux3/mGr4u5ZrbkGBXc/gtZnWK8N/0oaMfo2JSS6TlHCy6NwGocqXTjrGy5loFT4W
         sYBTKDl9fnjCBEqCsJ3SZF2e37UWCtLjxD96hWeXuSlz9awig7m6kM6ZgKn51WS3gCLY
         RGUBx4xtxUQt6AFgaRm6q9A6gEUOqMlBJrbimEfaSMWHlIcOk8zx3Cf4zh2SxlXDch9Y
         QuMy/yZT1EZ8/YivcJ3FTmknfRq9CVX4PyvTQmDed4GQEMAcLRQ9wDSfaWosamiwjfrF
         4J3mZvT+5NDQ2992aKcHY4gRhDLv3V8Ig6Krkjk1sJiOT10fyb9q7wNSW3SxgMsV6fJu
         LIrw==
X-Gm-Message-State: APjAAAUqVJQK0VZm3OR6ShSzs+kHhgoFmD1fH0bnHU4C+ts7ziqDahmF
	QrN7HtRTpgH6CAOZ/faffab1To+wkwVhZ0b+tlYrdqq2I7XJ6PwzFn/dWa3toZuKDPw0gvE3whx
	5el4/Kuxuz/ZwegtoiYOuyrEQ62ZHXUuEFPgmHtiHqVTDOPvCg/kv8lv2SDrepwMAaA==
X-Received: by 2002:a5d:87d6:: with SMTP id q22mr26632719ios.2.1563988460386;
        Wed, 24 Jul 2019 10:14:20 -0700 (PDT)
X-Received: by 2002:a5d:87d6:: with SMTP id q22mr26632660ios.2.1563988459658;
        Wed, 24 Jul 2019 10:14:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563988459; cv=none;
        d=google.com; s=arc-20160816;
        b=SQPjoveBBHo9/aHL9AYHGZGzfCZzOwd39ibyMsA4fQm6wQbVnhZd2Yw5oDYhcaHYp2
         iZkjeuPcAQBnrjBDR2PNCnMlPRPmNRyr+qKfLHIPZda2DPUkyO+etilv/hVK6MVZYG1N
         28Lwu+2UAFSxFnTpK+EzioAxoFpqYLFtgg2/wgiAlwL4y/A+GZ0Sal5BRWN56tOzWjKb
         +RQjMlKmZM/dHYE94iuaW3XvIh3NHKkMGk39+lJhqpeR4Gny54IcXGhS9pFlbx8kU0Pw
         8pNiQmm5hrm8W5VHIc4emC1icam80Ep8RVCrh4B82WApr9YFmYz50mlFf+L5txLPMdk1
         YTDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=ZIoj43NJHCuwdBLKiuQJ9FmxjncTWPcR2MlEt+h7o+U=;
        b=FuC7p/zsjKi/FkdYDqWgzIYV0L/uauqV2NPit8I2s1vjfm1f2SaZ/yqWXVMZPtA0Zd
         0vwIDmd6n2Sr1Jrb75xYMpZ2BgiQCa1PEnt+08mc3xZD1piBfI6+/mlrRD5p4aAPDK14
         lk1I1RH4KtufxQJIYgctO0e/sTQlJ+IJqJvDG8i3DHbXHfJuiqF67SZSLe4s0lFqUS+z
         lZcvyJ6k5QsKI1n+UfSDsT9O6XfTGmXKOOunXKYIV1QduS4qX21cdmJDm8n8Y4ottLRn
         ml6qMgvH77FMWB22o2hBkvlIYaHFWwZAByU88g9kmMcVkVYtk642ZgwUAsff58NMWXxk
         JjYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=aySNiRYG;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t11sor32024597iob.106.2019.07.24.10.14.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 10:14:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=aySNiRYG;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=ZIoj43NJHCuwdBLKiuQJ9FmxjncTWPcR2MlEt+h7o+U=;
        b=aySNiRYGFQc24x/Bc4iiG2Y8mXw+zOLMrDHCOA4vJM3jewhUf7oe5Txqi/cuNz8M3A
         9vC2fiueKfH9qGdmx3juwgOWXXcyypi9q8eMRv66hGnJRJ1PEt77uS7qmkddIWcKHYCW
         oCfrkvvDIAWj9jlewYnAsSo7AvQ5JWS7/Tu4y0mAgc6+76ATQO47+pWzNqMO/Zwuety5
         Qcr+LZLZo+l9B5D/ltvl0geoeTlAU6GvF5oA0ckB31hR2jfsAry1miFRntQGyiHHr8E2
         Qm5wk/Vd2wJ0vVtr1OqnHkKSjYl/+xaMjM3cfDoFYTCOjj4FdZDRQU62nXEyF1x7i5ax
         XjUQ==
X-Google-Smtp-Source: APXvYqzh3UDl4qShBdx52TKjsvLqQYDrV3cwS9+g5wM2wuTj8B9iWvID3doGQP/xGnP2TWfmTYT7hQ==
X-Received: by 2002:a6b:790d:: with SMTP id i13mr2316801iop.27.1563988459273;
        Wed, 24 Jul 2019 10:14:19 -0700 (PDT)
Received: from localhost.localdomain (50-39-177-61.bvtn.or.frontiernet.net. [50.39.177.61])
        by smtp.gmail.com with ESMTPSA id b8sm38193847ioj.16.2019.07.24.10.14.17
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 10:14:18 -0700 (PDT)
Subject: [PATCH v2 QEMU] virtio-balloon: Provide a interface for "bubble
 hinting"
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
Date: Wed, 24 Jul 2019 10:12:10 -0700
Message-ID: <20190724171050.7888.62199.stgit@localhost.localdomain>
In-Reply-To: <20190724165158.6685.87228.stgit@localhost.localdomain>
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
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
 hw/virtio/virtio-balloon.c                      |   40 +++++++++++++++++++++++
 include/hw/virtio/virtio-balloon.h              |    2 +
 include/standard-headers/linux/virtio_balloon.h |    1 +
 3 files changed, 42 insertions(+), 1 deletion(-)

diff --git a/hw/virtio/virtio-balloon.c b/hw/virtio/virtio-balloon.c
index 2112874055fb..70c0004c0f88 100644
--- a/hw/virtio/virtio-balloon.c
+++ b/hw/virtio/virtio-balloon.c
@@ -328,6 +328,39 @@ static void balloon_stats_set_poll_interval(Object *obj, Visitor *v,
     balloon_stats_change_timer(s, 0);
 }
 
+static void virtio_bubble_handle_output(VirtIODevice *vdev, VirtQueue *vq)
+{
+    VirtQueueElement *elem;
+
+    while ((elem = virtqueue_pop(vq, sizeof(VirtQueueElement)))) {
+    	unsigned int i;
+
+        for (i = 0; i < elem->in_num; i++) {
+            void *addr = elem->in_sg[i].iov_base;
+            size_t size = elem->in_sg[i].iov_len;
+            ram_addr_t ram_offset;
+            size_t rb_page_size;
+            RAMBlock *rb;
+
+            if (qemu_balloon_is_inhibited())
+                continue;
+
+            rb = qemu_ram_block_from_host(addr, false, &ram_offset);
+            rb_page_size = qemu_ram_pagesize(rb);
+
+            /* For now we will simply ignore unaligned memory regions */
+            if ((ram_offset | size) & (rb_page_size - 1))
+                continue;
+
+            ram_block_discard_range(rb, ram_offset, size);
+        }
+
+        virtqueue_push(vq, elem, 0);
+        virtio_notify(vdev, vq);
+        g_free(elem);
+    }
+}
+
 static void virtio_balloon_handle_output(VirtIODevice *vdev, VirtQueue *vq)
 {
     VirtIOBalloon *s = VIRTIO_BALLOON(vdev);
@@ -782,6 +815,11 @@ static void virtio_balloon_device_realize(DeviceState *dev, Error **errp)
     s->svq = virtio_add_queue(vdev, 128, virtio_balloon_receive_stats);
 
     if (virtio_has_feature(s->host_features,
+                           VIRTIO_BALLOON_F_HINTING)) {
+        s->hvq = virtio_add_queue(vdev, 128, virtio_bubble_handle_output);
+    }
+
+    if (virtio_has_feature(s->host_features,
                            VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
         s->free_page_vq = virtio_add_queue(vdev, VIRTQUEUE_MAX_SIZE,
                                            virtio_balloon_handle_free_page_vq);
@@ -897,6 +935,8 @@ static Property virtio_balloon_properties[] = {
                     VIRTIO_BALLOON_F_DEFLATE_ON_OOM, false),
     DEFINE_PROP_BIT("free-page-hint", VirtIOBalloon, host_features,
                     VIRTIO_BALLOON_F_FREE_PAGE_HINT, false),
+    DEFINE_PROP_BIT("guest-page-hinting", VirtIOBalloon, host_features,
+                    VIRTIO_BALLOON_F_HINTING, true),
     DEFINE_PROP_LINK("iothread", VirtIOBalloon, iothread, TYPE_IOTHREAD,
                      IOThread *),
     DEFINE_PROP_END_OF_LIST(),
diff --git a/include/hw/virtio/virtio-balloon.h b/include/hw/virtio/virtio-balloon.h
index 1afafb12f6bc..a58b24fdf29d 100644
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

