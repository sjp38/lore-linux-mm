From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14190.16136.552955.557245@dukat.scot.redhat.com>
Date: Mon, 21 Jun 1999 14:32:56 +0100 (BST)
Subject: Re: [RFC] [RFT] [PATCH] kanoj-mm9-2.2.10 simplify swapcache/shm code interaction
In-Reply-To: <199906192314.QAA33843@google.engr.sgi.com>
References: <199906192314.QAA33843@google.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: linux-mm@kvack.org, torvalds@transmeta.com, sct@redhat.com, andrea@suse.de
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, 19 Jun 1999 16:14:26 -0700 (PDT), kanoj@google.engr.sgi.com
(Kanoj Sarcar) said:

> There is no reason for shared memory pages to have to be marked
> PG_swap_cache to fool the underlying swap io routines. 

That code was never intended to "fool" anyone: the swap IO code is able
to do read/write swap even in the absense of swap cache entries for the
page.  Only recently have we forced all swap to go through the swap
cache, but the IO routines are still capable of doing it both ways.

> -	if (PageSwapCache(page)) {
> +	if (!shmfs) {
>  		/* Make sure we are the only process doing I/O with this swap page. */
>  		while (test_and_set_bit(offset,p->swap_lockmap)) {
>  			run_task_queue(&tq_disk);

This looks wrong, conceptually.  I'd prefer to see us do the locking any
time the page happens to have an appropriate swap lock map bit.
PageSwapCache() is the right test in this case: the rw_swap_page stuff
shouldn't care about whether it is shmfs calling it or not.  It should
just care about doing the swap cache locking correctly if that happens
to be required.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
