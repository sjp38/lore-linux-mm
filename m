Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBD1FC4CEC4
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 17:53:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7002E207FC
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 17:53:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mxVRZRFo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7002E207FC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 214E46B02ED; Wed, 18 Sep 2019 13:53:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 19F986B02EE; Wed, 18 Sep 2019 13:53:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08CDB6B02EF; Wed, 18 Sep 2019 13:53:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0149.hostedemail.com [216.40.44.149])
	by kanga.kvack.org (Postfix) with ESMTP id D3B286B02ED
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 13:53:46 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 833DE824377F
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 17:53:46 +0000 (UTC)
X-FDA: 75948789252.17.sleep14_20e4fb2173d4c
X-HE-Tag: sleep14_20e4fb2173d4c
X-Filterd-Recvd-Size: 8408
Received: from mail-ot1-f67.google.com (mail-ot1-f67.google.com [209.85.210.67])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 17:53:45 +0000 (UTC)
Received: by mail-ot1-f67.google.com with SMTP id y39so637783ota.7
        for <linux-mm@kvack.org>; Wed, 18 Sep 2019 10:53:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=a/jqoVnZMS4gCQHlsNMs0Wm0i9/bhDBfzuCMndLKGiI=;
        b=mxVRZRFofqB9VHPpnhAT0D2qY2vxDZ1aVOC8Ivg4ywPf0SoSqKkBkA0lErA+py0cOi
         Phoq68J5mWdb6Axadc87lebiz/yrt/Lt7XLsSf435rrSNrRmzw4YQitb5g4DJ43TmEfO
         bQWaa+eSzH50E0UlwKyPdM1f67Zbeu9B+6JNe0wyXmI+d8QFE0/ghL8e1hSSFe4ZelmR
         RtC37PGkriZyTxAS6cG+cJVCRG0tEqODfQEwbThwEPAk3D+9faNHzeAjTusBuL82Gk0b
         aYa6aDo58PZy43PBNx+jYufKFoA7j7I2A3YTfkK3efHTtU8DLE/ijZzPEqBgp0uBqJ8S
         7PxA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:from:to:cc:date:message-id:in-reply-to
         :references:user-agent:mime-version:content-transfer-encoding;
        bh=a/jqoVnZMS4gCQHlsNMs0Wm0i9/bhDBfzuCMndLKGiI=;
        b=huwUY8BGnnhGVxLssOqslfUFqUQzNKUnjfu1POnvknPYjfZ4AJFPlI+jDaTiZnVr6U
         WPSd9lkXTkuB7Abu8HJ3dEDYCPnMgs/GxNiA1lzD4BkkgLsJudv3q8rJMNioSbp3tuD1
         n0Gby1st8EtnsoSksB9HCC+Zse/+npWpJzKexgChzRVfkY0e+a5h6TjZjhSF8FH9hiAP
         ufWFU2/hdIby3jt/sU+FDTAfcigFm7ATxAmO/FF0EcTI3VOLd6WCRFOm0TOB69foi2Jj
         XCKOnyzLwIi/9cBy5KvT1rvueFJrzer2nhdnmi//8OR7rAa7WKNVQJSS9woW+mM9pvHU
         VXJQ==
X-Gm-Message-State: APjAAAVV+aQ0cLfimAcP1+ju5a79O1BdjiAYcEX08ZqqK9uaTPnURmht
	R/hdUjMTMa27NQOA8ofx7o8=
X-Google-Smtp-Source: APXvYqz0t5+ebI92vteMOWlqyFLfZiS195d+evCqucFxo/9o5+zuvvtyuNCeouoflWGA34VVfNklXQ==
X-Received: by 2002:a9d:2007:: with SMTP id n7mr3756897ota.132.1568829225129;
        Wed, 18 Sep 2019 10:53:45 -0700 (PDT)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id w201sm2029870oie.44.2019.09.18.10.53.42
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Sep 2019 10:53:44 -0700 (PDT)
Subject: [PATCH v10 QEMU 1/3] virtio-ballon: Implement support for page
 poison tracking feature
From: Alexander Duyck <alexander.duyck@gmail.com>
To: virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, mst@redhat.com,
 david@redhat.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org,
 willy@infradead.org, mhocko@kernel.org, linux-mm@kvack.org, vbabka@suse.cz,
 akpm@linux-foundation.org, mgorman@techsingularity.net,
 linux-arm-kernel@lists.infradead.org, osalvador@suse.de
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, konrad.wilk@oracle.com,
 nitesh@redhat.com, riel@surriel.com, lcapitulino@redhat.com,
 wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com,
 dan.j.williams@intel.com, alexander.h.duyck@linux.intel.com
Date: Wed, 18 Sep 2019 10:53:42 -0700
Message-ID: <20190918175342.23606.12400.stgit@localhost.localdomain>
In-Reply-To: <20190918175109.23474.67039.stgit@localhost.localdomain>
References: <20190918175109.23474.67039.stgit@localhost.localdomain>
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


