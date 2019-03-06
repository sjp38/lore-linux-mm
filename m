Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EFA2FC43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:51:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B186920663
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:51:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B186920663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D24548E0012; Wed,  6 Mar 2019 10:51:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CAE8A8E0002; Wed,  6 Mar 2019 10:51:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B9B378E0012; Wed,  6 Mar 2019 10:51:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 87AD88E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 10:51:28 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id j22so11783625qtq.21
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 07:51:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to
         :subject:date:message-id:in-reply-to:references;
        bh=MP5e6YhXBk99SlgyMaFRYTASfilfVGzXwWWzUP9r2gA=;
        b=JwyqkT+axrDpfyOnL4rHh1O9s5IQTSZgk8l8fvTrV+NAoKvny85hkJrZke1dFVbYpi
         clj5+VX5KHUpriABehjXzUwd8GxVAezizrPxPEe2/lRf+uWCwn0BN2J2sWZiP7lwCgeo
         gl3hQCAX4TednpDWQRtv7TLBZewInc2tY0vTbjEkhU6uqkyJ4i3ZcSsXBLN3tzSWdPbM
         iLzpPQPO2LI5TwFLqVFJePQNVHE6l/SNukH8wWedwp3Gqyg0NFaezEdH0zdPFRgZOD9X
         bzH0vURamSKX3mw9efIut0xBAdyvBI2Ruh1L2anX0h/PLkvQyHsxkg5/R/lXCNn+tnYE
         ShUw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXwo00IOeD6qaJcFxqCx9Xw1Hxni2dARPFhKdcCDc/wiFJ6YMP0
	MXAIBSEvj6qLqhwXucEIwGE+SUlc1VMrQup4lT7aaNi/lD3c3LPGhADLX/UIDjWHaRLJSb452Dc
	bzjc4a8pqgaWPHDauZxTxclRTaMKe/A6KUZJoqoEp+6SeqqUW3Atk3tB6bf29c/w+Mg==
X-Received: by 2002:ae9:e702:: with SMTP id m2mr6363669qka.279.1551887488332;
        Wed, 06 Mar 2019 07:51:28 -0800 (PST)
X-Google-Smtp-Source: APXvYqxQFDQJDK+/7SBaBugRIZkyRPURe1g1JYxdudxi+aS/EMXkuD1zfgcS103UrGpD/Jz3vcqo
X-Received: by 2002:ae9:e702:: with SMTP id m2mr6363596qka.279.1551887487252;
        Wed, 06 Mar 2019 07:51:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551887487; cv=none;
        d=google.com; s=arc-20160816;
        b=dhYjUi9iHvEZvSDAoYYLEh15asQIHa86VrHkpEm4diOrXDKdVNqyCXu6F97NwPmBY6
         bmXnBmdVcqErvhg83t0p6X3AdkXGGUjXLkv2FLEmHzLXYuWw2sG5dsFqBVoeVSDcLSFJ
         KxcwfEMV05Xzc5DubQwLEvAgaW+NJ3JuvlJYNeysG8sUO5HF1FUo9LScr+jr6XsfU/6x
         JsF88i1uIO+I/Q4D88yes5knfdtpzIEyO9/xKl2BxlRTUzEmVidl/R54NAkf6xFft3v7
         FSk7Ee0Udt38ry0N9C2olZRVQyEV40ld/gP/BMYhka72KxwXpY1bga9zPCEy8ugwI5xy
         PCbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:to:from;
        bh=MP5e6YhXBk99SlgyMaFRYTASfilfVGzXwWWzUP9r2gA=;
        b=s/680UxkI25pRaA5pRqV82OpL2xxvE8/7Wt/mHGTw8plee+4HatoVaHjnA2p9r+MVn
         iC2UvQbL4ngJL6/ZsSF9aFe1I9NwdfSAMrvLlFkGvHEaeRb36GbdEt7hLR0A/aFR9q9q
         SH0SXxiGlfwdSuGFjqwtAUoXMFs+EdY1A/bIS6h7GGVA2wPkIYKMV/fx/YScX4UMWQEo
         CYAhk1SrHMS835UnYGI1aHLjkt8ioC32ThYsebVtdAyE4AJ4MFD29Hjlwt7EM0ZcJl5D
         NYVoY4HDOENWXrua6JW3aDurwvDPNxBrrlcX9H/5cEHN/1ntaGOyQef5LOALnK1A61p2
         72UA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v21si1138511qvc.165.2019.03.06.07.51.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 07:51:27 -0800 (PST)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7EBB388305;
	Wed,  6 Mar 2019 15:51:26 +0000 (UTC)
Received: from virtlab420.virt.lab.eng.bos.redhat.com (virtlab420.virt.lab.eng.bos.redhat.com [10.19.152.148])
	by smtp.corp.redhat.com (Postfix) with ESMTP id CBFFF1001E60;
	Wed,  6 Mar 2019 15:51:21 +0000 (UTC)
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	pbonzini@redhat.com,
	lcapitulino@redhat.com,
	pagupta@redhat.com,
	wei.w.wang@intel.com,
	yang.zhang.wz@gmail.com,
	riel@surriel.com,
	david@redhat.com,
	mst@redhat.com,
	dodgen@google.com,
	konrad.wilk@oracle.com,
	dhildenb@redhat.com,
	aarcange@redhat.com,
	alexander.duyck@gmail.com
Subject: [RFC][Patch v9 4/6] KVM: Reporting page poisoning value to the host
Date: Wed,  6 Mar 2019 10:50:46 -0500
Message-Id: <20190306155048.12868-5-nitesh@redhat.com>
In-Reply-To: <20190306155048.12868-1-nitesh@redhat.com>
References: <20190306155048.12868-1-nitesh@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Wed, 06 Mar 2019 15:51:26 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch enables the kernel to report the page poisoning value
to the host by using VIRTIO_BALLOON_F_PAGE_POISON feature.
Page Poisoning is a feature in which the page is filled with a specific
pattern of (0x00 or 0xaa) after freeing and the same is verified
before allocation to prevent following issues:
    *information leak from the freed data
    *use after free bugs
    *memory corruption
The issue arises when the pattern used for Page Poisoning is 0xaa while
the newly allocated page received from the host by the guest is
filled with the pattern 0x00. This will result in memory corruption errors.

Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>
---
 drivers/virtio/virtio_balloon.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index cfe7574b5204..e82c72cd916b 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -970,6 +970,11 @@ static int virtballoon_probe(struct virtio_device *vdev)
 	}
 
 #ifdef CONFIG_KVM_FREE_PAGE_HINTING
+	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_PAGE_POISON)) {
+		memset(&poison_val, PAGE_POISON, sizeof(poison_val));
+		virtio_cwrite(vb->vdev, struct virtio_balloon_config,
+			      poison_val, &poison_val);
+	}
 	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING))
 		enable_hinting(vb);
 #endif
-- 
2.17.2

