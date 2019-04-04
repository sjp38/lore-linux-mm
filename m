Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9A19C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 05:48:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0416820855
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 05:48:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=iluvatar.ai header.i=@iluvatar.ai header.b="q/HyLEGS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0416820855
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=iluvatar.ai
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4DCEB6B000D; Thu,  4 Apr 2019 01:48:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 48BF76B000E; Thu,  4 Apr 2019 01:48:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 37BDD6B0266; Thu,  4 Apr 2019 01:48:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id F3ED16B000D
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 01:48:42 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id g1so1038703pfo.2
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 22:48:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version;
        bh=+wsX3euaQTbnZYORNSKThK5YQHdjOBZReHK6/+C0+Oc=;
        b=GyrfvVyMcFF17H0JolCH9m2rPs9NC9HiZPktQ7n69JU/DvFJOdqbkFQGILYzQpntrA
         n+XQdMOChGhFtwiKxkknGjYf4vZJ7IcNiPZ4Sq8ek8jH5X5mPqhU2nWrdMVrZ+mM5Yqp
         CySTzv4UPQj8G4Jlzak3fJ5ymCl2/N0zZaVUkht0yIAsLkwNiYQbkxJWIylmat7YF5WU
         8hr/oI/SKuRRhGjpm+sIrxJrMs4039GIOkcrb/56UTKVD+jZDRcftdvd6QN/XIpAkmpy
         GZFKEbZ+PrEETwQ38996pVLF54Mhygcwf+Ev+mzgTVZWM2/abu3J5T7Oz1k2BIwfYn4Z
         yaVw==
X-Gm-Message-State: APjAAAX306aF5gmvd6KJef5Cp9Zb4VZHg75l2z8/LNGgjWdaebt9F0eH
	9m+DQ1uZGPlD3wbhUyNBMAacxOCd007zI8L6ABjN0JsGCCM06GpMVolk8aRtFTZ72ImukadHRXf
	TNk+BkIg375CNqN7eG/E4dqAKTODIWFc8XT8zuZZAYysGNNRaprsqPp+5iilZIy2X/A==
X-Received: by 2002:a17:902:29ca:: with SMTP id h68mr4289343plb.297.1554356922481;
        Wed, 03 Apr 2019 22:48:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzIcYdxjsd+pFSez8s0T4NDBc4Ca5II9JQhFmaEN0RuAgxJzuYrvqcvWYk2Z0RH/zFn0X/8
X-Received: by 2002:a17:902:29ca:: with SMTP id h68mr4289291plb.297.1554356921629;
        Wed, 03 Apr 2019 22:48:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554356921; cv=none;
        d=google.com; s=arc-20160816;
        b=PgGbWcFeKj5xRdyA/PFE6qWON97YpXIBlxOI6lBcPcknuRzPztdyUzy04Ew9HBquvj
         vHL6YrxUIxMhPOVgbB9lUGz52PB8dYMggdohjwy1AcaCTaGR60mSM0bdTY6Ir0zp1oMh
         M7S9iHWH1c28zvQPvWbUCB0kn2BRZBhxvz8smKC6Wjmlx1iikq4lwFBDTVbRuzciVMb/
         xK9kUZRkB2R7U23ip6yUOHQ1Gt/xI7gpgUmk5wBvBFFnIKKTt2VGTUwlZVThTWWZLVlV
         MBpaqiYLlIfQHywus6bTZloObcGjW7C0aQdsJjrW04o4DW7+OF/xSPX0tVenH/n8Twdy
         ZFSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from:dkim-signature;
        bh=+wsX3euaQTbnZYORNSKThK5YQHdjOBZReHK6/+C0+Oc=;
        b=kzc1g30EqaTFOGach5jUy3kbHm743VMtUAh96gM4DSFaSxM3/JNv6Wxy1oY/ImPixn
         VSkDNsLgJ/LN+xOzC8GVKHaAFsUJsQI3KlyP8PEEWfW8qCzJwTtGAau4CLC4TMf+C5SY
         JuYjPhWKGHQ74wDLz5V6Ne/hEhmHutabYGszJ/koTVaTRZX74R8p4cvkoA9hVVcoVXWv
         wqDt50xPcTw/pWNMDMxOTUfzlEjTCpsj1RpaVIA5iH84YRgVRBQlPG8L1uQMasa/S5CS
         nxx3fai/eFecTrB1dPqO1zdNWtBqYwNrtWz+EonTYs9Z/qUQYryXRgOSe8qRT+5eND/T
         GZew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@iluvatar.ai header.s=key_2018 header.b="q/HyLEGS";
       spf=pass (google.com: domain of sjhuang@iluvatar.ai designates 103.91.158.24 as permitted sender) smtp.mailfrom=sjhuang@iluvatar.ai;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=iluvatar.ai
Received: from smg.iluvatar.ai (owa.iluvatar.ai. [103.91.158.24])
        by mx.google.com with ESMTP id n34si14408878pld.352.2019.04.03.22.48.39
        for <linux-mm@kvack.org>;
        Wed, 03 Apr 2019 22:48:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of sjhuang@iluvatar.ai designates 103.91.158.24 as permitted sender) client-ip=103.91.158.24;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@iluvatar.ai header.s=key_2018 header.b="q/HyLEGS";
       spf=pass (google.com: domain of sjhuang@iluvatar.ai designates 103.91.158.24 as permitted sender) smtp.mailfrom=sjhuang@iluvatar.ai;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=iluvatar.ai
X-AuditID: 0a650161-773ff700000078a3-c2-5ca59ab6fcce
Received: from owa.iluvatar.ai (s-10-101-1-102.iluvatar.local [10.101.1.102])
	by smg.iluvatar.ai (Symantec Messaging Gateway) with SMTP id A6.63.30883.6BA95AC5; Thu,  4 Apr 2019 13:48:38 +0800 (HKT)
Content-Type: text/plain
DKIM-Signature: v=1; a=rsa-sha256; d=iluvatar.ai; s=key_2018;
	c=relaxed/relaxed; t=1554356918; h=from:subject:to:date:message-id;
	bh=+wsX3euaQTbnZYORNSKThK5YQHdjOBZReHK6/+C0+Oc=;
	b=q/HyLEGSuwoWqkw3HI87CbTcbbnKSzjhK2J1MB7oInnuw/jssdO6l9LHmjDvPxZvnPyEyQnhQ7a
	Z7ul5pvZLj5RuIrTOuGDgMeDzFR6GgQnn2BlK2O/I89kySsrVewFr+TZGTKzoS9Ozd8vWqQsLIH8G
	8/t6gC+8L0rZCx7lYu4=
Received: from hsj-Precision-5520.iluvatar.local (10.101.199.253) by
 S-10-101-1-102.iluvatar.local (10.101.1.102) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256_P256) id
 15.1.1415.2; Thu, 4 Apr 2019 13:48:38 +0800
From: Huang Shijie <sjhuang@iluvatar.ai>
To: <akpm@linux-foundation.org>
CC: <kirill.shutemov@linux.intel.com>, <mike.kravetz@oracle.com>,
	<linux-mm@kvack.org>, Huang Shijie <sjhuang@iluvatar.ai>
Subject: [PATCH] mm:rmap: use the pra.mapcount to do the check
Date: Thu, 4 Apr 2019 13:48:28 +0800
Message-ID: <20190404054828.2731-1-sjhuang@iluvatar.ai>
X-Mailer: git-send-email 2.17.1
MIME-Version: 1.0
X-Originating-IP: [10.101.199.253]
X-ClientProxiedBy: S-10-101-1-105.iluvatar.local (10.101.1.105) To
 S-10-101-1-102.iluvatar.local (10.101.1.102)
X-Brightmail-Tracker: H4sIAAAAAAAAA+NgFtrCLMWRmVeSWpSXmKPExsXClcqYprtt1tIYg3PrpSzmrF/DZnHz+RwW
	i3tr/rNafNwf7MDisenTJHaPEzN+s3jMOxno8fHpLZYAligum5TUnMyy1CJ9uwSujCs/2QsO
	sVS83vGBqYHxDHMXIyeHhICJxI1399i6GLk4hAROMEo8WfCDDSTBLCAhcfDFC2aQBIvAWyaJ
	M8dusENUtTJJPPl7H6yKTUBDYu6Ju2CjRATkJZq+PAIq4gDqrpH48AcsLCxgJ9Hz4CYTiM0i
	oCLx8GoPWJxXwFyifeILJogr5CVWbzgAFReUODnzCQvIGCEBBYkXK7UgSpQkluydBVVeKDFj
	4grGCYwCs5CcOgtJ9wJGplWM/MW56XqZOaVliSWJRXqJmZsYIUGZuIPxRudLvUOMAhyMSjy8
	P1YviRFiTSwrrsw9xCjBwawkwuv6GijEm5JYWZValB9fVJqTWnyIUZqDRUmct2yiSYyQQHpi
	SWp2ampBahFMlomDU6qBKW67vFHsvUmvVN9sDTzjpVxxNHiyant3MVfAxFC7PVMbJjd8z38h
	/Uv63bT73v7zPax9P768V3jAas7cfCfFuPaX99oL5NlV9py+uO3MhjUPL7pvtnjU8N+Ao+2y
	+07WwopZSoeOqK9OFRZjEW+d/f/APBen5yorwgp3qGr8MLt90T+l8N/dU6rH/KXCrujGWO6M
	UZhw4MPH3iCBkOPuxzzZjv/QPiHB4tnDfezLPY5PSkyh02OOqz+tf3BB/sbhrj2Vl83+33oc
	tWBT8LOG2/trzgsuNTiusSEmupPte/uuyd3tN0Q2yrEeFI0zaJxpuNx50g3BizH9EnvORGWs
	/DbXN/bO6pwPq5MYl+1fKazEUpyRaKjFXFScCABG/mbkxwIAAA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We have the pra.mapcount already, and there is no need to call
the page_mapped() which may do some complicated computing
for compound page.

Signed-off-by: Huang Shijie <sjhuang@iluvatar.ai>
---
 mm/rmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 76c8dfd3ae1c..6c5843dddb5a 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -850,7 +850,7 @@ int page_referenced(struct page *page,
 	};
 
 	*vm_flags = 0;
-	if (!page_mapped(page))
+	if (!pra.mapcount)
 		return 0;
 
 	if (!page_rmapping(page))
-- 
2.17.1

