Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f176.google.com (mail-vc0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 9ECC26B0031
	for <linux-mm@kvack.org>; Sat,  8 Mar 2014 20:18:35 -0500 (EST)
Received: by mail-vc0-f176.google.com with SMTP id lc6so5144753vcb.21
        for <linux-mm@kvack.org>; Sat, 08 Mar 2014 17:18:35 -0800 (PST)
Received: from mail-ve0-x231.google.com (mail-ve0-x231.google.com [2607:f8b0:400c:c01::231])
        by mx.google.com with ESMTPS id at8si3520128vec.75.2014.03.08.17.18.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 08 Mar 2014 17:18:34 -0800 (PST)
Received: by mail-ve0-f177.google.com with SMTP id sa20so5644826veb.36
        for <linux-mm@kvack.org>; Sat, 08 Mar 2014 17:18:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140308220024.GA814@redhat.com>
References: <20140308220024.GA814@redhat.com>
Date: Sat, 8 Mar 2014 17:18:34 -0800
Message-ID: <CA+55aFzLxY8Xsn90v1OAsmVBWYPZTiJ74YE=HaCPYR2hvRfk+g@mail.gmail.com>
Subject: Re: deadlock in lru_add_drain ? (3.14rc5)
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Chris Metcalf <cmetcalf@tilera.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

Adding more appropriate people to the cc.

That semaphore was added by commit 5fbc461636c3 ("mm: make
lru_add_drain_all() selective"), and acked by Tejun. But we've had
problems before with holding locks and then calling flush_work(),
since that has had a tendency of deadlocking. I think we have various
lockdep hacks in place to make "flush_work()" trigger some of the
problems, but I'm not convinced it necessarily works.

Tejun, mind giving this a look?

          Linus


On Sat, Mar 8, 2014 at 2:00 PM, Dave Jones <davej@redhat.com> wrote:
> I left my fuzzing box running for the weekend, and checked in on it this evening,
> to find that none of the child processes were making any progress.
> cat'ing /proc/n/stack shows them all stuck in the same place..
> Some examples:
>
> [<ffffffffbe163444>] lru_add_drain_all+0x34/0x200
> [<ffffffffbe1850d3>] SyS_mlock+0x33/0x130
> [<ffffffffbe7451b9>] ia32_sysret+0x0/0x5
> [<ffffffffffffffff>] 0xffffffffffffffff
>
> [<ffffffffbe163444>] lru_add_drain_all+0x34/0x200
> [<ffffffffbe1852fd>] SyS_mlockall+0xad/0x1a0
> [<ffffffffbe74366a>] tracesys+0xd4/0xd9
> [<ffffffffffffffff>] 0xffffffffffffffff
>
> [<ffffffffbe163444>] lru_add_drain_all+0x34/0x200
> [<ffffffffbe1850d3>] SyS_mlock+0x33/0x130
> [<ffffffffbe74366a>] tracesys+0xd4/0xd9
> [<ffffffffffffffff>] 0xffffffffffffffff
>
> [<ffffffffbe163444>] lru_add_drain_all+0x34/0x200
> [<ffffffffbe1b2dae>] SYSC_move_pages+0x2be/0x7c0
> [<ffffffffbe1b32be>] SyS_move_pages+0xe/0x10
> [<ffffffffbe74366a>] tracesys+0xd4/0xd9
> [<ffffffffffffffff>] 0xffffffffffffffff
>
> [<ffffffffbe089d41>] flush_work+0x1d1/0x290
> [<ffffffffbe16358b>] lru_add_drain_all+0x17b/0x200
> [<ffffffffbe1b2dae>] SYSC_move_pages+0x2be/0x7c0
> [<ffffffffbe1b32be>] SyS_move_pages+0xe/0x10
> [<ffffffffbe74366a>] tracesys+0xd4/0xd9
> [<ffffffffffffffff>] 0xffffffffffffffff
>
> [<ffffffffbe163444>] lru_add_drain_all+0x34/0x200
> [<ffffffffbe1b133e>] migrate_prep+0xe/0x20
> [<ffffffffbe1a22a0>] do_migrate_pages+0x40/0x2e0
> [<ffffffffbe1a2889>] SYSC_migrate_pages+0x349/0x3d0
> [<ffffffffbe1a292e>] SyS_migrate_pages+0xe/0x10
> [<ffffffffbe74366a>] tracesys+0xd4/0xd9
> [<ffffffffffffffff>] 0xffffffffffffffff
>
> <and more repeated variants of above>
>
> The problem seems to be that one of the processes has the mutex..
>
> [<ffffffffbe089d41>] flush_work+0x1d1/0x290
> [<ffffffffbe16358b>] lru_add_drain_all+0x17b/0x200
> [<ffffffffbe1b2dae>] SYSC_move_pages+0x2be/0x7c0
> [<ffffffffbe1b32be>] SyS_move_pages+0xe/0x10
> [<ffffffffbe74366a>] tracesys+0xd4/0xd9
> [<ffffffffffffffff>] 0xffffffffffffffff
>
> but that flush_work doesn't seem to ever complete.
>
> meminfo looks like this:
> MemTotal:        7959748 kB
> MemFree:         7133336 kB
> MemAvailable:    7112444 kB
> Buffers:            5720 kB
> Cached:           160712 kB
> SwapCached:        43248 kB
> Active:           328040 kB
> Inactive:         171252 kB
> Active(anon):     319172 kB
> Inactive(anon):   145732 kB
> Active(file):       8868 kB
> Inactive(file):    25520 kB
> Unevictable:           8 kB
> Mlocked:              20 kB
> SwapTotal:       8011772 kB
> SwapFree:        7936572 kB
> Dirty:                 0 kB
> Writeback:             0 kB
> AnonPages:        291280 kB
> Mapped:            52676 kB
> Shmem:            132044 kB
> Slab:             206256 kB
> SReclaimable:      92760 kB
> SUnreclaim:       113496 kB
> KernelStack:        1856 kB
> PageTables:         9244 kB
> NFS_Unstable:          0 kB
> Bounce:                0 kB
> WritebackTmp:          0 kB
> CommitLimit:    11991644 kB
> Committed_AS:   2470095756 kB
> VmallocTotal:   34359738367 kB
> VmallocUsed:      594580 kB
> VmallocChunk:   34359067436 kB
> HardwareCorrupted:     0 kB
> AnonHugePages:    192512 kB
> HugePages_Total:       0
> HugePages_Free:        0
> HugePages_Rsvd:        0
> HugePages_Surp:        0
> Hugepagesize:       2048 kB
> DirectMap4k:     8151108 kB
> DirectMap2M:    18446744073709541376 kB
> DirectMap1G:           0 kB
>
>
> That DirectMap2M looks kind of ridiculous, is that it?
>
> /proc//maps for the pid that's stuck in the flush looks like this:
>
> 00400000-0042f000 r-xp 00000000 08:05 671186187                          /home/davej/src/trinity/tmp/trinity.7bIfPZ/trinity
> 0062e000-0062f000 r--p 0002e000 08:05 671186187                          /home/davej/src/trinity/tmp/trinity.7bIfPZ/trinity
> 0062f000-00690000 rw-p 0002f000 08:05 671186187                          /home/davej/src/trinity/tmp/trinity.7bIfPZ/trinity
> 00690000-00691000 rw-p 00000000 00:00 0
> 024bf000-026f0000 rw-p 00000000 00:00 0                                  [heap]
> 026f0000-02be1000 rw-p 00000000 00:00 0                                  [heap]
> 02be1000-02db5000 rwxp 00000000 00:00 0                                  [heap]
> 7f686032b000-7f6860d2b000 -w-s 00000000 00:03 14115504                   /dev/zero (deleted)
> 7f6860d2b000-7f686172b000 -w-s 00000000 00:03 14111702                   /dev/zero (deleted)
> 7f686172b000-7f686212b000 -w-s 00000000 00:03 14109886                   /dev/zero (deleted)
> 7f686212b000-7f6862b2b000 -w-s 00000000 00:03 14105135                   /dev/zero (deleted)
> 7f6862b2b000-7f686352b000 -w-s 00000000 00:03 14102702                   /dev/zero (deleted)
> 7f686352b000-7f6863f2b000 -w-s 00000000 00:03 14094076                   /dev/zero (deleted)
> 7f6863f2b000-7f686492b000 r--s 00000000 00:03 14115503                   /dev/zero (deleted)
> 7f686492b000-7f686532b000 rw-s 00000000 00:03 14115502                   /dev/zero (deleted)
> 7f686532b000-7f686572b000 -w-s 00000000 00:03 14115501                   /dev/zero (deleted)
> 7f686572b000-7f6865b2b000 r--s 00000000 00:03 14115500                   /dev/zero (deleted)
> 7f6865b2b000-7f6865f2b000 rw-s 00000000 00:03 14115499                   /dev/zero (deleted)
> 7f6865f2b000-7f686612b000 -w-s 00000000 00:03 14115498                   /dev/zero (deleted)
> 7f686612b000-7f686632b000 r--s 00000000 00:03 14115497                   /dev/zero (deleted)
> 7f686632b000-7f686652b000 rw-s 00000000 00:03 14115496                   /dev/zero (deleted)
> 7f686652b000-7f686662b000 -w-s 00000000 00:03 14115495                   /dev/zero (deleted)
> 7f686662b000-7f686672b000 r--s 00000000 00:03 14115494                   /dev/zero (deleted)
> 7f686672b000-7f686682b000 rw-s 00000000 00:03 14115493                   /dev/zero (deleted)
> 7f686682b000-7f6866836000 r-xp 00000000 08:03 924881                     /usr/lib64/libnss_files-2.18.so
> 7f6866836000-7f6866a35000 ---p 0000b000 08:03 924881                     /usr/lib64/libnss_files-2.18.so
> 7f6866a35000-7f6866a36000 r--p 0000a000 08:03 924881                     /usr/lib64/libnss_files-2.18.so
> 7f6866a36000-7f6866a37000 rw-p 0000b000 08:03 924881                     /usr/lib64/libnss_files-2.18.so
> 7f6866a37000-7f6866beb000 r-xp 00000000 08:03 924770                     /usr/lib64/libc-2.18.so
> 7f6866beb000-7f6866deb000 ---p 001b4000 08:03 924770                     /usr/lib64/libc-2.18.so
> 7f6866deb000-7f6866def000 r--p 001b4000 08:03 924770                     /usr/lib64/libc-2.18.so
> 7f6866def000-7f6866df1000 rw-p 001b8000 08:03 924770                     /usr/lib64/libc-2.18.so
> 7f6866df1000-7f6866df6000 rw-p 00000000 00:00 0
> 7f6866df6000-7f6866e16000 r-xp 00000000 08:03 924755                     /usr/lib64/ld-2.18.so
> 7f6866ea3000-7f6866f03000 rw-p 00000000 00:00 0
> 7f6866f03000-7f6866f05000 -w-s 00000000 00:03 14115492                   /dev/zero (deleted)
> 7f6866f05000-7f6866f07000 r--s 00000000 00:03 14115491                   /dev/zero (deleted)
> 7f6866f07000-7f6866f09000 rw-s 00000000 00:03 14115490                   /dev/zero (deleted)
> 7f6866f09000-7f6866f0a000 rw-s 00000000 00:03 14094061                   /dev/zero (deleted)
> 7f6866f0a000-7f6866f0b000 rw-s 00000000 00:03 14094060                   /dev/zero (deleted)
> 7f6866f0b000-7f6866f0c000 rw-s 00000000 00:03 14094059                   /dev/zero (deleted)
> 7f6866f0c000-7f6866f0d000 rw-s 00000000 00:03 14094058                   /dev/zero (deleted)
> 7f6866f0d000-7f6866f0e000 rw-s 00000000 00:03 14094057                   /dev/zero (deleted)
> 7f6866f0e000-7f6866f0f000 rw-s 00000000 00:03 14094056                   /dev/zero (deleted)
> 7f6866f0f000-7f6866f10000 rw-s 00000000 00:03 14094055                   /dev/zero (deleted)
> 7f6866f10000-7f6866f11000 rw-s 00000000 00:03 14094054                   /dev/zero (deleted)
> 7f6866f11000-7f6866f12000 rw-s 00000000 00:03 14094053                   /dev/zero (deleted)
> 7f6866f12000-7f6866f13000 rw-s 00000000 00:03 14094052                   /dev/zero (deleted)
> 7f6866f13000-7f6866f14000 rw-s 00000000 00:03 14094051                   /dev/zero (deleted)
> 7f6866f14000-7f6866f15000 rw-s 00000000 00:03 14094050                   /dev/zero (deleted)
> 7f6866f15000-7f6866f16000 rw-s 00000000 00:03 14094049                   /dev/zero (deleted)
> 7f6866f16000-7f6866f17000 rw-s 00000000 00:03 14094048                   /dev/zero (deleted)
> 7f6866f17000-7f6866f18000 rw-s 00000000 00:03 14094047                   /dev/zero (deleted)
> 7f6866f18000-7f6866f19000 rw-s 00000000 00:03 14094046                   /dev/zero (deleted)
> 7f6866f19000-7f6866f1a000 rw-s 00000000 00:03 14094045                   /dev/zero (deleted)
> 7f6866f1a000-7f6866f1b000 rw-s 00000000 00:03 14094044                   /dev/zero (deleted)
> 7f6866f1b000-7f6866f1c000 rw-s 00000000 00:03 14094043                   /dev/zero (deleted)
> 7f6866f1c000-7f6866f3a000 ---s 00000000 00:03 14094035                   /dev/zero (deleted)
> 7f6866f3a000-7f6866f3f000 rw-s 0001e000 00:03 14094035                   /dev/zero (deleted)
> 7f6866f3f000-7f6866f5d000 ---s 00023000 00:03 14094035                   /dev/zero (deleted)
> 7f6866f5d000-7f6866fb8000 rw-s 00000000 00:03 14094034                   /dev/zero (deleted)
> 7f6866fb8000-7f6867009000 rw-s 00000000 00:03 14094033                   /dev/zero (deleted)
> 7f6867009000-7f686700c000 rw-p 00000000 00:00 0
> 7f686700c000-7f686700d000 rw-s 00000000 00:03 14094042                   /dev/zero (deleted)
> 7f686700d000-7f686700e000 rw-s 00000000 00:03 14094041                   /dev/zero (deleted)
> 7f686700e000-7f686700f000 rw-s 00000000 00:03 14094040                   /dev/zero (deleted)
> 7f686700f000-7f6867010000 rw-s 00000000 00:03 14094039                   /dev/zero (deleted)
> 7f6867010000-7f6867011000 rw-s 00000000 00:03 14094038                   /dev/zero (deleted)
> 7f6867011000-7f6867012000 rw-s 00000000 00:03 14094037                   /dev/zero (deleted)
> 7f6867012000-7f6867013000 rw-s 00000000 00:03 14094036                   /dev/zero (deleted)
> 7f6867013000-7f6867015000 rw-p 00000000 00:00 0
> 7f6867015000-7f6867016000 r--p 0001f000 08:03 924755                     /usr/lib64/ld-2.18.so
> 7f6867016000-7f6867017000 rw-p 00020000 08:03 924755                     /usr/lib64/ld-2.18.so
> 7f6867017000-7f6867018000 rw-p 00000000 00:00 0
> 7fff21aad000-7fff21ace000 rw-p 00000000 00:00 0                          [stack]
> 7fff21b94000-7fff21b95000 r-xp 00000000 00:00 0                          [vdso]
> ffffffffff600000-ffffffffff601000 r-xp 00000000 00:00 0                  [vsyscall]
>
> any ideas ?
>
>         Dave
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
