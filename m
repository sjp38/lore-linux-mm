Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16905C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:16:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA5ED213A2
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:16:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="mslzkjz3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA5ED213A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C69C8E0008; Tue, 12 Mar 2019 18:16:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6627C8E000F; Tue, 12 Mar 2019 18:16:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B14A8E000E; Tue, 12 Mar 2019 18:16:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id D61278E0008
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 18:16:20 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id t7so1591049wrw.8
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 15:16:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=acqG75nChdz0NKlCBaUDHivOgUFydlR1lE4J1UHbXOo=;
        b=LRFqZzgmxtswkJyEVYzMa1NFBCBEbFNN82v0TAgFoDaybq0GusgxRDl0XWBN9dIxxq
         wZaktP489OCAzzNqMyHBVh0tBAqW2wsH4bHJ/i72UGBT2AAZTpFCle7wW5cbpA0JThIk
         0bsg1TAmLgwW9sMQN0P4qHlmnW2encxKFC3X/V6k/FttULh+Em7suEhNBoENUcTUzQ00
         31sEGP/VuEknt+NCvbCikJChBNfsMcZ1C0vLZG+fuu39ZbVdDDsMWvN7dFXxs6OdUYVZ
         DUrMID3Y1mM68nkh79L7LEdJ1tMRPdMTWmM0i/I/onqN2cngrZwZMySKKZ8Sy5EqBFXI
         j54Q==
X-Gm-Message-State: APjAAAWGyxr1I/zUdKhtdeJyDELnxPYmqKWy/vJIoRnuo2YFub6qUfSi
	q9TX2bdS+cs2ge9/LhF3TRRTfCf1dcTbKRROuox3LuqSqGBEroNUFr04r7n0qlK7vzOl1rZHOla
	loz4rtiK+7inHUH76r9G24wRLH0IlJMMhFyaUIK532UhFnhA9nUirq/iVWwReT4xjqg==
X-Received: by 2002:a05:600c:2301:: with SMTP id 1mr29983wmo.116.1552428980147;
        Tue, 12 Mar 2019 15:16:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwLSYD1XUrVubNT2agZbYJ3J6i/s+DrHNQHa5VAHT2boMHoqJB7vAQaccgnK2NZOpM2Q7W/
X-Received: by 2002:a05:600c:2301:: with SMTP id 1mr29946wmo.116.1552428978962;
        Tue, 12 Mar 2019 15:16:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552428978; cv=none;
        d=google.com; s=arc-20160816;
        b=uqiIEwy2cjCXBptzyYdOMzRILLF6xn+rhxsr8LfxCauZjg8B9X2lYT/t/wxF0Xjmjg
         kziqnGDxzbtVzeyskQsVds7jOegh8CUaTQLpEA7x6yuhSiFaeyIUjPXOOB/SKnaQcyu3
         +XHOgsNYgXRmT1kBjNAxfSVNXd804zvgp/n1+ulS5+a61n/SxC+BD6veq+qE7pjBmcYy
         /rHMG826keMZqi7xu3++RRMdHUGkAP0hznYp9DpPj0uyKJmEE9xI+uoqEtDTOS5PNvVc
         vZbW6fStIxHtLx6DVkEsmbdbn9P00VpK4OPSPG0booliUO+aVj2+eO0Mle3L8Omb+97p
         7Nhw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=acqG75nChdz0NKlCBaUDHivOgUFydlR1lE4J1UHbXOo=;
        b=LpJMXk4tKejebB4Tn/yV/NSyxhv+5IFuIGlExB0JVi5qes8Ht+nNJDjSFnMRuAxsTX
         zlDNA8exDZzgPBq1O97t0jNUYRRt5dFgggzWr71oDEaLypXRisCpKa1FKS+iFPFq6ZjU
         cqA6wRymcMUt4FSvnn2bCPwMrYS01oI4gGCUf9qHlGswK5ehy/Ld8h4p/K7NEKat9zZw
         NBrA0PdHJlUs5GgRTUVeeitO9kfhH4wg5wmRKrf5xVBYnNYM5tnb5Ot+YIil6TuS79gt
         oHf9C3M/6qaETHeqNvqynvnCYtejgJbt5J9WOlYnZUiuLmLTqjo6TUNAYAYgK0Hpserm
         VI9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=mslzkjz3;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id x26si1803wmk.36.2019.03.12.15.16.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 15:16:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=mslzkjz3;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44Jq7Q2VQKz9tylk;
	Tue, 12 Mar 2019 23:16:18 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=mslzkjz3; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id kQJExDHdjdbS; Tue, 12 Mar 2019 23:16:18 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44Jq7Q1MdLzB09ZG;
	Tue, 12 Mar 2019 23:16:18 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1552428978; bh=acqG75nChdz0NKlCBaUDHivOgUFydlR1lE4J1UHbXOo=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=mslzkjz309VjCj2gAhQK7SJYEHF6BddifXNIuPsHQ3b1X4xhoBE5ORIif8L3IIDtO
	 jPRlBMjFLE80b9TqrnMAYfdk1NNLZBgcaMXKAqBTDpk5DJbsVUCRck+sZBkFwdUuGv
	 bl9RxuHXHiti1w1eN5COxl9Z68hYJWdXdo9VvZms=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 677AE8B8B1;
	Tue, 12 Mar 2019 23:16:18 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id zYRs_Sbl-S64; Tue, 12 Mar 2019 23:16:18 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 2D75D8B8A7;
	Tue, 12 Mar 2019 23:16:18 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id EB7576FA15; Tue, 12 Mar 2019 22:16:17 +0000 (UTC)
Message-Id: <0cbf282d566c67a3cded4f41f64fc29420b80aa8.1552428161.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1552428161.git.christophe.leroy@c-s.fr>
References: <cover.1552428161.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v10 12/18] powerpc/32s: move hash code patching out of
 MMU_init_hw()
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 12 Mar 2019 22:16:17 +0000 (UTC)
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
index 3ee42c0ada69..0bfaf64e67ee 100644
--- a/arch/powerpc/kernel/head_32.S
+++ b/arch/powerpc/kernel/head_32.S
@@ -966,6 +966,9 @@ start_here:
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

