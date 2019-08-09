Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88F80C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 05:49:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 583212089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 05:49:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 583212089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 012446B000D; Fri,  9 Aug 2019 01:49:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F06476B000E; Fri,  9 Aug 2019 01:49:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD0A86B0010; Fri,  9 Aug 2019 01:49:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id BB6336B000D
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 01:49:17 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id v4so84617910qkj.10
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 22:49:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=JzO6kN8vx263crDqN9GLB46XC0hjzWSfPRcXHfgmC3U=;
        b=c0injk5SDbik5nEv7QVKCEaXwDwSbkdV8lzGdtgpyOH3k/B+N4rc15DA3h4fCae4EK
         xVyZmfer12vuYAkmEcLkWXnQyMVxvgPLhIktRDBfobeQtX4LwEyr8fNvTqU2yN20hEDK
         6i7j2oHvxmCcUzgb9eZV/RwDMVA8WrWxLCuHOenYE6Z4kF/xpqj6tGgP3H/YLHCYPBSr
         iRiWOGPgaMWafiOw3Ssc+04zHhvoYB5CJFD8/g5xb0OYg1x43CmPDf9Qu0XuP+TeVjdQ
         ExpJm8rQJq9EqAzMQB2Bc1LdK7tWpcw4tYrcL5E2TODssXByQd1LI8YJol0b0pDsA3Kh
         GCdg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVuuILItzZUb7xzuLTtHHpq/y677p0Yd3w73o98EpILQFYxbQox
	9e9chp94myFn6dyhTmooPacsWx9PGWdP5iMSR4WdTakztImOlRAvsQ98fxHS7pokj9psaA3sjI/
	oMzSDD5KW7w69yC1Zb4IBnam5oREFp+uxbGftfGHxJpbE5Jk892KZoA+ZbMIR0exvsQ==
X-Received: by 2002:ac8:2774:: with SMTP id h49mr15768115qth.97.1565329757555;
        Thu, 08 Aug 2019 22:49:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxYDmhpWOolRV35GwsGeR0M7iXN054gN/zt6vqU3875cK2/wW0DkeCmjq54UpkRODyTjXri
X-Received: by 2002:ac8:2774:: with SMTP id h49mr15768073qth.97.1565329756677;
        Thu, 08 Aug 2019 22:49:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565329756; cv=none;
        d=google.com; s=arc-20160816;
        b=xdmR990kPFcDSEJTEnDdCy4+9QsSNf0vrsechVg1flRqzbnifqsmGVT3IHfEpBBLHe
         KyUROgAyVhEQZnp8orPqlMf04sKH0TFcwqE/mSGtTzkslDqDbN+FC9OtxeV3N2/nDkyF
         SJ9gJhoa9Td6OXywDIbCr9xmpF/Z9ow++2yAHSbvdjVlFHhQ73oHgbC47paNIzR3ATfc
         BU0WVRL+BQqhrtP/PPegiNf741dh14Q+7ye/FWyxFRiSirxkHewyGq8k5KZm2Pd76kLf
         hG9IDy4sUIKY1SdL82Bbeql7r/ERqm/upX7Qv4vrPM2cWRewVfsnteCqF2h+DsUHXdo8
         /Yuw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=JzO6kN8vx263crDqN9GLB46XC0hjzWSfPRcXHfgmC3U=;
        b=zfrQ277CAExHGpvzODPRSmYbgEjNAXr/65MIg8bv/MaWdiX1rJb+ozGlMgONDBOQ+0
         Ff3icBIpwNIFHtl3c3xwSzQlBe2bskrd/8HemPtFefcw6lxRw6s9SryXxW+DlhWj7j+Q
         QHSb0wB5U4lE7gBGQLZZvPgFym9HE29EDrd8CTo4M8H7LRvJLABvRXyLTlpa01H0fDu7
         XB11Dyn53y0T2iFNhwcLwUCXHe0k+dYEgL0YDqXs1pLIS3ayGGRV3wBEThB4y8TYDldw
         iakNQ3uB4rmZtKMaeBqhPIeyNsObuo40/xwCplr+qQmOnyh6dUv4eY/n2i4gCK+49uHl
         RtNg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a186si3956083qkf.13.2019.08.08.22.49.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 22:49:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E6EBA30BA080;
	Fri,  9 Aug 2019 05:49:15 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 6BE455D9CC;
	Fri,  9 Aug 2019 05:49:13 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	jgg@ziepe.ca,
	Jason Wang <jasowang@redhat.com>
Subject: [PATCH V5 5/9] vhost: mark dirty pages during map uninit
Date: Fri,  9 Aug 2019 01:48:47 -0400
Message-Id: <20190809054851.20118-6-jasowang@redhat.com>
In-Reply-To: <20190809054851.20118-1-jasowang@redhat.com>
References: <20190809054851.20118-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Fri, 09 Aug 2019 05:49:16 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We don't mark dirty pages if the map was teared down outside MMU
notifier. This will lead untracked dirty pages. Fixing by marking
dirty pages during map uninit.

Reported-by: Michael S. Tsirkin <mst@redhat.com>
Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual address")
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.c | 22 ++++++++++++++++------
 1 file changed, 16 insertions(+), 6 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 2a7217c33668..c12cdadb0855 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -305,6 +305,18 @@ static void vhost_map_unprefetch(struct vhost_map *map)
 	kfree(map);
 }
 
+static void vhost_set_map_dirty(struct vhost_virtqueue *vq,
+				struct vhost_map *map, int index)
+{
+	struct vhost_uaddr *uaddr = &vq->uaddrs[index];
+	int i;
+
+	if (uaddr->write) {
+		for (i = 0; i < map->npages; i++)
+			set_page_dirty(map->pages[i]);
+	}
+}
+
 static void vhost_uninit_vq_maps(struct vhost_virtqueue *vq)
 {
 	struct vhost_map *map[VHOST_NUM_ADDRS];
@@ -314,8 +326,10 @@ static void vhost_uninit_vq_maps(struct vhost_virtqueue *vq)
 	for (i = 0; i < VHOST_NUM_ADDRS; i++) {
 		map[i] = rcu_dereference_protected(vq->maps[i],
 				  lockdep_is_held(&vq->mmu_lock));
-		if (map[i])
+		if (map[i]) {
+			vhost_set_map_dirty(vq, map[i], i);
 			rcu_assign_pointer(vq->maps[i], NULL);
+		}
 	}
 	spin_unlock(&vq->mmu_lock);
 
@@ -353,7 +367,6 @@ static void vhost_invalidate_vq_start(struct vhost_virtqueue *vq,
 {
 	struct vhost_uaddr *uaddr = &vq->uaddrs[index];
 	struct vhost_map *map;
-	int i;
 
 	if (!vhost_map_range_overlap(uaddr, start, end))
 		return;
@@ -364,10 +377,7 @@ static void vhost_invalidate_vq_start(struct vhost_virtqueue *vq,
 	map = rcu_dereference_protected(vq->maps[index],
 					lockdep_is_held(&vq->mmu_lock));
 	if (map) {
-		if (uaddr->write) {
-			for (i = 0; i < map->npages; i++)
-				set_page_dirty(map->pages[i]);
-		}
+		vhost_set_map_dirty(vq, map, index);
 		rcu_assign_pointer(vq->maps[index], NULL);
 	}
 	spin_unlock(&vq->mmu_lock);
-- 
2.18.1

