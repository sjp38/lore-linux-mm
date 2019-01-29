Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E03ACC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:49:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A283620844
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:49:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A283620844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4985C8E0007; Tue, 29 Jan 2019 13:49:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 447A38E0001; Tue, 29 Jan 2019 13:49:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3108D8E0007; Tue, 29 Jan 2019 13:49:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id CCAA88E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:49:46 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id t7so8287773edr.21
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:49:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=zWuERV+0zMTrfeg4mludKeQEAgk+5eFdnl31qbVuu4Y=;
        b=jcYvrUPDMjdoBqwHGPQHb1/KDVbbSHzfJAQzusBT4VbbDnwSL11yxJ8tz6i/oGap3A
         BZv69kbZho4UzsfLtqHWQgXZ/8hK7ncogBTJkp6FwgLOGeThqdz7Eh0HYlqod7MiqFrg
         +BovabmOmyv7U+WtfeLBG4XNY34CgYrqEnUb/SL4GhUGhuoDeOAYmsgDC9ts0caqPe+O
         F77PtvF3HpYEI+m9wPM0u71AGeD0R//en7FTrOFa8CKW+HJdXvVZ6sdIGDBGf3a0JnBW
         IVfUT2ymf+2g5phYCuzmoRJ3yqGZgJ2ys8kn8TNniK0ONEhDVqx25qGLUxUU9BquvgjB
         3MaQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
X-Gm-Message-State: AJcUukevfzG1OwR1vWZrwLjm68VUwXl57jV1scUzxkkteT7npeEf7pc9
	l2uVsZ1c7X30qPxW8Nzb0eOfOAHY4fJbltSaABwz5q2TF2fJXPvp5X7vHwB0hToS6Pyf7p8EygN
	25qk7Leb0jftKiR4ewX+iBUOEll6h7zyScrxhZhO2xrUSJa7vhTJcAt9PW2uWT4RpuQ==
X-Received: by 2002:a05:6402:511:: with SMTP id m17mr27009032edv.33.1548787786333;
        Tue, 29 Jan 2019 10:49:46 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5A9VoIQr1Gc/Fpus35/OAfC9hMg5qR/o2nQ6GGr8d0yHs0L+pfaZGgUri/wz8f5KzaIgg0
X-Received: by 2002:a05:6402:511:: with SMTP id m17mr27008976edv.33.1548787785438;
        Tue, 29 Jan 2019 10:49:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548787785; cv=none;
        d=google.com; s=arc-20160816;
        b=IIWYWIMqDu3HDSDJ8+JlmS0t6h8pE/BNl2cG+WtazznoShsYZGl7Vl5Fu4QTOUYmzc
         DcYYmBib9eSVWXNZnOCPE2/THUOw683rT1RjuNmucBjbH7To5Lgx9RGdQPCW7r7PufOt
         u6WRVWVQGWt2QkGFQRVmy4Xfdpxrn/6mzn4lIH9+7M59SslslE0zSJCsBVHfYA/szpa4
         RMfJ5rWKYTxYkHROfXb2hUvrhPR5k4AZwSeDznMWLDFO/c99Rf2NXPI6xZZb0kyaVLsB
         6OCue+1tUurfBhK0MPsiuDDP+Eco/bfzOhbsGBmGSOEfSMqLXfBcIH5K+O8EJlSfGIa0
         Wizw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=zWuERV+0zMTrfeg4mludKeQEAgk+5eFdnl31qbVuu4Y=;
        b=n6VRLXIVl+s+mncUCeafbGccZx3gcMyrmiykA4mVqX4YfjhkQgVfLaFq1R2hiVY651
         cMQTSi+J0nXRtt6tGRdhVY8gqJXUaGAx+RtlZ8EtutycSuNGVeWIVDiaf6F6TD+xqWaN
         4PVsibFDFBH4RBL2DwW7FG0JBhvsOJ83VywxhxKECsQj/gt42uZbFQsWDx7dk/ZskevA
         1MDOUEGoTSauVGE1DOXicuFi/IK2EesDtsa6X+kenU1tGgo0KUecFdcIk2ssE1isDuch
         h12AspZ+yX/M1AxCe+oKhjANNq6U7aYem6u30wxKAgI1pE2rWoyz4jd3xVyXrrjaZzI4
         OP7g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r16si2095416edo.219.2019.01.29.10.49.45
        for <linux-mm@kvack.org>;
        Tue, 29 Jan 2019 10:49:45 -0800 (PST)
Received-SPF: pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 815AAA78;
	Tue, 29 Jan 2019 10:49:44 -0800 (PST)
Received: from eglon.cambridge.arm.com (eglon.cambridge.arm.com [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id D4AC23F557;
	Tue, 29 Jan 2019 10:49:41 -0800 (PST)
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
Subject: [PATCH v8 02/26] ACPI / APEI: Remove silent flag from ghes_read_estatus()
Date: Tue, 29 Jan 2019 18:48:38 +0000
Message-Id: <20190129184902.102850-3-james.morse@arm.com>
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

Subsequent patches will split up ghes_read_estatus(), at which
point passing around the 'silent' flag gets annoying. This is to
suppress prink() messages, which prior to commit 42a0bb3f7138
("printk/nmi: generic solution for safe printk in NMI"), were
unsafe in NMI context.

This is no longer necessary, remove the flag. printk() messages
are batched in a per-cpu buffer and printed via irq-work, or a call
back from panic().

Signed-off-by: James Morse <james.morse@arm.com>
Reviewed-by: Borislav Petkov <bp@suse.de>

---
Changes since v6:
 * Moved earlier in the series,
 * Tinkered with the commit message.
 * switched to pr_warn_ratelimited() to shut checkpatch up
---
 drivers/acpi/apei/ghes.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index 0c46b79e31b1..f0a704aed040 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -324,7 +324,7 @@ static void ghes_copy_tofrom_phys(void *buffer, u64 paddr, u32 len,
 	}
 }
 
-static int ghes_read_estatus(struct ghes *ghes, int silent)
+static int ghes_read_estatus(struct ghes *ghes)
 {
 	struct acpi_hest_generic *g = ghes->generic;
 	u64 buf_paddr;
@@ -333,8 +333,7 @@ static int ghes_read_estatus(struct ghes *ghes, int silent)
 
 	rc = apei_read(&buf_paddr, &g->error_status_address);
 	if (rc) {
-		if (!silent && printk_ratelimit())
-			pr_warning(FW_WARN GHES_PFX
+		pr_warn_ratelimited(FW_WARN GHES_PFX
 "Failed to read error status block address for hardware error source: %d.\n",
 				   g->header.source_id);
 		return -EIO;
@@ -366,9 +365,9 @@ static int ghes_read_estatus(struct ghes *ghes, int silent)
 	rc = 0;
 
 err_read_block:
-	if (rc && !silent && printk_ratelimit())
-		pr_warning(FW_WARN GHES_PFX
-			   "Failed to read error status block!\n");
+	if (rc)
+		pr_warn_ratelimited(FW_WARN GHES_PFX
+				    "Failed to read error status block!\n");
 	return rc;
 }
 
@@ -702,7 +701,7 @@ static int ghes_proc(struct ghes *ghes)
 {
 	int rc;
 
-	rc = ghes_read_estatus(ghes, 0);
+	rc = ghes_read_estatus(ghes);
 	if (rc)
 		goto out;
 
@@ -939,7 +938,7 @@ static int ghes_notify_nmi(unsigned int cmd, struct pt_regs *regs)
 		return ret;
 
 	list_for_each_entry_rcu(ghes, &ghes_nmi, list) {
-		if (ghes_read_estatus(ghes, 1)) {
+		if (ghes_read_estatus(ghes)) {
 			ghes_clear_estatus(ghes);
 			continue;
 		} else {
-- 
2.20.1

