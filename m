Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 662112802A5
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 19:52:51 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id n89so8991258pfk.17
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 16:52:51 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id l17si10442134pfj.16.2017.11.10.16.52.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Nov 2017 16:52:50 -0800 (PST)
Subject: [PATCH 0/4] fix device-dax pud crash and fixup {pte,pmd,pud}_write
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 10 Nov 2017 16:44:25 -0800
Message-ID: <151036106541.32713.16875776773735515483.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, "David S. Miller" <davem@davemloft.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Andrew,

Here is a new version to the pud_write() fix [1], and some follow-on
patches to use the '_access_permitted' helpers in fault and
get_user_pages() paths where we are checking if the thread has access to
write. I explicitly omit conversions for places where the kernel is
checking the _PAGE_RW flag for kernel purposes, not for userspace
access.

Beyond fixing the crash, this series also fixes get_user_pages() and
fault paths to honor protection keys in the same manner as
get_user_pages_fast(). Only the crash fix is tagged for -stable as the
protection key check is done just for consistency reasons since
userspace can change protection keys at will.

[1]: https://lists.01.org/pipermail/linux-nvdimm/2017-November/013237.html

---

Dan Williams (4):
      mm: fix device-dax pud write-faults triggered by get_user_pages()
      mm: replace pud_write with pud_access_permitted in fault + gup paths
      mm: replace pmd_write with pmd_access_permitted in fault + gup paths
      mm: replace pte_write with pte_access_permitted in fault + gup paths


 arch/sparc/mm/gup.c            |    4 ++--
 arch/x86/include/asm/pgtable.h |    6 ++++++
 fs/dax.c                       |    3 ++-
 include/asm-generic/pgtable.h  |    9 +++++++++
 include/linux/hugetlb.h        |    8 --------
 mm/gup.c                       |    2 +-
 mm/hmm.c                       |    8 ++++----
 mm/huge_memory.c               |    6 +++---
 mm/memory.c                    |    8 ++++----
 9 files changed, 31 insertions(+), 23 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
