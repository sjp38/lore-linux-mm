Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0976C7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 13:41:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7C1CD22BEF
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 13:41:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="ELrxyKFQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C1CD22BEF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 19EB56B0007; Fri, 26 Jul 2019 09:41:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0AFF96B0008; Fri, 26 Jul 2019 09:41:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF8986B000A; Fri, 26 Jul 2019 09:40:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9C8096B0007
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 09:40:59 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id z14so25981107pgr.22
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 06:40:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=usjVSK9mfiQuFZBFwSBuMP/3nAEHHdyUsL0h8BamR0Y=;
        b=ApOcKX+JkM0ZEYad15W25rmlvGpIjWvwzOZtjTBgIcAPC+jfE3N9ppliPBkEFMWTfl
         NRl6pGLL+o9tz0c17qAdF5r80LGhf0AuY9M/bIB4xqXOG8AKcsSEfu3+3c6pbb4C1V0e
         mLu03suwsru+NkMRjBaWFypKeMZmtaxD3bS6tYNml04vYciLWS5SklCCokR1+MeQEqpp
         pugjMC/Iln31AC8ZYMsSvPwt/J9XqUmbHILd6kF9dtOsOZ/2bVUoty3Ri2YCgZgtZDpy
         vNvcYBem5z9tmuK1iqvJblOpjvhWJDFKlOOlUEqW5DtrI98R93Am8VZO+IMmMq5B1r2o
         VFrw==
X-Gm-Message-State: APjAAAVQE00Zssbv259DqTrh7K05z+8VZnghKKUAQTtEv0/TS5BGkn2E
	hVSlPUN/gYGDs/uctAK7mkPXssXUrOPKWZPlbB106i8TfBlW1q/F3AjyXoXhfJHA5CYD60Lgyb2
	RbSQziVoVdI/nT2R1sOsV38AEdSka4jlFZAOryRwQnE7QZwLtHu2a+Lka4gt+D+u5NA==
X-Received: by 2002:aa7:82da:: with SMTP id f26mr22455848pfn.82.1564148459228;
        Fri, 26 Jul 2019 06:40:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx4Rr1J/4V9DAV1wQrKOy63QyfLcySMon0Lf1aa/wtCF+HiQPLix9qB+JxJLwjPSVu07ev1
X-Received: by 2002:aa7:82da:: with SMTP id f26mr22455804pfn.82.1564148458544;
        Fri, 26 Jul 2019 06:40:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564148458; cv=none;
        d=google.com; s=arc-20160816;
        b=qmJBbaafFWOyBj/0a6iovLI/3RWeLWKmE/K3sdKk8r1IjPZYVfKgq1+vyNQwiBU9Sz
         Shae0QSSGhcdDujKwaEBVwUC0+Ik+YPCE7zYoOSicinuf5glaWtUNxvM8GWJImpRPgnv
         hmKyx7m3jCTifHDcwvan3PCZhqASjkxwQFPb7LrYARpj78r3ajVTbH+hmEHiGOTR0UXp
         t2WamtgagtC5SENwfqLgl28Moj7JJoQCqgbfGMW4m/1XSch80QUoFWEneHOHBudndjzb
         QTQ1779MrhXsY1JMr+lU2FVdPCEQIY89z8jc0vnQ1GCcxd5cS0ZuvQzs2+xTZlawoxWk
         E0PQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=usjVSK9mfiQuFZBFwSBuMP/3nAEHHdyUsL0h8BamR0Y=;
        b=REQnzzAoAwVoVPgAgwElVfN1xAnQBYvB21NUwrVuZ43L128VOgpjM0t1OCJh2sgZSN
         kRB3SLW7LfGAoZPLGPL6nOXoToyYB/Pcoi7NGl/IeJQ4HHhqLHrAckZudcJVY1t+NqtL
         VgYo5kv22qHKQTDa6Ju6vJnq24Dk6CBz/uQ3usngeK9vXrKQx5SS78BbhLPN919w2qFQ
         KtXzBAz6ZrOEdHIJKh6lHLp65Jiwf+mqawerLN9Zfr1KXLRDLfIkT2pL9jV/R2xINYBW
         kaoIrALT469aLNQ2vxZFrGLrnWw2rBjAd3juLKdsNb8SdyMV6Ba0ea0LInCdtjhlpQBC
         xZXg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ELrxyKFQ;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id az7si17746506pjb.51.2019.07.26.06.40.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 06:40:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ELrxyKFQ;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9EA4E22CB8;
	Fri, 26 Jul 2019 13:40:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564148458;
	bh=+djP42l890PRgPpyfSuCFeOV38wuWwlVMb3pz0E+Mag=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=ELrxyKFQDLqS1N5c45EI7brqIhCoo9ezXaunRAkZNDL3vpyy6+ZfRXRWB1FAluPLh
	 Qdjvq9/47PBveEgpJTgU/EAi6ElyHoYEJE8J/Ejb1B0gqRLDBR+qKeD1PMwz08kP7U
	 3c31vM3g2rLrw6seYjiqD294n+lVi3mTgSjoQtxY=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>,
	David Rientjes <rientjes@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Roman Gushchin <guro@fb.com>,
	Shakeel Butt <shakeelb@google.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org,
	clang-built-linux@googlegroups.com
Subject: [PATCH AUTOSEL 5.2 51/85] mm/slab_common.c: work around clang bug #42570
Date: Fri, 26 Jul 2019 09:39:01 -0400
Message-Id: <20190726133936.11177-51-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190726133936.11177-1-sashal@kernel.org>
References: <20190726133936.11177-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Arnd Bergmann <arnd@arndb.de>

[ Upstream commit a07057dce2823e10d64a2b73cefbf09d8645efe9 ]

Clang gets rather confused about two variables in the same special
section when one of them is not initialized, leading to an assembler
warning later:

  /tmp/slab_common-18f869.s: Assembler messages:
  /tmp/slab_common-18f869.s:7526: Warning: ignoring changed section attributes for .data..ro_after_init

Adding an initialization to kmalloc_caches is rather silly here
but does avoid the issue.

Link: https://bugs.llvm.org/show_bug.cgi?id=42570
Link: http://lkml.kernel.org/r/20190712090455.266021-1-arnd@arndb.de
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Acked-by: David Rientjes <rientjes@google.com>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Roman Gushchin <guro@fb.com>
Cc: Shakeel Butt <shakeelb@google.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/slab_common.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 58251ba63e4a..cbd3411f644e 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1003,7 +1003,8 @@ struct kmem_cache *__init create_kmalloc_cache(const char *name,
 }
 
 struct kmem_cache *
-kmalloc_caches[NR_KMALLOC_TYPES][KMALLOC_SHIFT_HIGH + 1] __ro_after_init;
+kmalloc_caches[NR_KMALLOC_TYPES][KMALLOC_SHIFT_HIGH + 1] __ro_after_init =
+{ /* initialization for https://bugs.llvm.org/show_bug.cgi?id=42570 */ };
 EXPORT_SYMBOL(kmalloc_caches);
 
 /*
-- 
2.20.1

