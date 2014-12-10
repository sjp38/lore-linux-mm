Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com [209.85.218.54])
	by kanga.kvack.org (Postfix) with ESMTP id 668846B0038
	for <linux-mm@kvack.org>; Tue,  9 Dec 2014 21:30:56 -0500 (EST)
Received: by mail-oi0-f54.google.com with SMTP id u20so1374185oif.27
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 18:30:56 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id ts6si2015116obb.38.2014.12.09.18.30.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 09 Dec 2014 18:30:55 -0800 (PST)
Message-ID: <5487AE8C.7000302@oracle.com>
Date: Tue, 09 Dec 2014 21:23:08 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: shmem: freeing mlocked page
References: <545C4A36.9050702@oracle.com>	<5466142C.60100@oracle.com> <20141118135843.bd711e95d3977c74cf51d803@linux-foundation.org> <5487ACC5.1010002@oracle.com>
In-Reply-To: <5487ACC5.1010002@oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, dbueso@suse.de, kirill@shutemov.name

(Apologies for spam, I've Cc'ed a few outdated emails in the previous mail)

On 12/09/2014 09:15 PM, Sasha Levin wrote:
> On 11/18/2014 04:58 PM, Andrew Morton wrote:
>>> [ 1026.994816] Modules linked in:
>>>> [ 1026.995378] CPU: 7 PID: 7879 Comm: trinity-c374 Not tainted 3.18.0-rc4-next-20141113-sasha-00047-gd1763ce-dirty #1455
>>>> [ 1026.996123] FAULT_INJECTION: forcing a failure.
>>>> [ 1026.996123] name failslab, interval 100, probability 30, space 0, times -1
>>>> [ 1026.999050]  0000000000000000 0000000000000000 0000000000b3d300 ffff88061295bbd8
>>>> [ 1027.000676]  ffffffff92f71097 0000000000000000 ffffea0000b3d300 ffff88061295bc08
>>>> [ 1027.002020]  ffffffff8197ef7a ffffea0000b3d300 ffffffff942dd148 dfffe90000000000
>>>> [ 1027.003359] Call Trace:
>>>> [ 1027.003831] dump_stack (lib/dump_stack.c:52)
>>>> [ 1027.004725] bad_page (mm/page_alloc.c:338)
>>>> [ 1027.005623] free_pages_prepare (mm/page_alloc.c:657 mm/page_alloc.c:763)
>>>> [ 1027.006761] free_hot_cold_page (mm/page_alloc.c:1438)
>>>> [ 1027.007772] ? __page_cache_release (mm/swap.c:66)
>>>> [ 1027.008815] put_page (mm/swap.c:270)
>>>> [ 1027.009665] page_cache_pipe_buf_release (fs/splice.c:93)
>>>> [ 1027.010888] __splice_from_pipe (fs/splice.c:784 fs/splice.c:886)
>>>> [ 1027.011917] ? might_fault (./arch/x86/include/asm/current.h:14 mm/memory.c:3734)
>>>> [ 1027.012856] ? pipe_lock (fs/pipe.c:69)
>>>> [ 1027.013728] ? write_pipe_buf (fs/splice.c:1534)
>>>> [ 1027.014756] vmsplice_to_user (fs/splice.c:1574)
>>>> [ 1027.015725] ? rcu_read_lock_held (kernel/rcu/update.c:169)
>>>> [ 1027.016757] ? __fget_light (include/linux/fdtable.h:80 fs/file.c:684)
>>>> [ 1027.017782] SyS_vmsplice (fs/splice.c:1656 fs/splice.c:1639)
>>>> [ 1027.018863] tracesys_phase2 (arch/x86/kernel/entry_64.S:529)
>>>>
>> So what happened here?  Userspace fed some mlocked memory into splice()
>> and then, while splice() was running, userspace dropped its reference
>> to the memory, leaving splice() with the last reference.  Yet somehow,
>> that page was still marked as being mlocked.  I wouldn't expect the
>> kernel to permit userspace to drop its reference to the memory without
>> first clearing the mlocked state.
>>
>> Is it possible to work out from trinity sources what the exact sequence
>> was?  Which syscalls are being used, for example?
> 
> Phew, this took a long while but I've bisected it (with good confidence) down
> to:
> 
> commit a38246260912ba4a0f8b563704a965a7a97cf3c3
> Author: Davidlohr Bueso <dave@stgolabs.net>
> Date:   Wed Dec 3 18:54:27 2014 +1100
> 
>     mm/memory.c: share the i_mmap_rwsem
> 
>     The unmap_mapping_range family of functions do the unmapping of user pages
>     (ultimately via zap_page_range_single) without touching the actual
>     interval tree, thus share the lock.
> 
>     Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
>     Cc: "Kirill A. Shutemov" <kirill@shutemov.name>
>     Acked-by: Hugh Dickins <hughd@google.com>
>     Cc: Oleg Nesterov <oleg@redhat.com>
>     Cc: Peter Zijlstra (Intel) <peterz@infradead.org>
>     Cc: Rik van Riel <riel@redhat.com>
>     Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
>     Acked-by: Mel Gorman <mgorman@suse.de>
>     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> 
> Thanks,
> Sasha
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
