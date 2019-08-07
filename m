Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 076C6C41514
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 07:06:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD52021E6A
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 07:06:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD52021E6A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 78B186B000C; Wed,  7 Aug 2019 03:06:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 70FA56B000E; Wed,  7 Aug 2019 03:06:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5FDAA6B0010; Wed,  7 Aug 2019 03:06:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 43D206B000C
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 03:06:34 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id y19so81415910qtm.0
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 00:06:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=DkgRyBFTw1NOJeXBoWug970nIMArpHVJngzRV71MoTc=;
        b=iq7cxg76IqFv64V77wM4UJtYPaBgw22RMzC7SOILBv2x+xwSqipWnqyMEk5oHX+PL0
         97ts8ugUPyXGYJYgrgJEcyu0h2evIo/Hgx0z+oLsPp/tuZkV+6ouCgrWJ00VZq6dcZNZ
         3xkV2rGhSlVpTKEpOE0LmRzj19RyfBz4FjjSYdShZlBU7DrN3MuORPyZ30CKAyW2bh59
         1LtltFMIQXXDLNmMzwvlBaVFvQfJVKivcTrv43j/OzavnpUW9CA2wUiObded/JnT08eX
         xLiSraCmZk7wdD6K8qG+V3I+AM8cjiDPx7ZMeQPBEoth40Wvx5ByM9dfc8nYCAz/BxbZ
         e29w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVimcgL2w2GqH43+hOB4d4oqckNaWTIC+m+ZyT5gmGkF9rMUuJ0
	QLGbkdcGUv0Vf/dLvgVUdzQk6Zpw4qNUGr+jc1OxF0sqxRYq83uSRQYq6km8hgwU1Yq5IXlEA3n
	8UmIVzMKv2WRYop1WqXrgkWIj/Td74iLBGqgwPlD2o7won+CBpvW/B7qrg2nowni/Ug==
X-Received: by 2002:a37:83c4:: with SMTP id f187mr6701579qkd.380.1565161594088;
        Wed, 07 Aug 2019 00:06:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxGhD19P5WXbeQdswie9meitmfWG7kOoTboc79S7f+e26POLo6OBOWaApmCc+tC5/Bs7vPH
X-Received: by 2002:a37:83c4:: with SMTP id f187mr6701555qkd.380.1565161593608;
        Wed, 07 Aug 2019 00:06:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565161593; cv=none;
        d=google.com; s=arc-20160816;
        b=FTYJflfK2XvisGWJbrBcWYa9m3Jde0YHo9eb557WVR7bzHsdfhCG6Q47xHdLmJcL4Y
         p71iMovrBwNNZyXF8F1rN2fubMCyXmWmEDK95AmlcgTqC4R1xCigc/9PagfCztPr3EM3
         spojB/Nx+eWUyHP+VnpHl5vmiDknUiCxMVL37nEZ4HhBwPndbRPd4OeEyBfjPC+AHwnL
         hhxN9VAPK4WXwZQYY1ZjRh0OrzQuNhI69mAj8pd0bCdUc7YiEhhIPULkmmU1KVGP39Qc
         trv4PLpugQzmSbysfQpyKMxuM1t+sSdaleOjZKx1y7Nw+fD3N8zPDS3Pj8YyXuk9Y5bp
         S+gQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=DkgRyBFTw1NOJeXBoWug970nIMArpHVJngzRV71MoTc=;
        b=R97ypvQwebAkja+OXV2mm+eWkahUoHxeiW5WEBSJVughIqzy6oV+eDH7tJOaL0pMDj
         VcpojLC1ztgJ38jQbuE2WvrFMLX2wsodzl6PpP6QUWsoSWoxsKRJqbu1PGMNp8HGW43y
         hmzDCY+VmG8N958oQ1KJ2fkqm9wQBXpTve6+L3ORb6ujSJdxh1DPXnycORasOJgZUA/g
         N6oLXXM67FbK36CmV5mbYeICYhHyEWgD4V8YJq2fwQWMPqLuzlVrmMbpy2ZP6oaRqSgw
         LF6s0oLyaQ2xuNT0qKFiIIg396shWSWZoREhS4agT5kMbyrVAOjmXL5LnczvgucQbsgd
         ZqkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n1si48093616qtn.402.2019.08.07.00.06.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 00:06:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id DAE9C30B27A5;
	Wed,  7 Aug 2019 07:06:32 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 5CAA210016E8;
	Wed,  7 Aug 2019 07:06:30 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	jgg@ziepe.ca,
	Jason Wang <jasowang@redhat.com>
Subject: [PATCH V4 3/9] vhost: fix vhost map leak
Date: Wed,  7 Aug 2019 03:06:11 -0400
Message-Id: <20190807070617.23716-4-jasowang@redhat.com>
In-Reply-To: <20190807070617.23716-1-jasowang@redhat.com>
References: <20190807070617.23716-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Wed, 07 Aug 2019 07:06:32 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We don't free map during vhost_map_unprefetch(). This means it could
be leaked. Fixing by free the map.

Reported-by: Michael S. Tsirkin <mst@redhat.com>
Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual address")
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 17f6abea192e..2a3154976277 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -302,9 +302,7 @@ static void vhost_vq_meta_reset(struct vhost_dev *d)
 static void vhost_map_unprefetch(struct vhost_map *map)
 {
 	kfree(map->pages);
-	map->pages = NULL;
-	map->npages = 0;
-	map->addr = NULL;
+	kfree(map);
 }
 
 static void vhost_uninit_vq_maps(struct vhost_virtqueue *vq)
-- 
2.18.1

