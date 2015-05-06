Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id D975B6B007B
	for <linux-mm@kvack.org>; Wed,  6 May 2015 13:51:12 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so19855546wgy.2
        for <linux-mm@kvack.org>; Wed, 06 May 2015 10:51:12 -0700 (PDT)
Received: from e06smtp17.uk.ibm.com (e06smtp17.uk.ibm.com. [195.75.94.113])
        by mx.google.com with ESMTPS id w6si1588038wib.76.2015.05.06.10.50.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Wed, 06 May 2015 10:50:53 -0700 (PDT)
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dahi@linux.vnet.ibm.com>;
	Wed, 6 May 2015 18:50:52 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id A566217D805D
	for <linux-mm@kvack.org>; Wed,  6 May 2015 18:51:35 +0100 (BST)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t46Hoobk64225426
	for <linux-mm@kvack.org>; Wed, 6 May 2015 17:50:50 GMT
Received: from d06av05.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t46Honvx027896
	for <linux-mm@kvack.org>; Wed, 6 May 2015 11:50:50 -0600
From: David Hildenbrand <dahi@linux.vnet.ibm.com>
Subject: [PATCH RFC 11/15] arm/futex: UP futex_atomic_op_inuser() relies on disabled preemption
Date: Wed,  6 May 2015 19:50:35 +0200
Message-Id: <1430934639-2131-12-git-send-email-dahi@linux.vnet.ibm.com>
In-Reply-To: <1430934639-2131-1-git-send-email-dahi@linux.vnet.ibm.com>
References: <1430934639-2131-1-git-send-email-dahi@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: dahi@linux.vnet.ibm.com, mingo@redhat.com, peterz@infradead.org, yang.shi@windriver.com, bigeasy@linutronix.de, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, borntraeger@de.ibm.com, mst@redhat.com, tglx@linutronix.de, David.Laight@ACULAB.COM, hughd@google.com, hocko@suse.cz, ralf@linux-mips.org, herbert@gondor.apana.org.au, linux@arm.linux.org.uk, airlied@linux.ie, daniel.vetter@intel.com, linux-mm@kvack.org, linux-arch@vger.kernel.org

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
