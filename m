Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3B4FC04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:45:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A29D3216F4
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:45:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A29D3216F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BFD7F6B027E; Wed,  8 May 2019 10:44:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE9FE6B027C; Wed,  8 May 2019 10:44:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 939816B027B; Wed,  8 May 2019 10:44:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 58CB26B0278
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:47 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id z7so12816007pgc.1
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=F0ymXJAnrrXyppjxA1B59vs7TgNB0ViOHAJtcr83nEY=;
        b=g3OvjigzULXs7DEQwNFis/ieQN6h+ATZOI6ThcI+PGgY46EF5WjbuPjNLmrXS7xc/H
         ofPJT3repHi/JEAXCXIpxmPjRZwhFirlcswz+5PlZa/TgHfHy3igSstdvriP8GSjIF6A
         byCOyuEV4VYHXcVfE3OQiP6oSpidQDPcnABe5fKu0stqFtredFkHMJ0NWv85XewTsqGC
         Xx7kq61qJA4relnhpCXfI5qRQex/cGEwZP8y744s1kJywUQ+4Vkzq+5APIQc0aqzJB7o
         extDz/bpcKPYb/dGVpFZj0JROhe/YTTKjAcD/b96ExCcCJ843YwxvLnS+bYqC7/wyLIB
         akgQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVLKKJ20WRCOrTnYm9ruYwZ/qAD8nBmOiK8CcZwdOG5lwsAmFRI
	xHJ+dq1c0zM4SP2XwimXi9RCq5z1WLmlmYnRFSWgxmiFbZCPwV4o98TETV8B8gNcYX9Kl75W70k
	xsjlTTSg05IX5y/OFYI88v9nGuNwH/MmoH+KcjGFUKj9Yo+jnzivtQ3HjHvZN+UUxRQ==
X-Received: by 2002:a17:902:201:: with SMTP id 1mr1448316plc.89.1557326686968;
        Wed, 08 May 2019 07:44:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzG4cGBjtFCee5AXl/UzxqPwj8Wku/7rrdORvJM3mGfn+mTF10rkf95gXlAPZrJxSph537m
X-Received: by 2002:a17:902:201:: with SMTP id 1mr1448210plc.89.1557326685781;
        Wed, 08 May 2019 07:44:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326685; cv=none;
        d=google.com; s=arc-20160816;
        b=hHBvtdm3QB1rEjwMLZ6QUnvrQMta17LPzbfThckhTSWQRLJplX2jOjaWGJFJQerNrA
         ey19T63/8IAjWuzHokvvhkByzDUJAP8cMcngqpwY0/kqei9N5wD4PKan3u8/tukxe4nG
         AO4de5izjpQP4okWZVXGP68b54kWbC8ryZCTlgvORx2MqLc00XQ3Nh/mcnjPbLr2yLqv
         ydQz9XRq49iNfrhUlOKLt/1YtTBr4DJSwvbKAiqnI98nMrTApMO5D/AmguQeYWSNKnAS
         4AvGDVtW5CRRCABce5LwNqyJWUndQGXK0HRwHiS5u3DOshphbFSNZ/PSVVnBekSW3EED
         h4NA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=F0ymXJAnrrXyppjxA1B59vs7TgNB0ViOHAJtcr83nEY=;
        b=aJqbjJnR9/19RYPZql90QiyPRyqG1nJt+92XXglJyUE3MxGI3nAIgmOzEep+TA3ha4
         UUoFrAQBMm9aSWWlaonDHKTBhe2BznLIZiSIbmICctrULqEU5hAMPVbbtpG+5gdcYvVx
         LKFcOtCQuS88NFj7z+DXefBHyLtOT4cYkEV70LVe0rcoAD+ag3aZG2kcF/2bGFGM6+/K
         9JaNCmgbIYUCfzxiqx3erFXjll0MrJdbqplL1ileO0+5JCC6iQCJ2TCXxpYhDlsRGnf1
         ieSGA0AxVj5d802RwC189vTPrsQi3gzGWLpJGY/+OS4B1YQ5GeNqawWR4jAXg79/sg/K
         L6Ug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id y4si21166079pgv.154.2019.05.08.07.44.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:45 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga102.fm.intel.com with ESMTP; 08 May 2019 07:44:44 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by orsmga008.jf.intel.com with ESMTP; 08 May 2019 07:44:39 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 8189A9B0; Wed,  8 May 2019 17:44:29 +0300 (EEST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>
Cc: Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>,
	Alison Schofield <alison.schofield@intel.com>,
	linux-mm@kvack.org,
	kvm@vger.kernel.org,
	keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC 17/62] x86/mm: Calculate direct mapping size
Date: Wed,  8 May 2019 17:43:37 +0300
Message-Id: <20190508144422.13171-18-kirill.shutemov@linux.intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The kernel needs to have a way to access encrypted memory. We have two
option on how approach it:

 - Create temporary mappings every time kernel needs access to encrypted
   memory. That's basically brings highmem and its overhead back.

 - Create multiple direct mappings, one per-KeyID. In this setup we
   don't need to create temporary mappings on the fly -- encrypted
   memory is permanently available in kernel address space.

We take the second approach as it has lower overhead.

It's worth noting that with per-KeyID direct mappings compromised kernel
would give access to decrypted data right away without additional tricks
to get memory mapped with the correct KeyID.

Per-KeyID mappings require a lot more virtual address space. On 4-level
machine with 64 KeyIDs we max out 46-bit virtual address space dedicated
for direct mapping with 1TiB of RAM. Given that we round up any
calculation on direct mapping size to 1TiB, we effectively claim all
46-bit address space for direct mapping on such machine regardless of
RAM size.

Increased usage of virtual address space has implications for KASLR:
we have less space for randomization. With 64 TiB claimed for direct
mapping with 4-level we left with 27 TiB of entropy to place
page_offset_base, vmalloc_base and vmemmap_base.

5-level paging provides much wider virtual address space and KASLR
doesn't suffer significantly from per-KeyID direct mappings.

It's preferred to run MKTME with 5-level paging.

A direct mapping for each KeyID will be put next to each other in the
virtual address space. We need to have a way to find boundaries of
direct mapping for particular KeyID.

The new variable direct_mapping_size specifies the size of direct
mapping. With the value, it's trivial to find direct mapping for
KeyID-N: PAGE_OFFSET + N * direct_mapping_size.

Size of direct mapping is calculated during KASLR setup. If KALSR is
disabled it happens during MKTME initialization.

With MKTME size of direct mapping has to be power-of-2. It makes
implementation of __pa() efficient.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 Documentation/x86/x86_64/mm.txt |  4 +++
 arch/x86/include/asm/page_32.h  |  1 +
 arch/x86/include/asm/page_64.h  |  2 ++
 arch/x86/include/asm/setup.h    |  6 ++++
 arch/x86/kernel/head64.c        |  4 +++
 arch/x86/kernel/setup.c         |  3 ++
 arch/x86/mm/init_64.c           | 58 +++++++++++++++++++++++++++++++++
 arch/x86/mm/kaslr.c             | 11 +++++--
 8 files changed, 86 insertions(+), 3 deletions(-)

diff --git a/Documentation/x86/x86_64/mm.txt b/Documentation/x86/x86_64/mm.txt
index 804f9426ed17..81a1b96e0902 100644
--- a/Documentation/x86/x86_64/mm.txt
+++ b/Documentation/x86/x86_64/mm.txt
@@ -132,6 +132,10 @@ The direct mapping covers all memory in the system up to the highest
 memory address (this means in some cases it can also include PCI memory
 holes).
 
+With MKTME, we have multiple direct mappings. One per-KeyID. They are put
+next to each other. PAGE_OFFSET + N * direct_mapping_size can be used to
+find direct mapping for KeyID-N.
+
 vmalloc space is lazily synchronized into the different PML4/PML5 pages of
 the processes using the page fault handler, with init_top_pgt as
 reference.
diff --git a/arch/x86/include/asm/page_32.h b/arch/x86/include/asm/page_32.h
index 94dbd51df58f..8bce788f9ca9 100644
--- a/arch/x86/include/asm/page_32.h
+++ b/arch/x86/include/asm/page_32.h
@@ -6,6 +6,7 @@
 
 #ifndef __ASSEMBLY__
 
+#define direct_mapping_size 0
 #define __phys_addr_nodebug(x)	((x) - PAGE_OFFSET)
 #ifdef CONFIG_DEBUG_VIRTUAL
 extern unsigned long __phys_addr(unsigned long);
diff --git a/arch/x86/include/asm/page_64.h b/arch/x86/include/asm/page_64.h
index 939b1cff4a7b..f57fc3cc2246 100644
--- a/arch/x86/include/asm/page_64.h
+++ b/arch/x86/include/asm/page_64.h
@@ -14,6 +14,8 @@ extern unsigned long phys_base;
 extern unsigned long page_offset_base;
 extern unsigned long vmalloc_base;
 extern unsigned long vmemmap_base;
+extern unsigned long direct_mapping_size;
+extern unsigned long direct_mapping_mask;
 
 static inline unsigned long __phys_addr_nodebug(unsigned long x)
 {
diff --git a/arch/x86/include/asm/setup.h b/arch/x86/include/asm/setup.h
index ed8ec011a9fd..d2861074cf83 100644
--- a/arch/x86/include/asm/setup.h
+++ b/arch/x86/include/asm/setup.h
@@ -62,6 +62,12 @@ extern void x86_ce4100_early_setup(void);
 static inline void x86_ce4100_early_setup(void) { }
 #endif
 
+#ifdef CONFIG_MEMORY_PHYSICAL_PADDING
+void calculate_direct_mapping_size(void);
+#else
+static inline void calculate_direct_mapping_size(void) { }
+#endif
+
 #ifndef _SETUP
 
 #include <asm/espfix.h>
diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index 16b1cbd3a61e..c1a3ef88cb08 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -60,6 +60,10 @@ EXPORT_SYMBOL(vmalloc_base);
 unsigned long vmemmap_base __ro_after_init = __VMEMMAP_BASE_L4;
 EXPORT_SYMBOL(vmemmap_base);
 #endif
+unsigned long direct_mapping_size __ro_after_init = -1UL;
+EXPORT_SYMBOL(direct_mapping_size);
+unsigned long direct_mapping_mask __ro_after_init = -1UL;
+EXPORT_SYMBOL(direct_mapping_mask);
 
 #define __head	__section(.head.text)
 
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 3d872a527cd9..8b47e3e38926 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -1057,6 +1057,9 @@ void __init setup_arch(char **cmdline_p)
 	 */
 	init_cache_modes();
 
+	 /* direct_mapping_size has to be initialized before KASLR and MKTME */
+	calculate_direct_mapping_size();
+
 	/*
 	 * Define random base addresses for memory sections after max_pfn is
 	 * defined and before each memory section base is used.
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index bccff68e3267..3a08d707eec8 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1383,6 +1383,64 @@ unsigned long memory_block_size_bytes(void)
 	return memory_block_size_probed;
 }
 
+#ifdef CONFIG_MEMORY_PHYSICAL_PADDING
+void __init calculate_direct_mapping_size(void)
+{
+	unsigned long available_va;
+
+	/* 1/4 of virtual address space is didicated for direct mapping */
+	available_va = 1UL << (__VIRTUAL_MASK_SHIFT - 1);
+
+	/* How much memory the system has? */
+	direct_mapping_size = max_pfn << PAGE_SHIFT;
+	direct_mapping_size = round_up(direct_mapping_size, 1UL << 40);
+
+	if (!mktme_nr_keyids)
+		goto out;
+
+	/*
+	 * For MKTME we need direct_mapping_size to be power-of-2.
+	 * It makes __pa() implementation efficient.
+	 */
+	direct_mapping_size = roundup_pow_of_two(direct_mapping_size);
+
+	/*
+	 * Not enough virtual address space to address all physical memory with
+	 * MKTME enabled. Even without padding.
+	 *
+	 * Disable MKTME instead.
+	 */
+	if (direct_mapping_size > available_va / (mktme_nr_keyids + 1)) {
+		pr_err("x86/mktme: Disabled. Not enough virtual address space\n");
+		pr_err("x86/mktme: Consider switching to 5-level paging\n");
+		mktme_disable();
+		goto out;
+	}
+
+	/*
+	 * Virtual address space is divided between per-KeyID direct mappings.
+	 */
+	available_va /= mktme_nr_keyids + 1;
+out:
+	/* Add padding, if there's enough virtual address space */
+	direct_mapping_size += (1UL << 40) * CONFIG_MEMORY_PHYSICAL_PADDING;
+	if (mktme_nr_keyids)
+		direct_mapping_size = roundup_pow_of_two(direct_mapping_size);
+
+	if (direct_mapping_size > available_va)
+		direct_mapping_size = available_va;
+
+	/*
+	 * For MKTME, make sure direct_mapping_size is still power-of-2
+	 * after adding padding and calculate mask that is used in __pa().
+	 */
+	if (mktme_nr_keyids) {
+		direct_mapping_size = rounddown_pow_of_two(direct_mapping_size);
+		direct_mapping_mask = direct_mapping_size - 1;
+	}
+}
+#endif
+
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
 /*
  * Initialise the sparsemem vmemmap using huge-pages at the PMD level.
diff --git a/arch/x86/mm/kaslr.c b/arch/x86/mm/kaslr.c
index 2228cc7d6b42..9cfba6627603 100644
--- a/arch/x86/mm/kaslr.c
+++ b/arch/x86/mm/kaslr.c
@@ -102,10 +102,15 @@ void __init kernel_randomize_memory(void)
 	 * add padding if needed (especially for memory hotplug support).
 	 */
 	BUG_ON(kaslr_regions[0].base != &page_offset_base);
-	memory_tb = DIV_ROUND_UP(max_pfn << PAGE_SHIFT, 1UL << TB_SHIFT) +
-		CONFIG_MEMORY_PHYSICAL_PADDING;
 
-	/* Adapt phyiscal memory region size based on available memory */
+	/*
+	 * Calculate space required to map all physical memory.
+	 * In case of MKTME, we map physical memory multiple times, one for
+	 * each KeyID. If MKTME is disabled mktme_nr_keyids is 0.
+	 */
+	memory_tb = (direct_mapping_size * (mktme_nr_keyids + 1)) >> TB_SHIFT;
+
+	/* Adapt physical memory region size based on available memory */
 	if (memory_tb < kaslr_regions[0].size_tb)
 		kaslr_regions[0].size_tb = memory_tb;
 
-- 
2.20.1

