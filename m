Date: Mon, 2 Oct 2000 15:53:57 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [highmem bug report against -test5 and -test6] Re: [PATCH] Re:
 simple FS application that hangs 2.4-test5, mem mgmt problem or FS buffer
 cache mgmt problem? (fwd)
In-Reply-To: <Pine.LNX.4.21.0010021902530.1067-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10010021550080.2206-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>


On Mon, 2 Oct 2000, Rik van Riel wrote:
> 
> Yes it has. The write order in flush_dirty_buffers() is the order
> in which the pages were written. This may be different from the
> LRU order and could give us slightly better IO performance.

.. or it might not.

Basically, the LRU order will be the same, EXCEPT if you have people
re-writing.

And if you have re-writing going on, you can't really say which order is
better.

I agree that flush_dirty_buffers() is _different_ from using the LRU pages
and try_to_free_buffer(). I don't think either one is obviously "better" -
I suspect you can find cases both ways.

What I do know is that we do need the try_to_free_buffer() approach anyway
from a VM standpoint, so I know that in that sense try_to_free_buffer() is
much superior in that it can do everything we want, and
flush_dirty_buffers() really doesn't cut it in that way.

Note that from a VM standpoint, there are real disadvantages from using
the flush_dirty_buffers() stuff - we may end up doing IO that we should
never have done at all, because flush_dirty_buffers() can write out stuff
that isn't needed from a VM standpoint.

> Furthermore, we'll need to preserve the data writeback list,
> since you really want to write back old data to disk some
> time.

Aging will certainly take care of that. As long as you do the writeback
_before_ you age it.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
