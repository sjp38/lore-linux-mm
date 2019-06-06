Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF77AC04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:17:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B6CA208C3
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:17:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B6CA208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7FCD66B02CC; Thu,  6 Jun 2019 16:17:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 42BCA6B02D2; Thu,  6 Jun 2019 16:17:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE0556B02CC; Thu,  6 Jun 2019 16:17:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2F03D6B02CA
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:17:34 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id s12so2178861plr.5
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:17:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to
         :subject:date:message-id:in-reply-to:references;
        bh=Hx9fQCfaehHECdP3yUizJoBr9I2sEjxAxWtfgK/yKTI=;
        b=STPXUahj12rqDzCZEoXhDAllgnMezT95+9RtTgT2xb+EhTQ2lr2f/4An38RVSNT+FH
         2UDb9CwmQVgsbGkul76FJ48IfWukSEc3hWX5UjKhoHlIbR27+zV88ts5Ayu9QqMMQs+X
         LOzSuuiC2Cjf14zlufo+CgILtTHT7PXXytjlavPOFhF9vRiB3uyfx5ezj5lsH83iZSDq
         gAqEtjTeO25nHoJqZWRwS6xOwT8/WW6mqdujJpmNlMnLfXKR8g6JBwtEYN6Aq/LBrm0y
         R0zl/GfAFVFCh/WSupZAmF90+dIC9w8moYWAeG4HmzthhldQ/WnU4dGXa1IHhaSQw+po
         IhhA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU2/e+DNEqcPYjTM/+jU5VBVnJINR3xYw+3pyGBNJEDqU55uvRX
	BDJnsIUS3l0eAuc2kOfGmVHrz6xp0w5/Rfaf5+unDbefeo2wOi56FMaE6cy8Dg53ogbEemYpKGk
	URPu1hjUWj859JgJWdovdk3u1rgXp1xigFCirYg/vgAcW5GMDuVF9OcJyLa/s1p6zQw==
X-Received: by 2002:a17:902:7003:: with SMTP id y3mr52080652plk.70.1559852253858;
        Thu, 06 Jun 2019 13:17:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx8v11zYNr78rPRmoIaelqPmiM6j1XCexI3tWll0ujRDQOvmh2V5U4uqAU29z0Eziw8yDJu
X-Received: by 2002:a17:902:7003:: with SMTP id y3mr52080571plk.70.1559852252590;
        Thu, 06 Jun 2019 13:17:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852252; cv=none;
        d=google.com; s=arc-20160816;
        b=xsfriLt7oXl8uY0lyMFAm1xPpeedsBgOxit19mHRVecPxOUjlaJpY6SDZK+C8J7ONr
         lIrWzTeIfw9HLEPOUJCVM/YsbBd95EGMur3GI16P/yvIRXGEcnoEzW2CyKUafN1/3W73
         GWcFR9lAvWMurryesbrFLQ1QSZwZgFHGuh9fnMjB5u8JJx7N0wse/6807x52JFPl148N
         VvmGkK29LLAxMKeaUk0XaMiaDwQC2lP7ifrwtnOoWSlSqwhj/joCMP96fQ82rks/IQ4j
         vaLnaE87/GN1NGI42T5nssOX74PE3i6znAh1B5c3D0N8GyEhJoyAGdwuuMpgsbu62csr
         OZjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:to:from;
        bh=Hx9fQCfaehHECdP3yUizJoBr9I2sEjxAxWtfgK/yKTI=;
        b=yvwYHlECx4wTP+sgjiI0UYHStY8gzEb8nADy9dxi8KihmtMNGAG2nPPFdSSW2jTSEl
         aABMjLODVOGbpIoaZRPIipMKU8NIbB2l4JZh95RToPvuApa0jJ3T15X5McKTLpLjcTCc
         jn4C68Xm8SohiBdz05RHxM6vbIqjPew8I8eXhfIUamALG3JCybCvNZTUqZ3LOWzkg5uM
         fvLhblt32gHW+CePcBeeTMZUMqaaO8CeqQc1QXO82ickYia5VQK5vuklfQJdxVCyhtUA
         X7nHqzkeIkP3S0Fo2FmCNaUihQd8zJXJY28FW8zFfxx4hWZdneCzZXOsLsI/EG+emkIr
         Yn/A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id t11si66755plr.23.2019.06.06.13.17.32
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
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 13:17:32 -0700
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
Subject: [PATCH v7 09/14] x86/vdso: Insert endbr32/endbr64 to vDSO
Date: Thu,  6 Jun 2019 13:09:21 -0700
Message-Id: <20190606200926.4029-10-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190606200926.4029-1-yu-cheng.yu@intel.com>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "H.J. Lu" <hjl.tools@gmail.com>

When Intel indirect branch tracking is enabled, functions in vDSO which
may be called indirectly must have endbr32 or endbr64 as the first
instruction.  Compiler must support -fcf-protection=branch so that it
can be used to compile vDSO.

Signed-off-by: H.J. Lu <hjl.tools@gmail.com>
---
 arch/x86/entry/vdso/Makefile          | 12 +++++++++++-
 arch/x86/entry/vdso/vdso-layout.lds.S |  1 +
 2 files changed, 12 insertions(+), 1 deletion(-)

diff --git a/arch/x86/entry/vdso/Makefile b/arch/x86/entry/vdso/Makefile
index 42fe42e82baf..718fc17b0d67 100644
--- a/arch/x86/entry/vdso/Makefile
+++ b/arch/x86/entry/vdso/Makefile
@@ -108,13 +108,17 @@ vobjx32s := $(foreach F,$(vobjx32s-y),$(obj)/$F)
 
 # Convert 64bit object file to x32 for x32 vDSO.
 quiet_cmd_x32 = X32     $@
-      cmd_x32 = $(OBJCOPY) -O elf32-x86-64 $< $@
+      cmd_x32 = $(OBJCOPY) -R .note.gnu.property -O elf32-x86-64 $< $@
 
 $(obj)/%-x32.o: $(obj)/%.o FORCE
 	$(call if_changed,x32)
 
 targets += vdsox32.lds $(vobjx32s-y)
 
+ifdef CONFIG_X86_INTEL_BRANCH_TRACKING_USER
+    $(obj)/vclock_gettime.o $(obj)/vgetcpu.o $(obj)/vdso32/vclock_gettime.o: KBUILD_CFLAGS += -fcf-protection=branch
+endif
+
 $(obj)/%.so: OBJCOPYFLAGS := -S
 $(obj)/%.so: $(obj)/%.so.dbg FORCE
 	$(call if_changed,objcopy)
@@ -173,6 +177,12 @@ quiet_cmd_vdso = VDSO    $@
 VDSO_LDFLAGS = -shared $(call ld-option, --hash-style=both) \
 	$(call ld-option, --build-id) $(call ld-option, --eh-frame-hdr) \
 	-Bsymbolic
+ifdef CONFIG_X86_INTEL_BRANCH_TRACKING_USER
+  VDSO_LDFLAGS += $(call ldoption, -z$(comma)ibt)
+endif
+ifdef CONFIG_X86_INTEL_SHADOW_STACK_USER
+  VDSO_LDFLAGS += $(call ldoption, -z$(comma)shstk)
+endif
 GCOV_PROFILE := n
 
 #
diff --git a/arch/x86/entry/vdso/vdso-layout.lds.S b/arch/x86/entry/vdso/vdso-layout.lds.S
index 93c6dc7812d0..3fea2ce318bc 100644
--- a/arch/x86/entry/vdso/vdso-layout.lds.S
+++ b/arch/x86/entry/vdso/vdso-layout.lds.S
@@ -52,6 +52,7 @@ SECTIONS
 		*(.gnu.linkonce.b.*)
 	}						:text
 
+	.note.gnu.property : { *(.note.gnu.property) }	:text	:note
 	.note		: { *(.note.*) }		:text	:note
 
 	.eh_frame_hdr	: { *(.eh_frame_hdr) }		:text	:eh_frame_hdr
-- 
2.17.1

