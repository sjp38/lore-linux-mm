Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 850EF82F64
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 21:02:11 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so100755291pab.3
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 18:02:11 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id hu10si6444330pad.131.2015.10.09.18.02.10
        for <linux-mm@kvack.org>;
        Fri, 09 Oct 2015 18:02:10 -0700 (PDT)
Subject: [PATCH v2 12/20] mips: fix PAGE_MASK definition
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 09 Oct 2015 20:56:28 -0400
Message-ID: <20151010005628.17221.44732.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
References: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: linux-mips@linux-mips.org, linux-kernel@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-mm@kvack.org, ross.zwisler@linux.intel.com, hch@lst.de

Make PAGE_MASK an unsigned long, like it is on x86, to avoid:

In file included from arch/mips/kernel/asm-offsets.c:14:0:
include/linux/mm.h: In function '__pfn_to_pfn_t':
include/linux/mm.h:1050:2: warning: left shift count >= width of type
  pfn_t pfn_t = { .val = pfn | (flags & PFN_FLAGS_MASK), };

...where PFN_FLAGS_MASK is:

#define PFN_FLAGS_MASK (~PAGE_MASK << (BITS_PER_LONG - PAGE_SHIFT))

Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: linux-mips@linux-mips.org
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/mips/include/asm/page.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/mips/include/asm/page.h b/arch/mips/include/asm/page.h
index 89dd7fed1a57..ad1fccdb8d13 100644
--- a/arch/mips/include/asm/page.h
+++ b/arch/mips/include/asm/page.h
@@ -33,7 +33,7 @@
 #define PAGE_SHIFT	16
 #endif
 #define PAGE_SIZE	(_AC(1,UL) << PAGE_SHIFT)
-#define PAGE_MASK	(~((1 << PAGE_SHIFT) - 1))
+#define PAGE_MASK	(~(PAGE_SIZE - 1))
 
 /*
  * This is used for calculating the real page sizes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
