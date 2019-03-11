Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8367BC10F06
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 20:00:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 39293214D8
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 20:00:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Oftf0J15"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39293214D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D9E188E0005; Mon, 11 Mar 2019 16:00:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D24BA8E0002; Mon, 11 Mar 2019 16:00:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B9ED98E0005; Mon, 11 Mar 2019 16:00:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 772A08E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 16:00:01 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id z5so8889pgv.11
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 13:00:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Q7aKCqbKwPKjXc9GxI3Tout/MP+Hue4x+jJeP3QpjUM=;
        b=rTMFbWFC4Fst0B/MRIfX9Ya3hQ0TPKijqv93Tf9aHLigaApno9YEDp51cp9JqvnhGp
         q01EzMjBw/M0OxoKL3nFy2W7CnO23qvSUuI+NWs85tw8PDvu406TVU5hYMYL9/l3lnxA
         pMSXfYFReUR5O8vaf1bfBjxJL94ZHNxqiH7p1A3kcLyyFVWs4XYzpEG5hyVQvTcmy0d8
         0zs+VoIXLJy6awtBguVN6CDNKA/K2aobe7LcvIKzQdChh0FsYfStopRGGJFL9TG1zz/B
         bmZywGqpSl2Nj+H+Frs2+S6YPdAK1gG3s80ZZ7KrkQsLJljYkTgxojU8E7RXFokcSaHn
         7QJQ==
X-Gm-Message-State: APjAAAXfUE5MAlw9HoVG45O8XgblQKuwnzhUWQA4yHo16PYq7JbYuc0C
	ibdGgm1lmdM2VfkfoJWgGWuS5n5xvbSGgmhZvV7kxZP3hEJMreJyjsY5T+QDQC3N91pMpBY9SDV
	+tetHjYHImWdOTadU+onEKjT233MGFSrPmmzmqY/wItosAZSvsKKcerikN52xVPi0ow==
X-Received: by 2002:a62:e716:: with SMTP id s22mr34414074pfh.35.1552334401177;
        Mon, 11 Mar 2019 13:00:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyHls5yS+EvBuqitJY4rg9hWsefZtBooNuNCaoO5jWcvjkc4N4cOZtVA+d67o5y1Z9hyCyC
X-Received: by 2002:a62:e716:: with SMTP id s22mr34414042pfh.35.1552334400503;
        Mon, 11 Mar 2019 13:00:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552334400; cv=none;
        d=google.com; s=arc-20160816;
        b=DUOv1ARd/SCKDzOsNlEF0YkQJvszrmacF6IddferIwPhWMERYY/DF222yhKKYNR/E3
         rwrQcxxJLZqGCsWSk+S5a8DSv1fYW3VlZk0HwaOrj6Fz/7XGlggaLdb2U5N7qnJ6usLC
         SKghr2W5E6JXXgzhjpbVuHfJTNR2Ur0Su3qS76nEgP6tOrwHrkL/xtfc4C/0wogAj61M
         gvn1m1EkbsrDPLWgCqQZkKSdJyzx8VgPzN9Zl/pSY+UftUBnGtPU+kWB8DAYjlJJJmVF
         XdMg2EdtAoNDXDgCpD3Vxg1YGpf0pKJmd6oLMCfujtWcD4OsqyFL4H++DZQS2eLCE7Na
         eINw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Q7aKCqbKwPKjXc9GxI3Tout/MP+Hue4x+jJeP3QpjUM=;
        b=mE3BVgkIvW7RxMj1dH8PCwNce1+QBW1Ngx7+9T8K4w7233KdIZwjH5MQLipKb7H3lj
         lduGabkCrmoFEiZvcrpyJFd++NcDsfM2DOEKarncNB61EdZvVmjDyimmiVmaTCCdQuu7
         odN9tU7FlgmR1ja/Hnmx5R2Wi8UIk7qj34ZMx7g/OCy9asqklzzrDZ1WDuqYdRphQgqs
         JzTOx22IWbbiV7axIIbmzYbeJk7yb2UWTUWEsv/ZUxkDahyQPzp1p0ot6ZZxNYGkROvH
         +bFJg+NVtzryy5Q1wQAFxMTAN+P8+231JKFGqbWnigBPTe7wCJudkyQHdlIAkMOrr5Ig
         k6jw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Oftf0J15;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j2si6152216pfb.268.2019.03.11.13.00.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 13:00:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Oftf0J15;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 830FE2064A;
	Mon, 11 Mar 2019 19:59:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552334400;
	bh=2ahr39JG4ahpvgXXMLZcvQGN109+8NUbGczsBU2Hx7g=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=Oftf0J15CcPizWZ9C6WR5oNE7StelMq+UfdPDnPmGSmzmoV7lh0Y20AAxR6zoYGZk
	 FythV8wA1etlKCuMYRZydtHobOIWS/h6qwXD0Qe+V4c0Sy6Wr17QUjMLL6PAxPaVaA
	 dVeeytRimHRQd4nNetRAj4kx0Z/GuvzzUaN4haog=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Yu Zhao <yuzhao@google.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Huang Ying <ying.huang@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Keith Busch <keith.busch@intel.com>,
	"Michael S . Tsirkin" <mst@redhat.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 3.18 4/6] mm/gup: fix gup_pmd_range() for dax
Date: Mon, 11 Mar 2019 15:59:49 -0400
Message-Id: <20190311195951.139741-4-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190311195951.139741-1-sashal@kernel.org>
References: <20190311195951.139741-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Yu Zhao <yuzhao@google.com>

[ Upstream commit 414fd080d125408cb15d04ff4907e1dd8145c8c7 ]

For dax pmd, pmd_trans_huge() returns false but pmd_huge() returns true
on x86.  So the function works as long as hugetlb is configured.
However, dax doesn't depend on hugetlb.

Link: http://lkml.kernel.org/r/20190111034033.601-1-yuzhao@google.com
Signed-off-by: Yu Zhao <yuzhao@google.com>
Reviewed-by: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Huang Ying <ying.huang@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Keith Busch <keith.busch@intel.com>
Cc: "Michael S . Tsirkin" <mst@redhat.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Wei Yang <richard.weiyang@gmail.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/gup.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/gup.c b/mm/gup.c
index ce1630bf0b95..29a36fae8624 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -885,7 +885,8 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 		if (pmd_none(pmd) || pmd_trans_splitting(pmd))
 			return 0;
 
-		if (unlikely(pmd_trans_huge(pmd) || pmd_huge(pmd))) {
+		if (unlikely(pmd_trans_huge(pmd) || pmd_huge(pmd) ||
+			     pmd_devmap(pmd))) {
 			/*
 			 * NUMA hinting faults need to be handled in the GUP
 			 * slowpath for accounting purposes and so that they
-- 
2.19.1

