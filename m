Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 83E0F6B0037
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 08:13:13 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id z2so2447014wiv.0
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 05:13:12 -0800 (PST)
Received: from mail-ee0-x230.google.com (mail-ee0-x230.google.com [2a00:1450:4013:c00::230])
        by mx.google.com with ESMTPS id a1si2158570wix.38.2013.12.12.05.13.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Dec 2013 05:13:12 -0800 (PST)
Received: by mail-ee0-f48.google.com with SMTP id e49so220155eek.21
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 05:13:12 -0800 (PST)
Date: Thu, 12 Dec 2013 14:13:09 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 2/3] x86: mm: Change tlb_flushall_shift for IvyBridge
Message-ID: <20131212131309.GD5806@gmail.com>
References: <1386849309-22584-1-git-send-email-mgorman@suse.de>
 <1386849309-22584-3-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386849309-22584-3-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Alex Shi <alex.shi@linaro.org>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>


* Mel Gorman <mgorman@suse.de> wrote:

> There was a large performance regression that was bisected to commit 611ae8e3
> (x86/tlb: enable tlb flush range support for x86). This patch simply changes
> the default balance point between a local and global flush for IvyBridge.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  arch/x86/kernel/cpu/intel.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/arch/x86/kernel/cpu/intel.c b/arch/x86/kernel/cpu/intel.c
> index dc1ec0d..2d93753 100644
> --- a/arch/x86/kernel/cpu/intel.c
> +++ b/arch/x86/kernel/cpu/intel.c
> @@ -627,7 +627,7 @@ static void intel_tlb_flushall_shift_set(struct cpuinfo_x86 *c)
>  		tlb_flushall_shift = 5;
>  		break;
>  	case 0x63a: /* Ivybridge */
> -		tlb_flushall_shift = 1;
> +		tlb_flushall_shift = 2;
>  		break;

I'd not be surprised if other CPU models showed similar weaknesses 
under ebizzy as well.

I don't particularly like the tuning aspect of the whole feature: the 
tunings are model specific and they seem to come out of thin air, 
without explicit measurements visible.

In particular the first commit that added this optimization:

 commit c4211f42d3e66875298a5e26a75109878c80f15b
 Date:   Thu Jun 28 09:02:19 2012 +0800

    x86/tlb: add tlb_flushall_shift for specific CPU

already had these magic tunings, with no explanation about what kind 
of measurement was done to back up those tunings.

I don't think this is acceptable and until this is cleared up I think 
we might be better off turning off this feature altogether, or making 
a constant, very low tuning point.

The original code came via:

  611ae8e3f520 x86/tlb: enable tlb flush range support for x86

which references a couple of benchmarks, in particular a 
micro-benchmark:

  My micro benchmark 'mummap' http://lkml.org/lkml/2012/5/17/59
  show that the random memory access on other CPU has 0~50% speed up
  on a 2P * 4cores * HT NHM EP while do 'munmap'.

if the tunings were done with the micro-benchmark then I think they 
are bogus, because AFAICS it does not measure the adversarial case of 
the optimization.

So I'd say at minimum we need to remove the per model tunings, and 
need to use very conservative defaults, to make sure we don't slow 
down reasonable workloads.

( In theory madvise() could give us information about the usage 
  pattern of the vma - but in practice madvise() is rarely used and I 
  doubt ebizzy or other real-world apps are using it, so it's 
  meaningless. )

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
