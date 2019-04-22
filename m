Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54F4FC10F11
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 18:59:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 07493218B0
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 18:59:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 07493218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B79116B0266; Mon, 22 Apr 2019 14:58:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6917B6B0010; Mon, 22 Apr 2019 14:58:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 257AF6B0010; Mon, 22 Apr 2019 14:58:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id B39A86B0269
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 14:58:44 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id n5so8474522pgk.9
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 11:58:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=CLKl6NZzJuOK2yM4IgvyVy0XzBWA5gDBiZYSHfLNQ00=;
        b=Ruja2QPURe+6IsigPi7rLyBcR7+r8uh+jczLnLnviBCfHeJq5aMP9CW8+JiS4glaeU
         iXZkAQb2gwYvqLUD4kth30Ai2KLGbds7n1CTeevEsYI/1ST4lqNLU+Wo77bux25AQCTl
         QqID8h8KJ4pvyrSlKkQnrRYhJoDEUPJBmsp8Vs21RkiJ0NXL9ojAjHoHEBsZLVN4Rszo
         zSUwxlgjC8psIk7iZBVfjavJYGx/gTjIA0X/O9xqh25uU45oGY51dP6LHxgFfJSLvyMr
         VyRlgyyt42xQ/jsg6D9JgTNf+MEE9CZDz/AJ5ER30Hgh5uvPBcW35rYl7HyUxw0Xa9rR
         1eCw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVVuZfi4YcrsONBtdXgLCV0Ie6VdNSmu8uOsI2kRj0xcLHm8Ft/
	W8mWRaXAhWPDVC/cl1ossjHuJuRyTxpS3G81GWQT1FONJpM4qL6ti6sPRCGimH9XJTtCCyz1mDa
	XUSXKhXE1RiyAUGts+JyJYCd9D+GdeZwcDa9GdSq7dPoyUyU5pP/pgr24grCfX72qfA==
X-Received: by 2002:a17:902:20c6:: with SMTP id v6mr20749444plg.276.1555959524395;
        Mon, 22 Apr 2019 11:58:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxFd/C5ODM2my4PUmNlkfyHBw5qK1S+aeT6PcS951bxAhA8IdWfEaSs2Vu8K8PladKM9yQW
X-Received: by 2002:a17:902:20c6:: with SMTP id v6mr20749394plg.276.1555959523454;
        Mon, 22 Apr 2019 11:58:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555959523; cv=none;
        d=google.com; s=arc-20160816;
        b=FkHmAXXRcwwuXgtdr1oS8gOqMMknf+ZXYEJIzYC81XQ2OIerTcMQs+71hB3N0emirB
         Q5k4OdbJczY3adc81oIy31lvRAOsOJ2u3G7lWEManAfxxltJpvyLNbNpbnMZTYelWwLo
         Ez/LI4vty2giKn3w2TIEiBp7Xd1HXlcb3DIPDxdxQBD2Gv7yICX1AIhYJT1SLjvw9UcG
         EHG3cZpDmS93F2awqxcnUH/hpIR76JflHQCXkD85kSmNjxxOOqqSoQQDxcC5aKLiCOLj
         MIsQD5H0DOCq6/KjrgEYXsS1sarKSFB8BUFpaq8L3Bf+60OfJEcTONpMtH9FiZT/OEta
         5NGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=CLKl6NZzJuOK2yM4IgvyVy0XzBWA5gDBiZYSHfLNQ00=;
        b=zsnA61SB2KFN8zQRhS5F5kJ3rNYCJ1c2kfOn0ANpG5PbGJFzBtk8auPM2o+4T7ag14
         fVHBcohcZso/Q1MeatI+5pr/97jN8MbBQR9QAEmQFkpd/6F3MEvkCZaSZrwox22pAWbF
         08Mb3Eq+okHJGqmGw7k1nmV5GPSwmkIjNNo4GLRAapnbWaZKTMt57DICs8nFPd75fFa3
         kFBkhyPCZ02PMuWzpDpZkfpC4hDAKqCYcie35083Rh8G7To6d401hMAVzMtf+VoEkEr2
         BjMjyTK9uHMpeMttmK3hU6ACbA1CXgVMSSrNKQ0yz4yeQPlyJDBQ46yXxVVruQLKbhfV
         MKTA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id a2si12975117pgn.530.2019.04.22.11.58.43
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
   d="scan'208";a="136417143"
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
Subject: [PATCH v4 09/23] x86/ftrace: Set trampoline pages as executable
Date: Mon, 22 Apr 2019 11:57:51 -0700
Message-Id: <20190422185805.1169-10-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
References: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

Since alloc_module() will not set the pages as executable soon, set
ftrace trampoline pages as executable after they are allocated.

For the time being, do not change ftrace to use the text_poke()
interface. As a result, ftrace still breaks W^X.

Reviewed-by: Steven Rostedt (VMware) <rostedt@goodmis.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/kernel/ftrace.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/arch/x86/kernel/ftrace.c b/arch/x86/kernel/ftrace.c
index ef49517f6bb2..53ba1aa3a01f 100644
--- a/arch/x86/kernel/ftrace.c
+++ b/arch/x86/kernel/ftrace.c
@@ -730,6 +730,7 @@ create_trampoline(struct ftrace_ops *ops, unsigned int *tramp_size)
 	unsigned long end_offset;
 	unsigned long op_offset;
 	unsigned long offset;
+	unsigned long npages;
 	unsigned long size;
 	unsigned long retq;
 	unsigned long *ptr;
@@ -762,6 +763,7 @@ create_trampoline(struct ftrace_ops *ops, unsigned int *tramp_size)
 		return 0;
 
 	*tramp_size = size + RET_SIZE + sizeof(void *);
+	npages = DIV_ROUND_UP(*tramp_size, PAGE_SIZE);
 
 	/* Copy ftrace_caller onto the trampoline memory */
 	ret = probe_kernel_read(trampoline, (void *)start_offset, size);
@@ -806,6 +808,12 @@ create_trampoline(struct ftrace_ops *ops, unsigned int *tramp_size)
 	/* ALLOC_TRAMP flags lets us know we created it */
 	ops->flags |= FTRACE_OPS_FL_ALLOC_TRAMP;
 
+	/*
+	 * Module allocation needs to be completed by making the page
+	 * executable. The page is still writable, which is a security hazard,
+	 * but anyhow ftrace breaks W^X completely.
+	 */
+	set_memory_x((unsigned long)trampoline, npages);
 	return (unsigned long)trampoline;
 fail:
 	tramp_free(trampoline, *tramp_size);
-- 
2.17.1

