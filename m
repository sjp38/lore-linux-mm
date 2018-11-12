Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2A52F6B0003
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 16:08:44 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id e89so619743pfb.17
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 13:08:44 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id h20-v6si19612095plr.343.2018.11.12.13.08.41
        for <linux-mm@kvack.org>;
        Mon, 12 Nov 2018 13:08:42 -0800 (PST)
Date: Tue, 13 Nov 2018 08:08:39 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 01/16] xfs: drop ->writepage completely
Message-ID: <20181112210839.GM19305@dastard>
References: <20181107063127.3902-1-david@fromorbit.com>
 <20181107063127.3902-2-david@fromorbit.com>
 <20181109151239.GD9153@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181109151239.GD9153@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Fri, Nov 09, 2018 at 07:12:39AM -0800, Christoph Hellwig wrote:
> [adding linux-mm to the CC list]
> 
> On Wed, Nov 07, 2018 at 05:31:12PM +1100, Dave Chinner wrote:
> > From: Dave Chinner <dchinner@redhat.com>
> > 
> > ->writepage is only used in one place - single page writeback from
> > memory reclaim. We only allow such writeback from kswapd, not from
> > direct memory reclaim, and so it is rarely used. When it comes from
> > kswapd, it is effectively random dirty page shoot-down, which is
> > horrible for IO patterns. We will already have background writeback
> > trying to clean all the dirty pages in memory as efficiently as
> > possible, so having kswapd interrupt our well formed IO stream only
> > slows things down. So get rid of xfs_vm_writepage() completely.
> 
> Interesting.  IFF we can pull this off it would simplify a lot of
> things, so I'm generally in favor of it.

Over the past few days of hammeringon this, the only thing I've
noticed is that page reclaim hangs up less, but it's also putting a
bit more pressure on the shrinkers. Filesystem intensive workloads
that drive the machine into reclaim via the page cache seem to hit
breakdown conditions slightly earlier and the impact is that the
shrinkers are run harder. Mostly I see this as the XFS buffer cache
having a much harder time keeping a working set active.

However, while the workloads hit the working set cache, writeback
performance does seem to be slightly higher. It is, however, being
offset by the deeper lows that come from the cache being turned
over.

So there's a bit of rebalancing to be done here as a followup, but
I've been unable to drive the system into unexepected OOM kills or
other bad behaviour as a result of removing ->writepage.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
