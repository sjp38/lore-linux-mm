Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC976C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:08:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E3C8220C01
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:08:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="McRooZfy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E3C8220C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D380D8E000F; Wed, 31 Jul 2019 11:08:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C982A8E0010; Wed, 31 Jul 2019 11:08:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC6DE8E000F; Wed, 31 Jul 2019 11:08:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4609C8E000D
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:08:24 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id w25so42560283edu.11
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:08:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=UEVrEENQF6GgqskaCpeVIXbw1wxW9ZHP7LEfmwaIX1Y=;
        b=UStqyrMcYBZ7q5WeBTST26mMYNSCtdqfFfkbaAogSgGds9mlf/Vpn6pOMseeNXIR9m
         AUdoliUiCzRcG/q5dx/CR8sXltkn+RlcKOcoNjhGXY5O9zmTHlE+s1+YFtA4+nC5hdHC
         LMC+nze2LDEsJ92B9XFSNOHybEtWRcMNYv0ElmuxkzNDqOuEJ+RGdEatyEVSC06jIrdO
         lUq2JpjCtHaa9LrfyfytFJWa5ECJVENlNke3iSCcAQGJW2oeO3Ydmm7PVmPkN79pX5//
         L65ovhFoVpKP+KPWs0NtvRtY1/k7gVrIlAllfHJA+8RlVCpbdMNSw3tQ8L5kwzJLPMs5
         CptA==
X-Gm-Message-State: APjAAAV2dcWff4y8lD/AG8FK8SMZGP8ULLEeZSgjv7mxKdUj8spv/Lny
	CRdkxDWwuhv4IGn5lQ1VkhJs6h+yfjyHthKdbsADfeEWRyxTJbTV60s5mbCInewkyj4uy+EhTPk
	nb5+wg6CRxeqMybIQKSqq4MMNSBzlYQ8i59GTplbeUmrkbjsR0Y1bpmz4CHvR/w8=
X-Received: by 2002:a17:906:a39a:: with SMTP id k26mr46259656ejz.82.1564585703499;
        Wed, 31 Jul 2019 08:08:23 -0700 (PDT)
X-Received: by 2002:a17:906:a39a:: with SMTP id k26mr46259507ejz.82.1564585701946;
        Wed, 31 Jul 2019 08:08:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564585701; cv=none;
        d=google.com; s=arc-20160816;
        b=kV97t7yTbkpF1aO2Wu/NSsZ0QFmTVfKwT2YX5WWtuyFE7qq05DAbtjnvhjEuiqNNnr
         iDkvU3vfdPs0UvzDgU5pLoy508+U/nFbUec9ZhaFTxYAqm9MRVxn4aMyyLrl8P2EOVIc
         87xLKBjIWCD2XLf3P5K91MSdyURLNVedaYqdsFmTMkdvewdXJ03VVeeksYlNg9JzM4lz
         D1hUpmwEYvw3HoPHXq9VhZfXpWD6dDGHrOkuhmaFkuD/LcI8q8FW1OlK1FslKGENdjh7
         Ki9GDO6edwPQyqmxIRfIBg1aVWUsKGvnxpARuJqgBmv1V91H3ViEq8R0FrLb9lqW1kEU
         NmDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=UEVrEENQF6GgqskaCpeVIXbw1wxW9ZHP7LEfmwaIX1Y=;
        b=qsGavfxTqd6Uu4HMybF7vxElpqgywErqlJjIwp0GzkCM8s2KBJE/9EMEVAcDqMmgLX
         Cf+nj+ZEU/uI0meD+U+JW28eInJFfTnT8WtnvEE7IemTTPD8s6M/5CpPG51EcJDujePs
         CxQWETZC8irquX9GtLTJyhVWjPX5AV0bVQqQZ1T3UJl0DWFUoba7TsdDa2sa0k3Pb8wP
         sq197BRkBRhB9ca03/F+bS5PgSdXCazoPUr3tpRBf4au9oUu1KqG3oGJGEuxfnBA1O9u
         WxZ5aEbp0w5INWvxUhR1feNQ5COHPvwPbVACIZJI5JqJkORIZvd3XvzNMHrFIuR8ROM+
         HbAw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=McRooZfy;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x7sor52262615edx.26.2019.07.31.08.08.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:08:21 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=McRooZfy;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=UEVrEENQF6GgqskaCpeVIXbw1wxW9ZHP7LEfmwaIX1Y=;
        b=McRooZfyR/RpXN5XMwhhQ4fnXOkpn46XyCphce8PhxPou3dx2i+zeEUPZwHp8TipgC
         BGI1enXNjaRfPWABi/58N/CnaStzBfe7I/sVoHLEwUVWO5RPpvbMnQlhUk+vrP5KitP0
         xlN7apakZ23IIc8QM67elrLhwzfh8ZdwIfgG4AOrbh58L2rHumcrLS2HKAJ0RvRNAs4E
         tHD5vqNYW5h49SvrGSAt/0No/7IhX7t7K59+y1G7hgFuma9uWtGUIV6MdVueE6BaPNDj
         +qOFDedI65e57Y1anrGxh7x7TSxMfmTc9skU5uDbNPifz28H6hTWzz2877Q1hXd1xky2
         0RXg==
X-Google-Smtp-Source: APXvYqz0kJ4Lqf/rOwIPdDm01UGfUWsjDSwUjlM7k6Av4cmEuFi6nnooAYqixqH6Nb/ho2xl1lQryA==
X-Received: by 2002:a50:a3ec:: with SMTP id t41mr107352548edb.43.1564585701601;
        Wed, 31 Jul 2019 08:08:21 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id a9sm17507685edc.44.2019.07.31.08.08.18
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:08:19 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 33AC2101321; Wed, 31 Jul 2019 18:08:16 +0300 (+03)
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
Subject: [PATCHv2 10/59] x86/mm: Preserve KeyID on pte_modify() and pgprot_modify()
Date: Wed, 31 Jul 2019 18:07:24 +0300
Message-Id: <20190731150813.26289-11-kirill.shutemov@linux.intel.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190731150813.26289-1-kirill.shutemov@linux.intel.com>
References: <20190731150813.26289-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

An encrypted VMA will have KeyID stored in vma->vm_page_prot. This way
we don't need to do anything special to setup encrypted page table
entries and don't need to reserve space for KeyID in a VMA.

This patch changes _PAGE_CHG_MASK to include KeyID bits. Otherwise they
are going to be stripped from vm_page_prot on the first pgprot_modify().

Define PTE_PFN_MASK_MAX similar to PTE_PFN_MASK but based on
__PHYSICAL_MASK_SHIFT. This way we include whole range of bits
architecturally available for PFN without referencing physical_mask and
mktme_keyid_mask variables.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/pgtable_types.h | 23 ++++++++++++++++++-----
 1 file changed, 18 insertions(+), 5 deletions(-)

diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index b5e49e6bac63..c23793146759 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -116,12 +116,25 @@
 				 _PAGE_ACCESSED | _PAGE_DIRTY)
 
 /*
- * Set of bits not changed in pte_modify.  The pte's
- * protection key is treated like _PAGE_RW, for
- * instance, and is *not* included in this mask since
- * pte_modify() does modify it.
+ * Set of bits not changed in pte_modify.
+ *
+ * The pte's protection key is treated like _PAGE_RW, for instance, and is
+ * *not* included in this mask since pte_modify() does modify it.
+ *
+ * They include the physical address and the memory encryption keyID.
+ * The paddr and the keyID never occupy the same bits at the same time.
+ * But, a given bit might be used for the keyID on one system and used for
+ * the physical address on another. As an optimization, we manage them in
+ * one unit here since their combination always occupies the same hardware
+ * bits. PTE_PFN_MASK_MAX stores combined mask.
+ *
+ * Cast PAGE_MASK to a signed type so that it is sign-extended if
+ * virtual addresses are 32-bits but physical addresses are larger
+ * (ie, 32-bit PAE).
  */
-#define _PAGE_CHG_MASK	(PTE_PFN_MASK | _PAGE_PCD | _PAGE_PWT |		\
+#define PTE_PFN_MASK_MAX \
+	(((signed long)PAGE_MASK) & ((1ULL << __PHYSICAL_MASK_SHIFT) - 1))
+#define _PAGE_CHG_MASK	(PTE_PFN_MASK_MAX | _PAGE_PCD | _PAGE_PWT |		\
 			 _PAGE_SPECIAL | _PAGE_ACCESSED | _PAGE_DIRTY |	\
 			 _PAGE_SOFT_DIRTY | _PAGE_DEVMAP)
 #define _HPAGE_CHG_MASK (_PAGE_CHG_MASK | _PAGE_PSE)
-- 
2.21.0

