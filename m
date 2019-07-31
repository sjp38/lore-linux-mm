Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A693DC32754
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 08:47:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6B5DD206A3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 08:47:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B5DD206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D2AF8E000A; Wed, 31 Jul 2019 04:47:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 182D78E0001; Wed, 31 Jul 2019 04:47:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 098168E000A; Wed, 31 Jul 2019 04:47:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id DC1448E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 04:47:30 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id c1so57305508qkl.7
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 01:47:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=JzO6kN8vx263crDqN9GLB46XC0hjzWSfPRcXHfgmC3U=;
        b=FShBdDSLLG5aiKYXDH1uzx8TUjxHbvOpccwFuZ6ieuqVqGhsdu0x4/uxz8kUZSLOIs
         tMd9OuT7Fqlv9ddzy42xuxDP9NFzRxOTOxyXWJUf/LIOtqd5Z6380vIfZH0cqRs8EVoR
         2tOau1NFx7MWbxsgR+RcPd66oCuSD4Hc3aqba+OJGBl/ZvG+PFJLLZBtZwIXGnTszutA
         mB3W6apIeTf5H4aMHLSE4qjhMctzuVuQ5QDchvI/GjrbFTW26/amZoQx76/sWGffEbl4
         9FNLZoUPdoqCNLGDtL1ygDvFVZFr7randWsXnvUdBw1uPgDNvm1stzpgqBQ/Al9INn7k
         OI0Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWCif6rGHHColi9zZP7/BRWSMQMcDEUpCs6SkH9IGEQ/CJ5Hmfb
	2YTJeyQOGYxirvp4cnv850V2wBlUTrI4aEW8vo0giGicehy5psyo0k9DrAY35GZtHc2sEN1nocf
	gehX/zcpX6sM1+P0Qbe87poPGNzvMY3FrtDFLF3ZDObwOAYILkbghgfg2ApjNitC/2A==
X-Received: by 2002:ae9:dfc3:: with SMTP id t186mr76155753qkf.461.1564562850629;
        Wed, 31 Jul 2019 01:47:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz9DrBVQbJBAg0uWc8qZTOTIo3JmHWsOcXoI184a5YAKV7QnHcTBIuirjjElPzu8ffOH78y
X-Received: by 2002:ae9:dfc3:: with SMTP id t186mr76155718qkf.461.1564562849710;
        Wed, 31 Jul 2019 01:47:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564562849; cv=none;
        d=google.com; s=arc-20160816;
        b=WzEwp6OoNZS+BM0Gog4HXjov8Tayo4YR/mK6UinGe0Zx2DxXCosWEXL+MjSwBKgFLo
         eT8FKScM78G2BfUJJgC5IdF42agBV68EFTIJDVV2ksXFTwPQwkeDMYSecvjeX6v2Y5zm
         wQYnali5YwusRFEsMCelLQBcV4X1BImXHtuEf0goFl1JJcYbJUsWA8Gl5npwElh3KECG
         Pa5Eoml7oR+7xBOs9JZXZURz6x6hL7xuZzV0jAsVS/apt63k9+iZo8CRufXMOuyQ7jWl
         fqorjzc0+Wr6ikjH+TTFUjzBPSx0HIpfYUFHHOkJIB2EWCRXIuo89doLO3aIBtLNhMUK
         pqTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=JzO6kN8vx263crDqN9GLB46XC0hjzWSfPRcXHfgmC3U=;
        b=EYQFy8cEm6cMZQ/bBJp+mTbsvghMGqX9Z+a3VdOmmAEDngXuPNgEXiZdvt4r+kiZPb
         5NMWEysmu2L305hs1OQ8XO7xUSjSliPkzs5c/Uh4coRnQOtY+B1cPRYDXlCojMnnf3IU
         z6qGS3YWGXIZlmPrs/ugGuManoP2IWAiqOG9uy0jYBjG8CbtwrAIM/Jk4QFARfjfHCIr
         OSKmq34nN0K67fB/VYXJgBH3TyWasBEolSIuoHZzOSTGDgLrAuRnFqdbFtOGJ0+04cog
         PyG7vVCFIzcRWzUyzgAl898O22dfj/zlGDMhYMSGp1XnrlHt+fmLDm/HIepb21cR7iIv
         X4eA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a13si224403qvh.92.2019.07.31.01.47.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 01:47:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id EE70030833B0;
	Wed, 31 Jul 2019 08:47:28 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 3A4D6600CC;
	Wed, 31 Jul 2019 08:47:19 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	jasowang@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	jgg@ziepe.ca
Subject: [PATCH V2 5/9] vhost: mark dirty pages during map uninit
Date: Wed, 31 Jul 2019 04:46:51 -0400
Message-Id: <20190731084655.7024-6-jasowang@redhat.com>
In-Reply-To: <20190731084655.7024-1-jasowang@redhat.com>
References: <20190731084655.7024-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Wed, 31 Jul 2019 08:47:29 +0000 (UTC)
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

