Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4FCAAC32753
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 08:47:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 201F8206A3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 08:47:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 201F8206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B213A8E0006; Wed, 31 Jul 2019 04:47:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD1DA8E0001; Wed, 31 Jul 2019 04:47:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 99A3C8E0006; Wed, 31 Jul 2019 04:47:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7AC638E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 04:47:07 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id l9so60734287qtu.12
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 01:47:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=hXDPuh5Kn7pFxSlRRDrUdecWVXcCQZqbNwxxDsR27Vo=;
        b=dBF/dDIZc1r0fqU5+365l68QjCYmcN4AQs4zZKvuxiJtqRwSh3SZC6bvSl5GubiGrj
         NKKw6bQxLjanraXrCs8Ly0sO6a+CtD8D1oqmST1dmeDADVDih8ZO4LcD+gsHJs6zcneH
         XqrYFsa58TOgy17GrSiW8VfGxG92WmXzo/V5zeZU8sqf5+tz0T1oqWzUQkr62PaWTwnl
         JDSyd4/kqPaq2c6Ca5vBbqKXjga1wzZU8eQLzhSZJ/Lm0R9A6uLkVEYzA25meCx30iV5
         yLwc+Cf8DbNt4Wk10RgVBvZkd+uYEJrlTkFGU8OTKFompmxelSgRiR7sPHGIDauxgLDD
         sWYA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWUFAjs+qwQwnD+uXtigzdgwaKBM2/X7zetPwkVn9HbGS0o6Shk
	l95/8c05TSQ1gSbIcXxGsSy7h18s/S+MHAf6rAfecnO9Dv/86IakAFHk978dyaHxnRwkwhCcDcl
	qbtkOyEXoohfh/j/ZhHYjbI2eY2rUIRMhmUt5qqPR0qlSduAAuF0/9PEk7uFjre6Ztg==
X-Received: by 2002:ac8:32c8:: with SMTP id a8mr82022522qtb.47.1564562827308;
        Wed, 31 Jul 2019 01:47:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzfxo65+Qb30xaHZyi6RfF6+WWXvBwGu1khpW/vgAao3FrUCdXs/2KWrTf9z8cTizO+ZbiW
X-Received: by 2002:ac8:32c8:: with SMTP id a8mr82022499qtb.47.1564562826748;
        Wed, 31 Jul 2019 01:47:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564562826; cv=none;
        d=google.com; s=arc-20160816;
        b=elZ/jwGUGoHO+Q+Hzh/mqEY74XvseAckoUPUn2dfR7bvxxz056/j081r2D14WQRzHC
         ZKd28Yo2uLZ6vGKLqkQdmBrNBOF9HFkCLttswmYhQ47sdPt0lAsB2ODC1gbpMT6d7O2k
         aJpNjdh1bpvSfuSVvbvIRE5RX9FfS24byWvFCIqyPmZ6izQVjHOhFgNl5bCA9pH5phAg
         fTBSA25LoHMMiK/X8KhG/khOJGNknPzDTNUhA5JtOPQvl8wFGoktTAHOhy8qFw7ookgB
         h7Pjzv158ZXpslJykKbpqOc8IFtmuPGvIMzV5Y3RQ6m+zFhiu1CvyF2O1p/3PEDMDcrp
         U0YA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=hXDPuh5Kn7pFxSlRRDrUdecWVXcCQZqbNwxxDsR27Vo=;
        b=mQGYQrqF3CP9a/6WFJ4ZdIntEO9hYtPTefby/gQSewIQCoZrXNSOh4LZh3WfxhwFl5
         eeYBjYWbsjYoA9PUMPKP9BJXZgDFSpM+koRT50mmQObUMWaGfVuG3cdllO2w63R4Hv5J
         Ru1lSreWQnbZWKdS/kCfme1dc9XOYohJT9VfhZqJ/D8ayufZLOW0vExEi5gGmwoja4KL
         9lQv2uONw5EJKVH1gpfUt6AiYccXOjNFmaoXsVhfvVO4MrdYiwjQTonjbwVoSwxbPY41
         JlFiTprHg/+aepGscdHccI9V7Gna6HcAEWKFHGQlNwEKpsuayW2qRX4FXV7QRLGSBCzo
         DV/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e12si39083476qve.144.2019.07.31.01.47.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 01:47:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 01C3C7FDE9;
	Wed, 31 Jul 2019 08:47:06 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 40E1C600CC;
	Wed, 31 Jul 2019 08:47:02 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	jasowang@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	jgg@ziepe.ca
Subject: [PATCH V2 1/9] vhost: don't set uaddr for invalid address
Date: Wed, 31 Jul 2019 04:46:47 -0400
Message-Id: <20190731084655.7024-2-jasowang@redhat.com>
In-Reply-To: <20190731084655.7024-1-jasowang@redhat.com>
References: <20190731084655.7024-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Wed, 31 Jul 2019 08:47:06 +0000 (UTC)
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

