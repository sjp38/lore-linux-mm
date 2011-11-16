Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3560B6B0069
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 22:13:59 -0500 (EST)
Date: Wed, 16 Nov 2011 05:13:50 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: Do not stall in synchronous compaction for THP
 allocations
Message-ID: <20111116041350.GA3306@redhat.com>
References: <CAEwNFnCRCxrru5rBk7FpypqeL8nD=SY5W3-TaA7Ap5o4CgDSbg@mail.gmail.com>
 <20111110161331.GG3083@suse.de>
 <20111110151211.523fa185.akpm@linux-foundation.org>
 <alpine.DEB.2.00.1111101536330.2194@chino.kir.corp.google.com>
 <20111111101414.GJ3083@suse.de>
 <20111114154408.10de1bc7.akpm@linux-foundation.org>
 <20111115132513.GF27150@suse.de>
 <alpine.DEB.2.00.1111151303230.23579@chino.kir.corp.google.com>
 <20111115234845.GK27150@suse.de>
 <alpine.DEB.2.00.1111151554190.3781@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1111151554190.3781@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Nov 15, 2011 at 04:07:08PM -0800, David Rientjes wrote:
> On Tue, 15 Nov 2011, Mel Gorman wrote:
> 
> > Adding sync here could obviously be implemented although it may
> > require both always-sync and madvise-sync. Alternatively, something
> > like an options file could be created to create a bitmap similar to
> > what ftrace does. Whatever the mechanism, it exposes the fact that
> > "sync compaction" is used. If that turns out to be not enough, then
> > you may want to add other steps like aggressively reclaiming memory
> > which also potentially may need to be controlled via the sysfs file
> > and this is the slippery slope.
> > 
> 
> So what's being proposed here in this patch is the fifth time this line 
> has been changed and its always been switched between true and !(gfp_mask 
> & __GFP_NO_KSWAPD).  Instead of changing it every few months, I'd suggest 
> that we tie the semantics of the tunable directly to sync_compaction since 
> we're primarily targeting thp hugepages with this change anyway for the 
> "always" case.  Comments?

I don't think it's ok. defrag=madvise means __GFP_WAIT not set for
regular THP alloc (without madvise(MADV_HUGEPAGE)) and __GFP_WAIT set
for madvise(MADV_HUGEPAGE).

If __GFP_WAIT isn't set, compaction-async won't be invoked.

After checking my current thp vmstat I think Andrew was right and we
backed out for a good reason before. I'm getting significantly worse
success rate, not sure why it was a small reduction in success rate
but hey I cannot exclude I may have broke something with some other
patch. I've been running it together with a couple more changes. If
it's this change that reduced the success rate, I'm afraid going
always async is not ok.

So before focusing so much on this sync/async flag, I'd like to
understand better why sync stalls so bad. I mean it's not like the VM
with 4k pages won't be doing some throttling too. I suspect we may be
too heavyweight on migrate looping 10 times. Especially with O_DIRECT
the pages may return pinned immediately after they're unpinned (if the
buffer for the I/O is the same like with dd) so there's no point to
wait on pinned pages 10 times around amounting to wait 10*2 = 20MB =
several seconds with usb stick for each 2M allocation. We can reduce
it to less than one second easily. Maybe somebody has time to test if
the below patch helps or not. I understand in some circumstance it may
not help and it'll lead to the same but I think this is good idea
anyway and maybe it helps. Currently we wait on locked pages, on
writeback pages, we retry on pinned pages again and again on locked
pages etc... That's a bit too much I guess, and we don't have to go
complete async to improve the situation I hope.

Could you try if you see any improvement with the below patch? I'm
running with a dd writing in a loop over 1g sd card and I don't see
stalls and success rate seems better than before but I haven't been
noticing the stalls before so I can't tell. (to test you need to
backout the other patches first, this is for 3.2rc2)

If this isn't enough I'd still prefer to find a way to tackle the
problem on a write-throttling way, or at least I'd need to re-verify
why the success rate was so bad with the patch applied (after 4 days
of uptime of normal load). I tend to check the success rate and with
upstream it's about perfect and a little degradation is ok but I was
getting less than 50%. Note with the usb writing in a loop the success
rate may degrade a bit, page will be locked, we won't wait on page
lock and then on writeback and all that slowdown anymore but it'll
still write throttle a bit and it will stop only working on movable
pages and isolating only clean pages like it would have done with
async forced.

===
