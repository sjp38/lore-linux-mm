Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 45E006B0003
	for <linux-mm@kvack.org>; Fri, 27 Apr 2018 23:18:17 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id v14-v6so2904476pgq.11
        for <linux-mm@kvack.org>; Fri, 27 Apr 2018 20:18:17 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i135-v6si2326777pgc.346.2018.04.27.20.18.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 27 Apr 2018 20:18:15 -0700 (PDT)
Date: Fri, 27 Apr 2018 20:18:10 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: provide a fallback for PAGE_KERNEL_RO for
 architectures
Message-ID: <20180428031810.GA14566@bombadil.infradead.org>
References: <20180428001526.22475-1-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180428001526.22475-1-mcgrof@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: arnd@arndb.de, gregkh@linuxfoundation.org, linux-arch@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

On Fri, Apr 27, 2018 at 05:15:26PM -0700, Luis R. Rodriguez wrote:
> Some architectures do not define PAGE_KERNEL_RO, best we can do
> for them is to provide a fallback onto PAGE_KERNEL. Remove the
> hack from the firmware loader and move it onto the asm-generic
> header, and document while at it the affected architectures
> which do not have a PAGE_KERNEL_RO:
> 
>   o alpha
>   o ia64
>   o m68k
>   o mips
>   o sparc64
>   o sparc

ia64 doesn't have it?

*fx: riffles through architecture book*

That seems like an oversight of the Linux port.  Tony, Fenghua, any thoughts?

(also, Luis, maybe move the PAGE_KERNEL_EXEC fallback the same way you
moved the PAGE_KERNEL_RO fallback?)

--- >8 ---

ia64: Add PAGE_KERNEL_RO and PAGE_KERNEL_EXEC

The rest of the kernel was falling back to simple PAGE_KERNEL pages; using
PAGE_KERNEL_RO and PAGE_KERNEL_EXEC provide better protection against
unintended writes.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

diff --git a/arch/ia64/include/asm/pgtable.h b/arch/ia64/include/asm/pgtable.h
index 165827774bea..041a32a7960d 100644
--- a/arch/ia64/include/asm/pgtable.h
+++ b/arch/ia64/include/asm/pgtable.h
@@ -23,7 +23,7 @@
 
 /*
  * First, define the various bits in a PTE.  Note that the PTE format
- * matches the VHPT short format, the firt doubleword of the VHPD long
+ * matches the VHPT short format, the first doubleword of the VHPD long
  * format, and the first doubleword of the TLB insertion format.
  */
 #define _PAGE_P_BIT		0
@@ -142,9 +142,11 @@
 #define PAGE_COPY_EXEC	__pgprot(__ACCESS_BITS | _PAGE_PL_3 | _PAGE_AR_RX)
 #define PAGE_GATE	__pgprot(__ACCESS_BITS | _PAGE_PL_0 | _PAGE_AR_X_RX)
 #define PAGE_KERNEL	__pgprot(__DIRTY_BITS  | _PAGE_PL_0 | _PAGE_AR_RWX)
-#define PAGE_KERNELRX	__pgprot(__ACCESS_BITS | _PAGE_PL_0 | _PAGE_AR_RX)
+#define PAGE_KERNEL_RO	__pgprot(__ACCESS_BITS | _PAGE_PL_0 | _PAGE_AR_R)
+#define PAGE_KERNEL_RX	__pgprot(__ACCESS_BITS | _PAGE_PL_0 | _PAGE_AR_RX)
 #define PAGE_KERNEL_UC	__pgprot(__DIRTY_BITS  | _PAGE_PL_0 | _PAGE_AR_RWX | \
 				 _PAGE_MA_UC)
+#define PAGE_KERNEL_EXEC	PAGE_KERNEL_RX
 
 # ifndef __ASSEMBLY__
 
