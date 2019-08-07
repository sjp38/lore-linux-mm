Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9D29C433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 22:43:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 602AF217D9
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 22:43:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mL9CoipY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 602AF217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 11BD66B0008; Wed,  7 Aug 2019 18:43:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0CD556B000A; Wed,  7 Aug 2019 18:43:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F26196B000D; Wed,  7 Aug 2019 18:43:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id BDE7A6B0008
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 18:43:26 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id h5so56468734pgq.23
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 15:43:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=R9EIePxtKgh7rutMNGBvqWvR/nyIQIv1yBQVlI6lc80=;
        b=rFO+vemmWn3maA0OXMlj+TyszWf56bVkr273fhWvhheB4kQMFUMYxjXQ0WtkXGttfh
         m1z7YGCXFoX+kSBiwgRVb7KXd+DqKqTn447JWZV6dVUxlZc9kBXeSOnQr2caZX4LgZm4
         kDuSJ1/M0z7AaTPSXrflOZ92Ha9EF5ofyDLRnir87mzNQol3AYW+/jEekQV4Gl7jkf5p
         oC1ZW1/rUlNbg+SvkIQQPcMmTmzVUKp69GKfHpQFfyNHBJBWLyYTuZ1M//GPuo3g8LqC
         YhpfSovMH3PU/nE2dvzxDWqu73OSvlN1qsGsrQHxZS9pfsQcl5HzXsEH4c4zAJ2urjJM
         PTRA==
X-Gm-Message-State: APjAAAUfg3NaEbJlpKVha/upLy7/D0RSHxFVFsqRBorOWjinmaIl7o9O
	Pr2zRajdbZ7FrGYCk7HK85Jvf+MwKJ+ozxG2WX1Ws2D40CucePzSqZfyEkAiFyNFLZF9fPcEoZE
	PdOkZoAZCFm87yZATA+8LO3cIgIbv263h3OnuiwCJ4idX8nv/8p15pBPNrgwktPKtUw==
X-Received: by 2002:a65:4b89:: with SMTP id t9mr9562196pgq.55.1565217806170;
        Wed, 07 Aug 2019 15:43:26 -0700 (PDT)
X-Received: by 2002:a65:4b89:: with SMTP id t9mr9562163pgq.55.1565217805252;
        Wed, 07 Aug 2019 15:43:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565217805; cv=none;
        d=google.com; s=arc-20160816;
        b=UKbLypT08DYg64f1DIDmaWP2td5ggKeOZPycQlVIWrGh/wkJU/RQZujECbP7aKVk3X
         MLxaf0fAu7BhFQRootjj5IYaPOgdnb7JHbLk/SC6MVv1o8PUsJZY1xPPfyCp30du8+oi
         HYCRPGnOp4tMatxhT9bFjCGyKS0Y7kkOmV3KbYiik71vjFMQ89v0ivf+6iUFj6WbHS8M
         0SUirBjbtMdaXR9hLFfTHMA7f+npwYSg1zgFJbcpT6+LzneQop1pXyCiNLl5OyZlmHse
         LgOQ5wMNNi9hfekEhCVtUQHvlVEh+YYxnlYZXrkvzwQekPSVYslllrTeiuo3ZxUG6JfB
         3clw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=R9EIePxtKgh7rutMNGBvqWvR/nyIQIv1yBQVlI6lc80=;
        b=PeE7wtjluzqxwWvyVdYVKS8Nl7pJGT7c+qjynW46iDandVXaFl263GQylBYoKXlX/6
         GZW0TGrl34sgSkz+m7mKS55YOrirsvBf/SVOby9U66rBSU9m4Qt0kW6iNIexhFuNUQ3l
         yiC5I8fskfVij54JA5rN7pdxn0tea6nSdG4uVujhLaxzF+MuNgIUvJNLTEs8Um5mLSSW
         QBKdN5y9V4/3PFu2MaqMUH70Og85bz79IGKF8YHlEdKuok82uZZHjGn/9aDom0guPv8I
         0UVxj3GSlI4xvr0/f81uj2GMYug+9b8PrXiGQmgAMbzplr4Bqy1f9ZMPd0PoUvk+P1jS
         LDEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mL9CoipY;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v10sor109796920plg.28.2019.08.07.15.43.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Aug 2019 15:43:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mL9CoipY;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=R9EIePxtKgh7rutMNGBvqWvR/nyIQIv1yBQVlI6lc80=;
        b=mL9CoipYppYg9TvgaxvW3rlAJ3cRgHGNuMlvCCVxbFer5O88XcNEYdHLJUlBnTbmcS
         D/ddFTZlvnguCqCjBdBZojggBwQK+k4JAC6YJiDQvHJDhO06ebhFIn32qxshi0LUy1+9
         Q0Ows9tRakkUSbaQRO6KpylgPFrCPMuO07wxB1COscKMaI+XtA0OH+cZFiVNe9dib6gm
         NgU6IOL7XT9bjhTmkGvJFh2Db0VsELCYdDlsJiAQgp+5VECNKpiAyTKsm16d3r5Iw0nq
         3Ydx9X+Nkoy3/I1P2Mu70YRQgBmsBxk+5WIJsajIoHRW1MiyIuhr+3mzskgQR1lJWrD0
         3vKw==
X-Google-Smtp-Source: APXvYqzt2235UK45pP6zV7IF86Iz17ZaDjI4fbCSaevrbzSonGjf1QqChod57+61jhscibCu/vVY4w==
X-Received: by 2002:a17:902:b212:: with SMTP id t18mr3980622plr.246.1565217804789;
        Wed, 07 Aug 2019 15:43:24 -0700 (PDT)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id x67sm96679320pfb.21.2019.08.07.15.43.24
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 15:43:24 -0700 (PDT)
Subject: [PATCH v4 QEMU 3/3] virtio-balloon: Provide a interface for unused
 page reporting
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, willy@infradead.org, lcapitulino@redhat.com,
 wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com,
 dan.j.williams@intel.com, alexander.h.duyck@linux.intel.com
Date: Wed, 07 Aug 2019 15:43:23 -0700
Message-ID: <20190807224323.7333.15220.stgit@localhost.localdomain>
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

Add support for what I am referring to as "unused page reporting".
Basically the idea is to function very similar to how the balloon works
in that we basically end up madvising the page as not being used. However
we don't really need to bother with any deflate type logic since the page
will be faulted back into the guest when it is read or written to.

This is meant to be a simplification of the existing balloon interface
to use for providing hints to what memory needs to be freed. I am assuming
this is safe to do as the deflate logic does not actually appear to do very
much other than tracking what subpages have been released and which ones
haven't.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 hw/virtio/virtio-balloon.c         |   46 ++++++++++++++++++++++++++++++++++--
 include/hw/virtio/virtio-balloon.h |    2 +-
 2 files changed, 45 insertions(+), 3 deletions(-)

diff --git a/hw/virtio/virtio-balloon.c b/hw/virtio/virtio-balloon.c
index 003b3ebcfdfb..7a30df63bc77 100644
--- a/hw/virtio/virtio-balloon.c
+++ b/hw/virtio/virtio-balloon.c
@@ -320,6 +320,40 @@ static void balloon_stats_set_poll_interval(Object *obj, Visitor *v,
     balloon_stats_change_timer(s, 0);
 }
 
+static void virtio_balloon_handle_report(VirtIODevice *vdev, VirtQueue *vq)
+{
+    VirtIOBalloon *dev = VIRTIO_BALLOON(vdev);
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
+            if (qemu_balloon_is_inhibited() || dev->poison_val)
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
@@ -627,7 +661,8 @@ static size_t virtio_balloon_config_size(VirtIOBalloon *s)
         return sizeof(struct virtio_balloon_config);
     }
     if (virtio_has_feature(features, VIRTIO_BALLOON_F_PAGE_POISON) ||
-        virtio_has_feature(features, VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
+        virtio_has_feature(features, VIRTIO_BALLOON_F_FREE_PAGE_HINT) ||
+        virtio_has_feature(features, VIRTIO_BALLOON_F_REPORTING)) {
         return sizeof(struct virtio_balloon_config);
     }
     return offsetof(struct virtio_balloon_config, free_page_report_cmd_id);
@@ -715,7 +750,8 @@ static uint64_t virtio_balloon_get_features(VirtIODevice *vdev, uint64_t f,
     VirtIOBalloon *dev = VIRTIO_BALLOON(vdev);
     f |= dev->host_features;
     virtio_add_feature(&f, VIRTIO_BALLOON_F_STATS_VQ);
-    if (virtio_has_feature(f, VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
+    if (virtio_has_feature(f, VIRTIO_BALLOON_F_FREE_PAGE_HINT) ||
+        virtio_has_feature(f, VIRTIO_BALLOON_F_REPORTING)) {
         virtio_add_feature(&f, VIRTIO_BALLOON_F_PAGE_POISON);
     }
 
@@ -805,6 +841,10 @@ static void virtio_balloon_device_realize(DeviceState *dev, Error **errp)
     s->dvq = virtio_add_queue(vdev, 128, virtio_balloon_handle_output);
     s->svq = virtio_add_queue(vdev, 128, virtio_balloon_receive_stats);
 
+    if (virtio_has_feature(s->host_features, VIRTIO_BALLOON_F_REPORTING)) {
+        s->rvq = virtio_add_queue(vdev, 32, virtio_balloon_handle_report);
+    }
+
     if (virtio_has_feature(s->host_features,
                            VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
         s->free_page_vq = virtio_add_queue(vdev, VIRTQUEUE_MAX_SIZE,
@@ -931,6 +971,8 @@ static Property virtio_balloon_properties[] = {
      */
     DEFINE_PROP_BOOL("qemu-4-0-config-size", VirtIOBalloon,
                      qemu_4_0_config_size, false),
+    DEFINE_PROP_BIT("unused-page-reporting", VirtIOBalloon, host_features,
+                    VIRTIO_BALLOON_F_REPORTING, true),
     DEFINE_PROP_LINK("iothread", VirtIOBalloon, iothread, TYPE_IOTHREAD,
                      IOThread *),
     DEFINE_PROP_END_OF_LIST(),
diff --git a/include/hw/virtio/virtio-balloon.h b/include/hw/virtio/virtio-balloon.h
index 7fe78e5c14d7..db5bf7127112 100644
--- a/include/hw/virtio/virtio-balloon.h
+++ b/include/hw/virtio/virtio-balloon.h
@@ -42,7 +42,7 @@ enum virtio_balloon_free_page_report_status {
 
 typedef struct VirtIOBalloon {
     VirtIODevice parent_obj;
-    VirtQueue *ivq, *dvq, *svq, *free_page_vq;
+    VirtQueue *ivq, *dvq, *svq, *free_page_vq, *rvq;
     uint32_t free_page_report_status;
     uint32_t num_pages;
     uint32_t actual;

