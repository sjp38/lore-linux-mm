Date: Fri, 14 Jan 2000 03:36:57 +0100 (CET)
From: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Subject: Re: [RFC] 2.3.39 zone balancing
In-Reply-To: <200001140117.RAA86279@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.10001140327570.7241-100000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Andrea Arcangeli <andrea@suse.de>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@nl.linux.org>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Thu, 13 Jan 2000, Kanoj Sarcar wrote:

> There's been some arguments against per-zone, or per-node kswapd's, 
> so the other alternative is to pass the list of unbalanced zones to
> kswapd, which can then scan only the unbalanced ones. This is the 
> best solution when there are fairly large number of nodes.

the current kswapd is not quite suited to go per-zone and/or per-node, i
agree. But the swap_out() logic itself i believe has to be per-node in the
long term. Especially as we are already able to allocate from a given
node. Thus it would be natural to be able to do swap_out() from a given
node - both page tables and pages will likely be bound to a node. Per-node
kswapds are simple - they only have to take a look at p->node or
p->processor to pick up the right mm. This means that every kswapd would
pick up preferred mm's from it's own node.

the pagecache and other 'global' freeing stuff should only run on one of
the kswapds. (or in a separate 'global' freeing daemon, just like bdflush
- although that i think would be an overkill.)

-- mingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
