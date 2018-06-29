Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A9DBB6B0269
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 18:41:42 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u130-v6so4478136pgc.0
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 15:41:42 -0700 (PDT)
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id v12-v6si10721204plo.264.2018.06.29.15.41.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 15:41:41 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC v3 PATCH 5/5] x86: check VM_DEAD flag in page fault
Date: Sat, 30 Jun 2018 06:39:45 +0800
Message-Id: <1530311985-31251-6-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1530311985-31251-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1530311985-31251-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, tglx@linutronix.de, hpa@zytor.com
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

Check VM_DEAD flag of vma in page fault handler, if it is set, trigger
SIGSEGV.

Cc: Michal Hocko <mhocko@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 arch/x86/mm/fault.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 9a84a0d..3fd2da5 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1357,6 +1357,10 @@ static inline bool smap_violation(int error_code, struct pt_regs *regs)
 		bad_area(regs, error_code, address);
 		return;
 	}
+	if (unlikely(vma->vm_flags & VM_DEAD)) {
+		bad_area(regs, error_code, address);
+		return;
+	}
 	if (error_code & X86_PF_USER) {
 		/*
 		 * Accessing the stack below %sp is always a bug.
-- 
1.8.3.1
