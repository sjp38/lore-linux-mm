Date: Sat, 6 Nov 2004 18:44:44 +0100
From: Andrea Arcangeli <andrea@novell.com>
Subject: Re: [PATCH] Remove OOM killer from try_to_free_pages / all_unreclaimable braindamage
Message-ID: <20041106174444.GF3851@dualathlon.random>
References: <20041105200118.GA20321@logos.cnet> <200411051532.51150.jbarnes@sgi.com> <20041106012018.GT8229@dualathlon.random> <418C2861.6030501@cyberone.com.au> <20041106015051.GU8229@dualathlon.random> <16780.46945.925271.26168@thebsh.namesys.com> <20041106153209.GC3851@dualathlon.random> <16781.436.710721.667909@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <16781.436.710721.667909@gargle.gargle.HOWL>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <nikita@clusterfs.com>
Cc: Nick Piggin <piggin@cyberone.com.au>, Jesse Barnes <jbarnes@sgi.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Nov 06, 2004 at 07:54:12PM +0300, Nikita Danilov wrote:
> Andrea Arcangeli writes:
>  > On Sat, Nov 06, 2004 at 02:37:05PM +0300, Nikita Danilov wrote:
>  > > We need page-reservation API of some sort. There were several attempts
>  > > to introduce this, but none get into mainline.
>  > 
>  > they're already in under the name of mempools
> 
> I am talking about slightly different thing. Think of some operation
> that calls find_or_create_page(). find_or_create_page() doesn't know
> about memory reserved in mempools, it uses alloc_page() directly. If one
> wants to guarantee that compound operation has enough memory to
> complete, memory should be reserved at the lowest level---in the page
> allocator.

the page allocator reserve only memory in order to swapout, that's
PF_MEMALLOC.

For other purposes not related to swapping (which is not a deterministic
thing, given there can be multiple layers of I/O and fs operations to
do), you should use mempool and change find_or_create_page to get your
reserved page as parameter.

>  > I'm perfectly aware the fs tends to be the less correct places in terms
>  > of allocations, and luckily it's not an heavy memory user, so I still
> 
> Either you are kidding, or we are facing very different workloads. In
> the world of file-system development, file-system is (not surprisingly)
> single largest memory consumer.

when the machine runs oom the fs allocations means nothing. when the
machine runs oom is because somebody entered the malloc loop or
something like that. all allocations come from page faults.

Try yourself to run your box oom with getblk allocations. Only then
you'll run into the deadlock.

You've to keep in mind an oom condition happens once in a while, and
when it happens the userspace memory allocation load is huge compared to
any fs operation.

>  > have to see a deadlock in getblk or create_buffers or similar. It's
>  > mostly a correctness issue (math proof it can't deadlock, right now it
>  > can if more tasks all get stuck in getblk at the same time during a hard
>  > oom condition etc..).
> 
> Add here mmap that can dirty all physical memory behind your back, and
> delayed disk block allocation that forces ->writepage() to allocate
> potentially huge extent when memory is already tight and hope of having
> a proof becomes quite remote.

that's the PF_MEMALLOC path. A reservation already exists, or it would
never work since 2.2. PF_MEMALLOC and the min/2 watermark are meant to
allow writepage to allocate ram. however the amount reserved is limited,
so it's not perfect. The only way to make it perfect I believe is to
reserve the stuff inside the fs with mempools as described above.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
