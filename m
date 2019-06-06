Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54E31C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:17:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4FE24208CA
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:17:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4FE24208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA4C36B02CF; Thu,  6 Jun 2019 16:17:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D03F76B02CD; Thu,  6 Jun 2019 16:17:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA1EE6B02CE; Thu,  6 Jun 2019 16:17:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7EB606B02C7
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:17:33 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id j21so2068510pff.12
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:17:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=yK5r0u+SDfqgRVohMfxwhJpS11WNf7HKHOdyvywJNCw=;
        b=K+Asb0TEjmToubXtSVKQ9pZWhyh3+l8hfNsikQ3CFOmkoPeNgoxT1IG5SmWNmPwYRP
         dUGIVsV5fJcRwt+h8Bw/owfBfrmkBix94EOLj9MLUit6lJc4UvppIzS2znOJMcRE+xmf
         UNZ5/JSUsKqP8zE1XQcYv3ynbhxMNZGZVGc+BztEPtRl5CY5UA/8bunh/rLtm5UCjD29
         47uEYN++fFfD+lwEa9uaSEvDyKHZpzZemtIB1BHGrbkBVMkH+VKV7MtN0Inv4k9KFgCf
         iJZoO+eYAXyAA+QMacaDrJ77NSfxk0waSDGNLdobAA69LPAv33fhshFrA9qRwhOlc2EJ
         MezQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVn2Qta51kq2j6oTJzpE5D4eFsaUt9ZljVbwXOF6hBCoz2G+yvO
	JY+OaUYWPuEJNzIuGjgyv86dtKe6Ehi0vM62h9v/bMo5rvLNYE7araVrZuPluo/TGJAHsoZAXqm
	p1a7UlXH2jbcSVsuHoqRNTz4/LploDE3Xw7lvNRMD7CjxvlXAhx+OO5HIKYKSOB/rmA==
X-Received: by 2002:aa7:8049:: with SMTP id y9mr870038pfm.195.1559852253202;
        Thu, 06 Jun 2019 13:17:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwN58vCvdTwN3f/43A2KDd3g6PcS5o9Yxy2BwfGbcBpwRcOiips3o3tu38LhzYbnroKajVc
X-Received: by 2002:aa7:8049:: with SMTP id y9mr869958pfm.195.1559852252106;
        Thu, 06 Jun 2019 13:17:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852252; cv=none;
        d=google.com; s=arc-20160816;
        b=OaF+ZLn0eOLlFwgJWxznsVhcBIwLRthJ/SklFlt1cTnUADWSiL0L8JzrF6zXxiOHU7
         eRf9VtAG7LnoEN2DfoceUWLq2E88a3VtWHqBzol4sI62noYFgrmSqUnBCcN1WFR4bN5X
         8V6pF+nYFZdih0qvTjhRehkxzNAkBsIHH1Rgy1NuknPpVB347HajV1o4MIHTju4p94WT
         4npZwst9L3YB9zAFB8E/IEfOIWosZzvHSbxYvk8psiMpW84ymERs/dQ+7sVSVZyJ8/vl
         LsyXKnFux7uEvYAqqeoDF9/9J4kfCgQfWf6lwAp6TQHfle9FAlMyyqGLFqIpMXUr/InZ
         SrFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=yK5r0u+SDfqgRVohMfxwhJpS11WNf7HKHOdyvywJNCw=;
        b=LeBTsQwY+G2Lwtywzp6thz+VQ++2iaof8OUM3AGAs05autWO62sZBmmgDfRezbku58
         i22WzJVb1QVDBxZtU7WtsySBXKRvzuzMKS1XtgsDVP0TzqHenmMZ+iN1WMaCW0yz8zzq
         UtWaJ/l4Rv6zO1NR70UOn1vOzRfCoJKLAujD1JOAUuF+SxyIuyNqO7+fgTEXRw5O9RJf
         Q9+aTWJJannTlAyHNLha45T1xKU1ougX+Z/YdCUPMsXLkuVc95KeNBUHp9D/yR0PLcsu
         03yTBucySFifff00/1eo5ZfzNS108EFcrsxiNLhsv/A9unqHo5pvo6sFUbC9ySSbxZ1n
         Mtlg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id e29si45752pgb.428.2019.06.06.13.17.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 13:17:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 13:17:31 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by fmsmga001.fm.intel.com with ESMTP; 06 Jun 2019 13:17:31 -0700
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org,
	linux-mm@kvack.org,
	linux-arch@vger.kernel.org,
	linux-api@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Andy Lutomirski <luto@amacapital.net>,
	Balbir Singh <bsingharora@gmail.com>,
	Borislav Petkov <bp@alien8.de>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Eugene Syromiatnikov <esyr@redhat.com>,
	Florian Weimer <fweimer@redhat.com>,
	"H.J. Lu" <hjl.tools@gmail.com>,
	Jann Horn <jannh@google.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Nadav Amit <nadav.amit@gmail.com>,
	Oleg Nesterov <oleg@redhat.com>,
	Pavel Machek <pavel@ucw.cz>,
	Peter Zijlstra <peterz@infradead.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
	Dave Martin <Dave.Martin@arm.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH v7 05/14] mm/mmap: Add IBT bitmap size to address space limit check
Date: Thu,  6 Jun 2019 13:09:17 -0700
Message-Id: <20190606200926.4029-6-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190606200926.4029-1-yu-cheng.yu@intel.com>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The indirect branch tracking legacy bitmap takes a large address
space.  This causes may_expand_vm() failure on the address limit
check.  For a IBT-enabled task, add the bitmap size to the
address limit.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/asm/mmu_context.h | 10 ++++++++++
 mm/mmap.c                          | 19 ++++++++++++++++++-
 2 files changed, 28 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index a9a768529540..2499f6490428 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -360,6 +360,16 @@ static inline unsigned long __get_current_cr3_fast(void)
 	return cr3;
 }
 
+#ifdef CONFIG_X86_INTEL_BRANCH_TRACKING_USER
+static inline unsigned long arch_as_limit(void)
+{
+	if (current->thread.cet.ibt_enabled)
+		return current->thread.cet.ibt_bitmap_size;
+	else
+		return 0;
+}
+#endif
+
 typedef struct {
 	struct mm_struct *mm;
 } temp_mm_state_t;
diff --git a/mm/mmap.c b/mm/mmap.c
index 3b643ace2c49..a0d6fb559518 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3283,13 +3283,30 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 	return NULL;
 }
 
+#ifndef CONFIG_ARCH_HAS_AS_LIMIT
+static inline unsigned long arch_as_limit(void)
+{
+	return 0;
+}
+#endif
+
 /*
  * Return true if the calling process may expand its vm space by the passed
  * number of pages
  */
 bool may_expand_vm(struct mm_struct *mm, vm_flags_t flags, unsigned long npages)
 {
-	if (mm->total_vm + npages > rlimit(RLIMIT_AS) >> PAGE_SHIFT)
+	unsigned long as_limit = rlimit(RLIMIT_AS);
+	unsigned long as_limit_plus = as_limit + arch_as_limit();
+
+	/* as_limit_plus overflowed */
+	if (as_limit_plus < as_limit)
+		as_limit_plus = RLIM_INFINITY;
+
+	if (as_limit_plus > as_limit)
+		as_limit = as_limit_plus;
+
+	if (mm->total_vm + npages > as_limit >> PAGE_SHIFT)
 		return false;
 
 	if (is_data_mapping(flags) &&
-- 
2.17.1

