Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id C70C26B0096
	for <linux-mm@kvack.org>; Mon, 17 Dec 2012 13:43:12 -0500 (EST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 0/2] pageattr fixes for pmd/pte_present
Date: Mon, 17 Dec 2012 19:00:22 +0100
Message-Id: <1355767224-13298-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>

Hi,

I got a report for a minor regression introduced by commit
027ef6c87853b0a9df53175063028edb4950d476.

So the problem is, pageattr creates kernel pagetables (pte and pmds)
that breaks pte_present/pmd_present and the patch above exposed this
invariant breakage for pmd_present.

The same problem already existed for the pte and pte_present and it
was fixed by commit 660a293ea9be709b893d371fbc0328fcca33c33a (if it
wasn't for that commit, it wouldn't even be a regression). That fix
avoids the pagefault to use pte_present. I could follow through by
stopping using pmd_present/pmd_huge too.

However I think it's more robust to fix pageattr and to clear the
PSE/GLOBAL bitflags too in addition to the present bitflag. So the
kernel page fault can keep using the regular
pte_present/pmd_present/pmd_huge.

The confusion arises because _PAGE_GLOBAL and _PAGE_PROTNONE are
sharing the same bit, and in the pmd case we pretend _PAGE_PSE to be
set only in present pmds (to facilitate split_huge_page final tlb
flush).

Andrea Arcangeli (2):
  Revert "x86, mm: Make spurious_fault check explicitly check the
    PRESENT bit"
  pageattr: prevent PSE and GLOABL leftovers to confuse pmd/pte_present
    and pmd_huge

 arch/x86/mm/fault.c    |    8 +------
 arch/x86/mm/pageattr.c |   50 +++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 48 insertions(+), 10 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
