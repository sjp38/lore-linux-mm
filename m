Date: Wed, 10 May 2000 17:16:05 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] Recent VM fiasco - fixed
In-Reply-To: <m366smx3qy.fsf@austin.jhcloos.com>
Message-ID: <Pine.LNX.4.10.10005101708590.1489-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "James H. Cloos Jr." <cloos@jhcloos.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Ok, there's a pre7-9 out there, and the biggest change versus pre7-8 is
actually how block fs dirty data is flushed out. Instead of just waking up
kflushd and hoping for the best, we actually just write it out (and even
wait on it, if absolutely required).

Which makes the whole process much more streamlined, and makes the numbers
more repeatable. It also fixes the problem with dirty buffer cache data
much more efficiently than the kflushd approach, and mmap002 is not a
problem any more. At least for me.

[ I noticed that mmap002 finishes a whole lot faster if I never actually
  wait for the writes to complete, but that had some nasty behaviour under
  low memory circumstances, so it's not what pre7-9 actually does. I
  _suspect_ that I should start actually waiting for pages only when
  priority reaches 0 - comments welcomed, see fs/buffer.c and the
  sync_page_buffers() function ]

kswapd is still quite aggressive, and will show higher CPU time than
before. This is a tweaking issue - I suspect it is too aggressive right
now, but it needs more testing and feedback. 

Just the dirty buffer handling made quite an enormous difference, so
please do test this if you hated earlier pre7 kernels.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
