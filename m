Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29950C19759
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 06:55:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E59FD21E6E
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 06:55:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E59FD21E6E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 89FA96B026A; Wed,  7 Aug 2019 02:55:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 851166B026B; Wed,  7 Aug 2019 02:55:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 717EC6B026C; Wed,  7 Aug 2019 02:55:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4FC386B026A
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 02:55:26 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id d26so81432795qte.19
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 23:55:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=JzO6kN8vx263crDqN9GLB46XC0hjzWSfPRcXHfgmC3U=;
        b=mgRPV6/ONCxkWqtXXUqSEJ0gz6PoYsrIKS/dEUPIGvDtI/vTq00JTpxYAtgNozqa0R
         efMy9ZyxXqYbC6jjVjTvElUNVLAuDPVPOZ7by6+xD6N/6dAiNUsOJDNuXAhkyxOWLoTO
         ebJhujLVwEZxwKoE4bI+RL0dTfKqZJ44j9Q6soCkkfdIutrsD3vUlqm57Vv5P4QN+INL
         ntNfV2eY02C7O85z2nq3KMK2RRIRy47lJobFYjIpZ4R4PtCEqYWysJ8xbcLrIE/ejREB
         vV32tLYgBNvMc9REZvFw7pxZiquUIQ71KUQbhumIlregUICdjgu+tOyLfet56+njmgeW
         YlMw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX78C4kcr/FtRxjV5Il83sO+RN71nJipVC6sBE7Q8eeCFW6P0z/
	XR6aFKhzDM1VHS+u+fvuMFUksVOm08a/BRQPL7nFVS8C4cbPiNTOot4XIkqTIDveL9sw509sab9
	a0sV9NmEOj4tO9J4Y3pDPhvGT2Vf18lNgJDIAWdY5nX+nw16NLNGKv+HW2F2M1BFgug==
X-Received: by 2002:aed:3aaa:: with SMTP id o39mr6808933qte.146.1565160926127;
        Tue, 06 Aug 2019 23:55:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx7yQEcyyM+QjDBUj8essh1KQn0vDcWU/cxU6zz4unjNsfkNKuAz0JIwThodzZs/s0q4aNa
X-Received: by 2002:aed:3aaa:: with SMTP id o39mr6808904qte.146.1565160925432;
        Tue, 06 Aug 2019 23:55:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565160925; cv=none;
        d=google.com; s=arc-20160816;
        b=qakpZg7l/wvRw/H5uAo8uteHyXx1Hgo4Rw6ztt+WZOH9u5ymqm8ANtp5JKMKXLcDzg
         /uFV3BT3QS98WmFg/Jnz3FC6O7ns/tlJOA1z1bfY63rahPMydMckNgbre5EIk/njF/ts
         tWBaBnZcUb8v+jcO+a4eG4K5J7gytZzxgW3TQbYfQUYQZz3KQRuZcn33g6OMl4XdTdG2
         CxC+Z0eLxubu+0iZyZGRruarUKzzzDd+OFDCPbaLWVUpCfdB22hFK6JskKRW/+lWX1R4
         DwkJ7eBPRYD3IEKblgJ3X0+48B6AJvKOLSxfdZQAM6X2enKi+ZbSytlK0OkfRLBQs1PO
         ZOrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=JzO6kN8vx263crDqN9GLB46XC0hjzWSfPRcXHfgmC3U=;
        b=gWFO1oGm7Qd8H6XLaBlk1MkQyHR28/esNR8u8199IWCILMBbcL9EnMIp0E32mFDJ1i
         6kfzZLfZIBcu5sy4wgoK3Kn9GjU37J2WCEIkZtNsJ7QOf3BbLX9e6TQc74AXotKM7cGR
         rUTf45gSafS5grZOdDHyYzD6cyitrzTJhp3LKlNOscXcqEyBtV0tDfAba4b/fe2uE1S6
         RHi1+J8JJ53hnoQUluLRuBuRw65BK3MWv/z7JbsVXXsQNPwY+e4TPBbxDQcC1j9RHYZT
         IcBMoD/qhY2pd6bp8ypimDAoHWK7SL8fW1/4V6Wb3rg33xSc/XRrtZlLj6KkAc9QZwl4
         tPBw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a55si23953452qtk.80.2019.08.06.23.55.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 23:55:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B30CC30C5859;
	Wed,  7 Aug 2019 06:55:24 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 37BF91000324;
	Wed,  7 Aug 2019 06:55:21 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	jgg@ziepe.ca,
	Jason Wang <jasowang@redhat.com>
Subject: [PATCH V3 06/10] vhost: mark dirty pages during map uninit
Date: Wed,  7 Aug 2019 02:54:45 -0400
Message-Id: <20190807065449.23373-7-jasowang@redhat.com>
In-Reply-To: <20190807065449.23373-1-jasowang@redhat.com>
References: <20190807065449.23373-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Wed, 07 Aug 2019 06:55:24 +0000 (UTC)
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

