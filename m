Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2379FC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 22:43:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA40C2080C
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 22:43:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NZxJbecw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA40C2080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7CF536B0003; Thu,  1 Aug 2019 18:43:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 77F556B0005; Thu,  1 Aug 2019 18:43:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 695AA6B0006; Thu,  1 Aug 2019 18:43:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 324BC6B0003
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 18:43:17 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i26so46663649pfo.22
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 15:43:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=a/jqoVnZMS4gCQHlsNMs0Wm0i9/bhDBfzuCMndLKGiI=;
        b=jH63Bll0LiakDNckm85gC+rMojhf7UprOVLGxPmoJfiW+p7P2/ydGLk0J5V4hIMq/s
         KMHnxb41OlzIIRCQKObhfef6WBrC1HxmD/N5jMY8aVXzvZTkYQBfTIF3Yto7dG116/3/
         H51X+G0JFfNzi7jxveQ7XGMeVRO0QrCl5Brz/cc+M85G1+xYI0G6stY4K+Aq8y/Lg/2f
         s41GL7j6c9p5KVFhdGQaOoRT1QG7WzrTpbuOu3ivOpUjUJjRgP5ojjVo2Kr8dw2jkkKU
         iaqpVgeyTFvOhskOK1IW1elVoGrVuHw6PhvywBEKGUMEvqLzNTCwx7xMoTW0PkFI7qar
         xVVA==
X-Gm-Message-State: APjAAAW73l8N7Kzebm6+as+jpPy0bVqHW0spwiIuyCnujM8CwnQ9eX7Q
	c0rYcH2mkemndTPo1EJSfj9Ig08FyGjlHUdEbbzn9GVEhp+ZGDbPM3KXUaeoG3jf2u0xSr/jE6C
	SNPhNNkomCz+xrGvzh5LSUqmRxdE6lrzQiKVkrDKYtG/dRdiOUOulZsahUPlyCioccg==
X-Received: by 2002:aa7:8705:: with SMTP id b5mr3280078pfo.27.1564699396848;
        Thu, 01 Aug 2019 15:43:16 -0700 (PDT)
X-Received: by 2002:aa7:8705:: with SMTP id b5mr3280017pfo.27.1564699396037;
        Thu, 01 Aug 2019 15:43:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564699396; cv=none;
        d=google.com; s=arc-20160816;
        b=qRbIcxb0rGE0T/txJZ1VrIvL9hnAJezJwLPv3OuX1cDAxf93Rls465NZc07H7C4d/q
         s05co3hT+63aWsz6d0j0ZVjlCtdbkaYKfEAH4ne0o/aaTST0JG1vK6EJvefshunIyeke
         GFuxtYNRAKJ4agK6YYXlf3W9vibxAfkv008QQ2BwwSUmxsjQVbxrlzeAHMSJ7wdvrbOE
         EcyX1V8uvKtqJvN+R7W4wbz4Tp/xgHd3WVFU3ctTH2V23t2pq9YgRXPSpAToZcmKi+jW
         WEhXqNDgwRoZFw2QqtGG8lliOsFigB3vL2dPmqS78TUsvD9FISvQCYyYfU4NqXHlM/wR
         vi/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=a/jqoVnZMS4gCQHlsNMs0Wm0i9/bhDBfzuCMndLKGiI=;
        b=kYBmCwXS4ahsh+dpQmLYQzuDK1hWoBvSu71DB6DQ0FGJRNV5INWZG34jeYKYIhHS9W
         SfzbBZTIO5hoBt8XA/oblxFrlXUQXFxxn7BB6HkG65w9zOGtzobEt+jX/qB56qR1TGak
         6kX6YuBUyQE+zXURngFG5Dp707EtDtCdAeEu0TerYuSR3xXy4Dti+kKyTkg27RO9ETEj
         PS5JFumINyWAGkY2Jm0q7gajQsxzxv2yGteX/NlXmc3lq68wg4KqwRbfSFe2uLPuVYjQ
         GNMXGMWdyfb9M4aXE9v11Rn95CXas0SVWxecswjoJ+hNL4Ji9hHo6+ToRrU25haF2sRt
         XT7w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NZxJbecw;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s138sor29072600pfc.44.2019.08.01.15.43.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 15:43:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NZxJbecw;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=a/jqoVnZMS4gCQHlsNMs0Wm0i9/bhDBfzuCMndLKGiI=;
        b=NZxJbecwhsIRKAn7eTc+DEWg5Y73G1yfBpYfTgoTLj8uI430qQIWPf10i2RoOhFOEM
         K8s8te0tZX6GiAk7J6xt9n53Vx8l2tHByIvKeFp1u6mjdP6+CETi9j1HazLfHNtMc6eH
         VBQBrLk1u4q/6cvecxbda6RZqN85ILzhHl2209VVRYknXehPkppSaaPPWFvMCqW/ytZ5
         ByPdU2snob67LZhf3oPJywHM6b1TJsX9O1t5FRK8sTKgA9nY37Z9fjisjPcfI0O2xEZT
         pD/i7OGIux0iSaaqYyOJyGgm4y2fH9QVmE0oMxOJhFwZEcJztwOGUuwZtFVjwWKf2tEX
         Yf6w==
X-Google-Smtp-Source: APXvYqwiVWmnhoDrq1Jrz/xXQN53b06Pcnek1E3BC3T6NIZ9i646fPk8RQ021fFAFPi8Y0XxndForA==
X-Received: by 2002:a62:ae02:: with SMTP id q2mr54784607pff.1.1564699395583;
        Thu, 01 Aug 2019 15:43:15 -0700 (PDT)
Received: from localhost.localdomain (50-39-177-61.bvtn.or.frontiernet.net. [50.39.177.61])
        by smtp.gmail.com with ESMTPSA id b6sm63677178pgq.26.2019.08.01.15.43.14
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 15:43:15 -0700 (PDT)
Subject: [PATCH v3 QEMU 1/2] virtio-ballon: Implement support for page
 poison tracking feature
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, willy@infradead.org, lcapitulino@redhat.com,
 wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com,
 dan.j.williams@intel.com, alexander.h.duyck@linux.intel.com
Date: Thu, 01 Aug 2019 15:41:04 -0700
Message-ID: <20190801224104.24744.18563.stgit@localhost.localdomain>
In-Reply-To: <20190801222158.22190.96964.stgit@localhost.localdomain>
References: <20190801222158.22190.96964.stgit@localhost.localdomain>
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

We need to make certain to advertise support for page poison tracking if
we want to actually get data on if the guest will be poisoning pages. So
if free page hinting is active we should add page poisoning support and
let the guest disable it if it isn't using it.

Page poisoning will result in a page being dirtied on free. As such we
cannot really avoid having to copy the page at least one more time since
we will need to write the poison value to the destination. As such we can
just ignore free page hinting if page poisoning is enabled as it will
actually reduce the work we have to do.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 hw/virtio/virtio-balloon.c         |   25 +++++++++++++++++++++----
 include/hw/virtio/virtio-balloon.h |    1 +
 2 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/hw/virtio/virtio-balloon.c b/hw/virtio/virtio-balloon.c
index 25de15430710..003b3ebcfdfb 100644
--- a/hw/virtio/virtio-balloon.c
+++ b/hw/virtio/virtio-balloon.c
@@ -530,6 +530,15 @@ static void virtio_balloon_free_page_start(VirtIOBalloon *s)
         return;
     }
 
+    /*
+     * If page poisoning is enabled then we probably shouldn't bother with
+     * the hinting since the poisoning will dirty the page and invalidate
+     * the work we are doing anyway.
+     */
+    if (virtio_vdev_has_feature(vdev, VIRTIO_BALLOON_F_PAGE_POISON)) {
+        return;
+    }
+
     if (s->free_page_report_cmd_id == UINT_MAX) {
         s->free_page_report_cmd_id =
                        VIRTIO_BALLOON_FREE_PAGE_REPORT_CMD_ID_MIN;
@@ -617,12 +626,10 @@ static size_t virtio_balloon_config_size(VirtIOBalloon *s)
     if (s->qemu_4_0_config_size) {
         return sizeof(struct virtio_balloon_config);
     }
-    if (virtio_has_feature(features, VIRTIO_BALLOON_F_PAGE_POISON)) {
+    if (virtio_has_feature(features, VIRTIO_BALLOON_F_PAGE_POISON) ||
+        virtio_has_feature(features, VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
         return sizeof(struct virtio_balloon_config);
     }
-    if (virtio_has_feature(features, VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
-        return offsetof(struct virtio_balloon_config, poison_val);
-    }
     return offsetof(struct virtio_balloon_config, free_page_report_cmd_id);
 }
 
@@ -633,6 +640,7 @@ static void virtio_balloon_get_config(VirtIODevice *vdev, uint8_t *config_data)
 
     config.num_pages = cpu_to_le32(dev->num_pages);
     config.actual = cpu_to_le32(dev->actual);
+    config.poison_val = cpu_to_le32(dev->poison_val);
 
     if (dev->free_page_report_status == FREE_PAGE_REPORT_S_REQUESTED) {
         config.free_page_report_cmd_id =
@@ -696,6 +704,8 @@ static void virtio_balloon_set_config(VirtIODevice *vdev,
         qapi_event_send_balloon_change(vm_ram_size -
                         ((ram_addr_t) dev->actual << VIRTIO_BALLOON_PFN_SHIFT));
     }
+    dev->poison_val = virtio_vdev_has_feature(vdev, VIRTIO_BALLOON_F_PAGE_POISON) ? 
+                      le32_to_cpu(config.poison_val) : 0;
     trace_virtio_balloon_set_config(dev->actual, oldactual);
 }
 
@@ -705,6 +715,9 @@ static uint64_t virtio_balloon_get_features(VirtIODevice *vdev, uint64_t f,
     VirtIOBalloon *dev = VIRTIO_BALLOON(vdev);
     f |= dev->host_features;
     virtio_add_feature(&f, VIRTIO_BALLOON_F_STATS_VQ);
+    if (virtio_has_feature(f, VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
+        virtio_add_feature(&f, VIRTIO_BALLOON_F_PAGE_POISON);
+    }
 
     return f;
 }
@@ -846,6 +859,8 @@ static void virtio_balloon_device_reset(VirtIODevice *vdev)
         g_free(s->stats_vq_elem);
         s->stats_vq_elem = NULL;
     }
+
+    s->poison_val = 0;
 }
 
 static void virtio_balloon_set_status(VirtIODevice *vdev, uint8_t status)
@@ -908,6 +923,8 @@ static Property virtio_balloon_properties[] = {
                     VIRTIO_BALLOON_F_DEFLATE_ON_OOM, false),
     DEFINE_PROP_BIT("free-page-hint", VirtIOBalloon, host_features,
                     VIRTIO_BALLOON_F_FREE_PAGE_HINT, false),
+    DEFINE_PROP_BIT("x-page-poison", VirtIOBalloon, host_features,
+                    VIRTIO_BALLOON_F_PAGE_POISON, false),
     /* QEMU 4.0 accidentally changed the config size even when free-page-hint
      * is disabled, resulting in QEMU 3.1 migration incompatibility.  This
      * property retains this quirk for QEMU 4.1 machine types.
diff --git a/include/hw/virtio/virtio-balloon.h b/include/hw/virtio/virtio-balloon.h
index d1c968d2376e..7fe78e5c14d7 100644
--- a/include/hw/virtio/virtio-balloon.h
+++ b/include/hw/virtio/virtio-balloon.h
@@ -70,6 +70,7 @@ typedef struct VirtIOBalloon {
     uint32_t host_features;
 
     bool qemu_4_0_config_size;
+    uint32_t poison_val;
 } VirtIOBalloon;
 
 #endif

