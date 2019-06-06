Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5699C28EB4
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:15:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 67CB6208C3
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:15:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 67CB6208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E18106B0295; Thu,  6 Jun 2019 16:15:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D79606B0296; Thu,  6 Jun 2019 16:15:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BCE946B0297; Thu,  6 Jun 2019 16:15:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7AE056B0295
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:15:20 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id a125so2599296pfa.13
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:15:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=gGafeXV2q0OOkveu5M5HI4+ttygaPPzx4ttepRTRb5w=;
        b=Ie9G+nJSHTd7nt+TdJSl7Wfnnk2jGetwXR0EhCn6YOgP6iTuAmtAakPP5/WYnlWtWV
         0++DAx85iXVKLqq77KEAMdVj2z46VEvkZWIKc+0Q3RrJAo8gb+8c9rLfd8nAlec/MfzT
         NLlf/2ZA6QvGFWxvhCmVizPLGiFmGsQ1rRVQ/tllIxEYfZgGkVXDKTmgIJjQDmwTQ9rE
         Wga7SZQe6iBxoGnWluAgLiQchrFjuNBiTE/gUzuOKOqLMQejIwAxUgUI0x5MFEkIKZeh
         RFF4wKgwTvPQSJz5u+H8YFoUiDRGzCeMYNVuPlm06Gyb0rjPXe2j9Zm/pVopH6Gvx3sA
         gdCg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU2YkIH5CVajFpttjH8HaU/GE6UXjfeXSatb5RkWpPTD0n70+oA
	FVA77KXhRzb1uEcG8NgIUEGkH/1Su7ICaez+udznAmqsVGsW+rOy2UNMIaULuYD+tRuZnL7KJaw
	t58+DF0g1RyKRDv7MWf/TPzxGYXujlVSR+3M4BZKYvDoaTjSn2jX+/azZuFBaBiMteg==
X-Received: by 2002:a17:902:24d:: with SMTP id 71mr53359895plc.166.1559852120130;
        Thu, 06 Jun 2019 13:15:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyYcNcDguJeRjEhyJN9fUWQesiyFHaAfLvbt2GW3nEU2FQc/HN3c07ljFVIZ9k5K71WhCT5
X-Received: by 2002:a17:902:24d:: with SMTP id 71mr53359844plc.166.1559852119423;
        Thu, 06 Jun 2019 13:15:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852119; cv=none;
        d=google.com; s=arc-20160816;
        b=c9+EO1BjUpMBUWRp8EjRer51FB2QWj02rsP+SGBefyeMOGtisR5LApxNlORAJQJ5g3
         HGtBasRIknH33eUgA2AMajtvjKo4J3p6CiDzq4XXTlixBIhXiCVEcoSx7ojTGI0EnuK1
         mfhozMghNXdMIH6ZRauV9VKcZmEUdUQ8aMoB/UyMnEprQYkIwYCzpwpjHQ91nhKqPKPy
         GiOfYQVX+7RTz61uX3kt3EOhuW+9aYFJGkqErKoYPbKSzxUhcYCK9fvPKraZ9hxn/W9A
         qv+5MbAuY6imToCn+0+cmfkHbsTlFIQDs3w+l7f4K5V+xmnm61zeo+zG2GytmhM/kMqw
         F/fQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=gGafeXV2q0OOkveu5M5HI4+ttygaPPzx4ttepRTRb5w=;
        b=l0POl04ZhX86xCr9T3Az3UlXW0sm/VTVcJNO6btu2RmKRhSmWkawzGB1NdTiVYmdNs
         ag4t3GKkw65tEKvjPk6PcAS+m77G8rwBoeV9hnKUjxmEGHzYw2BwvVhPc1CGnJh2Y2lB
         wLFnDe8ApvK7hiUUHqfADjPllRQwNMqpHcVx+LMItJ69sBnboSF2XDmSntE0ohUaHxfW
         lSgyZfMWafAzo2Pl0jh4fB8YDA/dScTRvvWJpewsRRdbK33incWSBJcwDFREBohld56+
         ygT5LTi6JQFaCdIG1X8RSUFRIbR684cIOg6r/0bUUpTcVIIQu0/V5u3+Fpl6UD6/3oA7
         GmTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id 91si31377plh.398.2019.06.06.13.15.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 13:15:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 13:15:18 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by orsmga002.jf.intel.com with ESMTP; 06 Jun 2019 13:15:17 -0700
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
Subject: [PATCH v7 08/27] mm: Introduce VM_SHSTK for shadow stack memory
Date: Thu,  6 Jun 2019 13:06:27 -0700
Message-Id: <20190606200646.3951-9-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190606200646.3951-1-yu-cheng.yu@intel.com>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

VM_SHSTK indicates a shadow stack memory area.
The shadow stack is implemented only for the 64-bit kernel.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 fs/proc/task_mmu.c | 3 +++
 include/linux/mm.h | 8 ++++++++
 2 files changed, 11 insertions(+)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 01d4eb0e6bd1..dd8b0cd1ea36 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -661,6 +661,9 @@ static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
 		[ilog2(VM_PKEY_BIT4)]	= "",
 #endif
 #endif /* CONFIG_ARCH_HAS_PKEYS */
+#ifdef CONFIG_X86_INTEL_SHADOW_STACK_USER
+		[ilog2(VM_SHSTK)]	= "ss"
+#endif
 	};
 	size_t i;
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0e8834ac32b7..398f1e1c35e5 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -287,11 +287,13 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_HIGH_ARCH_BIT_2	34	/* bit only usable on 64-bit architectures */
 #define VM_HIGH_ARCH_BIT_3	35	/* bit only usable on 64-bit architectures */
 #define VM_HIGH_ARCH_BIT_4	36	/* bit only usable on 64-bit architectures */
+#define VM_HIGH_ARCH_BIT_5	37	/* bit only usable on 64-bit architectures */
 #define VM_HIGH_ARCH_0	BIT(VM_HIGH_ARCH_BIT_0)
 #define VM_HIGH_ARCH_1	BIT(VM_HIGH_ARCH_BIT_1)
 #define VM_HIGH_ARCH_2	BIT(VM_HIGH_ARCH_BIT_2)
 #define VM_HIGH_ARCH_3	BIT(VM_HIGH_ARCH_BIT_3)
 #define VM_HIGH_ARCH_4	BIT(VM_HIGH_ARCH_BIT_4)
+#define VM_HIGH_ARCH_5	BIT(VM_HIGH_ARCH_BIT_5)
 #endif /* CONFIG_ARCH_USES_HIGH_VMA_FLAGS */
 
 #ifdef CONFIG_ARCH_HAS_PKEYS
@@ -329,6 +331,12 @@ extern unsigned int kobjsize(const void *objp);
 # define VM_MPX		VM_NONE
 #endif
 
+#ifdef CONFIG_X86_INTEL_SHADOW_STACK_USER
+# define VM_SHSTK	VM_HIGH_ARCH_5
+#else
+# define VM_SHSTK	VM_NONE
+#endif
+
 #ifndef VM_GROWSUP
 # define VM_GROWSUP	VM_NONE
 #endif
-- 
2.17.1

