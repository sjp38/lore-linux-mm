Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C565C76195
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:06:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D0FB218A3
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:06:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="IMkRRgg/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D0FB218A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CD3C78E000B; Fri, 19 Jul 2019 00:06:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C84018E0001; Fri, 19 Jul 2019 00:06:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B4C1F8E000B; Fri, 19 Jul 2019 00:06:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7E2388E0001
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 00:06:52 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id q11so15091988pll.22
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 21:06:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=qky3/CMVvm8BXSiLKgAZ0IM+AMXK0wNoLNZORjETYfA=;
        b=MP1CoN1v1QHJnI7HjtbG3Fjcf+AFJQSuVSlDssMy7eaKESJ/LDFnl15j3pgRxj72So
         uBk+9VKmEVrum7sR7IBm1sNQBFjul+dkoiz3nwVOBXEkJ1DQPBfu2vQgOxse42h35vpM
         E0LuoXGTfan/qgxaGz6T88mV9xwAkrj94xymiEEYtxbllBi4OvsMj9VFS7KBwF1vRFbT
         XPkMz6ehhz5OH/+8nF0c8ofxFHheHKYrAm5TBdKdVB/yQoGKuyMld9Qhgg1GB70CcH8n
         h9S1XbHQvZU6ODpSd+oDRRd9an/bPnmyS1PXaRLrO8iPALEXaDlT2+mpR9DI64vNaq2y
         O8Jg==
X-Gm-Message-State: APjAAAU5gfoYXdddiazOakbWGRK+vQUgU903C7PZcAncRutauj35gbV4
	APVU8EL4pN3y2Gu3QEY0UqX9o7i2oDd8t81Ny4pof9C00KSWxakiqxbNd86FmYv+X8jBAkb2FBb
	0+N5CyNP3jblx1A41/prQe2xCfDF0VHkV4AliebuZcL/cbPY6L8Aw0nxZLlOJlYJnnA==
X-Received: by 2002:a17:90b:d8b:: with SMTP id bg11mr55189427pjb.30.1563509212202;
        Thu, 18 Jul 2019 21:06:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwfoYai4rEumhpMEfBWFG0WsTPNPgnFxNOqRnmjr3QQiKYv+s5xzhAS6IbgPIvH4pJjtS1n
X-Received: by 2002:a17:90b:d8b:: with SMTP id bg11mr55189382pjb.30.1563509211555;
        Thu, 18 Jul 2019 21:06:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563509211; cv=none;
        d=google.com; s=arc-20160816;
        b=io8zazVfjWJStMCua40FiG/HrICj3rAczd50kExig4IPvp98gWN+Q5eQ8JyXLg+X9d
         K9JN8x4pcWSYKCT6cU84965oHChEzbjlRdjA/OIiU1e+WG8WkJ5uCI42ITXfU7HeqnfI
         +2sreD/mHiN7yG+9nCU9vEe0FUTfIJSF6vyUwBXYDgZC+eYCB3czBxEOJmSzN6pvOb46
         594e3R620eV3IyEFo46HNPcr0fAGxlpuU/RLmmMl3rc55uwYArsJOU5CrO2VSB0Cc4JB
         O6jynTx1xxC7N9spWRjoG0lPzz+P2Oh+TjROe9yiwlFf2rXEfK6hGUqjTkCBy/cRO0Zp
         infA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=qky3/CMVvm8BXSiLKgAZ0IM+AMXK0wNoLNZORjETYfA=;
        b=jRo+UFm5Gpi6OjCwnlTUmhO7sNThLAflU6flHjmYXclllBCNGxy5NLdacoeDL+1sYJ
         +snwn+3AT/iAzB+VDcZx/kVoXShrUiC4eQS4YpoG8lFFklTpcnh5TdypaHzSCxC39jrX
         N96heB/4KC4oEu8rdnduGyR1QgxSRSLlwOzP3+MGAtGcCWFb+wARRuA9+oQHqeSrCHMg
         RwJOHn7feEdyNXsz5nO/h6y4g/7HGo6BvOou83eEtkaBSiUEFOEwJt2BAaXufspdgS7L
         F6L6CrRRxJcihsmM3nTjt84SA1JQZcPKkAS5SOL3XcJBakbHrUDGBN7vs23ctP4/SZfH
         ymgA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="IMkRRgg/";
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id cl14si1416305plb.341.2019.07.18.21.06.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 21:06:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="IMkRRgg/";
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 3BD72218B8;
	Fri, 19 Jul 2019 04:06:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563509211;
	bh=2fRjPlFI+IC2gcVvwucsAE2Olid+tMqkjJzEkKVk00U=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=IMkRRgg/f7BTXgHk4ESTEEVb+qog01H0XI1qXA6/9SiUJg6zJpqgvA97xAUQxoVKK
	 uqQWoxjuOxO2QX09kTzMvlU6Yr33F2yLf3/iWofE3zntFj4q9IrqKprsLc6cEDEQ4k
	 A9Jnwv/mkI0fZWR7RV+pGqP2EyZrJwfZbZU3yGFI=
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
Subject: [PATCH AUTOSEL 5.1 129/141] mm/gup.c: mark undo_dev_pagemap as __maybe_unused
Date: Fri, 19 Jul 2019 00:02:34 -0400
Message-Id: <20190719040246.15945-129-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190719040246.15945-1-sashal@kernel.org>
References: <20190719040246.15945-1-sashal@kernel.org>
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
index 91819b8ad9cc..60d759f4e4b5 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1545,7 +1545,8 @@ static inline pte_t gup_get_pte(pte_t *ptep)
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

