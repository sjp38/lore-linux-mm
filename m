Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3575CC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 08:47:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 04C2C206A3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 08:47:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 04C2C206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A84258E000D; Wed, 31 Jul 2019 04:47:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A34DD8E0001; Wed, 31 Jul 2019 04:47:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 94BAB8E000D; Wed, 31 Jul 2019 04:47:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 76E638E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 04:47:54 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id g30so60784244qtm.17
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 01:47:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=4wTbOdmhrqXSYLdOwV661kuyaF4EI1X+WzfX+kFYoYc=;
        b=fHTQcWB144K/DR+ZmX36XlFTXSSpfq4/XDyAbayL/SwSrMlTRMXNilqv4OU11CPJqp
         ShQTExDqCQa4T6EJ37bmpD2HLEXdET/8k/2gCXWwcqj3fx+w7LjvTXv6PDnkGnwq4cAD
         bUjfKhcfnuY6ef6Ihe3X6WPAd6l/McaRvsD7QuxFtQcslPJZGjO3x1iW9SyBbxDVOLfg
         lmMjud3WOhiBzRCFk1wzKDWu+KABz++jJijMXsnFORqd8P+VedBtD1efve6nZG5ATVmK
         qtbBlM1OZfRsKUaM+wH7UBbMn//n6tln0muEIWHyfSKIN6UHmxlAvxEnPjK/X1kPsitK
         mB8A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXdKjlRIAFvUjYHnhMrZVmFBB6y5v26lrH5HdvTPrJmdH5t7qPx
	5sN5RW6bSc9mX6gMMQnRo5cebfntW/CRBzjxf3SCl0WRr1s114goged1MIZOcSdBWECH9SyIgS0
	I/pcoC7AD0gsVnxPW5V5Gk+sTX6qGVjHRlZIbxUf5X+8aEy3JsJqn5DwasXyaSFAinA==
X-Received: by 2002:a0c:d2da:: with SMTP id x26mr88105839qvh.51.1564562874288;
        Wed, 31 Jul 2019 01:47:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyi0DuvC2rSPAe0PjcOgZWzqI4Z1oW4MOa912ShoJS2ZU9afVYcanIP0ASvmDV2ULODhFwJ
X-Received: by 2002:a0c:d2da:: with SMTP id x26mr88105818qvh.51.1564562873821;
        Wed, 31 Jul 2019 01:47:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564562873; cv=none;
        d=google.com; s=arc-20160816;
        b=y+704TY+QTAd8iE58Ooej36c54Vei3SW7m7l7LzB+l8euPeiLx4NNuw6fVIYwo0+Wz
         ywznrbELu4rsSQeS+HRLPftr+ZYjpEFDYuSE9h/VdtGBOKhfxv9yUqP2eOP8Uvl6iHNZ
         EGxVtBKaiIpxORcmS/3zoHKJuC2+3Qeups6huMj9vF2pk9pJtbRMwEsX/6DbG+SQ2pO8
         T9Ga2FUEaigggzv3Qpuf8/5OEubeeBdO+t7n+5CCRmCJK+QouSX5H1b2XL4xmuo9oiu3
         6rBPJs6ZnIVjs3LNNMVPOZTsUfT6Ro2EdK5O29sTcajvNdmW4C2dxUZ3F/QYwElkc1Ry
         /pFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=4wTbOdmhrqXSYLdOwV661kuyaF4EI1X+WzfX+kFYoYc=;
        b=Ov1fwYwc0CgrXsVnRnfnnqfUo7U5UGs9qF85+dotF0+2VPn12ryOKP8iLm8w3cgp/h
         1ehGrweM4jy2sfUkOgu80O5yPAVfVz3EmV6OiffNqHdMneeX0NgmT/18TMdt6FYN0GXb
         rMqMfdfs0QYRoMqSUsDVlosfsQnzxS9AGbJHy012xK8k2T4HukbfSFZElVcrEmaZ9+cC
         FnlVZdNBVAW6kMFBf6BAw9NKx+CktTLl8wTYH8KB8gbCZKvuZpxi6iairw3GyAsfZcO/
         z5wC9pIY54dKHOg2HZRO7ecQcBill43rnaa47uSNEaKMSmVyI4fcSF2otD2Ij7rxPdCr
         skvA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q20si38756847qke.380.2019.07.31.01.47.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 01:47:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0D5CC30860A7;
	Wed, 31 Jul 2019 08:47:53 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 40899600F8;
	Wed, 31 Jul 2019 08:47:43 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	jasowang@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	jgg@ziepe.ca
Subject: [PATCH V2 8/9] vhost: correctly set dirty pages in MMU notifiers callback
Date: Wed, 31 Jul 2019 04:46:54 -0400
Message-Id: <20190731084655.7024-9-jasowang@redhat.com>
In-Reply-To: <20190731084655.7024-1-jasowang@redhat.com>
References: <20190731084655.7024-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Wed, 31 Jul 2019 08:47:53 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We need make sure there's no reference on the map before trying to
mark set dirty pages.

Reported-by: Michael S. Tsirkin <mst@redhat.com>
Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual address")
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index db2c81cb1e90..fc2da8a0c671 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -414,14 +414,13 @@ static void vhost_invalidate_vq_start(struct vhost_virtqueue *vq,
 	++vq->invalidate_count;
 
 	map = vq->maps[index];
-	if (map) {
-		vhost_set_map_dirty(vq, map, index);
+	if (map)
 		vq->maps[index] = NULL;
-	}
 	spin_unlock(&vq->mmu_lock);
 
 	if (map) {
 		vhost_vq_sync_access(vq);
+		vhost_set_map_dirty(vq, map, index);
 		vhost_map_unprefetch(map);
 	}
 }
-- 
2.18.1

