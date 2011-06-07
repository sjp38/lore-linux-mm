Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3FDD56B004A
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 16:28:35 -0400 (EDT)
Received: from EXHQ.corp.stratus.com (exhq.corp.stratus.com [134.111.201.100])
	by mailhub4.stratus.com (8.12.11/8.12.11) with ESMTP id p57KSSK0006945
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 16:28:28 -0400
Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01CC2551.752AE221"
Subject: [PATCH] Dirty page tracking for physical system migration
Date: Tue, 7 Jun 2011 16:28:27 -0400
Message-ID: <AC1B83CE65082B4DBDDB681ED2F6B2EF1ACD9D@EXHQ.corp.stratus.com>
From: "Paradis, James" <James.Paradis@stratus.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01CC2551.752AE221
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

=20

This patch implements a system to track re-dirtied pages and modified

PTEs.  It is used by Stratus Technologies for both our ftLinux product
and

our new GPL Live Kernel Self Migration project (lksm.sourceforge.net).

In both cases, we bring a backup server online by copying the primary

server's state while it is running.  We start by copying all of memory

top to bottom.  We then go back and re-copy any pages that were changed

during the first copy pass.  After several such passes we momentarily

suspend processing so we can copy the last few pages over and bring up

the secondary system.  This patch keeps track of which pages need to be

copied during these passes.

=20

 arch/x86/Kconfig                      |   11 +++++++++++

 arch/x86/include/asm/hugetlb.h        |    3 +++

 arch/x86/include/asm/pgtable-2level.h |    4 ++++

 arch/x86/include/asm/pgtable-3level.h |   11 +++++++++++

 arch/x86/include/asm/pgtable.h        |    4 ++--

 arch/x86/include/asm/pgtable_32.h     |    1 +

 arch/x86/include/asm/pgtable_64.h     |    7 +++++++

 arch/x86/include/asm/pgtable_types.h  |    5 ++++-

 arch/x86/mm/Makefile                  |    2 ++

 mm/huge_memory.c                      |    4 ++--

 11 files changed, 48 insertions(+), 6 deletions(-)

=20

Signed-off-by: "James Paradis" <james.paradis@stratus.com>

=20

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig

index cc6c53a..cc778a4 100644

--- a/arch/x86/Kconfig

+++ b/arch/x86/Kconfig

@@ -1146,6 +1146,17 @@ config DIRECT_GBPAGES

                  support it. This can improve the kernel's performance
a tiny bit by

                  reducing TLB pressure. If in doubt, say "Y".

=20

+config TRACK_DIRTY_PAGES

+              bool "Enable dirty page tracking"

+              default n

+              depends on !KMEMCHECK

+              ---help---

+                Turning this on enables tracking of re-dirtied and

+                changed pages.  This is needed by the Live Kernel

+                Self Migration project (lksm.sourceforge.net) to
perform

+                live copying of memory and system state to another
system.

+                Most users will say n here.

+

 # Common NUMA Features

 config NUMA

                bool "Numa Memory Allocation and Scheduler Support"

diff --git a/arch/x86/include/asm/hugetlb.h
b/arch/x86/include/asm/hugetlb.h

index 439a9ac..8266873 100644

--- a/arch/x86/include/asm/hugetlb.h

+++ b/arch/x86/include/asm/hugetlb.h

@@ -2,6 +2,7 @@

 #define _ASM_X86_HUGETLB_H

=20

 #include <asm/page.h>

+#include <asm/mm_track.h>

=20

=20

 static inline int is_hugepage_only_range(struct mm_struct *mm,

@@ -39,12 +40,14 @@ static inline void hugetlb_free_pgd_range(struct
mmu_gather *tlb,

 static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long
addr,

                                                                   pte_t
*ptep, pte_t pte)

 {

+              mm_track_pmd((pmd_t *)ptep);

                set_pte_at(mm, addr, ptep, pte);

 }

=20

 static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,

=20
unsigned long addr, pte_t *ptep)

 {

+              mm_track_pmd((pmd_t *)ptep);

                return ptep_get_and_clear(mm, addr, ptep);

 }

=20

diff --git a/arch/x86/include/asm/pgtable-2level.h
b/arch/x86/include/asm/pgtable-2level.h

index 98391db..a59deb5 100644

--- a/arch/x86/include/asm/pgtable-2level.h

+++ b/arch/x86/include/asm/pgtable-2level.h

@@ -13,11 +13,13 @@

  */

 static inline void native_set_pte(pte_t *ptep , pte_t pte)

 {

+              mm_track_pte(ptep);

                *ptep =3D pte;

 }

=20

 static inline void native_set_pmd(pmd_t *pmdp, pmd_t pmd)

 {

+              mm_track_pmd(pmdp);

                *pmdp =3D pmd;

 }

=20

@@ -34,12 +36,14 @@ static inline void native_pmd_clear(pmd_t *pmdp)

 static inline void native_pte_clear(struct mm_struct *mm,

=20
unsigned long addr, pte_t *xp)

 {

+              mm_track_pte(xp);

                *xp =3D native_make_pte(0);

 }

=20

 #ifdef CONFIG_SMP

 static inline pte_t native_ptep_get_and_clear(pte_t *xp)

 {

+              mm_track_pte(xp);

                return __pte(xchg(&xp->pte_low, 0));

 }

 #else

diff --git a/arch/x86/include/asm/pgtable-3level.h
b/arch/x86/include/asm/pgtable-3level.h

index effff47..b75d753 100644

--- a/arch/x86/include/asm/pgtable-3level.h

+++ b/arch/x86/include/asm/pgtable-3level.h

@@ -26,6 +26,7 @@

  */

 static inline void native_set_pte(pte_t *ptep, pte_t pte)

 {

+              mm_track_pte(ptep);

                ptep->pte_high =3D pte.pte_high;

                smp_wmb();

                ptep->pte_low =3D pte.pte_low;

@@ -33,16 +34,19 @@ static inline void native_set_pte(pte_t *ptep, pte_t
pte)

=20

 static inline void native_set_pte_atomic(pte_t *ptep, pte_t pte)

 {

+              mm_track_pte(ptep);

                set_64bit((unsigned long long *)(ptep),
native_pte_val(pte));

 }

=20

 static inline void native_set_pmd(pmd_t *pmdp, pmd_t pmd)

 {

+              mm_track_pmd(pmdp);

                set_64bit((unsigned long long *)(pmdp),
native_pmd_val(pmd));

 }

=20

 static inline void native_set_pud(pud_t *pudp, pud_t pud)

 {

+              mm_track_pud(pudp);

                set_64bit((unsigned long long *)(pudp),
native_pud_val(pud));

 }

=20

@@ -54,6 +58,7 @@ static inline void native_set_pud(pud_t *pudp, pud_t
pud)

 static inline void native_pte_clear(struct mm_struct *mm, unsigned long
addr,

=20
pte_t *ptep)

 {

+              mm_track_pte(ptep);

                ptep->pte_low =3D 0;

                smp_wmb();

                ptep->pte_high =3D 0;

@@ -62,6 +67,9 @@ static inline void native_pte_clear(struct mm_struct
*mm, unsigned long addr,

 static inline void native_pmd_clear(pmd_t *pmd)

 {

                u32 *tmp =3D (u32 *)pmd;

+

+              mm_track_pmd(pmd);

+

                *tmp =3D 0;

                smp_wmb();

                *(tmp + 1) =3D 0;

@@ -69,6 +77,7 @@ static inline void native_pmd_clear(pmd_t *pmd)

=20

 static inline void pud_clear(pud_t *pudp)

 {

+              mm_track_pud(pudp);

                set_pud(pudp, __pud(0));

=20

                /*

@@ -88,6 +97,8 @@ static inline pte_t native_ptep_get_and_clear(pte_t
*ptep)

 {

                pte_t res;

=20

+              mm_track_pte(ptep);

+

                /* xchg acts as a barrier before the setting of the high
bits */

                res.pte_low =3D xchg(&ptep->pte_low, 0);

                res.pte_high =3D ptep->pte_high;

diff --git a/arch/x86/include/asm/pgtable.h
b/arch/x86/include/asm/pgtable.h

index 18601c8..30bb916 100644

--- a/arch/x86/include/asm/pgtable.h

+++ b/arch/x86/include/asm/pgtable.h

@@ -89,7 +89,7 @@ extern struct mm_struct *pgd_page_get_mm(struct page
*page);

  */

 static inline int pte_dirty(pte_t pte)

 {

-              return pte_flags(pte) & _PAGE_DIRTY;

+              return pte_flags(pte) & (_PAGE_DIRTY | _PAGE_SOFTDIRTY);

 }

=20

 static inline int pte_young(pte_t pte)

@@ -183,7 +183,7 @@ static inline pte_t pte_clear_flags(pte_t pte,
pteval_t clear)

=20

 static inline pte_t pte_mkclean(pte_t pte)

 {

-              return pte_clear_flags(pte, _PAGE_DIRTY);

+              return pte_clear_flags(pte, (_PAGE_DIRTY |
_PAGE_SOFTDIRTY));

 }

=20

 static inline pte_t pte_mkold(pte_t pte)

diff --git a/arch/x86/include/asm/pgtable_32.h
b/arch/x86/include/asm/pgtable_32.h

index 0c92113..78415fb 100644

--- a/arch/x86/include/asm/pgtable_32.h

+++ b/arch/x86/include/asm/pgtable_32.h

@@ -21,6 +21,7 @@

 #include <linux/bitops.h>

 #include <linux/list.h>

 #include <linux/spinlock.h>

+#include <asm/mm_track.h>

=20

 struct mm_struct;

 struct vm_area_struct;

diff --git a/arch/x86/include/asm/pgtable_64.h
b/arch/x86/include/asm/pgtable_64.h

index 975f709..0848e9e 100644

--- a/arch/x86/include/asm/pgtable_64.h

+++ b/arch/x86/include/asm/pgtable_64.h

@@ -13,6 +13,7 @@

 #include <asm/processor.h>

 #include <linux/bitops.h>

 #include <linux/threads.h>

+#include <asm/mm_track.h>

=20

 extern pud_t level3_kernel_pgt[512];

 extern pud_t level3_ident_pgt[512];

@@ -46,11 +47,13 @@ void set_pte_vaddr_pud(pud_t *pud_page, unsigned
long vaddr, pte_t new_pte);

 static inline void native_pte_clear(struct mm_struct *mm, unsigned long
addr,

=20
pte_t *ptep)

 {

+              mm_track_pte(ptep);

                *ptep =3D native_make_pte(0);

 }

=20

 static inline void native_set_pte(pte_t *ptep, pte_t pte)

 {

+              mm_track_pte(ptep);

                *ptep =3D pte;

 }

=20

@@ -61,6 +64,7 @@ static inline void native_set_pte_atomic(pte_t *ptep,
pte_t pte)

=20

 static inline void native_set_pmd(pmd_t *pmdp, pmd_t pmd)

 {

+              mm_track_pmd(pmdp);

                *pmdp =3D pmd;

 }

=20

@@ -71,6 +75,7 @@ static inline void native_pmd_clear(pmd_t *pmd)

=20

 static inline pte_t native_ptep_get_and_clear(pte_t *xp)

 {

+              mm_track_pte(xp);

 #ifdef CONFIG_SMP

                return native_make_pte(xchg(&xp->pte, 0));

 #else

@@ -97,6 +102,7 @@ static inline pmd_t native_pmdp_get_and_clear(pmd_t
*xp)

=20

 static inline void native_set_pud(pud_t *pudp, pud_t pud)

 {

+              mm_track_pud(pudp);

                *pudp =3D pud;

 }

=20

@@ -107,6 +113,7 @@ static inline void native_pud_clear(pud_t *pud)

=20

 static inline void native_set_pgd(pgd_t *pgdp, pgd_t pgd)

 {

+              mm_track_pgd(pgdp);

                *pgdp =3D pgd;

 }

=20

diff --git a/arch/x86/include/asm/pgtable_types.h
b/arch/x86/include/asm/pgtable_types.h

index d56187c..7f366d0 100644

--- a/arch/x86/include/asm/pgtable_types.h

+++ b/arch/x86/include/asm/pgtable_types.h

@@ -23,6 +23,7 @@

 #define _PAGE_BIT_SPECIAL     _PAGE_BIT_UNUSED1

 #define _PAGE_BIT_CPA_TEST  _PAGE_BIT_UNUSED1

 #define _PAGE_BIT_SPLITTING _PAGE_BIT_UNUSED1 /* only valid on a PSE
pmd */

+#define _PAGE_BIT_SOFTDIRTY              _PAGE_BIT_HIDDEN

 #define _PAGE_BIT_NX           63       /* No execute: only valid after
cpuid check */

=20

 /* If _PAGE_BIT_PRESENT is clear, we use these: */

@@ -47,6 +48,7 @@

 #define _PAGE_SPECIAL              (_AT(pteval_t, 1) <<
_PAGE_BIT_SPECIAL)

 #define _PAGE_CPA_TEST          (_AT(pteval_t, 1) <<
_PAGE_BIT_CPA_TEST)

 #define _PAGE_SPLITTING          (_AT(pteval_t, 1) <<
_PAGE_BIT_SPLITTING)

+#define _PAGE_SOFTDIRTY       (_AT(pteval_t, 1) << _PAGE_BIT_SOFTDIRTY)

 #define __HAVE_ARCH_PTE_SPECIAL

=20

 #ifdef CONFIG_KMEMCHECK

@@ -71,7 +73,8 @@

=20

 /* Set of bits not changed in pte_modify */

 #define _PAGE_CHG_MASK       (PTE_PFN_MASK | _PAGE_PCD | _PAGE_PWT |
\

-                                              _PAGE_SPECIAL |
_PAGE_ACCESSED | _PAGE_DIRTY)

+                                              _PAGE_SPECIAL |
_PAGE_ACCESSED | _PAGE_DIRTY |   \

+                                              _PAGE_SOFTDIRTY)

 #define _HPAGE_CHG_MASK (_PAGE_CHG_MASK | _PAGE_PSE)

=20

 #define _PAGE_CACHE_MASK  (_PAGE_PCD | _PAGE_PWT)

diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile

index 3e608ed..a416317 100644

--- a/arch/x86/mm/Makefile

+++ b/arch/x86/mm/Makefile

@@ -30,3 +30,5 @@ obj-$(CONFIG_NUMA_EMU)                             =
+=3D
numa_emulation.o

 obj-$(CONFIG_HAVE_MEMBLOCK)                         +=3D memblock.o

=20

 obj-$(CONFIG_MEMTEST)                           +=3D memtest.o

+

+obj-$(CONFIG_TRACK_DIRTY_PAGES)  +=3D track.o

diff --git a/mm/huge_memory.c b/mm/huge_memory.c

index 83326ad..b94aad6 100644

--- a/mm/huge_memory.c

+++ b/mm/huge_memory.c

@@ -795,7 +795,7 @@ static int do_huge_pmd_wp_page_fallback(struct
mm_struct *mm,

=20
unsigned long haddr)

 {

                pgtable_t pgtable;

-              pmd_t _pmd;

+              pmd_t _pmd =3D {0};

                int ret =3D 0, i;

                struct page **pages;

=20

@@ -1265,7 +1265,7 @@ static int __split_huge_page_map(struct page
*page,

=20
unsigned long address)

 {

                struct mm_struct *mm =3D vma->vm_mm;

-              pmd_t *pmd, _pmd;

+              pmd_t *pmd, _pmd =3D {0};

                int ret =3D 0, i;

                pgtable_t pgtable;

                unsigned long haddr;


------_=_NextPart_001_01CC2551.752AE221
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html xmlns:v=3D"urn:schemas-microsoft-com:vml" =
xmlns:o=3D"urn:schemas-microsoft-com:office:office" =
xmlns:w=3D"urn:schemas-microsoft-com:office:word" =
xmlns:m=3D"http://schemas.microsoft.com/office/2004/12/omml" =
xmlns=3D"http://www.w3.org/TR/REC-html40">

<head>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Dus-ascii">
<meta name=3DGenerator content=3D"Microsoft Word 12 (filtered medium)">
<style>
<!--
 /* Font Definitions */
 @font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0in;
	margin-bottom:.0001pt;
	font-size:11.0pt;
	font-family:"Calibri","sans-serif";}
a:link, span.MsoHyperlink
	{mso-style-priority:99;
	color:blue;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{mso-style-priority:99;
	color:purple;
	text-decoration:underline;}
span.EmailStyle17
	{mso-style-type:personal;
	font-family:"Calibri","sans-serif";
	color:windowtext;}
span.EmailStyle18
	{mso-style-type:personal-reply;
	font-family:"Calibri","sans-serif";
	color:#1F497D;}
.MsoChpDefault
	{mso-style-type:export-only;
	font-size:10.0pt;}
@page Section1
	{size:8.5in 11.0in;
	margin:1.0in 1.0in 1.0in 1.0in;}
div.Section1
	{page:Section1;}
-->
</style>
<!--[if gte mso 9]><xml>
 <o:shapedefaults v:ext=3D"edit" spidmax=3D"1026" />
</xml><![endif]--><!--[if gte mso 9]><xml>
 <o:shapelayout v:ext=3D"edit">
  <o:idmap v:ext=3D"edit" data=3D"1" />
 </o:shapelayout></xml><![endif]-->
</head>

<body lang=3DEN-US link=3Dblue vlink=3Dpurple>

<div class=3DSection1>

<p class=3DMsoNormal><o:p>&nbsp;</o:p></p>

<p class=3DMsoNormal>This patch implements a system to track re-dirtied =
pages and
modified<o:p></o:p></p>

<p class=3DMsoNormal>PTEs.&nbsp; It is used by Stratus Technologies for =
both our
ftLinux product and<o:p></o:p></p>

<p class=3DMsoNormal>our new GPL Live Kernel Self Migration project
(lksm.sourceforge.net).<o:p></o:p></p>

<p class=3DMsoNormal>In both cases, we bring a backup server online by =
copying
the primary<o:p></o:p></p>

<p class=3DMsoNormal>server's state while it is running.&nbsp; We start =
by
copying all of memory<o:p></o:p></p>

<p class=3DMsoNormal>top to bottom.&nbsp; We then go back and re-copy =
any pages
that were changed<o:p></o:p></p>

<p class=3DMsoNormal>during the first copy pass.&nbsp; After several =
such passes
we momentarily<o:p></o:p></p>

<p class=3DMsoNormal>suspend processing so we can copy the last few =
pages over
and bring up<o:p></o:p></p>

<p class=3DMsoNormal>the secondary system.&nbsp; This patch keeps track =
of which
pages need to be<o:p></o:p></p>

<p class=3DMsoNormal>copied during these passes.<o:p></o:p></p>

<p class=3DMsoNormal><o:p>&nbsp;</o:p></p>

<p =
class=3DMsoNormal>&nbsp;arch/x86/Kconfig&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;
|&nbsp;&nbsp; 11 +++++++++++<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;arch/x86/include/asm/hugetlb.h&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;
|&nbsp;&nbsp;&nbsp; 3 +++<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;arch/x86/include/asm/pgtable-2level.h
|&nbsp;&nbsp;&nbsp; 4 ++++<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;arch/x86/include/asm/pgtable-3level.h =
|&nbsp;&nbsp; 11
+++++++++++<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;arch/x86/include/asm/pgtable.h&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;
|&nbsp;&nbsp;&nbsp; 4 ++--<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;arch/x86/include/asm/pgtable_32.h&nbsp;&nbsp;&nbs=
p;&nbsp;
|&nbsp;&nbsp;&nbsp; 1 +<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;arch/x86/include/asm/pgtable_64.h&nbsp;&nbsp;&nbs=
p;&nbsp;
|&nbsp;&nbsp;&nbsp; 7 +++++++<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;arch/x86/include/asm/pgtable_types.h&nbsp;
|&nbsp;&nbsp;&nbsp; 5 ++++-<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;arch/x86/mm/Makefile&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=

|&nbsp;&nbsp;&nbsp; 2 ++<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;mm/huge_memory.c&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;
|&nbsp;&nbsp;&nbsp; 4 ++--<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;11 files changed, 48 insertions(+), 6 =
deletions(-)<o:p></o:p></p>

<p class=3DMsoNormal><o:p>&nbsp;</o:p></p>

<p class=3DMsoNormal>Signed-off-by: &quot;James Paradis&quot;
&lt;james.paradis@stratus.com&gt;<o:p></o:p></p>

<p class=3DMsoNormal><o:p>&nbsp;</o:p></p>

<p class=3DMsoNormal>diff --git a/arch/x86/Kconfig =
b/arch/x86/Kconfig<o:p></o:p></p>

<p class=3DMsoNormal>index cc6c53a..cc778a4 100644<o:p></o:p></p>

<p class=3DMsoNormal>--- a/arch/x86/Kconfig<o:p></o:p></p>

<p class=3DMsoNormal>+++ b/arch/x86/Kconfig<o:p></o:p></p>

<p class=3DMsoNormal>@@ -1146,6 +1146,17 @@ config =
DIRECT_GBPAGES<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp; support it. This can improve the kernel's performance a tiny bit =
by<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp; reducing TLB pressure. If in doubt, say =
&quot;Y&quot;.<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>+config TRACK_DIRTY_PAGES<o:p></o:p></p>

<p =
class=3DMsoNormal>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
bool &quot;Enable dirty page tracking&quot;<o:p></o:p></p>

<p =
class=3DMsoNormal>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
default n<o:p></o:p></p>

<p =
class=3DMsoNormal>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
depends on !KMEMCHECK<o:p></o:p></p>

<p =
class=3DMsoNormal>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
---help---<o:p></o:p></p>

<p =
class=3DMsoNormal>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp; Turning this on enables tracking of re-dirtied and<o:p></o:p></p>

<p =
class=3DMsoNormal>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp; changed pages.&nbsp; This is needed by the Live =
Kernel<o:p></o:p></p>

<p =
class=3DMsoNormal>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp; Self Migration project (lksm.sourceforge.net) to =
perform<o:p></o:p></p>

<p =
class=3DMsoNormal>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp; live copying of memory and system state to another =
system.<o:p></o:p></p>

<p =
class=3DMsoNormal>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp; Most users will say n here.<o:p></o:p></p>

<p class=3DMsoNormal>+<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;# Common NUMA Features<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;config NUMA<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
bool &quot;Numa Memory Allocation and Scheduler =
Support&quot;<o:p></o:p></p>

<p class=3DMsoNormal>diff --git a/arch/x86/include/asm/hugetlb.h
b/arch/x86/include/asm/hugetlb.h<o:p></o:p></p>

<p class=3DMsoNormal>index 439a9ac..8266873 100644<o:p></o:p></p>

<p class=3DMsoNormal>--- a/arch/x86/include/asm/hugetlb.h<o:p></o:p></p>

<p class=3DMsoNormal>+++ b/arch/x86/include/asm/hugetlb.h<o:p></o:p></p>

<p class=3DMsoNormal>@@ -2,6 +2,7 @@<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;#define _ASM_X86_HUGETLB_H<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;#include &lt;asm/page.h&gt;<o:p></o:p></p>

<p class=3DMsoNormal>+#include &lt;asm/mm_track.h&gt;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;static inline int =
is_hugepage_only_range(struct
mm_struct *mm,<o:p></o:p></p>

<p class=3DMsoNormal>@@ -39,12 +40,14 @@ static inline void
hugetlb_free_pgd_range(struct mmu_gather *tlb,<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;static inline void set_huge_pte_at(struct =
mm_struct
*mm, unsigned long addr,<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp; pte_t *ptep, pte_t pte)<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;{<o:p></o:p></p>

<p =
class=3DMsoNormal>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
mm_track_pmd((pmd_t *)ptep);<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
set_pte_at(mm, addr, ptep, pte);<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;}<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;static inline pte_t =
huge_ptep_get_and_clear(struct
mm_struct *mm,<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp; unsigned long addr, pte_t *ptep)<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;{<o:p></o:p></p>

<p =
class=3DMsoNormal>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
mm_track_pmd((pmd_t *)ptep);<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
return ptep_get_and_clear(mm, addr, ptep);<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;}<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>diff --git a/arch/x86/include/asm/pgtable-2level.h
b/arch/x86/include/asm/pgtable-2level.h<o:p></o:p></p>

<p class=3DMsoNormal>index 98391db..a59deb5 100644<o:p></o:p></p>

<p class=3DMsoNormal>--- =
a/arch/x86/include/asm/pgtable-2level.h<o:p></o:p></p>

<p class=3DMsoNormal>+++ =
b/arch/x86/include/asm/pgtable-2level.h<o:p></o:p></p>

<p class=3DMsoNormal>@@ -13,11 +13,13 @@<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp; */<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;static inline void native_set_pte(pte_t *ptep =
, pte_t
pte)<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;{<o:p></o:p></p>

<p =
class=3DMsoNormal>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
mm_track_pte(ptep);<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
*ptep =3D pte;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;}<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;static inline void native_set_pmd(pmd_t =
*pmdp, pmd_t
pmd)<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;{<o:p></o:p></p>

<p =
class=3DMsoNormal>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
mm_track_pmd(pmdp);<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
*pmdp =3D pmd;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;}<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>@@ -34,12 +36,14 @@ static inline void
native_pmd_clear(pmd_t *pmdp)<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;static inline void native_pte_clear(struct =
mm_struct
*mm,<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp; unsigned long addr, pte_t *xp)<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;{<o:p></o:p></p>

<p =
class=3DMsoNormal>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
mm_track_pte(xp);<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
*xp =3D native_make_pte(0);<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;}<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;#ifdef CONFIG_SMP<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;static inline pte_t =
native_ptep_get_and_clear(pte_t
*xp)<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;{<o:p></o:p></p>

<p =
class=3DMsoNormal>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
mm_track_pte(xp);<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
return __pte(xchg(&amp;xp-&gt;pte_low, 0));<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;}<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;#else<o:p></o:p></p>

<p class=3DMsoNormal>diff --git a/arch/x86/include/asm/pgtable-3level.h
b/arch/x86/include/asm/pgtable-3level.h<o:p></o:p></p>

<p class=3DMsoNormal>index effff47..b75d753 100644<o:p></o:p></p>

<p class=3DMsoNormal>--- =
a/arch/x86/include/asm/pgtable-3level.h<o:p></o:p></p>

<p class=3DMsoNormal>+++ =
b/arch/x86/include/asm/pgtable-3level.h<o:p></o:p></p>

<p class=3DMsoNormal>@@ -26,6 +26,7 @@<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp; */<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;static inline void native_set_pte(pte_t =
*ptep, pte_t
pte)<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;{<o:p></o:p></p>

<p =
class=3DMsoNormal>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
mm_track_pte(ptep);<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ptep-&gt;pte_high =3D pte.pte_high;<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
smp_wmb();<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ptep-&gt;pte_low =3D pte.pte_low;<o:p></o:p></p>

<p class=3DMsoNormal>@@ -33,16 +34,19 @@ static inline void =
native_set_pte(pte_t
*ptep, pte_t pte)<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;static inline void =
native_set_pte_atomic(pte_t *ptep,
pte_t pte)<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;{<o:p></o:p></p>

<p =
class=3DMsoNormal>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
mm_track_pte(ptep);<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
set_64bit((unsigned long long *)(ptep), =
native_pte_val(pte));<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;}<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;static inline void native_set_pmd(pmd_t =
*pmdp, pmd_t
pmd)<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;{<o:p></o:p></p>

<p =
class=3DMsoNormal>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
mm_track_pmd(pmdp);<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
set_64bit((unsigned long long *)(pmdp), =
native_pmd_val(pmd));<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;}<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;static inline void native_set_pud(pud_t =
*pudp, pud_t
pud)<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;{<o:p></o:p></p>

<p =
class=3DMsoNormal>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
mm_track_pud(pudp);<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
set_64bit((unsigned long long *)(pudp), =
native_pud_val(pud));<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;}<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>@@ -54,6 +58,7 @@ static inline void =
native_set_pud(pud_t
*pudp, pud_t pud)<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;static inline void native_pte_clear(struct =
mm_struct
*mm, unsigned long addr,<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp; pte_t *ptep)<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;{<o:p></o:p></p>

<p =
class=3DMsoNormal>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
mm_track_pte(ptep);<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ptep-&gt;pte_low =3D 0;<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
smp_wmb();<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
ptep-&gt;pte_high =3D 0;<o:p></o:p></p>

<p class=3DMsoNormal>@@ -62,6 +67,9 @@ static inline void =
native_pte_clear(struct
mm_struct *mm, unsigned long addr,<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;static inline void native_pmd_clear(pmd_t =
*pmd)<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;{<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
u32 *tmp =3D (u32 *)pmd;<o:p></o:p></p>

<p class=3DMsoNormal>+<o:p></o:p></p>

<p =
class=3DMsoNormal>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
mm_track_pmd(pmd);<o:p></o:p></p>

<p class=3DMsoNormal>+<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
*tmp =3D 0;<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
smp_wmb();<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
*(tmp + 1) =3D 0;<o:p></o:p></p>

<p class=3DMsoNormal>@@ -69,6 +77,7 @@ static inline void =
native_pmd_clear(pmd_t
*pmd)<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;static inline void pud_clear(pud_t =
*pudp)<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;{<o:p></o:p></p>

<p =
class=3DMsoNormal>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
mm_track_pud(pudp);<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
set_pud(pudp, __pud(0));<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
/*<o:p></o:p></p>

<p class=3DMsoNormal>@@ -88,6 +97,8 @@ static inline pte_t =
native_ptep_get_and_clear(pte_t
*ptep)<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;{<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
pte_t res;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p =
class=3DMsoNormal>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
mm_track_pte(ptep);<o:p></o:p></p>

<p class=3DMsoNormal>+<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
/* xchg acts as a barrier before the setting of the high bits =
*/<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
res.pte_low =3D xchg(&amp;ptep-&gt;pte_low, 0);<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
res.pte_high =3D ptep-&gt;pte_high;<o:p></o:p></p>

<p class=3DMsoNormal>diff --git a/arch/x86/include/asm/pgtable.h
b/arch/x86/include/asm/pgtable.h<o:p></o:p></p>

<p class=3DMsoNormal>index 18601c8..30bb916 100644<o:p></o:p></p>

<p class=3DMsoNormal>--- a/arch/x86/include/asm/pgtable.h<o:p></o:p></p>

<p class=3DMsoNormal>+++ b/arch/x86/include/asm/pgtable.h<o:p></o:p></p>

<p class=3DMsoNormal>@@ -89,7 +89,7 @@ extern struct mm_struct
*pgd_page_get_mm(struct page *page);<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp; */<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;static inline int pte_dirty(pte_t =
pte)<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;{<o:p></o:p></p>

<p =
class=3DMsoNormal>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
return pte_flags(pte) &amp; _PAGE_DIRTY;<o:p></o:p></p>

<p =
class=3DMsoNormal>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
return pte_flags(pte) &amp; (_PAGE_DIRTY | =
_PAGE_SOFTDIRTY);<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;}<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;static inline int pte_young(pte_t =
pte)<o:p></o:p></p>

<p class=3DMsoNormal>@@ -183,7 +183,7 @@ static inline pte_t
pte_clear_flags(pte_t pte, pteval_t clear)<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;static inline pte_t pte_mkclean(pte_t =
pte)<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;{<o:p></o:p></p>

<p =
class=3DMsoNormal>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
return pte_clear_flags(pte, _PAGE_DIRTY);<o:p></o:p></p>

<p =
class=3DMsoNormal>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
return pte_clear_flags(pte, (_PAGE_DIRTY | =
_PAGE_SOFTDIRTY));<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;}<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;static inline pte_t pte_mkold(pte_t =
pte)<o:p></o:p></p>

<p class=3DMsoNormal>diff --git a/arch/x86/include/asm/pgtable_32.h
b/arch/x86/include/asm/pgtable_32.h<o:p></o:p></p>

<p class=3DMsoNormal>index 0c92113..78415fb 100644<o:p></o:p></p>

<p class=3DMsoNormal>--- =
a/arch/x86/include/asm/pgtable_32.h<o:p></o:p></p>

<p class=3DMsoNormal>+++ =
b/arch/x86/include/asm/pgtable_32.h<o:p></o:p></p>

<p class=3DMsoNormal>@@ -21,6 +21,7 @@<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;#include =
&lt;linux/bitops.h&gt;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;#include &lt;linux/list.h&gt;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;#include =
&lt;linux/spinlock.h&gt;<o:p></o:p></p>

<p class=3DMsoNormal>+#include &lt;asm/mm_track.h&gt;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;struct mm_struct;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;struct vm_area_struct;<o:p></o:p></p>

<p class=3DMsoNormal>diff --git a/arch/x86/include/asm/pgtable_64.h
b/arch/x86/include/asm/pgtable_64.h<o:p></o:p></p>

<p class=3DMsoNormal>index 975f709..0848e9e 100644<o:p></o:p></p>

<p class=3DMsoNormal>--- =
a/arch/x86/include/asm/pgtable_64.h<o:p></o:p></p>

<p class=3DMsoNormal>+++ =
b/arch/x86/include/asm/pgtable_64.h<o:p></o:p></p>

<p class=3DMsoNormal>@@ -13,6 +13,7 @@<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;#include =
&lt;asm/processor.h&gt;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;#include =
&lt;linux/bitops.h&gt;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;#include =
&lt;linux/threads.h&gt;<o:p></o:p></p>

<p class=3DMsoNormal>+#include &lt;asm/mm_track.h&gt;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;extern pud_t =
level3_kernel_pgt[512];<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;extern pud_t =
level3_ident_pgt[512];<o:p></o:p></p>

<p class=3DMsoNormal>@@ -46,11 +47,13 @@ void set_pte_vaddr_pud(pud_t =
*pud_page,
unsigned long vaddr, pte_t new_pte);<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;static inline void native_pte_clear(struct =
mm_struct
*mm, unsigned long addr,<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;&nbsp;&nbsp; pte_t *ptep)<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;{<o:p></o:p></p>

<p =
class=3DMsoNormal>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
mm_track_pte(ptep);<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
*ptep =3D native_make_pte(0);<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;}<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;static inline void native_set_pte(pte_t =
*ptep, pte_t
pte)<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;{<o:p></o:p></p>

<p =
class=3DMsoNormal>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
mm_track_pte(ptep);<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
*ptep =3D pte;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;}<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>@@ -61,6 +64,7 @@ static inline void
native_set_pte_atomic(pte_t *ptep, pte_t pte)<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;static inline void native_set_pmd(pmd_t =
*pmdp, pmd_t
pmd)<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;{<o:p></o:p></p>

<p =
class=3DMsoNormal>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
mm_track_pmd(pmdp);<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
*pmdp =3D pmd;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;}<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>@@ -71,6 +75,7 @@ static inline void =
native_pmd_clear(pmd_t
*pmd)<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;static inline pte_t =
native_ptep_get_and_clear(pte_t
*xp)<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;{<o:p></o:p></p>

<p =
class=3DMsoNormal>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
mm_track_pte(xp);<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;#ifdef CONFIG_SMP<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
return native_make_pte(xchg(&amp;xp-&gt;pte, 0));<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;#else<o:p></o:p></p>

<p class=3DMsoNormal>@@ -97,6 +102,7 @@ static inline pmd_t
native_pmdp_get_and_clear(pmd_t *xp)<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;static inline void native_set_pud(pud_t =
*pudp, pud_t
pud)<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;{<o:p></o:p></p>

<p =
class=3DMsoNormal>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
mm_track_pud(pudp);<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
*pudp =3D pud;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;}<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>@@ -107,6 +113,7 @@ static inline void
native_pud_clear(pud_t *pud)<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;static inline void native_set_pgd(pgd_t =
*pgdp, pgd_t
pgd)<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;{<o:p></o:p></p>

<p =
class=3DMsoNormal>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
mm_track_pgd(pgdp);<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
*pgdp =3D pgd;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;}<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>diff --git a/arch/x86/include/asm/pgtable_types.h
b/arch/x86/include/asm/pgtable_types.h<o:p></o:p></p>

<p class=3DMsoNormal>index d56187c..7f366d0 100644<o:p></o:p></p>

<p class=3DMsoNormal>--- =
a/arch/x86/include/asm/pgtable_types.h<o:p></o:p></p>

<p class=3DMsoNormal>+++ =
b/arch/x86/include/asm/pgtable_types.h<o:p></o:p></p>

<p class=3DMsoNormal>@@ -23,6 +23,7 @@<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;#define =
_PAGE_BIT_SPECIAL&nbsp;&nbsp;&nbsp;&nbsp;
_PAGE_BIT_UNUSED1<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;#define _PAGE_BIT_CPA_TEST&nbsp; =
_PAGE_BIT_UNUSED1<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;#define _PAGE_BIT_SPLITTING _PAGE_BIT_UNUSED1 =
/* only
valid on a PSE pmd */<o:p></o:p></p>

<p class=3DMsoNormal>+#define
_PAGE_BIT_SOFTDIRTY&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
_PAGE_BIT_HIDDEN<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;#define
_PAGE_BIT_NX&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
63&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /* No execute: only valid after =
cpuid
check */<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;/* If _PAGE_BIT_PRESENT is clear, we use =
these: */<o:p></o:p></p>

<p class=3DMsoNormal>@@ -47,6 +48,7 @@<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;#define =
_PAGE_SPECIAL&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;
(_AT(pteval_t, 1) &lt;&lt; _PAGE_BIT_SPECIAL)<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;#define
_PAGE_CPA_TEST&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
(_AT(pteval_t, 1) &lt;&lt; _PAGE_BIT_CPA_TEST)<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;#define
_PAGE_SPLITTING&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
(_AT(pteval_t, 1) &lt;&lt; _PAGE_BIT_SPLITTING)<o:p></o:p></p>

<p class=3DMsoNormal>+#define =
_PAGE_SOFTDIRTY&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
(_AT(pteval_t, 1) &lt;&lt; _PAGE_BIT_SOFTDIRTY)<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;#define =
__HAVE_ARCH_PTE_SPECIAL<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;#ifdef CONFIG_KMEMCHECK<o:p></o:p></p>

<p class=3DMsoNormal>@@ -71,7 +73,8 @@<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;/* Set of bits not changed in pte_modify =
*/<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;#define
_PAGE_CHG_MASK&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (PTE_PFN_MASK | =
_PAGE_PCD |
_PAGE_PWT |
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;
\<o:p></o:p></p>

<p =
class=3DMsoNormal>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
_PAGE_SPECIAL | _PAGE_ACCESSED | _PAGE_DIRTY)<o:p></o:p></p>

<p =
class=3DMsoNormal>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
_PAGE_SPECIAL | _PAGE_ACCESSED | _PAGE_DIRTY |&nbsp;&nbsp; =
\<o:p></o:p></p>

<p =
class=3DMsoNormal>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
_PAGE_SOFTDIRTY)<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;#define _HPAGE_CHG_MASK (_PAGE_CHG_MASK | =
_PAGE_PSE)<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;#define _PAGE_CACHE_MASK&nbsp; (_PAGE_PCD | =
_PAGE_PWT)<o:p></o:p></p>

<p class=3DMsoNormal>diff --git a/arch/x86/mm/Makefile =
b/arch/x86/mm/Makefile<o:p></o:p></p>

<p class=3DMsoNormal>index 3e608ed..a416317 100644<o:p></o:p></p>

<p class=3DMsoNormal>--- a/arch/x86/mm/Makefile<o:p></o:p></p>

<p class=3DMsoNormal>+++ b/arch/x86/mm/Makefile<o:p></o:p></p>

<p class=3DMsoNormal>@@ -30,3 +30,5 @@ =
obj-$(CONFIG_NUMA_EMU)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
+=3D numa_emulation.o<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;obj-$(CONFIG_HAVE_MEMBLOCK)&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
+=3D memblock.o<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;obj-$(CONFIG_MEMTEST)&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
+=3D memtest.o<o:p></o:p></p>

<p class=3DMsoNormal>+<o:p></o:p></p>

<p class=3DMsoNormal>+obj-$(CONFIG_TRACK_DIRTY_PAGES)&nbsp; +=3D =
track.o<o:p></o:p></p>

<p class=3DMsoNormal>diff --git a/mm/huge_memory.c =
b/mm/huge_memory.c<o:p></o:p></p>

<p class=3DMsoNormal>index 83326ad..b94aad6 100644<o:p></o:p></p>

<p class=3DMsoNormal>--- a/mm/huge_memory.c<o:p></o:p></p>

<p class=3DMsoNormal>+++ b/mm/huge_memory.c<o:p></o:p></p>

<p class=3DMsoNormal>@@ -795,7 +795,7 @@ static int
do_huge_pmd_wp_page_fallback(struct mm_struct *mm,<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
unsigned long haddr)<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;{<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
pgtable_t pgtable;<o:p></o:p></p>

<p =
class=3DMsoNormal>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
pmd_t _pmd;<o:p></o:p></p>

<p =
class=3DMsoNormal>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
pmd_t _pmd =3D {0};<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
int ret =3D 0, i;<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
struct page **pages;<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;<o:p></o:p></p>

<p class=3DMsoNormal>@@ -1265,7 +1265,7 @@ static int =
__split_huge_page_map(struct
page *page,<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
&nbsp;unsigned long address)<o:p></o:p></p>

<p class=3DMsoNormal>&nbsp;{<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
struct mm_struct *mm =3D vma-&gt;vm_mm;<o:p></o:p></p>

<p =
class=3DMsoNormal>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
pmd_t *pmd, _pmd;<o:p></o:p></p>

<p =
class=3DMsoNormal>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;
pmd_t *pmd, _pmd =3D {0};<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
int ret =3D 0, i;<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
pgtable_t pgtable;<o:p></o:p></p>

<p =
class=3DMsoNormal>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
unsigned long haddr;<o:p></o:p></p>

</div>

</body>

</html>

------_=_NextPart_001_01CC2551.752AE221--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
