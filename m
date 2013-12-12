Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 4A0B06B0031
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 08:38:11 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id jt11so533759pbb.14
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 05:38:10 -0800 (PST)
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
        by mx.google.com with ESMTPS id ez5si16568208pab.164.2013.12.12.05.38.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Dec 2013 05:38:09 -0800 (PST)
Received: by mail-pb0-f41.google.com with SMTP id jt11so539532pbb.0
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 05:38:09 -0800 (PST)
Message-ID: <52A9BC3A.7010602@linaro.org>
Date: Thu, 12 Dec 2013 21:38:02 +0800
From: Alex Shi <alex.shi@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] x86: mm: Change tlb_flushall_shift for IvyBridge
References: <1386849309-22584-1-git-send-email-mgorman@suse.de> <1386849309-22584-3-git-send-email-mgorman@suse.de> <20131212131309.GD5806@gmail.com>
In-Reply-To: <20131212131309.GD5806@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>
Cc: H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On 12/12/2013 09:13 PM, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
>> There was a large performance regression that was bisected to commit 611ae8e3
>> (x86/tlb: enable tlb flush range support for x86). This patch simply changes
>> the default balance point between a local and global flush for IvyBridge.
>>
>> Signed-off-by: Mel Gorman <mgorman@suse.de>
>> ---
>>  arch/x86/kernel/cpu/intel.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/arch/x86/kernel/cpu/intel.c b/arch/x86/kernel/cpu/intel.c
>> index dc1ec0d..2d93753 100644
>> --- a/arch/x86/kernel/cpu/intel.c
>> +++ b/arch/x86/kernel/cpu/intel.c
>> @@ -627,7 +627,7 @@ static void intel_tlb_flushall_shift_set(struct cpuinfo_x86 *c)
>>  		tlb_flushall_shift = 5;
>>  		break;
>>  	case 0x63a: /* Ivybridge */
>> -		tlb_flushall_shift = 1;
>> +		tlb_flushall_shift = 2;
>>  		break;
> 
> I'd not be surprised if other CPU models showed similar weaknesses 
> under ebizzy as well.
> 
> I don't particularly like the tuning aspect of the whole feature: the 
> tunings are model specific and they seem to come out of thin air, 
> without explicit measurements visible.
> 
> In particular the first commit that added this optimization:
> 
>  commit c4211f42d3e66875298a5e26a75109878c80f15b
>  Date:   Thu Jun 28 09:02:19 2012 +0800
> 
>     x86/tlb: add tlb_flushall_shift for specific CPU
> 
> already had these magic tunings, with no explanation about what kind 
> of measurement was done to back up those tunings.
> 
> I don't think this is acceptable and until this is cleared up I think 
> we might be better off turning off this feature altogether, or making 
> a constant, very low tuning point.
> 
> The original code came via:
> 
>   611ae8e3f520 x86/tlb: enable tlb flush range support for x86
> 
> which references a couple of benchmarks, in particular a 
> micro-benchmark:
> 
>   My micro benchmark 'mummap' http://lkml.org/lkml/2012/5/17/59
>   show that the random memory access on other CPU has 0~50% speed up
>   on a 2P * 4cores * HT NHM EP while do 'munmap'.
> 
> if the tunings were done with the micro-benchmark then I think they 
> are bogus, because AFAICS it does not measure the adversarial case of 
> the optimization.
> 
> So I'd say at minimum we need to remove the per model tunings, and 
> need to use very conservative defaults, to make sure we don't slow 
> down reasonable workloads.

I also hate to depends on mysterious hardware differentiation. But there
do have some changes in tlb/cache part on different Intel CPU.(Guess HPA
know this more). And the different shift value get from testing not from
air. :)

> 
> ( In theory madvise() could give us information about the usage 
>   pattern of the vma - but in practice madvise() is rarely used and I 
>   doubt ebizzy or other real-world apps are using it, so it's 
>   meaningless. )
> 
> Thanks,
> 
> 	Ingo
> 


-- 
Thanks
    Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
