Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id BC5706B0075
	for <linux-mm@kvack.org>; Mon, 11 May 2015 11:53:02 -0400 (EDT)
Received: by wgiu9 with SMTP id u9so132652994wgi.3
        for <linux-mm@kvack.org>; Mon, 11 May 2015 08:53:02 -0700 (PDT)
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com. [195.75.94.107])
        by mx.google.com with ESMTPS id cl7si22618832wjb.210.2015.05.11.08.52.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Mon, 11 May 2015 08:52:53 -0700 (PDT)
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dahi@linux.vnet.ibm.com>;
	Mon, 11 May 2015 16:52:51 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id D8CF217D8062
	for <linux-mm@kvack.org>; Mon, 11 May 2015 16:53:37 +0100 (BST)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t4BFqo138519960
	for <linux-mm@kvack.org>; Mon, 11 May 2015 15:52:50 GMT
Received: from d06av05.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t4BFqmRD014982
	for <linux-mm@kvack.org>; Mon, 11 May 2015 09:52:50 -0600
From: David Hildenbrand <dahi@linux.vnet.ibm.com>
Subject: [PATCH v1 08/15] futex: UP futex_atomic_op_inuser() relies on disabled preemption
Date: Mon, 11 May 2015 17:52:13 +0200
Message-Id: <1431359540-32227-9-git-send-email-dahi@linux.vnet.ibm.com>
In-Reply-To: <1431359540-32227-1-git-send-email-dahi@linux.vnet.ibm.com>
References: <1431359540-32227-1-git-send-email-dahi@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: mingo@redhat.com, yang.shi@windriver.com, bigeasy@linutronix.de, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, borntraeger@de.ibm.com, mst@redhat.com, tglx@linutronix.de, David.Laight@ACULAB.COM, hughd@google.com, hocko@suse.cz, ralf@linux-mips.org, herbert@gondor.apana.org.au, linux@arm.linux.org.uk, airlied@linux.ie, daniel.vetter@intel.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, peterz@infradead.org, dahi@linux.vnet.ibm.com

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
