Received: by py-out-1112.google.com with SMTP id f31so4158626pyh
        for <linux-mm@kvack.org>; Mon, 20 Aug 2007 23:05:34 -0700 (PDT)
Message-ID: <21d7e9970708202305h5128aa5cy847dafe033b00742@mail.gmail.com>
Date: Tue, 21 Aug 2007 16:05:33 +1000
From: "Dave Airlie" <airlied@gmail.com>
Subject: Re: uncached page allocator
In-Reply-To: <20070820094125.209e0811@the-village.bc.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <21d7e9970708191745h3b579f3bp72f138e089c624da@mail.gmail.com>
	 <20070820094125.209e0811@the-village.bc.nu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: dri-devel <dri-devel@lists.sourceforge.net>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Blame intel ;)
>
> > Any other ideas and suggestions?
>
> Without knowing exactly what you are doing:
>
> - Copies to uncached memory are very expensive on an x86 processor
> (so it might be faster not to write and flush)
> - Its not clear from your description how intelligent your transfer
> system is.

It is still possible to change the transfer system, but it should be
intelligent enough or possible to make it more intelligent..

I also realise I need PAT + write combining but I believe this problem
is othogonal...

>
> I'd expect for example that the process was something like
>
>         Parse pending commands until either
>         1. Queue empties
>         2. A time target passes
>
>         For each command we need to shove a pixmap over add it
>         to the buffer to transfer
>
>         Do a single CLFLUSH and maybe IPI
>
>         Fire up the command queue
>
>         Keep the buffers hanging around until there is memory pressure
>         if we may reuse that pixmap
>
> Can you clarify that ?

So at the moment a pixmap maps directly to a kernel buffer object
which is a bunch of pages that get faulted in on the CPU or allocated
when the buffer is to be used by the GPU. So when a pixmap is created
a buffer object is created, when a pixmap is destroyed a buffer object
is destroyed. Perhaps I can cache a bunch of buffer objects in
userspace for re-use as pixmaps but I'm not really sure that will
scale too well.

When X wishes the GPU to access a buffer (pixmap), it calls into the
kernel with a single ioctl with a list of all buffers the GPU is going
to access along with a buffer containing the command to do the access,
now at the moment, when each of those buffers is bound into the GART
for the first time the system does a change_page_attr for each page
and calls the global flush[1].

Now if a buffer is bound into the GART and gets accessed from the CPU
later again (software fallback) we have the choice of taking it back
out of the GART and letting the nopfn call fault back in the pages
uncached or we can flush the tlb and bring them back in cached. We are
hoping to avoid software fallbacks on the hardware platforms we want
to work on as much as possible.

Finally when a buffer is destroyed, the pages are released back to the
system, so of course the pages are set back to cached and we need
another tlb/cache flush per pixmap buffer destructor.

So you can see why some sort of uncached+writecombined page cache
would be useful, I could just allocate a bunch of pages at startup as
uncached+writecombined, and allocate pixmaps from them and when I
bind/free the pixmap I don't need the flush at all, now I'd really
like this to be part of the VM so that under memory pressure it can
just take the pages I've got in my cache back and after flushing turn
them back into cached pages, the other option is for the DRM to do
this on its own and penalise the whole system.

[1]. (this is one inefficiency in that if multiple buffers are being
bound in for the first time it'll flush for each of them, I'm trying
to get rid of this inefficiency but I may need to tweak the order of
things as at the moment, it crashes hard if I tried to leave the
cache/tlb flush until later.)

Dave.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
