Date: Sun, 4 Jul 1999 10:49:56 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] fix for OOM deadlock in swap_in (2.2.10) [Re: [test
 program] for OOM situations ]
In-Reply-To: <Pine.LNX.4.10.9907041920040.6789-100000@laser.random>
Message-ID: <Pine.LNX.4.10.9907041041100.1352-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Rik van Riel <riel@nl.linux.org>, Bernd Kaindl <bk@suse.de>, Linux Kernel <linux-kernel@vger.rutgers.edu>, kernel@suse.de, linux-mm@kvack.org, Alan Cox <alan@redhat.com>
List-ID: <linux-mm.kvack.org>


On Sun, 4 Jul 1999, Andrea Arcangeli wrote:
> 
> The first patch I sent you some time ago was buggy since I replaced the
> sigbus with a sigkill in do_page_fault, but now I force the signals only
> at the lower level (as shm and other places was just doing) and the retval
> of handle_mm_fault now _only_ tells do_page_fault if it has to fixup or
> not.

Ok. I still have your old patch, I'll just flush it so I don't confuse it
with anything else.

However, I still much prefer the 2.3.x approach (ie just returning more
than just 0/1 - a negative number means out-of-memory). In particular,
your current approach gets the ptrace() case wrong for the SIGBUS case,
and it's pretty much impossible to fix cleanly as far as I can tell.

Note that 2.3.10-pre2 also gets ptrace() wrong, but at least it's not
impossible to fix - it should just bother to check the return value it
gets from handle_mm_fault(). Right now it doesn't.

Note that ptrace() is a horrible special case, being the only thing that
accesses another process VM space (apart from vmscan which is also
horrible, in other ways). HOWEVER, it's rather bad to have a SIGBUS
problem and then when you try to debug it the debugger also gets a SIGBUS,
which is what your approach results in.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
