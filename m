Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 18DD26B0038
	for <linux-mm@kvack.org>; Wed,  6 May 2015 07:47:11 -0400 (EDT)
Received: by wief7 with SMTP id f7so123379999wie.0
        for <linux-mm@kvack.org>; Wed, 06 May 2015 04:47:10 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id o2si1823460wic.59.2015.05.06.04.47.09
        for <linux-mm@kvack.org>;
        Wed, 06 May 2015 04:47:09 -0700 (PDT)
Date: Wed, 6 May 2015 13:47:05 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v4 4/7] mtrr, x86: Fix MTRR state checks in
 mtrr_type_lookup()
Message-ID: <20150506114705.GD22949@pd.tnic>
References: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
 <1427234921-19737-5-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1427234921-19737-5-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl

On Tue, Mar 24, 2015 at 04:08:38PM -0600, Toshi Kani wrote:
> 'mtrr_state.enabled' contains the FE (fixed MTRRs enabled)
> and E (MTRRs enabled) flags in MSR_MTRRdefType.  Intel SDM,
> section 11.11.2.1, defines these flags as follows:
>  - All MTRRs are disabled when the E flag is clear.
>    The FE flag has no affect when the E flag is clear.
>  - The default type is enabled when the E flag is set.
>  - MTRR variable ranges are enabled when the E flag is set.
>  - MTRR fixed ranges are enabled when both E and FE flags
>    are set.
> 
> MTRR state checks in __mtrr_type_lookup() do not match with
> SDM.  Hence, this patch makes the following changes:
>  - The current code detects MTRRs disabled when both E and
>    FE flags are clear in mtrr_state.enabled.  Fix to detect
>    MTRRs disabled when the E flag is clear.
>  - The current code does not check if the FE bit is set in
>    mtrr_state.enabled when looking into the fixed entries.
>    Fix to check the FE flag.
>  - The current code returns the default type when the E flag
>    is clear in mtrr_state.enabled.  However, the default type
>    is also disabled when the E flag is clear.  Fix to remove
>    the code as this case is handled as MTRR disabled with
>    the 1st change.
> 
> In addition, this patch defines the E and FE flags in
> mtrr_state.enabled as follows.
>  - FE flag: MTRR_STATE_MTRR_FIXED_ENABLED
>  - E  flag: MTRR_STATE_MTRR_ENABLED
> 
> print_mtrr_state() is also updated accordingly.
> 
> Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> ---
>  arch/x86/include/uapi/asm/mtrr.h   |    4 ++++
>  arch/x86/kernel/cpu/mtrr/generic.c |   15 ++++++++-------
>  2 files changed, 12 insertions(+), 7 deletions(-)

You missed a spot in the conversion in
arch/x86/kernel/cpu/mtrr/cleanup.c::x86_get_mtrr_mem_range():

There we have

	if (base < (1<<(20-PAGE_SHIFT)) && mtrr_state.have_fixed &&
	    (mtrr_state.enabled & 1)) {

which should be mtrr_state.enabled & MTRR_STATE_MTRR_FIXED_ENABLED.

> diff --git a/arch/x86/include/uapi/asm/mtrr.h b/arch/x86/include/uapi/asm/mtrr.h
> index d0acb65..66ba88d 100644
> --- a/arch/x86/include/uapi/asm/mtrr.h
> +++ b/arch/x86/include/uapi/asm/mtrr.h
> @@ -88,6 +88,10 @@ struct mtrr_state_type {
>         mtrr_type def_type;
>  };
> 
> +/* Bit fields for enabled in struct mtrr_state_type */
> +#define MTRR_STATE_MTRR_FIXED_ENABLED  0x01
> +#define MTRR_STATE_MTRR_ENABLED                0x02
> +
>  #define MTRRphysBase_MSR(reg) (0x200 + 2 * (reg))
>  #define MTRRphysMask_MSR(reg) (0x200 + 2 * (reg) + 1)

Please add those to arch/x86/include/asm/mtrr.h instead. They have no
place in the uapi header.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
