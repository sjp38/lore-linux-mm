Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1BBA1C28CC3
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:22:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D8C8F27332
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:22:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Q565lAS3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D8C8F27332
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 73E106B0290; Sat,  1 Jun 2019 09:22:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6EEC96B0292; Sat,  1 Jun 2019 09:22:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 604816B0293; Sat,  1 Jun 2019 09:22:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2694D6B0290
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:22:19 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id s3so6556214pgv.12
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:22:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=YEs1CUWLBNAh996e07/+w+HkkiHiP49BkNBVAGtS5tE=;
        b=AM3sCgCC3WYJHQLsQXp2Pbf8nNhQjyOx8bTSc2aovXsvr0h+4hOAZlRGVIQAcT59bt
         poNQtDkV7t82l3xgg+fWLHgmvBQNfKbOwi3XNy3v1PBsduEWJTh5daz1cZPKI/H2JIuj
         kZbD4HMu4RQysa3+6GXmJMKmQaA+Z3CUaZGJGHmoCt7tFBJ6J0V4WF/WXmJVKicFV5gW
         i1Dbw5TlmNys/nRoQcLnAwVvZs7RxMrryzMTBPCbnT2aV8D628tMkJ8IY2d1Fc9Oxcfd
         4OZCar/2X5cXagazO0wUatcHUK5T/jJ/C2KXVa1Uy8+tcp29o71klb71hVWIT9YynryG
         RLjg==
X-Gm-Message-State: APjAAAUTEXMgl5xpTZG7stQmGYPhmOr/3On9Daf89taIDRJ/TOmjjTG3
	mgvsYWUdK5LTX4Plze4qQzH8v2nzXw85i+IuBzuk/0Jcyc2/rmtKrZlr+ZRqQMS+Zhbblfjup1Q
	DdcdI9Ntx+/FPlVww77+VZveSCviiK+2Q1ybsRzhwVjzhLEb0xAqpa77AtVoUXz6m3w==
X-Received: by 2002:a65:62cc:: with SMTP id m12mr15439168pgv.237.1559395338787;
        Sat, 01 Jun 2019 06:22:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzNvkPeJKdGLePzo50ZdvIAAM8eFBlHs12eZ40vfEtH4hzNnfTKlB5RtzMepBed2WfG/kAi
X-Received: by 2002:a65:62cc:: with SMTP id m12mr15439114pgv.237.1559395338174;
        Sat, 01 Jun 2019 06:22:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395338; cv=none;
        d=google.com; s=arc-20160816;
        b=X1K3MBFUk/idtgIrmFrE1REE0+rigXaFMgnTevF2N/WY74g86i3VqSlgzUPxA7O5Z2
         xr21++3b//uyJAWIrqNgV7h8JXEZAHlMxPxRKj9qUibw1EQh68N27IoJAmzEOCOfvXa3
         TYqYwfPCT+eQWmNBWJQ05Cga5FZ65SOe7ZNZMr2foopqAiiY+GcCB4Twhjl0YvqATbbx
         WebwEa7+FJjq4mP3nqaafp1l35rz4i1R+ySjzZwhHkssOBzWMeMzUsyzALhJG2dBvB/h
         h+Zgj8QKx15R+5oR9U+sBWQuI+3heKl1Su8/1pceaswGgwjjZfUGNiERNo1AE5DR+b9Q
         eSIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=YEs1CUWLBNAh996e07/+w+HkkiHiP49BkNBVAGtS5tE=;
        b=hrjZd1i42McQFH3SL2QgJf6v8KufePHCJbdJ2JWIRZRHjLIjB+DL3jjE+c9RQPyw2y
         2xsZLhcXwNGMuaCRGkr4CVZs67rN81ka3Pj4Gg96IUkqgYpUJFOgMKjKpcepdbH1xsjz
         4gisAyPGakZkL7OMNzXdT9QijLmjLBr5DhOyfLen7rvEbk41TpQu/LB8/cDOcJnvShcn
         uB7udTEHXFw7ptg1f8qIhhJFVzrKCrqJzFmPG7P/TolX84xVTPf8WhrSjliK7p7sePdW
         aFsh941hdHUCqyqcQ1YuYLyFSEMRPawzBiiBDAR31Ez2xsCvfThxT5mfds82HKqQTCIA
         Ersg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Q565lAS3;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g4si10536025plb.188.2019.06.01.06.22.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:22:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Q565lAS3;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 4DD2427321;
	Sat,  1 Jun 2019 13:22:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395337;
	bh=CdSJ4YXUM+EkF0+2PyNDv8RXYWcGiSC7PtrL3DKGYIY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=Q565lAS3F9l82JO/04MVdLIMympsA8l5O5DwmISGvnT6ZYUlyjuXc9U+ScJNpiqAx
	 3EpAOYpH2qaVdIt7KL2p7c7XZGdu9X7bTUwIInyn9lBFqhDfQxNyk24k6h/egGAf4P
	 KTQkwbWiDYY5/V2z8yUW16CvSHXhH56cCyza54Oc=
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
Subject: [PATCH AUTOSEL 4.19 007/141] mm/hmm: select mmu notifier when selecting HMM
Date: Sat,  1 Jun 2019 09:19:43 -0400
Message-Id: <20190601132158.25821-7-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601132158.25821-1-sashal@kernel.org>
References: <20190601132158.25821-1-sashal@kernel.org>
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
index de64ea658716a..b457e94ae6182 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -700,12 +700,12 @@ config DEV_PAGEMAP_OPS
 
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

