Date: Mon, 24 Nov 2008 12:53:35 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] vmscan: bail out of page reclaim after swap_cluster_max
 pages
Message-Id: <20081124125335.556c2a60.akpm@linux-foundation.org>
In-Reply-To: <20081124145057.4211bd46@bree.surriel.com>
References: <20081124145057.4211bd46@bree.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Mon, 24 Nov 2008 14:50:57 -0500
Rik van Riel <riel@redhat.com> wrote:

> Sometimes the VM spends the first few priority rounds rotating back
> referenced pages and submitting IO.  Once we get to a lower priority,
> sometimes the VM ends up freeing way too many pages.

It would help (a lot) if we had a much more specific and detailed
description of the problem which is being fixed.  Nobody has noticed it
in half a decade, so it can't be very serious?

> The fix is relatively simple: in shrink_zone() we can check how many
> pages we have already freed, direct reclaim tasks break out of the
> scanning loop if they have already freed enough pages and have reached
> a lower priority level.

So in the common scenario where there's a lot of dirty highmem and
little dirty lowmem, the kernel will start reclaiming highmem at a
vastly higher rate than lowmem.  iirc, this was the reason why this
change was tried then reverted.

Please demonstrate that this regression is not worse than the problem
which is being fixed!

> However, in order to do this we do need to know how many pages we already
> freed, so move nr_reclaimed into scan_control.

Thus carrying the state across the *entire* scanning pass: all zones.

So as soon as sc.nr_reclaimed exceeds swap_cluster_max, the scanner
will fall into a different mode for the remaining zones wherein it will
scan only swap_cluster_max pages from them, then will bale.

This will heavily bias scanning onto the zones at the start of the zone
list.  In fact it probably means that the zone at the head of the
zonelist gets thrashed and the remaining zones will just sit there
doing almost nothing.  Where's the sense in that?

Has any testing been done to demonstrate and quantify this effect?

> Signed-off-by: Rik van Riel <riel@redhat.com>
> ---
> Kosaki, this should address the zone scanning pressure issue.

What is the "zone scanning pressure issue"?

Please don't put "should" in a vmscan changelog :( Either it does, or
it does not?


This should look familiar:

	commit e468e46a9bea3297011d5918663ce6d19094cf87
	Author: akpm <akpm>
	Date:   Thu Jun 24 15:53:52 2004 +0000

	[PATCH] vmscan.c: dont reclaim too many pages
	    
	    The shrink_zone() logic can, under some circumstances, cause far too many
	    pages to be reclaimed.  Say, we're scanning at high priority and suddenly hit
	    a large number of reclaimable pages on the LRU.                                                                        
	    Change things so we bale out when SWAP_CLUSTER_MAX pages have been reclaimed.
	    
	    Signed-off-by: Andrew Morton <akpm@osdl.org>
	    Signed-off-by: Linus Torvalds <torvalds@osdl.org>
	    
	    BKrev: 40daf910sac4yN_aUhhJF2U8Upx1ww


And here is where it was reverted.  Note that this was nearly two years
later!  It takes that long for these things to be discovered, analysed
and fixed.



	commit 210fe530305ee50cd889fe9250168228b2994f32
	Author: Andrew Morton <akpm@osdl.org>
	Date:   Fri Jan 6 00:11:14 2006 -0800

	    [PATCH] vmscan: balancing fix
	    
	    Revert a patch which went into 2.6.8-rc1.  The changelog for that patch was:
	    
	      The shrink_zone() logic can, under some circumstances, cause far too many
	      pages to be reclaimed.  Say, we're scanning at high priority and suddenly
	      hit a large number of reclaimable pages on the LRU.
	    
	      Change things so we bale out when SWAP_CLUSTER_MAX pages have been
	      reclaimed.
	    
	    Problem is, this change caused significant imbalance in inter-zone scan
	    balancing by truncating scans of larger zones.
	    
	    Suppose, for example, ZONE_HIGHMEM is 10x the size of ZONE_NORMAL.  The zone
	    balancing algorithm would require that if we're scanning 100 pages of
	    ZONE_HIGHMEM, we should scan 10 pages of ZONE_NORMAL.  But this logic will
	    cause the scanning of ZONE_HIGHMEM to bale out after only 32 pages are
	    reclaimed.  Thus effectively causing smaller zones to be scanned relatively
	    harder than large ones.
	    
	    Now I need to remember what the workload was which caused me to write this
	    patch originally, then fix it up in a different way...
	    
	    Signed-off-by: Andrew Morton <akpm@osdl.org>
	    Signed-off-by: Linus Torvalds <torvalds@osdl.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
