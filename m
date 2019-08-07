Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A11CC433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 07:06:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4017621E6A
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 07:06:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4017621E6A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DEE166B0273; Wed,  7 Aug 2019 03:06:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D9E6E6B0274; Wed,  7 Aug 2019 03:06:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C41936B0275; Wed,  7 Aug 2019 03:06:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9D74E6B0273
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 03:06:54 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id 5so78283270qki.2
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 00:06:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=sYjMC87t7lQK71a5hL6RYQpnRJhjlWcFG0kpxjHSl+k=;
        b=X6Sg/4+W/UA0ebVOBX42VAKllfeGHA9WuxU+G5TDCmqObJBHHQIRShd2KjMSotikGo
         rfA5zrKPe0Xn6CiUHe8lwOA9bkovnNncpg+DpCEhH7Ohh6oIZc0uFM+YM713LqB4ecBx
         PKvnTP4TrlM7O7VS0tbyKb/vV5qqgA3m/+QToni68FnbLfgvxCsS9WDXjftJn2pV3LST
         e9+I/n/aLz+OUPqD2TQ1fbszQleG4EhgMaqIaMTjwf0NAUGN/ngG3d/p+9/ffM/ghDDr
         T25NwZQ5niHixuGBojHuk1nuVFIAkQ2VWmGX4YNDpj5WT4Dn/Tj4iJUy/1NDNWtFeWAe
         7hIg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWgQhoASkwDWo9fsywpxY34fR1crd1yf1NVtJFPkbTVR9bDVB/7
	Q3uac983z2nuH6i9/fiQadNT8SGDNmTi7wRbBQhsIxkmuya7xjl/VhCsgL3/kbx5dX0lKpn2Arz
	46yihmhJtX+U0bmiT4qIrqoVd+o71gl/KCQ+/JNWZ3gANRW4uuuT+ptK1Q/ew51m6IQ==
X-Received: by 2002:a0c:d4d0:: with SMTP id y16mr6450918qvh.191.1565161614437;
        Wed, 07 Aug 2019 00:06:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwoC31ruguoTh8erVWvksfV5FKa8nfo8cw7CkjB1PJkQwCn5AW/aiWVfXqghN50PwKYsB9H
X-Received: by 2002:a0c:d4d0:: with SMTP id y16mr6450898qvh.191.1565161613870;
        Wed, 07 Aug 2019 00:06:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565161613; cv=none;
        d=google.com; s=arc-20160816;
        b=appNgWHM9z9Yw2FmK1V5By536D7J7tzY5YkUsShUGbXhU3BeOzgRSxrTSHoui1uncl
         JgyzTW3jqBWaRAqJ79B5xWag9VPqaR8B/gDs8nR+0kJs+EHDZ8+18+WvyEvb5s5Lkxgn
         3ct7oa1+3L5qY8iKmUh50lJVZJ/2GSLsh9vxT4dKaMS4ZJDCpxp0v3sAzmJwQ1tTkwhP
         W3iJpZgVSx/0vBMdlTDPEMzPX9eyLsr6zS+N6eAvzl4YNReAT4vntlkXm3zNTaHLVM5y
         Av9IoLinZn6h+dqjB/wJRg/ucRfqlP4JwjUl7FFyTEJGSjxplNofi214Ct+FMD9S45XO
         Xt1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=sYjMC87t7lQK71a5hL6RYQpnRJhjlWcFG0kpxjHSl+k=;
        b=ikI/5ospfflL6q9ayRhfkOqBQ7+ico/g1YXwRq+mUdc4RoD213EWhHuBregAh5XWnI
         OmWML+Jpl2CdSgV4h4urkc8JsYHzGKIKprZ8prPNl63D9dyRCkkHusKEgNyZIO1KXDAO
         LxyaM8lpFv4hCSMxbVKR9/prWR4x7pRPlO2RZmEX/sg7bOFXxIZQxuPFn6QZ7WYRTiZb
         uNQcLjLlWNYOjRCbn5oVi/semSG70zcyGJ97c3D1lSW03RWJIx/OSRPlUoWKIcNXRRxk
         NzcjPuXH2HKCSlIijPDRKmaipaPKqUf5tGXjhg3LHLx+x49kikeu0hb7oksC57k9LR3h
         zkSw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h7si18225127qkj.360.2019.08.07.00.06.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 00:06:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2EC3CC009DE2;
	Wed,  7 Aug 2019 07:06:53 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id A5BFA1000324;
	Wed,  7 Aug 2019 07:06:50 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	jgg@ziepe.ca,
	Jason Wang <jasowang@redhat.com>
Subject: [PATCH V4 9/9] vhost: do not return -EAGAIN for non blocking invalidation too early
Date: Wed,  7 Aug 2019 03:06:17 -0400
Message-Id: <20190807070617.23716-10-jasowang@redhat.com>
In-Reply-To: <20190807070617.23716-1-jasowang@redhat.com>
References: <20190807070617.23716-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Wed, 07 Aug 2019 07:06:53 +0000 (UTC)
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

