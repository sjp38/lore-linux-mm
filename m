Received: from localhost.localdomain (groudier@ppp-103-100.villette.club-internet.fr [194.158.103.100])
	by kvack.org (8.8.7/8.8.7) with ESMTP id EAA17289
	for <linux-mm@kvack.org>; Sat, 5 Dec 1998 04:35:38 -0500
Date: Sat, 5 Dec 1998 10:46:40 +0100 (MET)
From: Gerard Roudier <groudier@club-internet.fr>
Subject: Re: [PATCH] swapin readahead and fixes
In-Reply-To: <199812041434.OAA04457@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.95.981205102900.449A-100000@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>



On Fri, 4 Dec 1998, Stephen C. Tweedie wrote:

> Hi,
> 
> On Fri, 4 Dec 1998 15:02:56 +0100 (CET), Rik van Riel
> <H.H.vanRiel@phys.uu.nl> said:
> 
> >> One odd thing about the readahead: you don't start the readahead until
> >> _after_ you have synchronously read in the first swap page of the
> >> cluster.  Surely it is better to do the readahead first, so that you
> >> are submitting one IO to disk, not two?
> 
> > This would severely suck when something else would be doing
> > a run_taskqueue(&tq_disk). It would mean that we'd read
> > n+1..n+15 before n itself.
> 
> No, not at all.  This is already the way we do all readahead
> everywhere in the kernel.  
> 
> The idea is to do readahead for all the data you want, *including* the
> bit you are going to need right away.  Once that is done, you just
> wait for the IO to complete on that first item.

Indeed.

In the old time, swapping and paging were different things, but they seems 
to be confused in Linux.

You may perform read-ahead when you really swap in a process that had been
swapped out. But about paging, you must consider that this mechanism is
not sequential but mostly ramdom in RL. So you just want to read more data
at the same time and near the location that faulted. Reading-ahead is
obviously candidate for this optimization, but reading behind must also be
considered in my opinion.

File read-ahead is based on the way that data file are often accessed 
sequentially by applications and we have to detect this behaviour prior 
to reading ahead large data blocks.
For mmapped file, you may want to allow applications to tell you as 
they intend to access data and trust them. But for paging, you just 
want to read more data than 1 single page at a time, assuming that 
data near the faulted address have good chances to be accessed by 
the application soon.

That's my current opinion on this topic.

Regards,
   Gerard.

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
