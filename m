Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7958F6B01F0
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 14:42:37 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id o7HIgaSh015939
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 11:42:36 -0700
Received: from pxi6 (pxi6.prod.google.com [10.243.27.6])
	by wpaz9.hot.corp.google.com with ESMTP id o7HIfs5r013383
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 11:42:33 -0700
Received: by pxi6 with SMTP id 6so2977205pxi.17
        for <linux-mm@kvack.org>; Tue, 17 Aug 2010 11:42:27 -0700 (PDT)
Date: Tue, 17 Aug 2010 11:42:25 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [S+Q3 20/23] slub: Shared cache to exploit cross cpu caching
 abilities.
In-Reply-To: <alpine.DEB.2.00.1008171234130.12188@router.home>
Message-ID: <alpine.DEB.2.00.1008171137030.6486@chino.kir.corp.google.com>
References: <20100804024514.139976032@linux.com> <20100804024535.338543724@linux.com> <alpine.DEB.2.00.1008162246500.26781@chino.kir.corp.google.com> <alpine.DEB.2.00.1008171234130.12188@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 17 Aug 2010, Christoph Lameter wrote:

> > This explodes on the memset() in slab_alloc() because of __GFP_ZERO on my
> > system:
> 
> Well that seems to be because __kmalloc_node returned invalid address. Run
> with full debugging please?
> 

Lots of data, so I trimmed it down to something reasonable by eliminating 
reports that were very similar.  (It also looks like some metadata is 
getting displayed incorrectly such as negative pid's and 10-digit cpu 
numbers.)

[   14.152177] =============================================================================
[   14.153172] BUG kmalloc-16: Object padding overwritten
[   14.153172] -----------------------------------------------------------------------------
[   14.153172] 
[   14.153172] INFO: 0xffff88107e595ea8-0xffff88107e595eab. First byte 0x0 instead of 0x5a
[   14.153172] INFO: Freed in 0x7e00000000 age=18446743536838353798 cpu=0 pid=0
[   14.153172] INFO: Slab 0xffffea0039ba3898 objects=51 new=4 fp=0x0007800000000000 flags=0xe00000000000080
[   14.153172] INFO: Object 0xffff88107e595e60 @offset=3680
[   14.153172] 
[   14.153172] Bytes b4 0xffff88107e595e50:  00 00 00 00 7e 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a ....~...ZZZZZZZZ
[   14.153172]   Object 0xffff88107e595e60:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkk
[   14.153172]  Redzone 0xffff88107e595e70:  bb bb bb bb bb bb bb bb                                 
[   14.153172]  Padding 0xffff88107e595ea8:  00 00 00 00 5a 5a 5a 5a                         ....ZZZZ        
[   14.153172] Pid: 1, comm: swapper Not tainted 2.6.35-slubq #1
[   14.153172] Call Trace:
[   14.153172]  [<ffffffff81104333>] print_trailer+0x134/0x13f
[   14.153172]  [<ffffffff811043f5>] check_bytes_and_report+0xb7/0xe8
[   14.153172]  [<ffffffff8110455e>] check_object+0x138/0x150
[   14.153172]  [<ffffffff81106f18>] ? alloc_shared_caches+0x10f/0x277
[   14.153172]  [<ffffffff811049bf>] alloc_debug_processing+0xd5/0x160
[   14.153172]  [<ffffffff811054d7>] slab_alloc+0x52e/0x590
[   14.153172]  [<ffffffff81106f18>] ? alloc_shared_caches+0x10f/0x277
[   14.153172]  [<ffffffff811061fc>] __kmalloc_node+0x78/0xa3
[   14.153172]  [<ffffffff81106f18>] alloc_shared_caches+0x10f/0x277
[   14.153172]  [<ffffffff81b09661>] slab_sysfs_init+0x96/0x10a
[   14.153172]  [<ffffffff81b095cb>] ? slab_sysfs_init+0x0/0x10a
[   14.153172]  [<ffffffff810001f9>] do_one_initcall+0x5e/0x14e
[   14.153172]  [<ffffffff81aec6bb>] kernel_init+0x178/0x202
[   14.153172]  [<ffffffff81030954>] kernel_thread_helper+0x4/0x10
[   14.153172]  [<ffffffff81aec543>] ? kernel_init+0x0/0x202
[   14.153172]  [<ffffffff81030950>] ? kernel_thread_helper+0x0/0x10
[   14.153172] FIX kmalloc-16: Restoring 0xffff88107e595ea8-0xffff88107e595eab=0x5a

...

[   15.751474] =============================================================================
[   15.752467] BUG kmalloc-16: Redzone overwritten
[   15.752467] -----------------------------------------------------------------------------
[   15.752467] 
[   15.752467] INFO: 0xffff880c7e5f3ec0-0xffff880c7e5f3ec7. First byte 0x30 instead of 0xbb
[   15.752467] INFO: Allocated in 0xffff88087e4f11e0 age=131909211166235 cpu=2119111312 pid=-30712
[   15.752467] INFO: Freed in 0xffff88087e4f13f0 age=131909211165707 cpu=2119111840 pid=-30712
[   15.752467] INFO: Slab 0xffffea002bba4d28 objects=51 new=3 fp=0x0007000000000000 flags=0xa00000000000080
[   15.752467] INFO: Object 0xffff880c7e5f3eb0 @offset=3760
[   15.752467] 
[   15.752467] Bytes b4 0xffff880c7e5f3ea0:  18 00 00 00 7e 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a ....~...ZZZZZZZZ
[   15.752467]   Object 0xffff880c7e5f3eb0:  d0 0f 4f 7e 08 88 ff ff 80 10 4f 7e 08 88 ff ff .O~....O~..
[   15.752467]  Redzone 0xffff880c7e5f3ec0:  30 11 4f 7e 08 88 ff ff                         0.O~..        
[   15.752467]  Padding 0xffff880c7e5f3ef8:  00 16 4f 7e 08 88 ff ff                         ..O~..        
[   15.752467] Pid: 1, comm: swapper Not tainted 2.6.35-slubq #1
[   15.752467] Call Trace:
[   15.752467]  [<ffffffff81104333>] print_trailer+0x134/0x13f
[   15.752467]  [<ffffffff811043f5>] check_bytes_and_report+0xb7/0xe8
[   15.752467]  [<ffffffff81104481>] check_object+0x5b/0x150
[   15.752467]  [<ffffffff81106f18>] ? alloc_shared_caches+0x10f/0x277
[   15.752467]  [<ffffffff811049bf>] alloc_debug_processing+0xd5/0x160
[   15.752467]  [<ffffffff811054d7>] slab_alloc+0x52e/0x590
[   15.752467]  [<ffffffff81106f18>] ? alloc_shared_caches+0x10f/0x277
[   15.752467]  [<ffffffff811061fc>] __kmalloc_node+0x78/0xa3
[   15.752467]  [<ffffffff81106f18>] alloc_shared_caches+0x10f/0x277
[   15.752467]  [<ffffffff81b09661>] slab_sysfs_init+0x96/0x10a
[   15.752467]  [<ffffffff81b095cb>] ? slab_sysfs_init+0x0/0x10a
[   15.752467]  [<ffffffff810001f9>] do_one_initcall+0x5e/0x14e
[   15.752467]  [<ffffffff81aec6bb>] kernel_init+0x178/0x202
[   15.752467]  [<ffffffff81030954>] kernel_thread_helper+0x4/0x10
[   15.752467]  [<ffffffff81aec543>] ? kernel_init+0x0/0x202
[   15.752467]  [<ffffffff81030950>] ? kernel_thread_helper+0x0/0x10
[   15.752467] FIX kmalloc-16: Restoring 0xffff880c7e5f3ec0-0xffff880c7e5f3ec7=0xbb

...

[   15.752467] =============================================================================
[   15.752467] BUG kmalloc-16: Pointer check fails
[   15.752467] -----------------------------------------------------------------------------
[   15.752467] 
[   15.752467] INFO: Allocated in 0xffff880c7e5f4080 age=131874850999735 cpu=2119539736 pid=-30704
[   15.752467] INFO: Freed in 0xc00000000 age=18446743536838355610 cpu=4 pid=1
[   15.752467] INFO: Slab 0xffffea002bba4d28 objects=51 new=0 fp=0x(null) flags=0xa00000000000080
[   15.752467] INFO: Object 0xffff880c7e5f3ff0 @offset=4080
[   15.752467] 
[   15.752467] Bytes b4 0xffff880c7e5f3fe0:  00 00 00 00 7e 00 00 00 00 00 00 00 5a 5a 5a 5a ....~.......ZZZZ
[   15.752467]   Object 0xffff880c7e5f3ff0:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
[   15.752467]  Redzone 0xffff880c7e5f4000:  80 35 37 7e 04 88 ff ff                         .57~..        
[   15.752467]  Padding 0xffff880c7e5f4038:  00 00 00 00 00 00 00 00                         ........        
[   15.752467] Pid: 1, comm: swapper Not tainted 2.6.35-slubq #1
[   15.752467] Call Trace:
[   15.752467]  [<ffffffff81104333>] print_trailer+0x134/0x13f
[   15.752467]  [<ffffffff81106f18>] ? alloc_shared_caches+0x10f/0x277
[   15.752467]  [<ffffffff81104858>] object_err+0x3a/0x43
[   15.752467]  [<ffffffff81106f18>] ? alloc_shared_caches+0x10f/0x277
[   15.752467]  [<ffffffff811049ad>] alloc_debug_processing+0xc3/0x160
[   15.752467]  [<ffffffff811054d7>] slab_alloc+0x52e/0x590
[   15.752467]  [<ffffffff81106f18>] ? alloc_shared_caches+0x10f/0x277
[   15.752467]  [<ffffffff811061fc>] __kmalloc_node+0x78/0xa3
[   15.752467]  [<ffffffff81106f18>] alloc_shared_caches+0x10f/0x277
[   15.752467]  [<ffffffff81b09661>] slab_sysfs_init+0x96/0x10a
[   15.752467]  [<ffffffff81b095cb>] ? slab_sysfs_init+0x0/0x10a
[   15.752467]  [<ffffffff810001f9>] do_one_initcall+0x5e/0x14e
[   15.752467]  [<ffffffff81aec6bb>] kernel_init+0x178/0x202
[   15.752467]  [<ffffffff81030954>] kernel_thread_helper+0x4/0x10
[   15.752467]  [<ffffffff81aec543>] ? kernel_init+0x0/0x202
[   15.752467]  [<ffffffff81030950>] ? kernel_thread_helper+0x0/0x10
[   15.752467] FIX kmalloc-16: Marking all objects used

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
