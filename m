Message-ID: <398827327.01162@ustc.edu.cn>
Date: Fri, 28 Dec 2007 15:35:15 +0800
From: Fengguang Wu <wfg@mail.ustc.edu.cn>
Subject: Re: [patch 1/1] Writeback fix for concurrent large and small file
	writes.
References: <20071211020255.CFFB21080E@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071211020255.CFFB21080E@localhost>
Message-Id: <E1J89kR-0001v3-CJ@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Michael Rubin <mrubin@google.com>
Cc: a.p.zijlstra@chello.nl, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Michael,

// sorry for the delay...

On Mon, Dec 10, 2007 at 06:02:55PM -0800, Michael Rubin wrote:
> From: Michael Rubin <mrubin@google.com>
> 
> Fixing a bug where writing to large files while concurrently writing to
> smaller ones creates a situation where writeback cannot keep up with the
> traffic and memory baloons until the we hit the threshold watermark. This
> can result in surprising latency spikes when syncing. This latency
> can take minutes on large memory systems. Upon request I can provide
> a test to reproduce this situation.
> 
> The only concern I have is that this makes the wb_kupdate slightly more
> agressive. I am not sure it is enough to cause any problems. I think
> there is enough checks to throttle the background activity.
> 
> Feng also the one line change that you recommended here 
> http://marc.info/?l=linux-kernel&m=119629655402153&w=2 had no effect.
> 
> Signed-off-by: Michael Rubin <mrubin@google.com>
> ---
> Index: 2624rc3_feng/fs/fs-writeback.c
> ===================================================================
> --- 2624rc3_feng.orig/fs/fs-writeback.c	2007-11-29 14:44:24.000000000 -0800
> +++ 2624rc3_feng/fs/fs-writeback.c	2007-12-10 17:21:45.000000000 -0800
> @@ -408,8 +408,7 @@ sync_sb_inodes(struct super_block *sb, s
>  {
>  	const unsigned long start = jiffies;	/* livelock avoidance */
>  
> -	if (!wbc->for_kupdate || list_empty(&sb->s_io))
> -		queue_io(sb, wbc->older_than_this);
> +	queue_io(sb, wbc->older_than_this);

Basically it's a workaround by changing the service priority.

Assume A to be the large file and B,C,D,E,... to be the small files.
- old behavior: 
                sync 4MB of A; sync B,C; congestion_wait();
                sync 4MB of A; sync D,E; congestion_wait();
                sync 4MB of A; sync F,G; congestion_wait();
                ...
- new behavior:
                sync 4MB of A;
                sync 4MB of A;
                sync 4MB of A;
                sync 4MB of A;
                sync 4MB of A;
                ...            // repeat until A is clean
                sync B,C,D,E,F,G;

So the bug is gone, but now A could possibly starve other files :-(

>  	while (!list_empty(&sb->s_io)) {
>  		struct inode *inode = list_entry(sb->s_io.prev,
> Index: 2624rc3_feng/mm/page-writeback.c
> ===================================================================
> --- 2624rc3_feng.orig/mm/page-writeback.c	2007-11-16 21:16:36.000000000 -0800
> +++ 2624rc3_feng/mm/page-writeback.c	2007-12-10 17:37:17.000000000 -0800
> @@ -638,7 +638,7 @@ static void wb_kupdate(unsigned long arg
>  		wbc.nr_to_write = MAX_WRITEBACK_PAGES;
>  		writeback_inodes(&wbc);
>  		if (wbc.nr_to_write > 0) {
> -			if (wbc.encountered_congestion || wbc.more_io)
> +			if (wbc.encountered_congestion)

No, this could make wb_kupdate() abort even when there are more data
to be synced. That will make David Chinner unhappy ;-)

>  				congestion_wait(WRITE, HZ/10);
>  			else
>  				break;	/* All the old data is written */

Just a minute, I'll propose a way out of this bug :-)

Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
