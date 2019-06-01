Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43DF6C28CC4
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:17:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B1F1251F0
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:17:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="x+MA9Hcl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B1F1251F0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9DAB66B0007; Sat,  1 Jun 2019 09:17:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 98A2F6B0008; Sat,  1 Jun 2019 09:17:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 853006B000A; Sat,  1 Jun 2019 09:17:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4A3A16B0007
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:17:28 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id x5so9623166pfi.5
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:17:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=aieyxn0mEzFmT/SVMyLfZDKWsbL/bT/xQcHnCZy3OlU=;
        b=Pp0/85da30DnuTv6HhFoaj/v53Vt0hHyW0ATeFQZwfGiSJFsJBdIaSZwufV82PJgkV
         PgVizPla/8aoIpolmno6bsiBNxwW0l4AIQIIr4yNAUW1fqtzUde667Bo81nE4nVtLoIA
         5RHN4t6vVXHcpEIn2ccxpG4CmOI/eQm2nXP5iM3eqRz8qb3saPpcEOf2N7QzSxEnwDb8
         VtawdXD41R2ZbTHRc+uJUFqIcG8HReoYukFWEdTZXxsUR5qrP2APtpZrTFk1V5vDa2dI
         ST28oTXWwUjP0KMF1LSLxhJQanaY1JZkcVi5gwH0Lg+xQfhlTf3L+SR0QhzFMw163nXo
         jnWw==
X-Gm-Message-State: APjAAAWAYsQg1n5duvYqNFC6AL6jZJ9sub3njr7fP3aUR/YcxMEXqpo9
	79nfMNKPXDCS/ptKMjt+jHEQFslqqQpw9W6zKb1nsZaTUd+JhPROBwDqadA6HTVr1R6U2d/fMUG
	zhaSJ01+KNhG36YhWmFcThZ+K12FwceOeWFDIjlhYJtF0LPbUTVs1OwSu/JAlijd85A==
X-Received: by 2002:a17:90a:be02:: with SMTP id a2mr14057221pjs.73.1559395047848;
        Sat, 01 Jun 2019 06:17:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx2i+mgq6jmH96NIsc9DYeNSuVHQOjfYIuEucnAMdOlf21NXg+B6jbChbcomb9ahipEhR2T
X-Received: by 2002:a17:90a:be02:: with SMTP id a2mr14057145pjs.73.1559395047130;
        Sat, 01 Jun 2019 06:17:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395047; cv=none;
        d=google.com; s=arc-20160816;
        b=CPdMZ6t+WJEU73UnVJVPZLpfeSyjGWBkOjkSANphrSGJE/lcGC3o6tSflTFg+OQPUy
         ukz3Jn1LOxI6PKHZWxakVXL6QuM8TXC6QGZWIOCexVh942p8oWuKwb1s5DCEkWbzpnEK
         Na6komCE1AKtU0Mnk2tOxphfy1rGouZmbC/6yo0JdxufokRZsBn0VfaxQ17h5Jqsm1Lj
         XqG/KeMoe6681EltgidxV7Em0qd3lGTwOmv566QvCuJ6NS8eyHjIT0PqEMQ22nOiymVf
         LHSvNjHwEVnTYuGaFMV5nuymei+kg9JrzDV7iphEdM5j463ghkHEunu/xoLXAWAzJldK
         xrkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=aieyxn0mEzFmT/SVMyLfZDKWsbL/bT/xQcHnCZy3OlU=;
        b=RzrO0qeONImX3l6nVW5riY1r30v/ULKvHMw70yBbJKgKeCJyjaAYQJymC5SG2LgMOi
         net5VNwWismHx8OBe47Lg/LleP/nU7Wl+UcDlHtSx6IwExNR/jaWDstlE+PCFAx5KZAr
         Y5OmIj7mELBYT+7sMT4n5lUBZhHKFdp9+cIJBjth4abce9QUPOYFxpNOplXWVNtwXrB2
         tdiX32S7mB3Jr3vn8Ax5bzdmukN+tp0tLUVkHID8nCSKOGyVxBeS1x0DrBN2aT5YBVDs
         W1wjE6u+fvsvSVteMAXs39Rra1HsJV9+iMBYFT4DqXf4JA97Qk6w4xf12Rb2Sf/PD9PO
         58Lw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=x+MA9Hcl;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j6si10262451plk.120.2019.06.01.06.17.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:17:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=x+MA9Hcl;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 45455246F5;
	Sat,  1 Jun 2019 13:17:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395046;
	bh=bjdhm5Xwy5p6mlRyQ5ERQsdIxvgBVKfKEgwzZJc15mE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=x+MA9Hcl/paqVGs4EnEdbjwX5CMgRZPriUFWfbom6NwDCI1JHj4Iabq/g4cFb6ZpJ
	 IFKGWERZXXaPvsjOiWQIwtqzWgTkSzwp0QYj2ogvvk1zwRNLK3Omyx8AquAFA0tcMZ
	 rczDcM87bO4HAQH8FUVENyJyM1M8o3TbgN+20vvM=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Balbir Singh <bsingharora@gmail.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.1 011/186] mm/hmm: select mmu notifier when selecting HMM
Date: Sat,  1 Jun 2019 09:13:47 -0400
Message-Id: <20190601131653.24205-11-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601131653.24205-1-sashal@kernel.org>
References: <20190601131653.24205-1-sashal@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

[ Upstream commit 734fb89968900b5c5f8edd5038bd4cdeab8c61d2 ]

To avoid random config build issue, select mmu notifier when HMM is
selected.  In any cases when HMM get selected it will be by users that
will also wants the mmu notifier.

Link: http://lkml.kernel.org/r/20190403193318.16478-2-jglisse@redhat.com
Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Acked-by: Balbir Singh <bsingharora@gmail.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Souptick Joarder <jrdr.linux@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 25c71eb8a7dbd..2e6d24d783f78 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -694,12 +694,12 @@ config DEV_PAGEMAP_OPS
 
 config HMM
 	bool
+	select MMU_NOTIFIER
 	select MIGRATE_VMA_HELPER
 
 config HMM_MIRROR
 	bool "HMM mirror CPU page table into a device page table"
 	depends on ARCH_HAS_HMM
-	select MMU_NOTIFIER
 	select HMM
 	help
 	  Select HMM_MIRROR if you want to mirror range of the CPU page table of a
-- 
2.20.1

