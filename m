Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8EA0C3E8A4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:39:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A88442184D
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:39:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A88442184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 825398E0001; Mon, 28 Jan 2019 19:39:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6DB408E0007; Mon, 28 Jan 2019 19:39:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 44B218E0003; Mon, 28 Jan 2019 19:39:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id EC1378E0004
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 19:39:13 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id d71so12729829pgc.1
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 16:39:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=OWv/u9lyuaHGR/jx5Ggc4M68NwrNRo7DfonKYg1/6LY=;
        b=GHT1SOnCwAtYwH25RqxuxjimhCDvSDnjUF/zPhcsfvtIuFLghmPG51SIQ4hVk4Y3cp
         5Gt9lj8omFIdPPtPi8rN5yq8RR8pz5u0IYHZMQuCLzrCTzgElwpvgImGcQK6WfpR2hVD
         oRfieGf7U7SyCZFim0I0so3zpCN2FSEJTiRkLe+xhsMub6fc5chhOf2MHYMamVBNAESY
         SSodLMyxfMMVDVWADXoJA+a70/1S16bB1US9w0VtkfsuPMLRdlPinhjlwipmHDEPfJBP
         lg0bk7Ulc3E9Bhs6C37VKRZNkeIvVODZ+o2jgJ2GpS1DeCc2TXHE1+AsIxDzoHAbsgPV
         MqDg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukfkgn0vvH+WwOtcC4TtU/eMyVC0bmy0Ep6XYkxQGbmFvf8TBRdq
	jb3c/ZSCSiHmR80ynbT3WKsuBDlfk8qf/6qWr7B5vVQrPT0EwElxnKgolIVoCxNiRHEYLHnaQW5
	940UygOOW1eC5SM3ycyvqKwCxo9H6Isa0CeagkyrUl+qyqEMjk5WM5t85J6zQIKp7bQ==
X-Received: by 2002:a63:4f5e:: with SMTP id p30mr21728829pgl.71.1548722353605;
        Mon, 28 Jan 2019 16:39:13 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6lko/xhaZY9OYbdcZKFE56eITyhdxBCGKpnEIem9qX3uRZKonKTj2L5wECPwV2PQsBrczc
X-Received: by 2002:a63:4f5e:: with SMTP id p30mr21728799pgl.71.1548722352789;
        Mon, 28 Jan 2019 16:39:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548722352; cv=none;
        d=google.com; s=arc-20160816;
        b=NWHSSNxcDk42X3BOPc29GC9eluHP1qaZft108aGod7hmO7C+/XdNNYS3y0dj31jbWB
         PByd1Nxc1mW+NNp9uS04HlT90sjZBjiYjd+h6s2MekRH5RegbEzf0N6o2Z/UaZ/V+K5e
         AJZ3a+ibfEsPY64PKN3SEdqW/yJfOf/pDINlEOhGl6eEs3xWs+uMdljlhfuU+UA13Pz8
         ww4LzQ34THfzN5BvWnWdCpvS+mM1QV48uOa6x+Em+aR8nNcw0cfqWe6B1PkysGwfMHPq
         Z1bPg2clv4vJv2MQz+GhemFnUGEsUDPMYZ1r8Ek9rvU0kXKssABa55ri2HtLPfHYShAQ
         1REg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=OWv/u9lyuaHGR/jx5Ggc4M68NwrNRo7DfonKYg1/6LY=;
        b=kMiMYlyF4OoU2H2er+COlUxTzkH2G6fAQoOHCwuoBlTB0mTHWTIrv16pyolDto0j1j
         YariuUGvs1c9yP4yXgphuMwukel9CSLkZkM7V05pvTGdYxc3dDrhg/YxpNNuppNVVqRs
         zBzMd2u7SwjCYhmGvLSOQ+WIng4m9N7YdpvObtKqk+RVt6OAjZPAX7ITEHrrrE5T2UVd
         YNO0a2G3lFQzPvhUYRnTaBTEU9iCmAYa26BfQ+cNJ/lrwNb9If88VoYmQ/fCbTX0cLrA
         a3xE2OM81/fJvA43KPndWFMmecgOP5hF+iBI6TXINJ/CXqXgtqRu3YKleJkYO6QJDZ3m
         OHJw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id i9si7660357plb.35.2019.01.28.16.39.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 16:39:12 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Jan 2019 16:39:12 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,535,1539673200"; 
   d="scan'208";a="133921909"
Received: from rpedgeco-desk5.jf.intel.com ([10.54.75.79])
  by orsmga001.jf.intel.com with ESMTP; 28 Jan 2019 16:39:11 -0800
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
Subject: [PATCH v2 09/20] x86/kprobes: instruction pages initialization enhancements
Date: Mon, 28 Jan 2019 16:34:11 -0800
Message-Id: <20190129003422.9328-10-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

Make kprobes instruction pages read-only (and executable) after they are
set to prevent them from mistaken or malicious modifications.

This is a preparatory patch for a following patch that makes module
allocated pages non-executable and sets the page as executable after
allocation.

While at it, do some small cleanup of what appears to be unnecessary
masking.

Acked-by: Masami Hiramatsu <mhiramat@kernel.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/kernel/kprobes/core.c | 24 ++++++++++++++++++++----
 1 file changed, 20 insertions(+), 4 deletions(-)

diff --git a/arch/x86/kernel/kprobes/core.c b/arch/x86/kernel/kprobes/core.c
index 4ba75afba527..fac692e36833 100644
--- a/arch/x86/kernel/kprobes/core.c
+++ b/arch/x86/kernel/kprobes/core.c
@@ -431,8 +431,20 @@ void *alloc_insn_page(void)
 	void *page;
 
 	page = module_alloc(PAGE_SIZE);
-	if (page)
-		set_memory_ro((unsigned long)page & PAGE_MASK, 1);
+	if (page == NULL)
+		return NULL;
+
+	/*
+	 * First make the page read-only, and then only then make it executable
+	 * to prevent it from being W+X in between.
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
+	 * First make the page non-executable, and then only then make it
+	 * writable to prevent it from being W+X in between.
+	 */
+	set_memory_nx((unsigned long)page, 1);
+	set_memory_rw((unsigned long)page, 1);
 	module_memfree(page);
 }
 
-- 
2.17.1

