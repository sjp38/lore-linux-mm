Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id EA6F26B0154
	for <linux-mm@kvack.org>; Wed,  8 May 2013 12:40:35 -0400 (EDT)
Date: Wed, 8 May 2013 17:40:19 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [RFC PATCH v2 08/11] ARM64: mm: Swap PTE_FILE and PTE_PROT_NONE
 bits.
Message-ID: <20130508164018.GF20820@mudshark.cambridge.arm.com>
References: <1368006763-30774-1-git-send-email-steve.capper@linaro.org>
 <1368006763-30774-9-git-send-email-steve.capper@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1368006763-30774-9-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Michal Hocko <mhocko@suse.cz>, Ken Chen <kenchen@google.com>, Mel Gorman <mgorman@suse.de>, Catalin Marinas <Catalin.Marinas@arm.com>, "patches@linaro.org" <patches@linaro.org>

On Wed, May 08, 2013 at 10:52:40AM +0100, Steve Capper wrote:
> Under ARM64, PTEs can be broadly categorised as follows:
>    - Present and valid: Bit #0 is set. The PTE is valid and memory
>      access to the region may fault.
> 
>    - Present and invalid: Bit #0 is clear and bit #1 is set.
>      Represents present memory with PROT_NONE protection. The PTE
>      is an invalid entry, and the user fault handler will raise a
>      SIGSEGV.
> 
>    - Not present (file): Bits #0 and #1 are clear, bit #2 is set.
>      Memory represented has been paged out. The PTE is an invalid
>      entry, and the fault handler will try and re-populate the
>      memory where necessary.
> 
> Huge PTEs are block descriptors that have bit #1 clear. If we wish
> to represent PROT_NONE huge PTEs we then run into a problem as
> there is no way to distinguish between regular and huge PTEs if we
> set bit #1.
> 
> As huge PTEs are always present, the meaning of bits #1 and #2 can
> be swapped for invalid PTEs. This patch swaps the PTE_FILE and
> PTE_PROT_NONE constants, allowing us to represent PROT_NONE huge
> PTEs.
> 
> Signed-off-by: Steve Capper <steve.capper@linaro.org>
> ---
>  arch/arm64/include/asm/pgtable.h | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
> index b1a1b59..e245260 100644
> --- a/arch/arm64/include/asm/pgtable.h
> +++ b/arch/arm64/include/asm/pgtable.h
> @@ -25,8 +25,8 @@
>   * Software defined PTE bits definition.
>   */
>  #define PTE_VALID		(_AT(pteval_t, 1) << 0)
> -#define PTE_PROT_NONE		(_AT(pteval_t, 1) << 1)	/* only when !PTE_VALID */
> -#define PTE_FILE		(_AT(pteval_t, 1) << 2)	/* only when !pte_present() */
> +#define PTE_FILE		(_AT(pteval_t, 1) << 1)	/* only when !pte_present() */
> +#define PTE_PROT_NONE		(_AT(pteval_t, 1) << 2)	/* only when !PTE_VALID */
>  #define PTE_DIRTY		(_AT(pteval_t, 1) << 55)
>  #define PTE_SPECIAL		(_AT(pteval_t, 1) << 56)
>  
> @@ -306,8 +306,8 @@ extern pgd_t idmap_pg_dir[PTRS_PER_PGD];
>  
>  /*
>   * Encode and decode a file entry:
> - *	bits 0-1:	present (must be zero)
> - *	bit  2:		PTE_FILE
> + *	bits 0 & 2:	present (must be zero)
> + *	bit  1:		PTE_FILE
>   *	bits 3-63:	file offset / PAGE_SIZE
>   */
>  #define pte_file(pte)		(pte_val(pte) & PTE_FILE)

Can you update the comment describing swp entries too please? I *think* the
__SWP_* defines can remain untouched, but the comment is now wrong.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
