Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A90D58E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 07:35:46 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id a2so14042595pgt.11
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 04:35:46 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id h188si12109130pfg.44.2019.01.21.04.35.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 04:35:45 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0LCTQ6C060936
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 07:35:44 -0500
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2q5c3we2kp-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 07:35:44 -0500
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Mon, 21 Jan 2019 12:35:42 -0000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: Re: [Bug 202149] New: NULL Pointer Dereference in __split_huge_pmd on PPC64LE
In-Reply-To: <A61367CF-277E-4E74-8A9D-C94C5E53817B@bluematt.me>
References: <bug-202149-27@https.bugzilla.kernel.org/> <20190104170459.c8c7fa57ba9bc8a69dee5666@linux-foundation.org> <87ef9nk4cj.fsf@linux.ibm.com> <ed4bea40-cf9e-89a1-f99a-3dbd6249847f@bluematt.me> <8736q2jbhr.fsf@linux.ibm.com> <A61367CF-277E-4E74-8A9D-C94C5E53817B@bluematt.me>
Date: Mon, 21 Jan 2019 18:05:33 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87bm4achnu.fsf@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Corallo <kernel@bluematt.me>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, bugzilla-daemon@bugzilla.kernel.org


Can you test this patch?

>From e511e79af9a314854848ea8fda9dfa6d7e07c5e4 Mon Sep 17 00:00:00 2001
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Mon, 21 Jan 2019 16:43:17 +0530
Subject: [PATCH] arch/powerpc/radix: Fix kernel crash with mremap

With support for split pmd lock, we use pmd page pmd_huge_pte pointer to store
the deposited page table. In those config when we move page tables we need to
make sure we move the depoisted page table to the right pmd page. Otherwise this
can result in crash when we withdraw of deposited page table because we can find
the pmd_huge_pte NULL.

c0000000004a1230 __split_huge_pmd+0x1070/0x1940
c0000000004a0ff4 __split_huge_pmd+0xe34/0x1940 (unreliable)
c0000000004a4000 vma_adjust_trans_huge+0x110/0x1c0
c00000000042fe04 __vma_adjust+0x2b4/0x9b0
c0000000004316e8 __split_vma+0x1b8/0x280
c00000000043192c __do_munmap+0x13c/0x550
c000000000439390 sys_mremap+0x220/0x7e0
c00000000000b488 system_call+0x5c/0x70

Fixes: 675d995297d4 ("powerpc/book3s64: Enable split pmd ptlock.")
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/pgtable.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index 92eaea164700..86e62384256d 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -1262,8 +1262,6 @@ static inline int pmd_move_must_withdraw(struct spinlock *new_pmd_ptl,
 					 struct spinlock *old_pmd_ptl,
 					 struct vm_area_struct *vma)
 {
-	if (radix_enabled())
-		return false;
 	/*
 	 * Archs like ppc64 use pgtable to store per pmd
 	 * specific information. So when we switch the pmd,
-- 
2.20.1
