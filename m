Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7FDC9C32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 07:06:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 52ABD21E70
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 07:06:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 52ABD21E70
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D2B186B0269; Wed,  7 Aug 2019 03:06:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CDAD06B026E; Wed,  7 Aug 2019 03:06:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BC9436B0272; Wed,  7 Aug 2019 03:06:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9C6F46B0269
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 03:06:45 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id m25so81116122qtn.18
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 00:06:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=B1luxMJLkB4TGmpB4Z6oIauGJZZAFOoy1m4euQKOEm4=;
        b=BwEhYr6aZRQ0ZvrUkeI3rREFqsM7xESQ2mLa4DWY22iLyUW4vQOghZaT2s4+Y70pPR
         aUyrnt/YiONKe8YzpkEEKCfJWRNVCsAyireqTHVpubB7LwpPBtmlk4xGT4GMmKTiN/7a
         bNmGG4E8dMxZ+yoP/CmuCBuH+hTtGxy/c9dOKeK5cGih6Xp7Wi2EDJAyam9WDpTwYwnl
         ktMRiqQ0JsPD9Z6rNg49fWVvBHMZ8A7qMHnVzttFgfiHwhfJt1oXJkH/yWXVtgtjxNJQ
         oxmN8KiBl6eIw3Q3bJPwfjVt7y34ZFwDKJ1L7SG3i0wMvFmj10+YP9kvSOkC5QCL0cpN
         reWA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV6+lk23C4CNrwHpajXpLKj710RI7gY7LrFjXi9ReWFJ6kJhfeE
	ERiuPVFAGGYskqbwYktG5JADfWEcRdyhXh39jrvk/bJsT5h9dhO8TEuf/j3PTRhv+tHM8cmLg3H
	BtaovsgToOM/2FKfaxzCTKdUME5RxJohNPtK63/aOfEZWWfs2en7j3z4l0EDqeq/cPw==
X-Received: by 2002:a05:620a:1393:: with SMTP id k19mr6813408qki.67.1565161605461;
        Wed, 07 Aug 2019 00:06:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx05zgvJRhhIslkk3zRwYd0akdvdqTQVm5SxjEKIypyWXH4jptpoA9nb4pOEWtk1Jj1XTjm
X-Received: by 2002:a05:620a:1393:: with SMTP id k19mr6813389qki.67.1565161604953;
        Wed, 07 Aug 2019 00:06:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565161604; cv=none;
        d=google.com; s=arc-20160816;
        b=o05aeMdGgbx42aVpHpIAf1mw10fTrUEn5oKZHHOh33YeLU40qp+ZnEeXVbnq9kYvTc
         28szV31SSPmJHi+qAwyn59DH18ndlJhSnFFv9+raCekF6/Ybpuj/Q611ASn2ty9ipT06
         TmMi7m8QNtVm7ZgUQCYbQ8l2ZbSx4ivkUKbHAEk8bPvbT6Poshh1HaoyTzT0ribWcKgd
         mqzku9x535iutWp4s3+Zlx8r6pCzC4m8eRv2ASIU2R2MARJo+A4HCpCObvbs3IGv2yFz
         h2M6NpsVLrRtq45grpN6GWsP+2RlWoMqR2cGCDq9v0fWQ09nZw1q1JL6Hbh9fPFUSpo4
         zwXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=B1luxMJLkB4TGmpB4Z6oIauGJZZAFOoy1m4euQKOEm4=;
        b=aFfvwOmLW4UYECxVZvLV27LEKy6CytlgjCJnCwP7xgrTc+nsaMUHA3RkFVTJE6ahrs
         rTNFDX35XuHIv70UJVQrw+h/iilKnUTzmBED0wxvzazcQDKdb3TbWfeNWIiT160Svifi
         lXUkvQbNcWus1UyOgtrh0qd6uOn1/nwPE5skjvq6cat0+nSOLrNAX5tJvOw5aBaJg2Rc
         Xygzh+TCaeUgFo3m/i+oOlKbnuhs2o+8iknOVjf5f8nJQJFXZCHR+rXrgXJxbjpYhlB8
         bmm6Fj6eWLrWSjU90pV//PA9UDmfOffy57A4jKVWsCSWwbkLprc+BWyk2ZaN6GZsB4rx
         3MIw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r21si229909qta.166.2019.08.07.00.06.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 00:06:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3862B30BA1B4;
	Wed,  7 Aug 2019 07:06:44 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id A47591001284;
	Wed,  7 Aug 2019 07:06:39 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	jgg@ziepe.ca,
	Jason Wang <jasowang@redhat.com>
Subject: [PATCH V4 6/9] vhost: don't do synchronize_rcu() in vhost_uninit_vq_maps()
Date: Wed,  7 Aug 2019 03:06:14 -0400
Message-Id: <20190807070617.23716-7-jasowang@redhat.com>
In-Reply-To: <20190807070617.23716-1-jasowang@redhat.com>
References: <20190807070617.23716-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Wed, 07 Aug 2019 07:06:44 +0000 (UTC)
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

