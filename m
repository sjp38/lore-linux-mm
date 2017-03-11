Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id F20256B0465
	for <linux-mm@kvack.org>; Sat, 11 Mar 2017 08:54:50 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id e5so213279418pgk.1
        for <linux-mm@kvack.org>; Sat, 11 Mar 2017 05:54:50 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id d13si12913409pln.274.2017.03.11.05.54.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 11 Mar 2017 05:54:49 -0800 (PST)
Date: Sat, 11 Mar 2017 21:54:36 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [mm/kasan] BUG: KASAN: slab-out-of-bounds in inotify_read at addr
 ffff88001539780c
Message-ID: <20170311135436.hh2pvivpiadkgdkr@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="tgxxsl4wajdjvchp"
Content-Disposition: inline
In-Reply-To: <20170228031227.tm7flsxl7t7klspf@wfg-t540p.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, LKP <lkp@01.org>


--tgxxsl4wajdjvchp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Alexander,

FYI, here is another bisect result.

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master

commit 80a9201a5965f4715d5c09790862e0df84ce0614
Author:     Alexander Potapenko <glider@google.com>
AuthorDate: Thu Jul 28 15:49:07 2016 -0700
Commit:     Linus Torvalds <torvalds@linux-foundation.org>
CommitDate: Thu Jul 28 16:07:41 2016 -0700

     mm, kasan: switch SLUB to stackdepot, enable memory quarantine for SLUB
     
     For KASAN builds:
      - switch SLUB allocator to using stackdepot instead of storing the
        allocation/deallocation stacks in the objects;
      - change the freelist hook so that parts of the freelist can be put
        into the quarantine.
     
     [aryabinin@virtuozzo.com: fixes]
       Link: http://lkml.kernel.org/r/1468601423-28676-1-git-send-email-aryabinin@virtuozzo.com
     Link: http://lkml.kernel.org/r/1468347165-41906-3-git-send-email-glider@google.com
     Signed-off-by: Alexander Potapenko <glider@google.com>
     Cc: Andrey Konovalov <adech.fo@gmail.com>
     Cc: Christoph Lameter <cl@linux.com>
     Cc: Dmitry Vyukov <dvyukov@google.com>
     Cc: Steven Rostedt (Red Hat) <rostedt@goodmis.org>
     Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
     Cc: Kostya Serebryany <kcc@google.com>
     Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
     Cc: Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>
     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

c146a2b98e  mm, kasan: account for object redzone in SLUB's nearest_obj()
80a9201a59  mm, kasan: switch SLUB to stackdepot, enable memory quarantine for SLUB
434fd6353b  Merge tag 'tty-4.11-rc2' of git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/tty
5be4921c99  Add linux-next specific files for 20170310
+------------------------------+------------+------------+------------+---------------+
|                              | c146a2b98e | 80a9201a59 | 434fd6353b | next-20170310 |
+------------------------------+------------+------------+------------+---------------+
| boot_successes               | 31         | 0          | 0          | 0             |
| boot_failures                | 0          | 11         | 13         | 11            |
| BUG:KASAN:slab-out-of-bounds | 0          | 11         | 13         | 11            |
| calltrace:SyS_read           | 0          | 11         |            |               |
| calltrace:SyS_linkat         | 0          | 11         |            |               |
| calltrace:SyS_link           | 0          | 11         |            |               |
| calltrace:SyS_unlink         | 0          | 11         |            |               |
| calltrace:SyS_write          | 0          | 11         |            |               |
| calltrace:SyS_getdents       | 0          | 9          |            |               |
| calltrace:sock_init          | 0          | 9          |            |               |
| calltrace:ide_cdrom_init     | 0          | 9          |            |               |
| calltrace:md_init            | 0          | 9          |            |               |
| calltrace:init_scsi          | 0          | 9          |            |               |
| calltrace:init_xfs_fs        | 0          | 7          |            |               |
| calltrace:init_devpts_fs     | 0          | 7          |            |               |
| calltrace:sysctl_core_init   | 0          | 3          |            |               |
| calltrace:af_unix_init       | 0          | 3          |            |               |
+------------------------------+------------+------------+------------+---------------+

[   22.974867] debug: unmapping init [mem 0xffff8800023f5000-0xffff8800023fffff]
[   40.729584] x86/mm: Checked W+X mappings: passed, no W+X pages found.
[   40.743879] random: init: uninitialized urandom read (12 bytes read)
[   40.754136] hostname (177) used greatest stack depth: 29632 bytes left
[   40.791170] ==================================================================
[   40.792751] BUG: KASAN: slab-out-of-bounds in inotify_read+0x1ac/0x2c6 at addr ffff88001539780c
[   40.794614] Read of size 5 by task init/1
[   40.795491] CPU: 0 PID: 1 Comm: init Not tainted 4.7.0-05999-g80a9201 #1
[   40.796933] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.9.3-20161025_171302-gandalf 04/01/2014
[   40.798606]  ffffed0002a72f02 ffff88000004fcb8 ffffffff813fbc56 ffff88000004fd48
[   40.799906]  ffffffff81125e14 ffff880000000000 ffff880000041300 0000000000000246
[   40.801214]  0000000000000282 ffff880011331b00 0000000000000010 0000000000000246
[   40.802505] Call Trace:
[   40.802934]  [<ffffffff813fbc56>] dump_stack+0x19/0x1b
[   40.803791]  [<ffffffff81125e14>] kasan_report+0x316/0x552
[   40.804670]  [<ffffffff81124ca6>] check_memory_region+0x10b/0x10d
[   40.805674]  [<ffffffff81124d7b>] kasan_check_read+0x11/0x13
[   40.806623]  [<ffffffff81171647>] inotify_read+0x1ac/0x2c6
[   40.807535]  [<ffffffff8108cda1>] ? wait_woken+0x76/0x76
[   40.808425]  [<ffffffff811382b0>] __vfs_read+0x23/0xe3
[   40.809270]  [<ffffffff813a372f>] ? security_file_permission+0x93/0x9c
[   40.810351]  [<ffffffff81138406>] vfs_read+0x96/0x102
[   40.811181]  [<ffffffff811387cb>] SyS_read+0x4e/0x94
[   40.812010]  [<ffffffff81d379bd>] entry_SYSCALL_64_fastpath+0x23/0xc1
[   40.813058] Object at ffff8800153977e0, in cache kmalloc-64
[   40.813979] Object allocated with size 54 bytes.
[   40.814697] Allocation:
[   40.815123] PID = 189
[   40.815514]  [<ffffffff81010c9f>] save_stack_trace+0x27/0x45
[   40.816473]  [<ffffffff8112530e>] kasan_kmalloc+0xe5/0x16c
[   40.817399]  [<ffffffff81123d1d>] __kmalloc+0x16c/0x17e
[   40.818289]  [<ffffffff8117106e>] inotify_handle_event+0x80/0x10e
[   40.819323]  [<ffffffff8116f8b0>] fsnotify+0x3c5/0x4f4
[   40.820200]  [<ffffffff81145c5b>] vfs_link+0x1d8/0x210
[   40.821070]  [<ffffffff81145dfb>] SyS_linkat+0x168/0x22c
[   40.821981]  [<ffffffff81145ed8>] SyS_link+0x19/0x1b
[   40.822805]  [<ffffffff81d379bd>] entry_SYSCALL_64_fastpath+0x23/0xc1
[   40.823902] Memory state around the buggy address:
[   40.824664]  ffff880015397700: fc fc fc fc 00 00 00 00 00 00 00 fc fc fc fc fc

                                                          # HH:MM RESULT GOOD BAD GOOD_BUT_DIRTY DIRTY_NOT_BAD
git bisect start v4.8 v4.7 --
git bisect  bad e6e7214fbbdab1f90254af68e0927bdb24708d22  # 17:23  B      0     7   17   0  Merge branch 'sched-urgent-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
git bisect  bad ba929b6646c5b87c7bb15cd8d3e51617725c983b  # 17:31  B      0     2   12   0  Merge branch 'for-linus-4.8' of git://git.kernel.org/pub/scm/linux/kernel/git/mason/linux-btrfs
git bisect good 468fc7ed5537615efe671d94248446ac24679773  # 17:44  G     11     0    0   0  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next
git bisect  bad e55884d2c6ac3ae50e49a1f6fe38601a91181719  # 17:59  B      0     5   15   0  Merge tag 'vfio-v4.8-rc1' of git://github.com/awilliam/linux-vfio
git bisect good 554828ee0db41618d101d9549db8808af9fd9d65  # 18:16  G     10     0    0   0  Merge branch 'salted-string-hash'
git bisect good ce8c891c3496d3ea4a72ec40beac9a7b7f6649bf  # 18:30  G     11     0    0   0  Merge tag 'rproc-v4.8' of git://github.com/andersson/remoteproc
git bisect  bad 1c88e19b0f6a8471ee50d5062721ba30b8fd4ba9  # 18:39  B      0    11   21   0  Merge branch 'akpm' (patches from Andrew)
git bisect good c9b011a87dd49bac1632311811c974bb7cd33c25  # 18:51  G     11     0    0   0  Merge tag 'hwlock-v4.8' of git://github.com/andersson/remoteproc
git bisect good 6039b80eb50a893476fea7d56e86ed2d19290054  # 19:06  G     11     0    0   0  Merge tag 'dmaengine-4.8-rc1' of git://git.infradead.org/users/vkoul/slave-dma
git bisect good bca6759258dbef378bcf5b872177bcd2259ceb68  # 19:17  G     11     0    0   0  mm, vmstat: remove zone and node double accounting by approximating retries
git bisect good efdc94907977d2db84b4b00cb9bd98ca011f6819  # 19:32  G     11     0    0   0  mm: fix memcg stack accounting for sub-page stacks
git bisect good fb399b4854d2159a4d23fbfbd7daaed914fd54fa  # 19:42  G     10     0    0   0  mm/memblock.c: fix index adjustment error in __next_mem_range_rev()
git bisect  bad 31a6c1909f51dbe9bf08eb40dc64e3db90cf6f79  # 19:50  B      0     2   12   0  mm, page_alloc: set alloc_flags only once in slowpath
git bisect good c146a2b98eb5898eb0fab15a332257a4102ecae9  # 20:04  G     10     0    0   0  mm, kasan: account for object redzone in SLUB's nearest_obj()
git bisect  bad 87cc271d5e4320d705cfdf59f68d4d037b3511b2  # 20:11  B      0     4   14   0  lib/stackdepot.c: use __GFP_NOWARN for stack allocations
git bisect  bad 80a9201a5965f4715d5c09790862e0df84ce0614  # 20:25  B      0     4   14   0  mm, kasan: switch SLUB to stackdepot, enable memory quarantine for SLUB
# first bad commit: [80a9201a5965f4715d5c09790862e0df84ce0614] mm, kasan: switch SLUB to stackdepot, enable memory quarantine for SLUB
git bisect good c146a2b98eb5898eb0fab15a332257a4102ecae9  # 20:34  G     31     0    0   0  mm, kasan: account for object redzone in SLUB's nearest_obj()
# extra tests with CONFIG_DEBUG_INFO_REDUCED
git bisect  bad 80a9201a5965f4715d5c09790862e0df84ce0614  # 20:47  B      0    10   20   0  mm, kasan: switch SLUB to stackdepot, enable memory quarantine for SLUB
# extra tests on HEAD of linux-devel/devel-spot-201703111328
git bisect  bad f5cfbd2efb09391768ad494ec6cab7395c6835fe  # 20:48  B      0    15   30   2  0day head guard for 'devel-spot-201703111328'
# extra tests on tree/branch linus/master
git bisect  bad 434fd6353b4c83938029ca6ea7dfa4fc82d602bd  # 20:59  B      0     2   12   0  Merge tag 'tty-4.11-rc2' of git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/tty
# extra tests on tree/branch linux-next/master
git bisect  bad 5be4921c9958ec02a67506bd6f7a52fce663c201  # 21:15  B      0    11   21   0  Add linux-next specific files for 20170310

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/lkp                          Intel Corporation

--tgxxsl4wajdjvchp
Content-Type: application/gzip
Content-Disposition: attachment; filename="dmesg-quantal-ivb41-2:20170311202540:x86_64-randconfig-in0-03111338:4.7.0-05999-g80a9201:1.gz"
Content-Transfer-Encoding: base64

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
O4g6klwtJoNsK22VyLIrMupC1BIRGpDZiah6X3vz3FFELZG5sZX3I6r1icHLdzGAqCWFeL0z
wB1ELUm/6mmNQEkp+8r6Lh4oKcNccrUkgFZLrLs8UFLbW3SYB3RjLzlfTa5+a7ouHMnVoqs/
39YIuORqUeKzu7yBqCVJRo+o+s/sbqoBRC26Trsq025EtaclMIeo1tTIDe1G1JJ1uW486O+Z
kqbXnGoZXDKh77DRMyUzE+7QCJQsIQ7XbxXQNfqswa/N36/3+esq/imqn2yAzyMupGsVSaqP
8nly9dvN93g7uWoUDWMagZ+OsYgJLz+fb7LcD8wFOITL5OrXlgFu/xXTd7mVWAtYk4JdydUi
JfDe96dvzw79O+106e3r27eXj4sqVoLWaxgmynXxIfVhEnJ5dtcKsYr7c2p9fcVXXum1JoER
oEWt4eKnn1r16Hd6nOio9dOtNVgfJvbksp1YFY3mPCC7qFUUD11lWTe1Wk+kVnPfIWqVCFwW
eq2Zrb7LI3XXh0nk4BOjffVhOlZaiaT79WESi394OlUfZjdlCzLu1odJirGljL1XHya6njgF
xwwniGJ3iU10rQve19vZVdFbY9ROV7kVqV0fJomq0uq9PiznTy9UX7NZeBU7Vk8LXEVh259N
uuBVdIHyB9LB+jCxPvDu5uqpDxNFZy+06TEMk5zBV5b1GYZJBvLv975hmJ5byLmrTc3qzCEP
K2Qll3BuZ2u3wEprBrEWlPky4g9W7Ug6fvzaR0QIgp8TtKeIHZay13qtCSRIM/VZPx0R8snn
7ew9rbRsEDA/MhfxVtb2Th5YgCBuNaUVshaMeyOeFsad1IpZT/2Hq4FQITtL91ErCchD5ADC
p1L6p1Ir53jeay191Z0+r7gaCENpC1kXqJUJqsJzJ7WytbNuUysXnGsCoRPL+632U6ue+Zab
QEiJLafdfmotqbgev/3UWjJ5uWIntRYgz9td1FqQnYJhjloLh1YjivvUWrhhUdxBraX4ErKp
/V1Clew1qLUueHdcDcS6YqdBajV/pivUWum0Ra0Kbk4mPUKturP6Zhvd1CqITujTSa3N/tWj
1KpLi785u6hVivi1odvVIP/WVsNGM8Db5mE2TC/PoHmYjUrJneH6zMNscM6u8m7MPMyCQKMT
9aB5mIVBcQKjcfMwC8Q5DeojbFTJ56lUu5fLdLcEi6gbRLyMKLdSqTfBVCPqDcRnyecasQwB
/Sd7BIuYGMeUvVdR3KLlco7i9v7m+9VZRD0GJhexcSjqg3uLSPUhwy5wtoi81RnYIpbqFLIb
xT8MxuxPnJxXOlBcfzmF2u19N4pb5FjgqbIH+5vKCvESxd8WDMYsJmLc2nHCYvJp/96G4haz
VHxzKG4vKUhMyB50ZA55Vplro2N9PrSA4hYkcYM2OlHcxuucmOzHZqPtidQMittYanYOvofi
NvLk9r2K4hap+G6p91HcBgp6f9l7KK7jIKBDy3EUt0C6VLa1D3XBu4niNjxVA/x+FLcxua19
sJes8bFD8fqCeAe6XhS38dRI1PehuI3m3BAW3UdxG6qToHFEHUBxCyLUAup7KK4jMaBvBzeC
4hj9ROswGLORiWDKYMzGZm55hHUYjNlg8L37OgzGbCSK8wmcuqvM62ZQvmGj9LbLl6x2z5vg
JkGj5OAIet5+VyNSoBQuCZoueXKEoEnPerf6sY0RNOUo7ho6g7GRa0jWw9tF7H2s4OrvLKLZ
a2/lXd1ow0aDMYuY6mFya0dj0e3k07HXqrH6LHrtlzGbtcgDCJqJ7W08laC50EfN6qmjcUyv
Jc53wtCY+m/Cmwm6xNp9eCtBF6XdVs+2+pLvpNlH0M2+tt0EXXADQRdCT8ADBF2YvDdYN0GX
4p22eglab8yWPW4HQUtAl7maI2h5t9sbJmjRU95wzzYblymvq4ctEDA1LXpPC97NAjcbjvVh
+xBBC2U78rQIuj4i/CBoODZuq1KZLnGz8cVXXvYTtEhuPOnpIeioi6PXhw8StLXH8kzYQ9C2
oLfaCt+TYNjI3Ejg90gwbKxCR2PsbQmGjUOg9Uc0FojIBGFjBBt1m8bzjrlC3247J9x68G8R
Szl3d6g3VTsH3JW/jDYX5KyjcOWSsQYS4RMhRv1m+FaN3E/Hb6ZY+PLTxIX8bhUtFhexfcU7
rw9Ux6h9LKl3a0pbM8YxFtxNpzEpaBx0GtOpEV8XneovVxHjfjqNKUF8qvOC/U04OenYtXkv
a8PvLCt0qjsF5835XbMGrOV3G+k0plJbqjXoNCaJjhi66NQ+Rav2po9OY44NdeogncacUkMD
2U2neiGTFzz00mnM4BNonXSqC1zy1fE9dGqeJc4rbIpOY9azaiNNe5dO9Xeyd4u7T6cxy6lV
4vI+DmaY1q5tswXvDp1GiFXXP0KnERQ7W8Zh9aXCuUGnEaz18jydmoGXb/ncS6cKVsld7U46
BQqu4muYTq1maKJPWx0p/uYYyO/a4+GGiOie1CJiCP7EfE9qEVFRxwlqOqUWEVNwjmejUgs7
BTjp07jUwm4K9zhhRmoREcmSBoOYjYR0Bn12L89XrVlE66B4GfGl10SthZFosvuzOr8KWDcw
+957pHA6sd/HbLJl7/LTvE5bwllE5QJ3xV97vZKbESHDRkWzRaRgc2lnRK4tUndjdnn5dBkk
QF8dXv1lfoSiWSNzTM91j7C/mU9esHZtDsyO83V4FhMobU4CWxuu+ox6J2bzydaphdlcgpOx
9WE2i98h+jHb/FIaLdbGMNusNlYwu6RUJuvwbHRuuD90YnaB7DtJdWF20avosvZTmF1IWv4T
9zFbZ6HPvXdgdpHoGvROYbacnrNfwexysw7PhkeWwSRwNCOj2MZs3cuptDBb9Jo4nc0AZgtG
fw7qxmyh7FUyfZgt7AsIhzFbisy0Q86/TaFVIDqA2cmUnRN92mxkQl/j0CejSEHPre5U1Cmj
SHpwRP+WO2QUKVCIO+6qFDjGwT5tdZSkdMlqvEDHKUiMchmxLPBkiiHHeEnHPWLpdh2gRdQz
2R2jttvUnHSfKo6aZelT6jIUXcSVb0LnuHmt7WNcPfhXQcvOiKXgft81vXJf3467U+9tg8cu
a2D79Rjt5L2fnFNKWZ5aC2h/E04di+zqHORM89bAFhMzNh0sfvzDODknPVO0Oxyfg3K/NbDF
ZDGlQ4OcFR3zTG82G6nfaqO+vo+cddNo5JAGyTldyXJ3+q5ZANuxLgJ0+67V8dLoPtDju2aD
lWxcZqvPd81GA/tSzA6TKxuKvnVBh8lVHSnuUfF9kysbSAjrvdks0EmScAWadbW7Cc06XEIe
sQa2MQWsc0UDmq2oIZQL37X6z+K/2X5k1tWRGrnlTmTWhS55COtCZmvJ7BQ1nb5rNjo2xAt9
UxJSbGnaO6YkJG6NvD8lIe95XJJ0kxqXPego8vlGV7Y1wjmA9RnKRcRecmrkY5N5epRL4rzw
XRuwBq4RTwb9XXAJ1p1gZ8paYTUFh/ndKeuGLjeBdQrbioJgJe5r1sAaxSz/t9bHJYyQuxK7
I4havr5aJ5fjj+ht6bpXXLEGrr8u8QHtgy1yLs/WUOih/WRrZVfnXeGL3/B13hrYYmL5wN6P
jWQRUZG45kzvIGq/NbDFZMK2hkJfEpfN6ENUtL1nGlFR51YjLzuGqCilkf0aQFQK6OycRhCV
9JA/Zw1cB7P34OpGVFKQaWzNPTxASbwVVRcPkJ5nGjnp+zxAEB20TfEAQbkin3hf7W5YA9tw
rOV9/dbANkYX+1b3ivpSjuQRlVbc1Wy8Utc8ohKXxq3VhahUwKejuxHV+mnOtA/Woaa3aEys
jimpZ4SW49/9KWkPcdbN0SxQqh7Dg4jK+YK/bP6+3lHm3uQvBjyvLat3RHdfslZEJFse/3Ae
cbrvmkUkjmPmaAexMmOSy8/3fdrI1yIWakTsVUc3I5qqfysZllANaXdYA1u0XE/4O98fVK/V
/cnVb8djslSwbpW9ydVyMqd7ALkWJjMGeCq52jPRi47Bllz9vkKucuolupVclehSR8fgoeSq
pNoypUWukpPr3NtHrnpKbm2vneSqvOyffI6SqyhH+TTSALkKkfPaHSFXYfQyyV5yFbPDnyZX
kdTa6zswIdskbEiP72NCrm5IE5iQ7T69vNAzmJAtcXhd+Kur3c3kag65OjGMJFezNfdpl6Xp
S7Uw6IJc9Z/LfMdgG48t2+tOcs2BqFH22UOuOTA4R4Zucs06OZzVeO+U1NV5Kt9v/T9aJ7j7
UzIGbvmKjU/JmIItoWPkqqNOCfiz+buSXM2mNnePpbuTq43MYY5IhZrJ1Q5vhc84e0TkwHeS
q0M4m03g5T70SgI2RynBaWJXErD6rUTairPWe0aWE7A556094ywi1tKl/QnYfCRgTQRmN25n
AjZnJnmIxYIePetJ/ZkYm8E2gssELPBKAjaD7qlbe7NZTD2X094ErG7d2Q7SDYzVl9ilUbsw
NgN5MunG2AzsHxqPYmwGO5gtYGwG8WK6AYzVXdsncHsxVm95cJXk3RibcbI3mw3N3uG0jxlQ
76IGAN9nBgRxBk5TzIAU8Iq7wmm1u5mA1eFSZCwBm5EZW1bB9lKJR4OLT2+yoMvLj2Astlzg
ujGWgq/578RYitkN7cdYSjlOnqwoJ++q0DUlCaLr+tc1JUlJYL3nigXSLWiwO0UdJcEl/9JC
8s+0ledmsfWO6Oq2e4XoSKoP5XkCNi8kYDOHk+/GDLHy+3p59m5gIQGb2Z4ouYgLSfDMebNZ
QmYMdqTdk4DV6V1tsza+vxLQlsD9CdjvdOyzJdV6js4ErP567QT1AHItugE+m1wVcqT882UC
9vuKutUMe/PmBKyuucCbE7DZmgm2pQNZgnd37yNXiad2NHPkqlPCFVUNk6vksCQdyJZEXkjA
6nhpoHMnuQqWZrarj1xFN6o5datZS7o9uw8TrM9G44/exwTr2rBDOqAbFcZ2a7b31e5mAhZ0
RRhNwOoUSc0mF/Ulsqf0F+QKZj29IB2AoO9zssVFHS3e9K2LXEF3IWf40E2uEKj4Ms2uKQmB
2c2PrilpetypZwK1Z9iOBCxE3eiG66l0B4TgErBvC5lDJXgUlzn8vuA2oDtVLaA8T8BePFof
UrdChFO6vAdVISIRXXygk0tZlxbCp0Ihnnz8LiJeNxzo+EAl0FZ1K+TIdhetJVchp7KzvbFF
hEqP25Orb98/zbiMmPuTq1APy49AVNATQ3pyARYoUsmZRsCSq69vK8lVfXdQNqtbzRWINidX
QfGg2YytvgRz1gXmXpunNQIAmBpP18cQFYCSqx4bQVQATq4MbABRQb/+Roq4D1EBxD+q70ZU
HS2+v2wfD+hxPTasBzp4ACN5ZUcPD2DyWegpHsCM16xrT6vdzeQqIFS75pHkqskAjNtaiIpI
JXhERQresmkAUfUjeousbkTVs/ikNRgoofqmJt2IisK+J0zflKRArXbWHVOSIrR8NO5PSd3d
3OF8akpSrlq6QUQlqzm7SOy9rWhRgRCcuvXt7abh072IhCVdJFffbutJbydXgfi0u/X/HMSq
eInuinVoUW+8m/fqiM8Rv4eudPT5/z4icgx7+yToDpXtiu1JrgIjl61mBMBcnTP2J1fx66fL
esrbdSZXwRZAeQi5lhPxPZVc9dxP+Z8vkqv07dsKuZYMKJvJVb8jaHrbnpPrSHIVim4MsU2u
eth06cE+ci2cnftTP7mW4lW1w+RaJDWaPwyQq+hitSALAImNiudecrW7wpl2dZOrJElzyVWQ
zK3qqg5MEJjMZAl6vpjCBCG089KV5Cre8dsCYcDb5OqTq1JSatdl6Utk7+aSXK1D5OW0GiFX
XTfnWy5gCGVSFoAhsnta0U2uGBJ5I72uKYkhN7P296ckWuu4mVJBtAfUO2QBeiSrDw7GyBUD
J3TJVVhIrup5FIIzq8KbydXbuUi0fiMuudrXl+wcYT8ixlDSpLr1pyNILNFlkWlBf4rx1Jro
IqKD/oEvI0IKWxERI/GhD5hNuqIiHW5NBmOUKNvRtXzljIeiFVMgdq5XV5OumGLmhyhaMSWy
pMIz0dXsFAD++SzpCm/0bSXpiglrm5ed6Ip6aaBDFzCSdEUdHtvoqi+Rez7fha7WVyA0ZHd9
6KrbMLi81Ci6otUirKCrSTudpfoAumLO2XXw6kVXNEH0dGEWmga+oQHs4YRMgacyXDqymem9
zwmZy5aHsJiLhLYu4H21u5l0xawcersjg0u6IpgjZxNd9aXaefkCXVFvcW+234+uCCm33Do6
0RVyum7FdntKWnnwtOsVgvXLnZuSgOJvpK4pCVT8QtIzJfXITjtE1gjWe3AYXfU0V856Btj8
vaemvKVoRWXXcx+tekf0phCbEVPVp/zhPOKCohV1xa0r9gyx6m0V3BWjO5/v9rvBfKkB1ogL
aWpEAtxag4V6uSXuSroixVo7ufH9UUIj6v3kGj+RK0HwSdfr5ErAVub5AHIlCpaUeCq5EjNn
R655iVxNTr+bXNkqmDeTK8dqQdIiV9bzyeXC30eurB9jnlw5i3+0OEquDNLsdNBNroy6xS2Q
K1PxJNdLrjoh3SP0fnK19s2TmKDnbm/J3oUJip8tG637mFBi2iIXQGtO0U66vq92t8nVulPc
VrR6ci25Prxvkeu7E8wluZbTyjlNrqYbnu4khoUauc8+ci2MblL1k2sp0Grf0TMli1QH74kp
Kbo4zsgF0B6Y7HgOgJLSuFwA5V31fDZ/wwq5ih54HIfFFbLTdQLhklyvNHbtI1c9n6RZchWG
gpefL62QuRQScREXarGUeIpsFZJSAIaPXOtf/vg//qRI+G//8Mdf/vXLn5S/Pgj2f0qA//OX
v1lnmz9/WtF0Mv79r8fKpLBUrbo3vr8Ya+/w/XKBeOyzytvVOLhTLkDW8vIhZlgUsXbheCa5
UjR0dXKBtCIXIL2Jd7sIUJRTreQdch2RC5DV4EGTXClZT+cZciVFgMaz+k5y1dGtgpExcjUn
U+dlNUKulECco9QAudp5E2bNsCgRu2L+bnKl1EgZ9WECpdJwcOjBBEp6uRpVXHcxgczEakct
FuWY03UzLF3tbsoFarH6YC0WZWWMdqcBfQkaZlhkLjMuddlPrpSByzS5mtVuvKphuT0lM1Hz
MNVFrpRbziB9UzIX8Kr5rilZCzJnpiQE32h4akpCTOM5VwI9yl0WGn0LC2ZYZJ2XnS9UWBAg
EEDNIJ7LBeLlexyQCxDgyTt34uenIwgRXlZUfbsJ1Hc/qCkpLyOmpS9DAm5VvBJSzfWsyQUI
S9ibdCU9udF2H1c7QuRDQGwNcWN/BwKi+CAfV91z+enoqnd2uTDAgjeilaSr+SXy5iZZRCTY
bC97jq4jSVf9lClfQVcTvk8lXe19ukft/ehqueVVuQBxBNdZcQhdTQB/id8j6KpH9EYxTSe6
MniZbT+6MoYWRfZwAqO0+mt1cAJTCTOyQivNaHWIH+cELjVTfSXpmu/UaBFLLfkeSbrqR85W
kdtC1xKqM/YlupaGAHoEXd/9XibRtZwqMmfQtWSZV7pSgcJzNgJUkFs6lI4pWXQ3mTpNFQZ3
PpiakqVUM99BdC2S4aKiai2FSApL0SclF1KIJJGsouc86XrbUut20lXp6/SUaoZYJXNyny8v
PNwnAYlesrGQpiZRxtoqFyDhJLBLLqBrZ0hbk64cuCYD9idd344aLTbtfn97Vw46VeAR5Got
tq2K4Jnkyrp25/TPF0lXfl1JuurfpLQ56aowJjXmHXIdSbrqeSVKm1z1JXItGbvIlSNDo0VP
J7lyLNmlPEbJVY8/zSDd5MrJPCbmyZWtvfVVSLhDrpxSdIO7yVWZOzgxZR8m6FBpGbDexwRO
Vp46gQm65ZCzcZjBBF0mq7/BlaTr250aLU5c5YUjSVdOJUPbAItrLxVHrrrXRNecY4BcTYhT
pq1b6yPiOaGrPQue70BgmDTpyaYEwv4Y3DUlq/n0zJTMCO6By9SUzIRpuEaLs15slzl8vclh
n2HJFxqZa6i4NK73K+jPHHIWknyZdHUmXQNJVza/sjF3AY+weuIX36S12+mrdekgV3/Ui4gL
NVpsLkF7EVF327A1XcqgU/Ahba/i27FF6mnWnuqeQ2fmD+j8uy4rr79Ln9AApN5Pn7lTX34n
z/rrC+iJofZUfyp6YqquXhfP+yF8umjfXvgmetbf+IyemEu6aQ+g/6CbSPz+KYTyF93CRMTY
87w/4Tt6fi9vBb7dRk8kiG3vVX2pOLvuPvREpobvaC96YkGnET1dqwptdXf8l7++/e1f/lL3
jVQ3WMDvRwDBZX8BJsW3lawrU4SV7lnWBK6R9u1k1/okeppd7YnjnNSVCcNcMTfb06GZFBcT
Vev+dVAgrgah1wQDb3fY1XJtt4u0crlkVxKMbWcsfakeNE/s+nn95eAfY4/Qqx61G8ZxvfSq
Zyrfi6qPXpWb3RfVT69KO5MOA2w6xinJAOtSNjcpdTq7yzQ1KS3SOL1yOcHz+Qx2CNafRWQW
8v2zYi8Pf0LPj4glsD1WOqfXU26Ypp6kc4lSMfEWnJZ0artx/lcXpA9c3s9GZxHzgiJAv7xS
9qJkoWipxTVFAJvtD+x9X6VaumxG3GyN3T5NNJHiGgtcVQSwBKKHeF+xROEnd3ZlyZThHG7Z
KHslrypmI7Q5ryqm89yrCGBhvFKGpS+JczPqg1tdYhbgVr9KX8Q+yKZ6Panx5LSfTYtOH9dP
Z4BNi0696TKsEjLMu7aWALnl+dOBASXoyt94cnsfA0qg4BPZHRigA2WLgYDtlZbJbLHpabW7
qQgooRQeNBAoQQjanV31+wrky7D0n8Fd4AEytWvauDk6ybToBHTXuo9M9daP83lVvXWie0bT
OSXNcH7quFQiFv94p2dKRmL3dGFqSkZlwuEyrBILynkqT+cvLzR4UujjklzEhSfmJYXayO4P
ZxHLgiKg6MKDY2LWn46xOUC4/Hxl6fNBSu6KyYJzrkI1hK3p1JJOipeaT/wvyuz//HubYr/+
zbj0399+/auuR1+UaT9+3+pMt7XQKtYEce/nyUT5IS6vn7SvJZfa9KhTQaC/XkJ4BOkW0GX/
ydrXArogXZAufifd135crnHSLfbgYXN/ggJQDcp2KggKIHGbdAtQcOrNLtLVkeJUs92kW4CL
7106Srp6EF4q2yogxaVxR0gXA193JbpHuubbN122VTBhq8lAD1ZgrnKqCayYbf6qA8XpMaew
wqz/rysI2tpX+vQ+SMpg2Vax5q9tw4FizV8bpGvNXxessoo9omjcWp2ka81f57SvZan5a7F+
No1zUM+UpJMRxMSUpHcDpeEpSSBOqTs1Ja2mpAyTLlFh97w/LTzvL1RC2Zq7LCZVjZc52Bva
16vttD4icgAeIN0Dc3V/Pxe+1rdy88PdtrAtrDeUk3DAQmK2mCpkLxbyZ+HrbGK2sALA1hIy
62Ky3x/Ljhlw+GPp1h6pv1RLf71YeuABuFpybW31VFxVtgH554vErOLKCq7q8r67KYEljupW
tzExWywotXG1SHTE14ereoCl6VItHd3qGDSIq9Y2dglXJfl80AiuShZXgdSNqwLeXKsfVwUb
efE+NhCiueezRRh9n94eNtBjwZa6mCJ6wcvVxCzc8cfSOQv2MH8kMSsamtulWvoSii/V0n8W
WvDHkqCbVKNTXR+uStAvZM5lQBQmXLuKblyVgBznErP2DLA1se5PSQncPLbdnZJiHv47nF11
JauPvcZwVWK4FLzq/F0pPBI9SSa6jAgLaUaTbed4mZi97T57OzErURfMSX8siVBSufx8Hc61
N94NXfYisIgLxW0SOVkB3j4y1O25euXtSbSKqYny1veXlLseoprlQzUrCWpZeGeiVRLWjhD7
yVUSYXpyqZYeGdOHFOgo1bI77fssuSr3INBecpUcThnIjYlWySleSbTqS+gq3bvIVXIG3xS0
l1wlQ/YukIPkKlZtsdKTwGQmsiApED1ZN95AH7lKLv7Jfje5KjNHL/XtwwTdzVqPfjswAU5C
93FMgMhhR1ZLwIRAVxOtfEfuqtsm3TEZcIlWAaia5ha5wmkzvSRXwCgLpVoK57GhVOklV7Ai
2zlyBZam70UfuYIeg+dy/wJSG1ROTElU6J0RuypuYtohKRDlxTjsjyVovd8v83y8IHY1G9bz
Lgc1Ym+itSF2FTTr68tE64WkIPe83yMiCd4p1TpQFflkA3v+590HGrlEpUSXi5aF5KpQqP7m
G1GQEAutJleFiGHz++KqA92fXP3UfEBIat6uM7kq1oQ2PgRR3/2LnoqoVmR74SbADEvNB/Qr
yx+9jj82kkVEZazd1HcmV8XqWNpuAsKcXIqhD1F18Ws8ze9FVN2RnHXsMKKyiG9dOoKoRTfz
heSqlFgamN6JqCWxq7rpR9SSyV/+Ph4ogL5PbRcPmDZ/ClELpT2Iao/w2j5Y76vd7eSqblH2
nHwouVpK9fltIaqZGTUQVed2cN/sAKJKaHy33YgqEb0dfx+iSgL3fLwfUfVemmw+IHr0KFNt
s8RQcyq5qnThvA+mpqR+2TJcj6WjTsYNZ/M3rCRXddoUl1yN08lV+G3dePAyuTrffMAixpMF
Tf/PT8fYdOEcZu+mwznsxrvR7dt9B2n6O7CIej7cmLy0iChxk4pVo1lx98bkr0W0qvAecv2v
b7/+WW/k77/85eOW/PrdbuYSWxaub0G3muOvlPq46sKT4MyS4Ovrn36XfiwMNkSq78y5KQF+
MiXQAbMMq+EpCDy19av9zYThrA1Bjkp+9Pb5yFX4Nd+0JbDfeClHTL3MVwUCHyO+nXkfIGa5
ypsWs+2IdfEuvqfww5bgJb6+fZfvKd6ISdF2Ycew9SWfbOhgWBtpRqZzDGujS2wVXQ0wrAWR
6C14uhm2BmjIFKR8OwW4ftN9BOBQvGG8WdOg27br1vd2XD+O5KtkynfEWPn3L2+/vvzl7//y
+st/s+v49VUjoG385bixFecaG/83+frtnaD/+u1fqsr/eP/2HX77FEERbDGCHgMnUrY2EmML
W+7ARx0orvfDOHxYIJJ8rY1sXUIbPHzc/Gz6ops4DGc0bEMKUEsZW18qCIc/wafLJMk9de/m
YR1fQvRK0T4erqMbFVUdPGxD9T5xKge9tyi1760SLu4tPeO1WhP03Fsloz9bds3KAtk3V+mZ
lQX9WjQ1KwtVq7sRJK6j+LyrgU3hH0b6FyB38z+PiHz6/s4jvgPsZZ7zevTvn76VUgud/3AW
0Zf2f7sZHT6/R91JTUG69HNAssRTS+zz93eW1r390X/85xExxfODikX8rJm9eek+/ecRUTfd
vZAsWM+tOyMSha6eWuNY+3asv8I1gTWCtVKo4OOwVuw4+1ys1a3gOIYdWMuvC1irf5nhqtHr
HNbGkE/+8RuxNpp3dRtr9SWECfWAjbQmQLNYqwtI9A77g1irFBgbnd/7sTbquuigfgRrLW/l
9+6urTfqJciOV0awNsZIjW5GA1Bq35fvDjYWIeeZnJqNhDjRFqkO3GFuYIFQQrvk630JvYW1
evH5c5+vDqyNkest08Bak9ba43OHtTEql06neev44hxHurFWbwZqiHx6sFZhulFrNoC1MUVw
N0jnvZVSapl2dcxKqzQb9zeoA2WDjNYCgYy2mbVRSJh3QmhMCsriIG8MQut/HhG5FtJcYO0A
NlamPYtYrjlvjTJtTAol7uOuEGjM741KziOW+ZNGzKmaFW0g0B/+BvLP+m4+FApv//3t5e86
3X7zu79++/nPv/vTL69/+fWXb2+/ufyHL//w7d+/fH35y8+//9/+8f/SWf2//39+/5uOxHBU
tIkbjbw0IuhBpEt1O0zQ378emxzYUjRE0Dqk1FKjxxB0BIjpqUYH9jetv9slQcfvsELQYG1Q
NhM0lLg7MazIkWun4QZBg/BcYjii7pCNrbmToNG6H68SNKbsAXiEoPUTRAcIIwSNOpMbW3XP
Lo/6rTifgyGCRiyNcpsR/jUDDH8AGIrAzR5LHayCpQlI91nFWtmvt13QQBTSFeva9yX0JkGT
nQLHCJpizd61CJpStGieoCn5Yr0RgtZzrp+h3QStR7TJxHAkvcVdRnqEoIkaDbD77i1zEZib
lYaNU+c60je2buVhgU7uxoMEzSGRS+N+dDXopb/PuKY7Kruk5vfgmfzefx4RE1ia9Jygv7vO
C3AT8c/fYz75ovViMkNyp4IYejurOYmyRcTMxUU803+4t398smZEgrLHLuEdkymsY/I//Z//
3//4j32YXFLejMklAzxIPwHHel6g2LYygsnmZ5Meh8nF+jU+GZNLcb1wTT8hK5hcBCVvxmQJ
pxbwOzFZr3+zF259ye+ifZgsueGf2o3JVvG01lHMgmBIS4lm/f68v9UIJgsVl17q3MqFyWcQ
hzBZite+jEGuaS+XMDnpfeRz/T1AkkxxN6Of0IHizjYzQJJCEvv01xLNcDPRrLcU01iiOQUA
busn9KVaAOgwOZlN8UKiOQXy3c26MTmZwmjGrMGGcqO/2AAmp1C45RHWcW8leyg8hckp6tc6
k2hOMUZX1DA1K2OqHnNjmKyj6lzep59IEUJ2mLySuk4RI6VR/cQFNZ+lrpPGqxd96OenY7gd
BXYKJvSra5xWVtLVybpm7qXmuCO5/B//j//cRc1J17K0sTuwRSTqq5cbpmY8ksspleofNUDN
yfpLPk51nHKoDXOeSc164qHkksvh20pyOeV0MmE924/WqDllCNSonFuh5pQxNfvw1pfIJXm7
qDllgtl+ETaas6/eGqTmlPU4OG9LZgEkerP5AWpOuiB6K+G+nV2PDd5qdYSaE0RutOIdYV7Q
Nd6//aEIGb2PcBefmF30uMWZDcTqrrjOJ0CR2kYR70voTWoGDjGNUTMwN7ui2UulFvZ6aobi
212PUDNInq3C09F2LL3qu3ebmjEGn+AdoWaMzcZoPfcW6p43NysxU+Mc2TErUefzllmJCKY/
H6RmpBS2agES8skT+fym+FGIN5FcTljAfNPOqRnHksv1P4+Icmpm2YvJFFJwUEvn3H5b9Bwu
rhLFUyf384jHZ+q+9EdEXZW3ajAoLWLyf/hf/+n/rZ8s/P6f/vGfwn8I2IfLZJ7cW3GZhK10
8gG4/JqOWcqxPi8ewWXWw5LrHLwPl99NH56Kywy17vBCi/F1CZcZC28u0ku2o4bNuMwlW6FP
C5e5sNOU9uEyC3o1ajcul9DaxQdxudiXvoLLJTX6547gcsnBuV51bulF54Ez8R3C5QItKBiB
3YLeomwwAtFMqzYbydDKId4Hk6Jr044ivVQkynVc1iX0Ji6bI/AgLpvl7BVcllgFcx6XJfrb
bASXxY5007gsOfku0X24LBCbOqduXNb1xYs5+u4twdJyn+iYlWYi1XhqdH9W6lbuWuJNzUop
GAZ7WNgoSeiw7WUhyZx1hySnj35pJJlv/+eRZM66HXO8xOXXyyTzAC7r6n+yf+vE5RxyAneV
Xm9lla/85xHxvcvlWcS3MI/LOeCuFhE/cDmvZ5WNBHsg2RTcsLHBhUVMVbX5AEj+FsvxVzLT
GCTnCCDxYZCcTeb4ZCeLHDmn4CCZ8gIkK3kiXO1BPAfJOQq3DINXIDm/95JsQHJOMePlVtYF
yabDoGlIzkmXTJ+sGoNkDSJ+LxyAZF0yS14RLGfLvMxt5DkR4pJgOdvBbymnXJ+JLGF2tgfA
U8VVWXdh/5C/A0d0YNmCI1nvX75e8qdL6C1Iznr50+2uGZeQnHOu6aIGJOtLJbacLHRILNPm
wzZekWs6p6yjxU3SPkjOOrP804YBSM66bfm+i333Vi7Nliw9s1Karb3vz0oI0V2pqVkJp84q
Y5Cso07ypLMp/PW+vNilUI+IOXiZwleXAb4f/YgIEZyTxbczSO4g5LOImO61NP7p0y8Xpy0O
3xbSv9keK8WtJxMrV9pjK/GDkOGJhKx7F+xJh39EpFQeo1X+iscmpjhKY1rlrIez8riSvmxW
cvnJhEzxoqVGJWT4ukLIpEem3YRMuX5bWwmZ4NTWr0HIhMk1Ou0jZKLg6aqbkImkYUE1SMjE
BRtB+gmZCnul7Qghk1Cr/1XPLs4BYCmNnHXONxSZI3zLKfkLOBZBb6MJ7+M6Ulp60vsswuDd
RKZYhJGTXCVkXUJvErIe8vl2dw5HyMyptNPI+hKZlMQTMpfgKmdHCJmLuGnWT8gsxXdf6SPk
EghWSvr0yICNydl1b5U06UCYS05hRkGv78v3qZmalbqkpeGSPh11Mj8/m8JyNZ15XThxRNTF
0ek4pK3juKnDOCLqbHIlfR0U7+TKR0QJU6YYP32KIMV55C2dAySennKdRfx2S9lx7xwgyrl7
5L4/sBkXsdnkFzHkLm7W+8KEHxu5WQ+jnPEh3Cy5HH8lYxrzSAbd0uFxZnIQFHafrFaGcDqz
XXBz4gVuhiAkm7kZdEgF2Y3cDDrCfJ0a3AwxZ7e7dXEzRMiNJ7Od3AwRW1rnMW6GSI269QFu
hsjFV9sPcDNE/S7nsl+QQnBYMMTNYOVAS3lhSKlhSDIWIaO3FOwhFNAz55RHMiSkLbZdkKi2
WrjCzbqE3uJmSCwyZoUBqRRp1/iZ44S95LgZ7HH8ghUGmNJtmpshp+gTrV3cDDk3ZucAN5tZ
cWuC9NxbOilbLRM7ZmUmbB2E789KPYW5uoWpWWl/bDizDNl6Dl3SWrlXP3eD/8yuCn3EEeu3
C/4D86EIl9x8ne2vZ5mPiCdPrWFcVrqJXoexcigA0GO0U6uspPYBTjaSG3GZNuDyf+jFZT30
8la1MiDhg9TK4dDUWz/HPOa9DCjmN/IwXKYg6clqZSDdkMolLocQVnCZAD/6xn9sRIu4THpx
aDMum918O80M1trjclPrw2WSFKed46x7UFjr3GxBIqYGc/fjMqeGNnEElzmXyTQzMBSX4B/D
ZabQeGg8ArvMqaEYHopQJhN6wNKwNOsBkxL2lFGBTv2UruKy/tzE5ZJKHEszQ8nVrrmFy0Uv
RssSQ19gpzYeweWCpSGl6MVlnaJTLfZsaAm+/fQILpeGQ2DnvSUhtYoIOmalxNx6bHJ/VkrK
Tlc0NSslV7vrQVwWqEv85yn8+v37dE9ii2jWiC5ibyPoZkRGcJYYoRJlw/fiBq8eEYtwO818
kLFCQ3bp8tDq/3wn8/sjIurt5xPwMfRrni+dNFARxh5ubCRj3kLG1EXGqAeNuFWAYe15LEnw
ADImCMdfOT0jHSBjNLfnx9leYMSaQH8mGaMC4Eehw0HGL2WBjDFK3m17gSnIbrM4s5uyB78N
MtaXpEwJMDBBy6mtk4wx6bRc9VRWLM5LAgxMDL43ygAZo34xrYKhjt0bde92VXhDZIym1V3i
WswpeFeDsQi5UQnZwyBoXr8zYlBUdHFuHzMMgpkwXxdg6BJ6i4zRCj/G6vgwl4oGDTK2RcES
8o6M9QWMC7YXCIH8JOklY4TIHjG7yBitBfRKHR/q4j97bwHGho1iz6wEii1d9P1ZqadsV3Mx
NSv1LJOHBRioaOyFBCsmFai8k7ztxQpRopksXZLxTdOJK7nkI2LmMtl/2rpxodMXrxhW4Lue
9jwiLyiWEZnjHu3CD2IuzyRmAi5bi/qQqBpdPYKYj6I+1FmAY5JlHSKPJGZFBbu9n0rM/O4d
ZJfpEzGvFPUhQ5a4mZgZZbdkWe+7ugi3iJlLgMsdoo+YWUKjwXQvMRedp6tGcVisM9AKMZeE
7tMPEXPJ5JG7b1cvwC5rNUbMRa/iUi4Zlbgb7tBDEfSumiPmUshraXvYpIiH9Ck2KSKfs8GX
xHy7qA8loBkhjRCzKOu2+/jpS7XdhydmPT+7g8UIMUuK3o+vm5glsczlklFydtWIQ8QsECbb
U+tQ8j0Eu2aloAffrlkpupTukCzr8j/hfIF6/Ab35H+JmIVrD4SNxCyFTChxi5hvJ5UdMYtA
fY9diCxSfFuVFUTWt37y2TyLuILIpMRCe5PKq536RhDZGqvbfVf/9pf/Sf/4//zl73/Vv/yv
uoPpSvi3L3Wt+vL69pe//ZsipfVYOK2RX/749v1vRxgOaavIWSMWeIwl89fv4fgrpR7CBkib
gmR6XHGgwbE8OTdNMZ4eEttlOkTO+LZA2qR7TtjcMdssHstm+wyyRw1t0taXstPmdZE2WRfB
6UYmZNdhNTdN1iVtxT5DA3hb5BHSpsi+y1cfDSjIBfdUYIi0NQI3UGSAkylKdu9hLEIKzaZs
95mGrMXGTG5av/Po6G+GaTSQxOsiZ11Cb5E2pVRrRwZIm3S5sINdg7T1pWpR7khbX0CnQx8g
bTN4ne+YraOLl150kTalltB4gLQpUcOkru/eMqfxKfsMSu9GxOOzUkF7R26adK0f75itCHsy
lz+bwiuqXcrhePC6RbWrh586Iy6KA8cK8SqKHxF1Ii91zP6M4pQzXipf1sr6KAOB+1ZWHDso
Y+3usw/FebUb4BCKW13Y1rYmBCmUx2Sr09djsYcMtlWMMDRANQt+FEMDVp+fpzI0KC75tib6
oT6u2zhDQwlps76DQE5p3J0MjSFDW/msL/ndpo+hzW5mnqHx1FlzjaEx+0ZpQwyN1ltkhaHt
uercM2hCXQ3dg/shhtYVv5EqHyFgZPDP4McilOzz/V20ghJ9s7geWrGs1w4LOqJQ0nWG1iX0
JkPrAQzGstVE1gipzdCKffZdeoZWlnGVmCMMTbrcTDcDJAL2X28fQ+sEbz4J6mZo/eNO2dJ5
b5GCxhxDE4tMMTQVdgWdc7NSqunPIENzAHS55fiJT0e70JGVlTj+W2kvqF8KBcfQrfaCd9pm
H98zm89hD0MfoMyQyYkw7nUkbP3nEdHkRC7iQktBYsK9nU14tQGgsZlBRR8pl4RhD+h/RMxs
0qBHtM1+OTYzM64c03VQoYAPzDZbMwN+MikXCeIsNQKvKKFJ9IbYXCNIEok3W2qQ6ASQNimL
2ZNOkbJAztNmzSSYvBXDKCkLpUYubICUhX1zjCFSlhLd/ti5m+uO7Aoch0iZ69e8wrkaQdZI
mYM1QJ9hEg6J/Smlg0k4ZHK9I2eYROGCc7zeNvvlZraZdYUcJGUOVG+2BimzPWBuWWqwnWTd
NOknZQ7Fmwh3kzIHaThqd5GyDhXnqT1CyhyDtA5hHfcWR40zpYTmmKjx/KVjVsbsjfOmZqU9
2R/WdbBZFHmuXWhyzVHPOr6n9AJScuTaZ+aibfbNfiJtmccRUQLd72jSRGYdKz4TvNLhmlOM
/myx0oSRU8pha3KWE1Yp8c6IBIaXjzC6OLpYc+JasTUAsWw9sx4nTuYcYn6y0YVuVyW4jiPh
EjiHIJZzPmWszraHNYjVo/6pa+1GiGWz1M5NiNXzcnSV7F0Qy9kwZBZidXRpGE6NQSznwp7B
BiCWs5DzTBiBWIaADY7s2mjN0mhJnKwnwej7BA8hKOTgGkKPRpBWG7MOXADgqd4ODHqJdjyc
ZiAo5brRxe0u1ubqnMbK+dgeD7WNLthqi6QFsVDE6WJGIBZOReiTEIuBfFObPohFpbGVLtaM
qdn8o+feQl3cpx5CsJVPTh2tFCK32K8wnpoYDUKsnqguXdzWbCnYDJqdgCA05M69thSMpUrG
L4wuFrpYM8rpYWUvuFI4dVg6ewcrFhVMEdCJwlfS7Gxao625UibrY7I3IorN0QeA61s5VlhS
dB3zodAhQo8zNFbaqM+XnwquHBhd9jW+xhVw1bsmbTY0Zl21ZLPWlxVxyhVw5dNZfwJcdV1r
oGcvuOr96a10R8GV9cC74kPBXIIvORoBV2uzMFf5wyzs2nmNgWsJ1HiQO4KdJUKjXd1QhJR9
bWUXIpQ2XNxHhJLFnZimEKEoFF4HV11Cb4JrwdFWeVwIYrsRiL7EpVVVx0VXtoWqOrbPM90q
T0cXmMy+FiF/a4yAqwT0KqS+e0tibpm7dcxKSdHrp3pmpaTiFrSpWSnWgmMYXAUouMzfSqdk
Fqz2wxc3xUKnZGUKJtcq7+1HdrKrSd5lxFM+9x6vSjkVeJ794e8dHUiulRyy6LLvLo4/J9zO
dH/+KBqjGmJvoMsf2oS0QcSbO+2LdStC2WrSVsx54TFZ3a9cjr8iedCkTZffYGeVB8GxLjfV
re+ZcKzIlwAcHMP3BThWtKCPPpIf284aHJeIpWzO6ha9Opa+asCxvkRO49cFxyWWhgC0F46L
lWCtinhLCrmhI+6H45Ki73UyAsclpaZPascGrlQZXcJsCI5LgpYuYgBti1nlLdm8lUSh5blx
H0N0pLSaoN3FkJLsTLMBQ4riDFyHY11Cb8Fx0S+exrK6JYeaum3Asb4kuZXV1SNEdkKMATgu
OtpdrW44LtayY85youid5eWwA3CsAWRS9lMy8pxgpmTClvz3/qzMnLZ0N1eOq9v1GBzrgTHu
7ZJXIGTfR3qltK7ocmVe78Nd8pxz2xExcbgKx/0/Px0Bc/Fp35WmeQUw+KYpK9V1uu1WV5SN
GJ03YLSJOrowGhOXrTnmokQlj2max592W0TAsVq4gpQsMfEojEZ7lvNkjDYLI98F5PtKFxDT
QYe0GaPJGrltxmjKwWK2MJpss5rCaILsEawbo60YriHOHcNoKy7y+bMBjCb20pAhjKYS05xz
mw4VR+BjGE3SepA7AsEcpFGPNhQhFprKMRfFjqlauMKKGTtyzIUBy/UuILqE3sRoexwuYxjN
FM1zoIXR9rwRWhjNJM7icASj2dKm0xjNpfhu7H0YzcKewEcwupjqee7eMlXzlGSn6Nm05fl2
f1bqecU9rpqalcaG4xitl8UrfFdsyYrubtER5YotWdHlxvtJcPFdQHpTvUWjyJ0uIPo76Ht2
rLQTLOV9Zp9HXGgnaNVHm10iYAMZY4h9ZCxcH5BtJGMrfymPaSd9bF7KYdVHfoCMJcSqkH4Q
GVvRDz1ZNiwBsneJiPmSe0fIWAISba59k0DCm9UXEkq60gXE2tiHqdo3vZnRFet3k7HEAI28
1xgZS4zQcFztJ2OJ6SS2myVj5UqY7I8nERZlwxIxNSS7A1wrkVqdOIYicPIP93sYRKKRzwSD
6EBxTf1mGESiuZxebyf97SYZ63uQMNZOWhGVsF37JkkvY6s/nunUaEE2LClDw9Kwk4xFObHx
FKmHjCVhWuoCIolSy8Sv595KHBr9cXpmZXp38h2eldbzZMustDrlYTKWrLutE/mu0JrkWPs/
7ktZSz4ZDV60k75SG3aLlY+IcKqg7vn56RiFwUsnVjzkJLf6f6zkpSVzzVhtZGV8IisLQNzb
S1oAITymY15Jx3YGVKVPI6wMTOmBrAx6yz3ZJ0Ls/vBijLBSYieYwodF+scutMjK1oNss0+E
IBC2xRhijZGmssg6Unznh25WRvLCvmFWRhZfDj7Cylga72KElVEatsZ9+zkFdvmqMVamyD7F
N0S6ZsK65GsslNmjWBeVEJA7pXVRCaGv3ZqiEiKk6x3zdAm9ycp0MqQeYWVSDmsrlfUlbroS
C9mBboGVzQtkWqksrCukP9J2sTJH8ZUMI6zMadYnQjg3BNZds5KBnfala1Yy+rKBqVlplUXD
vaSlFo7szPkKF/YdRWrOd7KjiJ4BhFwvaZfPvWen9vk96ndT7vtE/PTp9yW6XPvSiaLkGBwl
L50oCuTNdmq0gZK5U2shEmiv1kLkZB7/AEqOdCzneu6ytXmEkgXqM4xHUbIia3yy77AOjZU+
7TIdWov0ukLJcurmspWS9U7mzX2l9WtAuZJRtqTaREYZf6t/Alo2TT2UbKNj4IbaeICSaxBu
WbJ1UrIFSO1OXn2UbAFy8BehYyevQ8kXavVTskWA5JzwBhi3RmiVIw5FQPRJ/fs8YiOt8ckw
j9SB/nAwziMWyJDoKiXrEnqdkm30qT9gNyXXIcgtyXJ9qVYmXVCyvSDRiZK6KbmOZ29q1kfJ
OjqGVh/K+5RsQ/VtzvsO1wDkH1n13VsxJd83pGtW6uLa4uv7szJm2KAAskAQRyXLdRQVR8lh
2jbCIuKpLdF5xOkueRaRkjg3tREbiB8AfUTka1qLzp+fPoWqJuS7HCUsYjk1JzqLOG/cbBEF
TIGwi0A1YooAG+3aLGIyocdDzNXwmJxJTxIjKok6hB/GtBZe95LyTKa1v4mFnEdFCF+nmdZi
EuetHhUWk2lv5tdiFrQHuo5p60unbvPjTKs8NVuGV0eLa980zLRmDTbvUWEBYnYP3IeYNkdp
bZ49++6PXkrzTJv1ry8U0dUIDXnoWASAls9vBz3Ys8rxgqc60B8GpuhBDxV4nWl1Cb3JtDr7
aaQfnQ1RiG6Zq9WXGL1Hhb1QgjNHG2Fa/S58MVs302bJjU4cXUybRbyBzAjTgp6XZhRINlR5
eEK7U0dy61HO/VkJyZdTTM1K0Cs+zrSQ8ZJAX79/dyrZ+/87IgIkdhGn7dosIiby5mr3udvl
go+IFGoFxTzKApFXlyyROzBGF3HewM0iWi3u1lwwb8gF/8euXLC+fcxxUyr7iCj4GHUxxGNy
6ZmujOSCbQhCeSA3I4E9LH0qN6NOZ29KXNIKN2PJZatiwmKK/tdmbibLvLa5mXRjncsFU2hU
l3dzM0V0oslhbqaUGs5TA9xMdmxY4WYlrzhjSmxDwWtVxriZGj6oY9RL2DARGYtAIc1xMynP
TWXdanesHYRC5s92lZt1Cb3JzVSqvdMIN1MRbqmL7SW97X0PuvpCtfqZ5ubawWSam61HxUwf
ZxuafPO8IW7mJC3xQs+9xblR89c1KxnQ99rpmZWMybXkmJqVTGnU262OEm9fNt8HwyKWk2H5
ecTp1moW0SoqLrn5Uy+L7uq7j4glpLr83udje3DjaHa+64VFNP+my4jYOAX0KUosYpK8l4/L
Bj7+T7HH3s3efgk7q+8sokR5TF658HHZRTk8j/GxxGRL06P4WPcC21qeyseSjwXkk6L4bYWP
RU+Qu/PKQjlttXezmAxNrUR9qThO7eNjKeTbE3fzsQgsdp7D3+phPTb6hvTzcTS15XyPZgsQ
m49WO/ZwnbbkyHKIj6OlZpfyyjFAbuR2hyJgmnEAsJF6NJvJ4EXj2h1PpfXMWKU21xTFfJOP
owkfxvg46sKHLUVxfYlSK68crYHbtKJYx+v7bDhLdPJxjJEaZQM9fGw3YtNXvJePdTLkKXs3
GwpxclZGDT9zatOFnd3tPDUr9Ypb8miMj2NkSI7/5hXFFrGcjv7nEacVxRZRUFxeedAhojL0
R8Rkh+UVrcRnho4pnirRz9/ftN7YIp6szHbpjS2izuKNLT0sIlHZ4xb3EdGOVo9pqJyO2ZSk
3uMDWKtDCjwu7RtzrMUbz8TamBMlZyoRaL5QzmLqsrU57RszCG1O+8ZM1Zy2gbXRXDovs0pd
WBszt5pydGKt7hTRu4OOYq1eydSotuvHWj3qeNvjEayFwDAnATaln0vajmEtJFhp6WERcvKi
lbEIChBTCTYd2ayDug8QgORkqVMAAVTrR681VL5VKGejGcqIqYQNKdGeF7ewFgpa2aTHWiiF
F9K+imncOn12Yq1Zrs7YrdnQmL1tzAjWYkpTRag2NIdWG7uOWYm5uEY7XbMSgVy+eGpWIiIP
p33NXk5cEnJFb6qYDuCsF+ZbNFvEUkUsFw2V7xTK3UpNm8M/3JdLHOCKAsWB60oqO9rZ3KeT
p9syW0SdAVvVBZEy7HR4sIiQ6TE+wfjpGETIcUyvEIlqudujwJWYTJ7zVHAliex1vl/nfYI1
ph7fPh6CfGwJi+DK7xaXO8GVUzUTaIGrvuBMEvrAlXPLo6EXXBnYdcIdBlfWSzXvE2wBCDy4
jYAr81yjVxuqF3pJ5xv11OSVlEPYyVJ8um0oQlFyn1JU6lVEb/LcgwglgbOGmEKEkus2dgVc
dQm9Ca5mzT/i8GBDlMW4Da4FyZLMHlwLRXejjIBr4ejTot3gWkryj+/7wNUeNrrM5gi42ql0
rnbN6vjL3KyUFOeOU5K9ud/UrNTjnNXYDIKrgIjL/C0BlFD0tWsrT/ijHaHkElzrE/4pn2CL
+O4BfAtWRUJxnwMXlLx6HKg1eBeezLc6aNzJ2yYrFNxoi2ARdY3cWpSWql73MUYLEo6/QmWo
N5wN4fpg+EGwaqaX5alGC/o3FQSiEw+EvCKuTfa4Ie+F1RTzqV3oRljV9bdIq6mFvYS+lqIL
VpNe+dYu2AeryaB8NcuaonXbWoDVpFuMdwcdgNWUQrNvcMeGmlLMa7CaTFq8lGVNKTf6+41F
gEb77B4ssBRay/X4LhakRMlduBkssIrgdD3LqkvoLVhNVpEPQ7CaklSn0QasWovB4K179YUc
lowWUo4NK5BeWNXR4ns8dMGqlUL7tokDsGqew14W3HdvZaSW62/HrMxUWkWW92dltk+3Y1Zm
QcvkjMGqnt8AHKyuFFclsI6ilxFXiqt0tRJxsPrJy2BYXKuLz2kNvfbz0/GbGHyp2EoWWvfX
3PBRWMhC69pAuFUYkFDPe3u6MX9EtMcJj9G7vhy7im4NQw66NkRPZvI4ZNV7Ep+NrMj5Q95+
6F1jWUFWLKei27PNYBFZrfvNZh+FRBGb3SbspeQtMvuQlZL4MuduZKUsrRZqY8iqd/iS3jUR
BS9XHUFWatva92yrVIKTRowhK0nANWRls6taixA9UfXBAafQKpO/DwecxEm0p+CAoaYur+ld
X24jK2OQMWGADpFwBVmZ6ubrkZWJZMFHITE3LI67kZWt3dwcsrKwf/gxgqzFCojm7i3r0j4l
V0lFp9dMfjUV3V525Ff1JFRd4gaRtSAF5w27ok7VLaegg+D5/mUW0eaO07veeix/BWKPiNbW
YEjvekCshMwbu2lYxFiR8yLidANoi5hkM3IK1mTkzohUa0YeALEv34/VVk7VBSMQK5LlcXnX
bHaOTy7a0lfZq1ujfF+AWOsAEzdDbA54kixuhNgciJttIOwlXbOnirZyaPXR7YXYrMuF25tH
ITbrbu6UfyMQm/W3feJ2AGKzFTfObbQ55ujK1oYgVsfHxi4/gKDZFIQLTdcsAqUWit7HhWxp
nRlcyCZM2JHhyvZE+DrE6hJ6C2Kzri6fWxF3QKwOEWmrW3OK0FS36gvFPbUegNicdO2Yhths
BtBzBrc5gX/jIxCbdWK1vJN77i09Ic60gbCRzK53c9es1EXZ2aZNzUrdr03NNgax2RZylwX8
Nt1M2CKm0yH7/KZYyFRmDcnO4Palkam8Z3N7RASs2Lj489MREIuv23odrCsLZx+agziyfb1J
7u3/PCLqeWnr8/8MMeStZJshVWn7I2xu07EEKx4avAyQrXlXwuPsCDJQfVb0VLKFktjXbQVc
IVsQ/rB7/tgzFskW48niYCfZYkJqKwqybnHO2KaPbPVzNB429pItgviao1GytZTEis1t1iOf
zz6NkK0uhK0HkD27L0pwwuMxsiVrf7DEpRSDlzCPRUjRnYz6GIJymGglVQeKq0SaYgjC2oD3
ms1tuk22RIHGWjdYAo/adl26V+WmHYG+wO75yQjZUmHvhdxNtiTcaLfdRbYKer5gbIRsOfKk
zW1mpeK58xZn8GfdnlnJkFzB19SsZCs6GyZbptM5+dMUXrO5zTbviou4YHOre37thX3f5vZ2
6daRQtbLW8Itu64Gu5aA3rdhRXqRSzwqwrdIL7KiStzaoiEXTHGrWEFvpgyPYdd0ZGX1XF1s
ERlh13Ly9X4Uu+qunZ8sLcgSJTtpQcClrKzkvLc5r8WE0161k11FF7Yr7CqEM815bSRjo+C/
l12loG/NOsqu1k7N76z97AoKf77CeIBd9VRIHn679lfQaeugYohdIeSW5m+APCEANXJQQxEa
DkJdlACBqGXXcJcSIFgf1A2UoFszfW6v+ze3hN5iVwhCg23HIIbayanBrvqSYCsra8993CPr
AXYFvR8a5h6d7ApRN6i5rCzEU13yNLtCxBM8TdxbkbI3su6alVbLOmM1C1ZRuONEBVEgDJdu
QQpHaqalNB0u3YKk13+rflThviRnpTWuHz2ysma6Uqfn4s9PR0A8Tdqzt7ji2AuJyJsSrNgc
QGLZ23wM9LAUtrppgT1zy48g2/JGx+aj+BXHTGIh25L2MLKFjGglAM8kW9DztlyS7Wt8eVkg
W7BDw2a9QU2hl71kC7pJWD1ag2zBlsTL7aOLbMG6uTY6dfaRLYBehVXRrJUYeb+dEbIFLL4I
ZoRsgbiRGO3afYHRPTYfI1so4HulDnEpSPZtjYci6Pmk0cihhyFQv6kZ3yLAFB0STzEE5lpm
2yZbW0Jvki1CbXswQraIteaqRbaIYCdMT7a6VIbLw8cI2SKJq4rrJ1vk4h4ddJIttkykR8hW
j9wtp9eee4tCduf1vllJMXmzlJ5ZSaY/2TEr7WnFcFbWnnPSZROF4h6UdzDUERFKI2LpL713
SEa661+6aZW3q8YJ11O1R0QOPNN87BJoqQTXEKG8/fisAx2Jj4gS3bmgfB9ucHxUgQEHwK0C
WmvBk/cCLWMuD+kKVjgfew6TWCXkCNAy14aVjwJaLkWe7LIFOmWjA9rwdomrQ0Cri33ZLDMw
NQRuTtVCsUR1G2iLcukc0BYMDUP0XqAtuk83sqxjQFuo+Nr3EaAtugsspWp1p4M5mQEU8Sg4
BrRKOmv2sCBm57EYodlOuAMdJDWqhHrQQTK4BP0UOoieR+JVoNUl9CbQCqYyCLSCQldStUIZ
mqlaOZmSTwOtcAMLu4FWdOnwid4uoBWdGitVYGjL25w9rA4tNHXMwivPXu7OStQFd0s3XT0h
Qhjupou6u6VL5WcZcX66xE89e6XsI15N/l7/zyMi5XiZqi0/OjOMKA2OiHzqaTmEr6hrXnCo
3qqY64VNqwflS5OH4irmBo4TqFQDW/Ox+F7rsTOiSaIfgq94qGQx6uFgrP4Lzb8xPgxfMRLZ
kfOZ+Ip6qXJx+Pp1RSWLUZJsNonFZB2u9+IrpkipbWKAKQXX+KkLX83v0u8uvfiqS6NXOIzi
KyZo+IwO4CuaW8dKPtY6VjUSml1bbOLgwG8IXzWCNKpcBuDTAKzRk3cogpDr5dkHCjm0PL86
QCHH5Mryp0Ahp2rHeQVf8bZK1vzq0lj9lw6pfRka+IrZlAsNfNUXwMlJBvAVMzYenffiK2aK
jScePfiqQxsPS0bwNXNpnW967i2dgK2hPbNSwCege2Yl6KzZUf9l5b80nI/VUaVclhkV6C3J
b8Em6K19aYtQrpjEduUoUXdzy8yc4+vJJPamd8F1bASsz41H2BWwREfl9zxjW9KHIyIVcanX
pZMDcG3Ut5E09TBp1RwbIypgW0rsAez6ehhwKTGkMqaSVb4K6YHsipBtWXsquyIKXHrGvsZv
KwZciJzCZpUsoq4PmxscmHIjt1OvViPlKuj72JWs5ew0u1IsTvw3zK66QTWyvwPsSrl4pe8I
u5IpAub2V9KveklLgETYaC4wQp7EsGbAhVQgTrlzIom3fu2iBA7B9QSdogQ+1bddYdfX2wZc
OromnUfYlRPZntRiV841Ce7ZlTM4BBxhV+uv1JD8dLIrK/nONZxFbnlKj7Arc0xzXe90qPiy
tq5ZyToBp9hVcSPs0G4rRlX3hEF2LRHJJf9ehtOJR/UUlsROMLqkTsCSq6zlnF1vqhOuQOwR
UQlqzLvgp09j6xPpC/1Ar7KhRfuF415FApZSk2MbkVMCxa1dulDMS+YhECuHIBYlJxgTxOoQ
kfw4iBU72D8ZYs3s7LJL12tMLysQKyV/PIj42B4WIVaE42aIVVCtbS0bEKsvkWuq3gWxFMyD
dRZiyfqbNRwGhiCWAhRfqTQAsWS9VVotMHshlgLPPuOkUILj3yGIpfDeeG4aQfXeyW7nHYwQ
wek1u3CBlIVaueu7uKCLcHamZzO4QBEwXC31siX0FsRaF0gYS8BSJLjiIqsvVdslB7FKgtnl
Egcglsy/axpiKUojS94FsWZP7W/OAYgla8oy1wGPrB/HlCCWkk6uGf0AJfBNyaZmpT0UGjbg
okRV3L3vCTYpwyb/TPwmct6uvtdw4gy4iiwIYk07XA9Kcz8/HXHiaa6ev7M2ft68hkfEVJwb
Qvk6LIg9DhWmL6Kt8lWyJh+bI5baaOERQFuOlVfhNIwpCui9DfyDgJYg5fBk3y0COI5MB9Dm
uAC0BAiyWRBLuoFULddOoIUCdgBtAa3pMueA1vocTld4kaJEo6nCINBiij4lOAK0mNOSooCU
aXyJWN+mq+TqHkGOAa1lpZe8CwjfBWULEU5TawIdUKDlenAfHfQw5Krxp9BBiVauV3jpEnoT
aMn6zYwBLeVs+2YLaMkegreAliC7M9cI0Ooc9w21uoFW/7xv+9EHtMSNoSNASwVnD4tWAjLl
XUAc0HcY7JmVHL2Vy9Ss5FTNawaBlpVO3IPyJfzk954z5zfFQtaSWKHMA+0PjcLNNl5XsJHf
Cxru8Cpbg+mtdMlC4i731zFdwvn5ocRa2LeRLos5gu2NqFvWQzoglK9fj2tbqAy28aJiRV+P
49WipPNkFQFJjPHSJ/Y1IqzwqiSCzQpYMgXWbl4VJLySgBUKTgvQx6vCsZXZ6eRVKY1G5qO8
KpL9Q/ABXrXn0f4h6QCvss2/ORUBB508rtR8hFfZut76Pz5AmxxOLYNWIlCYUxFY/7PWQ+K7
ZMCheHfgGTLgcNIxXOFVXUJv8SrHUMtRBnhVb5jIbV7Vl4haPrEcU3RYP8Crui4mLzXp5VWO
kBpC9R5eVX7LPjU/wKsc9f6Ya5HHkWHOa4ujxm/M5/uzMgq4erWpWWlt38sor3KK5EuIVlKI
nHJg2Al5nKAenc551UHePfnr2XvEKsu58/PT8fuEyemEv92ydL0jVtXDxalT8XnEhTI3TlJF
n/swk3MKeatJLNfWEw8B15dP+1u2ErEhcNVTW/UFeRC4cmayNe2Z4MpZ6S07cJWwAK4M8UR9
Z1vCGrgyJAqbGxwwQLziPKAvoSst7gJXBqSGf2QnuOrGQi3mHAJXxbbissRD4ApFfF+jEXDF
EFqNLns2V4zVXn8BXK3vlt/ZR7ATc/blNWMRALyAuAsRTAQ/0+CA9T52opMpRECuS8IVcNUl
9Ca4YqEoY+BqCnxsg6vehdQq3dKVEtzRaARcKaJrKdUPrtTqFNAHrmQtLFbAlaBRG9p3bxEW
/6G7ZqUuS76ldc+sVG50N+PUrCQJMmwSy3oGzy4tugRQuqOWy9Zd5aXtE9Al5mROtVvGObie
Wnfdh9UmCutuGdqJ1p8+/U6J7nOsyHhZ7wrv8rBiMsbM9TbbiJZF+WZzRGWsx9RqyeuxquqG
bnm7EVgtkB/YjYsLyrNlrlzs/3lVwLcVWC2SP54NfGwDi7CqS1X1j9oJq5KqN3gLViXJnM8A
22ef7jOrq1ZZh1Uxle4KrIqV66zAqpSGrKBvQzUboaVarWJzeMkloFhnkSVYLebmMmVIpKsp
8AyslgB5i6CwBITr3bhsCb0FqyVQdUgbgFUFqHofNmDVWufafehgtYTi0XwAVktoiS96YVX/
VPYnii5Y1d+LXo4wAKslpjhpQadLWMSGhLpjVkaIU27ERf/glo4G5b0bwxisKklU07Z9qoAS
C2Uv/VxQBehSWZfrtirgXheDFv6WFE8NCCZ+fjqCJHTdtJbSycW6M3uN64JmoOhbpK1FW3ok
k71dDEo6uS49gmbjcW2z8t6YxlWHFH5c0VbJupE9mWaL9UIVR7MpLdBsscaNm2m2ZP1/m2m2
ZKn9xxs0W6zJ01R/Lqs49/13emm2QAL/xHiQZvXMhUuagQInQ7lpmi2AzHOp1wLEa6nXAnqc
WtIM6Pv0/W3HImCIrSKXDm7AGKaezhZMYUvqtWCulmfXaDbeTL0WPNklj9Csfrfcds3Sl6r8
yNOsOXys0CzaY/BpmkXdR+d6yxaU5P3URmiWQm40j+u6tyg2vGq7ZqUVX82UEtZWm1toloDG
uxgUQvQeVytFW8WEwr4MbIWPqVQbi6tFW90J2COiEN3qLXsgK4csWzUVhSP7Qq8lCOYc9/oM
KFPLXv1B0e3ODm0PQNb49ulKKDGOmWVZGNtOH4Wselx8tlqgKF9+HIoOo9f8soKsuu3uLssq
hbg+itiJrEVPqtxG1qK33hyyKi7Ny1x1pWJeRlYzyV8xyyqSvch3CFkFYsvntGdb1Q3B5W7H
kNW87deAU+xR2lqEQnPPZYvezDADB3r3kMv8z8CB4nrtaXUFWXUJvYWsOrQ2HRhAVlEGs4/c
QFYJUOvbHbLqC+zkkwPIKroKO1vcbmTVu7T1iKMHWaXlozGCrBIktTxXO+4tsT1hClnFVtcZ
nwGJyTd8mZqVMaOtjGPIKhGOCuGPKRwWcn4SseFfGhf8SyVyFT6fI+v1trf3fQYkKtxs8BmQ
99Tw+WdNC8oInbqZfcQF8zJJJ/Oyffgp6dT/dGdEXS4e4zNA346VV2lI4hDQWmqYH9d4S3KM
/OTOBWJdI8EB7SsvAK1koLgZaCXT6cnURqCVbDK2JtBKtoeGM0Ar1gq20Xy9D2gFQmw8qhwD
WqXJ1Cr+6gZagZR9gAGgFcjNB+o9my6AL0weAloB5MZz0wEcNVekRq5qKEJJLSztQAdroDWF
Dhh8Pc8UOmBkuS5/1SX0JtBiEh4EWr31DS5bQIsATeMsfUGcw/EI0KK1OJ0GWmSfWewEWiy+
U/IQ0Jov4STQ2qYwNyspxdZDlfuzknJ2ydupWUmAMuwzIIRETpK5YsgvxAldjdOKIb9QqdXg
50B7vZXX9ZTsR0TlJ76Vg71KsFZz7Pj/Sg+wPoLVq4WOYFe6eQnn+uR0I28qEe91HtClqXZS
fwDBhk+cpcv0oPOAmNTtcSlZqzrPT3bKEns876xfQ5QVgi3WqmUzwRbzHthMsMUel7cJ1jKr
UwVcZr/mnwJ3E6zEuJySFascX7F+Fcno81UjBKsM2Oqc2rPLKlv4XNsQweqW0OgwNMKf+t03
+HMoQhGvJeliBXv74ylZ+q3Obd+2YZwVLFBExqsEq0vodYK10QmGrF9tSK4P1h3B1pdqL/sL
grUXwFt0dBOsjcc8a/1qowmcK1kPwdpQbhzuugnWAhTyLU467i0b+u6fPTgrdWQMPNERzgbq
W18/V1mgHEZ7b9VREi+RjL87gr3/vyMintpHnN8UjU5Z957BHxGpLtfnBHsvbdzi2CMic+5t
HXvJsTa8sG9YNp911ojJ5oGLOF1HZxFj7cW5izotIqSdfbgsIhI/poVBwmPBTZxNMtLNsTak
pPQox1cLr2eCp0oL9G/mmNFnYmG+tstiptocYh/HWsxc61D3cazFhNDsw1Vf8uqvDo61kdh4
qt7HsXV000NggGMtCJF/tt7NsRaA0fs/dXOsBSh5qljahkp0jz8HOFYjgE7ihcqsGkEawoCh
CLEhEekiBkitLmIdxAA5u4K8KWJQDuXrtV26hN7kWOt/MKKGrUO4aURgL1lLhBbHAuG846uN
19V/Ug1ro0vyPT76OBZ0mXM35wjHgpTZewsDteoGO2YlRphwfLWBKeXLG2FqVlpr43GOxfdK
27MpvIRkaEL3rUiGJ7fGc47te4Dfqu2yiByrb/jEz0GzZlrhaHZeBWAR9Uzh0uL5jjS5dTr4
iEihToqN7Ekp7czKWsScbTt6AM3y63FtCcgOmiM0S5hN5PQomiUiW+ieSrNkla+OZr9/XaFZ
klR20yybMm4zzbJVnbZplpOXlPXRLGdvVNlPswyNTlajNKss6ns6jdAsky8vHqJZJpkS89lQ
ZlcVNUazXE71HPMsyoLeY34oQtEba0IoayMjTwhlbWDiDb3nLRDEdN0PVpfQmzRbMA11lbUh
FKVV21Vf4uCFsvYCJyfAGaHZUsCn7rtptkjDzr+PZiWc6m6maVZ01WpMkJ57S3K1hZyYlQIB
xl2KbSCGtN5VwwJRspVxkGaFT74QZ1P4+jP7DvYUXV38g/LpR+8W0R5iXdJsx6N3l5j9ETFa
CnuGZn86IiTwDrHzNXEWMZew0TPCImLEjYJWi1hqD+udEaX2/XsAysLrx5ob7WfEIdaG6HHp
UQIDC5/Jwj8TZY0hg0/MykpiNkYqkPairD2nKlsFBhZTCNqJWf2ioyug6UJZPRgEL6/sRdmo
x8LGDjuGsrqnJp6XyFoAyF5kOoCy+nkbbgtd221MjWe3QyirHHaq85gGUf0K0LVXGIwgOGMi
ryOzrtAzKBt/NIJchYaYE91oxQW3TLdsdOYhh1gbAkhtgUHMWBHKoaw9TpLLyzSAsuYl4izK
ulHWClcaad0elLVJ4G/OAZSNWdjr1/vuLdC9esI8w0bGpi73/qzUA4M7mU3NSt3zyqDplo3C
EJwPap52LbWIZvF7GRE+mQp09QA4i8hs5RjnKAs/WnHdVi00E7MRJJRhgcElzWI49UQ8e1t4
X0lxRdxqEXXGOM+Ieb2yRdTjzV6aRd1o0t6Ip9P4A2j27RPN4ulR6AjN6gKYH9WoS8NTYEtx
P5VmKWF0DgbxdYlmyYqeNtMsYX32uZVmieq23aJZ4uh8q/po1jLdjW2yk2ZJQsPNZ5BmWS/A
isxAZ02AedMtC6DHvhnTrTq0OCgbo1nOsuI/YBEwNBSJQxEozshlbSSfnsUNcwMXb0M1xQ0s
VTd2hWbf7tCsOYqPJWZ14kS7t1s0WyK1abak4G7QEZo1o6NpmUHU03rD/6CLZgs2SgFHaNZ8
rOYSs2YZ2QLhjllZiu+31TUri/ief1OzUkIt4xykWdHb0CHZvAe/RcwhOJp9m7aQtYhQ3ZDP
afatbXzVR7P2XGmZZoUKOquG78PuWZ9oVkqKLtvrtMt3WPn8g566Ne1jzxRSDltzs8lUf+kx
xV/fw/FXzOxwiGZToCSPspC18FzlUM+k2RTkyP5/Kv56W6DZpOvcRyfpj31ijWYtZRm2+nFZ
TEil5cdVX2L3oLmLZlNE9nm9Xpq1LomuKnuUZpOVn6/IDJIZMq2IZpOltmf8uGyoPTNZodlk
zbuWJK8p5SQ+tTwUAXJr97/PDUmJys+ADm5ISSlnvSG9BWLEG8Vf32/KDJKSsIy0nbUhUlvT
NGhWX6pT2dGs7jn+Mg3QbMoR/IGll2Z1fqB7eN5Hs0rB6B/YD9BsykCN2saueysjtTrDdcxK
25Fnzlgp8w6XOAtUxDR4YzSbsviH20vFX2al69vOhoXirwQ67eJo8VcLa4+Ipwr/pZ+fjmgY
xeW3V4THugcj+eqyBfFHAmthtBVCMdQHtzsjKtg+xtPgJR87D2YyYc0I1iKgpdAehbVIVQTx
VKzFEj5KNI8k7SUujmEtCsbNkoNEobpXbsVa0vs/tLFWzy+uYqMPa3UVb4BpL9bqreT1baNY
S9RoCTuCtcSNrj4jWEsltaylerZekuQSxGNYyyG78pMxKOW1Pl8WITW7z3cABCu2TAEE66qw
4+GuUi2Fcr0pbb6NtfYwnsawlhlTuxYs8Wl58ljLBVY8DZI1w5u0mdXRJVDDyLkLa0sk/wRl
BGtNJT15ZCzZGwz0zcoC7E/KPbPSWlDsEMKYhyYO2szaKC7km9KeIVnfA/QjojRcuebb3GpE
CeT7fF1pc3uzS8IR0bKXnVh74Ku17HDp55eF4i89ripvuhT5ggbXlFxhq/FAEt2qthZ/6Umc
0mPw9e3YYXJQ3hkxlbUhKT6w+MsSDenJ+JqDMnNy+Pq6gq856EoT9uJrtqIY2ouvuZY0NPE1
W7J6KiubY2jkL3rxNccIZbX4K1fF6wK+5phzbjm59+JrjpB8hUvXFqvTz3doGMJXvajB15mP
wKdGkMY2PxSBSwOhO0Ah69GxZYJwFxSs+82Wp7k5BSzXG3vpEnoLX63gHMcUszmZTryJr/pS
pUyHr/qCOAocwNecsjRsYTvxNeuu3HDO68HXnJDSfJcEC6Cn07mjYU6n9kMTs1K3Sq/z7ZmV
qfgue3Oz8rQij+FrzuFkgHY2hVc0BtmE6Q5fVzQG2WaTU8xe0Rh04auu3lQ7zQzha85QG4zt
ExXYAwjf0ndFVKAfDGmroDVnqRUKGyOCrp+PERUUOdZZiMW+4xF81cOEueQ8Cl8VOvipjrL2
NzE0+tLGvIKvQHk7vgLXObEVX6GU2JbIZpBq8TGBr2h/Yxpfld384+xRfMVYfB+hEXzF5CUV
Q/hqHh9zGSJb8dyVH8NXk+wvlWtpBGk8Qh2KQDzjPm8jGVoPfu+DgjKnU7NMgQJKncFX8FWX
0Jv4isIEY/iqOFZaPRHqS8W8ozy+6qHbkdgIvprJv/fS6sVX0iO6Vw514avVD7QEO934Sgo7
c6IC3fuxJVjpmJVEk7NS74M9s5JK4mFRQSa92A7J5i35NaK1d3OP2Feq+jPrzuWyr+dV/RfU
eqeqP3NKFbG7qJVT8YwpKzyu8zO6SzTf7NYiQklbk66ZOYatjrSZS21n9AjHrXAsr9YHYUwz
kC3M4wq7sn3sJ/vH5pKk4bj1FleotcDJAvRsP1ikVuutsFkKq8s15VYnL3uJg0s79lGrrom+
MKebWq0l7nLSVcHXm5aPUKuc0m7z1CoRJp9rZuVFZ9Y1Rq2SU15LmQrEtcIuPcmHuRIaHXlq
fTnMB/qlu2s+xQdyKpu+5rgVblOrFCw8Rq0i1SCoRa26tNmh2lEr2E2+4Lil46VMUyvopWjU
X/ZQK4TEzuZ3hFoh5KaetePeggAw52oMQa/MjEAbAvnWhDOzEqzoedhxS0dJdNVJ8323LKIE
cFLYFQ8v0HlrbX8vHLfe3+PNLOsVyAP9auJVzcBPn36tkDPBWkF6UNoI7nKvID1EqOaP++gS
rO687I3ItVvZA3j1K4bjryj44xCvQjytng/iVUgxPNuIAGqRicuywopDLCRL0+3lVRPLhK2d
Zy0mVjPsBq9CouxsGLt4FVLDwqCbV3W0OLegUV4FK+VvQG83r0ISWup3ADnApEMs5BgdKw/x
KuQUXZ52iDatc4BvGDEYoYFDXWSQgRtlYx1kkBHdxJsig0wQ6Cqv6hJ6i1fB0lBjIgEdgqld
uqUv1Udhnlfzuxv7LK/m5sGwl1ftTDSXZdWh4vPvI7yq7NiCzp57ywhlSiQA1r9j5hQFthns
sMcAXVN42IhAR6F3iF1JIYKGFCc7WEkhgpVGuc6zX+8/nHep1yMihSkjgp8+RSB0KPt1rJzs
HDyBwfsarKiNwTKve1EWT33fd0bUNeUxrbsUXY6/kqr4ZwRlMVXJ+KNQFi3j92SURRDy5VqJ
V1BW99SPdO7HJrGIskhUN+qdKIuncusWyiKzqyLvQ1n97M7aqB9lsRTvDzqKsiiw0IJWA5BC
QSs91I2yFNhXafdttwrR7oHqGMpSLGsOsUC6NPi3PxRBP8RU6tUMKD1j9UADQXRtf6eggaDg
dZTVJfQmyhKO6l11iBhhtVCWKFl2yKOsbrUuvz6CsmaaN+0Qq6MbVqt9KEul4U8xgrL2DHxO
MKBDyUmi+2alnk9aApj7s5IDbWlBCxzrujqIsvot+0ZbS7lATuSTuSum/cC5emKfo+x13L6e
jD0iQiy9etczgmVgbw+wxOm6xXo5QgenX60B03eYeU/q1Ijt9b8kln/Wd/P15z/qKvW3X768
/fe3l7/r5PrN7/767ec//+5Pv7z+5ddfvr395vIfvvzDt3//8vXlLz///p/+8Z/C/xr+0+9/
8/sv//jLl7/+/eXfvnzXaF9++fXL68+/6jKoM/bj7ZdIstUGTIm+MsMj9LVwrOv2PH2s060O
qX1IH4XL5dTy7qm4XBjFmXbFICu4XMpx031sRIu4XETSZn0tiHJYuzxMX/KdHftwWd9mo1dt
Ly5LU7g3iMuSxatbR3BZwLugD+GyeSBOZqesycVSeRgI50Y/zxHYlaLgtBZBYqsavANMdHHw
R5UOMMEQvMn/DJigLh5Jrutr4SYuo95hOGZBi9Zum5u4jNY4umXapS8U3xC5H5cxKPdMKxUw
IPrzVBcuo+Kj7zUygMvWrbbVrrbj3sLA/nlW16zUkTJljIyhoLNrmZuVJ9eTMVzWUdx4GL/Q
yQujfvdbFbs6wWv7mgt97b0GsA1oPiKmWBviDP389Gl4lcjvOxFgzJK2JuAx6kKzFZpLeCI0
Y4ppb5kbpvQwucSBdmafbav7ADTrkJqQfRA0Yzop/58JzajnE/ByCVyBZsvE581yCTQDhM1y
CT38ZnMDaUCzvsROttAFzWhdmKblEqhvaFkuYRVhSzlmzMQ+SzsAzfr1F1843rex58KOR4ag
Ga1N05LYASEUX1g4FiHWPO0EnkCrILAHT0C/tR1OtwhQ4nV5ry6hN6EZkD93feiBZiC6Iu9F
4Nri0kMzMPpHEQPQDK2uy93QrBO5YX3SBc0K3M2Cz25oxui9YzvvLd1h/Emha1bqmtKyuLs/
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
N7992X1+++Hx29/ef/r09c2nz4+7zz/98qD/6tN3n3f6l/Kf/+3u68O/Pn7685sPciy73Zf7
g7/77u5Bj/Q3jzt5ROXvP399eHN/92X3kx72H/UXoe/m84ffd6p/v/vph6cvP3x5vMs/PH74
8hf33bdP9OH3++S/C29/3j1+uPtJX3v74emn3z98FuMXDPhZA2HWQJw1kGYN5FkD0Grg1w+P
uvrND7J/fvjyrz//8BfdID/IX59a0J24+/zh7mP5cT+eLDj5xz/s/2nfmr/8/EW32+OdXBi/
CHbof/7w5dePd//+5pdPv+h/1b//+unzm19++/jxD//hD3+4+/XX3S+Pehp8FoM/Ffuf736W
zf+vv/3y5/fqFb7/9e6XDw8/ySP4vJ3vfpX/+vyf5fj4/N/e3338t7t///J+f3Y8iq2H3359
lMvqe/kP7xVd5er6+PG9bnzxZ3+S5+8PfyOP2PcfntTd+/KT/NdfP4sH+Zfv5efrh/jp0y/y
V+Xnfic/+Munp6/y6Pzlt1+3N/PLzx/ef3vefip/+4e/+fTp1y/f/vPHT3eP7+Wj6C/sp6A/
4NPPv359+Rv5kY+f7x+///nDL58+v3+QO/XrT1Q+jxyHj99//PTn9x93v+8+/rT7/PkPf/Ph
z7/oMFv52/KXf/ib3d3nj/++f88/ff367//ZvVX1Ov1cchR++SS76ezfyn/7/c93P4nBn/X3
+/nf5L1++OUvP8nv9LcPHx+/E0z8+uWHz7/9Ivtn99vu+Jd87dAtJ7MedLuPP5b/+92XXz99
VecY9/8m0I+tB/KP9x++CM9+t7cZ0g/ffzuhWy28/NzgQoz5O/zRPBL38kke/vWng/f9w5n3
/Ye/+dN//I//5f3/+r//8X/5x5/+f7uGKptGHqP/7r//f+Se/K//87/8v//dm+/2z9Qb+bv9
f/qv/6P89R/+P7pQQPg/QQ0A

--tgxxsl4wajdjvchp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="reproduce-quantal-ivb41-2:20170311202540:x86_64-randconfig-in0-03111338:4.7.0-05999-g80a9201:1"

#!/bin/bash

kernel=$1
initrd=quantal-core-x86_64.cgz

wget --no-clobber https://github.com/fengguang/reproduce-kernel-bug/raw/master/initrd/$initrd

kvm=(
	qemu-system-x86_64
	-enable-kvm
	-cpu kvm64
	-kernel $kernel
	-initrd $initrd
	-m 512
	-smp 2
	-device e1000,netdev=net0
	-netdev user,id=net0
	-boot order=nc
	-no-reboot
	-watchdog i6300esb
	-watchdog-action debug
	-rtc base=localtime
	-serial stdio
	-display none
	-monitor null
)

append=(
	root=/dev/ram0
	hung_task_panic=1
	debug
	apic=debug
	sysrq_always_enabled
	rcupdate.rcu_cpu_stall_timeout=100
	net.ifnames=0
	printk.devkmsg=on
	panic=-1
	softlockup_panic=1
	nmi_watchdog=panic
	oops=panic
	load_ramdisk=2
	prompt_ramdisk=0
	drbd.minor_count=8
	systemd.log_level=err
	ignore_loglevel
	earlyprintk=ttyS0,115200
	console=ttyS0,115200
	console=tty0
	vga=normal
	rw
	drbd.minor_count=8
)

"${kvm[@]}" -append "${append[*]}"

--tgxxsl4wajdjvchp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-4.7.0-05999-g80a9201"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 4.7.0 Kernel Configuration
#
CONFIG_64BIT=y
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_MMU=y
CONFIG_ARCH_MMAP_RND_BITS_MIN=28
CONFIG_ARCH_MMAP_RND_BITS_MAX=32
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MIN=8
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MAX=16
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
CONFIG_ZONE_DMA32=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_KASAN_SHADOW_OFFSET=0xdffffc0000000000
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_DEBUG_RODATA=y
CONFIG_PGTABLE_LEVELS=4
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_CONSTRUCTORS=y
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

#
# General setup
#
CONFIG_BROKEN_ON_SMP=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
# CONFIG_COMPILE_TEST is not set
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_HAVE_KERNEL_LZ4=y
CONFIG_KERNEL_GZIP=y
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SWAP=y
# CONFIG_SYSVIPC is not set
# CONFIG_POSIX_MQUEUE is not set
CONFIG_CROSS_MEMORY_ATTACH=y
CONFIG_FHANDLE=y
CONFIG_USELIB=y
# CONFIG_AUDIT is not set
CONFIG_HAVE_ARCH_AUDITSYSCALL=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_IRQ_CHIP=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_DOMAIN_HIERARCHY=y
CONFIG_GENERIC_MSI_IRQ=y
CONFIG_GENERIC_MSI_IRQ_DOMAIN=y
# CONFIG_IRQ_DOMAIN_DEBUG is not set
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_CLOCKSOURCE_VALIDATE_LAST_CYCLE=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_HZ_PERIODIC=y
# CONFIG_NO_HZ_IDLE is not set
# CONFIG_NO_HZ is not set
# CONFIG_HIGH_RES_TIMERS is not set

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=y
# CONFIG_VIRT_CPU_ACCOUNTING_GEN is not set
CONFIG_IRQ_TIME_ACCOUNTING=y
CONFIG_BSD_PROCESS_ACCT=y
CONFIG_BSD_PROCESS_ACCT_V3=y
# CONFIG_TASKSTATS is not set

#
# RCU Subsystem
#
CONFIG_PREEMPT_RCU=y
# CONFIG_RCU_EXPERT is not set
CONFIG_SRCU=y
CONFIG_TASKS_RCU=y
CONFIG_RCU_STALL_COMMON=y
CONFIG_TREE_RCU_TRACE=y
# CONFIG_RCU_EXPEDITE_BOOT is not set
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=17
CONFIG_NMI_LOG_BUF_SHIFT=13
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_SUPPORTS_INT128=y
CONFIG_CGROUPS=y
# CONFIG_MEMCG is not set
# CONFIG_BLK_CGROUP is not set
# CONFIG_CGROUP_SCHED is not set
# CONFIG_CGROUP_PIDS is not set
# CONFIG_CGROUP_FREEZER is not set
# CONFIG_CPUSETS is not set
# CONFIG_CGROUP_DEVICE is not set
# CONFIG_CGROUP_CPUACCT is not set
# CONFIG_CGROUP_PERF is not set
# CONFIG_CGROUP_DEBUG is not set
CONFIG_CHECKPOINT_RESTORE=y
# CONFIG_NAMESPACES is not set
# CONFIG_SCHED_AUTOGROUP is not set
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
CONFIG_RD_XZ=y
CONFIG_RD_LZO=y
CONFIG_RD_LZ4=y
# CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE is not set
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BPF=y
CONFIG_EXPERT=y
CONFIG_MULTIUSER=y
# CONFIG_SGETMASK_SYSCALL is not set
# CONFIG_SYSFS_SYSCALL is not set
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
# CONFIG_KALLSYMS_ABSOLUTE_PERCPU is not set
CONFIG_KALLSYMS_BASE_RELATIVE=y
CONFIG_PRINTK=y
CONFIG_PRINTK_NMI=y
CONFIG_BUG=y
# CONFIG_PCSPKR_PLATFORM is not set
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_BPF_SYSCALL=y
CONFIG_SHMEM=y
# CONFIG_AIO is not set
CONFIG_ADVISE_SYSCALLS=y
CONFIG_USERFAULTFD=y
CONFIG_PCI_QUIRKS=y
CONFIG_MEMBARRIER=y
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y
CONFIG_PERF_USE_VMALLOC=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
CONFIG_DEBUG_PERF_USE_VMALLOC=y
CONFIG_VM_EVENT_COUNTERS=y
# CONFIG_SLUB_DEBUG is not set
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLOB is not set
CONFIG_SLAB_FREELIST_RANDOM=y
# CONFIG_SYSTEM_DATA_VERIFICATION is not set
CONFIG_PROFILING=y
CONFIG_KEXEC_CORE=y
CONFIG_OPROFILE=y
# CONFIG_OPROFILE_EVENT_MULTIPLEX is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
CONFIG_JUMP_LABEL=y
# CONFIG_STATIC_KEYS_SELFTEST is not set
# CONFIG_UPROBES is not set
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_NMI=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_CONTIGUOUS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_ARCH_WANTS_DYNAMIC_TASK_STRUCT=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_CLK=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_ALIGNED_STRUCT_PAGE=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_HAVE_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR is not set
CONFIG_CC_STACKPROTECTOR_NONE=y
# CONFIG_CC_STACKPROTECTOR_REGULAR is not set
# CONFIG_CC_STACKPROTECTOR_STRONG is not set
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_VIRT_CPU_ACCOUNTING_GEN=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_HUGE_VMAP=y
CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_MODULES_USE_ELF_RELA=y
CONFIG_HAVE_IRQ_EXIT_ON_IRQ_STACK=y
CONFIG_ARCH_HAS_ELF_RANDOMIZE=y
CONFIG_HAVE_ARCH_MMAP_RND_BITS=y
CONFIG_HAVE_EXIT_THREAD=y
CONFIG_ARCH_MMAP_RND_BITS=28
CONFIG_HAVE_ARCH_MMAP_RND_COMPAT_BITS=y
CONFIG_ARCH_MMAP_RND_COMPAT_BITS=8
CONFIG_HAVE_COPY_THREAD_TLS=y
CONFIG_HAVE_STACK_VALIDATION=y
# CONFIG_HAVE_ARCH_HASH is not set
CONFIG_ISA_BUS_API=y
# CONFIG_CPU_NO_EFFICIENT_FFS is not set

#
# GCOV-based kernel profiling
#
CONFIG_GCOV_KERNEL=y
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
# CONFIG_GCOV_PROFILE_ALL is not set
CONFIG_GCOV_FORMAT_AUTODETECT=y
# CONFIG_GCOV_FORMAT_3_4 is not set
# CONFIG_GCOV_FORMAT_4_7 is not set
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
# CONFIG_MODULES is not set
CONFIG_MODULES_TREE_LOOKUP=y
CONFIG_BLOCK=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
CONFIG_BLK_DEV_INTEGRITY=y
CONFIG_BLK_CMDLINE_PARSER=y

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
CONFIG_ACORN_PARTITION=y
# CONFIG_ACORN_PARTITION_CUMANA is not set
# CONFIG_ACORN_PARTITION_EESOX is not set
CONFIG_ACORN_PARTITION_ICS=y
# CONFIG_ACORN_PARTITION_ADFS is not set
# CONFIG_ACORN_PARTITION_POWERTEC is not set
# CONFIG_ACORN_PARTITION_RISCIX is not set
CONFIG_AIX_PARTITION=y
# CONFIG_OSF_PARTITION is not set
CONFIG_AMIGA_PARTITION=y
# CONFIG_ATARI_PARTITION is not set
# CONFIG_MAC_PARTITION is not set
# CONFIG_MSDOS_PARTITION is not set
CONFIG_LDM_PARTITION=y
# CONFIG_LDM_DEBUG is not set
# CONFIG_SGI_PARTITION is not set
CONFIG_ULTRIX_PARTITION=y
# CONFIG_SUN_PARTITION is not set
# CONFIG_KARMA_PARTITION is not set
# CONFIG_EFI_PARTITION is not set
# CONFIG_SYSV68_PARTITION is not set
# CONFIG_CMDLINE_PARTITION is not set
CONFIG_BLOCK_COMPAT=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
CONFIG_DEFAULT_DEADLINE=y
# CONFIG_DEFAULT_CFQ is not set
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="deadline"
CONFIG_ASN1=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_ARCH_USE_QUEUED_SPINLOCKS=y
CONFIG_ARCH_USE_QUEUED_RWLOCKS=y
# CONFIG_FREEZER is not set

#
# Processor type and features
#
# CONFIG_ZONE_DMA is not set
# CONFIG_SMP is not set
CONFIG_X86_FEATURE_NAMES=y
CONFIG_X86_FAST_FEATURE_TESTS=y
CONFIG_X86_X2APIC=y
# CONFIG_X86_MPPARSE is not set
# CONFIG_GOLDFISH is not set
CONFIG_X86_EXTENDED_PLATFORM=y
# CONFIG_X86_GOLDFISH is not set
# CONFIG_X86_INTEL_LPSS is not set
# CONFIG_X86_AMD_PLATFORM_DEVICE is not set
CONFIG_IOSF_MBI=y
CONFIG_IOSF_MBI_DEBUG=y
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_XEN is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_GENERIC_CPU=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_PROCESSOR_SELECT=y
# CONFIG_CPU_SUP_INTEL is not set
# CONFIG_CPU_SUP_AMD is not set
# CONFIG_CPU_SUP_CENTAUR is not set
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
CONFIG_DMI=y
CONFIG_CALGARY_IOMMU=y
CONFIG_CALGARY_IOMMU_ENABLED_BY_DEFAULT=y
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_NR_CPUS=1
# CONFIG_PREEMPT_NONE is not set
# CONFIG_PREEMPT_VOLUNTARY is not set
CONFIG_PREEMPT=y
CONFIG_PREEMPT_COUNT=y
CONFIG_UP_LATE_INIT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
CONFIG_X86_MCE=y
CONFIG_X86_MCE_INTEL=y
CONFIG_X86_MCE_AMD=y
CONFIG_X86_MCE_THRESHOLD=y
CONFIG_X86_MCE_INJECT=y
CONFIG_X86_THERMAL_VECTOR=y

#
# Performance monitoring
#
# CONFIG_VM86 is not set
CONFIG_X86_16BIT=y
CONFIG_X86_ESPFIX64=y
CONFIG_X86_VSYSCALL_EMULATION=y
CONFIG_I8K=y
CONFIG_X86_MSR=y
CONFIG_X86_CPUID=y
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
CONFIG_SPARSEMEM_VMEMMAP=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
# CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
# CONFIG_MEMORY_HOTPLUG is not set
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
CONFIG_MEMORY_BALLOON=y
CONFIG_BALLOON_COMPACTION=y
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_VIRT_TO_BUS=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
# CONFIG_HWPOISON_INJECT is not set
CONFIG_TRANSPARENT_HUGEPAGE=y
# CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS is not set
CONFIG_TRANSPARENT_HUGEPAGE_MADVISE=y
CONFIG_TRANSPARENT_HUGE_PAGECACHE=y
CONFIG_NEED_PER_CPU_KM=y
# CONFIG_CLEANCACHE is not set
CONFIG_FRONTSWAP=y
# CONFIG_CMA is not set
# CONFIG_MEM_SOFT_DIRTY is not set
CONFIG_ZSWAP=y
CONFIG_ZPOOL=y
# CONFIG_ZBUD is not set
CONFIG_Z3FOLD=y
CONFIG_ZSMALLOC=y
# CONFIG_PGTABLE_MAPPING is not set
# CONFIG_ZSMALLOC_STAT is not set
CONFIG_GENERIC_EARLY_IOREMAP=y
CONFIG_ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT=y
CONFIG_IDLE_PAGE_TRACKING=y
CONFIG_FRAME_VECTOR=y
# CONFIG_X86_PMEM_LEGACY is not set
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW=64
# CONFIG_MTRR is not set
CONFIG_ARCH_RANDOM=y
CONFIG_X86_SMAP=y
# CONFIG_EFI is not set
# CONFIG_SECCOMP is not set
CONFIG_HZ_100=y
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=100
# CONFIG_SCHED_HRTICK is not set
CONFIG_KEXEC=y
CONFIG_KEXEC_FILE=y
CONFIG_KEXEC_VERIFY_SIG=y
# CONFIG_CRASH_DUMP is not set
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
# CONFIG_RANDOMIZE_BASE is not set
CONFIG_PHYSICAL_ALIGN=0x200000
# CONFIG_LEGACY_VSYSCALL_NATIVE is not set
CONFIG_LEGACY_VSYSCALL_EMULATE=y
# CONFIG_LEGACY_VSYSCALL_NONE is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_MODIFY_LDT_SYSCALL=y
CONFIG_HAVE_LIVEPATCH=y
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y

#
# Power management and ACPI options
#
# CONFIG_SUSPEND is not set
# CONFIG_HIBERNATION is not set
# CONFIG_PM is not set
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=y
CONFIG_ACPI_DEBUGGER=y
# CONFIG_ACPI_DEBUGGER_USER is not set
# CONFIG_ACPI_PROCFS_POWER is not set
CONFIG_ACPI_REV_OVERRIDE_POSSIBLE=y
CONFIG_ACPI_EC_DEBUGFS=y
# CONFIG_ACPI_AC is not set
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_VIDEO=y
CONFIG_ACPI_FAN=y
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_CPU_FREQ_PSS=y
CONFIG_ACPI_PROCESSOR_CSTATE=y
CONFIG_ACPI_PROCESSOR_IDLE=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_PROCESSOR_AGGREGATOR=y
CONFIG_ACPI_THERMAL=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ARCH_HAS_ACPI_TABLE_UPGRADE=y
CONFIG_ACPI_TABLE_UPGRADE=y
CONFIG_ACPI_DEBUG=y
CONFIG_ACPI_PCI_SLOT=y
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
CONFIG_ACPI_HOTPLUG_IOAPIC=y
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
CONFIG_ACPI_REDUCED_HARDWARE_ONLY=y
CONFIG_ACPI_NFIT=y
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
# CONFIG_ACPI_APEI is not set
CONFIG_DPTF_POWER=y
# CONFIG_ACPI_EXTLOG is not set
CONFIG_PMIC_OPREGION=y
CONFIG_XPOWER_PMIC_OPREGION=y
# CONFIG_ACPI_CONFIGFS is not set
CONFIG_SFI=y

#
# CPU Frequency scaling
#
# CONFIG_CPU_FREQ is not set

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set

#
# Memory power savings
#
# CONFIG_I7300_IDLE is not set

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
# CONFIG_PCI_MMCONFIG is not set
CONFIG_PCI_DOMAINS=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
# CONFIG_PCIEPORTBUS is not set
CONFIG_PCI_BUS_ADDR_T_64BIT=y
CONFIG_PCI_MSI=y
CONFIG_PCI_MSI_IRQ_DOMAIN=y
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
CONFIG_PCI_STUB=y
CONFIG_HT_IRQ=y
CONFIG_PCI_ATS=y
CONFIG_PCI_IOV=y
# CONFIG_PCI_PRI is not set
CONFIG_PCI_PASID=y
CONFIG_PCI_LABEL=y
CONFIG_PCI_HYPERV=y
CONFIG_HOTPLUG_PCI=y
CONFIG_HOTPLUG_PCI_ACPI=y
# CONFIG_HOTPLUG_PCI_ACPI_IBM is not set
# CONFIG_HOTPLUG_PCI_CPCI is not set
# CONFIG_HOTPLUG_PCI_SHPC is not set

#
# PCI host controller drivers
#
# CONFIG_PCIE_DW_PLAT is not set
CONFIG_ISA_BUS=y
CONFIG_ISA_DMA_API=y
# CONFIG_PCCARD is not set
# CONFIG_RAPIDIO is not set
# CONFIG_X86_SYSFB is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ELFCORE=y
CONFIG_BINFMT_SCRIPT=y
# CONFIG_HAVE_AOUT is not set
CONFIG_BINFMT_MISC=y
# CONFIG_COREDUMP is not set
# CONFIG_IA32_EMULATION is not set
CONFIG_X86_X32=y
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_KEYS_COMPAT=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_PMC_ATOM=y
# CONFIG_VMD is not set
CONFIG_NET=y

#
# Networking options
#
# CONFIG_PACKET is not set
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
# CONFIG_NET_KEY is not set
# CONFIG_INET is not set
# CONFIG_NETWORK_SECMARK is not set
# CONFIG_NET_PTP_CLASSIFY is not set
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
# CONFIG_NETFILTER is not set
# CONFIG_ATM is not set
# CONFIG_BRIDGE is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_PHONET is not set
# CONFIG_IEEE802154 is not set
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set
# CONFIG_DNS_RESOLVER is not set
# CONFIG_BATMAN_ADV is not set
# CONFIG_VSOCKETS is not set
# CONFIG_NETLINK_DIAG is not set
# CONFIG_MPLS is not set
# CONFIG_HSR is not set
# CONFIG_SOCK_CGROUP_DATA is not set
# CONFIG_CGROUP_NET_PRIO is not set
# CONFIG_CGROUP_NET_CLASSID is not set
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y

#
# Network testing
#
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_IRDA is not set
# CONFIG_BT is not set
CONFIG_WIRELESS=y
# CONFIG_CFG80211 is not set
# CONFIG_LIB80211 is not set

#
# CFG80211 needs to be enabled for MAC80211
#
CONFIG_MAC80211_STA_HASH_MAX_SIZE=0
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
# CONFIG_RFKILL_REGULATOR is not set
# CONFIG_NET_9P is not set
# CONFIG_CAIF is not set
# CONFIG_NFC is not set
# CONFIG_LWTUNNEL is not set
# CONFIG_DST_CACHE is not set
# CONFIG_NET_DEVLINK is not set
CONFIG_MAY_USE_DEVLINK=y
CONFIG_HAVE_EBPF_JIT=y

#
# Device Drivers
#

#
# Generic Driver Options
#
# CONFIG_UEVENT_HELPER is not set
CONFIG_DEVTMPFS=y
# CONFIG_DEVTMPFS_MOUNT is not set
CONFIG_STANDALONE=y
# CONFIG_PREVENT_FIRMWARE_BUILD is not set
CONFIG_FW_LOADER=y
# CONFIG_FIRMWARE_IN_KERNEL is not set
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
CONFIG_FW_LOADER_USER_HELPER_FALLBACK=y
# CONFIG_ALLOW_DEV_COREDUMP is not set
# CONFIG_DEBUG_DRIVER is not set
CONFIG_DEBUG_DEVRES=y
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SPMI=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y
# CONFIG_FENCE_TRACE is not set

#
# Bus devices
#
# CONFIG_CONNECTOR is not set
# CONFIG_MTD is not set
CONFIG_DTC=y
CONFIG_OF=y
CONFIG_OF_UNITTEST=y
CONFIG_OF_FLATTREE=y
CONFIG_OF_EARLY_FLATTREE=y
# CONFIG_OF_DYNAMIC is not set
CONFIG_OF_ADDRESS=y
CONFIG_OF_ADDRESS_PCI=y
CONFIG_OF_IRQ=y
CONFIG_OF_PCI=y
CONFIG_OF_PCI_IRQ=y
CONFIG_OF_RESOLVE=y
# CONFIG_OF_OVERLAY is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
# CONFIG_PARPORT is not set
CONFIG_PNP=y
# CONFIG_PNP_DEBUG_MESSAGES is not set

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
CONFIG_BLK_DEV_NULL_BLK=y
CONFIG_BLK_DEV_FD=y
CONFIG_BLK_DEV_PCIESSD_MTIP32XX=y
# CONFIG_ZRAM is not set
CONFIG_BLK_CPQ_CISS_DA=y
# CONFIG_CISS_SCSI_TAPE is not set
CONFIG_BLK_DEV_DAC960=y
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=y
CONFIG_BLK_DEV_LOOP_MIN_COUNT=8
# CONFIG_BLK_DEV_CRYPTOLOOP is not set

#
# DRBD disabled because PROC_FS or INET not selected
#
# CONFIG_BLK_DEV_NBD is not set
CONFIG_BLK_DEV_SKD=y
CONFIG_BLK_DEV_SX8=y
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=4096
# CONFIG_CDROM_PKTCDVD is not set
# CONFIG_ATA_OVER_ETH is not set
CONFIG_VIRTIO_BLK=y
# CONFIG_BLK_DEV_HD is not set
CONFIG_BLK_DEV_RSXX=y
CONFIG_NVME_CORE=y
CONFIG_BLK_DEV_NVME=y
CONFIG_BLK_DEV_NVME_SCSI=y
CONFIG_NVME_TARGET=y
# CONFIG_NVME_TARGET_LOOP is not set

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=y
# CONFIG_AD525X_DPOT is not set
# CONFIG_DUMMY_IRQ is not set
# CONFIG_IBM_ASM is not set
CONFIG_PHANTOM=y
CONFIG_SGI_IOC4=y
CONFIG_TIFM_CORE=y
# CONFIG_TIFM_7XX1 is not set
# CONFIG_ICS932S401 is not set
# CONFIG_ENCLOSURE_SERVICES is not set
CONFIG_HP_ILO=y
CONFIG_APDS9802ALS=y
CONFIG_ISL29003=y
# CONFIG_ISL29020 is not set
CONFIG_SENSORS_TSL2550=y
# CONFIG_SENSORS_BH1780 is not set
CONFIG_SENSORS_BH1770=y
CONFIG_SENSORS_APDS990X=y
CONFIG_HMC6352=y
# CONFIG_DS1682 is not set
# CONFIG_BMP085_I2C is not set
# CONFIG_USB_SWITCH_FSA9480 is not set
# CONFIG_SRAM is not set
# CONFIG_C2PORT is not set

#
# EEPROM support
#
# CONFIG_EEPROM_AT24 is not set
# CONFIG_EEPROM_LEGACY is not set
CONFIG_EEPROM_MAX6875=y
# CONFIG_EEPROM_93CX6 is not set
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
CONFIG_SENSORS_LIS3_I2C=y

#
# Altera FPGA firmware download module
#
CONFIG_ALTERA_STAPL=y
CONFIG_INTEL_MEI=y
CONFIG_INTEL_MEI_ME=y
# CONFIG_INTEL_MEI_TXE is not set
# CONFIG_VMWARE_VMCI is not set

#
# Intel MIC Bus Driver
#
CONFIG_INTEL_MIC_BUS=y

#
# SCIF Bus Driver
#
CONFIG_SCIF_BUS=y

#
# VOP Bus Driver
#
# CONFIG_VOP_BUS is not set

#
# Intel MIC Host Driver
#

#
# Intel MIC Card Driver
#

#
# SCIF Driver
#

#
# Intel MIC Coprocessor State Management (COSM) Drivers
#

#
# VOP Driver
#
CONFIG_GENWQE=y
CONFIG_GENWQE_PLATFORM_ERROR_RECOVERY=0
# CONFIG_ECHO is not set
# CONFIG_CXL_BASE is not set
# CONFIG_CXL_KERNEL_API is not set
# CONFIG_CXL_EEH is not set
CONFIG_HAVE_IDE=y
CONFIG_IDE=y

#
# Please see Documentation/ide/ide.txt for help/info on IDE drives
#
CONFIG_IDE_XFER_MODE=y
CONFIG_IDE_TIMINGS=y
CONFIG_IDE_ATAPI=y
CONFIG_BLK_DEV_IDE_SATA=y
CONFIG_IDE_GD=y
# CONFIG_IDE_GD_ATA is not set
CONFIG_IDE_GD_ATAPI=y
CONFIG_BLK_DEV_IDECD=y
# CONFIG_BLK_DEV_IDECD_VERBOSE_ERRORS is not set
CONFIG_BLK_DEV_IDETAPE=y
CONFIG_BLK_DEV_IDEACPI=y
CONFIG_IDE_TASK_IOCTL=y
CONFIG_IDE_PROC_FS=y

#
# IDE chipset support/bugfixes
#
CONFIG_IDE_GENERIC=y
CONFIG_BLK_DEV_PLATFORM=y
# CONFIG_BLK_DEV_CMD640 is not set
CONFIG_BLK_DEV_IDEPNP=y
CONFIG_BLK_DEV_IDEDMA_SFF=y

#
# PCI IDE chipsets support
#
CONFIG_BLK_DEV_IDEPCI=y
# CONFIG_IDEPCI_PCIBUS_ORDER is not set
# CONFIG_BLK_DEV_OFFBOARD is not set
CONFIG_BLK_DEV_GENERIC=y
CONFIG_BLK_DEV_OPTI621=y
CONFIG_BLK_DEV_RZ1000=y
CONFIG_BLK_DEV_IDEDMA_PCI=y
CONFIG_BLK_DEV_AEC62XX=y
# CONFIG_BLK_DEV_ALI15X3 is not set
# CONFIG_BLK_DEV_AMD74XX is not set
# CONFIG_BLK_DEV_ATIIXP is not set
CONFIG_BLK_DEV_CMD64X=y
# CONFIG_BLK_DEV_TRIFLEX is not set
CONFIG_BLK_DEV_HPT366=y
# CONFIG_BLK_DEV_JMICRON is not set
CONFIG_BLK_DEV_PIIX=y
# CONFIG_BLK_DEV_IT8172 is not set
# CONFIG_BLK_DEV_IT8213 is not set
# CONFIG_BLK_DEV_IT821X is not set
CONFIG_BLK_DEV_NS87415=y
CONFIG_BLK_DEV_PDC202XX_OLD=y
CONFIG_BLK_DEV_PDC202XX_NEW=y
CONFIG_BLK_DEV_SVWKS=y
CONFIG_BLK_DEV_SIIMAGE=y
# CONFIG_BLK_DEV_SIS5513 is not set
CONFIG_BLK_DEV_SLC90E66=y
# CONFIG_BLK_DEV_TRM290 is not set
# CONFIG_BLK_DEV_VIA82CXXX is not set
# CONFIG_BLK_DEV_TC86C001 is not set
CONFIG_BLK_DEV_IDEDMA=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=y
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
# CONFIG_SCSI_NETLINK is not set
# CONFIG_SCSI_MQ_DEFAULT is not set
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
# CONFIG_BLK_DEV_SD is not set
CONFIG_CHR_DEV_ST=y
# CONFIG_CHR_DEV_OSST is not set
CONFIG_BLK_DEV_SR=y
CONFIG_BLK_DEV_SR_VENDOR=y
# CONFIG_CHR_DEV_SG is not set
CONFIG_CHR_DEV_SCH=y
CONFIG_SCSI_CONSTANTS=y
# CONFIG_SCSI_LOGGING is not set
# CONFIG_SCSI_SCAN_ASYNC is not set

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
# CONFIG_SCSI_FC_ATTRS is not set
# CONFIG_SCSI_ISCSI_ATTRS is not set
CONFIG_SCSI_SAS_ATTRS=y
CONFIG_SCSI_SAS_LIBSAS=y
# CONFIG_SCSI_SAS_HOST_SMP is not set
CONFIG_SCSI_SRP_ATTRS=y
CONFIG_SCSI_LOWLEVEL=y
CONFIG_ISCSI_BOOT_SYSFS=y
# CONFIG_SCSI_BNX2_ISCSI is not set
# CONFIG_BE2ISCSI is not set
CONFIG_BLK_DEV_3W_XXXX_RAID=y
CONFIG_SCSI_HPSA=y
CONFIG_SCSI_3W_9XXX=y
CONFIG_SCSI_3W_SAS=y
CONFIG_SCSI_ACARD=y
CONFIG_SCSI_AACRAID=y
# CONFIG_SCSI_AIC7XXX is not set
CONFIG_SCSI_AIC79XX=y
CONFIG_AIC79XX_CMDS_PER_DEVICE=32
CONFIG_AIC79XX_RESET_DELAY_MS=5000
# CONFIG_AIC79XX_BUILD_FIRMWARE is not set
# CONFIG_AIC79XX_DEBUG_ENABLE is not set
CONFIG_AIC79XX_DEBUG_MASK=0
CONFIG_AIC79XX_REG_PRETTY_PRINT=y
# CONFIG_SCSI_AIC94XX is not set
# CONFIG_SCSI_MVSAS is not set
CONFIG_SCSI_MVUMI=y
CONFIG_SCSI_DPT_I2O=y
CONFIG_SCSI_ADVANSYS=y
CONFIG_SCSI_ARCMSR=y
CONFIG_SCSI_ESAS2R=y
CONFIG_MEGARAID_NEWGEN=y
CONFIG_MEGARAID_MM=y
CONFIG_MEGARAID_MAILBOX=y
CONFIG_MEGARAID_LEGACY=y
CONFIG_MEGARAID_SAS=y
# CONFIG_SCSI_MPT3SAS is not set
# CONFIG_SCSI_MPT2SAS is not set
# CONFIG_SCSI_UFSHCD is not set
CONFIG_SCSI_HPTIOP=y
CONFIG_SCSI_BUSLOGIC=y
# CONFIG_SCSI_FLASHPOINT is not set
CONFIG_VMWARE_PVSCSI=y
# CONFIG_HYPERV_STORAGE is not set
CONFIG_SCSI_SNIC=y
CONFIG_SCSI_SNIC_DEBUG_FS=y
CONFIG_SCSI_DMX3191D=y
CONFIG_SCSI_EATA=y
CONFIG_SCSI_EATA_TAGGED_QUEUE=y
# CONFIG_SCSI_EATA_LINKED_COMMANDS is not set
CONFIG_SCSI_EATA_MAX_TAGS=16
# CONFIG_SCSI_FUTURE_DOMAIN is not set
# CONFIG_SCSI_GDTH is not set
CONFIG_SCSI_ISCI=y
CONFIG_SCSI_IPS=y
# CONFIG_SCSI_INITIO is not set
# CONFIG_SCSI_INIA100 is not set
CONFIG_SCSI_STEX=y
# CONFIG_SCSI_SYM53C8XX_2 is not set
CONFIG_SCSI_QLOGIC_1280=y
# CONFIG_SCSI_QLA_ISCSI is not set
CONFIG_SCSI_DC395x=y
CONFIG_SCSI_AM53C974=y
# CONFIG_SCSI_WD719X is not set
CONFIG_SCSI_DEBUG=y
# CONFIG_SCSI_PMCRAID is not set
CONFIG_SCSI_PM8001=y
CONFIG_SCSI_VIRTIO=y
# CONFIG_SCSI_DH is not set
# CONFIG_SCSI_OSD_INITIATOR is not set
# CONFIG_ATA is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
# CONFIG_MD_AUTODETECT is not set
CONFIG_MD_LINEAR=y
CONFIG_MD_RAID0=y
# CONFIG_MD_RAID1 is not set
CONFIG_MD_RAID10=y
# CONFIG_MD_RAID456 is not set
CONFIG_MD_MULTIPATH=y
# CONFIG_MD_FAULTY is not set
# CONFIG_BCACHE is not set
# CONFIG_BLK_DEV_DM is not set
# CONFIG_TARGET_CORE is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
CONFIG_FIREWIRE_NOSY=y
CONFIG_MACINTOSH_DRIVERS=y
# CONFIG_MAC_EMUMOUSEBTN is not set
# CONFIG_NETDEVICES is not set
# CONFIG_VHOST_NET is not set
CONFIG_VHOST_CROSS_ENDIAN_LEGACY=y
CONFIG_NVM=y
CONFIG_NVM_DEBUG=y
# CONFIG_NVM_GENNVM is not set
CONFIG_NVM_RRPC=y

#
# Input device support
#
CONFIG_INPUT=y
# CONFIG_INPUT_LEDS is not set
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
CONFIG_INPUT_SPARSEKMAP=y
# CONFIG_INPUT_MATRIXKMAP is not set

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
CONFIG_INPUT_JOYDEV=y
# CONFIG_INPUT_EVDEV is not set
CONFIG_INPUT_EVBUG=y

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADP5588 is not set
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
# CONFIG_KEYBOARD_QT2160 is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_GPIO is not set
# CONFIG_KEYBOARD_GPIO_POLLED is not set
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_TCA8418 is not set
# CONFIG_KEYBOARD_MATRIX is not set
# CONFIG_KEYBOARD_LM8323 is not set
# CONFIG_KEYBOARD_LM8333 is not set
# CONFIG_KEYBOARD_MAX7359 is not set
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_MPR121 is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_SAMSUNG is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_STMPE is not set
# CONFIG_KEYBOARD_OMAP4 is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_CROS_EC is not set
# CONFIG_KEYBOARD_CAP11XX is not set
# CONFIG_KEYBOARD_BCM is not set
# CONFIG_INPUT_MOUSE is not set
CONFIG_INPUT_JOYSTICK=y
CONFIG_JOYSTICK_ANALOG=y
CONFIG_JOYSTICK_A3D=y
# CONFIG_JOYSTICK_ADI is not set
CONFIG_JOYSTICK_COBRA=y
CONFIG_JOYSTICK_GF2K=y
# CONFIG_JOYSTICK_GRIP is not set
CONFIG_JOYSTICK_GRIP_MP=y
CONFIG_JOYSTICK_GUILLEMOT=y
# CONFIG_JOYSTICK_INTERACT is not set
CONFIG_JOYSTICK_SIDEWINDER=y
CONFIG_JOYSTICK_TMDC=y
CONFIG_JOYSTICK_IFORCE=y
CONFIG_JOYSTICK_IFORCE_USB=y
CONFIG_JOYSTICK_IFORCE_232=y
# CONFIG_JOYSTICK_WARRIOR is not set
CONFIG_JOYSTICK_MAGELLAN=y
CONFIG_JOYSTICK_SPACEORB=y
CONFIG_JOYSTICK_SPACEBALL=y
# CONFIG_JOYSTICK_STINGER is not set
CONFIG_JOYSTICK_TWIDJOY=y
# CONFIG_JOYSTICK_ZHENHUA is not set
CONFIG_JOYSTICK_AS5011=y
CONFIG_JOYSTICK_JOYDUMP=y
CONFIG_JOYSTICK_XPAD=y
# CONFIG_JOYSTICK_XPAD_FF is not set
# CONFIG_JOYSTICK_XPAD_LEDS is not set
CONFIG_INPUT_TABLET=y
CONFIG_TABLET_USB_ACECAD=y
# CONFIG_TABLET_USB_AIPTEK is not set
CONFIG_TABLET_USB_GTCO=y
CONFIG_TABLET_USB_HANWANG=y
# CONFIG_TABLET_USB_KBTAB is not set
# CONFIG_TABLET_USB_PEGASUS is not set
# CONFIG_TABLET_SERIAL_WACOM4 is not set
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_TOUCHSCREEN_PROPERTIES=y
# CONFIG_TOUCHSCREEN_AD7879 is not set
# CONFIG_TOUCHSCREEN_AR1021_I2C is not set
CONFIG_TOUCHSCREEN_ATMEL_MXT=y
# CONFIG_TOUCHSCREEN_AUO_PIXCIR is not set
CONFIG_TOUCHSCREEN_BU21013=y
# CONFIG_TOUCHSCREEN_CHIPONE_ICN8318 is not set
# CONFIG_TOUCHSCREEN_CY8CTMG110 is not set
# CONFIG_TOUCHSCREEN_CYTTSP_CORE is not set
CONFIG_TOUCHSCREEN_CYTTSP4_CORE=y
# CONFIG_TOUCHSCREEN_CYTTSP4_I2C is not set
CONFIG_TOUCHSCREEN_DA9034=y
# CONFIG_TOUCHSCREEN_DYNAPRO is not set
CONFIG_TOUCHSCREEN_HAMPSHIRE=y
CONFIG_TOUCHSCREEN_EETI=y
# CONFIG_TOUCHSCREEN_EGALAX is not set
# CONFIG_TOUCHSCREEN_EGALAX_SERIAL is not set
# CONFIG_TOUCHSCREEN_FT6236 is not set
# CONFIG_TOUCHSCREEN_FUJITSU is not set
# CONFIG_TOUCHSCREEN_GOODIX is not set
CONFIG_TOUCHSCREEN_ILI210X=y
CONFIG_TOUCHSCREEN_GUNZE=y
# CONFIG_TOUCHSCREEN_ELAN is not set
CONFIG_TOUCHSCREEN_ELO=y
# CONFIG_TOUCHSCREEN_WACOM_W8001 is not set
CONFIG_TOUCHSCREEN_WACOM_I2C=y
CONFIG_TOUCHSCREEN_MAX11801=y
# CONFIG_TOUCHSCREEN_MCS5000 is not set
# CONFIG_TOUCHSCREEN_MMS114 is not set
CONFIG_TOUCHSCREEN_MELFAS_MIP4=y
CONFIG_TOUCHSCREEN_MTOUCH=y
# CONFIG_TOUCHSCREEN_IMX6UL_TSC is not set
CONFIG_TOUCHSCREEN_INEXIO=y
# CONFIG_TOUCHSCREEN_MK712 is not set
CONFIG_TOUCHSCREEN_PENMOUNT=y
# CONFIG_TOUCHSCREEN_EDT_FT5X06 is not set
CONFIG_TOUCHSCREEN_TOUCHRIGHT=y
CONFIG_TOUCHSCREEN_TOUCHWIN=y
CONFIG_TOUCHSCREEN_TI_AM335X_TSC=y
# CONFIG_TOUCHSCREEN_PIXCIR is not set
CONFIG_TOUCHSCREEN_WDT87XX_I2C=y
CONFIG_TOUCHSCREEN_WM831X=y
CONFIG_TOUCHSCREEN_USB_COMPOSITE=y
CONFIG_TOUCHSCREEN_USB_EGALAX=y
CONFIG_TOUCHSCREEN_USB_PANJIT=y
CONFIG_TOUCHSCREEN_USB_3M=y
# CONFIG_TOUCHSCREEN_USB_ITM is not set
CONFIG_TOUCHSCREEN_USB_ETURBO=y
CONFIG_TOUCHSCREEN_USB_GUNZE=y
# CONFIG_TOUCHSCREEN_USB_DMC_TSC10 is not set
# CONFIG_TOUCHSCREEN_USB_IRTOUCH is not set
CONFIG_TOUCHSCREEN_USB_IDEALTEK=y
CONFIG_TOUCHSCREEN_USB_GENERAL_TOUCH=y
CONFIG_TOUCHSCREEN_USB_GOTOP=y
# CONFIG_TOUCHSCREEN_USB_JASTEC is not set
CONFIG_TOUCHSCREEN_USB_ELO=y
CONFIG_TOUCHSCREEN_USB_E2I=y
# CONFIG_TOUCHSCREEN_USB_ZYTRONIC is not set
CONFIG_TOUCHSCREEN_USB_ETT_TC45USB=y
# CONFIG_TOUCHSCREEN_USB_NEXIO is not set
# CONFIG_TOUCHSCREEN_USB_EASYTOUCH is not set
# CONFIG_TOUCHSCREEN_TOUCHIT213 is not set
CONFIG_TOUCHSCREEN_TSC_SERIO=y
CONFIG_TOUCHSCREEN_TSC200X_CORE=y
CONFIG_TOUCHSCREEN_TSC2004=y
CONFIG_TOUCHSCREEN_TSC2007=y
CONFIG_TOUCHSCREEN_RM_TS=y
CONFIG_TOUCHSCREEN_ST1232=y
CONFIG_TOUCHSCREEN_STMPE=y
CONFIG_TOUCHSCREEN_SX8654=y
# CONFIG_TOUCHSCREEN_TPS6507X is not set
CONFIG_TOUCHSCREEN_ZFORCE=y
CONFIG_TOUCHSCREEN_COLIBRI_VF50=y
CONFIG_TOUCHSCREEN_ROHM_BU21023=y
# CONFIG_INPUT_MISC is not set
CONFIG_RMI4_CORE=y
CONFIG_RMI4_I2C=y
CONFIG_RMI4_2D_SENSOR=y
CONFIG_RMI4_F11=y
CONFIG_RMI4_F12=y
CONFIG_RMI4_F30=y

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
CONFIG_SERIO_CT82C710=y
CONFIG_SERIO_PCIPS2=y
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
CONFIG_SERIO_ALTERA_PS2=y
CONFIG_SERIO_PS2MULT=y
CONFIG_SERIO_ARC_PS2=y
CONFIG_SERIO_APBPS2=y
CONFIG_HYPERV_KEYBOARD=y
CONFIG_USERIO=y
CONFIG_GAMEPORT=y
CONFIG_GAMEPORT_NS558=y
CONFIG_GAMEPORT_L4=y
# CONFIG_GAMEPORT_EMU10K1 is not set
# CONFIG_GAMEPORT_FM801 is not set

#
# Character devices
#
CONFIG_TTY=y
# CONFIG_VT is not set
CONFIG_UNIX98_PTYS=y
# CONFIG_LEGACY_PTYS is not set
CONFIG_SERIAL_NONSTANDARD=y
CONFIG_ROCKETPORT=y
CONFIG_CYCLADES=y
# CONFIG_CYZ_INTR is not set
# CONFIG_MOXA_INTELLIO is not set
CONFIG_MOXA_SMARTIO=y
CONFIG_SYNCLINK=y
# CONFIG_SYNCLINKMP is not set
# CONFIG_SYNCLINK_GT is not set
CONFIG_NOZOMI=y
# CONFIG_ISI is not set
CONFIG_N_HDLC=y
# CONFIG_N_GSM is not set
CONFIG_TRACE_ROUTER=y
CONFIG_TRACE_SINK=y
CONFIG_DEVMEM=y
# CONFIG_DEVKMEM is not set

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
CONFIG_SERIAL_8250_PNP=y
# CONFIG_SERIAL_8250_FINTEK is not set
CONFIG_SERIAL_8250_CONSOLE=y
# CONFIG_SERIAL_8250_PCI is not set
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set
# CONFIG_SERIAL_8250_FSL is not set
CONFIG_SERIAL_8250_DW=y
# CONFIG_SERIAL_8250_RT288X is not set
CONFIG_SERIAL_8250_MID=y
# CONFIG_SERIAL_8250_MOXA is not set
CONFIG_SERIAL_OF_PLATFORM=y

#
# Non-8250 serial port support
#
CONFIG_SERIAL_UARTLITE=y
CONFIG_SERIAL_UARTLITE_CONSOLE=y
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
CONFIG_SERIAL_JSM=y
# CONFIG_SERIAL_SCCNXP is not set
CONFIG_SERIAL_SC16IS7XX_CORE=y
CONFIG_SERIAL_SC16IS7XX=y
CONFIG_SERIAL_SC16IS7XX_I2C=y
CONFIG_SERIAL_ALTERA_JTAGUART=y
# CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE is not set
CONFIG_SERIAL_ALTERA_UART=y
CONFIG_SERIAL_ALTERA_UART_MAXPORTS=4
CONFIG_SERIAL_ALTERA_UART_BAUDRATE=115200
# CONFIG_SERIAL_ALTERA_UART_CONSOLE is not set
CONFIG_SERIAL_XILINX_PS_UART=y
CONFIG_SERIAL_XILINX_PS_UART_CONSOLE=y
CONFIG_SERIAL_ARC=y
CONFIG_SERIAL_ARC_CONSOLE=y
CONFIG_SERIAL_ARC_NR_PORTS=1
CONFIG_SERIAL_RP2=y
CONFIG_SERIAL_RP2_NR_UARTS=32
CONFIG_SERIAL_FSL_LPUART=y
CONFIG_SERIAL_FSL_LPUART_CONSOLE=y
CONFIG_SERIAL_CONEXANT_DIGICOLOR=y
CONFIG_SERIAL_CONEXANT_DIGICOLOR_CONSOLE=y
CONFIG_SERIAL_MCTRL_GPIO=y
# CONFIG_TTY_PRINTK is not set
CONFIG_HVC_DRIVER=y
CONFIG_VIRTIO_CONSOLE=y
# CONFIG_IPMI_HANDLER is not set
CONFIG_HW_RANDOM=y
# CONFIG_HW_RANDOM_TIMERIOMEM is not set
CONFIG_HW_RANDOM_INTEL=y
CONFIG_HW_RANDOM_AMD=y
CONFIG_HW_RANDOM_VIA=y
CONFIG_HW_RANDOM_VIRTIO=y
# CONFIG_HW_RANDOM_TPM is not set
CONFIG_NVRAM=y
# CONFIG_R3964 is not set
CONFIG_APPLICOM=y
CONFIG_MWAVE=y
CONFIG_RAW_DRIVER=y
CONFIG_MAX_RAW_DEVS=256
# CONFIG_HPET is not set
# CONFIG_HANGCHECK_TIMER is not set
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS=y
# CONFIG_TCG_TIS_I2C_ATMEL is not set
# CONFIG_TCG_TIS_I2C_INFINEON is not set
CONFIG_TCG_TIS_I2C_NUVOTON=y
# CONFIG_TCG_NSC is not set
# CONFIG_TCG_ATMEL is not set
CONFIG_TCG_INFINEON=y
CONFIG_TCG_CRB=y
CONFIG_TCG_TIS_ST33ZP24=y
CONFIG_TCG_TIS_ST33ZP24_I2C=y
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y
# CONFIG_XILLYBUS is not set

#
# I2C support
#
CONFIG_I2C=y
# CONFIG_ACPI_I2C_OPREGION is not set
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_COMPAT is not set
CONFIG_I2C_CHARDEV=y
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
CONFIG_I2C_ARB_GPIO_CHALLENGE=y
# CONFIG_I2C_MUX_GPIO is not set
# CONFIG_I2C_MUX_PCA9541 is not set
CONFIG_I2C_MUX_PCA954x=y
CONFIG_I2C_MUX_REG=y
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_SMBUS=y
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_ALGOPCA=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
CONFIG_I2C_ALI1563=y
CONFIG_I2C_ALI15X3=y
# CONFIG_I2C_AMD756 is not set
# CONFIG_I2C_AMD8111 is not set
CONFIG_I2C_I801=y
CONFIG_I2C_ISCH=y
CONFIG_I2C_ISMT=y
CONFIG_I2C_PIIX4=y
# CONFIG_I2C_NFORCE2 is not set
CONFIG_I2C_SIS5595=y
CONFIG_I2C_SIS630=y
CONFIG_I2C_SIS96X=y
CONFIG_I2C_VIA=y
CONFIG_I2C_VIAPRO=y

#
# ACPI drivers
#
CONFIG_I2C_SCMI=y

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_CBUS_GPIO is not set
CONFIG_I2C_DESIGNWARE_CORE=y
CONFIG_I2C_DESIGNWARE_PLATFORM=y
# CONFIG_I2C_DESIGNWARE_PCI is not set
CONFIG_I2C_DESIGNWARE_BAYTRAIL=y
# CONFIG_I2C_EMEV2 is not set
CONFIG_I2C_GPIO=y
CONFIG_I2C_KEMPLD=y
CONFIG_I2C_OCORES=y
CONFIG_I2C_PCA_PLATFORM=y
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_RK3X=y
# CONFIG_I2C_SIMTEC is not set
CONFIG_I2C_XILINX=y

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_DIOLAN_U2C=y
CONFIG_I2C_PARPORT_LIGHT=y
CONFIG_I2C_ROBOTFUZZ_OSIF=y
CONFIG_I2C_TAOS_EVM=y
# CONFIG_I2C_TINY_USB is not set
CONFIG_I2C_VIPERBOARD=y

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_CROS_EC_TUNNEL is not set
CONFIG_I2C_SLAVE=y
CONFIG_I2C_SLAVE_EEPROM=y
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_SPI is not set
CONFIG_SPMI=y
CONFIG_HSI=y
CONFIG_HSI_BOARDINFO=y

#
# HSI controllers
#

#
# HSI clients
#
# CONFIG_HSI_CHAR is not set

#
# PPS support
#
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set
# CONFIG_NTP_PPS is not set

#
# PPS clients support
#
CONFIG_PPS_CLIENT_KTIMER=y
# CONFIG_PPS_CLIENT_LDISC is not set
# CONFIG_PPS_CLIENT_GPIO is not set

#
# PPS generators support
#

#
# PTP clock support
#
# CONFIG_PTP_1588_CLOCK is not set

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
CONFIG_GPIOLIB=y
CONFIG_GPIO_DEVRES=y
CONFIG_OF_GPIO=y
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
# CONFIG_DEBUG_GPIO is not set
CONFIG_GPIO_SYSFS=y
CONFIG_GPIO_GENERIC=y
CONFIG_GPIO_MAX730X=y

#
# Memory mapped GPIO drivers
#
CONFIG_GPIO_74XX_MMIO=y
# CONFIG_GPIO_ALTERA is not set
# CONFIG_GPIO_AMDPT is not set
CONFIG_GPIO_DWAPB=y
CONFIG_GPIO_GENERIC_PLATFORM=y
CONFIG_GPIO_GRGPIO=y
CONFIG_GPIO_ICH=y
# CONFIG_GPIO_LYNXPOINT is not set
# CONFIG_GPIO_SYSCON is not set
CONFIG_GPIO_VX855=y
CONFIG_GPIO_XILINX=y
# CONFIG_GPIO_ZX is not set

#
# Port-mapped I/O GPIO drivers
#
CONFIG_GPIO_104_DIO_48E=y
CONFIG_GPIO_104_IDIO_16=y
CONFIG_GPIO_104_IDI_48=y
CONFIG_GPIO_F7188X=y
# CONFIG_GPIO_IT87 is not set
CONFIG_GPIO_SCH=y
CONFIG_GPIO_SCH311X=y
CONFIG_GPIO_WS16C48=y

#
# I2C GPIO expanders
#
CONFIG_GPIO_ADP5588=y
# CONFIG_GPIO_ADP5588_IRQ is not set
CONFIG_GPIO_ADNP=y
CONFIG_GPIO_MAX7300=y
CONFIG_GPIO_MAX732X=y
CONFIG_GPIO_MAX732X_IRQ=y
CONFIG_GPIO_PCA953X=y
# CONFIG_GPIO_PCA953X_IRQ is not set
# CONFIG_GPIO_PCF857X is not set
# CONFIG_GPIO_SX150X is not set
CONFIG_GPIO_TPIC2810=y

#
# MFD GPIO expanders
#
# CONFIG_GPIO_ARIZONA is not set
CONFIG_GPIO_JANZ_TTL=y
# CONFIG_GPIO_KEMPLD is not set
CONFIG_GPIO_LP3943=y
CONFIG_GPIO_PALMAS=y
# CONFIG_GPIO_STMPE is not set
CONFIG_GPIO_TPS65086=y
CONFIG_GPIO_TPS65218=y
CONFIG_GPIO_TWL6040=y
CONFIG_GPIO_WM831X=y
CONFIG_GPIO_WM8994=y

#
# PCI GPIO expanders
#
# CONFIG_GPIO_AMD8111 is not set
CONFIG_GPIO_BT8XX=y
CONFIG_GPIO_ML_IOH=y
# CONFIG_GPIO_RDC321X is not set
CONFIG_GPIO_SODAVILLE=y

#
# SPI or I2C GPIO expanders
#
CONFIG_GPIO_MCP23S08=y

#
# USB GPIO expanders
#
CONFIG_GPIO_VIPERBOARD=y
CONFIG_W1=y

#
# 1-wire Bus Masters
#
CONFIG_W1_MASTER_MATROX=y
CONFIG_W1_MASTER_DS2490=y
CONFIG_W1_MASTER_DS2482=y
CONFIG_W1_MASTER_DS1WM=y
CONFIG_W1_MASTER_GPIO=y

#
# 1-wire Slaves
#
# CONFIG_W1_SLAVE_THERM is not set
CONFIG_W1_SLAVE_SMEM=y
CONFIG_W1_SLAVE_DS2408=y
CONFIG_W1_SLAVE_DS2408_READBACK=y
# CONFIG_W1_SLAVE_DS2413 is not set
# CONFIG_W1_SLAVE_DS2406 is not set
CONFIG_W1_SLAVE_DS2423=y
# CONFIG_W1_SLAVE_DS2431 is not set
CONFIG_W1_SLAVE_DS2433=y
# CONFIG_W1_SLAVE_DS2433_CRC is not set
CONFIG_W1_SLAVE_DS2760=y
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=y
CONFIG_W1_SLAVE_DS28E04=y
CONFIG_W1_SLAVE_BQ27000=y
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
CONFIG_PDA_POWER=y
CONFIG_GENERIC_ADC_BATTERY=y
CONFIG_WM831X_BACKUP=y
CONFIG_WM831X_POWER=y
CONFIG_TEST_POWER=y
CONFIG_BATTERY_DS2760=y
CONFIG_BATTERY_DS2780=y
# CONFIG_BATTERY_DS2781 is not set
CONFIG_BATTERY_DS2782=y
# CONFIG_BATTERY_SBS is not set
CONFIG_BATTERY_BQ27XXX=y
CONFIG_BATTERY_BQ27XXX_I2C=y
CONFIG_BATTERY_DA9030=y
# CONFIG_AXP288_FUEL_GAUGE is not set
CONFIG_BATTERY_MAX17040=y
# CONFIG_BATTERY_MAX17042 is not set
# CONFIG_CHARGER_PCF50633 is not set
# CONFIG_CHARGER_ISP1704 is not set
# CONFIG_CHARGER_MAX8903 is not set
CONFIG_CHARGER_LP8727=y
# CONFIG_CHARGER_GPIO is not set
CONFIG_CHARGER_MANAGER=y
CONFIG_CHARGER_MAX77693=y
CONFIG_CHARGER_MAX8997=y
# CONFIG_CHARGER_BQ2415X is not set
CONFIG_CHARGER_BQ24190=y
# CONFIG_CHARGER_BQ24257 is not set
# CONFIG_CHARGER_BQ24735 is not set
CONFIG_CHARGER_BQ25890=y
# CONFIG_CHARGER_SMB347 is not set
# CONFIG_CHARGER_TPS65217 is not set
CONFIG_BATTERY_GAUGE_LTC2941=y
CONFIG_CHARGER_RT9455=y
CONFIG_AXP20X_POWER=y
# CONFIG_POWER_RESET is not set
CONFIG_POWER_AVS=y
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
# CONFIG_SENSORS_ABITUGURU is not set
CONFIG_SENSORS_ABITUGURU3=y
CONFIG_SENSORS_AD7414=y
# CONFIG_SENSORS_AD7418 is not set
CONFIG_SENSORS_ADM1021=y
# CONFIG_SENSORS_ADM1025 is not set
# CONFIG_SENSORS_ADM1026 is not set
CONFIG_SENSORS_ADM1029=y
CONFIG_SENSORS_ADM1031=y
# CONFIG_SENSORS_ADM9240 is not set
CONFIG_SENSORS_ADT7X10=y
CONFIG_SENSORS_ADT7410=y
# CONFIG_SENSORS_ADT7411 is not set
CONFIG_SENSORS_ADT7462=y
CONFIG_SENSORS_ADT7470=y
# CONFIG_SENSORS_ADT7475 is not set
# CONFIG_SENSORS_ASC7621 is not set
CONFIG_SENSORS_K8TEMP=y
CONFIG_SENSORS_K10TEMP=y
# CONFIG_SENSORS_APPLESMC is not set
# CONFIG_SENSORS_ASB100 is not set
CONFIG_SENSORS_ATXP1=y
# CONFIG_SENSORS_DS620 is not set
CONFIG_SENSORS_DS1621=y
CONFIG_SENSORS_DELL_SMM=y
CONFIG_SENSORS_I5K_AMB=y
CONFIG_SENSORS_F71805F=y
CONFIG_SENSORS_F71882FG=y
CONFIG_SENSORS_F75375S=y
# CONFIG_SENSORS_FSCHMD is not set
CONFIG_SENSORS_GL518SM=y
CONFIG_SENSORS_GL520SM=y
CONFIG_SENSORS_G760A=y
# CONFIG_SENSORS_G762 is not set
# CONFIG_SENSORS_GPIO_FAN is not set
CONFIG_SENSORS_HIH6130=y
CONFIG_SENSORS_IIO_HWMON=y
CONFIG_SENSORS_I5500=y
CONFIG_SENSORS_CORETEMP=y
CONFIG_SENSORS_IT87=y
CONFIG_SENSORS_JC42=y
CONFIG_SENSORS_POWR1220=y
CONFIG_SENSORS_LINEAGE=y
CONFIG_SENSORS_LTC2945=y
CONFIG_SENSORS_LTC2990=y
CONFIG_SENSORS_LTC4151=y
CONFIG_SENSORS_LTC4215=y
# CONFIG_SENSORS_LTC4222 is not set
CONFIG_SENSORS_LTC4245=y
# CONFIG_SENSORS_LTC4260 is not set
CONFIG_SENSORS_LTC4261=y
CONFIG_SENSORS_MAX16065=y
# CONFIG_SENSORS_MAX1619 is not set
# CONFIG_SENSORS_MAX1668 is not set
CONFIG_SENSORS_MAX197=y
CONFIG_SENSORS_MAX6639=y
# CONFIG_SENSORS_MAX6642 is not set
CONFIG_SENSORS_MAX6650=y
CONFIG_SENSORS_MAX6697=y
CONFIG_SENSORS_MAX31790=y
CONFIG_SENSORS_MCP3021=y
CONFIG_SENSORS_LM63=y
CONFIG_SENSORS_LM73=y
CONFIG_SENSORS_LM75=y
# CONFIG_SENSORS_LM77 is not set
# CONFIG_SENSORS_LM78 is not set
CONFIG_SENSORS_LM80=y
CONFIG_SENSORS_LM83=y
# CONFIG_SENSORS_LM85 is not set
CONFIG_SENSORS_LM87=y
CONFIG_SENSORS_LM90=y
CONFIG_SENSORS_LM92=y
# CONFIG_SENSORS_LM93 is not set
CONFIG_SENSORS_LM95234=y
# CONFIG_SENSORS_LM95241 is not set
CONFIG_SENSORS_LM95245=y
CONFIG_SENSORS_PC87360=y
# CONFIG_SENSORS_PC87427 is not set
CONFIG_SENSORS_NTC_THERMISTOR=y
CONFIG_SENSORS_NCT6683=y
CONFIG_SENSORS_NCT6775=y
# CONFIG_SENSORS_NCT7802 is not set
# CONFIG_SENSORS_NCT7904 is not set
CONFIG_SENSORS_PCF8591=y
# CONFIG_PMBUS is not set
# CONFIG_SENSORS_PWM_FAN is not set
# CONFIG_SENSORS_SHT15 is not set
CONFIG_SENSORS_SHT21=y
CONFIG_SENSORS_SHT3x=y
CONFIG_SENSORS_SHTC1=y
# CONFIG_SENSORS_SIS5595 is not set
CONFIG_SENSORS_DME1737=y
CONFIG_SENSORS_EMC1403=y
CONFIG_SENSORS_EMC2103=y
CONFIG_SENSORS_EMC6W201=y
CONFIG_SENSORS_SMSC47M1=y
CONFIG_SENSORS_SMSC47M192=y
CONFIG_SENSORS_SMSC47B397=y
# CONFIG_SENSORS_SCH56XX_COMMON is not set
CONFIG_SENSORS_SMM665=y
CONFIG_SENSORS_ADC128D818=y
CONFIG_SENSORS_ADS1015=y
CONFIG_SENSORS_ADS7828=y
# CONFIG_SENSORS_AMC6821 is not set
# CONFIG_SENSORS_INA209 is not set
CONFIG_SENSORS_INA2XX=y
CONFIG_SENSORS_INA3221=y
# CONFIG_SENSORS_TC74 is not set
# CONFIG_SENSORS_THMC50 is not set
CONFIG_SENSORS_TMP102=y
CONFIG_SENSORS_TMP103=y
CONFIG_SENSORS_TMP401=y
# CONFIG_SENSORS_TMP421 is not set
CONFIG_SENSORS_VIA_CPUTEMP=y
CONFIG_SENSORS_VIA686A=y
# CONFIG_SENSORS_VT1211 is not set
# CONFIG_SENSORS_VT8231 is not set
CONFIG_SENSORS_W83781D=y
CONFIG_SENSORS_W83791D=y
# CONFIG_SENSORS_W83792D is not set
CONFIG_SENSORS_W83793=y
CONFIG_SENSORS_W83795=y
CONFIG_SENSORS_W83795_FANCTRL=y
# CONFIG_SENSORS_W83L785TS is not set
CONFIG_SENSORS_W83L786NG=y
CONFIG_SENSORS_W83627HF=y
CONFIG_SENSORS_W83627EHF=y
# CONFIG_SENSORS_WM831X is not set

#
# ACPI drivers
#
CONFIG_SENSORS_ACPI_POWER=y
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
# CONFIG_THERMAL_HWMON is not set
# CONFIG_THERMAL_OF is not set
CONFIG_THERMAL_WRITABLE_TRIPS=y
# CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE is not set
CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE=y
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR is not set
CONFIG_THERMAL_GOV_FAIR_SHARE=y
CONFIG_THERMAL_GOV_STEP_WISE=y
# CONFIG_THERMAL_GOV_BANG_BANG is not set
CONFIG_THERMAL_GOV_USER_SPACE=y
# CONFIG_THERMAL_GOV_POWER_ALLOCATOR is not set
CONFIG_THERMAL_EMULATION=y
# CONFIG_X86_PKG_TEMP_THERMAL is not set
CONFIG_INTEL_SOC_DTS_IOSF_CORE=y
CONFIG_INTEL_SOC_DTS_THERMAL=y

#
# ACPI INT340X thermal drivers
#
CONFIG_INT340X_THERMAL=y
CONFIG_ACPI_THERMAL_REL=y
# CONFIG_INT3406_THERMAL is not set
CONFIG_INTEL_PCH_THERMAL=y
CONFIG_QCOM_SPMI_TEMP_ALARM=y
CONFIG_GENERIC_ADC_THERMAL=y
# CONFIG_WATCHDOG is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
# CONFIG_SSB is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
CONFIG_BCMA=y
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
CONFIG_BCMA_HOST_PCI=y
# CONFIG_BCMA_HOST_SOC is not set
CONFIG_BCMA_DRIVER_PCI=y
CONFIG_BCMA_DRIVER_GMAC_CMN=y
CONFIG_BCMA_DRIVER_GPIO=y
CONFIG_BCMA_DEBUG=y

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
# CONFIG_MFD_ACT8945A is not set
CONFIG_MFD_AS3711=y
CONFIG_MFD_AS3722=y
# CONFIG_PMIC_ADP5520 is not set
CONFIG_MFD_AAT2870_CORE=y
CONFIG_MFD_ATMEL_FLEXCOM=y
# CONFIG_MFD_ATMEL_HLCDC is not set
CONFIG_MFD_BCM590XX=y
CONFIG_MFD_AXP20X=y
CONFIG_MFD_AXP20X_I2C=y
CONFIG_MFD_CROS_EC=y
CONFIG_MFD_CROS_EC_I2C=y
CONFIG_PMIC_DA903X=y
# CONFIG_MFD_DA9052_I2C is not set
# CONFIG_MFD_DA9055 is not set
# CONFIG_MFD_DA9062 is not set
CONFIG_MFD_DA9063=y
# CONFIG_MFD_DA9150 is not set
# CONFIG_MFD_DLN2 is not set
# CONFIG_MFD_MC13XXX_I2C is not set
# CONFIG_MFD_HI6421_PMIC is not set
CONFIG_HTC_PASIC3=y
# CONFIG_HTC_I2CPLD is not set
CONFIG_MFD_INTEL_QUARK_I2C_GPIO=y
CONFIG_LPC_ICH=y
CONFIG_LPC_SCH=y
# CONFIG_INTEL_SOC_PMIC is not set
CONFIG_MFD_INTEL_LPSS=y
# CONFIG_MFD_INTEL_LPSS_ACPI is not set
CONFIG_MFD_INTEL_LPSS_PCI=y
CONFIG_MFD_JANZ_CMODIO=y
CONFIG_MFD_KEMPLD=y
CONFIG_MFD_88PM800=y
CONFIG_MFD_88PM805=y
# CONFIG_MFD_88PM860X is not set
# CONFIG_MFD_MAX14577 is not set
# CONFIG_MFD_MAX77620 is not set
CONFIG_MFD_MAX77686=y
CONFIG_MFD_MAX77693=y
# CONFIG_MFD_MAX77843 is not set
CONFIG_MFD_MAX8907=y
# CONFIG_MFD_MAX8925 is not set
CONFIG_MFD_MAX8997=y
# CONFIG_MFD_MAX8998 is not set
CONFIG_MFD_MT6397=y
# CONFIG_MFD_MENF21BMC is not set
CONFIG_MFD_VIPERBOARD=y
CONFIG_MFD_RETU=y
CONFIG_MFD_PCF50633=y
CONFIG_PCF50633_ADC=y
CONFIG_PCF50633_GPIO=y
CONFIG_MFD_RDC321X=y
CONFIG_MFD_RTSX_PCI=y
# CONFIG_MFD_RT5033 is not set
# CONFIG_MFD_RTSX_USB is not set
# CONFIG_MFD_RC5T583 is not set
# CONFIG_MFD_RK808 is not set
# CONFIG_MFD_RN5T618 is not set
# CONFIG_MFD_SEC_CORE is not set
CONFIG_MFD_SI476X_CORE=y
CONFIG_MFD_SM501=y
CONFIG_MFD_SM501_GPIO=y
CONFIG_MFD_SKY81452=y
CONFIG_MFD_SMSC=y
# CONFIG_ABX500_CORE is not set
CONFIG_MFD_STMPE=y

#
# STMicroelectronics STMPE Interface Drivers
#
CONFIG_STMPE_I2C=y
CONFIG_MFD_SYSCON=y
CONFIG_MFD_TI_AM335X_TSCADC=y
CONFIG_MFD_LP3943=y
# CONFIG_MFD_LP8788 is not set
CONFIG_MFD_PALMAS=y
CONFIG_TPS6105X=y
# CONFIG_TPS65010 is not set
CONFIG_TPS6507X=y
CONFIG_MFD_TPS65086=y
# CONFIG_MFD_TPS65090 is not set
CONFIG_MFD_TPS65217=y
CONFIG_MFD_TPS65218=y
# CONFIG_MFD_TPS6586X is not set
# CONFIG_MFD_TPS65910 is not set
# CONFIG_MFD_TPS65912_I2C is not set
# CONFIG_MFD_TPS80031 is not set
# CONFIG_TWL4030_CORE is not set
CONFIG_TWL6040_CORE=y
# CONFIG_MFD_WL1273_CORE is not set
CONFIG_MFD_LM3533=y
# CONFIG_MFD_TC3589X is not set
# CONFIG_MFD_TMIO is not set
CONFIG_MFD_VX855=y
CONFIG_MFD_ARIZONA=y
CONFIG_MFD_ARIZONA_I2C=y
# CONFIG_MFD_CS47L24 is not set
# CONFIG_MFD_WM5102 is not set
# CONFIG_MFD_WM5110 is not set
CONFIG_MFD_WM8997=y
CONFIG_MFD_WM8998=y
# CONFIG_MFD_WM8400 is not set
CONFIG_MFD_WM831X=y
CONFIG_MFD_WM831X_I2C=y
# CONFIG_MFD_WM8350_I2C is not set
CONFIG_MFD_WM8994=y
CONFIG_REGULATOR=y
# CONFIG_REGULATOR_DEBUG is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=y
# CONFIG_REGULATOR_VIRTUAL_CONSUMER is not set
CONFIG_REGULATOR_USERSPACE_CONSUMER=y
# CONFIG_REGULATOR_88PM800 is not set
CONFIG_REGULATOR_ACT8865=y
# CONFIG_REGULATOR_AD5398 is not set
# CONFIG_REGULATOR_ANATOP is not set
CONFIG_REGULATOR_AAT2870=y
CONFIG_REGULATOR_AS3711=y
CONFIG_REGULATOR_AS3722=y
CONFIG_REGULATOR_AXP20X=y
# CONFIG_REGULATOR_BCM590XX is not set
# CONFIG_REGULATOR_DA903X is not set
CONFIG_REGULATOR_DA9063=y
CONFIG_REGULATOR_DA9210=y
# CONFIG_REGULATOR_DA9211 is not set
CONFIG_REGULATOR_FAN53555=y
# CONFIG_REGULATOR_GPIO is not set
CONFIG_REGULATOR_ISL9305=y
CONFIG_REGULATOR_ISL6271A=y
CONFIG_REGULATOR_LP3971=y
# CONFIG_REGULATOR_LP3972 is not set
# CONFIG_REGULATOR_LP872X is not set
CONFIG_REGULATOR_LP8755=y
# CONFIG_REGULATOR_LTC3589 is not set
CONFIG_REGULATOR_MAX1586=y
CONFIG_REGULATOR_MAX8649=y
# CONFIG_REGULATOR_MAX8660 is not set
# CONFIG_REGULATOR_MAX8907 is not set
# CONFIG_REGULATOR_MAX8952 is not set
CONFIG_REGULATOR_MAX8997=y
# CONFIG_REGULATOR_MAX77686 is not set
# CONFIG_REGULATOR_MAX77693 is not set
# CONFIG_REGULATOR_MAX77802 is not set
CONFIG_REGULATOR_MT6311=y
# CONFIG_REGULATOR_MT6323 is not set
# CONFIG_REGULATOR_MT6397 is not set
CONFIG_REGULATOR_PALMAS=y
CONFIG_REGULATOR_PCF50633=y
# CONFIG_REGULATOR_PFUZE100 is not set
CONFIG_REGULATOR_PV88060=y
CONFIG_REGULATOR_PV88080=y
CONFIG_REGULATOR_PV88090=y
CONFIG_REGULATOR_PWM=y
CONFIG_REGULATOR_QCOM_SPMI=y
CONFIG_REGULATOR_SKY81452=y
CONFIG_REGULATOR_TPS51632=y
# CONFIG_REGULATOR_TPS6105X is not set
CONFIG_REGULATOR_TPS62360=y
CONFIG_REGULATOR_TPS65023=y
CONFIG_REGULATOR_TPS6507X=y
CONFIG_REGULATOR_TPS65086=y
CONFIG_REGULATOR_TPS65217=y
CONFIG_REGULATOR_TPS65218=y
CONFIG_REGULATOR_WM831X=y
CONFIG_REGULATOR_WM8994=y
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
CONFIG_MEDIA_CAMERA_SUPPORT=y
CONFIG_MEDIA_ANALOG_TV_SUPPORT=y
CONFIG_MEDIA_DIGITAL_TV_SUPPORT=y
CONFIG_MEDIA_RADIO_SUPPORT=y
# CONFIG_MEDIA_SDR_SUPPORT is not set
# CONFIG_MEDIA_RC_SUPPORT is not set
CONFIG_MEDIA_CONTROLLER=y
CONFIG_MEDIA_CONTROLLER_DVB=y
CONFIG_VIDEO_DEV=y
# CONFIG_VIDEO_V4L2_SUBDEV_API is not set
CONFIG_VIDEO_V4L2=y
CONFIG_VIDEO_ADV_DEBUG=y
# CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
CONFIG_VIDEO_PCI_SKELETON=y
CONFIG_VIDEO_TUNER=y
CONFIG_VIDEOBUF_GEN=y
CONFIG_VIDEOBUF_DMA_SG=y
CONFIG_VIDEOBUF2_CORE=y
CONFIG_VIDEOBUF2_MEMOPS=y
CONFIG_VIDEOBUF2_DMA_CONTIG=y
CONFIG_VIDEOBUF2_DMA_SG=y
CONFIG_VIDEOBUF2_DVB=y
CONFIG_DVB_CORE=y
CONFIG_TTPCI_EEPROM=y
CONFIG_DVB_MAX_ADAPTERS=16
# CONFIG_DVB_DYNAMIC_MINORS is not set

#
# Media drivers
#
# CONFIG_MEDIA_USB_SUPPORT is not set
CONFIG_MEDIA_PCI_SUPPORT=y

#
# Media capture support
#
# CONFIG_VIDEO_TW68 is not set
CONFIG_VIDEO_ZORAN=y
# CONFIG_VIDEO_ZORAN_DC30 is not set
# CONFIG_VIDEO_ZORAN_ZR36060 is not set

#
# Media capture/analog TV support
#
CONFIG_VIDEO_HEXIUM_GEMINI=y
# CONFIG_VIDEO_HEXIUM_ORION is not set
CONFIG_VIDEO_MXB=y
CONFIG_VIDEO_DT3155=y

#
# Media capture/analog/hybrid TV support
#
CONFIG_VIDEO_CX25821=y
CONFIG_VIDEO_SAA7134=y
CONFIG_VIDEO_SAA7134_DVB=y
# CONFIG_VIDEO_SAA7164 is not set

#
# Media digital TV PCI Adapters
#
# CONFIG_DVB_AV7110 is not set
CONFIG_DVB_BUDGET_CORE=y
CONFIG_DVB_BUDGET=y
# CONFIG_DVB_BUDGET_AV is not set
CONFIG_DVB_B2C2_FLEXCOP_PCI=y
CONFIG_DVB_B2C2_FLEXCOP_PCI_DEBUG=y
# CONFIG_DVB_PLUTO2 is not set
CONFIG_DVB_PT1=y
CONFIG_DVB_PT3=y
# CONFIG_DVB_NGENE is not set
CONFIG_DVB_DDBRIDGE=y
# CONFIG_V4L_PLATFORM_DRIVERS is not set
# CONFIG_V4L_MEM2MEM_DRIVERS is not set
# CONFIG_V4L_TEST_DRIVERS is not set
# CONFIG_DVB_PLATFORM_DRIVERS is not set

#
# Supported MMC/SDIO adapters
#
CONFIG_RADIO_ADAPTERS=y
CONFIG_RADIO_TEA575X=y
CONFIG_RADIO_SI470X=y
CONFIG_USB_SI470X=y
CONFIG_RADIO_SI4713=y
CONFIG_USB_SI4713=y
# CONFIG_PLATFORM_SI4713 is not set
CONFIG_I2C_SI4713=y
# CONFIG_USB_MR800 is not set
CONFIG_USB_DSBR=y
CONFIG_RADIO_MAXIRADIO=y
CONFIG_RADIO_SHARK=y
CONFIG_RADIO_SHARK2=y
CONFIG_USB_KEENE=y
# CONFIG_USB_RAREMONO is not set
CONFIG_USB_MA901=y
CONFIG_RADIO_TEA5764=y
# CONFIG_RADIO_TEA5764_XTAL is not set
CONFIG_RADIO_SAA7706H=y
CONFIG_RADIO_TEF6862=y
# CONFIG_RADIO_WL1273 is not set

#
# Texas Instruments WL128x FM driver (ST based)
#
CONFIG_VIDEO_TVEEPROM=y
CONFIG_CYPRESS_FIRMWARE=y
CONFIG_DVB_B2C2_FLEXCOP=y
CONFIG_DVB_B2C2_FLEXCOP_DEBUG=y
CONFIG_VIDEO_SAA7146=y
CONFIG_VIDEO_SAA7146_VV=y

#
# Media ancillary drivers (tuners, sensors, i2c, frontends)
#
# CONFIG_MEDIA_SUBDRV_AUTOSELECT is not set

#
# Encoders, decoders, sensors and other helper chips
#

#
# Audio decoders, processors and mixers
#
CONFIG_VIDEO_TVAUDIO=y
# CONFIG_VIDEO_TDA7432 is not set
# CONFIG_VIDEO_TDA9840 is not set
# CONFIG_VIDEO_TEA6415C is not set
CONFIG_VIDEO_TEA6420=y
# CONFIG_VIDEO_MSP3400 is not set
CONFIG_VIDEO_CS3308=y
CONFIG_VIDEO_CS5345=y
# CONFIG_VIDEO_CS53L32A is not set
CONFIG_VIDEO_TLV320AIC23B=y
# CONFIG_VIDEO_UDA1342 is not set
CONFIG_VIDEO_WM8775=y
CONFIG_VIDEO_WM8739=y
CONFIG_VIDEO_VP27SMPX=y
CONFIG_VIDEO_SONY_BTF_MPX=y

#
# RDS decoders
#
# CONFIG_VIDEO_SAA6588 is not set

#
# Video decoders
#
CONFIG_VIDEO_ADV7183=y
CONFIG_VIDEO_BT819=y
# CONFIG_VIDEO_BT856 is not set
CONFIG_VIDEO_BT866=y
# CONFIG_VIDEO_KS0127 is not set
# CONFIG_VIDEO_ML86V7667 is not set
CONFIG_VIDEO_SAA7110=y
CONFIG_VIDEO_SAA711X=y
CONFIG_VIDEO_TVP514X=y
CONFIG_VIDEO_TVP5150=y
# CONFIG_VIDEO_TVP7002 is not set
# CONFIG_VIDEO_TW2804 is not set
# CONFIG_VIDEO_TW9903 is not set
CONFIG_VIDEO_TW9906=y
CONFIG_VIDEO_VPX3220=y

#
# Video and audio decoders
#
# CONFIG_VIDEO_SAA717X is not set
CONFIG_VIDEO_CX25840=y

#
# Video encoders
#
CONFIG_VIDEO_SAA7127=y
CONFIG_VIDEO_SAA7185=y
CONFIG_VIDEO_ADV7170=y
CONFIG_VIDEO_ADV7175=y
CONFIG_VIDEO_ADV7343=y
CONFIG_VIDEO_ADV7393=y
CONFIG_VIDEO_AK881X=y
CONFIG_VIDEO_THS8200=y

#
# Camera sensor devices
#
CONFIG_VIDEO_OV2659=y
# CONFIG_VIDEO_OV7640 is not set
CONFIG_VIDEO_OV7670=y
CONFIG_VIDEO_VS6624=y
CONFIG_VIDEO_MT9V011=y
CONFIG_VIDEO_SR030PC30=y

#
# Flash devices
#
CONFIG_VIDEO_ADP1653=y
# CONFIG_VIDEO_AS3645A is not set
CONFIG_VIDEO_LM3560=y
# CONFIG_VIDEO_LM3646 is not set

#
# Video improvement chips
#
# CONFIG_VIDEO_UPD64031A is not set
# CONFIG_VIDEO_UPD64083 is not set

#
# Audio/Video compression chips
#
CONFIG_VIDEO_SAA6752HS=y

#
# Miscellaneous helper chips
#
# CONFIG_VIDEO_THS7303 is not set
CONFIG_VIDEO_M52790=y

#
# Sensors used on soc_camera driver
#
CONFIG_MEDIA_TUNER=y

#
# Customize TV tuners
#
# CONFIG_MEDIA_TUNER_SIMPLE is not set
CONFIG_MEDIA_TUNER_TDA8290=y
CONFIG_MEDIA_TUNER_TDA827X=y
CONFIG_MEDIA_TUNER_TDA18271=y
# CONFIG_MEDIA_TUNER_TDA9887 is not set
CONFIG_MEDIA_TUNER_TEA5761=y
CONFIG_MEDIA_TUNER_TEA5767=y
# CONFIG_MEDIA_TUNER_MT20XX is not set
CONFIG_MEDIA_TUNER_MT2060=y
CONFIG_MEDIA_TUNER_MT2063=y
# CONFIG_MEDIA_TUNER_MT2266 is not set
CONFIG_MEDIA_TUNER_MT2131=y
CONFIG_MEDIA_TUNER_QT1010=y
CONFIG_MEDIA_TUNER_XC2028=y
CONFIG_MEDIA_TUNER_XC5000=y
CONFIG_MEDIA_TUNER_XC4000=y
CONFIG_MEDIA_TUNER_MXL5005S=y
# CONFIG_MEDIA_TUNER_MXL5007T is not set
CONFIG_MEDIA_TUNER_MC44S803=y
# CONFIG_MEDIA_TUNER_MAX2165 is not set
CONFIG_MEDIA_TUNER_TDA18218=y
CONFIG_MEDIA_TUNER_FC0011=y
CONFIG_MEDIA_TUNER_FC0012=y
CONFIG_MEDIA_TUNER_FC0013=y
CONFIG_MEDIA_TUNER_TDA18212=y
CONFIG_MEDIA_TUNER_E4000=y
CONFIG_MEDIA_TUNER_FC2580=y
CONFIG_MEDIA_TUNER_M88RS6000T=y
CONFIG_MEDIA_TUNER_TUA9001=y
CONFIG_MEDIA_TUNER_SI2157=y
CONFIG_MEDIA_TUNER_IT913X=y
CONFIG_MEDIA_TUNER_R820T=y
CONFIG_MEDIA_TUNER_MXL301RF=y
CONFIG_MEDIA_TUNER_QM1D1C0042=y

#
# Customise DVB Frontends
#

#
# Multistandard (satellite) frontends
#
CONFIG_DVB_STB0899=y
# CONFIG_DVB_STB6100 is not set
# CONFIG_DVB_STV090x is not set
# CONFIG_DVB_STV6110x is not set
# CONFIG_DVB_M88DS3103 is not set

#
# Multistandard (cable + terrestrial) frontends
#
# CONFIG_DVB_DRXK is not set
CONFIG_DVB_TDA18271C2DD=y
CONFIG_DVB_SI2165=y
# CONFIG_DVB_MN88472 is not set
# CONFIG_DVB_MN88473 is not set

#
# DVB-S (satellite) frontends
#
CONFIG_DVB_CX24110=y
# CONFIG_DVB_CX24123 is not set
# CONFIG_DVB_MT312 is not set
# CONFIG_DVB_ZL10036 is not set
CONFIG_DVB_ZL10039=y
CONFIG_DVB_S5H1420=y
CONFIG_DVB_STV0288=y
# CONFIG_DVB_STB6000 is not set
# CONFIG_DVB_STV0299 is not set
CONFIG_DVB_STV6110=y
CONFIG_DVB_STV0900=y
CONFIG_DVB_TDA8083=y
CONFIG_DVB_TDA10086=y
CONFIG_DVB_TDA8261=y
CONFIG_DVB_VES1X93=y
# CONFIG_DVB_TUNER_ITD1000 is not set
CONFIG_DVB_TUNER_CX24113=y
CONFIG_DVB_TDA826X=y
CONFIG_DVB_TUA6100=y
CONFIG_DVB_CX24116=y
CONFIG_DVB_CX24117=y
# CONFIG_DVB_CX24120 is not set
CONFIG_DVB_SI21XX=y
# CONFIG_DVB_TS2020 is not set
# CONFIG_DVB_DS3000 is not set
CONFIG_DVB_MB86A16=y
CONFIG_DVB_TDA10071=y

#
# DVB-T (terrestrial) frontends
#
CONFIG_DVB_SP8870=y
CONFIG_DVB_SP887X=y
CONFIG_DVB_CX22700=y
CONFIG_DVB_CX22702=y
# CONFIG_DVB_S5H1432 is not set
# CONFIG_DVB_DRXD is not set
CONFIG_DVB_L64781=y
# CONFIG_DVB_TDA1004X is not set
CONFIG_DVB_NXT6000=y
# CONFIG_DVB_MT352 is not set
CONFIG_DVB_ZL10353=y
CONFIG_DVB_DIB3000MB=y
CONFIG_DVB_DIB3000MC=y
# CONFIG_DVB_DIB7000M is not set
CONFIG_DVB_DIB7000P=y
CONFIG_DVB_DIB9000=y
CONFIG_DVB_TDA10048=y
CONFIG_DVB_AF9013=y
CONFIG_DVB_EC100=y
CONFIG_DVB_HD29L2=y
# CONFIG_DVB_STV0367 is not set
CONFIG_DVB_CXD2820R=y
CONFIG_DVB_CXD2841ER=y
CONFIG_DVB_RTL2830=y
# CONFIG_DVB_RTL2832 is not set
# CONFIG_DVB_SI2168 is not set
# CONFIG_DVB_AS102_FE is not set

#
# DVB-C (cable) frontends
#
# CONFIG_DVB_VES1820 is not set
CONFIG_DVB_TDA10021=y
CONFIG_DVB_TDA10023=y
CONFIG_DVB_STV0297=y

#
# ATSC (North American/Korean Terrestrial/Cable DTV) frontends
#
CONFIG_DVB_NXT200X=y
CONFIG_DVB_OR51211=y
CONFIG_DVB_OR51132=y
CONFIG_DVB_BCM3510=y
# CONFIG_DVB_LGDT330X is not set
# CONFIG_DVB_LGDT3305 is not set
# CONFIG_DVB_LGDT3306A is not set
# CONFIG_DVB_LG2160 is not set
# CONFIG_DVB_S5H1409 is not set
CONFIG_DVB_AU8522=y
CONFIG_DVB_AU8522_DTV=y
CONFIG_DVB_AU8522_V4L=y
CONFIG_DVB_S5H1411=y

#
# ISDB-T (terrestrial) frontends
#
# CONFIG_DVB_S921 is not set
# CONFIG_DVB_DIB8000 is not set
CONFIG_DVB_MB86A20S=y

#
# ISDB-S (satellite) & ISDB-T (terrestrial) frontends
#
CONFIG_DVB_TC90522=y

#
# Digital terrestrial only tuners/PLL
#
CONFIG_DVB_PLL=y
CONFIG_DVB_TUNER_DIB0070=y
CONFIG_DVB_TUNER_DIB0090=y

#
# SEC control devices for DVB-S
#
# CONFIG_DVB_DRX39XYJ is not set
# CONFIG_DVB_LNBH25 is not set
# CONFIG_DVB_LNBP21 is not set
# CONFIG_DVB_LNBP22 is not set
CONFIG_DVB_ISL6405=y
CONFIG_DVB_ISL6421=y
# CONFIG_DVB_ISL6423 is not set
# CONFIG_DVB_A8293 is not set
CONFIG_DVB_SP2=y
CONFIG_DVB_LGS8GL5=y
CONFIG_DVB_LGS8GXX=y
# CONFIG_DVB_ATBM8830 is not set
CONFIG_DVB_TDA665x=y
# CONFIG_DVB_IX2505V is not set
CONFIG_DVB_M88RS2000=y
CONFIG_DVB_AF9033=y
CONFIG_DVB_HORUS3A=y
CONFIG_DVB_ASCOT2E=y
CONFIG_DVB_HELENE=y

#
# Tools to develop new frontends
#
# CONFIG_DVB_DUMMY_FE is not set

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_INTEL_GTT=y
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
CONFIG_DRM=y
CONFIG_DRM_MIPI_DSI=y
CONFIG_DRM_DP_AUX_CHARDEV=y
CONFIG_DRM_KMS_HELPER=y
CONFIG_DRM_KMS_FB_HELPER=y
CONFIG_DRM_FBDEV_EMULATION=y
CONFIG_DRM_LOAD_EDID_FIRMWARE=y
CONFIG_DRM_TTM=y

#
# I2C encoder or helper chips
#
CONFIG_DRM_I2C_ADV7511=y
# CONFIG_DRM_I2C_CH7006 is not set
CONFIG_DRM_I2C_SIL164=y
# CONFIG_DRM_I2C_NXP_TDA998X is not set
CONFIG_DRM_TDFX=y
CONFIG_DRM_R128=y
CONFIG_DRM_RADEON=y
# CONFIG_DRM_RADEON_USERPTR is not set
CONFIG_DRM_AMDGPU=y
CONFIG_DRM_AMDGPU_CIK=y
# CONFIG_DRM_AMDGPU_USERPTR is not set
# CONFIG_DRM_AMDGPU_GART_DEBUGFS is not set
# CONFIG_DRM_AMD_POWERPLAY is not set

#
# ACP (Audio CoProcessor) Configuration
#
CONFIG_DRM_AMD_ACP=y
# CONFIG_DRM_NOUVEAU is not set
CONFIG_DRM_I915=y
# CONFIG_DRM_I915_PRELIMINARY_HW_SUPPORT is not set
# CONFIG_DRM_I915_USERPTR is not set

#
# drm/i915 Debugging
#
# CONFIG_DRM_I915_WERROR is not set
# CONFIG_DRM_I915_DEBUG is not set
# CONFIG_DRM_MGA is not set
CONFIG_DRM_VIA=y
CONFIG_DRM_SAVAGE=y
CONFIG_DRM_VGEM=y
# CONFIG_DRM_VMWGFX is not set
CONFIG_DRM_GMA500=y
# CONFIG_DRM_GMA600 is not set
# CONFIG_DRM_GMA3600 is not set
# CONFIG_DRM_UDL is not set
CONFIG_DRM_AST=y
CONFIG_DRM_MGAG200=y
# CONFIG_DRM_CIRRUS_QEMU is not set
CONFIG_DRM_QXL=y
CONFIG_DRM_BOCHS=y
CONFIG_DRM_VIRTIO_GPU=y
CONFIG_DRM_PANEL=y

#
# Display Panels
#
# CONFIG_DRM_PANEL_SIMPLE is not set
CONFIG_DRM_PANEL_PANASONIC_VVX10F034N00=y
# CONFIG_DRM_PANEL_SAMSUNG_S6E8AA0 is not set
CONFIG_DRM_PANEL_SHARP_LQ101R1SX01=y
# CONFIG_DRM_PANEL_SHARP_LS043T1LE01 is not set
CONFIG_DRM_BRIDGE=y

#
# Display Interface Bridges
#
CONFIG_DRM_ANALOGIX_ANX78XX=y
CONFIG_DRM_NXP_PTN3460=y
CONFIG_DRM_PARADE_PS8622=y
# CONFIG_DRM_ARCPGU is not set

#
# Frame buffer Devices
#
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
CONFIG_FB_CMDLINE=y
CONFIG_FB_NOTIFY=y
CONFIG_FB_DDC=y
CONFIG_FB_BOOT_VESA_SUPPORT=y
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
# CONFIG_FB_FOREIGN_ENDIAN is not set
CONFIG_FB_SYS_FOPS=y
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_HECUBA=y
CONFIG_FB_SVGALIB=y
# CONFIG_FB_MACMODES is not set
CONFIG_FB_BACKLIGHT=y
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
CONFIG_FB_CIRRUS=y
CONFIG_FB_PM2=y
# CONFIG_FB_PM2_FIFO_DISCONNECT is not set
# CONFIG_FB_CYBER2000 is not set
CONFIG_FB_ARC=y
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
CONFIG_FB_VESA=y
CONFIG_FB_N411=y
CONFIG_FB_HGA=y
CONFIG_FB_OPENCORES=y
# CONFIG_FB_S1D13XXX is not set
CONFIG_FB_NVIDIA=y
CONFIG_FB_NVIDIA_I2C=y
CONFIG_FB_NVIDIA_DEBUG=y
# CONFIG_FB_NVIDIA_BACKLIGHT is not set
CONFIG_FB_RIVA=y
# CONFIG_FB_RIVA_I2C is not set
# CONFIG_FB_RIVA_DEBUG is not set
# CONFIG_FB_RIVA_BACKLIGHT is not set
CONFIG_FB_I740=y
# CONFIG_FB_LE80578 is not set
# CONFIG_FB_MATROX is not set
CONFIG_FB_RADEON=y
# CONFIG_FB_RADEON_I2C is not set
# CONFIG_FB_RADEON_BACKLIGHT is not set
CONFIG_FB_RADEON_DEBUG=y
CONFIG_FB_ATY128=y
CONFIG_FB_ATY128_BACKLIGHT=y
CONFIG_FB_ATY=y
# CONFIG_FB_ATY_CT is not set
# CONFIG_FB_ATY_GX is not set
# CONFIG_FB_ATY_BACKLIGHT is not set
CONFIG_FB_S3=y
CONFIG_FB_S3_DDC=y
# CONFIG_FB_SAVAGE is not set
CONFIG_FB_SIS=y
CONFIG_FB_SIS_300=y
# CONFIG_FB_SIS_315 is not set
CONFIG_FB_VIA=y
CONFIG_FB_VIA_DIRECT_PROCFS=y
# CONFIG_FB_VIA_X_COMPATIBILITY is not set
CONFIG_FB_NEOMAGIC=y
CONFIG_FB_KYRO=y
CONFIG_FB_3DFX=y
# CONFIG_FB_3DFX_ACCEL is not set
CONFIG_FB_3DFX_I2C=y
CONFIG_FB_VOODOO1=y
# CONFIG_FB_VT8623 is not set
# CONFIG_FB_TRIDENT is not set
CONFIG_FB_ARK=y
# CONFIG_FB_PM3 is not set
CONFIG_FB_CARMINE=y
# CONFIG_FB_CARMINE_DRAM_EVAL is not set
CONFIG_CARMINE_DRAM_CUSTOM=y
CONFIG_FB_SM501=y
# CONFIG_FB_SMSCUFX is not set
CONFIG_FB_UDL=y
# CONFIG_FB_IBM_GXT4500 is not set
CONFIG_FB_VIRTUAL=y
# CONFIG_FB_METRONOME is not set
# CONFIG_FB_MB862XX is not set
# CONFIG_FB_BROADSHEET is not set
CONFIG_FB_AUO_K190X=y
# CONFIG_FB_AUO_K1900 is not set
CONFIG_FB_AUO_K1901=y
# CONFIG_FB_HYPERV is not set
CONFIG_FB_SIMPLE=y
CONFIG_FB_SSD1307=y
CONFIG_FB_SM712=y
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
# CONFIG_LCD_PLATFORM is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_GENERIC=y
# CONFIG_BACKLIGHT_LM3533 is not set
CONFIG_BACKLIGHT_PWM=y
CONFIG_BACKLIGHT_DA903X=y
# CONFIG_BACKLIGHT_APPLE is not set
# CONFIG_BACKLIGHT_PM8941_WLED is not set
# CONFIG_BACKLIGHT_SAHARA is not set
CONFIG_BACKLIGHT_WM831X=y
# CONFIG_BACKLIGHT_ADP8860 is not set
CONFIG_BACKLIGHT_ADP8870=y
CONFIG_BACKLIGHT_PCF50633=y
CONFIG_BACKLIGHT_AAT2870=y
CONFIG_BACKLIGHT_LM3630A=y
# CONFIG_BACKLIGHT_LM3639 is not set
# CONFIG_BACKLIGHT_LP855X is not set
# CONFIG_BACKLIGHT_SKY81452 is not set
# CONFIG_BACKLIGHT_TPS65217 is not set
# CONFIG_BACKLIGHT_AS3711 is not set
CONFIG_BACKLIGHT_GPIO=y
CONFIG_BACKLIGHT_LV5207LP=y
CONFIG_BACKLIGHT_BD6107=y
CONFIG_VGASTATE=y
CONFIG_HDMI=y
# CONFIG_LOGO is not set
CONFIG_SOUND=y
CONFIG_SOUND_OSS_CORE=y
# CONFIG_SOUND_OSS_CORE_PRECLAIM is not set
# CONFIG_SND is not set
CONFIG_SOUND_PRIME=y
CONFIG_SOUND_OSS=y
CONFIG_SOUND_TRACEINIT=y
CONFIG_SOUND_DMAP=y
# CONFIG_SOUND_VMIDI is not set
CONFIG_SOUND_TRIX=y
# CONFIG_SOUND_MSS is not set
CONFIG_SOUND_MPU401=y
# CONFIG_SOUND_PAS is not set
CONFIG_SOUND_PSS=y
CONFIG_PSS_MIXER=y
# CONFIG_SOUND_SB is not set
CONFIG_SOUND_YM3812=y
CONFIG_SOUND_UART6850=y
# CONFIG_SOUND_AEDSP16 is not set

#
# HID support
#
CONFIG_HID=y
CONFIG_HID_BATTERY_STRENGTH=y
CONFIG_HIDRAW=y
CONFIG_UHID=y
# CONFIG_HID_GENERIC is not set

#
# Special HID drivers
#
# CONFIG_HID_A4TECH is not set
CONFIG_HID_ACRUX=y
CONFIG_HID_ACRUX_FF=y
CONFIG_HID_APPLE=y
CONFIG_HID_APPLEIR=y
CONFIG_HID_ASUS=y
CONFIG_HID_AUREAL=y
# CONFIG_HID_BELKIN is not set
CONFIG_HID_BETOP_FF=y
CONFIG_HID_CHERRY=y
CONFIG_HID_CHICONY=y
CONFIG_HID_CORSAIR=y
CONFIG_HID_CMEDIA=y
CONFIG_HID_CP2112=y
CONFIG_HID_CYPRESS=y
# CONFIG_HID_DRAGONRISE is not set
CONFIG_HID_EMS_FF=y
CONFIG_HID_ELECOM=y
CONFIG_HID_ELO=y
# CONFIG_HID_EZKEY is not set
# CONFIG_HID_GEMBIRD is not set
CONFIG_HID_GFRM=y
CONFIG_HID_HOLTEK=y
# CONFIG_HOLTEK_FF is not set
CONFIG_HID_GT683R=y
# CONFIG_HID_KEYTOUCH is not set
# CONFIG_HID_KYE is not set
# CONFIG_HID_UCLOGIC is not set
CONFIG_HID_WALTOP=y
CONFIG_HID_GYRATION=y
CONFIG_HID_ICADE=y
# CONFIG_HID_TWINHAN is not set
CONFIG_HID_KENSINGTON=y
CONFIG_HID_LCPOWER=y
CONFIG_HID_LENOVO=y
# CONFIG_HID_LOGITECH is not set
CONFIG_HID_MAGICMOUSE=y
# CONFIG_HID_MICROSOFT is not set
# CONFIG_HID_MONTEREY is not set
# CONFIG_HID_MULTITOUCH is not set
# CONFIG_HID_NTRIG is not set
# CONFIG_HID_ORTEK is not set
# CONFIG_HID_PANTHERLORD is not set
CONFIG_HID_PENMOUNT=y
# CONFIG_HID_PETALYNX is not set
CONFIG_HID_PICOLCD=y
CONFIG_HID_PICOLCD_FB=y
CONFIG_HID_PICOLCD_BACKLIGHT=y
# CONFIG_HID_PICOLCD_LCD is not set
CONFIG_HID_PICOLCD_LEDS=y
CONFIG_HID_PLANTRONICS=y
CONFIG_HID_PRIMAX=y
CONFIG_HID_ROCCAT=y
# CONFIG_HID_SAITEK is not set
# CONFIG_HID_SAMSUNG is not set
CONFIG_HID_SONY=y
CONFIG_SONY_FF=y
CONFIG_HID_SPEEDLINK=y
# CONFIG_HID_STEELSERIES is not set
CONFIG_HID_SUNPLUS=y
CONFIG_HID_RMI=y
# CONFIG_HID_GREENASIA is not set
# CONFIG_HID_HYPERV_MOUSE is not set
CONFIG_HID_SMARTJOYPLUS=y
# CONFIG_SMARTJOYPLUS_FF is not set
CONFIG_HID_TIVO=y
CONFIG_HID_TOPSEED=y
# CONFIG_HID_THINGM is not set
# CONFIG_HID_THRUSTMASTER is not set
CONFIG_HID_WACOM=y
CONFIG_HID_WIIMOTE=y
CONFIG_HID_XINMO=y
# CONFIG_HID_ZEROPLUS is not set
CONFIG_HID_ZYDACRON=y
# CONFIG_HID_SENSOR_HUB is not set

#
# USB HID support
#
CONFIG_USB_HID=y
# CONFIG_HID_PID is not set
# CONFIG_USB_HIDDEV is not set

#
# I2C HID support
#
CONFIG_I2C_HID=y
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
CONFIG_USB_ANNOUNCE_NEW_DEVICES=y

#
# Miscellaneous USB options
#
# CONFIG_USB_DEFAULT_PERSIST is not set
# CONFIG_USB_DYNAMIC_MINORS is not set
CONFIG_USB_OTG_WHITELIST=y
CONFIG_USB_OTG_BLACKLIST_HUB=y
CONFIG_USB_ULPI_BUS=y
CONFIG_USB_MON=y
# CONFIG_USB_WUSB_CBAF is not set

#
# USB Host Controller Drivers
#
CONFIG_USB_C67X00_HCD=y
# CONFIG_USB_XHCI_HCD is not set
CONFIG_USB_EHCI_HCD=y
# CONFIG_USB_EHCI_ROOT_HUB_TT is not set
# CONFIG_USB_EHCI_TT_NEWSCHED is not set
CONFIG_USB_EHCI_PCI=y
# CONFIG_USB_EHCI_HCD_PLATFORM is not set
# CONFIG_USB_OXU210HP_HCD is not set
# CONFIG_USB_ISP116X_HCD is not set
# CONFIG_USB_ISP1362_HCD is not set
CONFIG_USB_FOTG210_HCD=y
CONFIG_USB_OHCI_HCD=y
CONFIG_USB_OHCI_HCD_PCI=y
CONFIG_USB_OHCI_HCD_PLATFORM=y
CONFIG_USB_UHCI_HCD=y
# CONFIG_USB_U132_HCD is not set
CONFIG_USB_SL811_HCD=y
# CONFIG_USB_SL811_HCD_ISO is not set
# CONFIG_USB_R8A66597_HCD is not set
# CONFIG_USB_HCD_BCMA is not set
CONFIG_USB_HCD_TEST_MODE=y

#
# USB Device Class drivers
#
# CONFIG_USB_ACM is not set
CONFIG_USB_PRINTER=y
CONFIG_USB_WDM=y
CONFIG_USB_TMC=y

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
# CONFIG_USB_STORAGE is not set

#
# USB Imaging devices
#
CONFIG_USB_MDC800=y
CONFIG_USB_MICROTEK=y
# CONFIG_USBIP_CORE is not set
CONFIG_USB_MUSB_HDRC=y
CONFIG_USB_MUSB_HOST=y
# CONFIG_USB_MUSB_GADGET is not set
# CONFIG_USB_MUSB_DUAL_ROLE is not set

#
# Platform Glue Layer
#

#
# MUSB DMA mode
#
# CONFIG_MUSB_PIO_ONLY is not set
CONFIG_USB_DWC3=y
CONFIG_USB_DWC3_ULPI=y
# CONFIG_USB_DWC3_HOST is not set
# CONFIG_USB_DWC3_GADGET is not set
CONFIG_USB_DWC3_DUAL_ROLE=y

#
# Platform Glue Driver Support
#
CONFIG_USB_DWC3_PCI=y
CONFIG_USB_DWC3_OF_SIMPLE=y
# CONFIG_USB_DWC2 is not set
CONFIG_USB_CHIPIDEA=y
CONFIG_USB_CHIPIDEA_OF=y
CONFIG_USB_CHIPIDEA_PCI=y
CONFIG_USB_CHIPIDEA_UDC=y
# CONFIG_USB_CHIPIDEA_HOST is not set
CONFIG_USB_ISP1760=y
CONFIG_USB_ISP1760_HCD=y
CONFIG_USB_ISP1761_UDC=y
# CONFIG_USB_ISP1760_HOST_ROLE is not set
# CONFIG_USB_ISP1760_GADGET_ROLE is not set
CONFIG_USB_ISP1760_DUAL_ROLE=y

#
# USB port drivers
#
CONFIG_USB_SERIAL=y
CONFIG_USB_SERIAL_CONSOLE=y
# CONFIG_USB_SERIAL_GENERIC is not set
CONFIG_USB_SERIAL_SIMPLE=y
CONFIG_USB_SERIAL_AIRCABLE=y
# CONFIG_USB_SERIAL_ARK3116 is not set
CONFIG_USB_SERIAL_BELKIN=y
CONFIG_USB_SERIAL_CH341=y
# CONFIG_USB_SERIAL_WHITEHEAT is not set
# CONFIG_USB_SERIAL_DIGI_ACCELEPORT is not set
CONFIG_USB_SERIAL_CP210X=y
# CONFIG_USB_SERIAL_CYPRESS_M8 is not set
CONFIG_USB_SERIAL_EMPEG=y
CONFIG_USB_SERIAL_FTDI_SIO=y
CONFIG_USB_SERIAL_VISOR=y
CONFIG_USB_SERIAL_IPAQ=y
# CONFIG_USB_SERIAL_IR is not set
CONFIG_USB_SERIAL_EDGEPORT=y
CONFIG_USB_SERIAL_EDGEPORT_TI=y
# CONFIG_USB_SERIAL_F81232 is not set
# CONFIG_USB_SERIAL_GARMIN is not set
CONFIG_USB_SERIAL_IPW=y
CONFIG_USB_SERIAL_IUU=y
CONFIG_USB_SERIAL_KEYSPAN_PDA=y
# CONFIG_USB_SERIAL_KEYSPAN is not set
# CONFIG_USB_SERIAL_KLSI is not set
CONFIG_USB_SERIAL_KOBIL_SCT=y
CONFIG_USB_SERIAL_MCT_U232=y
CONFIG_USB_SERIAL_METRO=y
CONFIG_USB_SERIAL_MOS7720=y
# CONFIG_USB_SERIAL_MOS7840 is not set
# CONFIG_USB_SERIAL_MXUPORT is not set
CONFIG_USB_SERIAL_NAVMAN=y
# CONFIG_USB_SERIAL_PL2303 is not set
CONFIG_USB_SERIAL_OTI6858=y
CONFIG_USB_SERIAL_QCAUX=y
# CONFIG_USB_SERIAL_QUALCOMM is not set
CONFIG_USB_SERIAL_SPCP8X5=y
CONFIG_USB_SERIAL_SAFE=y
CONFIG_USB_SERIAL_SAFE_PADDED=y
CONFIG_USB_SERIAL_SIERRAWIRELESS=y
CONFIG_USB_SERIAL_SYMBOL=y
# CONFIG_USB_SERIAL_TI is not set
# CONFIG_USB_SERIAL_CYBERJACK is not set
# CONFIG_USB_SERIAL_XIRCOM is not set
CONFIG_USB_SERIAL_WWAN=y
# CONFIG_USB_SERIAL_OPTION is not set
# CONFIG_USB_SERIAL_OMNINET is not set
# CONFIG_USB_SERIAL_OPTICON is not set
# CONFIG_USB_SERIAL_XSENS_MT is not set
# CONFIG_USB_SERIAL_WISHBONE is not set
# CONFIG_USB_SERIAL_SSU100 is not set
CONFIG_USB_SERIAL_QT2=y
CONFIG_USB_SERIAL_DEBUG=y

#
# USB Miscellaneous drivers
#
CONFIG_USB_EMI62=y
# CONFIG_USB_EMI26 is not set
# CONFIG_USB_ADUTUX is not set
CONFIG_USB_SEVSEG=y
CONFIG_USB_RIO500=y
CONFIG_USB_LEGOTOWER=y
CONFIG_USB_LCD=y
# CONFIG_USB_LED is not set
CONFIG_USB_CYPRESS_CY7C63=y
CONFIG_USB_CYTHERM=y
# CONFIG_USB_IDMOUSE is not set
CONFIG_USB_FTDI_ELAN=y
CONFIG_USB_APPLEDISPLAY=y
# CONFIG_USB_SISUSBVGA is not set
CONFIG_USB_LD=y
# CONFIG_USB_TRANCEVIBRATOR is not set
# CONFIG_USB_IOWARRIOR is not set
CONFIG_USB_TEST=y
CONFIG_USB_EHSET_TEST_FIXTURE=y
CONFIG_USB_ISIGHTFW=y
# CONFIG_USB_YUREX is not set
CONFIG_USB_EZUSB_FX2=y
CONFIG_USB_HSIC_USB3503=y
CONFIG_USB_LINK_LAYER_TEST=y
CONFIG_USB_CHAOSKEY=y
CONFIG_UCSI=y

#
# USB Physical Layer drivers
#
CONFIG_USB_PHY=y
CONFIG_NOP_USB_XCEIV=y
CONFIG_USB_GPIO_VBUS=y
CONFIG_TAHVO_USB=y
CONFIG_TAHVO_USB_HOST_BY_DEFAULT=y
# CONFIG_USB_ISP1301 is not set
CONFIG_USB_GADGET=y
CONFIG_USB_GADGET_DEBUG=y
CONFIG_USB_GADGET_VERBOSE=y
# CONFIG_USB_GADGET_DEBUG_FILES is not set
# CONFIG_USB_GADGET_DEBUG_FS is not set
CONFIG_USB_GADGET_VBUS_DRAW=2
CONFIG_USB_GADGET_STORAGE_NUM_BUFFERS=2

#
# USB Peripheral Controller
#
CONFIG_USB_FOTG210_UDC=y
CONFIG_USB_GR_UDC=y
CONFIG_USB_R8A66597=y
CONFIG_USB_PXA27X=y
CONFIG_USB_MV_UDC=y
# CONFIG_USB_MV_U3D is not set
CONFIG_USB_M66592=y
CONFIG_USB_BDC_UDC=y

#
# Platform Support
#
# CONFIG_USB_BDC_PCI is not set
CONFIG_USB_AMD5536UDC=y
CONFIG_USB_NET2272=y
# CONFIG_USB_NET2272_DMA is not set
CONFIG_USB_NET2280=y
CONFIG_USB_GOKU=y
CONFIG_USB_EG20T=y
CONFIG_USB_GADGET_XILINX=y
# CONFIG_USB_DUMMY_HCD is not set
# CONFIG_USB_CONFIGFS is not set
# CONFIG_USB_ZERO is not set
# CONFIG_USB_ETH is not set
# CONFIG_USB_G_NCM is not set
CONFIG_USB_GADGETFS=y
# CONFIG_USB_FUNCTIONFS is not set
# CONFIG_USB_MASS_STORAGE is not set
# CONFIG_USB_G_SERIAL is not set
# CONFIG_USB_G_PRINTER is not set
# CONFIG_USB_CDC_COMPOSITE is not set
# CONFIG_USB_G_ACM_MS is not set
# CONFIG_USB_G_MULTI is not set
# CONFIG_USB_G_HID is not set
# CONFIG_USB_G_DBGP is not set
# CONFIG_USB_G_WEBCAM is not set
CONFIG_USB_LED_TRIG=y
# CONFIG_UWB is not set
# CONFIG_MMC is not set
CONFIG_MEMSTICK=y
# CONFIG_MEMSTICK_DEBUG is not set

#
# MemoryStick drivers
#
CONFIG_MEMSTICK_UNSAFE_RESUME=y
# CONFIG_MSPRO_BLOCK is not set
# CONFIG_MS_BLOCK is not set

#
# MemoryStick Host Controller Drivers
#
CONFIG_MEMSTICK_TIFM_MS=y
CONFIG_MEMSTICK_JMICRON_38X=y
# CONFIG_MEMSTICK_R592 is not set
CONFIG_MEMSTICK_REALTEK_PCI=y
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y
CONFIG_LEDS_CLASS_FLASH=y

#
# LED drivers
#
# CONFIG_LEDS_BCM6328 is not set
CONFIG_LEDS_BCM6358=y
# CONFIG_LEDS_LM3530 is not set
CONFIG_LEDS_LM3533=y
# CONFIG_LEDS_LM3642 is not set
CONFIG_LEDS_PCA9532=y
CONFIG_LEDS_PCA9532_GPIO=y
CONFIG_LEDS_GPIO=y
CONFIG_LEDS_LP3944=y
# CONFIG_LEDS_LP3952 is not set
CONFIG_LEDS_LP55XX_COMMON=y
# CONFIG_LEDS_LP5521 is not set
CONFIG_LEDS_LP5523=y
CONFIG_LEDS_LP5562=y
CONFIG_LEDS_LP8501=y
# CONFIG_LEDS_LP8860 is not set
CONFIG_LEDS_CLEVO_MAIL=y
CONFIG_LEDS_PCA955X=y
CONFIG_LEDS_PCA963X=y
CONFIG_LEDS_WM831X_STATUS=y
# CONFIG_LEDS_DA903X is not set
# CONFIG_LEDS_PWM is not set
CONFIG_LEDS_REGULATOR=y
CONFIG_LEDS_BD2802=y
# CONFIG_LEDS_INTEL_SS4200 is not set
CONFIG_LEDS_LT3593=y
CONFIG_LEDS_TCA6507=y
# CONFIG_LEDS_TLC591XX is not set
CONFIG_LEDS_MAX77693=y
CONFIG_LEDS_MAX8997=y
CONFIG_LEDS_LM355x=y
CONFIG_LEDS_KTD2692=y
# CONFIG_LEDS_IS31FL32XX is not set

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
# CONFIG_LEDS_BLINKM is not set
CONFIG_LEDS_SYSCON=y

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
CONFIG_LEDS_TRIGGER_TIMER=y
# CONFIG_LEDS_TRIGGER_ONESHOT is not set
CONFIG_LEDS_TRIGGER_HEARTBEAT=y
CONFIG_LEDS_TRIGGER_BACKLIGHT=y
CONFIG_LEDS_TRIGGER_CPU=y
CONFIG_LEDS_TRIGGER_GPIO=y
# CONFIG_LEDS_TRIGGER_DEFAULT_ON is not set

#
# iptables trigger is under Netfilter config (LED target)
#
CONFIG_LEDS_TRIGGER_TRANSIENT=y
CONFIG_LEDS_TRIGGER_CAMERA=y
CONFIG_LEDS_TRIGGER_PANIC=y
CONFIG_ACCESSIBILITY=y
CONFIG_EDAC_ATOMIC_SCRUB=y
CONFIG_EDAC_SUPPORT=y
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
# CONFIG_RTC_HCTOSYS is not set
CONFIG_RTC_SYSTOHC=y
CONFIG_RTC_SYSTOHC_DEVICE="rtc0"
CONFIG_RTC_DEBUG=y

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=y
CONFIG_RTC_INTF_PROC=y
CONFIG_RTC_INTF_DEV=y
CONFIG_RTC_INTF_DEV_UIE_EMUL=y
CONFIG_RTC_DRV_TEST=y

#
# I2C RTC drivers
#
CONFIG_RTC_DRV_88PM80X=y
# CONFIG_RTC_DRV_ABB5ZES3 is not set
# CONFIG_RTC_DRV_ABX80X is not set
CONFIG_RTC_DRV_AS3722=y
CONFIG_RTC_DRV_DS1307=y
# CONFIG_RTC_DRV_DS1307_HWMON is not set
CONFIG_RTC_DRV_DS1374=y
CONFIG_RTC_DRV_DS1374_WDT=y
CONFIG_RTC_DRV_DS1672=y
CONFIG_RTC_DRV_HYM8563=y
CONFIG_RTC_DRV_MAX6900=y
CONFIG_RTC_DRV_MAX8907=y
# CONFIG_RTC_DRV_MAX8997 is not set
# CONFIG_RTC_DRV_MAX77686 is not set
# CONFIG_RTC_DRV_RS5C372 is not set
CONFIG_RTC_DRV_ISL1208=y
CONFIG_RTC_DRV_ISL12022=y
# CONFIG_RTC_DRV_ISL12057 is not set
CONFIG_RTC_DRV_X1205=y
CONFIG_RTC_DRV_PCF8523=y
CONFIG_RTC_DRV_PCF85063=y
CONFIG_RTC_DRV_PCF8563=y
CONFIG_RTC_DRV_PCF8583=y
CONFIG_RTC_DRV_M41T80=y
# CONFIG_RTC_DRV_M41T80_WDT is not set
# CONFIG_RTC_DRV_BQ32K is not set
CONFIG_RTC_DRV_PALMAS=y
CONFIG_RTC_DRV_S35390A=y
# CONFIG_RTC_DRV_FM3130 is not set
CONFIG_RTC_DRV_RX8010=y
# CONFIG_RTC_DRV_RX8581 is not set
# CONFIG_RTC_DRV_RX8025 is not set
CONFIG_RTC_DRV_EM3027=y
# CONFIG_RTC_DRV_RV8803 is not set

#
# SPI RTC drivers
#
CONFIG_RTC_I2C_AND_SPI=y

#
# SPI and I2C RTC drivers
#
# CONFIG_RTC_DRV_DS3232 is not set
CONFIG_RTC_DRV_PCF2127=y
CONFIG_RTC_DRV_RV3029C2=y
# CONFIG_RTC_DRV_RV3029_HWMON is not set

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
CONFIG_RTC_DRV_DS1286=y
# CONFIG_RTC_DRV_DS1511 is not set
CONFIG_RTC_DRV_DS1553=y
CONFIG_RTC_DRV_DS1685_FAMILY=y
CONFIG_RTC_DRV_DS1685=y
# CONFIG_RTC_DRV_DS1689 is not set
# CONFIG_RTC_DRV_DS17285 is not set
# CONFIG_RTC_DRV_DS17485 is not set
# CONFIG_RTC_DRV_DS17885 is not set
# CONFIG_RTC_DS1685_PROC_REGS is not set
# CONFIG_RTC_DS1685_SYSFS_REGS is not set
CONFIG_RTC_DRV_DS1742=y
# CONFIG_RTC_DRV_DS2404 is not set
CONFIG_RTC_DRV_DA9063=y
CONFIG_RTC_DRV_STK17TA8=y
CONFIG_RTC_DRV_M48T86=y
CONFIG_RTC_DRV_M48T35=y
CONFIG_RTC_DRV_M48T59=y
# CONFIG_RTC_DRV_MSM6242 is not set
CONFIG_RTC_DRV_BQ4802=y
CONFIG_RTC_DRV_RP5C01=y
CONFIG_RTC_DRV_V3020=y
CONFIG_RTC_DRV_WM831X=y
# CONFIG_RTC_DRV_PCF50633 is not set
CONFIG_RTC_DRV_ZYNQMP=y

#
# on-CPU RTC drivers
#
CONFIG_RTC_DRV_SNVS=y
CONFIG_RTC_DRV_MT6397=y

#
# HID Sensor RTC drivers
#
# CONFIG_RTC_DRV_HID_SENSOR_TIME is not set
# CONFIG_DMADEVICES is not set

#
# DMABUF options
#
CONFIG_SYNC_FILE=y
# CONFIG_AUXDISPLAY is not set
CONFIG_UIO=y
CONFIG_UIO_CIF=y
CONFIG_UIO_PDRV_GENIRQ=y
# CONFIG_UIO_DMEM_GENIRQ is not set
CONFIG_UIO_AEC=y
# CONFIG_UIO_SERCOS3 is not set
CONFIG_UIO_PCI_GENERIC=y
CONFIG_UIO_NETX=y
# CONFIG_UIO_PRUSS is not set
CONFIG_UIO_MF624=y
# CONFIG_VIRT_DRIVERS is not set
CONFIG_VIRTIO=y

#
# Virtio drivers
#
CONFIG_VIRTIO_PCI=y
CONFIG_VIRTIO_PCI_LEGACY=y
CONFIG_VIRTIO_BALLOON=y
CONFIG_VIRTIO_INPUT=y
CONFIG_VIRTIO_MMIO=y
# CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES is not set

#
# Microsoft Hyper-V guest support
#
CONFIG_HYPERV=y
CONFIG_HYPERV_BALLOON=y
CONFIG_STAGING=y
# CONFIG_SLICOSS is not set
CONFIG_RTS5208=y

#
# IIO staging drivers
#

#
# Accelerometers
#

#
# Analog to digital converters
#
# CONFIG_AD7606 is not set

#
# Analog digital bi-direction converters
#
CONFIG_ADT7316=y
# CONFIG_ADT7316_I2C is not set

#
# Capacitance to digital converters
#
CONFIG_AD7150=y
# CONFIG_AD7152 is not set
# CONFIG_AD7746 is not set

#
# Direct Digital Synthesis
#

#
# Digital gyroscope sensors
#

#
# Network Analyzer, Impedance Converters
#
CONFIG_AD5933=y

#
# Light sensors
#
# CONFIG_SENSORS_ISL29018 is not set
CONFIG_SENSORS_ISL29028=y
# CONFIG_TSL2583 is not set
CONFIG_TSL2x7x=y

#
# Active energy metering IC
#
CONFIG_ADE7854=y
CONFIG_ADE7854_I2C=y

#
# Resolver to digital converters
#

#
# Triggers - standalone
#
CONFIG_FB_SM750=y
CONFIG_FB_XGI=y

#
# Speakup console speech
#
CONFIG_STAGING_MEDIA=y
CONFIG_I2C_BCM2048=y
# CONFIG_MEDIA_CEC is not set
CONFIG_DVB_CXD2099=y
# CONFIG_VIDEO_TW686X_KH is not set

#
# Android
#
CONFIG_ASHMEM=y
# CONFIG_ANDROID_LOW_MEMORY_KILLER is not set
# CONFIG_SW_SYNC is not set
# CONFIG_ION is not set
# CONFIG_STAGING_BOARD is not set
# CONFIG_DGNC is not set
CONFIG_GS_FPGABOOT=y
# CONFIG_CRYPTO_SKEIN is not set
# CONFIG_UNISYSSPAR is not set
CONFIG_COMMON_CLK_XLNX_CLKWZRD=y
# CONFIG_MOST is not set
# CONFIG_X86_PLATFORM_DEVICES is not set
CONFIG_CHROME_PLATFORMS=y
# CONFIG_CHROMEOS_LAPTOP is not set
CONFIG_CHROMEOS_PSTORE=y
# CONFIG_CROS_EC_CHARDEV is not set
CONFIG_CROS_EC_LPC=y
CONFIG_CROS_EC_PROTO=y
CONFIG_CROS_KBD_LED_BACKLIGHT=y
CONFIG_CLKDEV_LOOKUP=y
CONFIG_HAVE_CLK_PREPARE=y
CONFIG_COMMON_CLK=y

#
# Common Clock Framework
#
CONFIG_COMMON_CLK_WM831X=y
# CONFIG_COMMON_CLK_MAX77686 is not set
# CONFIG_COMMON_CLK_MAX77802 is not set
# CONFIG_COMMON_CLK_SI5351 is not set
# CONFIG_COMMON_CLK_SI514 is not set
CONFIG_COMMON_CLK_SI570=y
# CONFIG_COMMON_CLK_CDCE706 is not set
# CONFIG_COMMON_CLK_CDCE925 is not set
CONFIG_COMMON_CLK_CS2000_CP=y
# CONFIG_CLK_TWL6040 is not set
# CONFIG_COMMON_CLK_NXP is not set
CONFIG_COMMON_CLK_PALMAS=y
CONFIG_COMMON_CLK_PWM=y
# CONFIG_COMMON_CLK_PXA is not set
# CONFIG_COMMON_CLK_PIC32 is not set
# CONFIG_COMMON_CLK_OXNAS is not set

#
# Hardware Spinlock drivers
#

#
# Clock Source drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_CLKBLD_I8253=y
# CONFIG_ATMEL_PIT is not set
# CONFIG_SH_TIMER_CMT is not set
# CONFIG_SH_TIMER_MTU2 is not set
# CONFIG_SH_TIMER_TMU is not set
# CONFIG_EM_TIMER_STI is not set
# CONFIG_MAILBOX is not set
# CONFIG_IOMMU_SUPPORT is not set

#
# Remoteproc drivers
#
# CONFIG_STE_MODEM_RPROC is not set

#
# Rpmsg drivers
#

#
# SOC (System On Chip) specific Drivers
#
# CONFIG_SUNXI_SRAM is not set
# CONFIG_SOC_TI is not set
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND=y
CONFIG_DEVFREQ_GOV_PERFORMANCE=y
CONFIG_DEVFREQ_GOV_POWERSAVE=y
CONFIG_DEVFREQ_GOV_USERSPACE=y
CONFIG_DEVFREQ_GOV_PASSIVE=y

#
# DEVFREQ Drivers
#
CONFIG_PM_DEVFREQ_EVENT=y
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
CONFIG_EXTCON_ADC_JACK=y
# CONFIG_EXTCON_AXP288 is not set
# CONFIG_EXTCON_GPIO is not set
# CONFIG_EXTCON_MAX3355 is not set
CONFIG_EXTCON_MAX77693=y
CONFIG_EXTCON_MAX8997=y
CONFIG_EXTCON_PALMAS=y
CONFIG_EXTCON_RT8973A=y
CONFIG_EXTCON_SM5502=y
CONFIG_EXTCON_USB_GPIO=y
# CONFIG_MEMORY is not set
CONFIG_IIO=y
CONFIG_IIO_BUFFER=y
CONFIG_IIO_BUFFER_CB=y
CONFIG_IIO_KFIFO_BUF=y
CONFIG_IIO_TRIGGERED_BUFFER=y
CONFIG_IIO_CONFIGFS=y
CONFIG_IIO_TRIGGER=y
CONFIG_IIO_CONSUMERS_PER_TRIGGER=2
CONFIG_IIO_SW_DEVICE=y
CONFIG_IIO_SW_TRIGGER=y

#
# Accelerometers
#
# CONFIG_BMA180 is not set
CONFIG_BMC150_ACCEL=y
CONFIG_BMC150_ACCEL_I2C=y
# CONFIG_IIO_ST_ACCEL_3AXIS is not set
# CONFIG_KXCJK1013 is not set
# CONFIG_MMA7455_I2C is not set
CONFIG_MMA7660=y
CONFIG_MMA8452=y
CONFIG_MMA9551_CORE=y
CONFIG_MMA9551=y
CONFIG_MMA9553=y
CONFIG_MXC4005=y
CONFIG_MXC6255=y
# CONFIG_STK8312 is not set
CONFIG_STK8BA50=y

#
# Analog to digital converters
#
# CONFIG_AD7291 is not set
# CONFIG_AD799X is not set
CONFIG_AXP288_ADC=y
# CONFIG_CC10001_ADC is not set
CONFIG_MAX1363=y
CONFIG_MCP3422=y
CONFIG_NAU7802=y
CONFIG_PALMAS_GPADC=y
CONFIG_QCOM_SPMI_IADC=y
CONFIG_QCOM_SPMI_VADC=y
CONFIG_TI_ADC081C=y
# CONFIG_TI_AM335X_ADC is not set
CONFIG_VF610_ADC=y
# CONFIG_VIPERBOARD_ADC is not set

#
# Amplifiers
#

#
# Chemical Sensors
#
CONFIG_ATLAS_PH_SENSOR=y
CONFIG_IAQCORE=y
CONFIG_VZ89X=y

#
# Hid Sensor IIO Common
#
CONFIG_IIO_MS_SENSORS_I2C=y

#
# SSP Sensor Common
#
CONFIG_IIO_ST_SENSORS_I2C=y
CONFIG_IIO_ST_SENSORS_CORE=y

#
# Digital to analog converters
#
CONFIG_AD5064=y
# CONFIG_AD5380 is not set
CONFIG_AD5446=y
# CONFIG_AD5593R is not set
# CONFIG_M62332 is not set
CONFIG_MAX517=y
CONFIG_MAX5821=y
# CONFIG_MCP4725 is not set
CONFIG_STX104=y
CONFIG_VF610_DAC=y

#
# IIO dummy driver
#
CONFIG_IIO_SIMPLE_DUMMY=y
# CONFIG_IIO_SIMPLE_DUMMY_EVENTS is not set
CONFIG_IIO_SIMPLE_DUMMY_BUFFER=y

#
# Frequency Synthesizers DDS/PLL
#

#
# Clock Generator/Distribution
#

#
# Phase-Locked Loop (PLL) frequency synthesizers
#

#
# Digital gyroscope sensors
#
# CONFIG_BMG160 is not set
# CONFIG_IIO_ST_GYRO_3AXIS is not set
CONFIG_ITG3200=y

#
# Health Sensors
#

#
# Heart Rate Monitors
#
CONFIG_AFE4404=y
# CONFIG_MAX30100 is not set

#
# Humidity sensors
#
CONFIG_AM2315=y
CONFIG_DHT11=y
# CONFIG_HDC100X is not set
CONFIG_HTU21=y
CONFIG_SI7005=y
# CONFIG_SI7020 is not set

#
# Inertial measurement units
#
# CONFIG_BMI160_I2C is not set
CONFIG_KMX61=y
CONFIG_INV_MPU6050_IIO=y
CONFIG_INV_MPU6050_I2C=y

#
# Light sensors
#
# CONFIG_ACPI_ALS is not set
CONFIG_ADJD_S311=y
CONFIG_AL3320A=y
# CONFIG_APDS9300 is not set
CONFIG_APDS9960=y
CONFIG_BH1750=y
CONFIG_BH1780=y
# CONFIG_CM32181 is not set
CONFIG_CM3232=y
# CONFIG_CM3323 is not set
CONFIG_CM36651=y
CONFIG_GP2AP020A00F=y
# CONFIG_ISL29125 is not set
CONFIG_JSA1212=y
# CONFIG_RPR0521 is not set
CONFIG_SENSORS_LM3533=y
# CONFIG_LTR501 is not set
# CONFIG_MAX44000 is not set
CONFIG_OPT3001=y
CONFIG_PA12203001=y
# CONFIG_STK3310 is not set
# CONFIG_TCS3414 is not set
# CONFIG_TCS3472 is not set
# CONFIG_SENSORS_TSL2563 is not set
CONFIG_TSL4531=y
CONFIG_US5182D=y
CONFIG_VCNL4000=y
CONFIG_VEML6070=y

#
# Magnetometer sensors
#
# CONFIG_AK8975 is not set
# CONFIG_AK09911 is not set
# CONFIG_BMC150_MAGN_I2C is not set
CONFIG_MAG3110=y
CONFIG_MMC35240=y
# CONFIG_IIO_ST_MAGN_3AXIS is not set
CONFIG_SENSORS_HMC5843=y
CONFIG_SENSORS_HMC5843_I2C=y

#
# Inclinometer sensors
#

#
# Triggers - standalone
#
# CONFIG_IIO_HRTIMER_TRIGGER is not set
CONFIG_IIO_INTERRUPT_TRIGGER=y
CONFIG_IIO_TIGHTLOOP_TRIGGER=y
# CONFIG_IIO_SYSFS_TRIGGER is not set

#
# Digital potentiometers
#
CONFIG_DS1803=y
CONFIG_MCP4531=y
CONFIG_TPL0102=y

#
# Pressure sensors
#
# CONFIG_BMP280 is not set
# CONFIG_HP03 is not set
CONFIG_MPL115=y
CONFIG_MPL115_I2C=y
# CONFIG_MPL3115 is not set
# CONFIG_MS5611 is not set
CONFIG_MS5637=y
CONFIG_IIO_ST_PRESS=y
CONFIG_IIO_ST_PRESS_I2C=y
CONFIG_T5403=y
# CONFIG_HP206C is not set

#
# Lightning sensors
#

#
# Proximity sensors
#
# CONFIG_LIDAR_LITE_V2 is not set
CONFIG_SX9500=y

#
# Temperature sensors
#
# CONFIG_MLX90614 is not set
CONFIG_TMP006=y
CONFIG_TSYS01=y
CONFIG_TSYS02D=y
CONFIG_NTB=y
CONFIG_NTB_AMD=y
CONFIG_NTB_INTEL=y
# CONFIG_NTB_PINGPONG is not set
CONFIG_NTB_TOOL=y
# CONFIG_NTB_PERF is not set
# CONFIG_NTB_TRANSPORT is not set
CONFIG_VME_BUS=y

#
# VME Bridge Drivers
#
CONFIG_VME_CA91CX42=y
CONFIG_VME_TSI148=y

#
# VME Board Drivers
#
# CONFIG_VMIVME_7805 is not set

#
# VME Device Drivers
#
# CONFIG_VME_USER is not set
CONFIG_VME_PIO2=y
CONFIG_PWM=y
CONFIG_PWM_SYSFS=y
CONFIG_PWM_FSL_FTM=y
# CONFIG_PWM_LP3943 is not set
CONFIG_PWM_LPSS=y
CONFIG_PWM_LPSS_PCI=y
CONFIG_PWM_LPSS_PLATFORM=y
CONFIG_PWM_PCA9685=y
CONFIG_IRQCHIP=y
CONFIG_ARM_GIC_MAX_NR=1
CONFIG_IPACK_BUS=y
# CONFIG_BOARD_TPCI200 is not set
# CONFIG_SERIAL_IPOCTAL is not set
CONFIG_RESET_CONTROLLER=y
# CONFIG_FMC is not set

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
CONFIG_PHY_PXA_28NM_HSIC=y
# CONFIG_PHY_PXA_28NM_USB2 is not set
# CONFIG_BCM_KONA_USB2_PHY is not set
CONFIG_PHY_TUSB1210=y
# CONFIG_POWERCAP is not set
# CONFIG_MCB is not set

#
# Performance monitor support
#
CONFIG_RAS=y
# CONFIG_THUNDERBOLT is not set

#
# Android
#
CONFIG_ANDROID=y
# CONFIG_ANDROID_BINDER_IPC is not set
CONFIG_LIBNVDIMM=y
# CONFIG_BLK_DEV_PMEM is not set
CONFIG_ND_BLK=y
# CONFIG_BTT is not set
CONFIG_DEV_DAX=y
CONFIG_NVMEM=y
CONFIG_STM=y
CONFIG_STM_DUMMY=y
# CONFIG_STM_SOURCE_CONSOLE is not set
# CONFIG_STM_SOURCE_HEARTBEAT is not set
# CONFIG_INTEL_TH is not set

#
# FPGA Configuration Support
#
CONFIG_FPGA=y
# CONFIG_FPGA_MGR_ZYNQ_FPGA is not set

#
# Firmware Drivers
#
CONFIG_EDD=y
CONFIG_EDD_OFF=y
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_DELL_RBU=y
CONFIG_DCDBAS=y
CONFIG_DMIID=y
CONFIG_DMI_SYSFS=y
CONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK=y
# CONFIG_ISCSI_IBFT_FIND is not set
CONFIG_FW_CFG_SYSFS=y
# CONFIG_FW_CFG_SYSFS_CMDLINE is not set
CONFIG_GOOGLE_FIRMWARE=y

#
# Google Firmware Drivers
#
# CONFIG_GOOGLE_MEMCONSOLE is not set

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_FS_IOMAP=y
CONFIG_EXT2_FS=y
CONFIG_EXT2_FS_XATTR=y
CONFIG_EXT2_FS_POSIX_ACL=y
CONFIG_EXT2_FS_SECURITY=y
# CONFIG_EXT3_FS is not set
# CONFIG_EXT4_FS is not set
CONFIG_FS_MBCACHE=y
CONFIG_REISERFS_FS=y
# CONFIG_REISERFS_CHECK is not set
# CONFIG_REISERFS_PROC_INFO is not set
# CONFIG_REISERFS_FS_XATTR is not set
# CONFIG_JFS_FS is not set
CONFIG_XFS_FS=y
CONFIG_XFS_QUOTA=y
# CONFIG_XFS_POSIX_ACL is not set
CONFIG_XFS_RT=y
CONFIG_XFS_WARN=y
# CONFIG_XFS_DEBUG is not set
CONFIG_GFS2_FS=y
# CONFIG_OCFS2_FS is not set
CONFIG_BTRFS_FS=y
# CONFIG_BTRFS_FS_POSIX_ACL is not set
CONFIG_BTRFS_FS_CHECK_INTEGRITY=y
# CONFIG_BTRFS_FS_RUN_SANITY_TESTS is not set
CONFIG_BTRFS_DEBUG=y
CONFIG_BTRFS_ASSERT=y
# CONFIG_NILFS2_FS is not set
CONFIG_F2FS_FS=y
CONFIG_F2FS_STAT_FS=y
# CONFIG_F2FS_FS_XATTR is not set
CONFIG_F2FS_CHECK_FS=y
CONFIG_F2FS_FAULT_INJECTION=y
# CONFIG_FS_DAX is not set
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_FILE_LOCKING=y
# CONFIG_MANDATORY_FILE_LOCKING is not set
CONFIG_FS_ENCRYPTION=y
CONFIG_FSNOTIFY=y
# CONFIG_DNOTIFY is not set
CONFIG_INOTIFY_USER=y
CONFIG_FANOTIFY=y
CONFIG_FANOTIFY_ACCESS_PERMISSIONS=y
# CONFIG_QUOTA is not set
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
CONFIG_QUOTACTL=y
CONFIG_QUOTACTL_COMPAT=y
CONFIG_AUTOFS4_FS=y
CONFIG_FUSE_FS=y
CONFIG_CUSE=y
CONFIG_OVERLAY_FS=y

#
# Caches
#
# CONFIG_FSCACHE is not set

#
# CD-ROM/DVD Filesystems
#
# CONFIG_ISO9660_FS is not set
CONFIG_UDF_FS=y
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=y
CONFIG_VFAT_FS=y
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
CONFIG_FAT_DEFAULT_UTF8=y
# CONFIG_NTFS_FS is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
# CONFIG_PROC_KCORE is not set
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_PROC_CHILDREN=y
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
# CONFIG_TMPFS_POSIX_ACL is not set
CONFIG_TMPFS_XATTR=y
# CONFIG_HUGETLBFS is not set
# CONFIG_HUGETLB_PAGE is not set
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
CONFIG_ORANGEFS_FS=y
CONFIG_ADFS_FS=y
CONFIG_ADFS_FS_RW=y
CONFIG_AFFS_FS=y
CONFIG_ECRYPT_FS=y
CONFIG_ECRYPT_FS_MESSAGING=y
# CONFIG_HFS_FS is not set
CONFIG_HFSPLUS_FS=y
CONFIG_HFSPLUS_FS_POSIX_ACL=y
# CONFIG_BEFS_FS is not set
CONFIG_BFS_FS=y
CONFIG_EFS_FS=y
# CONFIG_LOGFS is not set
CONFIG_CRAMFS=y
CONFIG_SQUASHFS=y
# CONFIG_SQUASHFS_FILE_CACHE is not set
CONFIG_SQUASHFS_FILE_DIRECT=y
# CONFIG_SQUASHFS_DECOMP_SINGLE is not set
# CONFIG_SQUASHFS_DECOMP_MULTI is not set
CONFIG_SQUASHFS_DECOMP_MULTI_PERCPU=y
# CONFIG_SQUASHFS_XATTR is not set
# CONFIG_SQUASHFS_ZLIB is not set
# CONFIG_SQUASHFS_LZ4 is not set
# CONFIG_SQUASHFS_LZO is not set
# CONFIG_SQUASHFS_XZ is not set
# CONFIG_SQUASHFS_4K_DEVBLK_SIZE is not set
CONFIG_SQUASHFS_EMBEDDED=y
CONFIG_SQUASHFS_FRAGMENT_CACHE_SIZE=3
CONFIG_VXFS_FS=y
# CONFIG_MINIX_FS is not set
CONFIG_OMFS_FS=y
# CONFIG_HPFS_FS is not set
CONFIG_QNX4FS_FS=y
CONFIG_QNX6FS_FS=y
CONFIG_QNX6FS_DEBUG=y
CONFIG_ROMFS_FS=y
CONFIG_ROMFS_BACKED_BY_BLOCK=y
CONFIG_ROMFS_ON_BLOCK=y
# CONFIG_PSTORE is not set
CONFIG_SYSV_FS=y
CONFIG_UFS_FS=y
# CONFIG_UFS_FS_WRITE is not set
CONFIG_UFS_DEBUG=y
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
# CONFIG_NLS_CODEPAGE_437 is not set
# CONFIG_NLS_CODEPAGE_737 is not set
CONFIG_NLS_CODEPAGE_775=y
CONFIG_NLS_CODEPAGE_850=y
CONFIG_NLS_CODEPAGE_852=y
# CONFIG_NLS_CODEPAGE_855 is not set
CONFIG_NLS_CODEPAGE_857=y
CONFIG_NLS_CODEPAGE_860=y
CONFIG_NLS_CODEPAGE_861=y
CONFIG_NLS_CODEPAGE_862=y
CONFIG_NLS_CODEPAGE_863=y
CONFIG_NLS_CODEPAGE_864=y
CONFIG_NLS_CODEPAGE_865=y
CONFIG_NLS_CODEPAGE_866=y
CONFIG_NLS_CODEPAGE_869=y
CONFIG_NLS_CODEPAGE_936=y
CONFIG_NLS_CODEPAGE_950=y
CONFIG_NLS_CODEPAGE_932=y
CONFIG_NLS_CODEPAGE_949=y
CONFIG_NLS_CODEPAGE_874=y
# CONFIG_NLS_ISO8859_8 is not set
CONFIG_NLS_CODEPAGE_1250=y
CONFIG_NLS_CODEPAGE_1251=y
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=y
CONFIG_NLS_ISO8859_2=y
CONFIG_NLS_ISO8859_3=y
CONFIG_NLS_ISO8859_4=y
CONFIG_NLS_ISO8859_5=y
# CONFIG_NLS_ISO8859_6 is not set
CONFIG_NLS_ISO8859_7=y
CONFIG_NLS_ISO8859_9=y
# CONFIG_NLS_ISO8859_13 is not set
CONFIG_NLS_ISO8859_14=y
CONFIG_NLS_ISO8859_15=y
CONFIG_NLS_KOI8_R=y
CONFIG_NLS_KOI8_U=y
# CONFIG_NLS_MAC_ROMAN is not set
# CONFIG_NLS_MAC_CELTIC is not set
CONFIG_NLS_MAC_CENTEURO=y
CONFIG_NLS_MAC_CROATIAN=y
CONFIG_NLS_MAC_CYRILLIC=y
CONFIG_NLS_MAC_GAELIC=y
CONFIG_NLS_MAC_GREEK=y
CONFIG_NLS_MAC_ICELAND=y
CONFIG_NLS_MAC_INUIT=y
CONFIG_NLS_MAC_ROMANIAN=y
# CONFIG_NLS_MAC_TURKISH is not set
CONFIG_NLS_UTF8=y

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_MESSAGE_LOGLEVEL_DEFAULT=4
# CONFIG_BOOT_PRINTK_DELAY is not set
# CONFIG_DYNAMIC_DEBUG is not set

#
# Compile-time checks and compiler options
#
# CONFIG_DEBUG_INFO is not set
CONFIG_ENABLE_WARN_DEPRECATED=y
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN=8192
# CONFIG_STRIP_ASM_SYMS is not set
CONFIG_READABLE_ASM=y
CONFIG_UNUSED_SYMBOLS=y
CONFIG_PAGE_OWNER=y
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
# CONFIG_DEBUG_SECTION_MISMATCH is not set
# CONFIG_SECTION_MISMATCH_WARN_ONLY is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
# CONFIG_STACK_VALIDATION is not set
CONFIG_DEBUG_FORCE_WEAK_PER_CPU=y
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_PAGE_EXTENSION=y
CONFIG_DEBUG_PAGEALLOC=y
CONFIG_DEBUG_PAGEALLOC_ENABLE_DEFAULT=y
# CONFIG_PAGE_POISONING is not set
CONFIG_DEBUG_OBJECTS=y
CONFIG_DEBUG_OBJECTS_SELFTEST=y
CONFIG_DEBUG_OBJECTS_FREE=y
# CONFIG_DEBUG_OBJECTS_TIMERS is not set
CONFIG_DEBUG_OBJECTS_WORK=y
CONFIG_DEBUG_OBJECTS_RCU_HEAD=y
# CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER is not set
CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
CONFIG_SLUB_STATS=y
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_STACK_USAGE=y
# CONFIG_DEBUG_VM is not set
# CONFIG_DEBUG_VIRTUAL is not set
# CONFIG_DEBUG_MEMORY_INIT is not set
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_HAVE_ARCH_KMEMCHECK=y
CONFIG_HAVE_ARCH_KASAN=y
CONFIG_KASAN=y
# CONFIG_KASAN_OUTLINE is not set
CONFIG_KASAN_INLINE=y
CONFIG_ARCH_HAS_KCOV=y
# CONFIG_KCOV is not set
# CONFIG_DEBUG_SHIRQ is not set

#
# Debug Lockups and Hangs
#
CONFIG_LOCKUP_DETECTOR=y
CONFIG_HARDLOCKUP_DETECTOR=y
# CONFIG_BOOTPARAM_HARDLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=0
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC=y
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=1
# CONFIG_DETECT_HUNG_TASK is not set
# CONFIG_WQ_WATCHDOG is not set
CONFIG_PANIC_ON_OOPS=y
CONFIG_PANIC_ON_OOPS_VALUE=1
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
# CONFIG_SCHED_INFO is not set
# CONFIG_SCHEDSTATS is not set
CONFIG_SCHED_STACK_END_CHECK=y
# CONFIG_DEBUG_TIMEKEEPING is not set
# CONFIG_TIMER_STATS is not set
CONFIG_DEBUG_PREEMPT=y

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
# CONFIG_DEBUG_RT_MUTEXES is not set
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_WW_MUTEX_SLOWPATH=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_PROVE_LOCKING=y
CONFIG_LOCKDEP=y
# CONFIG_LOCK_STAT is not set
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
# CONFIG_LOCK_TORTURE_TEST is not set
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_LIST=y
# CONFIG_DEBUG_PI_LIST is not set
CONFIG_DEBUG_SG=y
# CONFIG_DEBUG_NOTIFIERS is not set
CONFIG_DEBUG_CREDENTIALS=y

#
# RCU Debugging
#
CONFIG_PROVE_RCU=y
CONFIG_PROVE_RCU_REPEATEDLY=y
CONFIG_SPARSE_RCU_POINTER=y
CONFIG_TORTURE_TEST=y
CONFIG_RCU_PERF_TEST=y
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=21
CONFIG_RCU_TRACE=y
# CONFIG_RCU_EQS_DEBUG is not set
# CONFIG_DEBUG_WQ_FORCE_RR_CPU is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
CONFIG_NOTIFIER_ERROR_INJECTION=y
# CONFIG_NETDEV_NOTIFIER_ERROR_INJECT is not set
# CONFIG_FAULT_INJECTION is not set
# CONFIG_LATENCYTOP is not set
CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS=y
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_FENTRY=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACE_CLOCK=y
CONFIG_RING_BUFFER=y
CONFIG_RING_BUFFER_ALLOW_SWAP=y
CONFIG_TRACING_SUPPORT=y
# CONFIG_FTRACE is not set

#
# Runtime Testing
#
# CONFIG_LKDTM is not set
# CONFIG_TEST_LIST_SORT is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_RBTREE_TEST is not set
CONFIG_ATOMIC64_SELFTEST=y
CONFIG_TEST_HEXDUMP=y
CONFIG_TEST_STRING_HELPERS=y
CONFIG_TEST_KSTRTOX=y
# CONFIG_TEST_PRINTF is not set
# CONFIG_TEST_BITMAP is not set
# CONFIG_TEST_UUID is not set
# CONFIG_TEST_RHASHTABLE is not set
# CONFIG_TEST_HASH is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
CONFIG_BUILD_DOCSRC=y
# CONFIG_DMA_API_DEBUG is not set
CONFIG_TEST_FIRMWARE=y
# CONFIG_TEST_UDELAY is not set
# CONFIG_MEMTEST is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
CONFIG_UBSAN=y
# CONFIG_UBSAN_SANITIZE_ALL is not set
# CONFIG_UBSAN_ALIGNMENT is not set
CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
# CONFIG_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
CONFIG_EARLY_PRINTK_DBGP=y
CONFIG_X86_PTDUMP_CORE=y
CONFIG_X86_PTDUMP=y
CONFIG_DEBUG_RODATA_TEST=y
CONFIG_DEBUG_WX=y
CONFIG_DOUBLEFAULT=y
# CONFIG_DEBUG_TLBFLUSH is not set
# CONFIG_IOMMU_STRESS is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
CONFIG_IO_DELAY_0X80=y
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=0
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
# CONFIG_OPTIMIZE_INLINING is not set
# CONFIG_DEBUG_ENTRY is not set
# CONFIG_DEBUG_NMI_SELFTEST is not set
CONFIG_X86_DEBUG_FPU=y
CONFIG_PUNIT_ATOM_DEBUG=y

#
# Security options
#
CONFIG_KEYS=y
CONFIG_PERSISTENT_KEYRINGS=y
CONFIG_BIG_KEYS=y
# CONFIG_TRUSTED_KEYS is not set
CONFIG_ENCRYPTED_KEYS=y
CONFIG_KEY_DH_OPERATIONS=y
CONFIG_SECURITY_DMESG_RESTRICT=y
CONFIG_SECURITY=y
CONFIG_SECURITYFS=y
CONFIG_SECURITY_NETWORK=y
CONFIG_SECURITY_PATH=y
# CONFIG_SECURITY_TOMOYO is not set
# CONFIG_SECURITY_APPARMOR is not set
CONFIG_SECURITY_LOADPIN=y
CONFIG_SECURITY_LOADPIN_ENABLED=y
# CONFIG_SECURITY_YAMA is not set
CONFIG_INTEGRITY=y
# CONFIG_INTEGRITY_SIGNATURE is not set
# CONFIG_IMA is not set
CONFIG_EVM=y
CONFIG_EVM_ATTR_FSUUID=y
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_XOR_BLOCKS=y
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_RNG_DEFAULT=y
CONFIG_CRYPTO_AKCIPHER2=y
CONFIG_CRYPTO_AKCIPHER=y
CONFIG_CRYPTO_KPP2=y
CONFIG_CRYPTO_KPP=y
CONFIG_CRYPTO_RSA=y
CONFIG_CRYPTO_DH=y
CONFIG_CRYPTO_ECDH=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_NULL2=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_MCRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_ABLK_HELPER=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
CONFIG_CRYPTO_GCM=y
CONFIG_CRYPTO_CHACHA20POLY1305=y
CONFIG_CRYPTO_SEQIV=y
CONFIG_CRYPTO_ECHAINIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
# CONFIG_CRYPTO_PCBC is not set
CONFIG_CRYPTO_XTS=y
CONFIG_CRYPTO_KEYWRAP=y

#
# Hash modes
#
# CONFIG_CRYPTO_CMAC is not set
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=y
CONFIG_CRYPTO_VMAC=y

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=y
CONFIG_CRYPTO_CRC32=y
# CONFIG_CRYPTO_CRC32_PCLMUL is not set
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_CRCT10DIF_PCLMUL=y
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_POLY1305=y
# CONFIG_CRYPTO_POLY1305_X86_64 is not set
# CONFIG_CRYPTO_MD4 is not set
CONFIG_CRYPTO_MD5=y
# CONFIG_CRYPTO_MICHAEL_MIC is not set
CONFIG_CRYPTO_RMD128=y
CONFIG_CRYPTO_RMD160=y
# CONFIG_CRYPTO_RMD256 is not set
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_SSSE3=y
# CONFIG_CRYPTO_SHA256_SSSE3 is not set
CONFIG_CRYPTO_SHA512_SSSE3=y
CONFIG_CRYPTO_SHA1_MB=y
# CONFIG_CRYPTO_SHA256_MB is not set
CONFIG_CRYPTO_SHA512_MB=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_SHA3=y
# CONFIG_CRYPTO_TGR192 is not set
# CONFIG_CRYPTO_WP512 is not set
CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_X86_64=y
# CONFIG_CRYPTO_AES_NI_INTEL is not set
CONFIG_CRYPTO_ANUBIS=y
CONFIG_CRYPTO_ARC4=y
CONFIG_CRYPTO_BLOWFISH=y
CONFIG_CRYPTO_BLOWFISH_COMMON=y
# CONFIG_CRYPTO_BLOWFISH_X86_64 is not set
# CONFIG_CRYPTO_CAMELLIA is not set
CONFIG_CRYPTO_CAMELLIA_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64=y
# CONFIG_CRYPTO_CAST5 is not set
# CONFIG_CRYPTO_CAST5_AVX_X86_64 is not set
# CONFIG_CRYPTO_CAST6 is not set
# CONFIG_CRYPTO_CAST6_AVX_X86_64 is not set
CONFIG_CRYPTO_DES=y
CONFIG_CRYPTO_DES3_EDE_X86_64=y
CONFIG_CRYPTO_FCRYPT=y
CONFIG_CRYPTO_KHAZAD=y
# CONFIG_CRYPTO_SALSA20 is not set
CONFIG_CRYPTO_SALSA20_X86_64=y
CONFIG_CRYPTO_CHACHA20=y
CONFIG_CRYPTO_CHACHA20_X86_64=y
CONFIG_CRYPTO_SEED=y
CONFIG_CRYPTO_SERPENT=y
# CONFIG_CRYPTO_SERPENT_SSE2_X86_64 is not set
CONFIG_CRYPTO_SERPENT_AVX_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX2_X86_64=y
CONFIG_CRYPTO_TEA=y
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
# CONFIG_CRYPTO_TWOFISH_X86_64 is not set
# CONFIG_CRYPTO_TWOFISH_X86_64_3WAY is not set
# CONFIG_CRYPTO_TWOFISH_AVX_X86_64 is not set

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
CONFIG_CRYPTO_LZO=y
# CONFIG_CRYPTO_842 is not set
CONFIG_CRYPTO_LZ4=y
CONFIG_CRYPTO_LZ4HC=y

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=y
CONFIG_CRYPTO_DRBG_MENU=y
CONFIG_CRYPTO_DRBG_HMAC=y
# CONFIG_CRYPTO_DRBG_HASH is not set
# CONFIG_CRYPTO_DRBG_CTR is not set
CONFIG_CRYPTO_DRBG=y
CONFIG_CRYPTO_JITTERENTROPY=y
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
# CONFIG_CRYPTO_USER_API_RNG is not set
# CONFIG_CRYPTO_USER_API_AEAD is not set
CONFIG_CRYPTO_HW=y
CONFIG_CRYPTO_DEV_PADLOCK=y
CONFIG_CRYPTO_DEV_PADLOCK_AES=y
CONFIG_CRYPTO_DEV_PADLOCK_SHA=y
# CONFIG_CRYPTO_DEV_CCP is not set
CONFIG_CRYPTO_DEV_QAT=y
# CONFIG_CRYPTO_DEV_QAT_DH895xCC is not set
CONFIG_CRYPTO_DEV_QAT_C3XXX=y
CONFIG_CRYPTO_DEV_QAT_C62X=y
# CONFIG_CRYPTO_DEV_QAT_DH895xCCVF is not set
CONFIG_CRYPTO_DEV_QAT_C3XXXVF=y
CONFIG_CRYPTO_DEV_QAT_C62XVF=y
# CONFIG_ASYMMETRIC_KEY_TYPE is not set

#
# Certificates for signature checking
#
CONFIG_HAVE_KVM=y
CONFIG_VIRTUALIZATION=y
# CONFIG_BINARY_PRINTF is not set

#
# Library routines
#
CONFIG_RAID6_PQ=y
CONFIG_BITREVERSE=y
# CONFIG_HAVE_ARCH_BITREVERSE is not set
CONFIG_RATIONAL=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_ARCH_USE_CMPXCHG_LOCKREF=y
CONFIG_ARCH_HAS_FAST_MULTIPLIER=y
# CONFIG_CRC_CCITT is not set
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
CONFIG_CRC32_SELFTEST=y
CONFIG_CRC32_SLICEBY8=y
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
# CONFIG_CRC7 is not set
CONFIG_LIBCRC32C=y
CONFIG_CRC8=y
# CONFIG_AUDIT_ARCH_COMPAT_GENERIC is not set
# CONFIG_RANDOM32_SELFTEST is not set
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_COMPRESS=y
CONFIG_LZ4HC_COMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
CONFIG_XZ_DEC_POWERPC=y
CONFIG_XZ_DEC_IA64=y
CONFIG_XZ_DEC_ARM=y
CONFIG_XZ_DEC_ARMTHUMB=y
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
# CONFIG_XZ_DEC_TEST is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_INTERVAL_TREE=y
CONFIG_RADIX_TREE_MULTIORDER=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_CHECK_SIGNATURE=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
CONFIG_CLZ_TAB=y
# CONFIG_CORDIC is not set
CONFIG_DDR=y
# CONFIG_IRQ_POLL is not set
CONFIG_MPILIB=y
CONFIG_LIBFDT=y
# CONFIG_SG_SPLIT is not set
CONFIG_SG_POOL=y
CONFIG_ARCH_HAS_SG_CHAIN=y
CONFIG_ARCH_HAS_PMEM_API=y
CONFIG_ARCH_HAS_MMIO_FLUSH=y
CONFIG_STACKDEPOT=y

--tgxxsl4wajdjvchp--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
