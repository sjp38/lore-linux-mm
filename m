Date: Fri, 3 Aug 2001 20:13:59 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [RFC][DATA] re "ongoing vm suckage"
In-Reply-To: <0108040506570N.01827@starship>
Message-ID: <Pine.LNX.4.33.0108032003200.15155-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Rik van Riel <riel@conectiva.com.br>, Ben LaHaise <bcrl@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 4 Aug 2001, Daniel Phillips wrote:
>
> Nice shooting, this could explain the effect I noticed where
> writing a linker file takes 8 times longer when competing with
> a simultaneous grep.

Just remove that whole logic - it's silly and broken. That's _not_ where
the logic should be anyway.

The whole "we don't want to have too many queued requests" logic in that
place is just stupid. Let's go through this:

 - we have read requests, and we have write requests.
 - we _NEVER_ want to have a read request trigger this logic. When we
   start a read, we'll eventually wait on it, so readers will always
   throttle themselves. If readers do huge amounts of read-ahead, that's
   still ok. We're much better off just blocking in the request allocation
   layer.
 - writers are different. Writers write in big chunks, and they should
   wait for themselves, not on others. See write_locked_buffers() in
   recent kernels: that makes "sync()" a very nice player. It just waits
   every NRSYNC blocks (for "sync", NRSYNC is a low 32 buffers, which is
   just 128kB at a time. That's fine, because "sync" is not performance
   critical. Other writeouts might want to have slightly bigger blocking
   factors).

Agreed? Let's just remove the broken code in ll_rw_block() - it's not as
if most people even _use_ ll_rw_block() for writing at all any more.

(Yeah, fsync_inode_buffers() does, and would probably speed up by using
the same approach "sync" does - it not only gives nicer behaviour under
load, it also reduces spinlock contention and CPU usage by a LOT).

Oh, and "flush_dirty_buffers()" is _really_ broken. I wanted to clean that
up use the sync code too, but I was too lazy.

> Umm.... Hmm, there are lots more solutions than that, but those two
> are nice and simple.  A quick test for (1) I hope Ben will try is
> just to set high_queued_sectors = low_queued_sectors.

Please just remove the code instead. I don't think it buys you anything.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
