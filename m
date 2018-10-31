Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 835B76B0279
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 09:00:11 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id f26so7795474otl.20
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 06:00:11 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id y127-v6si3237745oia.189.2018.10.31.06.00.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 06:00:10 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w9VCx5mn110152
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 09:00:09 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2nfbgy4656-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 09:00:08 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Wed, 31 Oct 2018 13:00:06 -0000
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [PATCH 0/4] pgtable bytes mis-accounting v3
Date: Wed, 31 Oct 2018 13:59:57 +0100
Message-Id: <1540990801-4261-1-git-send-email-schwidefsky@de.ibm.com>
Content-Type: text/plain
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Wang <liwang@redhat.com>, Guenter Roeck <linux@roeck-us.net>, Janosch Frank <frankja@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>

Greetings,

version #3 of the fix for the pgtable_bytes mis-accounting problem
on s390. Three times is a charm..

Changes v2 -> v3:

 - Add a fourth patch to redefine __PAGETABLE_PxD_FOLDED as non-empty

 - Move mm_pxd_folded() to include/asm-generic/pgtable.h and use
    __is_defined() again with the redefined __PAGETABLE_PxD_FOLDED

 - Add a missing mm_inc_nr_puds() in arch/s390/mm/pgalloc.c

Changes v1 -> v2:

 - Split the patch into three parts, one patch to add the mm_pxd_folded
    helpers, one patch to use to the helpers in mm_[dec|inc]_nr_[pmds|puds]
       and finally the fix for s390.

 - Drop the use of __is_defined, it does not work with the
    __PAGETABLE_PxD_FOLDED defines

 - Do not change the basic #ifdef'ery in mm.h, just add the calls
    to mm_pxd_folded to the pgtable_bytes accounting functions. This
       fixes the compile error on alpha (and potentially on other archs).

Martin Schwidefsky (4):
  mm: make the __PAGETABLE_PxD_FOLDED defines non-empty
  mm: introduce mm_[p4d|pud|pmd]_folded
  mm: add mm_pxd_folded checks to pgtable_bytes accounting functions
  s390/mm: fix mis-accounting of pgtable_bytes

 arch/arm/include/asm/pgtable-2level.h    |  2 +-
 arch/m68k/include/asm/pgtable_mm.h       |  4 ++--
 arch/microblaze/include/asm/pgtable.h    |  2 +-
 arch/nds32/include/asm/pgtable.h         |  2 +-
 arch/parisc/include/asm/pgtable.h        |  2 +-
 arch/s390/include/asm/mmu_context.h      |  5 -----
 arch/s390/include/asm/pgalloc.h          |  6 +++---
 arch/s390/include/asm/pgtable.h          | 18 ++++++++++++++++++
 arch/s390/include/asm/tlb.h              |  6 +++---
 arch/s390/mm/pgalloc.c                   |  1 +
 include/asm-generic/4level-fixup.h       |  2 +-
 include/asm-generic/5level-fixup.h       |  2 +-
 include/asm-generic/pgtable-nop4d-hack.h |  2 +-
 include/asm-generic/pgtable-nop4d.h      |  2 +-
 include/asm-generic/pgtable-nopmd.h      |  2 +-
 include/asm-generic/pgtable-nopud.h      |  2 +-
 include/asm-generic/pgtable.h            | 16 ++++++++++++++++
 include/linux/mm.h                       |  8 ++++++++
 18 files changed, 61 insertions(+), 23 deletions(-)

-- 
2.7.4
