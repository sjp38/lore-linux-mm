Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A19EEC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5FAA720989
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5FAA720989
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 13E4A8E000D; Tue, 29 Jan 2019 13:50:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C6008E0003; Tue, 29 Jan 2019 13:50:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EFCDA8E000D; Tue, 29 Jan 2019 13:50:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 891F28E0003
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:50:10 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id l45so8325511edb.1
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:50:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=pgJKx3vOVAyg9MpHE0lPbrKAyNToi+4kEJf4caHQ36A=;
        b=NJcZy4H7rNVhBpZfp8L4izjK5Hyg1r2wdb15ed/6t0U+bRCqqLz5NyHbUQWNyhx2xh
         iZuvho3fzbLiIVhG33euHRKTSgRS4LPqS1P9+tqvRlC4eG+REuwwdX18TPZy4bXOYRIS
         Xr+ji+6sge2yW9EI/hntoEIIXmyTNKteZZM1/YVNmibWWSAuAMOEvy9sboYES15jsrge
         sRbiWiWuZ+XZl2N3gz4ewGh+C73McX5ZLpqkI+hf9vSQT7TbRKG2Mv8iX9gvq7ozGu7Z
         7egVgz0vDGGVnhLJJuKd9KMO9PQZdn5mpyKeHEiahN9bwj2snKYgaoLc7cDeVs9owfzl
         gngg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
X-Gm-Message-State: AJcUukcn0FvqR9H0zWAxjZSefGFkbMbBypQaBDFsBRwOgOu51Cixh46H
	81Q24aQQZ8AQXBabQhZHen6D5gRd0xGBwhasQ8eygoaKRl27kMkGUfPBJItO1SdUR7rdA02QlDJ
	lQjGWjvfp0/KK5VzNpwS8i5Qi44PIxIMn5Xr+gYo3MdFsM+MZ39TYjpolnQZmDOMv6A==
X-Received: by 2002:a50:a347:: with SMTP id 65mr27107336edn.40.1548787810016;
        Tue, 29 Jan 2019 10:50:10 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4+k8NANEsK32kNzrCoY71Kof5lSiC5m6K3iw3aIY9lPsqkTQHED/OQOAWEqzdp0uTbqHOQ
X-Received: by 2002:a50:a347:: with SMTP id 65mr27107273edn.40.1548787808984;
        Tue, 29 Jan 2019 10:50:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548787808; cv=none;
        d=google.com; s=arc-20160816;
        b=F6d8NUCkvuTlFMkMr7xd4zT/HrRy9b93hSRxan2ikAzbvXJj3Kxp9uVnOgbmWG8+Z5
         5PQSazDuwvCCPAfSIMaEX+QSCWJMGDvss3smxT5ZaQakTgT+EM7IPem3kAj6TGlfUKCh
         LRlvDQJGtKzpt2Vm1bPztPn5jdryLSe6drQjX6HgZSc7gNMPnJ/nR+SV8CLvkKRTNBCN
         yzBkQF2X+Zm7uZDm4HCUBurB9Z2UzJFC/S3ykzmM3c6vNrZHihpeqxkNVGK04dMPVzN0
         8rogjpZ6yn6DPyHmFvDm9Yqadkx6yXFvbebsznOUqlAdkK9Vwmi31OJY5Wt0rrDu5Ytn
         kvzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=pgJKx3vOVAyg9MpHE0lPbrKAyNToi+4kEJf4caHQ36A=;
        b=nFvQrDF5gx1KwUjp8/ZY/kVo8Ej99HUpYOaYiukaAQDpKaOkLrOW2JL2bIUxBG45v0
         rfIL8KrnCE0PLPcU+xP5h5plsVbDHvULkek3qks+D9u4Rz+ZN+xjJonKHw3QxvzJn314
         +jSRQEnHmQPkRHVAy428TzERrLtDb9jzEydYGnGwVOP8yQFkt9ZLfmCJJYM4OFfZ2Qll
         sCktZMSN94R0lDSeOtOhcsWlatJKip59ijGeWEyVwdoKy+1cYJe3GiBb0UI+vCe4came
         qAiEjNSH6pE425FTY3P2KDfCutV2LVOEqn++J9r5K7hkh8H/+6J8bKLWQf+dHDs/krjj
         n/ug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l3-v6si2441594ejs.120.2019.01.29.10.50.08
        for <linux-mm@kvack.org>;
        Tue, 29 Jan 2019 10:50:08 -0800 (PST)
Received-SPF: pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D6620A78;
	Tue, 29 Jan 2019 10:50:07 -0800 (PST)
Received: from eglon.cambridge.arm.com (eglon.cambridge.arm.com [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 3533B3F557;
	Tue, 29 Jan 2019 10:50:05 -0800 (PST)
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
Subject: [PATCH v8 10/26] ACPI / APEI: Don't allow ghes_ack_error() to mask earlier errors
Date: Tue, 29 Jan 2019 18:48:46 +0000
Message-Id: <20190129184902.102850-11-james.morse@arm.com>
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

During ghes_proc() we use ghes_ack_error() to tell an external agent
we are done with these records and it can re-use the memory.

rc may hold an error returned by ghes_read_estatus(), ENOENT causes
us to skip ghes_ack_error() (as there is nothing to ack), but rc may
also by EIO, which gets supressed.

ghes_clear_estatus() is where we mark the records as processed for
non GHESv2 error sources, and already spots the ENOENT case as
buf_paddr is set to 0 by ghes_read_estatus().

Move the ghes_ack_error() call in here to avoid extra logic with
the return code in ghes_proc().

This enables GHESv2 acking for NMI-like error sources. This is safe
as the buffer is pre-mapped by map_gen_v2() before the GHES is added
to any NMI handler lists.

This same pre-mapping step means we can't receive an error from
apei_read()/write() here as apei_check_gar() succeeded when it
was mapped, and the mapping was cached, so the address can't be
rejected at runtime. Remove the error-returns as this is now
called from a function with no return.

Signed-off-by: James Morse <james.morse@arm.com>
---
 drivers/acpi/apei/ghes.c | 47 +++++++++++++++++++---------------------
 1 file changed, 22 insertions(+), 25 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index cb3d88de711f..bd58749d31bb 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -197,6 +197,21 @@ static void unmap_gen_v2(struct ghes *ghes)
 	apei_unmap_generic_address(&ghes->generic_v2->read_ack_register);
 }
 
+static void ghes_ack_error(struct acpi_hest_generic_v2 *gv2)
+{
+	int rc;
+	u64 val = 0;
+
+	rc = apei_read(&val, &gv2->read_ack_register);
+	if (rc)
+		return;
+
+	val &= gv2->read_ack_preserve << gv2->read_ack_register.bit_offset;
+	val |= gv2->read_ack_write    << gv2->read_ack_register.bit_offset;
+
+	apei_write(val, &gv2->read_ack_register);
+}
+
 static struct ghes *ghes_new(struct acpi_hest_generic *generic)
 {
 	struct ghes *ghes;
@@ -361,6 +376,13 @@ static void ghes_clear_estatus(struct ghes *ghes, u64 buf_paddr)
 
 	ghes_copy_tofrom_phys(ghes->estatus, buf_paddr,
 			      sizeof(ghes->estatus->block_status), 0);
+
+	/*
+	 * GHESv2 type HEST entries introduce support for error acknowledgment,
+	 * so only acknowledge the error if this support is present.
+	 */
+	if (is_hest_type_generic_v2(ghes))
+		ghes_ack_error(ghes->generic_v2);
 }
 
 static void ghes_handle_memory_failure(struct acpi_hest_generic_data *gdata, int sev)
@@ -652,21 +674,6 @@ static void ghes_estatus_cache_add(
 	rcu_read_unlock();
 }
 
-static int ghes_ack_error(struct acpi_hest_generic_v2 *gv2)
-{
-	int rc;
-	u64 val = 0;
-
-	rc = apei_read(&val, &gv2->read_ack_register);
-	if (rc)
-		return rc;
-
-	val &= gv2->read_ack_preserve << gv2->read_ack_register.bit_offset;
-	val |= gv2->read_ack_write    << gv2->read_ack_register.bit_offset;
-
-	return apei_write(val, &gv2->read_ack_register);
-}
-
 static void __ghes_panic(struct ghes *ghes, u64 buf_paddr)
 {
 	__ghes_print_estatus(KERN_EMERG, ghes->generic, ghes->estatus);
@@ -701,16 +708,6 @@ static int ghes_proc(struct ghes *ghes)
 out:
 	ghes_clear_estatus(ghes, buf_paddr);
 
-	if (rc == -ENOENT)
-		return rc;
-
-	/*
-	 * GHESv2 type HEST entries introduce support for error acknowledgment,
-	 * so only acknowledge the error if this support is present.
-	 */
-	if (is_hest_type_generic_v2(ghes))
-		return ghes_ack_error(ghes->generic_v2);
-
 	return rc;
 }
 
-- 
2.20.1

