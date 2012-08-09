Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 6B3076B005A
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 05:08:39 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC 0/9] Introduce huge zero page
Date: Thu,  9 Aug 2012 12:08:11 +0300
Message-Id: <1344503300-9507-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org
Cc: Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

During testing I noticed big (up to 2.5 times) memory consumption overhead
on some workloads (e.g. ft.A from NPB) if THP is enabled.

The main reason for that big difference is lacking zero page in THP case.
We have to allocate a real page on read page fault.

A program to demonstrate the issue:
#include <assert.h>
#include <stdlib.h>
#include <unistd.h>

#define MB 1024*1024

int main(int argc, char **argv)
{
        char *p;
        int i;

        posix_memalign((void **)&p, 2 * MB, 200 * MB);
        for (i = 0; i < 200 * MB; i+= 4096)
                assert(p[i] == 0);
        pause();
        return 0;
}

With thp-never RSS is about 400k, but with thp-always it's 200M.
After the patcheset thp-always RSS is 400k too.

H. Peter Anvin proposed to use a "virtual huge zero page" -- a pmd table
with all pte set to 4k zero page. I haven't tried that approach and I'm
not sure if it's good idea (cache vs. tlb trashing). And I guess it will
require more code to handle.
For now, I just allocate 2M page and use it.

Kirill A. Shutemov (9):
  thp: huge zero page: basic preparation
  thp: zap_huge_pmd(): zap huge zero pmd
  thp: copy_huge_pmd(): copy huge zero page
  thp: do_huge_pmd_wp_page(): handle huge zero page
  thp: change_huge_pmd(): keep huge zero page write-protected
  thp: add address parameter to split_huge_page_pmd()
  thp: implement splitting pmd for huge zero page
  thp: setup huge zero page on non-write page fault
  thp: lazy huge zero page allocation

 Documentation/vm/transhuge.txt |    4 +-
 arch/x86/kernel/vm86_32.c      |    2 +-
 fs/proc/task_mmu.c             |    2 +-
 include/linux/huge_mm.h        |   10 +-
 include/linux/mm.h             |    8 ++
 mm/huge_memory.c               |  228 +++++++++++++++++++++++++++++++++++-----
 mm/memory.c                    |   11 +--
 mm/mempolicy.c                 |    2 +-
 mm/mprotect.c                  |    2 +-
 mm/mremap.c                    |    3 +-
 mm/pagewalk.c                  |    2 +-
 11 files changed, 226 insertions(+), 48 deletions(-)

-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
