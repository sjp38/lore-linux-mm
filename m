Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 457FAC10F14
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 05:55:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F2C0821738
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 05:55:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F2C0821738
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 989126B0010; Tue, 23 Apr 2019 01:55:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 90F016B0266; Tue, 23 Apr 2019 01:55:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7FC906B0269; Tue, 23 Apr 2019 01:55:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6019C6B0010
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 01:55:01 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id o16so720670qtp.18
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 22:55:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=9ROmEdhXXSco/ULkOaE6eoNIg0SUqKfnbfR953ok6yc=;
        b=JAYwPqrYcB/fHlq0tGoS7ZmuMv+wGJWjydokqyiwkPlFXg+IUV52rC1lekKktaav9u
         SkSHNxJ7SprKNiWgTMhGJwC4b+WodzwTi9EpYokAMYZYpBjEpdPfIu/SD0p1b9paEdiY
         t3D3VqQyqyzfI9M5YIF4n8+zWEV4+8ov/IuSfnHfL2CQuvXnbvTHwTJtAeSzhQolj1ny
         uc7dUU3jYC5NCwh5UG+3opxucnj/F0Vxmh0Bo9nSZ57Mq7UYEtXSxD/1SOqKVlItRRg+
         tApvQRjFZpx8TAhXoxCKLaZZ98gJw+MlAbFGscE2qos1Ym/dFUUi3UQf5rD0rkWYS/Yq
         zxZA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWWTuKYMp40OAJ+5XL9mbpTtR+tlAcOxeNvxZIGSHt+hfYFOSYE
	YDQDJeTMJ4KUAFZMocqMlq8wzp6FLQKjlj/qma2iyViaTTyNQcM7t5TjQt0vv8OOzRSSEMZUuGA
	tVVVsidjT37B6EVXi2D7irRskKJ1P3Pxoc4VndqiFU1RH8+GYVapV1VRvlFKYPUkACg==
X-Received: by 2002:a37:b7c1:: with SMTP id h184mr348670qkf.153.1555998901168;
        Mon, 22 Apr 2019 22:55:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJ2zPp6g6op6qAhmyi8VHjUXEv4X4uZFMcfXVEcZUj5LoTRGStFdcOoaQj93rpIuq3p9Y0
X-Received: by 2002:a37:b7c1:: with SMTP id h184mr348615qkf.153.1555998899515;
        Mon, 22 Apr 2019 22:54:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555998899; cv=none;
        d=google.com; s=arc-20160816;
        b=LVa5nvAoHMSHZ7+44ECxcuYxjKqtrwI2FdxviAgT6eXmkJUKrnYv++w23AkSmociOt
         lGZuITSdL4MpktSrh7mF0Jh5jSAcljKG0EoZ2I/yK1zvScWwEpEPxjX3jZQlIHx/ugri
         cAdkcrmc1x/PIWk1K2MJ04lkn9pQ942CZofix5Uemx//oaipHaAVSxz583WnVdID3I+Y
         gnXNFpjcRvXf1Q9BY8tjKjgldWo1mdwBMT5XG0DZjTc2NrOUTZpcgSscvhDJFpaT90K8
         T/AFrpx0FXRMtIfXmRe4PARzWeeghnMdsyCO3qFC4q1tY0KwywPQ4aRO/0RwMtDjBaT4
         UxIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=9ROmEdhXXSco/ULkOaE6eoNIg0SUqKfnbfR953ok6yc=;
        b=qNxGgT8QMQpFarFwaeogp+D8qezxKVP8KQuARhrF8GAFNTZWVjAGLmmdW8o6Vq/BDe
         yW1BTeFYjBLc7fECfzdWvGKoi996CDL2Ig9jkhrHoVCVELXJ2UDVbUhxVp+MtxH83+MU
         xbDeRbfDW+1PZ3bfgoFCYk/hTIP1cpKJAfXwyPfXHJzBDhTKDhwqp8GPgFpGwZmicukg
         6MAuGze7gH7GBdVh1V0o4kJY6k/Ahn+05uE8FI41nphc58vAVMnb4slMqBcHU8k20QVG
         i1zOJxiIZkhn5Qenm+HeJld3DbpVVmWQquElmNxXB0c23ZD9RRVrM6NJnz5Wz8gW699l
         EZzw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g51si1987970qta.362.2019.04.22.22.54.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 22:54:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9D8D63087925;
	Tue, 23 Apr 2019 05:54:58 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 9ECD3261D1;
	Tue, 23 Apr 2019 05:54:53 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	jasowang@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Cc: peterx@redhat.com,
	aarcange@redhat.com,
	James.Bottomley@hansenpartnership.com,
	hch@infradead.org,
	davem@davemloft.net,
	jglisse@redhat.com,
	linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org,
	linux-parisc@vger.kernel.org,
	christophe.de.dinechin@gmail.com,
	jrdr.linux@gmail.com
Subject: [RFC PATCH V3 4/6] vhost: introduce helpers to get the size of metadata area
Date: Tue, 23 Apr 2019 01:54:18 -0400
Message-Id: <20190423055420.26408-5-jasowang@redhat.com>
In-Reply-To: <20190423055420.26408-1-jasowang@redhat.com>
References: <20190423055420.26408-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Tue, 23 Apr 2019 05:54:58 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

To avoid code duplication since it will be used by kernel VA prefetching.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.c | 51 ++++++++++++++++++++++++++++---------------
 1 file changed, 33 insertions(+), 18 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index bff4d586871d..f3f86c3ed659 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -413,6 +413,32 @@ static void vhost_dev_free_iovecs(struct vhost_dev *dev)
 		vhost_vq_free_iovecs(dev->vqs[i]);
 }
 
+static size_t vhost_get_avail_size(struct vhost_virtqueue *vq,
+				   unsigned int num)
+{
+	size_t event __maybe_unused =
+	       vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX) ? 2 : 0;
+
+	return sizeof(*vq->avail) +
+	       sizeof(*vq->avail->ring) * num + event;
+}
+
+static size_t vhost_get_used_size(struct vhost_virtqueue *vq,
+				  unsigned int num)
+{
+	size_t event __maybe_unused =
+	       vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX) ? 2 : 0;
+
+	return sizeof(*vq->used) +
+	       sizeof(*vq->used->ring) * num + event;
+}
+
+static size_t vhost_get_desc_size(struct vhost_virtqueue *vq,
+				  unsigned int num)
+{
+	return sizeof(*vq->desc) * num;
+}
+
 void vhost_dev_init(struct vhost_dev *dev,
 		    struct vhost_virtqueue **vqs, int nvqs, int iov_limit)
 {
@@ -1257,13 +1283,9 @@ static bool vq_access_ok(struct vhost_virtqueue *vq, unsigned int num,
 			 struct vring_used __user *used)
 
 {
-	size_t s __maybe_unused = vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX) ? 2 : 0;
-
-	return access_ok(desc, num * sizeof *desc) &&
-	       access_ok(avail,
-			 sizeof *avail + num * sizeof *avail->ring + s) &&
-	       access_ok(used,
-			sizeof *used + num * sizeof *used->ring + s);
+	return access_ok(desc, vhost_get_desc_size(vq, num)) &&
+	       access_ok(avail, vhost_get_avail_size(vq, num)) &&
+	       access_ok(used, vhost_get_used_size(vq, num));
 }
 
 static void vhost_vq_meta_update(struct vhost_virtqueue *vq,
@@ -1315,22 +1337,18 @@ static bool iotlb_access_ok(struct vhost_virtqueue *vq,
 
 int vq_meta_prefetch(struct vhost_virtqueue *vq)
 {
-	size_t s = vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX) ? 2 : 0;
 	unsigned int num = vq->num;
 
 	if (!vq->iotlb)
 		return 1;
 
 	return iotlb_access_ok(vq, VHOST_ACCESS_RO, (u64)(uintptr_t)vq->desc,
-			       num * sizeof(*vq->desc), VHOST_ADDR_DESC) &&
+			       vhost_get_desc_size(vq, num), VHOST_ADDR_DESC) &&
 	       iotlb_access_ok(vq, VHOST_ACCESS_RO, (u64)(uintptr_t)vq->avail,
-			       sizeof *vq->avail +
-			       num * sizeof(*vq->avail->ring) + s,
+			       vhost_get_avail_size(vq, num),
 			       VHOST_ADDR_AVAIL) &&
 	       iotlb_access_ok(vq, VHOST_ACCESS_WO, (u64)(uintptr_t)vq->used,
-			       sizeof *vq->used +
-			       num * sizeof(*vq->used->ring) + s,
-			       VHOST_ADDR_USED);
+			       vhost_get_used_size(vq, num), VHOST_ADDR_USED);
 }
 EXPORT_SYMBOL_GPL(vq_meta_prefetch);
 
@@ -1347,13 +1365,10 @@ EXPORT_SYMBOL_GPL(vhost_log_access_ok);
 static bool vq_log_access_ok(struct vhost_virtqueue *vq,
 			     void __user *log_base)
 {
-	size_t s = vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX) ? 2 : 0;
-
 	return vq_memory_access_ok(log_base, vq->umem,
 				   vhost_has_feature(vq, VHOST_F_LOG_ALL)) &&
 		(!vq->log_used || log_access_ok(log_base, vq->log_addr,
-					sizeof *vq->used +
-					vq->num * sizeof *vq->used->ring + s));
+				  vhost_get_used_size(vq, vq->num)));
 }
 
 /* Can we start vq? */
-- 
2.18.1

