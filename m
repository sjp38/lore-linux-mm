Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 545C66B026E
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 08:18:05 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id h11-v6so6898121pfi.17
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 05:18:05 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id i128-v6si28492570pfb.256.2018.10.31.05.18.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 05:18:03 -0700 (PDT)
Date: Wed, 31 Oct 2018 15:17:59 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv3 2/3] x86/ldt: Unmap PTEs for the slot before freeing
 LDT pages
Message-ID: <20181031121758.wrxidqhkvegfh7h7@black.fi.intel.com>
References: <20181026122856.66224-1-kirill.shutemov@linux.intel.com>
 <20181026122856.66224-3-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181026122856.66224-3-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org
Cc: boris.ostrovsky@oracle.com, jgross@suse.com, bhe@redhat.com, willy@infradead.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Oct 26, 2018 at 12:28:55PM +0000, Kirill A. Shutemov wrote:
> +	va = (unsigned long)ldt_slot_va(ldt->slot);
> +	flush_tlb_mm_range(mm, va, va + nr_pages * PAGE_SIZE, 0, false);

I've got it wrong on rebase. It has to be PAGE_SHIFT instead of 0.
Here's the fix up.

diff --git a/arch/x86/kernel/ldt.c b/arch/x86/kernel/ldt.c
index 5dc8ed202fa8..60775dcd5bcc 100644
--- a/arch/x86/kernel/ldt.c
+++ b/arch/x86/kernel/ldt.c
@@ -287,7 +287,7 @@ unmap_ldt_struct(struct mm_struct *mm, struct ldt_struct *ldt)
 	}
 
 	va = (unsigned long)ldt_slot_va(ldt->slot);
-	flush_tlb_mm_range(mm, va, va + nr_pages * PAGE_SIZE, 0, false);
+	flush_tlb_mm_range(mm, va, va + nr_pages * PAGE_SIZE, PAGE_SHIFT, false);
 }
 
 #else /* !CONFIG_PAGE_TABLE_ISOLATION */
-- 
 Kirill A. Shutemov
