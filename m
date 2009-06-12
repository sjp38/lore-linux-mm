Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id AAF616B009E
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 12:08:29 -0400 (EDT)
Date: Fri, 12 Jun 2009 09:08:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3] Fix malloc() stall in zone_reclaim() and bring
 behaviour more in line with expectations V3
Message-Id: <20090612090814.731b6f8d.akpm@linux-foundation.org>
In-Reply-To: <20090612110424.GD14498@csn.ul.ie>
References: <1244717273-15176-1-git-send-email-mel@csn.ul.ie>
	<20090611163006.e985639f.akpm@linux-foundation.org>
	<20090612110424.GD14498@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, cl@linux-foundation.org, fengguang.wu@intel.com, linuxram@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Jun 2009 12:04:24 +0100 Mel Gorman <mel@csn.ul.ie> wrote:

> On Thu, Jun 11, 2009 at 04:30:06PM -0700, Andrew Morton wrote:
> > On Thu, 11 Jun 2009 11:47:50 +0100
> > Mel Gorman <mel@csn.ul.ie> wrote:
> > 
> > > The big change with this release is that the patch reintroducing
> > > zone_reclaim_interval has been dropped as Ram reports the malloc() stalls
> > > have been resolved. If this bug occurs again, the counter will be there to
> > > help us identify the situation.
> > 
> > What is the exact relationship between this work and the somewhat
> > mangled "[PATCH for mmotm 0/5] introduce swap-backed-file-mapped count
> > and fix
> > vmscan-change-the-number-of-the-unmapped-files-in-zone-reclaim.patch"
> > series?
> > 
> 
> The patch series "Fix malloc() stall in zone_reclaim() and bring
> behaviour more in line with expectations V3" replaces
> vmscan-change-the-number-of-the-unmapped-files-in-zone-reclaim.patch.
> 
> Portions of the patch series "Introduce swap-backed-file-mapped count" are
> potentially follow-on work if a failure case can be identified. The series
> brings the kernel behaviour more in line with documentation, but it's easier
> to fix the documentation.
> 
> > That five-patch series had me thinking that it was time to drop 
> > 
> > vmscan-change-the-number-of-the-unmapped-files-in-zone-reclaim.patch
> 
> This patch gets replaced. All the lessons in the new patch are included.
> They could be merged together.

OK, I'll fold
vmscan-change-the-number-of-the-unmapped-files-in-zone-reclaim.patch
and
vmscan-properly-account-for-the-number-of-page-cache-pages-zone_reclaim-can-reclaim.patch,
using
vmscan-properly-account-for-the-number-of-page-cache-pages-zone_reclaim-can-reclaim.patch's
changelog verbatim.


> > vmscan-drop-pf_swapwrite-from-zone_reclaim.patch
> 
> This patch is wrong, but only sortof. It should be dropped or replaced with
> another version. Kosaki, could you resubmit this patch except that you check
> if RECLAIM_SWAP is set in zone_reclaim_mode when deciding whether to set
> PF_SWAPWRITE or not please?
> 
> Your patch is correct if zone_reclaim_mode 1, but incorrect if it's 7 for
> example.

OK, I can drop that.

> > vmscan-zone_reclaim-use-may_swap.patch
> > 
> 
> This is a tricky one. Kosaki, I think this patch is a little dangerous. With
> this applied, pages get unmapped whether RECLAIM_SWAP is set or not. This
> means that zone_reclaim() now has more work to do when it's enabled and it
> incurs a number of minor faults for no reason as a result of trying to avoid
> going off-node. I don't believe that is desirable because it would manifest
> as high minor fault counts on NUMA and would be difficult to pin down why
> that was happening.
> 
> I think the code makes more sense than the documentation and it's the
> documentation that should be fixed. Our current behaviour is to discard
> clean, swap-backed, unmapped pages that require no further IO. This is
> reasonable behaviour for zone_reclaim_mode == 1 so maybe the patch
> should change the documentation to
> 
>         1       = Zone reclaim discards clean unmapped disk-backed pages
>         2       = Zone reclaim writes dirty pages out
>         4       = Zone reclaim unmaps and swaps pages
> 
> If you really wanted to strict about the meaning of RECLAIM_SWAP, then
> something like the following would be reasonable;
> 
> 	.may_unmap = !!(zone_reclaim_mode & RECLAIM_SWAP),
> 	.may_swap = !!(zone_reclaim_mode & RECLAIM_SWAP),
> 
> because a system administrator is not going to distinguish between
> unmapping and swap. I would assume at least that RECLAIM_SWAP implies
> unmapping pages for swapping but an updated documentation wouldn't hurt
> with
> 
> 	4       = Zone reclaim unmaps and swaps pages

OK, I can drop vmscan-zone_reclaim-use-may_swap.patch also.

> > (they can be removed cleanly, but I haven't tried compiling the result)
> > 
> > but your series is based on those.
> > 
> 
> The patchset only depends on
> vmscan-change-the-number-of-the-unmapped-files-in-zone-reclaim.patch
> and then only because of merge conflicts. All the lessons in
> vmscan-change-the-number-of-the-unmapped-files-in-zone-reclaim.patch are
> incorporated.

OK.

> > We have 142 MM patches queued, and we need to merge next week.
> > 
> 
> I'm sorry my timing for coming out with the zone_reclaim() patches sucks
> and that I failed to spot these patches earlier. Despite the abundance
> of evidence, I'm not trying to be deliberatly awkward :/

Well.  Speaking of bad timing, my next 2.5 days are dedicated to
zooming around a racetrack.  I'll do an mmotm now, if it looks like
it'll slightly compile.  Please check carefully.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
