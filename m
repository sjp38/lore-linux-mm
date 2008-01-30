Date: Wed, 30 Jan 2008 10:11:24 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [patch 2/6] mmu_notifier: Callbacks to invalidate address
	ranges
Message-ID: <20080130161123.GS26420@sgi.com>
References: <20080128202840.974253868@sgi.com> <20080128202923.849058104@sgi.com> <20080129162004.GL7233@v2.random> <Pine.LNX.4.64.0801291153520.25300@schroedinger.engr.sgi.com> <20080129211759.GV7233@v2.random> <Pine.LNX.4.64.0801291327330.26649@schroedinger.engr.sgi.com> <20080129220212.GX7233@v2.random> <Pine.LNX.4.64.0801291407380.27104@schroedinger.engr.sgi.com> <20080130000039.GA7233@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080130000039.GA7233@v2.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>, Christoph Lameter <clameter@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

> Robin, if you don't mind, could you please post or upload somewhere
> your GPLv2 code that registers itself in Christoph's V2 notifiers? Or
> is it top secret? I wouldn't mind to have a look so I can better
> understand what's the exact reason you're sleeping besides attempting
> GFP_KERNEL allocations. Thanks!

Dean is still actively working on updating the xpmem patch posted
here a few months ago reworked for the mmu_notifiers.  I am sure
we can give you a early look, but it is in a really rough state.

http://marc.info/?l=linux-mm&w=2&r=1&s=xpmem&q=t

The need to sleep comes from the fact that these PFNs are sent to other
hosts on the same NUMA fabric which have direct access to the pages
and then placed into remote process's page tables and then filled into
their TLBs.  Our only means of communicating the recall is async.

I think I need to straighten this discussion out in my head a little bit.
Am I correct in assuming Andrea's original patch set did not have any SMP
race conditions for KVM?  If so, then we need to start looking at how to
implement Christoph's and my changes in a safe fashion.  Andrea, I agree
complete that our introduction of the range callouts have introduced
SMP races.

The three issues we need to simultaneously solve is revoking the remote
page table/tlb information while still in a sleepable context and not
having the remote faulters become out of sync with the granting process.
Currently, I don't see a way to do that cleanly with a single callout.

Could we consider doing a range-based recall and lock callout before
clearing the processes page tables/TLBs, then use the _page or _range
callouts from Andrea's patch to clear the mappings,  finally make a
range-based unlock callout.  The mmu_notifier user would usually use ops
for either the recall+lock/unlock family of callouts or the _page/_range
family of callouts.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
