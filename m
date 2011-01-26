Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1331E6B0092
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 10:49:50 -0500 (EST)
Date: Wed, 26 Jan 2011 16:42:03 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: too big min_free_kbytes
Message-ID: <20110126154203.GS926@random.random>
References: <1295841406.1949.953.camel@sli10-conroe>
 <20110124150033.GB9506@random.random>
 <20110126141746.GS18984@csn.ul.ie>
 <20110126152302.GT18984@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110126152302.GT18984@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 26, 2011 at 03:23:02PM +0000, Mel Gorman wrote:
> On Wed, Jan 26, 2011 at 02:17:46PM +0000, Mel Gorman wrote:
> > On Mon, Jan 24, 2011 at 04:00:34PM +0100, Andrea Arcangeli wrote:
> > > eOn Mon, Jan 24, 2011 at 11:56:46AM +0800, Shaohua Li wrote:
> > > > Hi,
> > > > With transparent huge page, min_free_kbytes is set too big.
> > > > Before:
> > > > Node 0, zone    DMA32
> > > >   pages free     1812
> > > >         min      1424
> > > >         low      1780
> > > >         high     2136
> > > >         scanned  0
> > > >         spanned  519168
> > > >         present  511496
> > > > 
> > > > After:
> > > > Node 0, zone    DMA32
> > > >   pages free     482708
> > > >         min      11178
> > > >         low      13972
> > > >         high     16767
> > > >         scanned  0
> > > >         spanned  519168
> > > >         present  511496
> > > > This caused different performance problems in our test. I wonder why we
> > > > set the value so big.
> > > 
> > > It's to enable Mel's anti-frag that keeps pageblocks with movable and
> > > unmovable stuff separated, same as "hugeadm
> > > --set-recommended-min_free_kbytes".
> > > 
> > > Now that I checked, I'm seeing quite too much free memory with only 4G
> > > of ram... You can see the difference with a "cp /dev/sda /dev/null" in
> > > background interleaving these two commands:
> > > 
> > 
> > What kernel is this and is commit
> > [99504748: mm: kswapd: stop high-order balancing when any suitable zone
> > is balanced] present in the kernel you are testing?
> > 
> > I'm having very little luck reproducing your scenario with
> > 2.6.38-rc2.
> 
> Scratch that, a machine with 4G does reproduce it. The machine I was
> trying was 2G. Will dig more.

I can't reproduce on a 16G system (there I never get more than an
hundred mbyte free even with cp in background, which is very fine for
16G).

I only reproduce on my 4G workstation, and it happens also after echo
never >enabled (so without THP). I was reproducing it with "cp" anyway
which isn't triggering THP allocations but I verified to be sure. When
I start cp kswapd wasn't running yet, so free levels go down to 170M,
then kswapd starts and it frees 700M and then 700m remains free
forever until I stop "cp". The high wmark are never set to more than
85M for the normal zone, which is not excessively horrible. I'd still
like to lower the wmark though!  (there are 2 pageblocks reserved in
the min watermark for each type, why not just 1? removing that *2
would already halve it saving some 40M of ram!). But the wmarks don't
seem the real offender, maybe it's something related to the tiny pci32
zone that materialize on 4g systems that relocate some little memory
over 4g to make space for the pci32 mmio. I didn't yet finish to debug
it.

However in presence of memory pressure the low wmark is the limit not
the high wmark (and when kswapd isn't running free levels already go
down to 170M even where I can reproduce). Maybe the failure with too
much memory free may be only because of the increased wmark from some
20M to ~100M, and maybe I'm seeing something unrelated to that
problem. __GFP_NO_KSWAPD I exclude is the issue as it happens without
THP too and there's just one place where huge_memory.c allocates
memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
