Date: Tue, 11 Jul 2000 19:33:50 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] 2.2.17pre7 VM enhancement Re: I/O performance on
 2.4.0-test2
In-Reply-To: <yttn1jomxnb.fsf@serpe.mitica>
Message-ID: <Pine.LNX.4.21.0007111917240.3644-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, Rik van Riel <riel@conectiva.com.br>, Jens Axboe <axboe@suse.de>, Alan Cox <alan@redhat.com>, Derek Martin <derek@cerberus.ne.mediaone.net>, Linux Kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi Juan,

On 11 Jul 2000, Juan J. Quintela wrote:

>I agree with Stephen here, if my cache page is older than my mmaped vi
>page, I want to unmap first the vi page.

You said it in the other way around ;) but never mind I got your point
indeed.

With the logic "if my cache page is younger than my mmaped vi page, I want
to unmap first the vi page" then when you'll run:

	cp /dev/zero .

or also:

	find /usr/ -type f -exec cp {} /dev/null \;

(and also rsync of course)

and you'll start hanging in gnus, while switching desktop, while switching
window, while pressing a key in bash, and indeed also while pressing a key
in vi. For what? The cache got polluted because you only had 32mbyte of
ram so the second run of the above command will cause exactly the same
hangs all over the tasks.

I don't think that is a sane behaviour. I think caches have very different
priorities due the semantics of their objects.

And also think the swap_cache. When I add a page to the lru_swap_cache for
a swapout, it means that such page is the less interesting one of all the
VM, it means that it is the page that we are not interested at all to keep
in memory. It means we should throw it away ASAP. The swap_cache is only a
locking entitiy that avoids us to allocate a static and slow swap lockmap
for the swapouts. With current global lru to get rid of the
less-interesting-of-all swap cache we first have to throw away all the
cache in the lru and that hurts very much. That's one of the reasons
classzone is more responsive and deliver better performance under swap
load, because it knows it have to try to throw away the swap_cache first.

>andrea> I see what you plan to do. Fact is that I'm not convinced it's necessary
>andrea> and I prefer to have a dynamic falling back algorithms between caches that
>andrea> will avoid me to have additional lru lists and additional refile between
>andrea> lrus. Also I will be able to say when I did progress because my progress
>andrea> will _always_ correspond to a page freed (so I'll remove the unrobusteness
>andrea> of the current swap_out completly).
>
>Yes, but you have to find a _magic_ number for knowing when to free
>for the maped pages/cache pages.  That number comes for free with the
>inactive list implementation and is based in the actual workload,
>i.e. we don't need to guess.

Well, I'm pretty sure that with your design you'll end needing a magic
number too somewhere and it might be going to be more subtle than mine.
Also note that in someway I want that number to be dynamic. And of course
we have magic numbers also in current 2.[234].x.

Suppose you run out of lru_cache, then you start refiling the inactive
list, then you'll have to choose how much to unmap from the active list
and to put into the inactive list. How much stuff will you refile? 10
mapped pages or 20, or 30? If you unmap only one page then you could as
well move it directly to the lru_cache dropping the inactive or dirty
list, right? ;)

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
