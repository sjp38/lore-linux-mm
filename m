In-reply-to: <20070220001351.GJ6133@think.oraclecorp.com> (message from Chris
	Mason on Mon, 19 Feb 2007 19:13:51 -0500)
Subject: Re: dirty balancing deadlock
References: <E1HIqlm-0004iZ-00@dorka.pomaz.szeredi.hu> <20070218125307.4103c04a.akpm@linux-foundation.org> <E1HIurG-0005Bw-00@dorka.pomaz.szeredi.hu> <20070218145929.547c21c7.akpm@linux-foundation.org> <E1HIvMB-0005Fd-00@dorka.pomaz.szeredi.hu> <20070218155916.0d3c73a9.akpm@linux-foundation.org> <E1HJC3P-0006tz-00@dorka.pomaz.szeredi.hu> <20070220001351.GJ6133@think.oraclecorp.com>
Message-Id: <E1HJQeV-0008Kq-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 20 Feb 2007 09:47:11 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: chris.mason@oracle.com
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > How about this?
> > 
> > Solves the FUSE deadlock, but not the throttle_vm_writeout() one.
> > I'll try to tackle that one as well.
> > 
> > If the per-bdi dirty counter goes below 16, balance_dirty_pages()
> > returns.
> > 
> > Does the constant need to tunable?  If it's too large, then the global
> > threshold is more easily exceeded.  If it's too small, then in a tight
> > situation progress will be slower.
> 
> Ok, what is supposed to happen here is that filesystems are supposed to
> be throttled from making more dirty pages when the system is over the
> threshold.  Even if filesystem A doesn't have much to contribute, and
> filesystem B is the cause of 99% of the dirty pages, the goal of the
> threshold is to prevent more dirty data from happening, and filesystem A
> should block.

Which is the cause of the current deadlock.  But if we allow
filesystem A to go into the red just a little, the deadlock is
avoided, because it can continue to make progress with cleaning the
dirtyness produced by B.

The maximum that filesystems can go over the limit will be

  (16 + epsilon) * number-of-queues

This is usually insignificant compared to the limit itself (~2000
pages on a machine with 32MB)

However with thousands of fuse mounts this may become a problem, as
each filesystem gets a separate queue.  In theory, just 2 pages are
enough to always make progress, but current dirty balancing can't
enforce this, as the ratelimit is at least 8 pages.

So there may have to be some more strict page accounting within fuse
itself, but that doesn't change the overall concept I think.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
