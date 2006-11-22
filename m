Subject: Re: The VFS cache is not freed when there is not enough free
	memory to allocate
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <6d6a94c50611212351if1701ecx7b89b3fe79371554@mail.gmail.com>
References: <6d6a94c50611212351if1701ecx7b89b3fe79371554@mail.gmail.com>
Content-Type: text/plain
Date: Wed, 22 Nov 2006 09:43:56 +0100
Message-Id: <1164185036.5968.179.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Aubrey <aubreylee@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2006-11-22 at 15:51 +0800, Aubrey wrote:
> Hi all,
> 
> We are working on the blackfin uClinux platform and we encountered the
> following problem.
> The attached patch can work around this issue and I post it here to
> find better solution.

> root:/mnt> ./t
> Alloc 8 MB !
> t: page allocation failure. order:9, mode:0x40d0
                              ^^^^^^^
Such high order allocs rarely succeed after bootup. The proposed patch
will hardly help that more than lumpy reclaim will. Please see the
threads on Mel Gorman's Anti-Fragmentation and Linear/Lumpy reclaim in
the linux-mm archives.

> From: Aubrey.Li <aubrey.li@analog.com>
> Date: Wed, 22 Nov 2006 15:10:18 +0800
> Subject: [PATCH] Drop VFS cache when there is not enough free memory to allocate
> 
> Signed-off-by: Aubrey.Li <aubrey.li@analog.com>
> ---
>  mm/page_alloc.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index bf2f6cf..62559fd 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1039,6 +1039,11 @@ restart:
>         if (page)
>                 goto got_pg;
> 
> +#if defined(CONFIG_EMBEDDED) && !defined(CONFIG_MMU)
> +       drop_pagecache();
> +       drop_slab();
> +#endif
> +
>         /* This allocation should allow future memory freeing. */
> 
>         if (((p->flags & PF_MEMALLOC) || unlikely(test_thread_flag(TIF_MEMDIE)))
> --


> The patch drop the page cache and slab and then give a new chance to
> get more free pages. Applied this patch, my test application can
> allocate memory sucessfully and drop the cache and slab as well. See
> below:
> ================================
> root:/mnt> ./t
> Alloc 8 MB !
> alloc successful

Pure luck, there are workloads where there just would not have been any
order 9 contiguous block freeable (think where each 9th order block
would contain at least one active inode).

> I know performance is important for linux, and VFS cache obviously
> improve the performance when implement file operation. But for
> embedded system, we'll try our best to make the application executable
> rather than hanging system to guarantee the system performance.
> 
> Any suggestions and solutions are really appreciated!

Try Mel's patches and wait for the next Lumpy reclaim posting.

The lack of a MMU on your system makes it very hard not to rely on
higher order allocations, because even user-space allocs need to be
physically contiguous. But please take that into consideration when
writing software.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
