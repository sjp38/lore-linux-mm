Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 67A916B006E
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 01:59:26 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id y13so815368pdi.6
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 22:59:26 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id f9si11533217pdp.157.2014.10.21.22.59.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 21 Oct 2014 22:59:25 -0700 (PDT)
Received: by mail-pa0-f44.google.com with SMTP id et14so3035423pad.3
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 22:59:25 -0700 (PDT)
Message-ID: <1413957522.7070.5.camel@debian>
Subject: Re: [PATCH] x86, MCE: support memory error recovery for both UCNA
 and Deferred error in machine_check_poll
From: Chen Yucong <slaoub@gmail.com>
Date: Wed, 22 Oct 2014 13:58:42 +0800
In-Reply-To: <1412921020.3631.7.camel@debian>
References: <1412921020.3631.7.camel@debian>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Andi Kleen <ak@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "linux-edac@vger.kernel.org" <linux-edac@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Tony Luck <tony.luck@gmail.com>

On Fri, 2014-10-10 at 14:03 +0800, Chen Yucong wrote:
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
> +
>  		/*
>  		 * Don't get the IP here because it's unlikely to
>  		 * have anything to do with the actual error location.

Hi Boris,

Do you have any comments on this patch?

thx!
cyc

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
