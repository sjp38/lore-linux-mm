Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC99DC04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:18:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A1E392083E
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:18:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A1E392083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 693AB6B02DB; Thu,  6 Jun 2019 16:17:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0849C6B02D5; Thu,  6 Jun 2019 16:17:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A48D36B02DC; Thu,  6 Jun 2019 16:17:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 446EB6B02DB
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:17:35 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id e69so2314464pgc.7
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:17:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=5sD/VtOBJS3fd61Qzp6JVoTL0uRDWIHB9WqS2y24rXE=;
        b=C/lXQMputiarYgn2bRPMbL7uX+FJTIqtvCiP1xKgdD+EDZkI4aC6qQHBZWCevr3x3O
         BbP336cV1GLcyFrQj+MjvuAOiXzA/KRKBBeX3uJfy2HxUbBbTwDTi/J36IXdMq5SBl7P
         7UVM6hMuLfHWpX9aS8e2GZ96XqZcqoklGkXAStLcHvYO8PUiJaU/4ajWjRrCPwIbDnL9
         /X0qw4wIegYmRMWChE0MptQwQHSO3mgOb0o01sjqsFAfbLmFaeOwtln3owYACOSksiyJ
         ZK52h2NYGsu0AIKz/O6vWzC/Y71mlzg9cS91KYaMVWUJLQC4pFiOaNVHXfAdnhlB6ijP
         nzcw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWZcNjegnPBzj0SWvPxON/1UdsaiboYaEinvAexFIimrWCzs9VK
	arwmvL5ZgDVbYLTWQjcPD3a7xrBpEgRSo36grIK3hPiZ1eSF5opeyeCxPAhPxMe5HzYCrhW5qWT
	6MjenGzcHhKsUCEF4C8++Zd2du2nWWlqxnhzy5O8Y52Y+C3Y8nQBxCR8LYUDSR3Hjog==
X-Received: by 2002:a17:90a:5d09:: with SMTP id s9mr1615564pji.120.1559852254917;
        Thu, 06 Jun 2019 13:17:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwg+oJwtNI3sE8wx4ntVhiRfSe0QRUp+pKKzEzm5918TFvhVInycce3dyK540J0u/iNAwKn
X-Received: by 2002:a17:90a:5d09:: with SMTP id s9mr1615473pji.120.1559852253613;
        Thu, 06 Jun 2019 13:17:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852253; cv=none;
        d=google.com; s=arc-20160816;
        b=0LPphXBUBtqQIfmTi+HKznfYDFYLR3S8El5xtc61qXdWN+wjwYnr9118y5mygO0heU
         +Cu5+AFWBetF/pTOkejroIjwXygIuNXbgSQT/1balr+2jvXg2uVibB/rS8IUJYAkqRVU
         PuI+IYb4srqeT/1TGRAlzUK+fd3s1+2X9Lc505iWXN7pDbZPEPV3z4ENJGNREzRtXHX/
         8Xc+riJityF3Q6XKsEx/dSxZfNNMpZa354u1W0q4UHP7tDUyt3e9k+jz7J/LzLzSPoZl
         Ur2nZRNKFzpk74GgZ75Yu+HgALYTSwe1qj/rb4dVYpfVYqDzia/CZC7t5uxNhv+9mG8C
         LHwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=5sD/VtOBJS3fd61Qzp6JVoTL0uRDWIHB9WqS2y24rXE=;
        b=xVx7LvW1we1RiVBebE+EoNiaocxbG96xsghAG0HIrx2LwYTbP0+e7bY4vqI+056c17
         DV9LsrXIRaliPxr/osf8PhCzoaSZCek0lkwEchhI7chEzL5XJ/aVAYAIju4L14EnPfTg
         QMHnxvo4/kE4OfdbnlWnd8Z0FelUQufCxh2qFCC9wgk25MY4SWPm2TA63OGU1Lm+4fVH
         BClqz1AgV7pdJ5CA5pYxxyxXKXDSTJVlDh6/FAmTiiDBsZkU6T/z2xtAmoyLIzD/QbMn
         /TqirNtzwLsURMsUAucdhEOZmggLOhXHLC9sJcM55sypN0ssvkBfOpreGhEnDV+QdwL5
         lvQw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id p21si39566plq.328.2019.06.06.13.17.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 13:17:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 13:17:32 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by fmsmga001.fm.intel.com with ESMTP; 06 Jun 2019 13:17:32 -0700
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
Subject: [PATCH v7 13/14] x86/cet: Add PTRACE interface for CET
Date: Thu,  6 Jun 2019 13:09:25 -0700
Message-Id: <20190606200926.4029-14-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190606200926.4029-1-yu-cheng.yu@intel.com>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add REGSET_CET64/REGSET_CET32 to get/set CET MSRs:

    IA32_U_CET (user-mode CET settings) and
    IA32_PL3_SSP (user-mode shadow stack)

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/asm/fpu/regset.h |  7 +++---
 arch/x86/kernel/fpu/regset.c      | 41 +++++++++++++++++++++++++++++++
 arch/x86/kernel/ptrace.c          | 16 ++++++++++++
 include/uapi/linux/elf.h          |  1 +
 4 files changed, 62 insertions(+), 3 deletions(-)

diff --git a/arch/x86/include/asm/fpu/regset.h b/arch/x86/include/asm/fpu/regset.h
index d5bdffb9d27f..edad0d889084 100644
--- a/arch/x86/include/asm/fpu/regset.h
+++ b/arch/x86/include/asm/fpu/regset.h
@@ -7,11 +7,12 @@
 
 #include <linux/regset.h>
 
-extern user_regset_active_fn regset_fpregs_active, regset_xregset_fpregs_active;
+extern user_regset_active_fn regset_fpregs_active, regset_xregset_fpregs_active,
+				cetregs_active;
 extern user_regset_get_fn fpregs_get, xfpregs_get, fpregs_soft_get,
-				xstateregs_get;
+				xstateregs_get, cetregs_get;
 extern user_regset_set_fn fpregs_set, xfpregs_set, fpregs_soft_set,
-				 xstateregs_set;
+				 xstateregs_set, cetregs_set;
 
 /*
  * xstateregs_active == regset_fpregs_active. Please refer to the comment
diff --git a/arch/x86/kernel/fpu/regset.c b/arch/x86/kernel/fpu/regset.c
index d652b939ccfb..2937ec9d9215 100644
--- a/arch/x86/kernel/fpu/regset.c
+++ b/arch/x86/kernel/fpu/regset.c
@@ -156,6 +156,47 @@ int xstateregs_set(struct task_struct *target, const struct user_regset *regset,
 	return ret;
 }
 
+int cetregs_active(struct task_struct *target, const struct user_regset *regset)
+{
+#ifdef CONFIG_X86_INTEL_CET
+	if (target->thread.cet.shstk_enabled || target->thread.cet.ibt_enabled)
+		return regset->n;
+#endif
+	return 0;
+}
+
+int cetregs_get(struct task_struct *target, const struct user_regset *regset,
+		unsigned int pos, unsigned int count,
+		void *kbuf, void __user *ubuf)
+{
+	struct fpu *fpu = &target->thread.fpu;
+	struct cet_user_state *cetregs;
+
+	if (!boot_cpu_has(X86_FEATURE_SHSTK))
+		return -ENODEV;
+
+	cetregs = get_xsave_addr(&fpu->state.xsave, XFEATURE_CET_USER);
+
+	fpu__prepare_read(fpu);
+	return user_regset_copyout(&pos, &count, &kbuf, &ubuf, cetregs, 0, -1);
+}
+
+int cetregs_set(struct task_struct *target, const struct user_regset *regset,
+		  unsigned int pos, unsigned int count,
+		  const void *kbuf, const void __user *ubuf)
+{
+	struct fpu *fpu = &target->thread.fpu;
+	struct cet_user_state *cetregs;
+
+	if (!boot_cpu_has(X86_FEATURE_SHSTK))
+		return -ENODEV;
+
+	cetregs = get_xsave_addr(&fpu->state.xsave, XFEATURE_CET_USER);
+
+	fpu__prepare_write(fpu);
+	return user_regset_copyin(&pos, &count, &kbuf, &ubuf, cetregs, 0, -1);
+}
+
 #if defined CONFIG_X86_32 || defined CONFIG_IA32_EMULATION
 
 /*
diff --git a/arch/x86/kernel/ptrace.c b/arch/x86/kernel/ptrace.c
index a166c960bc9e..db902ed9b353 100644
--- a/arch/x86/kernel/ptrace.c
+++ b/arch/x86/kernel/ptrace.c
@@ -51,7 +51,9 @@ enum x86_regset {
 	REGSET_IOPERM64 = REGSET_XFP,
 	REGSET_XSTATE,
 	REGSET_TLS,
+	REGSET_CET64 = REGSET_TLS,
 	REGSET_IOPERM32,
+	REGSET_CET32,
 };
 
 struct pt_regs_offset {
@@ -1268,6 +1270,13 @@ static struct user_regset x86_64_regsets[] __ro_after_init = {
 		.size = sizeof(long), .align = sizeof(long),
 		.active = ioperm_active, .get = ioperm_get
 	},
+	[REGSET_CET64] = {
+		.core_note_type = NT_X86_CET,
+		.n = sizeof(struct cet_user_state) / sizeof(u64),
+		.size = sizeof(u64), .align = sizeof(u64),
+		.active = cetregs_active, .get = cetregs_get,
+		.set = cetregs_set
+	},
 };
 
 static const struct user_regset_view user_x86_64_view = {
@@ -1323,6 +1332,13 @@ static struct user_regset x86_32_regsets[] __ro_after_init = {
 		.size = sizeof(u32), .align = sizeof(u32),
 		.active = ioperm_active, .get = ioperm_get
 	},
+	[REGSET_CET32] = {
+		.core_note_type = NT_X86_CET,
+		.n = sizeof(struct cet_user_state) / sizeof(u64),
+		.size = sizeof(u64), .align = sizeof(u64),
+		.active = cetregs_active, .get = cetregs_get,
+		.set = cetregs_set
+	},
 };
 
 static const struct user_regset_view user_x86_32_view = {
diff --git a/include/uapi/linux/elf.h b/include/uapi/linux/elf.h
index 316177ce9e76..4f320d96d538 100644
--- a/include/uapi/linux/elf.h
+++ b/include/uapi/linux/elf.h
@@ -401,6 +401,7 @@ typedef struct elf64_shdr {
 #define NT_386_TLS	0x200		/* i386 TLS slots (struct user_desc) */
 #define NT_386_IOPERM	0x201		/* x86 io permission bitmap (1=deny) */
 #define NT_X86_XSTATE	0x202		/* x86 extended state using xsave */
+#define NT_X86_CET	0x203		/* x86 cet state */
 #define NT_S390_HIGH_GPRS	0x300	/* s390 upper register halves */
 #define NT_S390_TIMER	0x301		/* s390 timer register */
 #define NT_S390_TODCMP	0x302		/* s390 TOD clock comparator register */
-- 
2.17.1

