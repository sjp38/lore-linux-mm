Date: Wed, 31 May 2000 18:19:55 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] VM bugfix + rebalanced + code beauty
In-Reply-To: <qwwg0qy309r.fsf@sap.com>
Message-ID: <Pine.LNX.4.21.0005311817190.30221-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <cr@sap.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On 31 May 2000, Christoph Rohland wrote:
> Rik van Riel <riel@conectiva.com.br> writes:
> 
> > I'm testing stuff now, but seem unable to reproduce your
> > observation. However, I *am* seeing high cpu usage by
> > kswapd ;)
> 
> I do these tests regularly 8way/8GB and the latest kernel is
> definitely a step back.

I have tracked down why. Shrink_mmap uses a bit more CPU
due to the page aging, but because we really want to free
an SHM page, shrink_mmap won't find anything suitable (yes,
aging works) and just waste some CPU before falling through
to shm_swap.

> > I guess we really want to integrate the SHM swapout routine
> > with shrink_mmap...
> 
> I would love to integrate the whole shm page handling into the
> page cache.

That would be great. If we have this we can weigh page cache,
swap cache and shm pages equally. Not only will this result in
better page replacement, but it will also save on kswapd cpu
usage.

Even better, having this will allow us to (trivially) insert
the active/inactive queue idea into the kernel, fixing the
"write stall" problems for a lot of situations.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
