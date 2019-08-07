Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91E91C19759
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 06:55:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49F9421E6E
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 06:55:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49F9421E6E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E1DEC6B026C; Wed,  7 Aug 2019 02:55:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DCD986B026D; Wed,  7 Aug 2019 02:55:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C6EC06B026E; Wed,  7 Aug 2019 02:55:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id A87436B026C
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 02:55:32 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id r15so2790499qtt.6
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 23:55:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=SYlINvfnQReM9LtiAmH4n0lonK6ltUq2W4/IC64yAX0=;
        b=H3VPgK/N9RM4/LyRAih4n8pfHjg/Yf/8sJKsHg5s26YhEzITHDkuAU+aAnkyQcg5Zx
         aHTZc1eamx7prGB5txDHegecSuiZ4fnd3rnOZJqLXZ5IkBmCJAtr72U2XTPtTC+KiZes
         CFR0PPhWuLtlKZAwnLetkVqIwk1MyX4EkXMUZEt6EwlDhCVrqly10tRmgOdiXi8ytXd/
         PZFkDO+n7RdZwO+DcSJcAgRoDwIMIdG7GfWDIteoptgDTdJLfd2KekFCt8vWg1GohnOl
         MnhCGC3IAbycGPgHvW7yySVz0TpRVLjJoJl4fMibtOdrp63cNZLa6/+OriRuINzuKNz9
         a85A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXGlVWaesl5jU6hlWwr6DI83e2wWK/tdv5U9QwSSKrqWlx12vy1
	82P2mB0u+TJqiWJtASaEfKP1BO+9otClZB+P1PVNlk2PSdNQC236VV3JYALk4O8KmIyNKFUaI09
	aYymZCq3zwMlVDi4HidUf44q6Zi/GVrKUgtPo4OBY9QxBFX9CqWZ7JCUBfPEiiF99nQ==
X-Received: by 2002:ac8:25b1:: with SMTP id e46mr6844676qte.36.1565160932444;
        Tue, 06 Aug 2019 23:55:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxTIWeCsQUIHrc2kOunf10QIXG+8BI4DxWQYYb3M1+TXU6zp2UABXdX8z7GXtYzCrN6RnKL
X-Received: by 2002:ac8:25b1:: with SMTP id e46mr6844644qte.36.1565160931477;
        Tue, 06 Aug 2019 23:55:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565160931; cv=none;
        d=google.com; s=arc-20160816;
        b=S03P1xq8JA4TG6RbMIBU20ghvOwnCa8sdHM4C/11B6w4vrWf6JCpXy2YAkDZq99FAW
         iqXtYM9gRSmcDHU376aRBf63E6wE7XJDSkKd3VnhK8WGf3g7fWgk4Y88BScv72yLCwGW
         DYa7fT1rkaaPGFxbEEzGyXAvXn5yRkQHHn/mwK9iU8rRX+s8LxFXC/eGI2VoA3CAuBy4
         cKz9tKJOE4sf7dbIRSHG+9GM+oABPWvIH/8HV56N6K7yapgbTVnpCD53oFJ9+uv9NhcZ
         +tnAuffy/zNmx0nyU8Eo5AsiMC2l9UO3LEa4otJhnuadBO+JszCTMapWm9yWlQN2ok+Z
         TsLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=SYlINvfnQReM9LtiAmH4n0lonK6ltUq2W4/IC64yAX0=;
        b=aDFGRHIPqF1eg2Ff/fPaey1CrwtyaCYTksFzJT0kGGHgym9F02hv72chEXs5a8ELcL
         cvBXzHVd2bC75Rfp6inwq7JaWFqkXeU3pTXMoj3uMm8Ue0iOYB8KvDqY9W05F1r/GV/6
         DcZ1I4w9QCtHm3xGCzIahFHgdFY7jNlNkMf7zmXod8bG1HKyq3QTKCqhQtpjPPapVk92
         YRpmW88oFtckVDIGIP2o7upBdbwQf2xlqemhz3+z70uXDOc/hMqDCyQA+rCyIR2UuAY4
         jS101AfTeJxtkFg7q7D2M8T8rLV2nrgI3/n87s+Cjx2hql3zrdi8QPRpqnTf6G9PR+0a
         3qyw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e45si42485236qve.198.2019.08.06.23.55.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 23:55:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id AB692307BCC4;
	Wed,  7 Aug 2019 06:55:30 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 2E3881000324;
	Wed,  7 Aug 2019 06:55:27 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	jgg@ziepe.ca,
	Jason Wang <jasowang@redhat.com>
Subject: [PATCH V3 08/10] vhost: do not use RCU to synchronize MMU notifier with worker
Date: Wed,  7 Aug 2019 02:54:47 -0400
Message-Id: <20190807065449.23373-9-jasowang@redhat.com>
In-Reply-To: <20190807065449.23373-1-jasowang@redhat.com>
References: <20190807065449.23373-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Wed, 07 Aug 2019 06:55:30 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We used to use RCU to synchronize MMU notifier with worker. This leads
calling synchronize_rcu() in invalidate_range_start(). But on a busy
system, there would be many factors that may slow down the
synchronize_rcu() which makes it unsuitable to be called in MMU
notifier.

So this patch switches use seqlock counter to track whether or not the
map was used. The counter was increased when vq try to start or finish
uses the map. This means, when it was even, we're sure there's no
readers and MMU notifier is synchronized. When it was odd, it means
there's a reader we need to wait it to be even again then we are
synchronized. Consider the read critical section is pretty small the
synchronization should be done very fast.

Reported-by: Michael S. Tsirkin <mst@redhat.com>
Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual address")
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.c | 141 ++++++++++++++++++++++++++----------------
 drivers/vhost/vhost.h |   7 ++-
 2 files changed, 90 insertions(+), 58 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index cfc11f9ed9c9..57bfbb60d960 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -324,17 +324,16 @@ static void vhost_uninit_vq_maps(struct vhost_virtqueue *vq)
 
 	spin_lock(&vq->mmu_lock);
 	for (i = 0; i < VHOST_NUM_ADDRS; i++) {
-		map[i] = rcu_dereference_protected(vq->maps[i],
-				  lockdep_is_held(&vq->mmu_lock));
+		map[i] = vq->maps[i];
 		if (map[i]) {
 			vhost_set_map_dirty(vq, map[i], i);
-			rcu_assign_pointer(vq->maps[i], NULL);
+			vq->maps[i] = NULL;
 		}
 	}
 	spin_unlock(&vq->mmu_lock);
 
-	/* No need for synchronize_rcu() or kfree_rcu() since we are
-	 * serialized with memory accessors (e.g vq mutex held).
+	/* No need for synchronization since we are serialized with
+	 * memory accessors (e.g vq mutex held).
 	 */
 
 	for (i = 0; i < VHOST_NUM_ADDRS; i++)
@@ -362,6 +361,40 @@ static bool vhost_map_range_overlap(struct vhost_uaddr *uaddr,
 	return !(end < uaddr->uaddr || start > uaddr->uaddr - 1 + uaddr->size);
 }
 
+static void inline vhost_vq_access_map_begin(struct vhost_virtqueue *vq)
+{
+	write_seqcount_begin(&vq->seq);
+}
+
+static void inline vhost_vq_access_map_end(struct vhost_virtqueue *vq)
+{
+	write_seqcount_end(&vq->seq);
+}
+
+static void inline vhost_vq_sync_access(struct vhost_virtqueue *vq)
+{
+	unsigned int seq;
+
+	/* Make sure any changes to map was done before checking seq
+	 * counter. Paired with smp_wmb() in write_seqcount_begin().
+	 */
+	smp_mb();
+	seq = raw_read_seqcount(&vq->seq);
+	/* Odd means the map was currently accessed by vhost worker */
+	if (seq & 0x1) {
+		/* When seq changes, we are sure no reader can see
+		 * previous map */
+		while (raw_read_seqcount(&vq->seq) == seq) {
+			if (need_resched())
+				schedule();
+		}
+	}
+	/* Make sure seq counter was checked before map is
+	 * freed. Paired with smp_wmb() in write_seqcount_end().
+	 */
+	smp_mb();
+}
+
 static void vhost_invalidate_vq_start(struct vhost_virtqueue *vq,
 				      int index,
 				      unsigned long start,
@@ -376,16 +409,15 @@ static void vhost_invalidate_vq_start(struct vhost_virtqueue *vq,
 	spin_lock(&vq->mmu_lock);
 	++vq->invalidate_count;
 
-	map = rcu_dereference_protected(vq->maps[index],
-					lockdep_is_held(&vq->mmu_lock));
+	map = vq->maps[index];
 	if (map) {
 		vhost_set_map_dirty(vq, map, index);
-		rcu_assign_pointer(vq->maps[index], NULL);
+		vq->maps[index] = NULL;
 	}
 	spin_unlock(&vq->mmu_lock);
 
 	if (map) {
-		synchronize_rcu();
+		vhost_vq_sync_access(vq);
 		vhost_map_unprefetch(map);
 	}
 }
@@ -457,7 +489,7 @@ static void vhost_init_maps(struct vhost_dev *dev)
 	for (i = 0; i < dev->nvqs; ++i) {
 		vq = dev->vqs[i];
 		for (j = 0; j < VHOST_NUM_ADDRS; j++)
-			RCU_INIT_POINTER(vq->maps[j], NULL);
+			vq->maps[j] = NULL;
 	}
 }
 #endif
@@ -655,6 +687,7 @@ void vhost_dev_init(struct vhost_dev *dev,
 		vq->indirect = NULL;
 		vq->heads = NULL;
 		vq->dev = dev;
+		seqcount_init(&vq->seq);
 		mutex_init(&vq->mutex);
 		spin_lock_init(&vq->mmu_lock);
 		vhost_vq_reset(dev, vq);
@@ -921,7 +954,7 @@ static int vhost_map_prefetch(struct vhost_virtqueue *vq,
 	map->npages = npages;
 	map->pages = pages;
 
-	rcu_assign_pointer(vq->maps[index], map);
+	vq->maps[index] = map;
 	/* No need for a synchronize_rcu(). This function should be
 	 * called by dev->worker so we are serialized with all
 	 * readers.
@@ -1216,18 +1249,18 @@ static inline int vhost_put_avail_event(struct vhost_virtqueue *vq)
 	struct vring_used *used;
 
 	if (!vq->iotlb) {
-		rcu_read_lock();
+		vhost_vq_access_map_begin(vq);
 
-		map = rcu_dereference(vq->maps[VHOST_ADDR_USED]);
+		map = vq->maps[VHOST_ADDR_USED];
 		if (likely(map)) {
 			used = map->addr;
 			*((__virtio16 *)&used->ring[vq->num]) =
 				cpu_to_vhost16(vq, vq->avail_idx);
-			rcu_read_unlock();
+			vhost_vq_access_map_end(vq);
 			return 0;
 		}
 
-		rcu_read_unlock();
+		vhost_vq_access_map_end(vq);
 	}
 #endif
 
@@ -1245,18 +1278,18 @@ static inline int vhost_put_used(struct vhost_virtqueue *vq,
 	size_t size;
 
 	if (!vq->iotlb) {
-		rcu_read_lock();
+		vhost_vq_access_map_begin(vq);
 
-		map = rcu_dereference(vq->maps[VHOST_ADDR_USED]);
+		map = vq->maps[VHOST_ADDR_USED];
 		if (likely(map)) {
 			used = map->addr;
 			size = count * sizeof(*head);
 			memcpy(used->ring + idx, head, size);
-			rcu_read_unlock();
+			vhost_vq_access_map_end(vq);
 			return 0;
 		}
 
-		rcu_read_unlock();
+		vhost_vq_access_map_end(vq);
 	}
 #endif
 
@@ -1272,17 +1305,17 @@ static inline int vhost_put_used_flags(struct vhost_virtqueue *vq)
 	struct vring_used *used;
 
 	if (!vq->iotlb) {
-		rcu_read_lock();
+		vhost_vq_access_map_begin(vq);
 
-		map = rcu_dereference(vq->maps[VHOST_ADDR_USED]);
+		map = vq->maps[VHOST_ADDR_USED];
 		if (likely(map)) {
 			used = map->addr;
 			used->flags = cpu_to_vhost16(vq, vq->used_flags);
-			rcu_read_unlock();
+			vhost_vq_access_map_end(vq);
 			return 0;
 		}
 
-		rcu_read_unlock();
+		vhost_vq_access_map_end(vq);
 	}
 #endif
 
@@ -1298,17 +1331,17 @@ static inline int vhost_put_used_idx(struct vhost_virtqueue *vq)
 	struct vring_used *used;
 
 	if (!vq->iotlb) {
-		rcu_read_lock();
+		vhost_vq_access_map_begin(vq);
 
-		map = rcu_dereference(vq->maps[VHOST_ADDR_USED]);
+		map = vq->maps[VHOST_ADDR_USED];
 		if (likely(map)) {
 			used = map->addr;
 			used->idx = cpu_to_vhost16(vq, vq->last_used_idx);
-			rcu_read_unlock();
+			vhost_vq_access_map_end(vq);
 			return 0;
 		}
 
-		rcu_read_unlock();
+		vhost_vq_access_map_end(vq);
 	}
 #endif
 
@@ -1362,17 +1395,17 @@ static inline int vhost_get_avail_idx(struct vhost_virtqueue *vq,
 	struct vring_avail *avail;
 
 	if (!vq->iotlb) {
-		rcu_read_lock();
+		vhost_vq_access_map_begin(vq);
 
-		map = rcu_dereference(vq->maps[VHOST_ADDR_AVAIL]);
+		map = vq->maps[VHOST_ADDR_AVAIL];
 		if (likely(map)) {
 			avail = map->addr;
 			*idx = avail->idx;
-			rcu_read_unlock();
+			vhost_vq_access_map_end(vq);
 			return 0;
 		}
 
-		rcu_read_unlock();
+		vhost_vq_access_map_end(vq);
 	}
 #endif
 
@@ -1387,17 +1420,17 @@ static inline int vhost_get_avail_head(struct vhost_virtqueue *vq,
 	struct vring_avail *avail;
 
 	if (!vq->iotlb) {
-		rcu_read_lock();
+		vhost_vq_access_map_begin(vq);
 
-		map = rcu_dereference(vq->maps[VHOST_ADDR_AVAIL]);
+		map = vq->maps[VHOST_ADDR_AVAIL];
 		if (likely(map)) {
 			avail = map->addr;
 			*head = avail->ring[idx & (vq->num - 1)];
-			rcu_read_unlock();
+			vhost_vq_access_map_end(vq);
 			return 0;
 		}
 
-		rcu_read_unlock();
+		vhost_vq_access_map_end(vq);
 	}
 #endif
 
@@ -1413,17 +1446,17 @@ static inline int vhost_get_avail_flags(struct vhost_virtqueue *vq,
 	struct vring_avail *avail;
 
 	if (!vq->iotlb) {
-		rcu_read_lock();
+		vhost_vq_access_map_begin(vq);
 
-		map = rcu_dereference(vq->maps[VHOST_ADDR_AVAIL]);
+		map = vq->maps[VHOST_ADDR_AVAIL];
 		if (likely(map)) {
 			avail = map->addr;
 			*flags = avail->flags;
-			rcu_read_unlock();
+			vhost_vq_access_map_end(vq);
 			return 0;
 		}
 
-		rcu_read_unlock();
+		vhost_vq_access_map_end(vq);
 	}
 #endif
 
@@ -1438,15 +1471,15 @@ static inline int vhost_get_used_event(struct vhost_virtqueue *vq,
 	struct vring_avail *avail;
 
 	if (!vq->iotlb) {
-		rcu_read_lock();
-		map = rcu_dereference(vq->maps[VHOST_ADDR_AVAIL]);
+		vhost_vq_access_map_begin(vq);
+		map = vq->maps[VHOST_ADDR_AVAIL];
 		if (likely(map)) {
 			avail = map->addr;
 			*event = (__virtio16)avail->ring[vq->num];
-			rcu_read_unlock();
+			vhost_vq_access_map_end(vq);
 			return 0;
 		}
-		rcu_read_unlock();
+		vhost_vq_access_map_end(vq);
 	}
 #endif
 
@@ -1461,17 +1494,17 @@ static inline int vhost_get_used_idx(struct vhost_virtqueue *vq,
 	struct vring_used *used;
 
 	if (!vq->iotlb) {
-		rcu_read_lock();
+		vhost_vq_access_map_begin(vq);
 
-		map = rcu_dereference(vq->maps[VHOST_ADDR_USED]);
+		map = vq->maps[VHOST_ADDR_USED];
 		if (likely(map)) {
 			used = map->addr;
 			*idx = used->idx;
-			rcu_read_unlock();
+			vhost_vq_access_map_end(vq);
 			return 0;
 		}
 
-		rcu_read_unlock();
+		vhost_vq_access_map_end(vq);
 	}
 #endif
 
@@ -1486,17 +1519,17 @@ static inline int vhost_get_desc(struct vhost_virtqueue *vq,
 	struct vring_desc *d;
 
 	if (!vq->iotlb) {
-		rcu_read_lock();
+		vhost_vq_access_map_begin(vq);
 
-		map = rcu_dereference(vq->maps[VHOST_ADDR_DESC]);
+		map = vq->maps[VHOST_ADDR_DESC];
 		if (likely(map)) {
 			d = map->addr;
 			*desc = *(d + idx);
-			rcu_read_unlock();
+			vhost_vq_access_map_end(vq);
 			return 0;
 		}
 
-		rcu_read_unlock();
+		vhost_vq_access_map_end(vq);
 	}
 #endif
 
@@ -1843,13 +1876,11 @@ static bool iotlb_access_ok(struct vhost_virtqueue *vq,
 #if VHOST_ARCH_CAN_ACCEL_UACCESS
 static void vhost_vq_map_prefetch(struct vhost_virtqueue *vq)
 {
-	struct vhost_map __rcu *map;
+	struct vhost_map *map;
 	int i;
 
 	for (i = 0; i < VHOST_NUM_ADDRS; i++) {
-		rcu_read_lock();
-		map = rcu_dereference(vq->maps[i]);
-		rcu_read_unlock();
+		map = vq->maps[i];
 		if (unlikely(!map))
 			vhost_map_prefetch(vq, i);
 	}
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index a9a2a93857d2..12399e7c7a61 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -115,16 +115,17 @@ struct vhost_virtqueue {
 #if VHOST_ARCH_CAN_ACCEL_UACCESS
 	/* Read by memory accessors, modified by meta data
 	 * prefetching, MMU notifier and vring ioctl().
-	 * Synchonrized through mmu_lock (writers) and RCU (writers
-	 * and readers).
+	 * Synchonrized through mmu_lock (writers) and seqlock
+         * counters,  see vhost_vq_access_map_{begin|end}().
 	 */
-	struct vhost_map __rcu *maps[VHOST_NUM_ADDRS];
+	struct vhost_map *maps[VHOST_NUM_ADDRS];
 	/* Read by MMU notifier, modified by vring ioctl(),
 	 * synchronized through MMU notifier
 	 * registering/unregistering.
 	 */
 	struct vhost_uaddr uaddrs[VHOST_NUM_ADDRS];
 #endif
+	seqcount_t seq;
 	const struct vhost_umem_node *meta_iotlb[VHOST_NUM_ADDRS];
 
 	struct file *kick;
-- 
2.18.1

