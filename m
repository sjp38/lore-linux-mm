Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53FC5C282C7
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1076D20989
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1076D20989
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6DF228E0013; Tue, 29 Jan 2019 13:50:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B6CE8E0003; Tue, 29 Jan 2019 13:50:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A9318E0013; Tue, 29 Jan 2019 13:50:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id EE4268E0003
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:50:30 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id l45so8325919edb.1
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:50:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=GqLHpU/e3+KCvIM2ul3N2tkCkCGFhOd/kfF+9qLa44o=;
        b=qO03sy66dPo4zaOgx2cdkCtyJv2UBbNT2jtDXL9bG18saxmUCnGkQ+j3ieRg/ccyPD
         s0Yb8VbWwzovJ/IQhViKuxViEVzkbb2K1zOZ674jigODJ6kOEeG8Dskdv905TNyrIwSn
         OlBMKDOVRXw6dwiUrYP7VwTE7tUeJaI5CkHpofzRclTBP3tezm3hRnzxQ4Flx258AOLW
         9ChLSM/3y3chnczwt9KJZEhCT0Q+XT0seVJrDaRDJZP2KxJtRNejgM1j0Mk/iVlPdB6d
         hVNtC+8h2TvemEECZ3u5b8rxUzxRkDQKLTHSQyrBqzq/TyO8GppXwJXmkPCoargdb/51
         NzkA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
X-Gm-Message-State: AJcUukfzF8djYpNVUoSZ8ijB930UABw8lPqr6EJpgm70yt5JvWOMHkz4
	HdmNSAHjGtOpcNugSiGiT4uaUjYgobba8CUfCzhoSQD1TokFtm8rPYBYjteKzNrDTdVnK5Qttjl
	zF7xVBRIh2tyWoRird7HMSb7CnI5UlAYAg/NmnRCaRvXOeV4vSsIW7MCkk+rytseCwQ==
X-Received: by 2002:a17:906:ee2:: with SMTP id x2mr5448156eji.202.1548787830442;
        Tue, 29 Jan 2019 10:50:30 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5sicFCOZGQx8dkvN3ecJW7rpzbVztUQc7KY9oelFOe/XfUkp9uoQ8OxfPHx5/kH5ZYt0s6
X-Received: by 2002:a17:906:ee2:: with SMTP id x2mr5448102eji.202.1548787829461;
        Tue, 29 Jan 2019 10:50:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548787829; cv=none;
        d=google.com; s=arc-20160816;
        b=my5zCf1DrDpc/gzKW3z0rZfmAahW6JsF1l0HxOjjfJaBcuCF/hzK0Uf4lAOnq62JsD
         x0zdpg5Ckt1O7/Ngbm2ljz40V0dKcRZP6zvEoo22WDTCaY0x//aMThl4rMhgOOirOc9s
         5XUTPw+57LqJhKvc9hSeDxnv/tmKhYt0X8CVPILthzTU+Of07I3HF3hzS7imBOR+crOK
         vfJpWVvVP5ReS1yZV9KhOtQqTmOVtCyhfC6bFJ4qqONXg5ARxFAO1jwc9VtSymtNxdia
         5Jkvzj3TCadz5eo7ui36k+CYK6GYNmFXBNePwRVU45DYIltC+W11lGYdk+kBaz9mPHpl
         cjYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=GqLHpU/e3+KCvIM2ul3N2tkCkCGFhOd/kfF+9qLa44o=;
        b=rGgp99gQwHpJ/a77diVy3EMUg7O3zUr0NcdwLiJqslQ2U7f8VsGGDJPv6DoMuaXIwl
         XElkVB75zN6mboMeKPc0E92m7j6Qa4Z+ulm0LIzKLQUZa4bTJDprIM0wTZ7riy4tUYoJ
         l5Hj/Q+6y90vdkEqBTxGNm+5kZSwMPAXA6CSHLlgudvNtvOUA9khsD7yaRkng9TCbMHM
         xVQdgP/UPNb4JvCA3CtkIowyEdxIYasasmCxw3/uQWsn94KafWMTykkaVEeEPcZ7jHRL
         y2OgjOP+c+LkDeaArXrQnXXfBnKJe7E99Hx3IqD9V9/qcjdp3vr4xWQDKsK99ySAvwf0
         W1Ow==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id ge18si756742ejb.59.2019.01.29.10.50.29
        for <linux-mm@kvack.org>;
        Tue, 29 Jan 2019 10:50:29 -0800 (PST)
Received-SPF: pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6CC841596;
	Tue, 29 Jan 2019 10:50:28 -0800 (PST)
Received: from eglon.cambridge.arm.com (eglon.cambridge.arm.com [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C01DC3F557;
	Tue, 29 Jan 2019 10:50:25 -0800 (PST)
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
Subject: [PATCH v8 17/26] ACPI / APEI: Pass ghes and estatus separately to avoid a later copy
Date: Tue, 29 Jan 2019 18:48:53 +0000
Message-Id: <20190129184902.102850-18-james.morse@arm.com>
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

The NMI-like notifications scribble over ghes->estatus, before
copying it somewhere else. If this interrupts the ghes_probe() code
calling ghes_proc() on each struct ghes, the data is corrupted.

All the NMI-like notifications should use a queued estatus entry
from the beginning, instead of the ghes version, then copying it.
To do this, break up any use of "ghes->estatus" so that all
functions take the estatus as an argument.

This patch just moves these ghes->estatus dereferences into separate
arguments, no change in behaviour. struct ghes becomes unused in
ghes_clear_estatus() as it only wanted ghes->estatus, which we now
pass directly. This is removed.

Signed-off-by: James Morse <james.morse@arm.com>

---
Changes since v6:
 * Changed subject
 * Renamed ghes_estatus to src_estatus, which is a little clearer
 * Removed struct ghes from ghes_clear_estatus() now that this becomes
   unused in this patch.
 * Mangled the commit message to be different
---
 drivers/acpi/apei/ghes.c | 92 +++++++++++++++++++++-------------------
 1 file changed, 49 insertions(+), 43 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index ccad57468ab7..f95db2398dd5 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -293,9 +293,9 @@ static void ghes_copy_tofrom_phys(void *buffer, u64 paddr, u32 len,
 	}
 }
 
-static int ghes_read_estatus(struct ghes *ghes, u64 *buf_paddr,
-			     enum fixed_addresses fixmap_idx)
-
+static int ghes_read_estatus(struct ghes *ghes,
+			     struct acpi_hest_generic_status *estatus,
+			     u64 *buf_paddr, enum fixed_addresses fixmap_idx)
 {
 	struct acpi_hest_generic *g = ghes->generic;
 	u32 len;
@@ -312,25 +312,25 @@ static int ghes_read_estatus(struct ghes *ghes, u64 *buf_paddr,
 	if (!*buf_paddr)
 		return -ENOENT;
 
-	ghes_copy_tofrom_phys(ghes->estatus, *buf_paddr,
-			      sizeof(*ghes->estatus), 1, fixmap_idx);
-	if (!ghes->estatus->block_status) {
+	ghes_copy_tofrom_phys(estatus, *buf_paddr, sizeof(*estatus), 1,
+			      fixmap_idx);
+	if (!estatus->block_status) {
 		*buf_paddr = 0;
 		return -ENOENT;
 	}
 
 	rc = -EIO;
-	len = cper_estatus_len(ghes->estatus);
-	if (len < sizeof(*ghes->estatus))
+	len = cper_estatus_len(estatus);
+	if (len < sizeof(*estatus))
 		goto err_read_block;
 	if (len > ghes->generic->error_block_length)
 		goto err_read_block;
-	if (cper_estatus_check_header(ghes->estatus))
+	if (cper_estatus_check_header(estatus))
 		goto err_read_block;
-	ghes_copy_tofrom_phys(ghes->estatus + 1,
-			      *buf_paddr + sizeof(*ghes->estatus),
-			      len - sizeof(*ghes->estatus), 1, fixmap_idx);
-	if (cper_estatus_check(ghes->estatus))
+	ghes_copy_tofrom_phys(estatus + 1,
+			      *buf_paddr + sizeof(*estatus),
+			      len - sizeof(*estatus), 1, fixmap_idx);
+	if (cper_estatus_check(estatus))
 		goto err_read_block;
 	rc = 0;
 
@@ -342,16 +342,17 @@ static int ghes_read_estatus(struct ghes *ghes, u64 *buf_paddr,
 	return rc;
 }
 
-static void ghes_clear_estatus(struct ghes *ghes, u64 buf_paddr,
-			       enum fixed_addresses fixmap_idx)
+static void ghes_clear_estatus(struct ghes *ghes,
+			       struct acpi_hest_generic_status *estatus,
+			       u64 buf_paddr, enum fixed_addresses fixmap_idx)
 {
-	ghes->estatus->block_status = 0;
+	estatus->block_status = 0;
 
 	if (!buf_paddr)
 		return;
 
-	ghes_copy_tofrom_phys(ghes->estatus, buf_paddr,
-			      sizeof(ghes->estatus->block_status), 0,
+	ghes_copy_tofrom_phys(estatus, buf_paddr,
+			      sizeof(estatus->block_status), 0,
 			      fixmap_idx);
 
 	/*
@@ -651,12 +652,13 @@ static void ghes_estatus_cache_add(
 	rcu_read_unlock();
 }
 
-static void __ghes_panic(struct ghes *ghes, u64 buf_paddr,
-			 enum fixed_addresses fixmap_idx)
+static void __ghes_panic(struct ghes *ghes,
+			 struct acpi_hest_generic_status *estatus,
+			 u64 buf_paddr, enum fixed_addresses fixmap_idx)
 {
-	__ghes_print_estatus(KERN_EMERG, ghes->generic, ghes->estatus);
+	__ghes_print_estatus(KERN_EMERG, ghes->generic, estatus);
 
-	ghes_clear_estatus(ghes, buf_paddr, fixmap_idx);
+	ghes_clear_estatus(ghes, estatus, buf_paddr, fixmap_idx);
 
 	/* reboot to log the error! */
 	if (!panic_timeout)
@@ -666,25 +668,25 @@ static void __ghes_panic(struct ghes *ghes, u64 buf_paddr,
 
 static int ghes_proc(struct ghes *ghes)
 {
+	struct acpi_hest_generic_status *estatus = ghes->estatus;
 	u64 buf_paddr;
 	int rc;
 
-	rc = ghes_read_estatus(ghes, &buf_paddr, FIX_APEI_GHES_IRQ);
+	rc = ghes_read_estatus(ghes, estatus, &buf_paddr, FIX_APEI_GHES_IRQ);
 	if (rc)
 		goto out;
 
-	if (ghes_severity(ghes->estatus->error_severity) >= GHES_SEV_PANIC) {
-		__ghes_panic(ghes, buf_paddr, FIX_APEI_GHES_IRQ);
-	}
+	if (ghes_severity(estatus->error_severity) >= GHES_SEV_PANIC)
+		__ghes_panic(ghes, estatus, buf_paddr, FIX_APEI_GHES_IRQ);
 
-	if (!ghes_estatus_cached(ghes->estatus)) {
-		if (ghes_print_estatus(NULL, ghes->generic, ghes->estatus))
-			ghes_estatus_cache_add(ghes->generic, ghes->estatus);
+	if (!ghes_estatus_cached(estatus)) {
+		if (ghes_print_estatus(NULL, ghes->generic, estatus))
+			ghes_estatus_cache_add(ghes->generic, estatus);
 	}
-	ghes_do_proc(ghes, ghes->estatus);
+	ghes_do_proc(ghes, estatus);
 
 out:
-	ghes_clear_estatus(ghes, buf_paddr, FIX_APEI_GHES_IRQ);
+	ghes_clear_estatus(ghes, estatus, buf_paddr, FIX_APEI_GHES_IRQ);
 
 	return rc;
 }
@@ -825,17 +827,20 @@ static void ghes_print_queued_estatus(void)
 }
 
 /* Save estatus for further processing in IRQ context */
-static void __process_error(struct ghes *ghes)
+static void __process_error(struct ghes *ghes,
+			    struct acpi_hest_generic_status *src_estatus)
 {
-#ifdef CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG
 	u32 len, node_len;
 	struct ghes_estatus_node *estatus_node;
 	struct acpi_hest_generic_status *estatus;
 
-	if (ghes_estatus_cached(ghes->estatus))
+	if (!IS_ENABLED(CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG))
 		return;
 
-	len = cper_estatus_len(ghes->estatus);
+	if (ghes_estatus_cached(src_estatus))
+		return;
+
+	len = cper_estatus_len(src_estatus);
 	node_len = GHES_ESTATUS_NODE_LEN(len);
 
 	estatus_node = (void *)gen_pool_alloc(ghes_estatus_pool, node_len);
@@ -845,30 +850,31 @@ static void __process_error(struct ghes *ghes)
 	estatus_node->ghes = ghes;
 	estatus_node->generic = ghes->generic;
 	estatus = GHES_ESTATUS_FROM_NODE(estatus_node);
-	memcpy(estatus, ghes->estatus, len);
+	memcpy(estatus, src_estatus, len);
 	llist_add(&estatus_node->llnode, &ghes_estatus_llist);
-#endif
 }
 
 static int ghes_in_nmi_queue_one_entry(struct ghes *ghes,
 				       enum fixed_addresses fixmap_idx)
 {
+	struct acpi_hest_generic_status *estatus = ghes->estatus;
 	u64 buf_paddr;
 	int sev;
 
-	if (ghes_read_estatus(ghes, &buf_paddr, fixmap_idx)) {
-		ghes_clear_estatus(ghes, buf_paddr, fixmap_idx);
+	if (ghes_read_estatus(ghes, estatus, &buf_paddr, fixmap_idx)) {
+		ghes_clear_estatus(ghes, estatus, buf_paddr, fixmap_idx);
 		return -ENOENT;
 	}
 
-	sev = ghes_severity(ghes->estatus->error_severity);
+	sev = ghes_severity(estatus->error_severity);
 	if (sev >= GHES_SEV_PANIC) {
 		ghes_print_queued_estatus();
-		__ghes_panic(ghes, buf_paddr, fixmap_idx);
+		__ghes_panic(ghes, estatus, buf_paddr, fixmap_idx);
+
 	}
 
-	__process_error(ghes);
-	ghes_clear_estatus(ghes, buf_paddr, fixmap_idx);
+	__process_error(ghes, estatus);
+	ghes_clear_estatus(ghes, estatus, buf_paddr, fixmap_idx);
 
 	return 0;
 }
-- 
2.20.1

