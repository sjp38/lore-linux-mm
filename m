Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id DD53A6B031F
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 14:21:04 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id k13-v6so14653227ite.5
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 11:21:04 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id w65-v6si6056383iod.280.2018.07.09.11.21.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 11:21:04 -0700 (PDT)
Date: Mon, 9 Jul 2018 14:20:55 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCHv4 13/18] x86/mm: Allow to disable MKTME after enumeration
Message-ID: <20180709182055.GI6873@char.US.ORACLE.com>
References: <20180626142245.82850-1-kirill.shutemov@linux.intel.com>
 <20180626142245.82850-14-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180626142245.82850-14-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jun 26, 2018 at 05:22:40PM +0300, Kirill A. Shutemov wrote:
> The new helper mktme_disable() allows to disable MKTME even if it's
> enumerated successfully. MKTME initialization may fail and this
> functionality allows system to boot regardless of the failure.
> 
> MKTME needs per-KeyID direct mapping. It requires a lot more virtual
> address space which may be a problem in 4-level paging mode. If the
> system has more physical memory than we can handle with MKTME.

.. then what should happen?
> The feature allows to fail MKTME, but boot the system successfully.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/x86/include/asm/mktme.h | 2 ++
>  arch/x86/kernel/cpu/intel.c  | 5 +----
>  arch/x86/mm/mktme.c          | 9 +++++++++
>  3 files changed, 12 insertions(+), 4 deletions(-)
> 
> diff --git a/arch/x86/include/asm/mktme.h b/arch/x86/include/asm/mktme.h
> index 44409b8bbaca..ebbee6a0c495 100644
> --- a/arch/x86/include/asm/mktme.h
> +++ b/arch/x86/include/asm/mktme.h
> @@ -6,6 +6,8 @@
>  
>  struct vm_area_struct;
>  
> +void mktme_disable(void);
> +
>  #ifdef CONFIG_X86_INTEL_MKTME
>  extern phys_addr_t mktme_keyid_mask;
>  extern int mktme_nr_keyids;
> diff --git a/arch/x86/kernel/cpu/intel.c b/arch/x86/kernel/cpu/intel.c
> index efc9e9fc47d4..75e3b2602b4a 100644
> --- a/arch/x86/kernel/cpu/intel.c
> +++ b/arch/x86/kernel/cpu/intel.c
> @@ -591,10 +591,7 @@ static void detect_tme(struct cpuinfo_x86 *c)
>  		 * Maybe needed if there's inconsistent configuation
>  		 * between CPUs.
>  		 */
> -		physical_mask = (1ULL << __PHYSICAL_MASK_SHIFT) - 1;
> -		mktme_keyid_mask = 0;
> -		mktme_keyid_shift = 0;
> -		mktme_nr_keyids = 0;
> +		mktme_disable();
>  	}
>  #endif
>  
> diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
> index 1194496633ce..bb6210dbcf0e 100644
> --- a/arch/x86/mm/mktme.c
> +++ b/arch/x86/mm/mktme.c
> @@ -13,6 +13,15 @@ static inline bool mktme_enabled(void)
>  	return static_branch_unlikely(&mktme_enabled_key);
>  }
>  
> +void mktme_disable(void)
> +{
> +	physical_mask = (1ULL << __PHYSICAL_MASK_SHIFT) - 1;
> +	mktme_keyid_mask = 0;
> +	mktme_keyid_shift = 0;
> +	mktme_nr_keyids = 0;
> +	static_branch_disable(&mktme_enabled_key);
> +}
> +
>  int page_keyid(const struct page *page)
>  {
>  	if (!mktme_enabled())
> -- 
> 2.18.0
> 
