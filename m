Date: Sun, 14 Jan 2001 18:48:07 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: swapout selection change in pre1
In-Reply-To: <01011420222701.14309@oscar>
Message-ID: <Pine.LNX.4.10.10101141845010.4957-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Sun, 14 Jan 2001, Ed Tomlinson wrote:
> 
> Think its gone too far in the other direction now.  Running a heavily 
> threaded java program, 35 threads and RSS of 44M a 128M KIII-400 with cpu 
> usage of 4-10%, the rest of the system is getting paged out very quickly and 
> X feels slugish.  While we may not want to treat each thread as if it was a 
> process, I think we need more than one scan per group of threads sharing 
> memory.  

No, what we _really_ want is to penalize processes that have high
page-fault ratios: it indicates that they have a big working set, which in
turn is the absolute best way to find a memory hog in low-memory
conditions.

This is why I think the page allocation should end up having
"swap_out(self)" in the memory allocation path - because it will quite
naturally mean that processes with high page fault ratios are also going
to be the ones paged out more aggressively.

And this is what you should get if you do "try_to_free_pages()" in
page_alloc() instead of the current "page_launder()".

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
