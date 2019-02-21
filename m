Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36462C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:51:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E838420818
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:51:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E838420818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8EE1F8E00B5; Thu, 21 Feb 2019 18:51:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 872388E00CD; Thu, 21 Feb 2019 18:51:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 78C238E00B5; Thu, 21 Feb 2019 18:51:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 371998E00CD
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 18:51:03 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id o67so313706pfa.20
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 15:51:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=3G8hdtdnz6A4RGh5p5LJ2XCAn2wTvpUmINy+UI0phGA=;
        b=TWdRv2dLceYFqmzfPIpAAjvt0yjTrujvvJceCM/B5ZYvbgjG+suaWVTuTB/bJ6vrYN
         EXt0AFNqNKcUR7j2JlckmAJd6+n2xcvLMvXmjM5HZcVcpCrYEVegcsEs2FEUZUxgIenl
         ha3vfhpn9GHzM+1O1qu8t4WlUU90YEHNSatA7Q/PxuwLOw9rnDh10eLWDqGxmg5GcepT
         ep7JMiCHDzcBdjaUFfpM9N4aYq55Dz1wgxpDc10dfoxnFUCe30LnhO6CyBq3HuN/bpDN
         OCr34NWUXQwsgbbd3HfAsCg4PieX2zBVZscFOKrPHw9k9eGXRxdu8cLpbbcB3eESj7Bz
         cM6g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuaoELtUW8a/Fp/9cCLfpEkSF8y+/kCN+N9Sf32oRq+lREQ/0LG9
	xuDf6IjyRZmNvK7p+cxKk9YsSlfrCBesH+mSbwj2dlEBSM2ydAxaz5sKiRBJ7vD4VXXSoIaTZZQ
	ulFbtDqZsKEX1NUt4bHz+Z8uVKbbM72UKztpihZ26Ca3Os+JbuJzX5viVIAMmNOgLBA==
X-Received: by 2002:a63:cf01:: with SMTP id j1mr1076303pgg.342.1550793062887;
        Thu, 21 Feb 2019 15:51:02 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYrwJja9IeGg3jIRfbsQEviRqy255Ilib6t5yAWInYpd7qvnpxA3tYQmb1E9SosmdfjR8WD
X-Received: by 2002:a63:cf01:: with SMTP id j1mr1076279pgg.342.1550793062212;
        Thu, 21 Feb 2019 15:51:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550793062; cv=none;
        d=google.com; s=arc-20160816;
        b=lUg9IIzzcVI6NafLALPr2Y1BlLVTjoA+Ftcv0GVVAnARtt15MASuo3s1Wm/U2e9c/0
         pr/MkE/dGHrJqMkca94QLMMSbB2J2cXAjbHStKxdkpAEktXlHDzbN/qM4jBgXLt3j6kN
         6ZlScDNh6nEyLYTiDOUyYupmUvS0Bu2yKmc70ajXxXPZQCmBlcVWnXcZM60e7+xeXD8u
         ZOq6/W9UhUQJUoNqLuvIigwZOuHv5dIYyRs/beKZ8j5CsSPzbfT28uRkYx3KqxQkBdqC
         1PkKlp0gQ/b7IFl6bK0nZ8Wy7H/MwpEiaeAa5577s+uCuRHpSO+IHfmJMpd9JI3rVZ3f
         6O8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=3G8hdtdnz6A4RGh5p5LJ2XCAn2wTvpUmINy+UI0phGA=;
        b=gTOIlaioUm4rOFSU+TaKs35O4tJtmBfjgsWvqb1PD8RoRr/icyTC0UGZFCrpe+jqkT
         orr3C1GIUcrRLe1tUyd+iT4nURxI3T6rYO1n3qdTgA2aWkl+XGE5huIximirEtV0irZl
         k2f0WjDpkTyAw+UfcXXSRwkYWlx4JjgeooiOt/txSKfQdtYVeLk2aMXlyJ0cDdAl/gmM
         UurVlOsy0hFA/HVl7tRrpCLvhGBx/0qdPUYgHjlRLVWbZGnPuSBv0IiHBBQJ0dGLJeWG
         v1GOkWGRZrx4eueVtiwyVUG0Cs6r9n6RnZhmGMxxOnb3lBcIUdbJ1OJEToH/cLH2FbJ7
         Hyqw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id c4si238494pfn.83.2019.02.21.15.51.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 15:51:02 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 Feb 2019 15:51:01 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,397,1544515200"; 
   d="scan'208";a="322394901"
Received: from linksys13920.jf.intel.com (HELO rpedgeco-DESK5.jf.intel.com) ([10.54.75.11])
  by fmsmga005.fm.intel.com with ESMTP; 21 Feb 2019 15:51:00 -0800
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
	Nadav Amit <namit@vmware.com>,
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v3 09/20] x86/kprobes: Set instruction page as executable
Date: Thu, 21 Feb 2019 15:44:40 -0800
Message-Id: <20190221234451.17632-10-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
References: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

This patch is a preparatory patch for a following patch that makes
module allocated pages non-executable. The patch sets the page as
executable after allocation.

While at it, do some small cleanup of what appears to be unnecessary
masking.

Acked-by: Masami Hiramatsu <mhiramat@kernel.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/kernel/kprobes/core.c | 24 ++++++++++++++++++++----
 1 file changed, 20 insertions(+), 4 deletions(-)

diff --git a/arch/x86/kernel/kprobes/core.c b/arch/x86/kernel/kprobes/core.c
index 4ba75afba527..98c671e89889 100644
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

