Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 860D38E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 03:51:05 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id m37so5019519qte.10
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 00:51:05 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id a13si5824844qtp.35.2019.01.16.00.51.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 00:51:04 -0800 (PST)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x0G8n5GJ126749
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 03:51:03 -0500
Received: from e13.ny.us.ibm.com (e13.ny.us.ibm.com [129.33.205.203])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2q1xfcrabe-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 03:51:03 -0500
Received: from localhost
	by e13.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 16 Jan 2019 08:51:03 -0000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH V5 0/5] NestMMU pte upgrade workaround for mprotect
Date: Wed, 16 Jan 2019 14:20:30 +0530
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <20190116085035.29729-1-aneesh.kumar@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: npiggin@gmail.com, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, akpm@linux-foundation.org, x86@kernel.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>

We can upgrade pte access (R -> RW transition) via mprotect. We need
to make sure we follow the recommended pte update sequence as outlined in
commit bd5050e38aec ("powerpc/mm/radix: Change pte relax sequence to handle nest MMU hang")
for such updates. This patch series do that.

Changes from V4:
* Drop EXPORT_SYMBOL 

Changes from V3:
* Build fix for x86

Changes from V2:
* Update commit message for patch 4
* use radix tlb flush routines directly.

Changes from V1:
* Restrict ths only for R->RW upgrade. We don't need to do this for Autonuma
* Restrict this only for radix translation mode.


Aneesh Kumar K.V (5):
  mm: Update ptep_modify_prot_start/commit to take vm_area_struct as arg
  mm: update ptep_modify_prot_commit to take old pte value as arg
  arch/powerpc/mm: Nest MMU workaround for mprotect RW upgrade.
  mm/hugetlb: Add prot_modify_start/commit sequence for hugetlb update
  arch/powerpc/mm/hugetlb: NestMMU workaround for hugetlb mprotect RW
    upgrade

 arch/powerpc/include/asm/book3s/64/hugetlb.h | 12 ++++++++++
 arch/powerpc/include/asm/book3s/64/pgtable.h | 18 ++++++++++++++
 arch/powerpc/include/asm/book3s/64/radix.h   |  4 ++++
 arch/powerpc/mm/hugetlbpage-hash64.c         | 25 ++++++++++++++++++++
 arch/powerpc/mm/hugetlbpage-radix.c          | 17 +++++++++++++
 arch/powerpc/mm/pgtable-book3s64.c           | 25 ++++++++++++++++++++
 arch/powerpc/mm/pgtable-radix.c              | 18 ++++++++++++++
 arch/s390/include/asm/pgtable.h              |  5 ++--
 arch/s390/mm/pgtable.c                       |  8 ++++---
 arch/x86/include/asm/paravirt.h              | 13 +++++-----
 arch/x86/include/asm/paravirt_types.h        |  5 ++--
 arch/x86/xen/mmu.h                           |  4 ++--
 arch/x86/xen/mmu_pv.c                        |  8 +++----
 fs/proc/task_mmu.c                           |  8 ++++---
 include/asm-generic/pgtable.h                | 18 +++++++-------
 include/linux/hugetlb.h                      | 20 ++++++++++++++++
 mm/hugetlb.c                                 |  8 ++++---
 mm/memory.c                                  |  8 +++----
 mm/mprotect.c                                |  6 ++---
 19 files changed, 189 insertions(+), 41 deletions(-)

-- 
2.20.1
