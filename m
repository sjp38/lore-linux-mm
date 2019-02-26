Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA908C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 17:23:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A08C21848
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 17:23:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="e/w18jRF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A08C21848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 219278E000D; Tue, 26 Feb 2019 12:22:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 128F28E000A; Tue, 26 Feb 2019 12:22:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EBD828E000D; Tue, 26 Feb 2019 12:22:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8DE548E000A
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 12:22:54 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id f4so6491821wrj.11
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 09:22:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=iDP7gsyvcqTo9RdhF5mvEcZHsCZ/UEXVBMDee0rR734=;
        b=aFToaRv3BvyNg8WMTfUWj24ndpJxmca/6MOX8vHVELX21hFK4hAmJwxMCOckVm5QPQ
         HoGWyPdnix7Ixo5R+IWeHWYGHZxwvoPmr4XLGMgY5rLubAq62UqojXMZ80PBT0l2ZiXB
         XWdzyDo0xKUJZbBoNRfSwDNIyybqWXyoPBXqztfgC8C+5eL3H25kAVj91IU2zwtZFnr9
         cGGBQuNWlNh1e0SPfAWbsK2MAltNSKPBTg3hSPfcp11Qq9YevE6+4/G47H5jPo+0649+
         ZpyermhA7+kT10TwvHvWoDzZ4N9Y9NQmC39NQ8fUYSgJU19aVAGDbsr0bZVLzKsPxttl
         igmw==
X-Gm-Message-State: AHQUAubugruen890V7xGckgdq58R27UGw+HWM3M4b2B70ka4LoZf/to6
	nRyZCmIbTSJrepmOlowZ4LRkVvQJKGP69k7+csd46jJsGgzRlsJ/AUQS6ArOXtc1nVkDfI1mGFr
	+dEVOPVoeVGurwgWGcX0JzSjC1tGRTRD7FChvYwN47j3653aueQJOoUJLyagIKa4IaQ==
X-Received: by 2002:a1c:df07:: with SMTP id w7mr3412977wmg.23.1551201774087;
        Tue, 26 Feb 2019 09:22:54 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib5oFL6GVjjmnHWtuH3vGaCyA17u66L8T/lqt1h+027J+x4u5NtSVNG4VOmWPamg+b2e5E1
X-Received: by 2002:a1c:df07:: with SMTP id w7mr3412923wmg.23.1551201772790;
        Tue, 26 Feb 2019 09:22:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551201772; cv=none;
        d=google.com; s=arc-20160816;
        b=wp60vczsdA6YdOJjb4r9B25gnme/HC7Q7+vZj2LKRJP4UFkJBEMTcxP1dKkKi9v4FI
         3ktoaoZWzPAOPhoGXuK9XgLRmaKw0sJJm9HqExSvclc28uQ+du8xRqutHRANHHSAh4W3
         qlFsnBLo9itGAx96bSiMP/5VBZVbrkwpJeYiLBD+4EhzOXnJ+GcA+9uCyYnoCAlVBlnm
         gkduTarOHrbEZXP4mgD2Vif4njJuW33ng6GNqjphjLonAaY0+YUjRzIlPbWzFRTEp/kK
         qvrJ9x0+slHz8yKHOXDX7sB8xiOkq1XJxavBUzSxLd3Zpe/lVjqa7voxgHxXx/OLSfKs
         vYyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=iDP7gsyvcqTo9RdhF5mvEcZHsCZ/UEXVBMDee0rR734=;
        b=RfJ9M+PNe/1HE88AvWsj/48AqdnkAmcEe7IPydeFHdgXHpSnIvvbUf71HLQ5AHDVu2
         s7kyY8VOPIlN8edX7pyBeLRLxNw4yDx0hu2P/IgWejVZO9FLEqOc/r6YzhPFBEeB9Fir
         I7rhggGAZVtq28ctOFEAq6EE92NICT8TuFlnKzauxFgpUzjLAO2TkYWeAvVdGlcbL/5k
         /zOFwG/E5dzNdMNjPlYRim6xD8UYl+8ktg1hFWlId1hbjoClhQeDj9Ry1lp2bTOcEpkQ
         i0XwEVLp5Ju/aacm+MMnZ/Jx4PxXKg1fQIR3cLxsTLWkDI2AjxzfqD9BBF22atFZl0yn
         h57g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b="e/w18jRF";
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id n5si10373309wrr.153.2019.02.26.09.22.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 09:22:52 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b="e/w18jRF";
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 4485HG3nxHz9vJLm;
	Tue, 26 Feb 2019 18:22:50 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=e/w18jRF; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id cW5GIqbS7OHZ; Tue, 26 Feb 2019 18:22:50 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 4485HG2dYkz9vJLY;
	Tue, 26 Feb 2019 18:22:50 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1551201770; bh=iDP7gsyvcqTo9RdhF5mvEcZHsCZ/UEXVBMDee0rR734=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=e/w18jRFyW0Vuo5p+wAhkh3rq1yjS5qOco7z2p/J/BBRe0LT58LHBtGKNILkhGMHw
	 sa0J+UIikV4S+wkG2SMuVRDq2ijBRgaYrxjX/JcMc3nZJ4tpl+ZMCkAC2weRd427OG
	 eltKio7IHTZqgTmMBFawxxU0ykDDWxpCKs1Q2J+4=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 029B58B97A;
	Tue, 26 Feb 2019 18:22:52 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id cFVPliJT_nvz; Tue, 26 Feb 2019 18:22:51 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id B0E758B96A;
	Tue, 26 Feb 2019 18:22:51 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 7EB0F6F7A6; Tue, 26 Feb 2019 17:22:51 +0000 (UTC)
Message-Id: <6a7161b4c947d72ae0fba7d29748b57b92dd3814.1551161392.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1551161392.git.christophe.leroy@c-s.fr>
References: <cover.1551161392.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v8 10/11] powerpc/32s: move hash code patching out of
 MMU_init_hw()
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 26 Feb 2019 17:22:51 +0000 (UTC)
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
index 02229c005853..e644aab2cf5b 100644
--- a/arch/powerpc/kernel/head_32.S
+++ b/arch/powerpc/kernel/head_32.S
@@ -960,6 +960,9 @@ start_here:
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
index 2d5b0d50fb31..38c0e28c21e1 100644
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
@@ -349,20 +349,30 @@ void __init MMU_init_hw(void)
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
 
@@ -371,11 +381,9 @@ void __init MMU_init_hw(void)
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

