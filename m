Date: Mon, 26 Oct 1998 12:39:33 -0500 (EST)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: mmap() for a cluster of pages
In-Reply-To: <199810261144.MAA12564@faun.cs.tu-berlin.de>
Message-ID: <Pine.LNX.3.95.981026121852.9207B-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Gilles Pokam <pokam@cs.tu-berlin.de>
Cc: sct@redhat.com, Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 26 Oct 1998, Gilles Pokam wrote:

> I'm trying to developp my own driver. The problem is that i have to use a 
> large amount of contiguous memory. For this purpose, in the __get_free_pages()
> function, i use an order of 4 (for example).
> 
> I have implemented the mmap(), nopage(), open() and release() operations of 
> the vma and file structures. Like mentionned in the book of Alessandro Rubini,
> "Device Driver for Linux", when using more than one page size, the mmap()
> is only able to mmap the first page of a page cluster.
[...]

Argh, that too much work.  Try this instead:

	a. allocate buffer when you device is first open()ed and
	   set the PG_reserved bit for each page in the cluster
		-> remember to undo this before freeing the pages

	b. us the standard remap_page_range technique to implement mmap.
	   Note that you should'nt need to implement any vm_ops as the
	   zap_pte_range call in do_mmap will do the Right Thing for you.

Methinks this KISS approach is easiest, otherwise you have to set
VM_LOCKED in the vma and prevent people from touching it, which just isn't
quite as simple.

Stephen, in replying to this, I glanced at the sound driver's mmap
routine.  They use an order > 0 buffer that they map, but don't do
anything to prevent its being touched by the swap routines.  My guess is
simply that noone's encountered this bug before, but it's there.  If you
want, I'll submit a patch and scan the kernel for other instances of the
same problem.  Also, is PG_reserved the best flag for this case?

		-ben

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
