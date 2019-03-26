Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84FACC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:27:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E5F920879
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:27:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E5F920879
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F7E26B0281; Tue, 26 Mar 2019 12:27:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 485396B0282; Tue, 26 Mar 2019 12:27:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 34CF56B0283; Tue, 26 Mar 2019 12:27:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D9F546B0281
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 12:27:36 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f11so2271298edq.18
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:27:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=82GVaLwkCHLAJuw0cg7cs7mz13Kyr233/Gpjb9qS/I0=;
        b=G/kLw89LBpH4J+qQKqlUpvSLYaJpaBIYKWNVglQqZJyHADuDhsVnUkM/65tCTkDBJm
         Fr/dEIuYZD/ZhvuN9spzt95b/AfohbvJLKpW4hYfyIzypMRGV+4P3UfIbdybDXqWTbGI
         bcaGlFqsqrCJyeUswZSsKOBBOtkiORE44Kg2fiYlfFrooks4907hjhcEMjxndftLeIQS
         Vb5Y4lb1ndDOVmfHq54O3vpxCpNOevUN+ISzMbKVy4bNVylqMxKELQW3KgL7CDnudfvg
         aQMbKRV13WKXprhfJq0BcLQdlRAzvCpiNZUrI73NT5AaVkGpG5J0lYjbk1RBgDuuMrGU
         7Apg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAUjLMJVpo96SapFkysBdv/mxvt4RjU8FX1WiLM5olxuhLl6FjRw
	C1TlPYsSEBEJsU1AUvg+zABNsVQJonhpOFJwouVlqf9PrbowQeQ0o6ATQ5TzAC+LaWR2c9j4HXo
	6ecC5R6HkAhoh9T1ABtM+vgegCHiyy/Mzk/98j8UxZzYYnbgqeUsRqxwog7zRKGnnnA==
X-Received: by 2002:a50:fe14:: with SMTP id f20mr20316293edt.187.1553617656414;
        Tue, 26 Mar 2019 09:27:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzzRuoPXPoDN7C62A2Oc4M3NNE8ieplm7ZlHhYqR9I3rtCD4HD5yaW2yd3HGiGJ8+C59k95
X-Received: by 2002:a50:fe14:: with SMTP id f20mr20316246edt.187.1553617655525;
        Tue, 26 Mar 2019 09:27:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553617655; cv=none;
        d=google.com; s=arc-20160816;
        b=FGejlSjzqynKSie5w/XJ1is5XHhZwndFTkyVMrNimqRboIgNl5at1gVdvKP3h5zMiF
         kAoh0tdw46Qo8bIpqcRSk8S59FFVNsjVYg4dtp1kjDRAQsG1Qmy3Z+qq6I/a8DKjPSU4
         Ol5+65My/p4/SXcy3JMV+lzBquzGLpFoKo52+IcIxJaX5DKm3uoorJcb+ANZfSBqNgpl
         DmI08u+Eb8YIiHzbxdrmA+eJDKXuNj4xkoQIscminQWKtBEABd5/HFpxsg8rvQtu0foH
         /60cGvht1cYhMbnhpjbmtJTOMZir/fiJlqd3B0wF/vGlkXDQUvOpCbxoUPozax64aeUo
         m7fg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=82GVaLwkCHLAJuw0cg7cs7mz13Kyr233/Gpjb9qS/I0=;
        b=OUgGNactn9DgoHCAQ1PWRccUbYFrNucFYWGVDDOkBPs++Y+57sFdetS//smGPCd61i
         IllfO88QLcaxH9MWV6wQS0c3m3au29atWKTScARaVMp/iBGKX3SuUJPlgIUad4r1f5OM
         /coEFi2gN6acaSAnxEjES+7Uco2th2oyyG11urVhTFczfuboDYwPwZegScsxrB2rlVe0
         mW7GuBOz3OxYwloA2M9YZuiaAn4zXivHMkF/Txo5nJCGaDEvNgpnjgljQ2/u05EifmuP
         EtU0vNlNYsBcUgvcQ65uqJb3toeKHDrLnjl7PA50MQQXfMrqt9JBHg6aQYIZaACBvuY7
         uGng==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t32si1248409edd.442.2019.03.26.09.27.35
        for <linux-mm@kvack.org>;
        Tue, 26 Mar 2019 09:27:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 72C8619F6;
	Tue, 26 Mar 2019 09:27:34 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 366263F614;
	Tue, 26 Mar 2019 09:27:31 -0700 (PDT)
From: Steven Price <steven.price@arm.com>
To: linux-mm@kvack.org
Cc: Steven Price <steven.price@arm.com>,
	Andy Lutomirski <luto@kernel.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>,
	Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ingo Molnar <mingo@redhat.com>,
	James Morse <james.morse@arm.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Will Deacon <will.deacon@arm.com>,
	x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	Mark Rutland <Mark.Rutland@arm.com>,
	"Liang, Kan" <kan.liang@linux.intel.com>
Subject: [PATCH v6 16/19] x86: mm+efi: Convert ptdump_walk_pgd_level() to take a mm_struct
Date: Tue, 26 Mar 2019 16:26:21 +0000
Message-Id: <20190326162624.20736-17-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190326162624.20736-1-steven.price@arm.com>
References: <20190326162624.20736-1-steven.price@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

To enable x86 to use the generic walk_page_range() function, the
callers of ptdump_walk_pgd_level() need to pass an mm_struct rather
than the raw pgd_t pointer. Luckily since commit 7e904a91bf60
("efi: Use efi_mm in x86 as well as ARM") we now have an mm_struct
for EFI on x86.

Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/x86/include/asm/pgtable.h | 2 +-
 arch/x86/mm/dump_pagetables.c  | 4 ++--
 arch/x86/platform/efi/efi_32.c | 2 +-
 arch/x86/platform/efi/efi_64.c | 4 ++--
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 0dd04cf6ebeb..579959750f34 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -27,7 +27,7 @@
 extern pgd_t early_top_pgt[PTRS_PER_PGD];
 int __init __early_make_pgtable(unsigned long address, pmdval_t pmd);
 
-void ptdump_walk_pgd_level(struct seq_file *m, pgd_t *pgd);
+void ptdump_walk_pgd_level(struct seq_file *m, struct mm_struct *mm);
 void ptdump_walk_pgd_level_debugfs(struct seq_file *m, pgd_t *pgd, bool user);
 void ptdump_walk_pgd_level_checkwx(void);
 void ptdump_walk_user_pgd_level_checkwx(void);
diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index 3d12ac031144..ddf8ea6b059d 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -574,9 +574,9 @@ static void ptdump_walk_pgd_level_core(struct seq_file *m, pgd_t *pgd,
 		pr_info("x86/mm: Checked W+X mappings: passed, no W+X pages found.\n");
 }
 
-void ptdump_walk_pgd_level(struct seq_file *m, pgd_t *pgd)
+void ptdump_walk_pgd_level(struct seq_file *m, struct mm_struct *mm)
 {
-	ptdump_walk_pgd_level_core(m, pgd, false, true);
+	ptdump_walk_pgd_level_core(m, mm->pgd, false, true);
 }
 
 void ptdump_walk_pgd_level_debugfs(struct seq_file *m, pgd_t *pgd, bool user)
diff --git a/arch/x86/platform/efi/efi_32.c b/arch/x86/platform/efi/efi_32.c
index 9959657127f4..9175ceaa6e72 100644
--- a/arch/x86/platform/efi/efi_32.c
+++ b/arch/x86/platform/efi/efi_32.c
@@ -49,7 +49,7 @@ void efi_sync_low_kernel_mappings(void) {}
 void __init efi_dump_pagetable(void)
 {
 #ifdef CONFIG_EFI_PGT_DUMP
-	ptdump_walk_pgd_level(NULL, swapper_pg_dir);
+	ptdump_walk_pgd_level(NULL, init_mm);
 #endif
 }
 
diff --git a/arch/x86/platform/efi/efi_64.c b/arch/x86/platform/efi/efi_64.c
index cf0347f61b21..a2e0f9800190 100644
--- a/arch/x86/platform/efi/efi_64.c
+++ b/arch/x86/platform/efi/efi_64.c
@@ -611,9 +611,9 @@ void __init efi_dump_pagetable(void)
 {
 #ifdef CONFIG_EFI_PGT_DUMP
 	if (efi_enabled(EFI_OLD_MEMMAP))
-		ptdump_walk_pgd_level(NULL, swapper_pg_dir);
+		ptdump_walk_pgd_level(NULL, init_mm);
 	else
-		ptdump_walk_pgd_level(NULL, efi_mm.pgd);
+		ptdump_walk_pgd_level(NULL, efi_mm);
 #endif
 }
 
-- 
2.20.1

