Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E81DC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E575520844
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:50:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E575520844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D21A68E0019; Tue, 29 Jan 2019 13:50:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD3A28E0015; Tue, 29 Jan 2019 13:50:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B72E78E0019; Tue, 29 Jan 2019 13:50:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5AC4A8E0015
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:50:45 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id e29so8407931ede.19
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:50:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=6iae2T6BHQ6iX37iUpuGhQgLV/NJrmVS4ISG/YiCITg=;
        b=hsf5bfuBvUqfDHudQavnAEnAkg+tOOij+NcG+0wXUQLniB30Cx54MytJRQpBgJiFls
         7DoDOZFMNjbjb9mObv+LBEPVpQcQEnHHBBpHN9pu18oRxcLujQ7C6yoNzWFrb9+pFr0z
         wrQmq29KuV7b87kKBoRQE1rJjVKwxgCzpet7bryffSrF37ms9vh3RO+joKvcg2JGAvRt
         +PInc6q5dWc6Z2VFhfiJt8nRXvLlFRnvoHBoiCSrRg6zgfoxF58kXHcJKwDh9nxyYF5T
         TsOjJwBG3YM4Mxtl8Qq81DUd99XkipuszvZ4lmu/4RXc03UkmCYgZTr7YnKJX696/YCv
         mhGw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
X-Gm-Message-State: AJcUukdj5JsRJ0qaf7UxinjcoNRL6frLZR51IQePOIsPYL0mSSVe/EH7
	Xicecujfnag2frl/Jjara0v+OE8Drm6P2LkGxP7g1X8ZUQr+odTMNwMq5yQyywj4V84zNPTJDZq
	rhKhQgoOhNP2VRSde13u3Yxhxdlm7PDH70mSgf/A4/JC42OKEL94wQgbeZq5Zj2QP0g==
X-Received: by 2002:a17:906:7f01:: with SMTP id d1mr23564131ejr.244.1548787844845;
        Tue, 29 Jan 2019 10:50:44 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6J4uY2/pLp3HOYLpLuRNkCA1Qm/btC4gSyBnCQx+vgTH+WG/w/KECmDPk7ywoYcf8EBrdF
X-Received: by 2002:a17:906:7f01:: with SMTP id d1mr23564078ejr.244.1548787843858;
        Tue, 29 Jan 2019 10:50:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548787843; cv=none;
        d=google.com; s=arc-20160816;
        b=Sh35786+oTomw82op0Bo6fx9QZ/EJm97jZYDu8l32k/5ucMI+kutLBW7ROwc5EmL1S
         qHqWRh+kdSCtoX/7rs91CdebEUa/liEKkJKqfQ60sJnoD6Kqb828Fcpf17vie5cVQ4MJ
         eFxFPpdJDVvh/v7knmJiUn7GFSkH6AC6bPGmch2g/YJAw/OoKQFMsGXFKWMOPTUNma0T
         XXsB8S8VFDr6PAIUCH1K52PwEjtu5AxdAOevlobmmlvSD/0q0kBWgRFACfiz43EyDzKs
         RSfcf5sEZwe08OmeablUyKvitemnCWRxCwu8R8+wqlXPmn6R0NvkKEhOBAlk55mNk6v/
         zJ5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=6iae2T6BHQ6iX37iUpuGhQgLV/NJrmVS4ISG/YiCITg=;
        b=YHk3UYhav3MdARLfkDtt/+CG8vFi9WFBJS8hCMRS7vtg58HnsA6zmxvMPBif7yQgc6
         /kxe5swEGQFVhDb+eyF9zuoqUxIy7gcb9OSWotR279Bb6JZAER+LRv08pmr4zg3dGOqq
         nNRzI/U3Kfscs03vBylByZz/qCR5nKFm4zcKsmSDFVRtMHbmOIK3fWod+ydaQjeL2Snc
         5spmd8DbZqg88Y4h6j7z4LmjsA9Yo3UAatSwnPhoAr39+zEYA3oEa1nUlIYJlS+0K9DX
         pW4fka2WF+vq87kKFnZhuKUfdfu8V+Iyv2Bgu0Spoef+bTTFkP8n+YBx/BOru1pxPiVp
         PBqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l22si2236282edj.93.2019.01.29.10.50.43
        for <linux-mm@kvack.org>;
        Tue, 29 Jan 2019 10:50:43 -0800 (PST)
Received-SPF: pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 078BAA78;
	Tue, 29 Jan 2019 10:50:43 -0800 (PST)
Received: from eglon.cambridge.arm.com (eglon.cambridge.arm.com [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 5A5903F557;
	Tue, 29 Jan 2019 10:50:40 -0800 (PST)
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
Subject: [PATCH v8 22/26] mm/memory-failure: Add memory_failure_queue_kick()
Date: Tue, 29 Jan 2019 18:48:58 +0000
Message-Id: <20190129184902.102850-23-james.morse@arm.com>
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

The GHES code calls memory_failure_queue() from IRQ context to schedule
work on the current CPU so that memory_failure() can sleep.

For synchronous memory errors the arch code needs to know any signals
that memory_failure() will trigger are pending before it returns to
user-space, possibly when exiting from the IRQ.

Add a helper to kick the memory failure queue, to ensure the scheduled
work has happened. This has to be called from process context, so may
have been migrated from the original cpu. Pass the cpu the work was
queued on.

Change memory_failure_work_func() to permit being called on the 'wrong'
cpu.

Signed-off-by: James Morse <james.morse@arm.com>
---
 include/linux/mm.h  |  1 +
 mm/memory-failure.c | 15 ++++++++++++++-
 2 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 80bb6408fe73..b33bededc69d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2743,6 +2743,7 @@ enum mf_flags {
 };
 extern int memory_failure(unsigned long pfn, int flags);
 extern void memory_failure_queue(unsigned long pfn, int flags);
+extern void memory_failure_queue_kick(int cpu);
 extern int unpoison_memory(unsigned long pfn);
 extern int get_hwpoison_page(struct page *page);
 #define put_hwpoison_page(page)	put_page(page)
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 6379fff1a5ff..9b4705a53fed 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1494,7 +1494,7 @@ static void memory_failure_work_func(struct work_struct *work)
 	unsigned long proc_flags;
 	int gotten;
 
-	mf_cpu = this_cpu_ptr(&memory_failure_cpu);
+	mf_cpu = container_of(work, struct memory_failure_cpu, work);
 	for (;;) {
 		spin_lock_irqsave(&mf_cpu->lock, proc_flags);
 		gotten = kfifo_get(&mf_cpu->fifo, &entry);
@@ -1508,6 +1508,19 @@ static void memory_failure_work_func(struct work_struct *work)
 	}
 }
 
+/*
+ * Process memory_failure work queued on the specified CPU.
+ * Used to avoid return-to-userspace racing with the memory_failure workqueue.
+ */
+void memory_failure_queue_kick(int cpu)
+{
+	struct memory_failure_cpu *mf_cpu;
+
+	mf_cpu = &per_cpu(memory_failure_cpu, cpu);
+	cancel_work_sync(&mf_cpu->work);
+	memory_failure_work_func(&mf_cpu->work);
+}
+
 static int __init memory_failure_init(void)
 {
 	struct memory_failure_cpu *mf_cpu;
-- 
2.20.1

