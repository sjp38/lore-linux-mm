Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 414996B0080
	for <linux-mm@kvack.org>; Mon, 11 May 2015 11:53:12 -0400 (EDT)
Received: by widdi4 with SMTP id di4so101830431wid.0
        for <linux-mm@kvack.org>; Mon, 11 May 2015 08:53:11 -0700 (PDT)
Received: from e06smtp17.uk.ibm.com (e06smtp17.uk.ibm.com. [195.75.94.113])
        by mx.google.com with ESMTPS id r1si370947wic.112.2015.05.11.08.52.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Mon, 11 May 2015 08:52:56 -0700 (PDT)
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dahi@linux.vnet.ibm.com>;
	Mon, 11 May 2015 16:52:55 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 9ED262190061
	for <linux-mm@kvack.org>; Mon, 11 May 2015 16:52:35 +0100 (BST)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t4BFqsj250987098
	for <linux-mm@kvack.org>; Mon, 11 May 2015 15:52:54 GMT
Received: from d06av05.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t4BFqqiA015213
	for <linux-mm@kvack.org>; Mon, 11 May 2015 09:52:53 -0600
From: David Hildenbrand <dahi@linux.vnet.ibm.com>
Subject: [PATCH v1 12/15] futex: clarify that preemption doesn't have to be disabled
Date: Mon, 11 May 2015 17:52:17 +0200
Message-Id: <1431359540-32227-13-git-send-email-dahi@linux.vnet.ibm.com>
In-Reply-To: <1431359540-32227-1-git-send-email-dahi@linux.vnet.ibm.com>
References: <1431359540-32227-1-git-send-email-dahi@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: mingo@redhat.com, yang.shi@windriver.com, bigeasy@linutronix.de, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, borntraeger@de.ibm.com, mst@redhat.com, tglx@linutronix.de, David.Laight@ACULAB.COM, hughd@google.com, hocko@suse.cz, ralf@linux-mips.org, herbert@gondor.apana.org.au, linux@arm.linux.org.uk, airlied@linux.ie, daniel.vetter@intel.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, peterz@infradead.org, dahi@linux.vnet.ibm.com

As arm64 and arc have no special implementations for !CONFIG_SMP, mutual
exclusion doesn't seem to rely on preemption.

Let's make it clear in the comments that preemption doesn't have to be
disabled when accessing user space in the futex code, so we can remove
preempt_disable() from pagefault_disable().

Signed-off-by: David Hildenbrand <dahi@linux.vnet.ibm.com>
---
 arch/arc/include/asm/futex.h   | 10 +++++-----
 arch/arm64/include/asm/futex.h |  4 ++--
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/arch/arc/include/asm/futex.h b/arch/arc/include/asm/futex.h
index 4dc64dd..05b5aaf 100644
--- a/arch/arc/include/asm/futex.h
+++ b/arch/arc/include/asm/futex.h
@@ -53,7 +53,7 @@ static inline int futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr)
 	if (!access_ok(VERIFY_WRITE, uaddr, sizeof(int)))
 		return -EFAULT;
 
-	pagefault_disable();	/* implies preempt_disable() */
+	pagefault_disable();
 
 	switch (op) {
 	case FUTEX_OP_SET:
@@ -75,7 +75,7 @@ static inline int futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr)
 		ret = -ENOSYS;
 	}
 
-	pagefault_enable();	/* subsumes preempt_enable() */
+	pagefault_enable();
 
 	if (!ret) {
 		switch (cmp) {
@@ -104,7 +104,7 @@ static inline int futex_atomic_op_inuser(int encoded_op, u32 __user *uaddr)
 	return ret;
 }
 
-/* Compare-xchg with preemption disabled.
+/* Compare-xchg with pagefaults disabled.
  *  Notes:
  *      -Best-Effort: Exchg happens only if compare succeeds.
  *          If compare fails, returns; leaving retry/looping to upper layers
@@ -121,7 +121,7 @@ futex_atomic_cmpxchg_inatomic(u32 *uval, u32 __user *uaddr, u32 oldval,
 	if (!access_ok(VERIFY_WRITE, uaddr, sizeof(int)))
 		return -EFAULT;
 
-	pagefault_disable();	/* implies preempt_disable() */
+	pagefault_disable();
 
 	/* TBD : can use llock/scond */
 	__asm__ __volatile__(
@@ -142,7 +142,7 @@ futex_atomic_cmpxchg_inatomic(u32 *uval, u32 __user *uaddr, u32 oldval,
 	: "r"(oldval), "r"(newval), "r"(uaddr), "ir"(-EFAULT)
 	: "cc", "memory");
 
-	pagefault_enable();	/* subsumes preempt_enable() */
+	pagefault_enable();
 
 	*uval = val;
 	return val;
diff --git a/arch/arm64/include/asm/futex.h b/arch/arm64/include/asm/futex.h
index 5f750dc..74069b3 100644
--- a/arch/arm64/include/asm/futex.h
+++ b/arch/arm64/include/asm/futex.h
@@ -58,7 +58,7 @@ futex_atomic_op_inuser (int encoded_op, u32 __user *uaddr)
 	if (!access_ok(VERIFY_WRITE, uaddr, sizeof(u32)))
 		return -EFAULT;
 
-	pagefault_disable();	/* implies preempt_disable() */
+	pagefault_disable();
 
 	switch (op) {
 	case FUTEX_OP_SET:
@@ -85,7 +85,7 @@ futex_atomic_op_inuser (int encoded_op, u32 __user *uaddr)
 		ret = -ENOSYS;
 	}
 
-	pagefault_enable();	/* subsumes preempt_enable() */
+	pagefault_enable();
 
 	if (!ret) {
 		switch (cmp) {
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
