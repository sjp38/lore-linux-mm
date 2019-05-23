Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0CC5DC282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:35:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B9B7721773
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:35:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="AQy9qY5u"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B9B7721773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 21F1E6B0284; Thu, 23 May 2019 11:34:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A8D76B0286; Thu, 23 May 2019 11:34:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F3E3B6B0285; Thu, 23 May 2019 11:34:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id CE35C6B0282
	for <linux-mm@kvack.org>; Thu, 23 May 2019 11:34:44 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id l185so5744753qkd.14
        for <linux-mm@kvack.org>; Thu, 23 May 2019 08:34:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=xpfktVbL8Us0qmdWRL9VRFwkpcEhMFdO2zVbp5WooYk=;
        b=SXLotjewFsaqiJfBrEMxyyRyXPBEPpSG1UAlAiectMA2Rc3gf2dPtMEd8DFIRjyiZj
         //5SEg2xSzTpibSFAsJGadK2PpqmkGmDN+uheXUDXi4BQVOfkirRMb3krf9D8dIbr6JG
         bprejZF8OxrfBQk0M7c3E9IOL4FQqKoZQCyArX7/LGhoOj7RkTqrcmQZI2GfI91arepi
         ESqIHyG/lcVA4vax/7fnBl2hgOi2ICttP7p6GspUfZvuja75X90bF/7kX8ewiHGH5/Hk
         +sDZcEsYJ1NUJelYhM1DFqDCn/EkPxyTRl4cuXZ33AJJ7TPJs8uoJOGYchQLKnc6xfeK
         VsGA==
X-Gm-Message-State: APjAAAWP10e2wheNeD8H/G3JUDH+MpHoFWCtcRzIn6A0zBIdgPs4Qeja
	zPFARWMzXuoktOE8eaz5f2tihMFfJ7jLjRl1lpjbNRh/tuB2e4EiO+wZAfeVxRvOpmX+Eg6FzJs
	8HLP/T06DnujviHByRYTCxLCZZlnF10f25PI8IwwCxNAJvCL/0QC4gULDynXhX7LD3g==
X-Received: by 2002:ac8:3098:: with SMTP id v24mr81754028qta.114.1558625684622;
        Thu, 23 May 2019 08:34:44 -0700 (PDT)
X-Received: by 2002:ac8:3098:: with SMTP id v24mr81753922qta.114.1558625683581;
        Thu, 23 May 2019 08:34:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558625683; cv=none;
        d=google.com; s=arc-20160816;
        b=Gs6uGUrVy5xUoc9o+qeTli1ZECLtCcV/ibLLrd3f3kGBRlxLyaFWQ3VuGUejOFcNxp
         gU2ca1VeRwoqL1DPm6HlY04GeYe1SYgi2bIBsUW/ZWITKNf19vDcykRcwNoWoS3GN1mR
         MNbAZXFWmTXneVw2IDQVb1GQIN5qYEG5CCr7VAD38IBFE3LfGnuzF29jJGpLgh/GDWtJ
         LjgnxJAOhHLfTANL948g6VhZIn2333yuq3dsLQqfe2S5DynInTS/rf4KjBZFqVT4NilE
         mtwOOpuz8l5FPE+T8q3BwrikRIjNTJRt+AXAGO7uxtBSuuNVJ2mJmhZ/CiKbBR3ecYrY
         Rw+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=xpfktVbL8Us0qmdWRL9VRFwkpcEhMFdO2zVbp5WooYk=;
        b=ETu96V7ofpD2fKIv7fwbHUYprMnxMjHA7EbM448t3Z4FfRjg4qWvzhNkCAQlQviQ7H
         ZCRof7u+OOacl7Ttj2p0XXegUXYEO87nlZUW5NDtOUel487RH50jmDWStBlUngLrS4nl
         G1gzGpeHE7Fa16gyIBd/i8Ov5h1IwcHsH/SSmnjFDMqCyg196gDD7+MepLFkXVPCOlsw
         Jnad35iz/7cTletDrAZ12p5vK5zLXx1hdEiD7RdfdgHD9rnLQc5QCxFUxR1L63gf6x70
         KPK6bT+VBOMzuFzHgLuwCSwooffo5yTkvQDXU7EzC48Io9PatKgvqFL6ANuiF8SbRTAD
         Mh5g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=AQy9qY5u;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t126sor15513953qkb.65.2019.05.23.08.34.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 08:34:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=AQy9qY5u;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=xpfktVbL8Us0qmdWRL9VRFwkpcEhMFdO2zVbp5WooYk=;
        b=AQy9qY5unh9pvUOhg9td8t1dNvtTOZFdIPbHYbv6sGctT7lxBlvtaDEwnhn4A+19Ea
         Rg7FPBiK+QeEfNuYYey9/yTJuLOz1p93njDBTGg1o1kwmziRbYbc7/r1RV9voanVidls
         30IOKaMwGJFM53rpfO+9jyUNcc5sGg2amlLg17lxpwhDbVQBeZP7J9K2e+vswi8oBpRV
         I+kktxprDGfdJdLVSa1IlFeSv+iaXJXGJ2txMn51i04T0ADr1iIC1/SdYT+sTveLOLmP
         1UTrdvaCWyzmYz7MafIRNnc5+Gu9nQKBqUn+NLtIyiTvORUJoBnsXlq+HNOLcEnckf0g
         Vxiw==
X-Google-Smtp-Source: APXvYqx9y4W6qkw9q6CFNTSxrDtAaedtA4a51WwLa3lqT4HhvTbeWF2PV7OrPjgqqyxZwLXJZH3cDQ==
X-Received: by 2002:a37:50d4:: with SMTP id e203mr18097553qkb.83.1558625683357;
        Thu, 23 May 2019 08:34:43 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-49-251.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.49.251])
        by smtp.gmail.com with ESMTPSA id k30sm11757172qte.49.2019.05.23.08.34.38
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 23 May 2019 08:34:39 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hTpjq-0004zx-7m; Thu, 23 May 2019 12:34:38 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: linux-rdma@vger.kernel.org,
	linux-mm@kvack.org,
	Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Subject: [RFC PATCH 09/11] mm/hmm: Remove racy protection against double-unregistration
Date: Thu, 23 May 2019 12:34:34 -0300
Message-Id: <20190523153436.19102-10-jgg@ziepe.ca>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190523153436.19102-1-jgg@ziepe.ca>
References: <20190523153436.19102-1-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Gunthorpe <jgg@mellanox.com>

No other register/unregister kernel API attempts to provide this kind of
protection as it is inherently racy, so just drop it.

Callers should provide their own protection, it appears nouveau already
does, but just in case drop a debugging POISON.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
---
 mm/hmm.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 46872306f922bb..6c3b7398672c29 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -286,18 +286,13 @@ EXPORT_SYMBOL(hmm_mirror_register);
  */
 void hmm_mirror_unregister(struct hmm_mirror *mirror)
 {
-	struct hmm *hmm = READ_ONCE(mirror->hmm);
-
-	if (hmm == NULL)
-		return;
+	struct hmm *hmm = mirror->hmm;
 
 	down_write(&hmm->mirrors_sem);
 	list_del_init(&mirror->list);
-	/* To protect us against double unregister ... */
-	mirror->hmm = NULL;
 	up_write(&hmm->mirrors_sem);
-
 	hmm_put(hmm);
+	memset(&mirror->hmm, POISON_INUSE, sizeof(mirror->hmm));
 }
 EXPORT_SYMBOL(hmm_mirror_unregister);
 
-- 
2.21.0

