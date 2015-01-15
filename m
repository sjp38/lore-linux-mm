Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id D39A46B0073
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 03:58:26 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id n3so16216335wiv.1
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 00:58:26 -0800 (PST)
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com. [195.75.94.110])
        by mx.google.com with ESMTPS id bo6si1533760wjc.97.2015.01.15.00.58.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 15 Jan 2015 00:58:17 -0800 (PST)
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Thu, 15 Jan 2015 08:58:16 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 936FD17D805D
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 08:58:52 +0000 (GMT)
Received: from d06av08.portsmouth.uk.ibm.com (d06av08.portsmouth.uk.ibm.com [9.149.37.249])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t0F8wDrn42336450
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 08:58:13 GMT
Received: from d06av08.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av08.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t0F8wD2L016735
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 01:58:13 -0700
From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: [PATCH 4/8] x86/spinlock: Leftover conversion ACCESS_ONCE->READ_ONCE
Date: Thu, 15 Jan 2015 09:58:30 +0100
Message-Id: <1421312314-72330-5-git-send-email-borntraeger@de.ibm.com>
In-Reply-To: <1421312314-72330-1-git-send-email-borntraeger@de.ibm.com>
References: <1421312314-72330-1-git-send-email-borntraeger@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-arch@vger.kernel.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, xen-devel@lists.xenproject.org, linux-mm@kvack.org, Christian Borntraeger <borntraeger@de.ibm.com>, Oleg Nesterov <oleg@redhat.com>

commit 78bff1c8684f ("x86/ticketlock: Fix spin_unlock_wait() livelock")
introduced another ACCESS_ONCE case in x86 spinlock.h.

Change that as well.

Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Oleg Nesterov <oleg@redhat.com>
---
 arch/x86/include/asm/spinlock.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/spinlock.h b/arch/x86/include/asm/spinlock.h
index 625660f..9264f0f 100644
--- a/arch/x86/include/asm/spinlock.h
+++ b/arch/x86/include/asm/spinlock.h
@@ -186,7 +186,7 @@ static inline void arch_spin_unlock_wait(arch_spinlock_t *lock)
 	__ticket_t head = ACCESS_ONCE(lock->tickets.head);
 
 	for (;;) {
-		struct __raw_tickets tmp = ACCESS_ONCE(lock->tickets);
+		struct __raw_tickets tmp = READ_ONCE(lock->tickets);
 		/*
 		 * We need to check "unlocked" in a loop, tmp.head == head
 		 * can be false positive because of overflow.
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
