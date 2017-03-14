Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B52E26B038A
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 22:07:22 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id g2so342972803pge.7
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 19:07:22 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id b82si13099009pfe.296.2017.03.13.19.07.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Mar 2017 19:07:15 -0700 (PDT)
Date: Tue, 14 Mar 2017 10:07:05 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [x86/kasan] 1771c6e1a5 BUG: KASAN: slab-out-of-bounds in memdup_user
 at addr ffff8800001f3940
Message-ID: <20170314020705.f5dvvd5rlfgzrgpg@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="yvfyjqxnpxlz5bhg"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, LKP <lkp@01.org>


--yvfyjqxnpxlz5bhg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Greetings,

0day kernel testing robot got the below dmesg and the first bad commit is

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master

commit 1771c6e1a567ea0ba2cccc0a4ffe68a1419fd8ef
Author:     Andrey Ryabinin <aryabinin@virtuozzo.com>
AuthorDate: Fri May 20 16:59:31 2016 -0700
Commit:     Linus Torvalds <torvalds@linux-foundation.org>
CommitDate: Fri May 20 17:58:30 2016 -0700

     x86/kasan: instrument user memory access API
     
     Exchange between user and kernel memory is coded in assembly language.
     Which means that such accesses won't be spotted by KASAN as a compiler
     instruments only C code.
     
     Add explicit KASAN checks to user memory access API to ensure that
     userspace writes to (or reads from) a valid kernel memory.
     
     Note: Unlike others strncpy_from_user() is written mostly in C and KASAN
     sees memory accesses in it.  However, it makes sense to add explicit
     check for all @count bytes that *potentially* could be written to the
     kernel.
     
     [aryabinin@virtuozzo.com: move kasan check under the condition]
       Link: http://lkml.kernel.org/r/1462869209-21096-1-git-send-email-aryabinin@virtuozzo.com
     Link: http://lkml.kernel.org/r/1462538722-1574-4-git-send-email-aryabinin@virtuozzo.com
     Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
     Cc: Alexander Potapenko <glider@google.com>
     Cc: Dmitry Vyukov <dvyukov@google.com>
     Cc: Ingo Molnar <mingo@elte.hu>
     Cc: "H. Peter Anvin" <hpa@zytor.com>
     Cc: Thomas Gleixner <tglx@linutronix.de>
     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

64f8ebaf11  mm/kasan: add API to check memory regions
1771c6e1a5  x86/kasan: instrument user memory access API
065f3e4951  Merge tag 'platform-drivers-x86-v4.11-2' of git://git.infradead.org/linux-platform-drivers-x86
5be4921c99  Add linux-next specific files for 20170310
+------------------------------------------------+------------+------------+------------+---------------+
|                                                | 64f8ebaf11 | 1771c6e1a5 | 065f3e4951 | next-20170310 |
+------------------------------------------------+------------+------------+------------+---------------+
| boot_successes                                 | 26         | 0          | 0          | 0             |
| boot_failures                                  | 18         | 11         | 11         | 25            |
| BUG:soft_lockup-CPU##stuck_for#s               | 18         |            |            |               |
| RIP:ptdump_walk_pgd_level_core                 | 9          |            |            |               |
| calltrace:mark_rodata_ro                       | 18         |            |            |               |
| Kernel_panic-not_syncing:softlockup:hung_tasks | 18         |            |            |               |
| RIP:note_page                                  | 9          |            |            |               |
| BUG:KASAN:slab-out-of-bounds                   | 0          | 11         | 11         | 25            |
| calltrace:SyS_mount                            | 0          | 11         |            |               |
| calltrace:devtmpfsd                            | 0          | 11         |            |               |
+------------------------------------------------+------------+------------+------------+---------------+

[    0.385456] x86: Booted up 1 node, 1 CPUs
[    0.386626] smpboot: Total of 1 processors activated (5387.01 BogoMIPS)
[    0.386626] smpboot: Total of 1 processors activated (5387.01 BogoMIPS)
[    0.391649] ==================================================================
[    0.391649] ==================================================================
[    0.393756] BUG: KASAN: slab-out-of-bounds in memdup_user+0x46/0x7c at addr ffff8800001f3940
[    0.393756] BUG: KASAN: slab-out-of-bounds in memdup_user+0x46/0x7c at addr ffff8800001f3940
[    0.396381] Write of size 9 by task kdevtmpfs/12
[    0.396381] Write of size 9 by task kdevtmpfs/12
[    0.397828] CPU: 0 PID: 12 Comm: kdevtmpfs Not tainted 4.6.0-06644-g1771c6e #1
[    0.397828] CPU: 0 PID: 12 Comm: kdevtmpfs Not tainted 4.6.0-06644-g1771c6e #1
[    0.400059] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.9.3-20161025_171302-gandalf 04/01/2014
[    0.400059] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.9.3-20161025_171302-gandalf 04/01/2014
[    0.402897]  0000000000000000
[    0.402897]  0000000000000000 ffff8800188d7d18 ffff8800188d7d18 ffffffff98de3224 ffffffff98de3224 ffff8800001f3940 ffff8800001f3940

[    0.405982]  ffffed000003e729
[    0.405982]  ffffed000003e729 ffff8800188d7da8 ffff8800188d7da8 ffffffff98d2c370 ffffffff98d2c370 ffff8800188d7d68 ffff8800188d7d68

[    0.408131]  ffff8800001f3960
[    0.408131]  ffff8800001f3960 00000000024000c0 00000000024000c0 0000000000000292 0000000000000292 ffff880000098a00 ffff880000098a00

[    0.410372] Call Trace:
[    0.410372] Call Trace:
[    0.411072]  [<ffffffff98de3224>] dump_stack+0x63/0x7f
[    0.411072]  [<ffffffff98de3224>] dump_stack+0x63/0x7f
[    0.412528]  [<ffffffff98d2c370>] kasan_report+0x2d0/0x51c
[    0.412528]  [<ffffffff98d2c370>] kasan_report+0x2d0/0x51c
[    0.414082]  [<ffffffff98d296c1>] ? __kmalloc_track_caller+0xf8/0x111
[    0.414082]  [<ffffffff98d296c1>] ? __kmalloc_track_caller+0xf8/0x111
[    0.415889]  [<ffffffff98d2b77d>] check_memory_region+0x10b/0x10d
[    0.415889]  [<ffffffff98d2b77d>] check_memory_region+0x10b/0x10d
[    0.417601]  [<ffffffff98d2b7b8>] kasan_check_write+0x14/0x16
[    0.417601]  [<ffffffff98d2b7b8>] kasan_check_write+0x14/0x16
[    0.419230]  [<ffffffff98d04a37>] memdup_user+0x46/0x7c
[    0.419230]  [<ffffffff98d04a37>] memdup_user+0x46/0x7c
[    0.420784]  [<ffffffff98d04aa4>] strndup_user+0x37/0x4d
[    0.420784]  [<ffffffff98d04aa4>] strndup_user+0x37/0x4d
[    0.422276]  [<ffffffff98d56da4>] copy_mount_string+0x15/0x17
[    0.422276]  [<ffffffff98d56da4>] copy_mount_string+0x15/0x17
[    0.423890]  [<ffffffff98d57a1d>] SyS_mount+0x23/0xa1
[    0.423890]  [<ffffffff98d57a1d>] SyS_mount+0x23/0xa1
[    0.425323]  [<ffffffff98eaf072>] ? handle_create+0x1e0/0x1e0
[    0.425323]  [<ffffffff98eaf072>] ? handle_create+0x1e0/0x1e0
[    0.427107]  [<ffffffff98eaf0c9>] devtmpfsd+0x57/0x14a
[    0.427107]  [<ffffffff98eaf0c9>] devtmpfsd+0x57/0x14a
[    0.428567]  [<ffffffff98c8cd30>] kthread+0xab/0xb3
[    0.428567]  [<ffffffff98c8cd30>] kthread+0xab/0xb3
[    0.429958]  [<ffffffff9904cc9f>] ret_from_fork+0x1f/0x40
[    0.429958]  [<ffffffff9904cc9f>] ret_from_fork+0x1f/0x40
[    0.431528]  [<ffffffff98c8cc85>] ? kthread_parkme+0x1f/0x1f
[    0.431528]  [<ffffffff98c8cc85>] ? kthread_parkme+0x1f/0x1f
[    0.433125] Object at ffff8800001f3940, in cache kmalloc-32
[    0.433125] Object at ffff8800001f3940, in cache kmalloc-32
[    0.434675] Object allocated with size 9 bytes.
[    0.434675] Object allocated with size 9 bytes.
[    0.435954] Allocation:
[    0.435954] Allocation:
[    0.436656] PID = 12
[    0.436656] PID = 12
[    0.437279]  
[    0.437279]  [<ffffffff98c2048f>] save_stack_trace+0x27/0x44
[<ffffffff98c2048f>] save_stack_trace+0x27/0x44
[    0.438894]  
[    0.438894]  [<ffffffff98d2b863>] save_stack+0x37/0xb0
[<ffffffff98d2b863>] save_stack+0x37/0xb0
[    0.440370]  
[    0.440370]  [<ffffffff98d2ba2d>] kasan_kmalloc+0xb8/0xca
[<ffffffff98d2ba2d>] kasan_kmalloc+0xb8/0xca
[    0.442128]  
[    0.442128]  [<ffffffff98d296c1>] __kmalloc_track_caller+0xf8/0x111
[<ffffffff98d296c1>] __kmalloc_track_caller+0xf8/0x111
[    0.444113]  
[    0.444113]  [<ffffffff98d04a13>] memdup_user+0x22/0x7c
[<ffffffff98d04a13>] memdup_user+0x22/0x7c
[    0.445760]  
[    0.445760]  [<ffffffff98d04aa4>] strndup_user+0x37/0x4d
[<ffffffff98d04aa4>] strndup_user+0x37/0x4d
[    0.447446]  
[    0.447446]  [<ffffffff98d56da4>] copy_mount_string+0x15/0x17
[<ffffffff98d56da4>] copy_mount_string+0x15/0x17
[    0.449278]  
[    0.449278]  [<ffffffff98d57a1d>] SyS_mount+0x23/0xa1
[<ffffffff98d57a1d>] SyS_mount+0x23/0xa1
[    0.450895]  
[    0.450895]  [<ffffffff98eaf0c9>] devtmpfsd+0x57/0x14a
[<ffffffff98eaf0c9>] devtmpfsd+0x57/0x14a
[    0.452548]  
[    0.452548]  [<ffffffff98c8cd30>] kthread+0xab/0xb3
[<ffffffff98c8cd30>] kthread+0xab/0xb3
[    0.453943]  
[    0.453943]  [<ffffffff9904cc9f>] ret_from_fork+0x1f/0x40
[<ffffffff9904cc9f>] ret_from_fork+0x1f/0x40
[    0.455479] Memory state around the buggy address:
[    0.455479] Memory state around the buggy address:
[    0.456831]  ffff8800001f3800: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
[    0.456831]  ffff8800001f3800: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
[    0.458861]  ffff8800001f3880: fc fc fc fc fc fc fc fc 00 fc fc fc fc fc fc fc

                                                          # HH:MM RESULT GOOD BAD GOOD_BUT_DIRTY DIRTY_NOT_BAD
git bisect start v4.7 v4.6 --
git bisect  bad 4340fa55298d17049e71c7a34e04647379c269f3  # 06:00  B      0    11   22   0  Merge tag 'for-linus' of git://git.kernel.org/pub/scm/virt/kvm/kvm
git bisect good 0eff4589c36edd03d50b835d0768b2c2ef3f20bd  # 06:15  G     11     0    1   1  Merge tag 'clk-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/clk/linux
git bisect  bad 0e77816e096c4ae27e98977fef56b6b9169f9017  # 06:23  B      0     4   15   0  Merge tag 'mmc-v4.7-rc1' of git://git.linaro.org/people/ulf.hansson/mmc
git bisect  bad 36b150bbcc1125abaad89963420a37ff70686d5a  # 06:35  B      0    11   22   0  Merge tag 'microblaze-4.7-rc1' of git://git.monstr.eu/linux-2.6-microblaze
git bisect  bad bd28b14591b98f696bc9f94c5ba2e598ca487dfd  # 06:45  B      0     8   20   1  x86: remove more uaccess_32.h complexity
git bisect  bad 5469dc270cd44c451590d40c031e6a71c1f637e8  # 06:58  B      0    11   22   0  Merge branch 'akpm' (patches from Andrew)
git bisect good 5af2344013454640e0133bb62e8cf2e30190a472  # 07:06  G     11     0   11  11  Merge tag 'char-misc-4.7-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/char-misc
git bisect good 3aa2fc1667acdd9cca816a2bc9529f494bd61b05  # 07:16  G     11     0    9   9  Merge tag 'driver-core-4.7-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/driver-core
git bisect good 2f37dd131c5d3a2eac21cd5baf80658b1b02a8ac  # 07:24  G     11     0    7   7  Merge tag 'staging-4.7-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging
git bisect  bad 42a0bb3f71383b457a7db362f1c69e7afb96732b  # 07:35  B      0     5   16   0  printk/nmi: generic solution for safe printk in NMI
git bisect good 7b8da4c7f0777489f8690115b5fd7704ac0abb8f  # 07:45  G     11     0    0   0  vmstat: get rid of the ugly cpu_stat_off variable
git bisect good 936bb4bbbb832f81055328b84e5afe1fc7246a8d  # 07:57  G     11     0    0   0  mm/kasan: print name of mem[set,cpy,move]() caller in report
git bisect  bad 200867af4dedfe7cb707f96773684de1d1fd21e6  # 08:05  B      0     5   16   0  mm/zswap: use workqueue to destroy pool
git bisect  bad 830e4bc5baa9fda5d45257e9a3dbb3555c6c180e  # 08:32  B      0     1   12   0  zsmalloc: clean up many BUG_ON
git bisect  bad 1771c6e1a567ea0ba2cccc0a4ffe68a1419fd8ef  # 08:46  B      0     2   13   0  x86/kasan: instrument user memory access API
git bisect good 64f8ebaf115bcddc4aaa902f981c57ba6506bc42  # 09:01  G     10     0   10  10  mm/kasan: add API to check memory regions
# first bad commit: [1771c6e1a567ea0ba2cccc0a4ffe68a1419fd8ef] x86/kasan: instrument user memory access API
git bisect good 64f8ebaf115bcddc4aaa902f981c57ba6506bc42  # 09:10  G     30     0    8  18  mm/kasan: add API to check memory regions
# extra tests with CONFIG_DEBUG_INFO_REDUCED
git bisect  bad 1771c6e1a567ea0ba2cccc0a4ffe68a1419fd8ef  # 09:17  B      0     1   12   0  x86/kasan: instrument user memory access API
# extra tests on HEAD of linux-devel/devel-catchup-201703140350
git bisect  bad 702bbfb9a586a1f445aec794f66d4a625a19b6bf  # 09:22  B      0    13   27   0  0day head guard for 'devel-catchup-201703140350'
# extra tests on tree/branch linus/master
git bisect  bad 065f3e4951f11701729ad310ca0b610f61d91e2a  # 09:33  B      0     1   12   0  Merge tag 'platform-drivers-x86-v4.11-2' of git://git.infradead.org/linux-platform-drivers-x86
# extra tests on tree/branch linux-next/master
git bisect  bad 5be4921c9958ec02a67506bd6f7a52fce663c201  # 09:38  B      0    25   36   0  Add linux-next specific files for 20170310

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/lkp                          Intel Corporation

--yvfyjqxnpxlz5bhg
Content-Type: application/gzip
Content-Disposition: attachment; filename="dmesg-yocto-kbuild-51:20170314084603:x86_64-randconfig-in0-03140242:4.6.0-06644-g1771c6e:1.gz"
Content-Transfer-Encoding: base64

H4sICKtJx1gAA2RtZXNnLXlvY3RvLWtidWlsZC01MToyMDE3MDMxNDA4NDYwMzp4ODZfNjQt
cmFuZGNvbmZpZy1pbjAtMDMxNDAyNDI6NC42LjAtMDY2NDQtZzE3NzFjNmU6MQDsXVtv47iS
ft78CgLzMMme2CF1l7GePbl2G2mnPXF6prGNhkBLlKOJLPlIspPMr98qSvJFsmMn7WwfLGxg
xhZZ9bF4qwtZSguehM/EjaM0DgUJIpKKbDKGAk8ciGqdeMoS7mbOg0giER4E0XiSOR7PeIvQ
J1p+FEaZYhpFdSiipVqq2YqvWAfxJIPqpSqWfxVVNU7GmGf79CBv3cnijIdOGvwtlql0V4IM
4jgTHpkGnKQZT6BTjqocHh307p/TwOUhuT7tf7olkzSIhuT24q5/3mw2Dw4uhBuPxolIZfmn
IJo8QTnp8UQWXH66ko8i8eNkhCWJCGOXZwGMEtZ4cSSaB2fQOFZm94Lk4jYPvhH40GYu5fcc
mkwF4MYR0ZpGkzaoYWhaY8hMk7mGIIcPg0kQev90eZDER+Rw6LpLDBo5vBCDgBdPDfOIHJFf
GOl3e+RuIkiXJ4RphFotTWtRm5z374hCmVkV5TwejXjkkTCIYCwTkL194onpScJHlNxPoqGT
8fTBGfMocNuMeGIwGRI+hof8Z/qcJv9yePjIn1NHRHwQwsAn7mQMS0M04YfjjicOzEIIsxaM
BMxvG+aaRCJrBn7ERyJtUzJOgih7aELDD6N02IY+5g02GEljP4NRfoA5LIWIRoHzyDP33ouH
bVlI4nicFj/DmHsOiO8F6UNbAWiY02xWQImXDLwmTF+cOG48ibK2hZ3IxMhrhvEQVt5UhG2R
JCQYAo1woFCWEbklcknbWfbcp8eM6Qr0pdglawspmQ55G8BGsPSSRxzrh/ZJPsGNTKRZepJM
osa/JmIiTp5jN4sbeeXJk2U4htZIYIYAzw+GjSCCpaIyjSqachLiOmp4KF1L/r/h4rBMxg2c
akmm6rRVrCnGdcMUnA644sKHcs33hWFxpjHb9yzhtwZBKtyskcOaJ83pCH/+3dgWYN6spWmq
3mCstdidhs7IAPri3rcXJD9ZLzk5+/z5zul0Tz9ctk/GD8O8w5tGBbZKAzbFybZSn5TdXLkR
68uluoVAnBN/PGmRJ1jmmXBi3wdF+k353iJEN43jshzVVZoXK7qxFqU/GY/jRKqQr/3TPy6J
L3g2SYRUdKxFfn2yTOLDKpck4xjWIyiiYQBLOEl/fRusArD9/uUP42iAc/rH121wLgtdkQ9O
iZICjHmMmycDg0NwyEiQEktVyOAZtspxobR/Ba7I44n3K0FlzLOajp019CVnEHwokl/JVe/L
HP0xgDUn0hqvsBTaImedz/0GqI9p4IGc49J23J52yYiPW1UmSZ5zfhuJ0ZLdyz+NpSLbH/j+
d+gPjsOrwGzfrYP5CAYDKJKp8F4F59dl898Ox6pdZb7vMf8tXUVOpQb2Ztl84ePALcJh0Zvh
crQluI3SSaPZyk0LLsuZcQGNgXuqthTRlSm9sG/SAgEwLtF8+1TJb76Sw8sn4U5gS10EcryP
0ARmoNfBdWgRcOGCaW0O+l3sJ1GaFkH/R0T1/XTR7bTI75fdL6RfbD3SOyeHgabRq6/kH6TX
6Xw9Jsy2jaNjOWqENe2mivrcYFTRHWYylSqNITKHPqHaCWUnUKtVW/r4PIaxC9I4geFCwYXX
Itd/dFfv0tzTqE5OOSkL646027+tnZccKxGjeLqIxedYxcSuXsM5e8jTzBn7EWkDt1y8oCie
HJ6497NirZSwCtG9u72F/vp8EmYkgyFokcckyERjwN2HlcR+8IS+Fo+GoDaL9VDTSvBb9sG+
gs8LiIScSrozSTeJXO7er+opIeeS7moBr1hfK4Wc8iSQo79ZTjLgKZgRahUjBIOXPpCrq9nz
S1KBa5ov99rUgrV9oU59oU57oU5/oc54oc5cW4cGq3d61wKXHH2aSSIDC/KNNkxwGf48I+TP
c0K+nDfgP7L0/OcdIbUd7UJoAKZRBgQQvq3ZHyqs6e1ZFwxPbnC2Z10wMv5KVh+cK0/ydXuN
TC4Zni0CGAOjBICfsBXBCI9hAyAVIlr5OpF0NXRCRmO3RaDSpA3fcM2aF3eGiw9ai5NnApHu
aBxjSFRFt21JLL9y70TRwMergd1ew8Q9Mc7sARQck+K3VCG9D3enZ58uX+BxF3jcLXm8BR5v
Sx6xwCNe4gGf56LTv57ZQOa7rpFPKOg5d+WEnp73wGJcynOEfD7B13If0skIA9nAD/LIee1+
yPlv+xe9ZXflyrAtKrUaxLeHU4pRwvnHPjlaC3C36FNcXV0y6+JcAqgUAVgBQM6+9s5z8oJW
lsye1jRwBV/VBswzS7KZWq2BnPw1DVzUewCeNg4BxChWrYGLt/SgX2uA5mOs1QxVznPa65zX
hlXJm1ohVE7+GqE+9i7r83aq5fNWbyAnf00Dn2L05qVg3PPw1Aea84WQRFWWQtdI6iwm/uyj
+7jxyCEpPiVArdGbmNx86Z4Sd0m7S61XJb3iD+gbchLFXkULLn1WOdm1Zj9fXDoXp3enh/SI
8FCeV0FH5vuYFy4xbml9FcLDdNRw8QSmDKVGaZISbaAbmgdDjYdHxUNt1BZY3fGEgK4BXkJb
0JYCzbJjPPgZcdC4WC0pX4DII78UtIhH8hgbvohqM2pbiq0R99kNRVoFkMxpPElc8KgW0NC5
wMNDv/KRLlsOhdXM9TRFaKBRB8eyKvBC4URQZ1lMt6luM81SSVRr93/iqHR6Vjg7F91TCGnh
s2Jq2ZZTS2BNySMlQsRonD3X/K94KtXu3yiJPAeVplmADyVXVpU+V9WFCZRLLxe/3q6shKKV
kW5FfPjktuVVMOujyCpMJwoy5M7PriUk/ZFR/RyVIPKQecxxAgmELrZS8xnKecQRbhGFahA+
IT0sVVijONggB6iODXys4FoXnCyT56LkLMfkU+fqMzjOmXvfUllt8/CUQ8x3LU+hT3Ml1+cw
YOC4JOCfwQ8ewu81trfXbdwFI6DsfCa9OJEH9gatjcJPUadFo4jg3HQ75JC74wA25zfc0RBn
+6H8D3y4DJ2d7zWAzmfk/UbBt8bjbGBF/VQesTPzeKkbMtKH+g/9DqENRV0tTufmzunfnjuf
/7glh4NJijHNJHWC5F/waxjGAx7KB6WUry5VBKOM0R8KAy4ofmVJMMRvCQjfndvf5bccvc4F
mf28AQuovFoyfVEyndwHw3sizyQ2C8cK4dSKcPoa4fRXC2cvCmfvRDh7jXD2q4VjS5MKT7sQ
j68Rj79ePLYkHtuJeIM14g3WiHf7O8214eCZxLC7ksATtbOlrVc9W9N6TfNtjaiuQazt8K0R
tTWItXOu2QjpOxwhY03rtRB1a0RzDWLtKnFrRGsN4hrLAjz25hGa0bItFtycmO1w7N01/XLf
jOitQawZ7K0RxRrEmje4NaK/BtGvIubRAw49OeyeXtwdzU6KlmOiIMqvdOD3C6Fh4KE7YlHL
4AqEIXh2KN154UnaKmc6GuNROgSuEAM9oiCMnPe+gAcFajvOxuFkKJ/XeCq5t1D1VdArIIel
d1BTqkvXBkpeij4o3jrkR0F8yoNQOuk4FL3zDvHENHDrPneZVDDmCZ8GSTbJ/bYiwYDAqK04
IF8KfRLhB5HwGn8Fvh+gS1sNgCqBT1lciXqYzZhiUE0zFFPHZlaEPtIVd8YicfH+7ebWgYHt
tyxmKyRKMB8Am3YGQZa2WFECDRQP6HznT1XYEvByNBAeXsmphRd8gtHjP8tTOsblqT0lKWO6
xgySyJY9VcFDk4lCbZPpNTdpDBgNGR+3XmbMg+g2+88tgMC7hOVVpYCZKqIVnj5HLuldydmX
EfKq8DfNBA8xd2IpioZuMt2wahxnkyDMYHFjsBAGaZbiOewNRjRx4okEmONBEAbZMxkm8WSM
iyqOmoTcYbRDynBHsSy95hD14jBwn4swRIYkta7ly9HdJ5Xsk0r2SSU/klQit0Ar/yL5Tijv
zmoOSg9M7z1P74tjdhGBncZdLA8kDuW2h4djwgzV0vI8ipqt6spjnxbRmGnoxvWJrqgmU64X
LNShpjHturQ4mCQIiKoBNMkj5gEeExgnC57i/ImpFr2WhwzHxGYK/B6kYG4ZNSg0MDvsAAN8
TdwRb5QFNdE+BiLBO9Q8++L8CwlG41CMoJvSR6gNx38gjVQkftpAv8DDCx0XNV2wfhAlF8gA
Y+dKU4veAPFho5cWrC3NAbgAc5PVZjUcgAEnw/trkkqUoYhHIkuepYpHzeXzKJYJjtxvM/DW
F8Fqh7e3DrhY/RYse2k6IY5LW4puwExWSfcphXvtv9f+/1+0/z6lcJ9SSPcphcVnn1K4Tync
pxTuUwr3KYX7lMJ9SuE+pXCfUrhPKdynFO5TCvcphYvWaJ9S+DLMPqVwLfk+pXCh0X1K4T6l
8JXC7VMK9ymF+5TCfUrhPqVwn1K4TyncpxQW4PuUwn1K4T6pZJ9U8m+SVLJPKZzfB+9TCjen
FM5yBKS+WJsfsC3ZoudwPxbZj7sL5gpH4f+oGUTO2wKlsJAtVe/39pRZCvb9okhPIIphq02d
GqT78W80DuDBpXHyIzyKpVm28Z2cg6M3SPJcL0+E/BlMUTwmh+lDgI7pUZ6vkZEpDyei2SQ/
yq+rltnEG5R4GHc7vT45DMd/tVFWEBVc3E31s+ZNxVbAGwo8B2aqVWY2gIKhtkFA9QWjyahF
1Hno/iYWyzTUMiw4B8MKMzYN5Ake5p1QTVHeRAvLierfYa4i3LqYdSBWalhD11VjpmIhUtZR
B1oVHbtzOFVjFkZooIMb69FUxTTm+h9UjWIoTKsagF2j6Qa18e4BrNoLaAyM6gyMHROpWt8R
ytQtVkDJjMl/LzyVKsyCtQlWpkVmf/e2V+oECK1b89DglcRgOmDpjVDDAgdJ8/TNFI8ru+eX
EDdHD+lbqTWLwYaNIJ5zuOc58hIPI5TiBiXX5vDwuCjQm5gM8N++k088zfIDTBLcfTqbj7F2
fYZxkdKVXxp+7YYX1ry6xOtt4gUP58OOIcD3Z7ARrhIhUI3jiQkEhOCHcczlS4srO4zarslh
aSFt2+KYdEMaZKFooCweVLwnsq1b5sKxS5c/YbKjXKtj7j4Uceab6RVqqfrisU6vc45X3Odx
NBV5evIsYxev8qpgC8O7SyjFQhNWhqyXTxkehYGFgc30y+vJNMvQvpPLm9OzT52bD6TzuZEf
r93+nr6SSLd06CI640DgvIXAMBksYxmlwyiMg0ju2Aw9ykg6NG8iNS3cHAt3cX3wRRJwkHHU
c3N5SCFgb/wGzp8qv/HQkYHq9USLklOZzgo/LsBzb81TPd4RGfSvzjYjKwUyLZHpz0QGB03b
jKwWyGqJrP5MZJ1uMxpagayVyNrPRDZVy9iMrBfIeoms58jspyDbprLFaBgFslEiG5tH492Q
NXA97c3IZoFslsjmz0TWdI1uRrYKZKtEtn4msmFZW8ygXSDbJbK9cdW9I7INQdMWmp8W0Hym
+ulPxdaZYW+xw1lpsgYzbPZzsSFENbfALs2WO8NWNq6/d8U2DNvaArs0Xd4Me7PteldsPOva
Ars0X2KGvdl+vSe2AYp1G4+sNGH+DFv/udiqTZVld5YZa/zZV9Hq1LQqtOYuaA2FGhVaaxe0
poph0hKtvQtaPKlcplXWxQuvorUNpRKGKGwHtCY1dVqhVXZBy2zKKrTqLmjBD4MxazbvOt3L
2xaZQnWctGUAgfysLQFYW5GPCt6PwjN+7xZDZzjGd/1z4gnuybdrMpleWrmEeA2lwVDPzkJ3
iJ9pi2yo7kSZCPMT4Pmp2eFHnj6KMDx6uZYc+nwUhM8yFRbv0j0RtnLLs7bmmKSZGONNu0wo
PzqoFczktSwF1Efxj1bxyBXkEu8h0sU+raeZRMV5Hb6ubMgDPCkGMeiLdVFMet0vxEtAASbH
8nL8kUP/5R1ISuIofG4ebEVUCmnpmm7IV9paMnUFGp2MCZNHfMdF5s0biUFlGQtTmqctxD7Q
ze5Q0vwtV/miw2H1wuLoPaBsZmDU0P7hz3siwr6C7p59+dDCf1Lt9KZF0pAPGmAkG7HfGOCb
KDJZZCRG3mTsTFKR/IM+acYJfTJdfA0FE6LJ/GU45qv2/PWg98c3VIwY/sRXTnGW5Nt3Nmbu
YTIJefDENBuN/fSEKT/GY1qKVRyvU7xbx+NP+XdSWnMGcgO6NuNBhAtj5RX/L+z9EPElYh1W
x0eeeHITYsrLO7+d/XPaVCwb/P/yVa7ZZyPBbBkxy/JMD5yalQXy7NryhKoo2uqCxaVYX5tz
OXTbQscPKYoMRFWYir2RoCIXrwrKlwRVXHApVhfMWYwqhmEtCGoxlRVyzLti0I0E8yFWcCm4
LxXIQlupF8xBqW1xSmsFc0EZVU1F3l+H5C7hrmhtVcUoVpFv/1Wdzd++E28yGmPWmPsAesdQ
Ue/4u+BUdNzey5xyYn4rXsFxEoGmF3gVjwKzztxdccN81aRWbMNlwP3fxHEeRjIX0cEMmAfH
hQepdX0LgBhj7wCkW9JFXwYamKYHQPINYCe/VXIwuSKOAIPRAYLMs5p3BGIa0kmuggys2cjm
UPKvGCCEhgjGDgFsRaVVAKpx1QSAlWZwF6wKxIraClaOKznNkmiBVzWBV/N2w6soplHl1Q1P
8rrx+NkZ4X25gylW0RCHS8fhMncIoFp2bdB0kzNcNv3nfs6PGwm3MGc7YNRVGTguMgrugyqR
2+YeTFsoHDcRPF8gAjcw/H+HACYorhUAro16q3AuPGDVcbqYxnfBaelGldO1XE+VOiu7B2mR
j+OOHKg/zGbbekVD2lRzXdv/Df/QTuZgkp4D0RAqZ+bjoqS7Ycb78apuBoFdS5eTU4jsjHny
MBIlP/N3x68yTMf4PPgL4m30kBFi0QE5Rn86Tz0p9HNjnpT9w+yaYS6wz94dfwyy+7knnS38
/aw3sei2DhrnNCz/debWVlWGgcEGZr62CVM2l5uKiQalVrA0NZgwi+si5VORm3tp7nBqFKns
wDN9LX3ZHhg0bUmAoqBiXCxDXQIs9eyAHryCsmhDA0eJLjZaFlSguOLNLFqxEABtgKb9f6m7
/ue2bWT/e/8KzN3NnHPPVgCQ+ELdS+c5dtJ66i+q5bR9k8nzUBJlcyJLqigl8f31bxcgRYqU
ZFEkHVdtJBnCfkhwgcVisdjt+/nrPlE5uRJnpusXCtYqGDuoF3uSJVcH/c5ZuZ24ID/RMacw
v3Iez68lqiZXEaBCrFw2Lig1v+4xF7vKdeXKheOC8nPrvpOx63G12gPigt0n2bKzsaDaE9lL
JgUlprjSk6Hgwl1pZ1Kw6zRXbjYUILhXenJSUG6G22c6FMJFmWmPChAbt9GfmbhNc5hCeou7
u8fk1Hy7KpXUxWUofLbJsF/q/yYRtZZFRL0FEVe8z4soqUaF/scVRG9bqzHwD3teRFDScMCU
ev1fbeTQM5yCwaPSM68fUQqzLFtB9Kv03QYQNTCiTot1A4iKSsk/xZExbfzN/md7VujOnJBY
BOjgGZ9xMtbYemg5QzNlnS2pH9F1cDlYq/1eZ2aPxvGlRKfaMrb+/WjQrvqkNf/GWvLb5Cck
e5uRPE/Z9pvG17AGcJ/Zjv9drulw3LPevHewqUL9ewc6v3egs3sHWoCkK2wNpPFoNlZ47r0D
rSQrzGs6s3ewqcJz7x1oT+G237oNgi0/gSKsC2uznXYAKlAyzyksQ3e2/lekdkRxSbiPyb8+
IOHI/HKttNm/HhBFdd5UWcr0Xx1Am6lpnw2A/UkFxhQtsHI3m0M1WiZ1gWklrA01AMBsUDSQ
KN8ROaOD01sxOlQgBKGxzjixq+m/BgApVEnzSHVK0AXylE+bPfYm89y8vW1ne0c1YsYozXeL
Erb/6vRc4JbWBuO/fsL4X5nc5TgzldgI2IsEtFuxdoNg60/aHHjO7xFsLgemq4zFbVnwTHsH
glPlZI25y4IG9w4E5xxdwUmhoPG9Aww9guezSKHgu+wdCC4k0yu3Exc0uncgcHvWW7lsXNDw
3oHg0DuclQvHBc+2dyDwIHrWkL8s2H2SLTsbO0xTd+WScUGDewfCcYVYES1JQSN7B8IRnrfS
pZKCxvcOBIxgxy27C7Avlba7PniLyylLVbBtNoDoMioK9le1zUb8HRAdI3BWLf1bd0yesPQ3
gYiTw97G/8rkUrNa92uaQNRaFHcjKj3z2hFB1Ra1WvqbQLRnYBJ53l4XP33HSp7S+ehXDYbl
fPbrSTz+9Ylcvrtpk+tlBC2ThmzSn4yIPSiTCWK2B4ViDp6P6E8XeE9Jcog7DOI7nszICCaF
YLZvbS7lltoPwXixX13X9VgSgQpj6Jrwuhj1tRhnrGRlRdHLDX5NknSshtQ1tMzEoDNJtvw+
Hm+piVxCV6DAvZ8XdwGGtknvj3By8dbEFDULOEz3ERylKztqw43Wj+MoB3jyFTQRE/4SQ5CC
ynA0m/TCsY1rFIxsQjxsUx+DEAbfprjsnGaOVYUPUz/NatYUqmfczuOkOias7e1V9+zgYjJY
jAJyasIBv9q3OqcczTSF6unJthoomHDX3ZLTouS2e9LB8DbBGOOsRVWJuMfk1ns7vruDXuPP
191mBWLFXYXOa5Z4fSmzka2PL85tALCIRAszTIaLEYguv//nIsSubOLiTny4/g97kCwvLYWC
obLxb9BNMbBTHOd8DKMIhsy8eIKyREXG9FIeHSwDg3Up6YpXZWsJqpeh+KzAiQNso4jBjc3Z
bDFdHuCuTic9HDUZ+XY/ieakNwsHIFK+huPB5Gsc6xOx/03CIRkHyAl/9ogpZwPyt2k/fDOe
9GfR3ww/7L4K8XEN8tzX8SSHGXOZpQWmhOvJZE7e2st8hAKY7Q8GkwcfQy/h5PzRRmw/Gg7T
RCh1obgujmRMv0I6lx16TJ02qoIwuE7a5KqbxpD72A3uMGpr9KkmYmmOVK0lBo0hxNBaB8fv
bi+vbm7fX324PH317zjZnIlD3+1cNAGlMHa26QMrzJ9P4qj5AJvuQZetzY1jEXSR28zPNsK2
IYB1sNHvyMdwQuIESJj0qD9Ucff71BAYLKRUKbCBDYWPGmezYIrKHcHWpX3tPSOoZ1zSdwdd
SSnQGz4fqIZK7m6gqcioi9ox8RSBeklJaQvzLGAuiDYz63mbt4LCksc3CZwoJquktWJ4nGNA
rhUMlmLAvErXYrA6MRjGFlYi3xbWYikGW4fBKNP1YjjShJIsYoBOZbpVOxmtfW56F3wkbK1O
LmA1urYFI9Do+o/k7PQdQW3qcwLIUkDKhmZcsqFqEtBxnHKAbgroDGUjSMJzaSkknWmkso1U
qklAzdAZrgRgP9NWJZtAksLB1XIOyVmOFnOwpDhqNc2M2lowtING6SJG3Izk5qWddqQzRBuQ
Hz7YfEfoYuca7a9BRMXMtv2TiMoiKroOsXvxtjlAbd3ZVwC5kcEwDbhtxtAcW+CEQ7OcqAPD
WyMADUZGvNgZeuinM7QfG+1g0ZaRhjViMe5Kln/gWSydYoG6kNEcMM937TCaS9yE3gTj0CxM
kMIEa1pWJ5YHIiL/xJ2MRkFpsKYH8GwPqAODU9fE3i1iFDkf9PppmzBjeNqcumCYp90807Mw
6bwUJyHuw/xUG7mG5e0W8lX+6rQRvSJ/a8XyXONnsoLlWmnhD13k8zppwVb4XAOGgya4/Izo
5picPF7XPl6VNqMqOYZ9yqsKbo65qUBgqUBg2S5WF4zHqcpr4hmYTB63YS+VmD1lJaZ0e+F8
lcv1IwLDGcvPMqIcz2vBwMRA+b4nNjBeW8b3Ms2oSC6E8vJSW2xkOE8ZzrMMrwlGUKnklsas
cFmnXB5u5HIDiA6XBVkhy/G8FgxBdWGVKTcwvm8Zn33UFcml9rx8z5cbGe6kDHeG9cOALsS9
tc+zyOV+Kh36m6VDA4gwUFW+qaocz2vBEACRb5laz3hm1QCWUQOqkkvheXk5rjYy3E0Z7q4w
vB4YRT1W0BHVBi6n0qG/WTo0gMiXxtEUUZfjeS0YGNMnrxroDYy3CgrLKChVyQXTBYbrjQwX
KcPFCsNrgvHQaWczTJbLg1Q6DDZLh/oRNROqsLT3yvG8FgwOMiuvGngbGG8VFJZRUKqSY0jD
vMT0NjJcpgyXWYbXBaM5NGczzAqXU+kw2Cwd6kf00HCY57lfjue1YHAqClYXfwPjrYLCMo+6
KrkjvcJi2d/IcJUyXA0bgNGc6i2NyXI5SKVDsFk61I3IW5TCGi3f1F5qb+HC763huU5tsDVh
QC8qtKy3ydgy1Okjh6+Z5tQEIxRVXtYr4GzpVnEejj+Tj+eXvxx/IgdpdqiSRETAf/9i1Pxj
DP5/9eqHJZLknqRPIL3NX74M0ROX1yYW9Vakk8LlSxCZy+OV8QYY/steXrkm/8JWpNP85csQ
PXF5KdMUmRuQuoXLlyAi//Lg/+wlNTUe/lnPqnzpuzhNmkN+6rwzESJ6JvQGNcnY6Punfs9c
TDiYJuLLne/Pem1Mwm7yQ/gRwQjg6LUbom8s+u8shxCQ1UevmMzQ2/p4fgEDOeSpDgcBJlmO
3oST/4Jxezj5Ol5+N568b8aTcfA82B4svlPsrC/ak7961MGzasmvsYNLfzKezyYjMp1EUYjp
Mtc+r0q0AmaMFV8s42yHjmKY+GPFRWyP6oovq6MjgzkIeYuZCm7NUUVMqQudT8b5UavTaROK
NtDcCHSTKZtcH1+Q3mI4DGYZNxMPl/dH8dd0Tq4LwzNpm57CAM1kENvMWOxAXisGo7D44E87
jHOnCoVdg664zXe/hnPg2ACZlPmBfP7ycGT+romagQCEMfW+e3SCPaRNzldG1dO/cwcDiU3H
Uxj8447tzHgWoUwNjNhnahA7vkhntLgzXokdTCRtKKycOSRnp5HxnOuB1D0wORMS99l6kZQw
RsAYie2E5FCnSSQO+odKkfhOSEPWLBLXMXcNEjoWDB58wj+VqeFoY7tLa+xwN2od12pEUiaR
WYLk7oTkNovkMMfJtE7shCQoaxTJ1TLTu+VLQAIhgCE6ViROG2ZYPM2pYohoz9rC9Ryek7bo
zXs7fcgfcVp7wCl3vAnWmgK93ri7PNf0bBdRIrar5bwjE6dI90l/3PpQPJPyYzOKeNIDtzYU
yZhg21Dkzr629aM5Qmx92mpn79r60YTr7nC0jlcgUAIjldycdEgQ4UGWMEId596P7u25lkyy
c+pJcjCZDYJZmziHxAEprK2q+6o5PM/EuUe8Hjycp4HcQyJBOZCNAWEgB2aA2uTnJUi0PHWH
pw2yTTeg5pL4rQEcLtBq/uG0s7ZNXKRNYodEM48XWlQdAc+BG4Sjc4zG+J1hgG07rBZYBQIp
aN5cZ3zQz8OH0JgVBuEMDw/CWvE1mlXmM38cwfooqhVC6YI/iPFAR0dJJ7a9IFLHh8U2rtOC
UeBHQY0AHnWLjt8AcGwTr5lDXt1jcnpxjBGt7swBTBsDIqoXRFPN83uOxh/wt3AQTBKLig1H
dO+DkAX+Xl9dYHCkdK7op3PFYHXJ2jS846JjgrEsnJx3CbVd+hCAh/5iNCfS3a+uMKfEPoyn
fv8zPkdcI878h2HUarXK1QLl1hzseT8LgmWdAbHR+EB+w5r0F3KAzTLxJ4f9Pu5LkaM0JOXQ
7iW+ahBRgG4Az2a4mAff1koPlgqPI35IjP62Kj3qwRAM9d+zOH5AFJDoEYTKAwziRYSnnj8H
jxg9J6pCoTieg8HBgOXBvG3ybMKM8TC97YXz6I3jGp3V3Osbpkhv0f8czOO/af1AkoPij08O
7h6ZSQ6OYXnxBUQWHqtWLe6+2q+uy9F/cwIC8C4YRrdYv01MzKc4wpgJ5Bxr8W20fsIHbdcI
oMwEkQC0Mf0mHtlO7ncxjeazwH/I2U/3p/M0Tg6/BI92/6kX3t1CByhEDyhXVSmGTp/Lqn70
+PAQQK/u11BbmzMRx2klvImpP4uCGfnnN5jr/lkjmYaVLZ6xgE56ex98wyitbYw6RxjTrimO
ACSKKpK4HHOMfo2Y7Ls6+WyDoDQCYT6xUcTtGV8bxwj0twMQ8Gj2zIil+oCkkRJLANBQeib2
dQIdH3c1fTqYzSYzcpTE3ahO7jETmjQcTxcwfDowyc3I28V8Dh3Zj8jreFn/+vzyj+7/dm8u
YJLE753fr99e4ndDZ99ps5iOhyH+4k2tLORHIHz/aY+KQqJi+rs/G5vEv2ncgc7In2N4CKu2
2YS6IE3mJo3zIUjKucnsbMN5DlpNItpAbyeTcQQ6yQzWEQ/T0GhvJ50Pw1nwZ3IeG8/aT8gj
LEfjePe1YrjUpQoe6s+n5yfEZH8ehFE/nJqvMIsMQbEI3uASpgqFcHHX9PJ2LU0qMFpVKKwv
78zxJNoX7+E5TCP7Jzk1iZTJP66he6Igb+MREEr+UROxFpgeoBvMQBVoE80FfQ0re0GXCZxd
IytA58PtLVA4Z3a9EGWiPtSI43IHx2hs1ZzPH7sUFduz11d4emKoyUE4+5O8wRUzRpi57fmL
AUbhZIKDckbCiPjEXPe4SUjlmI382M6JkCyF5Cmk810htevhUar3VtDCGBriir4/XdBkEYGZ
s/euLgVmaUrnFSs34lCv92Ew82f9+0cbxeL0xuyQYvAbWieCNgHvYYJ9eDyC59PGFOXYv+6g
z41bhHxAlW/255vLKiQeNUcJuzCw+iCvz/1eRE64nUITGfWlZQK+tnDNcHDyigBTFLmeDCaj
4YT8FE4e0AWgSUQpJQZAPD6Jgj45e/fuHdGwamTH70pVUR7uK8wXY1QYcNxG/ojcfLh8fXPc
SXpBMqBZS9ZA6AlMa2kIsZXM87wjPPdPLvxv5JeZH40f/XH0+ZH8N4jnz//z58IfwUzx0IK3
H+tFMQG6QQvtdDrkLhgHqCHaW17q0HCpFt+/PoY1tPXfdk8xU8cU1S+sGOvqRfVzTyKlMMRj
qKmLe4OXHXjrvsbkIMYjYoSb5/E2ZfuXt6eH8fZg++LqwyeUOvSbpIfw5uJIIOyQ8eeAxm1N
WF6AOh5O2vYKBCBiXbVAWp3OUbg3vkJ3/OGPTXS8BkKpGcySIe8fwboDqx+Nwrt70Eb9gT/F
aEpm+bMYR9OgHw7DDEsrkHJmQnXFeu/xDeazGEcjExKtG8wJx4VQb4K5VbJ68DRWDl+bBr42
rV3RgvlzXsF10Csj1mdwJmBHX8NZQE5hXQWY42CORoWlHbVVB6VUqCuedtnvF+Qrw5AjsGrH
Rx0PcxDMfSOYXdL9j9+bjPoR+elxMfs8qRXDkUwZ31GtHIkW0xP88s2o5qmyHksDLAzH8Cjn
mR5QHcHFBCyfCGgGsHK+OwKtoJ2NuweTNygLYd/E3UVTajh/JBMT7S6qF8Mxx6qe3HSSVSiE
iyk5wmkIy/azzheXYJRG+w2mGFiBGNXV8K8akTABI5aWuP9glT/eX19gpxyhT2Q0QevX/vWZ
5ju03a1A4Aj0qB3x+fS2P5mhgxG/6RD8upzvf8u42+1BANoSjwniZsY0SaNNPLeh3w+q0UgX
DRagEjFQCo1m9Cv57fz4knQTjYy19N7VtTF8np7gFly82QAP9uTk7BSk48HNSQfE+efUCWIP
AnSXg0mpP59u3uQze3pcyNfwrxZSyTyce73pGG25Z+NoDlIVu6XXwU3nRJvdvz5MtdAhe/78
wR/f+oMvbfK2ddy6aV3A+2ULJr8vGC0T7owy2YIHg2YEfx72QLUG8ZEoYky8ytk9m0SWDMOT
TqbB+EtkPPna5Ar+IF+sXx+xhUYe+HMfQO/rodWOgKH1MB1Ft3cRaCYXnfMu+al7VXyqO9dU
zDhYt1otYuInYpY584o9Cig5SG2GZWtzk2JrWfu3d9fds6vLNqGMYpIgd5+ajueYZbR9bSp/
7tcP6Y1Ijrpj8QZXy7/jDdoFcvEGV8uf46Uzn+kNaioxGNrmvxlDS+t48dCDCXgyhM5tbU7G
KQY31URrz8rcwQBnaeWzqyPTH/9Ol4oMug241Ugcc4QetwlwmGP+grMr0+9b6191UGJWnU9J
bbi5sr9LEx0Wy5bNglqgahb6UZmqiqHrZXyzWNgm0/vHCHTEkb2RcIBkFQigYU6O4BRUNZDu
j+QGFlRtsm9ljJuZq3x+0yXL196VPWpip+UfIMOGMQzTy/aqys3Ek7kFgr6K34DOOofgZJfu
S6saCHHLMk/YgbEXwrwUYAxXPJFC96/verJQP+nB8fQNN8QqEEiTqD7/ePmarlymqnKTAZLe
hj/roZ+ESVBF9q6sRTyNtuxhlQyHjMbX3quqZ7bV4gDL9OkfJIVlDGZJmYZjSg+XmwCHJMBj
O4fkPry7h1XAAaWvcLvg+gA/u+Y9Gc2H5NT+fJHRKBoE5hJnZwPMDpOY16QA7LAC8GhyZ8SP
AWYGmD0HsOuZ/CAIzLcBFx/F9wJWJpKmAXa2MM9xXgywZ4LTG2B3G7D7UoAZ05itzwCLLPAo
+BKMMsDixQC7XCRDWm7rbvLFAMMaLhkgahuwejHAWuOJcAOstwHrlwLMmVH0DLCXBc53N+/F
ADuuTJjnbxsgxy8GGNakyQDpbQN++2KANfUSQd/f1t1OXgqwQ12eiM3BNuDTFwPMzYaGAQ62
Ab97McDCuH8a4OE24PcvBli5Ou5urFY1tjlgzMUQA7O/BDAMDxYPEMb/GsCuWUIa4G1q7AsC
lpLHA4RtU2NfELD2EkHPxF8CWNiMdQZY/jWAHUXjxQ1Tfw1gWPTituv1r7hJDfDkwZ9O8QBD
u1wdRdHDDupQsrbw6EdC29y+/5CpoTBoEtRgZG2hIWD2PUOmBTrYQg2HrC00BI59z5B5JtMQ
1HDJ2kJD4Nr3lExSaizE178KsrbQEAj7niVT2jZDkrWFhkDa9wyZTQsHNRRZW2gIlH3PkHHu
WSZpsrbQEGj7niEDbcq23iNrCw2BZ9+zZCoGZpSsL7U8o/FHhtQVXszdDM9XSi1NzPUM2yU8
BHtfjJP1pZaGxx8ZUsnRQxArZbrMSqmlceKPDKkyVmCslOk2K6WWxo0/sqQetQOAZbtOttTS
iPgjQ6oVY0vr59YXGUzGQasGSsUdjAeCcVRsAkx0Ww8GRzDi/2gJ6pF+MJuHQ+PHElWlcmxM
Bf8uuJ18HQcz9PPN+0zvWEsrjdJxecYmGPdnj1P0KSg6EJaqrCjGyMZ87eNoMgrIx3Ewh++g
A62kBixVEZ4XXN7+/v/FXVFvmzAQfoZfEVV7WLcYQ0IIjWRpm1RNe5j6MmkP1YQcMNQCDMXQ
Np3233dnkzbt1rVb1i0PxD7szzb4zoTc58Oyqxs3LXhyLvAK6p7vOij9SZVgvkTW0ZYTOKhB
G/IbcgxuqIHBPPZHaiB+jo6Wix1qoBXFHANRHP4D4MhECPncIWMZnXLwjfz4T98IjxHdSaOq
jfEPWBnKoF/+TYQ4xm1LHxnccubvEipBl2f+XULlkd2U4PD5gedg38NHgcEk3AEOF/l94Oi5
gd3jireIgaRIvPKuW17U7KXrnIt6IJamSa7iKIlC1yFWbQgUgUzaDui7cymqavpa16LFI2/h
zNgh2pYFraQarqhFIB1XmXXxATvkE38eoIvejBZpSkIvosFyGaSRCPgiWgrur/kshY/PwzwX
UcyDMDjKs1jk9KJG3Gus5AEOLFQhKcba0IGRbUsbLWswUnTTpH1jj6Tv8OxmHJSXFtdQoZ4s
YF1yiK7bSQDfowO5wH1Up6DWkGfw5cMpm8OQmN1UZlup2WbPckZViqUa0gkUQvqS9+lZ1hQT
CUu4L/R6R0a4/YvLcDRB3vWpoVswDCFc4V3B3qCb2iQH+81orqnOioCCuS19YodUrgdZZWQR
TGuRSc7w3FTm7EKCiW9+ARDsCzDbF2C+L0C4L8BiX4DoqQCtzLC2cUem+qymJU4QCuL7CDgT
DbHJNLe6V+FeYWqL/l6dstY43TIORkPJazPLpG5x3ySzwSKoBMgx4rAaqsoFSwE/LoTK0DRg
OERm8Dtew+Q/G1SR9FyXScuVTBl0f5zOvIXsmAZb0p0nvLrkG51s11+nS4cWrL7wIJGARUmM
f16CE78ZeobxBB1QMU/mitdCM8i2oMB96UH7OAjWKBCZdgk0rJu8R77p0N52RtUy2eobM1LX
aZpWb9PoTZfAUPCGsRk2AA9L/Y0Emsy6debVUjVdkjaD6llsxgO2MfNgsU/Me2Qmus51ZAGl
RAJSI3QdwbtqY/vMDBdsailUrjM+NzwshdxFwZnCCN2A1F1CX6UqGR3voyH20m5QxMT9vnOT
HzO5xi6jnRPVyhxJipdoaMkMPTWw2HwBD79PtMirtdSwshMLu6Te1kI/FeC22TgM5wsSBKsf
lGINg0nP2E7X6cNdd513Jyefkg8f374/Zv9tKfrJzAFdOnjxFdbQ0zdfvh1MiFWsCchs6vQV
iN3vVIrA71YfAQA=

--yvfyjqxnpxlz5bhg
Content-Type: application/gzip
Content-Disposition: attachment; filename="dmesg-yocto-kbuild-18:20170314090101:x86_64-randconfig-in0-03140242:4.6.0-06643-g64f8eba:1.gz"
Content-Transfer-Encoding: base64

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

--yvfyjqxnpxlz5bhg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="reproduce-yocto-kbuild-51:20170314084603:x86_64-randconfig-in0-03140242:4.6.0-06644-g1771c6e:1"

#!/bin/bash

kernel=$1
initrd=yocto-trinity-x86_64.cgz

wget --no-clobber https://github.com/fengguang/reproduce-kernel-bug/raw/master/initrd/$initrd

kvm=(
	qemu-system-x86_64
	-enable-kvm
	-cpu Haswell,+smep,+smap
	-kernel $kernel
	-initrd $initrd
	-m 512
	-smp 1
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

--yvfyjqxnpxlz5bhg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-4.6.0-06644-g1771c6e"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 4.6.0 Kernel Configuration
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
CONFIG_X86_64_SMP=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi -fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r10 -fcall-saved-r11"
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
# CONFIG_KERNEL_GZIP is not set
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
CONFIG_KERNEL_LZ4=y
CONFIG_DEFAULT_HOSTNAME="(none)"
# CONFIG_SYSVIPC is not set
# CONFIG_POSIX_MQUEUE is not set
# CONFIG_CROSS_MEMORY_ATTACH is not set
CONFIG_FHANDLE=y
# CONFIG_USELIB is not set
# CONFIG_AUDIT is not set
CONFIG_HAVE_ARCH_AUDITSYSCALL=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_GENERIC_IRQ_CHIP=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_DOMAIN_HIERARCHY=y
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
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ_COMMON=y
# CONFIG_HZ_PERIODIC is not set
# CONFIG_NO_HZ_IDLE is not set
CONFIG_NO_HZ_FULL=y
# CONFIG_NO_HZ_FULL_ALL is not set
# CONFIG_NO_HZ_FULL_SYSIDLE is not set
# CONFIG_NO_HZ is not set
# CONFIG_HIGH_RES_TIMERS is not set

#
# CPU/Task time and stats accounting
#
CONFIG_VIRT_CPU_ACCOUNTING=y
CONFIG_VIRT_CPU_ACCOUNTING_GEN=y
# CONFIG_BSD_PROCESS_ACCT is not set
# CONFIG_TASKSTATS is not set

#
# RCU Subsystem
#
CONFIG_TREE_RCU=y
CONFIG_RCU_EXPERT=y
CONFIG_SRCU=y
CONFIG_TASKS_RCU=y
CONFIG_RCU_STALL_COMMON=y
CONFIG_CONTEXT_TRACKING=y
# CONFIG_CONTEXT_TRACKING_FORCE is not set
CONFIG_RCU_FANOUT=64
CONFIG_RCU_FANOUT_LEAF=16
# CONFIG_RCU_FAST_NO_HZ is not set
CONFIG_TREE_RCU_TRACE=y
CONFIG_RCU_KTHREAD_PRIO=0
CONFIG_RCU_NOCB_CPU=y
CONFIG_RCU_NOCB_CPU_NONE=y
# CONFIG_RCU_NOCB_CPU_ZERO is not set
# CONFIG_RCU_NOCB_CPU_ALL is not set
# CONFIG_RCU_EXPEDITE_BOOT is not set
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=17
CONFIG_LOG_CPU_MAX_BUF_SHIFT=12
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH=y
CONFIG_ARCH_SUPPORTS_INT128=y
# CONFIG_NUMA_BALANCING is not set
CONFIG_CGROUPS=y
CONFIG_PAGE_COUNTER=y
CONFIG_MEMCG=y
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
CONFIG_CFS_BANDWIDTH=y
CONFIG_RT_GROUP_SCHED=y
# CONFIG_CGROUP_PIDS is not set
# CONFIG_CGROUP_FREEZER is not set
CONFIG_CGROUP_HUGETLB=y
# CONFIG_CPUSETS is not set
CONFIG_CGROUP_DEVICE=y
# CONFIG_CGROUP_CPUACCT is not set
CONFIG_CGROUP_PERF=y
CONFIG_CGROUP_DEBUG=y
# CONFIG_CHECKPOINT_RESTORE is not set
# CONFIG_NAMESPACES is not set
CONFIG_SCHED_AUTOGROUP=y
# CONFIG_SYSFS_DEPRECATED is not set
# CONFIG_RELAY is not set
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
CONFIG_RD_XZ=y
CONFIG_RD_LZO=y
CONFIG_RD_LZ4=y
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BPF=y
CONFIG_EXPERT=y
CONFIG_UID16=y
CONFIG_MULTIUSER=y
CONFIG_SGETMASK_SYSCALL=y
# CONFIG_SYSFS_SYSCALL is not set
CONFIG_SYSCTL_SYSCALL=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_KALLSYMS_ABSOLUTE_PERCPU=y
CONFIG_KALLSYMS_BASE_RELATIVE=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
# CONFIG_BASE_FULL is not set
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_BPF_SYSCALL=y
CONFIG_SHMEM=y
CONFIG_AIO=y
# CONFIG_ADVISE_SYSCALLS is not set
CONFIG_USERFAULTFD=y
CONFIG_PCI_QUIRKS=y
CONFIG_MEMBARRIER=y
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
# CONFIG_VM_EVENT_COUNTERS is not set
# CONFIG_COMPAT_BRK is not set
CONFIG_SLAB=y
# CONFIG_SLUB is not set
# CONFIG_SLOB is not set
CONFIG_SLAB_FREELIST_RANDOM=y
# CONFIG_SYSTEM_DATA_VERIFICATION is not set
# CONFIG_PROFILING is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_KPROBES is not set
CONFIG_JUMP_LABEL=y
CONFIG_STATIC_KEYS_SELFTEST=y
# CONFIG_UPROBES is not set
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_CONTIGUOUS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_ARCH_WANTS_DYNAMIC_TASK_STRUCT=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_COMPAT_IPC_PARSE_VERSION=y
CONFIG_ARCH_WANT_OLD_COMPAT_IPC=y
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
CONFIG_ARCH_MMAP_RND_BITS=28
CONFIG_HAVE_ARCH_MMAP_RND_COMPAT_BITS=y
CONFIG_ARCH_MMAP_RND_COMPAT_BITS=8
CONFIG_HAVE_COPY_THREAD_TLS=y
CONFIG_HAVE_STACK_VALIDATION=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_COMPAT_OLD_SIGACTION=y

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=1
CONFIG_MODULES=y
CONFIG_MODULE_FORCE_LOAD=y
CONFIG_MODULE_UNLOAD=y
# CONFIG_MODULE_FORCE_UNLOAD is not set
# CONFIG_MODVERSIONS is not set
# CONFIG_MODULE_SRCVERSION_ALL is not set
# CONFIG_MODULE_SIG is not set
# CONFIG_MODULE_COMPRESS is not set
CONFIG_MODULES_TREE_LOOKUP=y
# CONFIG_BLOCK is not set
CONFIG_ASN1=y
CONFIG_INLINE_SPIN_UNLOCK_IRQ=y
CONFIG_INLINE_READ_UNLOCK=y
CONFIG_INLINE_READ_UNLOCK_IRQ=y
CONFIG_INLINE_WRITE_UNLOCK=y
CONFIG_INLINE_WRITE_UNLOCK_IRQ=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_MUTEX_SPIN_ON_OWNER=y
CONFIG_RWSEM_SPIN_ON_OWNER=y
CONFIG_LOCK_SPIN_ON_OWNER=y
CONFIG_ARCH_USE_QUEUED_SPINLOCKS=y
CONFIG_QUEUED_SPINLOCKS=y
CONFIG_ARCH_USE_QUEUED_RWLOCKS=y
CONFIG_QUEUED_RWLOCKS=y
# CONFIG_FREEZER is not set

#
# Processor type and features
#
# CONFIG_ZONE_DMA is not set
CONFIG_SMP=y
CONFIG_X86_FEATURE_NAMES=y
CONFIG_X86_FAST_FEATURE_TESTS=y
# CONFIG_X86_X2APIC is not set
CONFIG_X86_MPPARSE=y
# CONFIG_GOLDFISH is not set
# CONFIG_X86_EXTENDED_PLATFORM is not set
# CONFIG_X86_INTEL_LPSS is not set
# CONFIG_X86_AMD_PLATFORM_DEVICE is not set
CONFIG_IOSF_MBI=m
# CONFIG_IOSF_MBI_DEBUG is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_PARAVIRT_SPINLOCKS is not set
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
# CONFIG_PROCESSOR_SELECT is not set
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
CONFIG_DMI=y
# CONFIG_GART_IOMMU is not set
# CONFIG_CALGARY_IOMMU is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_MAXSMP=y
CONFIG_NR_CPUS=8192
# CONFIG_SCHED_SMT is not set
# CONFIG_SCHED_MC is not set
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
CONFIG_X86_MCE=y
CONFIG_X86_MCE_INTEL=y
CONFIG_X86_MCE_AMD=y
CONFIG_X86_MCE_THRESHOLD=y
# CONFIG_X86_MCE_INJECT is not set
CONFIG_X86_THERMAL_VECTOR=y

#
# Performance monitoring
#
CONFIG_PERF_EVENTS_INTEL_UNCORE=y
CONFIG_PERF_EVENTS_INTEL_RAPL=y
CONFIG_PERF_EVENTS_INTEL_CSTATE=y
CONFIG_PERF_EVENTS_AMD_POWER=m
# CONFIG_VM86 is not set
# CONFIG_X86_16BIT is not set
CONFIG_X86_VSYSCALL_EMULATION=y
# CONFIG_I8K is not set
# CONFIG_MICROCODE is not set
CONFIG_X86_MSR=y
CONFIG_X86_CPUID=y
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_NUMA=y
CONFIG_AMD_NUMA=y
CONFIG_X86_64_ACPI_NUMA=y
CONFIG_NODES_SPAN_OTHER_NODES=y
CONFIG_NUMA_EMU=y
CONFIG_NODES_SHIFT=10
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_NEED_MULTIPLE_NODES=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
CONFIG_SPARSEMEM_VMEMMAP=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
# CONFIG_MOVABLE_NODE is not set
# CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
# CONFIG_MEMORY_HOTPLUG is not set
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
# CONFIG_COMPACTION is not set
CONFIG_MIGRATION=y
CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_VIRT_TO_BUS=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
CONFIG_HWPOISON_INJECT=m
# CONFIG_TRANSPARENT_HUGEPAGE is not set
CONFIG_CLEANCACHE=y
# CONFIG_CMA is not set
# CONFIG_ZPOOL is not set
CONFIG_ZBUD=m
CONFIG_ZSMALLOC=y
CONFIG_PGTABLE_MAPPING=y
# CONFIG_ZSMALLOC_STAT is not set
CONFIG_GENERIC_EARLY_IOREMAP=y
CONFIG_ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT=y
CONFIG_IDLE_PAGE_TRACKING=y
CONFIG_ARCH_USES_HIGH_VMA_FLAGS=y
CONFIG_ARCH_HAS_PKEYS=y
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
# CONFIG_MTRR_SANITIZER is not set
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
# CONFIG_ARCH_RANDOM is not set
# CONFIG_X86_SMAP is not set
CONFIG_X86_INTEL_MPX=y
CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS=y
# CONFIG_EFI is not set
# CONFIG_SECCOMP is not set
CONFIG_HZ_100=y
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=100
# CONFIG_SCHED_HRTICK is not set
# CONFIG_KEXEC is not set
# CONFIG_KEXEC_FILE is not set
CONFIG_CRASH_DUMP=y
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
CONFIG_RANDOMIZE_BASE=y
CONFIG_X86_NEED_RELOCS=y
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_HOTPLUG_CPU=y
# CONFIG_BOOTPARAM_HOTPLUG_CPU0 is not set
# CONFIG_DEBUG_HOTPLUG_CPU0 is not set
# CONFIG_COMPAT_VDSO is not set
# CONFIG_LEGACY_VSYSCALL_NATIVE is not set
CONFIG_LEGACY_VSYSCALL_EMULATE=y
# CONFIG_LEGACY_VSYSCALL_NONE is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_MODIFY_LDT_SYSCALL=y
CONFIG_HAVE_LIVEPATCH=y
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_USE_PERCPU_NUMA_NODE_ID=y

#
# Power management and ACPI options
#
# CONFIG_SUSPEND is not set
# CONFIG_PM is not set
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=y
# CONFIG_ACPI_DEBUGGER is not set
# CONFIG_ACPI_PROCFS_POWER is not set
CONFIG_ACPI_REV_OVERRIDE_POSSIBLE=y
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
# CONFIG_ACPI_VIDEO is not set
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_CPU_FREQ_PSS=y
CONFIG_ACPI_PROCESSOR_IDLE=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_HOTPLUG_CPU=y
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_NUMA=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ACPI_TABLE_UPGRADE=y
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
CONFIG_ACPI_HOTPLUG_IOAPIC=y
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
# CONFIG_ACPI_APEI is not set
# CONFIG_ACPI_EXTLOG is not set
# CONFIG_PMIC_OPREGION is not set
# CONFIG_SFI is not set

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
# CONFIG_INTEL_IDLE is not set

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
# CONFIG_PCI_MSI is not set
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
# CONFIG_PCI_STUB is not set
CONFIG_HT_IRQ=y
# CONFIG_PCI_IOV is not set
# CONFIG_PCI_PRI is not set
# CONFIG_PCI_PASID is not set
CONFIG_PCI_LABEL=y
# CONFIG_HOTPLUG_PCI is not set

#
# PCI host controller drivers
#
# CONFIG_PCIE_DW_PLAT is not set
CONFIG_ISA_DMA_API=y
CONFIG_AMD_NB=y
CONFIG_PCCARD=m
CONFIG_PCMCIA=m
# CONFIG_PCMCIA_LOAD_CIS is not set
CONFIG_CARDBUS=y

#
# PC-card bridges
#
# CONFIG_YENTA is not set
# CONFIG_PD6729 is not set
# CONFIG_I82092 is not set
# CONFIG_RAPIDIO is not set
# CONFIG_X86_SYSFB is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS=y
CONFIG_BINFMT_SCRIPT=y
# CONFIG_HAVE_AOUT is not set
CONFIG_BINFMT_MISC=m
CONFIG_COREDUMP=y
CONFIG_IA32_EMULATION=y
# CONFIG_IA32_AOUT is not set
CONFIG_X86_X32=y
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_KEYS_COMPAT=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_PMC_ATOM=y
CONFIG_NET=y
CONFIG_COMPAT_NETLINK_MESSAGES=y

#
# Networking options
#
# CONFIG_PACKET is not set
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
CONFIG_XFRM_USER=y
# CONFIG_XFRM_SUB_POLICY is not set
CONFIG_XFRM_MIGRATE=y
# CONFIG_XFRM_STATISTICS is not set
CONFIG_XFRM_IPCOMP=y
CONFIG_NET_KEY=m
# CONFIG_NET_KEY_MIGRATE is not set
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
CONFIG_IP_ADVANCED_ROUTER=y
CONFIG_IP_FIB_TRIE_STATS=y
# CONFIG_IP_MULTIPLE_TABLES is not set
CONFIG_IP_ROUTE_MULTIPATH=y
# CONFIG_IP_ROUTE_VERBOSE is not set
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
# CONFIG_IP_PNP_BOOTP is not set
# CONFIG_IP_PNP_RARP is not set
CONFIG_NET_IPIP=y
# CONFIG_NET_IPGRE_DEMUX is not set
CONFIG_NET_IP_TUNNEL=y
CONFIG_IP_MROUTE=y
# CONFIG_IP_MROUTE_MULTIPLE_TABLES is not set
CONFIG_IP_PIMSM_V1=y
# CONFIG_IP_PIMSM_V2 is not set
CONFIG_SYN_COOKIES=y
CONFIG_NET_UDP_TUNNEL=y
# CONFIG_NET_FOU is not set
# CONFIG_NET_FOU_IP_TUNNELS is not set
# CONFIG_INET_AH is not set
CONFIG_INET_ESP=m
CONFIG_INET_IPCOMP=y
CONFIG_INET_XFRM_TUNNEL=y
CONFIG_INET_TUNNEL=y
# CONFIG_INET_XFRM_MODE_TRANSPORT is not set
# CONFIG_INET_XFRM_MODE_TUNNEL is not set
CONFIG_INET_XFRM_MODE_BEET=m
CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
CONFIG_INET_UDP_DIAG=m
CONFIG_INET_DIAG_DESTROY=y
CONFIG_TCP_CONG_ADVANCED=y
# CONFIG_TCP_CONG_BIC is not set
CONFIG_TCP_CONG_CUBIC=y
CONFIG_TCP_CONG_WESTWOOD=m
CONFIG_TCP_CONG_HTCP=y
CONFIG_TCP_CONG_HSTCP=m
CONFIG_TCP_CONG_HYBLA=m
CONFIG_TCP_CONG_VEGAS=y
# CONFIG_TCP_CONG_SCALABLE is not set
# CONFIG_TCP_CONG_LP is not set
CONFIG_TCP_CONG_VENO=m
CONFIG_TCP_CONG_YEAH=y
# CONFIG_TCP_CONG_ILLINOIS is not set
CONFIG_TCP_CONG_DCTCP=m
# CONFIG_TCP_CONG_CDG is not set
CONFIG_DEFAULT_CUBIC=y
# CONFIG_DEFAULT_HTCP is not set
# CONFIG_DEFAULT_VEGAS is not set
# CONFIG_DEFAULT_RENO is not set
CONFIG_DEFAULT_TCP_CONG="cubic"
# CONFIG_TCP_MD5SIG is not set
# CONFIG_IPV6 is not set
# CONFIG_NETWORK_SECMARK is not set
CONFIG_NET_PTP_CLASSIFY=y
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
# CONFIG_NETFILTER is not set
CONFIG_IP_DCCP=y
CONFIG_INET_DCCP_DIAG=y

#
# DCCP CCIDs Configuration
#
CONFIG_IP_DCCP_CCID2_DEBUG=y
# CONFIG_IP_DCCP_CCID3 is not set

#
# DCCP Kernel Hacking
#
# CONFIG_IP_DCCP_DEBUG is not set
CONFIG_IP_SCTP=y
CONFIG_SCTP_DBG_OBJCNT=y
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5 is not set
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_SHA1 is not set
CONFIG_SCTP_DEFAULT_COOKIE_HMAC_NONE=y
CONFIG_SCTP_COOKIE_HMAC_MD5=y
CONFIG_SCTP_COOKIE_HMAC_SHA1=y
CONFIG_INET_SCTP_DIAG=y
# CONFIG_RDS is not set
CONFIG_TIPC=m
CONFIG_TIPC_MEDIA_UDP=y
# CONFIG_ATM is not set
CONFIG_L2TP=y
# CONFIG_L2TP_DEBUGFS is not set
CONFIG_L2TP_V3=y
# CONFIG_L2TP_IP is not set
# CONFIG_L2TP_ETH is not set
CONFIG_STP=y
CONFIG_GARP=y
CONFIG_MRP=y
CONFIG_BRIDGE=m
# CONFIG_BRIDGE_IGMP_SNOOPING is not set
CONFIG_BRIDGE_VLAN_FILTERING=y
CONFIG_HAVE_NET_DSA=y
# CONFIG_NET_DSA is not set
CONFIG_VLAN_8021Q=y
CONFIG_VLAN_8021Q_GVRP=y
CONFIG_VLAN_8021Q_MVRP=y
CONFIG_DECNET=m
CONFIG_DECNET_ROUTER=y
CONFIG_LLC=y
CONFIG_LLC2=y
CONFIG_IPX=y
# CONFIG_IPX_INTERN is not set
CONFIG_ATALK=m
CONFIG_DEV_APPLETALK=m
CONFIG_IPDDP=m
# CONFIG_IPDDP_ENCAP is not set
CONFIG_X25=m
# CONFIG_LAPB is not set
CONFIG_PHONET=m
CONFIG_IEEE802154=m
# CONFIG_IEEE802154_NL802154_EXPERIMENTAL is not set
CONFIG_IEEE802154_SOCKET=m
CONFIG_MAC802154=m
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set
# CONFIG_DNS_RESOLVER is not set
CONFIG_BATMAN_ADV=y
CONFIG_BATMAN_ADV_BLA=y
CONFIG_BATMAN_ADV_DAT=y
CONFIG_BATMAN_ADV_NC=y
# CONFIG_BATMAN_ADV_MCAST is not set
# CONFIG_BATMAN_ADV_DEBUG is not set
CONFIG_OPENVSWITCH=y
CONFIG_OPENVSWITCH_VXLAN=m
CONFIG_VSOCKETS=m
CONFIG_NETLINK_DIAG=m
CONFIG_MPLS=y
CONFIG_NET_MPLS_GSO=y
CONFIG_MPLS_ROUTING=m
CONFIG_HSR=m
CONFIG_NET_SWITCHDEV=y
# CONFIG_NET_L3_MASTER_DEV is not set
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
CONFIG_SOCK_CGROUP_DATA=y
CONFIG_CGROUP_NET_PRIO=y
# CONFIG_CGROUP_NET_CLASSID is not set
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
CONFIG_BPF_JIT=y
CONFIG_NET_FLOW_LIMIT=y

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
# CONFIG_HAMRADIO is not set
CONFIG_CAN=m
CONFIG_CAN_RAW=m
CONFIG_CAN_BCM=m
# CONFIG_CAN_GW is not set

#
# CAN Device Drivers
#
# CONFIG_CAN_VCAN is not set
CONFIG_CAN_SLCAN=m
CONFIG_CAN_DEV=m
# CONFIG_CAN_CALC_BITTIMING is not set
# CONFIG_CAN_LEDS is not set
CONFIG_CAN_GRCAN=m
CONFIG_CAN_C_CAN=m
# CONFIG_CAN_C_CAN_PLATFORM is not set
# CONFIG_CAN_C_CAN_PCI is not set
CONFIG_CAN_CC770=m
CONFIG_CAN_CC770_ISA=m
CONFIG_CAN_CC770_PLATFORM=m
CONFIG_CAN_IFI_CANFD=m
CONFIG_CAN_M_CAN=m
CONFIG_CAN_SJA1000=m
CONFIG_CAN_SJA1000_ISA=m
# CONFIG_CAN_SJA1000_PLATFORM is not set
CONFIG_CAN_EMS_PCMCIA=m
# CONFIG_CAN_EMS_PCI is not set
CONFIG_CAN_PEAK_PCMCIA=m
# CONFIG_CAN_PEAK_PCI is not set
# CONFIG_CAN_KVASER_PCI is not set
# CONFIG_CAN_PLX_PCI is not set
CONFIG_CAN_SOFTING=m
CONFIG_CAN_SOFTING_CS=m

#
# CAN USB interfaces
#
CONFIG_CAN_EMS_USB=m
CONFIG_CAN_ESD_USB2=m
CONFIG_CAN_GS_USB=m
# CONFIG_CAN_KVASER_USB is not set
# CONFIG_CAN_PEAK_USB is not set
CONFIG_CAN_8DEV_USB=m
# CONFIG_CAN_DEBUG_DEVICES is not set
CONFIG_IRDA=y

#
# IrDA protocols
#
CONFIG_IRLAN=m
CONFIG_IRNET=m
# CONFIG_IRCOMM is not set
# CONFIG_IRDA_ULTRA is not set

#
# IrDA options
#
CONFIG_IRDA_CACHE_LAST_LSAP=y
CONFIG_IRDA_FAST_RR=y
CONFIG_IRDA_DEBUG=y

#
# Infrared-port device drivers
#

#
# SIR device drivers
#
CONFIG_IRTTY_SIR=y

#
# Dongle support
#
# CONFIG_DONGLE is not set
CONFIG_KINGSUN_DONGLE=m
CONFIG_KSDAZZLE_DONGLE=m
CONFIG_KS959_DONGLE=m

#
# FIR device drivers
#
CONFIG_USB_IRDA=m
# CONFIG_SIGMATEL_FIR is not set
CONFIG_NSC_FIR=y
# CONFIG_WINBOND_FIR is not set
# CONFIG_SMC_IRCC_FIR is not set
CONFIG_ALI_FIR=m
# CONFIG_VLSI_FIR is not set
CONFIG_VIA_FIR=m
CONFIG_MCS_FIR=m
CONFIG_BT=m
CONFIG_BT_BREDR=y
CONFIG_BT_RFCOMM=y
CONFIG_BT_RFCOMM_TTY=y
CONFIG_BT_BNEP=m
CONFIG_BT_BNEP_MC_FILTER=y
CONFIG_BT_BNEP_PROTO_FILTER=y
CONFIG_BT_HIDP=m
CONFIG_BT_HS=y
# CONFIG_BT_LE is not set
CONFIG_BT_LEDS=y
# CONFIG_BT_SELFTEST is not set
CONFIG_BT_DEBUGFS=y

#
# Bluetooth device drivers
#
CONFIG_BT_INTEL=m
CONFIG_BT_RTL=m
CONFIG_BT_QCA=m
CONFIG_BT_HCIBTUSB=m
# CONFIG_BT_HCIBTUSB_BCM is not set
CONFIG_BT_HCIBTUSB_RTL=y
CONFIG_BT_HCIUART=m
CONFIG_BT_HCIUART_H4=y
# CONFIG_BT_HCIUART_BCSP is not set
CONFIG_BT_HCIUART_ATH3K=y
CONFIG_BT_HCIUART_LL=y
CONFIG_BT_HCIUART_3WIRE=y
CONFIG_BT_HCIUART_INTEL=y
# CONFIG_BT_HCIUART_BCM is not set
CONFIG_BT_HCIUART_QCA=y
# CONFIG_BT_HCIUART_AG6XX is not set
CONFIG_BT_HCIBCM203X=m
# CONFIG_BT_HCIBPA10X is not set
CONFIG_BT_HCIBFUSB=m
CONFIG_BT_HCIDTL1=m
# CONFIG_BT_HCIBT3C is not set
CONFIG_BT_HCIBLUECARD=m
CONFIG_BT_HCIBTUART=m
CONFIG_BT_HCIVHCI=m
# CONFIG_BT_MRVL is not set
# CONFIG_BT_ATH3K is not set
CONFIG_AF_RXRPC=m
# CONFIG_AF_RXRPC_DEBUG is not set
# CONFIG_RXKAD is not set
# CONFIG_AF_KCM is not set
CONFIG_FIB_RULES=y
CONFIG_WIRELESS=y
CONFIG_WEXT_CORE=y
CONFIG_WEXT_PROC=y
CONFIG_CFG80211=m
CONFIG_NL80211_TESTMODE=y
CONFIG_CFG80211_DEVELOPER_WARNINGS=y
# CONFIG_CFG80211_CERTIFICATION_ONUS is not set
CONFIG_CFG80211_DEFAULT_PS=y
CONFIG_CFG80211_DEBUGFS=y
# CONFIG_CFG80211_INTERNAL_REGDB is not set
CONFIG_CFG80211_CRDA_SUPPORT=y
CONFIG_CFG80211_WEXT=y
# CONFIG_LIB80211 is not set
# CONFIG_MAC80211 is not set
CONFIG_MAC80211_STA_HASH_MAX_SIZE=0
CONFIG_WIMAX=m
CONFIG_WIMAX_DEBUG_LEVEL=8
CONFIG_RFKILL=m
CONFIG_RFKILL_LEDS=y
# CONFIG_RFKILL_INPUT is not set
# CONFIG_RFKILL_REGULATOR is not set
# CONFIG_RFKILL_GPIO is not set
CONFIG_NET_9P=y
CONFIG_NET_9P_VIRTIO=y
# CONFIG_NET_9P_DEBUG is not set
CONFIG_CAIF=m
# CONFIG_CAIF_DEBUG is not set
CONFIG_CAIF_NETDEV=m
CONFIG_CAIF_USB=m
CONFIG_CEPH_LIB=m
CONFIG_CEPH_LIB_PRETTYDEBUG=y
# CONFIG_CEPH_LIB_USE_DNS_RESOLVER is not set
CONFIG_NFC=m
# CONFIG_NFC_DIGITAL is not set
CONFIG_NFC_NCI=m
CONFIG_NFC_NCI_UART=m
CONFIG_NFC_HCI=m
# CONFIG_NFC_SHDLC is not set

#
# Near Field Communication (NFC) devices
#
# CONFIG_NFC_SIM is not set
# CONFIG_NFC_FDP is not set
CONFIG_NFC_PN533=m
CONFIG_NFC_PN533_USB=m
CONFIG_NFC_PN533_I2C=m
CONFIG_NFC_MRVL=m
CONFIG_NFC_MRVL_USB=m
CONFIG_NFC_MRVL_UART=m
CONFIG_NFC_MRVL_I2C=m
# CONFIG_NFC_ST_NCI_I2C is not set
CONFIG_NFC_NXP_NCI=m
CONFIG_NFC_NXP_NCI_I2C=m
CONFIG_NFC_S3FWRN5=m
CONFIG_NFC_S3FWRN5_I2C=m
# CONFIG_LWTUNNEL is not set
CONFIG_DST_CACHE=y
CONFIG_NET_DEVLINK=m
CONFIG_MAY_USE_DEVLINK=m
CONFIG_HAVE_EBPF_JIT=y

#
# Device Drivers
#

#
# Generic Driver Options
#
# CONFIG_UEVENT_HELPER is not set
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y
CONFIG_STANDALONE=y
# CONFIG_PREVENT_FIRMWARE_BUILD is not set
CONFIG_FW_LOADER=y
CONFIG_FIRMWARE_IN_KERNEL=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
CONFIG_FW_LOADER_USER_HELPER_FALLBACK=y
# CONFIG_ALLOW_DEV_COREDUMP is not set
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SPMI=m
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y
# CONFIG_FENCE_TRACE is not set

#
# Bus devices
#
CONFIG_CONNECTOR=m
CONFIG_MTD=m
# CONFIG_MTD_TESTS is not set
CONFIG_MTD_REDBOOT_PARTS=m
CONFIG_MTD_REDBOOT_DIRECTORY_BLOCK=-1
CONFIG_MTD_REDBOOT_PARTS_UNALLOCATED=y
CONFIG_MTD_REDBOOT_PARTS_READONLY=y
CONFIG_MTD_CMDLINE_PARTS=m
CONFIG_MTD_OF_PARTS=m
CONFIG_MTD_AR7_PARTS=m

#
# User Modules And Translation Layers
#
# CONFIG_MTD_OOPS is not set
# CONFIG_MTD_PARTITIONED_MASTER is not set

#
# RAM/ROM/Flash chip drivers
#
# CONFIG_MTD_CFI is not set
# CONFIG_MTD_JEDECPROBE is not set
CONFIG_MTD_MAP_BANK_WIDTH_1=y
CONFIG_MTD_MAP_BANK_WIDTH_2=y
CONFIG_MTD_MAP_BANK_WIDTH_4=y
# CONFIG_MTD_MAP_BANK_WIDTH_8 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_16 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_32 is not set
CONFIG_MTD_CFI_I1=y
CONFIG_MTD_CFI_I2=y
# CONFIG_MTD_CFI_I4 is not set
# CONFIG_MTD_CFI_I8 is not set
CONFIG_MTD_RAM=m
# CONFIG_MTD_ROM is not set
CONFIG_MTD_ABSENT=m

#
# Mapping drivers for chip access
#
# CONFIG_MTD_COMPLEX_MAPPINGS is not set
# CONFIG_MTD_PHYSMAP_OF is not set
# CONFIG_MTD_INTEL_VR_NOR is not set
# CONFIG_MTD_PLATRAM is not set

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_PMC551 is not set
# CONFIG_MTD_SLRAM is not set
# CONFIG_MTD_PHRAM is not set
# CONFIG_MTD_MTDRAM is not set

#
# Disk-On-Chip Device Drivers
#
CONFIG_MTD_DOCG3=m
CONFIG_BCH_CONST_M=14
CONFIG_BCH_CONST_T=4
# CONFIG_MTD_NAND is not set
# CONFIG_MTD_ONENAND is not set

#
# LPDDR & LPDDR2 PCM memory drivers
#
# CONFIG_MTD_LPDDR is not set
CONFIG_MTD_SPI_NOR=m
# CONFIG_MTD_MT81xx_NOR is not set
CONFIG_MTD_SPI_NOR_USE_4K_SECTORS=y
CONFIG_MTD_UBI=m
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_LIMIT=20
CONFIG_MTD_UBI_FASTMAP=y
CONFIG_MTD_UBI_GLUEBI=m
CONFIG_OF=y
# CONFIG_OF_UNITTEST is not set
CONFIG_OF_DYNAMIC=y
CONFIG_OF_ADDRESS=y
CONFIG_OF_ADDRESS_PCI=y
CONFIG_OF_IRQ=y
CONFIG_OF_NET=y
CONFIG_OF_MDIO=m
CONFIG_OF_PCI=y
CONFIG_OF_PCI_IRQ=y
CONFIG_OF_MTD=y
CONFIG_OF_RESOLVE=y
CONFIG_OF_OVERLAY=y
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT=m
# CONFIG_PARPORT_PC is not set
# CONFIG_PARPORT_GSC is not set
CONFIG_PARPORT_AX88796=m
# CONFIG_PARPORT_1284 is not set
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=m
CONFIG_AD525X_DPOT=y
# CONFIG_AD525X_DPOT_I2C is not set
CONFIG_DUMMY_IRQ=y
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
CONFIG_ICS932S401=m
CONFIG_ENCLOSURE_SERVICES=y
# CONFIG_HP_ILO is not set
# CONFIG_APDS9802ALS is not set
CONFIG_ISL29003=m
CONFIG_ISL29020=m
# CONFIG_SENSORS_TSL2550 is not set
# CONFIG_SENSORS_BH1780 is not set
# CONFIG_SENSORS_BH1770 is not set
CONFIG_SENSORS_APDS990X=m
CONFIG_HMC6352=y
CONFIG_DS1682=m
# CONFIG_BMP085_I2C is not set
CONFIG_USB_SWITCH_FSA9480=y
# CONFIG_SRAM is not set
CONFIG_PANEL=m
CONFIG_PANEL_PARPORT=0
CONFIG_PANEL_PROFILE=5
CONFIG_PANEL_CHANGE_MESSAGE=y
CONFIG_PANEL_BOOT_MESSAGE=""
CONFIG_C2PORT=y
CONFIG_C2PORT_DURAMAR_2150=m

#
# EEPROM support
#
CONFIG_EEPROM_AT24=y
CONFIG_EEPROM_LEGACY=y
CONFIG_EEPROM_MAX6875=m
CONFIG_EEPROM_93CX6=m
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
CONFIG_SENSORS_LIS3_I2C=m

#
# Altera FPGA firmware download module
#
# CONFIG_ALTERA_STAPL is not set
# CONFIG_INTEL_MEI is not set
# CONFIG_INTEL_MEI_ME is not set
# CONFIG_INTEL_MEI_TXE is not set
# CONFIG_VMWARE_VMCI is not set

#
# Intel MIC Bus Driver
#
# CONFIG_INTEL_MIC_BUS is not set

#
# SCIF Bus Driver
#
# CONFIG_SCIF_BUS is not set

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
# CONFIG_GENWQE is not set
CONFIG_ECHO=m
# CONFIG_CXL_BASE is not set
# CONFIG_CXL_KERNEL_API is not set
# CONFIG_CXL_EEH is not set
CONFIG_HAVE_IDE=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
# CONFIG_SCSI_DMA is not set
# CONFIG_SCSI_NETLINK is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_FIREWIRE_NOSY is not set
# CONFIG_MACINTOSH_DRIVERS is not set
CONFIG_NETDEVICES=y
CONFIG_MII=m
CONFIG_NET_CORE=y
CONFIG_BONDING=m
CONFIG_DUMMY=m
CONFIG_EQUALIZER=m
CONFIG_NET_TEAM=m
CONFIG_NET_TEAM_MODE_BROADCAST=m
CONFIG_NET_TEAM_MODE_ROUNDROBIN=m
CONFIG_NET_TEAM_MODE_RANDOM=m
CONFIG_NET_TEAM_MODE_ACTIVEBACKUP=m
CONFIG_NET_TEAM_MODE_LOADBALANCE=m
# CONFIG_MACVLAN is not set
CONFIG_VXLAN=y
# CONFIG_GENEVE is not set
# CONFIG_GTP is not set
CONFIG_MACSEC=y
CONFIG_NETCONSOLE=y
CONFIG_NETPOLL=y
CONFIG_NET_POLL_CONTROLLER=y
CONFIG_TUN=y
# CONFIG_TUN_VNET_CROSS_LE is not set
CONFIG_VETH=y
CONFIG_VIRTIO_NET=y
# CONFIG_NLMON is not set
CONFIG_ARCNET=m
CONFIG_ARCNET_1201=m
CONFIG_ARCNET_1051=m
CONFIG_ARCNET_RAW=m
# CONFIG_ARCNET_CAP is not set
# CONFIG_ARCNET_COM90xx is not set
CONFIG_ARCNET_COM90xxIO=m
CONFIG_ARCNET_RIM_I=m
CONFIG_ARCNET_COM20020=m
# CONFIG_ARCNET_COM20020_PCI is not set
CONFIG_ARCNET_COM20020_CS=m

#
# CAIF transport drivers
#
CONFIG_CAIF_TTY=m
CONFIG_CAIF_SPI_SLAVE=m
CONFIG_CAIF_SPI_SYNC=y
CONFIG_CAIF_HSI=m
CONFIG_CAIF_VIRTIO=m
# CONFIG_VHOST_NET is not set
CONFIG_VHOST_RING=m
# CONFIG_VHOST_CROSS_ENDIAN_LEGACY is not set

#
# Distributed Switch Architecture drivers
#
CONFIG_ETHERNET=y
CONFIG_MDIO=m
CONFIG_NET_VENDOR_3COM=y
# CONFIG_PCMCIA_3C574 is not set
# CONFIG_PCMCIA_3C589 is not set
# CONFIG_VORTEX is not set
# CONFIG_TYPHOON is not set
CONFIG_NET_VENDOR_ADAPTEC=y
# CONFIG_ADAPTEC_STARFIRE is not set
CONFIG_NET_VENDOR_AGERE=y
# CONFIG_ET131X is not set
CONFIG_NET_VENDOR_ALTEON=y
# CONFIG_ACENIC is not set
# CONFIG_ALTERA_TSE is not set
CONFIG_NET_VENDOR_AMD=y
# CONFIG_AMD8111_ETH is not set
# CONFIG_PCNET32 is not set
# CONFIG_PCMCIA_NMCLAN is not set
CONFIG_NET_VENDOR_ARC=y
# CONFIG_ARC_EMAC is not set
# CONFIG_EMAC_ROCKCHIP is not set
CONFIG_NET_VENDOR_ATHEROS=y
# CONFIG_ATL2 is not set
# CONFIG_ATL1 is not set
# CONFIG_ATL1E is not set
# CONFIG_ATL1C is not set
# CONFIG_ALX is not set
# CONFIG_NET_VENDOR_AURORA is not set
CONFIG_NET_CADENCE=y
# CONFIG_MACB is not set
CONFIG_NET_VENDOR_BROADCOM=y
# CONFIG_B44 is not set
# CONFIG_BCMGENET is not set
# CONFIG_BNX2 is not set
# CONFIG_CNIC is not set
# CONFIG_TIGON3 is not set
# CONFIG_BNX2X is not set
# CONFIG_SYSTEMPORT is not set
# CONFIG_BNXT is not set
CONFIG_NET_VENDOR_BROCADE=y
# CONFIG_BNA is not set
CONFIG_NET_VENDOR_CAVIUM=y
# CONFIG_THUNDER_NIC_PF is not set
# CONFIG_THUNDER_NIC_VF is not set
# CONFIG_THUNDER_NIC_BGX is not set
# CONFIG_LIQUIDIO is not set
CONFIG_NET_VENDOR_CHELSIO=y
# CONFIG_CHELSIO_T1 is not set
# CONFIG_CHELSIO_T3 is not set
# CONFIG_CHELSIO_T4 is not set
# CONFIG_CHELSIO_T4VF is not set
CONFIG_NET_VENDOR_CISCO=y
# CONFIG_ENIC is not set
# CONFIG_CX_ECAT is not set
# CONFIG_DNET is not set
CONFIG_NET_VENDOR_DEC=y
# CONFIG_NET_TULIP is not set
CONFIG_NET_VENDOR_DLINK=y
# CONFIG_DL2K is not set
# CONFIG_SUNDANCE is not set
CONFIG_NET_VENDOR_EMULEX=y
# CONFIG_BE2NET is not set
CONFIG_NET_VENDOR_EZCHIP=y
# CONFIG_EZCHIP_NPS_MANAGEMENT_ENET is not set
CONFIG_NET_VENDOR_EXAR=y
# CONFIG_S2IO is not set
# CONFIG_VXGE is not set
CONFIG_NET_VENDOR_FUJITSU=y
# CONFIG_PCMCIA_FMVJ18X is not set
CONFIG_NET_VENDOR_HP=y
# CONFIG_HP100 is not set
CONFIG_NET_VENDOR_INTEL=y
# CONFIG_E100 is not set
CONFIG_E1000=m
CONFIG_E1000E=m
CONFIG_E1000E_HWTS=y
CONFIG_IGB=m
CONFIG_IGB_HWMON=y
# CONFIG_IGBVF is not set
# CONFIG_IXGB is not set
CONFIG_IXGBE=m
# CONFIG_IXGBE_VXLAN is not set
CONFIG_IXGBE_HWMON=y
# CONFIG_I40E is not set
CONFIG_NET_VENDOR_I825XX=y
# CONFIG_JME is not set
CONFIG_NET_VENDOR_MARVELL=y
# CONFIG_MVMDIO is not set
# CONFIG_MVNETA_BM is not set
# CONFIG_SKGE is not set
# CONFIG_SKY2 is not set
CONFIG_NET_VENDOR_MELLANOX=y
# CONFIG_MLX4_EN is not set
# CONFIG_MLX4_CORE is not set
# CONFIG_MLX5_CORE is not set
# CONFIG_MLXSW_CORE is not set
CONFIG_NET_VENDOR_MICREL=y
# CONFIG_KS8842 is not set
# CONFIG_KS8851_MLL is not set
# CONFIG_KSZ884X_PCI is not set
CONFIG_NET_VENDOR_MYRI=y
# CONFIG_MYRI10GE is not set
# CONFIG_FEALNX is not set
CONFIG_NET_VENDOR_NATSEMI=y
# CONFIG_NATSEMI is not set
# CONFIG_NS83820 is not set
CONFIG_NET_VENDOR_NETRONOME=y
CONFIG_NET_VENDOR_8390=y
# CONFIG_PCMCIA_AXNET is not set
# CONFIG_NE2K_PCI is not set
# CONFIG_PCMCIA_PCNET is not set
CONFIG_NET_VENDOR_NVIDIA=y
# CONFIG_FORCEDETH is not set
CONFIG_NET_VENDOR_OKI=y
# CONFIG_ETHOC is not set
CONFIG_NET_PACKET_ENGINE=y
# CONFIG_HAMACHI is not set
# CONFIG_YELLOWFIN is not set
CONFIG_NET_VENDOR_QLOGIC=y
# CONFIG_QLA3XXX is not set
# CONFIG_QLCNIC is not set
# CONFIG_QLGE is not set
# CONFIG_NETXEN_NIC is not set
# CONFIG_QED is not set
CONFIG_NET_VENDOR_QUALCOMM=y
CONFIG_NET_VENDOR_REALTEK=y
# CONFIG_ATP is not set
# CONFIG_8139CP is not set
# CONFIG_8139TOO is not set
# CONFIG_R8169 is not set
CONFIG_NET_VENDOR_RENESAS=y
CONFIG_NET_VENDOR_RDC=y
# CONFIG_R6040 is not set
CONFIG_NET_VENDOR_ROCKER=y
# CONFIG_ROCKER is not set
CONFIG_NET_VENDOR_SAMSUNG=y
# CONFIG_SXGBE_ETH is not set
CONFIG_NET_VENDOR_SEEQ=y
CONFIG_NET_VENDOR_SILAN=y
# CONFIG_SC92031 is not set
CONFIG_NET_VENDOR_SIS=y
# CONFIG_SIS900 is not set
# CONFIG_SIS190 is not set
# CONFIG_SFC is not set
CONFIG_NET_VENDOR_SMSC=y
# CONFIG_PCMCIA_SMC91C92 is not set
# CONFIG_EPIC100 is not set
# CONFIG_SMSC911X is not set
# CONFIG_SMSC9420 is not set
CONFIG_NET_VENDOR_STMICRO=y
# CONFIG_STMMAC_ETH is not set
CONFIG_NET_VENDOR_SUN=y
# CONFIG_HAPPYMEAL is not set
# CONFIG_SUNGEM is not set
# CONFIG_CASSINI is not set
# CONFIG_NIU is not set
CONFIG_NET_VENDOR_SYNOPSYS=y
# CONFIG_SYNOPSYS_DWC_ETH_QOS is not set
CONFIG_NET_VENDOR_TEHUTI=y
# CONFIG_TEHUTI is not set
CONFIG_NET_VENDOR_TI=y
# CONFIG_TI_CPSW_ALE is not set
# CONFIG_TLAN is not set
CONFIG_NET_VENDOR_VIA=y
# CONFIG_VIA_RHINE is not set
# CONFIG_VIA_VELOCITY is not set
CONFIG_NET_VENDOR_WIZNET=y
# CONFIG_WIZNET_W5100 is not set
# CONFIG_WIZNET_W5300 is not set
CONFIG_NET_VENDOR_XIRCOM=y
# CONFIG_PCMCIA_XIRC2PS is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_NET_SB1000 is not set
CONFIG_PHYLIB=m

#
# MII PHY device drivers
#
CONFIG_AQUANTIA_PHY=m
CONFIG_AT803X_PHY=m
# CONFIG_AMD_PHY is not set
CONFIG_MARVELL_PHY=m
CONFIG_DAVICOM_PHY=m
CONFIG_QSEMI_PHY=m
CONFIG_LXT_PHY=m
CONFIG_CICADA_PHY=m
CONFIG_VITESSE_PHY=m
CONFIG_TERANETICS_PHY=m
CONFIG_SMSC_PHY=m
CONFIG_BCM_NET_PHYLIB=m
CONFIG_BROADCOM_PHY=m
CONFIG_BCM7XXX_PHY=m
# CONFIG_BCM87XX_PHY is not set
CONFIG_ICPLUS_PHY=m
CONFIG_REALTEK_PHY=m
CONFIG_NATIONAL_PHY=m
# CONFIG_STE10XP is not set
CONFIG_LSI_ET1011C_PHY=m
# CONFIG_MICREL_PHY is not set
CONFIG_DP83848_PHY=m
CONFIG_DP83867_PHY=m
CONFIG_MICROCHIP_PHY=m
CONFIG_FIXED_PHY=m
CONFIG_MDIO_BITBANG=m
# CONFIG_MDIO_GPIO is not set
CONFIG_MDIO_CAVIUM=m
CONFIG_MDIO_OCTEON=m
# CONFIG_MDIO_THUNDER is not set
CONFIG_MDIO_BUS_MUX=m
CONFIG_MDIO_BUS_MUX_GPIO=m
CONFIG_MDIO_BUS_MUX_MMIOREG=m
CONFIG_MDIO_BCM_UNIMAC=m
CONFIG_PLIP=m
CONFIG_PPP=y
CONFIG_PPP_BSDCOMP=y
CONFIG_PPP_DEFLATE=m
# CONFIG_PPP_FILTER is not set
CONFIG_PPP_MPPE=m
# CONFIG_PPP_MULTILINK is not set
CONFIG_PPPOE=m
CONFIG_PPPOL2TP=m
CONFIG_PPP_ASYNC=m
# CONFIG_PPP_SYNC_TTY is not set
# CONFIG_SLIP is not set
CONFIG_SLHC=y

#
# Host-side USB support is needed for USB Network Adapter support
#
CONFIG_USB_NET_DRIVERS=m
CONFIG_USB_CATC=m
CONFIG_USB_KAWETH=m
CONFIG_USB_PEGASUS=m
# CONFIG_USB_RTL8150 is not set
# CONFIG_USB_RTL8152 is not set
CONFIG_USB_LAN78XX=m
CONFIG_USB_USBNET=m
# CONFIG_USB_NET_AX8817X is not set
CONFIG_USB_NET_AX88179_178A=m
CONFIG_USB_NET_CDCETHER=m
CONFIG_USB_NET_CDC_EEM=m
CONFIG_USB_NET_CDC_NCM=m
# CONFIG_USB_NET_HUAWEI_CDC_NCM is not set
CONFIG_USB_NET_CDC_MBIM=m
# CONFIG_USB_NET_DM9601 is not set
# CONFIG_USB_NET_SR9700 is not set
CONFIG_USB_NET_SR9800=m
CONFIG_USB_NET_SMSC75XX=m
CONFIG_USB_NET_SMSC95XX=m
CONFIG_USB_NET_GL620A=m
CONFIG_USB_NET_NET1080=m
# CONFIG_USB_NET_PLUSB is not set
CONFIG_USB_NET_MCS7830=m
# CONFIG_USB_NET_RNDIS_HOST is not set
# CONFIG_USB_NET_CDC_SUBSET is not set
# CONFIG_USB_NET_ZAURUS is not set
# CONFIG_USB_NET_CX82310_ETH is not set
CONFIG_USB_NET_KALMIA=m
# CONFIG_USB_NET_QMI_WWAN is not set
CONFIG_USB_HSO=m
CONFIG_USB_NET_INT51X1=m
# CONFIG_USB_CDC_PHONET is not set
CONFIG_USB_IPHETH=m
# CONFIG_USB_SIERRA_NET is not set
CONFIG_USB_VL600=m
# CONFIG_USB_NET_CH9200 is not set
# CONFIG_WLAN is not set

#
# WiMAX Wireless Broadband devices
#
CONFIG_WIMAX_I2400M=m
CONFIG_WIMAX_I2400M_USB=m
CONFIG_WIMAX_I2400M_DEBUG_LEVEL=8
# CONFIG_WAN is not set
CONFIG_IEEE802154_DRIVERS=m
CONFIG_IEEE802154_FAKELB=m
CONFIG_IEEE802154_ATUSB=m
# CONFIG_VMXNET3 is not set
# CONFIG_FUJITSU_ES is not set
# CONFIG_ISDN is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_LEDS=m
CONFIG_INPUT_FF_MEMLESS=m
CONFIG_INPUT_POLLDEV=m
CONFIG_INPUT_SPARSEKMAP=m
CONFIG_INPUT_MATRIXKMAP=m

#
# Userland interfaces
#
# CONFIG_INPUT_MOUSEDEV is not set
CONFIG_INPUT_JOYDEV=m
# CONFIG_INPUT_EVDEV is not set
CONFIG_INPUT_EVBUG=m

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADP5520 is not set
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
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_OMAP4 is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_CROS_EC is not set
# CONFIG_KEYBOARD_CAP11XX is not set
# CONFIG_INPUT_MOUSE is not set
CONFIG_INPUT_JOYSTICK=y
# CONFIG_JOYSTICK_ANALOG is not set
CONFIG_JOYSTICK_A3D=m
CONFIG_JOYSTICK_ADI=m
CONFIG_JOYSTICK_COBRA=m
CONFIG_JOYSTICK_GF2K=m
CONFIG_JOYSTICK_GRIP=m
# CONFIG_JOYSTICK_GRIP_MP is not set
CONFIG_JOYSTICK_GUILLEMOT=m
CONFIG_JOYSTICK_INTERACT=m
CONFIG_JOYSTICK_SIDEWINDER=m
# CONFIG_JOYSTICK_TMDC is not set
# CONFIG_JOYSTICK_IFORCE is not set
# CONFIG_JOYSTICK_WARRIOR is not set
CONFIG_JOYSTICK_MAGELLAN=m
# CONFIG_JOYSTICK_SPACEORB is not set
CONFIG_JOYSTICK_SPACEBALL=m
CONFIG_JOYSTICK_STINGER=m
# CONFIG_JOYSTICK_TWIDJOY is not set
CONFIG_JOYSTICK_ZHENHUA=m
CONFIG_JOYSTICK_DB9=m
CONFIG_JOYSTICK_GAMECON=m
# CONFIG_JOYSTICK_TURBOGRAFX is not set
# CONFIG_JOYSTICK_AS5011 is not set
CONFIG_JOYSTICK_JOYDUMP=m
CONFIG_JOYSTICK_XPAD=m
# CONFIG_JOYSTICK_XPAD_FF is not set
CONFIG_JOYSTICK_XPAD_LEDS=y
CONFIG_INPUT_TABLET=y
CONFIG_TABLET_USB_ACECAD=m
CONFIG_TABLET_USB_AIPTEK=m
CONFIG_TABLET_USB_GTCO=m
# CONFIG_TABLET_USB_HANWANG is not set
CONFIG_TABLET_USB_KBTAB=m
CONFIG_TABLET_SERIAL_WACOM4=m
# CONFIG_INPUT_TOUCHSCREEN is not set
CONFIG_INPUT_MISC=y
# CONFIG_INPUT_88PM80X_ONKEY is not set
CONFIG_INPUT_AD714X=m
# CONFIG_INPUT_AD714X_I2C is not set
CONFIG_INPUT_BMA150=m
CONFIG_INPUT_E3X0_BUTTON=m
# CONFIG_INPUT_PCSPKR is not set
# CONFIG_INPUT_MAX77693_HAPTIC is not set
CONFIG_INPUT_MAX8925_ONKEY=m
# CONFIG_INPUT_MAX8997_HAPTIC is not set
CONFIG_INPUT_MC13783_PWRBUTTON=m
CONFIG_INPUT_MMA8450=m
# CONFIG_INPUT_MPU3050 is not set
# CONFIG_INPUT_APANEL is not set
CONFIG_INPUT_GP2A=m
# CONFIG_INPUT_GPIO_BEEPER is not set
CONFIG_INPUT_GPIO_TILT_POLLED=m
# CONFIG_INPUT_ATLAS_BTNS is not set
# CONFIG_INPUT_ATI_REMOTE2 is not set
# CONFIG_INPUT_KEYSPAN_REMOTE is not set
CONFIG_INPUT_KXTJ9=m
# CONFIG_INPUT_KXTJ9_POLLED_MODE is not set
CONFIG_INPUT_POWERMATE=m
# CONFIG_INPUT_YEALINK is not set
# CONFIG_INPUT_CM109 is not set
CONFIG_INPUT_REGULATOR_HAPTIC=m
CONFIG_INPUT_RETU_PWRBUTTON=m
# CONFIG_INPUT_AXP20X_PEK is not set
CONFIG_INPUT_UINPUT=m
CONFIG_INPUT_PCF50633_PMU=m
CONFIG_INPUT_PCF8574=m
CONFIG_INPUT_PWM_BEEPER=m
CONFIG_INPUT_GPIO_ROTARY_ENCODER=m
CONFIG_INPUT_ADXL34X=m
# CONFIG_INPUT_ADXL34X_I2C is not set
CONFIG_INPUT_IMS_PCU=m
CONFIG_INPUT_CMA3000=m
CONFIG_INPUT_CMA3000_I2C=m
CONFIG_INPUT_IDEAPAD_SLIDEBAR=m
# CONFIG_INPUT_DRV260X_HAPTICS is not set
CONFIG_INPUT_DRV2665_HAPTICS=m
CONFIG_INPUT_DRV2667_HAPTICS=m
CONFIG_RMI4_CORE=m
CONFIG_RMI4_I2C=m
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
CONFIG_SERIO_SERPORT=m
CONFIG_SERIO_CT82C710=m
# CONFIG_SERIO_PARKBD is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
# CONFIG_SERIO_RAW is not set
CONFIG_SERIO_ALTERA_PS2=m
# CONFIG_SERIO_PS2MULT is not set
CONFIG_SERIO_ARC_PS2=m
# CONFIG_SERIO_APBPS2 is not set
CONFIG_USERIO=m
CONFIG_GAMEPORT=y
CONFIG_GAMEPORT_NS558=m
# CONFIG_GAMEPORT_L4 is not set
# CONFIG_GAMEPORT_EMU10K1 is not set
# CONFIG_GAMEPORT_FM801 is not set

#
# Character devices
#
CONFIG_TTY=y
# CONFIG_VT is not set
CONFIG_UNIX98_PTYS=y
# CONFIG_DEVPTS_MULTIPLE_INSTANCES is not set
# CONFIG_LEGACY_PTYS is not set
CONFIG_SERIAL_NONSTANDARD=y
# CONFIG_ROCKETPORT is not set
# CONFIG_CYCLADES is not set
# CONFIG_MOXA_INTELLIO is not set
# CONFIG_MOXA_SMARTIO is not set
# CONFIG_SYNCLINK is not set
# CONFIG_SYNCLINKMP is not set
# CONFIG_SYNCLINK_GT is not set
# CONFIG_NOZOMI is not set
# CONFIG_ISI is not set
CONFIG_N_HDLC=y
CONFIG_N_GSM=m
CONFIG_TRACE_ROUTER=m
CONFIG_TRACE_SINK=m
CONFIG_DEVMEM=y
# CONFIG_DEVKMEM is not set

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_DMA=y
CONFIG_SERIAL_8250_PCI=y
# CONFIG_SERIAL_8250_CS is not set
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set
# CONFIG_SERIAL_8250_FSL is not set
# CONFIG_SERIAL_8250_DW is not set
# CONFIG_SERIAL_8250_RT288X is not set
# CONFIG_SERIAL_8250_FINTEK is not set
CONFIG_SERIAL_8250_MID=y
# CONFIG_SERIAL_8250_MOXA is not set
# CONFIG_SERIAL_OF_PLATFORM is not set

#
# Non-8250 serial port support
#
CONFIG_SERIAL_UARTLITE=y
# CONFIG_SERIAL_UARTLITE_CONSOLE is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
CONFIG_SERIAL_SCCNXP=m
# CONFIG_SERIAL_SC16IS7XX is not set
CONFIG_SERIAL_ALTERA_JTAGUART=y
# CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE is not set
CONFIG_SERIAL_ALTERA_UART=m
CONFIG_SERIAL_ALTERA_UART_MAXPORTS=4
CONFIG_SERIAL_ALTERA_UART_BAUDRATE=115200
CONFIG_SERIAL_XILINX_PS_UART=y
CONFIG_SERIAL_XILINX_PS_UART_CONSOLE=y
CONFIG_SERIAL_ARC=m
CONFIG_SERIAL_ARC_NR_PORTS=1
# CONFIG_SERIAL_RP2 is not set
# CONFIG_SERIAL_FSL_LPUART is not set
CONFIG_SERIAL_CONEXANT_DIGICOLOR=y
# CONFIG_SERIAL_CONEXANT_DIGICOLOR_CONSOLE is not set
# CONFIG_SERIAL_MEN_Z135 is not set
# CONFIG_SERIAL_MVEBU_UART is not set
# CONFIG_TTY_PRINTK is not set
# CONFIG_PRINTER is not set
CONFIG_PPDEV=m
# CONFIG_VIRTIO_CONSOLE is not set
# CONFIG_IPMI_HANDLER is not set
CONFIG_HW_RANDOM=m
CONFIG_HW_RANDOM_TIMERIOMEM=m
CONFIG_HW_RANDOM_INTEL=m
CONFIG_HW_RANDOM_AMD=m
CONFIG_HW_RANDOM_VIA=m
# CONFIG_HW_RANDOM_VIRTIO is not set
CONFIG_NVRAM=m
CONFIG_R3964=y
# CONFIG_APPLICOM is not set

#
# PCMCIA character devices
#
CONFIG_SYNCLINK_CS=m
CONFIG_CARDMAN_4000=m
# CONFIG_CARDMAN_4040 is not set
CONFIG_IPWIRELESS=m
# CONFIG_MWAVE is not set
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=m
# CONFIG_TCG_TPM is not set
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y
CONFIG_XILLYBUS=m
CONFIG_XILLYBUS_OF=m

#
# I2C support
#
CONFIG_I2C=y
CONFIG_ACPI_I2C_OPREGION=y
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_COMPAT is not set
CONFIG_I2C_CHARDEV=m
CONFIG_I2C_MUX=m

#
# Multiplexer I2C Chip support
#
CONFIG_I2C_ARB_GPIO_CHALLENGE=m
CONFIG_I2C_MUX_GPIO=m
CONFIG_I2C_MUX_PCA9541=m
CONFIG_I2C_MUX_PCA954x=m
CONFIG_I2C_MUX_REG=m
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_SMBUS=y
CONFIG_I2C_ALGOBIT=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
# CONFIG_I2C_AMD756 is not set
# CONFIG_I2C_AMD8111 is not set
# CONFIG_I2C_I801 is not set
# CONFIG_I2C_ISCH is not set
# CONFIG_I2C_ISMT is not set
# CONFIG_I2C_PIIX4 is not set
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_VIA is not set
# CONFIG_I2C_VIAPRO is not set

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_CBUS_GPIO is not set
# CONFIG_I2C_DESIGNWARE_PCI is not set
# CONFIG_I2C_GPIO is not set
CONFIG_I2C_KEMPLD=m
# CONFIG_I2C_OCORES is not set
# CONFIG_I2C_PCA_PLATFORM is not set
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_SIMTEC=y
CONFIG_I2C_XILINX=m

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_DIOLAN_U2C=m
CONFIG_I2C_DLN2=m
# CONFIG_I2C_PARPORT is not set
CONFIG_I2C_PARPORT_LIGHT=y
CONFIG_I2C_ROBOTFUZZ_OSIF=m
CONFIG_I2C_TAOS_EVM=m
# CONFIG_I2C_TINY_USB is not set
CONFIG_I2C_VIPERBOARD=m

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_CROS_EC_TUNNEL is not set
CONFIG_I2C_STUB=m
CONFIG_I2C_SLAVE=y
# CONFIG_I2C_SLAVE_EEPROM is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_SPI is not set
CONFIG_SPMI=m
CONFIG_HSI=y
CONFIG_HSI_BOARDINFO=y

#
# HSI controllers
#

#
# HSI clients
#
CONFIG_HSI_CHAR=m

#
# PPS support
#
CONFIG_PPS=m
# CONFIG_PPS_DEBUG is not set
# CONFIG_NTP_PPS is not set

#
# PPS clients support
#
# CONFIG_PPS_CLIENT_KTIMER is not set
# CONFIG_PPS_CLIENT_LDISC is not set
# CONFIG_PPS_CLIENT_PARPORT is not set
# CONFIG_PPS_CLIENT_GPIO is not set

#
# PPS generators support
#

#
# PTP clock support
#
CONFIG_PTP_1588_CLOCK=m

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
CONFIG_GPIOLIB=y
CONFIG_GPIO_DEVRES=y
CONFIG_OF_GPIO=y
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
# CONFIG_DEBUG_GPIO is not set
# CONFIG_GPIO_SYSFS is not set
CONFIG_GPIO_GENERIC=y
CONFIG_GPIO_MAX730X=m

#
# Memory mapped GPIO drivers
#
CONFIG_GPIO_74XX_MMIO=m
CONFIG_GPIO_ALTERA=y
# CONFIG_GPIO_AMDPT is not set
CONFIG_GPIO_DWAPB=y
CONFIG_GPIO_GENERIC_PLATFORM=m
CONFIG_GPIO_GRGPIO=y
# CONFIG_GPIO_ICH is not set
# CONFIG_GPIO_LYNXPOINT is not set
CONFIG_GPIO_MENZ127=m
CONFIG_GPIO_SYSCON=m
# CONFIG_GPIO_VX855 is not set
CONFIG_GPIO_XILINX=y
# CONFIG_GPIO_ZX is not set

#
# Port-mapped I/O GPIO drivers
#
# CONFIG_GPIO_104_DIO_48E is not set
# CONFIG_GPIO_104_IDIO_16 is not set
# CONFIG_GPIO_104_IDI_48 is not set
CONFIG_GPIO_F7188X=m
# CONFIG_GPIO_IT87 is not set
# CONFIG_GPIO_SCH is not set
CONFIG_GPIO_SCH311X=y
CONFIG_GPIO_WS16C48=y

#
# I2C GPIO expanders
#
CONFIG_GPIO_ADP5588=m
CONFIG_GPIO_ADNP=m
CONFIG_GPIO_MAX7300=m
# CONFIG_GPIO_MAX732X is not set
CONFIG_GPIO_PCA953X=y
# CONFIG_GPIO_PCA953X_IRQ is not set
# CONFIG_GPIO_PCF857X is not set
# CONFIG_GPIO_SX150X is not set
CONFIG_GPIO_TPIC2810=y

#
# MFD GPIO expanders
#
CONFIG_GPIO_ADP5520=m
CONFIG_GPIO_CRYSTAL_COVE=m
CONFIG_GPIO_DLN2=m
# CONFIG_GPIO_KEMPLD is not set
# CONFIG_GPIO_RC5T583 is not set
CONFIG_GPIO_TPS65086=m
CONFIG_GPIO_TPS6586X=y
# CONFIG_GPIO_TPS65912 is not set
CONFIG_GPIO_WM8350=y
CONFIG_GPIO_WM8994=m

#
# PCI GPIO expanders
#
# CONFIG_GPIO_AMD8111 is not set
# CONFIG_GPIO_BT8XX is not set
# CONFIG_GPIO_INTEL_MID is not set
# CONFIG_GPIO_ML_IOH is not set
# CONFIG_GPIO_RDC321X is not set
# CONFIG_GPIO_SODAVILLE is not set

#
# SPI or I2C GPIO expanders
#
CONFIG_GPIO_MCP23S08=m

#
# USB GPIO expanders
#
# CONFIG_GPIO_VIPERBOARD is not set
CONFIG_W1=y
CONFIG_W1_CON=y

#
# 1-wire Bus Masters
#
# CONFIG_W1_MASTER_MATROX is not set
CONFIG_W1_MASTER_DS2490=m
CONFIG_W1_MASTER_DS2482=m
CONFIG_W1_MASTER_DS1WM=y
CONFIG_W1_MASTER_GPIO=y

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=m
CONFIG_W1_SLAVE_SMEM=y
CONFIG_W1_SLAVE_DS2408=m
# CONFIG_W1_SLAVE_DS2408_READBACK is not set
# CONFIG_W1_SLAVE_DS2413 is not set
CONFIG_W1_SLAVE_DS2406=m
# CONFIG_W1_SLAVE_DS2423 is not set
# CONFIG_W1_SLAVE_DS2431 is not set
CONFIG_W1_SLAVE_DS2433=y
CONFIG_W1_SLAVE_DS2433_CRC=y
# CONFIG_W1_SLAVE_DS2760 is not set
CONFIG_W1_SLAVE_DS2780=y
# CONFIG_W1_SLAVE_DS2781 is not set
# CONFIG_W1_SLAVE_DS28E04 is not set
CONFIG_W1_SLAVE_BQ27000=m
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
# CONFIG_GENERIC_ADC_BATTERY is not set
CONFIG_MAX8925_POWER=m
# CONFIG_WM8350_POWER is not set
CONFIG_TEST_POWER=m
CONFIG_BATTERY_ACT8945A=m
CONFIG_BATTERY_DS2780=y
# CONFIG_BATTERY_DS2781 is not set
CONFIG_BATTERY_DS2782=m
CONFIG_BATTERY_SBS=y
CONFIG_BATTERY_BQ27XXX=y
CONFIG_BATTERY_BQ27XXX_I2C=y
# CONFIG_CHARGER_DA9150 is not set
# CONFIG_BATTERY_DA9150 is not set
# CONFIG_AXP288_FUEL_GAUGE is not set
CONFIG_BATTERY_MAX17040=y
# CONFIG_BATTERY_MAX17042 is not set
CONFIG_CHARGER_PCF50633=m
CONFIG_CHARGER_ISP1704=m
# CONFIG_CHARGER_MAX8903 is not set
CONFIG_CHARGER_LP8727=m
# CONFIG_CHARGER_GPIO is not set
# CONFIG_CHARGER_MANAGER is not set
CONFIG_CHARGER_MAX77693=m
CONFIG_CHARGER_MAX8997=m
# CONFIG_CHARGER_MAX8998 is not set
# CONFIG_CHARGER_BQ2415X is not set
# CONFIG_CHARGER_BQ24190 is not set
CONFIG_CHARGER_BQ24257=m
CONFIG_CHARGER_BQ24735=m
CONFIG_CHARGER_BQ25890=m
CONFIG_CHARGER_SMB347=y
CONFIG_CHARGER_TPS65090=y
CONFIG_CHARGER_TPS65217=m
CONFIG_BATTERY_GAUGE_LTC2941=y
CONFIG_CHARGER_RT9455=y
CONFIG_AXP20X_POWER=m
CONFIG_POWER_RESET=y
CONFIG_POWER_RESET_AS3722=y
CONFIG_POWER_RESET_GPIO=y
# CONFIG_POWER_RESET_GPIO_RESTART is not set
# CONFIG_POWER_RESET_LTC2952 is not set
CONFIG_POWER_RESET_RESTART=y
CONFIG_POWER_RESET_SYSCON=y
# CONFIG_POWER_RESET_SYSCON_POWEROFF is not set
CONFIG_POWER_AVS=y
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
CONFIG_HWMON_DEBUG_CHIP=y

#
# Native drivers
#
CONFIG_SENSORS_ABITUGURU=y
CONFIG_SENSORS_ABITUGURU3=y
# CONFIG_SENSORS_AD7414 is not set
CONFIG_SENSORS_AD7418=m
CONFIG_SENSORS_ADM1021=m
# CONFIG_SENSORS_ADM1025 is not set
CONFIG_SENSORS_ADM1026=m
CONFIG_SENSORS_ADM1029=m
CONFIG_SENSORS_ADM1031=y
CONFIG_SENSORS_ADM9240=m
# CONFIG_SENSORS_ADT7410 is not set
# CONFIG_SENSORS_ADT7411 is not set
CONFIG_SENSORS_ADT7462=m
# CONFIG_SENSORS_ADT7470 is not set
# CONFIG_SENSORS_ADT7475 is not set
CONFIG_SENSORS_ASC7621=y
# CONFIG_SENSORS_K8TEMP is not set
# CONFIG_SENSORS_K10TEMP is not set
# CONFIG_SENSORS_FAM15H_POWER is not set
CONFIG_SENSORS_APPLESMC=m
CONFIG_SENSORS_ASB100=m
CONFIG_SENSORS_ATXP1=m
CONFIG_SENSORS_DS620=m
CONFIG_SENSORS_DS1621=m
# CONFIG_SENSORS_DELL_SMM is not set
# CONFIG_SENSORS_I5K_AMB is not set
CONFIG_SENSORS_F71805F=m
# CONFIG_SENSORS_F71882FG is not set
CONFIG_SENSORS_F75375S=m
CONFIG_SENSORS_MC13783_ADC=m
# CONFIG_SENSORS_FSCHMD is not set
CONFIG_SENSORS_GL518SM=y
CONFIG_SENSORS_GL520SM=y
# CONFIG_SENSORS_G760A is not set
CONFIG_SENSORS_G762=y
CONFIG_SENSORS_GPIO_FAN=y
CONFIG_SENSORS_HIH6130=m
CONFIG_SENSORS_IIO_HWMON=m
# CONFIG_SENSORS_I5500 is not set
CONFIG_SENSORS_CORETEMP=m
CONFIG_SENSORS_IT87=y
# CONFIG_SENSORS_JC42 is not set
CONFIG_SENSORS_POWR1220=y
# CONFIG_SENSORS_LINEAGE is not set
CONFIG_SENSORS_LTC2945=m
# CONFIG_SENSORS_LTC2990 is not set
# CONFIG_SENSORS_LTC4151 is not set
CONFIG_SENSORS_LTC4215=y
CONFIG_SENSORS_LTC4222=y
# CONFIG_SENSORS_LTC4245 is not set
# CONFIG_SENSORS_LTC4260 is not set
CONFIG_SENSORS_LTC4261=m
CONFIG_SENSORS_MAX16065=m
CONFIG_SENSORS_MAX1619=m
# CONFIG_SENSORS_MAX1668 is not set
CONFIG_SENSORS_MAX197=m
# CONFIG_SENSORS_MAX6639 is not set
CONFIG_SENSORS_MAX6642=m
# CONFIG_SENSORS_MAX6650 is not set
CONFIG_SENSORS_MAX6697=y
CONFIG_SENSORS_MAX31790=m
CONFIG_SENSORS_MCP3021=m
CONFIG_SENSORS_LM63=m
# CONFIG_SENSORS_LM73 is not set
CONFIG_SENSORS_LM75=m
CONFIG_SENSORS_LM77=m
# CONFIG_SENSORS_LM78 is not set
CONFIG_SENSORS_LM80=y
# CONFIG_SENSORS_LM83 is not set
CONFIG_SENSORS_LM85=y
CONFIG_SENSORS_LM87=y
CONFIG_SENSORS_LM90=y
CONFIG_SENSORS_LM92=m
CONFIG_SENSORS_LM93=m
CONFIG_SENSORS_LM95234=y
CONFIG_SENSORS_LM95241=m
# CONFIG_SENSORS_LM95245 is not set
CONFIG_SENSORS_PC87360=y
CONFIG_SENSORS_PC87427=m
# CONFIG_SENSORS_NTC_THERMISTOR is not set
# CONFIG_SENSORS_NCT6683 is not set
CONFIG_SENSORS_NCT6775=y
CONFIG_SENSORS_NCT7802=y
CONFIG_SENSORS_NCT7904=y
CONFIG_SENSORS_PCF8591=y
# CONFIG_PMBUS is not set
CONFIG_SENSORS_PWM_FAN=y
# CONFIG_SENSORS_SHT15 is not set
CONFIG_SENSORS_SHT21=y
CONFIG_SENSORS_SHTC1=y
# CONFIG_SENSORS_SIS5595 is not set
# CONFIG_SENSORS_DME1737 is not set
CONFIG_SENSORS_EMC1403=m
# CONFIG_SENSORS_EMC2103 is not set
# CONFIG_SENSORS_EMC6W201 is not set
CONFIG_SENSORS_SMSC47M1=m
CONFIG_SENSORS_SMSC47M192=m
# CONFIG_SENSORS_SMSC47B397 is not set
# CONFIG_SENSORS_SCH56XX_COMMON is not set
CONFIG_SENSORS_SMM665=y
CONFIG_SENSORS_ADC128D818=y
CONFIG_SENSORS_ADS1015=m
CONFIG_SENSORS_ADS7828=y
CONFIG_SENSORS_AMC6821=y
CONFIG_SENSORS_INA209=m
CONFIG_SENSORS_INA2XX=y
CONFIG_SENSORS_TC74=m
CONFIG_SENSORS_THMC50=y
CONFIG_SENSORS_TMP102=m
CONFIG_SENSORS_TMP103=m
CONFIG_SENSORS_TMP401=m
# CONFIG_SENSORS_TMP421 is not set
# CONFIG_SENSORS_VIA_CPUTEMP is not set
# CONFIG_SENSORS_VIA686A is not set
CONFIG_SENSORS_VT1211=y
# CONFIG_SENSORS_VT8231 is not set
CONFIG_SENSORS_W83781D=m
# CONFIG_SENSORS_W83791D is not set
# CONFIG_SENSORS_W83792D is not set
CONFIG_SENSORS_W83793=y
# CONFIG_SENSORS_W83795 is not set
CONFIG_SENSORS_W83L785TS=m
# CONFIG_SENSORS_W83L786NG is not set
CONFIG_SENSORS_W83627HF=y
CONFIG_SENSORS_W83627EHF=m
CONFIG_SENSORS_WM8350=m

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
# CONFIG_THERMAL_HWMON is not set
CONFIG_THERMAL_OF=y
CONFIG_THERMAL_WRITABLE_TRIPS=y
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR is not set
CONFIG_THERMAL_GOV_FAIR_SHARE=y
CONFIG_THERMAL_GOV_STEP_WISE=y
# CONFIG_THERMAL_GOV_BANG_BANG is not set
CONFIG_THERMAL_GOV_USER_SPACE=y
CONFIG_THERMAL_GOV_POWER_ALLOCATOR=y
CONFIG_THERMAL_EMULATION=y
# CONFIG_INTEL_POWERCLAMP is not set
# CONFIG_X86_PKG_TEMP_THERMAL is not set
CONFIG_INTEL_SOC_DTS_IOSF_CORE=m
CONFIG_INTEL_SOC_DTS_THERMAL=m

#
# ACPI INT340X thermal drivers
#
# CONFIG_INT340X_THERMAL is not set
# CONFIG_INTEL_PCH_THERMAL is not set
# CONFIG_QCOM_SPMI_TEMP_ALARM is not set
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
# CONFIG_BCMA is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
CONFIG_MFD_ACT8945A=m
CONFIG_MFD_AS3711=y
CONFIG_MFD_AS3722=y
CONFIG_PMIC_ADP5520=y
# CONFIG_MFD_AAT2870_CORE is not set
CONFIG_MFD_ATMEL_FLEXCOM=y
CONFIG_MFD_ATMEL_HLCDC=y
CONFIG_MFD_BCM590XX=m
CONFIG_MFD_AXP20X=m
CONFIG_MFD_AXP20X_I2C=m
CONFIG_MFD_CROS_EC=y
CONFIG_MFD_CROS_EC_I2C=m
# CONFIG_PMIC_DA903X is not set
# CONFIG_MFD_DA9052_I2C is not set
# CONFIG_MFD_DA9055 is not set
# CONFIG_MFD_DA9062 is not set
# CONFIG_MFD_DA9063 is not set
CONFIG_MFD_DA9150=y
CONFIG_MFD_DLN2=m
CONFIG_MFD_MC13XXX=m
CONFIG_MFD_MC13XXX_I2C=m
CONFIG_MFD_HI6421_PMIC=m
CONFIG_HTC_PASIC3=m
CONFIG_HTC_I2CPLD=y
# CONFIG_LPC_ICH is not set
# CONFIG_LPC_SCH is not set
CONFIG_INTEL_SOC_PMIC=y
# CONFIG_MFD_INTEL_LPSS_ACPI is not set
# CONFIG_MFD_INTEL_LPSS_PCI is not set
# CONFIG_MFD_JANZ_CMODIO is not set
CONFIG_MFD_KEMPLD=m
CONFIG_MFD_88PM800=y
CONFIG_MFD_88PM805=m
# CONFIG_MFD_88PM860X is not set
# CONFIG_MFD_MAX14577 is not set
CONFIG_MFD_MAX77620=y
# CONFIG_MFD_MAX77686 is not set
CONFIG_MFD_MAX77693=y
CONFIG_MFD_MAX77843=y
# CONFIG_MFD_MAX8907 is not set
CONFIG_MFD_MAX8925=y
CONFIG_MFD_MAX8997=y
CONFIG_MFD_MAX8998=y
CONFIG_MFD_MT6397=m
# CONFIG_MFD_MENF21BMC is not set
CONFIG_MFD_VIPERBOARD=m
CONFIG_MFD_RETU=m
CONFIG_MFD_PCF50633=m
# CONFIG_PCF50633_ADC is not set
# CONFIG_PCF50633_GPIO is not set
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_RTSX_PCI is not set
# CONFIG_MFD_RT5033 is not set
# CONFIG_MFD_RTSX_USB is not set
CONFIG_MFD_RC5T583=y
CONFIG_MFD_RK808=m
CONFIG_MFD_RN5T618=m
CONFIG_MFD_SEC_CORE=y
CONFIG_MFD_SI476X_CORE=y
CONFIG_MFD_SM501=y
CONFIG_MFD_SM501_GPIO=y
# CONFIG_MFD_SKY81452 is not set
# CONFIG_MFD_SMSC is not set
CONFIG_ABX500_CORE=y
# CONFIG_AB3100_CORE is not set
# CONFIG_MFD_STMPE is not set
CONFIG_MFD_SYSCON=y
CONFIG_MFD_TI_AM335X_TSCADC=y
# CONFIG_MFD_LP3943 is not set
# CONFIG_MFD_LP8788 is not set
# CONFIG_MFD_PALMAS is not set
CONFIG_TPS6105X=m
# CONFIG_TPS65010 is not set
CONFIG_TPS6507X=m
CONFIG_MFD_TPS65086=m
CONFIG_MFD_TPS65090=y
CONFIG_MFD_TPS65217=y
# CONFIG_MFD_TPS65218 is not set
CONFIG_MFD_TPS6586X=y
# CONFIG_MFD_TPS65910 is not set
CONFIG_MFD_TPS65912=y
CONFIG_MFD_TPS65912_I2C=y
# CONFIG_MFD_TPS80031 is not set
# CONFIG_TWL4030_CORE is not set
# CONFIG_TWL6040_CORE is not set
# CONFIG_MFD_WL1273_CORE is not set
CONFIG_MFD_LM3533=m
# CONFIG_MFD_TC3589X is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_VX855 is not set
# CONFIG_MFD_ARIZONA_I2C is not set
CONFIG_MFD_WM8400=y
# CONFIG_MFD_WM831X_I2C is not set
CONFIG_MFD_WM8350=y
CONFIG_MFD_WM8350_I2C=y
CONFIG_MFD_WM8994=y
CONFIG_REGULATOR=y
# CONFIG_REGULATOR_DEBUG is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=y
# CONFIG_REGULATOR_VIRTUAL_CONSUMER is not set
# CONFIG_REGULATOR_USERSPACE_CONSUMER is not set
# CONFIG_REGULATOR_88PM800 is not set
CONFIG_REGULATOR_ACT8865=m
CONFIG_REGULATOR_ACT8945A=m
CONFIG_REGULATOR_AD5398=y
CONFIG_REGULATOR_ANATOP=m
CONFIG_REGULATOR_AS3711=y
CONFIG_REGULATOR_AS3722=y
# CONFIG_REGULATOR_AXP20X is not set
CONFIG_REGULATOR_BCM590XX=m
# CONFIG_REGULATOR_DA9210 is not set
# CONFIG_REGULATOR_DA9211 is not set
# CONFIG_REGULATOR_FAN53555 is not set
CONFIG_REGULATOR_GPIO=m
# CONFIG_REGULATOR_HI6421 is not set
# CONFIG_REGULATOR_ISL9305 is not set
CONFIG_REGULATOR_ISL6271A=m
CONFIG_REGULATOR_LP3971=m
CONFIG_REGULATOR_LP3972=m
CONFIG_REGULATOR_LP872X=m
CONFIG_REGULATOR_LP8755=m
CONFIG_REGULATOR_LTC3589=y
# CONFIG_REGULATOR_MAX1586 is not set
CONFIG_REGULATOR_MAX77620=y
CONFIG_REGULATOR_MAX8649=y
CONFIG_REGULATOR_MAX8660=y
CONFIG_REGULATOR_MAX8925=m
CONFIG_REGULATOR_MAX8952=y
# CONFIG_REGULATOR_MAX8973 is not set
CONFIG_REGULATOR_MAX8997=m
CONFIG_REGULATOR_MAX8998=y
CONFIG_REGULATOR_MAX77693=m
CONFIG_REGULATOR_MC13XXX_CORE=m
CONFIG_REGULATOR_MC13783=m
# CONFIG_REGULATOR_MC13892 is not set
CONFIG_REGULATOR_MT6311=y
# CONFIG_REGULATOR_MT6397 is not set
CONFIG_REGULATOR_PCF50633=m
CONFIG_REGULATOR_PFUZE100=y
CONFIG_REGULATOR_PV88060=y
CONFIG_REGULATOR_PV88080=y
CONFIG_REGULATOR_PV88090=m
CONFIG_REGULATOR_PWM=m
CONFIG_REGULATOR_QCOM_SPMI=m
CONFIG_REGULATOR_RC5T583=m
CONFIG_REGULATOR_RK808=m
CONFIG_REGULATOR_RN5T618=m
# CONFIG_REGULATOR_S2MPA01 is not set
CONFIG_REGULATOR_S2MPS11=y
# CONFIG_REGULATOR_S5M8767 is not set
# CONFIG_REGULATOR_TPS51632 is not set
CONFIG_REGULATOR_TPS6105X=m
CONFIG_REGULATOR_TPS62360=m
CONFIG_REGULATOR_TPS65023=m
CONFIG_REGULATOR_TPS6507X=y
CONFIG_REGULATOR_TPS65086=m
CONFIG_REGULATOR_TPS65090=y
CONFIG_REGULATOR_TPS65217=y
CONFIG_REGULATOR_TPS6586X=m
# CONFIG_REGULATOR_TPS65912 is not set
CONFIG_REGULATOR_WM8350=m
# CONFIG_REGULATOR_WM8400 is not set
# CONFIG_REGULATOR_WM8994 is not set
# CONFIG_MEDIA_SUPPORT is not set

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
CONFIG_DRM=m
CONFIG_DRM_MIPI_DSI=y
CONFIG_DRM_DP_AUX_CHARDEV=y
CONFIG_DRM_KMS_HELPER=m
CONFIG_DRM_KMS_FB_HELPER=y
CONFIG_DRM_FBDEV_EMULATION=y
CONFIG_DRM_LOAD_EDID_FIRMWARE=y

#
# I2C encoder or helper chips
#
CONFIG_DRM_I2C_ADV7511=m
CONFIG_DRM_I2C_CH7006=m
CONFIG_DRM_I2C_SIL164=m
# CONFIG_DRM_I2C_NXP_TDA998X is not set
# CONFIG_DRM_TDFX is not set
# CONFIG_DRM_R128 is not set
# CONFIG_DRM_RADEON is not set
# CONFIG_DRM_AMDGPU is not set

#
# ACP (Audio CoProcessor) Configuration
#
# CONFIG_DRM_AMD_ACP is not set
# CONFIG_DRM_NOUVEAU is not set
# CONFIG_DRM_I915 is not set
# CONFIG_DRM_MGA is not set
# CONFIG_DRM_VIA is not set
# CONFIG_DRM_SAVAGE is not set
CONFIG_DRM_VGEM=m
# CONFIG_DRM_VMWGFX is not set
# CONFIG_DRM_GMA500 is not set
# CONFIG_DRM_UDL is not set
# CONFIG_DRM_AST is not set
# CONFIG_DRM_MGAG200 is not set
# CONFIG_DRM_CIRRUS_QEMU is not set
# CONFIG_DRM_QXL is not set
# CONFIG_DRM_BOCHS is not set
# CONFIG_DRM_VIRTIO_GPU is not set
CONFIG_DRM_PANEL=y

#
# Display Panels
#
CONFIG_DRM_PANEL_SIMPLE=m
CONFIG_DRM_PANEL_PANASONIC_VVX10F034N00=m
CONFIG_DRM_PANEL_SAMSUNG_S6E8AA0=m
CONFIG_DRM_PANEL_SHARP_LQ101R1SX01=m
CONFIG_DRM_PANEL_SHARP_LS043T1LE01=m
CONFIG_DRM_BRIDGE=y

#
# Display Interface Bridges
#
CONFIG_DRM_NXP_PTN3460=m
CONFIG_DRM_PARADE_PS8622=m

#
# Frame buffer Devices
#
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
CONFIG_FB_CMDLINE=y
CONFIG_FB_NOTIFY=y
# CONFIG_FB_DDC is not set
# CONFIG_FB_BOOT_VESA_SUPPORT is not set
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
CONFIG_FB_FOREIGN_ENDIAN=y
CONFIG_FB_BOTH_ENDIAN=y
# CONFIG_FB_BIG_ENDIAN is not set
# CONFIG_FB_LITTLE_ENDIAN is not set
CONFIG_FB_SYS_FOPS=y
CONFIG_FB_DEFERRED_IO=y
# CONFIG_FB_SVGALIB is not set
# CONFIG_FB_MACMODES is not set
CONFIG_FB_BACKLIGHT=y
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
# CONFIG_FB_ARC is not set
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
CONFIG_FB_UVESA=m
# CONFIG_FB_VESA is not set
# CONFIG_FB_N411 is not set
CONFIG_FB_HGA=m
CONFIG_FB_OPENCORES=m
CONFIG_FB_S1D13XXX=m
# CONFIG_FB_NVIDIA is not set
# CONFIG_FB_RIVA is not set
# CONFIG_FB_I740 is not set
# CONFIG_FB_LE80578 is not set
# CONFIG_FB_MATROX is not set
# CONFIG_FB_RADEON is not set
# CONFIG_FB_ATY128 is not set
# CONFIG_FB_ATY is not set
# CONFIG_FB_S3 is not set
# CONFIG_FB_SAVAGE is not set
# CONFIG_FB_SIS is not set
# CONFIG_FB_VIA is not set
# CONFIG_FB_NEOMAGIC is not set
# CONFIG_FB_KYRO is not set
# CONFIG_FB_3DFX is not set
# CONFIG_FB_VOODOO1 is not set
# CONFIG_FB_VT8623 is not set
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_ARK is not set
# CONFIG_FB_PM3 is not set
# CONFIG_FB_CARMINE is not set
CONFIG_FB_SM501=y
CONFIG_FB_SMSCUFX=m
# CONFIG_FB_UDL is not set
# CONFIG_FB_IBM_GXT4500 is not set
CONFIG_FB_VIRTUAL=y
CONFIG_FB_METRONOME=y
# CONFIG_FB_MB862XX is not set
# CONFIG_FB_BROADSHEET is not set
# CONFIG_FB_AUO_K190X is not set
CONFIG_FB_SIMPLE=y
CONFIG_FB_SSD1307=y
# CONFIG_FB_SM712 is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=m
# CONFIG_LCD_PLATFORM is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_GENERIC=m
# CONFIG_BACKLIGHT_LM3533 is not set
# CONFIG_BACKLIGHT_PWM is not set
CONFIG_BACKLIGHT_MAX8925=m
# CONFIG_BACKLIGHT_APPLE is not set
CONFIG_BACKLIGHT_PM8941_WLED=y
CONFIG_BACKLIGHT_SAHARA=y
CONFIG_BACKLIGHT_ADP5520=y
# CONFIG_BACKLIGHT_ADP8860 is not set
CONFIG_BACKLIGHT_ADP8870=m
CONFIG_BACKLIGHT_PCF50633=m
CONFIG_BACKLIGHT_LM3630A=y
# CONFIG_BACKLIGHT_LM3639 is not set
# CONFIG_BACKLIGHT_LP855X is not set
CONFIG_BACKLIGHT_TPS65217=m
# CONFIG_BACKLIGHT_AS3711 is not set
# CONFIG_BACKLIGHT_GPIO is not set
# CONFIG_BACKLIGHT_LV5207LP is not set
CONFIG_BACKLIGHT_BD6107=y
# CONFIG_VGASTATE is not set
CONFIG_VIDEOMODE_HELPERS=y
CONFIG_HDMI=y
CONFIG_LOGO=y
CONFIG_LOGO_LINUX_MONO=y
CONFIG_LOGO_LINUX_VGA16=y
CONFIG_LOGO_LINUX_CLUT224=y
CONFIG_SOUND=m
CONFIG_SOUND_OSS_CORE=y
# CONFIG_SOUND_OSS_CORE_PRECLAIM is not set
CONFIG_SND=m
CONFIG_SND_TIMER=m
CONFIG_SND_PCM=m
CONFIG_SND_DMAENGINE_PCM=m
CONFIG_SND_RAWMIDI=m
CONFIG_SND_JACK=y
CONFIG_SND_JACK_INPUT_DEV=y
CONFIG_SND_SEQUENCER=m
# CONFIG_SND_SEQ_DUMMY is not set
CONFIG_SND_OSSEMUL=y
CONFIG_SND_MIXER_OSS=m
CONFIG_SND_PCM_OSS=m
CONFIG_SND_PCM_OSS_PLUGINS=y
CONFIG_SND_PCM_TIMER=y
CONFIG_SND_SEQUENCER_OSS=y
CONFIG_SND_DYNAMIC_MINORS=y
CONFIG_SND_MAX_CARDS=32
# CONFIG_SND_SUPPORT_OLD_API is not set
CONFIG_SND_PROC_FS=y
CONFIG_SND_VERBOSE_PROCFS=y
# CONFIG_SND_VERBOSE_PRINTK is not set
# CONFIG_SND_DEBUG is not set
CONFIG_SND_DMA_SGBUF=y
CONFIG_SND_RAWMIDI_SEQ=m
# CONFIG_SND_OPL3_LIB_SEQ is not set
# CONFIG_SND_OPL4_LIB_SEQ is not set
# CONFIG_SND_SBAWE_SEQ is not set
# CONFIG_SND_EMU10K1_SEQ is not set
CONFIG_SND_DRIVERS=y
CONFIG_SND_DUMMY=m
CONFIG_SND_ALOOP=m
# CONFIG_SND_VIRMIDI is not set
CONFIG_SND_MTPAV=m
CONFIG_SND_MTS64=m
CONFIG_SND_SERIAL_U16550=m
# CONFIG_SND_MPU401 is not set
# CONFIG_SND_PORTMAN2X4 is not set
CONFIG_SND_PCI=y
# CONFIG_SND_AD1889 is not set
# CONFIG_SND_ALS4000 is not set
# CONFIG_SND_ASIHPI is not set
# CONFIG_SND_ATIIXP is not set
# CONFIG_SND_ATIIXP_MODEM is not set
# CONFIG_SND_AU8810 is not set
# CONFIG_SND_AU8820 is not set
# CONFIG_SND_AU8830 is not set
# CONFIG_SND_AW2 is not set
# CONFIG_SND_BT87X is not set
# CONFIG_SND_CA0106 is not set
# CONFIG_SND_CMIPCI is not set
# CONFIG_SND_OXYGEN is not set
# CONFIG_SND_CS4281 is not set
# CONFIG_SND_CS46XX is not set
# CONFIG_SND_CTXFI is not set
# CONFIG_SND_DARLA20 is not set
# CONFIG_SND_GINA20 is not set
# CONFIG_SND_LAYLA20 is not set
# CONFIG_SND_DARLA24 is not set
# CONFIG_SND_GINA24 is not set
# CONFIG_SND_LAYLA24 is not set
# CONFIG_SND_MONA is not set
# CONFIG_SND_MIA is not set
# CONFIG_SND_ECHO3G is not set
# CONFIG_SND_INDIGO is not set
# CONFIG_SND_INDIGOIO is not set
# CONFIG_SND_INDIGODJ is not set
# CONFIG_SND_INDIGOIOX is not set
# CONFIG_SND_INDIGODJX is not set
# CONFIG_SND_ENS1370 is not set
# CONFIG_SND_ENS1371 is not set
# CONFIG_SND_FM801 is not set
# CONFIG_SND_HDSP is not set
# CONFIG_SND_HDSPM is not set
# CONFIG_SND_ICE1724 is not set
# CONFIG_SND_INTEL8X0 is not set
# CONFIG_SND_INTEL8X0M is not set
# CONFIG_SND_KORG1212 is not set
# CONFIG_SND_LOLA is not set
# CONFIG_SND_LX6464ES is not set
# CONFIG_SND_MIXART is not set
# CONFIG_SND_NM256 is not set
# CONFIG_SND_PCXHR is not set
# CONFIG_SND_RIPTIDE is not set
# CONFIG_SND_RME32 is not set
# CONFIG_SND_RME96 is not set
# CONFIG_SND_RME9652 is not set
# CONFIG_SND_SE6X is not set
# CONFIG_SND_VIA82XX is not set
# CONFIG_SND_VIA82XX_MODEM is not set
# CONFIG_SND_VIRTUOSO is not set
# CONFIG_SND_VX222 is not set
# CONFIG_SND_YMFPCI is not set

#
# HD-Audio
#
# CONFIG_SND_HDA_INTEL is not set
CONFIG_SND_HDA_PREALLOC_SIZE=64
# CONFIG_SND_USB is not set
# CONFIG_SND_PCMCIA is not set
CONFIG_SND_SOC=m
CONFIG_SND_SOC_GENERIC_DMAENGINE_PCM=y
# CONFIG_SND_SOC_AMD_ACP is not set
CONFIG_SND_ATMEL_SOC=m

#
# SoC Audio for Freescale CPUs
#

#
# Common SoC Audio options for Freescale CPUs:
#
CONFIG_SND_SOC_FSL_ASRC=m
# CONFIG_SND_SOC_FSL_SAI is not set
CONFIG_SND_SOC_FSL_SSI=m
CONFIG_SND_SOC_FSL_SPDIF=m
CONFIG_SND_SOC_FSL_ESAI=m
CONFIG_SND_SOC_IMX_AUDMUX=m
CONFIG_SND_SOC_IMG=y
CONFIG_SND_SOC_IMG_I2S_IN=m
CONFIG_SND_SOC_IMG_I2S_OUT=m
CONFIG_SND_SOC_IMG_PARALLEL_OUT=m
# CONFIG_SND_SOC_IMG_SPDIF_IN is not set
CONFIG_SND_SOC_IMG_SPDIF_OUT=m
CONFIG_SND_SOC_IMG_PISTACHIO_INTERNAL_DAC=m
# CONFIG_SND_SOC_INTEL_BXT_RT298_MACH is not set
# CONFIG_SND_SOC_INTEL_BYTCR_RT5640_MACH is not set
# CONFIG_SND_SOC_INTEL_BYTCR_RT5651_MACH is not set
# CONFIG_SND_SOC_INTEL_SKL_RT286_MACH is not set

#
# Allwinner SoC Audio support
#
# CONFIG_SND_SUN4I_CODEC is not set
# CONFIG_SND_SUN4I_SPDIF is not set
CONFIG_SND_SOC_XTFPGA_I2S=m
CONFIG_SND_SOC_I2C_AND_SPI=m

#
# CODEC drivers
#
# CONFIG_SND_SOC_AC97_CODEC is not set
CONFIG_SND_SOC_ADAU1701=m
CONFIG_SND_SOC_AK4554=m
# CONFIG_SND_SOC_AK4613 is not set
CONFIG_SND_SOC_AK4642=m
# CONFIG_SND_SOC_AK5386 is not set
CONFIG_SND_SOC_ALC5623=m
CONFIG_SND_SOC_CS35L32=m
CONFIG_SND_SOC_CS42L51=m
CONFIG_SND_SOC_CS42L51_I2C=m
CONFIG_SND_SOC_CS42L52=m
CONFIG_SND_SOC_CS42L56=m
# CONFIG_SND_SOC_CS42L73 is not set
CONFIG_SND_SOC_CS4265=m
# CONFIG_SND_SOC_CS4270 is not set
# CONFIG_SND_SOC_CS4271_I2C is not set
CONFIG_SND_SOC_CS42XX8=m
CONFIG_SND_SOC_CS42XX8_I2C=m
CONFIG_SND_SOC_CS4349=m
CONFIG_SND_SOC_ES8328=m
CONFIG_SND_SOC_GTM601=m
CONFIG_SND_SOC_INNO_RK3036=m
# CONFIG_SND_SOC_PCM1681 is not set
CONFIG_SND_SOC_PCM179X=m
CONFIG_SND_SOC_PCM179X_I2C=m
CONFIG_SND_SOC_PCM3168A=m
CONFIG_SND_SOC_PCM3168A_I2C=m
CONFIG_SND_SOC_PCM512x=m
CONFIG_SND_SOC_PCM512x_I2C=m
CONFIG_SND_SOC_RL6231=m
CONFIG_SND_SOC_RT5616=m
CONFIG_SND_SOC_RT5631=m
# CONFIG_SND_SOC_RT5677_SPI is not set
CONFIG_SND_SOC_SGTL5000=m
CONFIG_SND_SOC_SIGMADSP=m
CONFIG_SND_SOC_SIGMADSP_I2C=m
# CONFIG_SND_SOC_SIRF_AUDIO_CODEC is not set
# CONFIG_SND_SOC_SPDIF is not set
# CONFIG_SND_SOC_SSM2602_I2C is not set
# CONFIG_SND_SOC_SSM4567 is not set
CONFIG_SND_SOC_STA32X=m
# CONFIG_SND_SOC_STA350 is not set
CONFIG_SND_SOC_STI_SAS=m
# CONFIG_SND_SOC_TAS2552 is not set
# CONFIG_SND_SOC_TAS5086 is not set
CONFIG_SND_SOC_TAS571X=m
CONFIG_SND_SOC_TFA9879=m
CONFIG_SND_SOC_TLV320AIC23=m
CONFIG_SND_SOC_TLV320AIC23_I2C=m
CONFIG_SND_SOC_TLV320AIC31XX=m
CONFIG_SND_SOC_TLV320AIC3X=m
CONFIG_SND_SOC_TS3A227E=m
CONFIG_SND_SOC_WM8510=m
# CONFIG_SND_SOC_WM8523 is not set
CONFIG_SND_SOC_WM8580=m
CONFIG_SND_SOC_WM8711=m
# CONFIG_SND_SOC_WM8728 is not set
CONFIG_SND_SOC_WM8731=m
# CONFIG_SND_SOC_WM8737 is not set
CONFIG_SND_SOC_WM8741=m
CONFIG_SND_SOC_WM8750=m
CONFIG_SND_SOC_WM8753=m
CONFIG_SND_SOC_WM8776=m
CONFIG_SND_SOC_WM8804=m
CONFIG_SND_SOC_WM8804_I2C=m
# CONFIG_SND_SOC_WM8903 is not set
CONFIG_SND_SOC_WM8962=m
# CONFIG_SND_SOC_WM8974 is not set
CONFIG_SND_SOC_WM8978=m
# CONFIG_SND_SOC_TPA6130A2 is not set
# CONFIG_SND_SIMPLE_CARD is not set
# CONFIG_SOUND_PRIME is not set

#
# HID support
#
CONFIG_HID=m
CONFIG_HID_BATTERY_STRENGTH=y
CONFIG_HIDRAW=y
# CONFIG_UHID is not set
CONFIG_HID_GENERIC=m

#
# Special HID drivers
#
CONFIG_HID_A4TECH=m
CONFIG_HID_ACRUX=m
# CONFIG_HID_ACRUX_FF is not set
# CONFIG_HID_APPLE is not set
CONFIG_HID_ASUS=m
CONFIG_HID_AUREAL=m
CONFIG_HID_BELKIN=m
CONFIG_HID_CHERRY=m
# CONFIG_HID_CHICONY is not set
CONFIG_HID_CORSAIR=m
CONFIG_HID_PRODIKEYS=m
CONFIG_HID_CMEDIA=m
CONFIG_HID_CYPRESS=m
# CONFIG_HID_DRAGONRISE is not set
CONFIG_HID_EMS_FF=m
# CONFIG_HID_ELECOM is not set
# CONFIG_HID_EZKEY is not set
CONFIG_HID_GEMBIRD=m
CONFIG_HID_GFRM=m
# CONFIG_HID_KEYTOUCH is not set
CONFIG_HID_KYE=m
# CONFIG_HID_WALTOP is not set
CONFIG_HID_GYRATION=m
CONFIG_HID_ICADE=m
# CONFIG_HID_TWINHAN is not set
CONFIG_HID_KENSINGTON=m
CONFIG_HID_LCPOWER=m
CONFIG_HID_LENOVO=m
CONFIG_HID_LOGITECH=m
CONFIG_HID_LOGITECH_DJ=m
CONFIG_HID_LOGITECH_HIDPP=m
# CONFIG_LOGITECH_FF is not set
CONFIG_LOGIRUMBLEPAD2_FF=y
CONFIG_LOGIG940_FF=y
# CONFIG_LOGIWHEELS_FF is not set
# CONFIG_HID_MAGICMOUSE is not set
# CONFIG_HID_MICROSOFT is not set
CONFIG_HID_MONTEREY=m
CONFIG_HID_MULTITOUCH=m
# CONFIG_HID_ORTEK is not set
# CONFIG_HID_PANTHERLORD is not set
# CONFIG_HID_PETALYNX is not set
CONFIG_HID_PICOLCD=m
# CONFIG_HID_PICOLCD_FB is not set
CONFIG_HID_PICOLCD_BACKLIGHT=y
# CONFIG_HID_PICOLCD_LCD is not set
# CONFIG_HID_PICOLCD_LEDS is not set
CONFIG_HID_PLANTRONICS=m
# CONFIG_HID_PRIMAX is not set
CONFIG_HID_SAITEK=m
CONFIG_HID_SAMSUNG=m
# CONFIG_HID_SPEEDLINK is not set
CONFIG_HID_STEELSERIES=m
CONFIG_HID_SUNPLUS=m
CONFIG_HID_RMI=m
CONFIG_HID_GREENASIA=m
# CONFIG_GREENASIA_FF is not set
CONFIG_HID_SMARTJOYPLUS=m
CONFIG_SMARTJOYPLUS_FF=y
CONFIG_HID_TIVO=m
# CONFIG_HID_TOPSEED is not set
CONFIG_HID_THINGM=m
# CONFIG_HID_THRUSTMASTER is not set
CONFIG_HID_WACOM=m
CONFIG_HID_WIIMOTE=m
CONFIG_HID_XINMO=m
CONFIG_HID_ZEROPLUS=m
CONFIG_ZEROPLUS_FF=y
CONFIG_HID_ZYDACRON=m
CONFIG_HID_SENSOR_HUB=m
CONFIG_HID_SENSOR_CUSTOM_SENSOR=m

#
# USB HID support
#
# CONFIG_USB_HID is not set
CONFIG_HID_PID=y

#
# USB HID Boot Protocol drivers
#
# CONFIG_USB_KBD is not set
# CONFIG_USB_MOUSE is not set

#
# I2C HID support
#
CONFIG_I2C_HID=m
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=m
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=m
CONFIG_USB_ANNOUNCE_NEW_DEVICES=y

#
# Miscellaneous USB options
#
CONFIG_USB_DEFAULT_PERSIST=y
CONFIG_USB_DYNAMIC_MINORS=y
CONFIG_USB_OTG_WHITELIST=y
CONFIG_USB_OTG_BLACKLIST_HUB=y
CONFIG_USB_ULPI_BUS=m
CONFIG_USB_MON=m
CONFIG_USB_WUSB=m
CONFIG_USB_WUSB_CBAF=m
# CONFIG_USB_WUSB_CBAF_DEBUG is not set

#
# USB Host Controller Drivers
#
CONFIG_USB_C67X00_HCD=m
CONFIG_USB_XHCI_HCD=m
CONFIG_USB_XHCI_PCI=m
CONFIG_USB_XHCI_PLATFORM=m
CONFIG_USB_EHCI_HCD=m
CONFIG_USB_EHCI_ROOT_HUB_TT=y
# CONFIG_USB_EHCI_TT_NEWSCHED is not set
CONFIG_USB_EHCI_PCI=m
CONFIG_USB_EHCI_HCD_PLATFORM=m
CONFIG_USB_OXU210HP_HCD=m
CONFIG_USB_ISP116X_HCD=m
CONFIG_USB_ISP1362_HCD=m
CONFIG_USB_FOTG210_HCD=m
CONFIG_USB_OHCI_HCD=m
CONFIG_USB_OHCI_HCD_PCI=m
CONFIG_USB_OHCI_HCD_PLATFORM=m
# CONFIG_USB_UHCI_HCD is not set
CONFIG_USB_SL811_HCD=m
# CONFIG_USB_SL811_HCD_ISO is not set
CONFIG_USB_SL811_CS=m
CONFIG_USB_R8A66597_HCD=m
# CONFIG_USB_WHCI_HCD is not set
CONFIG_USB_HWA_HCD=m
CONFIG_USB_HCD_TEST_MODE=y

#
# USB Device Class drivers
#
CONFIG_USB_ACM=m
CONFIG_USB_PRINTER=m
CONFIG_USB_WDM=m
CONFIG_USB_TMC=m

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#

#
# USB Imaging devices
#
CONFIG_USB_MDC800=m
CONFIG_USBIP_CORE=m
CONFIG_USBIP_VHCI_HCD=m
CONFIG_USBIP_HOST=m
CONFIG_USBIP_DEBUG=y
# CONFIG_USB_MUSB_HDRC is not set
# CONFIG_USB_DWC3 is not set
CONFIG_USB_DWC2=m
CONFIG_USB_DWC2_HOST=y

#
# Gadget/Dual-role mode requires USB Gadget support to be enabled
#
# CONFIG_USB_DWC2_PCI is not set
# CONFIG_USB_DWC2_DEBUG is not set
# CONFIG_USB_DWC2_TRACK_MISSED_SOFS is not set
# CONFIG_USB_CHIPIDEA is not set
CONFIG_USB_ISP1760=m
CONFIG_USB_ISP1760_HCD=y
CONFIG_USB_ISP1760_HOST_ROLE=y

#
# USB port drivers
#
# CONFIG_USB_USS720 is not set
# CONFIG_USB_SERIAL is not set

#
# USB Miscellaneous drivers
#
CONFIG_USB_EMI62=m
CONFIG_USB_EMI26=m
CONFIG_USB_ADUTUX=m
# CONFIG_USB_SEVSEG is not set
CONFIG_USB_RIO500=m
CONFIG_USB_LEGOTOWER=m
CONFIG_USB_LCD=m
# CONFIG_USB_LED is not set
CONFIG_USB_CYPRESS_CY7C63=m
CONFIG_USB_CYTHERM=m
# CONFIG_USB_IDMOUSE is not set
# CONFIG_USB_FTDI_ELAN is not set
CONFIG_USB_APPLEDISPLAY=m
# CONFIG_USB_SISUSBVGA is not set
CONFIG_USB_LD=m
CONFIG_USB_TRANCEVIBRATOR=m
CONFIG_USB_IOWARRIOR=m
CONFIG_USB_TEST=m
CONFIG_USB_EHSET_TEST_FIXTURE=m
CONFIG_USB_ISIGHTFW=m
# CONFIG_USB_YUREX is not set
# CONFIG_USB_EZUSB_FX2 is not set
# CONFIG_USB_HSIC_USB3503 is not set
CONFIG_USB_LINK_LAYER_TEST=m
# CONFIG_USB_CHAOSKEY is not set

#
# USB Physical Layer drivers
#
CONFIG_USB_PHY=y
# CONFIG_NOP_USB_XCEIV is not set
# CONFIG_USB_GPIO_VBUS is not set
CONFIG_TAHVO_USB=m
# CONFIG_TAHVO_USB_HOST_BY_DEFAULT is not set
CONFIG_USB_ISP1301=m
# CONFIG_USB_GADGET is not set
CONFIG_USB_LED_TRIG=y
CONFIG_UWB=m
CONFIG_UWB_HWA=m
# CONFIG_UWB_WHCI is not set
CONFIG_UWB_I1480U=m
# CONFIG_MMC is not set
CONFIG_MEMSTICK=m
# CONFIG_MEMSTICK_DEBUG is not set

#
# MemoryStick drivers
#
CONFIG_MEMSTICK_UNSAFE_RESUME=y

#
# MemoryStick Host Controller Drivers
#
# CONFIG_MEMSTICK_TIFM_MS is not set
# CONFIG_MEMSTICK_JMICRON_38X is not set
# CONFIG_MEMSTICK_R592 is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y
CONFIG_LEDS_CLASS_FLASH=m

#
# LED drivers
#
CONFIG_LEDS_BCM6328=m
CONFIG_LEDS_BCM6358=m
CONFIG_LEDS_LM3530=m
# CONFIG_LEDS_LM3533 is not set
CONFIG_LEDS_LM3642=m
CONFIG_LEDS_PCA9532=m
CONFIG_LEDS_PCA9532_GPIO=y
CONFIG_LEDS_GPIO=m
# CONFIG_LEDS_LP3944 is not set
CONFIG_LEDS_LP55XX_COMMON=y
# CONFIG_LEDS_LP5521 is not set
CONFIG_LEDS_LP5523=m
CONFIG_LEDS_LP5562=y
CONFIG_LEDS_LP8501=m
CONFIG_LEDS_LP8860=m
CONFIG_LEDS_CLEVO_MAIL=m
CONFIG_LEDS_PCA955X=y
CONFIG_LEDS_PCA963X=y
CONFIG_LEDS_WM8350=m
CONFIG_LEDS_PWM=m
CONFIG_LEDS_REGULATOR=m
# CONFIG_LEDS_BD2802 is not set
# CONFIG_LEDS_INTEL_SS4200 is not set
# CONFIG_LEDS_LT3593 is not set
CONFIG_LEDS_ADP5520=m
# CONFIG_LEDS_MC13783 is not set
# CONFIG_LEDS_TCA6507 is not set
# CONFIG_LEDS_TLC591XX is not set
CONFIG_LEDS_MAX77693=m
# CONFIG_LEDS_MAX8997 is not set
# CONFIG_LEDS_LM355x is not set
CONFIG_LEDS_KTD2692=m
# CONFIG_LEDS_IS31FL32XX is not set

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
CONFIG_LEDS_BLINKM=y
# CONFIG_LEDS_SYSCON is not set

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
CONFIG_LEDS_TRIGGER_TIMER=y
CONFIG_LEDS_TRIGGER_ONESHOT=y
CONFIG_LEDS_TRIGGER_MTD=y
# CONFIG_LEDS_TRIGGER_HEARTBEAT is not set
CONFIG_LEDS_TRIGGER_BACKLIGHT=y
CONFIG_LEDS_TRIGGER_CPU=y
CONFIG_LEDS_TRIGGER_GPIO=y
CONFIG_LEDS_TRIGGER_DEFAULT_ON=m

#
# iptables trigger is under Netfilter config (LED target)
#
CONFIG_LEDS_TRIGGER_TRANSIENT=y
CONFIG_LEDS_TRIGGER_CAMERA=y
# CONFIG_LEDS_TRIGGER_PANIC is not set
CONFIG_ACCESSIBILITY=y
# CONFIG_INFINIBAND is not set
CONFIG_EDAC_ATOMIC_SCRUB=y
CONFIG_EDAC_SUPPORT=y
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=y
# CONFIG_RTC_CLASS is not set
CONFIG_DMADEVICES=y
CONFIG_DMADEVICES_DEBUG=y
CONFIG_DMADEVICES_VDEBUG=y

#
# DMA Devices
#
CONFIG_DMA_ENGINE=y
CONFIG_DMA_VIRTUAL_CHANNELS=y
CONFIG_DMA_ACPI=y
CONFIG_DMA_OF=y
# CONFIG_FSL_EDMA is not set
CONFIG_INTEL_IDMA64=y
# CONFIG_INTEL_IOATDMA is not set
CONFIG_QCOM_HIDMA_MGMT=y
CONFIG_QCOM_HIDMA=m
CONFIG_DW_DMAC_CORE=m
CONFIG_DW_DMAC=m
# CONFIG_DW_DMAC_PCI is not set
CONFIG_HSU_DMA=y

#
# DMA Clients
#
# CONFIG_ASYNC_TX_DMA is not set
CONFIG_DMATEST=y
# CONFIG_AUXDISPLAY is not set
CONFIG_UIO=y
# CONFIG_UIO_CIF is not set
CONFIG_UIO_PDRV_GENIRQ=m
CONFIG_UIO_DMEM_GENIRQ=m
# CONFIG_UIO_AEC is not set
# CONFIG_UIO_SERCOS3 is not set
# CONFIG_UIO_PCI_GENERIC is not set
# CONFIG_UIO_NETX is not set
CONFIG_UIO_PRUSS=m
# CONFIG_UIO_MF624 is not set
CONFIG_VIRT_DRIVERS=y
CONFIG_VIRTIO=y

#
# Virtio drivers
#
# CONFIG_VIRTIO_PCI is not set
# CONFIG_VIRTIO_BALLOON is not set
# CONFIG_VIRTIO_INPUT is not set
CONFIG_VIRTIO_MMIO=y
CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES=y

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
# CONFIG_STAGING is not set
CONFIG_X86_PLATFORM_DEVICES=y
# CONFIG_ACERHDF is not set
# CONFIG_ASUS_LAPTOP is not set
CONFIG_DELL_SMBIOS=m
CONFIG_DELL_LAPTOP=m
# CONFIG_DELL_SMO8800 is not set
# CONFIG_DELL_RBTN is not set
# CONFIG_FUJITSU_LAPTOP is not set
# CONFIG_FUJITSU_TABLET is not set
CONFIG_AMILO_RFKILL=m
# CONFIG_HP_ACCEL is not set
# CONFIG_HP_WIRELESS is not set
# CONFIG_MSI_LAPTOP is not set
# CONFIG_PANASONIC_LAPTOP is not set
# CONFIG_COMPAL_LAPTOP is not set
# CONFIG_SONY_LAPTOP is not set
# CONFIG_IDEAPAD_LAPTOP is not set
# CONFIG_THINKPAD_ACPI is not set
CONFIG_SENSORS_HDAPS=m
# CONFIG_INTEL_MENLOW is not set
# CONFIG_ASUS_WIRELESS is not set
# CONFIG_ACPI_WMI is not set
# CONFIG_TOPSTAR_LAPTOP is not set
# CONFIG_TOSHIBA_BT_RFKILL is not set
# CONFIG_TOSHIBA_HAPS is not set
# CONFIG_ACPI_CMPC is not set
# CONFIG_INTEL_HID_EVENT is not set
# CONFIG_INTEL_IPS is not set
# CONFIG_IBM_RTL is not set
CONFIG_SAMSUNG_LAPTOP=m
# CONFIG_INTEL_OAKTRAIL is not set
# CONFIG_SAMSUNG_Q10 is not set
# CONFIG_APPLE_GMUX is not set
# CONFIG_INTEL_RST is not set
# CONFIG_INTEL_SMARTCONNECT is not set
# CONFIG_PVPANIC is not set
# CONFIG_INTEL_PMC_IPC is not set
# CONFIG_SURFACE_PRO3_BUTTON is not set
CONFIG_INTEL_PUNIT_IPC=m
CONFIG_CHROME_PLATFORMS=y
CONFIG_CHROMEOS_LAPTOP=y
CONFIG_CHROMEOS_PSTORE=y
# CONFIG_CROS_EC_CHARDEV is not set
CONFIG_CROS_EC_LPC=m
CONFIG_CROS_EC_PROTO=y

#
# Hardware Spinlock drivers
#

#
# Clock Source drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
# CONFIG_ATMEL_PIT is not set
# CONFIG_SH_TIMER_CMT is not set
# CONFIG_SH_TIMER_MTU2 is not set
# CONFIG_SH_TIMER_TMU is not set
# CONFIG_EM_TIMER_STI is not set
CONFIG_MAILBOX=y
# CONFIG_PCC is not set
# CONFIG_ALTERA_MBOX is not set
CONFIG_MAILBOX_TEST=y
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
# CONFIG_PM_DEVFREQ is not set
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
# CONFIG_EXTCON_ADC_JACK is not set
# CONFIG_EXTCON_AXP288 is not set
# CONFIG_EXTCON_GPIO is not set
CONFIG_EXTCON_MAX3355=y
CONFIG_EXTCON_MAX77693=m
CONFIG_EXTCON_MAX77843=m
CONFIG_EXTCON_MAX8997=m
CONFIG_EXTCON_RT8973A=m
CONFIG_EXTCON_SM5502=y
# CONFIG_EXTCON_USB_GPIO is not set
CONFIG_MEMORY=y
CONFIG_IIO=m
CONFIG_IIO_BUFFER=y
CONFIG_IIO_BUFFER_CB=m
CONFIG_IIO_KFIFO_BUF=m
CONFIG_IIO_TRIGGERED_BUFFER=m
CONFIG_IIO_CONFIGFS=m
CONFIG_IIO_TRIGGER=y
CONFIG_IIO_CONSUMERS_PER_TRIGGER=2
# CONFIG_IIO_SW_TRIGGER is not set

#
# Accelerometers
#
CONFIG_BMA180=m
CONFIG_BMC150_ACCEL=m
CONFIG_BMC150_ACCEL_I2C=m
CONFIG_HID_SENSOR_ACCEL_3D=m
CONFIG_IIO_ST_ACCEL_3AXIS=m
CONFIG_IIO_ST_ACCEL_I2C_3AXIS=m
CONFIG_KXCJK1013=m
# CONFIG_MMA7455_I2C is not set
CONFIG_MMA8452=m
CONFIG_MMA9551_CORE=m
CONFIG_MMA9551=m
# CONFIG_MMA9553 is not set
# CONFIG_MXC4005 is not set
CONFIG_MXC6255=m
CONFIG_STK8312=m
CONFIG_STK8BA50=m

#
# Analog to digital converters
#
# CONFIG_AD7291 is not set
CONFIG_AD799X=m
# CONFIG_AXP288_ADC is not set
CONFIG_DA9150_GPADC=m
CONFIG_MAX1363=m
CONFIG_MCP3422=m
CONFIG_MEN_Z188_ADC=m
CONFIG_NAU7802=m
CONFIG_QCOM_SPMI_IADC=m
# CONFIG_QCOM_SPMI_VADC is not set
CONFIG_TI_ADC081C=m
# CONFIG_TI_ADS1015 is not set
# CONFIG_TI_AM335X_ADC is not set
CONFIG_VF610_ADC=m
CONFIG_VIPERBOARD_ADC=m

#
# Amplifiers
#

#
# Chemical Sensors
#
# CONFIG_ATLAS_PH_SENSOR is not set
# CONFIG_IAQCORE is not set
CONFIG_VZ89X=m

#
# Hid Sensor IIO Common
#
CONFIG_HID_SENSOR_IIO_COMMON=m
CONFIG_HID_SENSOR_IIO_TRIGGER=m
CONFIG_IIO_MS_SENSORS_I2C=m

#
# SSP Sensor Common
#
CONFIG_IIO_ST_SENSORS_I2C=m
CONFIG_IIO_ST_SENSORS_CORE=m

#
# Digital to analog converters
#
# CONFIG_AD5064 is not set
# CONFIG_AD5380 is not set
CONFIG_AD5446=m
CONFIG_M62332=m
CONFIG_MAX517=m
CONFIG_MAX5821=m
CONFIG_MCP4725=m
# CONFIG_VF610_DAC is not set

#
# IIO dummy driver
#
CONFIG_IIO_DUMMY_EVGEN=m
CONFIG_IIO_SIMPLE_DUMMY=m
CONFIG_IIO_SIMPLE_DUMMY_EVENTS=y
# CONFIG_IIO_SIMPLE_DUMMY_BUFFER is not set

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
CONFIG_BMG160=m
CONFIG_BMG160_I2C=m
CONFIG_HID_SENSOR_GYRO_3D=m
CONFIG_IIO_ST_GYRO_3AXIS=m
CONFIG_IIO_ST_GYRO_I2C_3AXIS=m
# CONFIG_ITG3200 is not set

#
# Health Sensors
#

#
# Heart Rate Monitors
#
# CONFIG_AFE4404 is not set
# CONFIG_MAX30100 is not set

#
# Humidity sensors
#
CONFIG_DHT11=m
CONFIG_HDC100X=m
# CONFIG_HTU21 is not set
CONFIG_SI7005=m
# CONFIG_SI7020 is not set

#
# Inertial measurement units
#
# CONFIG_KMX61 is not set
CONFIG_INV_MPU6050_IIO=m
CONFIG_INV_MPU6050_I2C=m

#
# Light sensors
#
# CONFIG_ACPI_ALS is not set
CONFIG_ADJD_S311=m
CONFIG_AL3320A=m
# CONFIG_APDS9300 is not set
# CONFIG_APDS9960 is not set
CONFIG_BH1750=m
CONFIG_CM32181=m
# CONFIG_CM3232 is not set
CONFIG_CM3323=m
CONFIG_CM36651=m
CONFIG_GP2AP020A00F=m
# CONFIG_ISL29125 is not set
CONFIG_HID_SENSOR_ALS=m
CONFIG_HID_SENSOR_PROX=m
# CONFIG_JSA1212 is not set
CONFIG_RPR0521=m
CONFIG_SENSORS_LM3533=m
# CONFIG_LTR501 is not set
CONFIG_OPT3001=m
# CONFIG_PA12203001 is not set
# CONFIG_STK3310 is not set
# CONFIG_TCS3414 is not set
CONFIG_TCS3472=m
CONFIG_SENSORS_TSL2563=m
# CONFIG_TSL4531 is not set
CONFIG_US5182D=m
CONFIG_VCNL4000=m

#
# Magnetometer sensors
#
CONFIG_AK8975=m
CONFIG_AK09911=m
# CONFIG_BMC150_MAGN is not set
# CONFIG_MAG3110 is not set
CONFIG_HID_SENSOR_MAGNETOMETER_3D=m
# CONFIG_MMC35240 is not set
# CONFIG_IIO_ST_MAGN_3AXIS is not set
CONFIG_SENSORS_HMC5843=m
CONFIG_SENSORS_HMC5843_I2C=m

#
# Inclinometer sensors
#
# CONFIG_HID_SENSOR_INCLINOMETER_3D is not set
CONFIG_HID_SENSOR_DEVICE_ROTATION=m

#
# Triggers - standalone
#
CONFIG_IIO_INTERRUPT_TRIGGER=m
# CONFIG_IIO_SYSFS_TRIGGER is not set

#
# Digital potentiometers
#
CONFIG_MCP4531=m
# CONFIG_TPL0102 is not set

#
# Pressure sensors
#
CONFIG_BMP280=m
# CONFIG_HID_SENSOR_PRESS is not set
# CONFIG_MPL115_I2C is not set
CONFIG_MPL3115=m
# CONFIG_MS5611 is not set
CONFIG_MS5637=m
# CONFIG_IIO_ST_PRESS is not set
CONFIG_T5403=m

#
# Lightning sensors
#

#
# Proximity sensors
#
CONFIG_LIDAR_LITE_V2=m
CONFIG_SX9500=m

#
# Temperature sensors
#
# CONFIG_MLX90614 is not set
CONFIG_TMP006=m
# CONFIG_TSYS01 is not set
# CONFIG_TSYS02D is not set
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
CONFIG_PWM=y
CONFIG_PWM_SYSFS=y
# CONFIG_PWM_CRC is not set
# CONFIG_PWM_FSL_FTM is not set
# CONFIG_PWM_LPSS_PCI is not set
# CONFIG_PWM_LPSS_PLATFORM is not set
CONFIG_PWM_PCA9685=y
CONFIG_IRQCHIP=y
CONFIG_ARM_GIC_MAX_NR=1
# CONFIG_IPACK_BUS is not set
CONFIG_RESET_CONTROLLER=y
CONFIG_FMC=m
CONFIG_FMC_FAKEDEV=m
# CONFIG_FMC_TRIVIAL is not set
CONFIG_FMC_WRITE_EEPROM=m
# CONFIG_FMC_CHARDEV is not set

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
CONFIG_PHY_PXA_28NM_HSIC=m
# CONFIG_PHY_PXA_28NM_USB2 is not set
# CONFIG_BCM_KONA_USB2_PHY is not set
CONFIG_PHY_SAMSUNG_USB2=m
# CONFIG_PHY_EXYNOS4210_USB2 is not set
# CONFIG_PHY_EXYNOS4X12_USB2 is not set
# CONFIG_PHY_EXYNOS5250_USB2 is not set
CONFIG_PHY_TUSB1210=m
CONFIG_POWERCAP=y
CONFIG_INTEL_RAPL=m
CONFIG_MCB=y
# CONFIG_MCB_PCI is not set

#
# Performance monitor support
#
CONFIG_RAS=y
# CONFIG_THUNDERBOLT is not set

#
# Android
#
# CONFIG_ANDROID is not set
CONFIG_NVMEM=y
# CONFIG_STM is not set
CONFIG_INTEL_TH=m
# CONFIG_INTEL_TH_PCI is not set
CONFIG_INTEL_TH_GTH=m
CONFIG_INTEL_TH_MSU=m
# CONFIG_INTEL_TH_PTI is not set
# CONFIG_INTEL_TH_DEBUG is not set

#
# FPGA Configuration Support
#
# CONFIG_FPGA is not set

#
# Firmware Drivers
#
# CONFIG_EDD is not set
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_DELL_RBU=y
CONFIG_DCDBAS=m
CONFIG_DMIID=y
# CONFIG_DMI_SYSFS is not set
CONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK=y
# CONFIG_ISCSI_IBFT_FIND is not set
CONFIG_FW_CFG_SYSFS=m
CONFIG_FW_CFG_SYSFS_CMDLINE=y
CONFIG_GOOGLE_FIRMWARE=y

#
# Google Firmware Drivers
#
CONFIG_GOOGLE_MEMCONSOLE=y

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_FILE_LOCKING=y
CONFIG_MANDATORY_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
# CONFIG_FANOTIFY is not set
# CONFIG_QUOTA is not set
# CONFIG_QUOTACTL is not set
CONFIG_AUTOFS4_FS=y
CONFIG_FUSE_FS=y
CONFIG_CUSE=y
CONFIG_OVERLAY_FS=m

#
# Caches
#
CONFIG_FSCACHE=y
CONFIG_FSCACHE_STATS=y
# CONFIG_FSCACHE_HISTOGRAM is not set
# CONFIG_FSCACHE_DEBUG is not set
# CONFIG_FSCACHE_OBJECT_LIST is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
# CONFIG_PROC_KCORE is not set
# CONFIG_PROC_VMCORE is not set
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_PROC_CHILDREN=y
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_TMPFS_XATTR=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=m
CONFIG_MISC_FILESYSTEMS=y
CONFIG_ORANGEFS_FS=y
CONFIG_ECRYPT_FS=m
CONFIG_ECRYPT_FS_MESSAGING=y
CONFIG_JFFS2_FS=m
CONFIG_JFFS2_FS_DEBUG=0
# CONFIG_JFFS2_FS_WRITEBUFFER is not set
CONFIG_JFFS2_SUMMARY=y
# CONFIG_JFFS2_FS_XATTR is not set
# CONFIG_JFFS2_COMPRESSION_OPTIONS is not set
CONFIG_JFFS2_ZLIB=y
# CONFIG_JFFS2_LZO is not set
CONFIG_JFFS2_RTIME=y
# CONFIG_JFFS2_RUBIN is not set
CONFIG_UBIFS_FS=m
# CONFIG_UBIFS_FS_ADVANCED_COMPR is not set
CONFIG_UBIFS_FS_LZO=y
CONFIG_UBIFS_FS_ZLIB=y
# CONFIG_UBIFS_ATIME_SUPPORT is not set
# CONFIG_LOGFS is not set
CONFIG_ROMFS_FS=m
CONFIG_ROMFS_BACKED_BY_MTD=y
CONFIG_ROMFS_ON_MTD=y
CONFIG_PSTORE=m
CONFIG_PSTORE_CONSOLE=y
# CONFIG_PSTORE_PMSG is not set
CONFIG_PSTORE_RAM=m
# CONFIG_NETWORK_FILESYSTEMS is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
# CONFIG_NLS_CODEPAGE_437 is not set
CONFIG_NLS_CODEPAGE_737=m
CONFIG_NLS_CODEPAGE_775=y
# CONFIG_NLS_CODEPAGE_850 is not set
CONFIG_NLS_CODEPAGE_852=y
# CONFIG_NLS_CODEPAGE_855 is not set
# CONFIG_NLS_CODEPAGE_857 is not set
CONFIG_NLS_CODEPAGE_860=y
CONFIG_NLS_CODEPAGE_861=m
CONFIG_NLS_CODEPAGE_862=y
# CONFIG_NLS_CODEPAGE_863 is not set
# CONFIG_NLS_CODEPAGE_864 is not set
CONFIG_NLS_CODEPAGE_865=y
CONFIG_NLS_CODEPAGE_866=m
CONFIG_NLS_CODEPAGE_869=y
# CONFIG_NLS_CODEPAGE_936 is not set
CONFIG_NLS_CODEPAGE_950=y
# CONFIG_NLS_CODEPAGE_932 is not set
# CONFIG_NLS_CODEPAGE_949 is not set
CONFIG_NLS_CODEPAGE_874=y
CONFIG_NLS_ISO8859_8=m
# CONFIG_NLS_CODEPAGE_1250 is not set
# CONFIG_NLS_CODEPAGE_1251 is not set
# CONFIG_NLS_ASCII is not set
# CONFIG_NLS_ISO8859_1 is not set
# CONFIG_NLS_ISO8859_2 is not set
# CONFIG_NLS_ISO8859_3 is not set
CONFIG_NLS_ISO8859_4=y
CONFIG_NLS_ISO8859_5=m
# CONFIG_NLS_ISO8859_6 is not set
CONFIG_NLS_ISO8859_7=y
# CONFIG_NLS_ISO8859_9 is not set
# CONFIG_NLS_ISO8859_13 is not set
CONFIG_NLS_ISO8859_14=m
# CONFIG_NLS_ISO8859_15 is not set
# CONFIG_NLS_KOI8_R is not set
CONFIG_NLS_KOI8_U=y
CONFIG_NLS_MAC_ROMAN=y
# CONFIG_NLS_MAC_CELTIC is not set
CONFIG_NLS_MAC_CENTEURO=y
# CONFIG_NLS_MAC_CROATIAN is not set
CONFIG_NLS_MAC_CYRILLIC=y
CONFIG_NLS_MAC_GAELIC=m
# CONFIG_NLS_MAC_GREEK is not set
# CONFIG_NLS_MAC_ICELAND is not set
CONFIG_NLS_MAC_INUIT=m
CONFIG_NLS_MAC_ROMANIAN=m
# CONFIG_NLS_MAC_TURKISH is not set
CONFIG_NLS_UTF8=m
CONFIG_DLM=m
CONFIG_DLM_DEBUG=y

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
# CONFIG_ENABLE_WARN_DEPRECATED is not set
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=8192
CONFIG_STRIP_ASM_SYMS=y
# CONFIG_READABLE_ASM is not set
CONFIG_UNUSED_SYMBOLS=y
CONFIG_PAGE_OWNER=y
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
# CONFIG_DEBUG_SECTION_MISMATCH is not set
# CONFIG_SECTION_MISMATCH_WARN_ONLY is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
CONFIG_STACK_VALIDATION=y
CONFIG_DEBUG_FORCE_WEAK_PER_CPU=y
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_PAGE_EXTENSION=y
CONFIG_DEBUG_PAGEALLOC=y
# CONFIG_DEBUG_PAGEALLOC_ENABLE_DEFAULT is not set
CONFIG_PAGE_POISONING=y
# CONFIG_PAGE_POISONING_NO_SANITY is not set
# CONFIG_PAGE_POISONING_ZERO is not set
# CONFIG_DEBUG_OBJECTS is not set
# CONFIG_DEBUG_SLAB is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
# CONFIG_DEBUG_STACK_USAGE is not set
CONFIG_DEBUG_VM=y
# CONFIG_DEBUG_VM_VMACACHE is not set
# CONFIG_DEBUG_VM_RB is not set
CONFIG_DEBUG_VM_PGFLAGS=y
CONFIG_DEBUG_VIRTUAL=y
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_DEBUG_PER_CPU_MAPS=y
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
# CONFIG_DEBUG_STACKOVERFLOW is not set
CONFIG_HAVE_ARCH_KMEMCHECK=y
CONFIG_HAVE_ARCH_KASAN=y
CONFIG_KASAN=y
# CONFIG_KASAN_OUTLINE is not set
CONFIG_KASAN_INLINE=y
CONFIG_TEST_KASAN=m
CONFIG_ARCH_HAS_KCOV=y
# CONFIG_KCOV is not set
# CONFIG_DEBUG_SHIRQ is not set

#
# Debug Lockups and Hangs
#
CONFIG_LOCKUP_DETECTOR=y
CONFIG_HARDLOCKUP_DETECTOR=y
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC=y
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=1
# CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=0
# CONFIG_DETECT_HUNG_TASK is not set
# CONFIG_WQ_WATCHDOG is not set
CONFIG_PANIC_ON_OOPS=y
CONFIG_PANIC_ON_OOPS_VALUE=1
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
# CONFIG_SCHED_INFO is not set
# CONFIG_SCHEDSTATS is not set
# CONFIG_SCHED_STACK_END_CHECK is not set
CONFIG_DEBUG_TIMEKEEPING=y
# CONFIG_TIMER_STATS is not set

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
CONFIG_DEBUG_RT_MUTEXES=y
# CONFIG_DEBUG_SPINLOCK is not set
# CONFIG_DEBUG_MUTEXES is not set
# CONFIG_DEBUG_WW_MUTEX_SLOWPATH is not set
# CONFIG_DEBUG_LOCK_ALLOC is not set
# CONFIG_PROVE_LOCKING is not set
# CONFIG_LOCK_STAT is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_LOCK_TORTURE_TEST=m
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
# CONFIG_DEBUG_LIST is not set
# CONFIG_DEBUG_PI_LIST is not set
# CONFIG_DEBUG_SG is not set
# CONFIG_DEBUG_NOTIFIERS is not set
# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
# CONFIG_PROVE_RCU is not set
CONFIG_SPARSE_RCU_POINTER=y
CONFIG_TORTURE_TEST=m
CONFIG_RCU_PERF_TEST=m
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=21
CONFIG_RCU_TRACE=y
CONFIG_RCU_EQS_DEBUG=y
CONFIG_DEBUG_WQ_FORCE_RR_CPU=y
CONFIG_CPU_HOTPLUG_STATE_CONTROL=y
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
CONFIG_FAULT_INJECTION=y
# CONFIG_FAILSLAB is not set
CONFIG_FAIL_PAGE_ALLOC=y
# CONFIG_FAIL_FUTEX is not set
# CONFIG_FAULT_INJECTION_DEBUG_FS is not set
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
CONFIG_TRACING_SUPPORT=y
# CONFIG_FTRACE is not set

#
# Runtime Testing
#
CONFIG_TEST_LIST_SORT=y
# CONFIG_BACKTRACE_SELF_TEST is not set
CONFIG_RBTREE_TEST=m
CONFIG_INTERVAL_TREE_TEST=m
CONFIG_PERCPU_TEST=m
# CONFIG_ATOMIC64_SELFTEST is not set
CONFIG_TEST_HEXDUMP=y
# CONFIG_TEST_STRING_HELPERS is not set
CONFIG_TEST_KSTRTOX=y
# CONFIG_TEST_PRINTF is not set
CONFIG_TEST_BITMAP=m
# CONFIG_TEST_RHASHTABLE is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
CONFIG_BUILD_DOCSRC=y
# CONFIG_DMA_API_DEBUG is not set
CONFIG_TEST_LKM=m
CONFIG_TEST_USER_COPY=m
# CONFIG_TEST_BPF is not set
CONFIG_TEST_FIRMWARE=m
CONFIG_TEST_UDELAY=y
# CONFIG_MEMTEST is not set
CONFIG_TEST_STATIC_KEYS=m
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
# CONFIG_UBSAN is not set
CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
CONFIG_STRICT_DEVMEM=y
# CONFIG_IO_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
CONFIG_X86_PTDUMP_CORE=y
# CONFIG_X86_PTDUMP is not set
# CONFIG_DEBUG_RODATA_TEST is not set
CONFIG_DEBUG_WX=y
# CONFIG_DEBUG_SET_MODULE_RONX is not set
# CONFIG_DEBUG_NX_TEST is not set
# CONFIG_DOUBLEFAULT is not set
CONFIG_DEBUG_TLBFLUSH=y
CONFIG_IOMMU_STRESS=y
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
CONFIG_IO_DELAY_NONE=y
CONFIG_DEFAULT_IO_DELAY_TYPE=3
CONFIG_DEBUG_BOOT_PARAMS=y
# CONFIG_CPA_DEBUG is not set
CONFIG_OPTIMIZE_INLINING=y
CONFIG_DEBUG_ENTRY=y
# CONFIG_DEBUG_NMI_SELFTEST is not set
CONFIG_X86_DEBUG_FPU=y
CONFIG_PUNIT_ATOM_DEBUG=m

#
# Security options
#
CONFIG_KEYS=y
CONFIG_PERSISTENT_KEYRINGS=y
CONFIG_BIG_KEYS=y
CONFIG_ENCRYPTED_KEYS=y
# CONFIG_KEY_DH_OPERATIONS is not set
CONFIG_SECURITY_DMESG_RESTRICT=y
# CONFIG_SECURITY is not set
# CONFIG_SECURITYFS is not set
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
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
CONFIG_CRYPTO_RSA=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
CONFIG_CRYPTO_USER=y
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_NULL2=y
# CONFIG_CRYPTO_PCRYPT is not set
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_MCRYPTD=y
CONFIG_CRYPTO_AUTHENC=m
CONFIG_CRYPTO_TEST=m
CONFIG_CRYPTO_ABLK_HELPER=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=m
CONFIG_CRYPTO_GCM=y
CONFIG_CRYPTO_CHACHA20POLY1305=y
CONFIG_CRYPTO_SEQIV=y
CONFIG_CRYPTO_ECHAINIV=m

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=m
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
CONFIG_CRYPTO_PCBC=m
CONFIG_CRYPTO_XTS=y
# CONFIG_CRYPTO_KEYWRAP is not set

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=y
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=y
# CONFIG_CRYPTO_VMAC is not set

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=y
CONFIG_CRYPTO_CRC32=y
CONFIG_CRYPTO_CRC32_PCLMUL=y
# CONFIG_CRYPTO_CRCT10DIF is not set
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_POLY1305=y
# CONFIG_CRYPTO_POLY1305_X86_64 is not set
# CONFIG_CRYPTO_MD4 is not set
CONFIG_CRYPTO_MD5=y
# CONFIG_CRYPTO_MICHAEL_MIC is not set
CONFIG_CRYPTO_RMD128=y
CONFIG_CRYPTO_RMD160=y
# CONFIG_CRYPTO_RMD256 is not set
CONFIG_CRYPTO_RMD320=m
CONFIG_CRYPTO_SHA1=y
# CONFIG_CRYPTO_SHA1_SSSE3 is not set
# CONFIG_CRYPTO_SHA256_SSSE3 is not set
CONFIG_CRYPTO_SHA512_SSSE3=y
CONFIG_CRYPTO_SHA1_MB=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_TGR192=m
CONFIG_CRYPTO_WP512=m
# CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL is not set

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_X86_64=m
CONFIG_CRYPTO_AES_NI_INTEL=m
CONFIG_CRYPTO_ANUBIS=y
CONFIG_CRYPTO_ARC4=y
CONFIG_CRYPTO_BLOWFISH=y
CONFIG_CRYPTO_BLOWFISH_COMMON=y
CONFIG_CRYPTO_BLOWFISH_X86_64=y
# CONFIG_CRYPTO_CAMELLIA is not set
CONFIG_CRYPTO_CAMELLIA_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64=m
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
# CONFIG_CRYPTO_CAST5_AVX_X86_64 is not set
CONFIG_CRYPTO_CAST6=m
CONFIG_CRYPTO_CAST6_AVX_X86_64=m
CONFIG_CRYPTO_DES=m
CONFIG_CRYPTO_DES3_EDE_X86_64=m
CONFIG_CRYPTO_FCRYPT=m
CONFIG_CRYPTO_KHAZAD=m
CONFIG_CRYPTO_SALSA20=m
# CONFIG_CRYPTO_SALSA20_X86_64 is not set
CONFIG_CRYPTO_CHACHA20=y
# CONFIG_CRYPTO_CHACHA20_X86_64 is not set
CONFIG_CRYPTO_SEED=y
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_X86_64=y
# CONFIG_CRYPTO_SERPENT_AVX_X86_64 is not set
# CONFIG_CRYPTO_SERPENT_AVX2_X86_64 is not set
CONFIG_CRYPTO_TEA=y
CONFIG_CRYPTO_TWOFISH=m
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y
CONFIG_CRYPTO_TWOFISH_AVX_X86_64=y

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
CONFIG_CRYPTO_LZO=m
# CONFIG_CRYPTO_842 is not set
CONFIG_CRYPTO_LZ4=y
CONFIG_CRYPTO_LZ4HC=y

#
# Random Number Generation
#
# CONFIG_CRYPTO_ANSI_CPRNG is not set
CONFIG_CRYPTO_DRBG_MENU=y
CONFIG_CRYPTO_DRBG_HMAC=y
# CONFIG_CRYPTO_DRBG_HASH is not set
# CONFIG_CRYPTO_DRBG_CTR is not set
CONFIG_CRYPTO_DRBG=y
CONFIG_CRYPTO_JITTERENTROPY=y
CONFIG_CRYPTO_USER_API=m
# CONFIG_CRYPTO_USER_API_HASH is not set
CONFIG_CRYPTO_USER_API_SKCIPHER=m
CONFIG_CRYPTO_USER_API_RNG=m
CONFIG_CRYPTO_USER_API_AEAD=m
CONFIG_CRYPTO_HASH_INFO=y
# CONFIG_CRYPTO_HW is not set
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
CONFIG_X509_CERTIFICATE_PARSER=y
CONFIG_PKCS7_MESSAGE_PARSER=y

#
# Certificates for signature checking
#
CONFIG_SYSTEM_TRUSTED_KEYRING=y
CONFIG_SYSTEM_TRUSTED_KEYS=""
# CONFIG_SYSTEM_EXTRA_CERTIFICATE is not set
# CONFIG_SECONDARY_TRUSTED_KEYRING is not set
CONFIG_HAVE_KVM=y
CONFIG_VIRTUALIZATION=y
# CONFIG_BINARY_PRINTF is not set

#
# Library routines
#
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
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
# CONFIG_CRC_T10DIF is not set
# CONFIG_CRC_ITU_T is not set
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
# CONFIG_CRC32_SLICEBY8 is not set
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
CONFIG_CRC32_BIT=y
# CONFIG_CRC7 is not set
CONFIG_LIBCRC32C=y
# CONFIG_CRC8 is not set
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
# CONFIG_XZ_DEC_IA64 is not set
# CONFIG_XZ_DEC_ARM is not set
# CONFIG_XZ_DEC_ARMTHUMB is not set
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
CONFIG_XZ_DEC_TEST=m
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_REED_SOLOMON=m
CONFIG_REED_SOLOMON_ENC8=y
CONFIG_REED_SOLOMON_DEC8=y
CONFIG_BCH=m
CONFIG_BCH_CONST_PARAMS=y
CONFIG_INTERVAL_TREE=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_CPUMASK_OFFSTACK=y
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
CONFIG_CLZ_TAB=y
# CONFIG_CORDIC is not set
CONFIG_DDR=y
CONFIG_IRQ_POLL=y
CONFIG_MPILIB=y
CONFIG_OID_REGISTRY=y
# CONFIG_SG_SPLIT is not set
# CONFIG_SG_POOL is not set
CONFIG_ARCH_HAS_SG_CHAIN=y
CONFIG_ARCH_HAS_PMEM_API=y
CONFIG_ARCH_HAS_MMIO_FLUSH=y
CONFIG_STACKDEPOT=y

--yvfyjqxnpxlz5bhg--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
