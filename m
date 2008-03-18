Date: Tue, 18 Mar 2008 15:18:28 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH prototype] [0/8] Predictive bitmaps for ELF executables
Message-ID: <20080318141828.GD11966@one.firstfloor.org>
References: <20080318209.039112899@firstfloor.org> <20080318003620.d84efb95.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080318003620.d84efb95.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 18, 2008 at 12:36:20AM -0700, Andrew Morton wrote:
> On Tue, 18 Mar 2008 02:09:34 +0100 (CET) Andi Kleen <andi@firstfloor.org> wrote:
> 
> > This patchkit is an experimental optimization I played around with 
> > some time ago.
> > 
> > This is more a prototype still, but I wanted to push it out 
> > so that other people can play with it.
> > 
> > The basic idea is that most programs have the same working set
> > over multiple runs. So instead of demand paging all the text pages
> > in the order the program runs save the working set to disk and prefetch
> > it at program start and then save it at program exit.
> > 
> > This allows some optimizations: 
> > - it can avoid unnecessary disk seeks because the blocks will be fetched in 
> > sorted offset order instead of program execution order. 
> > - batch kernel entries (each demand page exception has some
> > overhead just for entering the kernel). This keeps the caches hot too.
> > - The prefetch could be in theory done in the background while the program 
> > runs (although that is not implemented currently)
> 
> Should be worthwhile for some things.
> 
> > Some details on the implementation:
> 
> Can't this all be done in userspace?  Hook into exit() with an LD_PRELOAD,

In theory yes, but it would have much more overhead. Also I think prefetching
algorithms like this really belong in the kernel.

> > - Executable files have to be writable by the user executing it
> > currently to get bitmap updates. It would be possible to let the 
> > kernel bypass this, but I haven't thought too much about the security 
> > implications of it.
> > However any user can use the bitmap data written by a user with
> > write rights.
> 
> Those all get fixed with the userspace version?

No in fact the permission problem is much harder to fix in user space.

The shared libraries would need some user support. Basically just a way
how the ld.so can tell the kernel about the offsets/locations of new 
bitmaps to add to the pbitmap list

-Andi

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
