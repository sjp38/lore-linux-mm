Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA89CC0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:53:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 762A220679
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:53:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 762A220679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D0AF8E0008; Tue, 30 Jul 2019 01:53:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 181748E0003; Tue, 30 Jul 2019 01:53:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 049828E0008; Tue, 30 Jul 2019 01:53:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id AAD918E0003
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 01:53:43 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id r21so39634995edc.6
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 22:53:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=LklZI+jjNy9P/Vf1oDAlKWfBdOZ3w4ODTtcULXIYH+w=;
        b=Qir4hcLqluTph1VEMJeyNWolANlmbocuX1H5jDM6B4dCGBuPq2JQt+XErxZUbUwVyv
         x4lVzBBpq1dNwj7KEOCyMyQb2QeBo8eX79rqUFEcLXPkQBIeYZmYRM1rAzW0sOZ4pYXM
         GWlOKGW2KixrqGW0eWaaHNIqSYfWZe6a+C1Mp1nh7oGcBazQCIiNcfamPhVUZ6HALjFR
         NBa1GrquQtKSLVp9VN36yQkvVmNfwolwb36/68/ho2zgfjigxJ8RpVpN8KnP+5CSOuWp
         uJdNO4xDX5KSwBTkd9bJ+6XTE+knCRCOFIzWL5tIHCNHVbonfSbJE9c3QN6WvrS2Q2JU
         RteA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAXpsIyAhpPFSidvmRWkgV9Xdl/T6qdp1YcP7FNkwvpE3ThNBvR3
	gazqKwHjIFg0/HNhqMS1xel7PG4kqvVcm3gfFy+F9+g1iCZBHN7w8BkygR+qb3qQziqefbEcEPG
	fnuSJRH2LpjzZ7po+9QLu8EOzCTljKgpIQX7zh0GN8CDvjks2xvuwldJkhl8amn4=
X-Received: by 2002:a50:9729:: with SMTP id c38mr102498609edb.283.1564466023218;
        Mon, 29 Jul 2019 22:53:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzckmsRdiSFtrdRq/s9cZSyOxhH1cbkR2ytIbHagtmh9mCnSZNFAJDedONgQgU2XZ1WJU91
X-Received: by 2002:a50:9729:: with SMTP id c38mr102498577edb.283.1564466022502;
        Mon, 29 Jul 2019 22:53:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564466022; cv=none;
        d=google.com; s=arc-20160816;
        b=bDInWtKWZTsUkj6DqZa4Z373rP0/BSYrd62urlgr5Z/Yq/Kh234XrxWNWxhZGTagV9
         j8PR4B01SZ1myVja7ScLoUhvhv0ujWYaFjZBjPzi40mhb8DUxMv5ADdU4RAUWY7A4ceB
         AvgmMU0eKzOzH+xAMJaW84c8q7Mvs4ocgSnaljk5x8kymA6/r2f4BUKdt8tAQlk9LyLc
         qGew8KVi1On7Xs1H/PhMeeikttHm6T/XqfNjFtJWYzNEGS3PZtHpKSNF6zRuLvG3BAci
         8rc2dJYr86NZ5JzQSq7dbmTm5IF8PMUa2p4V5LTWs5FoqofKNHvumU0vbAmzjO0nONs1
         T3fw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=LklZI+jjNy9P/Vf1oDAlKWfBdOZ3w4ODTtcULXIYH+w=;
        b=NRIhCxdCfgznOQbfMfuUqGPjR8BbdhIV4tKMyj/0Z8cwN59mJo/mPLRAz41g5+9r8v
         Pls61ASAgKq7x04rZQQtodTub0Ve4Om2LTzI7tG37vKqwB/ksO8K+rE1L89RhZnv7HSD
         t/S8rKbiQClsyZxFLG+RCca7V+WOHa39k0zbinjB0rot/ScN2wzs43psO3JDfLmyq4CC
         D33iVUwsWpu/8imkEeYUQ8YJHz+KuqFjXho7klSa2eU6wbSSuz377lVpaNMi4jNfhAYm
         l4S++NJOL6ckorxLqdiZ84/xw3xxCjW8W7oiFUpUUmszBW6OghBkkQWHy7mDmLe0Sijs
         d7hw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay7-d.mail.gandi.net (relay7-d.mail.gandi.net. [217.70.183.200])
        by mx.google.com with ESMTPS id l8si18237170eda.181.2019.07.29.22.53.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 29 Jul 2019 22:53:42 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.200;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay7-d.mail.gandi.net (Postfix) with ESMTPSA id 8A9D220002;
	Tue, 30 Jul 2019 05:53:36 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Luis Chamberlain <mcgrof@kernel.org>,
	Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Kees Cook <keescook@chromium.org>,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v5 02/14] arm64: Make use of is_compat_task instead of hardcoding this test
Date: Tue, 30 Jul 2019 01:51:01 -0400
Message-Id: <20190730055113.23635-3-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190730055113.23635-1-alex@ghiti.fr>
References: <20190730055113.23635-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Each architecture has its own way to determine if a task is a compat task,
by using is_compat_task in arch_mmap_rnd, it allows more genericity and
then it prepares its moving to mm/.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Acked-by: Catalin Marinas <catalin.marinas@arm.com>
Acked-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Luis Chamberlain <mcgrof@kernel.org>
---
 arch/arm64/mm/mmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/arm64/mm/mmap.c b/arch/arm64/mm/mmap.c
index b050641b5139..bb0140afed66 100644
--- a/arch/arm64/mm/mmap.c
+++ b/arch/arm64/mm/mmap.c
@@ -43,7 +43,7 @@ unsigned long arch_mmap_rnd(void)
 	unsigned long rnd;
 
 #ifdef CONFIG_COMPAT
-	if (test_thread_flag(TIF_32BIT))
+	if (is_compat_task())
 		rnd = get_random_long() & ((1UL << mmap_rnd_compat_bits) - 1);
 	else
 #endif
-- 
2.20.1

