Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8B1276B02A6
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 13:31:45 -0400 (EDT)
Date: Wed, 28 Jul 2010 10:30:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Why PAGEOUT_IO_SYNC stalls for a long time
Message-Id: <20100728103056.c5511c78.akpm@linux-foundation.org>
In-Reply-To: <20100728191322.4A85.A69D9226@jp.fujitsu.com>
References: <20100728071705.GA22964@localhost>
	<20100728191322.4A85.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, stable@kernel.org, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Andreas Mohr <andi@lisas.de>, Bill Davidsen <davidsen@tmr.com>, Ben Gamari <bgamari.foss@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, 28 Jul 2010 20:40:21 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> 3. pageout() is intended anynchronous api. but doesn't works so.
> 
> pageout() call ->writepage with wbc->nonblocking=1. because if the system have
> default vm.dirty_ratio (i.e. 20), we have 80% clean memory. so, getting stuck
> on one page is stupid, we should scan much pages as soon as possible.
> 
> HOWEVER, block layer ignore this argument. if slow usb memory device connect
> to the system, ->writepage() will sleep long time. because submit_bio() call
> get_request_wait() unconditionally and it doesn't have any PF_MEMALLOC task
> bonus.

The idea is that vmscan doesn't call ->writepage if the underlying
queue is congested.  may_write_to_queue()->bdi_queue_congested() should
return false and we skip the write.

If that logic is broken then that would explain a few things...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
