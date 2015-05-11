Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 723FB6B0081
	for <linux-mm@kvack.org>; Mon, 11 May 2015 11:53:14 -0400 (EDT)
Received: by wgic8 with SMTP id c8so106095778wgi.1
        for <linux-mm@kvack.org>; Mon, 11 May 2015 08:53:14 -0700 (PDT)
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com. [195.75.94.108])
        by mx.google.com with ESMTPS id aq6si22651704wjc.144.2015.05.11.08.52.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Mon, 11 May 2015 08:52:58 -0700 (PDT)
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dahi@linux.vnet.ibm.com>;
	Mon, 11 May 2015 16:52:57 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id C4B061B08069
	for <linux-mm@kvack.org>; Mon, 11 May 2015 16:53:40 +0100 (BST)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t4BFquTM54919324
	for <linux-mm@kvack.org>; Mon, 11 May 2015 15:52:56 GMT
Received: from d06av05.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t4BFqsOZ015358
	for <linux-mm@kvack.org>; Mon, 11 May 2015 09:52:55 -0600
From: David Hildenbrand <dahi@linux.vnet.ibm.com>
Subject: [PATCH v1 14/15] mips: properly lock access to the fpu
Date: Mon, 11 May 2015 17:52:19 +0200
Message-Id: <1431359540-32227-15-git-send-email-dahi@linux.vnet.ibm.com>
In-Reply-To: <1431359540-32227-1-git-send-email-dahi@linux.vnet.ibm.com>
References: <1431359540-32227-1-git-send-email-dahi@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: mingo@redhat.com, yang.shi@windriver.com, bigeasy@linutronix.de, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, borntraeger@de.ibm.com, mst@redhat.com, tglx@linutronix.de, David.Laight@ACULAB.COM, hughd@google.com, hocko@suse.cz, ralf@linux-mips.org, herbert@gondor.apana.org.au, linux@arm.linux.org.uk, airlied@linux.ie, daniel.vetter@intel.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, peterz@infradead.org, dahi@linux.vnet.ibm.com

Let's always disable preemption and pagefaults when locking the fpu,
so we can be sure that the owner won't change in between.

This is a preparation for pagefault_disable() not touching preemption
anymore.

Signed-off-by: David Hildenbrand <dahi@linux.vnet.ibm.com>
---
 arch/mips/kernel/signal-common.h | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/arch/mips/kernel/signal-common.h b/arch/mips/kernel/signal-common.h
index 06805e0..0b85f82 100644
--- a/arch/mips/kernel/signal-common.h
+++ b/arch/mips/kernel/signal-common.h
@@ -28,12 +28,7 @@ extern void __user *get_sigframe(struct ksignal *ksig, struct pt_regs *regs,
 extern int fpcsr_pending(unsigned int __user *fpcsr);
 
 /* Make sure we will not lose FPU ownership */
-#ifdef CONFIG_PREEMPT
-#define lock_fpu_owner()	preempt_disable()
-#define unlock_fpu_owner()	preempt_enable()
-#else
-#define lock_fpu_owner()	pagefault_disable()
-#define unlock_fpu_owner()	pagefault_enable()
-#endif
+#define lock_fpu_owner()	({ preempt_disable(); pagefault_disable(); })
+#define unlock_fpu_owner()	({ pagefault_enable(); preempt_enable(); })
 
 #endif	/* __SIGNAL_COMMON_H */
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
