Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 925AF6B0031
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 09:11:51 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id x12so476343wgg.4
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 06:11:50 -0800 (PST)
Received: from mail-ea0-x22f.google.com (mail-ea0-x22f.google.com [2a00:1450:4013:c01::22f])
        by mx.google.com with ESMTPS id yx3si10351151wjc.17.2013.12.12.06.11.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Dec 2013 06:11:50 -0800 (PST)
Received: by mail-ea0-f175.google.com with SMTP id z10so263724ead.20
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 06:11:50 -0800 (PST)
Date: Thu, 12 Dec 2013 15:11:47 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 2/3] x86: mm: Change tlb_flushall_shift for IvyBridge
Message-ID: <20131212141147.GB17059@gmail.com>
References: <1386849309-22584-1-git-send-email-mgorman@suse.de>
 <1386849309-22584-3-git-send-email-mgorman@suse.de>
 <20131212131309.GD5806@gmail.com>
 <52A9BC3A.7010602@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52A9BC3A.7010602@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Shi <alex.shi@linaro.org>
Cc: Mel Gorman <mgorman@suse.de>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>


* Alex Shi <alex.shi@linaro.org> wrote:

> On 12/12/2013 09:13 PM, Ingo Molnar wrote:
> > 
> > * Mel Gorman <mgorman@suse.de> wrote:
> > 
> >> There was a large performance regression that was bisected to commit 611ae8e3
> >> (x86/tlb: enable tlb flush range support for x86). This patch simply changes
> >> the default balance point between a local and global flush for IvyBridge.
> >>
> >> Signed-off-by: Mel Gorman <mgorman@suse.de>
> >> ---
> >>  arch/x86/kernel/cpu/intel.c | 2 +-
> >>  1 file changed, 1 insertion(+), 1 deletion(-)
> >>
> >> diff --git a/arch/x86/kernel/cpu/intel.c b/arch/x86/kernel/cpu/intel.c
> >> index dc1ec0d..2d93753 100644
> >> --- a/arch/x86/kernel/cpu/intel.c
> >> +++ b/arch/x86/kernel/cpu/intel.c
> >> @@ -627,7 +627,7 @@ static void intel_tlb_flushall_shift_set(struct cpuinfo_x86 *c)
> >>  		tlb_flushall_shift = 5;
> >>  		break;
> >>  	case 0x63a: /* Ivybridge */
> >> -		tlb_flushall_shift = 1;
> >> +		tlb_flushall_shift = 2;
> >>  		break;
> > 
> > I'd not be surprised if other CPU models showed similar weaknesses 
> > under ebizzy as well.
> > 
> > I don't particularly like the tuning aspect of the whole feature: the 
> > tunings are model specific and they seem to come out of thin air, 
> > without explicit measurements visible.
> > 
> > In particular the first commit that added this optimization:
> > 
> >  commit c4211f42d3e66875298a5e26a75109878c80f15b
> >  Date:   Thu Jun 28 09:02:19 2012 +0800
> > 
> >     x86/tlb: add tlb_flushall_shift for specific CPU
> > 
> > already had these magic tunings, with no explanation about what kind 
> > of measurement was done to back up those tunings.
> > 
> > I don't think this is acceptable and until this is cleared up I think 
> > we might be better off turning off this feature altogether, or making 
> > a constant, very low tuning point.
> > 
> > The original code came via:
> > 
> >   611ae8e3f520 x86/tlb: enable tlb flush range support for x86
> > 
> > which references a couple of benchmarks, in particular a 
> > micro-benchmark:
> > 
> >   My micro benchmark 'mummap' http://lkml.org/lkml/2012/5/17/59
> >   show that the random memory access on other CPU has 0~50% speed up
> >   on a 2P * 4cores * HT NHM EP while do 'munmap'.
> > 
> > if the tunings were done with the micro-benchmark then I think they 
> > are bogus, because AFAICS it does not measure the adversarial case of 
> > the optimization.

You have not replied to this concern of mine: if my concern is valid 
then that invalidates much of the current tunings.

> > So I'd say at minimum we need to remove the per model tunings, and 
> > need to use very conservative defaults, to make sure we don't slow 
> > down reasonable workloads.
> 
> I also hate to depends on mysterious hardware differentiation. But 
> there do have some changes in tlb/cache part on different Intel 
> CPU.(Guess HPA know this more). And the different shift value get 
> from testing not from air. :)

As far as I could see from the changelogs and the code itself the 
various tunings came from nowhere.

So I don't see my concerns addressed. My inclination would be to start 
with something like Mel's known-good tuning value below, we know that 
ebizzy does not regress with that setting. Any more aggressive tuning 
needs to be backed up with ebizzy-alike adversarial workload 
performance numbers.

Thanks,

	Ingo

(Patch totally untested.)

=============>
diff --git a/arch/x86/kernel/cpu/intel.c b/arch/x86/kernel/cpu/intel.c
index dc1ec0d..c98385d 100644
--- a/arch/x86/kernel/cpu/intel.c
+++ b/arch/x86/kernel/cpu/intel.c
@@ -614,23 +614,8 @@ static void intel_tlb_flushall_shift_set(struct cpuinfo_x86 *c)
 	case 0x61d: /* six-core 45 nm xeon "Dunnington" */
 		tlb_flushall_shift = -1;
 		break;
-	case 0x61a: /* 45 nm nehalem, "Bloomfield" */
-	case 0x61e: /* 45 nm nehalem, "Lynnfield" */
-	case 0x625: /* 32 nm nehalem, "Clarkdale" */
-	case 0x62c: /* 32 nm nehalem, "Gulftown" */
-	case 0x62e: /* 45 nm nehalem-ex, "Beckton" */
-	case 0x62f: /* 32 nm Xeon E7 */
-		tlb_flushall_shift = 6;
-		break;
-	case 0x62a: /* SandyBridge */
-	case 0x62d: /* SandyBridge, "Romely-EP" */
-		tlb_flushall_shift = 5;
-		break;
-	case 0x63a: /* Ivybridge */
-		tlb_flushall_shift = 1;
-		break;
 	default:
-		tlb_flushall_shift = 6;
+		tlb_flushall_shift = 2;
 	}
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
