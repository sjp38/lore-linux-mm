Date: Tue, 11 Jul 2000 18:17:25 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] 2.2.17pre7 VM enhancement Re: I/O performance on
 2.4.0-test2
In-Reply-To: <20000711125006.S1054@redhat.com>
Message-ID: <Pine.LNX.4.21.0007111756200.3644-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, Rik van Riel <riel@conectiva.com.br>, Jens Axboe <axboe@suse.de>, Alan Cox <alan@redhat.com>, Derek Martin <derek@cerberus.ne.mediaone.net>, Linux Kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 11 Jul 2000, Stephen C. Tweedie wrote:

>Hi,
>
>On Sun, Jul 09, 2000 at 10:31:46PM +0200, Andrea Arcangeli wrote:
>> 
>> Think what happens if we shrink lru_mapped first.
>
>It's not supposed to work that way.

Think if I shrink the lru_mapped first. you could have 100mbyte of clean
and unmapped cache and before shrinking it you would unmap `vi`. So you
would unmap/swapout vi from memory while you still have 100mbyte of
freeable cache. Isn't that broken? The other way around is much more sane.
With the other way around as worse you will have zero fs cache and you'll
run just like DOS.

The object of this simple example is to show that the lrus have different
priorities. These priorities will probably change in function of the
workload of course but we can try to take care of that.

>> Note I'm not thinking to fallback into lru_mapped when lru_cache is empty,
>> but probably doing something like, free 3 times from lru_cache and 1 from
>> lru_mapped could work. The 3 times should be a dynamic variable that
>> changes in function of the pressure that we have in the lru_cache.
>
>No, the mechanism would be that we only free pages from the scavenge
>or cache lists.  The mapped list contains only pages which _can't_ be
>freed. [..]

We will be _able_ free them on the fly instead. The only point of the
page2ptechain reverse lookup is to be able to free them on the fly and
nothing else.

>[..] The dynamic memory pressure is used to maintain a goal for the
>number of pages in the cache list, and to achieve that goal, we
>perform aging on the mapped list.  Pages which reach age zero can be
>unmapped and added to the cache list, from where they can be
>reclaimed.
>
>In other words, the queues naturally assist us in breaking apart the
>jobs of freeing pages and aging mappings.  

I see what you plan to do. Fact is that I'm not convinced it's necessary
and I prefer to have a dynamic falling back algorithms between caches that
will avoid me to have additional lru lists and additional refile between
lrus. Also I will be able to say when I did progress because my progress
will _always_ correspond to a page freed (so I'll remove the unrobusteness
of the current swap_out completly).

>> I think it's better to have a global LRU_DIRTY (composed by any dirty
>> object) and to let kupdate to flush not only the old dirty buffers, but
>> also the old dirty pages.
>
>We _must_ have separate dirty behaviour for dirty VM pages and for
>writeback pages.  Think about a large simulation filling most of main
>memory with dirty anon pages --- we don't want write throttling to
>kick in and swap out all of that memory!  But for writeback data ---

Good point (I was always thinking about MAP_SHARED but MAP_ANON is dirty
in the same way indeed). So I think at first step I'll left the dirty
pages into the lru_mapped lru. With the locked-pages-out-of-the-lru trick
I could reinsert them to the bottom of the lru (old pages) when the I/O is
completed so that we could free them without rolling the lru again.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
