Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 282A26B017F
	for <linux-mm@kvack.org>; Wed,  1 May 2013 07:42:44 -0400 (EDT)
Date: Wed, 1 May 2013 12:42:38 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [RFC PATCH 7/9] ARM64: mm: HugeTLB support.
Message-ID: <20130501114238.GG22796@mudshark.cambridge.arm.com>
References: <1367339448-21727-1-git-send-email-steve.capper@linaro.org>
 <1367339448-21727-8-git-send-email-steve.capper@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1367339448-21727-8-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Michal Hocko <mhocko@suse.cz>, Ken Chen <kenchen@google.com>, Mel Gorman <mgorman@suse.de>, Catalin Marinas <Catalin.Marinas@arm.com>

Hi Steve,

On Tue, Apr 30, 2013 at 05:30:46PM +0100, Steve Capper wrote:
> Add huge page support to ARM64, different huge page sizes are
> supported depending on the size of normal pages:
> 
> PAGE_SIZE is 4K:
>    2MB - (pmds) these can be allocated at any time.
> 1024MB - (puds) usually allocated on bootup with the command line
>          with something like: hugepagesz=1G hugepages=6
> 
> PAGE_SIZE is 64K:
>  512MB - (pmds), usually allocated on bootup via command line.

[...]

> diff --git a/arch/arm64/include/asm/pgtable-hwdef.h b/arch/arm64/include/asm/pgtable-hwdef.h
> index 75fd13d..c3cac68 100644
> --- a/arch/arm64/include/asm/pgtable-hwdef.h
> +++ b/arch/arm64/include/asm/pgtable-hwdef.h
> @@ -53,6 +53,7 @@
>  #define PTE_TYPE_MASK		(_AT(pteval_t, 3) << 0)
>  #define PTE_TYPE_FAULT		(_AT(pteval_t, 0) << 0)
>  #define PTE_TYPE_PAGE		(_AT(pteval_t, 3) << 0)
> +#define PTE_TYPE_HUGEPAGE	(_AT(pmdval_t, 1) << 0)

This breaks PROT_NONE mappings, where you get:

	pte = pte_mkhuge(pte_modify(pte, newprot));

The pte_modify will clear the valid bit and set the prot_none bit (in order
to create a present, faulting entry) but then your pte_mkhuge will come in
and clobber that with a valid block entry.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
