Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 713816B0062
	for <linux-mm@kvack.org>; Fri, 20 Dec 2013 07:20:24 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id x12so2432627wgg.16
        for <linux-mm@kvack.org>; Fri, 20 Dec 2013 04:20:23 -0800 (PST)
Received: from mail-ee0-x22a.google.com (mail-ee0-x22a.google.com [2a00:1450:4013:c00::22a])
        by mx.google.com with ESMTPS id um9si3008951wjc.4.2013.12.20.04.20.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 20 Dec 2013 04:20:23 -0800 (PST)
Received: by mail-ee0-f42.google.com with SMTP id e53so1022130eek.29
        for <linux-mm@kvack.org>; Fri, 20 Dec 2013 04:20:23 -0800 (PST)
Date: Fri, 20 Dec 2013 13:20:19 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/4] Fix ebizzy performance regression due to X86 TLB
 range flush v2
Message-ID: <20131220122019.GA24479@gmail.com>
References: <20131216102439.GA21624@gmail.com>
 <20131216125923.GS11295@suse.de>
 <20131216134449.GA3034@gmail.com>
 <20131217092124.GV11295@suse.de>
 <20131217110051.GA27701@gmail.com>
 <20131219142405.GM11295@suse.de>
 <20131219164925.GA29546@gmail.com>
 <20131220111303.GZ11295@suse.de>
 <20131220111818.GA23349@gmail.com>
 <20131220115854.GA11295@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131220115854.GA11295@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Alex Shi <alex.shi@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>


* Mel Gorman <mgorman@suse.de> wrote:

> tlb_flushall_shift == -1	Always use flush all
> tlb_flushall_shift == 1		Aggressively use individual flushes
> tlb_flushall_shift == 6		Conservatively use individual flushes
> 
> IvyBridge was too aggressive using individual flushes and my patch 
> makes it less aggressive.
> 
> Intel's code for this currently looks like
> 
>         switch ((c->x86 << 8) + c->x86_model) {
>         case 0x60f: /* original 65 nm celeron/pentium/core2/xeon, "Merom"/"Conroe" */
>         case 0x616: /* single-core 65 nm celeron/core2solo "Merom-L"/"Conroe-L" */
>         case 0x617: /* current 45 nm celeron/core2/xeon "Penryn"/"Wolfdale" */
>         case 0x61d: /* six-core 45 nm xeon "Dunnington" */
>                 tlb_flushall_shift = -1;
>                 break;
>         case 0x61a: /* 45 nm nehalem, "Bloomfield" */
>         case 0x61e: /* 45 nm nehalem, "Lynnfield" */
>         case 0x625: /* 32 nm nehalem, "Clarkdale" */
>         case 0x62c: /* 32 nm nehalem, "Gulftown" */
>         case 0x62e: /* 45 nm nehalem-ex, "Beckton" */
>         case 0x62f: /* 32 nm Xeon E7 */
>                 tlb_flushall_shift = 6;
>                 break;
>         case 0x62a: /* SandyBridge */
>         case 0x62d: /* SandyBridge, "Romely-EP" */
>                 tlb_flushall_shift = 5;
>                 break;
>         case 0x63a: /* Ivybridge */
>                 tlb_flushall_shift = 2;
>                 break;
>         default:
>                 tlb_flushall_shift = 6;
>         }
> 
> That default shift of "6" is already conservative which is why I 
> don't think we need to change anything there. AMD is slightly more 
> aggressive in their choices but not enough to panic.

Lets face it, the per model tunings are most likely crap: the only 
place where it significantly deviated from '6' was Ivybridge - and 
there it was causing a regression.

With your patch we'll have 6 everywhere, except on SandyBridge where 
it's slightly more agressive at 5 - which is probably noise.

So my argument is that we should use '6' _everywhere_ and do away with 
the pretense that we do per model tunings...

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
