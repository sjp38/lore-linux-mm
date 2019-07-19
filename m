Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2BBEFC76188
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:02:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC6D4218A3
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:02:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="aPtYU8Hx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC6D4218A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 92F6A6B000C; Fri, 19 Jul 2019 00:02:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 891F48E0003; Fri, 19 Jul 2019 00:02:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70B1A8E0001; Fri, 19 Jul 2019 00:02:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 36DAF6B000C
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 00:02:03 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id a21so17906418pgh.11
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 21:02:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=2SnQEihZXmbCxz7kEjeO3BZKTDlYsqkYF5GhuqOadJg=;
        b=G2DaqllKLrfJs5b7XXcIB32/rU6/ilJWWI8R5OO6nujmUZju6qm5ddWGGJPCzWwSQa
         ER+/Cc6IJykFpWTT+MAkSeK8+6xXMFY9NqdNIzeFaMYWB3/rkaj8FOLe/r988Jd8yF2R
         eYqnJA+gRR1RsHb+MuC4fHoe7OHEs7hj1lbPCJHwadCNa7cH23ud+EGXjqoKXsxDlHh8
         19/heQniEn/6L4X7bJoVDOrHjbpzHMqjsL/FnElSBBqP2NHrIt+zW7wQHBh7bI040tWG
         /ral/KjxAaT/ejauJ+S9tZwGUJ4kjftv8yi0tjYK+QWVV71wB77+QQ68m3PCZzabWmV/
         Nm2g==
X-Gm-Message-State: APjAAAX9Eau1yVJ+KJ1EvJJuSTqRcoUFDTdA9jacrMNoVf8N3IaFOoGQ
	26TkFGxFXr5qr1LnmFK8s10SzYKSwhQ0F2vkk4PXbUDDwfcQIn284hIuNUlRHHc/AWz5Nn41nnL
	85Klfy1I2uIz0Cy5aTdj9Z/ZEap72wZeCsr6lAyPceQ6AptNxaqCqrIIG2Q3pqFHD2w==
X-Received: by 2002:a17:902:e287:: with SMTP id cf7mr53700649plb.32.1563508922830;
        Thu, 18 Jul 2019 21:02:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx5vzujGc72DNT7dBwEyq0mvQzDRZeibjyQTXLnvU2VL8ASHPcLCzjUBCfcZLZiZmyZ8MSw
X-Received: by 2002:a17:902:e287:: with SMTP id cf7mr53700588plb.32.1563508922195;
        Thu, 18 Jul 2019 21:02:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563508922; cv=none;
        d=google.com; s=arc-20160816;
        b=QAuSr/kEI0g/t99ay0x7Z2pQqhBGdAy72nzDkmdCWm/Q2tkUx4jzLkjLc8sFItwuhO
         nAf1qRalU74Udywshzz2b8/zfL0XgOzJn0oun+pFUxpvTSf6SWyudlCwN9stj7kjRbXv
         R0qDMm/tIGdYll0wYetrBY0gCtzYU9fQJSC5hTim4JO5+wU9LAIbYaHMRUIv0NJhC5Id
         TChkKzm3iLcIhva9XngQNNN5huDU/8vyVNmxtnJmwnZT5aCt2dVKVE/fh6Zga7EB0CsA
         VRfgQh/LZHj1roBVULGuE2VjLzWCXP49sTqg2Me0J/VgAu+Ohr3WkMLrBiZjys3lJ0Wn
         pBxA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=2SnQEihZXmbCxz7kEjeO3BZKTDlYsqkYF5GhuqOadJg=;
        b=g5hePg9iqg7z0TfcAuep3As6d6u24AyxNfCIck7KRF967ivX7RMjtmPDy5WUntfFCM
         lyu3QjpXJML4Z6QPDHab43DLotSBzF6U1yu84Mm0hth+YmxM6aMIdgEalU4gj1/1nRQe
         ze8IbyWaZvcbNgC3G6ThL1/Mahb6DTkvAwy9MweUwI2szUwKccB6Bmg7K1g5E8pnT1sN
         7wb/+xCtcswB5EOi3eM4kwF7XtqAZoK4X33999LBMmH7i+5SVYw5Qqwzp3t/h1GfGWWC
         ZlEenVw6HxNu0xKptYFX0CFDQ8zsuAqaN3C268Ck/mJoU71azyj3Rs9jeVpfD1o87Roq
         aQIA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=aPtYU8Hx;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w11si3627506pgk.384.2019.07.18.21.02.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 21:02:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=aPtYU8Hx;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id DAFF321873;
	Fri, 19 Jul 2019 04:02:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563508921;
	bh=WIX+4yTSGgjulMaBlod+LF0gOGyUWTgf6fht0yor7qc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=aPtYU8HxzHVezx+iHN7CBfdflr/ZwCO2zUtpUjWE4DcNwA7stwb7PMaSkNp4W07Dn
	 W2Cocakhvrw3d3LLrVNDJSNS7WQGlYVQdNxZhNRMosGmexSkKUoyg1Fu3YMBIBnhzd
	 dpcFeU+2e7aseK5gCTavbp3TDeVh8AXlAShLDh7o=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Guenter Roeck <linux@roeck-us.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Robin Murphy <robin.murphy@arm.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.2 159/171] mm/gup.c: mark undo_dev_pagemap as __maybe_unused
Date: Thu, 18 Jul 2019 23:56:30 -0400
Message-Id: <20190719035643.14300-159-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190719035643.14300-1-sashal@kernel.org>
References: <20190719035643.14300-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Guenter Roeck <linux@roeck-us.net>

[ Upstream commit 790c73690c2bbecb3f6f8becbdb11ddc9bcff8cc ]

Several mips builds generate the following build warning.

  mm/gup.c:1788:13: warning: 'undo_dev_pagemap' defined but not used

The function is declared unconditionally but only called from behind
various ifdefs. Mark it __maybe_unused.

Link: http://lkml.kernel.org/r/1562072523-22311-1-git-send-email-linux@roeck-us.net
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Robin Murphy <robin.murphy@arm.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/gup.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/gup.c b/mm/gup.c
index ddde097cf9e4..22855ff0b448 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1696,7 +1696,8 @@ static inline pte_t gup_get_pte(pte_t *ptep)
 }
 #endif
 
-static void undo_dev_pagemap(int *nr, int nr_start, struct page **pages)
+static void __maybe_unused undo_dev_pagemap(int *nr, int nr_start,
+					    struct page **pages)
 {
 	while ((*nr) - nr_start) {
 		struct page *page = pages[--(*nr)];
-- 
2.20.1

