Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B22DC31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 05:49:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC5D221743
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 05:49:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC5D221743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6CB2F6B0269; Fri,  9 Aug 2019 01:49:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 67AF56B026A; Fri,  9 Aug 2019 01:49:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 569886B026B; Fri,  9 Aug 2019 01:49:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 33DB36B0269
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 01:49:37 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id t5so87652996qtd.21
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 22:49:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=GwEBtSZWPDxK4om7nakiiAS3FtL3tCJnZqvdYC99I0E=;
        b=kbNKlPkAvlZVtFgKYHOuNX3maQ9FM4TscWtYQK96GnLpgzn9tstw2OGB4py6YtMdbT
         NHkzlfCK0ujqpB1RdF/gPtEnRTEBxMMTwruiol+WwZRHGLNBo6GrIPbJepPRE/3fdCko
         iKIf1SM2zP5w+iHlrp3bgD2sTNmD2lybmbg3UXh00psIdcksnqxFC6E1XBplwS7GeJVl
         ZEFV3PrtCg4++K7zSL8kddmXw/uwIPngJEPi0jjlY/fYYJZZGGGxy8My03Jo5jIYL1AN
         UoDQOoGsEcMDIQ56HRBVTJGmyaR4/A4RGTUP81Gv08jfG+Xmm9Wq3/fzCzXol0cjRr/E
         dOCA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUUFkCLBjRy38p9DC8gwzESWgcYUtkB449+3XUAsUAeV3stXDWe
	+7Dxzjmnvu7QHyf0zcTJ3ssA3DJrPMcFOH7EvGxKBp7UrmbBCKMO2F4NWg6eOx1iOLN/QjZCKSr
	t45jDvwZvmidMrte6KhBrzpvLMr1UEBq0Ng+rFpjRxdjPIdRpCnuKi4AtSrheHnKUgA==
X-Received: by 2002:a37:7643:: with SMTP id r64mr16091124qkc.467.1565329777012;
        Thu, 08 Aug 2019 22:49:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw6PxMjLcY3ySZ9CMdlQQgmjW0QfVj5ke8zhD9v3C7gTDIzPfvuq6puN3C91AZfWJwb2UJa
X-Received: by 2002:a37:7643:: with SMTP id r64mr16091098qkc.467.1565329776428;
        Thu, 08 Aug 2019 22:49:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565329776; cv=none;
        d=google.com; s=arc-20160816;
        b=qPd8uuv773wPx/M3N6q/F9Hc7Bs3OSIstHWKGRR9lQAjF2ZX8dWNDK8Gyj+bphB8hk
         s1W41tcqShkLbPQm42Izw9FGslWxXA1CclBs0THLLV9pThxGGmRftPmupHtp+rYyySqm
         g7U7xBkjh895DHkFel6zm/fHSReiNUr8bwTJZKexJuXavf23ttBeInbyErl51R9gzLBz
         yxRfeDp9pXe92vDduVlVfWny8Kw/Lb/KM+Xe6x4YTld1iL6BvSEFbTwpC0c7fvpi2aCx
         f6Hr1F6JSf/dt1YpZTcp0wkQdybAG3iR/qpe6S+ko8plLLdStzKzbiiLB5AKzDfHPe0K
         wnNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=GwEBtSZWPDxK4om7nakiiAS3FtL3tCJnZqvdYC99I0E=;
        b=ecOvqljC2CpRX4t5034J7G7lX7L5wX9cBGFVcSYL2GkRptGhYq9R1wjQZ+K0pBtbm+
         l5akkQksW7XpQE0jOosb8BEfiNdLR1r/mhGNcvuwftDelyruT0bJ+NzD9AEbj28WjuES
         VtXn47z8qxwwhb1MoamWBKqtUEdBTVulYlCZrBP+pt8wdkaxQbtebC6NvG4KGn0ieumH
         qdLKxfwj1WvfGtNNwsc4wvpH25ZJpMN6nao0YjVXBKfyxGOjhM6/6Q2RFnLBjt/p+gAv
         efGJB2tzbt63g9jn0GhljYlumWg4o+7IEzhTwT2OIpUHhYnXyjy0tIRZRmaXGZOhmDMX
         cQSw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w6si53559738qkc.123.2019.08.08.22.49.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 22:49:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A097D300C768;
	Fri,  9 Aug 2019 05:49:35 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 184825D9CC;
	Fri,  9 Aug 2019 05:49:32 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	jgg@ziepe.ca,
	Jason Wang <jasowang@redhat.com>
Subject: [PATCH V5 9/9] vhost: do not return -EAGAIN for non blocking invalidation too early
Date: Fri,  9 Aug 2019 01:48:51 -0400
Message-Id: <20190809054851.20118-10-jasowang@redhat.com>
In-Reply-To: <20190809054851.20118-1-jasowang@redhat.com>
References: <20190809054851.20118-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Fri, 09 Aug 2019 05:49:35 +0000 (UTC)
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
index d8863aaaf0f6..f98155f28f02 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -371,16 +371,19 @@ static void inline vhost_vq_access_map_end(struct vhost_virtqueue *vq)
 	spin_unlock(&vq->mmu_lock);
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
@@ -394,6 +397,8 @@ static void vhost_invalidate_vq_start(struct vhost_virtqueue *vq,
 		vhost_set_map_dirty(vq, map, index);
 		vhost_map_unprefetch(map);
 	}
+
+	return 0;
 }
 
 static void vhost_invalidate_vq_end(struct vhost_virtqueue *vq,
@@ -414,18 +419,19 @@ static int vhost_invalidate_range_start(struct mmu_notifier *mn,
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

