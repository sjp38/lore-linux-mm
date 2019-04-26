Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.8 required=3.0 tests=DATE_IN_PAST_06_12,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B19CC43218
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:43:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C61A42087C
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:43:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Bic4fgDh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C61A42087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B02D6B0008; Sat, 27 Apr 2019 02:43:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 839566B000A; Sat, 27 Apr 2019 02:43:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D9BC6B000C; Sat, 27 Apr 2019 02:43:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 334C46B0008
	for <linux-mm@kvack.org>; Sat, 27 Apr 2019 02:43:09 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id q18so3232235pll.16
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 23:43:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=fM02CdP3EHsEznyJ/zI3DVkvywjW2Y0W5QE/m/kGqS8=;
        b=U7LrD0V4LLPfC4D1y/s4x8yNq4LWaCFm1uHiqPTh3c2581DJn/fZK43RzE/vGnJLtl
         z4meupkFyfSOJ876g/d3TBeA2a4vXlIQILFl1rYRqzaBXP7k+aAoNcpwT5nM97RzT+m+
         I2sn0IxR0Dm+fJz7b5va0W0V9bQS573wJjmR5J7fBiSL02ohBK/zDZav3PcUj99HJLn/
         9qnYpfa/vPOeHFC6xrrRYzbWrBcqVKtXuuuPK4D74HMn82w0TmQ/MeuWunraSZUVistk
         XHnTclndsjnPeWo5wm1t4lCvxfyKeNil6vXrmHu67KzH24imqZTJEXcm+nf1/KkOExKH
         +Xzg==
X-Gm-Message-State: APjAAAW4oTX52RIzbYgfWQ+e2oZQRUmx3lYtWo+Mmt5mfOWi5Mb0Ldxc
	RTqc6EXOKE3akt7Sy6UU6EtsNKMwGeJgNdrO+ywYHRVhRD7aCnHuIvofff8Zb1zfhLmezPZWeX6
	klo7WnCeWe0o4SbQ7RFotoRpE36PkvOLGgZT7GqKBJFHIMz5Vwed1C4tUgypl5oC6aA==
X-Received: by 2002:aa7:9294:: with SMTP id j20mr52918429pfa.64.1556347388739;
        Fri, 26 Apr 2019 23:43:08 -0700 (PDT)
X-Received: by 2002:aa7:9294:: with SMTP id j20mr52918363pfa.64.1556347387552;
        Fri, 26 Apr 2019 23:43:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556347387; cv=none;
        d=google.com; s=arc-20160816;
        b=xZTjTc0yp8T7e616wot5vcfXXjuZlueYvvf2aixdfpx8EccjXAyqXknCQJhii3YI5l
         D3yOsdem/k0JDpLlm6YiWHTRo3OpvklOWS9ntfBbxkkgx0Y8b3LekTD7J2bTJHvePhja
         iy6V7kK2M2CqPUBQUVuXTfRIv3TSBF3k3NM8syPfG/7bo03bh0vRdMFG2qF8qi27T92/
         QvV1gb2AhP1I4OHaIC9ktIRUsots5g2hwqq/ZsZprdWm1o6nvGJ0nsPgohHftCEv8WNu
         2i12vkkNWxbiyfp1NaeU1kWfF7yuggW/PBpq84J2DfH28LgxWfoJdTi2nQf8SDGxyYz+
         vO/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=fM02CdP3EHsEznyJ/zI3DVkvywjW2Y0W5QE/m/kGqS8=;
        b=kTESvyOURJ8vHfH8CU1xB8n+UIJCTlb4BdJD3XwWVylUgmGYWp2K3iPSFwzI8QXRaP
         B4qifCQI5uAzayqQVTfln/qeD6iHbV9uIp0pWNnpsfEdKwIdNrGr8CbQcA/22vO1CPz8
         6q+rhIloAqctvyKjaqKL75bxaG9oBhFPNZdRGgCZHFkaKD6n/oOU0BwEVkRAdjbolkeq
         4QOqZLTGs5TKSU90I3QvP0Kj5DXTU+C/gfq1Uq3gDImxq7T8jf2mUMKEzQ+bVU4HNNLP
         e7MWMxUxBCDtUkpo4SCBnw2DwfXsjWuxJUddCMwTntV7cDIL3FU7ShdC0hbKTKaQPXDf
         agww==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Bic4fgDh;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v6sor26413438plp.3.2019.04.26.23.43.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Apr 2019 23:43:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Bic4fgDh;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=fM02CdP3EHsEznyJ/zI3DVkvywjW2Y0W5QE/m/kGqS8=;
        b=Bic4fgDhw/zNUsH9AvCevjRRuqcBr7SeEwPi/mNBJHeVn3HWTtTQy0lqVBwB+uwJON
         033sEQUJVf4JsE8w16M+5haGmPR56gXJit7dknF2eDmFepylyOdGJlykH0b1NW+PihEa
         WnVuUa5XLxRLLr06QvgHjZbZbm6umZ2Z7Tk21XFYdu0XsSy3LVhSR76ovrEOyDS4RqXk
         ethcFURK2XAu1qKbwE8JJm/EyYlwhoXg4rc/DRAR47BR1Lx07vr+RFt4HZ8bItbsDTBV
         RxWJwnwgvwuNGmSEvPkHWRxMq59R7mUfHELo2gZLY6QtoYxwGmeesmwvk7AesQMYnBzh
         N2AQ==
X-Google-Smtp-Source: APXvYqxN6NLybNs8lwtcaE7rd9moWK47+PtSS3OruWZmc0YNonCQSY0zJUJKCwxGbV5SIYzeiwOfdw==
X-Received: by 2002:a17:902:d83:: with SMTP id 3mr52111624plv.125.1556347387028;
        Fri, 26 Apr 2019 23:43:07 -0700 (PDT)
Received: from sc2-haas01-esx0118.eng.vmware.com ([66.170.99.1])
        by smtp.gmail.com with ESMTPSA id j22sm36460145pfn.129.2019.04.26.23.43.05
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 23:43:06 -0700 (PDT)
From: nadav.amit@gmail.com
To: Peter Zijlstra <peterz@infradead.org>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
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
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Nadav Amit <namit@vmware.com>
Subject: [PATCH v6 03/24] x86/mm: Introduce temporary mm structs
Date: Fri, 26 Apr 2019 16:22:42 -0700
Message-Id: <20190426232303.28381-4-nadav.amit@gmail.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190426232303.28381-1-nadav.amit@gmail.com>
References: <20190426232303.28381-1-nadav.amit@gmail.com>
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

