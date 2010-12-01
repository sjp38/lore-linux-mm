Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5F6156B00AD
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 18:04:54 -0500 (EST)
Date: Wed, 1 Dec 2010 15:03:33 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 01/13] writeback: IO-less balance_dirty_pages()
Message-Id: <20101201150333.fa4b8955.akpm@linux-foundation.org>
In-Reply-To: <20101201133818.GA13377@localhost>
References: <20101117042720.033773013@intel.com>
	<20101117042849.410279291@intel.com>
	<1290085474.2109.1480.camel@laptop>
	<20101129151719.GA30590@localhost>
	<1291064013.32004.393.camel@laptop>
	<20101130043735.GA22947@localhost>
	<1291156522.32004.1359.camel@laptop>
	<1291156765.32004.1365.camel@laptop>
	<20101201133818.GA13377@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Hellwig <hch@lst.de>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 1 Dec 2010 21:38:18 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> It shows that
> 
> 1) io_schedule_timeout(200ms) always return immediately for iostat,
>    forming a busy loop.  How can this happen? When iostat received
>    some signal? Then we may have to break out of the loop on catching
>    signals. Note that I already have
>                 if (fatal_signal_pending(current))
>                         break;
>    in the balance_dirty_pages() loop. Obviously that's not enough.

Presumably the calling task has singal_pending().

Using TASK_INTERRUPTIBLE in balance_dirty_pages() seems wrong.  If it's
going to do that then it must break out if signal_pending(), otherwise
it's pretty much guaranteed to degenerate into a busywait loop.  Plus
we *do* want these processes to appear in D state and to contribute to
load average.

So it should be TASK_UNINTERRUPTIBLE.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
