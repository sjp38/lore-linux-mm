Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52A25C3A5A3
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 15:00:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 17B422339F
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 15:00:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UBcsbaFs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 17B422339F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C14926B02D9; Wed, 21 Aug 2019 10:59:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC56E6B02DA; Wed, 21 Aug 2019 10:59:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B01B06B02DB; Wed, 21 Aug 2019 10:59:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0220.hostedemail.com [216.40.44.220])
	by kanga.kvack.org (Postfix) with ESMTP id 8F0546B02D9
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 10:59:59 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 335B9181B0489
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:59:59 +0000 (UTC)
X-FDA: 75846744918.22.gate48_571f73a0ca13f
X-HE-Tag: gate48_571f73a0ca13f
X-Filterd-Recvd-Size: 5541
Received: from mail-pf1-f195.google.com (mail-pf1-f195.google.com [209.85.210.195])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:59:58 +0000 (UTC)
Received: by mail-pf1-f195.google.com with SMTP id f17so1601786pfn.6
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 07:59:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=N1FHoD6ZMNB/7wrUWG2IW6DScPoWU0//Swe9DNcA3ZM=;
        b=UBcsbaFs+RkamY++8TTiRe++zLe7yNVTPnIrDAYWzm6LUQbTSQ74QNJHEBRItO96HB
         02SZZHn9Htsz1WlaSdRZfvGuzTxKHGWc2BTRrG8pa42ToRFl/TqsOmC4vTT2ZLpLzij6
         J03iEvoiOsR8FEVWAeupmVSAapKUBh+nHpBJ+cYMBiQSo8sRE0exQ70QK2hX8qWFxFm+
         FHNs2+2u0OaVKL3V6vwnYYxHpMBclxb2LKiSbnwwHx9uizE+23ZTc/CC4/wjWPSTQIBA
         pIP+Jl8MJKuDfuNXSD5LHaK9Xckdi2zuiNxbYAPI6XYQpJdxTTG4nezco0WyqReMiODE
         W2aQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:from:to:cc:date:message-id:in-reply-to
         :references:user-agent:mime-version:content-transfer-encoding;
        bh=N1FHoD6ZMNB/7wrUWG2IW6DScPoWU0//Swe9DNcA3ZM=;
        b=JVs4zkZ+ndjrGXN6pTNOP/k9AB1HI5Sv5gYVueF8utzna2QicoRmAKoTbfSMZCd/5A
         XSaa/FNLd0fipY0mq9bZD1GHly5k2KYaW2rZ8fP4WGJsTkGvmet8ycyZF9mVpdymVBlF
         ObbHMBlIeo6DJPZ02Glc7nHqn1nijKs7ScJrXYIUpqwD7xI8/mMn4jaPRGrH2w3uG2FW
         l3wIEfz6aoYTSqvCssoEi9XTq9HvpiOvH4O2YgEPq+HhMIlTLBPwlt5FxjPviQREMXzh
         /E02mrhpeaiMwuDsTqzfYScupRAtJqY/ysfI7NbySYxOp+zMzyteiE2gL153V4i02Icm
         3o2Q==
X-Gm-Message-State: APjAAAXEJ0yETsTKZJJP7XmUpbiWKUrCOC9M/m2BLBc0V7chMBEp5az6
	iDgd6A6xDXu7vUQN3Jen/MI=
X-Google-Smtp-Source: APXvYqw/9ikn+1SlMs8YrpbK4yn240xMzQLoTRxSmZztXZbUiHNDLxVPWA0XUeakX5XWBDpVrXLuOQ==
X-Received: by 2002:a17:90a:8d86:: with SMTP id d6mr430067pjo.94.1566399597619;
        Wed, 21 Aug 2019 07:59:57 -0700 (PDT)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id y16sm25491605pfn.173.2019.08.21.07.59.56
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Aug 2019 07:59:57 -0700 (PDT)
Subject: [PATCH v6 5/6] virtio-balloon: Pull page poisoning config out of
 free page hinting
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, mst@redhat.com, david@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, willy@infradead.org,
 mhocko@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org,
 virtio-dev@lists.oasis-open.org, osalvador@suse.de
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
Date: Wed, 21 Aug 2019 07:59:56 -0700
Message-ID: <20190821145956.20926.7187.stgit@localhost.localdomain>
In-Reply-To: <20190821145806.20926.22448.stgit@localhost.localdomain>
References: <20190821145806.20926.22448.stgit@localhost.localdomain>
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

Currently the page poisoning setting wasn't being enabled unless free page
hinting was enabled. However we will need the page poisoning tracking logic
as well for unused page reporting. As such pull it out and make it a
separate bit of config in the probe function.

In addition we can actually wrap the code in a check for NO_SANITY. If we
don't care what is actually in the page we can just default to 0 and leave
it there.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 drivers/virtio/virtio_balloon.c |   19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 226fbb995fb0..2c19457ab573 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -842,7 +842,6 @@ static int virtio_balloon_register_shrinker(struct virtio_balloon *vb)
 static int virtballoon_probe(struct virtio_device *vdev)
 {
 	struct virtio_balloon *vb;
-	__u32 poison_val;
 	int err;
 
 	if (!vdev->config->get) {
@@ -909,11 +908,19 @@ static int virtballoon_probe(struct virtio_device *vdev)
 						  VIRTIO_BALLOON_CMD_ID_STOP);
 		spin_lock_init(&vb->free_page_list_lock);
 		INIT_LIST_HEAD(&vb->free_page_list);
-		if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_PAGE_POISON)) {
-			memset(&poison_val, PAGE_POISON, sizeof(poison_val));
-			virtio_cwrite(vb->vdev, struct virtio_balloon_config,
-				      poison_val, &poison_val);
-		}
+	}
+	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_PAGE_POISON)) {
+		__u32 poison_val = 0;
+
+#if !defined(CONFIG_PAGE_POISONING_NO_SANITY)
+		/*
+		 * Let hypervisor know that we are expecting a specific
+		 * value to be written back in unused pages.
+		 */
+		memset(&poison_val, PAGE_POISON, sizeof(poison_val));
+#endif
+		virtio_cwrite(vb->vdev, struct virtio_balloon_config,
+			      poison_val, &poison_val);
 	}
 	/*
 	 * We continue to use VIRTIO_BALLOON_F_DEFLATE_ON_OOM to decide if a


