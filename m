Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id B9CD36B0082
	for <linux-mm@kvack.org>; Mon, 11 May 2015 11:53:16 -0400 (EDT)
Received: by widdi4 with SMTP id di4so101833013wid.0
        for <linux-mm@kvack.org>; Mon, 11 May 2015 08:53:16 -0700 (PDT)
Received: from e06smtp17.uk.ibm.com (e06smtp17.uk.ibm.com. [195.75.94.113])
        by mx.google.com with ESMTPS id l9si413992wiv.44.2015.05.11.08.52.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Mon, 11 May 2015 08:52:58 -0700 (PDT)
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dahi@linux.vnet.ibm.com>;
	Mon, 11 May 2015 16:52:57 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id A7859219006A
	for <linux-mm@kvack.org>; Mon, 11 May 2015 16:52:34 +0100 (BST)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t4BFqrm55964096
	for <linux-mm@kvack.org>; Mon, 11 May 2015 15:52:53 GMT
Received: from d06av05.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t4BFqprP015138
	for <linux-mm@kvack.org>; Mon, 11 May 2015 09:52:52 -0600
From: David Hildenbrand <dahi@linux.vnet.ibm.com>
Subject: [PATCH v1 11/15] arm/futex: UP futex_atomic_op_inuser() relies on disabled preemption
Date: Mon, 11 May 2015 17:52:16 +0200
Message-Id: <1431359540-32227-12-git-send-email-dahi@linux.vnet.ibm.com>
In-Reply-To: <1431359540-32227-1-git-send-email-dahi@linux.vnet.ibm.com>
References: <1431359540-32227-1-git-send-email-dahi@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: mingo@redhat.com, yang.shi@windriver.com, bigeasy@linutronix.de, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, borntraeger@de.ibm.com, mst@redhat.com, tglx@linutronix.de, David.Laight@ACULAB.COM, hughd@google.com, hocko@suse.cz, ralf@linux-mips.org, herbert@gondor.apana.org.au, linux@arm.linux.org.uk, airlied@linux.ie, daniel.vetter@intel.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, peterz@infradead.org, dahi@linux.vnet.ibm.com

The !CONFIG_SMP implementation of futex_atomic_op_inuser() seems to rely
on disabled preemption to guarantee mutual exclusion.

>From commit e589ed23dd27:
    "For UP it's enough to disable preemption to ensure mutual exclusion..."
>From the code itself:
    "!SMP, we can work around lack of atomic ops by disabling preemption"

Let's make this explicit, to prepare for pagefault_disable() not
touching preemption anymore.

Signed-off-by: David Hildenbrand <dahi@linux.vnet.ibm.com>
---
 arch/arm/include/asm/futex.h | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/arch/arm/include/asm/futex.h b/arch/arm/include/asm/futex.h
index 255bfd1..5eed828 100644
--- a/arch/arm/include/asm/futex.h
+++ b/arch/arm/include/asm/futex.h
@@ -127,7 +127,10 @@ futex_atomic_op_inuser (int encoded_op, u32 __user *uaddr)
 	if (!access_ok(VERIFY_WRITE, uaddr, sizeof(u32)))
 		return -EFAULT;
 
-	pagefault_disable();	/* implies preempt_disable() */
+#ifndef CONFIG_SMP
+	preempt_disable();
+#endif
+	pagefault_disable();
 
 	switch (op) {
 	case FUTEX_OP_SET:
@@ -149,7 +152,10 @@ futex_atomic_op_inuser (int encoded_op, u32 __user *uaddr)
 		ret = -ENOSYS;
 	}
 
-	pagefault_enable();	/* subsumes preempt_enable() */
+	pagefault_enable();
+#ifndef CONFIG_SMP
+	preempt_enable();
+#endif
 
 	if (!ret) {
 		switch (cmp) {
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
