Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C373C282E1
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 18:58:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF6652175B
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 18:58:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF6652175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 386EF6B0003; Mon, 22 Apr 2019 14:58:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 30CC76B0007; Mon, 22 Apr 2019 14:58:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C2946B000D; Mon, 22 Apr 2019 14:58:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id CB5BF6B0003
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 14:58:43 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id o8so8479682pgq.5
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 11:58:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=2uQh+p4niM1XazCyX0W8SClLNopGSLFeOTKZKD97XRE=;
        b=n4Iwd7t0W2867DU6O4oY3WWOIQx2wBP93LnxYFdXpPKcfR51Bs6IFW0NcECLlMrRrL
         EGOH+ot+K7jK/2xlCXD724m+BKNXMehFL/ss8MX13UEBqZV9Ijc8B44v+wX+GzOqxuXw
         KdqYGLxlp3HCFbnHhkbAaStRobS+gafMD+9KM9cXyoUIy4n4+DAYDSZCX+GDnm4kaQP7
         psxitxEJHNoPTNEEExoOegkmu/a0gieGsm69WpgjbTKMzJwk45H0H6J5vGThEiWmkWYC
         BxOrVjyCWYfS707/7PCb2wElbsxzSkbLBnxEnzioGh7lwLm5aeJ7OsbAt4MQvm9zeDn7
         FJqQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXmjlnlvnz7YioPjLHOGjgILa7lpeuy9roqEXQsppn1IIVacS9d
	M2z/56cgYgIeNXi6wyNAae6ymCOQzqIE6skVd2E4sobVExeicaamsScQN98dkset7lUPxtiteyI
	U0rUJYTVNeP8JJejvQQQp/zBSXMqhv1L+Dwhc2SFS4iTY0eZVh8uh2xsd3vIk+x06Aw==
X-Received: by 2002:a63:6fcf:: with SMTP id k198mr20149697pgc.158.1555959523193;
        Mon, 22 Apr 2019 11:58:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqym7m/sJHOJ5H106O5w6z5v1U3smcyroZ/93ELbtQXKOaCclXHp6Cs3cHMNJLJXbfUoedeJ
X-Received: by 2002:a63:6fcf:: with SMTP id k198mr20149644pgc.158.1555959522203;
        Mon, 22 Apr 2019 11:58:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555959522; cv=none;
        d=google.com; s=arc-20160816;
        b=J+sRKXeEyrbbHnMQgLYSko/oGz++d5QGHUIKuQviTHbCCvXrHdhf95eoWYg8N9aklu
         fKuCKmcw/p0qZy4aKvodc6xZKyIUhM4HoVOjODzQETlJCHIxWO7Vb/hqSCnNlT2ul6bF
         oPh6A5IDJiql03qzuTb5P0fQya3FldE4qGXUzpQ5Vswrql+F+fpwPK2PtjtsFEO4LwPQ
         oCdP3XEuLR+iFFFN842QmMDbBCKlhW8P7foYb0EEdcqdTR9pe4X/3QbH/J9KJV3LVkFP
         tFa8STnnwq7A8vqAEBulUKl+Ec1DWOxZax3JOFJobeoWtjQ0Oa5g0V3eQE7O6uosv17X
         mmdg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=2uQh+p4niM1XazCyX0W8SClLNopGSLFeOTKZKD97XRE=;
        b=QPJcZt7evCAtr0SaUVicXQcgv6oMbYvDwwQqKf8j4Cexh29GrlrAY2IFIPxoO/pzBm
         0owClqPBPQ5r33kPURtwvrLxk/Ptj2z1VV9GitPAtH3VH86powmS+TbMEBehkMvrotOz
         twmn/lbsmeltC2zmb42Ldx67mgy7M1vy4GVr6MtxnejjA8z/iUSKum9tWzBZG+8EWmM+
         9aaClu3vqDQH9Z9aKZjKGrxtERfLMOzwd1e4yQ1l+kZ5wMyL/Lk967Q6akh0tAUSMn9v
         lUPoSmAsIDLBiNQgM5JTsPw6atgdI3IcvOE5cd8nDrunJvp/cMW197GcZKWUQY2C62jB
         9KlA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id a2si12975117pgn.530.2019.04.22.11.58.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 11:58:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Apr 2019 11:58:41 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,382,1549958400"; 
   d="scan'208";a="136417120"
Received: from linksys13920.jf.intel.com (HELO rpedgeco-DESK5.jf.intel.com) ([10.54.75.11])
  by orsmga008.jf.intel.com with ESMTP; 22 Apr 2019 11:58:40 -0700
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
To: Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
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
	Nadav Amit <namit@vmware.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Masami Hiramatsu <mhiramat@kernel.org>,
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v4 01/23] Fix "x86/alternatives: Lockdep-enforce text_mutex in text_poke*()"
Date: Mon, 22 Apr 2019 11:57:43 -0700
Message-Id: <20190422185805.1169-2-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
References: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

text_mutex is currently expected to be held before text_poke() is
called, but kgdb does not take the mutex, and instead *supposedly*
ensures the lock is not taken and will not be acquired by any other core
while text_poke() is running.

The reason for the "supposedly" comment is that it is not entirely clear
that this would be the case if gdb_do_roundup is zero.

Create two wrapper functions, text_poke() and text_poke_kgdb(), which do
or do not run the lockdep assertion respectively.

While we are at it, change the return code of text_poke() to something
meaningful. One day, callers might actually respect it and the existing
BUG_ON() when patching fails could be removed. For kgdb, the return
value can actually be used.

Cc: Andy Lutomirski <luto@kernel.org>
Cc: Kees Cook <keescook@chromium.org>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Masami Hiramatsu <mhiramat@kernel.org>
Fixes: 9222f606506c ("x86/alternatives: Lockdep-enforce text_mutex in text_poke*()")
Suggested-by: Peter Zijlstra <peterz@infradead.org>
Acked-by: Jiri Kosina <jkosina@suse.cz>
Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Reviewed-by: Masami Hiramatsu <mhiramat@kernel.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/include/asm/text-patching.h |  1 +
 arch/x86/kernel/alternative.c        | 52 ++++++++++++++++++++--------
 arch/x86/kernel/kgdb.c               | 11 +++---
 3 files changed, 45 insertions(+), 19 deletions(-)

diff --git a/arch/x86/include/asm/text-patching.h b/arch/x86/include/asm/text-patching.h
index e85ff65c43c3..f8fc8e86cf01 100644
--- a/arch/x86/include/asm/text-patching.h
+++ b/arch/x86/include/asm/text-patching.h
@@ -35,6 +35,7 @@ extern void *text_poke_early(void *addr, const void *opcode, size_t len);
  * inconsistent instruction while you patch.
  */
 extern void *text_poke(void *addr, const void *opcode, size_t len);
+extern void *text_poke_kgdb(void *addr, const void *opcode, size_t len);
 extern int poke_int3_handler(struct pt_regs *regs);
 extern void *text_poke_bp(void *addr, const void *opcode, size_t len, void *handler);
 extern int after_bootmem;
diff --git a/arch/x86/kernel/alternative.c b/arch/x86/kernel/alternative.c
index 9a79c7808f9c..0a814d73547a 100644
--- a/arch/x86/kernel/alternative.c
+++ b/arch/x86/kernel/alternative.c
@@ -679,18 +679,7 @@ void *__init_or_module text_poke_early(void *addr, const void *opcode,
 	return addr;
 }
 
-/**
- * text_poke - Update instructions on a live kernel
- * @addr: address to modify
- * @opcode: source of the copy
- * @len: length to copy
- *
- * Only atomic text poke/set should be allowed when not doing early patching.
- * It means the size must be writable atomically and the address must be aligned
- * in a way that permits an atomic write. It also makes sure we fit on a single
- * page.
- */
-void *text_poke(void *addr, const void *opcode, size_t len)
+static void *__text_poke(void *addr, const void *opcode, size_t len)
 {
 	unsigned long flags;
 	char *vaddr;
@@ -703,8 +692,6 @@ void *text_poke(void *addr, const void *opcode, size_t len)
 	 */
 	BUG_ON(!after_bootmem);
 
-	lockdep_assert_held(&text_mutex);
-
 	if (!core_kernel_text((unsigned long)addr)) {
 		pages[0] = vmalloc_to_page(addr);
 		pages[1] = vmalloc_to_page(addr + PAGE_SIZE);
@@ -733,6 +720,43 @@ void *text_poke(void *addr, const void *opcode, size_t len)
 	return addr;
 }
 
+/**
+ * text_poke - Update instructions on a live kernel
+ * @addr: address to modify
+ * @opcode: source of the copy
+ * @len: length to copy
+ *
+ * Only atomic text poke/set should be allowed when not doing early patching.
+ * It means the size must be writable atomically and the address must be aligned
+ * in a way that permits an atomic write. It also makes sure we fit on a single
+ * page.
+ */
+void *text_poke(void *addr, const void *opcode, size_t len)
+{
+	lockdep_assert_held(&text_mutex);
+
+	return __text_poke(addr, opcode, len);
+}
+
+/**
+ * text_poke_kgdb - Update instructions on a live kernel by kgdb
+ * @addr: address to modify
+ * @opcode: source of the copy
+ * @len: length to copy
+ *
+ * Only atomic text poke/set should be allowed when not doing early patching.
+ * It means the size must be writable atomically and the address must be aligned
+ * in a way that permits an atomic write. It also makes sure we fit on a single
+ * page.
+ *
+ * Context: should only be used by kgdb, which ensures no other core is running,
+ *	    despite the fact it does not hold the text_mutex.
+ */
+void *text_poke_kgdb(void *addr, const void *opcode, size_t len)
+{
+	return __text_poke(addr, opcode, len);
+}
+
 static void do_sync_core(void *info)
 {
 	sync_core();
diff --git a/arch/x86/kernel/kgdb.c b/arch/x86/kernel/kgdb.c
index 4ff6b4cdb941..2b203ee5b879 100644
--- a/arch/x86/kernel/kgdb.c
+++ b/arch/x86/kernel/kgdb.c
@@ -759,13 +759,13 @@ int kgdb_arch_set_breakpoint(struct kgdb_bkpt *bpt)
 	if (!err)
 		return err;
 	/*
-	 * It is safe to call text_poke() because normal kernel execution
+	 * It is safe to call text_poke_kgdb() because normal kernel execution
 	 * is stopped on all cores, so long as the text_mutex is not locked.
 	 */
 	if (mutex_is_locked(&text_mutex))
 		return -EBUSY;
-	text_poke((void *)bpt->bpt_addr, arch_kgdb_ops.gdb_bpt_instr,
-		  BREAK_INSTR_SIZE);
+	text_poke_kgdb((void *)bpt->bpt_addr, arch_kgdb_ops.gdb_bpt_instr,
+		       BREAK_INSTR_SIZE);
 	err = probe_kernel_read(opc, (char *)bpt->bpt_addr, BREAK_INSTR_SIZE);
 	if (err)
 		return err;
@@ -784,12 +784,13 @@ int kgdb_arch_remove_breakpoint(struct kgdb_bkpt *bpt)
 	if (bpt->type != BP_POKE_BREAKPOINT)
 		goto knl_write;
 	/*
-	 * It is safe to call text_poke() because normal kernel execution
+	 * It is safe to call text_poke_kgdb() because normal kernel execution
 	 * is stopped on all cores, so long as the text_mutex is not locked.
 	 */
 	if (mutex_is_locked(&text_mutex))
 		goto knl_write;
-	text_poke((void *)bpt->bpt_addr, bpt->saved_instr, BREAK_INSTR_SIZE);
+	text_poke_kgdb((void *)bpt->bpt_addr, bpt->saved_instr,
+		       BREAK_INSTR_SIZE);
 	err = probe_kernel_read(opc, (char *)bpt->bpt_addr, BREAK_INSTR_SIZE);
 	if (err || memcmp(opc, bpt->saved_instr, BREAK_INSTR_SIZE))
 		goto knl_write;
-- 
2.17.1

