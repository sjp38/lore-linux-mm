Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f176.google.com (mail-ea0-f176.google.com [209.85.215.176])
	by kanga.kvack.org (Postfix) with ESMTP id E20366B005A
	for <linux-mm@kvack.org>; Fri, 20 Dec 2013 07:00:16 -0500 (EST)
Received: by mail-ea0-f176.google.com with SMTP id h14so995641eaj.21
        for <linux-mm@kvack.org>; Fri, 20 Dec 2013 04:00:16 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s8si8442499eeh.38.2013.12.20.04.00.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 20 Dec 2013 04:00:15 -0800 (PST)
Date: Fri, 20 Dec 2013 12:00:11 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/4] Fix ebizzy performance regression due to X86 TLB
 range flush v2
Message-ID: <20131220115854.GA11295@suse.de>
References: <20131215155539.GM11295@suse.de>
 <20131216102439.GA21624@gmail.com>
 <20131216125923.GS11295@suse.de>
 <20131216134449.GA3034@gmail.com>
 <20131217092124.GV11295@suse.de>
 <20131217110051.GA27701@gmail.com>
 <20131219142405.GM11295@suse.de>
 <20131219164925.GA29546@gmail.com>
 <20131220111303.GZ11295@suse.de>
 <20131220111818.GA23349@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131220111818.GA23349@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Alex Shi <alex.shi@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Fri, Dec 20, 2013 at 12:18:18PM +0100, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > On Thu, Dec 19, 2013 at 05:49:25PM +0100, Ingo Molnar wrote:
> > > 
> > > * Mel Gorman <mgorman@suse.de> wrote:
> > > 
> > > > [...]
> > > > 
> > > > Because we lack data on TLB range flush distributions I think we 
> > > > should still go with the conservative choice for the TLB flush 
> > > > shift. The worst case is really bad here and it's painfully obvious 
> > > > on ebizzy.
> > > 
> > > So I'm obviously much in favor of this - I'd in fact suggest 
> > > making the conservative choice on _all_ CPU models that have 
> > > aggressive TLB range values right now, because frankly the testing 
> > > used to pick those values does not look all that convincing to me.
> > 
> > I think the choices there are already reasonably conservative. I'd 
> > be reluctant to support merging a patch that made a choice on all 
> > CPU models without having access to the machines to run tests on. I 
> > don't see the Intel people volunteering to do the necessary testing.
> 
> So based on this thread I lost confidence in test results on all CPU 
> models but the one you tested.
> 
> I see two workable options right now:
> 
>  - We turn the feature off on all other CPU models, until someone
>    measures and tunes them reliably.
> 

That would mean setting tlb_flushall_shift to -1. I think it's overkill
but it's not really my call.

HPA?

> or
> 
>  - We make all tunings that are more aggressive than yours to match
>    yours. In the future people can measure and argue for more
>    aggressive tunings.
> 

I'm missing something obvious because switching the default to 2 will use
individual page flushes more aggressively which I do not think was your
intent. The basic check is

	if (tlb_flushall_shift == -1)
		flush all

	act_entries = tlb_entries >> tlb_flushall_shift;
	nr_base_pages = range to flush
	if (nr_base_pages > act_entries)
		flush all
	else
		flush individual pages

Full mm flush is the "safe" bet

tlb_flushall_shift == -1	Always use flush all
tlb_flushall_shift == 1		Aggressively use individual flushes
tlb_flushall_shift == 6		Conservatively use individual flushes

IvyBridge was too aggressive using individual flushes and my patch makes
it less aggressive.

Intel's code for this currently looks like

        switch ((c->x86 << 8) + c->x86_model) {
        case 0x60f: /* original 65 nm celeron/pentium/core2/xeon, "Merom"/"Conroe" */
        case 0x616: /* single-core 65 nm celeron/core2solo "Merom-L"/"Conroe-L" */
        case 0x617: /* current 45 nm celeron/core2/xeon "Penryn"/"Wolfdale" */
        case 0x61d: /* six-core 45 nm xeon "Dunnington" */
                tlb_flushall_shift = -1;
                break;
        case 0x61a: /* 45 nm nehalem, "Bloomfield" */
        case 0x61e: /* 45 nm nehalem, "Lynnfield" */
        case 0x625: /* 32 nm nehalem, "Clarkdale" */
        case 0x62c: /* 32 nm nehalem, "Gulftown" */
        case 0x62e: /* 45 nm nehalem-ex, "Beckton" */
        case 0x62f: /* 32 nm Xeon E7 */
                tlb_flushall_shift = 6;
                break;
        case 0x62a: /* SandyBridge */
        case 0x62d: /* SandyBridge, "Romely-EP" */
                tlb_flushall_shift = 5;
                break;
        case 0x63a: /* Ivybridge */
                tlb_flushall_shift = 2;
                break;
        default:
                tlb_flushall_shift = 6;
        }

That default shift of "6" is already conservative which is why I don't
think we need to change anything there. AMD is slightly more aggressive
in their choices but not enough to panic.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
