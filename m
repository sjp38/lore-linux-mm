Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA23011
	for <linux-mm@kvack.org>; Mon, 21 Dec 1998 08:45:25 -0500
Date: Mon, 21 Dec 1998 13:39:42 GMT
Message-Id: <199812211339.NAA02125@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: New patch (was Re: [PATCH] swapin readahead v3 + kswapd fixes)
In-Reply-To: <Pine.LNX.3.95.981220060902.643A-100000@penguin.transmeta.com>
References: <199812192201.WAA04889@dax.scot.redhat.com>
	<Pine.LNX.3.95.981220060902.643A-100000@penguin.transmeta.com>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>, Andrea Arcangeli <andrea@e-mind.com>, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, 20 Dec 1998 06:18:23 -0800 (PST), Linus Torvalds
<torvalds@transmeta.com> said:

> This has Stephens page-in read-ahead code, and I clearly separated the
> cases where kswapd tries to throw something out vs a normal user - I
> suspect Stephen can agree with the new setup. 

It certainly looks OK, and it performs very well on my 64MB system.
Sadly, in low memory it stinks.  It has just given me the worst
benchmark _ever_ of any of the VMs I have tried for an 8MB NFS defrag
build, taking nearly twice as long as ac11.

Taking both the kswapd and foreground pageout priority initial values
down to 6, things improve: it is only 45% slower now.

> I expect that it needs to be tested in different configurations to
> find the optimal values for various tunables, but hopefully this is it
> when it comes to basic code.

Linus, I have tried this sort of thing before.  I have stopped believing
that one can write the VM balancing code just by thinking about it.
There is a very delicate balance between good performance in various
typical loads and reasonable worst-case behaviour, and ac11 is the best
I've tried for this.  You might well be able to tweak the new algorithm
for good performance on low-memory, but you may well upset larger-memory
behaviour in the process.

On the other hand, I will readily agree that the code in ac11 could be
better expressed: you are quite right when you point out that the
shrink_mmap() test, conditional on (current != kswap_task) would be
better written explicitly as a separate code path for the foreground
memory reclaim code.

As I've said, I'll not have any more time to fine-tune this stuff before
the New Year.  It's up to you what you decide to do about this, but if
you want things fine-tuned sooner than that you'll have to find somebody
else to do it; I've already tuned the ac11 VM and it works well overall
in every case I have tried.  132-pre3 seems OK on a larger memory
machine, but there's no way I'll be running it on my low-memory test
boxes.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
