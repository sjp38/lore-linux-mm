Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D13CC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 08:47:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3DADF208C3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 08:47:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3DADF208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E2E978E0008; Wed, 31 Jul 2019 04:47:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE19B8E0001; Wed, 31 Jul 2019 04:47:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CCE158E0008; Wed, 31 Jul 2019 04:47:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id B4B448E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 04:47:13 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id c207so57322370qkb.11
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 01:47:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=DkgRyBFTw1NOJeXBoWug970nIMArpHVJngzRV71MoTc=;
        b=VhP/5+cZnrUBCicfOT/Tir2pz4Eb86GmFkvtDsLEdYQCbXnGlscikOi0gJYHbad/iz
         PuXruzSmY0eShbbOcR7UpVJNh5fuyhSqfqP9VvWBXeQ8ElhSOQTKryRALIKkoA/ytK1a
         T6pQCshjmDTCGLPfm5BXx7ANf4QhHk/ODWyOEXY/b1CI+RAUvOS/4kjRDmMdCGtAPL+m
         thsY2tyk8L8vsOjXI+Rqo1hWvCtmdlvsy4ajRMqdFM6hcxQ3X9+Zg8M+z/jYbXUosKNe
         3WwV8BirSWByEJnfIxMB+SAyt68r3m50A3JoLZ9o6Lwq6MnClIF0uAbUXOyOdbLqg8qM
         1zcA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXt9oMkQLxt9I37JxO0ze2F1OzrHo8J6FkrXz3yRfdAsGSsve4A
	n9IpjTEWWjatQ+yALBlaelqKBKG6i5QicIbixZgowMlRJ1rkEZuGkaRtGdwhd3gmm2jNwIbjtZI
	w6k99Ep1IJftSfBLhACf8DoV6anbGD4RaX+XAGrJY0nf9lhvd0EVAwpdW7JtCLvdRKg==
X-Received: by 2002:ac8:6b8d:: with SMTP id z13mr83197141qts.86.1564562833520;
        Wed, 31 Jul 2019 01:47:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxgG8XKPC2RPn+I4Nnxu13CYb49Z90rzYi3Fz/BtvHW5jXGjJ2TxhkEmbslFil7tcyjmJ5e
X-Received: by 2002:ac8:6b8d:: with SMTP id z13mr83197128qts.86.1564562833004;
        Wed, 31 Jul 2019 01:47:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564562833; cv=none;
        d=google.com; s=arc-20160816;
        b=XaSaju4B5rTMw4+y2eA3r13X3C14vBVYMvXqMHqMSsgNHOGy6hiqEYvvwbVzZlgPoB
         hrZhkr18kPlQuOUBobY0qWnIMh8XCkK54knb6qqsjUAAxkttiRuZXijL4qxZAb3tm6ue
         1ZpMUbI+fHHLQ54en83H/XYhlKcysEtxeI1so/+9uFEsX/Ip8qs07isoyOW2YWSOWjCg
         jCDxP2elc5x1+h+0yIGwwJMq9ODOnhfM2YW2mSHsSFz74JLE305aXaEVLHgzpf5vIEyG
         Y/jvMUSfOkzQTGZSJsHHZtCdRKw/kvsQnQ6O8P1eU8wcTqLVQsZ4du6Otq2Yeq+0mRUi
         9/gg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=DkgRyBFTw1NOJeXBoWug970nIMArpHVJngzRV71MoTc=;
        b=FhyaimjRYoCgZdDuGVvxCi4HOIYR+PG28QSdFexkjLdOIMnYCVaJJRTifkIcpJ3dDJ
         +lwDxrkpoNM3OtuAapW5L5Ubng30ziKN/fI4zm6+zlFyLmZp22wRfKv3N9ZRzTnZx6ZM
         MrYhXxJxSaIvxcmh9T7pR6N+lQPiNEA3bNmHzD1c5EtoA99Yl9KXxSEyVxuJIVZiZSpr
         FDvvTE6HTzCHiJ0+W/vgOsdKIhY74Q9lZRXVTEyB5msn+4WluHyhFr4h86340TPuJZg/
         s138gxyk4Zezv4tw+jP1QnM+Doc3H2dBIq0JK6iZCEBLhIZvvFEAy4hwRPLpSVrLtna5
         Kk0g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 128si20297612qkf.348.2019.07.31.01.47.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 01:47:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4E9347FDF4;
	Wed, 31 Jul 2019 08:47:12 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id A079A600CC;
	Wed, 31 Jul 2019 08:47:09 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	jasowang@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	jgg@ziepe.ca
Subject: [PATCH V2 3/9] vhost: fix vhost map leak
Date: Wed, 31 Jul 2019 04:46:49 -0400
Message-Id: <20190731084655.7024-4-jasowang@redhat.com>
In-Reply-To: <20190731084655.7024-1-jasowang@redhat.com>
References: <20190731084655.7024-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Wed, 31 Jul 2019 08:47:12 +0000 (UTC)
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

