Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2A30F6B000C
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 10:39:28 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id j10-v6so7831165pgv.6
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 07:39:28 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id d191-v6si257904pga.192.2018.06.12.07.39.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jun 2018 07:39:26 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 05/17] x86/mm: Mask out KeyID bits from page table entry pfn
Date: Tue, 12 Jun 2018 17:39:03 +0300
Message-Id: <20180612143915.68065-6-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

MKTME claims several upper bits of the physical address in a page table
entry to encode KeyID. It effectively shrinks number of bits for
physical address. We should exclude KeyID bits from physical addresses.

For instance, if CPU enumerates 52 physical address bits and number of
bits claimed for KeyID is 6, bits 51:46 must not be threated as part
physical address.

This patch adjusts __PHYSICAL_MASK during MKTME enumeration.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/kernel/cpu/intel.c | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/arch/x86/kernel/cpu/intel.c b/arch/x86/kernel/cpu/intel.c
index eb75564f2d25..bf2caf9d52dd 100644
--- a/arch/x86/kernel/cpu/intel.c
+++ b/arch/x86/kernel/cpu/intel.c
@@ -571,6 +571,29 @@ static void detect_tme(struct cpuinfo_x86 *c)
 		mktme_status = MKTME_ENABLED;
 	}
 
+#ifdef CONFIG_X86_INTEL_MKTME
+	if (mktme_status == MKTME_ENABLED && nr_keyids) {
+		/*
+		 * Mask out bits claimed from KeyID from physical address mask.
+		 *
+		 * For instance, if a CPU enumerates 52 physical address bits
+		 * and number of bits claimed for KeyID is 6, bits 51:46 of
+		 * physical address is unusable.
+		 */
+		phys_addr_t keyid_mask;
+
+		keyid_mask = GENMASK_ULL(c->x86_phys_bits - 1, c->x86_phys_bits - keyid_bits);
+		physical_mask &= ~keyid_mask;
+	} else {
+		/*
+		 * Reset __PHYSICAL_MASK.
+		 * Maybe needed if there's inconsistent configuation
+		 * between CPUs.
+		 */
+		physical_mask = (1ULL << __PHYSICAL_MASK_SHIFT) - 1;
+	}
+#endif
+
 	/*
 	 * KeyID bits effectively lower the number of physical address
 	 * bits.  Update cpuinfo_x86::x86_phys_bits accordingly.
-- 
2.17.1
