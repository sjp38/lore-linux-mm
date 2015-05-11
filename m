Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 4D0566B007D
	for <linux-mm@kvack.org>; Mon, 11 May 2015 11:53:07 -0400 (EDT)
Received: by wief7 with SMTP id f7so89567919wie.0
        for <linux-mm@kvack.org>; Mon, 11 May 2015 08:53:06 -0700 (PDT)
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com. [195.75.94.108])
        by mx.google.com with ESMTPS id fn5si402849wib.71.2015.05.11.08.52.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Mon, 11 May 2015 08:52:55 -0700 (PDT)
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dahi@linux.vnet.ibm.com>;
	Mon, 11 May 2015 16:52:54 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id DC1891B08023
	for <linux-mm@kvack.org>; Mon, 11 May 2015 16:53:36 +0100 (BST)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t4BFqqYe54132850
	for <linux-mm@kvack.org>; Mon, 11 May 2015 15:52:52 GMT
Received: from d06av05.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t4BFqo9P015088
	for <linux-mm@kvack.org>; Mon, 11 May 2015 09:52:51 -0600
From: David Hildenbrand <dahi@linux.vnet.ibm.com>
Subject: [PATCH v1 10/15] arm/futex: UP futex_atomic_cmpxchg_inatomic() relies on disabled preemption
Date: Mon, 11 May 2015 17:52:15 +0200
Message-Id: <1431359540-32227-11-git-send-email-dahi@linux.vnet.ibm.com>
In-Reply-To: <1431359540-32227-1-git-send-email-dahi@linux.vnet.ibm.com>
References: <1431359540-32227-1-git-send-email-dahi@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: mingo@redhat.com, yang.shi@windriver.com, bigeasy@linutronix.de, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, borntraeger@de.ibm.com, mst@redhat.com, tglx@linutronix.de, David.Laight@ACULAB.COM, hughd@google.com, hocko@suse.cz, ralf@linux-mips.org, herbert@gondor.apana.org.au, linux@arm.linux.org.uk, airlied@linux.ie, daniel.vetter@intel.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, peterz@infradead.org, dahi@linux.vnet.ibm.com

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
