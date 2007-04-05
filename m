Date: Thu, 5 Apr 2007 16:24:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 12/12] mm: per BDI congestion feedback
Message-Id: <20070405162425.eb78c701.akpm@linux-foundation.org>
In-Reply-To: <20070405174320.649550491@programming.kicks-ass.net>
References: <20070405174209.498059336@programming.kicks-ass.net>
	<20070405174320.649550491@programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: root@programming.kicks-ass.net
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com
List-ID: <linux-mm.kvack.org>

On Thu, 05 Apr 2007 19:42:21 +0200
root@programming.kicks-ass.net wrote:

> Now that we have per BDI dirty throttling is makes sense to also have oer BDI
> congestion feedback; why wait on another device if the current one is not
> congested.

Similar comments apply.  congestion_wait() should be called
throttle_at_a_rate_proportional_to_the_speed_of_presently_uncongested_queues().

If a process is throttled in the page allocator waiting for pages to become
reclaimable, that process absolutely does not care whether those pages were
previously dirty against /dev/sda or against /dev/sdb.  It wants to be woken
up for writeout completion against any queue.


-		wbc.encountered_congestion = 0;
+		wbc.encountered_congestion = NULL;
 		wbc.nr_to_write = MAX_WRITEBACK_PAGES;
 		wbc.pages_skipped = 0;
 		writeback_inodes(&wbc);
 		min_pages -= MAX_WRITEBACK_PAGES - wbc.nr_to_write;
 		if (wbc.nr_to_write > 0 || wbc.pages_skipped > 0) {
	 			/* Wrote less than expected */
-			congestion_wait(WRITE, HZ/10);
-			if (!wbc.encountered_congestion)
+			if (wbc.encountered_congestion)
+				congestion_wait(wbc.encountered_congestion,
+						WRITE, HZ/10);
+			else

Well that confused me.  You'd be needing to rename
wbc.encountered_congestion to congested_bdi or something.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
