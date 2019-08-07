Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76A01C433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 06:55:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 313902086D
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 06:55:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 313902086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C705B6B026E; Wed,  7 Aug 2019 02:55:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C1FED6B026F; Wed,  7 Aug 2019 02:55:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B0EDA6B0270; Wed,  7 Aug 2019 02:55:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9694E6B026E
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 02:55:44 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id c207so78067256qkb.11
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 23:55:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=sYjMC87t7lQK71a5hL6RYQpnRJhjlWcFG0kpxjHSl+k=;
        b=lUIKzfYIW2QweOyRAwLPbZXBup3+K7z6n7LiWUvYAn1bKXBgzvhe+Sk6JaSAKncPL9
         +YnW/JhbsWF+qWpak9Sj8k1LKZ1szugIiw3DBwPArUi8IXOIvKHW97Aa8J6Wl/0j5Bhc
         85LVLDb12bpM0cldILzLZQEPGs8u/YvGNOdFmpeZumZdfzFQK6r531LQvTEVl9X1tD+b
         aypbs8cdkpgEIIyuzoQiHNMe8j4mbZWahxy+tPt8GEoC4GToTY7ONH4ybqzEwjYTkuua
         K+LUaKxUtrmeUkduuBZbf6oNm3GeWLiSf0xAM7EaYMPyAi6j0ZOCcQtag/PJGjKgfq0j
         t9jA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW5+SrkSgbxeiLtFgUNdB7/RBfI8aDwHJJ8pFhZx2mlPyGsQZlr
	YFD+0Oei+VmjWYr8sOHQIsSknHSaiUE4JE8DssDvtbB9HX9y8VMyvq7oqnyn3LsC/X/qXxVPHGg
	N5Cq4ONjDksd1kUf0h5XQWoA1S9jInACqwsArPe/AQCMbIwyyfgMLT05KjCzQJDi8/Q==
X-Received: by 2002:a37:f511:: with SMTP id l17mr6248417qkk.99.1565160944417;
        Tue, 06 Aug 2019 23:55:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw7V/uSjo2CaYf0mETI63b4XemXsz1B5NpOPWORgEUkYW3sz5xsjKPPqkoQMargU3umgFpF
X-Received: by 2002:a37:f511:: with SMTP id l17mr6248395qkk.99.1565160943864;
        Tue, 06 Aug 2019 23:55:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565160943; cv=none;
        d=google.com; s=arc-20160816;
        b=cVIpjAvdl4yUuDHUeBqHfgQdK3ya6lzgh2Zh5ss3w3B0eXn8pt2S7q+jGuer91oWNt
         S9eABaXGC+vRcqDZ7S/ZwWOEfTZ+5LPGPXQPqvPry6j6eKYoGlmmj/H9EeeaLlJibUjz
         IljT++XFRTpAGpHBlb3dRkOdF2Y/augxTwBav9uPW+7bl8BdM3pNTtjYdDBap2Ro7vOX
         Asq7tMbEpLNiDAfIx9RvuOjaggkDbEOzMAcxVIojAX1HjWZROMYcxQtGChZeV7rj4w4H
         w2xjHzbPF/JDo4LW7Gyl7874li/Pd3Gh4mQV/saVpDD8XYMIIkHAA1a+Pkvd7+GY4EcN
         cN2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=sYjMC87t7lQK71a5hL6RYQpnRJhjlWcFG0kpxjHSl+k=;
        b=FW02CSIwJtvehW9Z8qNySlyLqg8ro9e7NeOmqVgk2HYGBgYscqc+mTzYuzqREDftNu
         YEXQuolRj9DDgvl3xcOqrwQuK8qYlLYkQG/8Ob2Lz7cWCOwHNm3WOboCc0vKt9pTEAxA
         MzWLJ8XAThj8q3c6SmT2yiaA0hOSs2ffkM1hbLbTaiVYVsV2gUMcaFwjPHcS24YuZ2D7
         oIp9+TMHrQKGFZiduMUOAiSJ6ssE/uVNL36hDbDpu/vX38+af6qTjMpjV1nt27GPRQ/H
         mVADMZVv5tUGc/BGeEEcKuU9sxCMzK2qn+WtN4Yyf5xAcWilOs5plL4MlL2wB/qrP6tf
         NP7g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s54si51216749qte.241.2019.08.06.23.55.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 23:55:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2F233C08EC28;
	Wed,  7 Aug 2019 06:55:43 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id A54A01001958;
	Wed,  7 Aug 2019 06:55:36 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	jgg@ziepe.ca,
	Jason Wang <jasowang@redhat.com>
Subject: [PATCH V3 10/10] vhost: do not return -EAGAIN for non blocking invalidation too early
Date: Wed,  7 Aug 2019 02:54:49 -0400
Message-Id: <20190807065449.23373-11-jasowang@redhat.com>
In-Reply-To: <20190807065449.23373-1-jasowang@redhat.com>
References: <20190807065449.23373-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Wed, 07 Aug 2019 06:55:43 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Instead of returning -EAGAIN unconditionally, we'd better do that only
we're sure the range is overlapped with the metadata area.

Reported-by: Jason Gunthorpe <jgg@ziepe.ca>
Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual address")
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.c | 32 +++++++++++++++++++-------------
 1 file changed, 19 insertions(+), 13 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 6650a3ff88c1..0271f853fa9c 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -395,16 +395,19 @@ static void inline vhost_vq_sync_access(struct vhost_virtqueue *vq)
 	smp_mb();
 }
 
-static void vhost_invalidate_vq_start(struct vhost_virtqueue *vq,
-				      int index,
-				      unsigned long start,
-				      unsigned long end)
+static int vhost_invalidate_vq_start(struct vhost_virtqueue *vq,
+				     int index,
+				     unsigned long start,
+				     unsigned long end,
+				     bool blockable)
 {
 	struct vhost_uaddr *uaddr = &vq->uaddrs[index];
 	struct vhost_map *map;
 
 	if (!vhost_map_range_overlap(uaddr, start, end))
-		return;
+		return 0;
+	else if (!blockable)
+		return -EAGAIN;
 
 	spin_lock(&vq->mmu_lock);
 	++vq->invalidate_count;
@@ -419,6 +422,8 @@ static void vhost_invalidate_vq_start(struct vhost_virtqueue *vq,
 		vhost_set_map_dirty(vq, map, index);
 		vhost_map_unprefetch(map);
 	}
+
+	return 0;
 }
 
 static void vhost_invalidate_vq_end(struct vhost_virtqueue *vq,
@@ -439,18 +444,19 @@ static int vhost_invalidate_range_start(struct mmu_notifier *mn,
 {
 	struct vhost_dev *dev = container_of(mn, struct vhost_dev,
 					     mmu_notifier);
-	int i, j;
-
-	if (!mmu_notifier_range_blockable(range))
-		return -EAGAIN;
+	bool blockable = mmu_notifier_range_blockable(range);
+	int i, j, ret;
 
 	for (i = 0; i < dev->nvqs; i++) {
 		struct vhost_virtqueue *vq = dev->vqs[i];
 
-		for (j = 0; j < VHOST_NUM_ADDRS; j++)
-			vhost_invalidate_vq_start(vq, j,
-						  range->start,
-						  range->end);
+		for (j = 0; j < VHOST_NUM_ADDRS; j++) {
+			ret = vhost_invalidate_vq_start(vq, j,
+							range->start,
+							range->end, blockable);
+			if (ret)
+				return ret;
+		}
 	}
 
 	return 0;
-- 
2.18.1

