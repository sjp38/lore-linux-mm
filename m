Subject: Re: Estrange behaviour of pre9-1
References: <Pine.LNX.4.10.10005151724430.819-100000@penguin.transmeta.com>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Linus Torvalds's message of "Mon, 15 May 2000 17:34:13 -0700 (PDT)"
Date: 16 May 2000 02:54:49 +0200
Message-ID: <yttog67xqjq.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "linus" == Linus Torvalds <torvalds@transmeta.com> writes:

Hi

linus> That is indeed what my shink_mmap() suggested change does (ie make
linus> "sync_page_buffers()" wait for old locked buffers). 

But your change wait for *all* locked buffers, I want to start several
writes asynchronously and then wait for one of them. This makes the
system sure that we don't try to write *all* the memory in one simple
call to try_to_free_pages.  Just now for the vmstat traces that I have
shown, I read it as I have 90MB of pages in cache in one machine with
98MB ram.  Almost all the pages are dirty pages, then we end calling
shrink_mmap a lot of times and starting a lot of IO, we don't wait for
the IO to complete, and then we pass through the pages priority times.

I think this is the reason that Rik patch worked making the priority
higher, he gets more passes through the data, then he spent more time
in shrink_mmap, more possibilities for the IO to finish.  Otherwise it
has no sense that augmenting the priority achieves more possibilities
to allocate one page.  At least make no sense to me.

I will test the rest of your suggestions and we report my findings.

linus> Yes. This is what kflushd is there for, and this is what "balance_dirty()"
linus> is supposed to avoid. It may not work (and memory mappings are the worst
linus> case, because the system doesn't _know_ that they are dirty until at the
linus> point where it starts looking at the page tables - which is when it's too
linus> late).

I think that there is no daemon that would be able to stop a memory
hog like mmap002, it need to wait *itself* when it allocates memory,
otherwise it will empty all the memory very fast.  We don't want all
processes waiting for allocation, but we want memory hogs to wait for
memory and to be the prime candidates for swapout pages.

linus> In order to truly make this behave more smoothly, we should trap the thing
linus> when it creates a dirty page, which is quite hard the way things are set
linus> up now. Certainly not 2.4.x code.

Yes, I am thinking more in the lines of trap the allocations, and if
one application begins to do an insane number of allocations (like
mmap002), we make *that* application to wait for the pages to be
written to swap/disk.  My idea is doing that shrink_mmap returns some
value to tell the allocator that needs to wait for that process.  If I
find some simple solution that works I will sent it.

linus> [ Incidentally, the thing that mmap002 tests is quite rare, so I don't
linus>   think we have to have perfect behaviour, we just shouldn't kill
linus>    processes the way we do now ]

Yes, I agree here, but this program is based in one application that
gets Ooops in pre6 and previous kernels.  I made the test to know that
the code works, I know that the thing that does mmap002 is very rare,
but not one reason to begin doing Oops/killing innocent processes.
That is all the point of that test, not optimise performance for it.

Comments?

Later, Juan.


-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
