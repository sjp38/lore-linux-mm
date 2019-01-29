Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 235B2C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:49:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D7D3520844
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:49:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D7D3520844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 840638E0001; Tue, 29 Jan 2019 13:49:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7EFFA8E0008; Tue, 29 Jan 2019 13:49:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E9E18E0001; Tue, 29 Jan 2019 13:49:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 153A68E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:49:50 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id m19so8310303edc.6
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:49:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=fD8p7np7UeGkTdvd8XbtAHGwPZeSf1NvRF2y9gcTwlQ=;
        b=oSksLgkBnH54t10fkVzOGMP6B9YPMdIFR7ZripN/yGXIfzoLLDZEaBlNZujjP3iAmu
         p7Gitx3HK6ogH/daedavyHB1kctUZtN4rEwWSRYbuhHEJ9m+kTiQKc51TBBAF4K3/3Un
         Ln3whpAhx5+gfuAdM73uMMoDgdO7ivxUzlrrEvHuhJg67CiYRf2+Os2Prbg/vQ8XqnAy
         GGT663vJxC/VYLzmKYezvGevUeCTdyZQ9eLXqDEpsisIwSmyFHg14FLEn4iy1WuXJ+ND
         CinIF9yVEakRMVc4coiWDWnbg8YX6Y0w4oHDJpc5BKZ3wqQ8jeEj9uuPccFc0xRqTh+2
         Lh8Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
X-Gm-Message-State: AJcUukeFVIRWNn3TxrXN0EtMyfrzwN56zTMcExWfbqn/hl7y5CW7Tr0y
	1AOcSNC0dSgSEOz1qVl5hnjwG0rygXZDqS1YVO1jjbq/FfjuYLxFELAUfFe4G5hCLOYC3TrGwDn
	xsn7PhvPFgGVBe19T5bOY+54toLWKPwuNt7uawOv8qYkdrcsCrTtoJQECPyx3IxP7gw==
X-Received: by 2002:a17:906:b3c9:: with SMTP id cg9mr7408465ejb.159.1548787789551;
        Tue, 29 Jan 2019 10:49:49 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYfvfpsz50fR0C9IgJ+pBS6eEotVZcTIphqOajNg/jMXizM9dvemnJyEIklgpzWaLONqEb8
X-Received: by 2002:a17:906:b3c9:: with SMTP id cg9mr7408415ejb.159.1548787788477;
        Tue, 29 Jan 2019 10:49:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548787788; cv=none;
        d=google.com; s=arc-20160816;
        b=E07nXcNIIRDWPi0GujyBRnraGJCacMh+g68shJAvAZQ5PAYYvFDZAZMFRaVraVOn33
         Fyiqv/dqfmt6NHarBnOou2PfXASscq123BKQo0+1IoZUCqHbfiWINAbvOTrq7vdNuB8X
         OEIWFvPKTrpLMOXLexW4k8ZecYxwlqjNzcN+DtBp9hAu+PHmQGdp4vdeJ46BESOEz3O4
         CzoLIAX9nhISPx8y5hS/Lsdl0ziXwxhRycnDKN/2mVxKcIKGzQqx+n6BUwl5SMwjfHeW
         3mzzuTAoTQ/eD43Z7xbIQsjBhR3T4OEZK78V4zaUw5wDy2X0bQKBSpimAo0jTWvzEH8Z
         x2gA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=fD8p7np7UeGkTdvd8XbtAHGwPZeSf1NvRF2y9gcTwlQ=;
        b=gL1OyyeN3ZppSHXhf+KrbAiLGjgLLzhfV79jN/AWZRf3qkABl5KIMoRkRniUhxKD/3
         UX9giKPYAiCiJa6FRUraZhAKhpxtFPyVvftaWz7OBkRxycdr2AbMN6uP/X0MR9vJAat2
         B8qfqsKsHz8jemMvNrwCSQ5eK825IBCEAADrcshnGsEVLjmItATaSrSvXQlaG28pg3w0
         m0XFtixPq3YaTzPowi0g8fnJRdeX+CXHZo3lpAc7DM5QvJYDnBl8DsCShl8mESJMVTfO
         ThKEYtuWEWDMEWwHw+YUMCJvZSFKrKG1qFdYPeMzTN4M6FIhuPWFoXc1M8Odkac/utFr
         7zcg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f10si632871eda.112.2019.01.29.10.49.48
        for <linux-mm@kvack.org>;
        Tue, 29 Jan 2019 10:49:48 -0800 (PST)
Received-SPF: pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6C49B1596;
	Tue, 29 Jan 2019 10:49:47 -0800 (PST)
Received: from eglon.cambridge.arm.com (eglon.cambridge.arm.com [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id BFDA93F557;
	Tue, 29 Jan 2019 10:49:44 -0800 (PST)
From: James Morse <james.morse@arm.com>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu,
	linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org,
	Borislav Petkov <bp@alien8.de>,
	Marc Zyngier <marc.zyngier@arm.com>,
	Christoffer Dall <christoffer.dall@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Rafael Wysocki <rjw@rjwysocki.net>,
	Len Brown <lenb@kernel.org>,
	Tony Luck <tony.luck@intel.com>,
	Dongjiu Geng <gengdongjiu@huawei.com>,
	Xie XiuQi <xiexiuqi@huawei.com>,
	james.morse@arm.com
Subject: [PATCH v8 03/26] ACPI / APEI: Switch estatus pool to use vmalloc memory
Date: Tue, 29 Jan 2019 18:48:39 +0000
Message-Id: <20190129184902.102850-4-james.morse@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190129184902.102850-1-james.morse@arm.com>
References: <20190129184902.102850-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The ghes code is careful to parse and round firmware's advertised
memory requirements for CPER records, up to a maximum of 64K.
However when ghes_estatus_pool_expand() does its work, it splits
the requested size into PAGE_SIZE granules.

This means if firmware generates 5K of CPER records, and correctly
describes this in the table, __process_error() will silently fail as it
is unable to allocate more than PAGE_SIZE.

Switch the estatus pool to vmalloc() memory. On x86 vmalloc() memory
may fault and be fixed up by vmalloc_fault(). To prevent this call
vmalloc_sync_all() before an NMI handler could discover the memory.

Signed-off-by: James Morse <james.morse@arm.com>
Reviewed-by: Borislav Petkov <bp@suse.de>
---
 drivers/acpi/apei/ghes.c | 30 +++++++++++++++---------------
 1 file changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index f0a704aed040..ee9206d5e119 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -170,40 +170,40 @@ static int ghes_estatus_pool_init(void)
 	return 0;
 }
 
-static void ghes_estatus_pool_free_chunk_page(struct gen_pool *pool,
+static void ghes_estatus_pool_free_chunk(struct gen_pool *pool,
 					      struct gen_pool_chunk *chunk,
 					      void *data)
 {
-	free_page(chunk->start_addr);
+	vfree((void *)chunk->start_addr);
 }
 
 static void ghes_estatus_pool_exit(void)
 {
 	gen_pool_for_each_chunk(ghes_estatus_pool,
-				ghes_estatus_pool_free_chunk_page, NULL);
+				ghes_estatus_pool_free_chunk, NULL);
 	gen_pool_destroy(ghes_estatus_pool);
 }
 
 static int ghes_estatus_pool_expand(unsigned long len)
 {
-	unsigned long i, pages, size, addr;
-	int ret;
+	unsigned long size, addr;
 
 	ghes_estatus_pool_size_request += PAGE_ALIGN(len);
 	size = gen_pool_size(ghes_estatus_pool);
 	if (size >= ghes_estatus_pool_size_request)
 		return 0;
-	pages = (ghes_estatus_pool_size_request - size) / PAGE_SIZE;
-	for (i = 0; i < pages; i++) {
-		addr = __get_free_page(GFP_KERNEL);
-		if (!addr)
-			return -ENOMEM;
-		ret = gen_pool_add(ghes_estatus_pool, addr, PAGE_SIZE, -1);
-		if (ret)
-			return ret;
-	}
 
-	return 0;
+	addr = (unsigned long)vmalloc(PAGE_ALIGN(len));
+	if (!addr)
+		return -ENOMEM;
+
+	/*
+	 * New allocation must be visible in all pgd before it can be found by
+	 * an NMI allocating from the pool.
+	 */
+	vmalloc_sync_all();
+
+	return gen_pool_add(ghes_estatus_pool, addr, PAGE_ALIGN(len), -1);
 }
 
 static int map_gen_v2(struct ghes *ghes)
-- 
2.20.1

