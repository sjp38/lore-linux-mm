Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C782C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 08:47:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3AA9C206A3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 08:47:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3AA9C206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB96F8E000B; Wed, 31 Jul 2019 04:47:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D8FF78E0001; Wed, 31 Jul 2019 04:47:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C7FF18E000B; Wed, 31 Jul 2019 04:47:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id A97E68E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 04:47:37 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id v4so57329721qkj.10
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 01:47:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=B1luxMJLkB4TGmpB4Z6oIauGJZZAFOoy1m4euQKOEm4=;
        b=YMfFMS84zmpKGh712lf2SvZZ9ffGnJdyn3oJtFyrNuOJPIyG11ElgHBtASBeJoLVV2
         ZKMe80zf7wvNm9q9nM90dX9fbrx0SWQQXXbLcKHCkBC55qW+jAfYLYci5ScyVvpGXtSV
         0swM1D2Zpju8TDHcpSmAIUGba+d85SVZYwmlbeMCYO89SrBbbXuQxMYy0AglegG8AY8G
         uNxLz89G/jZgcP0VJVYJXbEEYHpgwcvPDOrbW2Li1vBLg3jWHNAEgr+jncia+p+SpSq8
         7AuhT21ahph1lW9QbF/7b4OT3r/74cS00NQPaGGdKmcdaIwB3RBkawGLqYl9pUkxb33B
         GS7A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWQ3A5txBLtW1TulXtyt0AfIMVQXOt1a9kein/lZYXVuRazMEKe
	yqD1/xJ3FtPxTlAhVHubto1nyL1SNQn1LDDTfhCvzsRv812wJecJYYbJK1kQqkAvXORPfUTiV73
	nuMGkr4KktSnE5UDgcEgU1dP8S/wOvl3P4V+oFA2zqHLnPLalOkUYnPEuSgHoHy8RXA==
X-Received: by 2002:ac8:750b:: with SMTP id u11mr83595988qtq.23.1564562857488;
        Wed, 31 Jul 2019 01:47:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx5sWjiUd1C+sCC4V09L2A+3dCmClAe9xUEjA5CMYtnSFdGRzbqh9MQnw8b874OywyyDbuE
X-Received: by 2002:ac8:750b:: with SMTP id u11mr83595961qtq.23.1564562856965;
        Wed, 31 Jul 2019 01:47:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564562856; cv=none;
        d=google.com; s=arc-20160816;
        b=P4NEVPtf3pIOL5Fl5+puww5IP4amRRe0rFPVYJ7us1wF3ObAvy/MRknL/L2BJ3A2HW
         FczRyfikzWm5SQqcuH4C4Aa+AoQJLz2+QE/oBMawUocoRQT5UJFnjzn+WrjXiEkvLXWC
         2whfFOX3/WbXfvsa0cFO2QVsMrAKq7/+tkIhvIDpL4+m91HkVpNNjTVmxNWfNsBeLumE
         hAVnXYiZ+tr1TPFHO/MLnkAEVe+HFtj2g18AKgpAJmzEEKzIqtYpPnaB6/XlZjbBRxVZ
         bDvSsCUhbDqlPJvVBlhwC/ZTsiw0Cvn0OGU1AxHrA/tFHdX/Yywsxj3tBiOHHW7AkgAE
         iqUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=B1luxMJLkB4TGmpB4Z6oIauGJZZAFOoy1m4euQKOEm4=;
        b=cWA5ySLKN3vBXEVdvM0aCqz27YNIguZWYJ1vXSI2iPb+nukn8qsJbWJ6122xkWSiMq
         +k4mpEdygPsuwZnW/OZTnwkNC1gUtd9km9KH8hfnpP91FPcLYefFvRrhHwYGgqJPrNj+
         HK8UevPi/E4EHBdu9v23rCBBCM09Sfw41xhsDEfdBYWn0Ym/mUoPjSxwoVVlA1bxmtPR
         V1XM6H/H63yFIKg3YV/3pfAa2kFq7a6w5/7mAtgQHIuQCUy+a1dXRX2jxHIFK/tWeNAD
         QmGZ7XelLVLbuy/IKMYbAmiFesi9cSuo3EBZFXPPJ4m3Br/sEFvPwUkj3z8isBr4A8H5
         3xbg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w1si36331643qkd.138.2019.07.31.01.47.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 01:47:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 31CC531628E3;
	Wed, 31 Jul 2019 08:47:36 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 62DE06012E;
	Wed, 31 Jul 2019 08:47:29 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	jasowang@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	jgg@ziepe.ca
Subject: [PATCH V2 6/9] vhost: don't do synchronize_rcu() in vhost_uninit_vq_maps()
Date: Wed, 31 Jul 2019 04:46:52 -0400
Message-Id: <20190731084655.7024-7-jasowang@redhat.com>
In-Reply-To: <20190731084655.7024-1-jasowang@redhat.com>
References: <20190731084655.7024-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Wed, 31 Jul 2019 08:47:36 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There's no need for RCU synchronization in vhost_uninit_vq_maps()
since we've already serialized with readers (memory accessors). This
also avoid the possible userspace DOS through ioctl() because of the
possible high latency caused by synchronize_rcu().

Reported-by: Michael S. Tsirkin <mst@redhat.com>
Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual address")
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index c12cdadb0855..cfc11f9ed9c9 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -333,7 +333,9 @@ static void vhost_uninit_vq_maps(struct vhost_virtqueue *vq)
 	}
 	spin_unlock(&vq->mmu_lock);
 
-	synchronize_rcu();
+	/* No need for synchronize_rcu() or kfree_rcu() since we are
+	 * serialized with memory accessors (e.g vq mutex held).
+	 */
 
 	for (i = 0; i < VHOST_NUM_ADDRS; i++)
 		if (map[i])
-- 
2.18.1

