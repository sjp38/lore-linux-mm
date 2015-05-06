Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2E6BC6B007D
	for <linux-mm@kvack.org>; Wed,  6 May 2015 13:51:15 -0400 (EDT)
Received: by widdi4 with SMTP id di4so31601803wid.0
        for <linux-mm@kvack.org>; Wed, 06 May 2015 10:51:14 -0700 (PDT)
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com. [195.75.94.109])
        by mx.google.com with ESMTPS id i7si6825488wjq.156.2015.05.06.10.50.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Wed, 06 May 2015 10:50:53 -0700 (PDT)
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dahi@linux.vnet.ibm.com>;
	Wed, 6 May 2015 18:50:52 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 1417D17D8059
	for <linux-mm@kvack.org>; Wed,  6 May 2015 18:51:35 +0100 (BST)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t46Honua61276336
	for <linux-mm@kvack.org>; Wed, 6 May 2015 17:50:49 GMT
Received: from d06av05.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t46HomqW027853
	for <linux-mm@kvack.org>; Wed, 6 May 2015 11:50:49 -0600
From: David Hildenbrand <dahi@linux.vnet.ibm.com>
Subject: [PATCH RFC 10/15] arm/futex: UP futex_atomic_cmpxchg_inatomic() relies on disabled preemption
Date: Wed,  6 May 2015 19:50:34 +0200
Message-Id: <1430934639-2131-11-git-send-email-dahi@linux.vnet.ibm.com>
In-Reply-To: <1430934639-2131-1-git-send-email-dahi@linux.vnet.ibm.com>
References: <1430934639-2131-1-git-send-email-dahi@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: dahi@linux.vnet.ibm.com, mingo@redhat.com, peterz@infradead.org, yang.shi@windriver.com, bigeasy@linutronix.de, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, borntraeger@de.ibm.com, mst@redhat.com, tglx@linutronix.de, David.Laight@ACULAB.COM, hughd@google.com, hocko@suse.cz, ralf@linux-mips.org, herbert@gondor.apana.org.au, linux@arm.linux.org.uk, airlied@linux.ie, daniel.vetter@intel.com, linux-mm@kvack.org, linux-arch@vger.kernel.org

The !CONFIG_SMP implementation of futex_atomic_cmpxchg_inatomic()
requires preemption to be disabled to guarantee mutual exclusion.
Let's make this explicit.

This patch is based on a patch by Sebastian Andrzej Siewior on the
-rt branch.

Signed-off-by: David Hildenbrand <dahi@linux.vnet.ibm.com>
---
 arch/arm/include/asm/futex.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/arm/include/asm/futex.h b/arch/arm/include/asm/futex.h
index 4e78065..255bfd1 100644
--- a/arch/arm/include/asm/futex.h
+++ b/arch/arm/include/asm/futex.h
@@ -93,6 +93,7 @@ futex_atomic_cmpxchg_inatomic(u32 *uval, u32 __user *uaddr,
 	if (!access_ok(VERIFY_WRITE, uaddr, sizeof(u32)))
 		return -EFAULT;
 
+	preempt_disable();
 	__asm__ __volatile__("@futex_atomic_cmpxchg_inatomic\n"
 	"1:	" TUSER(ldr) "	%1, [%4]\n"
 	"	teq	%1, %2\n"
@@ -104,6 +105,8 @@ futex_atomic_cmpxchg_inatomic(u32 *uval, u32 __user *uaddr,
 	: "cc", "memory");
 
 	*uval = val;
+	preempt_enable();
+
 	return ret;
 }
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
