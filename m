Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 598B0C742A5
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 08:56:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C8A220863
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 08:56:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BTIqWFou"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C8A220863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB0A98E012B; Fri, 12 Jul 2019 04:56:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A60F18E00DB; Fri, 12 Jul 2019 04:56:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 977008E012B; Fri, 12 Jul 2019 04:56:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 713ED8E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 04:56:45 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id y22so4840898plr.20
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 01:56:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=e+4xq9qMo01JuIeaVNf7eVM8TjnfdpLoykaSHLGnRek=;
        b=qEFIin08ZDlmwijDK2wiYA75nuBKw7qhJdzlH5hku77xeNmjTd2+2jkn22uZuALOvJ
         WecDhoYHLndDjNXIN617e5duEMQfFCAA6vGfCGYz7KbChKIjmTMrpnIV7OPEx6n+oTsL
         5rMSUiBxa/lUEIygidimBy4zDKmAe61h97NylzjQhG39Qdxk0dumfJcrX3voqSzKrNPM
         js1yLgEmymG/oy0MX12RQmdQCbXJcz+cWQPEKiiScUgFf5/1SeuTux+V/FYHTEbTCMym
         BxRYLnG+AuNuO/GU8IsrZfqsIzFcOobgGdQvsPqeANLM7UDjQGsst7Iiykxs5kJKKViW
         1Dsg==
X-Gm-Message-State: APjAAAX9QAf2QKSvVkVSKr4lmSplBBOnBm10dZMzjD3d4HKvoVCirEAl
	dZa98k6Twqu4o82AERWY0W4CzWy5+lhsx6d8pEf2Mh09Gz7ny7rvcwZXXaKanP2gZql63g3FZPw
	pEIIiG42HnH92Z7z9TqNCIhuJfSBlsKUhFfdVrCdhAwEcvTyBOcEptaN8iHNKQJZyLA==
X-Received: by 2002:a17:902:968d:: with SMTP id n13mr10127516plp.257.1562921805081;
        Fri, 12 Jul 2019 01:56:45 -0700 (PDT)
X-Received: by 2002:a17:902:968d:: with SMTP id n13mr10127454plp.257.1562921804188;
        Fri, 12 Jul 2019 01:56:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562921804; cv=none;
        d=google.com; s=arc-20160816;
        b=aRbNZlJ0WRZe3yTfR8SB8Cc3o1Llh6Gn2KCdhbVuqpxDEUWmAcqN7ifVh7zZzbU4hk
         AYQUbs4nbyZtid9ziqSRgb8zYY9CIl+AIgOQtl3rgeanhMQZKb6sFr9U+OzGnkOs+R3L
         BtIP7Bpch6wIS+8nFeCpyW3qpZDK5pCcdCwQ2IowR+fS4SaKOKCOBhiL4HEnrVa/kJKb
         PhKkCSzR5khcMEWR9ce+QKbyBnmb6UAwZuDibo7Tb+v8kYwXg8QTYbx7iGHphM/7k54H
         o9OhGzT2d/FGQT4+vLfiMl5aF0NmOsLulQhlMAG7JnTbIyq2fLVCLHE2INnngc4W/Y3c
         MeRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=e+4xq9qMo01JuIeaVNf7eVM8TjnfdpLoykaSHLGnRek=;
        b=MqFbzKG2N3nEGpLV1ju2eVpcMwthfQq6BgchIVZdrPqu426xt6tPkCInhnYI2HfhoH
         Zow5on0vZ87FY4BqBAB2PxcsbA6Vs6Kn6hgqXOfLJPVU5vQLC0BX9JYrbTfhdBS7nTrd
         C/TJTApAhNNxq3lvEArRtIbGuRHsTZOOlhiDjqivBKZmXXj5Kjr7X+5WrARAvs/5cF4q
         B79BhkbxHmL4y0VmGAWMPxfxehcSJEfHKQ+WZeryUaA5+WX0D1t5EiFFyfjKvpPGRpyF
         6SUunD+MXLxV0/Ko3J5R0hxDvRhY2ok1EYPgQLu60bVlrV3Gdya5QjwGrWv7qUUh9hji
         n/UA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BTIqWFou;
       spf=pass (google.com: domain of ryh.szk.cmnty@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=ryh.szk.cmnty@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h71sor4224302pge.80.2019.07.12.01.56.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Jul 2019 01:56:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of ryh.szk.cmnty@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BTIqWFou;
       spf=pass (google.com: domain of ryh.szk.cmnty@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=ryh.szk.cmnty@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=e+4xq9qMo01JuIeaVNf7eVM8TjnfdpLoykaSHLGnRek=;
        b=BTIqWFoueyE+y2FaPP2J0bXf5T5Wg6a/OG1y7MCfwAhd1H6CljEnPO8DP6eHqmhyMv
         Ts9l3So90ydKXZPEprFCGV04aWXxFbpOGLxY+hM3d1/VgcYgheYC/WorqbI4vLUDnRoA
         ZJF4SJl72vu8xEqfr+SC7SzG0hoY6eHBQodCkRxDLZ37wpTWxdqX//vzCBVa36Tc25KK
         JiHnPGBp7whGlWlT0Zwd/F1vz4SCynd4m1aLic3/RZX1X3XdHqYKNnqta54+S7MoAJA4
         p3RT4aewQmV2h9G/1EdSuVm+KATff4xvLN+9LWw8Mk6mQtletG0rmirsY9gwTpBM+xR5
         kX9g==
X-Google-Smtp-Source: APXvYqwG3TLDz5EyPwzKnL4LRoclrnK0KZsBNYJt1rAUmrBQPaf7iafrMvU9hpkOk9wFq49TMMJcDQ==
X-Received: by 2002:a63:8a43:: with SMTP id y64mr9421363pgd.104.1562921803819;
        Fri, 12 Jul 2019 01:56:43 -0700 (PDT)
Received: from rs-hpz4g4.kern.oss.ntt.co.jp ([222.151.198.97])
        by smtp.gmail.com with ESMTPSA id x67sm10715927pfb.21.2019.07.12.01.56.41
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 12 Jul 2019 01:56:42 -0700 (PDT)
From: Ryohei Suzuki <ryh.szk.cmnty@gmail.com>
To: akpm@linux-foundation.org,
	iamjoonsoo.kim@lge.com
Cc: Ryohei Suzuki <ryh.szk.cmnty@gmail.com>,
	linux-mm@kvack.org,
	trivial@kernel.org
Subject: [PATCH] mm/cma: Fix a typo ("alloc_cma" -> "cma_alloc") in cma_release() comments
Date: Fri, 12 Jul 2019 17:55:49 +0900
Message-Id: <20190712085549.5920-1-ryh.szk.cmnty@gmail.com>
X-Mailer: git-send-email 2.17.2
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

A comment referred to a non-existent function alloc_cma(),
which should have been cma_alloc().

Signed-off-by: Ryohei Suzuki <ryh.szk.cmnty@gmail.com>
---
 mm/cma.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/cma.c b/mm/cma.c
index 3340ef34c154..d415dfc0965e 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -494,7 +494,7 @@ struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align,
  * @pages: Allocated pages.
  * @count: Number of allocated pages.
  *
- * This function releases memory allocated by alloc_cma().
+ * This function releases memory allocated by cma_alloc().
  * It returns false when provided pages do not belong to contiguous area and
  * true otherwise.
  */
-- 
2.17.2

