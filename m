Date: Mon, 15 May 2000 16:59:47 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Estrange behaviour of pre9-1
In-Reply-To: <yttzoprxw05.fsf@vexeta.dc.fi.udc.es>
Message-ID: <Pine.LNX.4.10.10005151651140.812-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On 16 May 2000, Juan J. Quintela wrote:
> 
>        The one that more helped is Linus patch, it helps a lot in
> performance, we go almost as fast as 2.2, the problem with this patch
> is that sometimes we get out of memory errors (much less than with
> vanilla kernel, but in 5/6 tries we get the error in init, and after
> that the system freezes the same that previous paragraph.  Another
> problem of the patch is that we spend *a lot of time* in the kernel,
> system time has increased a lot.

Ok.

The system time increase I wouldn't worry about that much, as long as it's
still clearly smaller than the real time. If we did a better job of
writing stuff out so that the real time goes down, it's almost certainly
the right thing to do.

The fact that Rik's patch performs so badly is interesting in itself, and
I thus removed it from my tree.

I think I have a reasonable alternative to Rik's patch, which is to give
"negative brownie-points" to allocators after the fact. It should be
fairer to the person who frees up memory than the current one, by simply
re-ordering the requirement for freeing memory. The theory goes as
follows:

_Most_ of the time when "try_to_free_pages()" is called, the memory
actually exists, and we call try_to_free_pages() mainly because we want to
make sure that we don't get into a bad situation.

So, how about doing something like:

 - if memory is low, allocate the page anyway if you can, but increment a
   "bad user" count in current->user->mmuse;
 - when entering __alloc_pages(), if "current->user->mmuse > 0", do a
   "try_to_free_pages()" if there are any zones that need any help
   (otherwise just clear this field).

Think of it as "this user can allocate a few pages, but it's on credit.
They have to be paid back with the appropriate 'try_to_free_pages()'".

Couple this with raising the low-water-mark a bit, and it should work out
fine: the guy who does the "try_to_free_pages()" is always the one that
gets to be credited with it by actually allocating a page. And if kswapd
runs quickly enough that it's not needed, all the better.

Rik? I think this would solve the fairness concerns without the need to
tell the rest of the world about a process trying to free up memory and
causing bad performance..

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
