Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 5C1746B0069
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 09:54:45 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so7137692pbb.33
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 06:54:45 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 01/11] mm: avoid increase sizeof(struct page) due to split page table lock
Date: Mon,  7 Oct 2013 16:54:03 +0300
Message-Id: <1381154053-4848-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1381154053-4848-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1381154053-4848-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

CONFIG_GENERIC_LOCKBREAK increases sizeof(spinlock_t) to 8 bytes.
It leads to increase sizeof(struct page) by 4 bytes on 32-bit system if
split page table lock is in use, since page->ptl shares space in union
with longs and pointers.

Let's disable split page table lock on 32-bit systems with
GENERIC_LOCKBREAK enabled.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/Kconfig b/mm/Kconfig
index 026771a9b0..6f5be0dac9 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -212,6 +212,7 @@ config SPLIT_PTLOCK_CPUS
 	default "999999" if ARM && !CPU_CACHE_VIPT
 	default "999999" if PARISC && !PA20
 	default "999999" if DEBUG_SPINLOCK || DEBUG_LOCK_ALLOC
+	default "999999" if !64BIT && GENERIC_LOCKBREAK
 	default "4"
 
 #
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
