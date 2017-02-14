From: Michael Neuling <mikey@neuling.org>
Subject: Re: [PATCH 2/2] powerpc/mm/autonuma: Switch ppc64 to its own
 implementeation of saved write
Date: Tue, 14 Feb 2017 14:59:19 +1100
Message-ID: <1487044759.21048.24.camel@neuling.org>
References: <1486609259-6796-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
         <1486609259-6796-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486609259-6796-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, akpm@linux-foundation.org, Rik van Riel <riel@surriel.com>, Mel Gorman <mgorman@techsingularity.net>, paulus@ozlabs.org, benh@kernel.crashing.org
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

On Thu, 2017-02-09 at 08:30 +0530, Aneesh Kumar K.V wrote:
> With this our protnone becomes a present pte with READ/WRITE/EXEC bit cleared.
> By default we also set _PAGE_PRIVILEGED on such pte. This is now used to help
> us identify a protnone pte that as saved write bit. For such pte, we will
> clear
> the _PAGE_PRIVILEGED bit. The pte still remain non-accessible from both user
> and kernel.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>


FWIW I've tested this, so:

Acked-By: Michael Neuling <mikey@neuling.org>

> ---
>  arch/powerpc/include/asm/book3s/64/mmu-hash.h |  3 +++
>  arch/powerpc/include/asm/book3s/64/pgtable.h  | 32 +++++++++++++++++++++++++-
> -
>  2 files changed, 33 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/powerpc/include/asm/book3s/64/mmu-hash.h
> b/arch/powerpc/include/asm/book3s/64/mmu-hash.h
> index 0735d5a8049f..8720a406bbbe 100644
> --- a/arch/powerpc/include/asm/book3s/64/mmu-hash.h
> +++ b/arch/powerpc/include/asm/book3s/64/mmu-hash.h
> @@ -16,6 +16,9 @@
>  #include <asm/page.h>
>  #include <asm/bug.h>
>  
> +#ifndef __ASSEMBLY__
> +#include <linux/mmdebug.h>
> +#endif
>  /*
>   * This is necessary to get the definition of PGTABLE_RANGE which we
>   * need for various slices related matters. Note that this isn't the
> diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h
> b/arch/powerpc/include/asm/book3s/64/pgtable.h
> index e91ada786d48..efff910a84b1 100644
> --- a/arch/powerpc/include/asm/book3s/64/pgtable.h
> +++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
> @@ -443,8 +443,8 @@ static inline pte_t pte_clear_soft_dirty(pte_t pte)
>   */
>  static inline int pte_protnone(pte_t pte)
>  {
> -	return (pte_raw(pte) & cpu_to_be64(_PAGE_PRESENT | _PAGE_PRIVILEGED))
> ==
> -		cpu_to_be64(_PAGE_PRESENT | _PAGE_PRIVILEGED);
> +	return (pte_raw(pte) & cpu_to_be64(_PAGE_PRESENT | _PAGE_RWX)) ==
> +		cpu_to_be64(_PAGE_PRESENT);
>  }
>  #endif /* CONFIG_NUMA_BALANCING */
>  
> @@ -514,6 +514,32 @@ static inline pte_t pte_mkhuge(pte_t pte)
>  	return pte;
>  }
>  
> +#define pte_mk_savedwrite pte_mk_savedwrite
> +static inline pte_t pte_mk_savedwrite(pte_t pte)
> +{
> +	/*
> +	 * Used by Autonuma subsystem to preserve the write bit
> +	 * while marking the pte PROT_NONE. Only allow this
> +	 * on PROT_NONE pte
> +	 */
> +	VM_BUG_ON((pte_raw(pte) & cpu_to_be64(_PAGE_PRESENT | _PAGE_RWX |
> _PAGE_PRIVILEGED)) !=
> +		  cpu_to_be64(_PAGE_PRESENT | _PAGE_PRIVILEGED));
> +	return __pte(pte_val(pte) & ~_PAGE_PRIVILEGED);
> +}
> +
> +#define pte_savedwrite pte_savedwrite
> +static inline bool pte_savedwrite(pte_t pte)
> +{
> +	/*
> +	 * Saved write ptes are prot none ptes that doesn't have
> +	 * privileged bit sit. We mark prot none as one which has
> +	 * present and pviliged bit set and RWX cleared. To mark
> +	 * protnone which used to have _PAGE_WRITE set we clear
> +	 * the privileged bit.
> +	 */
> +	return !(pte_raw(pte) & cpu_to_be64(_PAGE_RWX | _PAGE_PRIVILEGED));
> +}
> +
>  static inline pte_t pte_mkdevmap(pte_t pte)
>  {
>  	return __pte(pte_val(pte) | _PAGE_SPECIAL|_PAGE_DEVMAP);
> @@ -885,6 +911,7 @@ static inline pte_t *pmdp_ptep(pmd_t *pmd)
>  #define pmd_mkclean(pmd)	pte_pmd(pte_mkclean(pmd_pte(pmd)))
>  #define pmd_mkyoung(pmd)	pte_pmd(pte_mkyoung(pmd_pte(pmd)))
>  #define pmd_mkwrite(pmd)	pte_pmd(pte_mkwrite(pmd_pte(pmd)))
> +#define pmd_mk_savedwrite(pmd)	pte_pmd(pte_mk_savedwrite(pmd_pte(pmd))
> )
>  
>  #ifdef CONFIG_HAVE_ARCH_SOFT_DIRTY
>  #define pmd_soft_dirty(pmd)    pte_soft_dirty(pmd_pte(pmd))
> @@ -901,6 +928,7 @@ static inline int pmd_protnone(pmd_t pmd)
>  
>  #define __HAVE_ARCH_PMD_WRITE
>  #define pmd_write(pmd)		pte_write(pmd_pte(pmd))
> +#define pmd_savedwrite(pmd)	pte_savedwrite(pmd_pte(pmd))
>  
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  extern pmd_t pfn_pmd(unsigned long pfn, pgprot_t pgprot);
