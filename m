Message-ID: <00ba01bfd240$4fdebac0$0a1e17ac@local>
From: "Manfred Spraul" <manfred@colorfullife.com>
References: <Pine.LNX.4.21.0006091410100.31358-100000@duckman.distro.conectiva>
Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel:it'snot just the code)
Date: Fri, 9 Jun 2000 20:26:48 +0200
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Is it correct that you want to use 5 levels?

* "mapped" or "hot file cache" / "hot buffer cache"
* active [here your page aging is performed]
* inactive list
* scavenge list
* gfp buddy list.

I thought that unmapping of the last externally visible mapping will move a
page into the inactive list, and the LRU nature of that list will perform
the aging. Is your inactive list a usually short clock like list? My
inactive list is a long LRU list. If the scavenge list gets empty, then the
last few dozend entries would be spliced out from the inactive list, and
page->a_op->we_need_memory__unpin_yourself_and_add_yourself_to_the_scavenge_
list() is called.


From: "Rik van Riel" <riel@conectiva.com.br>
> > You are right, but what will you do with pinned pages once they
> > reach the end of the LRU? Will you drop them from the LRU, or
> > will you add them to the beginning?
>
> We will ask the filesystem to write out data and unpin this
> block. If it doesn't, we'll ask again next time, ....
>

Why? E.g. you have a box with a fast raid array, and a slow parallel port
zip drive. I'd give the filesystem one "flush now" call for the page, and
remove the page immediately from the inactive list. If you walk circles,
then it's a clock like algorithm, not LRU like.

>
> Ahh, but the swap and filesystem IO will be triggered from the
> end of the _inactive_ list. We will unmap pages and allocate
> swap earlier on, but we won't actually do any of the IO...
>
Hey, I only have 192 MB. One kernel tree is ~90 MB, a diff between 2 trees
180 MB. One diff will push everything behind the end of the inactive list.

> > The selection between the Level 1 page holders could be made on
> > their "reanimate rate": if one owner often request pages from
> > Level 2 or 3 back, then we reap him too often.
>
> That's what page aging is for.
>
If a subsystem request a page back from the inactive/scavenge list, then we
must remove the page from these lists. We could use these function calls to
calculate accurate hit/miss rates for the memory users, and use these stats
for the page aging without a special aging level.

We could go one step further and assign these stats to each address space
[file data, shm]//each process [anon pages,mmap]. Playing a DVD & running a
database could auto-tune into discard the DVD data immediately, don't touch
the database data.

--
    Manfred



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
