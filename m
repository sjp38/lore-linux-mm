Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C9A5C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6537420989
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6537420989
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E83A8E0014; Tue, 29 Jan 2019 13:50:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 494D78E0003; Tue, 29 Jan 2019 13:50:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 362FB8E0014; Tue, 29 Jan 2019 13:50:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id CE81D8E0003
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:50:33 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id c34so8136849edb.8
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:50:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=81UVWBzuiiLWxlt5Zhyss5LIIbWmTL+dhjejw8e0YyU=;
        b=b0uX+mMOM/OaUwooOQgxTVvrcBPpFVfK2OXYYlKkrZyr/6rmEf3aMHftDG49gGOnm0
         kj1iRZWeOWzGkxP60njq0vrfS2FnvFjWafxMeJura1XxpgkkluRIcjEIrFsb5f07xDA+
         NULj3wRk+Bk0JILoQtsTqi1xp3XmscvcaCIkkyoxNnokSugWFQRoFEAbE+c20RrfbzUB
         8JBn+R8mw6UkEeysFwiczyBWBJzlbLVQymk0wYb6hAq8nTsGi6kJ/deOA6z51+dgZQwO
         7dTCCEtrwX0xOh5HsmLn0KnKg0bwsvEWpsWP2MeoDvnHgb5ETyFGQoEZBS7gNiLi5uRu
         hVNw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
X-Gm-Message-State: AJcUukc096SzJoODO6DHUjxEB3YzJUVqcdJz8igPVFhXyDO4exuLIB11
	AqsVCbCcuAH1y8qPsux0yMBqdC4OPml6DpYa4NkHxq9TgNS4QRQ4WkohmrOY9kQAnEBM90K/FH1
	6mmho9FpAc5YFXHrnA2lz23n6uxP7YtXIfr3lERpn9nTv8WSV1PcXAaBCNfJXBKJXGQ==
X-Received: by 2002:a05:6402:8d2:: with SMTP id d18mr27058927edz.119.1548787833349;
        Tue, 29 Jan 2019 10:50:33 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5Ue/JKRduXMJ0TgtL2FAfHvCY5OPa2F0ZayK2pc7JEfY/6lEGZekwMl161EwcdJULQKXU7
X-Received: by 2002:a05:6402:8d2:: with SMTP id d18mr27058864edz.119.1548787832296;
        Tue, 29 Jan 2019 10:50:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548787832; cv=none;
        d=google.com; s=arc-20160816;
        b=v7+Vi8YI79gVKRk5mQe7rkVcCEYwAhbecR4mKIBdstGme1iizH80yqq/76n8dtq+Mi
         hsUenK4oHaCOv9nvc9qDy6fSTGiIf0vPUMSunfRCjsnUjeP4IN0XAIg6DtE+jz1OMlsa
         q9vkELXH3V2sFCr87Xwjr5xIMbIgEnGN3x42uEdmNbSsSTNlDau0J+v0yqF0EVRMu/sD
         MwkGU7rOAkAdxum+6PR6bAbpWXvA+uCRgIxliw7swijl/yT5icFf0vAx0i343s5kGPoZ
         8TR56f9Xv61IZbTBfIKC1So/8oldroZjhzN/kLUWjiUBK9X8hXRHmJqrZ0lp3z4KE5+T
         T46w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=81UVWBzuiiLWxlt5Zhyss5LIIbWmTL+dhjejw8e0YyU=;
        b=0oNuboi1A5uKsh0RtKN8M5/knbU5I7tT2gJjoWN/BdRPR5q9l36qvYUee6vatn4jjJ
         0UXh4TgFP/1MGYD1oGDLc09XRb14AmBdqrDcw/SMnib94Kz+aSjpDFY5fFogH+4PBWx7
         psTURinZmwOV9xAc8xfxfr3TPbKgOu5hgboX3Xfe5Pqq+PEwtpXD09eNyCnTSgdhJP04
         e+DW8e2kWy47CnoOtoliwFP1JesMLv30KqZcmmWMmL7QGhUZRTEBqOyuk3oAndypFZgL
         e+i84BSRxxOJZufioK6OM+jc5+TopEVZMHCjwq6+lVO/8GPXPv8wS9xVTB4zn3IczdtJ
         wyjg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d15si1130618eds.170.2019.01.29.10.50.32
        for <linux-mm@kvack.org>;
        Tue, 29 Jan 2019 10:50:32 -0800 (PST)
Received-SPF: pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 5894715AB;
	Tue, 29 Jan 2019 10:50:31 -0800 (PST)
Received: from eglon.cambridge.arm.com (eglon.cambridge.arm.com [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id AB9013F557;
	Tue, 29 Jan 2019 10:50:28 -0800 (PST)
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
Subject: [PATCH v8 18/26] ACPI / APEI: Make GHES estatus header validation more user friendly
Date: Tue, 29 Jan 2019 18:48:54 +0000
Message-Id: <20190129184902.102850-19-james.morse@arm.com>
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

ghes_read_estatus() checks various lengths in the top-level header to
ensure the CPER records to be read aren't obviously corrupt.

Take the opportunity to make this more user-friendly, printing a
(ratelimited) message about the nature of the header format error.

Suggested-by: Borislav Petkov <bp@alien8.de>
Signed-off-by: James Morse <james.morse@arm.com>
---
 drivers/acpi/apei/ghes.c | 46 ++++++++++++++++++++++++++++------------
 1 file changed, 32 insertions(+), 14 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index f95db2398dd5..9391fff71344 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -293,6 +293,30 @@ static void ghes_copy_tofrom_phys(void *buffer, u64 paddr, u32 len,
 	}
 }
 
+/* Check the top-level record header has an appropriate size. */
+int __ghes_check_estatus(struct ghes *ghes,
+			 struct acpi_hest_generic_status *estatus)
+{
+	u32 len = cper_estatus_len(estatus);
+
+	if (len < sizeof(*estatus)) {
+		pr_warn_ratelimited(FW_WARN GHES_PFX "Truncated error status block!\n");
+		return -EIO;
+	}
+
+	if (len > ghes->generic->error_block_length) {
+		pr_warn_ratelimited(FW_WARN GHES_PFX "Invalid error status block length!\n");
+		return -EIO;
+	}
+
+	if (cper_estatus_check_header(estatus)) {
+		pr_warn_ratelimited(FW_WARN GHES_PFX "Invalid CPER header!\n");
+		return -EIO;
+	}
+
+	return 0;
+}
+
 static int ghes_read_estatus(struct ghes *ghes,
 			     struct acpi_hest_generic_status *estatus,
 			     u64 *buf_paddr, enum fixed_addresses fixmap_idx)
@@ -319,27 +343,21 @@ static int ghes_read_estatus(struct ghes *ghes,
 		return -ENOENT;
 	}
 
-	rc = -EIO;
+	rc = __ghes_check_estatus(ghes, estatus);
+	if (rc)
+		return rc;
+
 	len = cper_estatus_len(estatus);
-	if (len < sizeof(*estatus))
-		goto err_read_block;
-	if (len > ghes->generic->error_block_length)
-		goto err_read_block;
-	if (cper_estatus_check_header(estatus))
-		goto err_read_block;
 	ghes_copy_tofrom_phys(estatus + 1,
 			      *buf_paddr + sizeof(*estatus),
 			      len - sizeof(*estatus), 1, fixmap_idx);
-	if (cper_estatus_check(estatus))
-		goto err_read_block;
-	rc = 0;
-
-err_read_block:
-	if (rc)
+	if (cper_estatus_check(estatus)) {
 		pr_warn_ratelimited(FW_WARN GHES_PFX
 				    "Failed to read error status block!\n");
+		return -EIO;
+	}
 
-	return rc;
+	return 0;
 }
 
 static void ghes_clear_estatus(struct ghes *ghes,
-- 
2.20.1

