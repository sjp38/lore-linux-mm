Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F32636B0092
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 09:36:04 -0500 (EST)
Date: Tue, 25 Jan 2011 14:35:36 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: too big min_free_kbytes
Message-ID: <20110125143535.GH18984@csn.ul.ie>
References: <1295841406.1949.953.camel@sli10-conroe> <20110124150033.GB9506@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110124150033.GB9506@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>
List-ID: <linux-mm.kvack.org>

Sorry for the long delay in replying. I've been out the last week and am
not properly back until tomorrow.

On Mon, Jan 24, 2011 at 04:00:34PM +0100, Andrea Arcangeli wrote:
> eOn Mon, Jan 24, 2011 at 11:56:46AM +0800, Shaohua Li wrote:
> > Hi,
> > With transparent huge page, min_free_kbytes is set too big.
> > Before:
> > Node 0, zone    DMA32
> >   pages free     1812
> >         min      1424
> >         low      1780
> >         high     2136
> >         scanned  0
> >         spanned  519168
> >         present  511496
> > 
> > After:
> > Node 0, zone    DMA32
> >   pages free     482708
> >         min      11178
> >         low      13972
> >         high     16767
> >         scanned  0
> >         spanned  519168
> >         present  511496
> > This caused different performance problems in our test. I wonder why we
> > set the value so big.
> 
> It's to enable Mel's anti-frag that keeps pageblocks with movable and
> unmovable stuff separated, same as "hugeadm
> --set-recommended-min_free_kbytes".
> 

It's not so much "make it work" as "make it work better". The effect can
be measured by recording the mm_page_alloc_extfrag event. The more times
it occurs, the worse fragmentation can get. The event also reports
whether it is severe or not.

> Now that I checked, I'm seeing quite too much free memory with only 4G
> of ram... You can see the difference with a "cp /dev/sda /dev/null" in
> background interleaving these two commands:
> 

There is more than just min_free_kbytes happening here. The high
watermark goes to 16M-ish but the amount of free memory is *way* above
that watermark. Something is causing page reclaim to be a lot more
agressive than it should be.

Is there a difference with THP enabled and disabled but leaving
min_free_kbytes alone? My preliminary theory is that 2M pages are being
requested and kswapd is being woken up when it shouldn't
(__GFP_NO_KSWAPD not specified when it should be). Unfortunately I do
not have access to source at the moment to double check.

> echo always >/sys/kernel/mm/transparent_hugepage/enabled
> echo 1000 > /proc/sys/vm/min_free_kbytes
> 
> The setting of min_free_kbytes to 67584 leads to 716MB of memory
> free. Setting to 1000 leads to 20MB free. I'm afraid losing 716MB on a
> 4G system is way excessive regardless of THP...

Agreed.

> can't we just have a
> version of anti-frag that reserves a lot fewers pageblocks?

Anti-frag doesn't really take any additional special action due to
min_free_kbytes and it shouldn't be clearing out pageblocks
aggressively like this. I think it would also be worth checking how
often the mm_vmscan_kswapd_wake and mm_vmscan_wakeup_kswapd trace events
are triggering. If mm_vmscan_wakeup_kswapd is triggering a lot, a stack
trace of the most common triggering event might give a clue as to what
is going wrong.

> Anti-frag
> is quite important to avoid slab to fragment everything. I don't think
> we can leave it like this.
> 
> For now you can workaround with the above echo 1000 > ...
> 

Agreed. I'll try find time to investigate before the week is out but
after being offline for a week, I've a lot of catching up to do.

-- 
Mel Gorman
Linux Technology Center
IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
