In-reply-to: <alpine.LFD.0.999.0708012051100.3582@woody.linux-foundation.org>
	(message from Linus Torvalds on Wed, 1 Aug 2007 20:56:13 -0700 (PDT))
Subject: Re: [RFC PATCH] type safe allocator
References: <E1IGAAI-0006K6-00@dorka.pomaz.szeredi.hu> <alpine.LFD.0.999.0708012051100.3582@woody.linux-foundation.org>
Message-Id: <E1IGV6D-0000rM-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 02 Aug 2007 09:27:57 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@linux-foundation.org
Cc: miklos@szeredi.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> >
> > I wonder why we don't have type safe object allocators a-la new() in
> > C++ or g_new() in glib?
> > 
> >   fooptr = k_new(struct foo, GFP_KERNEL);
> 
> I would object to this if only because of the horrible name.
> 
> C++ is not a good language to take ideas from, and "new()" was not it's 
> best feature to begin with. "k_new()" is just disgusting.
> 
> I'd call it something like "alloc_struct()" instead, which tells you 
> exactly what it's all about. Especially since we try to avoid typedefs in 
> the kernel, and as a result, it's basically almost always a struct thing.

Yeah, I'm not strongly attached to the "new" name, although I got used
to it in glib.  The glib API is broken in lots of ways, but g_new()
and friends are nice and useful.

> That said, I'm not at all sure it's worth it. Especially not with all the 
> various variations on a theme (zeroed, arrays, etc etc).

The number of variations can be reduced to just zeroing/nonzeroing, by
making the array length mandatory.  That's what glib does in g_new().

> Quite frankly, I suspect you would be better off just instrumenting 
> "sparse" instead, and matching up the size of the allocation with the type 
> it gets assigned to.

But that just can't be done, because kmalloc() doesn't tell us the
_intent_ of the allocation.  The allocation could be for an array, or
for a struct with a variable length string at the end, or it could be
multiple structs concatenated.  We have all sorts of weird stuff in
there that sparse would not be able to handle.

That's why alloc_struct() is better: it describes the intention exacly
"allocate the given object and return an appropriately typed pointer".

While kmalloc() just says "allocate a given sized memory chunk and
return an untyped pointer".

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
