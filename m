Date: Tue, 11 Jul 2000 12:50:06 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [PATCH] 2.2.17pre7 VM enhancement Re: I/O performance on 2.4.0-test2
Message-ID: <20000711125006.S1054@redhat.com>
References: <20000706142945.A4237@redhat.com> <Pine.LNX.4.21.0007081139400.757-100000@inspiron.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0007081139400.757-100000@inspiron.random>; from andrea@suse.de on Sun, Jul 09, 2000 at 10:31:46PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, Rik van Riel <riel@conectiva.com.br>, Jens Axboe <axboe@suse.de>, Alan Cox <alan@redhat.com>, Derek Martin <derek@cerberus.ne.mediaone.net>, Linux Kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, Jul 09, 2000 at 10:31:46PM +0200, Andrea Arcangeli wrote:
> 
> Think what happens if we shrink lru_mapped first.

It's not supposed to work that way.

> Note I'm not thinking to fallback into lru_mapped when lru_cache is empty,
> but probably doing something like, free 3 times from lru_cache and 1 from
> lru_mapped could work. The 3 times should be a dynamic variable that
> changes in function of the pressure that we have in the lru_cache.

No, the mechanism would be that we only free pages from the scavenge
or cache lists.  The mapped list contains only pages which _can't_ be
freed.  The dynamic memory pressure is used to maintain a goal for the
number of pages in the cache list, and to achieve that goal, we
perform aging on the mapped list.  Pages which reach age zero can be
unmapped and added to the cache list, from where they can be
reclaimed.

In other words, the queues naturally assist us in breaking apart the
jobs of freeing pages and aging mappings.  

> I think it's better to have a global LRU_DIRTY (composed by any dirty
> object) and to let kupdate to flush not only the old dirty buffers, but
> also the old dirty pages.

We _must_ have separate dirty behaviour for dirty VM pages and for
writeback pages.  Think about a large simulation filling most of main
memory with dirty anon pages --- we don't want write throttling to
kick in and swap out all of that memory!  But for writeback data ---
data dirtied by the filesystem directly, not just by the VM --- we
definitely want to keep control of the amount of dirty memory.

Cheers,
 Stephen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
