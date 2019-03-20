Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12F7AC10F03
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:07:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A8D72217F4
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:07:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8D72217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5024C6B000A; Tue, 19 Mar 2019 22:07:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4B2BB6B000C; Tue, 19 Mar 2019 22:07:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 379E26B000D; Tue, 19 Mar 2019 22:07:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 106BF6B000A
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 22:07:27 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id n10so910824qtk.9
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:07:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=pXV/owCkhk/Ku3ko/t4dekZX/ZdfSDa6VsorYWBWRPI=;
        b=o1jtjlQatEmR7ua77/cMr82GP0ZwCs0GNeXm1S2d6U0zlCB9yMEgFBuR3byyOffZ+p
         XDyxp4nCfLJDISsppgRvQvITJ+Wt8zbBbfF1ocv85xTn6ZstNE33v9OQvsLp+q+Ja2gg
         zYEVlW+m8AA0GUwbg35AvilB5G0zOgi1bHIIFVX4rbNy+xlHme9uGaqqnxw5OtR4fQsD
         Cb+QmzPst2gJsnSiy/rC9264xphA+7TdCINRiu8+2H0Ry201UoNUhrrFDclSg8UIFT3c
         JzhcG9hQbjlAgVArYpE/rf3ICFdjvHG+bdJsB4q4PF9ZhezoxwPJFryyp84Y1hLqxLXp
         yhug==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUMV9IRi9aiEhpBMOZsFsYj0di5eBDrKKqQefThcxIhGVJ0am2J
	T9h+vLCxL3SAKHHXftbT9SV4sAw0bzOLkT/zPR4OokcsC3NqXFJSmQzRu5KAyX8mH6zfptCUIFJ
	Mm9XkHmAugnfuOrNMwYrQGTtmaprbLxF4ZelK78UaBsWIsd5K/bMavaaQLCeD9CPqsQ==
X-Received: by 2002:a37:c9d9:: with SMTP id m86mr4325305qkl.174.1553047646796;
        Tue, 19 Mar 2019 19:07:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy0aFIWKXvH+kVeFWx76Nr+k/jQcMBFyBozCphYK6Ne5BsN00tnjqRwkRudZpcy/BK0KS+1
X-Received: by 2002:a37:c9d9:: with SMTP id m86mr4325233qkl.174.1553047644934;
        Tue, 19 Mar 2019 19:07:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553047644; cv=none;
        d=google.com; s=arc-20160816;
        b=RkRi2bxF19HQlZ0+2PyaeQ3V+mkDNtfsLeGhw6fGi6bo5k5cNaLcY7C8K8KjIWXO30
         kRkFx59U5gl+xv/O3yKhT7U0vK2umcnZZLcTlIlpDJlEiC+ioiEuy2rzwsUBaJVwqsR/
         OCy2YVpUCyPT/NES/BfZug/5Zag41jqdPRO8LApAL9vjFOgoUiZ8jMaHV4bUvvULqmuM
         nsKx9qjfCwyXCldsCbfzr13s0RkEBdF8XWr0w8tQBTpreRHVXorH0MDG6zonBFZjwkyF
         XmojNNTUlLRXGI9tFUMG5z6GYxM7iatTB6CiAat9caySsreo6qEc8V6uaHAKztcg1jQf
         M+eg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=pXV/owCkhk/Ku3ko/t4dekZX/ZdfSDa6VsorYWBWRPI=;
        b=GW1z71fJvNbZIknGgEjquVGrC+mtP02c1vqVYKKRXSkNjeK5qzqzzTT6VN9fp31Ykr
         biWRBxGOl7GfgA4b2F6FgFYaJ2d5GFXS2hnWOxdHdtuxHo7d++MwRasoAsZpTet53/Vv
         02mNgM4qMW6PgQBy68h5Utc39CWdqmh+ym1hn8vh1oCwPZjM2DQVg24qQnZ1NkcoL+LO
         F7uXaQIizVjnx5BNghgUgXoTWEMTHa3AKc9WE7OOGzXCq1IQQF/ivfdNDhFndCEOpaef
         a3c+4fBAacUHHH9VwsZ3/eRfIcsWXyWUv1aDCi04je0XaPu5kaaAbePjtBYCW+E4CReH
         vWow==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m26si392106qtn.187.2019.03.19.19.07.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 19:07:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0D5E483F40;
	Wed, 20 Mar 2019 02:07:24 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 09E746014C;
	Wed, 20 Mar 2019 02:07:17 +0000 (UTC)
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
Subject: [PATCH v3 04/28] mm: allow VM_FAULT_RETRY for multiple times
Date: Wed, 20 Mar 2019 10:06:18 +0800
Message-Id: <20190320020642.4000-5-peterx@redhat.com>
In-Reply-To: <20190320020642.4000-1-peterx@redhat.com>
References: <20190320020642.4000-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Wed, 20 Mar 2019 02:07:24 +0000 (UTC)
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
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 arch/alpha/mm/fault.c           |  2 +-
 arch/arc/mm/fault.c             |  1 -
 arch/arm/mm/fault.c             |  3 ---
 arch/arm64/mm/fault.c           |  5 -----
 arch/hexagon/mm/vm_fault.c      |  1 -
 arch/ia64/mm/fault.c            |  1 -
 arch/m68k/mm/fault.c            |  3 ---
 arch/microblaze/mm/fault.c      |  1 -
 arch/mips/mm/fault.c            |  1 -
 arch/nds32/mm/fault.c           |  1 -
 arch/nios2/mm/fault.c           |  3 ---
 arch/openrisc/mm/fault.c        |  1 -
 arch/parisc/mm/fault.c          |  4 +---
 arch/powerpc/mm/fault.c         |  6 ------
 arch/riscv/mm/fault.c           |  5 -----
 arch/s390/mm/fault.c            |  5 +----
 arch/sh/mm/fault.c              |  1 -
 arch/sparc/mm/fault_32.c        |  1 -
 arch/sparc/mm/fault_64.c        |  1 -
 arch/um/kernel/trap.c           |  1 -
 arch/unicore32/mm/fault.c       |  4 +---
 arch/x86/mm/fault.c             |  2 --
 arch/xtensa/mm/fault.c          |  1 -
 drivers/gpu/drm/ttm/ttm_bo_vm.c | 12 ++++++++---
 include/linux/mm.h              | 38 ++++++++++++++++++++++++++++++++-
 mm/filemap.c                    |  2 +-
 mm/shmem.c                      |  2 +-
 27 files changed, 52 insertions(+), 56 deletions(-)

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
index 9e9e6eb1f7d0..e7d2947ba72c 100644
--- a/arch/arc/mm/fault.c
+++ b/arch/arc/mm/fault.c
@@ -167,7 +167,6 @@ void do_page_fault(unsigned long address, struct pt_regs *regs)
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
index a38ff8c49a66..d1d3c98f9ffb 100644
--- a/arch/arm64/mm/fault.c
+++ b/arch/arm64/mm/fault.c
@@ -523,12 +523,7 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
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
index be10b441d9cc..576751597e77 100644
--- a/arch/hexagon/mm/vm_fault.c
+++ b/arch/hexagon/mm/vm_fault.c
@@ -115,7 +115,6 @@ void do_page_fault(unsigned long address, long cause, struct pt_regs *regs)
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
index 5939434a31ae..9dd1c51acc22 100644
--- a/arch/nios2/mm/fault.c
+++ b/arch/nios2/mm/fault.c
@@ -158,9 +158,6 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long cause,
 		else
 			current->min_flt++;
 		if (fault & VM_FAULT_RETRY) {
-			/* Clear FAULT_FLAG_ALLOW_RETRY to avoid any risk
-			 * of starvation. */
-			flags &= ~FAULT_FLAG_ALLOW_RETRY;
 			flags |= FAULT_FLAG_TRIED;
 
 			/*
diff --git a/arch/openrisc/mm/fault.c b/arch/openrisc/mm/fault.c
index 873ecb5d82d7..ff92c5674781 100644
--- a/arch/openrisc/mm/fault.c
+++ b/arch/openrisc/mm/fault.c
@@ -185,7 +185,6 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long address,
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
index aaa853e6592f..c831cb3ce03f 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -583,13 +583,7 @@ static int __do_page_fault(struct pt_regs *regs, unsigned long address,
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
index 4fc8d746bec3..aad2c0557d2f 100644
--- a/arch/riscv/mm/fault.c
+++ b/arch/riscv/mm/fault.c
@@ -154,11 +154,6 @@ asmlinkage void do_page_fault(struct pt_regs *regs)
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
index aba1dad1efcd..4e8c066964a9 100644
--- a/arch/s390/mm/fault.c
+++ b/arch/s390/mm/fault.c
@@ -513,10 +513,7 @@ static inline vm_fault_t do_exception(struct pt_regs *regs, int access)
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
index 248ff0a28ecd..d842c3e02a50 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1483,9 +1483,7 @@ void do_user_addr_fault(struct pt_regs *regs,
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
index a1d977fbade5..5fac635f72a5 100644
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
@@ -136,7 +137,12 @@ static vm_fault_t ttm_bo_vm_fault(struct vm_fault *vmf)
 		if (err != -EBUSY)
 			return VM_FAULT_NOPAGE;
 
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
index 80bb6408fe73..f73dbc4a1957 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -336,16 +336,52 @@ extern unsigned int kobjsize(const void *objp);
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
 
+/*
+ * Returns true if the page fault allows retry and this is the first
+ * attempt of the fault handling; false otherwise.  This is mostly
+ * used for places where we want to try to avoid taking the mmap_sem
+ * for too long a time when waiting for another condition to change,
+ * in which case we can try to be polite to release the mmap_sem in
+ * the first round to avoid potential starvation of other processes
+ * that would also want the mmap_sem.
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
index 9f5e323e883e..a2b5c53166de 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1351,7 +1351,7 @@ EXPORT_SYMBOL_GPL(__lock_page_killable);
 int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
 			 unsigned int flags)
 {
-	if (flags & FAULT_FLAG_ALLOW_RETRY) {
+	if (fault_flag_allow_retry_first(flags)) {
 		/*
 		 * CAUTION! In this case, mmap_sem is not released
 		 * even though return 0.
diff --git a/mm/shmem.c b/mm/shmem.c
index 2c012eee133d..ac875b79281c 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1949,7 +1949,7 @@ static vm_fault_t shmem_fault(struct vm_fault *vmf)
 			DEFINE_WAIT_FUNC(shmem_fault_wait, synchronous_wake_function);
 
 			ret = VM_FAULT_NOPAGE;
-			if ((vmf->flags & FAULT_FLAG_ALLOW_RETRY) &&
+			if (fault_flag_allow_retry_first(vmf->flags) &&
 			   !(vmf->flags & FAULT_FLAG_RETRY_NOWAIT)) {
 				/* It's polite to up mmap_sem if we can */
 				up_read(&vma->vm_mm->mmap_sem);
-- 
2.17.1

