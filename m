Date: Mon, 12 Jul 2004 17:42:22 -0500
From: Brent Casavant <bcasavan@sgi.com>
Reply-To: Brent Casavant <bcasavan@sgi.com>
Subject: Re: Scaling problem with shmem_sb_info->stat_lock
In-Reply-To: <20040712215504.GN21066@holomorphy.com>
Message-ID: <Pine.SGI.4.58.0407121724270.111008@kzerza.americas.sgi.com>
References: <Pine.SGI.4.58.0407121546460.111008@kzerza.americas.sgi.com>
 <20040712215504.GN21066@holomorphy.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: hugh@veritas.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 12 Jul 2004, William Lee Irwin III wrote:

> On Mon, Jul 12, 2004 at 04:11:29PM -0500, Brent Casavant wrote:
> > Looking at this code, I don't see any straightforward way to alleviate
> > this problem.  So, I was wondering if you might have any ideas how one
> > might approach this.  I'm hoping for something that will give us good
> > scaling all the way up to 512P.
>
> Smells like per-cpu split counter material to me.

It does to me too, particularly since the only time the i_blocks and
free_blocks fields are used for something other than bookkeeping updates
is the inode getattr operation, the superblock statfs operation, and the
shmem_set_size() function which is called infrequently.

The complication with this is that we'd either need to redefine
i_blocks in the inode structure (somehow I don't see that happening),
or move that field up into the shmem_inode_info structure and make
the necessary code adjustments.

I tried the latter approach (without splitting the counter) in one
attempt, but never quite got the code right.  I couldn't spot my bug,
but it was sort a one-off hack-job anyway, and got me the information
I needed at the time.

Thanks,
Brent

-- 
Brent Casavant             bcasavan@sgi.com        Forget bright-eyed and
Operating System Engineer  http://www.sgi.com/     bushy-tailed; I'm red-
Silicon Graphics, Inc.     44.8562N 93.1355W 860F  eyed and bushy-haired.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
