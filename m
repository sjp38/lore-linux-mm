Date: Sat, 3 Jun 2000 18:29:34 -0700 (PDT)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: classzone-31
In-Reply-To: <Pine.LNX.4.21.0006032113330.17414-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0006031723550.542-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 3 Jun 2000, Rik van Riel wrote:

>1) could you explain your shrink_mmap changes?
>   why do they work?

I made shrink_mmap to only browse the unmapped pages. Actually you know
this shrink_mmap design changes have nothing to do with the classzone part
of the patch but it happened that I developed it in parallel while working
on the classzone stuff and I didn't had the time to split the orthogonal
parts of the classzone patch in separate patches yet...

Due this first design change I can now avoid to waste time on the mapped
pages, so I as well splitted the lru in two parts, one for unmapped swap
cache and one for page cache. The first lru (swap cache one) is always
shrunk first. Only this further design change allows the system to keep to
run smooth under heavy swap. There's a kind of autobalance. As first the
swap cache is a lower priority cache because the swap cache were not
recently touched in first place (during swapout I see the swap cache more
a locking entity than a real cache). As second the swap-cache-lru acts as
a protection to the filesystem cache: the more I/O is going on the more we
walk pagetables without eating the useful cache.

Another change I did is to not mark the cache as referenced when I
allocate it. I just described the goodness of this change in l-k recently.
We can't do that in 2.2.x because we don't have an LRU, but now we can
instead allow also the first pass of shrink_mmap to be useful and more
important we can provide better aging to the working set.

With swap_out we still can't avoid to waste the first pass due the round
robin algorithm.

>2) why are you backing out bugfixes made by Linus and
>   other people?  what does your patch gain by that?
>   (eg the do_try_to_free_pages stuff)

I backed out everything that looked not correct (even if only in a corner
case and not in the common case) or that looked not worty enough.

About the do_try_to_free_pages changes I did, they're necessary to pass to
shrink_mmap and friends the classzone from which we must generate free
pages. If you don't pass to them the classzone (as it happens in clean
2.4.0-test1-ac7) you'll have to use suboptimal algorithm (as
2.4.0-test1-ac7 does) that will simply end to free more memory than
necessary and also wasting CPU and hurting the LRU behaviour of
shrink_mmap. I don't consider as bugfixes the recent changes that happened
in do_try_to_free_pages during 2.3.99-pre.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
