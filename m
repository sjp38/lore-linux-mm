Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54D3BC282E1
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 08:12:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 215B120665
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 08:12:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 215B120665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C4DCA6B0006; Fri, 24 May 2019 04:12:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD7616B0007; Fri, 24 May 2019 04:12:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A9F416B0008; Fri, 24 May 2019 04:12:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7FEF76B0006
	for <linux-mm@kvack.org>; Fri, 24 May 2019 04:12:44 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id a22so4118027otr.21
        for <linux-mm@kvack.org>; Fri, 24 May 2019 01:12:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=f5DG36R8dorxM7QpzbvNwRCVr1cC7ERIoXVIrITIVeo=;
        b=IENBJWnwMS2LEOO7HFvBJUDl5Pe/6zaHahpCCGATyhELEAhN1Xqzi/+svQ1tXKQS97
         rGCAJiWq0LrPvR046wZahTKvsCoByV5iBrHM7MW/gB8b3YnT/VBjKcqo4SUGsxf+CBav
         vr2AizJGnbpVBjDyaoNrRFnkVS+cwWxKzEREQcx+F999uLTP62vP49Yqr0W8e1InXuFu
         GdDN8lrDKNyj/1mfo5YMQrqrFtTMJyi62JYRquNEKW8W7R4LMB+hGSAPPNhdg/gQ8Vfz
         qlccoS+tvRQmd/I9p1IbdaRgVjRkg6vkVudYQOI7AY2VuPEUmQCmnhGnnsqFiYkpdXtK
         LMfQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUsHzkjJOmudYF9YglCK9yA77ffI+hTUD/BzntfTwv6c3SYobbZ
	OxeLwK343WYnj2vnU7QyzYW+Hfpz9nIIzhfuox4J3vOuRGrhsccebLDNMBg6mEdudDcZkU5z8vJ
	EONGRWVrc6ATNMZHmkmH5YPCsBZlMxuj6owWb4EKElvXIi6DmvxovRpZDJc83c80alQ==
X-Received: by 2002:a05:6830:148e:: with SMTP id s14mr14870186otq.54.1558685564231;
        Fri, 24 May 2019 01:12:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1iXvjxg2awNdnGqmoI0znCzFK81mbPoRVwjOc+5M41vW1w9gjuNrbxTDjqGdh84cDT5Se
X-Received: by 2002:a05:6830:148e:: with SMTP id s14mr14870159otq.54.1558685563393;
        Fri, 24 May 2019 01:12:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558685563; cv=none;
        d=google.com; s=arc-20160816;
        b=gpg8bm4ICrjM7A2RrZqf1srlJljCOeTHjb0hQGb+XTfXFGb1h5nglz7zAlfpENTMcJ
         HKGGHe7559HzfCMe+3OFsuF+KsFVNItGkzL8RUuaQJNUh7CIbuHAbqy6j3+qf7tVordK
         uGVW6vzpfxhWXJ297UIwbiOjVb+mCTVjzTzbPUplBiHV3srjgb6CI9f7hmBe7Idmd3W9
         LjJwMQAu7SStFYs8VNB1u3pWJYkmN1yJSgbRdGPLx6aJDzCEL++0MRosgUAOH4KiVyg4
         d0mhZQyllYuoBDV88MY8Jfo3XtdGJZ4jFt60gFR8Ee+ZJqjT7wHhsQe4Th/eZOo8Vamx
         2EOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=f5DG36R8dorxM7QpzbvNwRCVr1cC7ERIoXVIrITIVeo=;
        b=MTG59LrAJUmqPAA4olks1uFB/XSb+iX3f6vbsOjJofn48GSVHuItHj8f+HRW9TfY6d
         z6Esj7ZISwC9sdD3jQ+KzDwA2tFBwK9+uPqWOHz7wZBkv1YEOsaacXLBaxx2cr9nRKnf
         fNYmlvzFOJryndaJafhAXQRisUtiE0fordBWQ8vTWBJ1nydZqooQkzZvLASEebVwmdbU
         zc15NdfHs2bRPqnPh8Btcka1EfROU9wqwxuOFRtlPLU5w643Dra94HgIlds/LQv2RCYL
         WPAdmJeyYS+7iINYgT3I2WXMdp8VbbALGHsVC5oZA3RoyXJUWtMLjQaMeqcWhqMV8h4h
         avzg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c3si1055512otp.40.2019.05.24.01.12.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 May 2019 01:12:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9DCAC3092654;
	Fri, 24 May 2019 08:12:37 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id D650119C4F;
	Fri, 24 May 2019 08:12:31 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	jasowang@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	peterx@redhat.com,
	James.Bottomley@hansenpartnership.com,
	hch@infradead.org,
	davem@davemloft.net,
	jglisse@redhat.com,
	linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org,
	linux-parisc@vger.kernel.org,
	christophe.de.dinechin@gmail.com,
	jrdr.linux@gmail.com
Subject: [PATCH net-next 1/6] vhost: generalize adding used elem
Date: Fri, 24 May 2019 04:12:13 -0400
Message-Id: <20190524081218.2502-2-jasowang@redhat.com>
In-Reply-To: <20190524081218.2502-1-jasowang@redhat.com>
References: <20190524081218.2502-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Fri, 24 May 2019 08:12:42 +0000 (UTC)
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
index 1e3ed41ae1f3..47fb3a297c29 100644
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

