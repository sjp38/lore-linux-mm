Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AFDD1C433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 22:20:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 62C3D214C6
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 22:20:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UDZlgD2P"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 62C3D214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F1CE56B0006; Mon,  5 Aug 2019 18:20:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ECE916B000A; Mon,  5 Aug 2019 18:20:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D9A656B000C; Mon,  5 Aug 2019 18:20:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8AC4D6B0006
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 18:20:24 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id a20so54419560pfn.19
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 15:20:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=H0Etnn7JHR8H7TocLV05oLauZ77NAi3PGTTr9FTaKTw=;
        b=G1XWXUx/0gvIFBJplqfkAgRZ80EwzbQy60LbVouygjPpEFBe0FNCOVol8mndtaqp5n
         NpRlQ6gaFEG+AHyu0PViQftG4MNSWU4+6gpNVe+EfVl/7oYqIp6Lm+X+Kj2qDIp0gncY
         RMPo2THBWnGM7aK1MeqUrM4NPwnksAOT/k9hh+fN474Sw0AxTfCdDVnhPhWypi7DSrHe
         KMhdQChBvjfyUhxB0fI3NSYPdo7K9gU2yVhgkXvyNGnomAvZJsOrAtyR0638nzOuQPCS
         UqivAtV0Ixle+MEfXRsH0J2Gz/VdImEnqSLhtzVUUvCq8UESC4D2GtaYNSyjH56TMkKx
         8FDQ==
X-Gm-Message-State: APjAAAUtjPYeLeVW16JT3P+zaWdGYVGVJymw+XB1wU6U0mqENfL2keIH
	dUSEcsaiLSLlJcJjZsxPiV8twfdRcjsVyCDtKt6S8Q3mUp01jz6QvlnUTMrGro1XRSe2fvOc+kV
	pvK08GDSh31MYCfFwqiL44z2lTOm1FO6gDZbVBS+Ge6ajN7uKYsPv/szcDcU8umNaXg==
X-Received: by 2002:a63:1749:: with SMTP id 9mr154855pgx.0.1565043623876;
        Mon, 05 Aug 2019 15:20:23 -0700 (PDT)
X-Received: by 2002:a63:1749:: with SMTP id 9mr154804pgx.0.1565043622850;
        Mon, 05 Aug 2019 15:20:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565043622; cv=none;
        d=google.com; s=arc-20160816;
        b=SLDkr7iGdtwNs3+gWU7F3dfFMH5+a9g1CdLzI4vc81EhPDWioJfGm3J48GH7a/YheZ
         GTcCx0n0sJisB4Pt5KidPEkVp/vharXM0ka0PCaDhH3sabn3Qe0xGp+sjM0X0hipwfRy
         NAldrGR87PcsmTtOnW4WXUAkc6l4tn2oDbo3v0mJasssVXXH0ypg9b4XsOYDwXU/f/PH
         r3224bxLTtF48MkjEJ5UTAE9L6zK3rHMlxQZYahT8Wr5GoIOwzAK3IcuCjptjyxhBLFL
         nXPCysKargMVUijggmxdy+5PGRBkSGKdlkuRpwS2hkDxBTN1h7qnQrtPHXRbeQPNRsjJ
         HdmA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=H0Etnn7JHR8H7TocLV05oLauZ77NAi3PGTTr9FTaKTw=;
        b=YQCOcVun87p+OWknP6V8CwKxNZXKQ49txIsqDF1LnPln2h7uQEzBI6gSSLF0m2Gmgr
         m7ayNanPYlN4LxYsLmUnUCDWM6CUuF3t5Rwwco5V+KQ1wHf7dL10g0OfeeyQ8qCT5jlC
         M2eQBaa3gT63F93X9wg2jnfJvUHFX8fOZeJjJTCV5vfmLcIc8uVodjxwNwZyjqLtLOSX
         Z9zbQROmwan6HelqszbyYlPoOGHTIRHtP51lWTM85m7wboOr3Y6aieKSNmqAqxvMMAXt
         /iQjLRxWxE/Hvr55TyhM88ngSVMkYxTtRbpEjljcBZoLYnaHuzENzSKoq7LZmLcVlj42
         2Znw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=UDZlgD2P;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id ck2sor99109554plb.1.2019.08.05.15.20.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Aug 2019 15:20:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=UDZlgD2P;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=H0Etnn7JHR8H7TocLV05oLauZ77NAi3PGTTr9FTaKTw=;
        b=UDZlgD2PuMBL9wl0f5xLH0x3A9s2q8HxsLrdHjkNK3SOB297SiXK4eDKAmDpzpVl0F
         w7RtBptvOSgkgei6aCHdJWFPpiqgXwXMNIebxu8QlDbK5Z8t4BrWzhYzunccIgMaW8sK
         sJyVIrDqI91Tqqq6buzI8UfXtB++A6hs6LheT/4+zFBgv64RCVjx8Owi0ChVufpwkbpZ
         2LuojDoYd+Vezc8faHDhkX/SZFHfkDc9OvfLKQ1u3UmYn4TNLMhIXBDbIlyGr5GhOr/h
         91/w2XsHFuoxIezqA/+us5UPVxiek/AM5+fz4RZ2lX85C4K/JJ/R/Pbt2SvrRyWhAfUi
         723Q==
X-Google-Smtp-Source: APXvYqzK4StBi4Z2q8H3xlbnqk9w5/yLbcwYtlETk2LVzUgJMZXcQMZS+fz6Zg+ZAAI3Y1k3oX59Ow==
X-Received: by 2002:a17:902:324:: with SMTP id 33mr34877pld.340.1565043622624;
        Mon, 05 Aug 2019 15:20:22 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id 185sm85744057pfd.125.2019.08.05.15.20.21
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 05 Aug 2019 15:20:22 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Jerome Glisse <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Daniel Black <daniel@linux.ibm.com>,
	Matthew Wilcox <willy@infradead.org>,
	Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 1/3] mm/mlock.c: convert put_page() to put_user_page*()
Date: Mon,  5 Aug 2019 15:20:17 -0700
Message-Id: <20190805222019.28592-2-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190805222019.28592-1-jhubbard@nvidia.com>
References: <20190805222019.28592-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page() or
release_pages().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Daniel Black <daniel@linux.ibm.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 mm/mlock.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index a90099da4fb4..b980e6270e8a 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -345,7 +345,7 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
 				get_page(page); /* for putback_lru_page() */
 				__munlock_isolated_page(page);
 				unlock_page(page);
-				put_page(page); /* from follow_page_mask() */
+				put_user_page(page); /* from follow_page_mask() */
 			}
 		}
 	}
@@ -467,7 +467,7 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
 		if (page && !IS_ERR(page)) {
 			if (PageTransTail(page)) {
 				VM_BUG_ON_PAGE(PageMlocked(page), page);
-				put_page(page); /* follow_page_mask() */
+				put_user_page(page); /* follow_page_mask() */
 			} else if (PageTransHuge(page)) {
 				lock_page(page);
 				/*
@@ -478,7 +478,7 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
 				 */
 				page_mask = munlock_vma_page(page);
 				unlock_page(page);
-				put_page(page); /* follow_page_mask() */
+				put_user_page(page); /* follow_page_mask() */
 			} else {
 				/*
 				 * Non-huge pages are handled in batches via
-- 
2.22.0

