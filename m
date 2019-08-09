Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9AAEC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 05:49:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6EF242089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 05:49:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6EF242089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 14CD06B0008; Fri,  9 Aug 2019 01:49:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0FE546B000A; Fri,  9 Aug 2019 01:49:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F2CB06B000C; Fri,  9 Aug 2019 01:49:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id D0F4B6B0008
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 01:49:08 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id t2so140212qkd.3
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 22:49:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=ObXb8s+P+33YOBHS71fbz/1szBcAnp4vJnFUmXXP1hc=;
        b=nRrIqEh8IaZNYu7u70yJwpwpjGF+JNYljLFvFKnfovI9w2otwURY1Iy+jMOEtq7aMv
         gT8V4Y+oNAhVxkABkzfdVKXYP1JVf+nkCSsGBktQAUtq+SpqvMG+CWhW9B3TLSzEt8uR
         6WGYpEVXGoXp1xWpg/MIcyWV7+jc6Mp/dZLcDY0JMo9cewSkpK0driD6CiG8qPNM77BT
         AmqvFzEwR0/EsAj1/oDY2SNKLmJnfeeNLwAN3DxNB5BquMwQg9q5w6jAxI6ZZPREdsmW
         6AtyswRwGS3RJHspu8KH3SUvsWBr5nMntAbJnlf3LrfZBwLr8wc2YfYBZ5AAVkTv614l
         QAbQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUjOx12TkH2EBujBTI/KVlMwyBdU9gwCiYXCBHDDXHkDAK+PB/R
	LqJUpRqOC6WXDY7Pnu432MaAmvhyubJBCFvAwhZgrwY9M6WtHaJZf4Ui5YCuasGswxAksuOpm+a
	WSWIwn5iAVbA9sArR3gGA1wk0jJ6ufXPDjY862Cfcun0ARUxafS4IEueDhfAoZXafIw==
X-Received: by 2002:a37:4944:: with SMTP id w65mr16263165qka.111.1565329748640;
        Thu, 08 Aug 2019 22:49:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyIIH7Nf9zsbaV5TkE9oU4UuGU8xYZfJym+XTxB3k4nI8wQWcPnB52Y8rg2j9+sUSsSIgBI
X-Received: by 2002:a37:4944:: with SMTP id w65mr16263134qka.111.1565329747722;
        Thu, 08 Aug 2019 22:49:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565329747; cv=none;
        d=google.com; s=arc-20160816;
        b=uOVhI0hylJMKFaf5+Q4jf6qwH8bmNViFoxhdy2/zO8lcB+kelNdr0SXqcYMOmMQsfp
         jeqQP8XrlFxQrQHUHSjC62DfI0dhsJbxpfWgnMFZUA4nAXyDEZYOht5rDoe0sf31cVVk
         MVqwXmrdCgV9JxYUa4U0Mndu5Q8P+5pytMaNLgeNzMHTvqkBQIT6fDWt9Wqp9qMmKHkC
         7b8VF1WK0Po0hlM7pBNxg0eoRGyIlBH/20gFC9mTaoariM6P85Qu3OcUrmsjb8CQfWOu
         e3aljL4mDHolzxULu8gf2ZBq/643Nul/i0PQMliCVWiLVcHP77NHFV1E1wJlEHHLTh/G
         hGYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=ObXb8s+P+33YOBHS71fbz/1szBcAnp4vJnFUmXXP1hc=;
        b=bw+oe2EqH5oW8e2tzAeRt7vwJa02YwmCY/TSDzv3oZFE5LTf1906Ec/mVOGR2U8UwN
         dB5AKW5LjRJON9ZZdx7TEtzLns91sjectJSvOc/lFmhbMtlF2jYq4MtSL133jSz6g/EG
         F6DO3fjMVoCXHJQyexKmLgkWWfQb8orc6NROmMcqKof5yasCLU/JM2ozsxniqmZXn/W0
         lztLoHD1oCq5RhHZrtaSMS0VDeCl3k/8cHJwOK34lUtGnIs170nLD1Ay9iueGhzdA7xc
         xk6XZo87cB2BcYu926L1iH654zJ0zCC2gNg6PPCjoYwGjiWXKzoFTnJHEz8eBNVNBdjG
         khJA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j96si55269664qtb.125.2019.08.08.22.49.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 22:49:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 01C9A30832E1;
	Fri,  9 Aug 2019 05:49:07 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 7A0545D9CC;
	Fri,  9 Aug 2019 05:49:04 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	jgg@ziepe.ca,
	Jason Wang <jasowang@redhat.com>
Subject: [PATCH V5 2/9] vhost: validate MMU notifier registration
Date: Fri,  9 Aug 2019 01:48:44 -0400
Message-Id: <20190809054851.20118-3-jasowang@redhat.com>
In-Reply-To: <20190809054851.20118-1-jasowang@redhat.com>
References: <20190809054851.20118-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Fri, 09 Aug 2019 05:49:07 +0000 (UTC)
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

