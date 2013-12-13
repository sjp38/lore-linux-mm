Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 7ED2D6B0031
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 20:02:18 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id q10so1459887pdj.22
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 17:02:18 -0800 (PST)
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
        by mx.google.com with ESMTPS id bc2si169016pad.71.2013.12.12.17.02.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Dec 2013 17:02:17 -0800 (PST)
Received: by mail-pb0-f46.google.com with SMTP id md12so1519245pbc.19
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 17:02:16 -0800 (PST)
Message-ID: <52AA5C92.7030207@linaro.org>
Date: Fri, 13 Dec 2013 09:02:10 +0800
From: Alex Shi <alex.shi@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] x86: mm: Change tlb_flushall_shift for IvyBridge
References: <1386849309-22584-1-git-send-email-mgorman@suse.de> <1386849309-22584-3-git-send-email-mgorman@suse.de> <20131212131309.GD5806@gmail.com> <52A9BC3A.7010602@linaro.org> <20131212141147.GB17059@gmail.com>
In-Reply-To: <20131212141147.GB17059@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Fengguang Wu <fengguang.wu@intel.com>

On 12/12/2013 10:11 PM, Ingo Molnar wrote:
> 
> * Alex Shi <alex.shi@linaro.org> wrote:
> 
>> On 12/12/2013 09:13 PM, Ingo Molnar wrote:
>>>
>>> * Mel Gorman <mgorman@suse.de> wrote:
>>>
>>>> There was a large performance regression that was bisected to commit 611ae8e3
>>>> (x86/tlb: enable tlb flush range support for x86). This patch simply changes
>>>> the default balance point between a local and global flush for IvyBridge.
>>>>
>>>> Signed-off-by: Mel Gorman <mgorman@suse.de>
>>>> ---
>>>>  arch/x86/kernel/cpu/intel.c | 2 +-
>>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>>
>>>> diff --git a/arch/x86/kernel/cpu/intel.c b/arch/x86/kernel/cpu/intel.c
>>>> index dc1ec0d..2d93753 100644
>>>> --- a/arch/x86/kernel/cpu/intel.c
>>>> +++ b/arch/x86/kernel/cpu/intel.c
>>>> @@ -627,7 +627,7 @@ static void intel_tlb_flushall_shift_set(struct cpuinfo_x86 *c)
>>>>  		tlb_flushall_shift = 5;
>>>>  		break;
>>>>  	case 0x63a: /* Ivybridge */
>>>> -		tlb_flushall_shift = 1;
>>>> +		tlb_flushall_shift = 2;
>>>>  		break;
>>>
>>> I'd not be surprised if other CPU models showed similar weaknesses 
>>> under ebizzy as well.
>>>
>>> I don't particularly like the tuning aspect of the whole feature: the 
>>> tunings are model specific and they seem to come out of thin air, 
>>> without explicit measurements visible.
>>>
>>> In particular the first commit that added this optimization:
>>>
>>>  commit c4211f42d3e66875298a5e26a75109878c80f15b
>>>  Date:   Thu Jun 28 09:02:19 2012 +0800
>>>
>>>     x86/tlb: add tlb_flushall_shift for specific CPU
>>>
>>> already had these magic tunings, with no explanation about what kind 
>>> of measurement was done to back up those tunings.
>>>
>>> I don't think this is acceptable and until this is cleared up I think 
>>> we might be better off turning off this feature altogether, or making 
>>> a constant, very low tuning point.
>>>
>>> The original code came via:
>>>
>>>   611ae8e3f520 x86/tlb: enable tlb flush range support for x86
>>>
>>> which references a couple of benchmarks, in particular a 
>>> micro-benchmark:
>>>
>>>   My micro benchmark 'mummap' http://lkml.org/lkml/2012/5/17/59
>>>   show that the random memory access on other CPU has 0~50% speed up
>>>   on a 2P * 4cores * HT NHM EP while do 'munmap'.
>>>
>>> if the tunings were done with the micro-benchmark then I think they 
>>> are bogus, because AFAICS it does not measure the adversarial case of 
>>> the optimization.
> 
> You have not replied to this concern of mine: if my concern is valid 
> then that invalidates much of the current tunings.

The benefit from pretend flush range is not unconditional, since invlpg
also cost time. And different CPU has different invlpg/flush_all
execution time. That is part of reason for different flushall_shift
value, another reason, if my memory right, is multiple invlpg execution
time is not strict linearity. Can't confirm this, Sorry.

In theory the benefit is there, but most of benchmark can not show the
performance improvement, because most of benchmark don't do flush_range
frequency. So, need a micro benchmark to discover this if the benefit
really exists. And the micro benchmark also can find regressions if use
too much invlpg. The balance point is the flushall_shift value. Maybe
the flushall_shift value are bit aggressive or maybe testing scenario
doesn't cover everything. So I don't mind to take more conservative value.

BTW, at that time, I tested every benchmark in hands, no regression found.
> 
>>> So I'd say at minimum we need to remove the per model tunings, and 
>>> need to use very conservative defaults, to make sure we don't slow 
>>> down reasonable workloads.
>>
>> I also hate to depends on mysterious hardware differentiation. But 
>> there do have some changes in tlb/cache part on different Intel 
>> CPU.(Guess HPA know this more). And the different shift value get 
>> from testing not from air. :)
> 
> As far as I could see from the changelogs and the code itself the 
> various tunings came from nowhere.
> 
> So I don't see my concerns addressed. My inclination would be to start 
> with something like Mel's known-good tuning value below, we know that 
> ebizzy does not regress with that setting. Any more aggressive tuning 
> needs to be backed up with ebizzy-alike adversarial workload 
> performance numbers.

Testing can tell us more.

CC to fengguang for the following patch.
> 
> Thanks,
> 
> 	Ingo
> 
> (Patch totally untested.)
> 
> =============>
> diff --git a/arch/x86/kernel/cpu/intel.c b/arch/x86/kernel/cpu/intel.c
> index dc1ec0d..c98385d 100644
> --- a/arch/x86/kernel/cpu/intel.c
> +++ b/arch/x86/kernel/cpu/intel.c
> @@ -614,23 +614,8 @@ static void intel_tlb_flushall_shift_set(struct cpuinfo_x86 *c)
>  	case 0x61d: /* six-core 45 nm xeon "Dunnington" */
>  		tlb_flushall_shift = -1;
>  		break;
> -	case 0x61a: /* 45 nm nehalem, "Bloomfield" */
> -	case 0x61e: /* 45 nm nehalem, "Lynnfield" */
> -	case 0x625: /* 32 nm nehalem, "Clarkdale" */
> -	case 0x62c: /* 32 nm nehalem, "Gulftown" */
> -	case 0x62e: /* 45 nm nehalem-ex, "Beckton" */
> -	case 0x62f: /* 32 nm Xeon E7 */
> -		tlb_flushall_shift = 6;
> -		break;
> -	case 0x62a: /* SandyBridge */
> -	case 0x62d: /* SandyBridge, "Romely-EP" */
> -		tlb_flushall_shift = 5;
> -		break;
> -	case 0x63a: /* Ivybridge */
> -		tlb_flushall_shift = 1;
> -		break;
>  	default:
> -		tlb_flushall_shift = 6;
> +		tlb_flushall_shift = 2;
>  	}
>  }
>  
> 


-- 
Thanks
    Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
