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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03146C4321B
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:44:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F224208CB
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:44:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Q470hKxC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F224208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1AEA26B0274; Sat, 27 Apr 2019 02:43:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E4CC6B0275; Sat, 27 Apr 2019 02:43:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EEC976B0276; Sat, 27 Apr 2019 02:43:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id B478A6B0274
	for <linux-mm@kvack.org>; Sat, 27 Apr 2019 02:43:33 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id g1so3591819pfo.2
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 23:43:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=03x8MyH4ONo6RL8TDAuJcYQYBUTk8Xfu5EMEl5vv8zs=;
        b=MtFC5o/r2uxOLrDAFj1cJ9d2DPvOQg84QrxU5uImSnRGWQ1ULXbRQVkTdnjrG8IBMR
         gkQUIGIzV7nl/FGBFJODmf/olA/iTTg2WAFCf5qAbgvUoszaCqoufNVbUtQjxoa3lgTR
         c6lQ1u9BMcYAkFwQBOvNZcU5nMnztpm2WpZ+s+2g7JB4Y2UAh3zc0XCMjimAJXDJ0qsR
         MrxfkQgogVhkw756H/JjSmbNub5sDQPsolha4vgydGM1MZcSjxxJgpkFbz946sKokqSN
         X0RUwz1G3TCve/BUtLBjpHQPqhBsPR5ofb0ysBl+mrMFtAyrMNjpSL+YR3v81VMfhyVB
         Of2w==
X-Gm-Message-State: APjAAAWPE3qIgo09QgNL3ca9GpVc4GhAsqMWah6c94ggSduxX+mu+nG8
	VBJLrXnI29+Yq2yBhNcPUIEfqvbVv3CTzHkCXUIQaRQQjgLaZlxEhXgp47xs90w0Q8xs3nhXJCM
	fCSj3aOE4pIrLV/00vsg5Kpr3RVcWLGsGcQRxlMyJE0Q+VVZPLwVeT/49XmtYjCJ9sA==
X-Received: by 2002:aa7:9285:: with SMTP id j5mr22726313pfa.129.1556347413420;
        Fri, 26 Apr 2019 23:43:33 -0700 (PDT)
X-Received: by 2002:aa7:9285:: with SMTP id j5mr22726238pfa.129.1556347412194;
        Fri, 26 Apr 2019 23:43:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556347412; cv=none;
        d=google.com; s=arc-20160816;
        b=dsJEPPuFZFbW7GeJHFFkpJZhIVR07EKWCX2cFtsgCff0F4dos3Hw0iO0ipT7F4O57U
         uDCcuuZNFxpO7ii2s4wULRSgbpxEp1fMU/NzXfNQwfIdAlkPoy7LqQzikwAq1Yet3qGo
         yJHGgWE84YuTG7ibGA/vddK4YRkNL5tyqyHqUEGoA/btRTXC1qxwxoKAmrr7nePETMmn
         AoPMXbTgGMIwXtOyphrTqxRoCUGVOHkOpZ+GT5Jwhk053hvLywE1R2mgSS/t9h78Tnux
         Iimqkx3YF4eRMFCE3I3JZTmei5rWY76GH/RPJ8rI6o43MKjTJ2p7v9yzkLGVCF3yQIYE
         xtAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=03x8MyH4ONo6RL8TDAuJcYQYBUTk8Xfu5EMEl5vv8zs=;
        b=bWWEjO8N6+uZzh/Bi4DC2KZXtIoaA+fvim2bCVMwwNkNagUC6NMo1MxSxjeJVe4qRr
         MhoHo166YHO5E/ldtPSCyecqQSqxyBtxUWt/BWMEz1jq1MQZlkPoSznTPJVjOtmbHX5J
         mf2Z+vZ+2oE0jdpc10273F6eERJSpUBGP6ERXlSiblGgaZo8qR/uIpBHNOrVJeKjo+YM
         gyTEEPcRpN6iBZDBJsvRxVtQ7bh9wKcK1bJbLqnB5ujQcjv2GTg5e3/cI3tclYT5hN2L
         d5pttL6pi+t8Ijp5fk7NPcLJZLmSxJxbAduZ5kgVn+lFLYHhXdHVBi+cyJ+yukXe20oV
         skTg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Q470hKxC;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g1sor26693120plp.57.2019.04.26.23.43.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Apr 2019 23:43:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Q470hKxC;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=03x8MyH4ONo6RL8TDAuJcYQYBUTk8Xfu5EMEl5vv8zs=;
        b=Q470hKxCA0zkhL+IQMRmPe5UQg42Gi+l2RRmW947taZyL//Jesf10pqg7iknajn5cM
         6MahwRUBormFC9ROtXZzOCBPO1osFE8XuHCncIgLvsCHxLcNuXntyLIPTNUxNKWwnbuS
         YivKpxFXT45f055xbj7gqKyZeZCL6izznlo4y+QcynGiNpgPJSJn6cIDoQUEWR8q3NIV
         QQ28y5mhdxTCv3ZGyzW3vgvH+5eRIAil3M9uo1sFkym+2/eXjUEbYhGGuoRIn6PGQ204
         szqozT+L1TEHgWXr+gjrabBNVx0fQWsxwFBogU0RCWe7qqaev2wbboj0cmVtOcpDQP9M
         I7SA==
X-Google-Smtp-Source: APXvYqwS9mBb6vrC0DhVyMmyRT5ZRdKwezrJErmAVG/FEmt+6AsmQkMSAz9lRez80K2MggQYstDNlg==
X-Received: by 2002:a17:902:bd0c:: with SMTP id p12mr17355851pls.50.1556347411683;
        Fri, 26 Apr 2019 23:43:31 -0700 (PDT)
Received: from sc2-haas01-esx0118.eng.vmware.com ([66.170.99.1])
        by smtp.gmail.com with ESMTPSA id j22sm36460145pfn.129.2019.04.26.23.43.30
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 23:43:31 -0700 (PDT)
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
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@kernel.org>
Subject: [PATCH v6 19/24] bpf: Use vmalloc special flag
Date: Fri, 26 Apr 2019 16:22:58 -0700
Message-Id: <20190426232303.28381-20-nadav.amit@gmail.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190426232303.28381-1-nadav.amit@gmail.com>
References: <20190426232303.28381-1-nadav.amit@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Rick Edgecombe <rick.p.edgecombe@intel.com>

Use new flag VM_FLUSH_RESET_PERMS for handling freeing of special
permissioned memory in vmalloc and remove places where memory was set RW
before freeing which is no longer needed. Don't track if the memory is RO
anymore because it is now tracked in vmalloc.

Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 include/linux/filter.h | 17 +++--------------
 kernel/bpf/core.c      |  1 -
 2 files changed, 3 insertions(+), 15 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 14ec3bdad9a9..7d3abde3f183 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -20,6 +20,7 @@
 #include <linux/set_memory.h>
 #include <linux/kallsyms.h>
 #include <linux/if_vlan.h>
+#include <linux/vmalloc.h>
 
 #include <net/sch_generic.h>
 
@@ -503,7 +504,6 @@ struct bpf_prog {
 	u16			pages;		/* Number of allocated pages */
 	u16			jited:1,	/* Is our filter JIT'ed? */
 				jit_requested:1,/* archs need to JIT the prog */
-				undo_set_mem:1,	/* Passed set_memory_ro() checkpoint */
 				gpl_compatible:1, /* Is filter GPL compatible? */
 				cb_access:1,	/* Is control block accessed? */
 				dst_needed:1,	/* Do we need dst entry? */
@@ -733,27 +733,17 @@ bpf_ctx_narrow_access_ok(u32 off, u32 size, u32 size_default)
 
 static inline void bpf_prog_lock_ro(struct bpf_prog *fp)
 {
-	fp->undo_set_mem = 1;
+	set_vm_flush_reset_perms(fp);
 	set_memory_ro((unsigned long)fp, fp->pages);
 }
 
-static inline void bpf_prog_unlock_ro(struct bpf_prog *fp)
-{
-	if (fp->undo_set_mem)
-		set_memory_rw((unsigned long)fp, fp->pages);
-}
-
 static inline void bpf_jit_binary_lock_ro(struct bpf_binary_header *hdr)
 {
+	set_vm_flush_reset_perms(hdr);
 	set_memory_ro((unsigned long)hdr, hdr->pages);
 	set_memory_x((unsigned long)hdr, hdr->pages);
 }
 
-static inline void bpf_jit_binary_unlock_ro(struct bpf_binary_header *hdr)
-{
-	set_memory_rw((unsigned long)hdr, hdr->pages);
-}
-
 static inline struct bpf_binary_header *
 bpf_jit_binary_hdr(const struct bpf_prog *fp)
 {
@@ -789,7 +779,6 @@ void __bpf_prog_free(struct bpf_prog *fp);
 
 static inline void bpf_prog_unlock_free(struct bpf_prog *fp)
 {
-	bpf_prog_unlock_ro(fp);
 	__bpf_prog_free(fp);
 }
 
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index ff09d32a8a1b..c605397c79f0 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -848,7 +848,6 @@ void __weak bpf_jit_free(struct bpf_prog *fp)
 	if (fp->jited) {
 		struct bpf_binary_header *hdr = bpf_jit_binary_hdr(fp);
 
-		bpf_jit_binary_unlock_ro(hdr);
 		bpf_jit_binary_free(hdr);
 
 		WARN_ON_ONCE(!bpf_prog_kallsyms_verify_off(fp));
-- 
2.17.1

