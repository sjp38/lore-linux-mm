From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200001131830.KAA72001@google.engr.sgi.com>
Subject: Re: [RFC] 2.3.39 zone balancing
Date: Thu, 13 Jan 2000 10:30:00 -0800 (PST)
In-Reply-To: <Pine.LNX.4.21.0001131806190.1648-100000@alpha.random> from "Andrea Arcangeli" at Jan 13, 2000 06:12:45 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Linus Torvalds <torvalds@transmeta.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

> 
> On Wed, 12 Jan 2000, Kanoj Sarcar wrote:
> 
> >+There are two reasons to be requesting non __GFP_WAIT allocations:
> >+the caller can not sleep (typically intr context), or does not want
> >+to incur cost overheads of page stealing and possible swap io.
> 
> You may be in a place where you can sleep but you can't do I/O to avoid
> deadlocking and so you shouldn't use __GFP_IO and nothing more (it has
> nothing to do with __GFP_WAIT).

You are right: the documentation should read:

+Memory balancing is _only_ needed for non __GFP_WAIT and non __GFP_IO allocations.
+
+There are two reasons to be requesting non __GFP_WAIT allocations:
+the caller can not sleep (typically intr context), or does not want
+to incur cost overheads of page stealing and possible swap io.
+
+Non __GFP_IO allocations are requested to prevent filesystem deadlocks.

But I would not say __GFP_WAIT and __GFP_IO have no relationship. __GFP_IO
does not make sense if __GFP_WAIT is not set. 

> 
> But if it can sleep and there aren't deadlock conditons going on and it
> doesn't use __GFP_WAIT, it means it's buggy and has to be fixed.
> 

Well, I thought about that while coding the patch: you can not try to 
outsmart the programmer who writes that code. For example, I was 
looking at replace_with_highmem() which makes __GFP_HIGHMEM|__GFP_HIGH
requests, although I _think_ it can do __GFP_WAIT|__GFP_IO without
any problems. I just assumed that whoever coded it (you/Mingo?) had
some logic, like not wanting to waste time scanning for stealable pages
or incur disk swap to implement this performance optimization (that
would defeat the optimization).

Kanoj

> I have not read the rest and the patch yet (I'll continue ASAP).
> 
> Andrea
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.nl.linux.org/Linux-MM/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
