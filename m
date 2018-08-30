Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id A20556B509D
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 05:22:10 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id w194-v6so6960259oiw.5
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 02:22:10 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s184-v6si4169929oif.386.2018.08.30.02.22.09
        for <linux-mm@kvack.org>;
        Thu, 30 Aug 2018 02:22:09 -0700 (PDT)
Date: Thu, 30 Aug 2018 10:22:20 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: mmotm 2018-08-23-17-26 uploaded
Message-ID: <20180830092219.GA5352@arm.com>
References: <20180824002731.XMNCl%akpm@linux-foundation.org>
 <049c3fa9-f888-6a2d-413b-872992b269f9@gmail.com>
 <20180829162213.fa1c7c54c801a036e64bacd2@linux-foundation.org>
 <7ae81ca1-46ca-af47-8260-c52736aa4453@gmail.com>
 <cf4acbb6-2815-56e2-829c-4e4c3a549e21@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cf4acbb6-2815-56e2-829c-4e4c3a549e21@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, broonie@kernel.org, mhocko@suse.cz, sfr@canb.auug.org.au, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, linux-arm-kernel@lists.infradead.org

On Thu, Aug 30, 2018 at 02:26:51PM +0800, Jia He wrote:
> On 8/30/2018 9:00 AM, Jia He Wrote:
> > On 8/30/2018 7:22 AM, Andrew Morton Wrote:
> >> On Tue, 28 Aug 2018 12:20:46 +0800 Jia He <hejianet@gmail.com> wrote:
> >>> FYI,I watched a lockdep warning based on your mmotm master branch[1]
> >>
> >> Thanks.  We'll need help from ARM peeps on this please.
> >>
> >>> [    6.692731] ------------[ cut here ]------------
> >>> [    6.696391] DEBUG_LOCKS_WARN_ON(!current->hardirqs_enabled)

[...]

> >>> I thought the root cause might be at [2] which seems not in your branch yet.
> >>>
> >>> [1] http://git.cmpxchg.org/cgit.cgi/linux-mmotm.git
> >>> [2]
> >>> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit?id=efd112
> >>
> >> I agree, that doesn't look like the culprit.  But something may well
> >> have gone wrong in "the recent conversion of the syscall entry/exit
> >> code to C".
> > Sorry for my unclearly previously description.
> > 1. no such lockdep warning in latest mainline kernel git tree.
> > 2. there is a 100% producible warning based on your latest mmotm tree
> > 3. after applying the commit efd112 based on your mmotm tree, the warning
> > disappearred
> > 
> > I will do some further digging to answer your question if no other experts' help
> > 
> 1. in el0_svc->el0_svc_common, without commit efd112
> 		local_daif_mask();   //disable the irq and trace irq off
> 		flags = current_thread_info()->flags;
> 		if (!has_syscall_work(flags))
> 			------------    //1
> 			return;
> If el0_svc_common enters the logic at line 1, the irq is disabled and
> current->hardirqs_enabled is 0.
> 
> 2. then it goes to el0_da
> in el0_da, it enables the irq without changing current->hardirqs_enabled to 1
> 
> 3. goes to el0_da->do_mem_abort->... the lockdep warning happens
> 
> The commit efd112 fixes it by invoking trace_hardirqs_off at line 1.
> It closes the inconsistency window.

Right, we fixed this last month in commit efd112353bf7 ("arm64: svc: Ensure
hardirq tracing is updated before return"). Is there anything more you need
from us on the Arm side?

Will
