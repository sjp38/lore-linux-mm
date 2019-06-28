Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D470C5B579
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 19:50:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2BA0020828
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 19:50:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2BA0020828
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A9C2E6B0003; Fri, 28 Jun 2019 15:50:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A4E358E0003; Fri, 28 Jun 2019 15:50:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 962478E0002; Fri, 28 Jun 2019 15:50:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f205.google.com (mail-pf1-f205.google.com [209.85.210.205])
	by kanga.kvack.org (Postfix) with ESMTP id 62DE76B0003
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 15:50:29 -0400 (EDT)
Received: by mail-pf1-f205.google.com with SMTP id x18so4524377pfj.4
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 12:50:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=OdQ9J3Abw5fE03GEt4uo8Rr+djgBr/SQIpVAY9l/fgk=;
        b=aczoCJGg4bYp3cCkrZmzPj9G44zZFwX+oz9LODOilanAowBQiWh8VUWN31W8xMjX8J
         VA2f7wFB7M6KawKFjgNe/WSprEQ0l4T+tdjE+pzfhMjhk8All8BjrqRR1VtFC+XvR5f7
         uS/7Hy66tppGLVdoM1FwZJ2oRYoaMuWqtiTF5KLZ1Ggmoiif72o/1hOaD6gNSdPfy4Ce
         B+XFyCXlUHUiEFG1r0+DX5HPkqKp3CTvdD7krvQZ9UEZM13mP6wqntj9TEVsH6iT7Nzu
         SH3ChWmo3jFzOuC5XUvsH7FQDTfN0aiUr8225I/jCH8GDLhonKCv1LwcZHu9/LxVfIP6
         OG9Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXUTfYQGmx3MvNMKoG5IECOlfSwNJxW1dZBd//MXG+T9aK8/IKj
	4TIJDQN18MPIYzp6yeIzbS9aEAJs+bTnKVbQ+HEa8apjwHHj3zwIx6A1xLE1Z5aZMeIT29QzeLP
	m+UIa81OllSMpGXhZEol0U5rR22xoSnHQN0hT51rrUM5FLTksHLJY3eRUqDBUPL0rSQ==
X-Received: by 2002:a17:902:a517:: with SMTP id s23mr13442502plq.306.1561751428989;
        Fri, 28 Jun 2019 12:50:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzbkaXg8SPDy9ghnQAZmkx1LhpR/nmBQMBGuzhC1kvGnh6vh1+KPwdDWqsGTMSzhAsn+7VZ
X-Received: by 2002:a17:902:a517:: with SMTP id s23mr13442434plq.306.1561751428198;
        Fri, 28 Jun 2019 12:50:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561751428; cv=none;
        d=google.com; s=arc-20160816;
        b=ku0GQnHmy7icv1RnYWoG0dM0EsGRyVrAH2HQGOf3JbBEObZOv0UfDEDwSHA8jz62Gl
         NMWroLUIQGeoi8s2HBaUI4/bzIrNXy8AvzTG3Xg8/QO8YG/0b3k+Hk3txNNIctRrvgRf
         0jeH+bIxH/q/G0XahgO+pZ/elkR7P/pmOanR09iLxuFXjKUao6rZ0FLZKxo9XOTJpXIE
         IAhWvc0d/3ycKy3xR4BMXoXFwdq3VACKJYinTlsP25AbOvoNpJO5aVgSLJ36fkC++GGh
         Vj9MZcNJb6aQqOyyJ5mQ+DmjLflGkgD5eyVyqMqYSkE2guiPzmDAJIuYJb0jZM3BQ1jS
         N46Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=OdQ9J3Abw5fE03GEt4uo8Rr+djgBr/SQIpVAY9l/fgk=;
        b=d/BUsB+CpR2zFDvVjLw0iVV/Lr/BOYOe2rZ0ZjNOB+U1sEgyDJdr+z+wkNgV6TsEFx
         hOcn4pyxjdmPIMzyFgEK4NV9jiAmB6UrnkflQqDHNAexet0Yh6AOeZj6jn7fvwDJ5V+3
         T0YUk13KNdBOTr0uYSaH7cH+S+8UkbnhQ/+4d1h1i3s9NL5xjLvRMeOCLWb1BmF0SUwx
         KgAjUyV715jFRJKLd3J6MBrfXWREWbwHUITxz0yOHqjouu6TAuwKHS3FRDat+3fC4IDG
         vaQcWyRGoYfKAioSM6Mdw1Kn/R/VfJOu5LYmj7cmCWmH+p49MqygQVAPbbFj1XwmUYK9
         0ypQ==
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
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Jun 2019 12:50:27 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,428,1557212400"; 
   d="scan'208";a="164756004"
Received: from yyu32-desk1.sc.intel.com ([10.144.153.205])
  by fmsmga007.fm.intel.com with ESMTP; 28 Jun 2019 12:50:26 -0700
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
Subject: [RFC PATCH 1/3] mm: Introduce VM_IBT for CET legacy code bitmap
Date: Fri, 28 Jun 2019 12:41:56 -0700
Message-Id: <20190628194158.2431-1-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The previous discussion of the IBT legacy code bitmap is here:

    https://lkml.org/lkml/2019/6/6/1032

When CET Indirect Branch Tracking (IBT) is enabled, the processor expects
every branch target is an ENDBR instruction, or the target's address is
marked as legacy in the legacy code bitmap.  The bitmap covers the whole
user-mode address space (TASK_SIZE_MAX for 64-bit, TASK_SIZE for IA32),
and each bit represents one page of linear address range.

This patch introduces VM_IBT for the bitmap.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 fs/proc/task_mmu.c | 3 +++
 include/linux/mm.h | 8 ++++++++
 2 files changed, 11 insertions(+)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 66725e262a77..d707390285d3 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -663,6 +663,9 @@ static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
 #endif /* CONFIG_ARCH_HAS_PKEYS */
 #ifdef CONFIG_X86_INTEL_SHADOW_STACK_USER
 		[ilog2(VM_SHSTK)]	= "ss",
+#endif
+#ifdef CONFIG_X86_INTEL_BRANCH_TRACKING_USER
+		[ilog2(VM_IBT)]		= "bt",
 #endif
 	};
 	size_t i;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 921bae5fa7ab..a8da5bdfd7c9 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -299,12 +299,14 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_HIGH_ARCH_BIT_3	35	/* bit only usable on 64-bit architectures */
 #define VM_HIGH_ARCH_BIT_4	36	/* bit only usable on 64-bit architectures */
 #define VM_HIGH_ARCH_BIT_5	37	/* bit only usable on 64-bit architectures */
+#define VM_HIGH_ARCH_BIT_6	38	/* bit only usable on 64-bit architectures */
 #define VM_HIGH_ARCH_0	BIT(VM_HIGH_ARCH_BIT_0)
 #define VM_HIGH_ARCH_1	BIT(VM_HIGH_ARCH_BIT_1)
 #define VM_HIGH_ARCH_2	BIT(VM_HIGH_ARCH_BIT_2)
 #define VM_HIGH_ARCH_3	BIT(VM_HIGH_ARCH_BIT_3)
 #define VM_HIGH_ARCH_4	BIT(VM_HIGH_ARCH_BIT_4)
 #define VM_HIGH_ARCH_5	BIT(VM_HIGH_ARCH_BIT_5)
+#define VM_HIGH_ARCH_6	BIT(VM_HIGH_ARCH_BIT_6)
 #endif /* CONFIG_ARCH_USES_HIGH_VMA_FLAGS */
 
 #ifdef CONFIG_ARCH_HAS_PKEYS
@@ -348,6 +350,12 @@ extern unsigned int kobjsize(const void *objp);
 # define VM_SHSTK	VM_NONE
 #endif
 
+#ifdef CONFIG_X86_INTEL_BRANCH_TRACKING_USER
+# define VM_IBT		VM_HIGH_ARCH_6
+#else
+# define VM_IBT		VM_NONE
+#endif
+
 #ifndef VM_GROWSUP
 # define VM_GROWSUP	VM_NONE
 #endif
-- 
2.17.1

