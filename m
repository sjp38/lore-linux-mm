Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C020C43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 12:34:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B0904206DD
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 12:34:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="NHKG7N0/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B0904206DD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ADDF08E000D; Fri,  1 Mar 2019 07:33:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A674D8E0006; Fri,  1 Mar 2019 07:33:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E28F8E000D; Fri,  1 Mar 2019 07:33:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 292088E0006
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 07:33:52 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id p3so11298269wrs.7
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 04:33:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=iDP7gsyvcqTo9RdhF5mvEcZHsCZ/UEXVBMDee0rR734=;
        b=tl3o6YNr+hbp9we5u1XGaUQacC4OSUs/cJf25aB2j9TGx/vU4pzoW2BXV86oWaAwiK
         W6Kv3KWlP4N/rqhGGpWY7PZgES6e92aiF31yKGAQv6/mmM7UBIKHYaL7zAm0QITK7D7x
         7vtYoEfrb76LVeopvfkXeChZcfHlE+ulfj87kSSI3RDvR9uMzRSw9FIgu9lVI/20kfA4
         E8uqvcShy5Ll8g5CQ0A88t+MgP2A0+0g0Ng61L5isW4KNqiTIWCFvlcE37aBCdo3APai
         Ctsz/e3ig7k80hPzGM9x2zW4pCwJXqwbkAS1JsG7ifYb6a9bPrQTU4YrpyMsrgVxcHYl
         /c0w==
X-Gm-Message-State: AHQUAuZd7rtN8v6IS8qTlFeomYFh6vmOW2Y/uzRiTS1ZfesdY5HDiF2M
	j766jgOpg8/gWbmJjjp4GjGyz6ttbyCl+QrmzT73o6bx7VQ7k5e7kYHl4yDK1jl4Y6TsWLXQQ2d
	N5n+RIxDFCzwZ3LxcacnirErj4TI+OvhIomItbt6FBxV03ZsbZwIRDd7UAY4owpQ2Hg==
X-Received: by 2002:a1c:a186:: with SMTP id k128mr3014812wme.54.1551443631617;
        Fri, 01 Mar 2019 04:33:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbCAHQjneH2tk/wxXrzMSbkDxtfpXiLTi/38iAdq0K4Ts88Na5rkwAAkOHlWqYTdc+NMFGW
X-Received: by 2002:a1c:a186:: with SMTP id k128mr3014742wme.54.1551443629841;
        Fri, 01 Mar 2019 04:33:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551443629; cv=none;
        d=google.com; s=arc-20160816;
        b=vESunvf7qGSRM5XI//7+/e0gGRTDhcQcMMjNKE8kb9FTWdqjkqhuw2fRCJrC5DbP91
         8j8Rx71uvSW5ihjppOGDgZrVD+kCq0QJs9imE/WMyIwID8cMYDzNlE4gJv+JJ7mPg+Yn
         GZ6BbrcOHjBebdXOku322EDFmyMhi8zQF4scAojOFB5PJyTVwgwchgugCfz4t7r/vZpp
         eLdS8CXqyuRAm/Vor4A7+F/Na6H0asrHszfWU+zFRDAcTGgAX8wX1CbJrhrgn1GdVX1p
         I9a5JU9YhJZ0qJsKVmB+5SjXc2S9DvtU55boavf5WsuH1eCymln2izuX3p+jbDJQuiL+
         Mxwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=iDP7gsyvcqTo9RdhF5mvEcZHsCZ/UEXVBMDee0rR734=;
        b=w+xEEi2SZpJC9b7EJFaMpZZH6edG5jCSqNJAgNsVkJhCJrcd7qwvnucX1tH7f78M/S
         3a9T4EOeN7UuqpA5+dUI4vZL29t57IH5kjgpl1pghbx1awBBwQOWod44qJDJgeDwRhR+
         o8NALjubY7655VpQE6J0ARalTbuGzLc9ElSEHDDywYS4fmGITsw7C97Gvrvv+PPy7xMy
         WYHfEpxGl97iLGDMP5fq89UmqagWcUM3p7hAx4+zuAuqC1rv3xjvZAvVK3kad0Uh+TU2
         /fpGEj3Pwrx42xuZTApuR1tA89y2R78l1bO39x8XjA6681TbHYBFMSFT0HSmVqcYw/ke
         6DGA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b="NHKG7N0/";
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id d6si78026wrv.172.2019.03.01.04.33.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 04:33:49 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b="NHKG7N0/";
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 449pkM5ygtz9txrx;
	Fri,  1 Mar 2019 13:33:47 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=NHKG7N0/; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id kgZlPUTjQ4vs; Fri,  1 Mar 2019 13:33:47 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 449pkM3mBtz9txrh;
	Fri,  1 Mar 2019 13:33:47 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1551443627; bh=iDP7gsyvcqTo9RdhF5mvEcZHsCZ/UEXVBMDee0rR734=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=NHKG7N0/a2VHnWnssuQPDjyqdh8s+45CBeHJAWULfSNKeDCxRXNaBh6L+HWRSU6lG
	 is+W1ZOteFBe8xziEsvJxKrnhJNkT9cYhZ7GsgfXxb4FnlRBn2WjVxccTD5OZCc12H
	 agPEkw2VHiHTFkCPrRqWuxwIVjPZX8HvZWVD9aKI=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id CB6118BB8B;
	Fri,  1 Mar 2019 13:33:48 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id STarbLg2zQUC; Fri,  1 Mar 2019 13:33:48 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 815AA8BB73;
	Fri,  1 Mar 2019 13:33:48 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 5C7226F89E; Fri,  1 Mar 2019 12:33:48 +0000 (UTC)
Message-Id: <acc79a0cbc59aeaaacb76b894d1120c1fb3c032a.1551443453.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1551443452.git.christophe.leroy@c-s.fr>
References: <cover.1551443452.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v9 10/11] powerpc/32s: move hash code patching out of
 MMU_init_hw()
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Fri,  1 Mar 2019 12:33:48 +0000 (UTC)
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

