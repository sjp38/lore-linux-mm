Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id AFEF2440D4B
	for <linux-mm@kvack.org>; Sat, 11 Nov 2017 15:19:52 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id x202so6263525pgx.1
        for <linux-mm@kvack.org>; Sat, 11 Nov 2017 12:19:52 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id i71si1107983pge.619.2017.11.11.12.19.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 11 Nov 2017 12:19:49 -0800 (PST)
Subject: [PATCH v2 0/4] fix device-dax pud crash and fixup {pte, pmd,
 pud}_write
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 11 Nov 2017 12:11:34 -0800
Message-ID: <151043109403.2842.11607911965674122836.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Catalin Marinas <catalin.marinas@arm.com>, x86@kernel.org, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, Will Deacon <will.deacon@arm.com>, Dave Hansen <dave.hansen@intel.com>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Ingo Molnar <mingo@redhat.com>, stable@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, "David S. Miller" <davem@davemloft.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-nvdimm@lists.01.org

Changes since v1 [1]:
* fix arm64 compilation, add __HAVE_ARCH_PUD_WRITE
* fix sparc64 compilation, add __HAVE_ARCH_PUD_WRITE
* fix s390 compilation, add a pud_write() helper

---

Andrew,

Here is a third version to the pud_write() fix [2], and some follow-on
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

[1]: https://lists.01.org/pipermail/linux-nvdimm/2017-November/013249.html
[2]: https://lists.01.org/pipermail/linux-nvdimm/2017-November/013237.html

---

Dan Williams (4):
      mm: fix device-dax pud write-faults triggered by get_user_pages()
      mm: replace pud_write with pud_access_permitted in fault + gup paths
      mm: replace pmd_write with pmd_access_permitted in fault + gup paths
      mm: replace pte_write with pte_access_permitted in fault + gup paths


 arch/arm64/include/asm/pgtable.h    |    1 +
 arch/s390/include/asm/pgtable.h     |    6 ++++++
 arch/sparc/include/asm/pgtable_64.h |    1 +
 arch/sparc/mm/gup.c                 |    4 ++--
 arch/x86/include/asm/pgtable.h      |    6 ++++++
 fs/dax.c                            |    3 ++-
 include/asm-generic/pgtable.h       |    9 +++++++++
 include/linux/hugetlb.h             |    8 --------
 mm/gup.c                            |    2 +-
 mm/hmm.c                            |    8 ++++----
 mm/huge_memory.c                    |    6 +++---
 mm/memory.c                         |    8 ++++----
 12 files changed, 39 insertions(+), 23 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
