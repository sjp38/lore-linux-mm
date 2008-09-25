Date: Thu, 25 Sep 2008 04:30:14 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: pageable memory allocator (for DRM-GEM?)
Message-ID: <20080925023014.GB4401@wotan.suse.de>
References: <20080923091017.GB29718@wotan.suse.de> <1222185029.4873.157.camel@koto.keithp.com> <20080925003021.GC23494@wotan.suse.de> <1222305622.4343.166.camel@koto.keithp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1222305622.4343.166.camel@koto.keithp.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Keith Packard <keithp@keithp.com>
Cc: eric@anholt.net, hugh@veritas.com, hch@infradead.org, airlied@linux.ie, jbarnes@virtuousgeek.org, thomas@tungstengraphics.com, dri-devel@lists.sourceforge.net, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 24, 2008 at 06:20:22PM -0700, Keith Packard wrote:
> On Thu, 2008-09-25 at 02:30 +0200, Nick Piggin wrote:
> 
> > I guess so. A big problem of ioctls is just that they had been easier to
> > add so they got less thought and review ;) If your ioctls are stable,
> > correct, cross platform etc. then I guess that's the best you can do.
> 
> One does what one can. Of course, in this case, 'cross platform' is just
> x86/x86_64 as we're talking Intel integrated graphics. When (if?) we
> figure out how to create a common interface across multiple cards for
> some of these operations, we'll probably discover mistakes. We have
> tried to be careful, but we cannot test in any other environment.

OK, that's all that can be asked I guess. Low level object / memory 
management hopefully can be shared.

 
> > Well, no not a seperate filesystem to do the pageable backing store, but
> > a filesystem to do your object management. If there was a need for pageable
> > RAM backing store, then you would still go back to the pageable allocator. 
> 
> Now that you've written one, we could go back and think about building a
> file system and using fds for our operations. It would be a whole lot
> easier than starting from scratch.

If it helps open some other possibilities, then great.

 
> > You can map them to userspace if you just take a page at a time and insert
> > them into the page tables at fault time (or mmap time if you prefer).
> > Currently, this will mean that mmapped pages would not be swappable; is
> > that a problem?
> 
> Yes. We leave a lot of objects mapped to user space as mmap isn't
> exactly cheap. We're trying to use pread/pwrite for as much bulk I/O as
> we can, but at this point, we're still mapping most of the pages we
> allocate into user space and leaving them. Things like textures and
> render buffers will get mmapped if there are any software fallbacks.
> Other objects, like vertex buffers, will almost always end up mapped.
> 
> One of our explicit design goals was to make sure user space couldn't
> ever pin arbitrary amounts of memory; I'd hate to go back on that as it
> seems like an important property for any subsystem designed to support
> regular user applications in a general purpose desktop environment. I
> don't want to trust user space to do the right thing, I want to enforce
> that from kernel space.

OK. I will have to add some facilities to allow mmaps that go back through
to tmpfs and be swappable... Thanks for the data point.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
