Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83DBAC4321A
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:32:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 477AF20B7C
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:32:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 477AF20B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 53FB26B026C; Fri, 26 Apr 2019 03:31:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 064986B026E; Fri, 26 Apr 2019 03:31:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D03B56B0007; Fri, 26 Apr 2019 03:31:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 27D9B6B026C
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 03:31:49 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 33so1491047pgv.17
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:31:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=MM86D2MJFg2ajXMn2L8v3GMZHyeRYJVGp1yjvaMMFQk=;
        b=ge19kVNuSFKbnlrZD3nKcaQrN+zI+lUtdwiepaVDq9E8yf14HNC1sDYVtCM/N0Jxi4
         PAb8msrts6fxqXPWDC0oAAjVqZYJHkXh3cSEHypKOw9dQktUxc/lQSZyC+VaO6uLq6f3
         CsKCsdKh8Wa1pzM9VGCdaGX0eUhAIIe+QeaULIuJrXgoqP+8m1kQolJK6FCBnHFRPhRk
         QAEiIRuN4Z6x9tqVBe3lalU8JBeyY6NVaB2gRd22W/X9A43d72slOIcC0fxzluqyRj7N
         aGjTAdaLpKoYYI/7+ehBMnBzcicsN4uJkJ4FRPTF6uU2p9HuMxdDOVc7W1bvWGpaQV8l
         11tw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAUqX4CMXRznn2cHITvHJ2eFsjEeQNW2VLVw0XgpGxl9PRptWkFr
	2C/YsNiJo650/rtbwfQChEGM1ekdrenafrKZYs5L/VyD3zmXKYMpkG555PK3LQ8xq9E/TOWZVKZ
	h6uPWZx81JehA3yDuq6Pq1mb/IiA/kmXoZKULyfUcn9Bts5FwHWIK/m3gic4HAjYnkw==
X-Received: by 2002:a63:cc0d:: with SMTP id x13mr41943541pgf.280.1556263908821;
        Fri, 26 Apr 2019 00:31:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwzAvntBPuqxEuZGkc97mHX+Mpe3DWsl5erVfwPmpCp8yBLbB9W7eTcAYiCS1ylrxDxyoBX
X-Received: by 2002:a63:cc0d:: with SMTP id x13mr41943460pgf.280.1556263907568;
        Fri, 26 Apr 2019 00:31:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556263907; cv=none;
        d=google.com; s=arc-20160816;
        b=rGwsTjz0RPXIGxonc+0CeTt8cO6lpcCGtU438yPWhR3Mpm7atDBf/uBC42Faw+6HX3
         x+RhpVOBCPhTvH/ayc0x8ZVLk9MbxyNgZQahQCDHfNPTec01CGmnoPPwDpByBpqu4daL
         7dQmTV8z9aiGdF3O70LAuxRo8NRqDGNhc/qRhGe4FL07ZGVCmc+cTTcKm/ZUJ8GhdFLg
         0CZoc61zpTxqrfJOuukjDiq8bgGo2yG2fKPgnvQvf3gcsC1vSYb+NmrbXCqn1pYvC0Xw
         J0LfBusI7jpoxMdtIdDLHNgshQsi2Hz0FCCPDT03g4iTcfG3DNEcJ2NP3kpord5ZITER
         CBLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=MM86D2MJFg2ajXMn2L8v3GMZHyeRYJVGp1yjvaMMFQk=;
        b=IjjH7rR6QKoPCNQxHAZ024O2Nrt1L73kf6PRmeFctmm3L0rwkqR3lkh/RkcPh36f1q
         3xjMGCklvi2yeHBz1oxnT7t3JEKl1S3aVgwyU7Ixgfl9bngGj+WiV9642hO4833wh+OW
         GgV1lmaWWr6TfgZI7U4tyQO3ZJfNmlnWhYJjrXYLc7s5U5TT7rozhUwcATZemdeCOz/l
         CVzpX7j9b1a1N9CQ44DlRkfTTfDn5U1PekGDISmzQl/oOiV0ZFoGuFOmIWkidha6gWFa
         QtpvwAbC+hJ/Zmx1edh0IOp2lC0hFyzV+JEp293AMdBPBdpbHDveUTA8gTJzy9ZHFkhh
         lkdA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-002.vmware.com (ex13-edg-ou-002.vmware.com. [208.91.0.190])
        by mx.google.com with ESMTPS id f9si22844507pgq.347.2019.04.26.00.31.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 26 Apr 2019 00:31:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) client-ip=208.91.0.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost3.vmware.com (10.113.161.73) by
 EX13-EDG-OU-002.vmware.com (10.113.208.156) with Microsoft SMTP Server id
 15.0.1156.6; Fri, 26 Apr 2019 00:31:44 -0700
Received: from sc2-haas01-esx0118.eng.vmware.com (sc2-haas01-esx0118.eng.vmware.com [10.172.44.118])
	by sc9-mailhost3.vmware.com (Postfix) with ESMTP id B36F4412A2;
	Fri, 26 Apr 2019 00:31:45 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
To: Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>
CC: <linux-kernel@vger.kernel.org>, <x86@kernel.org>, <hpa@zytor.com>, Thomas
 Gleixner <tglx@linutronix.de>, Nadav Amit <nadav.amit@gmail.com>, Dave Hansen
	<dave.hansen@linux.intel.com>, <linux_dti@icloud.com>,
	<linux-integrity@vger.kernel.org>, <linux-security-module@vger.kernel.org>,
	<akpm@linux-foundation.org>, <kernel-hardening@lists.openwall.com>,
	<linux-mm@kvack.org>, <will.deacon@arm.com>, <ard.biesheuvel@linaro.org>,
	<kristen@linux.intel.com>, <deneen.t.dock@intel.com>, Rick Edgecombe
	<rick.p.edgecombe@intel.com>, Nadav Amit <namit@vmware.com>
Subject: [PATCH v5 10/23] x86/kprobes: Set instruction page as executable
Date: Thu, 25 Apr 2019 17:11:30 -0700
Message-ID: <20190426001143.4983-11-namit@vmware.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190426001143.4983-1-namit@vmware.com>
References: <20190426001143.4983-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain
Received-SPF: None (EX13-EDG-OU-002.vmware.com: namit@vmware.com does not
 designate permitted sender hosts)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Set the page as executable after allocation.  This patch is a
preparatory patch for a following patch that makes module allocated
pages non-executable.

While at it, do some small cleanup of what appears to be unnecessary
masking.

Acked-by: Masami Hiramatsu <mhiramat@kernel.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/kernel/kprobes/core.c | 24 ++++++++++++++++++++----
 1 file changed, 20 insertions(+), 4 deletions(-)

diff --git a/arch/x86/kernel/kprobes/core.c b/arch/x86/kernel/kprobes/core.c
index a034cb808e7e..1591852d3ac4 100644
--- a/arch/x86/kernel/kprobes/core.c
+++ b/arch/x86/kernel/kprobes/core.c
@@ -431,8 +431,20 @@ void *alloc_insn_page(void)
 	void *page;
 
 	page = module_alloc(PAGE_SIZE);
-	if (page)
-		set_memory_ro((unsigned long)page & PAGE_MASK, 1);
+	if (!page)
+		return NULL;
+
+	/*
+	 * First make the page read-only, and only then make it executable to
+	 * prevent it from being W+X in between.
+	 */
+	set_memory_ro((unsigned long)page, 1);
+
+	/*
+	 * TODO: Once additional kernel code protection mechanisms are set, ensure
+	 * that the page was not maliciously altered and it is still zeroed.
+	 */
+	set_memory_x((unsigned long)page, 1);
 
 	return page;
 }
@@ -440,8 +452,12 @@ void *alloc_insn_page(void)
 /* Recover page to RW mode before releasing it */
 void free_insn_page(void *page)
 {
-	set_memory_nx((unsigned long)page & PAGE_MASK, 1);
-	set_memory_rw((unsigned long)page & PAGE_MASK, 1);
+	/*
+	 * First make the page non-executable, and only then make it writable to
+	 * prevent it from being W+X in between.
+	 */
+	set_memory_nx((unsigned long)page, 1);
+	set_memory_rw((unsigned long)page, 1);
 	module_memfree(page);
 }
 
-- 
2.17.1

