Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 555278E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 04:42:03 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id p9so14691056pfj.3
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 01:42:03 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id g33si13441804pgm.426.2018.12.18.01.42.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 01:42:01 -0800 (PST)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wBI9ddls118415
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 04:42:01 -0500
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com [32.97.110.149])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2pevdt5uck-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 04:42:01 -0500
Received: from localhost
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 18 Dec 2018 09:42:00 -0000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH V4 0/5] NestMMU pte upgrade workaround for mprotect
Date: Tue, 18 Dec 2018 15:11:32 +0530
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <20181218094137.13732-1-aneesh.kumar@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: npiggin@gmail.com, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, akpm@linux-foundation.org, x86@kernel.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>

We can upgrade pte access (R -> RW transition) via mprotect. We need
to make sure we follow the recommended pte update sequence as outlined in
commit bd5050e38aec ("powerpc/mm/radix: Change pte relax sequence to handle nest MMU hang")
for such updates. This patch series do that.

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

 arch/powerpc/include/asm/book3s/64/hugetlb.h | 12 +++++++++
 arch/powerpc/include/asm/book3s/64/pgtable.h | 18 +++++++++++++
 arch/powerpc/include/asm/book3s/64/radix.h   |  4 +++
 arch/powerpc/mm/hugetlbpage-hash64.c         | 27 ++++++++++++++++++++
 arch/powerpc/mm/hugetlbpage-radix.c          | 17 ++++++++++++
 arch/powerpc/mm/pgtable-book3s64.c           | 27 ++++++++++++++++++++
 arch/powerpc/mm/pgtable-radix.c              | 18 +++++++++++++
 arch/s390/include/asm/pgtable.h              |  5 ++--
 arch/s390/mm/pgtable.c                       |  8 +++---
 arch/x86/include/asm/paravirt.h              | 13 +++++-----
 arch/x86/include/asm/paravirt_types.h        |  5 ++--
 arch/x86/xen/mmu.h                           |  4 +--
 arch/x86/xen/mmu_pv.c                        |  8 +++---
 fs/proc/task_mmu.c                           |  8 +++---
 include/asm-generic/pgtable.h                | 18 ++++++-------
 include/linux/hugetlb.h                      | 20 +++++++++++++++
 mm/hugetlb.c                                 |  8 +++---
 mm/memory.c                                  |  8 +++---
 mm/mprotect.c                                |  6 ++---
 19 files changed, 193 insertions(+), 41 deletions(-)

-- 
2.19.2
