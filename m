Date: Mon, 2 Oct 2000 16:14:06 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [highmem bug report against -test5 and -test6] Re: [PATCH] Re:
 simple FS application that hangs 2.4-test5, mem mgmt problem or FS buffer
 cache mgmt problem? (fwd)
In-Reply-To: <Pine.LNX.4.21.0010022002440.1067-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10010021607210.2206-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>


On Mon, 2 Oct 2000, Rik van Riel wrote:
> > 
> > Aging will certainly take care of that. As long as you do the
> > writeback _before_ you age it.
> 
> Ummm. Even if you don't have any memory pressure, you'll
> still want old data to be written to disk. Currently all
> data which is written is committed to disk after 5 seconds
> by default.

Oh, no arguments there. But the point is that we have to do that currently
_anyway_ in the current code - we just move _that_ logic to the page aging
code instead.

I'm not really suggesting getting rid of kflushd. I'm more suggesting
thinking of it as a VM process rather than a fs/buffer.c process.

Right now kflushd is pretty tied to the notion of buffers, and doesn't
know what to do with pending NFS writebacks, for example. So NFS has to
have its own timeouts etc.

If you think of it as a VM issue, kflushd quite naturally does the
page->ops->flush() thing instead, and is more than it is today.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
