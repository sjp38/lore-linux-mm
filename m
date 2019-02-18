Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31044C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 21:07:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF88C217F5
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 21:07:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF88C217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=collabora.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 82A888E0006; Mon, 18 Feb 2019 16:07:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7DB228E0002; Mon, 18 Feb 2019 16:07:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C7D58E0006; Mon, 18 Feb 2019 16:07:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2DF038E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 16:07:35 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id f202so42840wme.2
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 13:07:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=R6jm3XECd8aWAueqMD0xo2xsLqP/zhyB2FKoKvR4+qI=;
        b=anen5sq/fU85HgWGXNKZD6y178IBIwG0uU4c0ebc5XAOv2kvg9BKr8ZgS51B7WKmH9
         Arn1cw9qQ22jB3PztKe0LHTszQhzCeZ3aEzdrUDFsKW+g81YbLUN/zROWbp0FG0HtFLV
         ash1HEqCCjLbfD///eGqM7I4qQGGwVLlHNEr71avupTfD3Lif/hoktJ1BTB4sWP87GUU
         8WItGL2h+by3JWEfTLEDBaX58nArxV9d5iFhQF36iYLETkYEoOiDp3GGVtDaOhv/19gQ
         RAI8y9fpYGLZ/FrI1p+GbD673dPzyC/VH3BKqpm144IPM8z6wwOdRPLRmCdJBk3JgnCY
         RCNw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of krisman@collabora.com designates 2a00:1098:0:82:1000:25:2eeb:e3e3 as permitted sender) smtp.mailfrom=krisman@collabora.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
X-Gm-Message-State: AHQUAuYrA/45XNz7/nDOo1o9ZBelG1tLk+EW7dfSi+1kyNB4QAyV2Gbr
	eF2z0xwQZF68CwQhBLoJ41bvIOlYeMWLdMoWScpMltS56nZT6PTM7phgocIN6ZE1aIrxsBUodK8
	KAWu1IJajqhfXdqu1VG7P9bUfCTGJHCDMxwzt/uSyy0FJXZkO2qHefDALd015THb5AQ==
X-Received: by 2002:adf:dc10:: with SMTP id t16mr18701434wri.40.1550524054667;
        Mon, 18 Feb 2019 13:07:34 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib1SeOOcnWHtPkUGN8ohv62ME9av6d9AmRctPw33TGsg4BlCirrmKP6a+AKSdnlzdw+3DgE
X-Received: by 2002:adf:dc10:: with SMTP id t16mr18701405wri.40.1550524053902;
        Mon, 18 Feb 2019 13:07:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550524053; cv=none;
        d=google.com; s=arc-20160816;
        b=bn2wmOW3iUG3/XyuObjVjK/86WW0PTU+nhpr/Jk0Uro9pmUkeUxMQxhy2wnOtmivXD
         hMaIzdfxOOTOPGU9Mq1BlnR6QXICnbXeDaOm1kDaBjafQKnv0VpomkrzYSOz2zN+E7SA
         m7YNI4n3rdma1UldHUbkdwGwXlU3hCg4GpLHqCEQBAFkaFcf2f085vy5M8tUNFzibca/
         wTsjcKRFkkqaA6yDbFJ8FJl+WeNOW4LCz66HYowHTFpMMY/M7FjxQZVUT9xVCoAEj4JO
         AblDgjVFZih1i4o086fngfNZrZxtovQBirQgTkQRWhUydVgw8mmiT/OtOjRMGeLDbeOt
         Xb3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=R6jm3XECd8aWAueqMD0xo2xsLqP/zhyB2FKoKvR4+qI=;
        b=j76ekZ9PMrcpmHZnDjFytsNo0fyqRIh3cuW+qrMN00awVK0XQoYkgGRvVtu8OFXwG7
         PT+7yWrImv7kv8L1EDGmLAXLpr9rwguTTvF4n8mxYoCLbwC75z13VuIgN0m2nL5FS6dJ
         18+RGp0fXwczemHgKkJSBw9RZuB6cOfNu1Qnqs9YbZt0r0EIfzWWsqjsnvJdlULm0Nsy
         fUSeWttzb0JEIQeeJyVCND8r17AbQpjA3+kPA8ZVVyqzzHD5Z0JG5IdPUcfX7Zfi0wTY
         pAOwQkwJdMwt3t2TFxCqL16JjobnS5LAdCtVdT7xVgtrS9Vc8dDw/XzV5ZAuRTW1/5mO
         2fig==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of krisman@collabora.com designates 2a00:1098:0:82:1000:25:2eeb:e3e3 as permitted sender) smtp.mailfrom=krisman@collabora.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
Received: from bhuna.collabora.co.uk (bhuna.collabora.co.uk. [2a00:1098:0:82:1000:25:2eeb:e3e3])
        by mx.google.com with ESMTPS id s18si255697wmc.179.2019.02.18.13.07.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 18 Feb 2019 13:07:33 -0800 (PST)
Received-SPF: pass (google.com: domain of krisman@collabora.com designates 2a00:1098:0:82:1000:25:2eeb:e3e3 as permitted sender) client-ip=2a00:1098:0:82:1000:25:2eeb:e3e3;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of krisman@collabora.com designates 2a00:1098:0:82:1000:25:2eeb:e3e3 as permitted sender) smtp.mailfrom=krisman@collabora.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
Received: from [127.0.0.1] (localhost [127.0.0.1])
	(Authenticated sender: krisman)
	with ESMTPSA id 67BC127F9AB
From: Gabriel Krisman Bertazi <krisman@collabora.com>
To: linux-mm@kvack.org
Cc: labbott@redhat.com,
	kernel@collabora.com,
	gael.portay@collabora.com,
	mike.kravetz@oracle.com,
	m.szyprowski@samsung.com,
	Gabriel Krisman Bertazi <krisman@collabora.com>
Subject: [PATCH 3/6] cma: Warn about callers requesting unsupported flags
Date: Mon, 18 Feb 2019 16:07:12 -0500
Message-Id: <20190218210715.1066-4-krisman@collabora.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190218210715.1066-1-krisman@collabora.com>
References: <20190218210715.1066-1-krisman@collabora.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The CMA allocator does not support every standard GFP flag.  Instead of
silently ignoring, we should be noisy about it, to catch wrong code
paths early.

Signed-off-by: Gabriel Krisman Bertazi <krisman@collabora.com>
---
 mm/cma.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/cma.c b/mm/cma.c
index fdad7ad0d9c4..5789e3545faf 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -411,6 +411,10 @@ struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align,
 	struct page *page = NULL;
 	int ret = -ENOMEM;
 
+	/* Be noisy about caller asking for unsupported flags. */
+	WARN_ON(unlikely(!(gfp_mask & __GFP_DIRECT_RECLAIM) ||
+			 (gfp_mask & (__GFP_ZERO|__GFP_NOFAIL))));
+
 	if (!cma || !cma->count)
 		return NULL;
 
-- 
2.20.1

