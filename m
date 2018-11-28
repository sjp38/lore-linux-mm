Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9EE976B4D6E
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 09:34:59 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id x15so12623779edd.2
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 06:34:59 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id z49si3929236edz.233.2018.11.28.06.34.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Nov 2018 06:34:57 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wASEYFOi082781
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 09:34:56 -0500
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com [32.97.110.154])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2p1vrn8eju-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 09:34:55 -0500
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 28 Nov 2018 14:34:55 -0000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH V2 0/5] NestMMU pte upgrade workaround for mprotect
Date: Wed, 28 Nov 2018 20:04:33 +0530
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <20181128143438.29458-1-aneesh.kumar@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>


We can upgrade pte access (R -> RW transition) via mprotect. We need
to make sure we follow the recommended pte update sequence as outlined in
commit: bd5050e38aec ("powerpc/mm/radix: Change pte relax sequence to handle nest MMU hang")
for such updates. This patch series do that.

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

 arch/powerpc/include/asm/book3s/64/hugetlb.h | 12 ++++++++
 arch/powerpc/include/asm/book3s/64/pgtable.h | 18 ++++++++++++
 arch/powerpc/include/asm/book3s/64/radix.h   |  4 +++
 arch/powerpc/mm/hugetlbpage-radix.c          | 17 ++++++++++++
 arch/powerpc/mm/hugetlbpage.c                | 29 ++++++++++++++++++++
 arch/powerpc/mm/pgtable-book3s64.c           | 27 ++++++++++++++++++
 arch/powerpc/mm/pgtable-radix.c              | 18 ++++++++++++
 arch/s390/include/asm/pgtable.h              |  5 ++--
 arch/s390/mm/pgtable.c                       |  8 ++++--
 arch/x86/include/asm/paravirt.h              |  9 ++++--
 fs/proc/task_mmu.c                           |  8 ++++--
 include/asm-generic/pgtable.h                | 10 +++----
 include/linux/hugetlb.h                      | 18 ++++++++++++
 mm/hugetlb.c                                 |  8 ++++--
 mm/memory.c                                  |  8 +++---
 mm/mprotect.c                                |  6 ++--
 16 files changed, 179 insertions(+), 26 deletions(-)

-- 
2.19.1
