Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA22962
	for <linux-mm@kvack.org>; Sun, 24 Jan 1999 19:30:43 -0500
Date: Sun, 24 Jan 1999 16:27:51 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <m104WE3-0007U1C@the-village.bc.nu>
Message-ID: <Pine.LNX.3.95.990124162426.17000B-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: sct@redhat.com, werner@suse.de, andrea@e-mind.com, riel@humbolt.geo.uu.nl, Zlatko.Calusic@CARNet.hr, ebiederm+eric@ccr.net, saw@msu.ru, steve@netplus.net, damonbrent@earthlink.net, reese@isn.net, kalle.andersson@mbox303.swipnet.se, bmccann@indusriver.com, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Sun, 24 Jan 1999, Alan Cox wrote:
>
> Being able to throw out page tables is something that is going to be needed
> too. As far as I can see that does not mean complexity. The Linux VM is
> very clean in its page handling, there is almost nothing in the page tables
> that cannot be flushed or dumped to disk if need be.

There _is_ a major problem: being able to swap out page tables means that
the thing that swaps them out _has_ to own the mm semaphore. 

That's the right thing to do anyway, but it means, for example, that the
_only_ process that can page stuff out would be kswapd. 

Who knows? Maybe I should just bite the bullet and make that the rule,
then we could forget about all the extra recursive semaphore crap too. And
it has other advantages - it can speed up the page fault handler (which
right now has to get the kernel lock for certain situations). 

Once that is done, paging out page tables is not really a problem.

> There are real cases where grab large linear block is needed.

Nobody has so far shown a reasonable implementation where this would be
possible.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
