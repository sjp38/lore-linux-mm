Date: Thu, 25 Sep 2008 02:18:56 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: pageable memory allocator (for DRM-GEM?)
Message-ID: <20080925001856.GB23494@wotan.suse.de>
References: <20080923091017.GB29718@wotan.suse.de> <48D8C326.80909@tungstengraphics.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <48D8C326.80909@tungstengraphics.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Thomas =?iso-8859-1?Q?Hellstr=F6m?= <thomas@tungstengraphics.com>
Cc: keith.packard@intel.com, eric@anholt.net, hugh@veritas.com, hch@infradead.org, airlied@linux.ie, jbarnes@virtuousgeek.org, dri-devel@lists.sourceforge.net, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 23, 2008 at 12:21:26PM +0200, Thomas Hellstrom wrote:
> Nick,
> From my point of view, this is exactly what's needed, although there 
> might be some different opinions among the
> DRM developers. A question:
> 
> Sometimes it's desirable to indicate that a page / object is "cleaned", 
> which would mean data has moved and is backed by device memory. In that 
> case one could either free the object or indicate to it that it can 
> release it's pages. Is freeing / recreating such an object an expensive 
> operation? Would it, in that case, be possible to add an object / page 
> "cleaned" function?

Ah, interesting... freeing/recreating isn't _too_ expensive, but it is
going to have to allocate a lot of pages (for a big object) and copy
a lot of memory. It's strange to say "cleaned", in a sense, because the
allocator itself doesn't know it is being used as a writeback cache ;)
(and it might get confusing with the shmem implementation because your
cleaned != shmem cleaned!).

I understand the operation you need, but it's tricky to make it work in
the existing shmem / vm infrastructure I think. Let's call it "dontneed",
and I'll add a hook in there we can play with later to see if it helps?

What I could imagine is to have a second backing store (not shmem), which
"dontneed" pages go onto, and they simply get discarded rather than swapped
out (eg. via the ->shrinker() memory pressure indicator). You could then
also register a callback to recreate these parts of memory if they have been
discarded then become used again. It wouldn't be terribly difficult come to
think of it... would that be useful?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
