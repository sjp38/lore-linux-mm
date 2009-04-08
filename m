Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id EB4305F0001
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 16:02:45 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id n38K2jUX012200
	for <linux-mm@kvack.org>; Wed, 8 Apr 2009 13:02:46 -0700
Received: from wf-out-1314.google.com (wff29.prod.google.com [10.142.6.29])
	by wpaz29.hot.corp.google.com with ESMTP id n38K2Zk2026495
	for <linux-mm@kvack.org>; Wed, 8 Apr 2009 13:02:44 -0700
Received: by wf-out-1314.google.com with SMTP id 29so260373wff.12
        for <linux-mm@kvack.org>; Wed, 08 Apr 2009 13:02:44 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 8 Apr 2009 13:02:43 -0700
Message-ID: <604427e00904081302g1e3e4923kd61ceac5de72ccb2@mail.gmail.com>
Subject: [PATCH][2/2]page_fault retry with NOPAGE_RETRY
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, akpm <akpm@linux-foundation.org>, torvalds@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>, =?ISO-8859-1?Q?T=F6r=F6k_Edwin?= <edwintorok@gmail.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

x86 support:

Signed-off-by: Ying Han <yinghan@google.com>
	       Mike Waychison <mikew@google.com>

arch/x86/mm/fault.c |   20 ++++++++++++++


diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 31e8730..0ec60a1 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -591,6 +591,7 @@ void __kprobes do_page_fault(struct pt_regs *regs, unsigne
 #ifdef CONFIG_X86_64
 	unsigned long flags;
 #endif
+	unsigned int retry_flag = FAULT_FLAG_RETRY;

 	tsk = current;
 	mm = tsk->mm;
@@ -689,6 +690,7 @@ again:
 		down_read(&mm->mmap_sem);
 	}

+retry:
 	vma = find_vma(mm, address);
 	if (!vma)
 		goto bad_area;
@@ -715,6 +717,7 @@ again:
 good_area:
 	si_code = SEGV_ACCERR;
 	write = 0;
+	write |= retry_flag;
 	switch (error_code & (PF_PROT|PF_WRITE)) {
 	default:	/* 3: write, present */
 		/* fall through */
@@ -743,6 +746,23 @@ good_area:
 			goto do_sigbus;
 		BUG();
 	}
+
+	/*
+	 * Here we retry fault once and switch to synchronous mode. The
+	 * main reason is to prevent us from the cases of starvation.
+	 * The retry logic open a starvation hole in which case pages might
+	 * be removed or changed after the retry.
+	 */
+	if (fault & VM_FAULT_RETRY) {
+		if (write & FAULT_FLAG_RETRY) {
+			retry_flag &= ~FAULT_FLAG_RETRY;
+			tsk->maj_flt++;
+			tsk->min_flt--;
+			goto retry;
+		}
+		BUG();
+	}
+
 	if (fault & VM_FAULT_MAJOR)
 		tsk->maj_flt++;
 	else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
