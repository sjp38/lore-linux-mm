Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1EFECC433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 07:06:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1ED3219BE
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 07:06:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1ED3219BE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 90C656B0010; Wed,  7 Aug 2019 03:06:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 89B326B0269; Wed,  7 Aug 2019 03:06:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70FB46B026E; Wed,  7 Aug 2019 03:06:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4F5AD6B0010
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 03:06:40 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id x10so81203520qti.11
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 00:06:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=JzO6kN8vx263crDqN9GLB46XC0hjzWSfPRcXHfgmC3U=;
        b=oyTUK7O2nwvejw6vt014J3mWoUyEs/+5n9uufcnR+o3y8aFUNi44IToJmRCUwGSGvo
         wJUxRkDQFl8C8G51HOBZnj5dLsN+IgUZqt7FutXPM8aQM6wM/ZAr+QHZ0K1ik/zr64S8
         XrdIJTHcQ/2+HtOPOLrlyVJfcw9/AkwZMpRYTTg0cXYKsXelpybx2oB1aa/cJgepVfSQ
         tcmw2Kt039GW7KdsE69NL9zcu8+6qJx07tdfsOaLt28ncaz2qTU6oORlcrzVnwdVfvw6
         HXd5DPHXvao713LmBEKefpHM6BTgFp2NadKK3a2bo6cafVp5yPePUAz5cGassExJSyq7
         ScHQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU8l0DjljYsBGz8IOhWtDD1PIoi4lmY2qLft2B1FMniYda4ZjK3
	/1pVe/ApT/tYliaYpF+Wh0CJU9j2opIGP/3ctml8GRn0JftuSVnyEdttLPq1vALD8CRD5heIwgZ
	IASi2tz9H9FL9/YCtQklyBy84Zb6Fwl6kSMkpjFuGPausW2B+qCqsWDQLYJED6irEJg==
X-Received: by 2002:a0c:adef:: with SMTP id x44mr6704784qvc.153.1565161600114;
        Wed, 07 Aug 2019 00:06:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxEE7vTmYluJ1xlTCEtJsIOkom2/p41f4fO/icOuiUHfJTXr6z0ALG9plNfKQGeDIbz3Gkc
X-Received: by 2002:a0c:adef:: with SMTP id x44mr6704753qvc.153.1565161599562;
        Wed, 07 Aug 2019 00:06:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565161599; cv=none;
        d=google.com; s=arc-20160816;
        b=kRpFaTf9LbD53P2GIUZw2E4Kvn1NowgvsL+spve4sJWVjcKZdWW+t0SpPMcpmgfGwb
         EvWqqmTCT6Dcl5bImr//ttiKd/nMB79w1dvdXYj7k1kRDLz7LD8ZCTrp5OzsbZ6kmPNv
         UR492kbG5akM8JIjNjr+CrhMQnEypRAzjPvJ17L/rfdHWwIbViAatrzFwyk23yJfWvWr
         bedX22FkIv+q1Eozj6eE+qzRLTcXbWeolXDEmc2qPcrdt3IJ6GGDKHQIo7FYihs5ss/v
         9OVC/Dk9geLR4OjxroWov+VyOvwSt1Eubsx4osjLyL0roAv2rkdBQgXA2Us3tilcn1RB
         dINA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=JzO6kN8vx263crDqN9GLB46XC0hjzWSfPRcXHfgmC3U=;
        b=FwijmNR1y1e2rY0tXJY8DA1wQ3KqGVKAPW4ihTS0SPvawuHT0vIwXGky86psUJ2sdx
         0HGuEenKkjiLnDryOIFNGrqP4NdNJXRF5KCfXiYviCt2YjlIIY0vhytS4Md0iEvjkIju
         FF1Xj6G+ixHzEJgjU6agzRj3pINZ5IF+CgAxn8fsmubOrmlqseVl2moPMSxzZBqPBo7w
         thATv6+utQJsz3B7hDj0Nn/nNr6rOYPSJA5C9ezpKHCnqc2zzphy8O46untaJKSepPHj
         psh27dXLC6r1ZF7lYwlOixxXgnIT4bYwdcempdgePkpjvQsEhajkDXiyU5VoN0lTJDRy
         yvsA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n83si35108614qke.91.2019.08.07.00.06.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 00:06:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D4B5F300C22C;
	Wed,  7 Aug 2019 07:06:38 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 579C51001284;
	Wed,  7 Aug 2019 07:06:36 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	jgg@ziepe.ca,
	Jason Wang <jasowang@redhat.com>
Subject: [PATCH V4 5/9] vhost: mark dirty pages during map uninit
Date: Wed,  7 Aug 2019 03:06:13 -0400
Message-Id: <20190807070617.23716-6-jasowang@redhat.com>
In-Reply-To: <20190807070617.23716-1-jasowang@redhat.com>
References: <20190807070617.23716-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Wed, 07 Aug 2019 07:06:38 +0000 (UTC)
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

