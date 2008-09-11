Date: Thu, 11 Sep 2008 10:58:16 +0200
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [RFC PATCH] discarding swap
Message-ID: <20080911085816.GP20055@kernel.dk>
References: <Pine.LNX.4.64.0809092222110.25727@blonde.site> <20080910173518.GD20055@kernel.dk> <Pine.LNX.4.64.0809102015230.16131@blonde.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0809102015230.16131@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: David Woodhouse <dwmw2@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 10 2008, Hugh Dickins wrote:
> On Wed, 10 Sep 2008, Jens Axboe wrote:
> > On Tue, Sep 09 2008, Hugh Dickins wrote:
> > 
> > > It seems odd to me that the data-less blkdev_issue_discard() is limited
> > > at all by max_hw_sectors; but I'm guessing there's a good reason, safety
> > > perhaps, which has forced you to that.
> > 
> > The discard request needs to be turned into a hw command at some point,
> > and for that we still need to fit the offset and size in there. So we
> > are still limited by 32MB commands on sata w/lba48, even though we are
> > not moving any data. Suboptimal, but...
> 
> ... makes good sense, thanks.
> 
> > > Here's the proposed patch, or combination of patches: the blkdev and
> > > swap parts should certainly be separated.  Advice welcome - thanks!
> > 
> > I'll snatch up the blk bits and put them in for-2.6.28. OK if I add your
> > SOB to that?
> 
> That would be great.  Thanks a lot for all your comments, I'd been
> expecting a much rougher ride!  If you've not already put it in,
> here's that subset of the patch - change it around as you wish.
> 
> 
> [PATCH] block: adjust blkdev_issue_discard for swap
> 
> Three mods to blkdev_issue_discard(), thinking ahead to its use on swap:
> 
> 1. Add gfp_mask argument, so swap allocation can use it where GFP_KERNEL
>    might deadlock but GFP_NOIO is safe.
> 
> 2. Enlarge nr_sects argument from unsigned to sector_t: unsigned long is
>    enough to cover a whole swap area, but sector_t suits any partition.
> 
> 3. Add an occasional cond_resched() into the loop, to avoid risking bad
>    latencies when discarding a large area in small max_hw_sectors steps.
> 
> Change sb_issue_discard()'s nr_blocks to sector_t too; but no need seen
> for a gfp_mask there, just pass GFP_KERNEL down to blkdev_issue_discard().
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>

Hugh, I applied this - but on 2nd though, I killed the cond_resched()
for two reasons:

- We should only add stuff like that if it's known problematic
- We'll be throttling on the request allocation eventually, once we get
  128 of these in flight.

So if this turns out to be a problem, we can revisit the cond_resched()
solution.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
