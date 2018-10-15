Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9626D6B000A
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 12:42:59 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id t68-v6so13710635oih.4
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 09:42:59 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id m130-v6si5157827oif.194.2018.10.15.09.42.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 09:42:58 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w9FGegwv014594
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 12:42:57 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2n4w9suyfu-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 12:42:57 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Mon, 15 Oct 2018 17:42:54 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [RFC][PATCH 0/3] pgtable bytes mis-accounting v2
Date: Mon, 15 Oct 2018 18:42:36 +0200
Message-Id: <1539621759-5967-1-git-send-email-schwidefsky@de.ibm.com>
Content-Type: text/plain
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Wang <liwang@redhat.com>, Guenter Roeck <linux@roeck-us.net>, Janosch Frank <frankja@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>

Greetings,

the first test patch to fix the pgtable_bytes mis-accounting on s390
still had a few problems. For one it didn't work for x86 ..

Changes v1 -> v2:

 - Split the patch into three parts, one patch to add the mm_pxd_folded
   helpers, one patch to use to the helpers in mm_[dec|inc]_nr_[pmds|puds]
   and finally the fix for s390.

 - Drop the use of __is_defined, it does not work with the
   __PAGETABLE_PxD_FOLDED defines

 - Do not change the basic #ifdef'ery in mm.h, just add the calls
   to mm_pxd_folded to the pgtable_bytes accounting functions. This
   fixes the compile error on alpha (and potentially on other archs).

Martin Schwidefsky (3):
  mm: introduce mm_[p4d|pud|pmd]_folded
  mm: add mm_pxd_folded checks to pgtable_bytes accounting functions
  s390/mm: fix mis-accounting of pgtable_bytes

 arch/s390/include/asm/mmu_context.h |  5 ----
 arch/s390/include/asm/pgalloc.h     |  6 ++---
 arch/s390/include/asm/pgtable.h     | 18 ++++++++++++++
 arch/s390/include/asm/tlb.h         |  6 ++---
 include/linux/mm.h                  | 48 +++++++++++++++++++++++++++++++++++++
 5 files changed, 72 insertions(+), 11 deletions(-)

-- 
2.16.4
