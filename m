Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 6AEB26B027E
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 16:49:06 -0400 (EDT)
Received: by qgx61 with SMTP id 61so78843455qgx.3
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 13:49:06 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 39si7308679qgi.21.2015.10.01.13.49.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Oct 2015 13:49:05 -0700 (PDT)
Date: Thu, 1 Oct 2015 13:49:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: linux-next: kernel BUG at mm/slub.c:1447!
Message-Id: <20151001134904.127ccc7bea14e969fbfba0d5@linux-foundation.org>
In-Reply-To: <560D59F7.4070002@roeck-us.net>
References: <560D59F7.4070002@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Dave Chinner <david@fromorbit.com>

On Thu, 1 Oct 2015 09:06:15 -0700 Guenter Roeck <linux@roeck-us.net> wrote:

> Seen with next-20151001, running qemu, simulating Opteron_G1 with a non-SMP configuration.
> On a re-run, I have seen it with the same image, but this time when simulating IvyBridge,
> so it is not CPU dependent. I did not previously see the problem.
> 
> Log is at
> http://server.roeck-us.net:8010/builders/qemu-x86-next/builds/259/steps/qemubuildcommand/logs/stdio
> 
> I'll try to bisect. The problem is not seen with every boot, so that may take a while.

Caused by mhocko's "mm, fs: obey gfp_mapping for add_to_page_cache()",
I expect.

> ---
> gfp: 2

That's __GFP_HIGHMEM

> ------------[ cut here ]------------
> invalid opcode: 0000 [#1] PREEMPT
> Modules linked in:
> CPU: 0 PID: 121 Comm: udevd Not tainted 4.3.0-rc3-next-20151001-yocto-standard #1
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.8.2-0-g33fbe13 by qemu-project.org 04/01/2014
> task: ced90000 ti: ced8c000 task.ti: ced8c000
> EIP: 0060:[<c1128873>] EFLAGS: 00000092 CPU: 0
> EIP is at new_slab+0x353/0x360
> EAX: 00000006 EBX: 00000000 ECX: 00000001 EDX: 80000001
> ESI: cf8019c0 EDI: 00000000 EBP: ced8daa4 ESP: ced8da7c
>   DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
> CR0: 8005003b CR2: 080791c0 CR3: 0ed6c000 CR4: 000006d0
> DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
> DR6: 00000000 DR7: 00000000
> Stack:
>   c19a42cf 00000002 c137542e ced8da90 c137544c ffffffff c144c8a8 00000000
>   cf8019c0 00000000 ced8db28 c1129ca8 0203128a c144f346 00004e20 cec2e740
>   c10ee933 0203128a cf8019c0 c181d6c0 c181d460 000001a1 00150015 c0011c00
> Call Trace:
>   [<c137542e>] ? __delay+0xe/0x10
>   [<c137544c>] ? __const_udelay+0x1c/0x20
>   [<c144c8a8>] ? ide_execute_command+0x68/0xa0
>   [<c1129ca8>] ___slab_alloc.constprop.75+0x248/0x310
>   [<c144f346>] ? do_rw_taskfile+0x286/0x320
>   [<c10ee933>] ? mempool_alloc_slab+0x13/0x20
>   [<c1457d12>] ? ide_do_rw_disk+0x222/0x320
>   [<c1136219>] __slab_alloc.isra.72.constprop.74+0x18/0x1f
>   [<c112a2f2>] kmem_cache_alloc+0x122/0x1c0
>   [<c10ee933>] ? mempool_alloc_slab+0x13/0x20
>   [<c10ee933>] mempool_alloc_slab+0x13/0x20
>   [<c10eebe5>] mempool_alloc+0x45/0x170
>   [<c1345202>] bio_alloc_bioset+0xd2/0x1b0
>   [<c1172e9f>] mpage_alloc+0x2f/0xa0
>   [<c1037979>] ? kmap_atomic_prot+0x59/0xf0
>   [<c1173523>] do_mpage_readpage+0x4d3/0x7e0
>   [<c10f31b8>] ? __alloc_pages_nodemask+0xf8/0x8c0
>   [<c134ed67>] ? blk_queue_bio+0x267/0x2d0
>   [<c112a24a>] ? kmem_cache_alloc+0x7a/0x1c0
>   [<c138357f>] ? __this_cpu_preempt_check+0xf/0x20
>   [<c1173894>] mpage_readpage+0x64/0x80

mpage_readpage() is getting the __GFP_HIGHMEM from mapping_gfp_mask()
and that got passed all the way into kmem_cache_alloc() to allocate a
bio.  slab goes BUG if asked for highmem.

A fix would be to mask off __GFP_HIGHMEM right there in
mpage_readpage().

But I think the patch needs a bit of a rethink.  mapping_gfp_mask() is
the mask for allocating a file's pagecache.  It isn't designed for
allocation of memory for IO structures, file metadata, etc.

Now, we could redefine mapping_gfp_mask()'s purpose (or formalize
stuff which has been sneaking in anyway).  Treat mapping_gfp_mask() as
a constraint mask - instead of it being "use this gfp for this
mapping", it becomes "don't use these gfp flags for this mapping".

Hence something like:

gfp_t mapping_gfp_constraint(struct address_space *mapping, gfp_t gfp_in)
{
	return mapping_gfp_mask(mapping) & gfp_in;
}

So instead of doing this:

@@ -370,12 +371,13 @@ mpage_readpages(struct address_space *ma
 		prefetchw(&page->flags);
 		list_del(&page->lru);
 		if (!add_to_page_cache_lru(page, mapping,
-					page->index, GFP_KERNEL)) {
+					page->index,
+					gfp)) {

Michal's patch will do:

@@ -370,12 +371,13 @@ mpage_readpages(struct address_space *ma
 		prefetchw(&page->flags);
 		list_del(&page->lru);
 		if (!add_to_page_cache_lru(page, mapping,
-				page->index, GFP_KERNEL)) {
+				page->index,
+				mapping_gfp_constraint(mapping, GFP_KERNEL))) {

ie: use mapping_gfp_mask() to strip out any GFP flags which the
filesystem doesn't want used.  If the filesystem has *added* flags to
mapping_gfp_mask() then obviously this won't work and we'll need two
fields in the address_space or something.

Meanwhile I'll drop "mm, fs: obey gfp_mapping for add_to_page_cache()",
thanks for the report.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
