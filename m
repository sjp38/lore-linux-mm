Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id AF2A08D0002
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 18:08:51 -0500 (EST)
Date: Wed, 17 Nov 2010 15:08:14 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 01/13] writeback: IO-less balance_dirty_pages()
Message-Id: <20101117150814.393ab033.akpm@linux-foundation.org>
In-Reply-To: <20101117042849.410279291@intel.com>
References: <20101117042720.033773013@intel.com>
	<20101117042849.410279291@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 17 Nov 2010 12:27:21 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> Since the task will be soft throttled earlier than before, it may be
> perceived by end users as performance "slow down" if his application
> happens to dirty more than ~15% memory.

writeback has always had these semi-bogus assumptions that all pages
are the same, and it can sometimes go very wrong.

A chronic case would be a 4GB i386 machine where only 1/4 of memory is
useable for GFP_KERNEL allocations, filesystem metadata and /dev/sdX
pagecache.

When you think about it, a lot of the throttling work being done in
writeback is really being done on behalf of the page allocator (and
hence page reclaim).  But what happens if the workload is mainly
hammering away at ZONE_NORMAL, but writeback is considering ZONE_NORMAL
to be the same thing as ZONE_HIGHMEM?

Or vice versa, where page-dirtyings are all happening in lowmem?  Can
writeback then think that there are plenty of clean pages (because it's
looking at highmem as well) so little or no throttling is happening? 
If so, what effect does this have upon GFP_KERNEL/GFP_USER allocation?

And bear in mind that the user can tune the dirty levels.  If they're
set to 10% on a machine on which 25% of memory is lowmem then ill
effects might be rare.  But if the user tweaks the thresholds to 30%
then can we get into problems?  Such as a situation where 100% of
lowmem is dirty and throttling isn't cutting in?



So please have a think about that and see if you can think of ways in
which this assumption can cause things to go bad.  I'd suggest
writing some targetted tests which write to /dev/sdX (to generate
lowmem-only dirty pages) and which read from /dev/sdX (to request
allocation of lowmem pages).  Run these tests in conjunction with tests
which exercise the highmem zone as well and check that everything
behaves as expected.

Of course, this all assumes that you have a 4GB i386 box :( It's almost
getting to the stage where we need a fake-zone-highmem option for
x86_64 boxes just so we can test this stuff.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
