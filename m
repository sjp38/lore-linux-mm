Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A841C32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 22:43:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3E0DD21743
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 22:43:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WOIdiRpz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E0DD21743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B7CD06B0006; Wed,  7 Aug 2019 18:43:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B2D536B0007; Wed,  7 Aug 2019 18:43:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A1F0D6B0008; Wed,  7 Aug 2019 18:43:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6926D6B0006
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 18:43:14 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id d6so54216778pls.17
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 15:43:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=a/jqoVnZMS4gCQHlsNMs0Wm0i9/bhDBfzuCMndLKGiI=;
        b=nsjOFm97QamEoNUKVAvyZO1YaCZjzP+7/akYTxmmYdVNKQmKdbHrfSVkQ5fquPOmir
         pGURL5iGf2ZMjY3AZs+I9WKKkctucWsd2m9NI6zg/WHsj2V/iPPXRX+0HzZHM+RsAI2D
         ZgScdeEL5NhdBaG3x898lUhI2AY+MNrXGUHnZQPQ5i0CsjEPMAy0Ubs5VVoXdB/1xsoF
         QIx4qKqoo3PqIk2w8kh2PcEPTSOw+FHv7tpS0wt1AvMcBvzmvP1/gpwnvjDIFgSXInev
         Ywsm0Q8UCnB5AyIV/in6QY2xfRv322xAL7/b2zmlQoZZMQWIabdtXAZnMpdSOosIMxYO
         Z1CA==
X-Gm-Message-State: APjAAAXJ8ms/5s8Fdv8UCT1P9SZDYWczcLxpCKG9ZLJX1otG4bkIJFSL
	u0n5jyZx6f+S7/Mo3VzuVi1xA2Ko9bNd9uWqY3ehv4A+LEE56fRPbSV0I8hNZurKPFyHU0Hs1Lv
	gt5RAC3MSMUfBx1YQtgr8Rn8rHbujYpv8nugXLIUVkgG0ouIHVfetZ+Fshe2GwEWRnA==
X-Received: by 2002:a17:90a:bb0c:: with SMTP id u12mr747945pjr.132.1565217794029;
        Wed, 07 Aug 2019 15:43:14 -0700 (PDT)
X-Received: by 2002:a17:90a:bb0c:: with SMTP id u12mr747913pjr.132.1565217793080;
        Wed, 07 Aug 2019 15:43:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565217793; cv=none;
        d=google.com; s=arc-20160816;
        b=Y2Ju2bqt4spdviD+nJ4dnekPTqBxhDY7EuyZUoPLz8TMm1KDSLvfH2VaKQV4LUfVHx
         1ae8clD6ngY1YRUWvUlRxSlkJ1VIqEPDuMs02tbP8PlZFE/C01DbjrfbcSUKAYgNymNX
         j90W4pI8cXCD1H43RBaSIL4FkRhG5SVVUVvrXefn95ttMbkyWCgmCYn1uFV8O2usZ5HL
         oQZ4MTixMMbgyNzrxbc/n3mSdzBKXewu6UxZwKBJEHq3GjdqI4cic3L1anodLbQPOVM+
         LmgnZ1cKoOuiftbN9V8VgzYlUHPeKQh00vrGBeyH0RtEb026r+tZvZBfK2rXVH6gHO7t
         y0Ew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=a/jqoVnZMS4gCQHlsNMs0Wm0i9/bhDBfzuCMndLKGiI=;
        b=I1eAh3UPVc6QxLgjNmty4uJ2zgvwl5kV4q40AgF1OdgR/Cxd43srf/1DQUWw+4982d
         OWrN18UEW84zgTOJL6ezgLnYuLDJ7hXDyYqOjRHq0rVFNcW68OaKUxjhqQzIGsd3u8R/
         BNRQ/VoVdu/fHqIvc/P5WGtfu7+tsjufIeOiYfJQCPTLSJPt5CmZCknLZG33jB5fLIJ9
         R+SR+9D2qWpfRROCkKMS9/OZDZcKALd/RCHFr7KuMFCA3IppofbqDJtf6VK/dr54xPs9
         7w3KjtpIAI7VzZAs5uJKbRCG2NMIvp+CUjpA6FIpUcfVYvXIC7ryAVnkjmFc/aHbUzAP
         uqHg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WOIdiRpz;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x18sor65574493pgx.37.2019.08.07.15.43.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Aug 2019 15:43:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WOIdiRpz;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=a/jqoVnZMS4gCQHlsNMs0Wm0i9/bhDBfzuCMndLKGiI=;
        b=WOIdiRpzpQLi0sAzn1SPNDVNkN8LjQpkIK4ijw83aauhzUWPBC5Un+04ial6iGzD61
         QH/Yh4dz+9Dmxi9YShTkyea0TOjXT0Jkr/udRSNlnATLlGFSrCBkiMQJxFHtRGMGyGKS
         GYUlxTuyS0YBb3cVJYh9xXUYlmATcyc4Vg/Tv/FyAjhYETV9ZWH0reXiLKXQTrU5zWU5
         MdgU6GhGTT0gAvzqcZVTb7Qn3XkQComFoW0x70xBuCcNBEpTNqibQDTBnrXNdchU3o7F
         /8DMgCxywEmy0CObmnYGDobObHo9wmx/mH0AZVFQmEF2zJ8WCEUwm/ez4pxixr242qTK
         C0IQ==
X-Google-Smtp-Source: APXvYqy5ghMQ6jNho8kK7smwzBWo9R7gPVdHTpBtmsHpaVTXQBJT06A5pJZILQmeqAQH8c3YMPUAMQ==
X-Received: by 2002:a63:6ec1:: with SMTP id j184mr8328337pgc.232.1565217792536;
        Wed, 07 Aug 2019 15:43:12 -0700 (PDT)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id l17sm17500766pgj.44.2019.08.07.15.43.11
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 15:43:12 -0700 (PDT)
Subject: [PATCH v4 QEMU 1/3] virtio-ballon: Implement support for page
 poison tracking feature
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, willy@infradead.org, lcapitulino@redhat.com,
 wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com,
 dan.j.williams@intel.com, alexander.h.duyck@linux.intel.com
Date: Wed, 07 Aug 2019 15:43:11 -0700
Message-ID: <20190807224311.7333.70569.stgit@localhost.localdomain>
In-Reply-To: <20190807224037.6891.53512.stgit@localhost.localdomain>
References: <20190807224037.6891.53512.stgit@localhost.localdomain>
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

