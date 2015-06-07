Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 3CF6E6B0071
	for <linux-mm@kvack.org>; Sun,  7 Jun 2015 13:41:42 -0400 (EDT)
Received: by pabqy3 with SMTP id qy3so80070354pab.3
        for <linux-mm@kvack.org>; Sun, 07 Jun 2015 10:41:42 -0700 (PDT)
Received: from terminus.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id df1si370181pad.84.2015.06.07.10.41.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Jun 2015 10:41:41 -0700 (PDT)
Date: Sun, 7 Jun 2015 10:41:00 -0700
From: tip-bot for Toshi Kani <tipbot@zytor.com>
Message-ID: <tip-ecb2febaaa3945e1578359adc30ca818e78540fb@git.kernel.org>
Reply-To: tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        bp@suse.de, toshi.kani@hp.com, peterz@infradead.org,
        luto@amacapital.net, mingo@kernel.org, torvalds@linux-foundation.org,
        hpa@zytor.com, akpm@linux-foundation.org, mcgrof@suse.com
In-Reply-To: <1433436928-31903-7-git-send-email-bp@alien8.de>
References: <1433436928-31903-7-git-send-email-bp@alien8.de>
Subject: [tip:x86/mm] x86/mm: Teach is_new_memtype_allowed()
  about Write-Through type
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: tglx@linutronix.de, linux-kernel@vger.kernel.org, bp@suse.de, toshi.kani@hp.com, linux-mm@kvack.org, mingo@kernel.org, torvalds@linux-foundation.org, hpa@zytor.com, peterz@infradead.org, luto@amacapital.net, mcgrof@suse.com, akpm@linux-foundation.org

Commit-ID:  ecb2febaaa3945e1578359adc30ca818e78540fb
Gitweb:     http://git.kernel.org/tip/ecb2febaaa3945e1578359adc30ca818e78540fb
Author:     Toshi Kani <toshi.kani@hp.com>
AuthorDate: Thu, 4 Jun 2015 18:55:14 +0200
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Sun, 7 Jun 2015 15:28:55 +0200

x86/mm: Teach is_new_memtype_allowed() about Write-Through type

__ioremap_caller() calls reserve_memtype() and the passed down
@new_pcm contains the actual page cache type it reserved in the
success case.

is_new_memtype_allowed() verifies if converting to the new page
cache type is allowed when @pcm (the requested type) is
different from @new_pcm.

When WT is requested, the caller expects that writes are ordered
and uncached. Therefore, enhance is_new_memtype_allowed() to
disallow the following cases:

 - If the request is WT, mapping type cannot be WB
 - If the request is WT, mapping type cannot be WC

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Signed-off-by: Borislav Petkov <bp@suse.de>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Elliott@hp.com
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: arnd@arndb.de
Cc: hch@lst.de
Cc: hmh@hmh.eng.br
Cc: jgross@suse.com
Cc: konrad.wilk@oracle.com
Cc: linux-mm <linux-mm@kvack.org>
Cc: linux-nvdimm@lists.01.org
Cc: stefan.bader@canonical.com
Cc: yigal@plexistor.com
Link: http://lkml.kernel.org/r/1433436928-31903-7-git-send-email-bp@alien8.de
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/include/asm/pgtable.h | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index fe57e7a..2562e30 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -398,11 +398,17 @@ static inline int is_new_memtype_allowed(u64 paddr, unsigned long size,
 	 * requested memtype:
 	 * - request is uncached, return cannot be write-back
 	 * - request is write-combine, return cannot be write-back
+	 * - request is write-through, return cannot be write-back
+	 * - request is write-through, return cannot be write-combine
 	 */
 	if ((pcm == _PAGE_CACHE_MODE_UC_MINUS &&
 	     new_pcm == _PAGE_CACHE_MODE_WB) ||
 	    (pcm == _PAGE_CACHE_MODE_WC &&
-	     new_pcm == _PAGE_CACHE_MODE_WB)) {
+	     new_pcm == _PAGE_CACHE_MODE_WB) ||
+	    (pcm == _PAGE_CACHE_MODE_WT &&
+	     new_pcm == _PAGE_CACHE_MODE_WB) ||
+	    (pcm == _PAGE_CACHE_MODE_WT &&
+	     new_pcm == _PAGE_CACHE_MODE_WC)) {
 		return 0;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
