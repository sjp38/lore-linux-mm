Date: Wed, 30 Jan 2008 18:04:52 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [patch 2/6] mmu_notifier: Callbacks to invalidate address
	ranges
Message-ID: <20080130170451.GP7233@v2.random>
References: <20080128202840.974253868@sgi.com> <20080128202923.849058104@sgi.com> <20080129162004.GL7233@v2.random> <Pine.LNX.4.64.0801291153520.25300@schroedinger.engr.sgi.com> <20080129211759.GV7233@v2.random> <Pine.LNX.4.64.0801291327330.26649@schroedinger.engr.sgi.com> <20080129220212.GX7233@v2.random> <Pine.LNX.4.64.0801291407380.27104@schroedinger.engr.sgi.com> <20080130000039.GA7233@v2.random> <20080130161123.GS26420@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080130161123.GS26420@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2008 at 10:11:24AM -0600, Robin Holt wrote:
> > Robin, if you don't mind, could you please post or upload somewhere
> > your GPLv2 code that registers itself in Christoph's V2 notifiers? Or
> > is it top secret? I wouldn't mind to have a look so I can better
> > understand what's the exact reason you're sleeping besides attempting
> > GFP_KERNEL allocations. Thanks!
> 
> Dean is still actively working on updating the xpmem patch posted
> here a few months ago reworked for the mmu_notifiers.  I am sure
> we can give you a early look, but it is in a really rough state.
> 
> http://marc.info/?l=linux-mm&w=2&r=1&s=xpmem&q=t
> 
> The need to sleep comes from the fact that these PFNs are sent to other
> hosts on the same NUMA fabric which have direct access to the pages
> and then placed into remote process's page tables and then filled into
> their TLBs.  Our only means of communicating the recall is async.
> 
> I think I need to straighten this discussion out in my head a little bit.
> Am I correct in assuming Andrea's original patch set did not have any SMP
> race conditions for KVM?  If so, then we need to start looking at how to

Yes my last patch was SMP safe, stable and feature complete for KVM. I
tested it for 1 week on my smp workstation with real desktop load and
everything loaded, with 3G non-linux guest running on 2G of ram.

Now for whatever reason I adapted the KVM side to Christoph's V2/V3
and it hangs the moment it hits swap. However in the meantime I
changed test hardware, upgraded host to 2.6.24-hg, and upgraded kvm
kernel and userland. all patches applied cleanly (with a minor nit in
a .h include in V2 on top of current git). Swapping of regular tasks
on the test system is 100% solid or I wouldn't even wasting time
mentioning this. By code inspection I didn't expect a stability
regression or I wouldn't have chanced all variables at the same time
(taking the opportunity to move everything to bleeding edge while
moving to V2 turned out to be a bad idea). I already audited the mmu
notifiers a few times, infact I already went back to call
invalidate_page and age_page inside ptep_clear_flush/young in case the
page-pin wasn't enough to prevent the page to change under the sptes,
as I thought yesterday.

Christoph's V3 notably still misses the needed range flushes in mremap
for example, but that's not my problem.  (Jack instead will certainly
kernel crash due to the missing invalidate_page after ptep_clear_flush
in mremap, such an invalidate_page wasn't missing with my last patch)

I'm now going to run the same binaries that still are stable on my
workstation on the test system too, to rule out timings and hardware
differences.

> implement Christoph's and my changes in a safe fashion.  Andrea, I agree
> complete that our introduction of the range callouts have introduced
> SMP races.

I think for KVM basic swapping both V2 and V3 should be safe. V2 had
race conditions that would later break KSM yes, I fixed it and V3
should be already ok and I'm not testing KSM. This is all thanks to the
pin of the page in get_user_page that KVM does for every page mapped
in any spte.

> The three issues we need to simultaneously solve is revoking the remote
> page table/tlb information while still in a sleepable context and not
> having the remote faulters become out of sync with the granting process.
> Currently, I don't see a way to do that cleanly with a single callout.

Agreed.

> Could we consider doing a range-based recall and lock callout before
> clearing the processes page tables/TLBs, then use the _page or _range
> callouts from Andrea's patch to clear the mappings,  finally make a
> range-based unlock callout.  The mmu_notifier user would usually use ops
> for either the recall+lock/unlock family of callouts or the _page/_range
> family of callouts.

invalidate_page/age_page can return inside ptep_clear_flush/young and
Jack will need that too. Infact Jack will need an invalidate_page also
inside ptep_get_and_clear. And the range callout will be done always
in a sleeping context and it'll relay on the page-pin to be safe (when
details->i_mmap_lock != NULL invalidate_range it shouldn't be called
inside zap_page_range but before returning from
unmap_mapping_range_vma before cond_resched). This will make
everything a bit simpler and less prone to breakage IMHO, plus it'll
have a chance to work for Jack w/o page-pin without additional
cluttering of mm/*.c.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
