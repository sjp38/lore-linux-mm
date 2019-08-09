Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C019C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 05:49:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 101592089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 05:49:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 101592089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A9ABB6B000C; Fri,  9 Aug 2019 01:49:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A4F516B000D; Fri,  9 Aug 2019 01:49:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A8D46B000E; Fri,  9 Aug 2019 01:49:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 65C4C6B000C
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 01:49:14 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id d203so6502679qke.4
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 22:49:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=QiaTlTQOPqg5IgdYAWRREFpZ9TwRpPDQdSyP4YgHR84=;
        b=LbR9MRuHHJK4tfuTe87n6wST0c+J3Vb+P3Rs8kIyPVZVvSHCrC6bCDhEeRO0Kh3psM
         LaGZfJpvzvfGEsQ+FRel6i0l1DvoMpz2QbLh6XVCuzL69M2evr+bW57sW4s+FwF/mfdz
         i2CGD6yH7AqIlX4PUux3gijKNGguYjRLus6R9xwc9cZXeEzXDOm++SBaUVcrxvYQ8tt0
         /YiGb5bxkztKyrtOSsIcAf8obIqfmeIggVyj/aNPXzLFwutfxmtdKBKi/i+Sa1rebFXL
         qjZphMwB0KXkiek1vTswI0uabCfPm86G9jZjsbVrBUir6V8/TCMLTMD9P2gEnM9Gw8QG
         NjGA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWQvwICAJSmUzAh+IIElZvc4zlGSyt41Y2EZA8f18h0582yC8TS
	XNAuTVWODEHjR1LrErfFrqma9NRB5u55WQhVPZwS0nvZM/F2LhYPVBF+9BSwAhrvjrOXCjvTL09
	/iKYw2S3juA5JjArSsKMcljf7eadmQrH2h/RsXlAi8JJVvd8bP8K1w5hwiKUvx3cacQ==
X-Received: by 2002:a37:f505:: with SMTP id l5mr16954705qkk.235.1565329754236;
        Thu, 08 Aug 2019 22:49:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyFokIeOhDrnV7mP+Eo9zgMIV6Me38P/GD2UxN/eKK9Cq27O1vsS1+ttQBA5Yl37EI3xN5n
X-Received: by 2002:a37:f505:: with SMTP id l5mr16954686qkk.235.1565329753695;
        Thu, 08 Aug 2019 22:49:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565329753; cv=none;
        d=google.com; s=arc-20160816;
        b=IlRpl9W7DChkxCHU4K+BPE5hf9idiuKqsQ9TAgA7xidJrZs3QJHYKQ5YniN2aYIHsx
         9DMZShuRJfcrnhxkDrF61cohrggPUhPWRy22KqAJHOxWWSnajZNqoiyWSq7C4sTcdqG1
         Fe0txdD1Iuh9in9+ZwpgjNiUAMZc6jUGZn4LRL0RfupipYimQ3dfK1+HjFUv4dUmPTtB
         ubIJToCJqAa9gqx8cn4pQfHVsVSDWbx4+vXsCtIjH6N//4DYzzuVZ0aH/2iduYUw+DRZ
         SMuj/F2ogD5qZ2KT/1m0AX3xXPJWhLGyIX1/ZKT2jb6FRIEFWXXdOpEbtNySuFr3mDTA
         E/NQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=QiaTlTQOPqg5IgdYAWRREFpZ9TwRpPDQdSyP4YgHR84=;
        b=DwSLjHQ0o2P0oRACVuN+Rr7c1ojS8BnQ9jA3M9b0Ndne2RfxjizFj6JnCTXtZvFVxt
         QNS4/0+oOg5aFvw8dOv6Q0MpsQZGP8yu4EMXXxBar2EYvJwFP9ycukY11jjbMvkcR7rj
         It3We1nY7uUBwcULZ1W2wN62WlCkAkcrbkGNZRAfwp8JjqBToKbAqxxo0l1x/4KB7R/1
         m1dRJIiqx3+3k7QZ71r5+EcIf79Ejov4H51EKSSsvQgoyabwJrC6sK3CKVKXDOpQHgAp
         W2QHPEkdF+rFow39P8cre90kY+t9w5Dd1IQNQl3jnUqthiULFS6ylYT8LT9Rw1J6HeLT
         d5nQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b185si52719662qkf.40.2019.08.08.22.49.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 22:49:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id EC9E281F31;
	Fri,  9 Aug 2019 05:49:12 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 7054C5D9CC;
	Fri,  9 Aug 2019 05:49:10 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	jgg@ziepe.ca,
	Jason Wang <jasowang@redhat.com>
Subject: [PATCH V5 4/9] vhost: reset invalidate_count in vhost_set_vring_num_addr()
Date: Fri,  9 Aug 2019 01:48:46 -0400
Message-Id: <20190809054851.20118-5-jasowang@redhat.com>
In-Reply-To: <20190809054851.20118-1-jasowang@redhat.com>
References: <20190809054851.20118-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Fri, 09 Aug 2019 05:49:13 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The vhost_set_vring_num_addr() could be called in the middle of
invalidate_range_start() and invalidate_range_end(). If we don't reset
invalidate_count after the un-registering of MMU notifier, the
invalidate_cont will run out of sync (e.g never reach zero). This will
in fact disable the fast accessor path. Fixing by reset the count to
zero.

Reported-by: Michael S. Tsirkin <mst@redhat.com>
Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual address")
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 2a3154976277..2a7217c33668 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -2073,6 +2073,10 @@ static long vhost_vring_set_num_addr(struct vhost_dev *d,
 		d->has_notifier = false;
 	}
 
+	/* reset invalidate_count in case we are in the middle of
+	 * invalidate_start() and invalidate_end().
+	 */
+	vq->invalidate_count = 0;
 	vhost_uninit_vq_maps(vq);
 #endif
 
-- 
2.18.1

