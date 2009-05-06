Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BED4B6B003D
	for <linux-mm@kvack.org>; Tue,  5 May 2009 23:01:21 -0400 (EDT)
Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id n4631JcM024531
	for <linux-mm@kvack.org>; Wed, 6 May 2009 04:01:19 +0100
Received: from wa-out-1112.google.com (wafm16.prod.google.com [10.114.189.16])
	by zps37.corp.google.com with ESMTP id n4631HVA015977
	for <linux-mm@kvack.org>; Tue, 5 May 2009 20:01:17 -0700
Received: by wa-out-1112.google.com with SMTP id m16so2222199waf.19
        for <linux-mm@kvack.org>; Tue, 05 May 2009 20:01:17 -0700 (PDT)
Date: Tue, 5 May 2009 20:01:14 -0700
From: Michel Lespinasse <walken@google.com>
Subject: x86_64 remote tlb invalidation
Message-ID: <20090506030114.GA31320@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Reading through arch/x86/kernel/tlb_64.c, I've been wondering why
the code for native_flush_tlb_others() can't be simplified as follows:

--- linux-2.6.29.2.orig/arch/x86/kernel/tlb_64.c	2009-04-27 10:37:11.000000000 -0700
+++ linux-2.6.29.2/arch/x86/kernel/tlb_64.c	2009-05-05 16:53:07.770085000 -0700
@@ -180,7 +180,7 @@
 
 	f->flush_mm = mm;
 	f->flush_va = va;
-	cpus_or(f->flush_cpumask, cpumask, f->flush_cpumask);
+	f->flush_cpumask = cpumask;
 
 	/*
 	 * Make the above memory operations globally visible before


My reasoning:

* The previous invocation of native_flush_tlb_others() waited for
  f->flush_cpumask to be cleared before it unlocked f->tlbstate_lock;

* sets bits in the flush_cpumask field of union smp_flush_state without
  holding the correwsponding tlbstate_lock;

* Therefore, f->flush_cpumask must still be cleared when the next invocation
  of native_flush_tlb_others() reacquires f->tlbstate_lock.

I don't think I missed anything, did I ?

Thanks,

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
