Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0FBA06B0096
	for <linux-mm@kvack.org>; Sat, 14 Nov 2009 13:10:25 -0500 (EST)
Received: from int-mx08.intmail.prod.int.phx2.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.21])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id nAEIAOS4009646
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Sat, 14 Nov 2009 13:10:24 -0500
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 01 of 25] bit_lock smp memory barriers
Message-Id: <8472e1d6f1da8b01874c.1258220299@v2.random>
In-Reply-To: <patchbomb.1258220298@v2.random>
References: <patchbomb.1258220298@v2.random>
Date: Sat, 14 Nov 2009 17:38:19 -0000
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Fix bit spinlock to issue the proper memory barries like regular spinlocks.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/include/linux/bit_spinlock.h b/include/linux/bit_spinlock.h
--- a/include/linux/bit_spinlock.h
+++ b/include/linux/bit_spinlock.h
@@ -26,6 +26,7 @@ static inline void bit_spin_lock(int bit
 		}
 	}
 #endif
+	smp_mb();
 	__acquire(bitlock);
 }
 
@@ -41,6 +42,7 @@ static inline int bit_spin_trylock(int b
 		return 0;
 	}
 #endif
+	smp_mb();
 	__acquire(bitlock);
 	return 1;
 }
@@ -50,6 +52,7 @@ static inline int bit_spin_trylock(int b
  */
 static inline void bit_spin_unlock(int bitnum, unsigned long *addr)
 {
+	smp_mb();
 #ifdef CONFIG_DEBUG_SPINLOCK
 	BUG_ON(!test_bit(bitnum, addr));
 #endif
@@ -67,6 +70,7 @@ static inline void bit_spin_unlock(int b
  */
 static inline void __bit_spin_unlock(int bitnum, unsigned long *addr)
 {
+	smp_mb();
 #ifdef CONFIG_DEBUG_SPINLOCK
 	BUG_ON(!test_bit(bitnum, addr));
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
