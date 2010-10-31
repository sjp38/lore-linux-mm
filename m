Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4F5548D005B
	for <linux-mm@kvack.org>; Sun, 31 Oct 2010 16:38:40 -0400 (EDT)
Date: Sun, 31 Oct 2010 21:38:35 +0100 (CET)
From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH/RFC] m68k/sun3: Kill pte_unmap() warnings
Message-ID: <alpine.DEB.2.00.1010312135110.22279@ayla.of.borg>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-7
Content-Transfer-Encoding: QUOTED-PRINTABLE
Sender: owner-linux-mm@kvack.org
To: Sam Creasey <sammy@sammy.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux/m68k <linux-m68k@lists.linux-m68k.org>, Linux Kernel Development <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Which one is preferable?

---------------------------------------------------------------------------=
----
Since commit 31c911329e048b715a1dfeaaf617be9430fd7f4e ("mm: check the argum=
ent
of kunmap on architectures without highmem"), we get lots of warnings like

arch/m68k/kernel/sys_m68k.c:508: warning: passing argument 1 of =A1kunmap=
=A2 from incompatible pointer type

As m68k doesn't support highmem anyway, open code the calls to kmap() and
kunmap() (the latter is a no-op) to kill the warnings.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 arch/m68k/include/asm/sun3_pgtable.h |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/arch/m68k/include/asm/sun3_pgtable.h b/arch/m68k/include/asm/s=
un3_pgtable.h
index cf5fad9..f55aa04 100644
--- a/arch/m68k/include/asm/sun3_pgtable.h
+++ b/arch/m68k/include/asm/sun3_pgtable.h
@@ -217,9 +217,8 @@ static inline pte_t pgoff_to_pte(unsigned off)
 /* Find an entry in the third-level pagetable. */
 #define pte_index(address) ((address >> PAGE_SHIFT) & (PTRS_PER_PTE-1))
 #define pte_offset_kernel(pmd, address) ((pte_t *) __pmd_page(*pmd) + pte_=
index(address))
-/* FIXME: should we bother with kmap() here? */
-#define pte_offset_map(pmd, address) ((pte_t *)kmap(pmd_page(*pmd)) + pte_=
index(address))
-#define pte_unmap(pte) kunmap(pte)
+#define pte_offset_map(pmd, address) ((pte_t *)page_address(pmd_page(*pmd)=
) + pte_index(address))
+#define pte_unmap(pte) do { } while (0)
=20
 /* Macros to (de)construct the fake PTEs representing swap pages. */
 #define __swp_type(x)=09=09((x).val & 0x7F)
--=20
1.7.0.4
---------------------------------------------------------------------------=
----
Since commit 31c911329e048b715a1dfeaaf617be9430fd7f4e ("mm: check the argum=
ent
of kunmap on architectures without highmem"), we get lots of warnings like

arch/m68k/kernel/sys_m68k.c:508: warning: passing argument 1 of =A1kunmap=
=A2 from incompatible pointer type

M68k doesn't support highmem, so kunmap() is a no-op anyway, but replace th=
e
calls to k{,un}map() by calls to k{,un}map_atomic() to kill the warnings.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 arch/m68k/include/asm/sun3_pgtable.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/m68k/include/asm/sun3_pgtable.h b/arch/m68k/include/asm/s=
un3_pgtable.h
index cf5fad9..637dda4 100644
--- a/arch/m68k/include/asm/sun3_pgtable.h
+++ b/arch/m68k/include/asm/sun3_pgtable.h
@@ -218,8 +218,8 @@ static inline pte_t pgoff_to_pte(unsigned off)
 #define pte_index(address) ((address >> PAGE_SHIFT) & (PTRS_PER_PTE-1))
 #define pte_offset_kernel(pmd, address) ((pte_t *) __pmd_page(*pmd) + pte_=
index(address))
 /* FIXME: should we bother with kmap() here? */
-#define pte_offset_map(pmd, address) ((pte_t *)kmap(pmd_page(*pmd)) + pte_=
index(address))
-#define pte_unmap(pte) kunmap(pte)
+#define pte_offset_map(pmd, address) ((pte_t *)kmap_atomic(pmd_page(*pmd))=
 + pte_index(address))
+#define pte_unmap(pte) kunmap_atomic(pte)
=20
 /* Macros to (de)construct the fake PTEs representing swap pages. */
 #define __swp_type(x)=09=09((x).val & 0x7F)
--=20
1.7.0.4

Gr{oetje,eeting}s,

=09=09=09=09=09=09Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k=
=2Eorg

In personal conversations with technical people, I call myself a hacker. Bu=
t
when I'm talking to journalists I just say "programmer" or something like t=
hat.
=09=09=09=09=09=09=09    -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
