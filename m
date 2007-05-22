Date: Tue, 22 May 2007 18:04:54 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH/RFC] Rework ptep_set_access_flags and fix sun4c
In-Reply-To: <1179815339.32247.799.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0705221738020.22822@blonde.wat.veritas.com>
References: <Pine.LNX.4.61.0705012354290.12808@mtfhpc.demon.co.uk>
 <20070509231937.ea254c26.akpm@linux-foundation.org>
 <1178778583.14928.210.camel@localhost.localdomain>
 <20070510.001234.126579706.davem@davemloft.net>
 <Pine.LNX.4.64.0705142018090.18453@blonde.wat.veritas.com>
 <1179176845.32247.107.camel@localhost.localdomain>
 <1179212184.32247.163.camel@localhost.localdomain>
 <1179757647.6254.235.camel@localhost.localdomain>
 <1179815339.32247.799.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: "Tom \"spot\" Callaway" <tcallawa@redhat.com>, David Miller <davem@davemloft.net>, akpm@linux-foundation.org, mark@mtfhpc.demon.co.uk, linuxppc-dev@ozlabs.org, wli@holomorphy.com, linux-mm@kvack.org, andrea@suse.de, sparclinux@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 22 May 2007, Benjamin Herrenschmidt wrote:

> This patch reworks ptep_set_access_flags() and the callers so that the
> comparison to the old PTE is done inside that function, which then
> returns wether an update_mmu_cache() is needed. That allows fixing
> the sun4c situation where update_mmu_cache() needs to be forced,
> always.
> 
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> ---
> 
> Ok, so that's only compile tested on sparc32 and powerpc 32 bits, boot
> tested on powerpc64 and not tested on others (I could use some help
> testing x86, x86_64 and s390 who also have their own implementations).

Looks pretty good to me.

There was a minor build error in x86 (see below), and ia64 is missing
(again see below).  I've now built and am running this on x86, x86_64
and powerpc64; but I'm very unlikely to be doing anything which
actually tickles these changes, or Andrea's original handle_pte_fault
optimization.

Would the "__changed && __dirty" architectures (x86, x86_64, ia64)
be better off saying __changed = __dirty && pte_same?  I doubt it's
worth bothering about.

You've updated do_wp_page to do "if (ptep_set_access_flags(...",
but not updated set_huge_ptep_writable in the same way: I'd have
thought you'd either leave both alone, or update them both: any
reason for one not the other?  But again, not really an issue.

These changes came about because the sun4c needs to update_mmu_cache
even in the pte_same case: might it also need to flush_tlb_page then?


> --- linux-work.orig/include/asm-generic/pgtable.h	2007-05-22 15:04:45.000000000 +1000
> +++ linux-work/include/asm-generic/pgtable.h	2007-05-22 15:32:21.000000000 +1000
> @@ -27,13 +27,20 @@ do {				  					\
>   * Largely same as above, but only sets the access flags (dirty,
>   * accessed, and writable). Furthermore, we know it always gets set
>   * to a "more permissive" setting, which allows most architectures
> - * to optimize this.
> + * to optimize this. We return wether the PTE actually changed, which

                                  whether

> + * in turn instructs the caller to do things like update__mmu_cache.

                                                     update_mmu_cache.

> + * This used to be done in the caller, but sparc needs minor faults to
> + * force that call on sun4c so we changed this macro slightly
>   */

> --- linux-work.orig/include/asm-i386/pgtable.h	2007-05-22 15:06:17.000000000 +1000
> +++ linux-work/include/asm-i386/pgtable.h	2007-05-22 15:16:11.000000000 +1000
> @@ -285,13 +285,15 @@ static inline pte_t native_local_ptep_ge
>   */
>  #define  __HAVE_ARCH_PTEP_SET_ACCESS_FLAGS
>  #define ptep_set_access_flags(vma, address, ptep, entry, dirty)		\
> -do {									\
> -	if (dirty) {							\
> +({									\
> +	int __changed = !pte_same(*(__ptep), __entry);			\

That just needs to be:

  +	int __changed = !pte_same(*(ptep), entry);			\

> +	if (__changed && dirty) {					\
>  		(ptep)->pte_low = (entry).pte_low;			\
>  		pte_update_defer((vma)->vm_mm, (address), (ptep));	\
>  		flush_tlb_page(vma, address);				\
>  	}								\
> -} while (0)
> +	__changed;							\
> +})

Here's what I think the ia64 hunk would be, unbuilt and untested.

--- linux-work.orig/include/asm-ia64/pgtable.h	2007-05-13 05:41:00.000000000 +0100
+++ linux-work/include/asm-ia64/pgtable.h	2007-05-22 17:33:58.000000000 +0100
@@ -533,16 +533,23 @@ extern void lazy_mmu_prot_update (pte_t 
  * daccess_bit in ivt.S).
  */
 #ifdef CONFIG_SMP
-# define ptep_set_access_flags(__vma, __addr, __ptep, __entry, __safely_writable)	\
-do {											\
-	if (__safely_writable) {							\
-		set_pte(__ptep, __entry);						\
-		flush_tlb_page(__vma, __addr);						\
-	}										\
-} while (0)
+# define ptep_set_access_flags(__vma, __addr, __ptep, __entry, __safely_writable) \
+({									\
+	int __changed = !pte_same(*(__ptep), __entry);			\
+	if (__changed && __safely_writable) {				\
+		set_pte(__ptep, __entry);				\
+		flush_tlb_page(__vma, __addr);				\
+	}								\
+	__changed;							\
+})
 #else
-# define ptep_set_access_flags(__vma, __addr, __ptep, __entry, __safely_writable)	\
-	ptep_establish(__vma, __addr, __ptep, __entry)
+# define ptep_set_access_flags(__vma, __addr, __ptep, __entry, __safely_writable) \
+({									\
+	int __changed = !pte_same(*(__ptep), __entry);			\
+	if (__changed)							\
+		ptep_establish(__vma, __addr, __ptep, __entry);		\
+	__changed;							\
+})
 #endif
 
 #  ifdef CONFIG_VIRTUAL_MEM_MAP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
