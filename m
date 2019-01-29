Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E89B5C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B16EB20844
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B16EB20844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 61D8A8E000C; Tue, 29 Jan 2019 13:50:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F5FD8E0003; Tue, 29 Jan 2019 13:50:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3FB658E000C; Tue, 29 Jan 2019 13:50:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D84708E0003
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:50:07 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id c53so8419867edc.9
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:50:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=zuDCjHKH0Pheb2PX+fbOrjU+7Fi6QYf32iCk7O3WPu8=;
        b=oSFdOgJtkUooDUuiJG21eV0LeeryjwQ2VuaZTVMRkMtUPS3gFB00yK20O6wQSZkfmH
         55yS+7lJ0eDWqW0Bq2AAdIjCAAsLjznW34geLGorMUM27AteY+Gj+zQjidJrWxt/shtp
         2twmWgFkLy9y5YccEg1gooQ0TwTA5VAD8TC6QsgeiYhjnIDB+YMEJwLsl36XRWAzdTG1
         R3JA3RHvCtXAZez/OfuBVmykRUXLlp3LKhocB4xweeOJuhPctTutn+d4idrK26Uxm8XB
         zpQYI+G3USZbpHD9mZQwusL7NXrVS0acXTJRaSxwWKj4QoHZC25z96suxPanC1KRrmlt
         wrEg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
X-Gm-Message-State: AJcUukcyvvNPjXle/fCX8ceOF5Hg963wTCKVk7voi0McvZ0KO1Tay1DJ
	xScZHJp453b8brEmqeKKO2uGbuC2Ca7ww5xg5VEW4wMPJAmyNdqaJClkLRRSUnjunJRnx4032pj
	PSaaIcPMe4nvHnrnsOh76UV74RXia064TOJDiEyAXTszq13P5oohQrOay+mHug1WMJQ==
X-Received: by 2002:a17:906:e96:: with SMTP id p22mr11108151ejf.109.1548787807370;
        Tue, 29 Jan 2019 10:50:07 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4muYygbx9yyGT1hXyeqsZj60gUylFwGAlO00lkD88JXDODd+LTpaMpbvUfUCtRvq1kpySP
X-Received: by 2002:a17:906:e96:: with SMTP id p22mr11108088ejf.109.1548787806163;
        Tue, 29 Jan 2019 10:50:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548787806; cv=none;
        d=google.com; s=arc-20160816;
        b=tHT1nW6ySUySTQXQ09pnFZG9aWhrxVB+qUAePgzgneagBNfxoifu0rYhc9EH/S61sO
         X5yK1URPtLHZgtZ3a2Us7HUIHK4zBuJbpFLZ+BBFhqeECklqOgoJAgfQn1ZCkqsnYw7i
         y3WhnOfQ9MgXs4iqUEWyfWctZdtBQnM2xv7Ic9e8Jm9nGr/jtdU7FT59h0eVfbFFZR6A
         sXGN/OdOSip3EspbNBPdUQvJnRVdu3JkywZnZ0Lm9E1ijYl4Znc6VQtUsHjfnmuA5bVw
         tdNgyh+F5B2t5HFpFQK+HErmeaYV4NuUXyDAZnBf6OAhSB5Zs6JIXJS66uzwoFZgt3Ns
         CqBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=zuDCjHKH0Pheb2PX+fbOrjU+7Fi6QYf32iCk7O3WPu8=;
        b=WDe1DrRjBR93SklSSgr9N3dsY0+lH2gpQEccunZfw3dL19J0/8QGjmqvM1kkFraSKS
         GfzWlisxDD7vHyG7Ri70e0gFdfrUOwruXo3IaVQcrauJzc0Cms4qVyC3QlznNChkutvd
         yJZD2r866QQa+f/pH2TROd6Ha76uAimKOuLu0uI3KFIoWxNLHMq266yK1T4WAjSgxy86
         TYzHdME3oPh+HL8mUtOhEGTZulETWUPW0Gqq0jdnq2SYbyPzV4sF0ukZWKAfAMZGwNtQ
         9ZssgApkxgts3EXFTKy8IKRWL5h+UukT380l2RYKH4cjg2a/mcuII2W4A4QISOLy7+5g
         wpMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z31si2458721ede.13.2019.01.29.10.50.05
        for <linux-mm@kvack.org>;
        Tue, 29 Jan 2019 10:50:06 -0800 (PST)
Received-SPF: pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id EA8C41596;
	Tue, 29 Jan 2019 10:50:04 -0800 (PST)
Received: from eglon.cambridge.arm.com (eglon.cambridge.arm.com [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 48CA03F557;
	Tue, 29 Jan 2019 10:50:02 -0800 (PST)
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
Subject: [PATCH v8 09/26] ACPI / APEI: Generalise the estatus queue's notify code
Date: Tue, 29 Jan 2019 18:48:45 +0000
Message-Id: <20190129184902.102850-10-james.morse@arm.com>
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

Refactor the estatus queue's pool notification routine from
NOTIFY_NMI's handlers. This will allow another notification
method to use the estatus queue without duplicating this code.

Add rcu_read_lock()/rcu_read_unlock() around the list
list_for_each_entry_rcu() walker. These aren't strictly necessary as
the whole nmi_enter/nmi_exit() window is a spooky RCU read-side
critical section.

in_nmi_queue_one_entry() is separate from the rcu-list walker for a
later caller that doesn't need to walk a list.

Signed-off-by: James Morse <james.morse@arm.com>
Reviewed-by: Punit Agrawal <punit.agrawal@arm.com>
Tested-by: Tyler Baicar <tbaicar@codeaurora.org>

---
Changes since v7:
 * Moved err= onto a separate line to make this more readable
 * Dropped ghes_ prefix on new static functions
 * Renamed stuff, 'notify' has an overloaded meaning,

Changes since v6:
 * Removed pool grow/remove code as this is no longer necessary.

Changes since v3:
 * Removed duplicate or redundant paragraphs in commit message.
 * Fixed the style of a zero check.
Changes since v1:
   * Tidied up _in_nmi_notify_one().
---
 drivers/acpi/apei/ghes.c | 65 ++++++++++++++++++++++++++--------------
 1 file changed, 43 insertions(+), 22 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index af3c10f47f20..cb3d88de711f 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -912,37 +912,58 @@ static void __process_error(struct ghes *ghes)
 #endif
 }
 
-static int ghes_notify_nmi(unsigned int cmd, struct pt_regs *regs)
+static int ghes_in_nmi_queue_one_entry(struct ghes *ghes)
 {
 	u64 buf_paddr;
-	struct ghes *ghes;
-	int sev, ret = NMI_DONE;
+	int sev;
 
-	if (!atomic_add_unless(&ghes_in_nmi, 1, 1))
-		return ret;
+	if (ghes_read_estatus(ghes, &buf_paddr)) {
+		ghes_clear_estatus(ghes, buf_paddr);
+		return -ENOENT;
+	}
 
-	list_for_each_entry_rcu(ghes, &ghes_nmi, list) {
-		if (ghes_read_estatus(ghes, &buf_paddr)) {
-			ghes_clear_estatus(ghes, buf_paddr);
-			continue;
-		} else {
-			ret = NMI_HANDLED;
-		}
+	sev = ghes_severity(ghes->estatus->error_severity);
+	if (sev >= GHES_SEV_PANIC) {
+		ghes_print_queued_estatus();
+		__ghes_panic(ghes, buf_paddr);
+	}
 
-		sev = ghes_severity(ghes->estatus->error_severity);
-		if (sev >= GHES_SEV_PANIC) {
-			ghes_print_queued_estatus();
-			__ghes_panic(ghes, buf_paddr);
-		}
+	__process_error(ghes);
+	ghes_clear_estatus(ghes, buf_paddr);
 
-		__process_error(ghes);
-		ghes_clear_estatus(ghes, buf_paddr);
+	return 0;
+}
+
+static int ghes_in_nmi_spool_from_list(struct list_head *rcu_list)
+{
+	int err, ret = -ENOENT;
+	struct ghes *ghes;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(ghes, rcu_list, list) {
+		err = ghes_in_nmi_queue_one_entry(ghes);
+		if (!err)
+			ret = 0;
 	}
+	rcu_read_unlock();
 
-#ifdef CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG
-	if (ret == NMI_HANDLED)
+	if (IS_ENABLED(CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG) && !ret)
 		irq_work_queue(&ghes_proc_irq_work);
-#endif
+
+	return ret;
+}
+
+static int ghes_notify_nmi(unsigned int cmd, struct pt_regs *regs)
+{
+	int err, ret = NMI_DONE;
+
+	if (!atomic_add_unless(&ghes_in_nmi, 1, 1))
+		return ret;
+
+	err = ghes_in_nmi_spool_from_list(&ghes_nmi);
+	if (!err)
+		ret = NMI_HANDLED;
+
 	atomic_dec(&ghes_in_nmi);
 	return ret;
 }
-- 
2.20.1

