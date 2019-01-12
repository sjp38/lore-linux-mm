Return-Path: <SRS0=vc3H=PU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8364DC43387
	for <linux-mm@archiver.kernel.org>; Sat, 12 Jan 2019 11:16:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 413E720881
	for <linux-mm@archiver.kernel.org>; Sat, 12 Jan 2019 11:16:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 413E720881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C08368E0006; Sat, 12 Jan 2019 06:16:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B8D358E0002; Sat, 12 Jan 2019 06:16:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E5658E0006; Sat, 12 Jan 2019 06:16:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 41DF98E0002
	for <linux-mm@kvack.org>; Sat, 12 Jan 2019 06:16:40 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id z16so5838921wrt.5
        for <linux-mm@kvack.org>; Sat, 12 Jan 2019 03:16:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :in-reply-to:references:from:subject:to:cc:date;
        bh=l3CYpY4f+3RCpH2OxjenMawcRpPCRnkX9BOGGkPpiFg=;
        b=Upi7y4j3q8KeLIfdTmXumpu7kL9S0+XLL3uJjPLNyFL7PmrlBDdj1A4782iMEuqAcV
         kyowFpNUbvYqMkW9wNdvbmZq5XnYc5ZM03MMgGa3q3A+Bm+qYqMDshvPeL6dxnMnYAsG
         2e72G0EKldtETemJhiXQoT0wXNdV/P2Boy1CQCo0ydZMuZcF12gdm78AFCggLayM6rIR
         mjq8oqFeHfAcO1LvORgzQkF+cswZcZiABOtLzN4touAQNQAp2AdJr/GrtToSfdHvvXlZ
         sZnWRHCXpqSo+uhOymTdTdjJf9/NbiSB2KGGbC6Q0fb+/50x4GY98F4IGofGIe5z0mxN
         tymA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
X-Gm-Message-State: AJcUukfPJ8D+xK1FDAjTlRcsVKe2P6UtkhGxm9CMSMsfLt+wgIvTBqvw
	VgP3a5NggVMWMR9KnW9UhU+lFN3f7rayMNdSe2vuzsHHkTtOnOWLxMvm1UIgxhikivjJicHyiYy
	rnMsTa/0rhRTdB/1rP/i4aE0AhjtHPifCpm5fzpG4R6++8eAPZdpokuscwNMBTja8mg==
X-Received: by 2002:adf:ebd0:: with SMTP id v16mr18016035wrn.109.1547291799784;
        Sat, 12 Jan 2019 03:16:39 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7khc1JlV4q+mhBEm0uu509WG5X4GIIKss4cF7F74zkOr/QUBhtwY47k4LmupgMJPhqzqqm
X-Received: by 2002:adf:ebd0:: with SMTP id v16mr18015994wrn.109.1547291798847;
        Sat, 12 Jan 2019 03:16:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547291798; cv=none;
        d=google.com; s=arc-20160816;
        b=SIlQxVwVMp1QOAyDDMj/wlc5KCQOkGAKX/EBBSWJVH6xKHkXkWoEQMLlcCV7n5FrtJ
         8dRaY2XIElDw3d2hWDOybsIVuYASXZweRF+/TbCQf5oYglleeYcQhp3LV615vjtzRP8k
         5VUg7/POm5sEogTGz1karJQQO6B2gVLHp/4E5+KFMfi5t07lSxe2K64gsXEruELbwS/B
         CK6VuU/9HE5Ygj0tq9ElV9qVEmhRoodwhkePLcOMJJK/M/pd1GDL1qbimvLPOZbWwrld
         uYe6xPIASx6Va+LQiT9JoYIvykN401khQiSaeN90ZEATtvoYLU8y8LR3zJyGGjYvD6lA
         qxuw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id;
        bh=l3CYpY4f+3RCpH2OxjenMawcRpPCRnkX9BOGGkPpiFg=;
        b=nRGwBcD8Nb1+Tueg9/oC9a6k3nmi4Zug+NJVaaN94Y0FpEqHh7lwn0pEWJSitkiSbW
         WJSKExjhMYV+y82owsQV7UJ5eulsV89Cc/u7Uah69ycL96yNcqdbygCBRS9EYr05V09N
         u+PtnHje10P2ZiMDeEv+zp1DY8AIs9G1P/lqQ7a9rdf2YmtUm2/GsXrf92tbD2FzIhsu
         XUvVEBVw4XRdyOHL7YVfYFHB7e9GAD1Am7r1HGYHkkxP6FZ6Ct/j9MX4h8rU8EBut9Ed
         TBKin/Q8av2rqau1AyrZQKwX3UT+dCpGl+v1XHbFGu7LRcCXjRPu/QJ7BeEPe0LJAta6
         DlbA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id 68si10912801wra.172.2019.01.12.03.16.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 12 Jan 2019 03:16:38 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 43cHHR2p9wz9vBKC;
	Sat, 12 Jan 2019 12:16:35 +0100 (CET)
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id pV72o-t3R62E; Sat, 12 Jan 2019 12:16:35 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 43cHHR24JPz9vBJm;
	Sat, 12 Jan 2019 12:16:35 +0100 (CET)
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 3F2928B77F;
	Sat, 12 Jan 2019 12:16:38 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id qUlfOC1G1LsL; Sat, 12 Jan 2019 12:16:38 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 00DF28B74C;
	Sat, 12 Jan 2019 12:16:37 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id D580F717D8; Sat, 12 Jan 2019 11:16:37 +0000 (UTC)
Message-Id:
 <0c8b246b2b3b60dc0d642a4e33f635e1699dc739.1547289808.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1547289808.git.christophe.leroy@c-s.fr>
References: <cover.1547289808.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v3 2/3] powerpc/32: Move early_init() in a separate file
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, 
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Sat, 12 Jan 2019 11:16:37 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190112111637.yyHdcoZt6rs91NBRSxnaM3W58yrG3z1-MQib2O8_7GY@z>

In preparation of KASAN, move early_init() into a separate
file in order to allow deactivation of KASAN for that function.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/kernel/Makefile   |  2 +-
 arch/powerpc/kernel/early_32.c | 35 +++++++++++++++++++++++++++++++++++
 arch/powerpc/kernel/setup_32.c | 26 --------------------------
 3 files changed, 36 insertions(+), 27 deletions(-)
 create mode 100644 arch/powerpc/kernel/early_32.c

diff --git a/arch/powerpc/kernel/Makefile b/arch/powerpc/kernel/Makefile
index cb7f0bb9ee71..879b36602748 100644
--- a/arch/powerpc/kernel/Makefile
+++ b/arch/powerpc/kernel/Makefile
@@ -93,7 +93,7 @@ extra-y				+= vmlinux.lds
 
 obj-$(CONFIG_RELOCATABLE)	+= reloc_$(BITS).o
 
-obj-$(CONFIG_PPC32)		+= entry_32.o setup_32.o
+obj-$(CONFIG_PPC32)		+= entry_32.o setup_32.o early_32.o
 obj-$(CONFIG_PPC64)		+= dma-iommu.o iommu.o
 obj-$(CONFIG_KGDB)		+= kgdb.o
 obj-$(CONFIG_BOOTX_TEXT)	+= btext.o
diff --git a/arch/powerpc/kernel/early_32.c b/arch/powerpc/kernel/early_32.c
new file mode 100644
index 000000000000..b3e40d6d651c
--- /dev/null
+++ b/arch/powerpc/kernel/early_32.c
@@ -0,0 +1,35 @@
+// SPDX-License-Identifier: GPL-2.0
+
+/*
+ * Early init before relocation
+ */
+
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <asm/setup.h>
+#include <asm/sections.h>
+
+/*
+ * We're called here very early in the boot.
+ *
+ * Note that the kernel may be running at an address which is different
+ * from the address that it was linked at, so we must use RELOC/PTRRELOC
+ * to access static data (including strings).  -- paulus
+ */
+notrace unsigned long __init early_init(unsigned long dt_ptr)
+{
+	unsigned long offset = reloc_offset();
+
+	/* First zero the BSS */
+	memset(PTRRELOC(&__bss_start), 0, __bss_stop - __bss_start);
+
+	/*
+	 * Identify the CPU type and fix up code sections
+	 * that depend on which cpu we have.
+	 */
+	identify_cpu(offset, mfspr(SPRN_PVR));
+
+	apply_feature_fixups();
+
+	return KERNELBASE + offset;
+}
diff --git a/arch/powerpc/kernel/setup_32.c b/arch/powerpc/kernel/setup_32.c
index 5e761eb16a6d..b46a9a33225b 100644
--- a/arch/powerpc/kernel/setup_32.c
+++ b/arch/powerpc/kernel/setup_32.c
@@ -63,32 +63,6 @@ EXPORT_SYMBOL(DMA_MODE_READ);
 EXPORT_SYMBOL(DMA_MODE_WRITE);
 
 /*
- * We're called here very early in the boot.
- *
- * Note that the kernel may be running at an address which is different
- * from the address that it was linked at, so we must use RELOC/PTRRELOC
- * to access static data (including strings).  -- paulus
- */
-notrace unsigned long __init early_init(unsigned long dt_ptr)
-{
-	unsigned long offset = reloc_offset();
-
-	/* First zero the BSS */
-	memset(PTRRELOC(&__bss_start), 0, __bss_stop - __bss_start);
-
-	/*
-	 * Identify the CPU type and fix up code sections
-	 * that depend on which cpu we have.
-	 */
-	identify_cpu(offset, mfspr(SPRN_PVR));
-
-	apply_feature_fixups();
-
-	return KERNELBASE + offset;
-}
-
-
-/*
  * This is run before start_kernel(), the kernel has been relocated
  * and we are running with enough of the MMU enabled to have our
  * proper kernel virtual addresses
-- 
2.13.3

