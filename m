Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id EBE206B005D
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 07:55:24 -0400 (EDT)
Message-ID: <50337671.9040004@parallels.com>
Date: Tue, 21 Aug 2012 15:52:17 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: C12 [00/19] Sl[auo]b: Common code rework V12
References: <0000013945a1cc89-ebeb1806-0a5a-4306-882e-ce0ac88e523c-000000@email.amazonses.com>
In-Reply-To: <0000013945a1cc89-ebeb1806-0a5a-4306-882e-ce0ac88e523c-000000@email.amazonses.com>
Content-Type: multipart/mixed;
	boundary="------------000500070603030008050301"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

--------------000500070603030008050301
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

On 08/21/2012 12:03 AM, Christoph Lameter wrote:
> V11->V12
> - Rediff against current slab/next from Pekka
> - Drop label name change patch
> 
> V10->V11
> - Fix issues pointed out by Joonsoo and Glauber
> - Simplify Slab bootstrap further
> 
> V9->V10
> - Memory leak was a false alarm
> - Resequence patches to make it easier
>   to apply.
> - Do more boot sequence consolidation in slab/slub.
>   [We could still do much more like common kmalloc
>   handling]
> - Fixes suggested by David and Glauber
> 
> V8->V9:
> - Fix numerous things pointed out by Glauber.
> - Cleanup the way error handling works in the
>   common kmem_cache_create() function.
> - General cleanup by breaking things up
>   into multiple patches were necessary.
> 
> V7->V8:
> - Do not use kfree for kmem_cache in slub.
> - Add more patches up to a common
>   scheme for object alignment.
> 
> V6->V7:
> - Omit pieces that were merged for 3.6
> - Fix issues pointed out by Glauber.
> - Include the patches up to the point at which
>   the slab name handling is unified
> 
> V5->V6:
> - Patches against Pekka's for-next tree.
> - Go slow and cut down to just patches that are safe
>   (there will likely be some churn already due to the
>   mutex unification between slabs)
> - More to come next week when I have more time (
>   took me almost the whole week to catch up after
>   being gone for awhile).
> 
> V4->V5
> - Rediff against current upstream + Pekka's cleanup branch.
> 
> V3->V4:
> - Do not use the COMMON macro anymore.
> - Fixup various issues
> - No general sysfs support yet due to lockdep issues with
>   keys in kmalloc'ed memory.
> 
> V2->V3:
> - Incorporate more feedback from Joonsoo Kim and Glauber Costa
> - And a couple more patches to deal with slab duping and move
>   more code to slab_common.c
> 
> V1->V2:
> - Incorporate glommers feedback.
> - Add 2 more patches dealing with common code in kmem_cache_destroy
> 
> This is a series of patches that extracts common functionality from
> slab allocators into a common code base. The intend is to standardize
> as much as possible of the allocator behavior while keeping the
> distinctive features of each allocator which are mostly due to their
> storage format and serialization approaches.
> 
> This patchset makes a beginning by extracting common functionality in
> kmem_cache_create() and kmem_cache_destroy(). However, there are
> numerous other areas where such work could be beneficial:
> 
> 1. Extract the sysfs support from SLUB and make it common. That way
>    all allocators have a common sysfs API and are handleable in the same
>    way regardless of the allocator chose.
> 
> 2. Extract the error reporting and checking from SLUB and make
>    it available for all allocators. This means that all allocators
>    will gain the resiliency and error handling capabilties.
> 
> 3. Extract the memory hotplug and cpu hotplug handling. It seems that
>    SLAB may be more sophisticated here. Having common code here will
>    make it easier to maintain the special code.
> 
> 4. Extract the aliasing capability of SLUB. This will enable fast
>    slab creation without creating too many additional slab caches.
>    The arrays of caches of varying sizes in numerous subsystems
>    do not cause the creation of numerous slab caches. Storage
>    density is increased and the cache footprint is reduced.
> 
> Ultimately it is to be hoped that the special code for each allocator
> shrinks to a mininum. This will also make it easier to make modification
> to allocators.
> 
> In the far future one could envision that the current allocators will
> just become storage algorithms that can be chosen based on the need of
> the subsystem. F.e.
> 
> Cpu cache dependend performance		= Bonwick allocator (SLAB)
> Minimal cycle count and cache footprint	= SLUB
> Maximum storage density			= K&R allocator (SLOB)
> 
> 
With the whole series applied, I get a bug (dmesg attached). Allocator
is SLUB, with all the debugging options ontop.

Triggered by executing the test routine "mybug()" after the kernel is
fully functional, and then issuing "cat /proc/slabinfo".

This is the test case I was using before, but this time it all works
immediately after the caches are destructed and recreated - so it's
better. But transversing the list triggers it.

Code I used is below:

void mybug(void)
{
        struct kmem_cache *c1;

        c1 = KMEM_CACHE(st1,
                SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|SLAB_MEM_SPREAD);

        printk("c1: %p\n", c1);
        kmem_cache_destroy(c1);

        c1 = KMEM_CACHE(st1,
                SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|SLAB_MEM_SPREAD);
        printk("c1 again: %p\n", c1);

        kmem_cache_destroy(c1);
}

I tried to bisect it to the precise point, but I couldn't. The series is
not runtime bisectable. Since it is such a fragile code, having all
patches to at least boot would be of great help. (I'll post the output
in reply to the relevant patch)






--------------000500070603030008050301
Content-Type: text/plain; charset="UTF-8"; name="newbug"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="newbug"

[   61.334165] general protection fault: 0000 [#1] SMP 
[   61.335015] Modules linked in:
[   61.335015] CPU 0 
[   61.335015] Pid: 1152, comm: cat Not tainted 3.6.0-rc1+ #452 Bochs Bochs
[   61.335015] RIP: 0010:[<ffffffff81134a9c>]  [<ffffffff81134a9c>] s_show+0x42/0x111
[   61.335015] RSP: 0018:ffff88003a49bde8  EFLAGS: 00010286
[   61.335015] RAX: 0000000000000000 RBX: ffff880037972000 RCX: 0000000000000000
[   61.335015] RDX: 0000000000000000 RSI: 0000000000000200 RDI: 840f04f883078b41
[   61.335015] RBP: ffff88003a49be38 R08: ffffffff81b8a948 R09: 00000000fffffffd
[   61.335015] R10: 0000000038320000 R11: 0000000000000000 R12: 0000000000000000
[   61.335015] R13: ffffffff81b8a948 R14: 0000000000000000 R15: 0000000000000000
[   61.335015] FS:  00007f2af63d5720(0000) GS:ffff88003ea00000(0000) knlGS:0000000000000000
[   61.335015] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   61.335015] CR2: 00000000025ee000 CR3: 000000003b443000 CR4: 00000000000006f0
[   61.335015] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   61.335015] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[   61.335015] Process cat (pid: 1152, threadinfo ffff88003a49a000, task ffff88003a27c220)
[   61.335015] Stack:
[   61.335015]  0000000000000013 ffffffff00000002 ffff880037972000 ffff880000000000
[   61.335015]  ffff88003a49be38 0000000000000000 0000000000008000 ffff88003a49bf60
[   61.335015]  ffff880037972000 ffff880037b2a500 ffff88003a49bea8 ffffffff81162fbb
[   61.335015] Call Trace:
[   61.335015]  [<ffffffff81162fbb>] seq_read+0x28e/0x371
[   61.335015]  [<ffffffff81162d2d>] ? seq_lseek+0xd2/0xd2
[   61.335015]  [<ffffffff81199c8e>] proc_reg_read+0x8d/0xac
[   61.335015]  [<ffffffff81146e88>] vfs_read+0x9d/0xff
[   61.335015]  [<ffffffff811480ff>] ? fget_light+0x38/0x99
[   61.335015]  [<ffffffff81146f2d>] sys_read+0x43/0x70
[   61.335015]  [<ffffffff8152dd69>] system_call_fastpath+0x16/0x1b
[   61.335015] Code: 31 ff 45 31 f6 45 31 e4 48 89 fb 48 c7 c7 10 d2 ae 81 49 89 f5 e8 79 e7 ff ff 89 c2 eb 40 48 63 c2 49 8b 7c c5 58 48 85 ff 74 23 <48> 8b 47 50 48 c7 c6 84 30 13 81 49 01 c4 48 8b 47 58 89 55 c8 
[   61.335015] RIP  [<ffffffff81134a9c>] s_show+0x42/0x111
[   61.335015]  RSP <ffff88003a49bde8>
[   61.376508] ---[ end trace 9afcc456cc5b11e1 ]---

--------------000500070603030008050301--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
