Date: Fri, 3 Nov 2006 10:11:58 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Page allocator: Single Zone optimizations
In-Reply-To: <Pine.LNX.4.64.0611030900480.9787@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0611030952530.14741@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0610271907400.10615@schroedinger.engr.sgi.com>
 <20061027192429.42bb4be4.akpm@osdl.org> <Pine.LNX.4.64.0610271926370.10742@schroedinger.engr.sgi.com>
 <20061027214324.4f80e992.akpm@osdl.org> <Pine.LNX.4.64.0610281743260.14058@schroedinger.engr.sgi.com>
 <20061028180402.7c3e6ad8.akpm@osdl.org> <Pine.LNX.4.64.0610281805280.14100@schroedinger.engr.sgi.com>
 <4544914F.3000502@yahoo.com.au> <20061101182605.GC27386@skynet.ie>
 <20061101123451.3fd6cfa4.akpm@osdl.org> <Pine.LNX.4.64.0611012155340.29614@skynet.skynet.ie>
 <454A2CE5.6080003@shadowen.org> <Pine.LNX.4.64.0611021004270.8098@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611022053490.27544@skynet.skynet.ie>
 <Pine.LNX.4.64.0611021345140.9877@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611022153491.27544@skynet.skynet.ie>
 <Pine.LNX.4.64.0611021442210.10447@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611030900480.9787@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Fri, 3 Nov 2006, Mel Gorman wrote:

> I know, this sort of thing would have to be written into page migration before
> defrag for high-order allocations was developed. Even then, defrag needs to
> sit on top of something like anti-frag to get teh clustering of movable pages.

Hmmm... The disk defraggers are capable of defragmenting around pinned 
blocks and this seems to be a similar. This only works if the number of 
unmovable objects is small compared to the movable objects otherwise we 
may need this sorting.  For other reasons discussed before (memory unplug, 
node unplug) I think it would be necessary to have this separation 
between movable and unmovable pages.

I can add a migrate_page_table_page() function? The migrate_pages() 
function is only capable of migrating user space pages since it relies on 
being able to take pages off the LRU. At some point we need to 
distinguishthe type of page and call the appropriate migration function 
for the various page types.

int migrate_page_table_page(struct page *new, struct page *new);
?

> Reclaimable - These are kernel allocations for caches that are
>         reclaimable or allocations that are known to be very short-lived.
> 	These allocations are marked __GFP_RECLAIMABLE

For now this would include reclaimable slabs? They are reclaimable with a 
huge effort and there may be pinned objects that we cannot move. Isnt this 
more another case of unmovable? Or can we tolerate the objects that cannot 
be moved and classify this as movable (with the understanding that we may 
have to do expensive slab reclaim (up to dropping all reclaimable slabs) 
in order to get there).

> Non-Movable - These are pages that are allocated by the kernel that
>         are not trivially reclaimed. For example, the memory allocated for a
>         loaded module would be in this category. By default, allocations are
>         considered to be of this type
> 	These are allocations that are not marked otherwise

Ok.

Note that memory for a loaded module is allocated via vmalloc, mapped via 
a page table (init_mm) and thus memory is remappable. We will likely be 
able to move those.

> So, right now, page tables would not be marked __GFP_MOVABLE, but they would
> be later when defrag was developed. Would that be any better?

Isnt this is still doing reclaim instead of defragmentation? Maybe it 
will work but I am not not sure about the performance impact. We 
would have to read pages back in from swap or disk?

The problem that we have is that one cannot higher order pages since 
memory is fragmented. Maybe what would initially be sufficient is that a failing 
allocation of a higher order page lead to defrag occurring until pages of 
suffiecient size have been created and then the allocation can be satisfied.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
