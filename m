Date: Mon, 8 May 2000 19:33:26 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [DATAPOINT] pre7-6 will not swap
In-Reply-To: <ytt66sov6a9.fsf@vexeta.dc.fi.udc.es>
Message-ID: <Pine.LNX.4.10.10005081927200.839-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Quintela Carreira Juan J." <quintela@vexeta.dc.fi.udc.es>
Cc: Rajagopal Ananthanarayanan <ananth@sgi.com>, Andrea Arcangeli <andrea@suse.de>, Benjamin Redelings I <bredelin@ucla.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On 9 May 2000, Quintela Carreira Juan J. wrote:
> Hi Linus, 
>    I have tested two versions of the patch (against vanilla
> pre7-6), the first was to remove the test altogether (I think this is
> from Rajagopal):

I'll make my current pre7-7 available right away, to head off the
discussion.

I found out the real reason for the problem, and it was quite a lot more
subtle than I originally thought.

The "don't page out pages from zones that don't need it" test is a good
test, but it turns out that it triggers a rather serious problem: the way
the buffer cache dirty page handling is done is by having shrink_mmap() do
a "try_to_free_buffers()" on the pages it encounters that have
"page->buffer" set.

And doing that is quite important, because without that logic the buffers
don't get written to disk in a timely manner, nor do already-written
buffers get refiled to their proper lists. So you end up being "out of
memory" - not because the machine is really out of memory, but because
those buffers have a tendency to stick around if they aren't constantly
looked after by "try_to_free_buffers()".

So the real fix ended up being to re-order the tests in shrink_mmap() a
bit, so that try_to_free_buffers() is called even for pages that are on
a good zone that doesn't need any real balancing..

[ time passes ] 

pre7-7 is there now.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
