Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0463DC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 05:49:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD82E2089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 05:49:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD82E2089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 67B996B0266; Fri,  9 Aug 2019 01:49:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 62BD96B0269; Fri,  9 Aug 2019 01:49:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CD1D6B026A; Fri,  9 Aug 2019 01:49:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2A7E56B0266
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 01:49:34 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id k31so87917261qte.13
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 22:49:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=Xg9xaOgVIH9JkOSw3sYvrdIssRyzR2ThUQFgQ50g+yQ=;
        b=Lxi3QF/raJu/+hPg/8QUqI+uCufPbB/KJsQ72n6iwwByELrMcPPlGmWwbHr33iaLmR
         Rkwc8wlbM5tmE0aU9RgwIYSDKTLTZmK2oraZJ8FtiwymDD3ydnZWccsZMyqXqdJVIAZL
         7iwn07Yekq58lSaUPv6IVc1d5Hbpv9LMa7AFbnUwRhdu+DWElUNy3DgmELrTPxVLPt1L
         xAkUIssI1jrtDTC4TECLxzmH965IVDsflcbQ31x5wwuDU4Ux+De7aRl2GKk/Kb7eqR3E
         U9zNkigwSeelj8TM1IbPut6/lcUmbFSm3Assq1r+nGH+W0OvC8KSLjzs/t9sRjESPHfR
         qwng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWhxff0poNZzpgGfsZn7dHHUuXrsHqS9CFkOa20POfdKHJQ93Um
	Bp5m/sYZPgiFSiAqxg2oSSxShjdgrxp0sz/vzX9mj1h7u/oL6olqdlKoLGHKjzQkzsdJDltNzab
	xWWKaUHkJjFjF9P+pbx7BZ81cGhC3eCwKS8BYU4B0FvuRLpssGpaG1+3FarKBcyBchw==
X-Received: by 2002:ac8:2439:: with SMTP id c54mr16190871qtc.160.1565329773984;
        Thu, 08 Aug 2019 22:49:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzv/Bl/ABY4mgPXyEvQfpVqY+a74raZj4prRu/zGsMc11q54tXt9g4urIZRVhFlacgF/VMF
X-Received: by 2002:ac8:2439:: with SMTP id c54mr16190851qtc.160.1565329773429;
        Thu, 08 Aug 2019 22:49:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565329773; cv=none;
        d=google.com; s=arc-20160816;
        b=jY1KkKargHlia2K72Ci37H4oi0b52yd2X7Zxa/K3x59UtPfc9aeMOIK5GPCgyTOcEl
         WKC1U+m40/Pnh1YZrlNkyTzeUOl8Del5kaPbn2PjFs87oXXg587pWdoKFmmWWCoNc6Kt
         aNrOBGxg6DjEsKZubBNW5wbGGduBkmpb2Pl5frFMZry+QJylnuGCtAdHYu5cnvNWzlm/
         JqdGy91UN5QImrcVbd6Djh8+jJNSJMCzumAWk5xv0rrgp+vZ4Ii62ZGG0mPESYtKkTmR
         fAsJcP+6BC/pMfJcDx+XqR6IAIPQjnuTCfAUFRZgukUBZ+Q7h0jDLFxbxcvVy8TWyBPi
         6/+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=Xg9xaOgVIH9JkOSw3sYvrdIssRyzR2ThUQFgQ50g+yQ=;
        b=dFDCEU9OZ/PLu9aOyOWYlCmm1GGhLL0wZu1MSKdyyPXQf326LcX9Em1JEU38mIZkmI
         QoghJNIM15rSDbKgICC3k+hZLXXEjdiwX2KKAsZYgcIKFIdTdLqQyKX1vcFUopH+GAYM
         +HZYxUwh2nI0aETxyLuAugLQ7jBtgHkCx2gl3i1xw3ck8uItzX2Ilm3EJMslvv7mPk28
         P0uZBN/11Fz04iLCfuOQn0sNpPnhqiSeZLP8BdYunIb2VVQalNiRkkrpZgq9MDgMghgp
         +J7d3LX8vO1/3UzjzTE76ousxWFsupTtf7EpsCzKR7BCYfKdeLh2nostfSlDhaJG/cJm
         tIVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m16si38191338qki.109.2019.08.08.22.49.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 22:49:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 93EEE300BEAC;
	Fri,  9 Aug 2019 05:49:32 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 70C8F5D9CC;
	Fri,  9 Aug 2019 05:49:28 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	jgg@ziepe.ca,
	Jason Wang <jasowang@redhat.com>
Subject: [PATCH V5 8/9] vhost: correctly set dirty pages in MMU notifiers callback
Date: Fri,  9 Aug 2019 01:48:50 -0400
Message-Id: <20190809054851.20118-9-jasowang@redhat.com>
In-Reply-To: <20190809054851.20118-1-jasowang@redhat.com>
References: <20190809054851.20118-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Fri, 09 Aug 2019 05:49:32 +0000 (UTC)
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
index 29e8abe694f7..d8863aaaf0f6 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -386,13 +386,12 @@ static void vhost_invalidate_vq_start(struct vhost_virtqueue *vq,
 	++vq->invalidate_count;
 
 	map = vq->maps[index];
-	if (map) {
+	if (map)
 		vq->maps[index] = NULL;
-		vhost_set_map_dirty(vq, map, index);
-	}
 	spin_unlock(&vq->mmu_lock);
 
 	if (map) {
+		vhost_set_map_dirty(vq, map, index);
 		vhost_map_unprefetch(map);
 	}
 }
-- 
2.18.1

