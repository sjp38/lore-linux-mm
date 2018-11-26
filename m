Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 74B926B41D6
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 06:05:30 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id s14so11073478pfk.16
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 03:05:30 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d12si20401600pla.351.2018.11.26.03.05.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 03:05:29 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.19 094/118] x86/ldt: Remove unused variable in map_ldt_struct()
Date: Mon, 26 Nov 2018 11:51:28 +0100
Message-Id: <20181126105105.473322783@linuxfoundation.org>
In-Reply-To: <20181126105059.832485122@linuxfoundation.org>
References: <20181126105059.832485122@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Andy Lutomirski <luto@kernel.org>, bp@alien8.de, hpa@zytor.com, dave.hansen@linux.intel.com, peterz@infradead.org, boris.ostrovsky@oracle.com, jgross@suse.com, bhe@redhat.com, willy@infradead.org, linux-mm@kvack.org, Sasha Levin <sashal@kernel.org>

4.19-stable review patch.  If anyone has any objections, please let me know.

------------------

commit b082f2dd80612015cd6d9d84e52099734ec9a0e1 upstream

Splitting out the sanity check in map_ldt_struct() moved page table syncing
into a separate function, which made the pgd variable unused. Remove it.

[ tglx: Massaged changelog ]

Fixes: 9bae3197e15d ("x86/ldt: Split out sanity check in map_ldt_struct()")
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Reviewed-by: Andy Lutomirski <luto@kernel.org>
Cc: bp@alien8.de
Cc: hpa@zytor.com
Cc: dave.hansen@linux.intel.com
Cc: peterz@infradead.org
Cc: boris.ostrovsky@oracle.com
Cc: jgross@suse.com
Cc: bhe@redhat.com
Cc: willy@infradead.org
Cc: linux-mm@kvack.org
Cc: stable@vger.kernel.org
Link: https://lkml.kernel.org/r/20181026122856.66224-4-kirill.shutemov@linux.intel.com
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 arch/x86/kernel/ldt.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/arch/x86/kernel/ldt.c b/arch/x86/kernel/ldt.c
index 2a71ded9b13e..65590eee6289 100644
--- a/arch/x86/kernel/ldt.c
+++ b/arch/x86/kernel/ldt.c
@@ -207,7 +207,6 @@ map_ldt_struct(struct mm_struct *mm, struct ldt_struct *ldt, int slot)
 	bool is_vmalloc;
 	spinlock_t *ptl;
 	int i, nr_pages;
-	pgd_t *pgd;
 
 	if (!static_cpu_has(X86_FEATURE_PTI))
 		return 0;
@@ -221,13 +220,6 @@ map_ldt_struct(struct mm_struct *mm, struct ldt_struct *ldt, int slot)
 	/* Check if the current mappings are sane */
 	sanity_check_ldt_mapping(mm);
 
-	/*
-	 * Did we already have the top level entry allocated?  We can't
-	 * use pgd_none() for this because it doens't do anything on
-	 * 4-level page table kernels.
-	 */
-	pgd = pgd_offset(mm, LDT_BASE_ADDR);
-
 	is_vmalloc = is_vmalloc_addr(ldt->entries);
 
 	nr_pages = DIV_ROUND_UP(ldt->nr_entries * LDT_ENTRY_SIZE, PAGE_SIZE);
-- 
2.17.1
