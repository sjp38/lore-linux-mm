Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 118976B0003
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 23:53:19 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id l89-v6so5329395otc.6
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 20:53:19 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c4si12691421otj.21.2018.10.10.20.53.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 20:53:17 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w9B3mqLQ057667
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 23:53:16 -0400
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2n1ubv7dhw-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 23:53:16 -0400
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 10 Oct 2018 21:53:16 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH 0/5] NestMMU pte upgrade workaround for mprotect and autonuma
Date: Thu, 11 Oct 2018 09:22:42 +0530
Message-Id: <20181011035247.30687-1-aneesh.kumar@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mpe@ellerman.id.au, benh@kernel.crashing.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>

We can upgrade pte access (R -> RW transition) via mprotect or autonuma. We need
to make sure we follow the recommended pte update sequence as outlined in
commit: bd5050e38aec ("powerpc/mm/radix: Change pte relax sequence to handle nest MMU hang")
for such updates. This patch series do that.

Aneesh Kumar K.V (5):
  mm: Update ptep_modify_prot_start/commit to take vm_area_struct as arg
  mm: update ptep_modify_prot_commit to take old pte value as arg
  arch/powerpc/mm: Nest MMU workaround for mprotect/autonuma RW upgrade.
  mm/hugetlb: Add prot_modify_start/commit sequence for hugetlb update
  arch/powerpc/mm/hugetlb: NestMMU workaround for hugetlb mprotect RW
    upgrade

 arch/powerpc/include/asm/book3s/64/hugetlb.h |  8 +++++
 arch/powerpc/include/asm/book3s/64/pgtable.h | 18 ++++++++++
 arch/powerpc/include/asm/hugetlb.h           |  2 +-
 arch/powerpc/mm/hugetlbpage.c                | 35 ++++++++++++++++++++
 arch/powerpc/mm/pgtable-book3s64.c           | 34 +++++++++++++++++++
 arch/s390/include/asm/pgtable.h              |  5 +--
 arch/s390/mm/pgtable.c                       |  8 +++--
 arch/x86/include/asm/paravirt.h              |  9 +++--
 fs/proc/task_mmu.c                           |  8 +++--
 include/asm-generic/pgtable.h                | 10 +++---
 include/linux/hugetlb.h                      | 18 ++++++++++
 mm/hugetlb.c                                 |  8 +++--
 mm/memory.c                                  |  8 ++---
 mm/mprotect.c                                |  6 ++--
 14 files changed, 150 insertions(+), 27 deletions(-)

-- 
2.17.1
