Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA49FC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 08:48:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 909FF206A3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 08:48:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 909FF206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F72D8E000E; Wed, 31 Jul 2019 04:48:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A4F28E0001; Wed, 31 Jul 2019 04:48:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 292F28E000E; Wed, 31 Jul 2019 04:48:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 082B08E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 04:48:02 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id c79so57555239qkg.13
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 01:48:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=f3Dgp0rISQbLBy1W6JCGeOGgAgYgofB8EtL0G3nJn5I=;
        b=AtQn+Cch0tO9iPi50leQ7r7UDcO/JFPefH+vWWE35WX8Xm3YQc2Eq51GvZECBdPAe0
         GQySMBC6hdmm+fgIbVrTHSKjN3UrKfLNCTEN4+hk09xjtfp1Cnh4KtRZCoi7JPjfjDE1
         vAfm8WYwnHgVuH62iTa89m5VG7sxHy3PZz+8E/9xTq+2tLDuOcs08nrAUsfZU8n6nb5E
         feOeBw2IR8N13ShY/S6kQmLzcFYIkaAD0mREL+nbr60f3GhWfsM6lKFUtEbCmgF77rG2
         AhK/jArUdoyE07uok+polhdoH7Ov8Vlgmp4kfxkceVRJEeOR2TEh67XJv7CKtGz9RPco
         WEgw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUhPOQyWJHBpaLHDSJ0zAEVLc7XPPzJfxkQdL00+tza7a3OKVHN
	CfOk4mcrxiOxzxkl/RTJGBdhYNSUqaN3gbiPDBlYgGKoYGIfdo03g2Tc8aEit8Eqj0IOmiYKV2h
	by0a2+Wm/7hIJBSAaelcINGpssV1CpPRfr4VWVByG276iYMRNBD1WoRac+zBKJQb0Kg==
X-Received: by 2002:a37:9c88:: with SMTP id f130mr78368388qke.494.1564562881816;
        Wed, 31 Jul 2019 01:48:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyGK2cyQkvPdQdwqSd3LRO1ZL9IxZHbxzlsF51O/uFpzqb8zYKrcCypYJQUJvg+K73sRsXQ
X-Received: by 2002:a37:9c88:: with SMTP id f130mr78368358qke.494.1564562881220;
        Wed, 31 Jul 2019 01:48:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564562881; cv=none;
        d=google.com; s=arc-20160816;
        b=zsdA0/6B2DuzCbTp6o2CdEcZjW02G1HsdvL8QewYJM24WTZji6GpTrsD66VmG3NAnd
         Rj1JpW2iDiMlmpTf/SYOeTEs/rRuu++Uihbz/F5uCC9UdiEX94Iv9gENK/CaX3vyIj4f
         ydAHfwAwv2woyydO/lzfaK/6XuTQQsK3HpWOSErsIi/Aj3IVchvidDyhxHFQy8qTUcEF
         E+8znb5X7+rRmucQiXZoLiVnych2P6kkAKHPatmOjyW5nxI9OgVnKE/26lEHWg+cOwDh
         9+4JW99pZdSYFh5j2T1z0YJqEIfr8ahpTeenIe0Pu+915ClYFNZrC9v71aJcJdVsD2aA
         Tphw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=f3Dgp0rISQbLBy1W6JCGeOGgAgYgofB8EtL0G3nJn5I=;
        b=vpN2XHB7eQ4Obd7IWBWLHUk2PHynYMU20SI/o/JS/q+pQOLk0vSBauUIHDT/KRfpLL
         JNfKedLXLG+0DNoDTPyw+eDWXo8qEWPcGYzumaHCbSNqiTJ++VC9ia0HBhl+QzyWMe7J
         JQsTX85KJJSlDMEahZ1v3f1nhdI3icirjGfE+6bQBjIQXLEF5tO8TunOL8jWblvnvwfF
         XD8athKHta+m0c7kVJ0vF1eMrlET0M1XjfUbVUVGPYAK6sKq6hspn/lYBgaqxm5aUD7o
         wPLtmMnBAEtO/SDu25VueU9XZvmKc+JY5u+KvNIi1xWk4BEADBWpcXozxNdbrsub3YyF
         xX/A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m56si9779577qtk.70.2019.07.31.01.48.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 01:48:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5159130C134A;
	Wed, 31 Jul 2019 08:48:00 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 7AA3F600D1;
	Wed, 31 Jul 2019 08:47:53 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	jasowang@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	jgg@ziepe.ca
Subject: [PATCH V2 9/9] vhost: do not return -EAGIAN for non blocking invalidation too early
Date: Wed, 31 Jul 2019 04:46:55 -0400
Message-Id: <20190731084655.7024-10-jasowang@redhat.com>
In-Reply-To: <20190731084655.7024-1-jasowang@redhat.com>
References: <20190731084655.7024-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Wed, 31 Jul 2019 08:48:00 +0000 (UTC)
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
index fc2da8a0c671..96c6aeb1871f 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -399,16 +399,19 @@ static void inline vhost_vq_sync_access(struct vhost_virtqueue *vq)
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
@@ -423,6 +426,8 @@ static void vhost_invalidate_vq_start(struct vhost_virtqueue *vq,
 		vhost_set_map_dirty(vq, map, index);
 		vhost_map_unprefetch(map);
 	}
+
+	return 0;
 }
 
 static void vhost_invalidate_vq_end(struct vhost_virtqueue *vq,
@@ -443,18 +448,19 @@ static int vhost_invalidate_range_start(struct mmu_notifier *mn,
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

