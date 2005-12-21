Date: Wed, 21 Dec 2005 11:04:47 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: Possible cure for memory fragmentation.
In-Reply-To: <43A9409D.1010904@superbug.demon.co.uk>
Message-ID: <Pine.LNX.4.62.0512211058350.2455@schroedinger.engr.sgi.com>
References: <43A9409D.1010904@superbug.demon.co.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Courtier-Dutton <James@superbug.demon.co.uk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 Dec 2005, James Courtier-Dutton wrote:

> I am suggesting we add a new memory allocation function into the kernel
> called kremalloc().
> 
> The purpose of any call to kremalloc() would mean that:
> a) One really needs the memory already allocated, so don't loose it.
> b) One does not mind if the memory location moves.
> 
> Now, the kernel driver module that has previously allocated a memory block,
> could at a time convenient to itself, allow the memory to be moved. It
> would simple call kremalloc() with the same size parameter as it originally
> called kmalloc(). The mm would then notice this, and then, if that location
> had been tagged with (1), the mm could then happily move it, and the kernel
> driver module would be happy. If it was not tagged with (1) the mm would
> simply return, so very little overhead.

Moving regular mapped kernel memory is not trivial. See my page migration
patchsets.

Slab memory cannot be resized since the memory is managed in portions 
of fixed sizes. So if these size boundaries are violated then the 
kremalloc would degenerate into a kfree and a kmalloc. kremalloc 
would be:

void *kremalloc(void *p, int oldsize, int newsize, gfp_t f)
{
	void *new;

	if (newsize < sizeboundary)
		return p;

	new = kmalloc(size, f);

	memcpy(new, old, oldsize);

	kfree(p);

	return new;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
