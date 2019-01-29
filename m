Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0AA8C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:49:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF88920844
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:49:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF88920844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5FADB8E000A; Tue, 29 Jan 2019 13:49:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A93E8E0008; Tue, 29 Jan 2019 13:49:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 470B08E000A; Tue, 29 Jan 2019 13:49:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id DD0B28E0008
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:49:55 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id b3so8351848edi.0
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:49:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ITscJhVBj/odootafLFz/vckhUTU5gGBqQS3E9P7ckE=;
        b=Cgw6W3a5ZF56uppvdLdfYd57IDsRHgg2TLO/ZfcTDqOFnpgEGMAYKROEGqd2Tu9DwY
         YHpcABnHt//viQBNZCkcEQ5qro3CcuutKw+fbb2Y3wxwaWukrPRXoByQBcSWSLIpQ7Jy
         Xrob9wY2YEM9ZgnBys0L3K18MMMc4yYSmBdt5yXd+lzh3h2PcxDHWL+wLINDskRYIh8m
         9dH3RAiBk5URc77tjIz7Pz6c+G5ARwV3WiQuZolMuDzfCeSmjP/Vic2gK3ZRc2KfPF7a
         TslLW9hWYTwYuQGEZdWmk0F3uZLqcfAdWPDwZIdLm/EXIJ/AKxydmQr9GA6SgIJt/qhg
         9b0w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
X-Gm-Message-State: AJcUukf7gAC1q2f+gQZM+8zkyjoKJj6C2CCsSamkTT0TKpVDHCzbBfZZ
	ZrymLe0q7pC/0BXhyFkFDU2d99uQdYZfep2RgADcGqpBWtTVp7IHdk6a/bX7evN43FN88SzHLpl
	j5RpRO8oAUAKukhaWV/hu/NXRfFXSYWB+wHZnKKBTwy0JKVGBFTU5PQdiYIi8By0jNQ==
X-Received: by 2002:a17:906:1c0c:: with SMTP id k12mr8271824ejg.39.1548787795305;
        Tue, 29 Jan 2019 10:49:55 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7E1HV2LoVzVYYxvOBmPk/IwxxPnzc6bTxviZ2yFalo6ZEL3x80EQVAgE9+UBxZ3h+mPlKH
X-Received: by 2002:a17:906:1c0c:: with SMTP id k12mr8271779ejg.39.1548787794260;
        Tue, 29 Jan 2019 10:49:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548787794; cv=none;
        d=google.com; s=arc-20160816;
        b=G/kH4Y1ISYcMr0FmxxlNuwghgbAzIrEpiibe04TBqoABoRo2lsi3lZVlmeRXSH3dyo
         2HOJ/lvAal55ZoVVSQS1XmnY+cUZru7010w2M4PXnq4GOtbXaGArkKe0b0FIWf4QF8Mn
         V9jkuWNahw7lt2v0DoP1+2OOtuzvFmNr6xwNxyY31zakY51FmKRpQopWIQq/0Lt4gZyQ
         E5v39VTNhFjFi+2NNzMMF94jP1E80bfe17gotMGlDgeB1wWObZJMPlfsl+d8Jesau+e3
         HhnJe/ai7OdxCrNaGyXbW32djsxc1bX9wV7BN5bsjs76zyDLE/Nd9PFCCevO1x8Ubrcs
         +QJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=ITscJhVBj/odootafLFz/vckhUTU5gGBqQS3E9P7ckE=;
        b=J8OvFNAncob0ktsrwzkGB0VHXxjwrRlPWd3VMILG/9/mHDo00r/U9M0Nq36FwPrVrl
         pq++UBNIh+2ZcILlW+fDGpb9QBIWXuudWxCMTJ9SGQvWIpWkOcfunVm/c7INV75wSeU2
         fHYolEjsqGjhzD3FaXqORLfOohlfYIFsqdYhimHapLiJmKRz5sXYDaQuqcWg9IqGl10E
         CyBQpz4F03OrKRNAlSzgS8YruQhqHnWBa9k7ErBgyVrGdwEPG+hBnJK5a3OeQOKo092I
         27O2aM2MNlx6Ogro1ot3QFb05Kazfi0BqvADiUFsXrFgLCnfo5DQtQS80pwYdnrJGyve
         MuMA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q15-v6si2728934ejj.286.2019.01.29.10.49.53
        for <linux-mm@kvack.org>;
        Tue, 29 Jan 2019 10:49:54 -0800 (PST)
Received-SPF: pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 45797A78;
	Tue, 29 Jan 2019 10:49:53 -0800 (PST)
Received: from eglon.cambridge.arm.com (eglon.cambridge.arm.com [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 97B233F557;
	Tue, 29 Jan 2019 10:49:50 -0800 (PST)
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
Subject: [PATCH v8 05/26] ACPI / APEI: Make estatus pool allocation a static size
Date: Tue, 29 Jan 2019 18:48:41 +0000
Message-Id: <20190129184902.102850-6-james.morse@arm.com>
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

Adding new NMI-like notifications duplicates the calls that grow
and shrink the estatus pool. This is all pretty pointless, as the
size is capped to 64K. Allocate this for each ghes and drop
the code that grows and shrinks the pool.

Suggested-by: Borislav Petkov <bp@suse.de>
Signed-off-by: James Morse <james.morse@arm.com>
Reviewed-by: Borislav Petkov <bp@suse.de>
---
 drivers/acpi/apei/ghes.c | 49 +++++-----------------------------------
 drivers/acpi/apei/hest.c |  2 +-
 include/acpi/ghes.h      |  2 +-
 3 files changed, 8 insertions(+), 45 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index 4150c72c78cb..33144ab0661a 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -162,27 +162,18 @@ static void ghes_iounmap_irq(void)
 	clear_fixmap(FIX_APEI_GHES_IRQ);
 }
 
-static int ghes_estatus_pool_expand(unsigned long len); //temporary
-
-int ghes_estatus_pool_init(void)
+int ghes_estatus_pool_init(int num_ghes)
 {
+	unsigned long addr, len;
+
 	ghes_estatus_pool = gen_pool_create(GHES_ESTATUS_POOL_MIN_ALLOC_ORDER, -1);
 	if (!ghes_estatus_pool)
 		return -ENOMEM;
 
-	return ghes_estatus_pool_expand(GHES_ESTATUS_CACHE_AVG_SIZE *
-					GHES_ESTATUS_CACHE_ALLOCED_MAX);
-}
-
-static int ghes_estatus_pool_expand(unsigned long len)
-{
-	unsigned long size, addr;
-
-	ghes_estatus_pool_size_request += PAGE_ALIGN(len);
-	size = gen_pool_size(ghes_estatus_pool);
-	if (size >= ghes_estatus_pool_size_request)
-		return 0;
+	len = GHES_ESTATUS_CACHE_AVG_SIZE * GHES_ESTATUS_CACHE_ALLOCED_MAX;
+	len += (num_ghes * GHES_ESOURCE_PREALLOC_MAX_SIZE);
 
+	ghes_estatus_pool_size_request = PAGE_ALIGN(len);
 	addr = (unsigned long)vmalloc(PAGE_ALIGN(len));
 	if (!addr)
 		return -ENOMEM;
@@ -956,32 +947,8 @@ static int ghes_notify_nmi(unsigned int cmd, struct pt_regs *regs)
 	return ret;
 }
 
-static unsigned long ghes_esource_prealloc_size(
-	const struct acpi_hest_generic *generic)
-{
-	unsigned long block_length, prealloc_records, prealloc_size;
-
-	block_length = min_t(unsigned long, generic->error_block_length,
-			     GHES_ESTATUS_MAX_SIZE);
-	prealloc_records = max_t(unsigned long,
-				 generic->records_to_preallocate, 1);
-	prealloc_size = min_t(unsigned long, block_length * prealloc_records,
-			      GHES_ESOURCE_PREALLOC_MAX_SIZE);
-
-	return prealloc_size;
-}
-
-static void ghes_estatus_pool_shrink(unsigned long len)
-{
-	ghes_estatus_pool_size_request -= PAGE_ALIGN(len);
-}
-
 static void ghes_nmi_add(struct ghes *ghes)
 {
-	unsigned long len;
-
-	len = ghes_esource_prealloc_size(ghes->generic);
-	ghes_estatus_pool_expand(len);
 	mutex_lock(&ghes_list_mutex);
 	if (list_empty(&ghes_nmi))
 		register_nmi_handler(NMI_LOCAL, ghes_notify_nmi, 0, "ghes");
@@ -991,8 +958,6 @@ static void ghes_nmi_add(struct ghes *ghes)
 
 static void ghes_nmi_remove(struct ghes *ghes)
 {
-	unsigned long len;
-
 	mutex_lock(&ghes_list_mutex);
 	list_del_rcu(&ghes->list);
 	if (list_empty(&ghes_nmi))
@@ -1003,8 +968,6 @@ static void ghes_nmi_remove(struct ghes *ghes)
 	 * freed after NMI handler finishes.
 	 */
 	synchronize_rcu();
-	len = ghes_esource_prealloc_size(ghes->generic);
-	ghes_estatus_pool_shrink(len);
 }
 
 static void ghes_nmi_init_cxt(void)
diff --git a/drivers/acpi/apei/hest.c b/drivers/acpi/apei/hest.c
index 097ba07a657b..fcc8cc1e4f3d 100644
--- a/drivers/acpi/apei/hest.c
+++ b/drivers/acpi/apei/hest.c
@@ -205,7 +205,7 @@ static int __init hest_ghes_dev_register(unsigned int ghes_count)
 	if (rc)
 		goto err;
 
-	rc = ghes_estatus_pool_init();
+	rc = ghes_estatus_pool_init(ghes_count);
 	if (rc)
 		goto err;
 
diff --git a/include/acpi/ghes.h b/include/acpi/ghes.h
index 46ef5566e052..cd9ee507d860 100644
--- a/include/acpi/ghes.h
+++ b/include/acpi/ghes.h
@@ -52,7 +52,7 @@ enum {
 	GHES_SEV_PANIC = 0x3,
 };
 
-int ghes_estatus_pool_init(void);
+int ghes_estatus_pool_init(int num_ghes);
 
 /* From drivers/edac/ghes_edac.c */
 
-- 
2.20.1

