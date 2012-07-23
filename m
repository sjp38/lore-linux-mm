Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 5F2406B0044
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 13:34:41 -0400 (EDT)
Message-ID: <1343064870.26034.23.camel@twins>
Subject: [RFC] page-table walkers vs memory order
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 23 Jul 2012 19:34:30 +0200
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, paulmck <paulmck@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>, linux-kernel <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>


While staring at mm/huge_memory.c I found a very under-commented
smp_wmb() in __split_huge_page_map(). It turns out that its copied from
__{pte,pmd,pud}_alloc() but forgot the useful comment (or a reference
thereto).

Now, afaict we're not good, as per that comment. Paul has since
convinced some of us that compiler writers are pure evil and out to get
us.

Therefore we should do what rcu_dereference() does and use
ACCESS_ONCE()/barrier() followed smp_read_barrier_depends() every time
we dereference a page-table pointer.


In particular it looks like things like
mm/memcontrol.c:mem_cgroup_count_precharge(), which use
walk_page_range() under down_read(&mm->mmap_sem) and can thus be
concurrent with __{pte,pmd,pud}_alloc() from faults (and possibly
itself) are quite broken on Alpha and subtly broken for those of us with
'creative' compilers.

Should I go do a more extensive audit of page-table walkers or are we
happy with the status quo?

---
 arch/x86/mm/gup.c |    6 +++---
 mm/pagewalk.c     |   24 ++++++++++++++++++++++++
 2 files changed, 27 insertions(+), 3 deletions(-)

diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
index dd74e46..4958fb1 100644
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -150,7 +150,7 @@ static int gup_pmd_range(pud_t pud, unsigned long addr,=
 unsigned long end,
=20
 	pmdp =3D pmd_offset(&pud, addr);
 	do {
-		pmd_t pmd =3D *pmdp;
+		pmd_t pmd =3D ACCESS_ONCE(*pmdp);
=20
 		next =3D pmd_addr_end(addr, end);
 		/*
@@ -220,7 +220,7 @@ static int gup_pud_range(pgd_t pgd, unsigned long addr,=
 unsigned long end,
=20
 	pudp =3D pud_offset(&pgd, addr);
 	do {
-		pud_t pud =3D *pudp;
+		pud_t pud =3D ACCESS_ONCE(*pudp);
=20
 		next =3D pud_addr_end(addr, end);
 		if (pud_none(pud))
@@ -280,7 +280,7 @@ int __get_user_pages_fast(unsigned long start, int nr_p=
ages, int write,
 	local_irq_save(flags);
 	pgdp =3D pgd_offset(mm, addr);
 	do {
-		pgd_t pgd =3D *pgdp;
+		pgd_t pgd =3D ACCESS_ONCE(*pgdp);
=20
 		next =3D pgd_addr_end(addr, end);
 		if (pgd_none(pgd))
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index 6c118d0..2ba2a74 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -10,6 +10,14 @@ static int walk_pte_range(pmd_t *pmd, unsigned long addr=
, unsigned long end,
 	int err =3D 0;
=20
 	pte =3D pte_offset_map(pmd, addr);
+	/*
+	 * Pairs with the smp_wmb() in __{pte,pmd,pud}_alloc() and
+	 * __split_huge_page_map(). Ideally we'd use ACCESS_ONCE() on the
+	 * actual dereference of p[gum]d, but that's hidden deep within the
+	 * bowels of {pte,pmd,pud}_offset.
+	 */
+	barrier();
+	smp_read_barrier_depends();
 	for (;;) {
 		err =3D walk->pte_entry(pte, addr, addr + PAGE_SIZE, walk);
 		if (err)
@@ -32,6 +40,14 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr=
, unsigned long end,
 	int err =3D 0;
=20
 	pmd =3D pmd_offset(pud, addr);
+	/*
+	 * Pairs with the smp_wmb() in __{pte,pmd,pud}_alloc() and
+	 * __split_huge_page_map(). Ideally we'd use ACCESS_ONCE() on the
+	 * actual dereference of p[gum]d, but that's hidden deep within the
+	 * bowels of {pte,pmd,pud}_offset.
+	 */
+	barrier();
+	smp_read_barrier_depends();
 	do {
 again:
 		next =3D pmd_addr_end(addr, end);
@@ -77,6 +93,14 @@ static int walk_pud_range(pgd_t *pgd, unsigned long addr=
, unsigned long end,
 	int err =3D 0;
=20
 	pud =3D pud_offset(pgd, addr);
+	/*
+	 * Pairs with the smp_wmb() in __{pte,pmd,pud}_alloc() and
+	 * __split_huge_page_map(). Ideally we'd use ACCESS_ONCE() on the
+	 * actual dereference of p[gum]d, but that's hidden deep within the
+	 * bowels of {pte,pmd,pud}_offset.
+	 */
+	barrier();
+	smp_read_barrier_depends();
 	do {
 		next =3D pud_addr_end(addr, end);
 		if (pud_none_or_clear_bad(pud)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
