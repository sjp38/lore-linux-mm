Date: Sun, 9 Jul 2000 22:31:46 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] 2.2.17pre7 VM enhancement Re: I/O performance on
 2.4.0-test2
In-Reply-To: <20000706142945.A4237@redhat.com>
Message-ID: <Pine.LNX.4.21.0007081139400.757-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, Rik van Riel <riel@conectiva.com.br>, Jens Axboe <axboe@suse.de>, Alan Cox <alan@redhat.com>, Derek Martin <derek@cerberus.ne.mediaone.net>, Linux Kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 6 Jul 2000, Stephen C. Tweedie wrote:

>concern identifying which pages to throw out or how to age them.
>Rik's multi-queued code, or the new code from Ludovic Fernandez which
>separates out page aging to a different thread.

I don't think it's orthogonal (at least not completly).

>> So basically we'll have these completly different lists:
>> 
>> 	lru_swap_cache
>> 	lru_cache
>> 	lru_mapped
>> 
>> The three caches have completly different importance that is implicit by
>> the semantics of the memory they are queuing.
>
>I think this is entirely the wrong way to be thinking about the
>problem.  It seems to me to be much more important that we know:

Think what happens if we shrink lru_mapped first. That would be an
obviously wrong behaviour and this proof we have to consider a priority
between lists.

Note I'm not thinking to fallback into lru_mapped when lru_cache is empty,
but probably doing something like, free 3 times from lru_cache and 1 from
lru_mapped could work. The 3 times should be a dynamic variable that
changes in function of the pressure that we have in the lru_cache.

Using an inactive lru for providing a dynamic behaviour or to provide
longer life to mapped pages looks bloating, if something I think it's
better to do more aggressive aging within the lru_cache itself.

>1) What pages are unreferenced by the VM (except for page cache
>references) and which can therefore be freed at a moment's notice;

That's the lru_cache and it's just implemented in classzone patch just
working fine. (it doesn't include any mapped pages, it only includes
unreferenced pages unlike current v2.4)

>2) What pages are queued for write;

I think it's better to have a global LRU_DIRTY (composed by any dirty
object) and to let kupdate to flush not only the old dirty buffers, but
also the old dirty pages. The pages have to be at the same time on the
LRU_DIRTY and on the lru_mapped or lru_cache so that's not really a list
in the same domain of lru_cache/lru_mapped and LRU_DIRTY. And we'll need
this anyway for allocate on flush (we for sure don't want to enter the fs
in any way [except than for accounting of the decreased available space to
assure the flush to succeed] before the dirty pages become old)

>3) what pages are referenced and in use for other reasons.

That's the lru_mapped. And to implement lru_mapped I will only need to
change lru_cache_map/unmap macro of the classzone patch since I just have
all the necessary hooks in place.

>Completely unreferenced pages can be freed on a moment's notice.  If

That's what I'm doing with lru_cache.

>we are careful with the spinlocks we can even free them from within an
>interrupt.  

That would cause us to use an irq spinlock in shrink_mmap and I'm not sure
this is good idea.

Talking about irq spinlocks I'd love to keep the pages under I/O out of
the lru too but I can't trivially because I can't grab the lru-spinlock
from the irq completation handler (since the spinlock of the LRU isn't an
irq spinlock). To workaround the irq spinlock thing (but to be still able
to keep locked pages out of the lru), I thought to split each list in two:

	lru_swap_cache
	lru_cache
	lru_mapped_cache

in:

	lru_swap_cache_irq
	lru_swap_cache

	lru_cache_irq
	lru_cache

	lru_mapped_cache_irq
	lru_mapped_cache

the lru_*_irq will be lists available _only_ with an irq spinlock held.

So then when we'll want to swapout an anonymous pages, instead of adding
it to the lru_swap_cache, we'll simply left it out of any lru list and
we'll start the I/O forgetting about it. Then the IRQ completion irq
handler will insert the page into the lru_swap_cache_irq, and it will
queue a task-scheduler tasklet for execution. This tasklet will simply
grab the lru_swap_cache_irq spinlock and it will extract the pages from
such list, and it will put the pages into the lru_swap_cache (it can
acquire the non-irq lru_swap_cache spinlock because it won't run from
irqs). I guess I'll try this trick once the stuff described in my previous
email will work.

>By measuring the throughput of these different page classes we can
>work out what the VM pressure and write pressure is.  When we get a

I agree, in my way I see it like: the falling back algorithm between lrus
should be dynamic and it should have some knowledge on the pressure going
on.

For the write pressure the thing should be really in a separated domain 
that is the current BUF_DIRTY that we have now.

I think instead it should be the list that kupdate is browsing that should
also include the dirty pages (and the dirty pages can be at the same time
also in the lru_mapped_cache of course so from a VM point of view dirty
pages will stay in lru_cache and lru_mapped_cache, and not on a
dedicated VM-lru list).

>write page fault, we can (for example) block until the write queue
>comes down to a certain size, to obtain write flow control.

Right, however we don't need a new page-lru for this, we simply need to
account for dirty pages in do_wp_page and no-page, and to extend the
current BUF_DIRTY list and to run kupdate will work on them too.

I'm not sure if somebody is abusing the missing (and I think also broken)
flush-old-buffers behaviour of the MAP_SHARED segment to build kind of SHM
memory with sane interface, in such case the app should be changed to use
new shm_open sane interface which is not that different than the old trick
after all.

>More importantly, the scanning of the dirty and in-use queues can go
>on separately from the freeing of clean pages.  The more memory

That's not what I planned to do for now. I'd prefer to learn when it's
time to fallback between the lists than to have to bloat with an
additional list. However I may as well change idea over the time.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
