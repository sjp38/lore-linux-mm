Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64FB7C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 07:18:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C24B20675
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 07:18:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C24B20675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B73D28E0007; Wed,  6 Mar 2019 02:18:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AFB858E0001; Wed,  6 Mar 2019 02:18:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C47D8E0007; Wed,  6 Mar 2019 02:18:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7176F8E0001
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 02:18:45 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id i66so9069177qke.21
        for <linux-mm@kvack.org>; Tue, 05 Mar 2019 23:18:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=hgLHbNBUqAGtlADp7mooWyIXpRAaHdyS6OF7kehE+CQ=;
        b=FOl/ENVGAXNUPEEGO0mk4nfe7v7dPmd1knvSmg63X9KweqtEgI0TMeg4oxa4qPgArc
         fzoQTpCPo97TjE0fzw9Phj0tjpOf7SdGnFrsJFTQz4zeqm2B8OnF7XAH4zBKTmWzkKuX
         bn51uoC0LJMm15aF1TeS2j9NXE2Gd19rvhxtz292S0tzF1diTY0W8yasz3GbfYl2RT+i
         2z+6PJH1Nsf2ZbSK8AsK8N1psoXnTErjj0k1J5NyozHgGbycL8518OXbneJa4xb/ImHQ
         o+SA3VYrplCDee6y4h1Q3IUIJiI9Uha3ShfKjPL6JEmJYqbauByhLoIyoYrhSBqOf5Sy
         4G4g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX0A5tsZKFmb/6rcZ7xpAl7+U84uiQB31dg6SoE6vhsARiXe8kZ
	MNtdI7XE4dFmoU3J5DPBD4/pNNzojCTKVk2HZYk8k5kBJB1Z/LpxdLDToR7xxboXq8IAEr1h2OV
	S9OOFcjmaYexj6nn8SAHN/yd3SdSM8MrtZIez7MF7Dz4xmEZwcdl1qZxwqe+e3Zj2MA==
X-Received: by 2002:ac8:23f7:: with SMTP id r52mr4452882qtr.378.1551856725188;
        Tue, 05 Mar 2019 23:18:45 -0800 (PST)
X-Google-Smtp-Source: APXvYqxTX+ylVUKqkeHEu3Qjok9LM5gm8Xr79/T0ZvS85HSrFZAVnlkj3OmAyzcG/pk9m5jUqN5f
X-Received: by 2002:ac8:23f7:: with SMTP id r52mr4452861qtr.378.1551856724414;
        Tue, 05 Mar 2019 23:18:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551856724; cv=none;
        d=google.com; s=arc-20160816;
        b=hDgtZJpXBPHdiAOyr+QF6szA97qLVJwlOBy9L+Y0wo5BukWqNS5NR+fIYLRu4vmw+J
         +zXfb1po4yBui6WS5WAno16xNmQLys7hPpgKpeAWeh+YNt1fyFB+O5MLKk/M5Ex9O2EG
         LVdQTYy+Mab8YNvHoPyKan9l+PI0fNFSzVeaqR3bexwpPSFNyn0w2dOvS/7Q8+tM9ArX
         f+xQTLowFn2ozgqgN4M/AYEt9uaDQfzl1m9Bws0x7meF162j4dvntvJ45NN68iyQJ4X6
         R98Dy0DtLy5QQtcZBaP5lFHVE9B5tU5WlvXVH4DcdzSejEyWTAbFgCR0AoQtSPRFjZQ4
         4//A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=hgLHbNBUqAGtlADp7mooWyIXpRAaHdyS6OF7kehE+CQ=;
        b=ZxVIxtVatIh2nQhhGbPLec1YBwvKBB55bfkpZQRNx+SvxF4qIJQPN3WV+TcuHi4nos
         P+cWGnkO9ulnBqeDqI4uzxpaRCfNIgBSvGo+O5diVa5BfguRDIK/eeejzAid25RooWEF
         EM2b+RXJX0s6pUco9gWsT3GZoGjxvp1IHPnGUH4v0IGH644Cql0Sf3Tt/mtRR/Uv+Tl4
         GPXNNeLgOxVxgdh9p349iLfgFLcUBIVRJQUKouDLk6Y7I+O/ZhNdBauHafvetkhXscX9
         +Qm8gptnrjbdhnq4BulFSykv3BfmjtMQNOx0gvrr3TP8SAJVSka6KxwSNrvzHJjalStW
         SmYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d2si261619qvn.110.2019.03.05.23.18.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Mar 2019 23:18:44 -0800 (PST)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9E63C30224BE;
	Wed,  6 Mar 2019 07:18:43 +0000 (UTC)
Received: from hp-dl380pg8-02.lab.eng.pek2.redhat.com (hp-dl380pg8-02.lab.eng.pek2.redhat.com [10.73.8.12])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 6C434600C5;
	Wed,  6 Mar 2019 07:18:34 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: jasowang@redhat.com,
	mst@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Cc: peterx@redhat.com,
	linux-mm@kvack.org,
	aarcange@redhat.com
Subject: [RFC PATCH V2 4/5] vhost: introduce helpers to get the size of metadata area
Date: Wed,  6 Mar 2019 02:18:11 -0500
Message-Id: <1551856692-3384-5-git-send-email-jasowang@redhat.com>
In-Reply-To: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Wed, 06 Mar 2019 07:18:43 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.c | 46 ++++++++++++++++++++++++++++------------------
 1 file changed, 28 insertions(+), 18 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 2025543..1015464 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -413,6 +413,27 @@ static void vhost_dev_free_iovecs(struct vhost_dev *dev)
 		vhost_vq_free_iovecs(dev->vqs[i]);
 }
 
+static size_t vhost_get_avail_size(struct vhost_virtqueue *vq, int num)
+{
+	size_t event = vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX) ? 2 : 0;
+
+	return sizeof(*vq->avail) +
+	       sizeof(*vq->avail->ring) * num + event;
+}
+
+static size_t vhost_get_used_size(struct vhost_virtqueue *vq, int num)
+{
+	size_t event = vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX) ? 2 : 0;
+
+	return sizeof(*vq->used) +
+	       sizeof(*vq->used->ring) * num + event;
+}
+
+static size_t vhost_get_desc_size(struct vhost_virtqueue *vq, int num)
+{
+	return sizeof(*vq->desc) * num;
+}
+
 void vhost_dev_init(struct vhost_dev *dev,
 		    struct vhost_virtqueue **vqs, int nvqs, int iov_limit)
 {
@@ -1253,13 +1274,9 @@ static bool vq_access_ok(struct vhost_virtqueue *vq, unsigned int num,
 			 struct vring_used __user *used)
 
 {
-	size_t s = vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX) ? 2 : 0;
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
@@ -1311,22 +1328,18 @@ static bool iotlb_access_ok(struct vhost_virtqueue *vq,
 
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
 
@@ -1343,13 +1356,10 @@ bool vhost_log_access_ok(struct vhost_dev *dev)
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
1.8.3.1

