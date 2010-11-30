Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D90EF6B0071
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 14:19:47 -0500 (EST)
Subject: Re: [thisops uV3 07/18] highmem: Use this_cpu_xx_return()
 operations
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1291144408.2904.232.camel@edumazet-laptop>
References: <20101130190707.457099608@linux.com>
	 <20101130190845.216537525@linux.com>
	 <1291144408.2904.232.camel@edumazet-laptop>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 30 Nov 2010 20:19:42 +0100
Message-ID: <1291144782.32004.1146.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, Catalin Marinas <catalin.marinas@arm.com>, linux-kernel@vger.kernel.org, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2010-11-30 at 20:13 +0100, Eric Dumazet wrote:
> Le mardi 30 novembre 2010 =C3=A0 13:07 -0600, Christoph Lameter a =C3=A9c=
rit :
> > pi=C3=A8ce jointe document texte brut (this_cpu_highmem)
> > Use this_cpu operations to optimize access primitives for highmem.
> >=20
> > The main effect is the avoidance of address calculations through the
> > use of a segment prefix.
> >=20
> > Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > Cc: Catalin Marinas <catalin.marinas@arm.com>
> > Signed-off-by: Christoph Lameter <cl@linux.com>
> >=20
> > ---
> >  include/linux/highmem.h |    7 ++++---
> >  1 file changed, 4 insertions(+), 3 deletions(-)
> >=20
> > Index: linux-2.6/include/linux/highmem.h
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > --- linux-2.6.orig/include/linux/highmem.h	2010-11-22 14:43:40.00000000=
0 -0600
> > +++ linux-2.6/include/linux/highmem.h	2010-11-22 14:45:02.000000000 -06=
00
> > @@ -81,7 +81,8 @@ DECLARE_PER_CPU(int, __kmap_atomic_idx);
> > =20
> >  static inline int kmap_atomic_idx_push(void)
> >  {
> > -	int idx =3D __get_cpu_var(__kmap_atomic_idx)++;
> > +	int idx =3D __this_cpu_inc_return(__kmap_atomic_idx) - 1;
> > +
> >  #ifdef CONFIG_DEBUG_HIGHMEM
> >  	WARN_ON_ONCE(in_irq() && !irqs_disabled());
> >  	BUG_ON(idx > KM_TYPE_NR);
> > @@ -91,12 +92,12 @@ static inline int kmap_atomic_idx_push(v
> > =20
> >  static inline int kmap_atomic_idx(void)
> >  {
> > -	return __get_cpu_var(__kmap_atomic_idx) - 1;
> > +	return __this_cpu_read(__kmap_atomic_idx) - 1;
> >  }
> > =20
> >  static inline int kmap_atomic_idx_pop(void)
> >  {
> > -	int idx =3D --__get_cpu_var(__kmap_atomic_idx);
> > +	int idx =3D __this_cpu_dec_return(__kmap_atomic_idx);
>=20
> __this_cpu_dec_return() is only needed if CONFIG_DEBUG_HIGHMEM
>=20
> >  #ifdef CONFIG_DEBUG_HIGHMEM
> >  	BUG_ON(idx < 0);
> >  #endif
> >=20
>=20
> You could change kmap_atomic_idx_pop() to return void, and use
> __this_cpu_dec(__kmap_atomic_idx)

You can do the void change unconditionally, the debug code already uses
kmap_atomic_idx() because of:


---
commit 20273941f2129aa5a432796d98a276ed73d60782
Author: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date:   Wed Oct 27 15:32:58 2010 -0700

    mm: fix race in kunmap_atomic()
   =20
    Christoph reported a nice splat which illustrated a race in the new sta=
ck
    based kmap_atomic implementation.
   =20
    The problem is that we pop our stack slot before we're completely done
    resetting its state -- in particular clearing the PTE (sometimes that's
    CONFIG_DEBUG_HIGHMEM).  If an interrupt happens before we actually clea=
r
    the PTE used for the last slot, that interrupt can reuse the slot in a
    dirty state, which triggers a BUG in kmap_atomic().
   =20
    Fix this by introducing kmap_atomic_idx() which reports the current slo=
t
    index without actually releasing it and use that to find the PTE and de=
lay
    the _pop() until after we're completely done.
   =20
    Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
    Reported-by: Christoph Hellwig <hch@infradead.org>
    Acked-by: Rik van Riel <riel@redhat.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

diff --git a/arch/arm/mm/highmem.c b/arch/arm/mm/highmem.c
index c00f119..c435fd9 100644
--- a/arch/arm/mm/highmem.c
+++ b/arch/arm/mm/highmem.c
@@ -89,7 +89,7 @@ void __kunmap_atomic(void *kvaddr)
 	int idx, type;
=20
 	if (kvaddr >=3D (void *)FIXADDR_START) {
-		type =3D kmap_atomic_idx_pop();
+		type =3D kmap_atomic_idx();
 		idx =3D type + KM_TYPE_NR * smp_processor_id();
=20
 		if (cache_is_vivt())
@@ -101,6 +101,7 @@ void __kunmap_atomic(void *kvaddr)
 #else
 		(void) idx;  /* to kill a warning */
 #endif
+		kmap_atomic_idx_pop();
 	} else if (vaddr >=3D PKMAP_ADDR(0) && vaddr < PKMAP_ADDR(LAST_PKMAP)) {
 		/* this address was obtained through kmap_high_get() */
 		kunmap_high(pte_page(pkmap_page_table[PKMAP_NR(vaddr)]));
diff --git a/arch/frv/mm/highmem.c b/arch/frv/mm/highmem.c
index 61088dc..fd7fcd4 100644
--- a/arch/frv/mm/highmem.c
+++ b/arch/frv/mm/highmem.c
@@ -68,7 +68,7 @@ EXPORT_SYMBOL(__kmap_atomic);
=20
 void __kunmap_atomic(void *kvaddr)
 {
-	int type =3D kmap_atomic_idx_pop();
+	int type =3D kmap_atomic_idx();
 	switch (type) {
 	case 0:		__kunmap_atomic_primary(4, 6);	break;
 	case 1:		__kunmap_atomic_primary(5, 7);	break;
@@ -83,6 +83,7 @@ void __kunmap_atomic(void *kvaddr)
 	default:
 		BUG();
 	}
+	kmap_atomic_idx_pop();
 	pagefault_enable();
 }
 EXPORT_SYMBOL(__kunmap_atomic);
diff --git a/arch/mips/mm/highmem.c b/arch/mips/mm/highmem.c
index 1e69b1f..3634c7e 100644
--- a/arch/mips/mm/highmem.c
+++ b/arch/mips/mm/highmem.c
@@ -74,7 +74,7 @@ void __kunmap_atomic(void *kvaddr)
 		return;
 	}
=20
-	type =3D kmap_atomic_idx_pop();
+	type =3D kmap_atomic_idx();
 #ifdef CONFIG_DEBUG_HIGHMEM
 	{
 		int idx =3D type + KM_TYPE_NR * smp_processor_id();
@@ -89,6 +89,7 @@ void __kunmap_atomic(void *kvaddr)
 		local_flush_tlb_one(vaddr);
 	}
 #endif
+	kmap_atomic_idx_pop();
 	pagefault_enable();
 }
 EXPORT_SYMBOL(__kunmap_atomic);
diff --git a/arch/mn10300/include/asm/highmem.h b/arch/mn10300/include/asm/=
highmem.h
index f577ba2..e2155e6 100644
--- a/arch/mn10300/include/asm/highmem.h
+++ b/arch/mn10300/include/asm/highmem.h
@@ -101,7 +101,7 @@ static inline void __kunmap_atomic(unsigned long vaddr)
 		return;
 	}
=20
-	type =3D kmap_atomic_idx_pop();
+	type =3D kmap_atomic_idx();
=20
 #if HIGHMEM_DEBUG
 	{
@@ -119,6 +119,8 @@ static inline void __kunmap_atomic(unsigned long vaddr)
 		__flush_tlb_one(vaddr);
 	}
 #endif
+
+	kmap_atomic_idx_pop();
 	pagefault_enable();
 }
 #endif /* __KERNEL__ */
diff --git a/arch/powerpc/mm/highmem.c b/arch/powerpc/mm/highmem.c
index b0848b4..e7450bd 100644
--- a/arch/powerpc/mm/highmem.c
+++ b/arch/powerpc/mm/highmem.c
@@ -62,7 +62,7 @@ void __kunmap_atomic(void *kvaddr)
 		return;
 	}
=20
-	type =3D kmap_atomic_idx_pop();
+	type =3D kmap_atomic_idx();
=20
 #ifdef CONFIG_DEBUG_HIGHMEM
 	{
@@ -79,6 +79,8 @@ void __kunmap_atomic(void *kvaddr)
 		local_flush_tlb_page(NULL, vaddr);
 	}
 #endif
+
+	kmap_atomic_idx_pop();
 	pagefault_enable();
 }
 EXPORT_SYMBOL(__kunmap_atomic);
diff --git a/arch/sparc/mm/highmem.c b/arch/sparc/mm/highmem.c
index 5e50c09..4730eac 100644
--- a/arch/sparc/mm/highmem.c
+++ b/arch/sparc/mm/highmem.c
@@ -75,7 +75,7 @@ void __kunmap_atomic(void *kvaddr)
 		return;
 	}
=20
-	type =3D kmap_atomic_idx_pop();
+	type =3D kmap_atomic_idx();
=20
 #ifdef CONFIG_DEBUG_HIGHMEM
 	{
@@ -104,6 +104,8 @@ void __kunmap_atomic(void *kvaddr)
 #endif
 	}
 #endif
+
+	kmap_atomic_idx_pop();
 	pagefault_enable();
 }
 EXPORT_SYMBOL(__kunmap_atomic);
diff --git a/arch/tile/mm/highmem.c b/arch/tile/mm/highmem.c
index 8ef6595..abb5733 100644
--- a/arch/tile/mm/highmem.c
+++ b/arch/tile/mm/highmem.c
@@ -241,7 +241,7 @@ void __kunmap_atomic(void *kvaddr)
 		pte_t pteval =3D *pte;
 		int idx, type;
=20
-		type =3D kmap_atomic_idx_pop();
+		type =3D kmap_atomic_idx();
 		idx =3D type + KM_TYPE_NR*smp_processor_id();
=20
 		/*
@@ -252,6 +252,7 @@ void __kunmap_atomic(void *kvaddr)
 		BUG_ON(!pte_present(pteval) && !pte_migrating(pteval));
 		kmap_atomic_unregister(pte_page(pteval), vaddr);
 		kpte_clear_flush(pte, vaddr);
+		kmap_atomic_idx_pop();
 	} else {
 		/* Must be a lowmem page */
 		BUG_ON(vaddr < PAGE_OFFSET);
diff --git a/arch/x86/mm/highmem_32.c b/arch/x86/mm/highmem_32.c
index d723e36..b499626 100644
--- a/arch/x86/mm/highmem_32.c
+++ b/arch/x86/mm/highmem_32.c
@@ -74,7 +74,7 @@ void __kunmap_atomic(void *kvaddr)
 	    vaddr <=3D __fix_to_virt(FIX_KMAP_BEGIN)) {
 		int idx, type;
=20
-		type =3D kmap_atomic_idx_pop();
+		type =3D kmap_atomic_idx();
 		idx =3D type + KM_TYPE_NR * smp_processor_id();
=20
 #ifdef CONFIG_DEBUG_HIGHMEM
@@ -87,6 +87,7 @@ void __kunmap_atomic(void *kvaddr)
 		 * attributes or becomes a protected page in a hypervisor.
 		 */
 		kpte_clear_flush(kmap_pte-idx, vaddr);
+		kmap_atomic_idx_pop();
 	}
 #ifdef CONFIG_DEBUG_HIGHMEM
 	else {
diff --git a/arch/x86/mm/iomap_32.c b/arch/x86/mm/iomap_32.c
index 75a3d7f..7b179b4 100644
--- a/arch/x86/mm/iomap_32.c
+++ b/arch/x86/mm/iomap_32.c
@@ -98,7 +98,7 @@ iounmap_atomic(void __iomem *kvaddr)
 	    vaddr <=3D __fix_to_virt(FIX_KMAP_BEGIN)) {
 		int idx, type;
=20
-		type =3D kmap_atomic_idx_pop();
+		type =3D kmap_atomic_idx();
 		idx =3D type + KM_TYPE_NR * smp_processor_id();
=20
 #ifdef CONFIG_DEBUG_HIGHMEM
@@ -111,6 +111,7 @@ iounmap_atomic(void __iomem *kvaddr)
 		 * attributes or becomes a protected page in a hypervisor.
 		 */
 		kpte_clear_flush(kmap_pte-idx, vaddr);
+		kmap_atomic_idx_pop();
 	}
=20
 	pagefault_enable();
diff --git a/include/linux/highmem.h b/include/linux/highmem.h
index 102f76b..e913819 100644
--- a/include/linux/highmem.h
+++ b/include/linux/highmem.h
@@ -88,6 +88,11 @@ static inline int kmap_atomic_idx_push(void)
 	return idx;
 }
=20
+static inline int kmap_atomic_idx(void)
+{
+	return __get_cpu_var(__kmap_atomic_idx) - 1;
+}
+
 static inline int kmap_atomic_idx_pop(void)
 {
 	int idx =3D --__get_cpu_var(__kmap_atomic_idx);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
