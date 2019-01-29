Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9524C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 87D1820844
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 87D1820844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E9228E000E; Tue, 29 Jan 2019 13:50:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 29A438E0003; Tue, 29 Jan 2019 13:50:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 18EFC8E000E; Tue, 29 Jan 2019 13:50:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A39A58E0003
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:50:13 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id t2so8195701edb.22
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:50:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ialR/FtHnTwHJvUu65JX50y7bWNIj6R4mAr1PLkRFOs=;
        b=lV299Cl8RSv8Zyies9VXxw/1Hkw58P5Wxj9ueJC7bveIYTAlUvSEdzrQcdfxFJIkAZ
         muI080zj4IvQiGsA7jfgq8gELW0Qe+CQh9/azJuvd+ZYWJYdBl2Fgq01H9mnIQqdbAXX
         Ey95tlnfrFsJb72L4Lvf0Umer1kkxnnHcSaonlhX2ZLDwdCrbG1yUeyCpTwqNwYOGvCw
         WBQ6Ja8bBMxw4g6kKHW9I7cOjdYzJra6RTV/HzDnnrd49ivn+K//0muKjxoQiqJwxlUX
         DKfIAX4DH/xOsMMg7DnGU2jTSJ3oPba1EW2L5RIwcD6GWeFjslTtAXtvFp8OTpU5oGzE
         CQQw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
X-Gm-Message-State: AJcUukdNxmSPqeSSCypmq9k/GLl0RP3nsXk8GapkQm/5bw7OBAgekiVu
	kDGEyrcNahWGLBw7QgAZiNV9R0QF8ZC8XJZ1cl++Mc195WFt9YygTBN4oHVGKiug5uptibq+wJG
	8PqrntWZx7op8w/Icbkmuk2cFk+yn8yNND4vbLKXPaxJD0ywR6vM40wzm+6Dh8bwkYA==
X-Received: by 2002:a17:906:9493:: with SMTP id t19mr23804578ejx.63.1548787813142;
        Tue, 29 Jan 2019 10:50:13 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6mmFOGka4I2wTRb+D2EEUL2Ncs/Z4hx4joSCbSVlGm+RKl2AncTd//90V21LSMsRTSo/lO
X-Received: by 2002:a17:906:9493:: with SMTP id t19mr23804508ejx.63.1548787811902;
        Tue, 29 Jan 2019 10:50:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548787811; cv=none;
        d=google.com; s=arc-20160816;
        b=zRIoWEmZd1Yc0upeLUGIoFWBjmGZidl7yvwQxTCHcee2H7LqLQBf+5QK2PZiS9P91C
         tL/qPn2C6qTd9x62yJMNVcZDEINUAHPzXlPIMrPZELpGCCPMNGif4iTdbNj0VOC2JOQD
         4R7APWcjxAamnzzMfpAAXn0hUMMmcocNE8GgM+RwGJKWeyqrsToASt4vLcDyBmAlRvp4
         6WLe5fUQ93/hjhwRTHgg4qWpnxV/0PftJhJS0NZQJulwneR3LHTTxB+apFjGrvwKopi8
         KTQ/DMq689Ersgn62OTPsEmZvIZYWnSzgmDR+69fUm+Skm0LgfgejFH/Xg9ssnVJTS03
         ROLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=ialR/FtHnTwHJvUu65JX50y7bWNIj6R4mAr1PLkRFOs=;
        b=wOh/nLd60+LrMIb05p0tRLplmXoBlZjpVm+qRP32PIRMujLPbVVSGkeX2Jh6izBHuF
         HQ3HR+gPzWlMVveZcU8GgOApdq3xe+m3E9HYskpDwYGQdFO70q4FHKK3KAMCKnRUz1uR
         uHhtArpvvf2X9yq5Axj4Egq/V9m3Uv7NISlRHz2BfmFVZn3bev/qmZAJ81X3O2rYhwOZ
         rv4FTXc2dqIHK+aW4uoCyLWhCl220qvFyC3/vhsu2UtQ9aC1s6yjS9IJeOjv2RH//tTU
         ditgR4yOMXWh7SG7zi5yv9m40CyQuq8mS3ydbucs67Jk+PZHDvOqomdPhyeNHC4R69nr
         Dhsg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id x22si315741ejs.223.2019.01.29.10.50.11
        for <linux-mm@kvack.org>;
        Tue, 29 Jan 2019 10:50:11 -0800 (PST)
Received-SPF: pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C2C4715AB;
	Tue, 29 Jan 2019 10:50:10 -0800 (PST)
Received: from eglon.cambridge.arm.com (eglon.cambridge.arm.com [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 210DF3F557;
	Tue, 29 Jan 2019 10:50:07 -0800 (PST)
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
Subject: [PATCH v8 11/26] ACPI / APEI: Move NOTIFY_SEA between the estatus-queue and NOTIFY_NMI
Date: Tue, 29 Jan 2019 18:48:47 +0000
Message-Id: <20190129184902.102850-12-james.morse@arm.com>
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

The estatus-queue code is currently hidden by the NOTIFY_NMI #ifdefs.
Once NOTIFY_SEA starts using the estatus-queue we can stop hiding
it as each architecture has a user that can't be turned off.

Split the existing CONFIG_HAVE_ACPI_APEI_NMI block in two, and move
the SEA code into the gap.

Move the code around ... and changes the stale comment describing
why the status queue is necessary: printk() is no longer the issue,
its the helpers like memory_failure_queue() that aren't nmi safe.

Signed-off-by: James Morse <james.morse@arm.com>
---
 drivers/acpi/apei/ghes.c | 113 ++++++++++++++++++++-------------------
 1 file changed, 59 insertions(+), 54 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index bd58749d31bb..576dce29159d 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -767,66 +767,21 @@ static struct notifier_block ghes_notifier_hed = {
 	.notifier_call = ghes_notify_hed,
 };
 
-#ifdef CONFIG_ACPI_APEI_SEA
-static LIST_HEAD(ghes_sea);
-
-/*
- * Return 0 only if one of the SEA error sources successfully reported an error
- * record sent from the firmware.
- */
-int ghes_notify_sea(void)
-{
-	struct ghes *ghes;
-	int ret = -ENOENT;
-
-	rcu_read_lock();
-	list_for_each_entry_rcu(ghes, &ghes_sea, list) {
-		if (!ghes_proc(ghes))
-			ret = 0;
-	}
-	rcu_read_unlock();
-	return ret;
-}
-
-static void ghes_sea_add(struct ghes *ghes)
-{
-	mutex_lock(&ghes_list_mutex);
-	list_add_rcu(&ghes->list, &ghes_sea);
-	mutex_unlock(&ghes_list_mutex);
-}
-
-static void ghes_sea_remove(struct ghes *ghes)
-{
-	mutex_lock(&ghes_list_mutex);
-	list_del_rcu(&ghes->list);
-	mutex_unlock(&ghes_list_mutex);
-	synchronize_rcu();
-}
-#else /* CONFIG_ACPI_APEI_SEA */
-static inline void ghes_sea_add(struct ghes *ghes) { }
-static inline void ghes_sea_remove(struct ghes *ghes) { }
-#endif /* CONFIG_ACPI_APEI_SEA */
-
 #ifdef CONFIG_HAVE_ACPI_APEI_NMI
 /*
- * printk is not safe in NMI context.  So in NMI handler, we allocate
- * required memory from lock-less memory allocator
- * (ghes_estatus_pool), save estatus into it, put them into lock-less
- * list (ghes_estatus_llist), then delay printk into IRQ context via
- * irq_work (ghes_proc_irq_work).  ghes_estatus_size_request record
- * required pool size by all NMI error source.
+ * Handlers for CPER records may not be NMI safe. For example,
+ * memory_failure_queue() takes spinlocks and calls schedule_work_on().
+ * In any NMI-like handler, memory from ghes_estatus_pool is used to save
+ * estatus, and added to the ghes_estatus_llist. irq_work_queue() causes
+ * ghes_proc_in_irq() to run in IRQ context where each estatus in
+ * ghes_estatus_llist is processed.
+ *
+ * Memory from the ghes_estatus_pool is also used with the ghes_estatus_cache
+ * to suppress frequent messages.
  */
 static struct llist_head ghes_estatus_llist;
 static struct irq_work ghes_proc_irq_work;
 
-/*
- * NMI may be triggered on any CPU, so ghes_in_nmi is used for
- * having only one concurrent reader.
- */
-static atomic_t ghes_in_nmi = ATOMIC_INIT(0);
-
-static LIST_HEAD(ghes_nmi);
-
 static void ghes_proc_in_irq(struct irq_work *irq_work)
 {
 	struct llist_node *llnode, *next;
@@ -949,6 +904,56 @@ static int ghes_in_nmi_spool_from_list(struct list_head *rcu_list)
 
 	return ret;
 }
+#endif /* CONFIG_HAVE_ACPI_APEI_NMI */
+
+#ifdef CONFIG_ACPI_APEI_SEA
+static LIST_HEAD(ghes_sea);
+
+/*
+ * Return 0 only if one of the SEA error sources successfully reported an error
+ * record sent from the firmware.
+ */
+int ghes_notify_sea(void)
+{
+	struct ghes *ghes;
+	int ret = -ENOENT;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(ghes, &ghes_sea, list) {
+		if (!ghes_proc(ghes))
+			ret = 0;
+	}
+	rcu_read_unlock();
+	return ret;
+}
+
+static void ghes_sea_add(struct ghes *ghes)
+{
+	mutex_lock(&ghes_list_mutex);
+	list_add_rcu(&ghes->list, &ghes_sea);
+	mutex_unlock(&ghes_list_mutex);
+}
+
+static void ghes_sea_remove(struct ghes *ghes)
+{
+	mutex_lock(&ghes_list_mutex);
+	list_del_rcu(&ghes->list);
+	mutex_unlock(&ghes_list_mutex);
+	synchronize_rcu();
+}
+#else /* CONFIG_ACPI_APEI_SEA */
+static inline void ghes_sea_add(struct ghes *ghes) { }
+static inline void ghes_sea_remove(struct ghes *ghes) { }
+#endif /* CONFIG_ACPI_APEI_SEA */
+
+#ifdef CONFIG_HAVE_ACPI_APEI_NMI
+/*
+ * NMI may be triggered on any CPU, so ghes_in_nmi is used for
+ * having only one concurrent reader.
+ */
+static atomic_t ghes_in_nmi = ATOMIC_INIT(0);
+
+static LIST_HEAD(ghes_nmi);
 
 static int ghes_notify_nmi(unsigned int cmd, struct pt_regs *regs)
 {
-- 
2.20.1

