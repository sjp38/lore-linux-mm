Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3BE8AC282DD
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 05:54:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF56420674
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 05:54:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF56420674
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AC0406B0007; Tue, 23 Apr 2019 01:54:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A6FB06B0008; Tue, 23 Apr 2019 01:54:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 936816B000A; Tue, 23 Apr 2019 01:54:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6F4706B0007
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 01:54:39 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id e13so9177113qkl.8
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 22:54:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=Fc5tzu6C1dq4dNrmHXxBLR13rAWvqP8agDt0wYDJxgY=;
        b=JcsAAubcygl0Wdvoj8lLKiEFHL7vhRrW2+7aCZNQ6FKiBGsebyH9qsm1j3yE52x9uD
         H43UwvWH3A0dFQv7AkJs2L1HPTVrxwWVS7ag7uddfLW3M6RbQsJW7buJO7cupCkSzaN5
         J3tQ8BbSbsb4a7XKidoCc82SYTO5nRuAF9L6RAXRP+R4P8PexMAXf1QmnHHiMpHS1xr5
         /q5yhQ37bmylwBFPe4envP962YYEuFfIQqcV0Vw2hLaYnE5bv2EXIa6GeHPdWL8s3dTT
         /N5eIBcZhIgdj4OTHzFjBQs6KQyfIP/0s/d9Z1EfqyA/uD/KvcJTKfpalJ6eB1iD1mpJ
         YjpA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXkLailYmwP7idzioMyYmxwAH8ura6244P9XhO62rrynQdTrw7j
	X5MUX6xYNc/Cml0PV90xC+Zwh1EDuEs+fFUOiuq/Fs2z+/kPeJz6MSXREWkXWpUD3VfxkNAyG1K
	iPS/RY814Lv9GN95OZJaX3uWA12Fm1C1AznHwisc0eiwIzOm5Hsz70H2fV/k1aRYI6A==
X-Received: by 2002:a37:2e43:: with SMTP id u64mr17143508qkh.340.1555998879219;
        Mon, 22 Apr 2019 22:54:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwBfl2ycdXeWxC37tN9xu2nicVssqquFWikJM53KZ+zCGF1gQCMet+Dryia4J7CfV9Rzek8
X-Received: by 2002:a37:2e43:: with SMTP id u64mr17143479qkh.340.1555998878198;
        Mon, 22 Apr 2019 22:54:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555998878; cv=none;
        d=google.com; s=arc-20160816;
        b=dBLUXwBYdklgjnF+CKf3PyKCRTsrnOt+fcQslrzoRVbIKe6Q3gxmqXwu0kxITQkBB2
         0IB7wC0Ju/Os5T49+6a4xpMzB4hqMYNkHiDKOdEiNKWxT6oomrjL1xrnbU/8k8IZIudI
         tawHAlDd9/51bBxzDLBgVxtpvrVV0ATflo27aOKCdUZRYN2vUg6cY5lgrfF4Z/Gcpq5X
         wlNJrUvn3oNJnjhRh4v2oqvtNWAHxd3AWtgx03aWtnATajjlu5ax2y/Gb8JOVkwvlGTb
         OmMQoK45foJPa3w0mkuhP2x8lH583MSzAWszji0eGprPo6XU5mon+EIY/uXfUUspnyS/
         MxgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=Fc5tzu6C1dq4dNrmHXxBLR13rAWvqP8agDt0wYDJxgY=;
        b=ncWkyfGd9hPRw1pwDmuK3eOGpgcTwYuYh5IOnqtFlljWbPt5NLh+ou+1ipzPdSCi1P
         /QyaHTP6QqEup+r/Re7tWBvwKRXy7V6aJ3hBsOazZNe3hcof05qvVmY22r2DmWiWcIz5
         0uCPrANcGisxCJmSEtO46JMmVTqmbKSVQkF5hoE9aZP1KlWTwoiwbSFpHjOl3G2HpJOb
         CaS4uGvfgqjZOSvpb1nmMfY3LvFnIpeaIngTSC3e9oKbEryOZO6hAHUpgQy0FHRehaJN
         +0M4Abwk+vm0YptRGTOd2wJ4RgEcdSEw4WclHIkSwFSjt+G/9cGTL1iSoDv1zp9XPEOn
         HkfA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 7si3742853qtz.236.2019.04.22.22.54.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 22:54:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 62C47307D8BE;
	Tue, 23 Apr 2019 05:54:37 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 5F53119C7E;
	Tue, 23 Apr 2019 05:54:32 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	jasowang@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Cc: peterx@redhat.com,
	aarcange@redhat.com,
	James.Bottomley@hansenpartnership.com,
	hch@infradead.org,
	davem@davemloft.net,
	jglisse@redhat.com,
	linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org,
	linux-parisc@vger.kernel.org,
	christophe.de.dinechin@gmail.com,
	jrdr.linux@gmail.com
Subject: [RFC PATCH V3 1/6] vhost: generalize adding used elem
Date: Tue, 23 Apr 2019 01:54:15 -0400
Message-Id: <20190423055420.26408-2-jasowang@redhat.com>
In-Reply-To: <20190423055420.26408-1-jasowang@redhat.com>
References: <20190423055420.26408-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Tue, 23 Apr 2019 05:54:37 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Use one generic vhost_copy_to_user() instead of two dedicated
accessor. This will simplify the conversion to fine grain
accessors. About 2% improvement of PPS were seen during vitio-user
txonly test.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.c | 11 +----------
 1 file changed, 1 insertion(+), 10 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 351af88231ad..6df76ac8200a 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -2255,16 +2255,7 @@ static int __vhost_add_used_n(struct vhost_virtqueue *vq,
 
 	start = vq->last_used_idx & (vq->num - 1);
 	used = vq->used->ring + start;
-	if (count == 1) {
-		if (vhost_put_user(vq, heads[0].id, &used->id)) {
-			vq_err(vq, "Failed to write used id");
-			return -EFAULT;
-		}
-		if (vhost_put_user(vq, heads[0].len, &used->len)) {
-			vq_err(vq, "Failed to write used len");
-			return -EFAULT;
-		}
-	} else if (vhost_copy_to_user(vq, used, heads, count * sizeof *used)) {
+	if (vhost_copy_to_user(vq, used, heads, count * sizeof *used)) {
 		vq_err(vq, "Failed to write used");
 		return -EFAULT;
 	}
-- 
2.18.1

