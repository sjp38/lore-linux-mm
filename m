Date: Wed, 13 Oct 2004 15:44:52 +1000
From: Nathan Scott <nathans@sgi.com>
Subject: Page cache write performance issue
Message-ID: <20041013054452.GB1618@frodo>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Nick Piggin <piggin@cyberone.com.au>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

Hi guys,

I've noticed the following performance regression from
between 2.6.8.1 and 2.6.9-rc.  It seems to have a very
pronounced affect on both ext2 and xfs.

- single thread, writing (what should be) straight into
the page cache, file size 1/2 of memory size (500MB vs
1GB), writes are in 1K chunks, most of memory is free,
machine was just booted;

- on 2.6.8 (and earlier 2.6 releases) I can typically
get ~50MB/sec on this machine doing this;  (or better
with larger I/O sizes, but thats not the point here)

- on 2.4.28-pre (and all 2.4 releases) I can typically
get ~70MB/sec, presumably writeback kicks in earlier on
2.6; OK, I guess we can live with that... probably some
tradeoff is being made there in the VM;

- on 2.6.9-rc I can only get _4_MB/sec (ext2 or xfs);
writeback commences very quickly, CPU utilisation drops
way down (from 100% to <10%)... looks like we go slower
cos we're initiating I/O almost from the start.

Now if I bump up /proc/sys/vm/dirty_background_ratio and
/proc/sys/vm/dirty_ratio from 40 to 80, I see the expected
performance again (actually, I see the 2.4 performance,
so the poorer early-2.6 numbers were probably due to I/O
commencing at the tail end of all the writes, due to 50%
being more than 40% :).  But 2.6.8 had the same default
dirty writeout ratios (40) as 2.6.9-rc does, didn't it?

So, any ideas what happened to 2.6.9?  Whats the rationale
for commencing writeout earlier in 2.6 (even when there's
so much free memory available)?  Any chance we can get the
defaults set to something much larger in the wake of the
other 2.6.9 VM changes, so we don't regress here?

thanks!

-- 
Nathan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
