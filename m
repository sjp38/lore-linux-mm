Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65E86C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 21:36:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E0B321882
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 21:36:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="s+QePJ3G"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E0B321882
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C18626B000A; Tue,  6 Aug 2019 17:36:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF02F6B000D; Tue,  6 Aug 2019 17:36:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ADE9D6B000E; Tue,  6 Aug 2019 17:36:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7A4436B000A
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 17:36:18 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id s21so49044133plr.2
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 14:36:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=e60IS95+aNpPzPs1GP5CDUw9xK87mCnyKjgs1xhwoEw=;
        b=GBmYZ+/NWQqN/YC+0wz0LpZgxuExtoJBPRIZyQIPvAZcHpbAVRbJUL0/ENyjQsxdOx
         sMDguU+3XUOC94zvbr19c4myz4lJcJpMTNT8Py45VavI9z6T7wXUfcxMC7sxpIjU7Nnf
         tmSHogpMtBdcAdOPww4BxGuKG2KvYJpZoHgwSPWgL77xjSMGMpQ+0cxlSKR1oaGXXkMJ
         Y9VVgITCQEWSnpzq3nPSzPW2BOW71Ga6r+MU+31t/GgqfEYVDSyAWbFdDqL5k+85zWiM
         /sddAJeogfzcKAToWu+uESCVVqp42t5lsn5yCT3mwysp5UStNNVOtNo1XnGjmSRT9SlL
         WiWg==
X-Gm-Message-State: APjAAAWHeaVM/oKzjfEAyyEf3Ux1uVHtSVi9ZONXK02yNmjnyw5jhe9L
	fZvJ84323nxwJMISyVqLvdy1estJ9zscHlN0wdG02csCqjDwYOOxv66MF7f8q7eVh+6LRbggFgF
	RKHd3mJh41ElNKJZE5PlFTyQv3eUhEmqdHkji7JfCyy9qGLUlLKftj71ojRokHGIZlQ==
X-Received: by 2002:a17:902:2bc5:: with SMTP id l63mr5299495plb.30.1565127378161;
        Tue, 06 Aug 2019 14:36:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwJKjYuKCfg9Aby/eC3oCoD6gsf+2q7JgU/eXVrIr0KpGSHu15zkvL4xlv+w26Ldc/b/8BP
X-Received: by 2002:a17:902:2bc5:: with SMTP id l63mr5299445plb.30.1565127377351;
        Tue, 06 Aug 2019 14:36:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565127377; cv=none;
        d=google.com; s=arc-20160816;
        b=rjFfEn91fe8MMY3cZQ+xJisCqnxYmuNAN0PdmYyT3QxbhNfyfQglNqenulNSvnD0Py
         xaYOuLtL3edYJXIvkp36oSEimCXiHPDAqldV+T1D1hp+rOxTF/WCNsS3Ui39UeCK9m7E
         BlvhgJb1WGn5TwHrx3h+givb0jEdxHq8yGulz8kmFKf3LPXLfVGbpLfAnvdv18K1+sOW
         MWsNTmzX/W2/WJSidYg/VlcLCeuYV1NF6InYH+sucupk+SoveXBw9vphPfyn7N78DqoQ
         XE0POhta2BVTXNdkChjHbTNHMzwkxnceVBZDAnuyc9wBLX80FajXaCMt6nBwbrM6YY8B
         ErAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=e60IS95+aNpPzPs1GP5CDUw9xK87mCnyKjgs1xhwoEw=;
        b=VSygIGFgajLBFPJvHmoWXB1H6h0DiCRkJOGEvLVzkJqw2KdhTnSToLmU7AzLmBdW7z
         aVf7Jgc4eF1+gS+D0Mn533zmnRgowWIGcTZtwQXqfoXcJoaS+e3cirbxz+UWxVgRjL0E
         vtkwFPfufXgkvbjqjwPGq1u0SjAGsX4aPI4o7zf+Qwr9sRZsIAndOA/UUnkSDQIQ6GsU
         hR912hN5oI07JOaKGY6ab526hS+u5672uipykx2qyOKozPdMD+csuBrS3azGy+SLjEMM
         1+wbe9gXT0W0HXYt72t6St+zCINx1Bte5TKzf2NvU3pDcPPBSeIMp6Br9WZsoUPTzurz
         Azhg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=s+QePJ3G;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h6si45651058plr.105.2019.08.06.14.36.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 14:36:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=s+QePJ3G;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C30912187F;
	Tue,  6 Aug 2019 21:36:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565127377;
	bh=vMeXn4r8zIRk/kbjlB9xWUci9fJf1v22wI04NOoZ6+A=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=s+QePJ3G06ESw8aXi3AbyVzNAALiman8kJSlLUU11pPkqeVACDTcDRcuUb299xkem
	 SACiha8S5L1mLVsOvrjbO+ymWI3QsR7gAMYiTigI1fyUNXXsCeAgKwMYWNwpXp9mGs
	 PQYn5Mgz7s4vjVS2JSOWmhHbI/IiSuF+jtF8nxjE=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Yang Shi <yang.shi@linux.alibaba.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Michal Hocko <mhocko@suse.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	David Rientjes <rientjes@google.com>,
	Matthew Wilcox <willy@infradead.org>,
	Qian Cai <cai@lca.pw>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.19 29/32] Revert "kmemleak: allow to coexist with fault injection"
Date: Tue,  6 Aug 2019 17:35:17 -0400
Message-Id: <20190806213522.19859-29-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190806213522.19859-1-sashal@kernel.org>
References: <20190806213522.19859-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Yang Shi <yang.shi@linux.alibaba.com>

[ Upstream commit df9576def004d2cd5beedc00cb6e8901427634b9 ]

When running ltp's oom test with kmemleak enabled, the below warning was
triggerred since kernel detects __GFP_NOFAIL & ~__GFP_DIRECT_RECLAIM is
passed in:

  WARNING: CPU: 105 PID: 2138 at mm/page_alloc.c:4608 __alloc_pages_nodemask+0x1c31/0x1d50
  Modules linked in: loop dax_pmem dax_pmem_core ip_tables x_tables xfs virtio_net net_failover virtio_blk failover ata_generic virtio_pci virtio_ring virtio libata
  CPU: 105 PID: 2138 Comm: oom01 Not tainted 5.2.0-next-20190710+ #7
  Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.10.2-0-g5f4c7b1-prebuilt.qemu-project.org 04/01/2014
  RIP: 0010:__alloc_pages_nodemask+0x1c31/0x1d50
  ...
   kmemleak_alloc+0x4e/0xb0
   kmem_cache_alloc+0x2a7/0x3e0
   mempool_alloc_slab+0x2d/0x40
   mempool_alloc+0x118/0x2b0
   bio_alloc_bioset+0x19d/0x350
   get_swap_bio+0x80/0x230
   __swap_writepage+0x5ff/0xb20

The mempool_alloc_slab() clears __GFP_DIRECT_RECLAIM, however kmemleak
has __GFP_NOFAIL set all the time due to d9570ee3bd1d4f2 ("kmemleak:
allow to coexist with fault injection").  But, it doesn't make any sense
to have __GFP_NOFAIL and ~__GFP_DIRECT_RECLAIM specified at the same
time.

According to the discussion on the mailing list, the commit should be
reverted for short term solution.  Catalin Marinas would follow up with
a better solution for longer term.

The failure rate of kmemleak metadata allocation may increase in some
circumstances, but this should be expected side effect.

Link: http://lkml.kernel.org/r/1563299431-111710-1-git-send-email-yang.shi@linux.alibaba.com
Fixes: d9570ee3bd1d4f2 ("kmemleak: allow to coexist with fault injection")
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
Suggested-by: Catalin Marinas <catalin.marinas@arm.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Qian Cai <cai@lca.pw>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/kmemleak.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 6c94b6865ac22..5eeabece0c178 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -126,7 +126,7 @@
 /* GFP bitmask for kmemleak internal allocations */
 #define gfp_kmemleak_mask(gfp)	(((gfp) & (GFP_KERNEL | GFP_ATOMIC)) | \
 				 __GFP_NORETRY | __GFP_NOMEMALLOC | \
-				 __GFP_NOWARN | __GFP_NOFAIL)
+				 __GFP_NOWARN)
 
 /* scanning area inside a memory block */
 struct kmemleak_scan_area {
-- 
2.20.1

