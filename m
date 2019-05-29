Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4EFFC28CC2
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 23:24:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F34D24336
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 23:24:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Vy03dE/f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F34D24336
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F7096B026E; Wed, 29 May 2019 19:24:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A6F26B026F; Wed, 29 May 2019 19:24:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 096936B0270; Wed, 29 May 2019 19:24:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id C73D76B026E
	for <linux-mm@kvack.org>; Wed, 29 May 2019 19:24:02 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id u7so3071460pfh.17
        for <linux-mm@kvack.org>; Wed, 29 May 2019 16:24:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding:sender;
        bh=uegJiDhnQxQaXlYd/KXlqxqemOhHfM+yEvioj3JsN+U=;
        b=k5+FKWLUzKuJdanqw6O4hrtZSvN7zLmHtzlMu6Q2XoHQjOQl4XCjRJjoAIA9Y0+YC1
         +zjbuetToO7k9ZfZ0Eogn188aoY5JVDqv4y+2j/ai3+yc6ur3kaQi1oEE/Tw8hn2IXy2
         /bQyMG+uHwK+SqnV1Dxa02wzP8WDcTLy4UTJQ8uz+h/I+/UPRvvPX3Izm0TocILkJELF
         mvFwYoQf1oCW7LQOXm1JKuwszIIOp4lou7dpcDUNJRoenl2ovCsm9V2XFMEOOw0YXaTa
         UI27YAKPJAHv+ncSl08X114wz3bVN+Eab2ppzUCBpSUOIAaw+kFzzQ8xj54IbXmAtPTG
         Q+Iw==
X-Gm-Message-State: APjAAAWDRb77s+S/h2uwUIUIP2o+o6GtRJx9LU3AXFVg6GnpzBwh4Uz+
	QeergK0ztCNV+cLbwjkkOJnNF2KPZ6CeUhk/YJIrZq77LdDZwPHt1Y1urzbcoxbmKk8g/af8dr2
	4J0W9idmWPHfQoyJh7HpXhDwth6uiNOrH+E4b9pP2BNKIqFDeSAG+R6AmZVDAbRM=
X-Received: by 2002:a17:90a:f488:: with SMTP id bx8mr556179pjb.62.1559172242443;
        Wed, 29 May 2019 16:24:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzTZdJ1FX08hGwTJJM8H6ePfMk6y8T20F2yab8AZ/bkPqf2h8zKKG8JV1cJxPBKfoDiN/Dn
X-Received: by 2002:a17:90a:f488:: with SMTP id bx8mr556117pjb.62.1559172241534;
        Wed, 29 May 2019 16:24:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559172241; cv=none;
        d=google.com; s=arc-20160816;
        b=aDdT9gn8K9hQ100cSiTeWH9gqPmBvlu5dNRwjGFEFc2gYTsDXDeS4fFfOgBjQJD0vQ
         2CQxKJKL486xUQLGHkVnDQASs427Rr/FBB6HQsKgCWiOGqOmTw2FhQRF17eGqPo4/pLd
         KSse/Skk7f77IE16IVSHSTewlx5PIWQze5ouITYrO4pXIOzR0em8WTvbNRbK90GdhOmq
         kXQka9Ki559craaF0p7me134GC4ZLVZIjAZpzWGDRai67mxvwVgUZ3UbTX7ouBaflBdJ
         ntlcLtZwuqxkSRpjn3v2Up5JHjfoS0+8iLv5n2sLhaSahXGBe3YRkvotfDMwit1RzLs0
         pJ5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:content-transfer-encoding:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature;
        bh=uegJiDhnQxQaXlYd/KXlqxqemOhHfM+yEvioj3JsN+U=;
        b=y5QebMcIl+UtARf7SZCPwwZ2XmyWFByD+9aOVCrD6rQxS4LoTiSOBZ7Bzmxn2Qkny9
         5it9ceiTAv6GCvJyIObL+dwMt/0rm87VzVMGRq+TZBiTjkFGrmYT2glKUUMBwM8WTU0g
         VRt2wL/hTS6X6rSrtJPbAUErWoeirdtAmkXK/hLxtZfSefdUcM3TiUbJxMmMvTubHWaE
         Uhx3qf7akuxmwUHLbwQYCmYR6LJraqrl1x+sF8VXvxgq7XJHSqxoSodGpIGflL3WWHEP
         6KXNTBUZMe7JomLHGmk7MaZ20TY61HIWambYNnrsAsX4lb+yPj2TrV0r7ZE9PAC5Dr5p
         G66A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="Vy03dE/f";
       spf=pass (google.com: best guess record for domain of mchehab@bombadil.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=mchehab@bombadil.infradead.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e23si1269809pgi.434.2019.05.29.16.24.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 29 May 2019 16:24:01 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of mchehab@bombadil.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="Vy03dE/f";
       spf=pass (google.com: best guess record for domain of mchehab@bombadil.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=mchehab@bombadil.infradead.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Sender:Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:
	Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=uegJiDhnQxQaXlYd/KXlqxqemOhHfM+yEvioj3JsN+U=; b=Vy03dE/fJC/z0esPCU5AkbkHF3
	iycmVoQXfI5JtgYWXdqkS/XOFIeUCCHZQloefUcIwvw/F9RID6w9JNTPlWLHVEAZMTcvhCuRDSlbG
	cTKg4kpk3xo67RR7YBdbuKoBzgMGnuR2OveRkdoAYSHL4SbPOEViLAvVOqGYPNB8S3srQBohoTvSM
	7Fln1mBeg7rufpwrymh3qF3m1/5FvbK0JOe5icvAQjJhqkZ0vr+mdRhWzeQoMLcd8cGZkrc4KiMBN
	r90mkuns5FaOpxt6Hy6mjCY2ZpaLtj6iqi2cI8edLXWL8UDTwQRKhd7t0VjpUbp2NerkecL5xH6H0
	Y190lk7A==;
Received: from 177.132.232.81.dynamic.adsl.gvt.net.br ([177.132.232.81] helo=bombadil.infradead.org)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hW7vL-0005Rm-7i; Wed, 29 May 2019 23:23:59 +0000
Received: from mchehab by bombadil.infradead.org with local (Exim 4.92)
	(envelope-from <mchehab@bombadil.infradead.org>)
	id 1hW7vI-0007xc-Rb; Wed, 29 May 2019 20:23:56 -0300
From: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
To: Linux Doc Mailing List <linux-doc@vger.kernel.org>
Cc: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>,
	Mauro Carvalho Chehab <mchehab@infradead.org>,
	linux-kernel@vger.kernel.org,
	Jonathan Corbet <corbet@lwn.net>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	linux-mm@kvack.org
Subject: [PATCH 14/22] docs: vm: hmm.rst: fix some warnings
Date: Wed, 29 May 2019 20:23:45 -0300
Message-Id: <59ddc30af749c0123af8b0dc04d3670133af5f8d.1559171394.git.mchehab+samsung@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <cover.1559171394.git.mchehab+samsung@kernel.org>
References: <cover.1559171394.git.mchehab+samsung@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

    Documentation/vm/hmm.rst:292: WARNING: Unexpected indentation.
    Documentation/vm/hmm.rst:300: WARNING: Unexpected indentation.

Signed-off-by: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
---
 Documentation/vm/hmm.rst | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/Documentation/vm/hmm.rst b/Documentation/vm/hmm.rst
index ec1efa32af3c..1ab609ca7835 100644
--- a/Documentation/vm/hmm.rst
+++ b/Documentation/vm/hmm.rst
@@ -283,12 +283,14 @@ The hmm_range struct has 2 fields default_flags and pfn_flags_mask that allows
 to set fault or snapshot policy for a whole range instead of having to set them
 for each entries in the range.
 
-For instance if the device flags for device entries are:
+For instance if the device flags for device entries are::
+
     VALID (1 << 63)
     WRITE (1 << 62)
 
 Now let say that device driver wants to fault with at least read a range then
-it does set:
+it does set::
+
     range->default_flags = (1 << 63)
     range->pfn_flags_mask = 0;
 
@@ -296,7 +298,8 @@ and calls hmm_range_fault() as described above. This will fill fault all page
 in the range with at least read permission.
 
 Now let say driver wants to do the same except for one page in the range for
-which its want to have write. Now driver set:
+which its want to have write. Now driver set::
+
     range->default_flags = (1 << 63);
     range->pfn_flags_mask = (1 << 62);
     range->pfns[index_of_write] = (1 << 62);
-- 
2.21.0

