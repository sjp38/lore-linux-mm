Date: Fri, 12 May 2000 12:06:13 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] balanced highmem subsystem under pre7-9
In-Reply-To: <Pine.LNX.4.10.10005122044130.6188-200000@elte.hu>
Message-ID: <Pine.LNX.4.10.10005121200590.4959-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Rik van Riel <riel@conectiva.com.br>, Andrea Arcangeli <andrea@suse.de>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


On Fri, 12 May 2000, Ingo Molnar wrote:
> 
> i initially tested pre7-9 and it showed bad behavior: high kswapd activity
> trying to balance highmem, while the pagecache is primarily filled from
> the highmem. I dont think this can be fixed without 'silencing'
> ZONE_HIGHMEM's balancing activities: the pagecache allocates from highmem
> so it puts direct pressure on the highmem zone.

If this is true, then that is a bug in the allocator.

I tried very hard (but must obviously have failed), to make the allocator
_always_ do the right thing - never allocating from a zone that causes
memory balancing if there is another zone that is preferable. 

> This had two effects: wasted CPU time, but it also limited the
> page-cache's maximum size to the size of highmem. I'll try the final
> pre7-2.3.99 kernel as well in a minute to make sure. (i think the bad
> behavior is still be there, judging from the differences between pre9 and
> the final patch.)

Please fix the memory allocator instead. It should really go to the next
zone instead of allocating more from the highmem zone.

Actually, I think the real bug is kswapd - I thought the "for (;;)" loop
was a good idea, but I've since actually thought about it more, and in
real life we really just want to go to sleep when we need to re-schedule,
because if there is any _real_ memory pressure people _will_ wake us up
anyway. So before you touch the memory allocator logic, you might want to
change the

	if (tsk->need_resched)
		schedule();

to a 

	if (tsk->need_resched)
		goto sleep;

(and add a "sleep:" thing to inside the if-statement that makes us go to
sleep). That way, if we end up scheduling away from kswapd, we won't waste
time scheduling back unless we really should.

But do check out __alloc_pages() too, maybe you see some obvious bug of
mine that I just never thought about.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
