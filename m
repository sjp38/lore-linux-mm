Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA26499
	for <linux-mm@kvack.org>; Sun, 4 Apr 1999 20:50:39 -0400
Date: Mon, 5 Apr 1999 02:22:35 +0200 (CEST)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] arca-vm-2.2.5
In-Reply-To: <Pine.BSF.4.03.9904041657210.15836-100000@funky.monkey.org>
Message-ID: <Pine.LNX.4.05.9904050033340.779-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Chuck Lever <cel@monkey.org>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Sun, 4 Apr 1999, Chuck Lever wrote:

>> 	ftp://e-mind.com/pub/linux/arca-tree/2.2.5_arca2.gz

*snip*

>first, i notice you've altered the page hash function and quadrupled the

The page hash function change is from Stephen (I did it here too because I
completly agreed with it). The point is that shm entries uses the lower
bits of the pagemap->offset field.

>size of the hash table.  do you have measurements/benchmarks that show
>that the page hash was not working well?  can you say how a plain 2.2.5

The page_hash looked like to me a quite obvious improvement while swapping
in/out shm entreis (it will improve the swap cache queries) but looks my
comment below...

>kernel compares to one that has just the page hash changes without the
>rest of your VM modifications? the reason i ask is because i've played

The reason of that is that it's an obvious improvement. And since it's
statically allocated (not dynamically allocated at boot in function of the
memory size) a bit larger default can be desiderable, I can safely alloc
some more bit of memory (some decade of kbyte) without harming the
avalilable mm here. Well, as I just said many times I think someday we'll
need RB-trees instead of fuzzy hash but it's not a big issue right now
due the so low number of pages available.

Returning to your question in my tree I enlarged the hashtable to 13 bit.
This mean that in the best case I'll be able to address in O(1) up to 8192
pages. Here I have 32752 pages so as worse I'll have 4 pages chained on
every hash entry. 13 bits of hash-depth will alloc for the hash 32k of
memory (really not an issue ;).

In the stock kernel instead the hash size is 2^11 = 2048 so in the worst
case I would have 16 pages chained in the same hash entry.

>with that hash table, and found most changes to it cause undesirable
>increases in system CPU utilization.  although, it *is* highly interesting

Swapping out/in shm entries is not a so frequent task as doing normal
query on the page cache. So I am removing the patch here. Thanks for the
info, I really didn't thought about this...

For the record this is the hash-function change we are talking about:

Index: pagemap.h
===================================================================
RCS file: /var/cvs/linux/include/linux/pagemap.h,v
retrieving revision 1.1.1.2
retrieving revision 1.1.2.12
diff -u -r1.1.1.2 -r1.1.2.12
--- pagemap.h	1999/01/23 16:29:55	1.1.1.2
+++ pagemap.h	1999/04/01 23:12:37	1.1.2.12
@@ -36,7 +35,7 @@
 #define i (((unsigned long) inode)/(sizeof(struct inode) & ~ (sizeof(struct inode) - 1)))
 #define o (offset >> PAGE_SHIFT)
 #define s(x) ((x)+((x)>>PAGE_HASH_BITS))
-	return s(i+o) & (PAGE_HASH_SIZE-1);
+	return s(i+o+offset) & (PAGE_HASH_SIZE-1);
 #undef i
 #undef o
 #undef s

>that the buffer hash table is orders of magnitude larger, yet hashes about
>the same number of objects.  can someone provide history on the design of
>the page hash function?

I can't help you into this, but looks Ok to me ;). If somebody did the
math on it I'd like to try understanding it.

>also, can you tell what improvement you expect from the additional logic
>in try_to_free_buffers() ?

Eh, my shrink_mmap() is is a black magic and it's long to explain what I
thought ;). Well one of the reasons is that ext2 take used the superblock
all the time and so when I reach an used buffers I'll put back at the top
of the lru list since I don't want to go in swap because there are some
unfreeable superblock that live forever at the end of the pagemap
lru_list.

Note also (you didn't asked about that but I bet you noticed that ;) that
in my tree I also made every pagemap entry L1 cacheline aliged. I asked to
people that was complainig about page colouring (and I still don't know
what is exactly page colouring , I only have a guess but I would like to
read something about implementation details, pointers???) to try out my
patch to see if it made differences; but I had no feedback :(. I also
made the irq_state entry cacheline aligned (when I understood the
cacheline issue I agreed with it).

Many thanks for commenting and reading my new experimental code (rock
solid here). I'll release now a:

	ftp://e-mind.com/pub/linux/arca-tree/2.2.5_arca4.bz2

It will have my latest stuff I did (flushtime-bugfix included and sane
sysctl values included too) in the last days plus the old hash-function
for the reasons you pointed out to me now.

If you'll find some spare time to try out the new patch let me know the
numbers! ;))

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
