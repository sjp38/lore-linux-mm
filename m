Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 6132F6B007D
	for <linux-mm@kvack.org>; Mon, 11 May 2015 11:53:10 -0400 (EDT)
Received: by wgin8 with SMTP id n8so132715140wgi.0
        for <linux-mm@kvack.org>; Mon, 11 May 2015 08:53:09 -0700 (PDT)
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com. [195.75.94.111])
        by mx.google.com with ESMTPS id i7si430503wib.26.2015.05.11.08.52.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Mon, 11 May 2015 08:52:55 -0700 (PDT)
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dahi@linux.vnet.ibm.com>;
	Mon, 11 May 2015 16:52:54 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id EE62F17D8067
	for <linux-mm@kvack.org>; Mon, 11 May 2015 16:53:38 +0100 (BST)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t4BFqpAH54919312
	for <linux-mm@kvack.org>; Mon, 11 May 2015 15:52:51 GMT
Received: from d06av05.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t4BFqnOl015047
	for <linux-mm@kvack.org>; Mon, 11 May 2015 09:52:51 -0600
From: David Hildenbrand <dahi@linux.vnet.ibm.com>
Subject: [PATCH v1 09/15] futex: UP futex_atomic_cmpxchg_inatomic() relies on disabled preemption
Date: Mon, 11 May 2015 17:52:14 +0200
Message-Id: <1431359540-32227-10-git-send-email-dahi@linux.vnet.ibm.com>
In-Reply-To: <1431359540-32227-1-git-send-email-dahi@linux.vnet.ibm.com>
References: <1431359540-32227-1-git-send-email-dahi@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: mingo@redhat.com, yang.shi@windriver.com, bigeasy@linutronix.de, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, borntraeger@de.ibm.com, mst@redhat.com, tglx@linutronix.de, David.Laight@ACULAB.COM, hughd@google.com, hocko@suse.cz, ralf@linux-mips.org, herbert@gondor.apana.org.au, linux@arm.linux.org.uk, airlied@linux.ie, daniel.vetter@intel.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, peterz@infradead.org, dahi@linux.vnet.ibm.com

Let's explicitly disable/enable preemption in the !CONFIG_SMP version
of futex_atomic_cmpxchg_inatomic, to prepare for pagefault_disable() not
touching preemption anymore. This is needed for this function to be
callable from both, atomic and non-atomic context.

Otherwise we might break mutual exclusion when relying on a get_user()/
put_user() implementation.

Signed-off-by: David Hildenbrand <dahi@linux.vnet.ibm.com>
---
 include/asm-generic/futex.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/asm-generic/futex.h b/include/asm-generic/futex.h
index 3586017..e56272c 100644
--- a/include/asm-generic/futex.h
+++ b/include/asm-generic/futex.h
@@ -107,6 +107,7 @@ futex_atomic_cmpxchg_inatomic(u32 *uval, u32 __user *uaddr,
 {
 	u32 val;
 
+	preempt_disable();
 	if (unlikely(get_user(val, uaddr) != 0))
 		return -EFAULT;
 
@@ -114,6 +115,7 @@ futex_atomic_cmpxchg_inatomic(u32 *uval, u32 __user *uaddr,
 		return -EFAULT;
 
 	*uval = val;
+	preempt_enable();
 
 	return 0;
 }
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
