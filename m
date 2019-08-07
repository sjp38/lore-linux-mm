Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD7EBC433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 06:55:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A5FF52086D
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 06:55:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A5FF52086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A89A6B0010; Wed,  7 Aug 2019 02:55:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 458E96B0266; Wed,  7 Aug 2019 02:55:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3477E6B0269; Wed,  7 Aug 2019 02:55:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1CAE66B0010
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 02:55:16 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id x11so76785415qto.23
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 23:55:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=DkgRyBFTw1NOJeXBoWug970nIMArpHVJngzRV71MoTc=;
        b=a3jZ+WLt8ZpBlNDnZZXFKaNZYGuMQNG1BAwBLNRdNmmQM51d4IQ8UkhL5T+SRTx7Du
         8nP+ZLTvyMt8LP5Xj/SLmvbQlZHLQun98tCInGuJ+a+eBBXxE8JgWY+bxE5mvZTpu15w
         PnipSKrz6+Ficx8JQGMwkiJ5zBlpnLKRr3uDKm0JjLlyqO+1DsVxeeIeLjFs3zFGxpBd
         frQ5QAuF7BfOHIswHev1TkHKrBB9/ihraYUg5wHB1vuGWoyoo7nVMzfmecHJm0/tdTsO
         ht2Aec0loTekTuADtl5xceLzzUTB90GTruERxMiEe9K1dNZGyOmhDpjGNWcaT2DXwBNd
         ibhg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUhQQ15ipSXWSbyDYt3Wbb1ZFiM+OG9BzIxktTOiw7CzLzINq/I
	PLk1hHfA6MTRFH+6euUNR7iTlIeQdwkc636M0gkV6uRgPJ80E87G0RW81GvoBO18bl++aiRICbE
	l7Wzch4w11mD67Z26JWgd240u3tHWI3AxMZUNqFiLhhBQFD412M7TsgTOm8viuA7O5Q==
X-Received: by 2002:ac8:538d:: with SMTP id x13mr536852qtp.223.1565160915908;
        Tue, 06 Aug 2019 23:55:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz5j342wrRkqPrrbkCH4R3ZZRQif1FdxuSzCSPx8kjqm7QHN+OpxzP+MxTOKFFF8TDWe0Ue
X-Received: by 2002:ac8:538d:: with SMTP id x13mr536819qtp.223.1565160915164;
        Tue, 06 Aug 2019 23:55:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565160915; cv=none;
        d=google.com; s=arc-20160816;
        b=R6WozALoPf9CRdJoCKWKCq0QTxANpVt7OQjwNmefT6s46kMo+pLMwkeOvNbtx+iu1a
         Ae3Zm4e7NcuDGqldvAq7NkiffPLgOA//K7pmwhEja0pNMTu/S5xlVlehmUBhKatqB7nN
         q+f4iRJfNQT6EwlKg2J6+CHC0Nzib6wLjEezv2AUm+5llmq2pgxdJ0WJexRtdbiH2TK+
         GW0ja5/ZRx9mz2emvaRAckydfgcRcb6nixM5Sdbbgch50dV2PQxz6F2vtnGzKck9jniR
         TwkkI8X8ZhYEJXOZIf1SoUcbX4J6okicH0HyQReG1H0syXsyM9NiOagDnVEK7GTuESYq
         gYTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=DkgRyBFTw1NOJeXBoWug970nIMArpHVJngzRV71MoTc=;
        b=BcuPhAgpeaUt9uBz0RqTafbc2u4NHoFfIl7bzdf0S1TnE9XqR0i4iWH9BQ1Dr6ep2Q
         BU9PTGXFJlAC4kjByT3IfBHZTSM0NIu6gLRAsokNLq7YX69yxmz1dd/6WHsQXKZNLp08
         lpDOSTJC8mdemX1H9fvFTMIpEqQCPx7pxtL7iKovS/nQZkiSwmjvmehSOUj1wCf+VAdy
         jqfMr4eMemftYe5lNSt36CCPFP0R4eXdNR7L8HQMlWizJhR3/3YspfEPYjt/r/OKjW5e
         ksJZRADMkj80nobv3TPDuXmoR6a+F/lvHyyWuKlmCjXF7ses04NeHG78vwkP2TAOn060
         Y4cA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j94si50642014qte.116.2019.08.06.23.55.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 23:55:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6DA583066FD9;
	Wed,  7 Aug 2019 06:55:14 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id E10841000324;
	Wed,  7 Aug 2019 06:55:10 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	jgg@ziepe.ca,
	Jason Wang <jasowang@redhat.com>
Subject: [PATCH V3 04/10] vhost: fix vhost map leak
Date: Wed,  7 Aug 2019 02:54:43 -0400
Message-Id: <20190807065449.23373-5-jasowang@redhat.com>
In-Reply-To: <20190807065449.23373-1-jasowang@redhat.com>
References: <20190807065449.23373-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Wed, 07 Aug 2019 06:55:14 +0000 (UTC)
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

