Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C82A3C282CD
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:41:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8AB9E217F5
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 00:41:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8AB9E217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 35AFC8E0013; Mon, 28 Jan 2019 19:41:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3084A8E0008; Mon, 28 Jan 2019 19:41:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D2A88E0013; Mon, 28 Jan 2019 19:41:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6FD388E0008
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 19:41:11 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id v72so12685172pgb.10
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 16:41:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=yHQwJpfGDvOx+xHKw3fwkxaiviK2x3hbH3nzRfUqk4U=;
        b=IHLwIgNQs9LwEuDdk6Bj74q98VR3ScVhaE5tMNMUbn2EXuYuAKxsniqquTOryAeQF2
         l2HqArS3k3SpJQnF2b+ucE8LEd6MRTskEuokU3C1gT8w9J0DPbMvbZvq65Wq49pD9Dvj
         tCgeYGFSEA8KlYKi8mneYDFSygFujv/3jAbavX4d2iFa8W+N1ZFvotKwpnOSBNc/PrcO
         CWMR5llrm4i6Uba5TyYmEq9gY7iwdQ5ErvfK2xzRPJR4IbsQz62vlz8EVn4oqqathqgb
         3CnT3BZM4w48yRsFqDwW4O35gWvD1nqPI8SdkrOXoJBE6qsKz+1t/ckNsypPR1Ie4F4i
         B3pg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukc4QBMBEqJC8rKpUmcuvP96Yzmcg+aNoi2FYWGPE3HBvZLwDW0w
	omq/OmCx2Uq5wDjY9vYudWZwk1Xi5bzA6j0CPbZQQ8hrut3IpV5NggmFgcGt6eIkcQjVUvYYEZd
	+sOZ8lmjeL3u5C2ls9KEPJ3bzc9k8MX4Knp/o0Ff7q3sd+3KgfLPdhQan/EvnGkNNpg==
X-Received: by 2002:a62:f247:: with SMTP id y7mr24061684pfl.25.1548722471116;
        Mon, 28 Jan 2019 16:41:11 -0800 (PST)
X-Google-Smtp-Source: ALg8bN77UwLKDiFu+6adYjd1pkd5TqJEGuXvxhtMei3OGsZ07CN5hdwS+aqMypwqY81/p6Taz/c1
X-Received: by 2002:a62:f247:: with SMTP id y7mr24055495pfl.25.1548722354305;
        Mon, 28 Jan 2019 16:39:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548722354; cv=none;
        d=google.com; s=arc-20160816;
        b=g0KneIySxUH0hIaPgGtS4kHa5NT9PSCNwkgrWTIUjZxbUXCbD3+Mvy+2fZLZ2I2AOH
         3nc9GIrPc1GvJqRz4BxCiBafIZFp5gUiOtm+Rz9+ze7VlM7u7TzihRNIP7q9iIqaP8BP
         e/WHt7Ac0quGGU4+mcMmRV3YWyBFeb8gQd0DeTJRJW1YdXKOXVi4J97jkqf060W59O5j
         WRaj4ss69oDn+o+xWweRqk8Cr4pxfFAUDkNoV1Va5oenvs96+N6c6p4K5xQy6zbEyYVh
         m0BGOC/rGMPocz9NHuTgB1EehM6Hvw9nVTJ1pSm9fbWNJAKdw+/IFDofSi7brSarlpFa
         JFhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=yHQwJpfGDvOx+xHKw3fwkxaiviK2x3hbH3nzRfUqk4U=;
        b=haqxzf8Khbg7g4DUg2K3AXcjDzXf9rxDUugvzTd1WFQwa/kIWrSq2B3uR7kOlhoCnT
         j2mQIahDG1tlY7AKrG17Z3M2NT4EiXo4MVkQaEsH3lxx6DvVVQn/6xXpmvRIkQO0O4Mo
         bjMP09uXPmcyZoRIpbOmC33T12BBUYXslgiyFEYcC1Ug1NjOnisqDiOh91GtJ1AQ4nm8
         bvcVBVt+nA+X2uEenWmBnQc044HGICUn45uU6ULBUpq+nuAXOBtKymUrXbz4JueWgEsn
         1LYu3p8BdagxO1NwAYOs7TuwOxvawjzYK4s0NAB5sfiGXLbh11ebLUsUinV4snNP0eMv
         pSgA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id u184si34858171pgd.262.2019.01.28.16.39.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 16:39:14 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Jan 2019 16:39:12 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,535,1539673200"; 
   d="scan'208";a="133921940"
Received: from rpedgeco-desk5.jf.intel.com ([10.54.75.79])
  by orsmga001.jf.intel.com with ESMTP; 28 Jan 2019 16:39:12 -0800
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
Subject: [PATCH v2 18/20] x86/ftrace: Use vmalloc special flag
Date: Mon, 28 Jan 2019 16:34:20 -0800
Message-Id: <20190129003422.9328-19-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Use new flag VM_HAS_SPECIAL_PERMS for handling freeing of special
permissioned memory in vmalloc and remove places where memory was set NX
and RW before freeing which is no longer needed.

Cc: Steven Rostedt <rostedt@goodmis.org>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/kernel/ftrace.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/arch/x86/kernel/ftrace.c b/arch/x86/kernel/ftrace.c
index 13c8249b197f..cf30594a2032 100644
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
 
+	set_vm_special(trampoline);
+
 	/*
 	 * Module allocation needs to be completed by making the page
 	 * executable. The page is still writable, which is a security hazard,
-- 
2.17.1

