Message-ID: <392360181.25583@ustc.edu.cn>
Date: Sun, 14 Oct 2007 19:09:37 +0800
From: Fengguang Wu <wfg@mail.ustc.edu.cn>
Subject: Re: [RFC] mm - background_writeout exits when pages_skipped ?
Message-ID: <20071014110937.GA9235@mail.ustc.edu.cn>
References: <1192123174.3082.41.camel@castor.rsk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1192123174.3082.41.camel@castor.rsk.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: richard kennedy <richard@rsk.demon.co.uk>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 11, 2007 at 06:19:34PM +0100, richard kennedy wrote:
> When background_writeout() (mm/page-writeback.c) finds any pages_skipped
> in writeback_inodes() and it didn't meet any congestion, it exits even
> when it hasn't written enough pages yet.
> 
> Performing 2 ( or more) concurrent copies of a large file, often creates
> lots of skipped pages (1000+) making background_writeout exit and so
> pages don't get written out until we reach dirty_ratio.
> 
> I added some instrumentation to fs/buffer.c in
> __block_write_full_page(..) and all the skipped pages come from here :-
> 
> done:
> 	if (nr_underway == 0) {
> 		/*
> 		 * The page was marked dirty, but the buffers were
> 		 * clean.  Someone wrote them back by hand with
> 		 * ll_rw_block/submit_bh.  A rare case.
> 		 */
> 		end_page_writeback(page);
> 
> 		/*
> 		 * The page and buffer_heads can be released at any time from
> 		 * here on.
> 		 */

> 		wbc->pages_skipped++;	/* We didn't write this page */

FYI: The above line has just been removed in 2.6.23-mm1, which fixed the bug.

Thank you,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
