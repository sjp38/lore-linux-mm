Date: Sun, 4 Jul 1999 13:32:10 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] fix for OOM deadlock in swap_in (2.2.10) [Re: [test
 program] for OOM situations ]
In-Reply-To: <Pine.LNX.4.10.9907042030310.521-100000@laser.random>
Message-ID: <Pine.LNX.4.10.9907041329130.1624-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Rik van Riel <riel@nl.linux.org>, Bernd Kaindl <bk@suse.de>, Linux Kernel <linux-kernel@vger.rutgers.edu>, kernel@suse.de, linux-mm@kvack.org, Alan Cox <alan@redhat.com>
List-ID: <linux-mm.kvack.org>


On Sun, 4 Jul 1999, Andrea Arcangeli wrote:
> 
> Woops, I see your point, now I changed the patch as you suggested to catch
> the ptrace case properly. Now the retval of handle_mm_fault means this:
> 
> 	 1 ->	page fault resolved succesfully
> 	 0 ->	we accessed a shared mmap beyond the end of the file.
> 		So do_page_fault will send a sigbus in this case while
> 		ptrace won't send the sigbus and will return 0.
> 	-1 ->	OOM. But we don't need to send a sigkill since the lower
> 		layer just sent out the sigkill for us.

Note that if you handle OOM in the caller instead of in the lower layers,
you get _much_ better behaviour. In particular, the page fault handler
knows whether the fault happened in kernel mode or in user mode, and can
do different things depending on which it was. 

See 2.3.10-pre2 - when the OOM fault happens from user mode (the most
common case by far), you can just do a "do_exit(SIGKILL)" and kill it off
much more cleanly without having to go through any extra pseudo-real-time
stuff.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
