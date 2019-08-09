Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52254C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 05:49:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15E492173E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 05:49:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15E492173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B5DD56B0006; Fri,  9 Aug 2019 01:49:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B0FF96B0007; Fri,  9 Aug 2019 01:49:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9AF726B0008; Fri,  9 Aug 2019 01:49:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 807796B0006
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 01:49:05 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id h7so749463qtq.5
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 22:49:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=hXDPuh5Kn7pFxSlRRDrUdecWVXcCQZqbNwxxDsR27Vo=;
        b=DrGVSPxhjpUjgmnu6+b7CkoDy1Ehvu2Dm0MLoZp3jXEgXPdi5bU044r1OYq614yybe
         9SfUObfXWUoKEE93iVgIoPUy3eGYzsA++szIOhba1EGgXBnaJe8odB9M8VDU4s4wZZsx
         PVY2lSzCXAX7xiOEEBptm1pK5pze4nIjF+aOL0BUr5mBJr6QTDiWqtumCEeIbpJvTYWL
         X2WCQGqbYM50dGkDlcpX7BhMPPjZNyiN7ZraXS0/LfIOcoC17pBsgRmprjm82xga8XmS
         g+zBwgJqEiN9NGnmnbN4W5fGtWvQnQwYuemtbA/xx9QEqn5AJ9gcVuGibSHzaJBh3nXo
         2Tmg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWgMhZcP4/4b3UbC7xS0GclAx/nreNBy6+FiY0D7Px917csjwPN
	oR0tZwcBOFPhJlNfnR5piwX0a0gV20ozkNsLr3/9TjkLhRQQIXYhrjoIcHmM4DxtcZrzU/zGLfb
	Aj6pWF7hd4UKKiOMIDppMPd9rDb+zt82pwHo8rwwt6vtMa3tUo6W5pFcMiwejlZRxnw==
X-Received: by 2002:a37:dcc7:: with SMTP id v190mr16991806qki.169.1565329745323;
        Thu, 08 Aug 2019 22:49:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyzc6zPGFLAKqaVA/8m7Y16ZVyVIWiBo6JnM2Sl0okJDuAPYyNnZe/xYK9IiDK8G/KO7BlG
X-Received: by 2002:a37:dcc7:: with SMTP id v190mr16991788qki.169.1565329744809;
        Thu, 08 Aug 2019 22:49:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565329744; cv=none;
        d=google.com; s=arc-20160816;
        b=SQkt0Z4VyEYyW4UpMtK9QVaxn/TDImFhLXRaO1k4nr1CR0ZiSjrzZmMNMtt76Ii0fY
         OmzpRE847zyfW+8orMasOVTYHhUTqrU5LhO0tfLk9tNyJoxIf76/S0i8o8yE1rJysg9O
         407bgdRrKxQyhRtBQMfI3ABsUgbBxUBoqZRlnzUGDbQsUITOHZcvPKk0yCn4tcfbvnA1
         UrrEd2LD9/AZr0eBrNrjAEHe1pjSn0ObIY0EBBvnvo3AUY8p+qrors8chnzFqZaHeqrD
         4gXZouedwqQ6J/46Tq4L43YYuSwx2bTkHD6jDpW8nXf4ck+EfZ5sIXNjVwcWz4U+VtRp
         06zg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=hXDPuh5Kn7pFxSlRRDrUdecWVXcCQZqbNwxxDsR27Vo=;
        b=aAOWncHdISozDhqXj4xAvC5WqU5z7s6b8GKLmDukV/ExjXR18sYZqnJ4oLojaAinsK
         dm8Dfb6XUiyp7dNkMsVLsBpCCM1q2H7llRW0rtoXlW+4S+7SFrSUsse3wcZbYWuAKhKF
         sL+S4ITxIq58F0r3RHyYoo8wcrGqmQMJaNA1BhqcfYD4RbTF1Wg9CjnBimLSE+rd4M9F
         l2vS5o5X/+feoiB/7xlqGnUe6vVOnbBoQwmbUb98DAbZpN9+43pq8QzOZ22V1jIS5efh
         8U8CaPjDg/R3JieToWcPOPm1ClcXzAExLLV69Fs5IfxsQekYRPci5zrM0Idkw34FF4aT
         h1Mw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m12si1886618qtf.221.2019.08.08.22.49.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 22:49:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 07BE830FB8DC;
	Fri,  9 Aug 2019 05:49:04 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 7F6315D9CD;
	Fri,  9 Aug 2019 05:49:01 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	jgg@ziepe.ca,
	Jason Wang <jasowang@redhat.com>
Subject: [PATCH V5 1/9] vhost: don't set uaddr for invalid address
Date: Fri,  9 Aug 2019 01:48:43 -0400
Message-Id: <20190809054851.20118-2-jasowang@redhat.com>
In-Reply-To: <20190809054851.20118-1-jasowang@redhat.com>
References: <20190809054851.20118-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Fri, 09 Aug 2019 05:49:04 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We should not setup uaddr for the invalid address, otherwise we may
try to pin or prefetch mapping of wrong pages.

Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual address")
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 0536f8526359..488380a581dc 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -2082,7 +2082,8 @@ static long vhost_vring_set_num_addr(struct vhost_dev *d,
 	}
 
 #if VHOST_ARCH_CAN_ACCEL_UACCESS
-	vhost_setup_vq_uaddr(vq);
+	if (r == 0)
+		vhost_setup_vq_uaddr(vq);
 
 	if (d->mm)
 		mmu_notifier_register(&d->mmu_notifier, d->mm);
-- 
2.18.1

