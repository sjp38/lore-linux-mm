Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 75A696B0279
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 19:26:50 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id j124so851883ith.3
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 16:26:50 -0700 (PDT)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0086.outbound.protection.outlook.com. [104.47.37.86])
        by mx.google.com with ESMTPS id u10si168482ota.11.2016.08.22.16.26.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 22 Aug 2016 16:26:49 -0700 (PDT)
Subject: [RFC PATCH v1 15/28] x86: Unroll string I/O when SEV is active
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Mon, 22 Aug 2016 19:26:40 -0400
Message-ID: <147190840032.9523.7491479364800390492.stgit@brijesh-build-machine>
In-Reply-To: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, linux-crypto@vger.kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

From: Tom Lendacky <thomas.lendacky@amd.com>

Secure Encrypted Virtualization (SEV) does not support string I/O, so
unroll the string I/O operation into a loop operating on one element at
a time.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/io.h |   26 ++++++++++++++++++++++----
 1 file changed, 22 insertions(+), 4 deletions(-)

diff --git a/arch/x86/include/asm/io.h b/arch/x86/include/asm/io.h
index de25aad..130b3e2 100644
--- a/arch/x86/include/asm/io.h
+++ b/arch/x86/include/asm/io.h
@@ -303,14 +303,32 @@ static inline unsigned type in##bwl##_p(int port)			\
 									\
 static inline void outs##bwl(int port, const void *addr, unsigned long count) \
 {									\
-	asm volatile("rep; outs" #bwl					\
-		     : "+S"(addr), "+c"(count) : "d"(port));		\
+	if (sev_active) {						\
+		unsigned type *value = (unsigned type *)addr;		\
+		while (count) {						\
+			out##bwl(*value, port);				\
+			value++;					\
+			count--;					\
+		}							\
+	} else {							\
+		asm volatile("rep; outs" #bwl				\
+			     : "+S"(addr), "+c"(count) : "d"(port));	\
+	}								\
 }									\
 									\
 static inline void ins##bwl(int port, void *addr, unsigned long count)	\
 {									\
-	asm volatile("rep; ins" #bwl					\
-		     : "+D"(addr), "+c"(count) : "d"(port));		\
+	if (sev_active) {						\
+		unsigned type *value = (unsigned type *)addr;		\
+		while (count) {						\
+			*value = in##bwl(port);				\
+			value++;					\
+			count--;					\
+		}							\
+	} else {							\
+		asm volatile("rep; ins" #bwl				\
+			     : "+D"(addr), "+c"(count) : "d"(port));	\
+	}								\
 }
 
 BUILDIO(b, b, char)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
