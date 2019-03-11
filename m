Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1DE3C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 19:58:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A9C0D2087C
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 19:58:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="tqzFM3Px"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A9C0D2087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 586D38E0003; Mon, 11 Mar 2019 15:58:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5363C8E0002; Mon, 11 Mar 2019 15:58:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4247C8E0003; Mon, 11 Mar 2019 15:58:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id F23C38E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 15:58:03 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id n24so6953306pgm.17
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 12:58:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=VX4hD6BpySBpY9Dp+LHSGDMOr/px9Qy0quyQ74u1HJU=;
        b=iF8KNag0McrKjQLAO2NlTzMTUgYUHTtlwHjrDyy2iaSv2+6/WfVVFsz1+ZnKuNCQ4g
         V/rVR6xoYKtGZj/zGkDxzVeWqdos6JrbFa/dcs2/Mwu0H3e15HCTHjQ/y4sShVKklft0
         KPYdogUdHK+y7ttIfZN+FkJA8gizU+rvyWfhhbs23THqvQ4M/W/WlHSI6ecXdwnayceh
         biuSj/y0Dtz8NapOCoSN/X+Ch4EfkPAgvifyJCUP0eq/5TXcceLp/DSkLNvgBowBz0D3
         VROav8A4Gi1aNGy9eyJtMWKGEdYcSZC0a4Hy/D7Ww+Urs7sk1kxahttuojrOvFo1rIhW
         DE8Q==
X-Gm-Message-State: APjAAAU77HU+G5yWMITV9lvEVDpMCmDeceuu3kADOKvMtMI1UYQjef18
	NGcG4n9Btgctzc/rzAkQRlpCxF16k1Pu2lkMpwmPc9Dnite31Fv9q/va3Anp0rYYy5niePz2Nrn
	d+DyV88dZdgbM6T2eT466LbVGL46q4E40QihonqWcMWhiZ9KBeny8K06bDFD4CB31vw==
X-Received: by 2002:a65:64c4:: with SMTP id t4mr31601592pgv.152.1552334283674;
        Mon, 11 Mar 2019 12:58:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyjTYOUBTram+vHTphGy2MMALu+mWyLAuk8IAmnfhGVjjfrpmlgpzQWBl/668Bcl/9BXzWf
X-Received: by 2002:a65:64c4:: with SMTP id t4mr31601550pgv.152.1552334283048;
        Mon, 11 Mar 2019 12:58:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552334283; cv=none;
        d=google.com; s=arc-20160816;
        b=C9JPjkLKe7bIjkXNwWPG3UJzo0CJc8zHOqD17GgYdt9ZmBjhFkuOCz2VHfSNuPFvJC
         u3KjnRWe5564ez4e5AU4ncnh6NaIO3USeUGPlKWMz6mX1mxgCy2Mpz6bxZtE54zUt1hq
         vd7JCRY9zJsz6fw5oaNCBfJYi+rSWzybOc+9oyLAq9qlMFUq26QzWS4E3BGgCvY2QVl2
         cEqUX90SkR3OXN1HtzRSlaNqahYEiIEXptoNnraTXJXxbJqM994M2aLtCS7Els2uNQnR
         z/adIuLaYfymkQArslIvGPknu3lTx2juyYC2GJoe9JedmrKaAHxYrmlL17JLURXIeFsZ
         IOyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=VX4hD6BpySBpY9Dp+LHSGDMOr/px9Qy0quyQ74u1HJU=;
        b=buuu/ualV1ROfcipIhySbNASDphROmifDIdVU7aFD/H53phZiaesosZvR4x0Og1BPc
         DfVaF5CNBx/uk0SSvCt325TRHJorgQr3pMl4jZaUa2/hqCDM8J5PwBwCDPvmrT28IIbW
         C/4GTkyKqkYgOO8r1RdaVoDCQbavrS41Xhzfb01fqG1IujPRh1iVuBHfg69XCWR/S4IE
         QSqDwT9//IA/7kzFZa9OHoaB/tZRqAKJR3TWygx7ohnWm7+drWYeuGS0LToO3aUuSBr2
         LIH5HCQTIBqRS5fuMpKFOb4yo02Wcw0wTfqqgJlB6xg+m41Ve18U2nc+Pc2rjuvZOVXY
         YLOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=tqzFM3Px;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p12si6021253plo.206.2019.03.11.12.58.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 12:58:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=tqzFM3Px;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1ACAA2084F;
	Mon, 11 Mar 2019 19:58:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552334282;
	bh=PvDL5hfdTo39+081iHzkelRzGH/4i9a2+4eP8jFCCv4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=tqzFM3PxPRKFZ/5BwC0Lahcl49AXKVUkZk0bdiUCFf6ak/wSQp5LjcZDoRo/6w8ad
	 GsbbI5h3PMNX4KpTQ4toDZ8VpjVNzJRRKyiYdIaaf1qsylNnPQG7U0FqtBUaNxmlnI
	 OAxG6WijGYVRXQQQFIWJ3I7Ck4rk6J2Ky25a8rqA=
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
Subject: [PATCH AUTOSEL 4.19 34/44] mm/gup: fix gup_pmd_range() for dax
Date: Mon, 11 Mar 2019 15:56:50 -0400
Message-Id: <20190311195700.138462-34-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190311195700.138462-1-sashal@kernel.org>
References: <20190311195700.138462-1-sashal@kernel.org>
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
index 1abc8b4afff6..0a5374e6e82d 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1649,7 +1649,8 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 		if (!pmd_present(pmd))
 			return 0;
 
-		if (unlikely(pmd_trans_huge(pmd) || pmd_huge(pmd))) {
+		if (unlikely(pmd_trans_huge(pmd) || pmd_huge(pmd) ||
+			     pmd_devmap(pmd))) {
 			/*
 			 * NUMA hinting faults need to be handled in the GUP
 			 * slowpath for accounting purposes and so that they
-- 
2.19.1

