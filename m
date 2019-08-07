Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1914C19759
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 07:06:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 85F5E219BE
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 07:06:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 85F5E219BE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 33FB46B0008; Wed,  7 Aug 2019 03:06:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2CA016B000C; Wed,  7 Aug 2019 03:06:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B7E66B000E; Wed,  7 Aug 2019 03:06:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id EC65A6B0008
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 03:06:31 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id p18so4637554qke.9
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 00:06:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=ObXb8s+P+33YOBHS71fbz/1szBcAnp4vJnFUmXXP1hc=;
        b=fj9c5/Apurf6bKfKeBjeck2fPOdr3k7M0cmxNMKM6mmZ4fzVnbs60Ilgt/6lYpcXMz
         6X9tuRanTZ31uJG9rpLkrzr2kz0or+8Asp96/CakTmbm8lQxlwf6Fc+ONKc5kVNBmGUl
         nUu8dakF57lKdSlkq9t7/4i9gpaGKsOh12Xf86cDZufsB1JWbtgYmgpABuUlhh7UeJCQ
         t0VfpIaqx8dAMGbWAdK3+A51/XYFNZn0n5Lkz9IslFdDUP18ApnfJULTElR4bmJ/CId8
         2LvK3eSakYmmajpdNP+P+xvJVP5lEFihdt3Q6+P0b7du1PH/PXD1LiEs3hqHhLVDrsjg
         ONkw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUe7ceydbt0Ld6nWLOrhtP+ytoMlfdLyVqFv1iNCoqW3CEPND/E
	oxmxGo1JelAMGHebB2U242WUbsW5lK//zIh8AG5e9cFNCK3V7IP1pvUQAEtU9ZhAjAfh2X32QGy
	FS9oC+f0f3EuARYhU6voLZyEoW9DDkPH8iRc96MVxAxqUDYJUzHi9nlisr3h5n4kEJg==
X-Received: by 2002:a0c:d11c:: with SMTP id a28mr6687898qvh.180.1565161591685;
        Wed, 07 Aug 2019 00:06:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwsuyN62vbpgyIsGHl3HCDaa0ETouFNmcquNnArpXpo/Yz3tbHxKtUOOnxnOmptPH8vsi5V
X-Received: by 2002:a0c:d11c:: with SMTP id a28mr6687861qvh.180.1565161590656;
        Wed, 07 Aug 2019 00:06:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565161590; cv=none;
        d=google.com; s=arc-20160816;
        b=HJJTJp2Ozp9cI0nBO2g9G7utKU+/06AAfoP11LpbrTLEqfbF7KWPNibG2Ehk/F9pbK
         +l/mS/BBt3Bd9VvCi6RsScfFSG1VfCq1/PlsnBH83BRHBP0HVEEsQXScP/ulRXH1QEhU
         ktNtM8ioJCEfEbtmQWJV/mjTqahTTTqB7vCbT/E4NxHh/DS2JguydFxpK2tNhchmirpm
         NCFVMCvhJRiNJRWKVGALVYNxLWGwFdV1eIALDPolrryGW6VuZr5rOVZJNckFJvGjbIyL
         PWw62XCO+sFQoyq+chZrvZ3zhXmbrkYa0dJKZvs4n3HMLS2hnyeLpuXMNB81QwoPywZh
         3Vng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=ObXb8s+P+33YOBHS71fbz/1szBcAnp4vJnFUmXXP1hc=;
        b=n4i+rxgoGUP7NiNT6w0XRPVjjFqf/YxgQ/e9gdPL0l0kuPJy97BzggeVVYtLAEJpWj
         Vx9gJADSvnuogKIAUqk7RIQ47sH1byXGfCizEU4HFE+d1e8eTOZY0V1xiUF97MOcxn02
         utBE78MYEoarMB2S9X61lbUGikiJFyLXzjEeM+ZtVruoM7wNHbQ8sinDK9bLhmhFWeFz
         3X+eGhM1iw5rhML1o9dzK6wTNPwFFmOaaten9e07i8jSCfvfCtcXpjma0oKTfIpTxHi2
         RSQ+8dgfgOkqbSYOwgDxzQOp7EoW2GMMH3rNHxdrVSqmbhyUKDPMEn6nbup49A8/y1Q9
         /Jrw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 22si9286568qvj.193.2019.08.07.00.06.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 00:06:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E00C62CE953;
	Wed,  7 Aug 2019 07:06:29 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 609271001281;
	Wed,  7 Aug 2019 07:06:27 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	jgg@ziepe.ca,
	Jason Wang <jasowang@redhat.com>
Subject: [PATCH V4 2/9] vhost: validate MMU notifier registration
Date: Wed,  7 Aug 2019 03:06:10 -0400
Message-Id: <20190807070617.23716-3-jasowang@redhat.com>
In-Reply-To: <20190807070617.23716-1-jasowang@redhat.com>
References: <20190807070617.23716-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Wed, 07 Aug 2019 07:06:30 +0000 (UTC)
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

