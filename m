Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8635BC43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:32:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D00C2084F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:32:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D00C2084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6826D6B0269; Fri, 26 Apr 2019 03:31:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 26CE26B026A; Fri, 26 Apr 2019 03:31:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D97366B000E; Fri, 26 Apr 2019 03:31:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 513D46B0010
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 03:31:48 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id x2so1500328pge.16
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:31:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=fM02CdP3EHsEznyJ/zI3DVkvywjW2Y0W5QE/m/kGqS8=;
        b=Pb9cpKScgKGeExDhe8wM+s9431ECWwdnTjH1NEIgCeNfXY9qUBzdDy++R77b3yyHeX
         utvYIw+Ki50tW9lI5yNDnG5WFd0onahoQJ6SMQ15+fpmwytShHELtUiO2H+f2KRozqWH
         oO43qlZyNqAfXvTiWkeVmmeog4ufQhn9nnAcMh/k1WEiC2z78Erm0+4D5nZdauZ2mD4r
         biyNqlvbQuNWc7MU9aLJinQd21vQQkpTgseoNqmzhhsJkX03Xgv9X6ikEofcWogYVlcc
         A6EbskLvAZ7W7OMSEau3y7u5FshVzlqAjpNFphoac+RI78f803khifaVsXW35Al1QPUu
         r/mQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAV3ZNUeN/xcqLCr4QhLGUPquY1A+TleLi6FZTUJNMolWHwqt/qx
	CHppnbkQ3aLHZ1tj6NjSE9m4HSFeTToKxPMTnRkJq12Ne29XygSB6IGnsG3HfPmyfbUF1Wm5f66
	c2M2+KETCz5F/zLcUfLWc6aPCO+SRHVHo9EbZQ0sb6xOXui5EWCrNKrJGpLybvoO1Zg==
X-Received: by 2002:a62:ae0f:: with SMTP id q15mr11015424pff.238.1556263907789;
        Fri, 26 Apr 2019 00:31:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyuMfgiag3mPiU52KnyusRS+KjA4Lrru8Asf0XkvhgJBGAScUyigznveRJDq331OSjmjgQR
X-Received: by 2002:a62:ae0f:: with SMTP id q15mr11015319pff.238.1556263906333;
        Fri, 26 Apr 2019 00:31:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556263906; cv=none;
        d=google.com; s=arc-20160816;
        b=X7fqCsVZzXTvqnqBrreUgnZOzgt0vPhWGOHlHLpg+Ov4KXJ+hkCC6X2fmxXHoAZYyI
         zyaKMjjUCWbOqL+NCgkDyMFvrEkUQCy8RwNFxQq3S/kJQ/AvzptwCLS/HnO0gnDrHO3W
         +zqoBk+WoOcMXYfTlgsJ2w7JtSYMqysEPCN8HdzAywLRhnhJZ4FdlT5T/8ol7u/kBVnx
         XMtHsqYxOhz3bsEU9Y5N0IgWygoVB6W92hOKNOHNlNo17yDVbhQKRLfyrVT4f6hnAcF5
         /QeXoK4Ijv6l6MlhUSK2mlrgtDZKGdzJK2RNHvVoxzTBrDAwWYn6bTkPSoUgX0oYwFNP
         wy8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=fM02CdP3EHsEznyJ/zI3DVkvywjW2Y0W5QE/m/kGqS8=;
        b=NlZqRKQ2gedf0EuJ+EDu6zGjOXPjra4SOAmMDb3v2ANvBy/hxii3DmRXaOGOd92kvn
         l5NUhacyPGzojWcHcHFYq8qEuuWoz7P/qmDm6cDlSayjDtKBFOCVPS/BqWLJls7pTBdc
         NZN4ZrBvTpusNPwhzx071jGMEZhRFQfwmSC3qfU/mCU2ogs1As4508p6QHpMdbbRrFI+
         4bVDx+whr02iPLsxSoffolXHy0f2MHg3YrNuVM0ePE8jn1ubtHRxjjbdL/z5bFo3xCAc
         khNdnUEIGQ4R8aNvK8KDclMzLXHCu+uXTWJtfgHl6U8qFRTmF5M1k/7Fi0L/dFCx0bhF
         CKjw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-002.vmware.com (ex13-edg-ou-002.vmware.com. [208.91.0.190])
        by mx.google.com with ESMTPS id f9si22844507pgq.347.2019.04.26.00.31.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 26 Apr 2019 00:31:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) client-ip=208.91.0.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost3.vmware.com (10.113.161.73) by
 EX13-EDG-OU-002.vmware.com (10.113.208.156) with Microsoft SMTP Server id
 15.0.1156.6; Fri, 26 Apr 2019 00:31:44 -0700
Received: from sc2-haas01-esx0118.eng.vmware.com (sc2-haas01-esx0118.eng.vmware.com [10.172.44.118])
	by sc9-mailhost3.vmware.com (Postfix) with ESMTP id 77C0D412A1;
	Fri, 26 Apr 2019 00:31:45 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
To: Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>
CC: <linux-kernel@vger.kernel.org>, <x86@kernel.org>, <hpa@zytor.com>, Thomas
 Gleixner <tglx@linutronix.de>, Nadav Amit <nadav.amit@gmail.com>, Dave Hansen
	<dave.hansen@linux.intel.com>, <linux_dti@icloud.com>,
	<linux-integrity@vger.kernel.org>, <linux-security-module@vger.kernel.org>,
	<akpm@linux-foundation.org>, <kernel-hardening@lists.openwall.com>,
	<linux-mm@kvack.org>, <will.deacon@arm.com>, <ard.biesheuvel@linaro.org>,
	<kristen@linux.intel.com>, <deneen.t.dock@intel.com>, Rick Edgecombe
	<rick.p.edgecombe@intel.com>, Kees Cook <keescook@chromium.org>, Dave Hansen
	<dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>
Subject: [PATCH v5 03/23] x86/mm: Introduce temporary mm structs
Date: Thu, 25 Apr 2019 17:11:23 -0700
Message-ID: <20190426001143.4983-4-namit@vmware.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190426001143.4983-1-namit@vmware.com>
References: <20190426001143.4983-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain
Received-SPF: None (EX13-EDG-OU-002.vmware.com: namit@vmware.com does not
 designate permitted sender hosts)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Andy Lutomirski <luto@kernel.org>

Using a dedicated page-table for temporary PTEs prevents other cores
from using - even speculatively - these PTEs, thereby providing two
benefits:

(1) Security hardening: an attacker that gains kernel memory writing
abilities cannot easily overwrite sensitive data.

(2) Avoiding TLB shootdowns: the PTEs do not need to be flushed in
remote page-tables.

To do so a temporary mm_struct can be used. Mappings which are private
for this mm can be set in the userspace part of the address-space.
During the whole time in which the temporary mm is loaded, interrupts
must be disabled.

The first use-case for temporary mm struct, which will follow, is for
poking the kernel text.

[ Commit message was written by Nadav Amit ]

Cc: Kees Cook <keescook@chromium.org>
Cc: Dave Hansen <dave.hansen@intel.com>
Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Reviewed-by: Masami Hiramatsu <mhiramat@kernel.org>
Tested-by: Masami Hiramatsu <mhiramat@kernel.org>
Signed-off-by: Andy Lutomirski <luto@kernel.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/include/asm/mmu_context.h | 33 ++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index 19d18fae6ec6..24dc3b810970 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -356,4 +356,37 @@ static inline unsigned long __get_current_cr3_fast(void)
 	return cr3;
 }
 
+typedef struct {
+	struct mm_struct *mm;
+} temp_mm_state_t;
+
+/*
+ * Using a temporary mm allows to set temporary mappings that are not accessible
+ * by other CPUs. Such mappings are needed to perform sensitive memory writes
+ * that override the kernel memory protections (e.g., W^X), without exposing the
+ * temporary page-table mappings that are required for these write operations to
+ * other CPUs. Using a temporary mm also allows to avoid TLB shootdowns when the
+ * mapping is torn down.
+ *
+ * Context: The temporary mm needs to be used exclusively by a single core. To
+ *          harden security IRQs must be disabled while the temporary mm is
+ *          loaded, thereby preventing interrupt handler bugs from overriding
+ *          the kernel memory protection.
+ */
+static inline temp_mm_state_t use_temporary_mm(struct mm_struct *mm)
+{
+	temp_mm_state_t temp_state;
+
+	lockdep_assert_irqs_disabled();
+	temp_state.mm = this_cpu_read(cpu_tlbstate.loaded_mm);
+	switch_mm_irqs_off(NULL, mm, current);
+	return temp_state;
+}
+
+static inline void unuse_temporary_mm(temp_mm_state_t prev_state)
+{
+	lockdep_assert_irqs_disabled();
+	switch_mm_irqs_off(NULL, prev_state.mm, current);
+}
+
 #endif /* _ASM_X86_MMU_CONTEXT_H */
-- 
2.17.1

