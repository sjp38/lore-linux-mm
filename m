Date: Fri, 7 Apr 2000 15:14:55 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] take 2 Re: PG_swap_entry bug in recent kernels
In-Reply-To: <Pine.LNX.4.21.0004070950570.23401-100000@duckman.conectiva>
Message-ID: <Pine.LNX.4.21.0004071507030.1367-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: Ben LaHaise <bcrl@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 7 Apr 2000, Rik van Riel wrote:

>Won't this screw up when another processor is atomically
>setting the bit just after we removed it and we still have
>it in the store queue?
>
>from include/asm-i386/spinlock.h
>/*
> * Sadly, some early PPro chips require the locked access,
> * otherwise we could just always simply do
> *
> *      #define spin_unlock_string \
> *              "movb $0,%0"
> *
> * Which is noticeably faster.
> */
>
>I don't know if it is relevant here, but would like to
>be sure ...

The spin_unlock case is actually not relevant, I wasn't relying on it in
first place since I was using C (which can implement the
read/change/modify in multiple instruction playing with registers).

The reason we can use C before putting the page into the freelist, is
because we know we don't risk to race with other processors. We are
putting the page into the freelist and if another processor would be
playing someway with the page we couldn't put it on the freelist in first
place.

If some other processor/task is referencing the page while we call
free_pages_ok, then that would be a major MM bug.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
