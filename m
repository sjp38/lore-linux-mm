Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5016FC433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 21:03:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0FA542070D
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 21:03:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0FA542070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD0A36B027A; Tue, 13 Aug 2019 17:03:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B07C06B027B; Tue, 13 Aug 2019 17:03:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 97F866B027C; Tue, 13 Aug 2019 17:03:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0063.hostedemail.com [216.40.44.63])
	by kanga.kvack.org (Postfix) with ESMTP id 6E5166B027A
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 17:03:07 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 17C39181AC9AE
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 21:03:07 +0000 (UTC)
X-FDA: 75818629614.30.flame38_1b1d7c9904b1d
X-HE-Tag: flame38_1b1d7c9904b1d
X-Filterd-Recvd-Size: 4846
Received: from mga12.intel.com (mga12.intel.com [192.55.52.136])
	by imf22.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 21:03:06 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Aug 2019 14:03:05 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,382,1559545200"; 
   d="scan'208";a="187901529"
Received: from yyu32-desk1.sc.intel.com ([10.144.153.205])
  by orsmga002.jf.intel.com with ESMTP; 13 Aug 2019 14:03:04 -0700
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
Subject: [PATCH v8 23/27] x86/cet/shstk: ELF header parsing of Shadow Stack
Date: Tue, 13 Aug 2019 13:52:21 -0700
Message-Id: <20190813205225.12032-24-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190813205225.12032-1-yu-cheng.yu@intel.com>
References: <20190813205225.12032-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Look in .note.gnu.property of an ELF file and check if Shadow Stack needs
to be enabled for the task.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/Kconfig             |  2 ++
 arch/x86/include/asm/elf.h   | 13 +++++++++++++
 arch/x86/kernel/process_64.c | 34 ++++++++++++++++++++++++++++++++++
 3 files changed, 49 insertions(+)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index eaf86ef13348..7d13ba326962 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1947,6 +1947,8 @@ config X86_INTEL_SHADOW_STACK_USER
 	select ARCH_USES_HIGH_VMA_FLAGS
 	select X86_INTEL_CET
 	select ARCH_HAS_SHSTK
+	select ARCH_USE_GNU_PROPERTY
+	select ARCH_BINFMT_ELF_STATE
 	---help---
 	  Shadow stack provides hardware protection against program stack
 	  corruption.  Only when all the following are true will an application
diff --git a/arch/x86/include/asm/elf.h b/arch/x86/include/asm/elf.h
index 69c0f892e310..fac79b621e0a 100644
--- a/arch/x86/include/asm/elf.h
+++ b/arch/x86/include/asm/elf.h
@@ -367,6 +367,19 @@ extern int compat_arch_setup_additional_pages(struct linux_binprm *bprm,
 					      int uses_interp);
 #define compat_arch_setup_additional_pages compat_arch_setup_additional_pages
 
+#ifdef CONFIG_ARCH_BINFMT_ELF_STATE
+struct arch_elf_state {
+	unsigned int gnu_property;
+};
+
+#define INIT_ARCH_ELF_STATE {	\
+	.gnu_property = 0,	\
+}
+
+#define arch_elf_pt_proc(ehdr, phdr, elf, interp, state) (0)
+#define arch_check_elf(ehdr, interp, interp_ehdr, state) (0)
+#endif
+
 /* Do not change the values. See get_align_mask() */
 enum align_flags {
 	ALIGN_VA_32	= BIT(0),
diff --git a/arch/x86/kernel/process_64.c b/arch/x86/kernel/process_64.c
index af64519b2695..1232f7a6c023 100644
--- a/arch/x86/kernel/process_64.c
+++ b/arch/x86/kernel/process_64.c
@@ -818,3 +818,37 @@ unsigned long KSTK_ESP(struct task_struct *task)
 {
 	return task_pt_regs(task)->sp;
 }
+
+#ifdef CONFIG_ARCH_USE_GNU_PROPERTY
+int arch_parse_property(void *ehdr, void *phdr, struct file *f, bool inter,
+			struct arch_elf_state *state)
+{
+	int r = 0;
+	unsigned int property = 0;
+
+	r = get_gnu_property(ehdr, phdr, f, GNU_PROPERTY_X86_FEATURE_1_AND,
+			     &property);
+
+	if (r)
+		return r;
+
+	state->gnu_property = property;
+	return 0;
+}
+
+int arch_setup_property(struct arch_elf_state *state)
+{
+	int r = 0;
+
+	memset(&current->thread.cet, 0, sizeof(struct cet_status));
+
+	if (cpu_feature_enabled(X86_FEATURE_SHSTK)) {
+		if (state->gnu_property & GNU_PROPERTY_X86_FEATURE_1_SHSTK)
+			r = cet_setup_shstk();
+		if (r < 0)
+			return r;
+	}
+
+	return r;
+}
+#endif
-- 
2.17.1


