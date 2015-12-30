Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 723396B025E
	for <linux-mm@kvack.org>; Wed, 30 Dec 2015 00:32:31 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id q63so101202407pfb.0
        for <linux-mm@kvack.org>; Tue, 29 Dec 2015 21:32:31 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id y85si25069953pfi.192.2015.12.29.21.32.30
        for <linux-mm@kvack.org>;
        Tue, 29 Dec 2015 21:32:30 -0800 (PST)
From: "Williams, Dan J" <dan.j.williams@intel.com>
Subject: Re: [-mm PATCH v4 15/18] mm, dax: dax-pmd vs thp-pmd vs
 hugetlbfs-pmd
Date: Wed, 30 Dec 2015 05:32:29 +0000
Message-ID: <1451453548.7954.4.camel@intel.com>
References: <20151221054406.34542.64393.stgit@dwillia2-desk3.jf.intel.com>
	 <20151221054526.34542.25205.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151221054526.34542.25205.stgit@dwillia2-desk3.jf.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-7"
Content-ID: <1070702E90F5954F805CC8E8CD3D5FCB@intel.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "peterz@infradead.org" <peterz@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dave@sr71.net" <dave@sr71.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "willy@linux.intel.com" <willy@linux.intel.com>, "mgorman@suse.de" <mgorman@suse.de>

On Sun, 2015-12-20 at 21:45 -0800, Dan Williams wrote:
+AD4- A dax-huge-page mapping while it uses some thp helpers is ultimately =
not a
+AD4- transparent huge page.+AKAAoA-The distinction is especially important=
 in the
+AD4- get+AF8-user+AF8-pages() path.+AKAAoA-pmd+AF8-devmap() is used to dis=
tinguish dax-pmds from
+AD4- pmd+AF8-huge() and pmd+AF8-trans+AF8-huge() which have slightly diffe=
rent semantics.
+AD4-=20
+AD4- Explicitly mark the pmd+AF8-trans+AF8-huge() helpers that dax needs b=
y adding
+AD4- pmd+AF8-devmap() checks.
+AD4-=20
+AD4- Cc: Dave Hansen +ADw-dave+AEA-sr71.net+AD4-
+AD4- Cc: Mel Gorman +ADw-mgorman+AEA-suse.de+AD4-
+AD4- Cc: Peter Zijlstra +ADw-peterz+AEA-infradead.org+AD4-
+AD4- Cc: Andrea Arcangeli +ADw-aarcange+AEA-redhat.com+AD4-
+AD4- Cc: Matthew Wilcox +ADw-willy+AEA-linux.intel.com+AD4-
+AD4- Cc: Andrew Morton +ADw-akpm+AEA-linux-foundation.org+AD4-
+AD4- Cc: Kirill A. Shutemov +ADw-kirill.shutemov+AEA-linux.intel.com+AD4-
+AD4- Signed-off-by: Dan Williams +ADw-dan.j.williams+AEA-intel.com+AD4-
+AD4-=20
+AFs-..+AF0-
+AD4- diff --git a/include/linux/mm.h b/include/linux/mm.h
+AD4- index 957afd1b10a5..96f396bbcc9f 100644
+AD4- --- a/include/linux/mm.h
+AD4- +-+-+- b/include/linux/mm.h
+AD4- +AEAAQA- -1471,6 +-1471,13 +AEAAQA- static inline int +AF8AXw-pud+AF8=
-alloc(struct mm+AF8-struct +ACo-mm, pgd+AF8-t +ACo-pgd,
+AD4- +AKA-int +AF8AXw-pud+AF8-alloc(struct mm+AF8-struct +ACo-mm, pgd+AF8-=
t +ACo-pgd, unsigned long address)+ADs-
+AD4- +AKAAIw-endif
+AD4- +AKA-
+AD4- +-+ACM-if +ACE-defined(+AF8AXw-HAVE+AF8-ARCH+AF8-PTE+AF8-DEVMAP) +AHw=
AfA- +ACE-defined(CONFIG+AF8-TRANSPARENT+AF8-HUGEPAGE)
+AD4- +-static inline int pmd+AF8-devmap(pmd+AF8-t pmd)
+AD4- +-+AHs-
+AD4- +-	return 0+ADs-
+AD4- +-+AH0-
+AD4- +-+ACM-endif
+AD4- +-

Andrew, here's an incremental fix to fold into this patch.

8+ADw----
Subject: mm: fix pmd+AF8-devmap compile error

From: Dan Williams +ADw-dan.j.williams+AEA-intel.com+AD4-

The kbuild robot reports the following with an i386 randconfig:

+AKAAoACg-In file included from arch/x86/include/asm/atomic.h:4:0,
+AKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAoA-from include/linux/=
atomic.h:4,
+AKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAoA-from include/linux/=
crypto.h:20,
+AKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAoA-from arch/x86/kerne=
l/asm-offsets.c:8:
+AKAAoACg-include/linux/huge+AF8-mm.h: In function 'pmd+AF8-trans+AF8-huge+=
AF8-lock':
+AD4APg- include/linux/huge+AF8-mm.h:128:30: error: implicit declaration of=
 function 'pmd+AF8-devmap' +AFs--Werror+AD0-implicit-function-declaration+A=
F0-
+AKAAoACgAKAAoA-if (pmd+AF8-trans+AF8-huge(+ACo-pmd) +AHwAfA- pmd+AF8-devma=
p(+ACo-pmd))
+AKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAoACgAKAAoACgAK=
AAoACgAKAAoACgAF4-
Fix by moving the fallback definition of pmd+AF8-devmap() earlier in mm.h,
before it include huge+AF8-mm.h.

Reported-by: kbuild test robot +ADw-lkp+AEA-intel.com+AD4-
Signed-off-by: Dan Williams +ADw-dan.j.williams+AEA-intel.com+AD4-
---
+AKA-include/linux/mm.h +AHwAoACgAKA-14 +-+-+-+-+-+-+--------
+AKA-1 file changed, 7 insertions(+-), 7 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index d802df18f08a..9f934b4235ca 100644
--- a/include/linux/mm.h
+-+-+- b/include/linux/mm.h
+AEAAQA- -342,6 +-342,13 +AEAAQA- struct inode+ADs-
+AKAAIw-define page+AF8-private(page)		((page)-+AD4-private)
+AKAAIw-define set+AF8-page+AF8-private(page, v)	((page)-+AD4-private +AD0-=
 (v))
+AKA-
+-+ACM-if +ACE-defined(+AF8AXw-HAVE+AF8-ARCH+AF8-PTE+AF8-DEVMAP) +AHwAfA- +=
ACE-defined(CONFIG+AF8-TRANSPARENT+AF8-HUGEPAGE)
+-static inline int pmd+AF8-devmap(pmd+AF8-t pmd)
+-+AHs-
+-	return 0+ADs-
+-+AH0-
+-+ACM-endif
+-
+AKA-/+ACo-
+AKA- +ACo- FIXME: take this include out, include page-flags.h in
+AKA- +ACo- files which need it (119 of them)
+AEAAQA- -1487,13 +-1494,6 +AEAAQA- static inline int +AF8AXw-pud+AF8-alloc=
(struct mm+AF8-struct +ACo-mm, pgd+AF8-t +ACo-pgd,
+AKA-int +AF8AXw-pud+AF8-alloc(struct mm+AF8-struct +ACo-mm, pgd+AF8-t +ACo=
-pgd, unsigned long address)+ADs-
+AKAAIw-endif
+AKA-
-+ACM-if +ACE-defined(+AF8AXw-HAVE+AF8-ARCH+AF8-PTE+AF8-DEVMAP) +AHwAfA- +A=
CE-defined(CONFIG+AF8-TRANSPARENT+AF8-HUGEPAGE)
-static inline int pmd+AF8-devmap(pmd+AF8-t pmd)
-+AHs-
-	return 0+ADs-
-+AH0-
-+ACM-endif
-
+AKAAIw-ifndef +AF8AXw-HAVE+AF8-ARCH+AF8-PTE+AF8-DEVMAP
+AKA-static inline int pte+AF8-devmap(pte+AF8-t pte)
+AKAAew-=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
