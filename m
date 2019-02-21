Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA8D1C00319
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:51:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A12C720818
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:51:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A12C720818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C5558E00D7; Thu, 21 Feb 2019 18:51:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 686E58E00D4; Thu, 21 Feb 2019 18:51:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 517F18E00D4; Thu, 21 Feb 2019 18:51:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1380E8E00D7
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 18:51:13 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id e5so317773pgc.16
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 15:51:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=twme+qjq33jZ13XlnvG7AH24qCU88X9Kbd4vP+8UtMM=;
        b=jkjOW7PuA7kEOZIyp1Gp5zgjQvaJdpFUXnf7M3tUVt7zpXc/2YrN5IEWR8bKW5ARUd
         pAAYpd37fNyh5Z5qBn8NAUUG01uwI8hi1F4eCBqc9Kw2d1aOoko+HaVziTDrz1LOo3Wm
         ceU8I1L25q6k1Et6n0m0bxsmOcxzLRKSZS/Gh3cJZa1cj79LRfoVe80bcOsHcbmf2mYv
         whS8Pxnwsx2ALMEGWHX+u2mvWl0qTckFEzPi1awVH7bT6xoE2J3+YiRlHLq9UtCzG9if
         84o7ra7JmV4p8tfuFzLQ1JcdEhujuSos7bJTOHkdeI/8aOgEImPzidkt0TaTJkJ0RZS8
         iZmQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuYky4wvv96Ovr+m35lLYgaviKMSSt/6wMaMOgbXTULBcIvjlYWb
	OIX6u+lIxlroX7W23XlCXnyGmL6xbL9DuNI3DFa8Ah+lLV1QjlujYJZrU+gI/ZeKdGlrq5AuR2T
	MAqhPoRtMekf2oGQ0Dd5rH7/bYAWjfdoc/TcTWPaLIi9dmgcMkUhg+DI+Z7wJrzFRdA==
X-Received: by 2002:a17:902:22a:: with SMTP id 39mr1165244plc.153.1550793072747;
        Thu, 21 Feb 2019 15:51:12 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibpo/e/BOv/b9u2I/sWFfsKnNdZ2w17bAMSK6+hSXNn6ZU9OBTFIuf1fKRK31r4wfU1g4Ok
X-Received: by 2002:a17:902:22a:: with SMTP id 39mr1165213plc.153.1550793072043;
        Thu, 21 Feb 2019 15:51:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550793072; cv=none;
        d=google.com; s=arc-20160816;
        b=s68qqi6et1GOSTdhMVXRtbJLClJJ8gcA9xFoOZ5HK88A7gzhn/kxt7PctpudzW9Scq
         7cJj3FAhhddJvXKJpwkwQ7eRF47+5s2P6Yfg3hPWfpFo12yK3Fj8bfL9H+XEtSNaYTqh
         9kc4UyX4rJW30LB3kLJ3cDAsSlXiKS0TYtNSViF6oMMJ/61WxGU6YPUYOxdUDPo6a8T9
         MSU/FIiDjjNJK7P3lpg26C5US8FZV2oeLtK5BcR9CimEkgnBUIwCo7M/EBWyNuch6CPi
         sWn1Nju02m00IyGzpYukPGgSSXpjJLjC0aKiIKfAfwIpWx4C4m3f3unUdNClq2+y/nQ5
         h8mw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=twme+qjq33jZ13XlnvG7AH24qCU88X9Kbd4vP+8UtMM=;
        b=IC/sokXqB6InHv2ZQWuMKi7tPcmCAHGmc1wmrq4knvxsZc7EhgzOY9fFGslquhGf8C
         3+KUYjl7nte1ooaz9/IBfwFS6OhIWvo3VuPwphBYqKc4OsuCwcoKifIFmdtlUARjT4Ib
         3R+yxPf33mdV+1I4sQhNpYmaTGWrvImKjohFyjov1Bsa/q423lpgGm+Dq1yr8fmngrCA
         I9l+S6Kdswl1GTKaJKlsiQyI+bLznA0GlSf1okI6J8cQGCsudfjlnL5Q3675lqzf1HM3
         3eqnGr1S7B5RROw7qaOIWv9jNBbiT36vASOLYHZ9+JBPBHkQ35+pzikZmIj9LSgbevQJ
         EPaw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id c4si238494pfn.83.2019.02.21.15.51.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 15:51:12 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 Feb 2019 15:51:11 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,397,1544515200"; 
   d="scan'208";a="322394963"
Received: from linksys13920.jf.intel.com (HELO rpedgeco-DESK5.jf.intel.com) ([10.54.75.11])
  by fmsmga005.fm.intel.com with ESMTP; 21 Feb 2019 15:51:10 -0800
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
	Masami Hiramatsu <mhiramat@kernel.org>
Subject: [PATCH v3 19/20] x86/kprobes: Use vmalloc special flag
Date: Thu, 21 Feb 2019 15:44:50 -0800
Message-Id: <20190221234451.17632-20-rick.p.edgecombe@intel.com>
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

Cc: Masami Hiramatsu <mhiramat@kernel.org>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/kernel/kprobes/core.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/arch/x86/kernel/kprobes/core.c b/arch/x86/kernel/kprobes/core.c
index 98c671e89889..8b56935d7b53 100644
--- a/arch/x86/kernel/kprobes/core.c
+++ b/arch/x86/kernel/kprobes/core.c
@@ -434,6 +434,7 @@ void *alloc_insn_page(void)
 	if (!page)
 		return NULL;
 
+	set_vm_flush_reset_perms(page);
 	/*
 	 * First make the page read-only, and only then make it executable to
 	 * prevent it from being W+X in between.
@@ -452,12 +453,6 @@ void *alloc_insn_page(void)
 /* Recover page to RW mode before releasing it */
 void free_insn_page(void *page)
 {
-	/*
-	 * First make the page non-executable, and only then make it writable to
-	 * prevent it from being W+X in between.
-	 */
-	set_memory_nx((unsigned long)page, 1);
-	set_memory_rw((unsigned long)page, 1);
 	module_memfree(page);
 }
 
-- 
2.17.1

