Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id SAA19995
	for <linux-mm@kvack.org>; Mon, 9 Sep 2002 18:13:43 -0700 (PDT)
Message-ID: <3D7D4747.5F73D7FB@digeo.com>
Date: Mon, 09 Sep 2002 18:13:43 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [PATCH] modified segq for 2.5
References: <Pine.LNX.4.44L.0208151119190.23404-100000@imladris.surriel.com> <3D7C6C0A.1BBEBB2D@digeo.com> <E17oXIx-0006vb-00@starship> <3D7D277E.7E179FA0@digeo.com> <20020909234044.GJ18800@holomorphy.com> <3D7D3697.1DE602D1@digeo.com> <20020910002123.GK18800@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Daniel Phillips <phillips@arcor.de>, Rik van Riel <riel@conectiva.com.br>, sfkaplan@cs.amherst.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> 
> William Lee Irwin III wrote:
> >> This seemed to work fine when I just tweaked problem areas to use
> >> __GFP_NOKILL. mempool was fixed by the __GFP_FS checks, but
> >> generic_file_read(), generic_file_write(), the rest of filemap.c,
> >> slab allocations, and allocating file descriptor tables for poll() and
> >> select() appeared to generate OOM when it appeared to me that failing
> >> system calls with -ENOMEM was a better alternative than shooting tasks.
> 
> On Mon, Sep 09, 2002 at 05:02:31PM -0700, Andrew Morton wrote:
> > But clearly there is reclaimable pagecache down there; we just
> > have to wait for it.  No idea why you'd get an oom on ZONE_HIGHMEM,
> > but when I have a few more gigs I might be able to say.
> > Anyway, it's all too much scanning.
> 
> Well, there was no swap, and most things were dirty. Not sure about the
> rest. I was miffed by "Something tells it there's no memory and it
> shoots tasks instead of returning -ENOMEM to userspace in a syscall?"
> Saying "no" to the task allocating seems better than shooting tasks to
> me. out_of_memory() being called too early sounds bad, too, though.

If there is dirty memory or memory under writeback then
going oom or returning NULL is a bug.

It's just a search problem, and not a very complex one.  Per-zone
dirty accounting, per-zone throttling and a separate known-to-be-unreclaimable list should fix it up.  Give me
a few days to find a motivated moment...
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
