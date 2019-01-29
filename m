Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30392C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:49:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1E6920844
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:49:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1E6920844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 979188E0009; Tue, 29 Jan 2019 13:49:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 92CBD8E0008; Tue, 29 Jan 2019 13:49:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7CC448E0009; Tue, 29 Jan 2019 13:49:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 24FA58E0008
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:49:53 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id b3so8351803edi.0
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:49:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ZWJF8bIGxtJvec8yE+OonkJxAD3YvXGOUAi1MFmnEfk=;
        b=KEF+RXjQAet2fibFflkdpqZWru3mP4chgPVruszJW/tVSU2UMkG/RbRsQtYDeOaCEi
         CWqui28Vnvu+6LQ2aG0Qy6F8Rsf9DkDorI39c2CTeITSztvS7aoHCgyyc79kq4gjUptD
         ZbV4jFE07dnJrG9kCzG2cL4GXgDvbR3MClnfEvAmfEK03a55ZbvfO5tzOZKeGor6g971
         PcxKH6e3oGIvDbGhia9IpxCBkVKhLcqvxABk6UdkK52ltdXp4bThYgu4rOraK7P3xdh6
         SXvCICHHvEJSjxRjF1xdMt7W7zQeHLMBdGaHfiMMCR3I3PLW/JsJ5dgFKhMrTWaA4QKT
         GXOg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
X-Gm-Message-State: AJcUukdShHdoHY5ulVEadClSUwlVfSMW8djD5SouIvIJvW1tUYOOeK3n
	IJ5WdW7CKX7O+ILOFXmo1rA2tOqn0R0ZAOT1/2/EVC8d7FtTtYYqDNL3Mq4hrt86AHOoamWypeM
	HcMBtahL3wxxO8s/NVZhwxcWMgNeGeseOykPjfqBCxn0tCqD2syviaixudX5FCxlK4g==
X-Received: by 2002:a17:906:32c6:: with SMTP id k6-v6mr23489192ejk.48.1548787792607;
        Tue, 29 Jan 2019 10:49:52 -0800 (PST)
X-Google-Smtp-Source: ALg8bN78vs8FDN0GsM8BtbOb0UJyR1MapD97rIUMfVtALWA+CKgitja/IwzWUGw8jTPLRHDDBfql
X-Received: by 2002:a17:906:32c6:: with SMTP id k6-v6mr23489136ejk.48.1548787791586;
        Tue, 29 Jan 2019 10:49:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548787791; cv=none;
        d=google.com; s=arc-20160816;
        b=sk3FbrxBf78lt+NphGAQV+Kef7DAayQr2vqPZ2G9eUbTiWLx4sD3gHEE1iPiXKMbj+
         gEiyw+kxjkn5h8peOO2ctpdbQy27Z3I4TRJJhELjYMH7f6Gj/TxZ/O7eosmwvivhlQXj
         y80w8Nf8Ypt9OnHzi+NTZuj7RexptOBtP4g97ynE5vG2P1dSmvk0GaBPvdLSWQuwDTlJ
         6II1C5D0y1R4HKQ3c3XejrffMraygezF737iExS22RD8/rIhGTG7Ygbv/3ivisgWMMiB
         IxcJJo048mVoC8zZJm5xOwiXuXV+PQxQYT/WuVPLMjst9e6uFAWQAnx4N8ZJGnxwMRfY
         w26Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=ZWJF8bIGxtJvec8yE+OonkJxAD3YvXGOUAi1MFmnEfk=;
        b=De/ECf8MikobceSyxgy5Rb5uXrR2EBUYPlWUz9uDUmj3/MMIeL44rGjtuhER4SvYQg
         v0FMX/BnNsQmFzlGRoI/aA+AE8doAUWilP9bOBFExI13dfzoBgsW+t5EtCPMGoCDI7G4
         Wio9iPA4DUFa7MyEbBhZuwzS4eEsBtJPG7ViZ4ihzK5QTocsy+hQzSc2PJwDX1fJpHKB
         EQA/RFeRLTJr3zY4XhBKS2oAa+B5JJSZCDA8ERCC90xUphL3aO1YUhXRTO02QxvVUSx2
         1e30EOh4p0bMn5KNKvSyVKtEtTb7Ax7E7/G675BMxcI+Li1/BVDWvjXYfjHT36/xhzxN
         X7kQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t16si2100473ejd.131.2019.01.29.10.49.51
        for <linux-mm@kvack.org>;
        Tue, 29 Jan 2019 10:49:51 -0800 (PST)
Received-SPF: pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 58D2DA78;
	Tue, 29 Jan 2019 10:49:50 -0800 (PST)
Received: from eglon.cambridge.arm.com (eglon.cambridge.arm.com [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id AB2903F557;
	Tue, 29 Jan 2019 10:49:47 -0800 (PST)
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
Subject: [PATCH v8 04/26] ACPI / APEI: Make hest.c manage the estatus memory pool
Date: Tue, 29 Jan 2019 18:48:40 +0000
Message-Id: <20190129184902.102850-5-james.morse@arm.com>
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

ghes.c has a memory pool it uses for the estatus cache and the estatus
queue. The cache is initialised when registering the platform driver.
For the queue, an NMI-like notification has to grow/shrink the pool
as it is registered and unregistered.

This is all pretty noisy when adding new NMI-like notifications, it
would be better to replace this with a static pool size based on the
number of users.

As a precursor, move the call that creates the pool from ghes_init(),
into hest.c. Later this will take the number of ghes entries and
consolidate the queue allocations.
Remove ghes_estatus_pool_exit() as hest.c doesn't have anywhere to put
this.

The pool is now initialised as part of ACPI's subsys_initcall():
(acpi_init(), acpi_scan_init(), acpi_pci_root_init(), acpi_hest_init())
Before this patch it happened later as a GHES specific device_initcall().

Signed-off-by: James Morse <james.morse@arm.com>
---
Changes since v7:
* Moved the pool init later, the driver isn't probed until device_init.
---
 drivers/acpi/apei/ghes.c | 33 ++++++---------------------------
 drivers/acpi/apei/hest.c | 10 +++++++++-
 include/acpi/ghes.h      |  2 ++
 3 files changed, 17 insertions(+), 28 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index ee9206d5e119..4150c72c78cb 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -162,26 +162,16 @@ static void ghes_iounmap_irq(void)
 	clear_fixmap(FIX_APEI_GHES_IRQ);
 }
 
-static int ghes_estatus_pool_init(void)
+static int ghes_estatus_pool_expand(unsigned long len); //temporary
+
+int ghes_estatus_pool_init(void)
 {
 	ghes_estatus_pool = gen_pool_create(GHES_ESTATUS_POOL_MIN_ALLOC_ORDER, -1);
 	if (!ghes_estatus_pool)
 		return -ENOMEM;
-	return 0;
-}
 
-static void ghes_estatus_pool_free_chunk(struct gen_pool *pool,
-					      struct gen_pool_chunk *chunk,
-					      void *data)
-{
-	vfree((void *)chunk->start_addr);
-}
-
-static void ghes_estatus_pool_exit(void)
-{
-	gen_pool_for_each_chunk(ghes_estatus_pool,
-				ghes_estatus_pool_free_chunk, NULL);
-	gen_pool_destroy(ghes_estatus_pool);
+	return ghes_estatus_pool_expand(GHES_ESTATUS_CACHE_AVG_SIZE *
+					GHES_ESTATUS_CACHE_ALLOCED_MAX);
 }
 
 static int ghes_estatus_pool_expand(unsigned long len)
@@ -1227,18 +1217,9 @@ static int __init ghes_init(void)
 
 	ghes_nmi_init_cxt();
 
-	rc = ghes_estatus_pool_init();
-	if (rc)
-		goto err;
-
-	rc = ghes_estatus_pool_expand(GHES_ESTATUS_CACHE_AVG_SIZE *
-				      GHES_ESTATUS_CACHE_ALLOCED_MAX);
-	if (rc)
-		goto err_pool_exit;
-
 	rc = platform_driver_register(&ghes_platform_driver);
 	if (rc)
-		goto err_pool_exit;
+		goto err;
 
 	rc = apei_osc_setup();
 	if (rc == 0 && osc_sb_apei_support_acked)
@@ -1251,8 +1232,6 @@ static int __init ghes_init(void)
 		pr_info(GHES_PFX "Failed to enable APEI firmware first mode.\n");
 
 	return 0;
-err_pool_exit:
-	ghes_estatus_pool_exit();
 err:
 	return rc;
 }
diff --git a/drivers/acpi/apei/hest.c b/drivers/acpi/apei/hest.c
index b1e9f81ebeea..097ba07a657b 100644
--- a/drivers/acpi/apei/hest.c
+++ b/drivers/acpi/apei/hest.c
@@ -32,6 +32,7 @@
 #include <linux/io.h>
 #include <linux/platform_device.h>
 #include <acpi/apei.h>
+#include <acpi/ghes.h>
 
 #include "apei-internal.h"
 
@@ -203,6 +204,11 @@ static int __init hest_ghes_dev_register(unsigned int ghes_count)
 	rc = apei_hest_parse(hest_parse_ghes, &ghes_arr);
 	if (rc)
 		goto err;
+
+	rc = ghes_estatus_pool_init();
+	if (rc)
+		goto err;
+
 out:
 	kfree(ghes_arr.ghes_devs);
 	return rc;
@@ -251,7 +257,9 @@ void __init acpi_hest_init(void)
 		rc = apei_hest_parse(hest_parse_ghes_count, &ghes_count);
 		if (rc)
 			goto err;
-		rc = hest_ghes_dev_register(ghes_count);
+
+		if (ghes_count)
+			rc = hest_ghes_dev_register(ghes_count);
 		if (rc)
 			goto err;
 	}
diff --git a/include/acpi/ghes.h b/include/acpi/ghes.h
index 82cb4eb225a4..46ef5566e052 100644
--- a/include/acpi/ghes.h
+++ b/include/acpi/ghes.h
@@ -52,6 +52,8 @@ enum {
 	GHES_SEV_PANIC = 0x3,
 };
 
+int ghes_estatus_pool_init(void);
+
 /* From drivers/edac/ghes_edac.c */
 
 #ifdef CONFIG_EDAC_GHES
-- 
2.20.1

