Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 059E8C19759
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 07:06:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC1C4219BE
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 07:06:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC1C4219BE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7ADCC6B0007; Wed,  7 Aug 2019 03:06:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 70F826B0008; Wed,  7 Aug 2019 03:06:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5FDD46B000C; Wed,  7 Aug 2019 03:06:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 459BC6B0007
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 03:06:28 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id c207so78092004qkb.11
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 00:06:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=hXDPuh5Kn7pFxSlRRDrUdecWVXcCQZqbNwxxDsR27Vo=;
        b=XRwaiKtx9bzPho2sHWRJw1wCa2kGADgH2vFaa+InW+829yW0ukoYuShaoR3uNdOeAF
         CawJuCZsWGVV3Md3BYXVXDqAR8QbIvWoAt6XBjG5GlcnPDCqayyA4kE74JuWxb7zgk8r
         kh+A6yram1NFVba9ee9++B2qe57xNlH2b4dK1bnBMcTMsy30nFDqSLLXP2xkWPivUofg
         8ocpuNvsHVBfEEEbSY5iTvsGfnviQw30WpCQ8jLYaxDn9lh2m9pAsVkckkOSaHOPQESC
         Y9+bgTCi8YJJlh1rSeJXqlvx4zQ0KoN/OsodCIWbH4UWUQf1hRdCyRTpo2UH2zjBuKf0
         T+Og==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWQSHlGLvlsKot+cmpXmPeZyHtR0mAPWv3BZstqG/IOpDXlX/Up
	fP8Lgw1aY8wflcC3Wm6zTHNbkR2mfRmWaIHk1oVBPGbecQXdu1S2JKjlj0BQs5cQQJOZ1cKPmHz
	HGGpu2xahMvuDNQFFs0csRNY1ffMp0B2OpwOQ6A1hYtBG/Hweo7MpL6/zrDm8yxUNwA==
X-Received: by 2002:ac8:431e:: with SMTP id z30mr6630029qtm.291.1565161588095;
        Wed, 07 Aug 2019 00:06:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyaYgJ/oiYEXXt3uhvdDSucD05kj/2iWbg0oD0XJL7Zi3VdJv1YpvWUBaXVw0z4PEtd0hvn
X-Received: by 2002:ac8:431e:: with SMTP id z30mr6630010qtm.291.1565161587586;
        Wed, 07 Aug 2019 00:06:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565161587; cv=none;
        d=google.com; s=arc-20160816;
        b=XJ+GwiuGKxOaUEB+qwvQW1+G2GGr1XhAJujbtlWPkLh/Yk51gfbUacB7etIoGj4JVr
         MzQqUtUpsu4Abl9j3oaezVtvoUybIOTcFkv0P0N9Xdwb7/riK+BjaE+iXGaZks1am4Bn
         Mc1Dk/yYsjN6qwcMR7xxH4UxH7scPQRO8Qcwp0nnxQOgPZPwlcqaxl/SLKFi83xT022v
         o02Ef2u2jwkZJFFt8tghJNfVBNWZpfRTz67BN70QRKK2SeDa+1Pdm0MUnniEc6cb2g6z
         ojnQPZbmtDVOyENV7E2HmJX00Hk3Os5enJ6TCkEyeM4xxA2G02LTzZmcis/rGK+1xPEi
         NSug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=hXDPuh5Kn7pFxSlRRDrUdecWVXcCQZqbNwxxDsR27Vo=;
        b=MbIGkZH08fWgud2RBPzwBqfHGjQE/yLvZqpBB/D+Z/Mfxo5PRSiP4mQRHBJvxAczaO
         5sM5/cam34M509DD/PUzo1ea4TomSI4rPPcFnsTT+g8VXAtRZbSScYDdQ83bkbfPwwW7
         viOObb8sd5XNwkBGe5XCS5eRvx6lOmjpLi58H6lDQ0J3kKpJdytve6FyQvy+eIPvMt0B
         AfgGVugLy/JCRljB7ThbvWbYnQXiiJ1Q3R2mEPYtnX7OB/ev6SIm3Qn2+35es6vo+ohI
         fsH4nWD9KU9tS8BBMrGKLpGCA2SKwDlNR6909g1DxH25DDl2q22P6mSLaHzMmSlQacDW
         yU/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l3si51416911qve.218.2019.08.07.00.06.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 00:06:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id DC9B17DCC4;
	Wed,  7 Aug 2019 07:06:26 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 5D34410016E9;
	Wed,  7 Aug 2019 07:06:24 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	jgg@ziepe.ca,
	Jason Wang <jasowang@redhat.com>
Subject: [PATCH V4 1/9] vhost: don't set uaddr for invalid address
Date: Wed,  7 Aug 2019 03:06:09 -0400
Message-Id: <20190807070617.23716-2-jasowang@redhat.com>
In-Reply-To: <20190807070617.23716-1-jasowang@redhat.com>
References: <20190807070617.23716-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Wed, 07 Aug 2019 07:06:26 +0000 (UTC)
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

