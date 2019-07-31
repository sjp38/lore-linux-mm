Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 065D7C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 08:47:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C769A208C3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 08:47:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C769A208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 666878E0009; Wed, 31 Jul 2019 04:47:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 616628E0001; Wed, 31 Jul 2019 04:47:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 505648E0009; Wed, 31 Jul 2019 04:47:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2F2268E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 04:47:21 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id r200so57502069qke.19
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 01:47:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=QiaTlTQOPqg5IgdYAWRREFpZ9TwRpPDQdSyP4YgHR84=;
        b=oOPAZjZdV/JnA3rnLnv5BASWPtRM9yPgxqi3fP1puMnfs6HphWsCv8W/Vq5VvtG/W9
         3j1vFleU+UZhjfEGDIQvRmzQmTY9WPILICGQqT9kj1W+J1MEtVViB19uzYDvGC0X7Ot6
         DCP+CDsHzZ5xizzbkWyrJNxOX2b/ItZhNebSLKotjLXS4VAQHNeEh94WAaiCpZKCnWPX
         JIeNUGxkDvb0vl5KDsa55BlAIVtogIOrAg6rQa8hg6tlZQa1mCThZkgwW1iseqhEdz5i
         Hj4kCXvmBnH/EKbz/7mTkTO8blDo6QYti0ng5XBjV2ZZAjHEDGbL1IjDr+e+htb6HCZz
         4Ndg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWVxwyXg32LEzxOsE38T887X4D6VQmE2yZ6N11CCyKzTjoD0Bzk
	CPR/1lgimUXO7nMJFe8p3EOlYg1JLUi4AeNqmWUF5MTq1dHzMhWWeDHQAF0vsreMmeDomBBk8BX
	mtUbdUzJ32BDiTuBB8aDDif3J9jgSros01Hw6e/Fh+ehegEp08I3KfO1kE975yB+1pQ==
X-Received: by 2002:a05:620a:11ac:: with SMTP id c12mr78270811qkk.232.1564562840979;
        Wed, 31 Jul 2019 01:47:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZLxtcM2PjRYkGUxjn7L/vtTP0Ht8rOU8oHSJToA8Z+DXhNPNwUCrX4C0GrTxCleA89OnL
X-Received: by 2002:a05:620a:11ac:: with SMTP id c12mr78270786qkk.232.1564562840337;
        Wed, 31 Jul 2019 01:47:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564562840; cv=none;
        d=google.com; s=arc-20160816;
        b=HZMeW/eHgal1ZXAa4VaipYb1OvtjDAcOJY9lL4E5DSmY36ym436rkru00GEj2n0pLw
         rXnj0gL5hCJGVd3ziLUHRc0F98odW2HVqAJbj7jDwzK54kGbAQNfSkhEQi5lpOnLOnv4
         5azTX4bq4y/GyWy3KrQCCuiIxHeaBXhCI8opGJMbwfjzjBoi8nVKm2C0jwIws4w/nytu
         tMe8Gvj1VUq7FVSKGGXdIeX1m/Qy8swKGgXG6b8qSuZ5zn6GyGbfI7EYCf2oqlqtXtQD
         x1MWVwZ0UjaJrNqnaSI0r+VH5wEKhWhVaqS5uvyGnketuQCbWfJmvOo2hCK6ap19mfYP
         S23g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=QiaTlTQOPqg5IgdYAWRREFpZ9TwRpPDQdSyP4YgHR84=;
        b=nraJyi7a/cOHEPiNigE4A39uYYCOjQZvp+IJwBtQyIGOz47kq8rqwZ7Ld11ImTJmd3
         65t1PzpvvuUwyR1eI7dpjor7bfZxjJlVI4EcP8bUIOfh/CsyukMmVMPJiMgbN2p+6sEV
         qgEhzlQaK3mXPfCAV6I73jeR5M9CnBbFrhlFUNwv0byQ8N3mqzI78zvaiyL5TB9RZYkB
         Z1Ta7sNUUvK9M7+GjBqrZr8CduxenC4yuQ5Nhrsvp4pFYEu60PPd3FFGvwQSdTtMcjea
         Y9sqitwgpknJcAMlaIQyBUu75/Xq3++oPZxF5mwnWh6TDzX6lCxpIuYPjl5slHAs9XP/
         sPWg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j4si36984043qkm.152.2019.07.31.01.47.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 01:47:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9BF10300CA4E;
	Wed, 31 Jul 2019 08:47:19 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id E79D3600CC;
	Wed, 31 Jul 2019 08:47:12 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	jasowang@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	jgg@ziepe.ca
Subject: [PATCH V2 4/9] vhost: reset invalidate_count in vhost_set_vring_num_addr()
Date: Wed, 31 Jul 2019 04:46:50 -0400
Message-Id: <20190731084655.7024-5-jasowang@redhat.com>
In-Reply-To: <20190731084655.7024-1-jasowang@redhat.com>
References: <20190731084655.7024-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Wed, 31 Jul 2019 08:47:19 +0000 (UTC)
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

