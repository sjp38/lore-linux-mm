Return-Path: <SRS0=dqyo=XC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 822E9C43331
	for <linux-mm@archiver.kernel.org>; Sat,  7 Sep 2019 21:41:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3CB5521835
	for <linux-mm@archiver.kernel.org>; Sat,  7 Sep 2019 21:41:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Ujox5d06"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3CB5521835
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E1AD06B0006; Sat,  7 Sep 2019 17:41:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA4736B0007; Sat,  7 Sep 2019 17:41:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C6B5D6B0008; Sat,  7 Sep 2019 17:41:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0103.hostedemail.com [216.40.44.103])
	by kanga.kvack.org (Postfix) with ESMTP id A39146B0006
	for <linux-mm@kvack.org>; Sat,  7 Sep 2019 17:41:26 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 40E56181AC9AE
	for <linux-mm@kvack.org>; Sat,  7 Sep 2019 21:41:26 +0000 (UTC)
X-FDA: 75909446172.27.drum28_46b391bb63741
X-HE-Tag: drum28_46b391bb63741
X-Filterd-Recvd-Size: 4068
Received: from mail-pf1-f195.google.com (mail-pf1-f195.google.com [209.85.210.195])
	by imf40.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat,  7 Sep 2019 21:41:25 +0000 (UTC)
Received: by mail-pf1-f195.google.com with SMTP id b13so6739950pfo.8
        for <linux-mm@kvack.org>; Sat, 07 Sep 2019 14:41:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :in-reply-to:references;
        bh=Zj674LUoNkKvSpexmegA5PsZaKcGFKG4/kThw6ZXlmw=;
        b=Ujox5d061GkoJp1y4gs3/uinU01AK46f9UdarPx27G2y1doaNX1SE5I+pgGob0a5xq
         D7naagu+P+UhLSm36uYT2/ZbPOVD/+lYyDb62ieH655Wfp1Twoitw1+DetYB6tJoYZV7
         mAPa5PZfA5MTIzejdGl0ftr1u6aapyu99pEq4yrW30hF6rh0oBUjUsVaWDhokWEfSmEy
         YHkz/g2ZSRovh5Hz45kJJynuABEvmOrcI9AmcO/Pzqhro3NT3c7vO5cgFaH4d4Hk15Px
         KAy/zaOFRAsiJiQ2Iqpeigz8cpiyCt5vtvHH12MLqnzlhnDJ87YKjN09D3C9lwP5wCTo
         0mfA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:in-reply-to:references;
        bh=Zj674LUoNkKvSpexmegA5PsZaKcGFKG4/kThw6ZXlmw=;
        b=GSonCrDMJ7ADexufJ59dZ36AFZPX0ZPbpSz43PZ2CWIs2fhzuZ+3+Bc7Sf015cEgJj
         Jn0i6rCKm+hiEtZqLX7O99OWwx89k+9JxNJ33UCcEvp3yCnhiQPe+/+9o4P5/YHSiTEz
         dZybH3zv8UWjiqY49XReikpo4AXII4NHrVcpH/mygr4dGNnwm4U5PPNR4KOBvXn7GpGO
         nQL+oVrZCDJ6C0Np8kLhrS6+R6Y9sbun4T9tbBsH7/s67C53S6setbhoGh9HIXR0sU0J
         U74r4iHIVnxwnqnPT5K7CDhqBRpxH2scu9+D0xY5h5x8E4fG6BmBP6XpcDOpLVAT9JHx
         vWxg==
X-Gm-Message-State: APjAAAV4sIFDu0MpGqCRlkvxDJKF32VShW/7zqkGwekf62E1KkiWLnw3
	h26wfnlOSH/p/JVrG1QVd78=
X-Google-Smtp-Source: APXvYqxfWkn27m4YwwErHi0RMDLqVgW7yc2OyNzSnRttW+TV1ma82at8a0X804W7PsbzNHRM+aaXvw==
X-Received: by 2002:a65:430b:: with SMTP id j11mr14111649pgq.383.1567892484556;
        Sat, 07 Sep 2019 14:41:24 -0700 (PDT)
Received: from localhost.localdomain ([112.79.80.177])
        by smtp.gmail.com with ESMTPSA id h11sm9078516pgv.5.2019.09.07.14.41.17
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 07 Sep 2019 14:41:23 -0700 (PDT)
From: Souptick Joarder <jrdr.linux@gmail.com>
To: kys@microsoft.com,
	haiyangz@microsoft.com,
	sthemmin@microsoft.com,
	sashal@kernel.org,
	boris.ostrovsky@oracle.com,
	jgross@suse.com,
	sstabellini@kernel.org,
	akpm@linux-foundation.org,
	david@redhat.com,
	osalvador@suse.com,
	mhocko@suse.com,
	pasha.tatashin@soleen.com,
	dan.j.williams@intel.com,
	richard.weiyang@gmail.com,
	cai@lca.pw
Cc: linux-hyperv@vger.kernel.org,
	xen-devel@lists.xenproject.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH 1/3] hv_ballon: Avoid calling dummy function __online_page_set_limits()
Date: Sun,  8 Sep 2019 03:17:02 +0530
Message-Id: <8e1bc9d3b492f6bde16e95ebc1dee11d6aefabd7.1567889743.git.jrdr.linux@gmail.com>
X-Mailer: git-send-email 1.9.1
In-Reply-To: <cover.1567889743.git.jrdr.linux@gmail.com>
References: <cover.1567889743.git.jrdr.linux@gmail.com>
In-Reply-To: <cover.1567889743.git.jrdr.linux@gmail.com>
References: <cover.1567889743.git.jrdr.linux@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

__online_page_set_limits() is a dummy function and an extra call
to this function can be avoided.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
---
 drivers/hv/hv_balloon.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/hv/hv_balloon.c b/drivers/hv/hv_balloon.c
index 6fb4ea5..9bab443 100644
--- a/drivers/hv/hv_balloon.c
+++ b/drivers/hv/hv_balloon.c
@@ -680,7 +680,6 @@ static void hv_page_online_one(struct hv_hotadd_state *has, struct page *pg)
 		__ClearPageOffline(pg);
 
 	/* This frame is currently backed; online the page. */
-	__online_page_set_limits(pg);
 	__online_page_increment_counters(pg);
 	__online_page_free(pg);
 
-- 
1.9.1


