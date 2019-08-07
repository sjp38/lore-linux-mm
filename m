Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D087C433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 06:55:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F9CC2086D
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 06:55:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F9CC2086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 963876B000D; Wed,  7 Aug 2019 02:55:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 914846B000E; Wed,  7 Aug 2019 02:55:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7DBDB6B0010; Wed,  7 Aug 2019 02:55:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 661FC6B000D
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 02:55:09 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id t5so81213570qtd.21
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 23:55:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=hXDPuh5Kn7pFxSlRRDrUdecWVXcCQZqbNwxxDsR27Vo=;
        b=rsf1jVvbxI6uTXHLPDllYhl3OxB156V90It/vz2HM8GmZkz33qGEe7Cu5fnKwFwia/
         Y4PMjRIAV8pVt0nzUz+r81TJDRm/nxlg/Si92c7vIiqKK7evHsPMHiHVOrwusiTiH6cw
         W75k14h7e/QiTvPBaUe1HBeZXf0h95Whdv3IF+QS5o92GqA6Ea5i7y39TWDoxBA3yf0A
         xaJNoFoxZqLJNxeaxbozUcWx02ZV3gG5CJ4U+tYmOh4Utfi8+Ov1l74P4tkSWdzxFqva
         gq+TpyzMKyXtjy6qfw6vdhI37HjdtTNQjZeccc95KyjboDQ59phdvQ4Yt/8pXw2VoR+f
         GjMw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWZHmu38kg+CiIuIteJu/oI4l0n+sau25l73LzubJajlRbRSHye
	Dl4K3PTo5bQ+p/zyAf7fNSXiXe8dEN+ioor6Mbn+PBgQ300+QE2N3f1BbUDACVjLbE3HsXOUR/L
	ZCbe3sR2PeDZJGUz+j2Rjdx5L+QcFSasuOvMzJGsh8JsJ28gMckkPe65B3x26xjzhtA==
X-Received: by 2002:ae9:ef48:: with SMTP id d69mr6766035qkg.313.1565160909230;
        Tue, 06 Aug 2019 23:55:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxXmg4FbiH+rIvJMjNzRM4gcn0tc+ey7HCYQVrQzQ+xZTGT5tyRJm6qQLAI/vyea/QPLGI/
X-Received: by 2002:ae9:ef48:: with SMTP id d69mr6765993qkg.313.1565160908191;
        Tue, 06 Aug 2019 23:55:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565160908; cv=none;
        d=google.com; s=arc-20160816;
        b=ugPd7vG01TobjKqD9LVhpVyDcC0HFQORh6K+fAHUQDusHsJWOQLqnqRKKT3l7+D5tb
         XejUt4eTQqXK8Il4e73pXjqONl5IfsrEmv3njKSru26z3Bf7E8ZdRBJhhXCyqtUCcDwb
         rOmeAR4qX0FcqKWWRJTML7CyfzXbVqkbb0UkNDUcfeLaVq5lSt0x4/sngqR8XztO6A0K
         3Zymb4dXiJnLNEFoQWC/wRo0tDbZmYHsuiLBOv/JxvqHQqklKdmCx6ITjg7cA0xLU6q3
         sMZAf8UA3m0/V3qe1Xqka3X4Xgld4YFiBYf8L/8zJFcL0ITPk1AWn8TyfnFZm90zqm0f
         8fyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=hXDPuh5Kn7pFxSlRRDrUdecWVXcCQZqbNwxxDsR27Vo=;
        b=bPFCu1I0esEs8aHoRNBZCLHBj0ILVv0acICNeGQHz817z7O9igVWmkBS8+r6Li3IJs
         RWkoeNhnwgQRHvkgfOtb81Gm/GVuKNoZbLQ5sXQ3lvwq4svArPlaJrZTWu133DZgYUtv
         KvdNr+a2ZItSKVsJ89aoV9N7sjuS5dN0kDX1Xvn+h7Aqn6Bkp2Tzv7wqHk5nBDdyqem5
         WNPmhlRWtr7KCP0JBsNdaScsIhd99OZRH2V4WCQVSu/TiOIZMf1O8ZQBxCXaNL4tbaHj
         Hvf5QwaddnaM2Uq8Fr9lyGLjtCMyyo8XdT/lx/DRS/Yh564E/1JPjxxwUodkL9DkDjfB
         gKfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g15si54179049qtk.184.2019.08.06.23.55.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 23:55:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6FB273DE02;
	Wed,  7 Aug 2019 06:55:07 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 8EE3D1001281;
	Wed,  7 Aug 2019 06:55:04 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	jgg@ziepe.ca,
	Jason Wang <jasowang@redhat.com>
Subject: [PATCH V3 02/10] vhost: don't set uaddr for invalid address
Date: Wed,  7 Aug 2019 02:54:41 -0400
Message-Id: <20190807065449.23373-3-jasowang@redhat.com>
In-Reply-To: <20190807065449.23373-1-jasowang@redhat.com>
References: <20190807065449.23373-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Wed, 07 Aug 2019 06:55:07 +0000 (UTC)
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

