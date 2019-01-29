Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63913C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:49:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E1FD20844
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:49:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E1FD20844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D47F68E0006; Tue, 29 Jan 2019 13:49:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF91A8E0001; Tue, 29 Jan 2019 13:49:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BC1928E0006; Tue, 29 Jan 2019 13:49:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 650C38E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:49:44 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id y35so8312687edb.5
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:49:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=yrq+fajuZYlMQD6pqhm35zNniWCBZ92c1vlrhOua6h8=;
        b=AXw6/xtLSRyQub65b3D1GdfneArKON+zj+c1FpRJvDHBdK6wLVAYWYbyspAOhafiWz
         NYZjOJGVVs0+3Ykjbsp/8EWgYGhBilhPcCxwHH64k8NjWqkcyW9TY/kdjhWC9V6kUGms
         7qAf6q/UfY71mqZV8D0QVNFg34M6EnKtz5IbzpStG6TpvCnSXQ5L6MZ427krzZieqCmi
         FxaJWYWA9cbD5XRWAFud8UcuduvHLfO8PZb2onQDkK9NzonirrkxjlqKVJ9s89vYpLEK
         RL5XuQ8cePVc873sOahvImgs21SYBeXSM46URDbUOt3S5QmxGMv3RhqZsGD37pq4esHa
         Mmjg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
X-Gm-Message-State: AJcUukeJnaueXkZZ+jbC0QGZa5YEvS36Se1EU79NLnDJ+yfeNKfPNnod
	9+ouot5OepVUS0RzwIqUbOfS72hLkYqmus1UI2zzZlc9WdR5cLVegKHBa35Hqq5yy1E4reGZbfu
	oTb7+ErWQ1Jxk+H3gh4tV9dUD0l7KMkqhcB+gPjwdg3MaEoZlY5RZJrLC0UHereS9Bg==
X-Received: by 2002:a05:6402:14cd:: with SMTP id f13mr26783899edx.224.1548787783904;
        Tue, 29 Jan 2019 10:49:43 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7skBc3PEYe2A3LRSiwLYqh7Dr41XmZVctFALIIGlkA5PSuwJgT888/D5TwE/RHTxTGxNEb
X-Received: by 2002:a05:6402:14cd:: with SMTP id f13mr26783835edx.224.1548787782726;
        Tue, 29 Jan 2019 10:49:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548787782; cv=none;
        d=google.com; s=arc-20160816;
        b=WNqi9Fj5UQh4abqJmxkz5MT+CcVjzjbgf4d+OdaVO0R8Mn25hu3Vdl7okszLC30910
         PIY5zNRcM/KupD3ZiLfIftLcHU7b+g9/fd9zyZPGz2lqtdVOaWx3kjRU4DFktobi0LHe
         rB1nMp6PrxYa+OPwtLRpQM6VZfE0M0CY7aAR64vm+u/9Aad6kbyveRAS9SgnwWrwpCFH
         G6xsZG4XMHHsPCPOO5/jHOzBg2yJ9cjxs+2+XwnGynEQ7tDIQBCDGhOcQQ/llJhzL6m2
         xj4Ypf33WliO4lJaQb7BeCJZUEHcugoz30rcJEGA6DNm37ycWjXFpOLkm9VfjwL6s7tI
         /z6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=yrq+fajuZYlMQD6pqhm35zNniWCBZ92c1vlrhOua6h8=;
        b=p8WFIcNL7N7LWqb2UcahQIjAlUALnx/Kmp0RpEM8BWmChuQYssNihoJkGnu/jptf34
         FlPHJPKktYrFqRmYTnBTsdaHLdmDHqf9qjgOdXXqCuiiORpJ+HWOoIBjMMmazO4lcpWa
         GSfKOb4GNubTL2eb7zva6n1pjsm9lCSGfktakPVmIbPgkwk6gSyJ8KQeKEmp+/s9HD79
         qtM7WkLb9l0PmMgDF0SXPA+b7hXb8hTXRa+QTqwu2mc2c1lxrQ+VUG4i7cgtJk8CQnDJ
         diSdS9ya03cI6cNLQddToRqvWYp7kzrw1/gQPGveLXiFojfAmXFFNPkdhglNa+OvPTNd
         RLCw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k25si3149949edk.323.2019.01.29.10.49.42
        for <linux-mm@kvack.org>;
        Tue, 29 Jan 2019 10:49:42 -0800 (PST)
Received-SPF: pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 960CEA78;
	Tue, 29 Jan 2019 10:49:41 -0800 (PST)
Received: from eglon.cambridge.arm.com (eglon.cambridge.arm.com [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id E99963F557;
	Tue, 29 Jan 2019 10:49:38 -0800 (PST)
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
Subject: [PATCH v8 01/26] ACPI / APEI: Don't wait to serialise with oops messages when panic()ing
Date: Tue, 29 Jan 2019 18:48:37 +0000
Message-Id: <20190129184902.102850-2-james.morse@arm.com>
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

oops_begin() exists to group printk() messages with the oops message
printed by die(). To reach this caller we know that platform firmware
took this error first, then notified the OS via NMI with a 'panic'
severity.

Don't wait for another CPU to release the die-lock before panic()ing,
our only goal is to print this fatal error and panic().

This code is always called in_nmi(), and since commit 42a0bb3f7138
("printk/nmi: generic solution for safe printk in NMI"), it has been
safe to call printk() from this context. Messages are batched in a
per-cpu buffer and printed via irq-work, or a call back from panic().

Link: https://patchwork.kernel.org/patch/10313555/
Acked-by: Borislav Petkov <bp@suse.de>
Signed-off-by: James Morse <james.morse@arm.com>

---
Changes since v6:
 * Capitals in patch subject
 * Tinkered with the commit message.
---
 drivers/acpi/apei/ghes.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index f008ba7c9ced..0c46b79e31b1 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -33,7 +33,6 @@
 #include <linux/interrupt.h>
 #include <linux/timer.h>
 #include <linux/cper.h>
-#include <linux/kdebug.h>
 #include <linux/platform_device.h>
 #include <linux/mutex.h>
 #include <linux/ratelimit.h>
@@ -949,7 +948,6 @@ static int ghes_notify_nmi(unsigned int cmd, struct pt_regs *regs)
 
 		sev = ghes_severity(ghes->estatus->error_severity);
 		if (sev >= GHES_SEV_PANIC) {
-			oops_begin();
 			ghes_print_queued_estatus();
 			__ghes_panic(ghes);
 		}
-- 
2.20.1

