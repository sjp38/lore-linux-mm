Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6A2CE6B000C
	for <linux-mm@kvack.org>; Mon,  7 May 2018 22:35:33 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id p138-v6so10690679itc.3
        for <linux-mm@kvack.org>; Mon, 07 May 2018 19:35:33 -0700 (PDT)
Received: from mail1.bemta12.messagelabs.com (mail1.bemta12.messagelabs.com. [216.82.251.11])
        by mx.google.com with ESMTPS id z127-v6si8581670itg.32.2018.05.07.19.35.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 May 2018 19:35:32 -0700 (PDT)
From: Huaisheng HS1 Ye <yehs1@lenovo.com>
Subject: [External]  [RFC PATCH v1 6/6] arch/x86/mm: create page table mapping
 for DRAM and NVDIMM both
Date: Tue, 8 May 2018 02:35:13 +0000
Message-ID: <HK2PR03MB1684101846A9D9639BE00001929A0@HK2PR03MB1684.apcprd03.prod.outlook.com>
References: <1525746628-114136-1-git-send-email-yehs1@lenovo.com>
 <1525746628-114136-7-git-send-email-yehs1@lenovo.com>
In-Reply-To: <1525746628-114136-7-git-send-email-yehs1@lenovo.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "mhocko@suse.com" <mhocko@suse.com>, "willy@infradead.org" <willy@infradead.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "pasha.tatashin@oracle.com" <pasha.tatashin@oracle.com>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "penguin-kernel@I-love.SAKURA.ne.jp" <penguin-kernel@I-love.SAKURA.ne.jp>, "colyli@suse.de" <colyli@suse.de>, NingTing Cheng <chengnt@lenovo.com>, Ocean HY1 He <hehy1@lenovo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

Create PTE, PMD, PUD and P4D levels page table mapping for physical
addresses of DRAM and NVDIMM both. Here E820_TYPE_PMEM represents
the region of e820_table.

Signed-off-by: Huaisheng Ye <yehs1@lenovo.com>
Signed-off-by: Ocean He <hehy1@lenovo.com>
---
 arch/x86/mm/init_64.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index af11a28..c03c2091 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -420,6 +420,10 @@ void __init cleanup_highmap(void)
 			if (!after_bootmem &&
 			    !e820__mapped_any(paddr & PAGE_MASK, paddr_next,
 					     E820_TYPE_RAM) &&
+#ifdef CONFIG_ZONE_NVM
+			    !e820__mapped_any(paddr & PAGE_MASK, paddr_next,
+					     E820_TYPE_PMEM) &&
+#endif
 			    !e820__mapped_any(paddr & PAGE_MASK, paddr_next,
 					     E820_TYPE_RESERVED_KERN))
 				set_pte(pte, __pte(0));
@@ -475,6 +479,10 @@ void __init cleanup_highmap(void)
 			if (!after_bootmem &&
 			    !e820__mapped_any(paddr & PMD_MASK, paddr_next,
 					     E820_TYPE_RAM) &&
+#ifdef CONFIG_ZONE_NVM
+			    !e820__mapped_any(paddr & PAGE_MASK, paddr_next,
+					     E820_TYPE_PMEM) &&
+#endif
 			    !e820__mapped_any(paddr & PMD_MASK, paddr_next,
 					     E820_TYPE_RESERVED_KERN))
 				set_pmd(pmd, __pmd(0));
@@ -561,6 +569,10 @@ void __init cleanup_highmap(void)
 			if (!after_bootmem &&
 			    !e820__mapped_any(paddr & PUD_MASK, paddr_next,
 					     E820_TYPE_RAM) &&
+#ifdef CONFIG_ZONE_NVM
+			    !e820__mapped_any(paddr & PAGE_MASK, paddr_next,
+					     E820_TYPE_PMEM) &&
+#endif
 			    !e820__mapped_any(paddr & PUD_MASK, paddr_next,
 					     E820_TYPE_RESERVED_KERN))
 				set_pud(pud, __pud(0));
@@ -647,6 +659,10 @@ void __init cleanup_highmap(void)
 			if (!after_bootmem &&
 			    !e820__mapped_any(paddr & P4D_MASK, paddr_next,
 					     E820_TYPE_RAM) &&
+#ifdef CONFIG_ZONE_NVM
+			    !e820__mapped_any(paddr & PAGE_MASK, paddr_next,
+					     E820_TYPE_PMEM) &&
+#endif
 			    !e820__mapped_any(paddr & P4D_MASK, paddr_next,
 					     E820_TYPE_RESERVED_KERN))
 				set_p4d(p4d, __p4d(0));
--=20
1.8.3.1
