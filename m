Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8A4336B0047
	for <linux-mm@kvack.org>; Thu, 25 Feb 2010 07:27:53 -0500 (EST)
Date: Thu, 25 Feb 2010 20:27:26 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 02/15] readahead: retain inactive lru pages to be
	accessed soon
Message-ID: <20100225122726.GA9077@localhost>
References: <20100224031001.026464755@intel.com> <20100224031053.886603916@intel.com> <4B85EBD5.2050006@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B85EBD5.2050006@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jens.axboe@oracle.com>, Chris Frost <frost@cs.ucla.edu>, Steve VanDeBogart <vandebo@cs.ucla.edu>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Clemens Ladisch <clemens@ladisch.de>, Olivier Galibert <galibert@pobox.com>, Vivek Goyal <vgoyal@redhat.com>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Matt Mackall <mpm@selenic.com>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Feb 25, 2010 at 11:17:41AM +0800, Rik van Riel wrote:
> On 02/23/2010 10:10 PM, Wu Fengguang wrote:
> > From: Chris Frost<frost@cs.ucla.edu>
> >
> > Ensure that cached pages in the inactive list are not prematurely evicted;
> > move such pages to lru head when they are covered by
> > - in-kernel heuristic readahead
> > - an posix_fadvise(POSIX_FADV_WILLNEED) hint from an application
> 
> > Signed-off-by: Chris Frost<frost@cs.ucla.edu>
> > Signed-off-by: Steve VanDeBogart<vandebo@cs.ucla.edu>
> > Signed-off-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> > Signed-off-by: Wu Fengguang<fengguang.wu@intel.com>
> 
> Acked-by: Rik van Riel <riel@redhat.com>
> 
> When we get into the situation where readahead thrashing
> would occur, we will end up evicting other stuff more
> quickly from the inactive file list.  However, that will
> be the case either with or without this code...

Thanks. I'm actually not afraid of it adding memory pressure to the
readahead thrashing case.  The context readahead (patch 07) can
adaptively control the memory pressure with or without this patch.

It does add memory pressure to mmap read-around. A typical read-around
request would cover some cached pages (whether or not they are
memory-mapped), and all those pages would be moved to LRU head by
this patch.

This somehow implicitly adds LRU lifetime to executable/lib pages.

Hopefully this won't behave too bad. And will be limited by
smaller readahead size in small memory systems (patch 05).

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
