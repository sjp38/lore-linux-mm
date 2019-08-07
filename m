Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5EDF4C19759
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 07:06:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 312B722305
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 07:06:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 312B722305
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D08826B0272; Wed,  7 Aug 2019 03:06:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C43B96B0273; Wed,  7 Aug 2019 03:06:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE2646B0274; Wed,  7 Aug 2019 03:06:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8AD9C6B0272
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 03:06:51 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id q9so2033313qtp.20
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 00:06:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=emOCY78+qYrPzYEsa6BTu0t1qLH1xOVvjmlFjmRfsdo=;
        b=FP3XHinKgRS7ahoFgcsn+gnq+uRRnHc0jMfMQjZgZpAHaDttq8Ub06rD/6Mff1ct+R
         ljhyw21DHINadm0CVsBaL5K1wwvSQTAaGLDh8mhljbCL2jm7UZPCj2cF60tpg/KULWBR
         mdz0zooayRCDls6AIXmZPCBZu1adSCJim42PvsTN3Eay2IGBVmnsti+p2yp/S17x2E4u
         yHPbnKAYFcpswI0ItcqObWGa8vTbE8g0zWx5DEdujME0OO+NQ5fp5dBh70x7Tjq9UEWa
         Rm0dGxL/ZM8p1dDDuiLLn3qQJAsSIF2iA1IgCUkv2StsBG5J1rsQNHbtx50Z3ikXw07M
         YTUQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWJGq2N7eFR0Lz5OhS1As8Av824vYsgNKfpC14md7aRj/+TsXPf
	MJuDu7ZWlO5Lipm5AmMtnbVj9oBPrwHkXXTRiFL+Kg+PLcIn8xqzpYq/AEw+QuPtyQtVwZ1Ukdx
	uBsih8uQysdMLODnACKxobI3Af3Ho9x+rFK1JyLo2K4v70aLPgdVRuf5rYFgXo/3YcA==
X-Received: by 2002:aed:3b02:: with SMTP id p2mr6887031qte.62.1565161611364;
        Wed, 07 Aug 2019 00:06:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwCoixfDiFWJyWpiUWjfG5BXTp2y2wsOZlKh0O82SPyMEMIgoskTWO2tnsGrUIlww65hiKd
X-Received: by 2002:aed:3b02:: with SMTP id p2mr6887010qte.62.1565161610865;
        Wed, 07 Aug 2019 00:06:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565161610; cv=none;
        d=google.com; s=arc-20160816;
        b=dZHEGjW8J6zX5H9AxuZ1Qqh7opEyoVtHKDs9J2EsrXzJRn7iJoF5oobfW8/ltAaOB5
         0riA0TgSG9m/1ebfdMIbyUpMiEAav6ObLKbnkDA9TBOWxLwFmmXlmNHsR98wFDvn/u16
         1+Wt/DX2cy+lBIAiWI7HTKLVaRZHzkBH9od8dMc/TkQsKFsZ7H5wLA+7VLf6b95MvIDe
         DN/u35rZKndTq1jvEOsOzFkNFqudxniqj8AO8pzBIaW1RRAtT/mOVCkGFzaSFmp3nYVz
         3BH2bJiPqFn+WhEg0q4vcXo0k7pGLJ0zdrILBpruYbDcOFnO3eq/a2sPKkEJ8FOyrdbx
         RXmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=emOCY78+qYrPzYEsa6BTu0t1qLH1xOVvjmlFjmRfsdo=;
        b=UDRg7IDmVD8sCr4hM0/vwB2eRnijAXun66v0h1EZX14a6WETxbeBxqCuIVocd6BhkR
         p2xuY9hFCC2NJQ1EvlPndZhba4Xn3fxhK30/gqFXjyUXUrormUPoiJNTAAmHJBXJRmtF
         CEbwi9EA4OVG7EYvUYp+g8NUy2CxLSKWbGm0K/rvTd0XtZ7XH+6KpVilYsWbXBOTfsar
         j96BgcLzGBsRDRLh/6wE3XTD3Yfl85QvubW5znAnzzg97b/4wBlvxXUneFhXyJQEuKcf
         GElZuqE7LI+74Nw+5mb43XhOX7TCMDOQbSzgZfO9Fls4p+3/imtNb+m6rXBf1sowvkpQ
         a8tQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s26si55048929qta.169.2019.08.07.00.06.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 00:06:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2E6E6CAA6D;
	Wed,  7 Aug 2019 07:06:50 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id A4D861001B02;
	Wed,  7 Aug 2019 07:06:47 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	jgg@ziepe.ca,
	Jason Wang <jasowang@redhat.com>
Subject: [PATCH V4 8/9] vhost: correctly set dirty pages in MMU notifiers callback
Date: Wed,  7 Aug 2019 03:06:16 -0400
Message-Id: <20190807070617.23716-9-jasowang@redhat.com>
In-Reply-To: <20190807070617.23716-1-jasowang@redhat.com>
References: <20190807070617.23716-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Wed, 07 Aug 2019 07:06:50 +0000 (UTC)
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
index 57bfbb60d960..6650a3ff88c1 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -410,14 +410,13 @@ static void vhost_invalidate_vq_start(struct vhost_virtqueue *vq,
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

