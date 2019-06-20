Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B69AC48BE0
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:21:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 05BDA2084A
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:21:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 05BDA2084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D34F6B0008; Wed, 19 Jun 2019 22:21:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 886398E0002; Wed, 19 Jun 2019 22:21:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 74E268E0001; Wed, 19 Jun 2019 22:21:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 511AC6B0008
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 22:21:20 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id s25so1694250qkj.18
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 19:21:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=qSXj0wJMv5utUSmbkTfP2quxBqGfypnNHDKzmRsioFc=;
        b=bvRyjwHN8F3zJurVtqVgfeBVEIrAUyJ8wIOEhyNXVsBnODI7HXtztAvfy5mcO+MO/b
         letH2Z7npcWtYdTnfYTMvdO0++ZFopvmFBUSrnXK23voXK7OFou9CnmlmMSEHEoa+ZE0
         ltKGbhsmYRVD7UJ5N7H1MYXV05LFdLuCdSt4WedXmQhsctXusTM42ptLGmfvrhBvjSO5
         b/dIV6sLYz4iPXpA87XgVkMFSx3sBAJRICRwjqcQfYik8/pkG9KN++CH1YRnHRsFunju
         HkFpsXmuzi6BWIWrsBirbx9v7r6CnPJvo6EkrwewM+b5MA0zsutr1bh9yrJ7i2pRPbMg
         y5aA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWEx2ic5z8pgVMXYBP+/MRbtdvw6k5uNgUZbFJoC/C2OajAdefS
	aT/uWRxdIwHe4vLAZNTyZUJM4nD3+iVLVHTCzoZSDPIJ+C8xGKhPQaf3WfM+6Nmm51JjP1eBurW
	l/ZFy/2FbIXbr/bl0+kCUYINImCPFwn2VNr72k4yXtS8BHeiWEoiQfzJT9GxcZVyZHw==
X-Received: by 2002:ac8:6b06:: with SMTP id w6mr26169507qts.80.1560997280038;
        Wed, 19 Jun 2019 19:21:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyptUacbFf4a49YNgBjH0O7IfSkBL8fONo9OtgBfhh/OQe4jpX3KB5Kd701DnS5Fk5qykkP
X-Received: by 2002:ac8:6b06:: with SMTP id w6mr26169409qts.80.1560997278207;
        Wed, 19 Jun 2019 19:21:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560997278; cv=none;
        d=google.com; s=arc-20160816;
        b=PSafZAjVaCovX8Z1VqkIxcoiDVoHURIj69mf8C7B5sbqXXlwK0wTVayUlJPszTDYkL
         1Ly3i6UnrJ48mtmkPhCj9mWI9wEpN2dtRCgeB3nNLMjtF/MUIQUiq+jS1ynquB5qQChz
         +YDlzuvH1Zf6CujdMNFkn0QaLJaNB0xA0yH4q0ArfLlahwuJXgOAFjpZkHQDs4RwNR1Z
         FkXiAMxEHvfHUX3RAiUmZWUCmobHKNQZb85Wl45I+o7hAERwW8k8ta4fA57kVOWfa394
         P1FMdFW8E2kACxf+IHDnXfF0GEwkQDJ59frjhZZMRcoPeKHnrkGnQI4Qq45xqfW6PWHo
         3VGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=qSXj0wJMv5utUSmbkTfP2quxBqGfypnNHDKzmRsioFc=;
        b=L+plSOZNethYElvLJHlbwPtQS4WlZ2ppMgaistWRu0seRERxzfQcClfxi11xQDLgDu
         zoDVZLyn600q9URpO+1bXv3Dbj8u4sTD5cZAHOV3idfqGSqY9K3EUVejm86k7DkCnwAZ
         2PQLjkD2drwJbSprM4t/8gd0yW+AJIqVLyX/tt+DjvSWs0VUQ710YDYlvoMH9xGK13PN
         jPcVWlVVjAkikOXzhBxFN1AdypF5Lx/3zlicnCCMndLOw66THBl7TFlIkaJM94aKiwRY
         zx+i8M6lcNTJsXWBY1Fb7UpqBcIxpIIG+uWyb8OyjUOKbu/yhujLBk7mw4B9UO+8/Vai
         F6Rg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a55si3992722qtk.80.2019.06.19.19.21.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 19:21:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 44B5D307D910;
	Thu, 20 Jun 2019 02:21:17 +0000 (UTC)
Received: from xz-x1.redhat.com (ovpn-12-78.pek2.redhat.com [10.72.12.78])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 90D531001E69;
	Thu, 20 Jun 2019 02:21:04 +0000 (UTC)
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
Subject: [PATCH v5 04/25] mm: allow VM_FAULT_RETRY for multiple times
Date: Thu, 20 Jun 2019 10:19:47 +0800
Message-Id: <20190620022008.19172-5-peterx@redhat.com>
In-Reply-To: <20190620022008.19172-1-peterx@redhat.com>
References: <20190620022008.19172-1-peterx@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Thu, 20 Jun 2019 02:21:17 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The idea comes from a discussion between Linus and Andrea [1].

Before this patch we only allow a page fault to retry once.  We
achieved this by clearing the FAULT_FLAG_ALLOW_RETRY flag when doing
handle_mm_fault() the second time.  This was majorly used to avoid
unexpected starvation of the system by looping over forever to handle
the page fault on a single page.  However that should hardly happen,
and after all for each code path to return a VM_FAULT_RETRY we'll
first wait for a condition (during which time we should possibly yield
the cpu) to happen before VM_FAULT_RETRY is really returned.

This patch removes the restriction by keeping the
FAULT_FLAG_ALLOW_RETRY flag when we receive VM_FAULT_RETRY.  It means
that the page fault handler now can retry the page fault for multiple
times if necessary without the need to generate another page fault
event.  Meanwhile we still keep the FAULT_FLAG_TRIED flag so page
fault handler can still identify whether a page fault is the first
attempt or not.

Then we'll have these combinations of fault flags (only considering
ALLOW_RETRY flag and TRIED flag):

  - ALLOW_RETRY and !TRIED:  this means the page fault allows to
                             retry, and this is the first try

  - ALLOW_RETRY and TRIED:   this means the page fault allows to
                             retry, and this is not the first try

  - !ALLOW_RETRY and !TRIED: this means the page fault does not allow
                             to retry at all

  - !ALLOW_RETRY and TRIED:  this is forbidden and should never be used

In existing code we have multiple places that has taken special care
of the first condition above by checking against (fault_flags &
FAULT_FLAG_ALLOW_RETRY).  This patch introduces a simple helper to
detect the first retry of a page fault by checking against
both (fault_flags & FAULT_FLAG_ALLOW_RETRY) and !(fault_flag &
FAULT_FLAG_TRIED) because now even the 2nd try will have the
ALLOW_RETRY set, then use that helper in all existing special paths.
One example is in __lock_page_or_retry(), now we'll drop the mmap_sem
only in the first attempt of page fault and we'll keep it in follow up
retries, so old locking behavior will be retained.

This will be a nice enhancement for current code [2] at the same time
a supporting material for the future userfaultfd-writeprotect work,
since in that work there will always be an explicit userfault
writeprotect retry for protected pages, and if that cannot resolve the
page fault (e.g., when userfaultfd-writeprotect is used in conjunction
with swapped pages) then we'll possibly need a 3rd retry of the page
fault.  It might also benefit other potential users who will have
similar requirement like userfault write-protection.

GUP code is not touched yet and will be covered in follow up patch.

Please read the thread below for more information.

[1] https://lkml.org/lkml/2017/11/2/833
[2] https://lkml.org/lkml/2018/12/30/64

Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: Jerome Glisse <jglisse@redhat.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 arch/alpha/mm/fault.c           |  2 +-
 arch/arc/mm/fault.c             |  1 -
 arch/arm/mm/fault.c             |  3 ---
 arch/arm64/mm/fault.c           |  5 ----
 arch/hexagon/mm/vm_fault.c      |  1 -
 arch/ia64/mm/fault.c            |  1 -
 arch/m68k/mm/fault.c            |  3 ---
 arch/microblaze/mm/fault.c      |  1 -
 arch/mips/mm/fault.c            |  1 -
 arch/nds32/mm/fault.c           |  1 -
 arch/nios2/mm/fault.c           |  3 ---
 arch/openrisc/mm/fault.c        |  1 -
 arch/parisc/mm/fault.c          |  4 +---
 arch/powerpc/mm/fault.c         |  6 -----
 arch/riscv/mm/fault.c           |  5 ----
 arch/s390/mm/fault.c            |  5 +---
 arch/sh/mm/fault.c              |  1 -
 arch/sparc/mm/fault_32.c        |  1 -
 arch/sparc/mm/fault_64.c        |  1 -
 arch/um/kernel/trap.c           |  1 -
 arch/unicore32/mm/fault.c       |  4 +---
 arch/x86/mm/fault.c             |  2 --
 arch/xtensa/mm/fault.c          |  1 -
 drivers/gpu/drm/ttm/ttm_bo_vm.c | 12 +++++++---
 include/linux/mm.h              | 41 ++++++++++++++++++++++++++++++++-
 mm/filemap.c                    |  2 +-
 mm/shmem.c                      |  2 +-
 27 files changed, 55 insertions(+), 56 deletions(-)

diff --git a/arch/alpha/mm/fault.c b/arch/alpha/mm/fault.c
index 8a2ef90b4bfc..6a02c0fb36b9 100644
--- a/arch/alpha/mm/fault.c
+++ b/arch/alpha/mm/fault.c
@@ -169,7 +169,7 @@ do_page_fault(unsigned long address, unsigned long mmcsr,
 		else
 			current->min_flt++;
 		if (fault & VM_FAULT_RETRY) {
-			flags &= ~FAULT_FLAG_ALLOW_RETRY;
+			flags |= FAULT_FLAG_TRIED;
 
 			 /* No need to up_read(&mm->mmap_sem) as we would
 			 * have already released it in __lock_page_or_retry
diff --git a/arch/arc/mm/fault.c b/arch/arc/mm/fault.c
index 3517820aea07..144d25b2e044 100644
--- a/arch/arc/mm/fault.c
+++ b/arch/arc/mm/fault.c
@@ -165,7 +165,6 @@ void do_page_fault(unsigned long address, struct pt_regs *regs)
 			}
 
 			if (fault & VM_FAULT_RETRY) {
-				flags &= ~FAULT_FLAG_ALLOW_RETRY;
 				flags |= FAULT_FLAG_TRIED;
 				goto retry;
 			}
diff --git a/arch/arm/mm/fault.c b/arch/arm/mm/fault.c
index c41c021bbe40..7910b4b5205d 100644
--- a/arch/arm/mm/fault.c
+++ b/arch/arm/mm/fault.c
@@ -342,9 +342,6 @@ do_page_fault(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 					regs, addr);
 		}
 		if (fault & VM_FAULT_RETRY) {
-			/* Clear FAULT_FLAG_ALLOW_RETRY to avoid any risk
-			* of starvation. */
-			flags &= ~FAULT_FLAG_ALLOW_RETRY;
 			flags |= FAULT_FLAG_TRIED;
 			goto retry;
 		}
diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
index 890ec3a693e6..c36da19d9098 100644
--- a/arch/arm64/mm/fault.c
+++ b/arch/arm64/mm/fault.c
@@ -524,12 +524,7 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
 			return 0;
 		}
 
-		/*
-		 * Clear FAULT_FLAG_ALLOW_RETRY to avoid any risk of
-		 * starvation.
-		 */
 		if (mm_flags & FAULT_FLAG_ALLOW_RETRY) {
-			mm_flags &= ~FAULT_FLAG_ALLOW_RETRY;
 			mm_flags |= FAULT_FLAG_TRIED;
 			goto retry;
 		}
diff --git a/arch/hexagon/mm/vm_fault.c b/arch/hexagon/mm/vm_fault.c
index febb4f96ba6f..21b6e9d8f2a1 100644
--- a/arch/hexagon/mm/vm_fault.c
+++ b/arch/hexagon/mm/vm_fault.c
@@ -102,7 +102,6 @@ void do_page_fault(unsigned long address, long cause, struct pt_regs *regs)
 			else
 				current->min_flt++;
 			if (fault & VM_FAULT_RETRY) {
-				flags &= ~FAULT_FLAG_ALLOW_RETRY;
 				flags |= FAULT_FLAG_TRIED;
 				goto retry;
 			}
diff --git a/arch/ia64/mm/fault.c b/arch/ia64/mm/fault.c
index 62c2d39d2bed..9de95d39935e 100644
--- a/arch/ia64/mm/fault.c
+++ b/arch/ia64/mm/fault.c
@@ -189,7 +189,6 @@ ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_regs *re
 		else
 			current->min_flt++;
 		if (fault & VM_FAULT_RETRY) {
-			flags &= ~FAULT_FLAG_ALLOW_RETRY;
 			flags |= FAULT_FLAG_TRIED;
 
 			 /* No need to up_read(&mm->mmap_sem) as we would
diff --git a/arch/m68k/mm/fault.c b/arch/m68k/mm/fault.c
index d9808a807ab8..b1b2109e4ab4 100644
--- a/arch/m68k/mm/fault.c
+++ b/arch/m68k/mm/fault.c
@@ -162,9 +162,6 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 		else
 			current->min_flt++;
 		if (fault & VM_FAULT_RETRY) {
-			/* Clear FAULT_FLAG_ALLOW_RETRY to avoid any risk
-			 * of starvation. */
-			flags &= ~FAULT_FLAG_ALLOW_RETRY;
 			flags |= FAULT_FLAG_TRIED;
 
 			/*
diff --git a/arch/microblaze/mm/fault.c b/arch/microblaze/mm/fault.c
index 4fd2dbd0c5ca..05a4847ac0bf 100644
--- a/arch/microblaze/mm/fault.c
+++ b/arch/microblaze/mm/fault.c
@@ -236,7 +236,6 @@ void do_page_fault(struct pt_regs *regs, unsigned long address,
 		else
 			current->min_flt++;
 		if (fault & VM_FAULT_RETRY) {
-			flags &= ~FAULT_FLAG_ALLOW_RETRY;
 			flags |= FAULT_FLAG_TRIED;
 
 			/*
diff --git a/arch/mips/mm/fault.c b/arch/mips/mm/fault.c
index 92374fd091d2..9953b5b571df 100644
--- a/arch/mips/mm/fault.c
+++ b/arch/mips/mm/fault.c
@@ -178,7 +178,6 @@ static void __kprobes __do_page_fault(struct pt_regs *regs, unsigned long write,
 			tsk->min_flt++;
 		}
 		if (fault & VM_FAULT_RETRY) {
-			flags &= ~FAULT_FLAG_ALLOW_RETRY;
 			flags |= FAULT_FLAG_TRIED;
 
 			/*
diff --git a/arch/nds32/mm/fault.c b/arch/nds32/mm/fault.c
index da777de8a62e..3642bdd7909d 100644
--- a/arch/nds32/mm/fault.c
+++ b/arch/nds32/mm/fault.c
@@ -242,7 +242,6 @@ void do_page_fault(unsigned long entry, unsigned long addr,
 				      1, regs, addr);
 		}
 		if (fault & VM_FAULT_RETRY) {
-			flags &= ~FAULT_FLAG_ALLOW_RETRY;
 			flags |= FAULT_FLAG_TRIED;
 
 			/* No need to up_read(&mm->mmap_sem) as we would
diff --git a/arch/nios2/mm/fault.c b/arch/nios2/mm/fault.c
index bdb1f9db75ba..9d4961d51db4 100644
--- a/arch/nios2/mm/fault.c
+++ b/arch/nios2/mm/fault.c
@@ -157,9 +157,6 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long cause,
 		else
 			current->min_flt++;
 		if (fault & VM_FAULT_RETRY) {
-			/* Clear FAULT_FLAG_ALLOW_RETRY to avoid any risk
-			 * of starvation. */
-			flags &= ~FAULT_FLAG_ALLOW_RETRY;
 			flags |= FAULT_FLAG_TRIED;
 
 			/*
diff --git a/arch/openrisc/mm/fault.c b/arch/openrisc/mm/fault.c
index f9f47dc32f94..05c754664fcb 100644
--- a/arch/openrisc/mm/fault.c
+++ b/arch/openrisc/mm/fault.c
@@ -181,7 +181,6 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long address,
 		else
 			tsk->min_flt++;
 		if (fault & VM_FAULT_RETRY) {
-			flags &= ~FAULT_FLAG_ALLOW_RETRY;
 			flags |= FAULT_FLAG_TRIED;
 
 			 /* No need to up_read(&mm->mmap_sem) as we would
diff --git a/arch/parisc/mm/fault.c b/arch/parisc/mm/fault.c
index 29422eec329d..675b221af198 100644
--- a/arch/parisc/mm/fault.c
+++ b/arch/parisc/mm/fault.c
@@ -327,14 +327,12 @@ void do_page_fault(struct pt_regs *regs, unsigned long code,
 		else
 			current->min_flt++;
 		if (fault & VM_FAULT_RETRY) {
-			flags &= ~FAULT_FLAG_ALLOW_RETRY;
-
 			/*
 			 * No need to up_read(&mm->mmap_sem) as we would
 			 * have already released it in __lock_page_or_retry
 			 * in mm/filemap.c.
 			 */
-
+			flags |= FAULT_FLAG_TRIED;
 			goto retry;
 		}
 	}
diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index c2168b298c82..63564afb24ed 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -608,13 +608,7 @@ static int __do_page_fault(struct pt_regs *regs, unsigned long address,
 	 * case.
 	 */
 	if (unlikely(fault & VM_FAULT_RETRY)) {
-		/* We retry only once */
 		if (flags & FAULT_FLAG_ALLOW_RETRY) {
-			/*
-			 * Clear FAULT_FLAG_ALLOW_RETRY to avoid any risk
-			 * of starvation.
-			 */
-			flags &= ~FAULT_FLAG_ALLOW_RETRY;
 			flags |= FAULT_FLAG_TRIED;
 			if (is_user && signal_pending(current))
 				return 0;
diff --git a/arch/riscv/mm/fault.c b/arch/riscv/mm/fault.c
index 4aa7a2343353..cc76c8766951 100644
--- a/arch/riscv/mm/fault.c
+++ b/arch/riscv/mm/fault.c
@@ -142,11 +142,6 @@ asmlinkage void do_page_fault(struct pt_regs *regs)
 				      1, regs, addr);
 		}
 		if (fault & VM_FAULT_RETRY) {
-			/*
-			 * Clear FAULT_FLAG_ALLOW_RETRY to avoid any risk
-			 * of starvation.
-			 */
-			flags &= ~(FAULT_FLAG_ALLOW_RETRY);
 			flags |= FAULT_FLAG_TRIED;
 
 			/*
diff --git a/arch/s390/mm/fault.c b/arch/s390/mm/fault.c
index 94087ba285be..e460043776f3 100644
--- a/arch/s390/mm/fault.c
+++ b/arch/s390/mm/fault.c
@@ -530,10 +530,7 @@ static inline vm_fault_t do_exception(struct pt_regs *regs, int access)
 				fault = VM_FAULT_PFAULT;
 				goto out_up;
 			}
-			/* Clear FAULT_FLAG_ALLOW_RETRY to avoid any risk
-			 * of starvation. */
-			flags &= ~(FAULT_FLAG_ALLOW_RETRY |
-				   FAULT_FLAG_RETRY_NOWAIT);
+			flags &= ~FAULT_FLAG_RETRY_NOWAIT;
 			flags |= FAULT_FLAG_TRIED;
 			down_read(&mm->mmap_sem);
 			goto retry;
diff --git a/arch/sh/mm/fault.c b/arch/sh/mm/fault.c
index baf5d73df40c..cd710e2d7c57 100644
--- a/arch/sh/mm/fault.c
+++ b/arch/sh/mm/fault.c
@@ -498,7 +498,6 @@ asmlinkage void __kprobes do_page_fault(struct pt_regs *regs,
 				      regs, address);
 		}
 		if (fault & VM_FAULT_RETRY) {
-			flags &= ~FAULT_FLAG_ALLOW_RETRY;
 			flags |= FAULT_FLAG_TRIED;
 
 			/*
diff --git a/arch/sparc/mm/fault_32.c b/arch/sparc/mm/fault_32.c
index a2c83104fe35..6735cd1c09b9 100644
--- a/arch/sparc/mm/fault_32.c
+++ b/arch/sparc/mm/fault_32.c
@@ -261,7 +261,6 @@ asmlinkage void do_sparc_fault(struct pt_regs *regs, int text_fault, int write,
 				      1, regs, address);
 		}
 		if (fault & VM_FAULT_RETRY) {
-			flags &= ~FAULT_FLAG_ALLOW_RETRY;
 			flags |= FAULT_FLAG_TRIED;
 
 			/* No need to up_read(&mm->mmap_sem) as we would
diff --git a/arch/sparc/mm/fault_64.c b/arch/sparc/mm/fault_64.c
index cad71ec5c7b3..28d5b4d012c6 100644
--- a/arch/sparc/mm/fault_64.c
+++ b/arch/sparc/mm/fault_64.c
@@ -459,7 +459,6 @@ asmlinkage void __kprobes do_sparc64_fault(struct pt_regs *regs)
 				      1, regs, address);
 		}
 		if (fault & VM_FAULT_RETRY) {
-			flags &= ~FAULT_FLAG_ALLOW_RETRY;
 			flags |= FAULT_FLAG_TRIED;
 
 			/* No need to up_read(&mm->mmap_sem) as we would
diff --git a/arch/um/kernel/trap.c b/arch/um/kernel/trap.c
index 05dcd4c5f0d5..e7723c133c7f 100644
--- a/arch/um/kernel/trap.c
+++ b/arch/um/kernel/trap.c
@@ -99,7 +99,6 @@ int handle_page_fault(unsigned long address, unsigned long ip,
 			else
 				current->min_flt++;
 			if (fault & VM_FAULT_RETRY) {
-				flags &= ~FAULT_FLAG_ALLOW_RETRY;
 				flags |= FAULT_FLAG_TRIED;
 
 				goto retry;
diff --git a/arch/unicore32/mm/fault.c b/arch/unicore32/mm/fault.c
index 3611f19234a1..efca122b5ef7 100644
--- a/arch/unicore32/mm/fault.c
+++ b/arch/unicore32/mm/fault.c
@@ -261,9 +261,7 @@ static int do_pf(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 		else
 			tsk->min_flt++;
 		if (fault & VM_FAULT_RETRY) {
-			/* Clear FAULT_FLAG_ALLOW_RETRY to avoid any risk
-			* of starvation. */
-			flags &= ~FAULT_FLAG_ALLOW_RETRY;
+			flags |= FAULT_FLAG_TRIED;
 			goto retry;
 		}
 	}
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index dcd7c1393be3..8d3fbd3dca75 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1465,9 +1465,7 @@ void do_user_addr_fault(struct pt_regs *regs,
 	if (unlikely(fault & VM_FAULT_RETRY)) {
 		bool is_user = flags & FAULT_FLAG_USER;
 
-		/* Retry at most once */
 		if (flags & FAULT_FLAG_ALLOW_RETRY) {
-			flags &= ~FAULT_FLAG_ALLOW_RETRY;
 			flags |= FAULT_FLAG_TRIED;
 			if (is_user && signal_pending(tsk))
 				return;
diff --git a/arch/xtensa/mm/fault.c b/arch/xtensa/mm/fault.c
index 792dad5e2f12..7cd55f2d66c9 100644
--- a/arch/xtensa/mm/fault.c
+++ b/arch/xtensa/mm/fault.c
@@ -128,7 +128,6 @@ void do_page_fault(struct pt_regs *regs)
 		else
 			current->min_flt++;
 		if (fault & VM_FAULT_RETRY) {
-			flags &= ~FAULT_FLAG_ALLOW_RETRY;
 			flags |= FAULT_FLAG_TRIED;
 
 			 /* No need to up_read(&mm->mmap_sem) as we would
diff --git a/drivers/gpu/drm/ttm/ttm_bo_vm.c b/drivers/gpu/drm/ttm/ttm_bo_vm.c
index 6dacff49c1cc..8f2f9ee6effa 100644
--- a/drivers/gpu/drm/ttm/ttm_bo_vm.c
+++ b/drivers/gpu/drm/ttm/ttm_bo_vm.c
@@ -61,9 +61,10 @@ static vm_fault_t ttm_bo_vm_fault_idle(struct ttm_buffer_object *bo,
 
 	/*
 	 * If possible, avoid waiting for GPU with mmap_sem
-	 * held.
+	 * held.  We only do this if the fault allows retry and this
+	 * is the first attempt.
 	 */
-	if (vmf->flags & FAULT_FLAG_ALLOW_RETRY) {
+	if (fault_flag_allow_retry_first(vmf->flags)) {
 		ret = VM_FAULT_RETRY;
 		if (vmf->flags & FAULT_FLAG_RETRY_NOWAIT)
 			goto out_unlock;
@@ -132,7 +133,12 @@ static vm_fault_t ttm_bo_vm_fault(struct vm_fault *vmf)
 	 * for the buffer to become unreserved.
 	 */
 	if (unlikely(!reservation_object_trylock(bo->resv))) {
-		if (vmf->flags & FAULT_FLAG_ALLOW_RETRY) {
+		/*
+		 * If the fault allows retry and this is the first
+		 * fault attempt, we try to release the mmap_sem
+		 * before waiting
+		 */
+		if (fault_flag_allow_retry_first(vmf->flags)) {
 			if (!(vmf->flags & FAULT_FLAG_RETRY_NOWAIT)) {
 				ttm_bo_get(bo);
 				up_read(&vmf->vma->vm_mm->mmap_sem);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index dd0b5f4e1e45..dcaca899e4a8 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -383,16 +383,55 @@ extern unsigned int kobjsize(const void *objp);
  */
 extern pgprot_t protection_map[16];
 
+/*
+ * About FAULT_FLAG_ALLOW_RETRY and FAULT_FLAG_TRIED: we can specify whether we
+ * would allow page faults to retry by specifying these two fault flags
+ * correctly.  Currently there can be three legal combinations:
+ *
+ * (a) ALLOW_RETRY and !TRIED:  this means the page fault allows retry, and
+ *                              this is the first try
+ *
+ * (b) ALLOW_RETRY and TRIED:   this means the page fault allows retry, and
+ *                              we've already tried at least once
+ *
+ * (c) !ALLOW_RETRY and !TRIED: this means the page fault does not allow retry
+ *
+ * The unlisted combination (!ALLOW_RETRY && TRIED) is illegal and should never
+ * be used.  Note that page faults can be allowed to retry for multiple times,
+ * in which case we'll have an initial fault with flags (a) then later on
+ * continuous faults with flags (b).  We should always try to detect pending
+ * signals before a retry to make sure the continuous page faults can still be
+ * interrupted if necessary.
+ */
+
 #define FAULT_FLAG_WRITE	0x01	/* Fault was a write access */
 #define FAULT_FLAG_MKWRITE	0x02	/* Fault was mkwrite of existing pte */
 #define FAULT_FLAG_ALLOW_RETRY	0x04	/* Retry fault if blocking */
 #define FAULT_FLAG_RETRY_NOWAIT	0x08	/* Don't drop mmap_sem and wait when retrying */
 #define FAULT_FLAG_KILLABLE	0x10	/* The fault task is in SIGKILL killable region */
-#define FAULT_FLAG_TRIED	0x20	/* Second try */
+#define FAULT_FLAG_TRIED	0x20	/* We've tried once */
 #define FAULT_FLAG_USER		0x40	/* The fault originated in userspace */
 #define FAULT_FLAG_REMOTE	0x80	/* faulting for non current tsk/mm */
 #define FAULT_FLAG_INSTRUCTION  0x100	/* The fault was during an instruction fetch */
 
+/**
+ * fault_flag_allow_retry_first - check ALLOW_RETRY the first time
+ *
+ * This is mostly used for places where we want to try to avoid taking
+ * the mmap_sem for too long a time when waiting for another condition
+ * to change, in which case we can try to be polite to release the
+ * mmap_sem in the first round to avoid potential starvation of other
+ * processes that would also want the mmap_sem.
+ *
+ * Return: true if the page fault allows retry and this is the first
+ * attempt of the fault handling; false otherwise.
+ */
+static inline bool fault_flag_allow_retry_first(unsigned int flags)
+{
+	return (flags & FAULT_FLAG_ALLOW_RETRY) &&
+	    (!(flags & FAULT_FLAG_TRIED));
+}
+
 #define FAULT_FLAG_TRACE \
 	{ FAULT_FLAG_WRITE,		"WRITE" }, \
 	{ FAULT_FLAG_MKWRITE,		"MKWRITE" }, \
diff --git a/mm/filemap.c b/mm/filemap.c
index df2006ba0cfa..83fdf429f795 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1381,7 +1381,7 @@ EXPORT_SYMBOL_GPL(__lock_page_killable);
 int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
 			 unsigned int flags)
 {
-	if (flags & FAULT_FLAG_ALLOW_RETRY) {
+	if (fault_flag_allow_retry_first(flags)) {
 		/*
 		 * CAUTION! In this case, mmap_sem is not released
 		 * even though return 0.
diff --git a/mm/shmem.c b/mm/shmem.c
index 1bb3b8dc8bb2..ef3a19c83927 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2009,7 +2009,7 @@ static vm_fault_t shmem_fault(struct vm_fault *vmf)
 			DEFINE_WAIT_FUNC(shmem_fault_wait, synchronous_wake_function);
 
 			ret = VM_FAULT_NOPAGE;
-			if ((vmf->flags & FAULT_FLAG_ALLOW_RETRY) &&
+			if (fault_flag_allow_retry_first(vmf->flags) &&
 			   !(vmf->flags & FAULT_FLAG_RETRY_NOWAIT)) {
 				/* It's polite to up mmap_sem if we can */
 				up_read(&vma->vm_mm->mmap_sem);
-- 
2.21.0

