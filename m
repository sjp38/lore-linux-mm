Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CDCC6C072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 08:13:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91FB92184B
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 08:13:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91FB92184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 485BC6B000A; Fri, 24 May 2019 04:13:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 410746B000C; Fri, 24 May 2019 04:13:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D8296B000D; Fri, 24 May 2019 04:13:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id F085A6B000A
	for <linux-mm@kvack.org>; Fri, 24 May 2019 04:13:03 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id t17so4115410otp.19
        for <linux-mm@kvack.org>; Fri, 24 May 2019 01:13:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=m6tK+A2i9kvOrNp8SLo2LyEmYDirSbo50rDKkd7XZTw=;
        b=JJo3CFelQPORhooV2LWjlf0DLeV47lD5ER5jncpwrD4kXexqpeuIOkdDihG/TbMCiQ
         OOWG/9392ArwqBGJeU238D4IysL+OrfNCzMdYNamGEQfokK7Aqvo8cuLcgoAns3OaaoN
         FQtut/4dtSbpHPxjyYikUpTx075n2J9gRQMH0iyFIR0lsQFwwiyhgC7+HW392X6T6thn
         O0Gh0ucJAMKI5VAKu/JBn6E2CR51Fv6QpeBLuSOy/cTFwuptL2Cw0y7JnkvOtbWRH46z
         GTJmepwzArehBCSb+tR2BnuZuTVswaZqQOJG/3jcrHZdK9OZA0VX+BdoDnB8vphyB2QT
         nC4w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVHGjwB2tKXldd7nOSGJTnbLUJn4lE8/b1OQmwgWJ0dokktqCN4
	20IRo0vuTx/8Axx5d8Fl11UhGUR0XI+FA2nwQ0sjJCMjmg3K7AiPhpJsgXKV1xNEXYeHysoAl/q
	D2IP3JjdKR+28vO8PB+ih6YE2bSI6R02+GjJE1gAf/N4RGHGN6V5YTC0SzBu1AFjAhA==
X-Received: by 2002:aca:5350:: with SMTP id h77mr5775389oib.57.1558685583657;
        Fri, 24 May 2019 01:13:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwIJ796SqJ6kGlk1g2Lb2ZIkv8l9DkCYAqhFaRcyqTX9f88ffNiRTyYI5RIJz9jKZ7bRTt9
X-Received: by 2002:aca:5350:: with SMTP id h77mr5775354oib.57.1558685582806;
        Fri, 24 May 2019 01:13:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558685582; cv=none;
        d=google.com; s=arc-20160816;
        b=gioxYs0sDdsYieV8u5qmI6RNvAG6eypWU546SY1wuU9iJs577sPLWnwW9XhwnrRKlA
         aVkyTYhE/MvMsD83mpLB7q7oJjYFnlBVpBZIlTdrSjnuyfCRZr7RcrM8kuf6npHdrmw1
         HpXAT1C8xa9FMTQjwW1eoHtS1e8Zkvl6kJ0s0sCbVKZL0VUtjQW4496nHOm3zIZJTiur
         qJtXoGJM9aZkd3psquvBmSWTzc+uoKqYGS2pA29BI2Tglg3AKKHGgAd+roEIWGLu5GYZ
         3gHsHvizUHiq3BiKFmoxGwg5dsa72ycg1KckbpfysoPRYVivvkwF5IigGHo+TYhvaHZW
         7aig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=m6tK+A2i9kvOrNp8SLo2LyEmYDirSbo50rDKkd7XZTw=;
        b=ZIg6vx222IXPjI4+SpFxeIQiauHSxqCWIWw2SCtc+WsMbalxpyUY1JX88sLbq7ticS
         InUE4w78AvNMmMEJYFiDm4vQILddSzYAys4UDFueUfkfDfpXDN3cSzmRwrtgCdNtBW6U
         Q6sAxH4tXJJjCvsuzFWHR1Rz8c2DmDTyxoaSyiPqN4YVnGpR3sYP5OFqwonB/xVGFpqe
         MNXUqUwt3adtX10hZpl23y1x1eiqaJS2OcdZcaSiFxYFKYH/WRETng3iLUP2lGo/i6rX
         Zs/il8LzWa01n8vcQZrQCqXz/RthBoShNxJ2brLsoJZ3aMRBbP2D5ZhjkZubloQrrm/m
         SMxA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t21si1217266oih.211.2019.05.24.01.13.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 May 2019 01:13:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id ED9AC9B424;
	Fri, 24 May 2019 08:13:01 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 30D2719C4F;
	Fri, 24 May 2019 08:12:56 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	jasowang@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	peterx@redhat.com,
	James.Bottomley@hansenpartnership.com,
	hch@infradead.org,
	davem@davemloft.net,
	jglisse@redhat.com,
	linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org,
	linux-parisc@vger.kernel.org,
	christophe.de.dinechin@gmail.com,
	jrdr.linux@gmail.com
Subject: [PATCH net-next 4/6] vhost: introduce helpers to get the size of metadata area
Date: Fri, 24 May 2019 04:12:16 -0400
Message-Id: <20190524081218.2502-5-jasowang@redhat.com>
In-Reply-To: <20190524081218.2502-1-jasowang@redhat.com>
References: <20190524081218.2502-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Fri, 24 May 2019 08:13:02 +0000 (UTC)
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
index b353a00094aa..8605e44a7001 100644
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

