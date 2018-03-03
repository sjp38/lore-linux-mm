Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B5A2F6B0008
	for <linux-mm@kvack.org>; Sat,  3 Mar 2018 17:41:10 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id k62so5820347pgd.11
        for <linux-mm@kvack.org>; Sat, 03 Mar 2018 14:41:10 -0800 (PST)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0092.outbound.protection.outlook.com. [104.47.38.92])
        by mx.google.com with ESMTPS id c26si6109683pgn.716.2018.03.03.14.41.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 03 Mar 2018 14:41:09 -0800 (PST)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: [PATCH AUTOSEL for 3.18 22/63] mm: Fix false-positive VM_BUG_ON() in
 page_cache_{get,add}_speculative()
Date: Sat, 3 Mar 2018 22:33:22 +0000
Message-ID: <20180303223228.27323-22-alexander.levin@microsoft.com>
References: <20180303223228.27323-1-alexander.levin@microsoft.com>
In-Reply-To: <20180303223228.27323-1-alexander.levin@microsoft.com>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A . Shutemov" <kirill@shutemov.name>, LKP <lkp@01.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@kernel.org>, Sasha Levin <Alexander.Levin@microsoft.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

[ Upstream commit 591a3d7c09fa08baff48ad86c2347dbd28a52753 ]

0day testing by Fengguang Wu triggered this crash while running Trinity:

  kernel BUG at include/linux/pagemap.h:151!
  ...
  CPU: 0 PID: 458 Comm: trinity-c0 Not tainted 4.11.0-rc2-00251-g2947ba0 #1
  ...
  Call Trace:
   __get_user_pages_fast()
   get_user_pages_fast()
   get_futex_key()
   futex_requeue()
   do_futex()
   SyS_futex()
   do_syscall_64()
   entry_SYSCALL64_slow_path()

It' VM_BUG_ON() due to false-negative in_atomic(). We call
page_cache_get_speculative() with disabled local interrupts.
It should be atomic enough.

So let's check for disabled interrupts in the VM_BUG_ON() condition
too, to resolve this.

( This got triggered by the conversion of the x86 GUP code to the
  generic GUP code. )

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Cc: Kirill A. Shutemov <kirill@shutemov.name>
Cc: LKP <lkp@01.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/20170324114709.pcytvyb3d6ajux33@black.fi.int=
el.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Sasha Levin <alexander.levin@microsoft.com>
---
 include/linux/pagemap.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 30a8f531236c..2629fc3e24e0 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -146,7 +146,7 @@ static inline int page_cache_get_speculative(struct pag=
e *page)
=20
 #ifdef CONFIG_TINY_RCU
 # ifdef CONFIG_PREEMPT_COUNT
-	VM_BUG_ON(!in_atomic());
+	VM_BUG_ON(!in_atomic() && !irqs_disabled());
 # endif
 	/*
 	 * Preempt must be disabled here - we rely on rcu_read_lock doing
@@ -184,7 +184,7 @@ static inline int page_cache_add_speculative(struct pag=
e *page, int count)
=20
 #if !defined(CONFIG_SMP) && defined(CONFIG_TREE_RCU)
 # ifdef CONFIG_PREEMPT_COUNT
-	VM_BUG_ON(!in_atomic());
+	VM_BUG_ON(!in_atomic() && !irqs_disabled());
 # endif
 	VM_BUG_ON_PAGE(page_count(page) =3D=3D 0, page);
 	atomic_add(count, &page->_count);
--=20
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
