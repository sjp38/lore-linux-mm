Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C851CC28CC4
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:24:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 87DC82736E
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:24:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Vx54991I"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 87DC82736E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F8DE6B02A2; Sat,  1 Jun 2019 09:24:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2CE516B02A4; Sat,  1 Jun 2019 09:24:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E52D6B02A5; Sat,  1 Jun 2019 09:24:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id DE7A26B02A2
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:24:05 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id y7so6218504pfy.9
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:24:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=2zOwmnbCHpIfTVhwQJ9e3u08zmH4kgFu0ANCtYiZLpM=;
        b=RYYQbww5Z6qb0TOqDD50wQAH8yXt8gVUMpg1rRBf2qr8EL9KIT+1wQr3bIdBtFf1lZ
         NkvTSBn1zaDWXoTJmMrgWSejSLX3OhJr6VOHm0yOEZvdfMn3E+zt5CUoRjr08axQ7byS
         oHqzhKVO1pP8PLQU0JSGTnQGmB4mvAJ74GHN7bntGSGVLqnokylu/n9iRAR9F0rKYwHx
         aelOYK1c0Kr4dOQ19pqThJqi83tITePjle85oi0IDejNVULYBA2AprM2/mgiPJM3JuIq
         pvV5KT1Bbri3xanu/cXA4Dyc8GQGdJp6DaILDwGIndu9sRjz0PAhyZLbZAWlAZu2UEsR
         jUEQ==
X-Gm-Message-State: APjAAAUbJC6bGhgQHTT4JaKLj4Z3/2lWSV78TtwdCHfNHwSQmINho9fw
	NDbqqbSB4QlQjwR4zCjjoOw9Nc4ZmvQFEPvF0RzECvhYckTThIDFwTU/QC6k2GAlPtG49+tEOUf
	FkIe/kfnlMflcXhbVj9uU5jMOOtKJzbXeVyR0xHNuAGGRTAny6KQ/C84IW9rldHIVww==
X-Received: by 2002:aa7:9256:: with SMTP id 22mr3445700pfp.69.1559395445577;
        Sat, 01 Jun 2019 06:24:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw4XD5IMBonkDvgxFp2ltA03mKIUUYyIy2H5BV6/lNUUoX+c2aqhQvYEIyQQt81K6Wn8+43
X-Received: by 2002:aa7:9256:: with SMTP id 22mr3445645pfp.69.1559395445017;
        Sat, 01 Jun 2019 06:24:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395445; cv=none;
        d=google.com; s=arc-20160816;
        b=ZxmDmmuBgISmWjuK0d16j4qoj755d6G5P9B1IdfJfYUV9CvMFM7BzJpB3sR4E0F/zl
         kT2vL6GprUlw8WjoPWL11iz6S+9cqtkOapE7f75w03UvYit33CubWb4PlQ+lBm0ds9h+
         /680R1sB/V+0w72uZqzr07Fo317yrPGyzeNZTOgIMZxjgiSLHyhUw0z16YXEX7h9IvpF
         vEohvLClfe4LguHwWg2TxSIWldrMofJDOLW8wEe0LR1KXjIWwMkGiUeqawPGcecIg1/R
         vr5di++qwb46rzVXVDRA0NB4RfrHOjQCOloZGpNFg5HTIvDz6oyzYG3TjyFp5ug2okwP
         PhUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=2zOwmnbCHpIfTVhwQJ9e3u08zmH4kgFu0ANCtYiZLpM=;
        b=qcebgFW3uE1mF4Up69fmbcFYA+CJHoddiOQcUxnE6mbZ8MHsfN5CZfsbNiv5f6Vx+Q
         znHiADTY4tzwmWVE1/D79epWcxjqK3x/gI6RnK1B1Wu49OUFQ8WyOIoixBjkKSdkCl0h
         WkA4betxK7wtpA73lF+QFR/Ssaahg7vGSDndoiueb/YvU/xctylctkXGwWBtFBIE50YF
         IzHg0w4Q+NVn1PGuXg+gg2V57r8hsEQ0x4fS2R7w0q7Tbanu73PjR16jYQh6NxiUTKb6
         uh7fdZKCujpGaebDLh7j19hj58xDvAT6rUSpirfMnqoVaJIF+P/UCGTbyY9dOJuMSxfY
         QHrg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Vx54991I;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h1si5896038plr.116.2019.06.01.06.24.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:24:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Vx54991I;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 2A3E027355;
	Sat,  1 Jun 2019 13:24:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395444;
	bh=dg/hQgmd7Dh998D1vF9dt1j5c4/F+dz2LDsSHZxNSkI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=Vx54991IOXa1TvoMVx5m7NUe+lkj6rr3frz0zDt7WjM8z/TD9/3jLJhO8sWXc5Gdz
	 Uwi6xgap+THUUklGripJ8eCSw4sPe4Z3iysIkrsgFt5yOEnSKSN7j9DtEten14/qu7
	 dZYvZhRLoJTK1DnJj4aak/rdcuKIbOxjjU1RiPl0=
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
Subject: [PATCH AUTOSEL 4.14 06/99] mm/hmm: select mmu notifier when selecting HMM
Date: Sat,  1 Jun 2019 09:22:13 -0400
Message-Id: <20190601132346.26558-6-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601132346.26558-1-sashal@kernel.org>
References: <20190601132346.26558-1-sashal@kernel.org>
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
index 59efbd3337e0c..cc4d633947bfa 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -708,12 +708,12 @@ config MIGRATE_VMA_HELPER
 
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

