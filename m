Date: Mon, 15 May 2000 22:15:35 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Estrange behaviour of pre9-1
In-Reply-To: <yttog67xqjq.fsf@vexeta.dc.fi.udc.es>
Message-ID: <Pine.LNX.4.21.0005152208340.20410-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 16 May 2000, Juan J. Quintela wrote:

> I think this is the reason that Rik patch worked making the priority
> higher, he gets more passes through the data, then he spent more time
> in shrink_mmap, more possibilities for the IO to finish.  Otherwise it
> has no sense that augmenting the priority achieves more possibilities
> to allocate one page.  At least make no sense to me.

The reason that starting with a higher priority works is that
shrink_mmap() will fail easier on the first run, causing
swap_out() to refill the lru queue and keeping freeable pages
around.

Of course this is no more than a demonstration that:
- we need to have some freeable pages around
- the current fail-through behaviour is not right

> I think that there is no daemon that would be able to stop a
> memory hog like mmap002, it need to wait *itself* when it
> allocates memory, otherwise it will empty all the memory very
> fast.  We don't want all processes waiting for allocation, but
> we want memory hogs to wait for memory and to be the prime
> candidates for swapout pages.

Agreed. How could we achieve this?

> linus> In order to truly make this behave more smoothly, we should trap the thing
> linus> when it creates a dirty page, which is quite hard the way things are set
> linus> up now. Certainly not 2.4.x code.
> 
> Yes, I am thinking more in the lines of trap the allocations,
> and if one application begins to do an insane number of
> allocations (like mmap002), we make *that* application to wait
> for the pages to be written to swap/disk.

"some insane number" is probably not good enough (how would
we detect this?  how do we know that it isn't a process that
slept for the last minute and needs to be swapped in because
the user switched desktops while running mmap002?)

The problem seems to be that we leave dirty pages lying around
instead of waiting on them. Waiting on dirty buffers has a number
of effects:
- try_to_free_pages() will take a bit longer, so we have to make
  sure we don't wait too often (only once per shrink_mmap run?)
- we'll have a better change of replacing the right page, instead
  of a clean page from an innocent process
- that in turn should make sure the innocent process has less
  page faults than it has now, making it run faster and let the
  memory hog proceed faster because of less disk seek time

> linus> [ Incidentally, the thing that mmap002 tests is quite rare, so I don't
> linus>   think we have to have perfect behaviour, we just shouldn't kill
> linus>    processes the way we do now ]
> 
> Yes, I agree here, but this program is based in one application
> that gets Ooops in pre6 and previous kernels.

Wasn't mmap002 based on the behaviour of a real-world program
you were working on?

Also, wouldn't video streaming and data acquisition give similar
results in some cases?

I really think we should support this kind of workload. It is
within our reach and some people are actually running this kind
of application...

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
