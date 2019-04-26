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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48FC7C43218
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:44:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F0DA8208C2
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:44:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JScJif31"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0DA8208C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CA3E06B0278; Sat, 27 Apr 2019 02:43:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C54656B0279; Sat, 27 Apr 2019 02:43:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD4A46B027A; Sat, 27 Apr 2019 02:43:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 728B86B0278
	for <linux-mm@kvack.org>; Sat, 27 Apr 2019 02:43:38 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id l13so3503920pgp.3
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 23:43:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=p6XVxxmeId6Fyrw7m3B0ifgQzW6nhwdk5H1SAhfRKS0=;
        b=RTcpy+NiC7R7PpBw+ceRfAGSTppaDldn2RDmHu9JdKrcXLuTv7mw/Somu/uBJHLWjg
         qTczf1mEKbL88YbVt3zoztYaTkrSZjWCNcMKdz/yNZxKW79kSkl/8/RuxisgRTojd9EU
         dT8k8lcdrv7ak8dTrR4HUtS2nSkXy8Z3jHBfLpwqQssEchhb90wHu8JVEmCqS0mCRAMW
         IrKehKihLntPKPE3Uxmm00Vu9IyemujRN17smK8ScQuGX1ArXnJ+2kFdRHxkfOKM/GJc
         +iwx9u6qSrmMvMfuZghHSBH5q+yaqy2XJaaucnjsJTfMG6ntJ9EpK1cNngGJfvH0eju/
         krGQ==
X-Gm-Message-State: APjAAAWO7PKC99ofUHDBDR1pPe4kCPnjlxpWjw1ILy3F75060Y8xRp0O
	k/0RBj4VDTGROVJ+ukMFJ8Y+KfXAf47V9NGKLC0eImrpZp607FclC+nSAF05VpP8ZfqEedwZLkB
	LpnDr91Vd5EsibdCUL4Vi2f74cd33l05KflBhO6N0GXyBiblvRj0wJCkLwS00gjq28g==
X-Received: by 2002:a63:5166:: with SMTP id r38mr7836282pgl.429.1556347418155;
        Fri, 26 Apr 2019 23:43:38 -0700 (PDT)
X-Received: by 2002:a63:5166:: with SMTP id r38mr7836252pgl.429.1556347417503;
        Fri, 26 Apr 2019 23:43:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556347417; cv=none;
        d=google.com; s=arc-20160816;
        b=KEnpMbqyOGnwZudvoXbs8vNZ0854cG1ExsVWLUyQ2QcKpcDqOVa7iJjN6/5NEWQ2N/
         kJndYRwlGEIh4LH6X98oIWAhJ2erL27ji0PinbwI1Y6GpS1VKDr9lTjhNhv6/eAhHlpq
         5KHgn3fic/eDAtyV/qUskwlmJxCdROCVRfJ3FReig2b/toUZ07I/o2R5n8Hqls/CDSMv
         h2KU/HAywlkv5wyfiI0WW0B0PF1mf1DdwPiRAesI566E+dvogSHKfRXDj5uCr/2OchLq
         QF8SUdsL4x/3nIPo+L12UrcGyI/wK2oPUGgbmIQoM00lGEMpLCV6EoDQhh9rBahgg5W2
         PDeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=p6XVxxmeId6Fyrw7m3B0ifgQzW6nhwdk5H1SAhfRKS0=;
        b=UZzoysDNTOglg2FvotNOaH+KdUGRhhtr2uG4jdQ3HJcnyAYccyCLD8kgc8W9VHyyo6
         KR8e1290s0Ur+hukRIQKQ3yF9G7MZsIEpb7sfQOzZuJKWZUZndTPL2fGMJc+dOVbeafR
         CyemrbJosLxaFPwA9nzKhHtFUwINMuLpvwZROBoes82iCMQDZTVlo9VJmgqbdlpKrSJ/
         xikrW9ZYttBEjZVydH952iBB+TJ2UZbN5PK4jqQdznl7e8MtM0whHNC+uLWIBhAWHIBO
         3Rygw1pX095T3c8J2g+ForuHJeemwi8Co8RMTgCCEd/YY986PJsSrlsHqb8xPz6bQaos
         wKEg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JScJif31;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i36sor26615136plb.39.2019.04.26.23.43.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Apr 2019 23:43:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JScJif31;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=p6XVxxmeId6Fyrw7m3B0ifgQzW6nhwdk5H1SAhfRKS0=;
        b=JScJif310IMh72ZohwOauSCAwdoUkuEv8bR6xdhJcKtk1RynLwO3Yk/O8uL4tZE53n
         NrQxpNK4N1uzjciA1sdkWWtPp8ycpHXFn7qqLzJr7tYIRLsxhiosMqxmPVmHzIChx8+N
         dySb7k6fhrhmrpcilrlJoW9blvaY3Q+PCSiONh6FBKvoxbL7qSMy7/IzPS7lXjYYk3R/
         KYc3BtX2zUuYUpbQToVTJQ3xLcXFtZGa0gKnazTNuB9oRgES+e5Dt6lyOMWvmuEim8L6
         0oOzDDk8SIoEGUBtvVZ7G2upgHOvvdwFGoH6Y4DMveFflSyOioLkC8F7etEF6M59+eVc
         h1Dg==
X-Google-Smtp-Source: APXvYqy73yIN4FITPLecL8eRrrVFTQfYnIM8wwU5XCBZXYl3CE93cW/V+JNeu8zKe2r7aDykFyaZUg==
X-Received: by 2002:a17:902:d83:: with SMTP id 3mr52113119plv.125.1556347416975;
        Fri, 26 Apr 2019 23:43:36 -0700 (PDT)
Received: from sc2-haas01-esx0118.eng.vmware.com ([66.170.99.1])
        by smtp.gmail.com with ESMTPSA id j22sm36460145pfn.129.2019.04.26.23.43.35
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 23:43:36 -0700 (PDT)
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
	Nadav Amit <namit@vmware.com>
Subject: [PATCH v6 23/24] mm/tlb: Provide default nmi_uaccess_okay()
Date: Fri, 26 Apr 2019 16:23:02 -0700
Message-Id: <20190426232303.28381-24-nadav.amit@gmail.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190426232303.28381-1-nadav.amit@gmail.com>
References: <20190426232303.28381-1-nadav.amit@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

x86 has an nmi_uaccess_okay(), but other architectures do not.
Arch-independent code might need to know whether access to user
addresses is ok in an NMI context or in other code whose execution
context is unknown.  Specifically, this function is needed for
bpf_probe_write_user().

Add a default implementation of nmi_uaccess_okay() for architectures
that do not have such a function.

Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/include/asm/tlbflush.h | 2 ++
 include/asm-generic/tlb.h       | 9 +++++++++
 2 files changed, 11 insertions(+)

diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index 90926e8dd1f8..dee375831962 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -274,6 +274,8 @@ static inline bool nmi_uaccess_okay(void)
 	return true;
 }
 
+#define nmi_uaccess_okay nmi_uaccess_okay
+
 /* Initialize cr4 shadow for this CPU. */
 static inline void cr4_init_shadow(void)
 {
diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index b9edc7608d90..480e5b2a5748 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -21,6 +21,15 @@
 #include <asm/tlbflush.h>
 #include <asm/cacheflush.h>
 
+/*
+ * Blindly accessing user memory from NMI context can be dangerous
+ * if we're in the middle of switching the current user task or switching
+ * the loaded mm.
+ */
+#ifndef nmi_uaccess_okay
+# define nmi_uaccess_okay() true
+#endif
+
 #ifdef CONFIG_MMU
 
 /*
-- 
2.17.1

