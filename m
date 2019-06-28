Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EA98C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 19:50:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C35B214DA
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 19:50:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C35B214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 45F396B0005; Fri, 28 Jun 2019 15:50:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 322148E0003; Fri, 28 Jun 2019 15:50:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 156D06B0005; Fri, 28 Jun 2019 15:50:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f207.google.com (mail-pl1-f207.google.com [209.85.214.207])
	by kanga.kvack.org (Postfix) with ESMTP id D766E6B0005
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 15:50:29 -0400 (EDT)
Received: by mail-pl1-f207.google.com with SMTP id s22so4074256plp.5
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 12:50:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=Z3FMaOQYFMR5/uuy/5W8NqANQmF1P4lxdq0t3zNRwG4=;
        b=VLDpHUmsXtwAbAhXi4KpQ04IMCScQLv/ewIr7r4eG4bm6q0L/TNa6/X2YsEEGFFYxS
         hmHG+uL44XRDMrwLZCUuv6UMi3u4rFs1t/AN034sMxXpXTLKBv5DRANKcU22NlXnQPz1
         Ene004DejhGGuFvcKqfs87xqm4Q8f5EvtN3/glaKmqto4zciHKGX5jPKXcQ/pn6rcTFx
         RddSTIdaVcbsAUCnKOEPIPa1n69b0ELX9fhReW2QvBXKSZnL+DlyZyV2PpN8rbi6aKa5
         dOO9t37n8DgQp/FdZO0AKaqQuZ5JVjqVH7mp4oEAxgnkeQiJ58HuoF+s8rB9X94ugnV+
         SGhw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU88zhzacXIWmRD5QciNWMmgTUZl1mKVs64zdyYA/1Y/CR+EM0k
	08Uh9gp5rkRrplpW3Jz8GLcm67PZ5aYt5eBQmSLZMCHFToJUYZN1F6vArnQb6uMjsOkal+4HaOp
	0amSK7SGJb/BHbzUGYFpJhe5ucX7jT8Vk/MvyRBCR0nVyzVEguytLRqXJkezerDsyRA==
X-Received: by 2002:a65:55ca:: with SMTP id k10mr11052660pgs.14.1561751429403;
        Fri, 28 Jun 2019 12:50:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyvLMsrhunlygnaZXWNbWiPdRaQ2SzrWbX2zYqgNr2KB+K2SJBKiHPqmZYFfro/enH3v+Qd
X-Received: by 2002:a65:55ca:: with SMTP id k10mr11052610pgs.14.1561751428697;
        Fri, 28 Jun 2019 12:50:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561751428; cv=none;
        d=google.com; s=arc-20160816;
        b=WvfGCefarPJ1mPlCjJ2GAo/W8nkrtIknLaJ+gHDU5k13FI7Y5elnG17pN/hoglVYvJ
         ROLxVs3rWxOIAXGUaTsbsdUhacXCb2K788RLGHrVl2OeyNiWTpp4U7+Ej9W9qQ51BbXS
         pPc3A08LQ9hGB9+Cf2rVZXsBTAnont3ijoBio9ezimjfrdJQ/G1s24GoGSB1hoIEvDOK
         tPf6CNooVXGYNAsPawCVJAo5bCzwxvJqcIV1KGflyR3a3zrGnuKVXdfeFRAiGIigqRzU
         xXHYdnvyP7aZVX4hSUukcCN5FO2p4eVxY/azRepQaYepXZkomLVx83yoYwpCeS1VXTID
         6Fvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=Z3FMaOQYFMR5/uuy/5W8NqANQmF1P4lxdq0t3zNRwG4=;
        b=t2X2P5yJPUYe5YRezJB6GhAyV4PEzVFpuIJnjUl/hPCy5I/RtDi2Se9KCqkCvVFwzA
         8u1LsdEooIpW134uhwfeKUsnKfnHNKIACSWbk0Rjyq6YyfdI7sc5ZRhVl/+B3gCdUliA
         kuDWk+zLwtl4zcV7BBdW7FWic5IR1+q0QSIkUk1cvtPY6yI+NZMD+GPPUn6KclAGl33Y
         UHDeytZNEXpCw2aLMlnP2k4iUFe+YQFc6/KLQs9eUELTi5s2WKAVqRFtFO5lmr/+wdn8
         3pwGY9YnKwDrAQTzrzx6KnyevSCKW4y0MNmKfEBf8yCQ3DY1xSosysMev1n0fGDJbAO9
         KLzA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id cd3si3020212plb.228.2019.06.28.12.50.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jun 2019 12:50:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Jun 2019 12:50:28 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,428,1557212400"; 
   d="scan'208";a="164756014"
Received: from yyu32-desk1.sc.intel.com ([10.144.153.205])
  by fmsmga007.fm.intel.com with ESMTP; 28 Jun 2019 12:50:27 -0700
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
Subject: [RFC PATCH 3/3] Prevent user from writing to IBT bitmap.
Date: Fri, 28 Jun 2019 12:41:58 -0700
Message-Id: <20190628194158.2431-3-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190628194158.2431-1-yu-cheng.yu@intel.com>
References: <20190628194158.2431-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The IBT bitmap is visiable from user-mode, but not writable.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>

---
 arch/x86/mm/fault.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 59f4f66e4f2e..231196abb62e 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1454,6 +1454,13 @@ void do_user_addr_fault(struct pt_regs *regs,
 	 * we can handle it..
 	 */
 good_area:
+#define USER_MODE_WRITE (FAULT_FLAG_WRITE | FAULT_FLAG_USER)
+	if (((flags & USER_MODE_WRITE)  == USER_MODE_WRITE) &&
+	    (vma->vm_flags & VM_IBT)) {
+		bad_area_access_error(regs, hw_error_code, address, vma);
+		return;
+	}
+
 	if (unlikely(access_error(hw_error_code, vma))) {
 		bad_area_access_error(regs, hw_error_code, address, vma);
 		return;
-- 
2.17.1

