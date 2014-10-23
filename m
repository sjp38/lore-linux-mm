Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id 25CCD6B0069
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 06:47:23 -0400 (EDT)
Received: by mail-la0-f46.google.com with SMTP id gi9so595676lab.5
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 03:47:22 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id xu5si1985148lab.64.2014.10.23.03.47.20
        for <linux-mm@kvack.org>;
        Thu, 23 Oct 2014 03:47:20 -0700 (PDT)
Date: Thu, 23 Oct 2014 12:47:17 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH] x86, MCE: support memory error recovery for both UCNA
 and Deferred error in machine_check_poll
Message-ID: <20141023104717.GB4619@pd.tnic>
References: <1412921020.3631.7.camel@debian>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1412921020.3631.7.camel@debian>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Yucong <slaoub@gmail.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "linux-edac@vger.kernel.org" <linux-edac@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Aravind Gopalakrishnan <aravind.gopalakrishnan@amd.com>

On Fri, Oct 10, 2014 at 02:03:40PM +0800, Chen Yucong wrote:
> From: Chen Yucong <slaoub@gmail.com>
> 
> dram_ce_error() stems from Boris's patch set. Thanks!
> Link: http://lkml.org/lkml/2014/7/1/545
> 
> Uncorrected no action required (UCNA) - is a UCR error that is not
> signaled via a machine check exception and, instead, is reported to
> system software as a corrected machine check error. UCNA errors indicate
> that some data in the system is corrupted, but the data has not been
> consumed and the processor state is valid and you may continue execution
> on this processor. UCNA errors require no action from system software
> to continue execution. Note that UCNA errors are supported by the
> processor only when IA32_MCG_CAP[24] (MCG_SER_P) is set.
>                                            -- Intel SDM Volume 3B
> 
> Deferred errors are errors that cannot be corrected by hardware, but
> do not cause an immediate interruption in program flow, loss of data
> integrity, or corruption of processor state. These errors indicate
> that data has been corrupted but not consumed. Hardware writes information
> to the status and address registers in the corresponding bank that
> identifies the source of the error if deferred errors are enabled for
> logging. Deferred errors are not reported via machine check exceptions;
> they can be seen by polling the MCi_STATUS registers.
>                                             -- ADM64 APM Volume 2
> 
> Above two items, both UCNA and Deferred errors belong to detected
> errors, but they can't be corrected by hardware, and this is very
> similar to Software Recoverable Action Optional (SRAO) errors.
> Therefore, we can take some actions that have been used for handling
> SRAO errors to handle UCNA and Deferred errors.
> 
> Signed-off-by: Chen Yucong <slaoub@gmail.com>
> ---
>  arch/x86/include/asm/mce.h       |    4 ++++
>  arch/x86/kernel/cpu/mcheck/mce.c |   39 ++++++++++++++++++++++++++++++++++++++
>  2 files changed, 43 insertions(+)
> 
> diff --git a/arch/x86/include/asm/mce.h b/arch/x86/include/asm/mce.h
> index 958b90f..c9ac7df4 100644
> --- a/arch/x86/include/asm/mce.h
> +++ b/arch/x86/include/asm/mce.h
> @@ -34,6 +34,10 @@
>  #define MCI_STATUS_S	 (1ULL<<56)  /* Signaled machine check */
>  #define MCI_STATUS_AR	 (1ULL<<55)  /* Action required */
>  
> +/* AMD-specific bits */
> +#define MCI_STATUS_DEFERRED     (1ULL<<44)  /* declare an uncorrected error */
> +#define MCI_STATUS_POISON       (1ULL<<43)  /* access poisonous data */
> +
>  /*
>   * Note that the full MCACOD field of IA32_MCi_STATUS MSR is
>   * bits 15:0.  But bit 12 is the 'F' bit, defined for corrected
> diff --git a/arch/x86/kernel/cpu/mcheck/mce.c b/arch/x86/kernel/cpu/mcheck/mce.c
> index 61a9668ce..4030c77 100644
> --- a/arch/x86/kernel/cpu/mcheck/mce.c
> +++ b/arch/x86/kernel/cpu/mcheck/mce.c
> @@ -575,6 +575,35 @@ static void mce_read_aux(struct mce *m, int i)
>  	}
>  }
>  
> +static bool dram_ce_error(struct mce *m)
> +{
> +	struct cpuinfo_x86 *c = &boot_cpu_data;
> +
> +	if (c->x86_vendor == X86_VENDOR_AMD) {
> +		/* ErrCodeExt[20:16] */
> +		u8 xec = (m->status >> 16) & 0x1f;
> +
> +		if (m->status & MCI_STATUS_DEFERRED)
> +			return (xec == 0x0 || xec == 0x8);
> +	} else if (c->x86_vendor == X86_VENDOR_INTEL) {
> +		/*
> +		 * SDM Volume 3B - 15.9.2 Compound Error Codes (Table 15-9)
> +		 *
> +		 * Bit 7 of the MCACOD field of IA32_MCi_STATUS is used for
> +		 * indicating a memory error. But we can't just blindly check
> +		 * bit 7 because if bit 8 is set, then this is a cache error,
> +		 * and if bit 11 is set, then it is a bus/ interconnect error
> +		 * - and either way bit 7 just gives more detail on what
> +		 * cache/bus/interconnect error happened. Note that we can
> +		 * ignore bit 12, as it's the "filter" bit.
> +		 */
> +		if ((m->mcgcap & MCG_SER_P) && (m->status & MCI_STATUS_UC))
> +			return (m->status & 0xef80) == BIT(7);

This is wrong - dram_ce_error is supposed to tell us whether this is a
correctable error, not uncorrectable.

> +	}
> +
> +	return false;
> +}
> +
>  DEFINE_PER_CPU(unsigned, mce_poll_count);
>  
>  /*
> @@ -630,6 +659,16 @@ void machine_check_poll(enum mcp_flags flags, mce_banks_t *b)
>  
>  		if (!(flags & MCP_TIMESTAMP))
>  			m.tsc = 0;
> +
> +		/*
> +		 * In the cases where we don't have a valid address after all,
> +		 * do not add it into the ring buffer.
> +		 */
> +		if (dram_ce_error(&m) && (m.status & MCI_STATUS_ADDRV)) {
> +			mce_ring_add(m.addr >> PAGE_SHIFT);
> +			mce_schedule_work();
> +		}

The general idea of preemptively poisoning pages which contain deferred
errors is fine though.

You need to figure out how exactly you're going to detect such errors.
On AMD it is easy - MCI_STATUS_DEFERRED. The problem there is to find
out which models actually set that bit and what the other bits in
MCi_STATUS are set to. For that we should ask Aravind.

On Intel, SDM says something like this:

"A UNCA error is indicated with UC=1, PCC=0, S=0 and AR=0 in the
IA32_MCi_STATUS register."

I think a proper solution would be to extend the mce_severity mechanism
to handle that and return AO_SEVERITY.

What I would love even more, though, if in conjunction with this someone
(you?) would sit down and actually make that severities[] array readable
because it makes my eyes bleed and my brain twist everytime I look at
it.

Thanks.

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
