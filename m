Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27119C433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 06:55:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF53B2086D
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 06:55:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF53B2086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 878CC6B000E; Wed,  7 Aug 2019 02:55:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7DAA46B0010; Wed,  7 Aug 2019 02:55:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C8BC6B0266; Wed,  7 Aug 2019 02:55:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 48CE36B000E
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 02:55:12 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id l16so74537130qtq.16
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 23:55:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=ObXb8s+P+33YOBHS71fbz/1szBcAnp4vJnFUmXXP1hc=;
        b=PaD67hXgCaPHUlLWg1LTMVbygMFciMBInCJUrVWQJJGHWdGEVFCikgTcKW0/TdYucR
         433H8yftTk9t8uV3AC/tdIvntxYWZzWaQrFOUv+Mxlm87c1NZTyLjELblbkUFLJN3hMD
         CSeYfiqn6HFhqKY7+Icp4nPFni1bvQm+nH0WI5WRnSDpXU3TGxRou76MD3kO3vYOAS6b
         PSZOd2wErFUYs5xbYkIp4Hbgb62xkzLfNtxNdXNJ/FXyHo9X6V/8ZCYD5cGpbOKW2enl
         EdA6+QbtuDVHtpBqME/rCETP5sz+ClWVMo7s/ocFyaivljzk2r3tPFFme/yM+5CyRvSB
         fBfg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWeTXFtoOWuUa+sADho8uf+LrRXndYnPOfNP2hE0xV+DBGdJyeb
	16tEmpjwDd57mEQr6Lswik8Hvdy1cztZSpYXEQYQHXQx56yrhzc71SPyex72a9mjtxJ51J6Noeb
	PsXlle/P+0kzm5XSIszAA8YblUpGS6Y+w1Uvqrz/Lor9zyBJOWslnhL46QxiuFjLuZg==
X-Received: by 2002:a05:620a:15ce:: with SMTP id o14mr6973434qkm.30.1565160912094;
        Tue, 06 Aug 2019 23:55:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyj/8vGMkYid9engB6YRdvmsfq50V9QkI8sGsIXrAjKG5ip+2Uf+x6bjZnG/CLPU/dlJfFv
X-Received: by 2002:a05:620a:15ce:: with SMTP id o14mr6973397qkm.30.1565160911174;
        Tue, 06 Aug 2019 23:55:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565160911; cv=none;
        d=google.com; s=arc-20160816;
        b=Aknb8ONLrngMvRA3UQc7Ht/p/KwNKbooTr0syQCH4VdQjQ/6gf/g7xOZ5yzX0QkZFF
         GXLpRAgN8/ZrV0sgMyCxjvjRABjthd3EsbPv0ZeZHGWKQV6CpB5ZfBfeIyuy8t4/+pWK
         RqzLuP1MQua6mlh/axsWQ7LHiLokC8y1CB2R3YKO+YgHyigBn/G/ygXbkH5BCI/NPzAB
         UxIcZpwCi7A1PEyzIkyyZdyeOpstdxZxz6CvwstOcxrqkAgE39NZCDdZZwIn/ogAGJWT
         rsw0sc0DhrH0kj3CXYZoovrMO9yeCwuvPS71al8TL1vVitJFktZjcB8MB94CkmZGbBIa
         oZ9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=ObXb8s+P+33YOBHS71fbz/1szBcAnp4vJnFUmXXP1hc=;
        b=dvq+JAmzQJu48SwKa//k+B4xobG4IaIKgzq4zQE7RQNPlBW28TujXwSKGxnEVEIX/A
         oz1T8Uv3Dz/5TjceU+xex0qge3dDCFQ09jWlo8Z/qviB4TAvx+jCheMhbVprvX/YA1Tk
         d5YkJ/nj+kQbjF06rZ9tDBeZa7zJvWM85663byVFyAuhoZ6l3suOTMaBVTxlrGSEYmIO
         fWejLz8VnWQE6jtb+7dWjbPEFKT54GMu4dYIKtBkA/Ed/0v07zCn+9QLDdLFff0OF1Kb
         H+4NTvvfxJ2dImtPTyqYRiHrdEUa+9Gi7koKZpedQQk0tBa9a9I9QsDmRLMc1L4AFJbP
         kbyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y2si10683055qvf.221.2019.08.06.23.55.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 23:55:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6EB818EA41;
	Wed,  7 Aug 2019 06:55:10 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id E2C7B10016F3;
	Wed,  7 Aug 2019 06:55:07 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	jgg@ziepe.ca,
	Jason Wang <jasowang@redhat.com>
Subject: [PATCH V3 03/10] vhost: validate MMU notifier registration
Date: Wed,  7 Aug 2019 02:54:42 -0400
Message-Id: <20190807065449.23373-4-jasowang@redhat.com>
In-Reply-To: <20190807065449.23373-1-jasowang@redhat.com>
References: <20190807065449.23373-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Wed, 07 Aug 2019 06:55:10 +0000 (UTC)
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

