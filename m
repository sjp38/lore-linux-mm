Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD2CDC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 08:47:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 948C7206A3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 08:47:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 948C7206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 444548E0007; Wed, 31 Jul 2019 04:47:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F42A8E0001; Wed, 31 Jul 2019 04:47:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 30B828E0007; Wed, 31 Jul 2019 04:47:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1153A8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 04:47:11 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id t124so57530566qkh.3
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 01:47:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=ObXb8s+P+33YOBHS71fbz/1szBcAnp4vJnFUmXXP1hc=;
        b=SPE3P9vVR88IQoXIuslwUm5a1wcVKOHa2h1AEEw3jf1JyBWFQ91BFPU2Ze7Efrz8PK
         IgM1vPk03d5/zBEk4KZFamBHqSNw6fIE+yTdg/eY15KdEkMI6iYnOGzCc8qW7zj0Kfk6
         5ToMwwGSSuD3JA+5DiQQ2Q8iPTbG4u6MNJnX5ZGbvM3QDhoce/WjET+vfwDmsNWM6u9B
         wG3z7byXQLZO+uHvoAe8KsedNvx9obfLcVfnU1PMTrhkKjiIb6QR5EBVhYsnGGuJnozd
         6OHFMCFVzlkj0NoVzoKFMZZyc5XSLuuyBlZalfG3IYJRQRk25JIPXKvECs00f38ToWwD
         G8gw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVpndRlAHw9QaKAgkWenUo/kaxzqp1pmgVdV4Xj2Dh7FufTBggm
	XncKjAmzysRmg9GtpCrAkWe1vW9NIybSQ19ETxoAEX/U3TKaY1kR5R1/nXoPhyTSVrgg3LF8MU5
	9CwxcpPciWJ8ZtHxTugkjD2t9xnpjCOR2nFIOAbIMv3/wJfMDmvbjbnr8XTL73DeqNQ==
X-Received: by 2002:a37:9904:: with SMTP id b4mr76507965qke.159.1564562830866;
        Wed, 31 Jul 2019 01:47:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx0CCIzwzvH9fcPHuUyen6xMwyJG70NQ8WO8hBKVou7c3j/mrg26/FiSs1k7JNHWFwdmacK
X-Received: by 2002:a37:9904:: with SMTP id b4mr76507915qke.159.1564562829836;
        Wed, 31 Jul 2019 01:47:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564562829; cv=none;
        d=google.com; s=arc-20160816;
        b=TFsXymezVvlW2l1rtMcMfir0ZssaNttjxpsRSVk66GiIosrk8JY3prtd7K7PDvBuEc
         3DQzRXkfI2yQEnvfgfj/JdQ1khAknhP7amvX+4+Zk4Ci5vL57cH48k0k/VsrClTlNnqq
         Yx0fM1YOL2NtvqNEgoDWPEr1tvHgbXMVhviWudPjn0d7O0+2juDIosgBRPWsoW6Sa/Tx
         W/NRnpoBRnvr48i/0jRW+f5idSuoReyL5nBcmfKhwO0nnAWT+ipPUbROtXnIsUUE5LXz
         My7+5PWaXwuhobDzy/99L/1XnPzm4Sx2dRNXAPfe9SecBgyZUt/5AKDnBggR6xNkqfYz
         T1Ww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=ObXb8s+P+33YOBHS71fbz/1szBcAnp4vJnFUmXXP1hc=;
        b=RXhCbThZcPGLBcl8Jw4sSzJaOLHu0T71xmgtY/S/yKtMys708nujWwoZlxEJh1c63B
         3ORbmigvOC9iDC05f4vEfCJUFEdvj2FQawi97yijjZttDAMhr7xrguPvQ+agEW0OhbgX
         a2OY/b1ZpZTEyH50PuWOc2WIlTi/+thM5WqIHZ9HWXuvYMgjtbGDqHyGq2/GoX9hDqHC
         jgw8NxkORfrDBhIUNU/vwRfUTNNHyWD+zrSDgprd+4lA0ggO+f+PStTxpi/CEd1DU2S7
         YrVr/o6LtVWKC28wvVH3qYmOJ2QR6Fz8VlX+tbKbG2MHWAh8DwmirHdGBeMnRKzb43IT
         jIxA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q20si38756108qke.380.2019.07.31.01.47.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 01:47:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2870D307CDFC;
	Wed, 31 Jul 2019 08:47:09 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 7A39C600CC;
	Wed, 31 Jul 2019 08:47:06 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	jasowang@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	jgg@ziepe.ca
Subject: [PATCH V2 2/9] vhost: validate MMU notifier registration
Date: Wed, 31 Jul 2019 04:46:48 -0400
Message-Id: <20190731084655.7024-3-jasowang@redhat.com>
In-Reply-To: <20190731084655.7024-1-jasowang@redhat.com>
References: <20190731084655.7024-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Wed, 31 Jul 2019 08:47:09 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The return value of mmu_notifier_register() is not checked in
vhost_vring_set_num_addr(). This will cause an out of sync between mm
and MMU notifier thus a double free. To solve this, introduce a
boolean flag to track whether MMU notifier is registered and only do
unregistering when it was true.

Reported-and-tested-by:
syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com
Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual address")
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.c | 19 +++++++++++++++----
 drivers/vhost/vhost.h |  1 +
 2 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 488380a581dc..17f6abea192e 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -629,6 +629,7 @@ void vhost_dev_init(struct vhost_dev *dev,
 	dev->iov_limit = iov_limit;
 	dev->weight = weight;
 	dev->byte_weight = byte_weight;
+	dev->has_notifier = false;
 	init_llist_head(&dev->work_list);
 	init_waitqueue_head(&dev->wait);
 	INIT_LIST_HEAD(&dev->read_list);
@@ -730,6 +731,7 @@ long vhost_dev_set_owner(struct vhost_dev *dev)
 	if (err)
 		goto err_mmu_notifier;
 #endif
+	dev->has_notifier = true;
 
 	return 0;
 
@@ -959,7 +961,11 @@ void vhost_dev_cleanup(struct vhost_dev *dev)
 	}
 	if (dev->mm) {
 #if VHOST_ARCH_CAN_ACCEL_UACCESS
-		mmu_notifier_unregister(&dev->mmu_notifier, dev->mm);
+		if (dev->has_notifier) {
+			mmu_notifier_unregister(&dev->mmu_notifier,
+						dev->mm);
+			dev->has_notifier = false;
+		}
 #endif
 		mmput(dev->mm);
 	}
@@ -2064,8 +2070,10 @@ static long vhost_vring_set_num_addr(struct vhost_dev *d,
 	/* Unregister MMU notifer to allow invalidation callback
 	 * can access vq->uaddrs[] without holding a lock.
 	 */
-	if (d->mm)
+	if (d->has_notifier) {
 		mmu_notifier_unregister(&d->mmu_notifier, d->mm);
+		d->has_notifier = false;
+	}
 
 	vhost_uninit_vq_maps(vq);
 #endif
@@ -2085,8 +2093,11 @@ static long vhost_vring_set_num_addr(struct vhost_dev *d,
 	if (r == 0)
 		vhost_setup_vq_uaddr(vq);
 
-	if (d->mm)
-		mmu_notifier_register(&d->mmu_notifier, d->mm);
+	if (d->mm) {
+		r = mmu_notifier_register(&d->mmu_notifier, d->mm);
+		if (!r)
+			d->has_notifier = true;
+	}
 #endif
 
 	mutex_unlock(&vq->mutex);
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 42a8c2a13ab1..a9a2a93857d2 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -214,6 +214,7 @@ struct vhost_dev {
 	int iov_limit;
 	int weight;
 	int byte_weight;
+	bool has_notifier;
 };
 
 bool vhost_exceeds_weight(struct vhost_virtqueue *vq, int pkts, int total_len);
-- 
2.18.1

