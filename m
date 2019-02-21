Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87955C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:51:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4DC372083B
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:51:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4DC372083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 037FC8E00D6; Thu, 21 Feb 2019 18:51:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EDBD98E00D4; Thu, 21 Feb 2019 18:51:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA3B38E00D6; Thu, 21 Feb 2019 18:51:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9A6198E00D4
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 18:51:12 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id b4so316269plb.9
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 15:51:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=QccAqP9ksTYPDqnzYjlcAcLDZYYNNkUf8Gwz8DkOtZc=;
        b=nHwLgKvX6c4h38m98FK14jAJuZgRL8xJmVJkAExjeRNsOiJdGKBeiYRIJciqnMl3WH
         2fbz3JhI/4WYtnwNoIOiETf0fenc6+mUQDkYWNudybVbftwBBOqh/MtnIGCm0+CE6bfa
         pYV4w4dtJAWYrybBqEIuYXLBvWsHozQXLMsVk6t71D0me+CzZRYclGXrRWM2ecugPfgD
         B03bV4i4SrRzSOu1eyvumz012uw8jgW8CiInM/3lUpzgf7lmJ+ZgoB/2GJUlDdYd5Ulv
         kWQuj3btXtSmGEnS/TqntpvbhCKv2ed2mn94Lkc82BwR7e5wZMQYGTGNRdw/koCFwODa
         5x0A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZcF0GG2hF4K5uy2+PSAYaQb7lEc/lWk6AthMyjGKcO0pQAfNlc
	+kDhVviAozEJvfzZuYJbZnZysAfPSZhkXEfDpVYfLwChGlBJJICbUUYZjhbWXP9J8962Jg7iWSW
	Kl1UjXFVkzsEI/qYN+BEEz+FESPXrCaC7gc0gTlxvKDVCQ1f79BP99q+t5qe2iogWsQ==
X-Received: by 2002:a62:f51d:: with SMTP id n29mr1133364pfh.21.1550793072296;
        Thu, 21 Feb 2019 15:51:12 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZU+N4zo+AyvPZY4MPxsLe9ed/LWrubWi8OmtUHyCwINETYAhJ4Tfi62Avb8ieM7W9MbN1y
X-Received: by 2002:a62:f51d:: with SMTP id n29mr1133312pfh.21.1550793071080;
        Thu, 21 Feb 2019 15:51:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550793071; cv=none;
        d=google.com; s=arc-20160816;
        b=x6r/N5Iq9SFLQ3KR8UxH9HErwbT/XreLDA3ty4gYaXFitOr4w5w8BxHkKPevdd84zE
         w7TIS2zarGibR9UxsDN+rm/A00cW8F8O5jApVIZVDyd9ki7QAjSAbhAHCG9HtzWQOYAQ
         9XoYzCsWq29j5wOWz67I089ZOF/0Xm9dfE12dS0zWhVYHA6nLzGekBakNZRp2D3kEEnK
         9JRJVaw38uMNgnrFsf/NIqmeU5LngncLSYIMSZ8kNwg9frGMMbP75dw4qb/tZNXwm6vQ
         JyL+xcFhx1w2qRf6hsm9OEVSv0W+55aIprf89ca+i95+F3zJGhjgzg8IqRfSGANcg3AV
         xaYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=QccAqP9ksTYPDqnzYjlcAcLDZYYNNkUf8Gwz8DkOtZc=;
        b=aXYd8KRyUZ9j97ZYafMca/vBzXS3R74BEkdhBwgY2NbYDOVkSTeOswnyR8H3Tomm+j
         5Ke7gRBulkowv5Qnq59eS3C7dZW+9HUNIG4w1TQxsmQeir+78zUaRSyRJivT6jZ6U4La
         EWCbOLWT+96gJGR8Wfe+Ja+naooU2+xcgvAQnlfbA7pU5otafmkpuq7uWgQK85UQ+kOj
         39FGI4wEnY5j5pv1dp8UWxhqFzJRvDfGnEB0K4Q00pm7UnhD+dQIALoNGAACbMZ3LmPq
         77Wzpt4LkCErttb8KXGSfXcIu2VO7JVQSkuS/DMmQk04MdN9kar4uM7opw44AdKFGhMj
         qbfw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id c4si238494pfn.83.2019.02.21.15.51.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 15:51:11 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 Feb 2019 15:51:10 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,397,1544515200"; 
   d="scan'208";a="322394958"
Received: from linksys13920.jf.intel.com (HELO rpedgeco-DESK5.jf.intel.com) ([10.54.75.11])
  by fmsmga005.fm.intel.com with ESMTP; 21 Feb 2019 15:51:09 -0800
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
To: Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Borislav Petkov <bp@alien8.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org,
	will.deacon@arm.com,
	ard.biesheuvel@linaro.org,
	kristen@linux.intel.com,
	deneen.t.dock@intel.com,
	Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Steven Rostedt <rostedt@goodmis.org>
Subject: [PATCH v3 18/20] x86/ftrace: Use vmalloc special flag
Date: Thu, 21 Feb 2019 15:44:49 -0800
Message-Id: <20190221234451.17632-19-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
References: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Use new flag VM_FLUSH_RESET_PERMS for handling freeing of special
permissioned memory in vmalloc and remove places where memory was set NX
and RW before freeing which is no longer needed.

Cc: Steven Rostedt <rostedt@goodmis.org>
Acked-by: Steven Rostedt (VMware) <rostedt@goodmis.org>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/kernel/ftrace.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/arch/x86/kernel/ftrace.c b/arch/x86/kernel/ftrace.c
index 13c8249b197f..93efe3955333 100644
--- a/arch/x86/kernel/ftrace.c
+++ b/arch/x86/kernel/ftrace.c
@@ -692,10 +692,6 @@ static inline void *alloc_tramp(unsigned long size)
 }
 static inline void tramp_free(void *tramp, int size)
 {
-	int npages = PAGE_ALIGN(size) >> PAGE_SHIFT;
-
-	set_memory_nx((unsigned long)tramp, npages);
-	set_memory_rw((unsigned long)tramp, npages);
 	module_memfree(tramp);
 }
 #else
@@ -820,6 +816,8 @@ create_trampoline(struct ftrace_ops *ops, unsigned int *tramp_size)
 	/* ALLOC_TRAMP flags lets us know we created it */
 	ops->flags |= FTRACE_OPS_FL_ALLOC_TRAMP;
 
+	set_vm_flush_reset_perms(trampoline);
+
 	/*
 	 * Module allocation needs to be completed by making the page
 	 * executable. The page is still writable, which is a security hazard,
-- 
2.17.1

