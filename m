Date: Sat, 26 Jul 2008 05:08:10 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: MMU notifiers review and some proposals
Message-ID: <20080726030810.GA18896@wotan.suse.de>
References: <20080724143949.GB12897@wotan.suse.de> <20080725214552.GB21150@duo.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080725214552.GB21150@duo.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org, steiner@sgi.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 25, 2008 at 11:45:52PM +0200, Andrea Arcangeli wrote:
> Hi Nick,
> 
> On Thu, Jul 24, 2008 at 04:39:49PM +0200, Nick Piggin wrote:
> > I think everybody is hoping to have a workable mmu notifier scheme
> > merged in 2.6.27 (myself included). However I do have some concerns
> 
> Just to be clear, I'm waiting mmu notifiers to showup on Linus's tree
> before commenting this as it was all partly covered in the past
> discussions anyway, so there's nothing really urgent or new here (at
> least for me ;).

Well I just was never completely satisfied with how that turned out.
There was an assertion that invalidate range begin/end were the right
way to go because performance would be too bad using the traditional
mmu gather / range flushing. Now that I actually had the GRU and KVM
code to look at, I must say I would be very surprised if performance
is too bad. Given that, I would have thought the logical way to go
would be to start with the "minimal" type of notifiers I proposed now,
and then get some numbers together to try to support the start/end
scheme.

If there is some real performance numbers or something that I missed,
please let me know.


> It's a tradeoff, you pointed out the positive sides and negative point
> of both approaches, and depending which kind of the trade you're
> interested about, you'll prefer one or the other approach. Your
> preference is the exact opposite of what SGI liked and what we
> liked. But all works for us, and all works for GRU (though -mm is
> faster for the fast path), but only -mm can be easily later extended
> for XPMEM/IB if they ever decide to schedule in the mmu notifier
> methods in the future (which may never happen and it's unrelated to
> the current patches that don't contemplate sleeping at all and it's
> pure luck they can be trivially extended to provide for it).
> 
> As your patch shown the changes are fairly small anyway if we later
> decide to change in 2.6.28-rc, in the meantime current code in -mm was

OK. The significant thing from my POV is that it doesn't need to
introduce the take-all-locks code.


> heavily tested and all code including kvm and gru has been tested only
> with this, and this combined with the fact -mm guarantees the fastest
> fast path, I hope we leave any discussion to the 2.6.28-rc merge
> window, now it's time to go productive finally!

Well everybody knows I would prefer to merge the minimal notifiers now,
and look at more complex things as we get results to see if they are
required (I doubt anybody is going to help me get numbers to justify
going the other way ;)).

I think for the core VM, minimal notifiers are basically trivial, and
their consumers are more peripheral code so I don't think it would go
against merge standards.

Anyway, I just voice my opinion and let Andrew and Linus decide. To be
clear: I have not found any actual bugs in Andrea's -mm patchset, only
some dislikes of the approach.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
