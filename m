Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 958FC6B0078
	for <linux-mm@kvack.org>; Wed,  6 May 2015 13:51:10 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so19854559wgy.2
        for <linux-mm@kvack.org>; Wed, 06 May 2015 10:51:10 -0700 (PDT)
Received: from e06smtp17.uk.ibm.com (e06smtp17.uk.ibm.com. [195.75.94.113])
        by mx.google.com with ESMTPS id gv10si3372966wib.68.2015.05.06.10.50.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Wed, 06 May 2015 10:50:52 -0700 (PDT)
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dahi@linux.vnet.ibm.com>;
	Wed, 6 May 2015 18:50:51 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 36A831B0805F
	for <linux-mm@kvack.org>; Wed,  6 May 2015 18:51:31 +0100 (BST)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t46Homkm6095220
	for <linux-mm@kvack.org>; Wed, 6 May 2015 17:50:48 GMT
Received: from d06av05.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t46HoluJ027751
	for <linux-mm@kvack.org>; Wed, 6 May 2015 11:50:48 -0600
From: David Hildenbrand <dahi@linux.vnet.ibm.com>
Subject: [PATCH RFC 08/15] futex: UP futex_atomic_op_inuser() relies on disabled preemption
Date: Wed,  6 May 2015 19:50:32 +0200
Message-Id: <1430934639-2131-9-git-send-email-dahi@linux.vnet.ibm.com>
In-Reply-To: <1430934639-2131-1-git-send-email-dahi@linux.vnet.ibm.com>
References: <1430934639-2131-1-git-send-email-dahi@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: dahi@linux.vnet.ibm.com, mingo@redhat.com, peterz@infradead.org, yang.shi@windriver.com, bigeasy@linutronix.de, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, borntraeger@de.ibm.com, mst@redhat.com, tglx@linutronix.de, David.Laight@ACULAB.COM, hughd@google.com, hocko@suse.cz, ralf@linux-mips.org, herbert@gondor.apana.org.au, linux@arm.linux.org.uk, airlied@linux.ie, daniel.vetter@intel.com, linux-mm@kvack.org, linux-arch@vger.kernel.org

Let's explicitly disable/enable preemption in the !CONFIG_SMP version
of futex_atomic_op_inuser, to prepare for pagefault_disable() not
touching preemption anymore.

Otherwise we might break mutual exclusion when relying on a get_user()/
put_user() implementation.

Signed-off-by: David Hildenbrand <dahi@linux.vnet.ibm.com>
---
 include/asm-generic/futex.h | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/asm-generic/futex.h b/include/asm-generic/futex.h
index b59b5a5..3586017 100644
--- a/include/asm-generic/futex.h
+++ b/include/asm-generic/futex.h
@@ -8,8 +8,7 @@
 #ifndef CONFIG_SMP
 /*
  * The following implementation only for uniprocessor machines.
- * For UP, it's relies on the fact that pagefault_disable() also disables
- * preemption to ensure mutual exclusion.
+ * It relies on preempt_disable() ensuring mutual exclusion.
  *
  */
 
@@ -38,6 +37,7 @@ futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr)
 	if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28))
 		oparg = 1 << oparg;
 
+	preempt_disable();
 	pagefault_disable();
 
 	ret = -EFAULT;
@@ -72,6 +72,7 @@ futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr)
 
 out_pagefault_enable:
 	pagefault_enable();
+	preempt_enable();
 
 	if (ret == 0) {
 		switch (cmp) {
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
