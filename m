Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF451C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:07:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 633C6217F4
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:07:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 633C6217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 17EFD6B0007; Tue, 19 Mar 2019 22:07:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12F1F6B0008; Tue, 19 Mar 2019 22:07:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F12976B000A; Tue, 19 Mar 2019 22:07:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id C39B66B0007
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 22:07:11 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id i3so912932qtc.7
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:07:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=BU0FSMjUhzRwc9BHCX7EGJ7teQkDzu6N7AKfPnOzHPU=;
        b=fABx5Lr5E8lm8mVqaYgJJWU+XqaD5ukn39dK12w6dVh2L5M6xsvXkuk4yFF32LF2pT
         qoTi2UK2322Kd8dINOB7YwSP7+KyMmg2Jx/2i5NT3dMarjkG07W2lCnsN6Q4tOMOfaoG
         krqIdhgcN6Dhx+yLw+7vVF45ySAZRplleCjdktMwJY4ajH+JFfvNvsPJNi87TEV+PvUR
         l9/pmuKgEdni0fOoAsuG10UatYdqYxwG2nNz3WmMlNwVJt28RtdFulUCQ97vhYVZcGEI
         ABUOi0x2XYXZ3rieBLB0pVu43Uo7rAkH+xw2eLBETbqGufHLSY9K2u3RcPaxL6RzomMc
         3G7w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXgEsjTiMGbrlXKOCl8Iwv/JiE1WCsXAVVQj/RHveCycmoCVNZH
	4v9aVzM14iGzsv6dICpZWw8DDxWhUU0CpJRvdyI3/ooIe0Pf6gZjbdCn78t2gISW2Ov4R7gH2UL
	HB1//gQN9jGPCfC/IJrQnG9kEcWGT2MKshTfd3pWNBDsXBN1vVdyrnLWTVoKLxwWPeQ==
X-Received: by 2002:aed:3ac9:: with SMTP id o67mr4778793qte.64.1553047631551;
        Tue, 19 Mar 2019 19:07:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyha0yHSgwHScbFnlX5lUTqqrIuEpEDg5DkpdAHjQmyi3DJe92l+QLzgtRBEs6/W6tWxcoB
X-Received: by 2002:aed:3ac9:: with SMTP id o67mr4778739qte.64.1553047630180;
        Tue, 19 Mar 2019 19:07:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553047630; cv=none;
        d=google.com; s=arc-20160816;
        b=QxIuo5BXnN4RBAJcThermfUjXbjD+hhce08+wse0G6j6g+NzUobE8cP575EMeAVljV
         WJkzwxZOWmpl7T3fyCwSDBqcZBlYAl0FXzsVBSSRoQ1IvxpRbJB6Wn95R4J+4vOvodHS
         inXeDd5Hqkort8iL/u6UQzX4SJeb8xgRhpSm89NqP5g0DBGWgH7KhuFW7oSWvQtYzISD
         QgnrzEznrOlfOsn7/ERIG1CfXEGlnrpTCL8RS6ASi8JAHw3yzHfKwuxW6VemehuhGSQK
         qQiRMqH+Dh82jvRYUdP1wCWWsoQu9BM8gN6uthFRQLa+vMAkn8HWZRzte/BngLsntrNK
         IBXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=BU0FSMjUhzRwc9BHCX7EGJ7teQkDzu6N7AKfPnOzHPU=;
        b=EhKQEh1m9dn8u0GpIdNkfYeFKiziRxBOdhejjK1IjDeYDr/yu6Y4WmItXU++VVKUTr
         JJcrAowzWNWK8w/+a5dBn6DhEyj5bRn+Nt9A5IvHCknduBXE347T0C/Xf+FFUtvzmf2p
         5vuO3CAfNf6G6FYgj7eRS6ialnYoq//04YwJEP/j5Izy5jLpYdyuyBlP/KXiHXKmNRW+
         zANqDxKf4Oww64BlkCocYAu4FmIvhGhOb2KlrFf9ycXUgjd9Ju3ukocaXxxzS+BNcItA
         Rhdcxr97DWd9RhJmZllJyS1KppVdBIhaSQLV6Zw8VkHUK0RwKVRsNMPzqcjdWfUUbG7u
         YR+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k31si267380qvh.70.2019.03.19.19.07.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 19:07:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3D0CDC0587F5;
	Wed, 20 Mar 2019 02:07:09 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 952CC6014C;
	Wed, 20 Mar 2019 02:07:01 +0000 (UTC)
From: Peter Xu <peterx@redhat.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Maya Gokhale <gokhale2@llnl.gov>,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	peterx@redhat.com,
	Martin Cracauer <cracauer@cons.org>,
	Shaohua Li <shli@fb.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v3 02/28] mm: userfault: return VM_FAULT_RETRY on signals
Date: Wed, 20 Mar 2019 10:06:16 +0800
Message-Id: <20190320020642.4000-3-peterx@redhat.com>
In-Reply-To: <20190320020642.4000-1-peterx@redhat.com>
References: <20190320020642.4000-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Wed, 20 Mar 2019 02:07:09 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The idea comes from the upstream discussion between Linus and Andrea:

  https://lkml.org/lkml/2017/10/30/560

A summary to the issue: there was a special path in handle_userfault()
in the past that we'll return a VM_FAULT_NOPAGE when we detected
non-fatal signals when waiting for userfault handling.  We did that by
reacquiring the mmap_sem before returning.  However that brings a risk
in that the vmas might have changed when we retake the mmap_sem and
even we could be holding an invalid vma structure.

This patch removes the special path and we'll return a VM_FAULT_RETRY
with the common path even if we have got such signals.  Then for all
the architectures that is passing in VM_FAULT_ALLOW_RETRY into
handle_mm_fault(), we check not only for SIGKILL but for all the rest
of userspace pending signals right after we returned from
handle_mm_fault().  This can allow the userspace to handle nonfatal
signals faster than before.

This patch is a preparation work for the next patch to finally remove
the special code path mentioned above in handle_userfault().

Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: Jerome Glisse <jglisse@redhat.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 arch/alpha/mm/fault.c      |  2 +-
 arch/arc/mm/fault.c        | 11 ++++-------
 arch/arm/mm/fault.c        |  6 +++---
 arch/arm64/mm/fault.c      |  6 +++---
 arch/hexagon/mm/vm_fault.c |  2 +-
 arch/ia64/mm/fault.c       |  2 +-
 arch/m68k/mm/fault.c       |  2 +-
 arch/microblaze/mm/fault.c |  2 +-
 arch/mips/mm/fault.c       |  2 +-
 arch/nds32/mm/fault.c      |  6 +++---
 arch/nios2/mm/fault.c      |  2 +-
 arch/openrisc/mm/fault.c   |  2 +-
 arch/parisc/mm/fault.c     |  2 +-
 arch/powerpc/mm/fault.c    |  2 ++
 arch/riscv/mm/fault.c      |  4 ++--
 arch/s390/mm/fault.c       |  9 ++++++---
 arch/sh/mm/fault.c         |  4 ++++
 arch/sparc/mm/fault_32.c   |  3 +++
 arch/sparc/mm/fault_64.c   |  3 +++
 arch/um/kernel/trap.c      |  5 ++++-
 arch/unicore32/mm/fault.c  |  4 ++--
 arch/x86/mm/fault.c        |  6 +++++-
 arch/xtensa/mm/fault.c     |  3 +++
 23 files changed, 56 insertions(+), 34 deletions(-)

diff --git a/arch/alpha/mm/fault.c b/arch/alpha/mm/fault.c
index 188fc9256baf..8a2ef90b4bfc 100644
--- a/arch/alpha/mm/fault.c
+++ b/arch/alpha/mm/fault.c
@@ -150,7 +150,7 @@ do_page_fault(unsigned long address, unsigned long mmcsr,
 	   the fault.  */
 	fault = handle_mm_fault(vma, address, flags);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && signal_pending(current))
 		return;
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
diff --git a/arch/arc/mm/fault.c b/arch/arc/mm/fault.c
index 8df1638259f3..9e9e6eb1f7d0 100644
--- a/arch/arc/mm/fault.c
+++ b/arch/arc/mm/fault.c
@@ -141,17 +141,14 @@ void do_page_fault(unsigned long address, struct pt_regs *regs)
 	 */
 	fault = handle_mm_fault(vma, address, flags);
 
-	if (fatal_signal_pending(current)) {
-
+	if (unlikely((fault & VM_FAULT_RETRY) && signal_pending(current))) {
+		if (fatal_signal_pending(current) && !user_mode(regs))
+			goto no_context;
 		/*
 		 * if fault retry, mmap_sem already relinquished by core mm
 		 * so OK to return to user mode (with signal handled first)
 		 */
-		if (fault & VM_FAULT_RETRY) {
-			if (!user_mode(regs))
-				goto no_context;
-			return;
-		}
+		return;
 	}
 
 	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, address);
diff --git a/arch/arm/mm/fault.c b/arch/arm/mm/fault.c
index 58f69fa07df9..c41c021bbe40 100644
--- a/arch/arm/mm/fault.c
+++ b/arch/arm/mm/fault.c
@@ -314,12 +314,12 @@ do_page_fault(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 
 	fault = __do_page_fault(mm, addr, fsr, flags, tsk);
 
-	/* If we need to retry but a fatal signal is pending, handle the
+	/* If we need to retry but a signal is pending, handle the
 	 * signal first. We do not need to release the mmap_sem because
 	 * it would already be released in __lock_page_or_retry in
 	 * mm/filemap.c. */
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)) {
-		if (!user_mode(regs))
+	if (unlikely(fault & VM_FAULT_RETRY && signal_pending(current))) {
+		if (fatal_signal_pending(current) && !user_mode(regs))
 			goto no_context;
 		return 0;
 	}
diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
index efb7b2cbead5..a38ff8c49a66 100644
--- a/arch/arm64/mm/fault.c
+++ b/arch/arm64/mm/fault.c
@@ -512,13 +512,13 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
 
 	if (fault & VM_FAULT_RETRY) {
 		/*
-		 * If we need to retry but a fatal signal is pending,
+		 * If we need to retry but a signal is pending,
 		 * handle the signal first. We do not need to release
 		 * the mmap_sem because it would already be released
 		 * in __lock_page_or_retry in mm/filemap.c.
 		 */
-		if (fatal_signal_pending(current)) {
-			if (!user_mode(regs))
+		if (signal_pending(current)) {
+			if (fatal_signal_pending(current) && !user_mode(regs))
 				goto no_context;
 			return 0;
 		}
diff --git a/arch/hexagon/mm/vm_fault.c b/arch/hexagon/mm/vm_fault.c
index eb263e61daf4..be10b441d9cc 100644
--- a/arch/hexagon/mm/vm_fault.c
+++ b/arch/hexagon/mm/vm_fault.c
@@ -104,7 +104,7 @@ void do_page_fault(unsigned long address, long cause, struct pt_regs *regs)
 
 	fault = handle_mm_fault(vma, address, flags);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && signal_pending(current))
 		return;
 
 	/* The most common case -- we are done. */
diff --git a/arch/ia64/mm/fault.c b/arch/ia64/mm/fault.c
index 5baeb022f474..62c2d39d2bed 100644
--- a/arch/ia64/mm/fault.c
+++ b/arch/ia64/mm/fault.c
@@ -163,7 +163,7 @@ ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_regs *re
 	 */
 	fault = handle_mm_fault(vma, address, flags);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && signal_pending(current))
 		return;
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
diff --git a/arch/m68k/mm/fault.c b/arch/m68k/mm/fault.c
index 9b6163c05a75..d9808a807ab8 100644
--- a/arch/m68k/mm/fault.c
+++ b/arch/m68k/mm/fault.c
@@ -138,7 +138,7 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 	fault = handle_mm_fault(vma, address, flags);
 	pr_debug("handle_mm_fault returns %x\n", fault);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && signal_pending(current))
 		return 0;
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
diff --git a/arch/microblaze/mm/fault.c b/arch/microblaze/mm/fault.c
index 202ad6a494f5..4fd2dbd0c5ca 100644
--- a/arch/microblaze/mm/fault.c
+++ b/arch/microblaze/mm/fault.c
@@ -217,7 +217,7 @@ void do_page_fault(struct pt_regs *regs, unsigned long address,
 	 */
 	fault = handle_mm_fault(vma, address, flags);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && signal_pending(current))
 		return;
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
diff --git a/arch/mips/mm/fault.c b/arch/mips/mm/fault.c
index 73d8a0f0b810..92374fd091d2 100644
--- a/arch/mips/mm/fault.c
+++ b/arch/mips/mm/fault.c
@@ -154,7 +154,7 @@ static void __kprobes __do_page_fault(struct pt_regs *regs, unsigned long write,
 	 */
 	fault = handle_mm_fault(vma, address, flags);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && signal_pending(current))
 		return;
 
 	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, address);
diff --git a/arch/nds32/mm/fault.c b/arch/nds32/mm/fault.c
index 68d5f2a27f38..da777de8a62e 100644
--- a/arch/nds32/mm/fault.c
+++ b/arch/nds32/mm/fault.c
@@ -206,12 +206,12 @@ void do_page_fault(unsigned long entry, unsigned long addr,
 	fault = handle_mm_fault(vma, addr, flags);
 
 	/*
-	 * If we need to retry but a fatal signal is pending, handle the
+	 * If we need to retry but a signal is pending, handle the
 	 * signal first. We do not need to release the mmap_sem because it
 	 * would already be released in __lock_page_or_retry in mm/filemap.c.
 	 */
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)) {
-		if (!user_mode(regs))
+	if ((fault & VM_FAULT_RETRY) && signal_pending(current)) {
+		if (fatal_signal_pending(current) && !user_mode(regs))
 			goto no_context;
 		return;
 	}
diff --git a/arch/nios2/mm/fault.c b/arch/nios2/mm/fault.c
index 24fd84cf6006..5939434a31ae 100644
--- a/arch/nios2/mm/fault.c
+++ b/arch/nios2/mm/fault.c
@@ -134,7 +134,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long cause,
 	 */
 	fault = handle_mm_fault(vma, address, flags);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && signal_pending(current))
 		return;
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
diff --git a/arch/openrisc/mm/fault.c b/arch/openrisc/mm/fault.c
index dc4dbafc1d83..873ecb5d82d7 100644
--- a/arch/openrisc/mm/fault.c
+++ b/arch/openrisc/mm/fault.c
@@ -165,7 +165,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long address,
 
 	fault = handle_mm_fault(vma, address, flags);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && signal_pending(current))
 		return;
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
diff --git a/arch/parisc/mm/fault.c b/arch/parisc/mm/fault.c
index c8e8b7c05558..29422eec329d 100644
--- a/arch/parisc/mm/fault.c
+++ b/arch/parisc/mm/fault.c
@@ -303,7 +303,7 @@ void do_page_fault(struct pt_regs *regs, unsigned long code,
 
 	fault = handle_mm_fault(vma, address, flags);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && signal_pending(current))
 		return;
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index 887f11bcf330..aaa853e6592f 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -591,6 +591,8 @@ static int __do_page_fault(struct pt_regs *regs, unsigned long address,
 			 */
 			flags &= ~FAULT_FLAG_ALLOW_RETRY;
 			flags |= FAULT_FLAG_TRIED;
+			if (is_user && signal_pending(current))
+				return 0;
 			if (!fatal_signal_pending(current))
 				goto retry;
 		}
diff --git a/arch/riscv/mm/fault.c b/arch/riscv/mm/fault.c
index 88401d5125bc..4fc8d746bec3 100644
--- a/arch/riscv/mm/fault.c
+++ b/arch/riscv/mm/fault.c
@@ -123,11 +123,11 @@ asmlinkage void do_page_fault(struct pt_regs *regs)
 	fault = handle_mm_fault(vma, addr, flags);
 
 	/*
-	 * If we need to retry but a fatal signal is pending, handle the
+	 * If we need to retry but a signal is pending, handle the
 	 * signal first. We do not need to release the mmap_sem because it
 	 * would already be released in __lock_page_or_retry in mm/filemap.c.
 	 */
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(tsk))
+	if ((fault & VM_FAULT_RETRY) && signal_pending(tsk))
 		return;
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
diff --git a/arch/s390/mm/fault.c b/arch/s390/mm/fault.c
index 11613362c4e7..aba1dad1efcd 100644
--- a/arch/s390/mm/fault.c
+++ b/arch/s390/mm/fault.c
@@ -476,9 +476,12 @@ static inline vm_fault_t do_exception(struct pt_regs *regs, int access)
 	 * the fault.
 	 */
 	fault = handle_mm_fault(vma, address, flags);
-	/* No reason to continue if interrupted by SIGKILL. */
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)) {
-		fault = VM_FAULT_SIGNAL;
+	/* Do not continue if interrupted by signals. */
+	if ((fault & VM_FAULT_RETRY) && signal_pending(current)) {
+		if (fatal_signal_pending(current))
+			fault = VM_FAULT_SIGNAL;
+		else
+			fault = 0;
 		if (flags & FAULT_FLAG_RETRY_NOWAIT)
 			goto out_up;
 		goto out;
diff --git a/arch/sh/mm/fault.c b/arch/sh/mm/fault.c
index 6defd2c6d9b1..baf5d73df40c 100644
--- a/arch/sh/mm/fault.c
+++ b/arch/sh/mm/fault.c
@@ -506,6 +506,10 @@ asmlinkage void __kprobes do_page_fault(struct pt_regs *regs,
 			 * have already released it in __lock_page_or_retry
 			 * in mm/filemap.c.
 			 */
+
+			if (user_mode(regs) && signal_pending(tsk))
+				return;
+
 			goto retry;
 		}
 	}
diff --git a/arch/sparc/mm/fault_32.c b/arch/sparc/mm/fault_32.c
index b0440b0edd97..a2c83104fe35 100644
--- a/arch/sparc/mm/fault_32.c
+++ b/arch/sparc/mm/fault_32.c
@@ -269,6 +269,9 @@ asmlinkage void do_sparc_fault(struct pt_regs *regs, int text_fault, int write,
 			 * in mm/filemap.c.
 			 */
 
+			if (user_mode(regs) && signal_pending(tsk))
+				return;
+
 			goto retry;
 		}
 	}
diff --git a/arch/sparc/mm/fault_64.c b/arch/sparc/mm/fault_64.c
index 8f8a604c1300..cad71ec5c7b3 100644
--- a/arch/sparc/mm/fault_64.c
+++ b/arch/sparc/mm/fault_64.c
@@ -467,6 +467,9 @@ asmlinkage void __kprobes do_sparc64_fault(struct pt_regs *regs)
 			 * in mm/filemap.c.
 			 */
 
+			if (user_mode(regs) && signal_pending(current))
+				return;
+
 			goto retry;
 		}
 	}
diff --git a/arch/um/kernel/trap.c b/arch/um/kernel/trap.c
index 0e8b6158f224..05dcd4c5f0d5 100644
--- a/arch/um/kernel/trap.c
+++ b/arch/um/kernel/trap.c
@@ -76,8 +76,11 @@ int handle_page_fault(unsigned long address, unsigned long ip,
 
 		fault = handle_mm_fault(vma, address, flags);
 
-		if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+		if ((fault & VM_FAULT_RETRY) && signal_pending(current)) {
+			if (is_user && !fatal_signal_pending(current))
+				err = 0;
 			goto out_nosemaphore;
+		}
 
 		if (unlikely(fault & VM_FAULT_ERROR)) {
 			if (fault & VM_FAULT_OOM) {
diff --git a/arch/unicore32/mm/fault.c b/arch/unicore32/mm/fault.c
index b9a3a50644c1..3611f19234a1 100644
--- a/arch/unicore32/mm/fault.c
+++ b/arch/unicore32/mm/fault.c
@@ -248,11 +248,11 @@ static int do_pf(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 
 	fault = __do_pf(mm, addr, fsr, flags, tsk);
 
-	/* If we need to retry but a fatal signal is pending, handle the
+	/* If we need to retry but a signal is pending, handle the
 	 * signal first. We do not need to release the mmap_sem because
 	 * it would already be released in __lock_page_or_retry in
 	 * mm/filemap.c. */
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && signal_pending(current))
 		return 0;
 
 	if (!(fault & VM_FAULT_ERROR) && (flags & FAULT_FLAG_ALLOW_RETRY)) {
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 9d5c75f02295..248ff0a28ecd 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1481,16 +1481,20 @@ void do_user_addr_fault(struct pt_regs *regs,
 	 * that we made any progress. Handle this case first.
 	 */
 	if (unlikely(fault & VM_FAULT_RETRY)) {
+		bool is_user = flags & FAULT_FLAG_USER;
+
 		/* Retry at most once */
 		if (flags & FAULT_FLAG_ALLOW_RETRY) {
 			flags &= ~FAULT_FLAG_ALLOW_RETRY;
 			flags |= FAULT_FLAG_TRIED;
+			if (is_user && signal_pending(tsk))
+				return;
 			if (!fatal_signal_pending(tsk))
 				goto retry;
 		}
 
 		/* User mode? Just return to handle the fatal exception */
-		if (flags & FAULT_FLAG_USER)
+		if (is_user)
 			return;
 
 		/* Not returning to user mode? Handle exceptions or die: */
diff --git a/arch/xtensa/mm/fault.c b/arch/xtensa/mm/fault.c
index 2ab0e0dcd166..792dad5e2f12 100644
--- a/arch/xtensa/mm/fault.c
+++ b/arch/xtensa/mm/fault.c
@@ -136,6 +136,9 @@ void do_page_fault(struct pt_regs *regs)
 			 * in mm/filemap.c.
 			 */
 
+			if (user_mode(regs) && signal_pending(current))
+				return;
+
 			goto retry;
 		}
 	}
-- 
2.17.1

