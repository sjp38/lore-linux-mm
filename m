Date: Mon, 9 Sep 2002 17:21:23 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] modified segq for 2.5
Message-ID: <20020910002123.GK18800@holomorphy.com>
References: <Pine.LNX.4.44L.0208151119190.23404-100000@imladris.surriel.com> <3D7C6C0A.1BBEBB2D@digeo.com> <E17oXIx-0006vb-00@starship> <3D7D277E.7E179FA0@digeo.com> <20020909234044.GJ18800@holomorphy.com> <3D7D3697.1DE602D1@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <3D7D3697.1DE602D1@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Daniel Phillips <phillips@arcor.de>, Rik van Riel <riel@conectiva.com.br>, sfkaplan@cs.amherst.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
>> This seemed to work fine when I just tweaked problem areas to use
>> __GFP_NOKILL. mempool was fixed by the __GFP_FS checks, but
>> generic_file_read(), generic_file_write(), the rest of filemap.c,
>> slab allocations, and allocating file descriptor tables for poll() and
>> select() appeared to generate OOM when it appeared to me that failing
>> system calls with -ENOMEM was a better alternative than shooting tasks.

On Mon, Sep 09, 2002 at 05:02:31PM -0700, Andrew Morton wrote:
> But clearly there is reclaimable pagecache down there; we just
> have to wait for it.  No idea why you'd get an oom on ZONE_HIGHMEM,
> but when I have a few more gigs I might be able to say.
> Anyway, it's all too much scanning.

Well, there was no swap, and most things were dirty. Not sure about the
rest. I was miffed by "Something tells it there's no memory and it
shoots tasks instead of returning -ENOMEM to userspace in a syscall?"
Saying "no" to the task allocating seems better than shooting tasks to
me. out_of_memory() being called too early sounds bad, too, though.


On Mon, Sep 09, 2002 at 05:02:31PM -0700, Andrew Morton wrote:
> You'll probably find that segq helps by accident.  I installed
> SEGQ (and the shrink-slab-harder-if-mapped-pages-are-enountered)
> on my desktop here.  Initial indications are that SEGQ kicks butt.

It seems to be a nice strategy a priori. It's good to hear initial
indications of the advantages coming out in practice. Something to
bench soon for sure.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
