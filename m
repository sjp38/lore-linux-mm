Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 1D2426B0035
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 22:19:21 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id kl14so1271666pab.15
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 19:19:20 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id gx4si12211126pbc.51.2014.01.22.19.19.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 19:19:19 -0800 (PST)
Message-ID: <52E088FC.2050407@oracle.com>
Date: Wed, 22 Jan 2014 22:14:04 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: BUG: Bad rss-counter state
References: <52E06B6F.90808@oracle.com> <alpine.DEB.2.02.1401221735450.26172@chino.kir.corp.google.com> <20140123015241.GA947@redhat.com> <52E07B63.1070400@oracle.com> <20140123022147.GA3221@redhat.com>
In-Reply-To: <20140123022147.GA3221@redhat.com>
Content-Type: multipart/mixed;
 boundary="------------060503060908030906080402"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, David Rientjes <rientjes@google.com>, khlebnikov@openvz.org, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

This is a multi-part message in MIME format.
--------------060503060908030906080402
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 01/22/2014 09:21 PM, Dave Jones wrote:
> On Wed, Jan 22, 2014 at 09:16:03PM -0500, Sasha Levin wrote:
>   > On 01/22/2014 08:52 PM, Dave Jones wrote:
>   > > Sasha, is this the current git tree version of Trinity ?
>   > > (I'm wondering if yesterdays munmap changes might be tickling this bug).
>   >
>   > Ah yes, my tree has the munmap patch from yesterday, which would explain why we
>   > started seeing this issue just now.
>
> So that change is basically allowing trinity to munmap just part of a prior mmap.
> So it may do things like..
>
> mmap   |--------------|
>
> munmap |----XXX-------|
>
> munmap |------XXX-----|
>
> ie, it might try unmapping some pages more than once, and may even overlap prior munmaps.
>
> until yesterdays change, it would only munmap the entire mmap.
>
> There's no easy way to tell exactly what happened without a trinity log of course.

I've attached the trinity log of the child that triggered the bug. Odd thing is that I
don't see any munmaps in it.


Thanks,
Sasha


--------------060503060908030906080402
Content-Type: text/x-log;
 name="trinity-child234.log"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="trinity-child234.log"

[child234:9994] [0] [32BIT] munlock(addr=0x7f724f784000, len=0x400000) = -1 (Cannot allocate memory)
[child234:9994] [1] remap_file_pages(start=0x7f724e984000, size=0x406f79, prot=0, pgoff=6, flags=0x10000) = 0
[child234:9994] [2] vmsplice(fd=682, iov=0x318d710, nr_segs=404, flags=2) = 0x5000
[child234:9994] [3] mbind(start=0x7f724f384000, len=0x400000, mode=1, nmask=0, maxnode=0x8000, flags=0) = 0
[child234:9994] [4] mmap(addr=0, len=0x200000, prot=7[PROT_READ|PROT_WRITE|PROT_EXEC], flags=0x43842, fd=682, off=0) = -1 (Invalid argument)
[child234:9994] [5] mprotect(start=0x7f7250384000, len=0x200000, prot=0) = 0
[child234:9994] [6] mprotect(start=0x7f7250886000, len=8192, prot=0x2000005) = -1 (Invalid argument)
[child234:9994] [7] munlock(addr=0x7f7250584000, len=0x100000) = 0
[child234:9994] [8] [32BIT] mlock(addr=0x7f7250684000, len=0x100000) = -1 (Cannot allocate memory)
[child234:9994] [9] move_pages(pid=0, nr_pages=236, pages=0x3015ed0, nodes=0x3111010, status=0x31909d0, flags=4) = 0
[child234:9994] [10] mlock(addr=0x7f7250384000, len=0x200000) = -1 (Cannot allocate memory)
[child234:9994] [11] remap_file_pages(start=0x7f724f784000, size=0x3bbfbd, prot=0, pgoff=19, flags=0) = 0
[child234:9994] [12] msync(start=0x7f724d584000, len=0xa00000, flags=3) = 0
[child234:9994] [13] mlock(addr=0x7f7250684000, len=0x100000) = 0
[child234:9994] [14] madvise(start=0x7f7250384000, len_in=0x200000, advice=0) = 0
[child234:9994] [15] mlock(addr=0x7f7250888000, len=8192) = 0
[child234:9994] [16] mbind(start=0x7f7250584000, len=0x100000, mode=0, nmask=0, maxnode=0x8000, flags=0x4000) = -1 (Invalid argument)
[child234:9994] [17] move_pages(pid=9896, nr_pages=124, pages=0x3015ed0, nodes=0x3190d90, status=0x3109500, flags=4) = -1 (Invalid argument)
[child234:9994] [18] mprotect(start=0x7f724df84000, len=0xa00000, prot=8) = 0
[child234:9994] [19] move_pages(pid=0, nr_pages=221, pages=0x3015ed0, nodes=0x3109700, status=0x3109a80, flags=6) = 0
[child234:9994] [20] [32BIT] madvise(start=0x7f7250184000, len_in=0x200000, advice=14) = -1 (Cannot allocate memory)
[child234:9994] [21] move_pages(pid=0, nr_pages=337, pages=0x3015ed0, nodes=0x318f790, status=0x318fce0, flags=4) = 0
[child234:9994] [22] move_pages(pid=9981, nr_pages=115, pages=0x3015ed0, nodes=0x3109e00, status=0x9db1a0, flags=4) = 0
[child234:9994] [23] migrate_pages(pid=0, maxnode=0x68000000000016c3, old_nodes=0x6ba000[page_0xff], new_nodes=0xffffffff81000000) = -1 (Invalid argument)
[child234:9994] [24] msync(start=0x7f7250384000, len=0x200000, flags=1) = 0
[child234:9994] [25] msync(start=0x7f724fb84000, len=0x400000, flags=6) = 0
[child234:9994] [26] mincore(start=0, len=0, vec=0xffffffff81000000) = -1 (Bad address)
[child234:9994] [27] remap_file_pages(start=0x7f7250184000, size=0x1597ab, prot=0, pgoff=336, flags=0) = 0
[child234:9994] [28] move_pages(pid=0, nr_pages=99, pages=0x3015ed0, nodes=0x3190230, status=0x9db380, flags=0) = 0
[child234:9994] [29] mincore(start=0x7f724df84000, len=0x31978b, vec=0x7f724df84001) = -1 (Bad address)
[child234:9994] [30] move_pages(pid=9962, nr_pages=83, pages=0x3015ed0, nodes=0x31113d0, status=0x9db520, flags=6) = -1 (Invalid argument)
[child234:9994] [31] [32BIT] madvise(start=0x7f7250384000, len_in=0x200000, advice=9) = -1 (Cannot allocate memory)
[child234:9994] [32] msync(start=0x7f7250886000, len=8192, flags=6) = 0
[child234:9994] [33] migrate_pages(pid=0, maxnode=0xffff929292929292, old_nodes=1, new_nodes=0x6c0000[page_allocs]) = -1 (Invalid argument)
[child234:9994] [34] mlock(addr=0x7f7250888000, len=8192) = 0
[child234:9994] [35] mbind(start=0x7f724fb84000, len=0x400000, mode=3, nmask=0x6c0000[page_allocs], maxnode=0x8000, flags=0) = -1 (Invalid argument)
[child234:9994] [36] vmsplice(fd=681, iov=0x31903d0, nr_segs=68, flags=1) = 4096
[child234:9994] [37] mbind(start=0x7f7250584000, len=0x100000, mode=3, nmask=0x3016ee0, maxnode=0x8000, flags=0x8000) = -1 (Invalid argument)
[child234:9994] [38] mmap(addr=0, len=0x40000000, prot=6[PROT_WRITE|PROT_EXEC], flags=1, fd=866, off=0) = -1 (Permission denied)
[child234:9994] [39] madvise(start=0x7f7250886000, len_in=8192, advice=10) = 0
[child234:9994] [40] mbind(start=0x7f7250784000, len=0x100000, mode=3, nmask=4, maxnode=0x8000, flags=0x8000) = -1 (Bad address)
[child234:9994] [41] munlock(addr=0x7f724fb84000, len=0x400000) = 0
[child234:9994] [42] mremap(addr=0x7f7250784000, old_len=0x100000, new_len=0x100000, flags=2, new_addr=0x40000000) = -1 (Invalid argument)
[child234:9994] [43] mremap(addr=0x7f7250684000, old_len=0x100000, new_len=0x100000, flags=0, new_addr=0) = 0x7f7250684000
[child234:9994] [44] remap_file_pages(start=0x7f7250684000, size=0xc76c, prot=0, pgoff=0, flags=0x10000) = 0
[child234:9994] [45] mmap(addr=0, len=0x200000, prot=0[PROT_NONE], flags=1, fd=866, off=0xb000) = -1 (Input/output error)
[child234:9994] [46] vmsplice(fd=866, iov=0x3018f50, nr_segs=536, flags=4) = -1 (Bad file descriptor)
[child234:9994] [47] move_pages(pid=0, nr_pages=331, pages=0x310e020, nodes=0x9db680, status=0x3018fa0, flags=4) = 0
[child234:9994] [48] vmsplice(fd=682, iov=0x3018ef0, nr_segs=944, flags=13) = 0x3430
[child234:9994] [49] [32BIT] mincore(start=1, len=0, vec=2) = -1 (Invalid argument)
[child234:9994] [50] [32BIT] munlock(addr=0x7f724fb84000, len=0x400000) = -1 (Cannot allocate memory)
[child234:9994] [51] vmsplice(fd=705, iov=0x30194e0, nr_segs=300, flags=2) = -1 (Bad file descriptor)
[child234:9994] [52] mremap(addr=0x7f7250888000, old_len=8192, new_len=8192, flags=0, new_addr=0) = 0x7f7250888000
[child234:9994] [53] mincore(start=0x2c00000000000000, len=0xdbcd, vec=0x6b7000[page_zeros]) = -1 (Cannot allocate memory)
[child234:9994] [54] move_pages(pid=0, nr_pages=296, pages=0x9e2c30, nodes=0x3019530, status=0x30199e0, flags=4) = 0
[child234:9994] [55] vmsplice(fd=304, iov=0x3019e90, nr_segs=208, flags=15) = -1 (Resource temporarily unavailable)
[child234:9994] [56] mlock(addr=0x7f7250384000, len=0x200000) = -1 (Cannot allocate memory)
[child234:9994] [57] [32BIT] vmsplice(fd=304, iov=0x3110040, nr_segs=171, flags=8) = -1 (Bad address)
[child234:9994] [58] move_pages(pid=9825, nr_pages=444, pages=0x9e8c90, nodes=0x3110090, status=0x3110790, flags=6) = -1 (Invalid argument)
[child234:9994] [59] mprotect(start=0x7f724f784000, len=0x400000, prot=0x2000003) = -1 (Invalid argument)
[child234:9994] [60] mlock(addr=0x7f724fb84000, len=0x400000) = 0
[child234:9994] [61] [32BIT] msync(start=0x7f724ff84000, len=0x200000, flags=3) = -1 (Cannot allocate memory)
[child234:9994] [62] mprotect(start=0x7f724f784000, len=0x400000, prot=0x3000009) = -1 (Invalid argument)
[child234:9994] [63] msync(start=0x7f724ff84000, len=0x200000, flags=3) = 0
[child234:9994] [64] mmap(addr=0, len=0x400000, prot=0[PROT_NONE], flags=0x9951, fd=708, off=0) = -1 (No such device)
[child234:9994] [65] vmsplice(fd=681, iov=0x3110ef0, nr_segs=419, flags=0) = 0x4000
[child234:9994] [66] remap_file_pages(start=0x7f7250384000, size=0x1b2764, prot=0, pgoff=418, flags=0x10000) = 0
[child234:9994] [67] mmap(addr=0, len=4096, prot=5[PROT_READ|PROT_EXEC], flags=0x1c902, fd=706, off=0xbff000) = -1 (No such device)
[child234:9994] [68] mincore(start=4, len=4096, vec=0x6c0000[page_allocs]) = -1 (Invalid argument)
[child234:9994] [69] vmsplice(fd=681, iov=0x3110f40, nr_segs=227, flags=5) = 0x3000
[child234:9994] [70] mincore(start=1, len=4688, vec=0x6ba000[page_0xff]) = -1 (Invalid argument)
[child234:9994] [71] move_pages(pid=0, nr_pages=184, pages=0x3194fd0, nodes=0x9ebcc0, status=0x3199010, flags=0) = 0
[child234:9994] [72] mprotect(start=0x7f724df84000, len=0xa00000, prot=0x2000002) = -1 (Invalid argument)
[child234:9994] [73] msync(start=0x7f7250684000, len=0x100000, flags=6) = -1 (Device or resource busy)
[child234:9994] [74] [32BIT] munlock(addr=0x7f724e984000, len=0xa00000) = -1 (Cannot allocate memory)
[child234:9994] [75] mremap(addr=0x7f7250884000, old_len=8192, new_len=8192, flags=0, new_addr=0) = 0x7f7250884000
[child234:9994] [76] remap_file_pages(start=0x7f724f384000, size=0xc771, prot=0, pgoff=12, flags=0) = 0
[child234:9994] [77] remap_file_pages(start=0x7f724ff84000, size=0x2a629, prot=0, pgoff=2, flags=0x10000) = 0
[child234:9994] [78] mincore(start=0x7f7250888000, len=0, vec=0x7f7250888008) = 0
[child234:9994] [79] migrate_pages(pid=0, maxnode=0xfffffffffff3df6f, old_nodes=0x3194fd0, new_nodes=0x3194fd4) = -1 (Invalid argument)
[child234:9994] [80] mbind(start=0x7f724f384000, len=0x400000, mode=3, nmask=0x3196fe0, maxnode=0x8000, flags=0x8000) = -1 (Invalid argument)
[child234:9994] [81] mprotect(start=0x7f7250584000, len=0x100000, prot=0x100000f) = -1 (Invalid argument)
[child234:9994] [82] mlock(addr=0x7f7250886000, len=8192) = 0
[child234:9994] [83] vmsplice(fd=304, iov=0x3110e90, nr_segs=255, flags=14) = 8192
[child234:9994] [84] remap_file_pages(start=0x7f7250684000, size=0x5c10, prot=0, pgoff=4, flags=0) = 0
[child234:9994] [85] madvise(start=0x7f7250184000, len_in=0x200000, advice=12) = -1 (Invalid argument)
[child234:9994] [86] move_pages(pid=0, nr_pages=247, pages=0x319b320, nodes=0x319c330, status=0x319c720, flags=0) = -1 (Cannot allocate memory)
[child234:9994] [87] madvise(start=0x7f724d584000, len_in=0xa00000, advice=0) = 0
[child234:9994] [88] mlock(addr=0x7f724f784000, len=0x400000) = 0
[child234:9994] [89] mprotect(start=0x7f724e984000, len=0xa00000, prot=0x2000004) = -1 (Invalid argument)
[child234:9994] [90] msync(start=0x7f7250684000, len=0x100000, flags=4) = 0
[child234:9994] [91] move_pages(pid=0, nr_pages=158, pages=0x319b320, nodes=0x319cb10, status=0x31a0010, flags=0) = -1 (Cannot allocate memory)
[child234:9994] [92] munlock(addr=0x7f724f384000, len=0x400000) = 0
[child234:9994] [93] move_pages(pid=0, nr_pages=102, pages=0x319b320, nodes=0x9ebfb0, status=0x319cd90, flags=4) = 0
[child234:9994] [94] mbind(start=0x7f724f384000, len=0x400000, mode=2, nmask=0x6c0000[page_allocs], maxnode=0x8000, flags=0x8000) = -1 (Invalid argument)
[child234:9994] [95] mmap(addr=0, len=0x400000, prot=0[PROT_NONE], flags=0x407b142, fd=682, off=0x800000) = -1 (Invalid argument)
[child234:9994] [96] mincore(start=0x6bd000[page_rand], len=215, vec=0x6b7000[page_zeros]) = 0
[child234:9994] [97] mbind(start=0x7f724f784000, len=0x400000, mode=3, nmask=0x6c0000[page_allocs], maxnode=0x8000, flags=0xc000) = -1 (Invalid argument)
[child234:9994] [98] [32BIT] msync(start=0x7f724ff84000, len=0x200000, flags=1) = -1 (Cannot allocate memory)
[child234:9994] [99] mbind(start=0x7f7250784000, len=0x100000, mode=0, nmask=0x6c0000[page_allocs], maxnode=0x8000, flags=0x4000) = -1 (Invalid argument)
[child234:9994] [100] madvise(start=0x7f7250884000, len_in=8192, advice=16) = 0
[child234:9994] [101] [32BIT] move_pages(pid=9810, nr_pages=80, pages=0x319b320, nodes=0x31a0290, status=0x31a03e0, flags=4) = -1 (Bad address)
[child234:9994] [102] madvise(start=0x7f724df84000, len_in=0xa00000, advice=15) = -1 (Invalid argument)
[child234:9994] [103] remap_file_pages(start=0x7f7250784000, size=0xcf32, prot=0, pgoff=12, flags=0) = 0
[child234:9994] [104] remap_file_pages(start=0x7f724fb84000, size=0x12d83f, prot=0, pgoff=265, flags=0) = 0
[child234:9994] [105] mlock(addr=0x7f7250584000, len=0x100000) = 0
[child234:9994] [106] migrate_pages(pid=0, maxnode=0x8000eaac576b0694, old_nodes=0xffffffff81000000, new_nodes=0xffffffff81000000) = -1 (Invalid argument)
[child234:9994] [107] mmap(addr=0, len=0x400000, prot=14[PROT_WRITE|PROT_EXEC|PROT_SEM], flags=97, fd=18446744073709551615, off=0) = 0x40fb4000
[child234:9994] [108] move_pages(pid=0, nr_pages=376, pages=0x319b320, nodes=0x31a0530, status=0x31a4010, flags=0) = 0
[child234:9994] [109] munlock(addr=0x40fb4000, len=0x400000) = 0
[child234:9994] [110] madvise(start=0x40fb4000, len_in=0x400000, advice=15) = -1 (Invalid argument)
[child234:9994] [111] madvise(start=0x40fb4000, len_in=0x400000, advice=10) = 0
[child234:9994] [112] msync(start=0x7f7250684000, len=0x100000, flags=1) = 0
[child234:9994] [113] mbind(start=0x40fb4000, len=0x400000, mode=2, nmask=0x6c0000[page_allocs], maxnode=0x8000, flags=0x4000) = -1 (Invalid argument)
[child234:9994] [114] move_pages(pid=0, nr_pages=297, pages=0x319b320, nodes=0x31a0b20, status=0x31a4600, flags=2) = 0
[child234:9994] [115] migrate_pages(pid=10056, maxnode=0xffffffffff51a690, old_nodes=4, new_nodes=0x6ba000[page_0xff]) = -1 (Invalid argument)
[child234:9994] [116] vmsplice(fd=682, iov=0x3110ec0, nr_segs=811, flags=9) = 8192
[child234:9994] [117] [32BIT] mprotect(start=0x40fb4000, len=0x400000, prot=14) = 0
[child234:9994] [118] mincore(start=0, len=92, vec=0) = -1 (Cannot allocate memory)
[child234:9994] [119] mremap(addr=0x7f7250888000, old_len=8192, new_len=8192, flags=2, new_addr=0x400000) = -1 (Invalid argument)
[child234:9994] [120] mincore(start=0xffffffff81000000, len=253, vec=0x319cf30) = -1 (Cannot allocate memory)
[child234:9994] [121] move_pages(pid=0, nr_pages=279, pages=0x319ef40, nodes=0x31a4ab0, status=0x31a8010, flags=6) = -1 (Cannot allocate memory)
[child234:9994] [122] move_pages(pid=9888, nr_pages=438, pages=0x319ef40, nodes=0x31a8480, status=0x31ac010, flags=2) = -1 (Invalid argument)
[child234:9994] [123] [32BIT] mincore(start=0, len=1554, vec=8) = -1 (Cannot allocate memory)
[child234:9994] [124] vmsplice(fd=680, iov=0x9ec190, nr_segs=721, flags=1) = 8192
[child234:9994] [125] mmap(addr=0, len=0x40000000, prot=2[PROT_WRITE], flags=0x47011, fd=691, off=0xf9714000) = -1 (Invalid argument)
[child234:9994] [126] mbind(start=0x40fb4000, len=0x400000, mode=1, nmask=0, maxnode=0x8000, flags=0) = 0
[child234:9994] [127] mincore(start=0x6c0000[page_allocs], len=15, vec=0x6b7000[page_zeros]) = 0
[child234:9994] [128] mincore(start=0, len=57, vec=0x6b7000[page_zeros]) = -1 (Cannot allocate memory)
[child234:9994] [129] mprotect(start=0x40fb4000, len=0x400000, prot=15) = 0
[child234:9994] [130] mremap(addr=0x40fb4000, old_len=0x400000, new_len=0x400000, flags=0, new_addr=0) = 0x40fb4000
[child234:9994] [131] mincore(start=4, len=255, vec=4) = -1 (Invalid argument)
[child234:9994] [132] munlock(addr=0x7f7250886000, len=8192) = 0
[child234:9994] [133] mlock(addr=0x7f7250584000, len=0x100000) = 0
[child234:9994] [134] mprotect(start=0x7f724e984000, len=0xa00000, prot=0x200000a) = -1 (Invalid argument)
[child234:9994] [135] madvise(start=0x7f7250384000, len_in=0x200000, advice=13) = -1 (Invalid argument)
[child234:9994] [136] migrate_pages(pid=0, maxnode=0xffffffffff3fb5a5, old_nodes=0x40fb4000, new_nodes=0xffffffff81000000) = -1 (Invalid argument)
[child234:9994] [137] mremap(addr=0x40fb4000, old_len=0x400000, new_len=0x400000, flags=2, new_addr=0x400000) = -1 (Invalid argument)
[child234:9994] [138] [32BIT] msync(start=0x40fb4000, len=0x400000, flags=1) = 0
[child234:9994] [139] migrate_pages(pid=9940, maxnode=0xffffffffffffff00, old_nodes=0xffffffff81000000, new_nodes=0x7f7250184000) = -1 (Invalid argument)
[child234:9994] [140] remap_file_pages(start=0x40fb4000, size=0x259a4f, prot=0, pgoff=1, flags=0x10000) = 0
[child234:9994] [141] move_pages(pid=0, nr_pages=503, pages=0x31a5f30, nodes=0x31ac6f0, status=0x31b0010, flags=0) = 0
[child234:9994] [142] mmap(addr=0, len=4096, prot=9[PROT_READ|PROT_SEM], flags=0x4008112, fd=842, off=0) = -1 (Invalid argument)
[child234:9994] [143] mlock(addr=0x7f724d584000, len=0xa00000) = 0
[child234:9994] [144] mbind(start=0x40fb4000, len=0x400000, mode=2, nmask=0x6b7000[page_zeros], maxnode=0x8000, flags=0) = 0
[child234:9994] [145] mlock(addr=0x7f7250684000, len=0x100000) = 0
[child234:9994] [146] migrate_pages(pid=0, maxnode=0xfffffffffffffbb7, old_nodes=0, new_nodes=1) = -1 (Invalid argument)
[child234:9994] [147] mprotect(start=0x40fb4000, len=0x400000, prot=0x3000000) = -1 (Invalid argument)
[child234:9994] [148] remap_file_pages(start=0x40fb4000, size=0x368b10, prot=0, pgoff=8, flags=0x10000) = 0
[child234:9994] [149] [32BIT] mmap(addr=0, len=0xa00000, prot=6[PROT_WRITE|PROT_EXEC], flags=0x10072, fd=18446744073709551615, off=0) = -1 (Bad address)
[child234:9994] [150] msync(start=0x7f7250888000, len=8192, flags=6) = -1 (Device or resource busy)
[child234:9994] [151] mincore(start=1, len=0xffffff, vec=0x6c0000[page_allocs]) = -1 (Invalid argument)
[child234:9994] [152] [32BIT] mlock(addr=0x7f7250184000, len=0x200000) = -1 (Cannot allocate memory)
[child234:9994] [153] migrate_pages(pid=9912, maxnode=0xc000000e11f301a, old_nodes=0, new_nodes=0x2000000080001000) = -1 (Invalid argument)
[child234:9994] [154] mbind(start=0x7f7250184000, len=0x200000, mode=3, nmask=8, maxnode=0x8000, flags=0) = -1 (Bad address)
[child234:9994] [155] mbind(start=0x7f724fb84000, len=0x400000, mode=3, nmask=8, maxnode=0x8000, flags=0x4000) = -1 (Bad address)
[child234:9994] [156] mremap(addr=0x40fb4000, old_len=0x400000, new_len=0x400000, flags=0, new_addr=0) = 0x40fb4000
[child234:9994] [157] mmap(addr=0, len=0x40000000, prot=13[PROT_READ|PROT_EXEC|PROT_SEM], flags=1, fd=681, off=4096) = -1 (No such device)
[child234:9994] [158] munlock(addr=0x7f7250184000, len=0x200000) = 0
[child234:9994] [159] mbind(start=0x40fb4000, len=0x400000, mode=3, nmask=0x6bd000[page_rand], maxnode=0x8000, flags=0) = -1 (Invalid argument)
[child234:9994] [160] [32BIT] munlock(addr=0x7f724df84000, len=0xa00000) = -1 (Cannot allocate memory)
[child234:9994] [161] madvise(start=0x7f7250684000, len_in=0x100000, advice=3) = 0
[child234:9994] [162] munlock(addr=0x40fb4000, len=0x400000) = 0
[child234:9994] [163] munlock(addr=0x40fb4000, len=0x400000) = 0
[child234:9994] [164] remap_file_pages(start=0x40fb4000, size=0x38f0a8, prot=0, pgoff=396, flags=0x10000) = 0
[child234:9994] [165] mbind(start=0x40fb4000, len=0x400000, mode=1, nmask=0x6b7000[page_zeros], maxnode=0x8000, flags=0) = 0
[child234:9994] [166] [32BIT] mmap(addr=0, len=4096, prot=6[PROT_WRITE|PROT_EXEC], flags=0x4049012, fd=681, off=4096) = -1 (Bad address)
[child234:9994] [167] mbind(start=0x40fb4000, len=0x400000, mode=3, nmask=0x6ba000[page_0xff], maxnode=0x8000, flags=0xc000) = -1 (Invalid argument)
[child234:9994] [168] vmsplice(fd=680, iov=0x31a3ff0, nr_segs=114, flags=0) = 4096
[child234:9994] [169] mbind(start=0x40fb4000, len=0x400000, mode=3, nmask=0, maxnode=0x8000, flags=0) = -1 (Invalid argument)
[child234:9994] [170] mlock(addr=0x7f724ff84000, len=0x200000) = 0
[child234:9994] [171] mremap(addr=0x40fb4000, old_len=0x400000, new_len=0x400000, flags=3, new_addr=0x40000000) = 0x40000000
[child234:9994] [172] mbind(start=0x7f724ff84000, len=0x200000, mode=0, nmask=0x6c0000[page_allocs], maxnode=0x8000, flags=0) = -1 (Invalid argument)
[child234:9994] [173] mbind(start=0x7f7250886000, len=8192, mode=0, nmask=4, maxnode=0x8000, flags=0xc000) = -1 (Bad address)
[child234:9994] [174] move_pages(pid=0, nr_pages=338, pages=0x31a6f40, nodes=0x31b0800, status=0x31b4010, flags=0) = 0
[child234:9994] [175] remap_file_pages(start=0x40000000, size=0x1a270a, prot=0, pgoff=0, flags=0) = 0
[child234:9994] [176] mmap(addr=0, len=0x40000000, prot=7[PROT_READ|PROT_WRITE|PROT_EXEC], flags=0x8901, fd=705, off=0xfff000) = -1 (No such device)
[child234:9994] [177] mmap(addr=0, len=4096, prot=12[PROT_EXEC|PROT_SEM], flags=0x24022, fd=18446744073709551615, off=0) = 0x7f724d1e5000
[child234:9994] [178] vmsplice(fd=682, iov=0x319ff50, nr_segs=535, flags=7) = 0x3000
[child234:9994] [179] munlock(addr=0x7f724f784000, len=0x400000) = 0
[child234:9994] [180] [32BIT] madvise(start=0x40000000, len_in=0x400000, advice=11) = 0
[child234:9994] [181] mlock(addr=0x7f7250884000, len=8192) = 0
[child234:9994] [182] move_pages(pid=0, nr_pages=429, pages=0x31aef00, nodes=0x31b4560, status=0x31b8010, flags=0) = 0
[child234:9994] [183] migrate_pages(pid=0, maxnode=0x8000000000000400, old_nodes=0x6bd000[page_rand], new_nodes=0x6bd008[page_rand]) = -1 (Invalid argument)
[child234:9994] [184] vmsplice(fd=681, iov=0x3110f80, nr_segs=175, flags=14) = 4096
[child234:9994] [185] mincore(start=4, len=0, vec=12) = -1 (Invalid argument)
[child234:9994] [186] [32BIT] mlock(addr=0x40000000, len=0x400000) = -1 (Cannot allocate memory)
[child234:9994] [187] mbind(start=0x7f7250888000, len=8192, mode=3, nmask=8, maxnode=0x8000, flags=0x8000) = -1 (Bad address)
[child234:9994] [188] msync(start=0x40000000, len=0x400000, flags=1) = 0
[child234:9994] [189] remap_file_pages(start=0x7f7250184000, size=0xe2420, prot=0, pgoff=192, flags=0x10000) = 0
[child234:9994] [190] madvise(start=0x7f724d1e5000, len_in=4096, advice=3) = 0
[child234:9994] [191] [32BIT] madvise(start=0x40000000, len_in=0x400000, advice=1) = 0
[child234:9994] [192] munlock(addr=0x7f724f384000, len=0x400000) = 0
[child234:9994] [193] move_pages(pid=0, nr_pages=318, pages=0x31b0d50, nodes=0x31b86d0, status=0x31bc010, flags=0) = 0
[child234:9994] [194] remap_file_pages(start=0x40000000, size=0x25cad7, prot=0, pgoff=532, flags=0) = 0
[child234:9994] [195] mlock(addr=0x40000000, len=0x400000) = -1 (Cannot allocate memory)
[child234:9994] [196] mincore(start=8, len=0x58000010, vec=0x6b7000[page_zeros]) = -1 (Invalid argument)
[child234:9994] [197] [32BIT] mmap_pgoff(addr=0, len=149, prot=4, flags=0x37912, fd=697, pgoff=255) = -1 (No such device)
[child234:9994] [198] mincore(start=0x6b7000[page_zeros], len=207, vec=0x8c5000) = 0
[child234:9994] [199] madvise(start=0x7f724d1e5000, len_in=4096, advice=0) = 0
[child234:9994] [200] munlock(addr=0x7f724df84000, len=0xa00000) = 0
[child234:9994] [201] mincore(start=0, len=0, vec=0) = 0
[child234:9994] [202] msync(start=0x7f724d1e5000, len=4096, flags=6) = 0
[child234:9994] [203] migrate_pages(pid=0, maxnode=0x8000000000e87cae, old_nodes=0x7f724d584000, new_nodes=0x7f724d584001) = -1 (Invalid argument)
[child234:9994] [204] [32BIT] remap_file_pages(start=0x7f724d1e5000, size=1045, prot=0, pgoff=0, flags=0x10000) = -1 (Invalid argument)
[child234:9994] [205] madvise(start=0x7f724df84000, len_in=0xa00000, advice=17) = 0
[child234:9994] [206] munlock(addr=0x7f724d1e5000, len=4096) = 0
[child234:9994] [207] mremap(addr=0x7f724ff84000, old_len=0x200000, new_len=0x200000, flags=2, new_addr=0x100000) = -1 (Invalid argument)
[child234:9994] [208] msync(start=0x40000000, len=0x400000, flags=4) = 0
[child234:9994] [209] munlock(addr=0x7f724df84000, len=0xa00000) = 0
[child234:9994] [210] mincore(start=0x6bd000[page_rand], len=0xc3fa, vec=0x6ba000[page_0xff]) = 0
[child234:9994] [211] remap_file_pages(start=0x7f724df84000, size=0xa0e1a, prot=0, pgoff=0, flags=0) = 0
[child234:9994] [212] remap_file_pages(start=0x7f724d584000, size=0x8db565, prot=0, pgoff=193, flags=0) = 0
[child234:9994] [213] mremap(addr=0x40000000, old_len=0x400000, new_len=0x400000, flags=0, new_addr=0) = 0x40000000
[child234:9994] [214] mbind(start=0x40000000, len=0x400000, mode=0, nmask=1, maxnode=0x8000, flags=0x4000) = -1 (Bad address)
[child234:9994] [215] madvise(start=0x7f724ff84000, len_in=0x200000, advice=17) = 0
[child234:9994] [216] mprotect(start=0x7f7250784000, len=0x100000, prot=0) = 0
[child234:9994] [217] migrate_pages(pid=0, maxnode=0x1ffdffff, old_nodes=1, new_nodes=5) = -1 (Invalid argument)
[child234:9994] [218] migrate_pages(pid=0, maxnode=0x4200000000000000, old_nodes=4, new_nodes=0xffffffffffffff77) = -1 (Invalid argument)
[child234:9994] [219] remap_file_pages(start=0x7f724d1e5000, size=2215, prot=0, pgoff=0, flags=0) = -1 (Invalid argument)
[child234:9994] [220] remap_file_pages(start=0x7f7250884000, size=5644, prot=0, pgoff=0, flags=0) = 0
[child234:9994] [221] [32BIT] remap_file_pages(start=0x7f724f784000, size=0x3e2f51, prot=0, pgoff=258, flags=0) = -1 (Invalid argument)
[child234:9994] [222] vmsplice(fd=870, iov=0x3110fa0, nr_segs=485, flags=12) = -1 (Bad file descriptor)
[child234:9994] [223] move_pages(pid=0, nr_pages=339, pages=0x31b1d60, nodes=0x31bc510, status=0x31bca70, flags=4) = 0
[child234:9994] [224] mremap(addr=0x7f724f784000, old_len=0x400000, new_len=0x400000, flags=3, new_addr=0xa00000) = 0xa00000
[child234:9994] [225] vmsplice(fd=680, iov=0x319ff90, nr_segs=782, flags=5) = 8192
[child234:9994] [226] mprotect(start=0x40000000, len=0x400000, prot=9) = 0
[child234:9994] [227] [32BIT] mmap_pgoff(addr=0xa00000, len=113, prot=6, flags=0x4a001, fd=918, pgoff=0) = -1 (Invalid argument)
[child234:9994] [228] msync(start=0x40000000, len=0x400000, flags=4) = 0
[child234:9994] [229] vmsplice(fd=682, iov=0x319ffc0, nr_segs=200, flags=5) = 0x3000
[child234:9994] [230] mlock(addr=0x7f724fb84000, len=0x400000) = 0
[child234:9994] [231] mlock(addr=0x40000000, len=0x400000) = -1 (Cannot allocate memory)
[child234:9994] [232] [32BIT] msync(start=0x7f7250886000, len=8192, flags=6) = -1 (Cannot allocate memory)
[child234:9994] [233] mbind(start=0x7f7250184000, len=0x200000, mode=3, nmask=0x6c0000[page_allocs], maxnode=0x8000, flags=0) = -1 (Invalid argument)
[child234:9994] [234] mmap(addr=0, len=4096, prot=7[PROT_READ|PROT_WRITE|PROT_EXEC], flags=0x34062, fd=18446744073709551615, off=0) = 0x40e51000
[child234:9994] [235] move_pages(pid=0, nr_pages=308, pages=0x31b9be0, nodes=0x31c0010, status=0x31c04f0, flags=0) = 0
[child234:9994] [236] remap_file_pages(start=0x7f7250184000, size=0xfdb82, prot=0, pgoff=252, flags=0) = 0
[child234:9994] [237] [32BIT] mbind(start=0x7f7250888000, len=8192, mode=0, nmask=0x6c0000[page_allocs], maxnode=0x8000, flags=0x4000) = -1 (Invalid argument)
[child234:9994] [238] msync(start=0x7f7250684000, len=0x100000, flags=4) = 0
[child234:9994] [239] mremap(addr=0x7f724d1e5000, old_len=4096, new_len=4096, flags=3, new_addr=0x100000) = 0x100000
[child234:9994] [240] msync(start=0x40e51000, len=4096, flags=3) = 0
[child234:9994] [241] [32BIT] mincore(start=8, len=0x1d460, vec=0xffffffff81000000) = -1 (Invalid argument)
[child234:9994] [242] migrate_pages(pid=0, maxnode=0x84000000ca1c7a69, old_nodes=0, new_nodes=4) = -1 (Invalid argument)
[child234:9994] [243] mmap(addr=0, len=0x40000000, prot=9[PROT_READ|PROT_SEM], flags=0x4065822, fd=18446744073709551615, off=0) = -1 (Invalid argument)
[child234:9994] [244] munlock(addr=0x7f7250886000, len=8192) = 0
[child234:9994] [245] mprotect(start=0x7f7250384000, len=0x200000, prot=9) = 0
[child234:9994] [246] munlock(addr=0x40000000, len=0x400000) = 0
[child234:9994] [247] migrate_pages(pid=9777, maxnode=0x8000000000000008, old_nodes=0x6bd000[page_rand], new_nodes=0x6bd008[page_rand]) = -1 (Invalid argument)
[child234:9994] [248] vmsplice(fd=688, iov=0x31aff10, nr_segs=709, flags=1) = -1 (Bad file descriptor)
[child234:9994] [249] mincore(start=1, len=108, vec=0xffffffff81000000) = -1 (Invalid argument)
[child234:9994] [250] mmap(addr=0, len=0x40000000, prot=0[PROT_NONE], flags=0x2a001, fd=921, off=0xfffff000) = -1 (Input/output error)
[child234:9994] [251] msync(start=0x40e51000, len=4096, flags=1) = 0
[child234:9994] [252] [32BIT] mmap_pgoff(addr=0x6b7000[page_zeros], len=0x51c3, prot=2, flags=32, fd=921, pgoff=0xe9bb) = -1 (Invalid argument)
[child234:9994] [253] munlock(addr=0x7f724ff84000, len=0x200000) = 0
[child234:9994] [254] mmap(addr=0, len=0xa00000, prot=3[PROT_READ|PROT_WRITE], flags=0x402a132, fd=18446744073709551615, off=0) 
--------------060503060908030906080402--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
