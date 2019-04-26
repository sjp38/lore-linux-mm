Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 554F4C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 16:23:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0724B206C1
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 16:23:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="RReb59vX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0724B206C1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A40D6B026A; Fri, 26 Apr 2019 12:23:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 487226B026B; Fri, 26 Apr 2019 12:23:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D0AC6B026C; Fri, 26 Apr 2019 12:23:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id D1AD96B026A
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 12:23:37 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id r21so3521940wmh.4
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 09:23:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=1mJSVzNKDD/Yewvby3vQjwYmfiN9I0dVahztYQpyLk4=;
        b=CG+DWU8StkrfrpcqkhaQYeL0GuJN+abuDpFpRHURpeHrYuEtgmx1Or/lE9ra0r1FyX
         IWZzFKMN0zWiSEZWNoSAfkll4NL1ORcTRFqlEmH/Cw56vlywswB9mQJCobGAx+6nMG+6
         8PQKc6hrFXl4eAW0G8LkiwQBwJX3jl8hpPz7ouuZIfpYI1H6XHhEFqoRMOdXoSFKYx/2
         sZyGTJQT/TfO96HWXmb38w3gsX3CVMswN+nmcVAVcIv9QWndi6pfE/ZhQgPMUfIUBPHx
         h+U+ulLtV2ADhOiHme5eK5YUyxoA4rI7Z2z7ejII4h8g/dJjwg34HcKx+YdUQlRlnlSP
         vxGQ==
X-Gm-Message-State: APjAAAWuNu6T2sG4+1DoOI7JnTLasRdx2iYQRaR4201ka6zeIHpPyU1Z
	R6bNXch8ofL/smfBSIm/UG8DSxsJtgEjhFn3TAw1rSYZNM1iCDxs1vHxS4FhTmMgSlA0OF/Di6j
	OJ/h69AvhjL2Uylxngb/nE3SG2cOG9Ox1LLej9lteIeisxRXpl3l3gQkFgjVUQidDfw==
X-Received: by 2002:a7b:cb58:: with SMTP id v24mr7021133wmj.107.1556295817380;
        Fri, 26 Apr 2019 09:23:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwBzv8YrTPuHdxByqjo+7M8z2HPr1JRRfc+ViKTAcMH46boHOtEzwdL+3I6YNiVvDaGLYqb
X-Received: by 2002:a7b:cb58:: with SMTP id v24mr7021065wmj.107.1556295816370;
        Fri, 26 Apr 2019 09:23:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556295816; cv=none;
        d=google.com; s=arc-20160816;
        b=CGWRx20i5SizlSkfYZmnfDI6UQGM2hqE3C4iupOlwJu78fnMoBylov0HHG/jgMnuVi
         /Lbj9qpbKfcdosc5Xrx8vFz2cy0GliBlFlJPi2hIah97dWttDdPxYQDskVJKbOwzV5YJ
         I2B6ukW2MncuPSVQdn5755Mue1thDpHg8rmhgk5QZRRQdA8zLi4mwsei14ZiHvEn2HBG
         5Z9fdjJwRSbY3imTGgFpxZYhm9TK7dj7uDVCQZfeyCrjl8WMU6V0qUtl5QCe/BBd4xdL
         BvpmQloCLMYaGl2+tNdA/VXvp2VtOTzgR886LaBzxIufolgYgnaoSMB2lVHfw9LssNr4
         FLDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=1mJSVzNKDD/Yewvby3vQjwYmfiN9I0dVahztYQpyLk4=;
        b=uAFHLQHQpMUsXFOlXGD6FyXl4m/kWOrSyGYAo+Gb8HA/ahu6s1JspgMyDsYGxqwr5V
         FYKjVQjnVCrxFTtswztCkWfNxuAnC6VZ7sx7guUu/m5lrK82wSjNDL38FX8rTz0ZSCao
         sMqG/2kpa/241jZzz8WgAM607ecEdTEYeaN6DfNIBmmHuvgIdYrLgaX1v4b0ryI+L0ay
         VpjI7Zgjwki4yaK94go66xG/upAJgOcsgmnsBpK8122FWeG6iFdNKXpIwiw1Q1DAEurb
         FZozwxWH+2O1feyQVfXrKHsYbkLorGr0mjWmcFZ7dneWYN/hyGgbrSp7oXXGAeXAzRAw
         62XQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=RReb59vX;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id n18si15971914wro.455.2019.04.26.09.23.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 09:23:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=RReb59vX;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44rK9f2KGnz9v0yb;
	Fri, 26 Apr 2019 18:23:34 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=RReb59vX; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id AWuolCdHIWQh; Fri, 26 Apr 2019 18:23:34 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44rK9f1BGWz9v17t;
	Fri, 26 Apr 2019 18:23:34 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1556295814; bh=1mJSVzNKDD/Yewvby3vQjwYmfiN9I0dVahztYQpyLk4=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=RReb59vXqq0AZCDDcuNWqtGN2iAx//z1t7ZkXoK4udlCQM+kUq9dSXvkyGJvtC84/
	 D3ZvTnU2yo5ApLBFeCQF7QorAMg11Hny9YBRKaHXGFb+/S9FU5pnWh2DgdSxAHgN4a
	 B5VhczygdXn2xxGApHdxqQcIfPKB8XiSSaRd5gl8=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id CDCA98B950;
	Fri, 26 Apr 2019 18:23:35 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id 5YGjCKhSIj6u; Fri, 26 Apr 2019 18:23:35 +0200 (CEST)
Received: from po16846vm.idsi0.si.c-s.fr (po15451.idsi0.si.c-s.fr [172.25.231.6])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id A5DCE8B82F;
	Fri, 26 Apr 2019 18:23:35 +0200 (CEST)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 8EFDF666FE; Fri, 26 Apr 2019 16:23:35 +0000 (UTC)
Message-Id: <5251637ee5e81788470cda83a6cbb88dd0a18b17.1556295461.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1556295459.git.christophe.leroy@c-s.fr>
References: <cover.1556295459.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v11 11/13] powerpc/32s: move hash code patching out of
 MMU_init_hw()
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Fri, 26 Apr 2019 16:23:35 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

For KASAN, hash table handling will be activated early for
accessing to KASAN shadow areas.

In order to avoid any modification of the hash functions while
they are still used with the early hash table, the code patching
is moved out of MMU_init_hw() and put close to the big-bang switch
to the final hash table.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/kernel/head_32.S |  3 +++
 arch/powerpc/mm/mmu_decl.h    |  1 +
 arch/powerpc/mm/ppc_mmu_32.c  | 36 ++++++++++++++++++++++--------------
 3 files changed, 26 insertions(+), 14 deletions(-)

diff --git a/arch/powerpc/kernel/head_32.S b/arch/powerpc/kernel/head_32.S
index 6e85171e513c..5958ea685968 100644
--- a/arch/powerpc/kernel/head_32.S
+++ b/arch/powerpc/kernel/head_32.S
@@ -977,6 +977,9 @@ start_here:
 	bl	machine_init
 	bl	__save_cpu_setup
 	bl	MMU_init
+BEGIN_MMU_FTR_SECTION
+	bl	MMU_init_hw_patch
+END_MMU_FTR_SECTION_IFSET(MMU_FTR_HPTE_TABLE)
 
 /*
  * Go back to running unmapped so we can load up new values
diff --git a/arch/powerpc/mm/mmu_decl.h b/arch/powerpc/mm/mmu_decl.h
index 74ff61dabcb1..d726ff776054 100644
--- a/arch/powerpc/mm/mmu_decl.h
+++ b/arch/powerpc/mm/mmu_decl.h
@@ -130,6 +130,7 @@ extern void wii_memory_fixups(void);
  */
 #ifdef CONFIG_PPC32
 extern void MMU_init_hw(void);
+void MMU_init_hw_patch(void);
 unsigned long mmu_mapin_ram(unsigned long base, unsigned long top);
 #endif
 
diff --git a/arch/powerpc/mm/ppc_mmu_32.c b/arch/powerpc/mm/ppc_mmu_32.c
index bf1de3ca39bc..8a21958484d8 100644
--- a/arch/powerpc/mm/ppc_mmu_32.c
+++ b/arch/powerpc/mm/ppc_mmu_32.c
@@ -39,6 +39,7 @@
 struct hash_pte *Hash, *Hash_end;
 unsigned long Hash_size, Hash_mask;
 unsigned long _SDR1;
+static unsigned int hash_mb, hash_mb2;
 
 struct ppc_bat BATS[8][2];	/* 8 pairs of IBAT, DBAT */
 
@@ -308,7 +309,6 @@ void hash_preload(struct mm_struct *mm, unsigned long ea,
  */
 void __init MMU_init_hw(void)
 {
-	unsigned int hmask, mb, mb2;
 	unsigned int n_hpteg, lg_n_hpteg;
 
 	if (!mmu_has_feature(MMU_FTR_HPTE_TABLE))
@@ -351,20 +351,30 @@ void __init MMU_init_hw(void)
 	       (unsigned long long)(total_memory >> 20), Hash_size >> 10, Hash);
 
 
-	/*
-	 * Patch up the instructions in hashtable.S:create_hpte
-	 */
-	if ( ppc_md.progress ) ppc_md.progress("hash:patch", 0x345);
 	Hash_mask = n_hpteg - 1;
-	hmask = Hash_mask >> (16 - LG_HPTEG_SIZE);
-	mb2 = mb = 32 - LG_HPTEG_SIZE - lg_n_hpteg;
+	hash_mb2 = hash_mb = 32 - LG_HPTEG_SIZE - lg_n_hpteg;
 	if (lg_n_hpteg > 16)
-		mb2 = 16 - LG_HPTEG_SIZE;
+		hash_mb2 = 16 - LG_HPTEG_SIZE;
+}
+
+void __init MMU_init_hw_patch(void)
+{
+	unsigned int hmask = Hash_mask >> (16 - LG_HPTEG_SIZE);
 
+	if (ppc_md.progress)
+		ppc_md.progress("hash:patch", 0x345);
+	if (ppc_md.progress)
+		ppc_md.progress("hash:done", 0x205);
+
+	/* WARNING: Make sure nothing can trigger a KASAN check past this point */
+
+	/*
+	 * Patch up the instructions in hashtable.S:create_hpte
+	 */
 	modify_instruction_site(&patch__hash_page_A0, 0xffff,
 				((unsigned int)Hash - PAGE_OFFSET) >> 16);
-	modify_instruction_site(&patch__hash_page_A1, 0x7c0, mb << 6);
-	modify_instruction_site(&patch__hash_page_A2, 0x7c0, mb2 << 6);
+	modify_instruction_site(&patch__hash_page_A1, 0x7c0, hash_mb << 6);
+	modify_instruction_site(&patch__hash_page_A2, 0x7c0, hash_mb2 << 6);
 	modify_instruction_site(&patch__hash_page_B, 0xffff, hmask);
 	modify_instruction_site(&patch__hash_page_C, 0xffff, hmask);
 
@@ -373,11 +383,9 @@ void __init MMU_init_hw(void)
 	 */
 	modify_instruction_site(&patch__flush_hash_A0, 0xffff,
 				((unsigned int)Hash - PAGE_OFFSET) >> 16);
-	modify_instruction_site(&patch__flush_hash_A1, 0x7c0, mb << 6);
-	modify_instruction_site(&patch__flush_hash_A2, 0x7c0, mb2 << 6);
+	modify_instruction_site(&patch__flush_hash_A1, 0x7c0, hash_mb << 6);
+	modify_instruction_site(&patch__flush_hash_A2, 0x7c0, hash_mb2 << 6);
 	modify_instruction_site(&patch__flush_hash_B, 0xffff, hmask);
-
-	if ( ppc_md.progress ) ppc_md.progress("hash:done", 0x205);
 }
 
 void setup_initial_memory_limit(phys_addr_t first_memblock_base,
-- 
2.13.3

