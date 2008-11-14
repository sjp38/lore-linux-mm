Date: Fri, 14 Nov 2008 09:18:28 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm] vmscan: bail out of page reclaim after
 swap_cluster_max pages
Message-Id: <20081114091828.48fc4b67.akpm@linux-foundation.org>
In-Reply-To: <491D8CEC.5050106@redhat.com>
References: <20081113171208.6985638e@bree.surriel.com>
	<20081113192729.7d8eb133.akpm@linux-foundation.org>
	<491D8CEC.5050106@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 14 Nov 2008 09:36:28 -0500 Rik van Riel <riel@redhat.com> wrote:

> Andrew Morton wrote:
> > On Thu, 13 Nov 2008 17:12:08 -0500 Rik van Riel <riel@redhat.com> wrote:
> > 
> >> Sometimes the VM spends the first few priority rounds rotating back
> >> referenced pages and submitting IO.  Once we get to a lower priority,
> >> sometimes the VM ends up freeing way too many pages.
> >>
> >> The fix is relatively simple: in shrink_zone() we can check how many
> >> pages we have already freed and break out of the loop.
> >>
> >> However, in order to do this we do need to know how many pages we already
> >> freed, so move nr_reclaimed into scan_control.
> > 
> > There was a reason for not doing this, but I forget what it was.  It might require
> > some changelog archeology.  iirc it was to do with balancing scanning rates
> > between the various things which we scan.
> 
> I've seen worse symptoms without this code, though. Pretty
> much all 2.6 kernels show bad behaviour occasionally.
> 
> Sometimes the VM gets in such a state where multiple processes
> cannot find anything readily evictable, and they all end up
> at a lower priority level.
> 
> This can cause them to evict more than half of everything from
> memory, before breaking out of the pageout loop and swapping
> things back in.  On my 2GB desktop, I've seen as much as 1200MB
> memory free due to such a swapout storm.  It is possible more is
> free at the top of the cycle, but X and gnome-terminal and top
> and everything else is stuck, so that's not actually visible :)
> 
> I am not convinced that a scanning imbalance is more serious.

I'm not as sure as you are that it was done this way to avoid scanning
imbalance.  I don't remember the reasons :(

It isn't necessarily true that this change and <whatever that was> are
mutually exclusive things.

> Of course, one thing we could do is exempt kswapd from this check.
> During light reclaim, kswapd does most of the eviction so scanning
> should remain balanced.  Having one process fall down to a lower
> priority level is also not a big problem.
> 
> As long as the direct reclaim processes do not also fall into the
> same trap, the situation should be manageable.
> 
> Does that sound reasonable to you?

I'll need to find some time to go dig through the changelogs.  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
