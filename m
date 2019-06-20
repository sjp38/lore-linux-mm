Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41164C48BE0
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:20:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E27742084A
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:20:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E27742084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 726FC6B0006; Wed, 19 Jun 2019 22:20:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D8428E0002; Wed, 19 Jun 2019 22:20:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5788C8E0001; Wed, 19 Jun 2019 22:20:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 343936B0006
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 22:20:56 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id x17so1712313qkf.14
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 19:20:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=RS/yHOYmyDP2DU15NcuGnajOg/n1TeDVshB1Bs7O87I=;
        b=A/vbuQtcnM2uFlOvRRUIxCzbJ3kefSOoOtH92QITM/NmhC59DX4WDCy7261YJJBqd1
         EIUHgxxbuwQs0OnD9rveekmsRHxn4cKRhWvvU6N+ONX0udEwr+M9OkRnJD2j4X0L0fL1
         GzxDrPWANOtoPiPJ2qEeiKqsVGpkT6tKAeixWbWd+rz0GgN8b6eFxFJgbmb9usOwQcHb
         gxoQtq7gBVzMCTMGGB0nZpIhaNHtkesrBgE428/2z8GjzQV9RFz+B9dFRkzPurAdpV4V
         87kKglKbWxdNmGjoylkANVbM73+J+yRC7RWWz57A3z/VZ6kSA5N09SPzUYtKkUV0fxgy
         FsBg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVW94cef7OSnVDiLXEWphCqvCF7wJUx9KsNRfS+SoER/uUBe55O
	SMzZpvvmV3qMk2uRYmoDATBcCJt4pGwvoEgu1T4l2arIrgPOBC6Oz/wbQzHo/vDuhE54XS514qD
	4g/08WzmW9FMfDzJo1fVx0p2yS6twQrxFWCn0Ia6QQZROM+FghwBnyrz3gAPg2udVuw==
X-Received: by 2002:a0c:889a:: with SMTP id 26mr5797832qvn.20.1560997255889;
        Wed, 19 Jun 2019 19:20:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzpLCyxwzxs61EtHDkPBAcFTyKz2ISnzGzmyvQ1YKIajL30m41ZTOmOKCm8RAYDwB/SxVyD
X-Received: by 2002:a0c:889a:: with SMTP id 26mr5797730qvn.20.1560997254529;
        Wed, 19 Jun 2019 19:20:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560997254; cv=none;
        d=google.com; s=arc-20160816;
        b=ZMkOMG0HkWf0kqKXJ65knVUYhMe6l77qvDZfQgQS9O7D0cQdBP769ITouz3V0nS5r4
         DJ9PhjJLrzXGbMLu0+BXxqKmJFCUDmitlu5L0I30AVQYHvcNfxSu/QsbHI4fSFA8ecUf
         C/YLyd6hJDoljkgggO6oB+zRE00s8sTIIBvboCF5SN0BrpRNvX7kF1PFRmfwTnaQPoKT
         0AkqmSWYG2c/V/C8cVf1yaknWr3h8CmwHf10xYiwhfGjGgdOWoyemDzZiYg27EOSapo5
         NtnByfbc5F2T9uzKfcM4LrdgPnkdjMfxy3r0yohaGy56pUn0KGzhO2fK0XOiN56lxIy1
         76NQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=RS/yHOYmyDP2DU15NcuGnajOg/n1TeDVshB1Bs7O87I=;
        b=nky6IpNG4pd/R+EX7i9LrWkw80yJxotZucb6xf0+/XfAJPLMj6H0jOCMC1mcR6eZZs
         wAvQbc2oP5AZFJV8ta2xOT51jkbLjfnbi73goLDv1i9bLxrXuJAQ6bB0ZHn3pmByoAWh
         ZWbI4edt+2Geurtt31Rneb6qXF+HriHKx6cJdQbrY6YNcDHrC1zGLGkkkLkziNXjCxTj
         L4yjlnSLubsz4xIJCW9W1x1edaXQH2KiYNIR9A/rnVO/R3Q/Wu8F7cHtqNZ/tpefhlgL
         GalEKixF/7qqOb+oYxMnthxZX8MpUpf/FkLmYFNMwNHC0mc2PIHWvsk+mPmMvcn2LAi7
         LwGA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w49si4164143qta.277.2019.06.19.19.20.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 19:20:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E63DFDD9F4;
	Thu, 20 Jun 2019 02:20:52 +0000 (UTC)
Received: from xz-x1.redhat.com (ovpn-12-78.pek2.redhat.com [10.72.12.78])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 509E41001DC3;
	Thu, 20 Jun 2019 02:20:37 +0000 (UTC)
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
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Shaohua Li <shli@fb.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>
Subject: [PATCH v5 02/25] mm: userfault: return VM_FAULT_RETRY on signals
Date: Thu, 20 Jun 2019 10:19:45 +0800
Message-Id: <20190620022008.19172-3-peterx@redhat.com>
In-Reply-To: <20190620022008.19172-1-peterx@redhat.com>
References: <20190620022008.19172-1-peterx@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Thu, 20 Jun 2019 02:20:53 +0000 (UTC)
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
index 6836095251ed..3517820aea07 100644
--- a/arch/arc/mm/fault.c
+++ b/arch/arc/mm/fault.c
@@ -139,17 +139,14 @@ void do_page_fault(unsigned long address, struct pt_regs *regs)
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
index a30818ed9c60..890ec3a693e6 100644
--- a/arch/arm64/mm/fault.c
+++ b/arch/arm64/mm/fault.c
@@ -513,13 +513,13 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
 
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
index b7a99aa5b0ba..febb4f96ba6f 100644
--- a/arch/hexagon/mm/vm_fault.c
+++ b/arch/hexagon/mm/vm_fault.c
@@ -91,7 +91,7 @@ void do_page_fault(unsigned long address, long cause, struct pt_regs *regs)
 
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
index 6a2e716b959f..bdb1f9db75ba 100644
--- a/arch/nios2/mm/fault.c
+++ b/arch/nios2/mm/fault.c
@@ -133,7 +133,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long cause,
 	 */
 	fault = handle_mm_fault(vma, address, flags);
 
-	if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(current))
+	if ((fault & VM_FAULT_RETRY) && signal_pending(current))
 		return;
 
 	if (unlikely(fault & VM_FAULT_ERROR)) {
diff --git a/arch/openrisc/mm/fault.c b/arch/openrisc/mm/fault.c
index 9eee5bf3db27..f9f47dc32f94 100644
--- a/arch/openrisc/mm/fault.c
+++ b/arch/openrisc/mm/fault.c
@@ -161,7 +161,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long address,
 
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
index ec6b7ad70659..c2168b298c82 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -616,6 +616,8 @@ static int __do_page_fault(struct pt_regs *regs, unsigned long address,
 			 */
 			flags &= ~FAULT_FLAG_ALLOW_RETRY;
 			flags |= FAULT_FLAG_TRIED;
+			if (is_user && signal_pending(current))
+				return 0;
 			if (!fatal_signal_pending(current))
 				goto retry;
 		}
diff --git a/arch/riscv/mm/fault.c b/arch/riscv/mm/fault.c
index 3e2708c626a8..4aa7a2343353 100644
--- a/arch/riscv/mm/fault.c
+++ b/arch/riscv/mm/fault.c
@@ -111,11 +111,11 @@ asmlinkage void do_page_fault(struct pt_regs *regs)
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
index df75d574246d..94087ba285be 100644
--- a/arch/s390/mm/fault.c
+++ b/arch/s390/mm/fault.c
@@ -493,9 +493,12 @@ static inline vm_fault_t do_exception(struct pt_regs *regs, int access)
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
index 46df4c6aae46..dcd7c1393be3 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1463,16 +1463,20 @@ void do_user_addr_fault(struct pt_regs *regs,
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
2.21.0

