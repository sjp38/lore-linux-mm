Date: Mon, 2 Oct 2000 14:58:39 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [highmem bug report against -test5 and -test6] Re: [PATCH] Re:
 simple FS application that hangs 2.4-test5, mem mgmt problem or FS buffer
 cache mgmt problem? (fwd)
In-Reply-To: <Pine.LNX.4.21.0010021836090.1067-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10010021447310.2206-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>


On Mon, 2 Oct 2000, Rik van Riel wrote:
> 
> You will want to add page->mapping too, so we won't be kicking
> buffermem data out of memory when we don't need to.

Fair enough.

> Also, you really want to free the bufferheads on the pages that
> are in heavy use (say glibc shared ages) too...

I don't think they matter that much, but yes, we could just do this all
outside the whole test.

> > (and yes, I think it should also start background writing - we
> > probably need the gfp_mask to know whether we can do that).
> 
> Background writing is done by kupdate / kflushd.

.. but there's no reason why we should not do it here.

I'd MUCH rather work towards a setup where kupdate/kflushd goes away
completely, and the work is done as a natural end result of just aging the
pages.

If you look at what kflushd does, you'll notice that it already has a lot
of incestuous relationships with the VM layer. And the VM layer has a lot
of the same with bdflush. That is what I call UGLY and bad design.

Now, look at what bdflush actually _does_. Think about it.

Yeah, it's really aging the pages and writing them out in the background.

In short, it's something that kswapd might as well do.

In fact, if you look at how the VM layer tries to wake up bdflush, you'll
notice that the VM layer really wants to say "please flush more pages
because I'm low on memory". Which is really another way of saying that
kswapd should run more. 

It all ties together, and we should make that explicit, instead of having
the current incestuous relationships and saying "oh, the VM layer
shouldn't write out dirty pages, because that's the job of kflushd (but
the VM layer can wake it up because it knows that kflushd needs to be
run)".

Note that the current "flush_dirty_buffers()" should just go away. It has
no advantages compared to having "try_to_free_buffers(x,1)" on the
properly aged LRU queue..

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
