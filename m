From: lord@sgi.com
Message-Id: <200006282016.PAA19321@jen.americas.sgi.com>
Subject: Re: kmap_kiobuf() 
In-reply-to: Your message of "Wed, 28 Jun 2000 18:46:46 BST
Date: Wed, 28 Jun 2000 15:16:42 -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: lord@sgi.com, David Woodhouse <dwmw2@infradead.org>, linux-mm@kvack.org, riel@conectiva.com.br
List-ID: <linux-mm.kvack.org>

> Hi,
> 
> On Wed, Jun 28, 2000 at 10:54:40AM -0500, lord@sgi.com wrote:
> 
> > I always knew it would go down like a ton of bricks, because of the TLB
> > flushing costs. As soon as you have a multi-cpu box this operation gets
> > expensive, the code could be changed to do lazy tlb flushes on unmapping
> > the pages, but you still have the cost every time you set a mapping up.
> 
> That's exactly what kmap() is for --- it does all the lazy tlb
> flushing for you.  Of course, the kmap area can get fragmented so it's
> not a magic solution if you really need contiguous virtual mappings.
> 
> However, kmap caches the virtual mappings for you automatically, so it
> may well be fast enough for you that you can avoid the whole
> contiguous map thing and just kmap pages as you need them.  Is that
> impossible for your code?
> 
> Cheers,
>  Stephen

Hmm, not sure how much kmap helps - it appears to be for mapping a single
page from highmem. The issue with XFS is that we have variable sized
chunks of meta-data (could be upto 64 Kbytes depending on how the filesystem
was built). 

The code was originally written to treat this like a byte array. Some of the
structures are layed out so that we could rework the code to not treat it
as a byte array, since they are basically arrays of smaller records. Some are
run length encoded type structures (directory leaf blocks being one) where
reworking the code would be a pain to say the least.

So we are currently using memory managed as an address space to do the
caching of metadata. Everything is built up out of single pages, and when we
need something bigger we glue it together into a larger chunk of address
space. This has the nice property that for cached metadata which does
not have special properties at the moment, we can just leave the pages
in the address space. The rest of the vm system is then free to reuse
them out from under us when there is demand for more memory.

Clearly it also has the nasty property of wanting to mess with the address
space map on a regular basis. [ Note that the mapping together of
pages like this is only done when the caller requests it, we can
still use pagebufs without it. ]

So if we do not use pages then we could use other memory from the slab
allocator, and work really hard to ensure it always works. If we go this
route then we now have chunks memory which we need to manage as our own cache,
otherwise we end up continually re-reading from disk. We introduce another 
caching mechanism into the kernel - yet another beast to fight over memory.

If we do not allow the remapping of the pages then we get into rewriting
lots of XFS, and almost certainly breaking it in the process.

Ben mentioned large page support as another way to get around this
problem. Where is that in the grand scheme of things?

Steve

p.s. Woudn't the remapping of pages be a way to let modules etc get larger
arrays of memory after boot time - doing it a few times is not going to
kill the system.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
