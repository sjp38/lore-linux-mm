Date: Mon, 2 Oct 2000 22:25:12 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [highmem bug report against -test5 and -test6] Re: [PATCH] Re:
 simple FS application that hangs 2.4-test5, mem mgmt problem or FS buffer
 cache mgmt problem? (fwd)
In-Reply-To: <Pine.LNX.4.10.10010021305210.826-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0010022218460.11418-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Oct 2000, Linus Torvalds wrote:

> I agree. Most of the time, there's absolutely no point in keeping the
> buffer heads around. Most pages (and _especially_ the actively mapped
> ones) do not need the buffer heads at all after creation - once they
> are uptodate they stay uptodate and we're only interested in the page,
> not the buffers used to create it.

except for writes, there we cache the block # in the bh and do not have to
call the lowlevel FS repeatedly to calculate the FS position of the page.
This also makes it possible to flush metadata blocks from RAM - otherwise
those metadata blocks would be accessed frequently. Especially in the case
of smaller files (smaller than 100k) there could be much more RAM
allocated to metadata than to the bhs. The write-mark-dirty shortcut also
makes a measurable difference in dbench-type write-intensive workloads. In
pure read-only workloads the bh overhead is definitely there. Maybe we
should separate bhs into 'physical block mapping' and 'IO context' parts?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
