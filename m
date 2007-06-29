Date: Thu, 28 Jun 2007 18:29:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 01 of 16] remove nr_scan_inactive/active
Message-Id: <20070628182947.d2aadefb.akpm@linux-foundation.org>
In-Reply-To: <46845E68.9070508@redhat.com>
References: <8e38f7656968417dfee0.1181332979@v2.random>
	<466C36AE.3000101@redhat.com>
	<20070610181700.GC7443@v2.random>
	<46814829.8090808@redhat.com>
	<20070626105541.cd82c940.akpm@linux-foundation.org>
	<468439E8.4040606@redhat.com>
	<20070628155715.49d051c9.akpm@linux-foundation.org>
	<46843E65.3020008@redhat.com>
	<20070628161350.5ce20202.akpm@linux-foundation.org>
	<4684415D.1060700@redhat.com>
	<20070628162936.9e78168d.akpm@linux-foundation.org>
	<46844B83.20901@redhat.com>
	<20070628171922.2c1bd91f.akpm@linux-foundation.org>
	<46845620.6020906@redhat.com>
	<20070628181238.372828fa.akpm@linux-foundation.org>
	<46845E68.9070508@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 28 Jun 2007 21:20:40 -0400
Rik van Riel <riel@redhat.com> wrote:

> > But for now, the question is: is this a reasonable overall design?  Back
> > off from contention points, block at the top-level, polling for allocatable
> > memory to turn up?
> 
> I'm not convinced.  If we have already reclaimed some
> pages from the inactive list, why wait in congestion_wait()
> AT ALL?

Well by top-level I meant top-level.  The point where we either block or
declare oom.

We do that now in alloc_pages(), correctly I believe.

The congestion_wait()s in vmscan.c might be misplaced (ie: too far down)
because they could lead to us blocking when some memory actually got freed
up (or became freeable?) somewhere else.

To fix that we'd need to take a global look at things from within
direct-reclaim, or back out of direct-reclaim back up to alloc_pages(), but
remember where we were up to for the next pass.  Perhaps by extending
scan_control a bit and moving its instantiation up to __alloc_pages().


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
