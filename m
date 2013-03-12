Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id B28036B0006
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 14:48:47 -0400 (EDT)
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Tue, 12 Mar 2013 18:46:11 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id DD33117D805C
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 18:49:21 +0000 (GMT)
Received: from d06av08.portsmouth.uk.ibm.com (d06av08.portsmouth.uk.ibm.com [9.149.37.249])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2CImXuI37224510
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 18:48:33 GMT
Received: from d06av08.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av08.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2CImfWE029672
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 12:48:42 -0600
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: [PATCH 0/1] mm/hugetlb: add more arch-defined huge_pte_xxx functions
Date: Tue, 12 Mar 2013 19:48:25 +0100
Message-Id: <1363114106-30251-1-git-send-email-gerald.schaefer@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Mundt <lethal@linux-sh.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@tilera.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>

Using pte_t and pte_xxx functions in mm/hugetlbfs.c for "huge ptes" has
always been confusing and error-prone on architectures that have a
different layout for the pte/pmd/... level entries. That was the reason
for the individual arch header files in <arch>/include/asm/hugetlb.h
containing implementations for various huge_pte_xxx versions of the
original pte_xxx functions, if needed.

Commit abf09bed3c "s390/mm: implement software dirty bits" introduced
another difference in the pte layout vs. the pmd layout on s390,
thoroughly breaking the s390 support for hugetlbfs. This requires
replacing some more pte_xxx functions in mm/hugetlbfs.c with a
huge_pte_xxx version.

This patch introduces those huge_pte_xxx functions and their
implementation on all architectures supporting hugetlbfs. This change
will be a no-op for all architectures other than s390.

I am also thinking about a more complete clean-up patch, replacing all
remaining pte_xxx invocations in mm/hugetlbfs.c and maybe also
introducing a separate type like hpte_t to make this issue more
transparent and prevent future problems. But that may also require some
functional changes, and it probably won't be ready in time for Kernel
3.9. So for now, this patch only fixes the impact of the software dirty
bit changes on s390, hoping that it can be included in Kernel 3.9,
since that will be the first release including the sw dirty bits.

Gerald Schaefer (1):
  mm/hugetlb: add more arch-defined huge_pte_xxx functions

 arch/ia64/include/asm/hugetlb.h    | 36 ++++++++++++++++++++++++
 arch/mips/include/asm/hugetlb.h    | 36 ++++++++++++++++++++++++
 arch/powerpc/include/asm/hugetlb.h | 36 ++++++++++++++++++++++++
 arch/s390/include/asm/hugetlb.h    | 56 +++++++++++++++++++++++++++++++++++++-
 arch/s390/include/asm/pgtable.h    | 20 --------------
 arch/s390/mm/hugetlbpage.c         |  2 +-
 arch/sh/include/asm/hugetlb.h      | 36 ++++++++++++++++++++++++
 arch/sparc/include/asm/hugetlb.h   | 36 ++++++++++++++++++++++++
 arch/tile/include/asm/hugetlb.h    | 36 ++++++++++++++++++++++++
 arch/x86/include/asm/hugetlb.h     | 36 ++++++++++++++++++++++++
 mm/hugetlb.c                       | 23 ++++++++--------
 11 files changed, 320 insertions(+), 33 deletions(-)

-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
