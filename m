Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6DF596B0005
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 19:48:52 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e189so204992427pfa.2
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 16:48:52 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id a7si1900322pfb.252.2016.06.23.16.48.50
        for <linux-mm@kvack.org>;
        Thu, 23 Jun 2016 16:48:50 -0700 (PDT)
Date: Fri, 24 Jun 2016 07:47:28 +0800
From: kernel test robot <fengguang.wu@intel.com>
Subject: [mm] c3e3459c92:  WARNING: CPU: 1 PID: 249 at mm/util.c:519
 __vm_enough_memory
Message-ID: <576c7510.SAiRMzo9wNiGCq5R%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=_576c7510.zgj2Zxs266gQ+rvSsgnlrgnW2s7z0Q4/wE6R0I7zQHBVWTR8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: LKP <lkp@01.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.orgLinux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, wfg@linux.intel.com

This is a multi-part message in MIME format.

--=_576c7510.zgj2Zxs266gQ+rvSsgnlrgnW2s7z0Q4/wE6R0I7zQHBVWTR8
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Greetings,

0day kernel testing robot got the below dmesg and the first bad commit is

https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master

commit c3e3459c92a22be17145cdd9d86a8acc74afa5cf
Author:     Mel Gorman <mgorman@techsingularity.net>
AuthorDate: Thu Jun 23 09:59:20 2016 +1000
Commit:     Stephen Rothwell <sfr@canb.auug.org.au>
CommitDate: Thu Jun 23 09:59:20 2016 +1000

    mm: move vmscan writes and file write accounting to the node
    
    As reclaim is now node-based, it follows that page write activity due to
    page reclaim should also be accounted for on the node.  For consistency,
    also account page writes and page dirtying on a per-node basis.
    
    After this patch, there are a few remaining zone counters that may appear
    strange but are fine.  NUMA stats are still per-zone as this is a
    user-space interface that tools consume.  NR_MLOCK, NR_SLAB_*,
    NR_PAGETABLE, NR_KERNEL_STACK and NR_BOUNCE are all allocations that
    potentially pin low memory and cannot trivially be reclaimed on demand.
    This information is still useful for debugging a page allocation failure
    warning.
    
    Link: http://lkml.kernel.org/r/1466518566-30034-20-git-send-email-mgorman@techsingularity.net
    Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
    Acked-by: Vlastimil Babka <vbabka@suse.cz>
    Cc: Johannes Weiner <hannes@cmpxchg.org>
    Cc: Rik van Riel <riel@surriel.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

+------------------------------------------------+------------+------------+---------------+
|                                                | e426f7b4ad | c3e3459c92 | next-20160623 |
+------------------------------------------------+------------+------------+---------------+
| boot_successes                                 | 93         | 0          | 0             |
| boot_failures                                  | 12         | 16         | 29            |
| IP-Config:Auto-configuration_of_network_failed | 12         | 12         | 16            |
| WARNING:at_mm/util.c:#__vm_enough_memory       | 0          | 14         | 27            |
| backtrace:vm_mmap_pgoff                        | 0          | 13         | 21            |
| backtrace:SyS_mmap_pgoff                       | 0          | 13         | 21            |
| backtrace:SyS_mmap                             | 0          | 13         | 21            |
| BUG:kernel_test_hang                           | 0          | 2          |               |
| backtrace:do_execveat_common                   | 0          | 1          |               |
| backtrace:SyS_execve                           | 0          | 1          |               |
| backtrace:_do_fork                             | 0          | 0          | 6             |
| backtrace:SyS_clone                            | 0          | 0          | 6             |
+------------------------------------------------+------------+------------+---------------+

[    7.529499] systemd-sysv-generator[249]: Ignoring K01watchdog symlink in rc6.d, not generating watchdog.service.
[    7.530773] systemd-fstab-generator[247]: Parsing /etc/fstab
[    7.535727] ------------[ cut here ]------------
[    7.535734] WARNING: CPU: 1 PID: 249 at mm/util.c:519 __vm_enough_memory+0x6f/0x1d0
[    7.535738] memory commitment underflow
[    7.535738] CPU: 1 PID: 249 Comm: systemd-sysv-ge Not tainted 4.7.0-rc4-00215-gc3e3459 #1
[    7.535739] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[    7.535742]  0000000000000000 ffff88003f1f3cb8 ffffffff8143c528 ffff88003f1f3d08
[    7.535745]  0000000000000000 ffff88003f1f3cf8 ffffffff810a9976 000002073f1f3de0
[    7.535747]  0000000000000001 ffffffffff0a01aa 0000000000000001 ffff88003f4d52c0
[    7.535747] Call Trace:
[    7.535751]  [<ffffffff8143c528>] dump_stack+0x65/0x8d
[    7.535754]  [<ffffffff810a9976>] __warn+0xb6/0xe0
[    7.535756]  [<ffffffff810a99ea>] warn_slowpath_fmt+0x4a/0x50
[    7.535757]  [<ffffffff8115e84f>] __vm_enough_memory+0x6f/0x1d0
[    7.535761]  [<ffffffff813d7a8e>] security_vm_enough_memory_mm+0x4e/0x60
[    7.535765]  [<ffffffff81176fc1>] mmap_region+0x131/0x590
[    7.535767]  [<ffffffff811777dd>] do_mmap+0x3bd/0x4a0
[    7.535768]  [<ffffffff8115e4d5>] vm_mmap_pgoff+0x85/0xd0
[    7.535770]  [<ffffffff811754d1>] SyS_mmap_pgoff+0xb1/0xc0
[    7.535773]  [<ffffffff81023376>] SyS_mmap+0x16/0x20
[    7.535777]  [<ffffffff81c25df6>] entry_SYSCALL_64_fastpath+0x1e/0xa8

git bisect start 5c4d1ca9cfa71d9515ce5946cfc6497d22b1108e 33688abb2802ff3a230bd2441f765477b94cc89e --
git bisect good 8a5968b8e3f00a767f43f88805f3d288756570e0  # 05:57     22+      6  Merge remote-tracking branch 'wireless-drivers-next/master'
git bisect good fdb4089f350a5e41bf8cf99838be4142e7fffda9  # 05:59     22+      6  Merge remote-tracking branch 'spi/for-next'
git bisect good d262aacb56c190b7b1cfeb0b9edca24e38147ade  # 06:00     22+      4  Merge remote-tracking branch 'char-misc/char-misc-next'
git bisect good b36d4f39637feedd4de59b79f9efbe57419a6090  # 06:03     22+      6  Merge remote-tracking branch 'pwm/for-next'
git bisect good 97730d0a214f1be8043cc2e06c7510d8a93d559b  # 06:05     22+      6  Merge remote-tracking branch 'livepatching/for-next'
git bisect good 82b3e0323b0abaa917a383a61e48b3028a14311a  # 06:07     22+      6  Merge remote-tracking branch 'rtc/rtc-next'
git bisect  bad 204502b144a6e67a067aa476e4c0149815e1be8e  # 06:07      0-      5  Merge branch 'akpm-current/current'
git bisect good 7f8d9cfe93d5d5fcbd3719e96782922f55c17947  # 06:32     22+      2  thp: handle file pages in split_huge_pmd()
git bisect  bad ead73aa015eae132a31e8b1324931781d5cd1ba9  # 06:49      0-     15  mm: update the comment in __isolate_free_page
git bisect good 44918a56e3af3c802cd0daeb9eba5ecc22fa4a96  # 07:04     22+      2  mm-vmscan-move-lru-lists-to-node-fix
git bisect  bad e128e3836e98482661449dc811d10741ba75be61  # 07:10      1-     23  mm, vmscan: only wakeup kswapd once per node for the requested classzone
git bisect good b4f255ed4b93bb514f0e79cdbb2c6c2620e40325  # 07:16     22+      0  mm, vmscan: make shrink_node decisions more node-centric
git bisect good 6123aec614297a16b0446d3f4046020a7d692857  # 07:19     22+      4  mm: move page mapped accounting to the node
git bisect good e426f7b4ade5e59ee0b504d2472d850ded146196  # 07:21     22+     12  mm: move most file-based accounting to the node
git bisect  bad 60747f09fcc202a80bba0e8a97ae0835befd34d2  # 07:21      0-     29  mm, vmscan: update classzone_idx if buffer_heads_over_limit
git bisect  bad c3e3459c92a22be17145cdd9d86a8acc74afa5cf  # 07:21      0-     16  mm: move vmscan writes and file write accounting to the node
# first bad commit: [c3e3459c92a22be17145cdd9d86a8acc74afa5cf] mm: move vmscan writes and file write accounting to the node
git bisect good e426f7b4ade5e59ee0b504d2472d850ded146196  # 07:24     69+     12  mm: move most file-based accounting to the node
# extra tests with CONFIG_DEBUG_INFO_REDUCED
git bisect  bad c3e3459c92a22be17145cdd9d86a8acc74afa5cf  # 07:24      0-      4  mm: move vmscan writes and file write accounting to the node
# extra tests on HEAD of linux-next/master
git bisect  bad 5c4d1ca9cfa71d9515ce5946cfc6497d22b1108e  # 07:25      0-     29  Add linux-next specific files for 20160623
# extra tests on tree/branch linux-next/master
git bisect  bad 5c4d1ca9cfa71d9515ce5946cfc6497d22b1108e  # 07:25      0-     29  Add linux-next specific files for 20160623
# extra tests with first bad commit reverted
git bisect good eb910f180124bc59e1c1d2bf3a6f036526d3bf16  # 07:27     69+     12  Revert "mm: move vmscan writes and file write accounting to the node"
# extra tests on tree/branch linus/master
git bisect good da01e18a37a57f360222d3a123b8f6994aa1ad14  # 07:46     67+      4  x86: avoid avoid passing around 'thread_info' in stack dumping code
# extra tests on tree/branch linux-next/master
git bisect  bad 5c4d1ca9cfa71d9515ce5946cfc6497d22b1108e  # 07:46      0-     29  Add linux-next specific files for 20160623


---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/lkp                          Intel Corporation

--=_576c7510.zgj2Zxs266gQ+rvSsgnlrgnW2s7z0Q4/wE6R0I7zQHBVWTR8
Content-Type: application/gzip
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="dmesg-vm-kbuild-1G-6:20160624003936:x86_64-randconfig-s0-06231721:4.7.0-rc4-00215-gc3e3459:1.gz"

H4sICOl0bFcAA2RtZXNnLXZtLWtidWlsZC0xRy02OjIwMTYwNjI0MDAzOTM2Ong4Nl82NC1y
YW5kY29uZmlnLXMwLTA2MjMxNzIxOjQuNy4wLXJjNC0wMDIxNS1nYzNlMzQ1OToxAOxdWXPb
SJJ+96/InX5oakegULjBDU6MDsrmSrTYoux2rEPBAIEChRYIoHHocMyPn8wCwAukSHv8MBtD
RneTALK+ysrKygupaO6k4Su4cZTFIYcggoznRYI3PP6Orz/jL3nquPn4kacRD98FUVLkY8/J
nQ7IL3L9UZg+UXS9ehzyaOWpbOv+ROPv4iLHxyuPWPlVPWqMZI5jWab1rpx9nMe5E46z4Btf
pTLdCYG8u+BuPEtSnmVBNIXrICpe2u02DJ1U3OhdX9KlF0e8/e4sjnO6mT9wKOHb774CfuR2
iXpfAsATx9FxBFrbbMtS6mqSWK80dVWuaroNrcdJEYTe38PHRIq4rB1Ba+q683FGm7UZKDIz
ZE2VoXXBJ4FT3ZbYERzBLwxGgyEMb3u9wfAO7h4K+N8iAkXFfzq63WEKnI/uBMQ6i+fxbOZE
HoRBhDJJcU3dE48/naTOTIYi42kXuYI/4kn3BH+cZO4D94qQeydPM6lkW2LvJePkyQkD3FU+
niCExCRPMCm9WMbY0CScWZdkRZLNtjv9Vt9NcWLUFD+YSpksyYaiMlNhUiUW11YcRZlwZjJN
dz3P9izDsRzXNTXHd3TXl4RIDEWTGLNsGWXh//n8mgaS0X51ZiGc3p5/6JZTwWM5T/fNmWGC
992Hbkjbhjvxkp/MnCznKerzbBbk3X05g7Obm7txf3D6vtc9SR6nJwLx5M3JT3DLUY77ToHy
J9Bv0latmjkv4yLJgxnvGrIMt73Rp+u78S1y1j1BDS/C/IT26oStbOXJWxv3c1egw/XVcDzq
3X7u3XaDCE0F2Y4kDaL8sZvnryP5mDFdQd6zV9yFmdcO4yme8CcednmaAnJaTMFJArdb/kSy
9M+xEz47r9mYR84E9RRSt0hIMdv4Y+wmxThDE4CWAOWCNqOL9gMSJ0IMiUEW+3kYu49FMi7v
MYhmwfjZyd0HL552xU2I4ySrfoax443xqHhB9thVIEnReuTzG3JtB1dXs3RThqep043idOaE
kD5DkHQ7+Fk9W52O9+Am6wcXt+LET4oOvOCC8NzFvo9m+Kty3wHQTeO4vk/GLitvK3rj+M9R
RkWSxKkwaF9Gp5974HMnL1IuzCTrwK8vlgk+rleQJDFuEqR8GtDxyH79MVgFYUej3r+MoyHO
6ecv++D0Kq0ohVOjZAhjHtPG5HjogUQGQQaWqsDkNefZMVpCmvpXHBV5Tur9Cj7tWd6w+POJ
PpUDuDPl6a9wOfy0QH8OUJ141hjLLUXuwFn/ZiShIj0FHvKZPLxmgYvKcXs6wBOddNYHCfJy
5NcZn614zfIjrdyy/Ynv3+N6SA7fBWb7bhPMJzAUIE+fuPddcH6TN//H4dj6UlXf90q4710q
juRNsB/mzec+CW4Zjm79MFyJtgK3kzuy83VI9lVYWaQjjStPwzr5xy/Q6r1wt8ATchEI8R2R
bcu5m2NA0gGM54KnhkhHA2IblLYFFELxqHk8Lgb9DvzWG3yCUXWSYHgOrUDT5Msv8FcY9vtf
joHZtnF0LIQAZbAjsbbVVtBCy9qJzE7QK2nr0B9eE1x7kMXkGIhT7nXg6vNg8ykrfcK6cGuh
LukNdLt/2yrXEivls/hpGctZYPlv6WA5PMQQY5z4EXRxtFA+4bqd1H2Y39ZqDtchBne3t7he
30F3DjmKoAPPaZBzaeK4jxuJ/eCFvKITTdHsVQrQsCr4W6zBvsTPG4gAp4LuTNAVkeu4D5tW
CnAu6C6X8CqF2sjkk5MGQvq7+YSJk6EbkK1KQii87BEuL+fXb3HFwCv1u7G16C3feKa+8Ux7
45n+xjPjjWfm1mfkcIandx0M5CkeK1KHjih8lSUTXf7vZwC/nwN8OpfwX1i5/v0OoHGEXUws
0LWJdAKTty3nA7X0fv+hS46jdBj7D11yEv7GoX5cYPJC4wZDKRcq4+TLAIah1AD4E48iOtEE
DwBREaJV6omga6ADzBK3A/hQlSXfMJnbMNSkfDhbnL4C5rmzJKZEah3dtgWx+CqjC0XDGK0B
dnuFG/ciK6aj441jqH4LEzJ8f3d6dt17Y4yxNMbYc4y5NMbcc4y1NMZ6awzGLBf90dXch6mW
y5xyQ+fueX3M6fkQXURPVBHK/cRYyX3Mihnlw4GPwZBQ8G3noRx/O7oYroYbl4bGZGHVmAat
J9yHs5vzDyM42gpwtxwTXF72mKmaAkAVAKwCgLMvw/OSvPwwcWd+tWWCS/xam0A+R9bowmxO
UJJ/zwQXzRVgpCxEcHbRnODiR1YwakwglzLWGo6qHDPawNS5ZdEY+9JsMDX6bqZOh/3z9X0z
zEsxzJIbE5Tk3zPBh2GvoRjGZTmBajUmKMm/Z4LrmMJ9wZjjeVSKwul8LkLShlQrYyao8xj8
+Uf3PdqLFlSfGqAx6SPmmi7lvHXKMsvSDLSJbmgeckyloeqiMfnSUMyrAW0CjgW5Q8ccLR07
xjAwmDloGemxoHwDosywRH0JylwWv0BVTd2wLNuwFHBf3ZBn6xBieBYXqYuxzxIehQFU5PPX
PiK4KqHoMXM9TeEaGqPJsXgUeCEfR/jMsphuy7rNNEuFqDHv/8VRHZ5sCEsuBqel4DckZZSr
rCQ+/mbfJlAwBd2AUlU9N+U7TZSPZXkBgM+S/LURb8VPwsx+o/VgfpvmwhVzjJkgooruGn1p
miuXRwSVEJrziod4a2Nm2hCCbPPN7L8Bsz3rW4fpR0FOo8tKtYCU92BrK95NVIOIknLikBqA
YmzKTEptIPl2wNBA0FJp1ROCRh7wFL81RmHVmG1pyDKxattWSX4M1/3LGwyPc/eh0zi8tXKV
ozQZf+7P2HycolsyMzbMp7LN1m04kO6CGU+hfwPDOBW1fEO2/i1MYTUpIYw/DvrQctwkQHvw
lYzIPXh+KP7FAC/HW+y+AdC/obFfZQy8qSqJQ8ko1mV8Zh6vLEOk8fj8/agPsqSom9npf7wb
j27Pxzefb6E1KTJKeIpsHKR/4q9pGE+cUFwoNX9NriKUMqWGxAzGp/SVp8GUvgUgfvdvfxPf
Qnr9C5j//IjeS/luzvRlznR4CKYPIOq2u5ljFXPqGnP6Fub072bOXmbO/inM2VuYs7+bObay
qXj1M9hztrDnfD97bIU99lPYm2xhb7KFvdvf5NJKTV4hxtOVBh5vVJr21nq2ZfaGAdsbUd2C
2DjheyNqWxAbrmYuIf0nSsjYMnsjf90b0dyCaP4worUFcYtnwTH2bgnNadkeCrcgZj9R9u6W
dTUKEXsjelsQG1HF3oh8C2IjdNwb0d+C6K8jlikLiR5ag9OLu6N5GcldKYcFUfm+Bn+/kdYF
HoUjlmwZDsZxorAoMgjuCdr1kdksocI6Jp1hGD8TIwqcDz9hIIRmO86TsJiK6y2RShktrMcq
FBVAq44OGkZ15Z1AXRWWiEefXuxgmOI8OUEoInoSxfC8Dx5/CtxmgF73LyRO6jwFaV44YfAN
+Sp7GQCltqF6vpJtpdwPIu5JfwS+H1D8u55zreVa9e21RMs0NF1ntkHvrxlmexuSLRG2jxOe
uvRu7ePtGOU66mAwHaX0TpfmHU+CPOso1R1Ery4oTBdXDYNew/VmE+7RyzZVLiPZE8pX/17X
71TLEAMgs5lqK5DK4KmYFFpQMFmzNtTxEhwvOagUbmf7IBAEXfbfimybTG8EWcsgGFKiTrFG
uRY3qMponOw1cmF4KTZdZOObUu0s505Ib75XMnZaoKe5jRFnRRDmOCuF+mGQ5RnVZkXaG6ce
T3FwPAnCIH+FaRoXCelSHLUB7igjgjol0k3Lbtj1q1LH3EPzyaH55NB88v+v+WSInvnByR6q
Ej2P0I3Taddk24CWMA8divNVxUR7LnooGq7sgka9Ar2c4xvBmMpkU5nDYYhXm87NgH0y9dJ2
PEPX1QV3GIPqiqZY29gbiAoXlQEN01SuTmhuWTeulhxsiymarlzVHpP6H5FHzTKvUJzU4ngM
mslwSBqXV4zZSB5EQU5rka0rmGQYLjCDKZZ2Na/vYABxBe7MkeobDeZG15/OMGj5He3eNOoa
mB/c0Kq6soRCHwTRzeQP7uZZFy08RSBd5Rg+IndZt+EEhymnsmBA63kIeEqvncuGk/NPEMyS
kM9QgCJyakSxSILBj/dHkYlAYsrjGactJR9ECu87USx6Mh2/yzCLWLjmbsPdoU/H0G/U0VRd
uG3ML7OOpqHX29CyKFQYfVgcYiQCn9+f/hUs+UVp1ALmPQ+k7VvbHbZ1R2x7xXTo6jw41oNj
PTjWQ1fnoavz0NV56OpcunXo6jx0dR66Og9dnYtnh67OQ1fnoavz0NV56Oo8dHUeujoPXZ1w
6OrcBXPo6mwQH7o6D12d66p/6Oo8dHUeujoPXZ0/OPuhq/PQ1Xno6jx0dTayrUNX56Gr89DV
eWg+OTSf/Kc1nxy6Og9dnf+xXZ3LqKPtsCuh0kPC8x+Nj5jNmGLImmaYG0IjQi7nQtu01JTV
ZCjPMJS4qHojQDFsta3LFgw+fCPbgRFiFqf1GFVXmWqirFHDJmnZ9OXx0HlFqxMn0MoeAwpi
j8pOjxzQAxe83QZdtdAjMAwup/GgPxxBK0z+QDtnmlRiPFrA4+wMg5zAG+NaO3ULQ6eyGDM8
I7NihpeLPFzVLdtW64D9PE45rvUpELW1sjlWmWuVasiWZuM54W6RUoRyiWaRP8fpozh9QRnq
LqgVU7GpFF5E+RsGREETMLcfCp1b1dLWzIdq6Oh0KizRJvcvA2JCotzDNQYDZaUFgrvrsyWb
e3VGkZwyEF8afc3HmrKi6itjvV1jkYv3KxAaGuF7FCDnpASUW2EMiRbPoR6grHoTgDuFdq5V
a7CF2kXv7kGCpVvizfFiYRbTFGMpjRo4L6hdU2F9Esd9rALIBb2q0mIWaRemTy35iOwB5tll
LlO3y1Fdfh1saVHoRXRtHYpthmKboBZaaVmqZsyNAPReckpVUSfR8P6ymNHGI4xkvY+nZ9f9
j+8x+5PKvPb2t2xBpNh06EhFkWC8gUDTNeRbxB24Roy58b9RnJNNisS5XpAaKmEt1aRHeE4x
UBerK31vS8a4Q/obvZoX35R8M1Rdj3dkOBVNXvjjgmd5Z/G6kt4wWHsgKxWyXCPLu5DRRKh0
wnchqxWyWiOru5HR3uyBrFXIWo2s7URmsk7nYxeyXiHrNbJeIrM3kFEee8jZqJCNGtnYzbNp
qNpuZLNCNmtkcycyZvDaHnK2KmSrRrZ2I2uGLu9Gtitku0a2d8pZsVRlD2kwuYJ25kdF3omt
Mstie2DXx3Ayx2a7sXXMdPbArg+iO8dWdkpbtWXL2gO7PoreHHv3WUSrv4+OsPow8jn27tOI
EjH3wa6Poz/H1ndjo0k1V40vMzZbX01nmqGu0ZrbaFVFXTPqzNpGq8uqvUZrb6M1LHuNB2WL
t9B0y7SVNVq2hdaQdWtNDoqyjVZRbX2NVt1GixqNZ6XdvusPercdeMLHMeY05EJoPOsKAIa5
Ll0qlDTjNX3PMUwZ48B7uBudY0jpeKIZLxcvnNeidM1ULGU5BEB3LXeoRI1Bkgguh3VMDK0P
TvbMw/AIAxxnFoSv4q011b8wJO6Io3UMGHMnVAMTTSULpTEtpqPfH/JUVKAjl0OP4nSMbIoo
K/+qgfr8DWKgRASDdgmGg0/gpaiK6bGoDTw7yJSI8TMML8LXeTqmY2SsMdEK2plXdRs18M6C
3DTJF7bpf1BQNlf8UuWJHRCfX+by1NHoGmaj1YettvpoeJ1xnM3b2OyjY+IsK/ci+2lESIup
DMy09Tdrmgtak+FJ31jTZHVN01ypaeqmip56SUbICE7BhACOq8L9gpjKDPcgrX0Wz6nodA//
AGoTwGA9z4og5wsJm6ZOlnl9/CqGZVHOAaJ9POfQp6wG4keAf8xpMGZmoucC40+KPjfSoFWy
dsxly7aONO/j2DumujNQdzPx7ToZhvCJk2Xc+68lUMLUN4NumcFWlOVXImUNOPZBWeSWWfl3
Aw7JviVSwraszjPF+ZEx8MColH7zp3yW+KiUG1I2g5mybZXtzzPME8tqDUxI76D8v3YwxRqc
zekVndGWriTlP+G9Beq+aellH9JScm6ouqLgdC8xJnZOkcf07gl3MHyt+twmKPx5Z+uM7vhF
5K6cU8PUFV0Ru+88vZQnE3BZBmYJlNPD4OwET92C3DAttDQOTha4hjam/e1UeyuOEMpKov6j
0MnJFsFzkD/A+RdLNPmJi9Got4CzNbKkH3t3Hbid1xTEn4HEbhxCaQmXyjMG5mcU6+ApJBHV
HX1Tegka4fSh42Geu6DGxNLaTj3jUbGgtTFIqzN/elMoXiLSu61mtcNAZSfdxad1S+Pqu0Ax
lgmJiD8dcFxSz3q4aZqKgXOlTuChqUDhKS8Mn0x51DoCQAejCsHX9Ba9u9Ka9Ljzgh7D1hV6
m6kGGetlemWBb+i2vkpvMZMUd52+xsdUbImetWXNRle+Sq8t8DHnNlboGTOFuNbpK3wDU7I1
elszF/TlrjnhNE5RgWb1+HK25mSYHigL4QoPVE40n+cY0tnzqrOmcYrJ1LVJM5xLRVmk6HlQ
aV4XXCyGaSqly1VrsHjHN74Z9VsY6RUhxwCPXoweLcjRKCsbyBeRQGOEqejWhhFqW4bx6HxI
zo5HVKLKlgZZJu3QG9OcTqeo2HiSmzOqaMbmRTClfPV9OrguK0sZZIXQZr8gU+O4fxYBHVrx
ji12vCWJqqpG1mJxjVmsPu9iwCgoTVKer8dNRIiGd85Aq4pgMhjJMFJhpC9xamGkXxOWB7F6
5U1HL6Ap0iKZB+fzcZosU0Fl6fw+xGgsJ2ngTTnaqciLnzPw03gmsP8HAh8wksRVY/RBf6nJ
4S+JG3Sj2E2zv4i1p5yYBAdtx9I8hrJYMdmSW/RccFZO8xVvoA9qeWi5qchC9vZr2aMg+f79
YpUY2xAKtQr+k7Qr/20bZ9r/il5ggU32jR2Joi5/6A9pjjZoc6BOFwssCkOW5VhvbNlrSWmy
f/03z1AS6aOptbtHDovzcMRjODN8yFj3t/f2me0ObHIkqUfPB9bd0Gpb6M+z4f2NdY4FiL4P
08cFu3I3w+tvGi2KEOTuRSOLmyHDdHR2Obq9exhd3X29vTj+vzpNzTwIqqCF8pzQ8fdAAQUZ
LbLG1s3N+d3t1fUHkx9xYiVx/mtZm0X8Ua40xxBFC20a0mIVkzdb0dO1Vc6you6ivlbBc3yb
e3KjC6ly1ZKkTsOqQGnfw4ikrhsZj9W2MAusU7VwW39mS6vm7YKrm0yDeljohiSPGFa2A9hE
8Siw+m+DkXGCq3YI2L4zgOP9oCIK7S6gG2yP8XQ/qOfDTh4Cqgezlg5cLGUk3Uradh98E3Bi
Bo5A+Kv4OzZ5UjETWW1mR2iMyINftoHhaIxA7UTsYjgGRiBsz93BcDSGsw/DsZ3QwAh9sf0u
jEGGlUozi0b1fGKHaFP6ZjRFSHHrXvE52eXk1bq+uLRgXJ8aQEcD2s6Ue96ZBgYgAs5OgFID
ulPfQKJOtjshhYZqgVItMFULZdgNMDFUCwzVIupIsYPkth3nYHDudn5oDqBIhJ6zD6NWoanY
V9PLd6fw6mMKAJlyhxPEko26RvSkt9v0u4iBQgzsfYjDJpYAYOAjAbIBKHiM0xSRA4f+2fOa
rjlPhE1+4HajM4YxnNS8n070vJ/U8QmtzXqwCrTg9mA1sUKNRYbDsCH21Jj+goymvT3tDBjX
NmFSDZPuUQleZbSF5RqmxLbTPU0kNppIwDfdh7HbROk40fqYJzYAIzm19UMYaVgCW1kC1xB3
yU/YHj3uj1ol1FqM97QK9vK230iqgRNPJVpF7jVsZqtgGdjuJbnVKs3rSPU6gaGCpPjoLXG5
MVYcPVacjUb1KE7yt2A83b/Ci8d73iQ0Z7ogWxFuz3TvR/07FVoV+tFQxfd5M2NnzSMP5fbr
zVl9TkcXjwTiKe32Xbee6Ocsf7L+/Hz76Yw8P+y7WZ71m2NbjtP6exSHcErmTfH3b4jTsvIz
8XMtTtK/bYgjj/ET8Ys3xEPPkz8RHzbiv0VakIat2/ryzR0qjm99uL9kVqDKu9i862pfaTHX
9kns+TGO1+MB0nqcm4wL5lzUxFTWZGBaHC0vA4QCjbwqD88VdztsS51M0oQ5LtnyvzRsTpbf
8/ZnzvpQRJCnGpugA429GR4J5CKlflp7rrjCZb2cW6tlUTBjZp/WZOc9HXW22Yqvw/c72QoU
Fg6SXVUxTpZr5tS2qZY8/a7CpCn8bJUKRsFpoaWlDRN5sPSsGmtZuLU/lq0bW1erBYMIS1d9
uVk2SZcUMqz4Np62woH1TE1itEkUYa//6v7DmbWIc9yKQyFczcloSzkUACEkmzwjUT6pqxjy
Gf8zEJPAXUE9F0qra50Y7GsQ16ujjoHJD0fQiY2erXCT4mmB/CkXhw1htsYIGwd8dRIGLUa1
X/MytFwgyIlqrwBhohbf0jOuplPS7af3HwAjcuER/QzDuJGmvYmmxRDCxY4QaEAEEpcU1F3f
Gax1ptQXYJeEJ9oMurQQoPdrMRckUxDBy+W6OKGX7Y2zEhS1mjzEJKEElJYmgweIKAq2eU5D
dbnRBE1mPNAbCK20C9osjYhh7xwtjtN+5gx0XVdgX50fXmWcid0uQSsz3LB8RcYgv1fdjFyx
LuGTteYSVr0o3IOUj5TAPbhMLKEGOjXTRcGB8hgEfHXDzbFGAvlEIzkHIbm2u4skbRn5Gkkc
hDR19iHR0mfoBDd7sogtoceG7/KeuVHigLqCfe9PsXkoNZI8CEnuRQo5CmiQvIOQPNvZRQps
r+5d3f+D+kYQf/PUA5WmOYbAdGO08gHP1WJ7A2Bv+n8r+S/s0EMgKmSb9kcl2DDbF383Ybc8
IHnhhoEng7dQvAOyFm5IkfibKH6HdIWLvPXe7EyDFnTIU7hk95Ab/OnmghaQvvT2pSY+Z4tM
sROzNS0OsOOn8GzKdZwXZEN130S+H+yG9LAJFOC5tVsDpHvyVjMY4nSexkWqAUJ/J5BggDO1
rcUZzuEZH8aexfQL1rZ4jfHYaiFtCg63QTjI+p0X0nrV5d2YYhZTo1GzfLm72bzVxrgBbDPY
IeMiEXzyanb+eYijm+oCu+aOKF/qsj5zdb7mILVBedhOWpOnRb9fL6eSAgZpw19u+H9cZtKy
/hyHXEpRM//UaRl1x0vN/OOP6uXruMUMlROdrF9X5XLxuOa9KutIesfq6NzjOo35o6Ik1Uj3
VTmjujxX1Gxta55OSw0nI+TnduD8n8DhRpA9cBEZzWAXLgrehpOeI/bAkTvIXMOz3/8QFnL7
l8PeLdapolxXvONXWNjZz9khVuTcvhYWXtQIHyoiBRK/xSrLRzB2PVrT4TQNer0erl1b88Ua
ancw56u41sWIkNOieIcDVSktsvoTG29Zjtixe47n73wbB9rHyyJ959AIJT+FDGL71KXSVUm/
vPPwsKTxm4+KNAHOMl9Op7po88FsOZ/Q93e2foHI9eW+F7DO0fIYhfUno1oBqyT73coL14Nn
dpC80nZL3qMW3Cu/r1p1Z0bjlkA8YKfurerx8agBU12wpULkYJPtLRUMzXdUoCb8wRscrgK9
BxhgezB+JLqrhqQl+t+q4Xv+fozD1QiZLPKv1JC2iP5la3hk+38yrDewMO+KTS188trFv9PC
J68RSdi6KMz5aEwrcI6FeKp2VtdJxXZ+oGuy1lWe0zNtZnxfIHDdB3QH0pX6nO0MFq+YaVj/
0eIhE0amVZm+7OXGw5q+eZKIQAIaYQf0im7JneaIQht5SqzU9HYFDmlATyq2WPGJ0nfSZ8eP
NXnnkApV8pSW9e+t0aLx4cPq/j2uJpvJBDyTPiLS4q+K3hOEFn0jODnIgsJCXGrpOsfW/Syb
z7MVRTrV46wJtSRIxi5mUl5Cug7JRR8xmPXn1Tx+pE+/nN5ZF5fvv3741tdiwkFGMYUUeSox
LcqzslwNTk/jtKBwup/M+mnVX64fT6nMqZZzOTZbLxeQJPfjamjdPFxYR+fH5PjaAQ2VifUx
LslBzxOjOs+H1VryhUDTYqTGEGgvaU0wUUfllLc9yPkKmYE90ACBj42fBmAAPhw26pv2qlZY
leLFdgMjxQ+uyvVnUrQpLLZLUQCALaFxanTBABSLvtuWkS5naN/zmKdwhNp5eD68BqEhXWeJ
dTQuHo+bHmhqsvuyrss6WsT/o0VeyOBYY/qRpFFKHntzgHVNS/dytZMOQtmQz0RslG2JjEaG
5qj253QtHg2R7VqS6V/7KvEcJiBgamKZp4E/mqXzFb0Ndbaa54rVZviB0vPov1polr5MqgWF
XeCSkQsoVfGabKRFAgdBM4tMs/UCDMaBkZSCq/HalqaxoyugiTKwRvx95IqjY5gIkCJxPG3r
WBpSDRDSqvoRk04NpH+GEzgC02Abx5ddcVxOORs4LtJOG42mS4cyjJreqSrcScCtHO5v49AP
YRlmz6PnBQVmOo3HMVGd9XseUbzRiHgUNofULdlqkZEfXxQ4z0LxymRuDGk36gstEIhWoA5Q
2k7UhUJGvb6/ubaGfGRWZZeN9GP7jp4Dv1YhjopsQDEIG3/chUCRohXnrzsYR9rue4JCF/Jv
Pny8HA4s+vKA27rhDddklf/okoJcqW/W5Rcqc/H+w0D9VHMyINUc8tO6hWT8xM9z7M2BH1rb
FF9fA4Bv+c3CnQrZsre706IeoEuwxRo/M/sPBDm13araqkHzIwofYIspfkXWhRaIbFWoX5s0
6C9f6nNwsPKObf2ihQWbsyENh3g+sELh2aeO73l2yyyWFrNT1MUbFHGuFU/e4PzIfiBcZpLX
+Ro+9sjvfXrH2cnQOsJ1QO8secKUutE4rib0qzpyfIxmji2u9kxDBh4otPNVu57VFnRclZhY
dfpGpXO0VCThNZytVvMsWS5q0YH1yzWmSdJPTp4524xVyj613VMhqGJkvrzAmnxffBfW5ctK
NxC56iE4liS6HFi3S+7v8TJeT+qa+7qky0kZVfKKuivOOdrn0tbrsrIWFWJCGlr6fjxktdA0
SK0uQKcqNKBUfOfbZd57Xs7JdMzbm2Sb9cXRKxMNgoDTFytqmQFfjtBTBBxg0wo7547cGj2B
J3yY+mIRr7LBgL+N1Pnjyy9f7r7QPOa7EwhviGfXF1oSxMZvFhntZ4QdKzcIbYJQP1yPdOr9
PRrgIi5jmlzrNQivw5szZGLVlNTHpWEaQRNaxOR65KmuKXSFrom/TSaDAf9Q+xA18JViQJGZ
0JTgugNwwLpFJOsAo/gPEVsYWpA4wRqv0bQ0YZvcp+KT1fSAneyllg8E3+Sh5JFpOu8V5au6
oxjnqsITHh0B6GbD+/ujE1pwj79p+YhWaswRu+E8NlA04Rqj1OMez4/1wAqVn8NizVnljaU2
AK+cXky/PFvdZFXZjX3XNz+iuMubN9pIq6RDc3S/PjX+qjh5Fw9szHCaofWOQ0d6oJhczZer
VT28yZ4PrOnExjhxyPG5aQsLh88G46Bx6wFuunIhGSRsDBZPNO2x00S+cG9MLri9U9DzwG5d
lNnKFS8v1u/NZXx9t+/oUoFAAikbk2e6GFjX72+ssyE4emtuDIP/uen4kU+9U2HkwYWdP03K
BVuUZI3ghk8CF4YzdlIbWZoSazj7yjVutvYIiJxh+O73tDKX1KxqK+yittqNAjm8V4winBi9
+6SFkf2lBbJC9AXHbpnHfFOLQaVXxgnbt+Z1/iTsBXzg+PebhrdXjwnT/czJnL17XiQZ0uLk
8b5zcJlMltNPnnZ9Qy8MQZ4w9ukUoqFSW9Z3bBtbhBfnlq2WjGEo7CB835SIgoAPP63iHMdu
dpzwqO+ZOtJnxnRZvuMJp6dJFETMKT547/Q5WyHxRcamhQgdbuavecaE+htyyLPefcOvv+yB
OWUaZK/PLDUa3Nkk7T1OGmiQsHQJxwVFACWStoTXbqaihPBAUR8O0VaY2T2cB6LZhZH2gMT3
XHmiHMBoMclHID5LaX/4w5pyadxFxYeWppu2QJGeeH3jrW9mhdbHtkoaiqlG9XmbofELse4j
Z9w+pzAfBNnN56Hx3GUWyObzxHguPbkjPzGee0G0/dyLHf2cRrO/9dwPDPnQZSZL02s4902t
0uP26dtmyzApTO94aAzp+shYTsv5KCEX/OrhszXjNCqvgKYjQYU9L8L00qvCmDN5U+rB1Xo5
pqZmim7P0e9Ar7i5kNSd8Uh9TU7vSzKveMei5uxO+W9g8PsWq6w3XwT2fL5q0XwpIpUfHdWP
BuYvSgtW4oSTv1VByohWnFY1mOd0lmSjWUIGGMwGQZbw18t8xvv2v1ofMcnPFVsCYcXR5cfz
6+PafGkk8m1rpB57wyjFLljbG1uzh2IdRJRKoi5TizUR+g9FhYN85nJDbfxhtV/vVmm+R+W7
fSrTUggFlq3Kdz9VGeftGolW5buDVPYj7LlVGyqTsYHJi+c7Gm+HWxonDOC6NlQOxxWAax9H
ETP6DzaEySQZxcmikSeLRtHst+ZjpeXZuCjXtK40+vHh2nmDgAGKUjjuuCh4IboeXtxa8SRe
le2eHaCl34nfQgX1QHeELZFx7fRi3yf6xSh4xIUTXWovF4kWDxyvC7UnnlRl9dKKI4nfpXay
5GSnsoJG06sGISXCLk3wWs7StW4CV/LtFtNyko3SeZy3yy4+6eGTtqgXBG6XqvYgRJHs0tvZ
ZLGsinYpcnzyHN9gNO3KL7/H63W2XGsE6Tpdx1s60eK+16m1qW5Pr+uOH0rb6TjeyMFr5QOb
CSFd5EfprEjL0SaMCP0u0wZb7QktN2OmD2kYGXXqjaooKF7S4gHNv2/1pwPr2e77A9iMe7UI
WufsPRsG5VydgFKBEo1i63OV4EKkhzSZ5Utc4EJPvw6HBGedzzJtJkK7dgRVTbd3D5cDFamy
F1qs0iTD1S8VVVzot17yDY7faYnPmz8LpyFdzhw2kA2vobCO0se+Nc7KcZw/HvP9sI1K1E7A
bKP5hF9HI1KULDXi9ZRTDrh6y/oOJwDuiTpRz5pZfJMdQgWch2KzyPvH5JW0kOS+8vLSYbgU
6XORPmqEKOjUxa/VOm0NHK7KjzrZplm8LJ7SVw3g+kGXFyiyouUxQtzzgy71z58LLRtw3mhS
LRavWEz1T3AZMU6xOv/3Q0y+c2ldLqo55sZJA2UL6yZ+RZbKayEdh/d8fwB5gV9U8JS0S76W
dW0/+qEs3gYqqQNAOgIFz+Ux55xbYeXVYoxQRGOSMaRpMavGltOzB07zYvjAyMqhZMiab5R0
6nRUTU9oy1I0gEGXhbYE9e32nr4MT4Xpx/xZc+cGn95fnNTst8HN3ddvKm3i2yf0RXLmxDnR
jqmgKB5TpCCfajlQNVgEoRTZFdVykQtK/Ibc2dc/fiSnKwxCgbOYfK/aF3UXLt88YRIfk+YC
NWRn1Z1ruMbk498bKN4WMY0hD/wLJsKfuHJqTwWuod/gqEmwgz0hfBmKlqXmMS07/GfhBIk8
jXVnhjLCKbu3Nx/47/KNaN4asbPXl7Ynw87uTbmskpmGoA7vst6NkwXFqlLLR0wPPdx+vObk
n2ZJMTLMiHTITwOxcEE/DKxP6StFj9xmn5aLKs+e8HcGP13f4ygFBZe4PtdMGQFABEEXNbgm
LR0p71tVf35D3+pqmuS4wJ8+osiJt2/P5lMAX/atj+njIza6tSLCEWDlZfmqKpGstIarNH5C
2xfWaZ2QP22CldNVUqye1qdcWn1tp5RkssM3a10mo2SxLBr27ZeHc4w1WrGeUpUtHOrecAMO
xLdl6Hdrp13aQqQZ/WxrkMgV7i5IPI/XFGhUKyyO3DbxK67jrEndVv68jhcn6i5F3DzZ4kmH
+VdQgv53Bm3CnBHVtYe4odG2e05PSGprChocepFw4Nj0QpIWbn+g9ZNuaDTx2UObrqGXwk1F
wmomyv5GZ+t0yqbKNpveqMEPkCsgbXvMvWh+6P+oLRVDg9vRMVE8p31v8e/fm+I4d59Wzs+1
EgZKiNRDJhJumoYsshXvYsOdiZpZ9iJHxcLkq6qDf8Ob9/TZdvzMpj4AY769V9J4AXK7utga
0rE3yZYU3vQqkWzASH6DXm1+B03Uq46JVDn7m9PMMBC7Qr159jg7ULRTkhN1lFn+2jMtnAxc
0I7GIhG96ZzWByTm34tzYV2p366vT6+vj8bH9PXammSPGS5/efgdVzOkteuWrZoNPvOKAqMK
Zhc8ZwuxUF/Z6dlJPNeT4pSPnZi9IzuZ0LKkor1JmmwgdIn8GMGUxonQg6Unz2OsIaN4Gtmu
Z8JEXdbEFiZ/LdLUgPHsLm55C1P5vmM2qud0adQW5m/fbv6URw3Txc1uYJIUDDMTRvyTJl6X
cxG+vFQmkNslvG2A6HvxZI5Yzksf7jwsis0Rw0fxDvddaPKN6sk32gLqFK0XQnjmiPPCTimH
54Sn3gYAjTUEBorBfs6HPeviR06f/j3eLv1YrJJ4hJs1+JyYAx7cNk9Jle6WmKSV/cWQ9jvN
gmSVxY4p7XSaQ2VS2K5ryosuDUuu7aIwpd0u0k/LPEtiU1x2yTwu4vVG3Z2ycPn30N5oda+L
9PLZcyJT2u9iK0jalaMN+U4ZgVWciA1T5YcdxQPX2Rg0nex3kUrblGa69MHSahYVeUTvYHZA
0CnpXdDQefmfKS46iZMORg4T8p1iMiW/0Qiye/2mQQs62VUlH5ry3cwp5P0N/YOu8o4nNhQI
OzXgX9Hm60edqv8rcjcGT9jJyy2qfDWvTNsRdrKaRfnU/sFMJd7JaKoZUC5Xa3NBCjsdqH7J
1vMsf+ol/8/elTW3jSTp9/4VcPth5BiRQhVuxtixasnuVtiyvabanp2ODgYIghZHvIYgLal/
/daXBaAAsgCiZEfsyypixi0h88s6s648ZtsqhpH+PH83sxaeb/MqgmfSEMObz7b/UOsI34S/
sAu8T8dJvNiHiXd2yMNB/m/d4K5KG5iIlGBVdqOdRLrAtqzGLqTLv9acAk9e09+s8504T6mA
ai9kaKqsTOmVgzitIGITdxTC8NVivP1W48ZV4iLLJrhMHM7i5UocN4fsQQgfXl59ODir7nFc
rNaPGxzurI+zdLNJrQ9Ztoir5SNTgEv17sF69zO4xMfzOWyS0y2lOSieHPpVTqNBfTmM3Mj+
VOMXa/PlkH25tu4ZLo3zBEU5Q886Scg/wLWGf8Xj1TzJrF8fd5u76uSMcOPGel9Q5MrjDd5r
LodcbNmQQHaLcH4LsTAhAh6dHRV2D5fmp20ScCc7Gq1X9+lmJM0xR0VdBzD/lPkvRAOtaQnf
4JEov99EUf5Gltdx8jeFGVLEqe/GzGtWA8axkZ5cxYk5/3eEhFt4NSJplAIMjwcDoW2zrdgz
42FIFsW6n83n1ji1BPpsEW+rszm0sRB8d5nFcMnL6/dtn9tYHOkqNlsgu1kZwHger4UeVvYu
zxST48PcRDEVVw2wWSti2m3S7csei14oNqG40OjTgAnFMP0KWzp4Eb3BOL3Ly6mI5dtzJ+LI
dWiRwre5bJ5kHsOb4f2qzO8AQ01c3JbWq4rbc7jJNFon9xN1YANAkMf4o+CM95PtwPpyeVOd
DOfyk4WXzHlh4IoADbtt3m4wpsvKKBYC1LMDvKVVQWGdrfINi5njWPGc7EARsaV8Nwcz92Al
XmWWNkCraeWPRV+RI08K81mr5ykM10Gca1GuRcBsNiKU4Tb9llq/YZD+I8N//9dSNOjtqp+s
+ru7V4rZi7D01JmxqF7jV4qEjYFFuWbEIO1Rg+EvWbpVIGLzDS+FcWDbula9+gWRDUzaNKKw
WvfxNN2IY6ujA/2Cjxa+miD7MFrbR97rL7e5v3yX47Js5ju2nWbjImo5fn0tzuFfkDHscvXV
kpm2C5tVu2+r7vJ9ClyqIPInoGI0W4tZluCKdbXMzTqZY1snotvFNPVfKJyQTC5mhWyKtV4Z
PtXATroBVIQPFlCBzeH3Mru5+CAHgKyV+LWpRohGq9g5hSecbcNAspdOBIoEaYHgex8GLnMk
lTIIZrgAFjsM+4G/ViwelwEVKyxPbCpxLoP55fLbaJvA2eBzW9VEZ1WqFrE8VLJHBYDAUpXn
rVoSh7Z0NlxkiROMg6I1htfZheUEv4g/WEVKORqlYq1ZFm4D1ArVEVs6gAHYd8kheA9YWYU3
NojFins8wIQUG/0+dITSno4Mh35kO9BzgjsquZW3hK3ERCwKoj3CJ3ac2DbBEAtuC3/dT5Cn
KLn9l/WvN713SAokexCtWVnXyNi5OuOFMnGrGGJwlgCVx3RQ4u1ENPM4GaXrh1HiPL3ckY8B
t4BD6myZxpuaJXhl3ZLOR8gOVWRSCERTMhcRX8CNsMv2cWZb8Tr0YFDwsuO8Fbkeq/F2EMwq
kgMbG0xwk3/kY4c6eyU3s33yBh5ngv/LbDleLSfWl9B557GHS7F9P7u+xgOm0O/7y7yC4BT/
VEKUm3lsXjX7edC7FGxCzOBslGUux2ulGBzvXl/qXKDA4LvYvUySyVhs9+U/eCkRa6x0mcvE
AEWALTgkWr8gwnmuVE4KU3mvL7ZMPadf5GMDakTee+0v+bPJSL7ml2ycmd3XCUKBotgdsh2X
f83NZq4u6TFwv125R8m/Ln77dPn6s/Xz9H67ffxZ+h4UpivccayvK9Fg4xR2WThSTB6X8UJM
sXwTjcqTb7GCDXx4fihYeJ0c4PKuuAXO5OsyOUBhxqVzOOWSo6hplx++vH/34fwSSRleKQq8
UOcU4gQgdq5T+JHBPWNgPYhp/zCarr/Gpfttf1xcc4DZp0gVv34Ux9Kr91c31pvzq3fPnqnv
IYN5x2KVbWX3QrWdqEHjiMMcYl/PFqMMY/SAwLUjjCoFsDc+YvLjK1J0y7GCAZc7/WS1ge/h
BejpYN/cuYLyI7KZ2KyyUZqM5uukno1FpnztK/qQQkwec7IdoyNXam77tkORX64vTz69gJF4
7zW5+9Gbf37gyuONXxbrr1JlPudofdoFdeXnVX5xzkH6iGl8l/ami6SXwNgVu7NF+tdf8RIe
5RVqL4LfkvwRCmQnWg/BEzYDCfAtXU5WajoGoQ81J38+bkQTJ9t81BH5JIVpWU9oWXrmL5fC
gGz4EXZIlKiJtDe1EWEtr1PuaX11CYsoBJfLMGEUHKdbcwE32goG8nMtt59tAnTb0UitBaHn
Y+79sGIiDbYsJoXnGKUpEvYewd4np7VBjMDZJPcDh63CtEjCMKe1KStlRmJfYP+4KkSOh/MQ
ypTcCkFiB9IOS3FNRAtjv1LcLPzcxvJzIYt52AYUZ/RNvJ5TzaUJCn61ZGD+fHHELnEvySMw
eAgzt1Ink0lktl307QPVbJuqZuZJx8JDcLYPziPj1aME4wdgoXFJEUDH1ZXUOQAPjMHFMQBX
B+fvhufWYruOv/WTgYeUJDefzz9KC0ryu4MptRi3jyVjiMVBbHOXkxHxVSZt+be2AyMguEvx
g83NGK9vhkUctKDPxS4Ge/O8DpnvijpEnm9d7G271zTmywMlOB2ZQ4wKnME/f68SANOeez2F
4TPnabUAfWUrye2QkKge+Tf+gMoEntulMlEE0zkUXHHv1agCe6RaSN7NKcmYJdOYXubJxfLo
gOLAYr9Q1G6I3V1J/fn1p+HVh/cDS2zJPbt8IgKlWImjP0uUp/4ovIjCXP0wPMTndp6Oh7gF
Kkg28AIX7mPq94hh3uRTVnTL9UcZuoEshxHnxyv3LUKvBbg4UMRF1tnnyt4CsSzdCguYZPSR
wo9C7A7B1Nf/KE7Xxg1gTi1E7H/3XNx7UtKfchg+x3nnoBGdgBoxl4A/DlQ+XkLHcaHKEHrO
PoM4EmFVe7RuxJlloNYF9BCcfGrE726GVvlTI8ZSdFhqBvFMFJMxRcqjkNVwLSykD4JPBqeE
+lTZ7QPF6HqRvc/4UXRqGVgG8a4rZfL5oaCi3b8VgY2qJRPbNU3Tc03TuxFHL9ax480YkSGl
EXuF2BMqp2gciq1cqSiF8xooUs5ZmVDUsisfHAcPNsjkCNPLIh7LqZViX3sqTp1fb0+tzye2
/QJBSj6d4N8h/X8xJE6tS/n5uqpTxLJHqTIBzE7LeC0HwA47AC6yPROwQ8CsAhxRWAcC5m3A
hyVuB/YZ2Q4QsNMG7JgCy8yaBOy2tLHjGgIHopELYK8KTFcrFWDPEDgUI7wA9tuawjcF9ijE
GAEHbcCBKXDoRMVwC9uAQ0NgKHw/B46qwPttHJkCOz6WFgKO2zrv3BRYJg0l4HEb8C+mwJFL
WWoBnLS18YUZsGOLjbWXA0/agC9NgT1argk4bQN+bQosNnsF8LQN+I0hsFhd8MxPmXZ/pD5G
PFGeazfGfiSw2LAUuoLxHwrs+GWJnR8K7FNORwJu08fmwJHL81HBvB8JjOCJRRv7PxTYpTA3
BBz8UGDElfqTtiVwq50ti1gn2UDRhJTFRtDI3O4DXn4Spw7s+8QnmZp9wNQnxnEDLz7J7OcD
R33idFEoPsnk5QNXfXIZl+WRuccHnvrkBY4shi8/+epTQFeI4lMgPwXqk1hxQvoUyk9h+cm3
OQ5J4lMkP0XqEwvoVlHUK6+zej1xfIeWGnwsaq2q7bsBk6B5RvkBU83l+xzHBnzMG4WpVvED
5uecebOoAx1SIgX5x7xhmFf5SJ48DUeP2o81WS3T8rThBB4d6n/ZbqZZbul2aiWbxOHJS/lP
Lw+/cSpDL71E6kPcqW22L9UdrgNLagQEvfn0ZogMNvOpjJydUXJymWlYUPgWhcxSvysAaWFv
BIBHdQUQUrsbAYhTcqiaGBleQ0MEirdbIoR2BNsKIwTf8xzVDCHniHY3W8RkZ3Pz8VoadtH9
3WmRGRpHTvGpN37E9eYzxe3auB/Yd+srEgrJ+3rpQovZzm3m92wfjmmCzIkG3LN+v7mwTpjr
+wEPA99TiiLPpydvQ3rbTZrC21q+JciXFFwvFtmyewg0h1tXfKCoQD9PCuIe/vZc3WI6YUjX
Gs+fP7cmW+n4hv/OiiDsu+VsS3/tkTc/WXNlaZrfpuSxOcv7XCeS0/qsVpaztYzdSfDZGQK+
7Rbpphcj+NtuPiE7GTihPy8Ik3Q+z3qLWZYVkSdbEdebFVw+NkoTRNyHd+f/fTk8hheOJ5SD
YlzlhApOnAyCHwgXhNhIdYaLN193MiXsfLVEfqStIM3N87aPCjYKuEkpu8G6uMyA+czmP3TT
Dk/3PPetvGHXdE8ZgjDDfya29UyhOZQUe3/gpwKoPuwZ3vfzlwy7ZsoSUBhq7L9+X6pby28U
ozQtElBQsZL1Tl2OIOMzLhoo/qCMQXkvZE7nZcRJ0PgMT4l0U5pfps6FgIEiCCjdiGU9L0Mv
MPUx4rDaFB8Z0nZstjuxmb6+uryyLmAaoAhdHmDTVKTO2C0pfcRdulmm80oGjajIn0EJM7gX
YO+R58+Qf/IjZG18oYD9EDY0X/AyRJa+uHPJb+tyeBUWbkKhObnthvZdieAxv5rVo6FooR9W
UnvYLOETu5baw2aU2aNSNC9iUHlHgF1eA+Y8Gu8Bc3cP2JcGhlLVT/5gf+bu5HlK4pQegfBK
MYcN2ik9Bz/S+2w638YYdqIBYC+zg8O30Nv5ogHqvpIShoyyrS8neG3LpVk7+QdqVXnh7SCK
SwZY3Oit1o/7pqIBgg9HoSpyLw/Z3ctjNPXyPGhyHwIL3z+4GHS0PJ6l2+Tsn4ydNfDQK/8p
dM+tTGdh5SAV4Q6jt4m6cOuEH8uy4jq2e5DHBIAupVsqAL+ut714t13Viu+jV1akEfF+L1sY
GnK1tGLrRJpIvsjTBcqZ11cCPJcs13IBm6RH3VkTEAoB50IqclUjsPwj7MZkzgJJ3c9k0M4q
LCWb2YNFQ4RHGgIbGl1D+BHMLwtA8e+3WhmjP5GqbHVXrGo7MnRGCjMM0ROcaKDKEHgKRknT
2SbbvhhU4Sl9SVf44WP2WRpTZ8lmJrSx+KWGhjXSDG2TvO9PYDR2twcmtuPuEbCrr8sV2UUM
bWeBjHGim7PdeJr1s1vBuQAq2mGTDPuT03xXQBDSWKPGcdCXogBR5wIweyegemJ1nnWRXSHW
SI7oSaKrZP+BsV6yWiyQJ/2YYEWrl3tsNFRrLFaDZJ0dlynptPIY6y7PpQ5bmvTuUtuxQuyx
OVUR6xVIPSQSTeZpvDQqQJVNUxRudx/kQXKbJndIsG5YFi2frjDdh53tlaBmRdAL7j7TbPf2
nk5fncSWtBqhjoF+iag7xSrwlFGwx6YrSmiiafIdwnEtIwm1Et3uM88O7haryXFxoNLLMphu
PhoKVjydmlcR68QaDCpGHYW9o4l+Keg1wr1jK2FVOGKt4UDfbUiXxDqx3Zva5liFuq1VWlm+
geryaf53bNuSVifUYNKGxewzmqpasWHn6fLW5sg1kn7bmzFMIzIn1Es06EmGeTBffc2Oiywo
9TJNZszdbD7H0t5BaEmqlRoZrDpinm47NCyo9LJ8g35cTOLJooMwkOmkkVlS59mYO3UdFSfp
9PI6b9/e2qx0zTkqsaDUyuTdt4xBML9b00qIiM3rumCuEVwj10p3DDaQ3v1kdJem6xjGOseF
V6n1sr9/hurkts1QZrBsMy/bV3s6cZn+CMLc7oqWeRMEPjsqClRaWZ5BrXz9uNX2YNu49QwW
Eo3W0clr0jrMYKVk/mYhQwgvjwssSfVSDQ6RXrLZPz7qBIJKL6u7FhCteahXtc3ZqFcDg/b0
tKuxTl7LaixTpHbuwaRPF0QdOjCn1Mo0WBfbdJvzFN0WmfSnXrfp5LbpNm5y6XGo23TiGnQb
N7nm0Og2nagm3Ubv99+p27Q92KLbZFLmp+s2nbwm3ca5Sf0adJtOYKtu49zkBudQt+kENuk2
bnI5odNt2uZs0m3cMWhPvW7TyWvRbeTL/p26TduBLbqNe91HaJtuc5+g2ygd5HfqNp3cVt3m
m4zXA92mE9ek23yDqySNbtOJatRtgcEesUG3aXuwTbcF3eun0206eY26LTS5hm/QbTqB7bot
NFmdDnWbTmCjbosM7nB0uk3bnI26zeBFp0G36eS16bbIYDY06DZtB7boNsdg9W3Tbd4TdBul
lPlO3aaT26bbHKO1+EC36cQ16DaHf59u04lq0m2OwetAk27T9mCLbnMMngF0uk0nr0m3Oe4P
0G06ga26zXG/T7fpBDbpNsf7Tt2mbc4m3eYY3Cc06DadvBbd5pic7xt0m7YD23Rb9xWx6R7c
Nqxl9zvpt3a0o0t8PDMeF6potXK7r1VvmU3Doncfz7bIiHJcdp1eL7/7XS5jt/G8Q41BpZNF
CTS6trGbpctJNttfNXTyCkq9zO7tq72Jb2xWvbTOmvWtHcqRMe1Qw4JSK5MZzBVv12jd0Cy3
4e3RZQbPAFz7mqyV2fya7Ha/BHhrB03v99oh2/x+73KDt5yG1w6dyLYV2u3+vtqk/3wz/ef6
BnOzUf/phLbrP9fv3rrt+k8n+7j+c30Dvd+gk3SSW3VS0H3GMr5Jx53aWdLp5ZlMVI0ObGxa
rbSw836oUQc2j6MGVRQazNEWHdgst0kHmmwb9DpQK7NFBxpsGJp1oE5omw7sbqLYqAN1Ipt1
oGMH1VkyzbbxuCY0EEI/xhtytCDbYiJR/B75FPQqP39YyW5r3aab1Pqz+vcqD05jX84/vb96
/+sABvfI+vcRgT5ELRFMc7E4221nc4SEYZE1Gn1bjNIlkt2PpCH43+0Hf3pmP7CJXYMV24Lc
vB9WkbMtRbLbLSdIkr263yfdF3wheAb77U8BgRE8GfGI3H7Qt3ubxO3ZNmde72vipI7rRdZz
VgMX3fhbvJkgbloe2+q/X1//bg3zbJ/IkHYyc137zT+tv1PG9FOLRRE80n+5+jC0LtPxLF72
WD/s8x6zbPfMZme8EswEQpAN7CBaSGkG70zZ1EnGofIFYK6TeDysU0zssIbpHcecVjHtOIoC
38ojkAQSM611Cs6I+5ishJhO7dhmcaynkFLdiceTA8wLhK262cSJihWBTxRV4I9/7Ff7FeW4
XI/IUBvDxxPDJ5zUON09Tlm5V4iFLXpyKbjGvuCqVw9X3wdcafwKQXo3y1Emxt063t6Opout
AHBjAeDVAYI9AOaloTslsR3Hvb9fZ2cSxGH6Cqkpkx1sxQ+QRosFipOeIUdlDcvbL07gTxMm
sBaLeE3BY1doCuYwVCWqMx/UJQiCyQSNvxqBXzA648kZGqLOGB42guh2wSgKToLXX1fTqWAP
0XH16uP9eE+q505Q5OHjsM49RqHrY4liiNQ6kDsOdXvBjdqi43mdb7+uCfcmU/DBr+NxNPyf
4cX5u3cj3x1N42yLQQAgtHhcm3S4Aie9CScn5D5PLSf0xCCwme8kAfNdlzSp4vFtzYML/BKi
dr8E+B8d+CWEcD5m1VeUf692m2U8n/zBfTjLvJk9wG0qfhgJ7Jdu1Heu6Tc4a770++wavjHy
N7dvX1u40hxNN2n6MnD60bWSEnLWLOVTSouTWGYY45yVGfrEonYbi3WVosL0SzDf9t1msM9x
stuJUqkwxIIlsGt+LU0s5A58aqECE8uWzVXBcKo7+P2Wmu8ycquhTHN3i6wun7Hq/fUer1h8
EKUcvQe/K2s1/jdSMoszCnybfdstcULB4BvjeFzihAUOvMqr1l57OPt/tja75RJ1izNrPZtY
vEhdE/Y9RJ6qtCxMTAVMAJck8lgFWxFClhdO2mE/CFwb76Pj+d1otxalTYV6+c+O/IMR2Jmc
WeFk/c2aTuzT3Ge48NgDvxdi8oi1fb1+HJShxKz7WzgRweWKbrvJZ6jkCgOHtwydTzLzoKiv
LApcpKboVzQAXL6snEGmIRWbB4spaC/yOgyxyqhA/oGqTYHRqPzp3duPA+u3D8Ob9+fXr4Wq
7N2Nd7P5pMd+7fmn1vX5hXVaeNA1bl3YKSUwFhWC8+dKNByN3u32cWj/BE8pIV06TM/Tn2Zr
6TZXCZKe5RnEpTPd/1MYU5zN79b0v2yTnI1nyzMx0HqKjbv+wOoPEIfvb1trtU6XFijOlum2
l25v7T4If3r27Jl19bF3kTPB061XiJDhF1fTMsVLHn9P8PxvcVfW2zYOhN/zK9inpKgokbp8
ACyQbr1NgG0L2GlfBVqSY8GSrOiw6/z6nSElJXZg1ygMNAhiiSaHw+ubI+DMH7dT23eEOYzd
wSswUv8qiMiN4zm/EUUgxd6IopE5xNApoze5GPRNW7CbkGKTx20KknRnElVB3X9XaR3qddEz
N3R9+P39SZ/df3mYTL++OtDkpheuy6aO1tv35gvRkbqbey5sIkeFzj+6B5tAyfPdE8LkVkWU
wBW4rujHeAMCkX7UuUXeCTL7HEx+Tr49BP/ef7uf3U0+X3erA+aTaaq9lCbzlrZVRVRR6B/A
tOKeMwREaXIddq2KAvVNoAMCBnDiA8S7m/dmb3a+zMLIdwZn3rDuBzxiTHv5CtAXEJQpwDmG
CsZcAFW4jDHcchdDmbQznx9kggcyfOjiTbO2MamX6nJt+xpAu8Ui1RnHFXA28atLux3Vnpht
qxQ9x4jVTd0GvTyLGChYAObaR6R0mk786RZ9RYyv6L1UxOj+GFW51A2uriapLHCv4wKMCRgM
T3HWUE2E/hr6oFUSqkM30dUmIxQn+k5W2zhNjQ9VFhf4VxaEtvBvFatH2BB588vSzSn6PvRJ
pxWjzLcdPrC59RiG1Lda4RCObGnb85gPuOuFUTSKhr4cyjAcuHIhvXBhbdD10DzTo+KFStj+
AAnX6JoUSrSUMmMIDqUA1ANxOhca/rodYO0LMksF70XtACeLchpp87gdB6yfR5lN2cAMH5/p
ydHRc8eFVEHFtF3K+XDEOOWLp+2uTKhv7mSWktvpP3eiXYeV7kec7JnMoTxcCrUEFBCsttoc
WNpTIc7ljHz6/v0huP96+2Ui/tqiKmOgwM0pfMbIdDL78d9DMAXOhAV7uElrC9fK4ntLaZ1a
uMuOwCOgGgWzyfTnZCqSPCexLNNdARhWr4RSbQwwMW1M66MR0gTJFagocwLUSB3Yh8giCYV+
hGrlUyDTrdxVQRczrQy12mrCQwAnEL0LaapQc93UgjMMUZEDDcpJtV7UiHkNGKOqjJM8S4LO
NSdUIVmvi6p9xNBDARyVKKlWwsZrt1lR9wWs09b2R/OqkJHNoxSA25ggrNySpBBj+Nk/W+Nx
tAyLa0Io3gMvI2ItKpARS27pd7pfndCMgH0M2FNlBQGLopXMMQyVGaAmwLuAD0aoflHH3Egi
VWjgXbfFNhJ1WIzHtsOYR8c2UFGe93UZASLkITRd09YbT3sfZ5dviFBM+j6XYIn2IRt6NjYJ
CkxahVVCizDBfvEZuFGh9tVVetGPEOeRHQzQSBYwZaBpQ9Ml2BxZHCVSYE1DJmuRg0q0iY0Q
4DpW9fquVZ/LyJg3le7TZIbqVJFR3wJJbqRNLk7ww0/ywy/DDz/ghx/nxz7Jj30ZfuwDfuzj
/Dgn+XEuw49zwI9znB/3JD/uZfhxD/iB4weqpAqUoeRptcyslcJbKH5zYlvjDquPD6rrr960
iGSMKRSfkTsdPYRoXrvEinkD6vbV/4EoSamjKQEA

--=_576c7510.zgj2Zxs266gQ+rvSsgnlrgnW2s7z0Q4/wE6R0I7zQHBVWTR8
Content-Type: application/gzip
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="dmesg-vm-kbuild-1G-1:20160624010922:x86_64-randconfig-s0-06231721:4.7.0-rc4-00214-ge426f7b:1.gz"

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
zGHtEnvlDVrbV/8AyCT1vh0kAQA=

--=_576c7510.zgj2Zxs266gQ+rvSsgnlrgnW2s7z0Q4/wE6R0I7zQHBVWTR8
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="config-4.7.0-rc4-00215-gc3e3459"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 4.7.0-rc4 Kernel Configuration
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
CONFIG_X86_64_SMP=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi -fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r10 -fcall-saved-r11"
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_DEBUG_RODATA=y
CONFIG_PGTABLE_LEVELS=4
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
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
CONFIG_KERNEL_LZO=y
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
# CONFIG_SWAP is not set
# CONFIG_SYSVIPC is not set
# CONFIG_POSIX_MQUEUE is not set
# CONFIG_CROSS_MEMORY_ATTACH is not set
CONFIG_FHANDLE=y
CONFIG_USELIB=y
# CONFIG_AUDIT is not set
CONFIG_HAVE_ARCH_AUDITSYSCALL=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_DOMAIN_HIERARCHY=y
CONFIG_GENERIC_MSI_IRQ=y
CONFIG_GENERIC_MSI_IRQ_DOMAIN=y
CONFIG_IRQ_DOMAIN_DEBUG=y
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
CONFIG_NO_HZ_IDLE=y
# CONFIG_NO_HZ_FULL is not set
# CONFIG_NO_HZ is not set
CONFIG_HIGH_RES_TIMERS=y

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=y
# CONFIG_VIRT_CPU_ACCOUNTING_GEN is not set
# CONFIG_IRQ_TIME_ACCOUNTING is not set
# CONFIG_BSD_PROCESS_ACCT is not set
# CONFIG_TASKSTATS is not set

#
# RCU Subsystem
#
CONFIG_PREEMPT_RCU=y
CONFIG_RCU_EXPERT=y
CONFIG_SRCU=y
CONFIG_TASKS_RCU=y
CONFIG_RCU_STALL_COMMON=y
CONFIG_RCU_FANOUT=64
CONFIG_RCU_FANOUT_LEAF=16
CONFIG_RCU_FAST_NO_HZ=y
CONFIG_TREE_RCU_TRACE=y
CONFIG_RCU_BOOST=y
CONFIG_RCU_KTHREAD_PRIO=1
CONFIG_RCU_BOOST_DELAY=500
CONFIG_RCU_NOCB_CPU=y
# CONFIG_RCU_NOCB_CPU_NONE is not set
# CONFIG_RCU_NOCB_CPU_ZERO is not set
CONFIG_RCU_NOCB_CPU_ALL=y
# CONFIG_RCU_EXPEDITE_BOOT is not set
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
# CONFIG_IKCONFIG_PROC is not set
CONFIG_LOG_BUF_SHIFT=17
CONFIG_LOG_CPU_MAX_BUF_SHIFT=12
CONFIG_NMI_LOG_BUF_SHIFT=13
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH=y
CONFIG_ARCH_SUPPORTS_INT128=y
CONFIG_CGROUPS=y
CONFIG_PAGE_COUNTER=y
CONFIG_MEMCG=y
# CONFIG_BLK_CGROUP is not set
# CONFIG_CGROUP_SCHED is not set
CONFIG_CGROUP_PIDS=y
# CONFIG_CGROUP_FREEZER is not set
# CONFIG_CPUSETS is not set
CONFIG_CGROUP_DEVICE=y
# CONFIG_CGROUP_CPUACCT is not set
# CONFIG_CGROUP_PERF is not set
# CONFIG_CGROUP_DEBUG is not set
# CONFIG_CHECKPOINT_RESTORE is not set
CONFIG_NAMESPACES=y
# CONFIG_UTS_NS is not set
CONFIG_USER_NS=y
# CONFIG_PID_NS is not set
CONFIG_NET_NS=y
# CONFIG_SCHED_AUTOGROUP is not set
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
CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE=y
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BPF=y
# CONFIG_EXPERT is not set
CONFIG_MULTIUSER=y
CONFIG_SGETMASK_SYSCALL=y
CONFIG_SYSFS_SYSCALL=y
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_KALLSYMS_ABSOLUTE_PERCPU=y
CONFIG_KALLSYMS_BASE_RELATIVE=y
CONFIG_PRINTK=y
CONFIG_PRINTK_NMI=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_BPF_SYSCALL=y
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_ADVISE_SYSCALLS=y
CONFIG_USERFAULTFD=y
CONFIG_PCI_QUIRKS=y
CONFIG_MEMBARRIER=y
# CONFIG_EMBEDDED is not set
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_SLUB_DEBUG=y
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLAB_FREELIST_RANDOM is not set
# CONFIG_SLUB_CPU_PARTIAL is not set
# CONFIG_SYSTEM_DATA_VERIFICATION is not set
# CONFIG_PROFILING is not set
CONFIG_KEXEC_CORE=y
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
CONFIG_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR_NONE is not set
CONFIG_CC_STACKPROTECTOR_REGULAR=y
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
# CONFIG_ISA_BUS_API is not set
# CONFIG_CPU_NO_EFFICIENT_FFS is not set

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
# CONFIG_MODULES is not set
CONFIG_MODULES_TREE_LOOKUP=y
CONFIG_BLOCK=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
CONFIG_BLK_DEV_INTEGRITY=y
# CONFIG_BLK_CMDLINE_PARSER is not set

#
# Partition Types
#
# CONFIG_PARTITION_ADVANCED is not set
CONFIG_AMIGA_PARTITION=y
CONFIG_MSDOS_PARTITION=y
CONFIG_EFI_PARTITION=y
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
CONFIG_PADATA=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_RWSEM_SPIN_ON_OWNER=y
CONFIG_LOCK_SPIN_ON_OWNER=y
CONFIG_ARCH_USE_QUEUED_SPINLOCKS=y
CONFIG_QUEUED_SPINLOCKS=y
CONFIG_ARCH_USE_QUEUED_RWLOCKS=y
CONFIG_QUEUED_RWLOCKS=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
CONFIG_SMP=y
CONFIG_X86_FEATURE_NAMES=y
CONFIG_X86_FAST_FEATURE_TESTS=y
# CONFIG_X86_X2APIC is not set
CONFIG_X86_MPPARSE=y
# CONFIG_GOLDFISH is not set
# CONFIG_X86_EXTENDED_PLATFORM is not set
# CONFIG_X86_INTEL_LPSS is not set
# CONFIG_X86_AMD_PLATFORM_DEVICE is not set
CONFIG_IOSF_MBI=y
# CONFIG_IOSF_MBI_DEBUG is not set
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
CONFIG_PARAVIRT_SPINLOCKS=y
# CONFIG_QUEUED_LOCK_STAT is not set
CONFIG_XEN=y
CONFIG_XEN_DOM0=y
CONFIG_XEN_PVHVM=y
# CONFIG_XEN_512GB is not set
CONFIG_XEN_SAVE_RESTORE=y
# CONFIG_XEN_DEBUG_FS is not set
# CONFIG_XEN_PVH is not set
CONFIG_KVM_GUEST=y
CONFIG_KVM_DEBUG_FS=y
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
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
CONFIG_DMI=y
CONFIG_GART_IOMMU=y
# CONFIG_CALGARY_IOMMU is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
# CONFIG_MAXSMP is not set
CONFIG_NR_CPUS=64
CONFIG_SCHED_SMT=y
# CONFIG_SCHED_MC is not set
# CONFIG_PREEMPT_NONE is not set
# CONFIG_PREEMPT_VOLUNTARY is not set
CONFIG_PREEMPT=y
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
# CONFIG_X86_MCE is not set

#
# Performance monitoring
#
# CONFIG_PERF_EVENTS_INTEL_UNCORE is not set
CONFIG_PERF_EVENTS_INTEL_RAPL=y
CONFIG_PERF_EVENTS_INTEL_CSTATE=y
# CONFIG_PERF_EVENTS_AMD_POWER is not set
# CONFIG_VM86 is not set
CONFIG_X86_16BIT=y
CONFIG_X86_ESPFIX64=y
CONFIG_X86_VSYSCALL_EMULATION=y
CONFIG_I8K=y
CONFIG_MICROCODE=y
# CONFIG_MICROCODE_INTEL is not set
# CONFIG_MICROCODE_AMD is not set
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_X86_MSR=y
CONFIG_X86_CPUID=y
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_X86_DIRECT_GBPAGES=y
# CONFIG_NUMA is not set
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_MEMORY_PROBE=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
# CONFIG_SPARSEMEM_VMEMMAP is not set
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
# CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
# CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE is not set
# CONFIG_MEMORY_HOTREMOVE is not set
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
# CONFIG_BOUNCE is not set
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
# CONFIG_KSM is not set
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_TRANSPARENT_HUGEPAGE=y
CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y
# CONFIG_TRANSPARENT_HUGEPAGE_MADVISE is not set
CONFIG_TRANSPARENT_HUGE_PAGECACHE=y
CONFIG_CLEANCACHE=y
# CONFIG_CMA is not set
# CONFIG_ZPOOL is not set
CONFIG_ZBUD=y
CONFIG_ZSMALLOC=y
CONFIG_PGTABLE_MAPPING=y
CONFIG_ZSMALLOC_STAT=y
CONFIG_GENERIC_EARLY_IOREMAP=y
CONFIG_ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT=y
# CONFIG_DEFERRED_STRUCT_PAGE_INIT is not set
CONFIG_IDLE_PAGE_TRACKING=y
CONFIG_FRAME_VECTOR=y
CONFIG_ARCH_USES_HIGH_VMA_FLAGS=y
CONFIG_ARCH_HAS_PKEYS=y
CONFIG_X86_PMEM_LEGACY_DEVICE=y
CONFIG_X86_PMEM_LEGACY=y
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
CONFIG_MTRR_SANITIZER=y
CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=0
CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_ARCH_RANDOM=y
CONFIG_X86_SMAP=y
CONFIG_X86_INTEL_MPX=y
CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS=y
CONFIG_EFI=y
# CONFIG_EFI_STUB is not set
# CONFIG_SECCOMP is not set
# CONFIG_HZ_100 is not set
CONFIG_HZ_250=y
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=250
CONFIG_SCHED_HRTICK=y
# CONFIG_KEXEC is not set
CONFIG_KEXEC_FILE=y
# CONFIG_KEXEC_VERIFY_SIG is not set
CONFIG_CRASH_DUMP=y
CONFIG_PHYSICAL_START=0x1000000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_HOTPLUG_CPU=y
CONFIG_BOOTPARAM_HOTPLUG_CPU0=y
CONFIG_DEBUG_HOTPLUG_CPU0=y
# CONFIG_LEGACY_VSYSCALL_NATIVE is not set
CONFIG_LEGACY_VSYSCALL_EMULATE=y
# CONFIG_LEGACY_VSYSCALL_NONE is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_MODIFY_LDT_SYSCALL=y
CONFIG_HAVE_LIVEPATCH=y
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_HIBERNATE_CALLBACKS=y
CONFIG_PM_SLEEP=y
CONFIG_PM_SLEEP_SMP=y
# CONFIG_PM_AUTOSLEEP is not set
# CONFIG_PM_WAKELOCKS is not set
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
CONFIG_PM_CLK=y
CONFIG_WQ_POWER_EFFICIENT_DEFAULT=y
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=y
# CONFIG_ACPI_DEBUGGER is not set
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS_POWER is not set
CONFIG_ACPI_REV_OVERRIDE_POSSIBLE=y
CONFIG_ACPI_EC_DEBUGFS=y
# CONFIG_ACPI_AC is not set
# CONFIG_ACPI_BATTERY is not set
# CONFIG_ACPI_BUTTON is not set
# CONFIG_ACPI_VIDEO is not set
CONFIG_ACPI_FAN=y
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_CPU_FREQ_PSS=y
CONFIG_ACPI_PROCESSOR_IDLE=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_IPMI=y
CONFIG_ACPI_HOTPLUG_CPU=y
CONFIG_ACPI_PROCESSOR_AGGREGATOR=y
CONFIG_ACPI_THERMAL=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ACPI_TABLE_UPGRADE=y
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
# CONFIG_ACPI_HOTPLUG_MEMORY is not set
CONFIG_ACPI_HOTPLUG_IOAPIC=y
CONFIG_ACPI_SBS=y
CONFIG_ACPI_HED=y
CONFIG_ACPI_CUSTOM_METHOD=y
CONFIG_ACPI_BGRT=y
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
CONFIG_ACPI_NFIT=y
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
CONFIG_ACPI_APEI=y
CONFIG_ACPI_APEI_GHES=y
# CONFIG_ACPI_APEI_PCIEAER is not set
CONFIG_ACPI_APEI_EINJ=y
CONFIG_ACPI_APEI_ERST_DEBUG=y
# CONFIG_PMIC_OPREGION is not set
# CONFIG_SFI is not set

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_GOV_ATTR_SET=y
CONFIG_CPU_FREQ_GOV_COMMON=y
# CONFIG_CPU_FREQ_STAT is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_SCHEDUTIL is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=y
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y
# CONFIG_CPU_FREQ_GOV_SCHEDUTIL is not set

#
# CPU frequency scaling drivers
#
# CONFIG_CPUFREQ_DT is not set
# CONFIG_X86_INTEL_PSTATE is not set
# CONFIG_X86_PCC_CPUFREQ is not set
CONFIG_X86_ACPI_CPUFREQ=y
CONFIG_X86_ACPI_CPUFREQ_CPB=y
CONFIG_X86_POWERNOW_K8=y
# CONFIG_X86_AMD_FREQ_SENSITIVITY is not set
CONFIG_X86_SPEEDSTEP_CENTRINO=y
CONFIG_X86_P4_CLOCKMOD=y

#
# shared options
#
CONFIG_X86_SPEEDSTEP_LIB=y

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
CONFIG_I7300_IDLE_IOAT_CHANNEL=y
CONFIG_I7300_IDLE=y

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_XEN=y
CONFIG_PCI_DOMAINS=y
CONFIG_PCIEPORTBUS=y
CONFIG_PCIEAER=y
# CONFIG_PCIE_ECRC is not set
CONFIG_PCIEAER_INJECT=y
CONFIG_PCIEASPM=y
CONFIG_PCIEASPM_DEBUG=y
# CONFIG_PCIEASPM_DEFAULT is not set
CONFIG_PCIEASPM_POWERSAVE=y
# CONFIG_PCIEASPM_PERFORMANCE is not set
CONFIG_PCIE_PME=y
# CONFIG_PCIE_DPC is not set
CONFIG_PCI_BUS_ADDR_T_64BIT=y
CONFIG_PCI_MSI=y
CONFIG_PCI_MSI_IRQ_DOMAIN=y
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
# CONFIG_PCI_STUB is not set
CONFIG_XEN_PCIDEV_FRONTEND=y
CONFIG_HT_IRQ=y
CONFIG_PCI_ATS=y
CONFIG_PCI_IOV=y
# CONFIG_PCI_PRI is not set
CONFIG_PCI_PASID=y
CONFIG_PCI_LABEL=y
CONFIG_PCI_HYPERV=y
# CONFIG_HOTPLUG_PCI is not set

#
# PCI host controller drivers
#
# CONFIG_PCIE_DW_PLAT is not set
CONFIG_ISA_DMA_API=y
CONFIG_AMD_NB=y
# CONFIG_PCCARD is not set
CONFIG_RAPIDIO=y
CONFIG_RAPIDIO_TSI721=y
CONFIG_RAPIDIO_DISC_TIMEOUT=30
# CONFIG_RAPIDIO_ENABLE_RX_TX_PORTS is not set
# CONFIG_RAPIDIO_DMA_ENGINE is not set
# CONFIG_RAPIDIO_DEBUG is not set
CONFIG_RAPIDIO_ENUM_BASIC=y
CONFIG_RAPIDIO_MPORT_CDEV=y

#
# RapidIO Switch drivers
#
CONFIG_RAPIDIO_TSI57X=y
CONFIG_RAPIDIO_CPS_XX=y
# CONFIG_RAPIDIO_TSI568 is not set
CONFIG_RAPIDIO_CPS_GEN2=y
# CONFIG_X86_SYSFB is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ELFCORE=y
CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS=y
CONFIG_BINFMT_SCRIPT=y
# CONFIG_HAVE_AOUT is not set
CONFIG_BINFMT_MISC=y
CONFIG_COREDUMP=y
# CONFIG_IA32_EMULATION is not set
CONFIG_X86_X32=y
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_PMC_ATOM=y
CONFIG_VMD=y
CONFIG_NET=y
CONFIG_COMPAT_NETLINK_MESSAGES=y

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
# CONFIG_BATMAN_ADV is not set
# CONFIG_VSOCKETS is not set
# CONFIG_NETLINK_DIAG is not set
# CONFIG_MPLS is not set
# CONFIG_HSR is not set
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
# CONFIG_SOCK_CGROUP_DATA is not set
# CONFIG_CGROUP_NET_PRIO is not set
# CONFIG_CGROUP_NET_CLASSID is not set
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
CONFIG_NET_FLOW_LIMIT=y

#
# Network testing
#
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_IRDA is not set
# CONFIG_BT is not set
CONFIG_WIRELESS=y
CONFIG_WEXT_CORE=y
CONFIG_WEXT_PROC=y
CONFIG_CFG80211=y
# CONFIG_NL80211_TESTMODE is not set
# CONFIG_CFG80211_DEVELOPER_WARNINGS is not set
CONFIG_CFG80211_DEFAULT_PS=y
# CONFIG_CFG80211_DEBUGFS is not set
# CONFIG_CFG80211_INTERNAL_REGDB is not set
CONFIG_CFG80211_CRDA_SUPPORT=y
CONFIG_CFG80211_WEXT=y
# CONFIG_LIB80211 is not set
CONFIG_MAC80211=y
CONFIG_MAC80211_HAS_RC=y
CONFIG_MAC80211_RC_MINSTREL=y
CONFIG_MAC80211_RC_MINSTREL_HT=y
# CONFIG_MAC80211_RC_MINSTREL_VHT is not set
CONFIG_MAC80211_RC_DEFAULT_MINSTREL=y
CONFIG_MAC80211_RC_DEFAULT="minstrel_ht"
CONFIG_MAC80211_MESH=y
CONFIG_MAC80211_LEDS=y
# CONFIG_MAC80211_DEBUGFS is not set
# CONFIG_MAC80211_MESSAGE_TRACING is not set
# CONFIG_MAC80211_DEBUG_MENU is not set
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
CONFIG_DEVTMPFS_MOUNT=y
CONFIG_STANDALONE=y
# CONFIG_PREVENT_FIRMWARE_BUILD is not set
CONFIG_FW_LOADER=y
# CONFIG_FIRMWARE_IN_KERNEL is not set
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
CONFIG_FW_LOADER_USER_HELPER_FALLBACK=y
CONFIG_ALLOW_DEV_COREDUMP=y
# CONFIG_DEBUG_DRIVER is not set
CONFIG_DEBUG_DEVRES=y
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SPI=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y
CONFIG_FENCE_TRACE=y

#
# Bus devices
#
# CONFIG_CONNECTOR is not set
CONFIG_MTD=y
CONFIG_MTD_REDBOOT_PARTS=y
CONFIG_MTD_REDBOOT_DIRECTORY_BLOCK=-1
# CONFIG_MTD_REDBOOT_PARTS_UNALLOCATED is not set
CONFIG_MTD_REDBOOT_PARTS_READONLY=y
CONFIG_MTD_CMDLINE_PARTS=y
# CONFIG_MTD_OF_PARTS is not set
CONFIG_MTD_AR7_PARTS=y

#
# User Modules And Translation Layers
#
CONFIG_MTD_BLKDEVS=y
CONFIG_MTD_BLOCK=y
CONFIG_FTL=y
CONFIG_NFTL=y
CONFIG_NFTL_RW=y
CONFIG_INFTL=y
CONFIG_RFD_FTL=y
CONFIG_SSFDC=y
CONFIG_SM_FTL=y
# CONFIG_MTD_OOPS is not set
CONFIG_MTD_PARTITIONED_MASTER=y

#
# RAM/ROM/Flash chip drivers
#
CONFIG_MTD_CFI=y
CONFIG_MTD_JEDECPROBE=y
CONFIG_MTD_GEN_PROBE=y
# CONFIG_MTD_CFI_ADV_OPTIONS is not set
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
CONFIG_MTD_CFI_INTELEXT=y
# CONFIG_MTD_CFI_AMDSTD is not set
CONFIG_MTD_CFI_STAA=y
CONFIG_MTD_CFI_UTIL=y
CONFIG_MTD_RAM=y
CONFIG_MTD_ROM=y
# CONFIG_MTD_ABSENT is not set

#
# Mapping drivers for chip access
#
# CONFIG_MTD_COMPLEX_MAPPINGS is not set
CONFIG_MTD_PHYSMAP=y
CONFIG_MTD_PHYSMAP_COMPAT=y
CONFIG_MTD_PHYSMAP_START=0x8000000
CONFIG_MTD_PHYSMAP_LEN=0
CONFIG_MTD_PHYSMAP_BANKWIDTH=2
CONFIG_MTD_PHYSMAP_OF=y
CONFIG_MTD_PHYSMAP_OF_VERSATILE=y
CONFIG_MTD_AMD76XROM=y
# CONFIG_MTD_ICHXROM is not set
CONFIG_MTD_ESB2ROM=y
# CONFIG_MTD_CK804XROM is not set
CONFIG_MTD_SCB2_FLASH=y
# CONFIG_MTD_NETtel is not set
CONFIG_MTD_L440GX=y
# CONFIG_MTD_INTEL_VR_NOR is not set
CONFIG_MTD_PLATRAM=y

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_PMC551 is not set
# CONFIG_MTD_DATAFLASH is not set
# CONFIG_MTD_M25P80 is not set
# CONFIG_MTD_SST25L is not set
# CONFIG_MTD_SLRAM is not set
CONFIG_MTD_PHRAM=y
CONFIG_MTD_MTDRAM=y
CONFIG_MTDRAM_TOTAL_SIZE=4096
CONFIG_MTDRAM_ERASE_SIZE=128
CONFIG_MTDRAM_ABS_POS=0
CONFIG_MTD_BLOCK2MTD=y

#
# Disk-On-Chip Device Drivers
#
# CONFIG_MTD_DOCG3 is not set
CONFIG_MTD_NAND_ECC=y
# CONFIG_MTD_NAND_ECC_SMC is not set
CONFIG_MTD_NAND=y
# CONFIG_MTD_NAND_ECC_BCH is not set
CONFIG_MTD_SM_COMMON=y
# CONFIG_MTD_NAND_DENALI_PCI is not set
# CONFIG_MTD_NAND_DENALI_DT is not set
# CONFIG_MTD_NAND_OMAP_BCH_BUILD is not set
CONFIG_MTD_NAND_IDS=y
CONFIG_MTD_NAND_RICOH=y
# CONFIG_MTD_NAND_DISKONCHIP is not set
CONFIG_MTD_NAND_DOCG4=y
# CONFIG_MTD_NAND_CAFE is not set
# CONFIG_MTD_NAND_NANDSIM is not set
CONFIG_MTD_NAND_PLATFORM=y
# CONFIG_MTD_NAND_HISI504 is not set
CONFIG_MTD_ONENAND=y
# CONFIG_MTD_ONENAND_VERIFY_WRITE is not set
CONFIG_MTD_ONENAND_GENERIC=y
CONFIG_MTD_ONENAND_OTP=y
# CONFIG_MTD_ONENAND_2X_PROGRAM is not set

#
# LPDDR & LPDDR2 PCM memory drivers
#
# CONFIG_MTD_LPDDR is not set
CONFIG_MTD_SPI_NOR=y
# CONFIG_MTD_MT81xx_NOR is not set
CONFIG_MTD_SPI_NOR_USE_4K_SECTORS=y
# CONFIG_MTD_UBI is not set
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
CONFIG_OF_MTD=y
CONFIG_OF_RESOLVE=y
# CONFIG_OF_OVERLAY is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT=y
CONFIG_PARPORT_PC=y
CONFIG_PARPORT_SERIAL=y
CONFIG_PARPORT_PC_FIFO=y
# CONFIG_PARPORT_PC_SUPERIO is not set
# CONFIG_PARPORT_GSC is not set
# CONFIG_PARPORT_AX88796 is not set
# CONFIG_PARPORT_1284 is not set
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
# CONFIG_BLK_DEV_NULL_BLK is not set
CONFIG_BLK_DEV_FD=y
# CONFIG_PARIDE is not set
CONFIG_BLK_DEV_PCIESSD_MTIP32XX=y
# CONFIG_ZRAM is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
CONFIG_BLK_DEV_DAC960=y
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=y
CONFIG_BLK_DEV_LOOP_MIN_COUNT=8
CONFIG_BLK_DEV_CRYPTOLOOP=y

#
# DRBD disabled because PROC_FS or INET not selected
#
# CONFIG_BLK_DEV_NBD is not set
CONFIG_BLK_DEV_SKD=y
CONFIG_BLK_DEV_SX8=y
# CONFIG_BLK_DEV_RAM is not set
CONFIG_CDROM_PKTCDVD=y
CONFIG_CDROM_PKTCDVD_BUFFERS=8
CONFIG_CDROM_PKTCDVD_WCACHE=y
# CONFIG_ATA_OVER_ETH is not set
CONFIG_XEN_BLKDEV_FRONTEND=y
# CONFIG_XEN_BLKDEV_BACKEND is not set
CONFIG_VIRTIO_BLK=y
# CONFIG_BLK_DEV_HD is not set
CONFIG_BLK_DEV_RSXX=y
# CONFIG_BLK_DEV_NVME is not set

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=y
CONFIG_AD525X_DPOT=y
CONFIG_AD525X_DPOT_I2C=y
CONFIG_AD525X_DPOT_SPI=y
# CONFIG_DUMMY_IRQ is not set
CONFIG_IBM_ASM=y
CONFIG_PHANTOM=y
CONFIG_SGI_IOC4=y
CONFIG_TIFM_CORE=y
# CONFIG_TIFM_7XX1 is not set
# CONFIG_ICS932S401 is not set
CONFIG_ENCLOSURE_SERVICES=y
CONFIG_HP_ILO=y
# CONFIG_APDS9802ALS is not set
CONFIG_ISL29003=y
# CONFIG_ISL29020 is not set
# CONFIG_SENSORS_TSL2550 is not set
# CONFIG_SENSORS_BH1780 is not set
# CONFIG_SENSORS_BH1770 is not set
CONFIG_SENSORS_APDS990X=y
CONFIG_HMC6352=y
# CONFIG_DS1682 is not set
CONFIG_TI_DAC7512=y
# CONFIG_VMWARE_BALLOON is not set
CONFIG_BMP085=y
# CONFIG_BMP085_I2C is not set
CONFIG_BMP085_SPI=y
# CONFIG_USB_SWITCH_FSA9480 is not set
CONFIG_LATTICE_ECP3_CONFIG=y
CONFIG_SRAM=y
CONFIG_PANEL=y
CONFIG_PANEL_PARPORT=0
CONFIG_PANEL_PROFILE=5
# CONFIG_PANEL_CHANGE_MESSAGE is not set
# CONFIG_C2PORT is not set

#
# EEPROM support
#
# CONFIG_EEPROM_AT24 is not set
CONFIG_EEPROM_AT25=y
# CONFIG_EEPROM_LEGACY is not set
# CONFIG_EEPROM_MAX6875 is not set
CONFIG_EEPROM_93CX6=y
# CONFIG_EEPROM_93XX46 is not set
CONFIG_CB710_CORE=y
CONFIG_CB710_DEBUG=y
CONFIG_CB710_DEBUG_ASSUMPTIONS=y

#
# Texas Instruments shared transport line discipline
#
CONFIG_SENSORS_LIS3_I2C=y

#
# Altera FPGA firmware download module
#
# CONFIG_ALTERA_STAPL is not set
# CONFIG_INTEL_MEI is not set
# CONFIG_INTEL_MEI_ME is not set
# CONFIG_INTEL_MEI_TXE is not set
CONFIG_VMWARE_VMCI=y

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
CONFIG_VOP_BUS=y

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
CONFIG_VOP=y
# CONFIG_GENWQE is not set
CONFIG_ECHO=y
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
CONFIG_IDE_GD_ATA=y
CONFIG_IDE_GD_ATAPI=y
CONFIG_BLK_DEV_IDECD=y
CONFIG_BLK_DEV_IDECD_VERBOSE_ERRORS=y
CONFIG_BLK_DEV_IDETAPE=y
CONFIG_BLK_DEV_IDEACPI=y
# CONFIG_IDE_TASK_IOCTL is not set
CONFIG_IDE_PROC_FS=y

#
# IDE chipset support/bugfixes
#
# CONFIG_IDE_GENERIC is not set
CONFIG_BLK_DEV_PLATFORM=y
CONFIG_BLK_DEV_CMD640=y
# CONFIG_BLK_DEV_CMD640_ENHANCED is not set
# CONFIG_BLK_DEV_IDEPNP is not set
CONFIG_BLK_DEV_IDEDMA_SFF=y

#
# PCI IDE chipsets support
#
CONFIG_BLK_DEV_IDEPCI=y
# CONFIG_IDEPCI_PCIBUS_ORDER is not set
# CONFIG_BLK_DEV_OFFBOARD is not set
# CONFIG_BLK_DEV_GENERIC is not set
# CONFIG_BLK_DEV_OPTI621 is not set
CONFIG_BLK_DEV_RZ1000=y
CONFIG_BLK_DEV_IDEDMA_PCI=y
CONFIG_BLK_DEV_AEC62XX=y
CONFIG_BLK_DEV_ALI15X3=y
CONFIG_BLK_DEV_AMD74XX=y
# CONFIG_BLK_DEV_ATIIXP is not set
CONFIG_BLK_DEV_CMD64X=y
# CONFIG_BLK_DEV_TRIFLEX is not set
CONFIG_BLK_DEV_HPT366=y
CONFIG_BLK_DEV_JMICRON=y
# CONFIG_BLK_DEV_PIIX is not set
CONFIG_BLK_DEV_IT8172=y
CONFIG_BLK_DEV_IT8213=y
# CONFIG_BLK_DEV_IT821X is not set
CONFIG_BLK_DEV_NS87415=y
# CONFIG_BLK_DEV_PDC202XX_OLD is not set
CONFIG_BLK_DEV_PDC202XX_NEW=y
CONFIG_BLK_DEV_SVWKS=y
CONFIG_BLK_DEV_SIIMAGE=y
# CONFIG_BLK_DEV_SIS5513 is not set
CONFIG_BLK_DEV_SLC90E66=y
CONFIG_BLK_DEV_TRM290=y
CONFIG_BLK_DEV_VIA82CXXX=y
CONFIG_BLK_DEV_TC86C001=y
CONFIG_BLK_DEV_IDEDMA=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=y
# CONFIG_SCSI is not set
# CONFIG_SCSI_DMA is not set
# CONFIG_SCSI_NETLINK is not set
# CONFIG_ATA is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
CONFIG_MD_AUTODETECT=y
CONFIG_MD_LINEAR=y
CONFIG_MD_RAID0=y
CONFIG_MD_RAID1=y
CONFIG_MD_RAID10=y
# CONFIG_MD_RAID456 is not set
# CONFIG_MD_MULTIPATH is not set
CONFIG_MD_FAULTY=y
CONFIG_BCACHE=y
# CONFIG_BCACHE_DEBUG is not set
# CONFIG_BCACHE_CLOSURES_DEBUG is not set
# CONFIG_BLK_DEV_DM is not set
CONFIG_FUSION=y
CONFIG_FUSION_MAX_SGE=128
# CONFIG_FUSION_LOGGING is not set

#
# IEEE 1394 (FireWire) support
#
CONFIG_FIREWIRE=y
# CONFIG_FIREWIRE_OHCI is not set
CONFIG_FIREWIRE_NOSY=y
CONFIG_MACINTOSH_DRIVERS=y
# CONFIG_MAC_EMUMOUSEBTN is not set
# CONFIG_NETDEVICES is not set
CONFIG_VHOST_RING=y
CONFIG_NVM=y
# CONFIG_NVM_DEBUG is not set
CONFIG_NVM_GENNVM=y
CONFIG_NVM_RRPC=y

#
# Input device support
#
CONFIG_INPUT=y
# CONFIG_INPUT_LEDS is not set
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
CONFIG_INPUT_SPARSEKMAP=y
CONFIG_INPUT_MATRIXKMAP=y

#
# Userland interfaces
#
# CONFIG_INPUT_MOUSEDEV is not set
CONFIG_INPUT_JOYDEV=y
# CONFIG_INPUT_EVDEV is not set
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADP5520 is not set
CONFIG_KEYBOARD_ADP5588=y
CONFIG_KEYBOARD_ADP5589=y
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
CONFIG_KEYBOARD_QT2160=y
CONFIG_KEYBOARD_LKKBD=y
CONFIG_KEYBOARD_TCA6416=y
CONFIG_KEYBOARD_TCA8418=y
CONFIG_KEYBOARD_LM8323=y
# CONFIG_KEYBOARD_LM8333 is not set
CONFIG_KEYBOARD_MAX7359=y
# CONFIG_KEYBOARD_MCS is not set
CONFIG_KEYBOARD_MPR121=y
# CONFIG_KEYBOARD_NEWTON is not set
CONFIG_KEYBOARD_OPENCORES=y
CONFIG_KEYBOARD_SAMSUNG=y
# CONFIG_KEYBOARD_STOWAWAY is not set
CONFIG_KEYBOARD_SUNKBD=y
# CONFIG_KEYBOARD_OMAP4 is not set
CONFIG_KEYBOARD_XTKBD=y
CONFIG_KEYBOARD_CROS_EC=y
CONFIG_KEYBOARD_CAP11XX=y
CONFIG_KEYBOARD_BCM=y
CONFIG_INPUT_MOUSE=y
# CONFIG_MOUSE_PS2 is not set
CONFIG_MOUSE_SERIAL=y
CONFIG_MOUSE_APPLETOUCH=y
CONFIG_MOUSE_BCM5974=y
CONFIG_MOUSE_CYAPA=y
CONFIG_MOUSE_ELAN_I2C=y
# CONFIG_MOUSE_ELAN_I2C_I2C is not set
# CONFIG_MOUSE_ELAN_I2C_SMBUS is not set
CONFIG_MOUSE_VSXXXAA=y
CONFIG_MOUSE_SYNAPTICS_I2C=y
CONFIG_MOUSE_SYNAPTICS_USB=y
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
CONFIG_INPUT_MISC=y
# CONFIG_INPUT_88PM860X_ONKEY is not set
CONFIG_INPUT_88PM80X_ONKEY=y
# CONFIG_INPUT_AD714X is not set
# CONFIG_INPUT_BMA150 is not set
CONFIG_INPUT_E3X0_BUTTON=y
CONFIG_INPUT_PCSPKR=y
CONFIG_INPUT_MAX8925_ONKEY=y
CONFIG_INPUT_MC13783_PWRBUTTON=y
CONFIG_INPUT_MMA8450=y
CONFIG_INPUT_MPU3050=y
# CONFIG_INPUT_APANEL is not set
CONFIG_INPUT_ATLAS_BTNS=y
# CONFIG_INPUT_ATI_REMOTE2 is not set
# CONFIG_INPUT_KEYSPAN_REMOTE is not set
CONFIG_INPUT_KXTJ9=y
# CONFIG_INPUT_KXTJ9_POLLED_MODE is not set
# CONFIG_INPUT_POWERMATE is not set
# CONFIG_INPUT_YEALINK is not set
CONFIG_INPUT_CM109=y
CONFIG_INPUT_REGULATOR_HAPTIC=y
CONFIG_INPUT_RETU_PWRBUTTON=y
CONFIG_INPUT_TPS65218_PWRBUTTON=y
CONFIG_INPUT_TWL6040_VIBRA=y
CONFIG_INPUT_UINPUT=y
CONFIG_INPUT_PALMAS_PWRBUTTON=y
CONFIG_INPUT_PCF50633_PMU=y
# CONFIG_INPUT_PCF8574 is not set
CONFIG_INPUT_PWM_BEEPER=y
CONFIG_INPUT_DA9052_ONKEY=y
# CONFIG_INPUT_DA9063_ONKEY is not set
# CONFIG_INPUT_ADXL34X is not set
# CONFIG_INPUT_IMS_PCU is not set
# CONFIG_INPUT_CMA3000 is not set
CONFIG_INPUT_XEN_KBDDEV_FRONTEND=y
# CONFIG_INPUT_IDEAPAD_SLIDEBAR is not set
# CONFIG_INPUT_DRV2665_HAPTICS is not set
# CONFIG_INPUT_DRV2667_HAPTICS is not set
# CONFIG_RMI4_CORE is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
# CONFIG_SERIO_SERPORT is not set
CONFIG_SERIO_CT82C710=y
CONFIG_SERIO_PARKBD=y
CONFIG_SERIO_PCIPS2=y
CONFIG_SERIO_LIBPS2=y
# CONFIG_SERIO_RAW is not set
CONFIG_SERIO_ALTERA_PS2=y
CONFIG_SERIO_PS2MULT=y
# CONFIG_SERIO_ARC_PS2 is not set
CONFIG_SERIO_APBPS2=y
CONFIG_HYPERV_KEYBOARD=y
# CONFIG_USERIO is not set
CONFIG_GAMEPORT=y
CONFIG_GAMEPORT_NS558=y
CONFIG_GAMEPORT_L4=y
# CONFIG_GAMEPORT_EMU10K1 is not set
CONFIG_GAMEPORT_FM801=y

#
# Character devices
#
CONFIG_TTY=y
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_VT_CONSOLE_SLEEP=y
CONFIG_HW_CONSOLE=y
CONFIG_VT_HW_CONSOLE_BINDING=y
CONFIG_UNIX98_PTYS=y
# CONFIG_LEGACY_PTYS is not set
# CONFIG_SERIAL_NONSTANDARD is not set
# CONFIG_NOZOMI is not set
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
# CONFIG_SERIAL_8250_DEPRECATED_OPTIONS is not set
CONFIG_SERIAL_8250_PNP=y
# CONFIG_SERIAL_8250_FINTEK is not set
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
# CONFIG_SERIAL_8250_MANY_PORTS is not set
CONFIG_SERIAL_8250_SHARE_IRQ=y
CONFIG_SERIAL_8250_DETECT_IRQ=y
# CONFIG_SERIAL_8250_RSA is not set
# CONFIG_SERIAL_8250_FSL is not set
CONFIG_SERIAL_8250_DW=y
CONFIG_SERIAL_8250_RT288X=y
CONFIG_SERIAL_8250_MID=y
CONFIG_SERIAL_8250_MOXA=y
# CONFIG_SERIAL_OF_PLATFORM is not set

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MAX3100 is not set
CONFIG_SERIAL_MAX310X=y
CONFIG_SERIAL_UARTLITE=y
# CONFIG_SERIAL_UARTLITE_CONSOLE is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
CONFIG_SERIAL_JSM=y
CONFIG_SERIAL_SCCNXP=y
# CONFIG_SERIAL_SCCNXP_CONSOLE is not set
# CONFIG_SERIAL_SC16IS7XX is not set
CONFIG_SERIAL_ALTERA_JTAGUART=y
# CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE is not set
# CONFIG_SERIAL_ALTERA_UART is not set
CONFIG_SERIAL_XILINX_PS_UART=y
CONFIG_SERIAL_XILINX_PS_UART_CONSOLE=y
CONFIG_SERIAL_ARC=y
CONFIG_SERIAL_ARC_CONSOLE=y
CONFIG_SERIAL_ARC_NR_PORTS=1
CONFIG_SERIAL_RP2=y
CONFIG_SERIAL_RP2_NR_UARTS=32
CONFIG_SERIAL_FSL_LPUART=y
# CONFIG_SERIAL_FSL_LPUART_CONSOLE is not set
CONFIG_SERIAL_CONEXANT_DIGICOLOR=y
CONFIG_SERIAL_CONEXANT_DIGICOLOR_CONSOLE=y
CONFIG_PRINTER=y
CONFIG_LP_CONSOLE=y
CONFIG_PPDEV=y
CONFIG_HVC_DRIVER=y
CONFIG_HVC_IRQ=y
CONFIG_HVC_XEN=y
# CONFIG_HVC_XEN_FRONTEND is not set
CONFIG_VIRTIO_CONSOLE=y
CONFIG_IPMI_HANDLER=y
CONFIG_IPMI_PANIC_EVENT=y
# CONFIG_IPMI_PANIC_STRING is not set
CONFIG_IPMI_DEVICE_INTERFACE=y
CONFIG_IPMI_SI=y
# CONFIG_IPMI_SI_PROBE_DEFAULTS is not set
# CONFIG_IPMI_SSIF is not set
# CONFIG_IPMI_WATCHDOG is not set
# CONFIG_IPMI_POWEROFF is not set
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_TIMERIOMEM=y
# CONFIG_HW_RANDOM_INTEL is not set
CONFIG_HW_RANDOM_AMD=y
CONFIG_HW_RANDOM_VIA=y
# CONFIG_HW_RANDOM_VIRTIO is not set
# CONFIG_HW_RANDOM_TPM is not set
CONFIG_NVRAM=y
CONFIG_R3964=y
CONFIG_APPLICOM=y
CONFIG_MWAVE=y
CONFIG_RAW_DRIVER=y
CONFIG_MAX_RAW_DEVS=256
CONFIG_HPET=y
CONFIG_HPET_MMAP=y
CONFIG_HPET_MMAP_DEFAULT=y
# CONFIG_HANGCHECK_TIMER is not set
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS=y
CONFIG_TCG_TIS_I2C_ATMEL=y
# CONFIG_TCG_TIS_I2C_INFINEON is not set
CONFIG_TCG_TIS_I2C_NUVOTON=y
# CONFIG_TCG_NSC is not set
CONFIG_TCG_ATMEL=y
CONFIG_TCG_INFINEON=y
CONFIG_TCG_XEN=y
CONFIG_TCG_CRB=y
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y
CONFIG_XILLYBUS=y
CONFIG_XILLYBUS_PCIE=y
CONFIG_XILLYBUS_OF=y

#
# I2C support
#
CONFIG_I2C=y
CONFIG_ACPI_I2C_OPREGION=y
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_COMPAT is not set
CONFIG_I2C_CHARDEV=y
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
CONFIG_I2C_MUX_PCA9541=y
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
CONFIG_I2C_ALI1535=y
CONFIG_I2C_ALI1563=y
CONFIG_I2C_ALI15X3=y
CONFIG_I2C_AMD756=y
CONFIG_I2C_AMD756_S4882=y
CONFIG_I2C_AMD8111=y
CONFIG_I2C_I801=y
CONFIG_I2C_ISCH=y
CONFIG_I2C_ISMT=y
CONFIG_I2C_PIIX4=y
# CONFIG_I2C_NFORCE2 is not set
CONFIG_I2C_SIS5595=y
# CONFIG_I2C_SIS630 is not set
CONFIG_I2C_SIS96X=y
# CONFIG_I2C_VIA is not set
CONFIG_I2C_VIAPRO=y

#
# ACPI drivers
#
CONFIG_I2C_SCMI=y

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
CONFIG_I2C_DESIGNWARE_CORE=y
CONFIG_I2C_DESIGNWARE_PLATFORM=y
CONFIG_I2C_DESIGNWARE_PCI=y
CONFIG_I2C_DESIGNWARE_BAYTRAIL=y
CONFIG_I2C_EMEV2=y
CONFIG_I2C_KEMPLD=y
CONFIG_I2C_OCORES=y
CONFIG_I2C_PCA_PLATFORM=y
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_RK3X=y
CONFIG_I2C_SIMTEC=y
CONFIG_I2C_XILINX=y

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_DIOLAN_U2C=y
CONFIG_I2C_PARPORT=y
CONFIG_I2C_PARPORT_LIGHT=y
# CONFIG_I2C_ROBOTFUZZ_OSIF is not set
# CONFIG_I2C_TAOS_EVM is not set
CONFIG_I2C_TINY_USB=y
# CONFIG_I2C_VIPERBOARD is not set

#
# Other I2C/SMBus bus drivers
#
CONFIG_I2C_CROS_EC_TUNNEL=y
CONFIG_I2C_SLAVE=y
CONFIG_I2C_SLAVE_EEPROM=y
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
CONFIG_SPI=y
CONFIG_SPI_DEBUG=y
CONFIG_SPI_MASTER=y

#
# SPI Master Controller Drivers
#
CONFIG_SPI_ALTERA=y
CONFIG_SPI_AXI_SPI_ENGINE=y
CONFIG_SPI_BITBANG=y
CONFIG_SPI_BUTTERFLY=y
CONFIG_SPI_CADENCE=y
# CONFIG_SPI_DESIGNWARE is not set
CONFIG_SPI_LM70_LLP=y
CONFIG_SPI_FSL_LIB=y
CONFIG_SPI_FSL_SPI=y
CONFIG_SPI_PXA2XX=y
CONFIG_SPI_PXA2XX_PCI=y
CONFIG_SPI_ROCKCHIP=y
CONFIG_SPI_SC18IS602=y
# CONFIG_SPI_XCOMM is not set
CONFIG_SPI_XILINX=y
# CONFIG_SPI_ZYNQMP_GQSPI is not set

#
# SPI Protocol Masters
#
CONFIG_SPI_SPIDEV=y
CONFIG_SPI_TLE62X0=y
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
# CONFIG_PPS is not set

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
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
# CONFIG_GPIOLIB is not set
CONFIG_W1=y

#
# 1-wire Bus Masters
#
CONFIG_W1_MASTER_MATROX=y
CONFIG_W1_MASTER_DS2490=y
CONFIG_W1_MASTER_DS2482=y
CONFIG_W1_MASTER_DS1WM=y

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
# CONFIG_W1_SLAVE_SMEM is not set
CONFIG_W1_SLAVE_DS2408=y
# CONFIG_W1_SLAVE_DS2408_READBACK is not set
CONFIG_W1_SLAVE_DS2413=y
CONFIG_W1_SLAVE_DS2406=y
CONFIG_W1_SLAVE_DS2423=y
# CONFIG_W1_SLAVE_DS2431 is not set
# CONFIG_W1_SLAVE_DS2433 is not set
CONFIG_W1_SLAVE_DS2760=y
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=y
# CONFIG_W1_SLAVE_DS28E04 is not set
CONFIG_W1_SLAVE_BQ27000=y
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
CONFIG_PDA_POWER=y
# CONFIG_MAX8925_POWER is not set
CONFIG_TEST_POWER=y
CONFIG_BATTERY_88PM860X=y
# CONFIG_BATTERY_ACT8945A is not set
CONFIG_BATTERY_DS2760=y
CONFIG_BATTERY_DS2780=y
CONFIG_BATTERY_DS2781=y
CONFIG_BATTERY_DS2782=y
CONFIG_BATTERY_SBS=y
# CONFIG_BATTERY_BQ27XXX is not set
# CONFIG_BATTERY_DA9052 is not set
# CONFIG_BATTERY_DA9150 is not set
CONFIG_BATTERY_MAX17040=y
CONFIG_BATTERY_MAX17042=y
# CONFIG_CHARGER_88PM860X is not set
CONFIG_CHARGER_PCF50633=y
CONFIG_CHARGER_ISP1704=y
CONFIG_CHARGER_MAX8903=y
# CONFIG_CHARGER_LP8727 is not set
# CONFIG_CHARGER_MANAGER is not set
CONFIG_CHARGER_MAX8998=y
CONFIG_CHARGER_BQ2415X=y
CONFIG_CHARGER_SMB347=y
CONFIG_CHARGER_TPS65217=y
# CONFIG_BATTERY_GAUGE_LTC2941 is not set
# CONFIG_BATTERY_RT5033 is not set
# CONFIG_POWER_RESET is not set
CONFIG_POWER_AVS=y
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
CONFIG_HWMON_DEBUG_CHIP=y

#
# Native drivers
#
CONFIG_SENSORS_ABITUGURU=y
CONFIG_SENSORS_ABITUGURU3=y
CONFIG_SENSORS_AD7314=y
CONFIG_SENSORS_AD7414=y
CONFIG_SENSORS_AD7418=y
CONFIG_SENSORS_ADM1021=y
CONFIG_SENSORS_ADM1025=y
CONFIG_SENSORS_ADM1026=y
CONFIG_SENSORS_ADM1029=y
# CONFIG_SENSORS_ADM1031 is not set
CONFIG_SENSORS_ADM9240=y
CONFIG_SENSORS_ADT7X10=y
CONFIG_SENSORS_ADT7310=y
CONFIG_SENSORS_ADT7410=y
CONFIG_SENSORS_ADT7411=y
# CONFIG_SENSORS_ADT7462 is not set
CONFIG_SENSORS_ADT7470=y
CONFIG_SENSORS_ADT7475=y
CONFIG_SENSORS_ASC7621=y
CONFIG_SENSORS_K8TEMP=y
CONFIG_SENSORS_K10TEMP=y
# CONFIG_SENSORS_FAM15H_POWER is not set
CONFIG_SENSORS_APPLESMC=y
# CONFIG_SENSORS_ASB100 is not set
CONFIG_SENSORS_ATXP1=y
# CONFIG_SENSORS_DS620 is not set
# CONFIG_SENSORS_DS1621 is not set
CONFIG_SENSORS_DELL_SMM=y
CONFIG_SENSORS_DA9052_ADC=y
CONFIG_SENSORS_I5K_AMB=y
CONFIG_SENSORS_F71805F=y
CONFIG_SENSORS_F71882FG=y
CONFIG_SENSORS_F75375S=y
# CONFIG_SENSORS_MC13783_ADC is not set
CONFIG_SENSORS_FSCHMD=y
CONFIG_SENSORS_GL518SM=y
CONFIG_SENSORS_GL520SM=y
CONFIG_SENSORS_G760A=y
CONFIG_SENSORS_G762=y
CONFIG_SENSORS_HIH6130=y
CONFIG_SENSORS_IBMAEM=y
CONFIG_SENSORS_IBMPEX=y
CONFIG_SENSORS_I5500=y
CONFIG_SENSORS_CORETEMP=y
CONFIG_SENSORS_IT87=y
# CONFIG_SENSORS_JC42 is not set
CONFIG_SENSORS_POWR1220=y
# CONFIG_SENSORS_LINEAGE is not set
# CONFIG_SENSORS_LTC2945 is not set
CONFIG_SENSORS_LTC2990=y
CONFIG_SENSORS_LTC4151=y
CONFIG_SENSORS_LTC4215=y
CONFIG_SENSORS_LTC4222=y
CONFIG_SENSORS_LTC4245=y
# CONFIG_SENSORS_LTC4260 is not set
CONFIG_SENSORS_LTC4261=y
# CONFIG_SENSORS_MAX1111 is not set
# CONFIG_SENSORS_MAX16065 is not set
CONFIG_SENSORS_MAX1619=y
CONFIG_SENSORS_MAX1668=y
CONFIG_SENSORS_MAX197=y
# CONFIG_SENSORS_MAX31722 is not set
CONFIG_SENSORS_MAX6639=y
# CONFIG_SENSORS_MAX6642 is not set
CONFIG_SENSORS_MAX6650=y
CONFIG_SENSORS_MAX6697=y
CONFIG_SENSORS_MAX31790=y
CONFIG_SENSORS_MCP3021=y
# CONFIG_SENSORS_MENF21BMC_HWMON is not set
# CONFIG_SENSORS_ADCXX is not set
# CONFIG_SENSORS_LM63 is not set
# CONFIG_SENSORS_LM70 is not set
# CONFIG_SENSORS_LM73 is not set
# CONFIG_SENSORS_LM75 is not set
CONFIG_SENSORS_LM77=y
# CONFIG_SENSORS_LM78 is not set
CONFIG_SENSORS_LM80=y
# CONFIG_SENSORS_LM83 is not set
CONFIG_SENSORS_LM85=y
CONFIG_SENSORS_LM87=y
# CONFIG_SENSORS_LM90 is not set
CONFIG_SENSORS_LM92=y
# CONFIG_SENSORS_LM93 is not set
CONFIG_SENSORS_LM95234=y
CONFIG_SENSORS_LM95241=y
CONFIG_SENSORS_LM95245=y
# CONFIG_SENSORS_PC87360 is not set
CONFIG_SENSORS_PC87427=y
# CONFIG_SENSORS_NTC_THERMISTOR is not set
CONFIG_SENSORS_NCT6683=y
CONFIG_SENSORS_NCT6775=y
# CONFIG_SENSORS_NCT7802 is not set
CONFIG_SENSORS_NCT7904=y
CONFIG_SENSORS_PCF8591=y
CONFIG_PMBUS=y
CONFIG_SENSORS_PMBUS=y
CONFIG_SENSORS_ADM1275=y
CONFIG_SENSORS_LM25066=y
CONFIG_SENSORS_LTC2978=y
CONFIG_SENSORS_LTC2978_REGULATOR=y
CONFIG_SENSORS_LTC3815=y
CONFIG_SENSORS_MAX16064=y
CONFIG_SENSORS_MAX20751=y
CONFIG_SENSORS_MAX34440=y
CONFIG_SENSORS_MAX8688=y
# CONFIG_SENSORS_TPS40422 is not set
# CONFIG_SENSORS_UCD9000 is not set
# CONFIG_SENSORS_UCD9200 is not set
CONFIG_SENSORS_ZL6100=y
# CONFIG_SENSORS_PWM_FAN is not set
CONFIG_SENSORS_SHT21=y
CONFIG_SENSORS_SHTC1=y
CONFIG_SENSORS_SIS5595=y
# CONFIG_SENSORS_DME1737 is not set
# CONFIG_SENSORS_EMC1403 is not set
# CONFIG_SENSORS_EMC2103 is not set
# CONFIG_SENSORS_EMC6W201 is not set
# CONFIG_SENSORS_SMSC47M1 is not set
# CONFIG_SENSORS_SMSC47M192 is not set
CONFIG_SENSORS_SMSC47B397=y
# CONFIG_SENSORS_SCH56XX_COMMON is not set
# CONFIG_SENSORS_SCH5627 is not set
# CONFIG_SENSORS_SCH5636 is not set
# CONFIG_SENSORS_SMM665 is not set
CONFIG_SENSORS_ADC128D818=y
CONFIG_SENSORS_ADS1015=y
# CONFIG_SENSORS_ADS7828 is not set
CONFIG_SENSORS_ADS7871=y
CONFIG_SENSORS_AMC6821=y
CONFIG_SENSORS_INA209=y
CONFIG_SENSORS_INA2XX=y
CONFIG_SENSORS_TC74=y
CONFIG_SENSORS_THMC50=y
CONFIG_SENSORS_TMP102=y
# CONFIG_SENSORS_TMP103 is not set
CONFIG_SENSORS_TMP401=y
CONFIG_SENSORS_TMP421=y
CONFIG_SENSORS_VIA_CPUTEMP=y
# CONFIG_SENSORS_VIA686A is not set
CONFIG_SENSORS_VT1211=y
CONFIG_SENSORS_VT8231=y
CONFIG_SENSORS_W83781D=y
CONFIG_SENSORS_W83791D=y
CONFIG_SENSORS_W83792D=y
CONFIG_SENSORS_W83793=y
CONFIG_SENSORS_W83795=y
CONFIG_SENSORS_W83795_FANCTRL=y
CONFIG_SENSORS_W83L785TS=y
# CONFIG_SENSORS_W83L786NG is not set
CONFIG_SENSORS_W83627HF=y
# CONFIG_SENSORS_W83627EHF is not set

#
# ACPI drivers
#
CONFIG_SENSORS_ACPI_POWER=y
CONFIG_SENSORS_ATK0110=y
CONFIG_THERMAL=y
# CONFIG_THERMAL_HWMON is not set
# CONFIG_THERMAL_OF is not set
CONFIG_THERMAL_WRITABLE_TRIPS=y
# CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE is not set
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR=y
CONFIG_THERMAL_GOV_FAIR_SHARE=y
# CONFIG_THERMAL_GOV_STEP_WISE is not set
# CONFIG_THERMAL_GOV_BANG_BANG is not set
CONFIG_THERMAL_GOV_USER_SPACE=y
CONFIG_THERMAL_GOV_POWER_ALLOCATOR=y
CONFIG_THERMAL_EMULATION=y
CONFIG_INTEL_POWERCLAMP=y
CONFIG_INTEL_SOC_DTS_IOSF_CORE=y
CONFIG_INTEL_SOC_DTS_THERMAL=y

#
# ACPI INT340X thermal drivers
#
CONFIG_INT340X_THERMAL=y
CONFIG_ACPI_THERMAL_REL=y
CONFIG_INTEL_PCH_THERMAL=y
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y
CONFIG_WATCHDOG_NOWAYOUT=y
# CONFIG_WATCHDOG_SYSFS is not set

#
# Watchdog Device Drivers
#
# CONFIG_SOFT_WATCHDOG is not set
CONFIG_DA9052_WATCHDOG=y
CONFIG_DA9063_WATCHDOG=y
# CONFIG_DA9062_WATCHDOG is not set
CONFIG_MENF21BMC_WATCHDOG=y
CONFIG_XILINX_WATCHDOG=y
# CONFIG_ZIIRAVE_WATCHDOG is not set
CONFIG_CADENCE_WATCHDOG=y
CONFIG_DW_WATCHDOG=y
CONFIG_RN5T618_WATCHDOG=y
CONFIG_MAX63XX_WATCHDOG=y
CONFIG_RETU_WATCHDOG=y
CONFIG_ACQUIRE_WDT=y
# CONFIG_ADVANTECH_WDT is not set
CONFIG_ALIM1535_WDT=y
CONFIG_ALIM7101_WDT=y
# CONFIG_F71808E_WDT is not set
# CONFIG_SP5100_TCO is not set
CONFIG_SBC_FITPC2_WATCHDOG=y
# CONFIG_EUROTECH_WDT is not set
CONFIG_IB700_WDT=y
CONFIG_IBMASR=y
CONFIG_WAFER_WDT=y
CONFIG_I6300ESB_WDT=y
# CONFIG_IE6XX_WDT is not set
CONFIG_ITCO_WDT=y
# CONFIG_ITCO_VENDOR_SUPPORT is not set
CONFIG_IT8712F_WDT=y
CONFIG_IT87_WDT=y
CONFIG_HP_WATCHDOG=y
CONFIG_KEMPLD_WDT=y
CONFIG_HPWDT_NMI_DECODING=y
# CONFIG_SC1200_WDT is not set
CONFIG_PC87413_WDT=y
CONFIG_NV_TCO=y
# CONFIG_60XX_WDT is not set
CONFIG_CPU5_WDT=y
CONFIG_SMSC_SCH311X_WDT=y
CONFIG_SMSC37B787_WDT=y
CONFIG_VIA_WDT=y
# CONFIG_W83627HF_WDT is not set
CONFIG_W83877F_WDT=y
CONFIG_W83977F_WDT=y
CONFIG_MACHZ_WDT=y
CONFIG_SBC_EPX_C3_WATCHDOG=y
# CONFIG_NI903X_WDT is not set
CONFIG_XEN_WDT=y

#
# PCI-based Watchdog Cards
#
# CONFIG_PCIPCWATCHDOG is not set
CONFIG_WDTPCI=y

#
# USB-based Watchdog Cards
#
CONFIG_USBPCWATCHDOG=y
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
# CONFIG_BCMA_HOST_PCI is not set
CONFIG_BCMA_HOST_SOC=y
CONFIG_BCMA_DRIVER_PCI=y
# CONFIG_BCMA_DRIVER_GMAC_CMN is not set
CONFIG_BCMA_DEBUG=y

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
CONFIG_MFD_ACT8945A=y
# CONFIG_MFD_AS3711 is not set
# CONFIG_MFD_AS3722 is not set
CONFIG_PMIC_ADP5520=y
CONFIG_MFD_ATMEL_FLEXCOM=y
CONFIG_MFD_ATMEL_HLCDC=y
CONFIG_MFD_BCM590XX=y
# CONFIG_MFD_AXP20X_I2C is not set
CONFIG_MFD_CROS_EC=y
CONFIG_MFD_CROS_EC_I2C=y
CONFIG_MFD_CROS_EC_SPI=y
# CONFIG_PMIC_DA903X is not set
CONFIG_PMIC_DA9052=y
# CONFIG_MFD_DA9052_SPI is not set
CONFIG_MFD_DA9052_I2C=y
# CONFIG_MFD_DA9055 is not set
CONFIG_MFD_DA9062=y
CONFIG_MFD_DA9063=y
CONFIG_MFD_DA9150=y
# CONFIG_MFD_DLN2 is not set
CONFIG_MFD_MC13XXX=y
CONFIG_MFD_MC13XXX_SPI=y
CONFIG_MFD_MC13XXX_I2C=y
CONFIG_MFD_HI6421_PMIC=y
CONFIG_HTC_PASIC3=y
CONFIG_MFD_INTEL_QUARK_I2C_GPIO=y
CONFIG_LPC_ICH=y
CONFIG_LPC_SCH=y
CONFIG_MFD_INTEL_LPSS=y
CONFIG_MFD_INTEL_LPSS_ACPI=y
# CONFIG_MFD_INTEL_LPSS_PCI is not set
# CONFIG_MFD_JANZ_CMODIO is not set
CONFIG_MFD_KEMPLD=y
CONFIG_MFD_88PM800=y
# CONFIG_MFD_88PM805 is not set
CONFIG_MFD_88PM860X=y
# CONFIG_MFD_MAX14577 is not set
# CONFIG_MFD_MAX77620 is not set
CONFIG_MFD_MAX77686=y
# CONFIG_MFD_MAX77693 is not set
# CONFIG_MFD_MAX77843 is not set
CONFIG_MFD_MAX8907=y
CONFIG_MFD_MAX8925=y
# CONFIG_MFD_MAX8997 is not set
CONFIG_MFD_MAX8998=y
CONFIG_MFD_MT6397=y
CONFIG_MFD_MENF21BMC=y
# CONFIG_EZX_PCAP is not set
CONFIG_MFD_VIPERBOARD=y
CONFIG_MFD_RETU=y
CONFIG_MFD_PCF50633=y
CONFIG_PCF50633_ADC=y
# CONFIG_PCF50633_GPIO is not set
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_RTSX_PCI is not set
CONFIG_MFD_RT5033=y
# CONFIG_MFD_RTSX_USB is not set
CONFIG_MFD_RC5T583=y
# CONFIG_MFD_RK808 is not set
CONFIG_MFD_RN5T618=y
# CONFIG_MFD_SEC_CORE is not set
CONFIG_MFD_SI476X_CORE=y
CONFIG_MFD_SM501=y
# CONFIG_MFD_SKY81452 is not set
CONFIG_MFD_SMSC=y
CONFIG_ABX500_CORE=y
# CONFIG_AB3100_CORE is not set
# CONFIG_MFD_STMPE is not set
CONFIG_MFD_SYSCON=y
CONFIG_MFD_TI_AM335X_TSCADC=y
CONFIG_MFD_LP3943=y
# CONFIG_MFD_LP8788 is not set
CONFIG_MFD_PALMAS=y
CONFIG_TPS6105X=y
CONFIG_TPS6507X=y
# CONFIG_MFD_TPS65086 is not set
# CONFIG_MFD_TPS65090 is not set
CONFIG_MFD_TPS65217=y
CONFIG_MFD_TPS65218=y
# CONFIG_MFD_TPS6586X is not set
CONFIG_MFD_TPS65912=y
CONFIG_MFD_TPS65912_I2C=y
# CONFIG_MFD_TPS65912_SPI is not set
# CONFIG_MFD_TPS80031 is not set
# CONFIG_TWL4030_CORE is not set
CONFIG_TWL6040_CORE=y
CONFIG_MFD_WL1273_CORE=y
CONFIG_MFD_LM3533=y
# CONFIG_MFD_TC3589X is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_VX855 is not set
CONFIG_MFD_ARIZONA=y
CONFIG_MFD_ARIZONA_I2C=y
CONFIG_MFD_ARIZONA_SPI=y
# CONFIG_MFD_CS47L24 is not set
CONFIG_MFD_WM5102=y
# CONFIG_MFD_WM5110 is not set
CONFIG_MFD_WM8997=y
# CONFIG_MFD_WM8998 is not set
# CONFIG_MFD_WM8400 is not set
# CONFIG_MFD_WM831X_I2C is not set
# CONFIG_MFD_WM831X_SPI is not set
# CONFIG_MFD_WM8350_I2C is not set
# CONFIG_MFD_WM8994 is not set
CONFIG_REGULATOR=y
# CONFIG_REGULATOR_DEBUG is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=y
CONFIG_REGULATOR_VIRTUAL_CONSUMER=y
# CONFIG_REGULATOR_USERSPACE_CONSUMER is not set
CONFIG_REGULATOR_88PM800=y
CONFIG_REGULATOR_88PM8607=y
# CONFIG_REGULATOR_ACT8865 is not set
CONFIG_REGULATOR_ACT8945A=y
# CONFIG_REGULATOR_AD5398 is not set
CONFIG_REGULATOR_ANATOP=y
CONFIG_REGULATOR_BCM590XX=y
# CONFIG_REGULATOR_DA9052 is not set
CONFIG_REGULATOR_DA9062=y
CONFIG_REGULATOR_DA9063=y
CONFIG_REGULATOR_DA9210=y
CONFIG_REGULATOR_DA9211=y
CONFIG_REGULATOR_FAN53555=y
# CONFIG_REGULATOR_HI6421 is not set
# CONFIG_REGULATOR_ISL9305 is not set
CONFIG_REGULATOR_ISL6271A=y
# CONFIG_REGULATOR_LP3971 is not set
# CONFIG_REGULATOR_LP3972 is not set
# CONFIG_REGULATOR_LP872X is not set
# CONFIG_REGULATOR_LP8755 is not set
CONFIG_REGULATOR_LTC3589=y
CONFIG_REGULATOR_MAX1586=y
CONFIG_REGULATOR_MAX8649=y
CONFIG_REGULATOR_MAX8660=y
CONFIG_REGULATOR_MAX8907=y
CONFIG_REGULATOR_MAX8925=y
CONFIG_REGULATOR_MAX8952=y
CONFIG_REGULATOR_MAX8998=y
CONFIG_REGULATOR_MAX77686=y
# CONFIG_REGULATOR_MAX77802 is not set
CONFIG_REGULATOR_MC13XXX_CORE=y
CONFIG_REGULATOR_MC13783=y
CONFIG_REGULATOR_MC13892=y
CONFIG_REGULATOR_MT6311=y
CONFIG_REGULATOR_MT6397=y
CONFIG_REGULATOR_PALMAS=y
CONFIG_REGULATOR_PCF50633=y
# CONFIG_REGULATOR_PFUZE100 is not set
# CONFIG_REGULATOR_PV88060 is not set
CONFIG_REGULATOR_PV88080=y
CONFIG_REGULATOR_PV88090=y
CONFIG_REGULATOR_PWM=y
CONFIG_REGULATOR_QCOM_SPMI=y
CONFIG_REGULATOR_RC5T583=y
CONFIG_REGULATOR_RN5T618=y
CONFIG_REGULATOR_RT5033=y
# CONFIG_REGULATOR_TPS51632 is not set
CONFIG_REGULATOR_TPS6105X=y
CONFIG_REGULATOR_TPS62360=y
CONFIG_REGULATOR_TPS65023=y
CONFIG_REGULATOR_TPS6507X=y
CONFIG_REGULATOR_TPS65217=y
# CONFIG_REGULATOR_TPS65218 is not set
# CONFIG_REGULATOR_TPS6524X is not set
CONFIG_REGULATOR_TPS65912=y
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
CONFIG_MEDIA_CAMERA_SUPPORT=y
# CONFIG_MEDIA_ANALOG_TV_SUPPORT is not set
CONFIG_MEDIA_DIGITAL_TV_SUPPORT=y
# CONFIG_MEDIA_RADIO_SUPPORT is not set
# CONFIG_MEDIA_SDR_SUPPORT is not set
# CONFIG_MEDIA_RC_SUPPORT is not set
# CONFIG_MEDIA_CONTROLLER is not set
CONFIG_VIDEO_DEV=y
CONFIG_VIDEO_V4L2=y
CONFIG_VIDEO_ADV_DEBUG=y
# CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
CONFIG_VIDEO_TUNER=y
CONFIG_V4L2_MEM2MEM_DEV=y
CONFIG_VIDEOBUF2_CORE=y
CONFIG_VIDEOBUF2_MEMOPS=y
CONFIG_VIDEOBUF2_VMALLOC=y
CONFIG_VIDEOBUF2_DMA_SG=y
CONFIG_DVB_CORE=y
# CONFIG_TTPCI_EEPROM is not set
CONFIG_DVB_MAX_ADAPTERS=8
CONFIG_DVB_DYNAMIC_MINORS=y

#
# Media drivers
#
CONFIG_MEDIA_USB_SUPPORT=y

#
# Webcam devices
#
CONFIG_USB_VIDEO_CLASS=y
# CONFIG_USB_VIDEO_CLASS_INPUT_EVDEV is not set
CONFIG_USB_GSPCA=y
CONFIG_USB_M5602=y
CONFIG_USB_STV06XX=y
# CONFIG_USB_GL860 is not set
# CONFIG_USB_GSPCA_BENQ is not set
CONFIG_USB_GSPCA_CONEX=y
CONFIG_USB_GSPCA_CPIA1=y
CONFIG_USB_GSPCA_DTCS033=y
CONFIG_USB_GSPCA_ETOMS=y
# CONFIG_USB_GSPCA_FINEPIX is not set
# CONFIG_USB_GSPCA_JEILINJ is not set
# CONFIG_USB_GSPCA_JL2005BCD is not set
# CONFIG_USB_GSPCA_KINECT is not set
CONFIG_USB_GSPCA_KONICA=y
CONFIG_USB_GSPCA_MARS=y
# CONFIG_USB_GSPCA_MR97310A is not set
CONFIG_USB_GSPCA_NW80X=y
CONFIG_USB_GSPCA_OV519=y
# CONFIG_USB_GSPCA_OV534 is not set
CONFIG_USB_GSPCA_OV534_9=y
CONFIG_USB_GSPCA_PAC207=y
# CONFIG_USB_GSPCA_PAC7302 is not set
CONFIG_USB_GSPCA_PAC7311=y
CONFIG_USB_GSPCA_SE401=y
# CONFIG_USB_GSPCA_SN9C2028 is not set
CONFIG_USB_GSPCA_SN9C20X=y
# CONFIG_USB_GSPCA_SONIXB is not set
CONFIG_USB_GSPCA_SONIXJ=y
CONFIG_USB_GSPCA_SPCA500=y
CONFIG_USB_GSPCA_SPCA501=y
CONFIG_USB_GSPCA_SPCA505=y
# CONFIG_USB_GSPCA_SPCA506 is not set
CONFIG_USB_GSPCA_SPCA508=y
CONFIG_USB_GSPCA_SPCA561=y
CONFIG_USB_GSPCA_SPCA1528=y
CONFIG_USB_GSPCA_SQ905=y
# CONFIG_USB_GSPCA_SQ905C is not set
CONFIG_USB_GSPCA_SQ930X=y
CONFIG_USB_GSPCA_STK014=y
# CONFIG_USB_GSPCA_STK1135 is not set
# CONFIG_USB_GSPCA_STV0680 is not set
CONFIG_USB_GSPCA_SUNPLUS=y
# CONFIG_USB_GSPCA_T613 is not set
CONFIG_USB_GSPCA_TOPRO=y
# CONFIG_USB_GSPCA_TOUPTEK is not set
# CONFIG_USB_GSPCA_TV8532 is not set
# CONFIG_USB_GSPCA_VC032X is not set
# CONFIG_USB_GSPCA_VICAM is not set
CONFIG_USB_GSPCA_XIRLINK_CIT=y
# CONFIG_USB_GSPCA_ZC3XX is not set
CONFIG_USB_PWC=y
# CONFIG_USB_PWC_DEBUG is not set
# CONFIG_USB_PWC_INPUT_EVDEV is not set
# CONFIG_VIDEO_CPIA2 is not set
# CONFIG_USB_ZR364XX is not set
# CONFIG_USB_STKWEBCAM is not set
CONFIG_USB_S2255=y
CONFIG_VIDEO_USBTV=y

#
# Analog/digital TV USB devices
#
CONFIG_VIDEO_AU0828=y
CONFIG_VIDEO_AU0828_V4L2=y

#
# Digital TV USB devices
#
CONFIG_DVB_USB_V2=y
# CONFIG_DVB_USB_AF9015 is not set
CONFIG_DVB_USB_AF9035=y
CONFIG_DVB_USB_ANYSEE=y
CONFIG_DVB_USB_AU6610=y
CONFIG_DVB_USB_AZ6007=y
CONFIG_DVB_USB_CE6230=y
# CONFIG_DVB_USB_EC168 is not set
# CONFIG_DVB_USB_GL861 is not set
# CONFIG_DVB_USB_MXL111SF is not set
CONFIG_DVB_USB_RTL28XXU=y
CONFIG_DVB_USB_DVBSKY=y
CONFIG_DVB_TTUSB_BUDGET=y
CONFIG_DVB_TTUSB_DEC=y
CONFIG_SMS_USB_DRV=y
CONFIG_DVB_B2C2_FLEXCOP_USB=y
CONFIG_DVB_B2C2_FLEXCOP_USB_DEBUG=y
# CONFIG_DVB_AS102 is not set

#
# Webcam, TV (analog/digital) USB devices
#
CONFIG_VIDEO_EM28XX=y
# CONFIG_VIDEO_EM28XX_V4L2 is not set
CONFIG_VIDEO_EM28XX_ALSA=y
CONFIG_VIDEO_EM28XX_DVB=y
# CONFIG_MEDIA_PCI_SUPPORT is not set
# CONFIG_V4L_PLATFORM_DRIVERS is not set
# CONFIG_V4L_MEM2MEM_DRIVERS is not set
CONFIG_V4L_TEST_DRIVERS=y
CONFIG_VIDEO_VIM2M=y
CONFIG_DVB_PLATFORM_DRIVERS=y

#
# Supported MMC/SDIO adapters
#
CONFIG_SMS_SDIO_DRV=y

#
# Supported FireWire (IEEE 1394) Adapters
#
# CONFIG_DVB_FIREDTV is not set
CONFIG_MEDIA_COMMON_OPTIONS=y

#
# common driver options
#
CONFIG_VIDEO_TVEEPROM=y
CONFIG_CYPRESS_FIRMWARE=y
CONFIG_DVB_B2C2_FLEXCOP=y
CONFIG_DVB_B2C2_FLEXCOP_DEBUG=y
CONFIG_SMS_SIANO_MDTV=y
# CONFIG_SMS_SIANO_DEBUGFS is not set

#
# Media ancillary drivers (tuners, sensors, i2c, frontends)
#
CONFIG_MEDIA_SUBDRV_AUTOSELECT=y

#
# Audio decoders, processors and mixers
#

#
# RDS decoders
#

#
# Video decoders
#

#
# Video and audio decoders
#

#
# Video encoders
#

#
# Camera sensor devices
#

#
# Flash devices
#

#
# Video improvement chips
#

#
# Audio/Video compression chips
#

#
# Miscellaneous helper chips
#

#
# Sensors used on soc_camera driver
#
CONFIG_MEDIA_TUNER=y
CONFIG_MEDIA_TUNER_SIMPLE=y
CONFIG_MEDIA_TUNER_TDA8290=y
CONFIG_MEDIA_TUNER_TDA827X=y
CONFIG_MEDIA_TUNER_TDA18271=y
CONFIG_MEDIA_TUNER_TDA9887=y
CONFIG_MEDIA_TUNER_MT20XX=y
CONFIG_MEDIA_TUNER_MT2060=y
CONFIG_MEDIA_TUNER_MT2063=y
CONFIG_MEDIA_TUNER_QT1010=y
CONFIG_MEDIA_TUNER_XC2028=y
CONFIG_MEDIA_TUNER_XC5000=y
CONFIG_MEDIA_TUNER_XC4000=y
CONFIG_MEDIA_TUNER_MXL5005S=y
CONFIG_MEDIA_TUNER_MXL5007T=y
CONFIG_MEDIA_TUNER_MC44S803=y
CONFIG_MEDIA_TUNER_TDA18218=y
CONFIG_MEDIA_TUNER_FC0011=y
CONFIG_MEDIA_TUNER_FC0012=y
CONFIG_MEDIA_TUNER_FC0013=y
CONFIG_MEDIA_TUNER_TDA18212=y
CONFIG_MEDIA_TUNER_E4000=y
CONFIG_MEDIA_TUNER_FC2580=y
CONFIG_MEDIA_TUNER_TUA9001=y
CONFIG_MEDIA_TUNER_SI2157=y
CONFIG_MEDIA_TUNER_IT913X=y
CONFIG_MEDIA_TUNER_R820T=y
CONFIG_MEDIA_TUNER_QM1D1C0042=y

#
# Multistandard (satellite) frontends
#
CONFIG_DVB_M88DS3103=y

#
# Multistandard (cable + terrestrial) frontends
#
CONFIG_DVB_DRXK=y
CONFIG_DVB_TDA18271C2DD=y

#
# DVB-S (satellite) frontends
#
CONFIG_DVB_CX24123=y
CONFIG_DVB_MT312=y
CONFIG_DVB_S5H1420=y
CONFIG_DVB_STV0299=y
CONFIG_DVB_STV6110=y
CONFIG_DVB_STV0900=y
CONFIG_DVB_TDA8083=y
CONFIG_DVB_TUNER_ITD1000=y
CONFIG_DVB_TUNER_CX24113=y
CONFIG_DVB_CX24116=y
CONFIG_DVB_CX24120=y
CONFIG_DVB_TS2020=y
CONFIG_DVB_TDA10071=y

#
# DVB-T (terrestrial) frontends
#
CONFIG_DVB_CX22700=y
CONFIG_DVB_DRXD=y
CONFIG_DVB_TDA1004X=y
CONFIG_DVB_MT352=y
CONFIG_DVB_ZL10353=y
CONFIG_DVB_CXD2820R=y
CONFIG_DVB_RTL2830=y
CONFIG_DVB_RTL2832=y
CONFIG_DVB_SI2168=y
# CONFIG_DVB_AS102_FE is not set

#
# DVB-C (cable) frontends
#
CONFIG_DVB_VES1820=y
CONFIG_DVB_TDA10023=y
CONFIG_DVB_STV0297=y

#
# ATSC (North American/Korean Terrestrial/Cable DTV) frontends
#
CONFIG_DVB_NXT200X=y
CONFIG_DVB_BCM3510=y
CONFIG_DVB_LGDT330X=y
CONFIG_DVB_LGDT3305=y
CONFIG_DVB_S5H1409=y
CONFIG_DVB_AU8522=y
CONFIG_DVB_AU8522_DTV=y
CONFIG_DVB_AU8522_V4L=y

#
# ISDB-T (terrestrial) frontends
#
CONFIG_DVB_S921=y
CONFIG_DVB_MB86A20S=y

#
# ISDB-S (satellite) & ISDB-T (terrestrial) frontends
#
CONFIG_DVB_TC90522=y

#
# Digital terrestrial only tuners/PLL
#
CONFIG_DVB_PLL=y

#
# SEC control devices for DVB-S
#
CONFIG_DVB_DRX39XYJ=y
CONFIG_DVB_LNBP21=y
CONFIG_DVB_ISL6421=y
CONFIG_DVB_ISL6423=y
CONFIG_DVB_A8293=y
CONFIG_DVB_SP2=y
CONFIG_DVB_AF9033=y

#
# Tools to develop new frontends
#
# CONFIG_DVB_DUMMY_FE is not set

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
CONFIG_VGA_SWITCHEROO=y
# CONFIG_DRM is not set

#
# ACP (Audio CoProcessor) Configuration
#

#
# Frame buffer Devices
#
# CONFIG_FB is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
CONFIG_LCD_LTV350QV=y
# CONFIG_LCD_ILI922X is not set
CONFIG_LCD_ILI9320=y
CONFIG_LCD_TDO24M=y
CONFIG_LCD_VGG2432A4=y
CONFIG_LCD_PLATFORM=y
# CONFIG_LCD_S6E63M0 is not set
CONFIG_LCD_LD9040=y
# CONFIG_LCD_AMS369FG06 is not set
# CONFIG_LCD_LMS501KF03 is not set
CONFIG_LCD_HX8357=y
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_GENERIC=y
CONFIG_BACKLIGHT_LM3533=y
CONFIG_BACKLIGHT_PWM=y
# CONFIG_BACKLIGHT_DA9052 is not set
CONFIG_BACKLIGHT_MAX8925=y
CONFIG_BACKLIGHT_APPLE=y
# CONFIG_BACKLIGHT_PM8941_WLED is not set
# CONFIG_BACKLIGHT_SAHARA is not set
CONFIG_BACKLIGHT_ADP5520=y
CONFIG_BACKLIGHT_ADP8860=y
CONFIG_BACKLIGHT_ADP8870=y
# CONFIG_BACKLIGHT_88PM860X is not set
CONFIG_BACKLIGHT_PCF50633=y
# CONFIG_BACKLIGHT_LM3630A is not set
CONFIG_BACKLIGHT_LM3639=y
# CONFIG_BACKLIGHT_LP855X is not set
# CONFIG_BACKLIGHT_TPS65217 is not set
CONFIG_BACKLIGHT_LV5207LP=y
CONFIG_BACKLIGHT_BD6107=y
# CONFIG_VGASTATE is not set

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
CONFIG_VGACON_SOFT_SCROLLBACK=y
CONFIG_VGACON_SOFT_SCROLLBACK_SIZE=64
CONFIG_DUMMY_CONSOLE=y
CONFIG_DUMMY_CONSOLE_COLUMNS=80
CONFIG_DUMMY_CONSOLE_ROWS=25
CONFIG_SOUND=y
CONFIG_SOUND_OSS_CORE=y
# CONFIG_SOUND_OSS_CORE_PRECLAIM is not set
CONFIG_SND=y
CONFIG_SND_TIMER=y
CONFIG_SND_PCM=y
CONFIG_SND_HWDEP=y
CONFIG_SND_RAWMIDI=y
CONFIG_SND_JACK=y
CONFIG_SND_JACK_INPUT_DEV=y
CONFIG_SND_SEQUENCER=y
# CONFIG_SND_SEQ_DUMMY is not set
CONFIG_SND_OSSEMUL=y
CONFIG_SND_MIXER_OSS=y
# CONFIG_SND_PCM_OSS is not set
CONFIG_SND_PCM_TIMER=y
# CONFIG_SND_SEQUENCER_OSS is not set
CONFIG_SND_HRTIMER=y
# CONFIG_SND_SEQ_HRTIMER_DEFAULT is not set
# CONFIG_SND_DYNAMIC_MINORS is not set
# CONFIG_SND_SUPPORT_OLD_API is not set
CONFIG_SND_PROC_FS=y
CONFIG_SND_VERBOSE_PROCFS=y
CONFIG_SND_VERBOSE_PRINTK=y
CONFIG_SND_DEBUG=y
# CONFIG_SND_DEBUG_VERBOSE is not set
# CONFIG_SND_PCM_XRUN_DEBUG is not set
CONFIG_SND_VMASTER=y
CONFIG_SND_DMA_SGBUF=y
CONFIG_SND_RAWMIDI_SEQ=y
CONFIG_SND_OPL3_LIB_SEQ=y
# CONFIG_SND_OPL4_LIB_SEQ is not set
# CONFIG_SND_SBAWE_SEQ is not set
CONFIG_SND_EMU10K1_SEQ=y
CONFIG_SND_MPU401_UART=y
CONFIG_SND_OPL3_LIB=y
CONFIG_SND_VX_LIB=y
CONFIG_SND_AC97_CODEC=y
CONFIG_SND_DRIVERS=y
# CONFIG_SND_PCSP is not set
CONFIG_SND_DUMMY=y
# CONFIG_SND_ALOOP is not set
CONFIG_SND_VIRMIDI=y
CONFIG_SND_MTPAV=y
CONFIG_SND_MTS64=y
# CONFIG_SND_SERIAL_U16550 is not set
# CONFIG_SND_MPU401 is not set
CONFIG_SND_PORTMAN2X4=y
CONFIG_SND_AC97_POWER_SAVE=y
CONFIG_SND_AC97_POWER_SAVE_DEFAULT=0
CONFIG_SND_PCI=y
CONFIG_SND_AD1889=y
CONFIG_SND_ALS300=y
# CONFIG_SND_ALS4000 is not set
CONFIG_SND_ALI5451=y
# CONFIG_SND_ASIHPI is not set
# CONFIG_SND_ATIIXP is not set
# CONFIG_SND_ATIIXP_MODEM is not set
# CONFIG_SND_AU8810 is not set
CONFIG_SND_AU8820=y
CONFIG_SND_AU8830=y
CONFIG_SND_AW2=y
CONFIG_SND_AZT3328=y
CONFIG_SND_BT87X=y
# CONFIG_SND_BT87X_OVERCLOCK is not set
CONFIG_SND_CA0106=y
CONFIG_SND_CMIPCI=y
CONFIG_SND_OXYGEN_LIB=y
CONFIG_SND_OXYGEN=y
# CONFIG_SND_CS4281 is not set
CONFIG_SND_CS46XX=y
CONFIG_SND_CS46XX_NEW_DSP=y
CONFIG_SND_CTXFI=y
# CONFIG_SND_DARLA20 is not set
# CONFIG_SND_GINA20 is not set
CONFIG_SND_LAYLA20=y
CONFIG_SND_DARLA24=y
# CONFIG_SND_GINA24 is not set
# CONFIG_SND_LAYLA24 is not set
CONFIG_SND_MONA=y
# CONFIG_SND_MIA is not set
CONFIG_SND_ECHO3G=y
# CONFIG_SND_INDIGO is not set
CONFIG_SND_INDIGOIO=y
CONFIG_SND_INDIGODJ=y
# CONFIG_SND_INDIGOIOX is not set
CONFIG_SND_INDIGODJX=y
CONFIG_SND_EMU10K1=y
# CONFIG_SND_EMU10K1X is not set
CONFIG_SND_ENS1370=y
CONFIG_SND_ENS1371=y
CONFIG_SND_ES1938=y
CONFIG_SND_ES1968=y
CONFIG_SND_ES1968_INPUT=y
# CONFIG_SND_FM801 is not set
# CONFIG_SND_HDSP is not set
CONFIG_SND_HDSPM=y
CONFIG_SND_ICE1712=y
CONFIG_SND_ICE1724=y
CONFIG_SND_INTEL8X0=y
CONFIG_SND_INTEL8X0M=y
CONFIG_SND_KORG1212=y
# CONFIG_SND_LOLA is not set
# CONFIG_SND_LX6464ES is not set
CONFIG_SND_MAESTRO3=y
CONFIG_SND_MAESTRO3_INPUT=y
CONFIG_SND_MIXART=y
CONFIG_SND_NM256=y
CONFIG_SND_PCXHR=y
CONFIG_SND_RIPTIDE=y
# CONFIG_SND_RME32 is not set
CONFIG_SND_RME96=y
# CONFIG_SND_RME9652 is not set
CONFIG_SND_SONICVIBES=y
CONFIG_SND_TRIDENT=y
# CONFIG_SND_VIA82XX is not set
# CONFIG_SND_VIA82XX_MODEM is not set
CONFIG_SND_VIRTUOSO=y
CONFIG_SND_VX222=y
CONFIG_SND_YMFPCI=y

#
# HD-Audio
#
# CONFIG_SND_HDA_INTEL is not set
CONFIG_SND_HDA_PREALLOC_SIZE=64
CONFIG_SND_SPI=y
# CONFIG_SND_USB is not set
CONFIG_SND_FIREWIRE=y
CONFIG_SND_FIREWIRE_LIB=y
# CONFIG_SND_DICE is not set
CONFIG_SND_OXFW=y
# CONFIG_SND_ISIGHT is not set
CONFIG_SND_FIREWORKS=y
# CONFIG_SND_BEBOB is not set
CONFIG_SND_FIREWIRE_DIGI00X=y
# CONFIG_SND_FIREWIRE_TASCAM is not set
# CONFIG_SND_SOC is not set
# CONFIG_SOUND_PRIME is not set
CONFIG_AC97_BUS=y

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
# CONFIG_HIDRAW is not set
CONFIG_UHID=y
# CONFIG_HID_GENERIC is not set

#
# Special HID drivers
#
# CONFIG_HID_A4TECH is not set
CONFIG_HID_ACRUX=y
CONFIG_HID_ACRUX_FF=y
# CONFIG_HID_APPLE is not set
CONFIG_HID_APPLEIR=y
CONFIG_HID_ASUS=y
CONFIG_HID_AUREAL=y
# CONFIG_HID_BELKIN is not set
CONFIG_HID_BETOP_FF=y
CONFIG_HID_CHERRY=y
# CONFIG_HID_CHICONY is not set
CONFIG_HID_CORSAIR=y
CONFIG_HID_PRODIKEYS=y
# CONFIG_HID_CMEDIA is not set
CONFIG_HID_CYPRESS=y
CONFIG_HID_DRAGONRISE=y
CONFIG_DRAGONRISE_FF=y
CONFIG_HID_EMS_FF=y
# CONFIG_HID_ELECOM is not set
# CONFIG_HID_ELO is not set
CONFIG_HID_EZKEY=y
# CONFIG_HID_GEMBIRD is not set
CONFIG_HID_GFRM=y
CONFIG_HID_HOLTEK=y
CONFIG_HOLTEK_FF=y
CONFIG_HID_GT683R=y
# CONFIG_HID_KEYTOUCH is not set
CONFIG_HID_KYE=y
# CONFIG_HID_UCLOGIC is not set
CONFIG_HID_WALTOP=y
# CONFIG_HID_GYRATION is not set
CONFIG_HID_ICADE=y
CONFIG_HID_TWINHAN=y
CONFIG_HID_KENSINGTON=y
CONFIG_HID_LCPOWER=y
# CONFIG_HID_LENOVO is not set
# CONFIG_HID_LOGITECH is not set
# CONFIG_HID_MAGICMOUSE is not set
CONFIG_HID_MICROSOFT=y
# CONFIG_HID_MONTEREY is not set
# CONFIG_HID_MULTITOUCH is not set
CONFIG_HID_NTRIG=y
CONFIG_HID_ORTEK=y
# CONFIG_HID_PANTHERLORD is not set
CONFIG_HID_PENMOUNT=y
CONFIG_HID_PETALYNX=y
# CONFIG_HID_PICOLCD is not set
CONFIG_HID_PLANTRONICS=y
CONFIG_HID_PRIMAX=y
# CONFIG_HID_ROCCAT is not set
CONFIG_HID_SAITEK=y
# CONFIG_HID_SAMSUNG is not set
CONFIG_HID_SONY=y
CONFIG_SONY_FF=y
CONFIG_HID_SPEEDLINK=y
CONFIG_HID_STEELSERIES=y
CONFIG_HID_SUNPLUS=y
CONFIG_HID_RMI=y
CONFIG_HID_GREENASIA=y
CONFIG_GREENASIA_FF=y
CONFIG_HID_HYPERV_MOUSE=y
# CONFIG_HID_SMARTJOYPLUS is not set
CONFIG_HID_TIVO=y
# CONFIG_HID_TOPSEED is not set
CONFIG_HID_THINGM=y
# CONFIG_HID_THRUSTMASTER is not set
CONFIG_HID_WACOM=y
# CONFIG_HID_WIIMOTE is not set
CONFIG_HID_XINMO=y
CONFIG_HID_ZEROPLUS=y
CONFIG_ZEROPLUS_FF=y
# CONFIG_HID_ZYDACRON is not set
CONFIG_HID_SENSOR_HUB=y
CONFIG_HID_SENSOR_CUSTOM_SENSOR=y

#
# USB HID support
#
CONFIG_USB_HID=y
CONFIG_HID_PID=y
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
# CONFIG_USB_ANNOUNCE_NEW_DEVICES is not set

#
# Miscellaneous USB options
#
# CONFIG_USB_DEFAULT_PERSIST is not set
# CONFIG_USB_DYNAMIC_MINORS is not set
# CONFIG_USB_OTG is not set
# CONFIG_USB_OTG_WHITELIST is not set
CONFIG_USB_ULPI_BUS=y
# CONFIG_USB_MON is not set
CONFIG_USB_WUSB_CBAF=y
# CONFIG_USB_WUSB_CBAF_DEBUG is not set

#
# USB Host Controller Drivers
#
# CONFIG_USB_C67X00_HCD is not set
# CONFIG_USB_XHCI_HCD is not set
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_EHCI_ROOT_HUB_TT=y
CONFIG_USB_EHCI_TT_NEWSCHED=y
CONFIG_USB_EHCI_PCI=y
CONFIG_USB_EHCI_HCD_PLATFORM=y
# CONFIG_USB_OXU210HP_HCD is not set
CONFIG_USB_ISP116X_HCD=y
CONFIG_USB_ISP1362_HCD=y
# CONFIG_USB_FOTG210_HCD is not set
CONFIG_USB_MAX3421_HCD=y
CONFIG_USB_OHCI_HCD=y
CONFIG_USB_OHCI_HCD_PCI=y
CONFIG_USB_OHCI_HCD_PLATFORM=y
CONFIG_USB_UHCI_HCD=y
CONFIG_USB_U132_HCD=y
CONFIG_USB_SL811_HCD=y
CONFIG_USB_SL811_HCD_ISO=y
CONFIG_USB_R8A66597_HCD=y
CONFIG_USB_HCD_BCMA=y
# CONFIG_USB_HCD_TEST_MODE is not set

#
# USB Device Class drivers
#
CONFIG_USB_ACM=y
CONFIG_USB_PRINTER=y
CONFIG_USB_WDM=y
CONFIG_USB_TMC=y

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#

#
# USB Imaging devices
#
# CONFIG_USB_MDC800 is not set
# CONFIG_USBIP_CORE is not set
CONFIG_USB_MUSB_HDRC=y
# CONFIG_USB_MUSB_HOST is not set
CONFIG_USB_MUSB_GADGET=y
# CONFIG_USB_MUSB_DUAL_ROLE is not set

#
# Platform Glue Layer
#

#
# MUSB DMA mode
#
CONFIG_MUSB_PIO_ONLY=y
CONFIG_USB_DWC3=y
CONFIG_USB_DWC3_ULPI=y
CONFIG_USB_DWC3_HOST=y
# CONFIG_USB_DWC3_GADGET is not set
# CONFIG_USB_DWC3_DUAL_ROLE is not set

#
# Platform Glue Driver Support
#
CONFIG_USB_DWC3_PCI=y
# CONFIG_USB_DWC3_OF_SIMPLE is not set
# CONFIG_USB_DWC2 is not set
# CONFIG_USB_CHIPIDEA is not set
CONFIG_USB_ISP1760=y
CONFIG_USB_ISP1760_HCD=y
CONFIG_USB_ISP1760_HOST_ROLE=y
# CONFIG_USB_ISP1760_GADGET_ROLE is not set
# CONFIG_USB_ISP1760_DUAL_ROLE is not set

#
# USB port drivers
#
CONFIG_USB_USS720=y
# CONFIG_USB_SERIAL is not set

#
# USB Miscellaneous drivers
#
# CONFIG_USB_EMI62 is not set
# CONFIG_USB_EMI26 is not set
CONFIG_USB_ADUTUX=y
CONFIG_USB_SEVSEG=y
CONFIG_USB_RIO500=y
# CONFIG_USB_LEGOTOWER is not set
# CONFIG_USB_LCD is not set
CONFIG_USB_LED=y
# CONFIG_USB_CYPRESS_CY7C63 is not set
CONFIG_USB_CYTHERM=y
CONFIG_USB_IDMOUSE=y
CONFIG_USB_FTDI_ELAN=y
CONFIG_USB_APPLEDISPLAY=y
CONFIG_USB_SISUSBVGA=y
# CONFIG_USB_SISUSBVGA_CON is not set
# CONFIG_USB_LD is not set
CONFIG_USB_TRANCEVIBRATOR=y
CONFIG_USB_IOWARRIOR=y
CONFIG_USB_TEST=y
CONFIG_USB_EHSET_TEST_FIXTURE=y
# CONFIG_USB_ISIGHTFW is not set
CONFIG_USB_YUREX=y
CONFIG_USB_EZUSB_FX2=y
# CONFIG_USB_HSIC_USB3503 is not set
CONFIG_USB_LINK_LAYER_TEST=y
CONFIG_USB_CHAOSKEY=y
# CONFIG_UCSI is not set

#
# USB Physical Layer drivers
#
CONFIG_USB_PHY=y
CONFIG_NOP_USB_XCEIV=y
CONFIG_USB_ISP1301=y
CONFIG_USB_GADGET=y
# CONFIG_USB_GADGET_DEBUG is not set
CONFIG_USB_GADGET_DEBUG_FILES=y
CONFIG_USB_GADGET_DEBUG_FS=y
CONFIG_USB_GADGET_VBUS_DRAW=2
CONFIG_USB_GADGET_STORAGE_NUM_BUFFERS=2

#
# USB Peripheral Controller
#
CONFIG_USB_FOTG210_UDC=y
# CONFIG_USB_GR_UDC is not set
# CONFIG_USB_R8A66597 is not set
CONFIG_USB_PXA27X=y
CONFIG_USB_MV_UDC=y
CONFIG_USB_MV_U3D=y
CONFIG_USB_M66592=y
# CONFIG_USB_BDC_UDC is not set
CONFIG_USB_AMD5536UDC=y
CONFIG_USB_NET2272=y
# CONFIG_USB_NET2272_DMA is not set
CONFIG_USB_NET2280=y
# CONFIG_USB_GOKU is not set
CONFIG_USB_EG20T=y
CONFIG_USB_GADGET_XILINX=y
CONFIG_USB_DUMMY_HCD=y
CONFIG_USB_LIBCOMPOSITE=y
CONFIG_USB_F_SS_LB=y
CONFIG_USB_U_SERIAL=y
CONFIG_USB_F_OBEX=y
CONFIG_USB_F_MASS_STORAGE=y
CONFIG_USB_F_FS=y
CONFIG_USB_F_UAC2=y
CONFIG_USB_F_HID=y
CONFIG_USB_F_PRINTER=y
CONFIG_USB_CONFIGFS=y
# CONFIG_USB_CONFIGFS_SERIAL is not set
# CONFIG_USB_CONFIGFS_ACM is not set
CONFIG_USB_CONFIGFS_OBEX=y
# CONFIG_USB_CONFIGFS_NCM is not set
# CONFIG_USB_CONFIGFS_ECM is not set
# CONFIG_USB_CONFIGFS_ECM_SUBSET is not set
# CONFIG_USB_CONFIGFS_RNDIS is not set
# CONFIG_USB_CONFIGFS_EEM is not set
CONFIG_USB_CONFIGFS_MASS_STORAGE=y
CONFIG_USB_CONFIGFS_F_LB_SS=y
CONFIG_USB_CONFIGFS_F_FS=y
# CONFIG_USB_CONFIGFS_F_UAC1 is not set
CONFIG_USB_CONFIGFS_F_UAC2=y
# CONFIG_USB_CONFIGFS_F_MIDI is not set
CONFIG_USB_CONFIGFS_F_HID=y
# CONFIG_USB_CONFIGFS_F_UVC is not set
CONFIG_USB_CONFIGFS_F_PRINTER=y
# CONFIG_USB_ZERO is not set
# CONFIG_USB_AUDIO is not set
# CONFIG_USB_ETH is not set
# CONFIG_USB_G_NCM is not set
# CONFIG_USB_GADGETFS is not set
# CONFIG_USB_FUNCTIONFS is not set
# CONFIG_USB_MASS_STORAGE is not set
# CONFIG_USB_G_SERIAL is not set
# CONFIG_USB_MIDI_GADGET is not set
# CONFIG_USB_G_PRINTER is not set
# CONFIG_USB_CDC_COMPOSITE is not set
# CONFIG_USB_G_ACM_MS is not set
# CONFIG_USB_G_MULTI is not set
# CONFIG_USB_G_HID is not set
# CONFIG_USB_G_DBGP is not set
# CONFIG_USB_G_WEBCAM is not set
# CONFIG_USB_LED_TRIG is not set
# CONFIG_UWB is not set
CONFIG_MMC=y
# CONFIG_MMC_DEBUG is not set
CONFIG_PWRSEQ_EMMC=y
CONFIG_PWRSEQ_SIMPLE=y

#
# MMC/SD/SDIO Card Drivers
#
# CONFIG_MMC_BLOCK is not set
CONFIG_SDIO_UART=y
CONFIG_MMC_TEST=y

#
# MMC/SD/SDIO Host Controller Drivers
#
# CONFIG_MMC_SDHCI is not set
CONFIG_MMC_WBSD=y
CONFIG_MMC_TIFM_SD=y
CONFIG_MMC_SPI=y
CONFIG_MMC_CB710=y
CONFIG_MMC_VIA_SDMMC=y
# CONFIG_MMC_VUB300 is not set
# CONFIG_MMC_USHC is not set
CONFIG_MMC_USDHI6ROL0=y
CONFIG_MMC_TOSHIBA_PCI=y
CONFIG_MMC_MTK=y
# CONFIG_MEMSTICK is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y
CONFIG_LEDS_CLASS_FLASH=y

#
# LED drivers
#
# CONFIG_LEDS_88PM860X is not set
CONFIG_LEDS_BCM6328=y
CONFIG_LEDS_BCM6358=y
# CONFIG_LEDS_LM3530 is not set
CONFIG_LEDS_LM3533=y
CONFIG_LEDS_LM3642=y
CONFIG_LEDS_PCA9532=y
CONFIG_LEDS_LP3944=y
CONFIG_LEDS_LP55XX_COMMON=y
CONFIG_LEDS_LP5521=y
# CONFIG_LEDS_LP5523 is not set
# CONFIG_LEDS_LP5562 is not set
# CONFIG_LEDS_LP8501 is not set
# CONFIG_LEDS_LP8860 is not set
# CONFIG_LEDS_CLEVO_MAIL is not set
CONFIG_LEDS_PCA955X=y
# CONFIG_LEDS_PCA963X is not set
CONFIG_LEDS_DA9052=y
CONFIG_LEDS_DAC124S085=y
CONFIG_LEDS_PWM=y
CONFIG_LEDS_REGULATOR=y
CONFIG_LEDS_BD2802=y
CONFIG_LEDS_INTEL_SS4200=y
CONFIG_LEDS_ADP5520=y
CONFIG_LEDS_MC13783=y
CONFIG_LEDS_TCA6507=y
CONFIG_LEDS_TLC591XX=y
CONFIG_LEDS_LM355x=y
CONFIG_LEDS_MENF21BMC=y
CONFIG_LEDS_IS31FL32XX=y

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
# CONFIG_LEDS_BLINKM is not set
CONFIG_LEDS_SYSCON=y

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
# CONFIG_LEDS_TRIGGER_TIMER is not set
# CONFIG_LEDS_TRIGGER_ONESHOT is not set
# CONFIG_LEDS_TRIGGER_IDE_DISK is not set
# CONFIG_LEDS_TRIGGER_MTD is not set
# CONFIG_LEDS_TRIGGER_HEARTBEAT is not set
# CONFIG_LEDS_TRIGGER_BACKLIGHT is not set
# CONFIG_LEDS_TRIGGER_CPU is not set
# CONFIG_LEDS_TRIGGER_DEFAULT_ON is not set

#
# iptables trigger is under Netfilter config (LED target)
#
# CONFIG_LEDS_TRIGGER_TRANSIENT is not set
# CONFIG_LEDS_TRIGGER_CAMERA is not set
# CONFIG_LEDS_TRIGGER_PANIC is not set
CONFIG_ACCESSIBILITY=y
# CONFIG_A11Y_BRAILLE_CONSOLE is not set
CONFIG_EDAC_ATOMIC_SCRUB=y
CONFIG_EDAC_SUPPORT=y
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
CONFIG_RTC_HCTOSYS=y
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
CONFIG_RTC_SYSTOHC=y
CONFIG_RTC_SYSTOHC_DEVICE="rtc0"
# CONFIG_RTC_DEBUG is not set

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=y
# CONFIG_RTC_INTF_PROC is not set
CONFIG_RTC_INTF_DEV=y
# CONFIG_RTC_INTF_DEV_UIE_EMUL is not set
CONFIG_RTC_DRV_TEST=y

#
# I2C RTC drivers
#
CONFIG_RTC_DRV_88PM860X=y
# CONFIG_RTC_DRV_88PM80X is not set
# CONFIG_RTC_DRV_ABB5ZES3 is not set
CONFIG_RTC_DRV_ABX80X=y
# CONFIG_RTC_DRV_DS1307 is not set
CONFIG_RTC_DRV_DS1374=y
# CONFIG_RTC_DRV_DS1374_WDT is not set
CONFIG_RTC_DRV_DS1672=y
# CONFIG_RTC_DRV_HYM8563 is not set
CONFIG_RTC_DRV_MAX6900=y
CONFIG_RTC_DRV_MAX8907=y
CONFIG_RTC_DRV_MAX8925=y
CONFIG_RTC_DRV_MAX8998=y
CONFIG_RTC_DRV_MAX77686=y
# CONFIG_RTC_DRV_RS5C372 is not set
CONFIG_RTC_DRV_ISL1208=y
# CONFIG_RTC_DRV_ISL12022 is not set
CONFIG_RTC_DRV_ISL12057=y
CONFIG_RTC_DRV_X1205=y
# CONFIG_RTC_DRV_PCF8523 is not set
# CONFIG_RTC_DRV_PCF85063 is not set
CONFIG_RTC_DRV_PCF8563=y
CONFIG_RTC_DRV_PCF8583=y
CONFIG_RTC_DRV_M41T80=y
CONFIG_RTC_DRV_M41T80_WDT=y
# CONFIG_RTC_DRV_BQ32K is not set
CONFIG_RTC_DRV_PALMAS=y
# CONFIG_RTC_DRV_RC5T583 is not set
CONFIG_RTC_DRV_S35390A=y
# CONFIG_RTC_DRV_FM3130 is not set
CONFIG_RTC_DRV_RX8010=y
# CONFIG_RTC_DRV_RX8581 is not set
CONFIG_RTC_DRV_RX8025=y
# CONFIG_RTC_DRV_EM3027 is not set
# CONFIG_RTC_DRV_RV8803 is not set

#
# SPI RTC drivers
#
CONFIG_RTC_DRV_M41T93=y
# CONFIG_RTC_DRV_M41T94 is not set
CONFIG_RTC_DRV_DS1302=y
CONFIG_RTC_DRV_DS1305=y
CONFIG_RTC_DRV_DS1343=y
# CONFIG_RTC_DRV_DS1347 is not set
# CONFIG_RTC_DRV_DS1390 is not set
# CONFIG_RTC_DRV_R9701 is not set
CONFIG_RTC_DRV_RX4581=y
CONFIG_RTC_DRV_RX6110=y
CONFIG_RTC_DRV_RS5C348=y
CONFIG_RTC_DRV_MAX6902=y
CONFIG_RTC_DRV_PCF2123=y
CONFIG_RTC_DRV_MCP795=y
CONFIG_RTC_I2C_AND_SPI=y

#
# SPI and I2C RTC drivers
#
CONFIG_RTC_DRV_DS3232=y
CONFIG_RTC_DRV_PCF2127=y
# CONFIG_RTC_DRV_RV3029C2 is not set

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
CONFIG_RTC_DRV_DS1286=y
# CONFIG_RTC_DRV_DS1511 is not set
CONFIG_RTC_DRV_DS1553=y
CONFIG_RTC_DRV_DS1685_FAMILY=y
# CONFIG_RTC_DRV_DS1685 is not set
CONFIG_RTC_DRV_DS1689=y
# CONFIG_RTC_DRV_DS17285 is not set
# CONFIG_RTC_DRV_DS17485 is not set
# CONFIG_RTC_DRV_DS17885 is not set
# CONFIG_RTC_DS1685_PROC_REGS is not set
CONFIG_RTC_DS1685_SYSFS_REGS=y
# CONFIG_RTC_DRV_DS1742 is not set
CONFIG_RTC_DRV_DS2404=y
CONFIG_RTC_DRV_DA9052=y
CONFIG_RTC_DRV_DA9063=y
# CONFIG_RTC_DRV_STK17TA8 is not set
CONFIG_RTC_DRV_M48T86=y
CONFIG_RTC_DRV_M48T35=y
CONFIG_RTC_DRV_M48T59=y
CONFIG_RTC_DRV_MSM6242=y
CONFIG_RTC_DRV_BQ4802=y
CONFIG_RTC_DRV_RP5C01=y
CONFIG_RTC_DRV_V3020=y
CONFIG_RTC_DRV_PCF50633=y
CONFIG_RTC_DRV_ZYNQMP=y

#
# on-CPU RTC drivers
#
CONFIG_RTC_DRV_MC13XXX=y
CONFIG_RTC_DRV_SNVS=y
# CONFIG_RTC_DRV_MT6397 is not set

#
# HID Sensor RTC drivers
#
# CONFIG_RTC_DRV_HID_SENSOR_TIME is not set
# CONFIG_DMADEVICES is not set

#
# DMABUF options
#
CONFIG_SYNC_FILE=y
CONFIG_AUXDISPLAY=y
# CONFIG_KS0108 is not set
# CONFIG_UIO is not set
# CONFIG_VIRT_DRIVERS is not set
CONFIG_VIRTIO=y

#
# Virtio drivers
#
CONFIG_VIRTIO_PCI=y
# CONFIG_VIRTIO_PCI_LEGACY is not set
# CONFIG_VIRTIO_BALLOON is not set
# CONFIG_VIRTIO_INPUT is not set
CONFIG_VIRTIO_MMIO=y
# CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES is not set

#
# Microsoft Hyper-V guest support
#
CONFIG_HYPERV=y
CONFIG_HYPERV_BALLOON=y

#
# Xen driver support
#
CONFIG_XEN_BALLOON=y
# CONFIG_XEN_BALLOON_MEMORY_HOTPLUG is not set
# CONFIG_XEN_SCRUB_PAGES is not set
CONFIG_XEN_DEV_EVTCHN=y
CONFIG_XEN_BACKEND=y
# CONFIG_XENFS is not set
# CONFIG_XEN_SYS_HYPERVISOR is not set
CONFIG_XEN_XENBUS_FRONTEND=y
CONFIG_XEN_GNTDEV=y
CONFIG_XEN_GRANT_DEV_ALLOC=y
CONFIG_SWIOTLB_XEN=y
CONFIG_XEN_TMEM=y
CONFIG_XEN_PCIDEV_BACKEND=y
CONFIG_XEN_PRIVCMD=y
CONFIG_XEN_ACPI_PROCESSOR=y
CONFIG_XEN_HAVE_PVMMU=y
CONFIG_XEN_EFI=y
CONFIG_XEN_AUTO_XLATE=y
CONFIG_XEN_ACPI=y
CONFIG_XEN_HAVE_VPMU=y
CONFIG_STAGING=y
# CONFIG_SLICOSS is not set

#
# Speakup console speech
#
# CONFIG_SPEAKUP is not set
CONFIG_STAGING_MEDIA=y
CONFIG_DVB_CXD2099=y
CONFIG_DVB_MN88472=y
CONFIG_VIDEO_TW686X_KH=y

#
# Android
#
# CONFIG_ASHMEM is not set
# CONFIG_ANDROID_LOW_MEMORY_KILLER is not set
CONFIG_SYNC=y
# CONFIG_SW_SYNC is not set
CONFIG_ION=y
CONFIG_ION_TEST=y
# CONFIG_ION_DUMMY is not set
# CONFIG_STAGING_BOARD is not set
CONFIG_FIREWIRE_SERIAL=y
CONFIG_FWTTY_MAX_TOTAL_PORTS=64
CONFIG_FWTTY_MAX_CARD_PORTS=32
CONFIG_MTD_SPINAND_MT29F=y
CONFIG_MTD_SPINAND_ONDIEECC=y
CONFIG_DGNC=y
CONFIG_GS_FPGABOOT=y
CONFIG_CRYPTO_SKEIN=y
CONFIG_UNISYSSPAR=y
CONFIG_UNISYS_VISORBUS=y
# CONFIG_UNISYS_VISORNIC is not set
CONFIG_COMMON_CLK_XLNX_CLKWZRD=y
CONFIG_MOST=y
CONFIG_MOSTCORE=y
# CONFIG_AIM_CDEV is not set
# CONFIG_AIM_NETWORK is not set
CONFIG_AIM_SOUND=y
CONFIG_AIM_V4L2=y
CONFIG_HDM_I2C=y
# CONFIG_HDM_USB is not set
# CONFIG_X86_PLATFORM_DEVICES is not set
CONFIG_CHROME_PLATFORMS=y
CONFIG_CHROMEOS_LAPTOP=y
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
# CONFIG_COMMON_CLK_MAX77686 is not set
# CONFIG_COMMON_CLK_MAX77802 is not set
# CONFIG_COMMON_CLK_SI5351 is not set
# CONFIG_COMMON_CLK_SI514 is not set
CONFIG_COMMON_CLK_SI570=y
# CONFIG_COMMON_CLK_CDCE706 is not set
CONFIG_COMMON_CLK_CDCE925=y
CONFIG_COMMON_CLK_CS2000_CP=y
# CONFIG_CLK_TWL6040 is not set
# CONFIG_COMMON_CLK_NXP is not set
CONFIG_COMMON_CLK_PALMAS=y
# CONFIG_COMMON_CLK_PWM is not set
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
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
# CONFIG_ATMEL_PIT is not set
# CONFIG_SH_TIMER_CMT is not set
# CONFIG_SH_TIMER_MTU2 is not set
# CONFIG_SH_TIMER_TMU is not set
# CONFIG_EM_TIMER_STI is not set
CONFIG_MAILBOX=y
# CONFIG_PCC is not set
CONFIG_ALTERA_MBOX=y
# CONFIG_MAILBOX_TEST is not set
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
CONFIG_SOC_TI=y
# CONFIG_PM_DEVFREQ is not set
# CONFIG_EXTCON is not set
# CONFIG_MEMORY is not set
# CONFIG_IIO is not set
CONFIG_NTB=y
CONFIG_NTB_AMD=y
CONFIG_NTB_INTEL=y
# CONFIG_NTB_PINGPONG is not set
CONFIG_NTB_TOOL=y
CONFIG_NTB_PERF=y
# CONFIG_NTB_TRANSPORT is not set
# CONFIG_VME_BUS is not set
CONFIG_PWM=y
CONFIG_PWM_SYSFS=y
CONFIG_PWM_ATMEL_HLCDC_PWM=y
CONFIG_PWM_FSL_FTM=y
CONFIG_PWM_LP3943=y
CONFIG_PWM_LPSS=y
CONFIG_PWM_LPSS_PCI=y
# CONFIG_PWM_LPSS_PLATFORM is not set
CONFIG_PWM_PCA9685=y
CONFIG_IRQCHIP=y
CONFIG_ARM_GIC_MAX_NR=1
# CONFIG_IPACK_BUS is not set
CONFIG_RESET_CONTROLLER=y
CONFIG_FMC=y
CONFIG_FMC_FAKEDEV=y
CONFIG_FMC_TRIVIAL=y
CONFIG_FMC_WRITE_EEPROM=y
CONFIG_FMC_CHARDEV=y

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
CONFIG_PHY_PXA_28NM_HSIC=y
CONFIG_PHY_PXA_28NM_USB2=y
CONFIG_BCM_KONA_USB2_PHY=y
# CONFIG_PHY_TUSB1210 is not set
CONFIG_POWERCAP=y
CONFIG_INTEL_RAPL=y
# CONFIG_MCB is not set

#
# Performance monitor support
#
CONFIG_RAS=y
CONFIG_THUNDERBOLT=y

#
# Android
#
CONFIG_ANDROID=y
CONFIG_ANDROID_BINDER_IPC=y
CONFIG_LIBNVDIMM=y
# CONFIG_BLK_DEV_PMEM is not set
CONFIG_ND_BLK=y
# CONFIG_BTT is not set
CONFIG_DEV_DAX=y
CONFIG_NVMEM=y
CONFIG_STM=y
CONFIG_STM_DUMMY=y
CONFIG_STM_SOURCE_CONSOLE=y
CONFIG_STM_SOURCE_HEARTBEAT=y
# CONFIG_INTEL_TH is not set

#
# FPGA Configuration Support
#
CONFIG_FPGA=y
CONFIG_FPGA_MGR_ZYNQ_FPGA=y

#
# Firmware Drivers
#
# CONFIG_EDD is not set
CONFIG_FIRMWARE_MEMMAP=y
# CONFIG_DELL_RBU is not set
CONFIG_DCDBAS=y
CONFIG_DMIID=y
# CONFIG_DMI_SYSFS is not set
CONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK=y
CONFIG_ISCSI_IBFT_FIND=y
# CONFIG_FW_CFG_SYSFS is not set
CONFIG_GOOGLE_FIRMWARE=y

#
# Google Firmware Drivers
#
CONFIG_GOOGLE_SMI=y
# CONFIG_GOOGLE_MEMCONSOLE is not set

#
# EFI (Extensible Firmware Interface) Support
#
CONFIG_EFI_VARS=y
CONFIG_EFI_ESRT=y
# CONFIG_EFI_VARS_PSTORE is not set
CONFIG_EFI_RUNTIME_MAP=y
CONFIG_EFI_FAKE_MEMMAP=y
CONFIG_EFI_MAX_FAKE_MEM=8
CONFIG_EFI_RUNTIME_WRAPPERS=y
CONFIG_EFI_BOOTLOADER_CONTROL=y
CONFIG_EFI_CAPSULE_LOADER=y
CONFIG_UEFI_CPER=y

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_EXT2_FS=y
# CONFIG_EXT2_FS_XATTR is not set
CONFIG_EXT3_FS=y
CONFIG_EXT3_FS_POSIX_ACL=y
# CONFIG_EXT3_FS_SECURITY is not set
CONFIG_EXT4_FS=y
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
# CONFIG_EXT4_ENCRYPTION is not set
# CONFIG_EXT4_DEBUG is not set
CONFIG_JBD2=y
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=y
# CONFIG_REISERFS_FS is not set
# CONFIG_JFS_FS is not set
# CONFIG_XFS_FS is not set
# CONFIG_GFS2_FS is not set
# CONFIG_OCFS2_FS is not set
CONFIG_BTRFS_FS=y
# CONFIG_BTRFS_FS_POSIX_ACL is not set
# CONFIG_BTRFS_FS_CHECK_INTEGRITY is not set
# CONFIG_BTRFS_FS_RUN_SANITY_TESTS is not set
CONFIG_BTRFS_DEBUG=y
CONFIG_BTRFS_ASSERT=y
CONFIG_NILFS2_FS=y
CONFIG_F2FS_FS=y
# CONFIG_F2FS_STAT_FS is not set
# CONFIG_F2FS_FS_XATTR is not set
CONFIG_F2FS_CHECK_FS=y
CONFIG_F2FS_FAULT_INJECTION=y
# CONFIG_FS_DAX is not set
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_FILE_LOCKING=y
CONFIG_MANDATORY_FILE_LOCKING=y
# CONFIG_FS_ENCRYPTION is not set
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
CONFIG_FANOTIFY=y
CONFIG_FANOTIFY_ACCESS_PERMISSIONS=y
# CONFIG_QUOTA is not set
# CONFIG_QUOTACTL is not set
# CONFIG_AUTOFS4_FS is not set
# CONFIG_FUSE_FS is not set
CONFIG_OVERLAY_FS=y

#
# Caches
#
CONFIG_FSCACHE=y
# CONFIG_FSCACHE_STATS is not set
CONFIG_FSCACHE_HISTOGRAM=y
# CONFIG_FSCACHE_DEBUG is not set
# CONFIG_FSCACHE_OBJECT_LIST is not set
CONFIG_CACHEFILES=y
# CONFIG_CACHEFILES_DEBUG is not set
CONFIG_CACHEFILES_HISTOGRAM=y

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=y
CONFIG_JOLIET=y
CONFIG_ZISOFS=y
# CONFIG_UDF_FS is not set

#
# DOS/FAT/NT Filesystems
#
# CONFIG_MSDOS_FS is not set
# CONFIG_VFAT_FS is not set
CONFIG_NTFS_FS=y
CONFIG_NTFS_DEBUG=y
# CONFIG_NTFS_RW is not set

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
# CONFIG_TMPFS_POSIX_ACL is not set
# CONFIG_TMPFS_XATTR is not set
# CONFIG_HUGETLBFS is not set
# CONFIG_HUGETLB_PAGE is not set
CONFIG_CONFIGFS_FS=y
# CONFIG_EFIVAR_FS is not set
CONFIG_MISC_FILESYSTEMS=y
CONFIG_ORANGEFS_FS=y
CONFIG_ADFS_FS=y
CONFIG_ADFS_FS_RW=y
CONFIG_AFFS_FS=y
CONFIG_HFS_FS=y
CONFIG_HFSPLUS_FS=y
# CONFIG_HFSPLUS_FS_POSIX_ACL is not set
CONFIG_BEFS_FS=y
# CONFIG_BEFS_DEBUG is not set
CONFIG_BFS_FS=y
CONFIG_EFS_FS=y
# CONFIG_JFFS2_FS is not set
# CONFIG_LOGFS is not set
CONFIG_CRAMFS=y
CONFIG_SQUASHFS=y
CONFIG_SQUASHFS_FILE_CACHE=y
# CONFIG_SQUASHFS_FILE_DIRECT is not set
CONFIG_SQUASHFS_DECOMP_SINGLE=y
# CONFIG_SQUASHFS_DECOMP_MULTI is not set
# CONFIG_SQUASHFS_DECOMP_MULTI_PERCPU is not set
# CONFIG_SQUASHFS_XATTR is not set
CONFIG_SQUASHFS_ZLIB=y
# CONFIG_SQUASHFS_LZ4 is not set
# CONFIG_SQUASHFS_LZO is not set
CONFIG_SQUASHFS_XZ=y
CONFIG_SQUASHFS_4K_DEVBLK_SIZE=y
CONFIG_SQUASHFS_EMBEDDED=y
CONFIG_SQUASHFS_FRAGMENT_CACHE_SIZE=3
CONFIG_VXFS_FS=y
# CONFIG_MINIX_FS is not set
CONFIG_OMFS_FS=y
CONFIG_HPFS_FS=y
# CONFIG_QNX4FS_FS is not set
# CONFIG_QNX6FS_FS is not set
CONFIG_ROMFS_FS=y
CONFIG_ROMFS_BACKED_BY_BLOCK=y
# CONFIG_ROMFS_BACKED_BY_MTD is not set
# CONFIG_ROMFS_BACKED_BY_BOTH is not set
CONFIG_ROMFS_ON_BLOCK=y
CONFIG_PSTORE=y
CONFIG_PSTORE_CONSOLE=y
# CONFIG_PSTORE_PMSG is not set
CONFIG_PSTORE_RAM=y
# CONFIG_SYSV_FS is not set
CONFIG_UFS_FS=y
CONFIG_UFS_FS_WRITE=y
CONFIG_UFS_DEBUG=y
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
# CONFIG_NLS_CODEPAGE_437 is not set
# CONFIG_NLS_CODEPAGE_737 is not set
# CONFIG_NLS_CODEPAGE_775 is not set
CONFIG_NLS_CODEPAGE_850=y
CONFIG_NLS_CODEPAGE_852=y
CONFIG_NLS_CODEPAGE_855=y
# CONFIG_NLS_CODEPAGE_857 is not set
CONFIG_NLS_CODEPAGE_860=y
CONFIG_NLS_CODEPAGE_861=y
CONFIG_NLS_CODEPAGE_862=y
CONFIG_NLS_CODEPAGE_863=y
# CONFIG_NLS_CODEPAGE_864 is not set
# CONFIG_NLS_CODEPAGE_865 is not set
# CONFIG_NLS_CODEPAGE_866 is not set
# CONFIG_NLS_CODEPAGE_869 is not set
# CONFIG_NLS_CODEPAGE_936 is not set
# CONFIG_NLS_CODEPAGE_950 is not set
# CONFIG_NLS_CODEPAGE_932 is not set
CONFIG_NLS_CODEPAGE_949=y
# CONFIG_NLS_CODEPAGE_874 is not set
CONFIG_NLS_ISO8859_8=y
CONFIG_NLS_CODEPAGE_1250=y
CONFIG_NLS_CODEPAGE_1251=y
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=y
CONFIG_NLS_ISO8859_2=y
CONFIG_NLS_ISO8859_3=y
CONFIG_NLS_ISO8859_4=y
CONFIG_NLS_ISO8859_5=y
CONFIG_NLS_ISO8859_6=y
CONFIG_NLS_ISO8859_7=y
CONFIG_NLS_ISO8859_9=y
# CONFIG_NLS_ISO8859_13 is not set
CONFIG_NLS_ISO8859_14=y
# CONFIG_NLS_ISO8859_15 is not set
CONFIG_NLS_KOI8_R=y
# CONFIG_NLS_KOI8_U is not set
CONFIG_NLS_MAC_ROMAN=y
CONFIG_NLS_MAC_CELTIC=y
CONFIG_NLS_MAC_CENTEURO=y
# CONFIG_NLS_MAC_CROATIAN is not set
CONFIG_NLS_MAC_CYRILLIC=y
# CONFIG_NLS_MAC_GAELIC is not set
CONFIG_NLS_MAC_GREEK=y
CONFIG_NLS_MAC_ICELAND=y
CONFIG_NLS_MAC_INUIT=y
CONFIG_NLS_MAC_ROMANIAN=y
CONFIG_NLS_MAC_TURKISH=y
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
CONFIG_BOOT_PRINTK_DELAY=y
# CONFIG_DYNAMIC_DEBUG is not set

#
# Compile-time checks and compiler options
#
# CONFIG_DEBUG_INFO is not set
# CONFIG_ENABLE_WARN_DEPRECATED is not set
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=2048
# CONFIG_STRIP_ASM_SYMS is not set
CONFIG_READABLE_ASM=y
# CONFIG_UNUSED_SYMBOLS is not set
# CONFIG_PAGE_OWNER is not set
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
# CONFIG_DEBUG_SECTION_MISMATCH is not set
# CONFIG_SECTION_MISMATCH_WARN_ONLY is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
CONFIG_STACK_VALIDATION=y
CONFIG_DEBUG_FORCE_WEAK_PER_CPU=y
# CONFIG_MAGIC_SYSRQ is not set
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_PAGE_EXTENSION=y
# CONFIG_DEBUG_PAGEALLOC is not set
# CONFIG_PAGE_POISONING is not set
CONFIG_DEBUG_OBJECTS=y
# CONFIG_DEBUG_OBJECTS_SELFTEST is not set
# CONFIG_DEBUG_OBJECTS_FREE is not set
CONFIG_DEBUG_OBJECTS_TIMERS=y
CONFIG_DEBUG_OBJECTS_WORK=y
CONFIG_DEBUG_OBJECTS_RCU_HEAD=y
# CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER is not set
CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
# CONFIG_SLUB_DEBUG_ON is not set
# CONFIG_SLUB_STATS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_STACK_USAGE=y
CONFIG_DEBUG_VM=y
CONFIG_DEBUG_VM_VMACACHE=y
# CONFIG_DEBUG_VM_RB is not set
CONFIG_DEBUG_VM_PGFLAGS=y
# CONFIG_DEBUG_VIRTUAL is not set
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_MEMORY_NOTIFIER_ERROR_INJECT=y
CONFIG_DEBUG_PER_CPU_MAPS=y
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
# CONFIG_DEBUG_STACKOVERFLOW is not set
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_KMEMCHECK is not set
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
# CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=0
CONFIG_DETECT_HUNG_TASK=y
CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=120
CONFIG_BOOTPARAM_HUNG_TASK_PANIC=y
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=1
CONFIG_WQ_WATCHDOG=y
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
CONFIG_SCHED_INFO=y
CONFIG_SCHEDSTATS=y
CONFIG_SCHED_STACK_END_CHECK=y
CONFIG_DEBUG_TIMEKEEPING=y
# CONFIG_TIMER_STATS is not set
CONFIG_DEBUG_PREEMPT=y

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
# CONFIG_DEBUG_RT_MUTEXES is not set
# CONFIG_DEBUG_SPINLOCK is not set
CONFIG_DEBUG_MUTEXES=y
# CONFIG_DEBUG_WW_MUTEX_SLOWPATH is not set
# CONFIG_DEBUG_LOCK_ALLOC is not set
# CONFIG_PROVE_LOCKING is not set
# CONFIG_LOCK_STAT is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_LOCK_TORTURE_TEST=y
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
# CONFIG_DEBUG_KOBJECT_RELEASE is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_LIST=y
# CONFIG_DEBUG_PI_LIST is not set
CONFIG_DEBUG_SG=y
CONFIG_DEBUG_NOTIFIERS=y
CONFIG_DEBUG_CREDENTIALS=y

#
# RCU Debugging
#
# CONFIG_PROVE_RCU is not set
CONFIG_SPARSE_RCU_POINTER=y
CONFIG_TORTURE_TEST=y
CONFIG_RCU_PERF_TEST=y
CONFIG_RCU_PERF_TEST_RUNNABLE=y
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=21
CONFIG_RCU_TRACE=y
# CONFIG_RCU_EQS_DEBUG is not set
# CONFIG_DEBUG_WQ_FORCE_RR_CPU is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
CONFIG_CPU_HOTPLUG_STATE_CONTROL=y
CONFIG_NOTIFIER_ERROR_INJECTION=y
# CONFIG_CPU_NOTIFIER_ERROR_INJECT is not set
CONFIG_PM_NOTIFIER_ERROR_INJECT=y
# CONFIG_NETDEV_NOTIFIER_ERROR_INJECT is not set
CONFIG_FAULT_INJECTION=y
CONFIG_FAILSLAB=y
# CONFIG_FAIL_PAGE_ALLOC is not set
# CONFIG_FAIL_MAKE_REQUEST is not set
CONFIG_FAIL_IO_TIMEOUT=y
# CONFIG_FAIL_FUTEX is not set
# CONFIG_FAULT_INJECTION_DEBUG_FS is not set
CONFIG_LATENCYTOP=y
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
CONFIG_LKDTM=y
CONFIG_TEST_LIST_SORT=y
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_RBTREE_TEST is not set
CONFIG_ATOMIC64_SELFTEST=y
CONFIG_TEST_HEXDUMP=y
CONFIG_TEST_STRING_HELPERS=y
CONFIG_TEST_KSTRTOX=y
# CONFIG_TEST_PRINTF is not set
# CONFIG_TEST_BITMAP is not set
CONFIG_TEST_UUID=y
# CONFIG_TEST_RHASHTABLE is not set
CONFIG_TEST_HASH=y
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
CONFIG_BUILD_DOCSRC=y
# CONFIG_DMA_API_DEBUG is not set
CONFIG_TEST_FIRMWARE=y
CONFIG_TEST_UDELAY=y
CONFIG_MEMTEST=y
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
# CONFIG_UBSAN is not set
CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
# CONFIG_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
# CONFIG_EARLY_PRINTK_EFI is not set
CONFIG_X86_PTDUMP_CORE=y
# CONFIG_X86_PTDUMP is not set
CONFIG_EFI_PGT_DUMP=y
# CONFIG_DEBUG_RODATA_TEST is not set
# CONFIG_DEBUG_WX is not set
CONFIG_DOUBLEFAULT=y
# CONFIG_DEBUG_TLBFLUSH is not set
# CONFIG_IOMMU_DEBUG is not set
# CONFIG_IOMMU_STRESS is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
# CONFIG_IO_DELAY_0XED is not set
CONFIG_IO_DELAY_UDELAY=y
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=2
CONFIG_DEBUG_BOOT_PARAMS=y
# CONFIG_CPA_DEBUG is not set
# CONFIG_OPTIMIZE_INLINING is not set
# CONFIG_DEBUG_ENTRY is not set
CONFIG_DEBUG_NMI_SELFTEST=y
CONFIG_X86_DEBUG_FPU=y
CONFIG_PUNIT_ATOM_DEBUG=y

#
# Security options
#
# CONFIG_KEYS is not set
# CONFIG_SECURITY_DMESG_RESTRICT is not set
CONFIG_SECURITY=y
CONFIG_SECURITYFS=y
# CONFIG_SECURITY_NETWORK is not set
# CONFIG_SECURITY_PATH is not set
# CONFIG_SECURITY_TOMOYO is not set
# CONFIG_SECURITY_APPARMOR is not set
# CONFIG_SECURITY_LOADPIN is not set
# CONFIG_SECURITY_YAMA is not set
CONFIG_INTEGRITY=y
CONFIG_IMA=y
CONFIG_IMA_MEASURE_PCR_IDX=10
CONFIG_IMA_TEMPLATE=y
# CONFIG_IMA_NG_TEMPLATE is not set
# CONFIG_IMA_SIG_TEMPLATE is not set
CONFIG_IMA_DEFAULT_TEMPLATE="ima"
CONFIG_IMA_DEFAULT_HASH_SHA1=y
CONFIG_IMA_DEFAULT_HASH="sha1"
# CONFIG_IMA_WRITE_POLICY is not set
CONFIG_IMA_READ_POLICY=y
# CONFIG_IMA_APPRAISE is not set
# CONFIG_EVM is not set
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
# CONFIG_CRYPTO_RSA is not set
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_NULL2=y
CONFIG_CRYPTO_PCRYPT=y
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
# CONFIG_CRYPTO_CHACHA20POLY1305 is not set
CONFIG_CRYPTO_SEQIV=y
CONFIG_CRYPTO_ECHAINIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=y
# CONFIG_CRYPTO_CTS is not set
# CONFIG_CRYPTO_ECB is not set
CONFIG_CRYPTO_LRW=y
CONFIG_CRYPTO_PCBC=y
CONFIG_CRYPTO_XTS=y
# CONFIG_CRYPTO_KEYWRAP is not set

#
# Hash modes
#
# CONFIG_CRYPTO_CMAC is not set
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=y
# CONFIG_CRYPTO_VMAC is not set

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
# CONFIG_CRYPTO_CRC32C_INTEL is not set
CONFIG_CRYPTO_CRC32=y
# CONFIG_CRYPTO_CRC32_PCLMUL is not set
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_CRCT10DIF_PCLMUL=y
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_POLY1305=y
CONFIG_CRYPTO_POLY1305_X86_64=y
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
CONFIG_CRYPTO_RMD128=y
CONFIG_CRYPTO_RMD160=y
CONFIG_CRYPTO_RMD256=y
# CONFIG_CRYPTO_RMD320 is not set
CONFIG_CRYPTO_SHA1=y
# CONFIG_CRYPTO_SHA1_SSSE3 is not set
CONFIG_CRYPTO_SHA256_SSSE3=y
CONFIG_CRYPTO_SHA512_SSSE3=y
CONFIG_CRYPTO_SHA1_MB=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_TGR192=y
# CONFIG_CRYPTO_WP512 is not set
CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
# CONFIG_CRYPTO_AES_X86_64 is not set
# CONFIG_CRYPTO_AES_NI_INTEL is not set
# CONFIG_CRYPTO_ANUBIS is not set
CONFIG_CRYPTO_ARC4=y
CONFIG_CRYPTO_BLOWFISH=y
CONFIG_CRYPTO_BLOWFISH_COMMON=y
CONFIG_CRYPTO_BLOWFISH_X86_64=y
CONFIG_CRYPTO_CAMELLIA=y
CONFIG_CRYPTO_CAMELLIA_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64=y
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST5_AVX_X86_64=y
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_CAST6_AVX_X86_64=y
CONFIG_CRYPTO_DES=y
# CONFIG_CRYPTO_DES3_EDE_X86_64 is not set
CONFIG_CRYPTO_FCRYPT=y
CONFIG_CRYPTO_KHAZAD=y
# CONFIG_CRYPTO_SALSA20 is not set
CONFIG_CRYPTO_SALSA20_X86_64=y
CONFIG_CRYPTO_CHACHA20=y
CONFIG_CRYPTO_CHACHA20_X86_64=y
# CONFIG_CRYPTO_SEED is not set
CONFIG_CRYPTO_SERPENT=y
# CONFIG_CRYPTO_SERPENT_SSE2_X86_64 is not set
CONFIG_CRYPTO_SERPENT_AVX_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX2_X86_64=y
CONFIG_CRYPTO_TEA=y
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y
CONFIG_CRYPTO_TWOFISH_AVX_X86_64=y

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
CONFIG_CRYPTO_LZO=y
CONFIG_CRYPTO_842=y
CONFIG_CRYPTO_LZ4=y
CONFIG_CRYPTO_LZ4HC=y

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=y
CONFIG_CRYPTO_DRBG_MENU=y
CONFIG_CRYPTO_DRBG_HMAC=y
CONFIG_CRYPTO_DRBG_HASH=y
CONFIG_CRYPTO_DRBG_CTR=y
CONFIG_CRYPTO_DRBG=y
CONFIG_CRYPTO_JITTERENTROPY=y
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
# CONFIG_CRYPTO_USER_API_RNG is not set
# CONFIG_CRYPTO_USER_API_AEAD is not set
CONFIG_CRYPTO_HASH_INFO=y
# CONFIG_CRYPTO_HW is not set

#
# Certificates for signature checking
#
CONFIG_HAVE_KVM=y
# CONFIG_VIRTUALIZATION is not set
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
# CONFIG_CRC32_SELFTEST is not set
# CONFIG_CRC32_SLICEBY8 is not set
CONFIG_CRC32_SLICEBY4=y
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
CONFIG_CRC7=y
# CONFIG_LIBCRC32C is not set
# CONFIG_CRC8 is not set
# CONFIG_AUDIT_ARCH_COMPAT_GENERIC is not set
# CONFIG_RANDOM32_SELFTEST is not set
CONFIG_842_COMPRESS=y
CONFIG_842_DECOMPRESS=y
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
CONFIG_REED_SOLOMON=y
CONFIG_REED_SOLOMON_ENC8=y
CONFIG_REED_SOLOMON_DEC8=y
CONFIG_BCH=y
CONFIG_RADIX_TREE_MULTIORDER=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_CHECK_SIGNATURE=y
CONFIG_CPUMASK_OFFSTACK=y
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
CONFIG_CORDIC=y
CONFIG_DDR=y
# CONFIG_IRQ_POLL is not set
CONFIG_LIBFDT=y
CONFIG_UCS2_STRING=y
# CONFIG_SG_SPLIT is not set
# CONFIG_SG_POOL is not set
CONFIG_ARCH_HAS_SG_CHAIN=y
CONFIG_ARCH_HAS_PMEM_API=y
CONFIG_ARCH_HAS_MMIO_FLUSH=y

--=_576c7510.zgj2Zxs266gQ+rvSsgnlrgnW2s7z0Q4/wE6R0I7zQHBVWTR8--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
