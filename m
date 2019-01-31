Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A4C3C282D9
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 04:11:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4F44720870
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 04:11:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="uteUYPBT";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="uuzs2ZrF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F44720870
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 98BB28E0003; Wed, 30 Jan 2019 23:11:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 93B9E8E0001; Wed, 30 Jan 2019 23:11:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7DAC98E0003; Wed, 30 Jan 2019 23:11:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5A7CF8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 23:11:03 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id n39so2161164qtn.18
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 20:11:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rauvfyZCPbYRmjy9jHi8eBrEGRdsrFO1TIKSyFZd+ow=;
        b=mtHWem0Z1ZMI83HmcZ/BUAYIuXmSgDr8hZ63r3QO4d6AVxLDjiKpDhjDuk1v0N+z8O
         dGfP+InU9F/Iuvn9UI1HrELQoONmjaFIvuguto/0fd220dle6nY9z54bJu/8sDLwtwbO
         JT4ubDksPXYdpd3Vz0R9heOAdVlBg67nawC6UpeTqTOmXGyyrAm/+mtLjuXc1xm7KYqI
         r3PBbfEXbTKhYOqxH5QVs2goNj0x49YAFYqLjh6nrN8CFIFY2/a8mOEsxRgvCv/wLKMl
         zeH2L81x7KCHyQePL2LJVJSQmuzkwz4NbIB7J8DLeOAQUZWaSXnle4WidajF09LNIBNt
         FJ7w==
X-Gm-Message-State: AJcUukcZQht3F36JM8PPl8ZKRy3vRlepuwtgsj3Y6+HHLo+iqMEA6hsE
	2wL3B98nxcqgWL9ay3tslIqYwm6iDZyXxRhqh+sA2U71TuPiXCMs5u6azKi+3x3RvaX3KSMNo0h
	//RcmkP3R0LmIa4+ie6xgtZ+1RvuHG9GvwN/3y6eq6HugzA6eIdhlY2wnbPRk8vhYtw==
X-Received: by 2002:a0c:d6c2:: with SMTP id l2mr30305685qvi.97.1548907863156;
        Wed, 30 Jan 2019 20:11:03 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5La/PooZff55A24SPVEfXfrmkmVW8XdytSNRNJ9cVHXCvvI6sblo5BoRn2HBeiaFlX4lfK
X-Received: by 2002:a0c:d6c2:: with SMTP id l2mr30305659qvi.97.1548907862436;
        Wed, 30 Jan 2019 20:11:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548907862; cv=none;
        d=google.com; s=arc-20160816;
        b=0NsIoKgiiE4fIS9rl7Ux/F4mgAspYpSjwSkwlFVClc0mccTZ3/gRzsZxwzMpkVsfn8
         td9wD9Oga4WjMLMg8ehvCj1RmywFUCeKKi0w4DgtXJcvZ9GLCUNBREkewveVRbABhjkY
         uu53hgLhYzI4ADbN7fTzS6Erujw9RzJ+E1CU8FegtUyS+UwkqbtSAqSpMdEPKCASpAKa
         0RRI9jZCUVgLF/x9fzABKwmtRGkvdqMX18NpbvrvL1G9/h7zzIkmbAEZ1EyDebmrxCiY
         /Lb1cllFwLH/nwBfJOukMTEFxFVNJMOYBQkahQmyH1Crk36/xq2H8AftNRU0wBKo+zOa
         aOAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=rauvfyZCPbYRmjy9jHi8eBrEGRdsrFO1TIKSyFZd+ow=;
        b=DRYvoPk6AMIFC/SIdWQhcn7pRJOOC42W56zPa7PuHlDfsIGneqQAJhhHCS+5j4lq4d
         xA2RDjJD0RDybIl4z4J5FP3cNFIvdFAMaNUJJKQuqtW1gYZGrqZM8HSb2mIZLd3Weabc
         eCoDL/bny05EwiCkWjnzPVqC3L2bSjq/tS/Qq28UReVUmPEbQx1tt602QTvC+eFvqdJL
         5Po5iY0gIl2zxexPOAhVnvgSxSLwGzm2gaTbwtUUaUpxFoZxXlKmrpFKDvzLJd8pHz77
         6mXi9MEi31snJKyyh/y+RyL7BT8nvLuDDzzWA3Y7ZWmQCuFGaUFOSWrVruHylFz+uTqH
         J7SA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=uteUYPBT;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b=uuzs2ZrF;
       spf=neutral (google.com: 66.111.4.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id z63si2316428qkc.262.2019.01.30.20.11.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 20:11:02 -0800 (PST)
Received-SPF: neutral (google.com: 66.111.4.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=uteUYPBT;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b=uuzs2ZrF;
       spf=neutral (google.com: 66.111.4.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 2CB0E2228A;
	Wed, 30 Jan 2019 23:11:02 -0500 (EST)
Received: from mailfrontend2 ([10.202.2.163])
  by compute5.internal (MEProxy); Wed, 30 Jan 2019 23:11:02 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=from
	:to:cc:subject:date:message-id:in-reply-to:references
	:mime-version:content-transfer-encoding; s=fm2; bh=rauvfyZCPbYRm
	jy9jHi8eBrEGRdsrFO1TIKSyFZd+ow=; b=uteUYPBTPIXQO1ResTVzg+2Pjq6OH
	Pnlwo12SM69SmMG7cL/5TRaS4EU/lzAE+ahzwly6mPCZuQ0bqnWfHZaog+Nk7kUA
	J3vkh/EgUsXuBVnWgJMlS/ON6H6UfV829CGeb1gAMMydafVDdFTBamBeCYaUzo3m
	P/nPycsijs79AumMOginoW8oUMD705FUd7kgE6loAg687mg7FaQYp6bxY6fzTSaR
	08UsrRtNKDVrgQrLOVJI9F15xEfJI8JhBW1zc/q1rkt6cxXIUDYRP4KaMFI5PK03
	F/ie1+EceCkyRtZm6DAf/fjgiurcYP7eXkTV277GkzZfIb0LJcRtB4Xhg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm1; bh=rauvfyZCPbYRmjy9jHi8eBrEGRdsrFO1TIKSyFZd+ow=; b=uuzs2ZrF
	3TuBy6aaDkOtqdfiLmf+IP8FlyNAGuMZ9ZgSMv/gaYJJpjMehsJ2RJUvc9vYttEN
	3+KWSc4xetWMFRUZSX+4iBBZ3PPBHxvhujvD2iD2vdj1SFvfnJjKGDLq0CQW2XCU
	yyt3ViHQ0U0lBB9Z2QFn/qMdh21WA5BR8SlQ1xgwiGBKbbmz4tbEBGNnlQHw3jD3
	R+ReBDmnj9MMAWTwgvDuB/QBIB8Ud2z5ROLLkrH83FLIrymMNTG1SeFuynm8A2jE
	Jf/oKtoIJ1jMVbKirbZJ1wXivef0wZXemwhTXp5NomiuFtmO4D1c3/cdXe9y7C0s
	4CpH45egLirn4w==
X-ME-Sender: <xms:VnVSXEbHv0EufiqjRAuGZh-OvQHwYiQD3gkUoLJRZlXk95KtoGrWMw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledrjeehgdeijecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecufedt
    tdenucesvcftvggtihhpihgvnhhtshculddquddttddmnegfrhhlucfvnfffucdlfedtmd
    enucfjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgs
    ihhnucevrdcujfgrrhguihhnghdfuceomhgvsehtohgsihhnrdgttgeqnecukfhppeduud
    ekrddvuddurddvudefrdduvddvnecurfgrrhgrmhepmhgrihhlfhhrohhmpehmvgesthho
    sghinhdrtggtnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:VnVSXKbNFCb2fUCd77ph5B4sO9trDHgcO-Z8Hgi40FTqm3B7rEh2UA>
    <xmx:VnVSXFkGbz-Z4nBIXvt4KgqtaIzmFDGioP7zPI6fke0d8E4otvQqFQ>
    <xmx:VnVSXMS7Tskg4hGtS04BC3-f4_mz3OMLO9YET_-qLyljMDhkguZGaA>
    <xmx:VnVSXODPwJ4zYx_6igWkgFhx0l6XwH-PD8Xb2Z5SGVlRv9cGNu6dzA>
Received: from eros.localdomain (ppp118-211-213-122.bras1.syd2.internode.on.net [118.211.213.122])
	by mail.messagingengine.com (Postfix) with ESMTPA id 2B45810288;
	Wed, 30 Jan 2019 23:10:58 -0500 (EST)
From: "Tobin C. Harding" <me@tobin.cc>
To: Christopher Lameter <cl@linux.com>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 1/3] slub: Fix comment spelling mistake
Date: Thu, 31 Jan 2019 15:10:01 +1100
Message-Id: <20190131041003.15772-2-me@tobin.cc>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190131041003.15772-1-me@tobin.cc>
References: <20190131041003.15772-1-me@tobin.cc>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Tobin C. Harding" <tobin@kernel.org>

SLUB include file contains spelling mistake.

Fix up spelling mistake.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 include/linux/slub_def.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 3a1a1dbc6f49..201a635be846 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -81,7 +81,7 @@ struct kmem_cache_order_objects {
  */
 struct kmem_cache {
 	struct kmem_cache_cpu __percpu *cpu_slab;
-	/* Used for retriving partial slabs etc */
+	/* Used for retrieving partial slabs etc */
 	slab_flags_t flags;
 	unsigned long min_partial;
 	unsigned int size;	/* The size of an object including meta data */
-- 
2.20.1

