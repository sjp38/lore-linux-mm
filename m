Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id C1B3D6B015A
	for <linux-mm@kvack.org>; Wed,  8 May 2013 12:17:37 -0400 (EDT)
Message-ID: <518A7A9F.9080105@codeaurora.org>
Date: Wed, 08 May 2013 12:17:35 -0400
From: Christopher Covington <cov@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v2 08/11] ARM64: mm: Swap PTE_FILE and PTE_PROT_NONE
 bits.
References: <1368006763-30774-1-git-send-email-steve.capper@linaro.org> <1368006763-30774-9-git-send-email-steve.capper@linaro.org>
In-Reply-To: <1368006763-30774-9-git-send-email-steve.capper@linaro.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org, patches@linaro.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Michal Hocko <mhocko@suse.cz>, Ken Chen <kenchen@google.com>, Mel Gorman <mgorman@suse.de>

Hi Steve,

On 05/08/2013 05:52 AM, Steve Capper wrote:
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

[...]

> diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h

[...]

> @@ -306,8 +306,8 @@ extern pgd_t idmap_pg_dir[PTRS_PER_PGD];
>  
>  /*
>   * Encode and decode a file entry:
> - *	bits 0-1:	present (must be zero)
> - *	bit  2:		PTE_FILE
> + *	bits 0 & 2:	present (must be zero)

Consider using punctuation like "bits 0, 2" here to disambiguate from the
binary and operation.

[...]

Christopher

-- 
Employee of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by the Linux Foundation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
