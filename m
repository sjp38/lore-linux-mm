Date: Mon, 2 Oct 2000 16:16:24 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [highmem bug report against -test5 and -test6] Re: [PATCH] Re:
 simple FS application that hangs 2.4-test5, mem mgmt problem or FS buffer
 cache mgmt problem? (fwd)
In-Reply-To: <Pine.LNX.4.21.0010022008270.1067-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10010021614430.2206-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Andrea Arcangeli <andrea@suse.de>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>


On Mon, 2 Oct 2000, Rik van Riel wrote:
> 
> The VM is doing page aging and should, for page replacement
> efficiency, only write out OLD pages. This can conflict with
> the write ordering constraints in such a way that the system
> will never get around to flushing out the only writable page
> we have at that moment -> livelock.

Yeah. In which case the VM layer is _buggy_.

Think about it.

The easy solution is to say that if we tried to write out a page where the
buffers were of a generation that is in the future, we should just move
that page to the head of the LRU queue, and go on with the next one. It
is, after all, "busy".

So you end up getting to the pages that _can_ be written out eventually.
End of story.

If you think that LRU and write ordering constraints cannot live together,
then you're being inflexible.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
