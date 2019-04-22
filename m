Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00902C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 18:59:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ABD4F2064A
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 18:59:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ABD4F2064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 86CA86B0271; Mon, 22 Apr 2019 14:58:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 75B216B026E; Mon, 22 Apr 2019 14:58:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E36C6B0271; Mon, 22 Apr 2019 14:58:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id DDEFE6B026E
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 14:58:54 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 132so8436601pgc.18
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 11:58:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=3mFI7V2IpbwOhuCcp+g9CO2dE2meFXsvyyAeb18NWyo=;
        b=fnzdWan1Z5sBJvBF44Yi6VVgB1VudELxIMBtHaQOvnu5WeJUBrFjTPmAL16/CJDDWW
         gI7TyCI/nv49kzLVCWZlYS2EJDzlW5ZjpI/Zn+UR0huwlcR3+7Rt/wY3JXGyAR7gepsk
         qjuTf/6i3sJYyOi/p3v4a0F/7Pi5jXTFdrKfIPgCBXeitOFLu9wI+QVYuqYVIeF9QmyW
         MZ7V6ZXCzd7s/e/Ua4n62uMIxIxF73vctdotWhJMrxsGsnQ6jpFWndds6QB0f/Afc9YR
         UtoJe3N+v8nqglPZZkMRJ5ZA6MdLzpHVGw4N8szYuG9HYCNrNsgKMv37HO0ulHg1qlwU
         cvTQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVeuzOofa6d6XE5xMlzhfLtRqjt6ooQaIy/bzeFtbuRQaRKvAvn
	8jhouz3hBAfDGVnSpSC4if6m9pB+inVQ76a7kAczKr6tIbzA1zUSiplLF5Sxby1jYod+4gZvFN1
	samxh6BrnikDgsryxdq9lKQgio5vyM9ayhlXx6+dEjUhLCF55L9HB2hOMhpSXKTS8Hw==
X-Received: by 2002:a63:3281:: with SMTP id y123mr20452289pgy.272.1555959534517;
        Mon, 22 Apr 2019 11:58:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqygQWToNVYgEOHPy2ZS9ereJqkOFwCvtNhHZ3h+9+8saUbuz+HKI2reMQVulZ3SgMWB8h4A
X-Received: by 2002:a63:3281:: with SMTP id y123mr20451661pgy.272.1555959523359;
        Mon, 22 Apr 2019 11:58:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555959523; cv=none;
        d=google.com; s=arc-20160816;
        b=k/BgZ+PD/RpyuAd6ziaISb7wk7hzWL/ttc8KwLGlyu0H3qpFvVkfw2/ADrUGIXpBlE
         e+efm1LVx2EwhM+azY/LGEE7VZmK5qlTggHM8bUaxMBXVpw8waMSauTAkFDNmFNbAZKN
         6emqfw3UfkTIE+eF38x7w10edH3/IUla1nEIHhkZ95s6KVSZPBfcV2s98I0TYlCuxBZ5
         CGe9QUyegqk6+iI1x5gA84melXn14WDkMj7EVV+p6y4H7igQnBcFireKVNd/Fo67iBxL
         C9ErWgvEXG1IKKwz+yTcorBlOZZQVgIfaRIGg31ElHHzK4Z32gONrvSPqtxkvp1spmvu
         DVAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=3mFI7V2IpbwOhuCcp+g9CO2dE2meFXsvyyAeb18NWyo=;
        b=TJbIhnwQTpc3a+wbTeNixsIhlPM+RbYjke6hAX7/YAhpVhhVmGmwAbJaqWEC3FSc2G
         Xl0Utwwox2y7HOK4PDW1Luw3p76ckLR0TihC8LWMJfK0e9FljIuYhyy3VKDaEYl26ihK
         uWxXA8LoLwJY1H+I2SC0fSw7VuWIBfTM5G+7MvlWZlnodmoQjajmzxNHDVONXHvfBWaa
         7ogbh1xrT0b87AErJDbHpmaDcFhSPIs/cP4y0xcHQKpasrnRPYHjQ6uly/toENLZgJAu
         G5n6hiQo7mDm2vjGl+DhPjLmZr0ywmSLRK3c/4sxwP8i/05gJ22OzoS4r9volYmk4o8A
         5U5g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id a20si5314305pgb.421.2019.04.22.11.58.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 11:58:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Apr 2019 11:58:41 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,382,1549958400"; 
   d="scan'208";a="136417140"
Received: from linksys13920.jf.intel.com (HELO rpedgeco-DESK5.jf.intel.com) ([10.54.75.11])
  by orsmga008.jf.intel.com with ESMTP; 22 Apr 2019 11:58:41 -0700
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
To: Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
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
Subject: [PATCH v4 08/23] x86/kgdb: Avoid redundant comparison of patched code
Date: Mon, 22 Apr 2019 11:57:50 -0700
Message-Id: <20190422185805.1169-9-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
References: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

text_poke() already ensures that the written value is the correct one
and fails if that is not the case. There is no need for an additional
comparison. Remove it.

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/kernel/kgdb.c | 14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/arch/x86/kernel/kgdb.c b/arch/x86/kernel/kgdb.c
index 2b203ee5b879..13b13311b792 100644
--- a/arch/x86/kernel/kgdb.c
+++ b/arch/x86/kernel/kgdb.c
@@ -747,7 +747,6 @@ void kgdb_arch_set_pc(struct pt_regs *regs, unsigned long ip)
 int kgdb_arch_set_breakpoint(struct kgdb_bkpt *bpt)
 {
 	int err;
-	char opc[BREAK_INSTR_SIZE];
 
 	bpt->type = BP_BREAKPOINT;
 	err = probe_kernel_read(bpt->saved_instr, (char *)bpt->bpt_addr,
@@ -766,11 +765,6 @@ int kgdb_arch_set_breakpoint(struct kgdb_bkpt *bpt)
 		return -EBUSY;
 	text_poke_kgdb((void *)bpt->bpt_addr, arch_kgdb_ops.gdb_bpt_instr,
 		       BREAK_INSTR_SIZE);
-	err = probe_kernel_read(opc, (char *)bpt->bpt_addr, BREAK_INSTR_SIZE);
-	if (err)
-		return err;
-	if (memcmp(opc, arch_kgdb_ops.gdb_bpt_instr, BREAK_INSTR_SIZE))
-		return -EINVAL;
 	bpt->type = BP_POKE_BREAKPOINT;
 
 	return err;
@@ -778,9 +772,6 @@ int kgdb_arch_set_breakpoint(struct kgdb_bkpt *bpt)
 
 int kgdb_arch_remove_breakpoint(struct kgdb_bkpt *bpt)
 {
-	int err;
-	char opc[BREAK_INSTR_SIZE];
-
 	if (bpt->type != BP_POKE_BREAKPOINT)
 		goto knl_write;
 	/*
@@ -791,10 +782,7 @@ int kgdb_arch_remove_breakpoint(struct kgdb_bkpt *bpt)
 		goto knl_write;
 	text_poke_kgdb((void *)bpt->bpt_addr, bpt->saved_instr,
 		       BREAK_INSTR_SIZE);
-	err = probe_kernel_read(opc, (char *)bpt->bpt_addr, BREAK_INSTR_SIZE);
-	if (err || memcmp(opc, bpt->saved_instr, BREAK_INSTR_SIZE))
-		goto knl_write;
-	return err;
+	return 0;
 
 knl_write:
 	return probe_kernel_write((char *)bpt->bpt_addr,
-- 
2.17.1

