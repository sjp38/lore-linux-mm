Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id D974E6B0038
	for <linux-mm@kvack.org>; Tue, 18 Nov 2014 22:50:49 -0500 (EST)
Received: by mail-yk0-f174.google.com with SMTP id 10so2825517ykt.19
        for <linux-mm@kvack.org>; Tue, 18 Nov 2014 19:50:49 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id n45si343350yho.55.2014.11.18.19.50.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 18 Nov 2014 19:50:48 -0800 (PST)
Message-ID: <546C1202.1020502@oracle.com>
Date: Tue, 18 Nov 2014 22:44:02 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: shmem: freeing mlocked page
References: <545C4A36.9050702@oracle.com>	<5466142C.60100@oracle.com> <20141118135843.bd711e95d3977c74cf51d803@linux-foundation.org>
In-Reply-To: <20141118135843.bd711e95d3977c74cf51d803@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>, Jens Axboe <axboe@kernel.dk>

On 11/18/2014 04:58 PM, Andrew Morton wrote:
> On Fri, 14 Nov 2014 09:39:40 -0500 Sasha Levin <sasha.levin@oracle.com> wrote:
> 
>>
>> [ 1026.988043] BUG: Bad page state in process trinity-c374  pfn:23f70
>> [ 1026.989684] page:ffffea0000b3d300 count:0 mapcount:0 mapping:          (null) index:0x5b
>> [ 1026.991151] flags: 0x1fffff8028000c(referenced|uptodate|swapbacked|mlocked)
>> [ 1026.992410] page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
>> [ 1026.993479] bad because of flags:
>> [ 1026.994125] flags: 0x200000(mlocked)
> 
> Gee that new page dumping code is nice!
> 
>> [ 1026.994816] Modules linked in:
>> [ 1026.995378] CPU: 7 PID: 7879 Comm: trinity-c374 Not tainted 3.18.0-rc4-next-20141113-sasha-00047-gd1763ce-dirty #1455
>> [ 1026.996123] FAULT_INJECTION: forcing a failure.
>> [ 1026.996123] name failslab, interval 100, probability 30, space 0, times -1
>> [ 1026.999050]  0000000000000000 0000000000000000 0000000000b3d300 ffff88061295bbd8
>> [ 1027.000676]  ffffffff92f71097 0000000000000000 ffffea0000b3d300 ffff88061295bc08
>> [ 1027.002020]  ffffffff8197ef7a ffffea0000b3d300 ffffffff942dd148 dfffe90000000000
>> [ 1027.003359] Call Trace:
>> [ 1027.003831] dump_stack (lib/dump_stack.c:52)
>> [ 1027.004725] bad_page (mm/page_alloc.c:338)
>> [ 1027.005623] free_pages_prepare (mm/page_alloc.c:657 mm/page_alloc.c:763)
>> [ 1027.006761] free_hot_cold_page (mm/page_alloc.c:1438)
>> [ 1027.007772] ? __page_cache_release (mm/swap.c:66)
>> [ 1027.008815] put_page (mm/swap.c:270)
>> [ 1027.009665] page_cache_pipe_buf_release (fs/splice.c:93)
>> [ 1027.010888] __splice_from_pipe (fs/splice.c:784 fs/splice.c:886)
>> [ 1027.011917] ? might_fault (./arch/x86/include/asm/current.h:14 mm/memory.c:3734)
>> [ 1027.012856] ? pipe_lock (fs/pipe.c:69)
>> [ 1027.013728] ? write_pipe_buf (fs/splice.c:1534)
>> [ 1027.014756] vmsplice_to_user (fs/splice.c:1574)
>> [ 1027.015725] ? rcu_read_lock_held (kernel/rcu/update.c:169)
>> [ 1027.016757] ? __fget_light (include/linux/fdtable.h:80 fs/file.c:684)
>> [ 1027.017782] SyS_vmsplice (fs/splice.c:1656 fs/splice.c:1639)
>> [ 1027.018863] tracesys_phase2 (arch/x86/kernel/entry_64.S:529)
>>
> 
> So what happened here?  Userspace fed some mlocked memory into splice()
> and then, while splice() was running, userspace dropped its reference
> to the memory, leaving splice() with the last reference.  Yet somehow,
> that page was still marked as being mlocked.  I wouldn't expect the
> kernel to permit userspace to drop its reference to the memory without
> first clearing the mlocked state.
> 
> Is it possible to work out from trinity sources what the exact sequence
> was?  Which syscalls are being used, for example?

Trinity can't really log anything because attempts to log syscalls slow everything
down to a crawl to the point nothing reproduces.

I've just looked at that trace above, and got a bit more confused. I didn't think
that you can mlock page cache. How would a user do that exactly?


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
