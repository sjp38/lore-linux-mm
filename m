Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72F7BC19759
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 06:55:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C1F92086D
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 06:55:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C1F92086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D810E6B0269; Wed,  7 Aug 2019 02:55:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D324B6B026A; Wed,  7 Aug 2019 02:55:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C486F6B026B; Wed,  7 Aug 2019 02:55:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id A728E6B0269
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 02:55:23 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id d11so78185978qkb.20
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 23:55:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=xahfPfm1mZfbC4QuU9FoOa3rgOujgUARqGYj2KI+pdA=;
        b=KuTJ0fuuaNtfm/yilc0uTtCAUt5OrZKrIYnu5iSPxTZv17raYd/t6P3YLydiBpKhs/
         zkK3K0AJDFO3mSfKgKMFI7LQTBNd1FSWKKCumpii9qRoPIEZ/Nr8sgGtEHXtGeCnSgFd
         5SvJlFDq0UKVQvidTzJaOkI0SoVw+r3ngk+wmuTrf8AwUOmqILnjdgsybdVUzGcgfmHy
         SdKPnA9Ql7UMPWZQvUquVp29Ks7/PRHdMtTHBu5EEXCDWHZQUt46cvWx0zP7tYt2xngW
         F6ftWp2HpgxEQ9MbMmMtBBo1ZNYVjkdbWJxbpqdKwi12InoVkhX89NkmzLbqayMIWPuG
         aa6w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVSo9+9dPZfEqQHRtrQkHY7UQwZD1M+Bz8GrkskxdOUFMrYQgBZ
	Hq+TNXne44AF2xtgzhRML+DxNe86HvESoswHW/IIY1ArYCbft210BjdYb1cVP/xbF2JVDxH6qNi
	qTUPMzCZDNXgpikhr0rnCSNUYhr+kEbF0QPvNPFkhNQiPITLgcVs/XaQwy2Gl/Q/Low==
X-Received: by 2002:a0c:b998:: with SMTP id v24mr6682173qvf.132.1565160923472;
        Tue, 06 Aug 2019 23:55:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzuy8lTnViqOb89+zR9X/ClnOa7kmZiV+azpplA+j9Ut7znE2zur8rAW3b+30dVjWwDmAVd
X-Received: by 2002:a0c:b998:: with SMTP id v24mr6682150qvf.132.1565160922709;
        Tue, 06 Aug 2019 23:55:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565160922; cv=none;
        d=google.com; s=arc-20160816;
        b=FD/GBp1OkE1BdgQ0mJ87WJZsqy3aCeFwQrWI7joqECJo5VSQYKlKrMBuntWGppVyDn
         d0M7+/g/dbIr8lVqZKrqaHE1492wAYXXBaYg+VvTmNkpiAVq86co+mwJl92N+zN8zc0X
         gGyzNXLTuSG1/v6LThMuM9JVhA89ucPyY5wO7fSYzHALbN5+paBAFzKFhpi7D6IytYMG
         EpsrIrvF7IsjT4DKTBcFL0yXQe5V332Ydu+vmwfL8wvZ3ngzcecxRcsCns4Z5T4wVgsX
         59yXriDj7JI1s8+DTN5xYs+81X1RB/0ku+/yOntVb/kUmfAhsJKCKjIMk+k5OpandBGi
         qLiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=xahfPfm1mZfbC4QuU9FoOa3rgOujgUARqGYj2KI+pdA=;
        b=bLbiOrQXzeCya3S0etx0p8tqC2SfDzIXIiMxeaFdSueAr8wsxM54TG/eZvR88kTY7/
         YK6K0fkjnf9vcgVqwSUTxhDkF3KaiK7Wr/He5iwt3hcDAHppyp5ggaxXUWj1634dlXnO
         qhkYYHk61I7+vs6zekj21fiYMIgAwZV6x5E022zzeQZJMpH39YQlREBweqBo6keq5H+8
         aBPbCI/5gD6rhiOroKw16vPVdZZrO1iYDVqWKUZKHQWleYC2cnBVvfgHw89mVqlCcPmw
         fWMMDGDAoWrgl0g9EFY1PLKTPdkBoPaCbk52L92X1Ws0LdpdfmiCiqhUdU5Ke5dJV7G9
         pWiA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o13si54603935qve.145.2019.08.06.23.55.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 23:55:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B7B0230C061C;
	Wed,  7 Aug 2019 06:55:21 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 2503F1000324;
	Wed,  7 Aug 2019 06:55:14 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	jgg@ziepe.ca,
	Jason Wang <jasowang@redhat.com>
Subject: [PATCH V3 05/10] vhost: reset invalidate_count in vhost_set_vring_num_addr()
Date: Wed,  7 Aug 2019 02:54:44 -0400
Message-Id: <20190807065449.23373-6-jasowang@redhat.com>
In-Reply-To: <20190807065449.23373-1-jasowang@redhat.com>
References: <20190807065449.23373-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Wed, 07 Aug 2019 06:55:21 +0000 (UTC)
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
Reported-by: Jason Gunthorpe <jgg@mellanox.com>
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

