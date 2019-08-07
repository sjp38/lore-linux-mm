Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3788C433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 06:55:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C618F2086D
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 06:55:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C618F2086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 592316B026B; Wed,  7 Aug 2019 02:55:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 520B26B026C; Wed,  7 Aug 2019 02:55:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 40AA56B026D; Wed,  7 Aug 2019 02:55:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 227A66B026B
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 02:55:29 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id p18so4612543qke.9
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 23:55:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=B1luxMJLkB4TGmpB4Z6oIauGJZZAFOoy1m4euQKOEm4=;
        b=pUCg6+YLHFO8MECx9YZtcJCaCj39lSoOOCkDbWmMXdfx7maVZgx183S90QiYfuQWMv
         F0QjeqQSZaTZeltI4NMrU7nR0O6KlxSwknRJUMcgX4do64+Jo+iJGYP9dDVGbW6HgmHj
         x6JAKNWTwrIlUtlUJZyj2+vITazYKzaz+mbggzIfRWm15gcSE5DQuYB1zuiLgrd2CYkH
         ZYhUw1eMkMs+H6Nsem74Ode7nA+q2EE3q710bko9QoJH8rsmj3ihRDk00EvWuEqsCg9O
         vK1s6JHd8F9THDasaeU6DwroBzivfLedzlGbZ8zbCN4zkejmmaIzWTOli9iH6JFtKKjd
         dOJw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWJxY2a0g58R5Km6v1fL6m3JCDtOgk/jTFkTXaq2iDHiBRy6wyW
	Tf2TuguN88HDYe3G6YWHLf54ifnA1XsVp8Jar3d8SapohidIh69ouZQJz0p2p1YuTQbMSLv6pre
	ZIQeIF/AomS96MAbVO7rgRGxrlvUXmZKlqmo/AcBJ40HpD/3+51WAvfkEEn86JP/82Q==
X-Received: by 2002:a0c:d0fc:: with SMTP id b57mr6694880qvh.78.1565160928950;
        Tue, 06 Aug 2019 23:55:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJUWJepLoFU2/PZgUF73L8A8ul1PaUFelsfDjZ1R2rnH+HYU79bhb4lgS+dmZVnz9T2E2H
X-Received: by 2002:a0c:d0fc:: with SMTP id b57mr6694864qvh.78.1565160928435;
        Tue, 06 Aug 2019 23:55:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565160928; cv=none;
        d=google.com; s=arc-20160816;
        b=bwLa1jxwhjOKvJ3SzDjmmsIz1REtLYqA75BKsONNV9B+ZRudN0KuCuSCdwhJ4BvGNy
         ytSSGrKqN1zCjlVI6/vMnujQnMT4F8s9oNu+o7YwQsZm7y9Yd15NTNsmVzYzSb2/C60c
         JQoAU3O3x/Hv1gToS399P422cO6SHyZhxjzNUAn7w7xikH/2BzDnRKqUB88sipVwJ8bI
         NiAioZiGSClLByRT463MWJHhyE3jic/miE9rkVPD7rXCame1HOSDArNzywOruTKBsi3K
         p87W4aPGnu8KNeVHOTA6AZHmJZRGYp1iyZDf2HvUhMWpEiSVg4edi2uvfZupM3gfPNIo
         oYYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=B1luxMJLkB4TGmpB4Z6oIauGJZZAFOoy1m4euQKOEm4=;
        b=viMhoTR0cQALbP1Nup8YGd1RDTrPc7TBzpeX1vzrdsEeeYKggdwcGTIgd31Sru0lgv
         KjyCERzJYpSgFQE1xduL4lDZbcZZL1mOF8H7rQv+IHys4QILIllfW9ZpLicV3y57qlLN
         rmAmdMKb3pvvJRzL04gdp7qFrqkE/z42ENfd9O/h4wt9qV79hTksAwlqlBqVb4oObPF7
         DV41FCebs+VO/9Swt1USk38tdqTOY/5mdE1O4Na2uD8eyRCTWpDd5N5SVfXBrw9Flmfl
         CHSaxF1fZx43WODaiDMtRLjf7uQ0GYC2igApOJzWei4liuxap/ItIJp2FZB14/q0M5oR
         ptzA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y10si52993902qvf.166.2019.08.06.23.55.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 23:55:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id AD0ED30C5859;
	Wed,  7 Aug 2019 06:55:27 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 33C2A1001281;
	Wed,  7 Aug 2019 06:55:24 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	jgg@ziepe.ca,
	Jason Wang <jasowang@redhat.com>
Subject: [PATCH V3 07/10] vhost: don't do synchronize_rcu() in vhost_uninit_vq_maps()
Date: Wed,  7 Aug 2019 02:54:46 -0400
Message-Id: <20190807065449.23373-8-jasowang@redhat.com>
In-Reply-To: <20190807065449.23373-1-jasowang@redhat.com>
References: <20190807065449.23373-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Wed, 07 Aug 2019 06:55:27 +0000 (UTC)
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

