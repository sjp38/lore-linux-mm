Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id F2A4A6B0010
	for <linux-mm@kvack.org>; Sat,  5 May 2018 21:40:21 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y12so12051386pfe.8
        for <linux-mm@kvack.org>; Sat, 05 May 2018 18:40:21 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 64si19050809pfl.309.2018.05.05.18.40.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 May 2018 18:40:19 -0700 (PDT)
Date: Sun, 06 May 2018 09:39:40 +0800
From: kernel test robot <lkp@intel.com>
Subject: 27e2ce5dba ("mm: access to uninitialized struct page"): BUG:
 kernel reboot-without-warning in test stage
Message-ID: <5aee5cdc.X6ey7TYTGWMNVGn2%lkp@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=_5aee5cdc.zEbxaqK9/iCmq7DlX0jmOWaUbrRh3+k4ZSE81n3dLGkkpD7B"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: LKP <lkp@01.org>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Steven Rostedt (VMware)" <rostedt@goodmis.org>, Johannes Weiner <hannes@cmpxchg.org>, wfg@linux.intel.com

This is a multi-part message in MIME format.

--=_5aee5cdc.zEbxaqK9/iCmq7DlX0jmOWaUbrRh3+k4ZSE81n3dLGkkpD7B
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Greetings,

0day kernel testing robot got the below dmesg and the first bad commit is

git://git.cmpxchg.org/linux-mmotm.git master

commit 27e2ce5dba4c30db031744c8140675d03d2ae7aa
Author:     Pavel Tatashin <pasha.tatashin@oracle.com>
AuthorDate: Thu May 3 23:02:17 2018 +0000
Commit:     Johannes Weiner <hannes@cmpxchg.org>
CommitDate: Thu May 3 23:02:17 2018 +0000

    mm: access to uninitialized struct page
    
    The following two bugs were reported by Fengguang Wu:
    
    kernel reboot-without-warning in early-boot stage, last printk: early
    console in setup code
    
    http://lkml.kernel.org/r/20180418135300.inazvpxjxowogyge@wfg-t540p.sh.intel.com
    
    And, also:
    [per_cpu_ptr_to_phys] PANIC: early exception 0x0d
    IP 10:ffffffffa892f15f error 0 cr2 0xffff88001fbff000
    
    http://lkml.kernel.org/r/20180419013128.iurzouiqxvcnpbvz@wfg-t540p.sh.intel.com
    
    Both of the problems are due to accessing uninitialized struct page from
    trap_init().  We must first do mm_init() in order to initialize allocated
    struct pages, and than we can access fields of any struct page that
    belongs to memory that's been allocated.
    
    Below is explanation of the root cause.
    
    The issue arises in this stack:
    
    start_kernel()
     trap_init()
      setup_cpu_entry_areas()
       setup_cpu_entry_area(cpu)
        get_cpu_gdt_paddr(cpu)
         per_cpu_ptr_to_phys(addr)
          pcpu_addr_to_page(addr)
           virt_to_page(addr)
            pfn_to_page(__pa(addr) >> PAGE_SHIFT)
    
    The returned "struct page" is sometimes uninitialized, and thus failing
    later when used.  It turns out sometimes is because it depends on KASLR.
    
    When boot is failing we have this when  pfn_to_page() is called:
    kasrl: 0x000000000d600000
     addr: ffffffff83e0d000
        pa: 1040d000
       pfn: 1040d
    page: ffff88001f113340
    page->flags ffffffffffffffff <- Uninitialized!
    
    When boot is successful:
    kaslr: 0x000000000a800000
     addr: ffffffff83e0d000
         pa: d60d000
        pfn: d60d
     page: ffff88001f05b340
    page->flags 280000000000 <- Initialized!
    
    Here are physical addresses that BIOS provided to us:
    e820: BIOS-provided physical RAM map:
    BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
    BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
    BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
    BIOS-e820: [mem 0x0000000000100000-0x000000001ffdffff] usable
    BIOS-e820: [mem 0x000000001ffe0000-0x000000001fffffff] reserved
    BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
    BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
    
    In both cases, working and non-working the real physical address is
    the same:
    
    pa - kasrl = 0x2E0D000
    
    The only thing that is different is PFN.
    
    We initialize struct pages in four places:
    
    1. Early in boot a small set of struct pages is initialized to fill
       the first section, and lower zones.
    
    2. During mm_init() we initialize "struct pages" for all the memory
       that is allocated, i.e reserved in memblock.
    
    3. Using on-demand logic when pages are allocated after mm_init call
    
    4. After smp_init() when the rest free deferred pages are initialized.
    
    The above path happens before deferred memory is initialized, and thus it
    must be covered either by 1, 2 or 3.
    
    So, lets check what PFNs are initialized after (1).
    
    memmap_init_zone() is called for pfn ranges:
    1 - 1000, and 1000 - 1ffe0, but it quits after reaching pfn 0x10000,
    as it leaves the rest to be initialized as deferred pages.
    
    In the working scenario pfn ended up being below 1000, but in the failing
    scenario it is above.  Hence, we must initialize this page in (2).  But
    trap_init() is called before mm_init().
    
    The bug was introduced by "mm: initialize pages on demand during boot"
    because we lowered amount of pages that is initialized in the step (1).
    But, it still could happen, because the number of initialized pages was a
    guessing.
    
    The current fix moves trap_init() to be called after mm_init, but as
    alternative, we could increase pgdat->static_init_pgcnt: In
    free_area_init_node we can increase:
    
           pgdat->static_init_pgcnt = min_t(unsigned long, PAGES_PER_SECTION,
                                            pgdat->node_spanned_pages);
    
    Instead of one PAGES_PER_SECTION, set several, so the text is covered for
    all KASLR offsets.  But, this would still be guessing.  Therefore, I
    prefer the current fix.
    
    Link: http://lkml.kernel.org/r/20180426202619.2768-1-pasha.tatashin@oracle.com
    Fixes: c9e97a1997fb ("mm: initialize pages on demand during boot")
    Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
    Reviewed-by: Steven Rostedt (VMware) <rostedt@goodmis.org>
    Cc: Steven Sistare <steven.sistare@oracle.com>
    Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
    Cc: Thomas Gleixner <tglx@linutronix.de>
    Cc: Michal Hocko <mhocko@suse.com>
    Cc: Mel Gorman <mgorman@techsingularity.net>
    Cc: Ingo Molnar <mingo@kernel.org>
    Cc: Peter Zijlstra <peterz@infradead.org>
    Cc: Steven Rostedt (VMware) <rostedt@goodmis.org>
    Cc: Fengguang Wu <fengguang.wu@intel.com>
    Cc: Dennis Zhou <dennisszhou@gmail.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

7a0e68e17b  mm: sections are not offlined during memory hotremove
27e2ce5dba  mm: access to uninitialized struct page
f26843c180  pci: test for unexpectedly disabled bridges
+-------------------------------------------------+------------+------------+------------+
|                                                 | 7a0e68e17b | 27e2ce5dba | mmotm/v4.1 |
+-------------------------------------------------+------------+------------+------------+
| boot_successes                                  | 29         | 0          | 0          |
| boot_failures                                   | 11         | 15         | 21         |
| BUG:soft_lockup-CPU##stuck_for#s                | 11         |            |            |
| RIP:ftrace_likely_update                        | 2          |            |            |
| Kernel_panic-not_syncing:softlockup:hung_tasks  | 11         |            |            |
| RIP:__local_bh_enable_ip                        | 4          |            |            |
| RIP:__local_bh_disable_ip                       | 4          |            |            |
| RIP:_raw_spin_lock_bh                           | 1          |            |            |
| BUG:kernel_reboot-without-warning_in_test_stage | 0          | 15         | 21         |
+-------------------------------------------------+------------+------------+------------+

[    7.926963] VIA Graphics Integration Chipset framebuffer 2.4 initializing
[    7.927638] vmlfb: initializing
[    7.927964] no IO addresses supplied
[    7.928403] usbcore: registered new interface driver udlfb
[    7.928829] usbcore: registered new interface driver smscufx
BUG: kernel reboot-without-warning in test stage


                                                          # HH:MM RESULT GOOD BAD GOOD_BUT_DIRTY DIRTY_NOT_BAD
git bisect start fde0dff646849fa89e3a4719076b95cf79b4bf8b 6da6c0db5316275015e8cc2959f12a17584aeb64 --
git bisect  bad fd90f2f335c4e4c7ba2b0abbaf4d39f9abf4d036  # 04:49  B      0    11   24   0  Merge 'superna9999/amlogic/v4.17/ao-cec-monitor' into devel-catchup-201805060049
git bisect  bad 74e54669e872ec6e10d357dfbb7b3fed586a4076  # 05:05  B      0     6   19   0  Merge 'pinchartl-media/drm/du/next' into devel-catchup-201805060049
git bisect  bad cb455c1cfb0892769f12297c0d960fef2cdaf86b  # 05:19  B      0    11   24   0  Merge 'yhuang/fix_thp_swap' into devel-catchup-201805060049
git bisect good 248940b0466555830976ee7b03ac83e1b6f19248  # 05:48  G     11     0    2   8  0day base guard for 'devel-catchup-201805060049'
git bisect  bad 47038efa1e57bd47df8bf3a5ca43fcc650e6034d  # 06:26  B      0     4   17   0  mm/ksm: remove unused page_referenced_ksm declaration
git bisect  bad 3e86b1e8f205968b70c55d4272acef28b7d404e5  # 06:59  B      0    11   24   0  mm, memcontrol: implement memory.swap.events
git bisect  bad 9e57af3cb2757349d0a02e1e05b298651503d2d2  # 07:18  B      0    11   26   2  scripts/faddr2line: fix error when addr2line output contains discriminator
git bisect good 9d98b109b501913c8414739830995d36615de37e  # 07:39  G     11     0    1   1  z3fold: fix reclaim lock-ups
git bisect  bad 57780f28c60a16270830fd95e6171121699eb87c  # 07:48  B      0     2   15   0  mm: don't show nr_indirectly_reclaimable in /proc/vmstat
git bisect good 7a0e68e17b8aa41aa33e8c80015e36d47dde390a  # 08:11  G     11     0    4   4  mm: sections are not offlined during memory hotremove
git bisect  bad 27e2ce5dba4c30db031744c8140675d03d2ae7aa  # 08:25  B      0     3   16   0  mm: access to uninitialized struct page
# first bad commit: [27e2ce5dba4c30db031744c8140675d03d2ae7aa] mm: access to uninitialized struct page
git bisect good 7a0e68e17b8aa41aa33e8c80015e36d47dde390a  # 08:37  G     32     0    7  11  mm: sections are not offlined during memory hotremove
# extra tests with debug options
git bisect  bad 27e2ce5dba4c30db031744c8140675d03d2ae7aa  # 08:53  B      0    11   24   0  mm: access to uninitialized struct page
# extra tests on HEAD of linux-devel/devel-catchup-201805060049
git bisect  bad fde0dff646849fa89e3a4719076b95cf79b4bf8b  # 08:53  B      0    29   61   0  0day head guard for 'devel-catchup-201805060049'
# extra tests on tree/branch mmotm/master
git bisect  bad f26843c1807bca843e87bfc9e9036ede686260f8  # 09:19  B      0    11   28   4  pci: test for unexpectedly disabled bridges
# extra tests with first bad commit reverted
git bisect good 203504d2048112f180c55b79f01a81b97c1d2c7a  # 09:39  G     10     0    3   3  Revert "mm: access to uninitialized struct page"

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/lkp                          Intel Corporation

--=_5aee5cdc.zEbxaqK9/iCmq7DlX0jmOWaUbrRh3+k4ZSE81n3dLGkkpD7B
Content-Type: application/gzip
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="dmesg-yocto-lkp-hsw01-100:20180506082503:x86_64-randconfig-v0-05051634:4.17.0-rc3-00012-g27e2ce5:1.gz"

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
/wiPe/8FUn3IgmaPAAA=

--=_5aee5cdc.zEbxaqK9/iCmq7DlX0jmOWaUbrRh3+k4ZSE81n3dLGkkpD7B
Content-Type: application/gzip
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="dmesg-yocto-lkp-hsw01-10:20180506081041:x86_64-randconfig-v0-05051634:4.17.0-rc3-00011-g7a0e68e:1.gz"

H4sICMlc7loAA2RtZXNnLXlvY3RvLWxrcC1oc3cwMS0xMDoyMDE4MDUwNjA4MTA0MTp4ODZf
NjQtcmFuZGNvbmZpZy12MC0wNTA1MTYzNDo0LjE3LjAtcmMzLTAwMDExLWc3YTBlNjhlOjEA
7Fxbc9vGkn5e/4o+lYfIZ0UKgzuwxdTR1VHJshVRTrLrcrFAYCAhAgEGF0pK+cdv9wxIgQBB
kTKdp8BlgQBmvunpmb7NjXtZ/AR+muRpzCFKIOdFOcUXAX9zlaXjKLmF05MT2ONBMEjDEIoU
gij3xjF/2+/3Ib1/w5sQ/LHIPL8Y3fMs4fGbKJmWxSjwCs8F5VGZX3pga9pYrz7HPFn6ypzA
VHz+Ji0L/Lz8Sd6qT62chhkyR9XfyNJHRVp48SiP/uKNVMwnEKR0Mk3jKOEjTR1HyyUpihNQ
onGaFjyAWeRBXngZMggT7719c3X3lEe+F8PF4fD9NZQ5cev65PrwwwnebobHyKE3v0aY4YU0
b064n06mGc/F5/dRUj4Sd6+8TLw4fX8mHnkWptmE3mQ8Tn2viJDr9CVIE95/c4R00sfijoOs
fv/NZ8BL6cvqfJHQMOOImyag95nVV3qZr/WIsax3a3kKN20Oe/fjMoqD//helKVvYe/W9xe5
rL7WV2DvhI8jr3rqMfPtW/iBwfDyCoZlApfeE5igWK5hu6oGx8MbUBVmN8k5TicTLwmAGsCF
DOkfHAR8doCtosBdmdyOCi+/H029JPIHDAI+Lm/Bm+KD/Jk/5dmfIy9+8J7yEU+oWwaQ+eUU
uxvv44+RPy1H2Ggx9oRowrHPDLD/QMKLfhQm3oTnAwWmWZQU930s+H6S3w6wirLAHoM8DQvk
9D02+ZyIZBKNHrzCvwvS24F4CWk6zaufceoFIyQfheR+oCI0tmuxeKFAkI2DPjZhmo38tEyK
gU2VKPgk6MfpLfbmGY8HPMsgusU0fIQvxbu5gA2K4kkBIXOSbHoxVPYZM1SsWC3V88vZrTdA
sAn2wuyBeH0/OJDt2yt4XuQHWZn0/ix5yQ+eUr9Ie/H9tHeXPyjs4NE2R6bey7CREDqMbnsz
pacYisFMTT+IqTf1AqLPFX97PjGmnPaosTGZiXLuuFWnYtbY9jydeZ6mcdu3sccZXDMD3QoC
rjmK546jnPtFT8Lq6kF/NqHff/U2RXgu11YszexZbqNCPabAGGvj3w1qxB90Ew9HHz/ejM4v
D9+dDg6m97eyzi/wBaWlZx1sSvTBvJbd4rii11AvR33Qz+/KIkgfkoHSFC6k8SCcli4K5HSa
ZkI1/D48/PUUQu4VZcaFrmMu/PhoWxBizxVJpil2K1QwtxF2yyz/8XWwKsIOh6ffjKMjzuGv
v2+C84hyXvARWik0Yp/VLy6AYZn78/dkA3L5WjXMTpTTSovIXHNaciTG2ifxKtC8AWFBlIOt
qTB+QiHarzT7j5grCbws+BFIVXtFSwNzW1VcODr/OOyhcphFAZY1nRuS68NLmHhTt5lJJJc5
P0/4ZNlIiau3bLfCcRh+QZqoLluBOaHfBgsJDJnAsxkPtoIL27SFr4djzaqyMAzG4WuqSjn9
FtiraQt5GDbg6NWr4STaEtyL1AmT6ErDQX1xYTpQHEi6Wl2R/Jq53/ZZmBQEpi4qRaCZ/MPv
sHf6yP0SxeKk8gHJwBWos9EvcAGdvmjWaoOfn1BPzaI8zZBCSssDFy5+vVwtGNJ0N/kx50Ot
qWEw+KmTFRIr45N0VsfynrEqXq7uNjJ77OXFaBomMMDcor+gbD6OvMy/W7zW5xQ2IS5vrq+x
vqFXxgUUyAIXHrKo4L2x59+vTBxGj+S8eMktapuqCVqKAH+LOjhneK1BBDgU6Y5EujLxPf9u
VU0BjkW6sxpe1aQriZx5WSS4/zKdMPZy1OFoieWFzMvv4exs8byOKjaPMlpNi9p7zTdtzTd9
zTdjzTdzzTer8xsZlKvDGxd9XPIPykx46/BZ6Vlogn47AvjtGODTcQ//g3y+ks+/3QC0VAXx
Evtxmj3Bc8wCXgEiIV170yKbefHbL+A4xF5ho1QdTWAL7PoC6XhUQp18HGUfqt9CIq7e3Rwe
vT9dk8eq5bE2zGPX8tgb5nFqeZx1edBqnpwPLxZalKH1c6Sko9j6QtKbeQ6Pr87R2IvYtRA9
2r/j/n1eTijOicJIRledzSvzXw9PrpYN3plpHytCSJkOezNsh6OPxz8P4W0nwE3dKp2dnTLj
+FQAaAoBsAoAjn6/OpbJq7TizeKpo4AzvDUL0NVDkc3SWwXI5NsUcNKuAXptxAKmnR62Cjh5
TQ2GrQIUyWO9pXdlnsOr8+MWW5lkq2W3iJLJtyHq56vTdrs5pmy3dgEy+TYFvE/JHxSEeUFA
IwNYXMi5SNTMgi7jFG2HSF2kEC4uI6QBDNib64g5QKvQ+9mk51Og6wJGzIByN8kzUFwUJQtF
ie1TkDzxUPvQZ5FyDcQn4QsjQg762DD1ACtNYX710KK/llW60TkKYwDSk8cbmEwzFcdRHQb+
kx/zvIkgcudpmfloaGtwZHNoTCdsXMKSSyj6zPxAV7kehOF4X3yKgpiPEvxm29iuiuEw3dYg
aZX7f2kyt4UrbODJ5aHk+wqnnXzZJce4cu9WomCYsQKlGglb5Q+3UT7IAQAAPpkWTy3jns6E
EvyL6iMGuSh+AY4GGhIaDGykl4qzMkiUoGJCu1zxEV+tjFxaTFAcvpr8NTDdUUET5jyJCsot
BzkFpLIBWZ14H5M5iBhmnHrUDYBpiqO1hrpkbyD+umCYINJib8duToxGGlCI1+VRWZWny+et
J9Ycx5bJ9+H9+dlH9MUK/85tCd68c8lczNK2Iew5n2o6qPHb5WmsZaor4mFcFugAejMviqnj
uTAneLU6vLrs3UQTnsH5R7hKMzFOayotJr9Cd1ZZKPXow+U57Hn+NEL5/0xKA4OqMBb/0d0q
8BX70lKd5x8p72cFvToamcSspD7ng6XM2l8iQoR1+P3d8ByUnqqtJuf8w81oeH08+vjrNeyN
y5y86TIfRdmf+Os2TsdeLB7UOX1tqhLkEcUdRAx6i3QrsuiW7gIQ7+fXv4i74NT5CSx+fkBj
pW5NmVGnzIC76PYORAD6MnGsIk5rEGd0EGdsTZxTJ87ZCXFOB3HO1sSxpUbFp12Q53WQ521P
Hlsij+2EvHEHeeMO8q5/UaRWGj8BRvVZFgW8NaKxca9nHaW3FNbGiFoHYkvCN0bUOxD1Tg4Z
O+SQ2VF6K5rcGNHqQLRejWh3IHbYBczjvMyhRVq2QYd7Tsx2yHu/o17+qxGDDsSWF7ExIu9A
bLmKGyOGHYhhE1GGF8R62Ls8PLl5KzwVmnr0l8ZaokSOwePvNVFcFJAzYSu26akYp9ColYgY
eLDSX8gnUxo3xRgzjtMHIoTB8dUndHxQbafFNC5vxXNHjCa9hWaURl4B7M29g5ZSXRojVuVb
clBpiFkOfy8cKcGKq+NzCPgs8tvu1HyOeOpl3kxOTUd/IV1yvhiQayuGZpeiq4yHUcKD3h9R
GEbk7zZjrEZsNX/dCKyYwxTHdNBx1DC4Ys6K4Eq46aMpz3yamPlwPUK+Dl2bOSokGc3sUsmj
cVTkLqveIH71QI65fGrCzgFPJ2Me0PSLXrnWBxTb/geqaz6eBjnTHFXVIVMgUG2LqVCqimMx
o+UiTRGg52G/8N01uUCkGLB/b4CCbiX2q2YKbKIqhvHyp8SHqzPR7CJyXxVb5wX3Ypr/Xoru
WWgzPWz38KMyigvs1eTcx1FeYNeepOMojoonuM3Sckr9J036ADcU9cA87MHoXG05ZheyX/n/
TPT/M9H/z0T/95noF8LhyhtIGZlPzLR8kBOeFDSK5/l3HO68/K4a/abXQpubhqGZsJdmAc9c
QJ/NUHXVtuU09wp3H9VsrxtNUy3TXqChT6maKtP1DrRLMZ7kgq6idVAvDgxVswz1ombd9jTb
UfWLubmidWqIqSoWu8AuT4vM9lERKZqJj2n1aOv2BfoCUYG/FcPBT+M8p9/4RblYjKegAb8A
f+L15i9a5ElddvAJPwulJyubQ4SS6Mkp0NbUKRM5f454RvOGcpL/+BNEk2nMJ8gmka/fTP9f
lAa7alLQbI9PCjda1aa11Eg18twXxp38DwhRI82N5kAYTXQ6nq3kgK3GkfqWPxY8Idv4y1A0
5tMBf4yK1TmwABCaFx68LMHyc6hUMBkpKpU08d5KJf22DXmDhiAXTOqqL35D9yv4o8xFbW95
OuHUqckGUimhl6RiZaAXDhj2uXqlm1jIIHQ+h9jnNEMVSTHGxY6r2zTkzYUZ9mj1n3zNzBa9
H0NaOhMIirF5Y5qOrbhP7eDCXoKGtF3Rxcy7UOErZt1lsq5J+vbElEzf67ia6b7SMNm9cKTR
jxbmoYwK7m6K95qrif3i9RVy9Dbg6wOZZviaydukLPgjfnvI0SH+Cpm4tbH/ZroPe4coPF4g
Jh5CVFg8+FrdANJ7rMzyy+Xbi0Uc9o7w33crQsIf47/vWgTC09/vUcRzDU7w33ephazBCf79
G4o4/l5F1K4gLcmqlsmKIjYo8OUiyOxGIsSEOx4Ha4vYsBZ/l1hn3C+zPJpx/OUFPTmfWL/m
PFl++TJrVgDDD+pusGEiVxERsFzNs4LuRZO+ClvCdvFkO+watYR1QH8k3XB4dHT4bXSvBKfH
Vdhb8bvOiJ3T/Z37952XBT1yZnoY/v43uTW93At57/CAqauVzEoYipd3ANNNjcp2Qs1WMAj0
nBUGP8FdhbldpbphtqSm4k8FJOr1Gmoq/nw7zGpqtq7Uamq2gVkmpEzEzyP4gWGdtM1hlgl5
NcwaarQtWLyGmm1guqlR2U54sxXMGmq0LRp8DTXbwHRTo20jDN3UbAWzhppthGENNbuQKXU3
MrUlzBpqdiFTW8J0U7MTmdoSZg01u5CpLWG6qdmJTG0Js4aaXcjUljDPDg4IFzFKqnVB2wnD
s4PzjTCd1GwjDGuo2Q6mi5qthKGbmi1hOqnZRhjWULMdTBc1WwlDNzVbwnRSs50wdFLzSpkS
sV0VTlfCsFn522bsLFFTX1niSxm7SqRO/aoSX8zYWSJ23NeV+FLGrhKpc76qxBczdpaovrKO
azN+z0j+K/yWlklw8OBFhRy935iCl0ftHh5o7h1IFmnv67yGy2OAL8AgRrVbNqfxkii5bYj4
2vxhlET5Hc1OPOOsHTx8gZq4muuYRPmEJn+xUq8bND09OT08eX+BPSkJYqrUSt7sYJhzcdEM
iBgjTLCVq6FavhhJ3VGv235mZiznYoAm3uBr1UR/PzmNvrHcGtvVCmvSgNm0U9SucX0k/ZUw
8xbfDOZVDF7BY2brQHO2aUiT9EKn+F7Oc5Dl7oOXA3+cig28/TZvd0GCXJV3nGY0ND6LxAJ6
sUZDY1oz7dKatLspL75hIRpTTUXXTWtpDZoshpBlWXI6fn4OwfLEK9O+iAWLLgwfIlQvNOmd
P01oWjry4fzgI0xon4hYs/WcT1VUZzHvC6ePBS13xCofX336obbIQ1N1+wucfjg8en/+4R2c
f+zJtZHXv9So1UwVqaXpFkwwWpXAoQRiTRUoQLOqCiRpQQKUiDZ9TqorKlva1zBEHmTYN0iD
yvUje0qPQe8n5CoP6U4LOBlcYiVdBQ7FPnD8cYJ9yK3vcDMUIuIlZFUia8ocWdkA2dHNl5G1
Js3ay8imXOjyArLeRNZ3hWw0kQ2JzL4Z2Wwim7ui2WoiW7tCtpvI9q6QnSaysys+M6UlKsrO
sNtiyHaGrbaw1V1xm7VEke1MFllLGNnOpJG1xJEZm2LXlS8zu7TvirTWFmntLdI6m6dVO63F
irRsi7TqFmm19Wn7/Zvzy9NrF2b4Oc0GwoRQfjYQAGygikeVFvziM92bGEXuu9h+8pwSUA1H
6zsO9vqf/6Ilvj7P8zRr5llyRRCgJ5Zpbbz5WDVMnSmWHmjNzce6rliOoeq67dhLvompMP0L
HHtxNM7kqU0Bj70nDHPSKezl9xHtNaDDWTitwJt5ccn7fTCYbfUR6Si9TS/Pr4awF0//GFAd
sYq13mphAV+QQcEIqXHnp5ggOYpjYgSVRJNy4oJW3yxl6br1BSUG42JaJn6WeRP+kGb3tQUg
teayRQH/6008F8Z09J0MzZIgLOtH1tka2fT3qRdcRYkrQu8n8qyoL+xhSRlKZfy0WAn3tp7T
IHdyOj3MJmnmLn4t0tI+HVpZJ1Yqis0Q6KvxWss6CnNoW3SZFGuWtzJF1RerW9k+iGWWjbWt
5EfOocTZWt+Kx1QH8dBJdGFxAuHVvG/C+Ylb2wTAmGVjw7z3MHSUy8ujm/dHzwXqF0e0HUC9
FDedbs95VWzXpbzBS3n3gb1bgtBERx1S1IBO/a8quIuHCXaM22rZbLWcV0r3ZErxBqAjfYdt
XsijTv4HP9ayPC8J/teiMM3WiTFnGefUn4aXV+DF2KiJR2o5r3aru2DqF4s8OjM0JPBmWC1J
o0NVCrHRuLkcU8emMGrbf5D/ikubm5BuEbE8N8Hez17+wOP4LeyF3iQiVaA8mvsiBojpt+bv
AwYR06kYQFAe9efW1VVVRYKqox69xOdwSoEH8rtMcnlSGp0YZopltwIRTNLNcHX5CYIMa5rt
i+GqBw+JEkFLjkFF/PQsWLqGEthYlDxctypZ1yzKQNuj5xsiXEFitUbZR9EseBW6oLKWEaNs
wd7z/hZUZ4q9Eqb+ivbnYMWXZbuGYTqWaAYXjuiYK2rqcoqhFZqFgA6oEIuf6VTNRRZDCGCV
JS1v7wrKwcTe/X25fauWWDfUWjNfeo90kJbg0dTz76u9LrX0DgVLnZGtboo6fxVVXLHKVjc1
tiJ/A8M0LBovoAOtkM/nFCU3Rjh0az6mEIvd76vTaIbxUlmW6SA979KUIv6YDoyojwVMvTzn
wb/qoLbQEpvH+rqtG1aNw3ITURpiQywsbC7PEhMLr/eaZqsmLI5mMTr4bFZMpiG2yyprozu2
pcrzmCZotuQeAzlOA/JcWKbal0eL9IZuG2bDqH/7XrdqiEG1sDMqdVtuGArDRgnFmuaVNuF5
N0ZP3ZcmomESDMMi3fRIps4ri5T2PNJS9KfqOJUxjRzOzzcSxjYsE3FoG+b3Zo8gr2c8U0gM
qifU1LTLIuNLvF18ycux3NRUy2qT/rq+OQa54Qxsl46BRfVHW7WQScaBYh7UjoI1LKYj8R9O
b1y4XoyuiIPlUj+NQarQ+sp7w7EdbFGv/H/SroW5cRtJ/xVsLldrZy2ZBN9Kueps2Z54z6+z
PJPcTaVUFEXZ3NEromR78uuvvwZJQCRty5vdqowsdX8AQaDR3ehujFGwt+oXnmuerpH2VHRM
7DV1A99yPOpgstzg9ZQFZx6QtDvnehfzjaalnZYWFZJ/FjR1HlIkeOHzkF8Ah/ujTgZi/b8l
s+UwWSy+0Usbok//sF7s+JCEfSEIk9X8gX8wEnh82h9l6fdCMiznySJ9s8XP5DseRAX9WlbY
2U53ZV6bsyC49FqcYDFpdl9iohWjBuIjpJKqL/ZsT3qe78nA7zqOTcZLT3ABzCPztTNpmX5H
OjWplzqjglQNKyRR98vmIYWeoJ9ASFKoxFV2orJmsOg4uaKjsyus7eIftrTZXZWsvi/X455a
ZcvN8I9pOjeSSqqBtJ3IkhJvKhv71PM8lS82/fKQzvf2BW2QMNJODjU+zXDbb9LTCgK963rh
Nn3gsD5o0kuNH0gYmCY9aiYFTfoC37Nq+JJ0brxbk97V+BEJpW166fHEqdOX+J4VbdO7kvTQ
ip6WvDk+Nm0LNXwvYsWtTl/ghyT0t+kDn32gJr0eH9sNPGebPnJY6tXpFb4Nl+cWvUMv23he
ptfjY/uBU6OXQaP/roEfkUldo/cMfCUT4unDgqyZx1nJ/3prIW/yBXcXFbnrLR2I1ey5rlQS
o+dE9WbVYKxIoSGZ9F13Q3ORyhFUpc44hXl4M7jYu1qMN7RznHLm975B7mPuNsi1wlrncCye
jQ0O1P0eDvq38FWnc7jnc5PJhbn2RjPHDw8kFOJ1a4uR18bM9co7p6RMd75k43RhcLjsFlcc
tqoGcHx1Webk5RuWfmRQ0t4RJ39sMggiTkEme9J4BQ5NXbcq5EDq/Iok07ppADhOaJxR7BWq
eC4Glhg4YuAZPQsdvxo9JaiLrH+I5gxNrDbLyrdk8IWBvyXfHxe0b49W2Zik5jOZx4vnIrEM
2D+LbEL7HZ6S1F4UIE7FD8skO5ovklX+Az/rKkUnRUx7i9FO5OjpU5Y7luLT7VmO8v1KM7JQ
00pY5xUX6Vqy4sIOdQfz+UR17it9QWOzR1tjjJMF7CtfVXGHzmSiayYRSuSQnECNJXF7fWsd
W07PIjuKXna/J24GohrXr4P0AaZIXlXdIpuehXwrc2lz7B2fDa9v7ofnN5+vT/d/LgwITnMb
3F5pKNuBfMBzmINMj6x6TbB6dyHqAOuBBndo/Kzy2JmBNkLWFMXXbCGKYmIoIJZMguLFGU8h
lXK1O9hYFXuAutkE890de9ZWBXfUDuqwSr876FZJitHkFdAAy2cXUD1xNLdruapLFadFOk1P
fEXhjp4tHfpVFRmxSHWPudoWu+eMt+hJ6dQwbI2hDKgWDNvE8En5bGDYGsNuw0CqscbwaQfx
2zBIOPJg9so3n1gJxpT+MYbCdy2vPhTMPiXZmnwXF6dnAuLuWwloa0DLnvCbtyeBCRi41ocA
XQ3oTHwDyeNd9wNIodG1QHUtMLtG5sTHABOja4HZNRo22UByqhdnQ31pvvzQnEDY+JsjTxhF
F8qGfbW8fGcCMzImM4j9jbcXF7+5LEA1Yshq6LuIgUIMrDbEgTZeHT+yovq7lDzHaYm4PduG
HGs8prO1TgK72SnGMKaTWveTsV7348Igpt3TmKxk7sr6CzSxQo1FgsOQIZZZb5F2VKuxdA0Y
xzJhUg2TtnQpdGUQ1bAcQ5RYVtoyRHJriMKAzYEmRnOI0lGi+zOebD9WxFrwqzCuIQksJQkc
gz16uxfboxLqXoxaRiUipaWO5aqJE09cjErbxLHNUXHpT1l/HLc2KuXjuOpxAt0F13Kao+HW
RkPPFVvPFdscVNSNtuur1ICR5qgY25ZFQ0uj4rujbL09Nq6tjNEtRO+DY2O7zYXgvTI2oRqb
kdkFv/lQ3qtjI/XYyK2xkdKS9aXtvTo2rh6b4LWxISVc1ueNr1eT9OJRy9iEplx1pTIemxht
q2ni6Iejj0ZXHBQbadEwFnNx/fnquCjVqsk92/dNhfai0swv4UL6enn938ek0yKMRnjiJ9sS
tj7TdWkbD+132E/eYA9s7z32vmYn7p+22EOW82+yn77FHnrhO+yDkv2nSDO6eHVtgvjpIY5X
o1551wSCxfh87cun46IUmcZQkVWvY2gelE7FdRHjFJVe8qNs8Q+aCAeL53n1md20RyixYTbQ
mE9bDRTaPmIHV4upWC7yPDOuISAA36EeluTbFqNL+wdc/oP+4EI7QNtcz65LZq3fcO99Hpy0
uPdcTEgLN1KMlL/V8J/N02dlN07iJC0OeUA4yTU3aYXOB7gfNyOD1wvfaLl4FbpZzej5cF+c
39ILm8Xz+IF+n5RHv5rK5zg3w65lYx3GMOInamYwkbtO6ebEWubT0iFf0cZXGhTuP7/wgmu+
gNWW8uoPruHDF+qMNpMJdUwbQMYdN9HWhkwYXui8j2FcHlNdGqMxQnbTnkw36ZpWwGMR0Iix
k10pDTqyqN/3e+sayq4bsXlhIP9SFfpjc7+IjIAzuHwdrdMy8n3ZwMkR47gW0/j7K2yeVW/+
UvaPb3dh9EJvi3HQv9mBzWb15r0BCg0GN9hhRKVlcEQu7crX6foyHuFs9sI4TNBU6iBcU4nC
z8HHNTwpj3CIZDC4EO4GQ9mHnCg/X18en5xdnp2K/sXt4ObJFf3jS3zS/I6FgzqDfzOf4hM9
zXoVTyZZwkUEn5UZUARoGOwhtqb5hIwh+g8fOvTE9Xlfz0Srq6cVbOtdJmJkcPjYOsfJeERy
Xv2DqJnpVAxYGubiiucfHDjq7pJTJT32yrrYXpd2+I7T1XEnJEwiiLCtgzcVTovHXpg/6BL/
JTfZGRKz81dVgqpHa2EzHXNEQSnO+DhT1YSDg3Adr3ODO4T/903uOf3JhxXtGDjLCWhTPR90
+hBZPY5c0fOZfvfhpVjOl7Tnzm+VFMS70RQ2H8wThSh0l1uUE8XSvkV4D3Oo9X5Atm/OXrAR
imupq5f2DaRQhhrJ3gnJsZwWJNLOAo0kd0Ka2G1IDtm7Ggm293gWC/m7QRFAUBgUO7QVtD6/
yztTieTuhOS2InmeNJC8nZA8y25Bov/7Gsn/C0hB5Hm1mdSjDXVDUEG98ittp5FXj1LjIvfL
Wf1Au/U4u3aYLa3Qg59LusYxto9NxWlz75VePXcH36jvep73Joq3g1PUd31byrdQ/A94Qwkt
8Fr9tSVa8AE3qE8aBmzJd/cozRA60DbXyXKIYqzpfAj/OK4UGPL20xYyID0dM4DQLMTtbYcM
+KRL4Pjkvn8r0hzsWQ4x24bG7CWcc1DUdGzgBYjpA96IHvl9IPegKDVZA/IsB64eAiK1pALJ
q7Nu+PjNHquHQ5P4ZODYLmTp59Pbd4eoPdDOpxeFAy1C6Fyiss+/DRO4O6gxtmZwvIBW991t
f4sBRWzHpDxc/FaqTqQKzHM+4JnxyV9XQ7g2opjqEJvx8k0mH1OizkQz7y0mj6M32piuzwdP
bhcVtZNvySNtn+n0TaCw4cxiD/9lhrA/hLhmK1JuYRgcwmRlKFLKtQzyaK02vcXYRS8ufnOK
sy4g3cY519+6I42KlBMNEFhR08FLAMcqGomP8gbHfNEKPdCDgJ0TryB3jV4EHHLZtD75ALNU
1zkkJH+Mx6zE3d1c8V1ulVQybn/c9hn6XsgBcGwe9S8HuKZBXUBaXjbou5o2ch0sytV3vhZ6
QWokYtj4zGWSi2yGcIw4ZyWEzLZJboTNRSTgIUXLcEqmGVdBlA4ZL1UYZWTTpoCouWU2H3Ju
95peMa3VXqfTEQO+Tmgx4TAy0ki5TtYqH+Zr3IpyhGLeKSlK+huLFash26xP8fTIt6CzjhZ5
emTTmJEpRltR9atD1Js1/XHkibJG7jBPE+As5ovJRJOWXzwupmP6VwfiRDY9j9/2AKKP2EY1
fPzNsOiAQMHqil8God86AC38qrc1/tDHHt3C39asuqFJq5aRjBzXebt5fD0swdQr2O4Cqa9O
+yO09bzRBcSUvjOC73fB9iBMWjBeY212Q9JQfqAbrMLXekF68F/thRM44fsQuvFtBLsbRb70
vSId4U5V3OcoZdMISsr4f4RQF6kKLlIVDJTIDpsJCh9LTSDTyB65rakJZNJEoU6bDLqB7boI
AiufEFJjOKJ9Yc6PoSJcVslGKJu0GiCx2szn+o5aAKm4jDagGwRpq+9ZpkB0xhxu+DfNTjMh
+r2y58kCLfx069UmX/OFB98RPmz0PIqw7UKk43sklAKSXsxsyZcMHPmSx4C3+yM7EKMNtuHi
b6sCkmQykYQ+vbyip+Rqx+V7pR8dFZBPe6PeL1k6PKYiGw+hVE5hKFP32FuoGaVreahBrb7f
Iq57E5k8xF5okhdnpm3EDuuYF6q36M63+SQnRStZLGmUEDC9198XNEK+WHzLVv81W8zjcTd/
HnXHVWVj4LisBM7XiMUt/IWya3cdKb6eT+MH+vbu8Eacnp18/vS7wea58MJMEMHCGax7KElc
egqCrizVOtD6NlbWPzF+8/uXE548RwK+/wN8can+lr5vR5opjKALDj5diN/OB8XeW+aqxGvS
5UYb3kPzZLUZHSCaviiDbcYAERDNerR+fXFJMGUH5ZaDmKg8sknpVSXp8rF0Hou92ThXOh/p
z/pxfItDud71vYQGRwj3YvViY51n3PJmabSgw6phUq429ls/pPMULHuj/GG/fFXlA1ldV3c7
/teCXqIbGX2mLtNGQXYYX9NIWtyKRmyxbGs/DF3olFu0VaKF4WfeK7QX3UoYWYjt3uJMJn+0
NkKCyKmRzv7o7NZOZFlBnfnb91H7qiKjCYb3FvGopVNh15VRAI1isOblnafTiarSwYFp6dig
pFUD31OySlAUpn/XH16eDU8u7gfwKh7wFydnovxCs3kysio2NFDUAVEx+gdlND2Cu2hzKIvu
C066c0IaNJLbaaLxSLEs8ZJGPzQZ7m3RZB9ql7YS2pCirXYDK+BwGAYcJovZiK8ICWkHbYKX
TCTbONhQ9WJ3LrLFaLW9/Dkcp8lQqaPKDtlawkwZIJJli7KvslziUoXn80SWJX+ffaM/TGqR
0JoJhfV3du+oyrDdlz/FJIMtS0KgKqaPxvwQcSW4Yw3ZSfwAne0xLXNqNE/owlWWkJnxuBz+
ufY8j0yM/7vHv6K/mJGev4aV9MtirdxMp1trnDb3rtRgpLD4FVghG3riUyEk2F5DEYPdcKu5
gigJeJbruEUSZ2HOH+gYva7BGcARlD8uk8dlDyYEknvGuln0oa/O77AIm71wNZZNz0dY7Epe
p0kpk43WpI/nJ4x4Mhqqm3UG98d395rC4TOs+VM2zl6n4cOjLxfH4tMqXj5mSc7nqg9FfH7/
MVvi8IpPyIoDJUmiNmucOQBMOTCfZtPJqPcKiWcj3II2q4ub8o5JjnxdLqeZMVUCskijjxws
jqlNze3T7vkB7nyWJ5vJi+aPAtirm6c0j/Eon4oD4i8k03BBVxFvWoZvpvHLkfWCa4kORLpa
HXWc/QqKDAzM+QrqaaT0wr39WsaZntmhLSHdKxaSTaMUtmjxTXc7WY1apN1uC0BaSBfJlrOM
bN88h8XMtX+M/dKJuiaDh+dlhkJQVGOkicjEgMJ1e3VRnJioE3hjILsGsY/zciAO86wnPrNS
wleIwe0Vz783MPZyY9RcCc+samtwcd5oyaAMoLgy5a9Vgl7xXhsndGCgLYjWd39LS5SWhWz7
+Tr+QhMlFoMyF7GjkG8Xz+kKRrp4ymJo5aTHIlTAeGA/CriYyXJDYpfpxQmZnkj7zMVh4d8+
vLz+bfC/g/urnmXh8+2vdyfX+Mx86r+WxiStSUd7mJBfifG88K/Qi/SsCKv49ZiKsl4LGR2q
3ELJGkSub9mvsh43Wa2SlWa2FdA0++X0ss93ZEEmJtmSP5LNwSLjCA5Og8NnVXTYyqNXaVdz
IE2FpJwT+TgPecymJI/Un6X8/PGuKLvTI+vRtsSPBnOEhTQgCR5PaaOlcTq0fWw2Zc6py/tE
ri7zyx/jlfLZmfmbhEPDi5mfMw5QyMrC/Sc8JrTFWC/OJBR7KLV2BB8xMpmGo3gzhhLCt1zt
4yqcWHDjxyUu0rUhL+u4tsaVGtfZHdePOB/XPBcW14s/F1jdlYEzNsg5NuSOHbS4qLgWPaG0
DX09sOziGllbdv65macd6oVTQZENAUXreiFWjMa7sIqN55Oen7kWWDzmYTYWMlhtG7bz4Ps8
4en36d74iTVY46cDDJRgPf8/pGsblGG4TansIl58qguaVjoIQ69or0jFztTjNyaW23VCPbGi
MAgc70Os2x22NJKyNY6x/ZFGWPD3xI8XYxx4dZODJ5rVjgUJZR1azqGU9LZxzOgFYvw8e5bi
7GVpdi2yYasT66KH94CFPVqQGlI8fteg9HD0qyjPFzgsZkcxU4vvi42YbUgp5K25ujYdmiHm
Y1V9INeAZGggh+R6Me888eVSJPALttJYo0cxyDmOYZ1Ok+m3oU4xOYKLh17bvDNLlqMpAjjE
47PRjM0xR/ksXma9Hv8zVDdlnd3d3dyRCH6iST+m3X+A3y5ONafkZL/Zc/wEn9ISGeIEoT5c
DKv1kp5gCE7jddwTZ9hdSZm7gnlPiw16oL7aCxmMj/TtLE4eszKaCy05FszNoiX+Zzzu9fhD
EdpQAJ+rnRzatb52RL0CXAVmILJv5N9E1DCuB58vpyiJ+GH5ADe31oeeSBM2lnPk2/CNjFez
IdKQ71N1edXp3RXySx8g5ucI2NnL16tNsi4I9w+KOggq7TRPkXf5Yrtp4kxiS7nkqEFWMHN1
yxe+W64y2i+qkBQ0HzjI6y6bzx7WwzymZ/rOacG0Ny++/c0gDjGdQaT8IOrU1vxfp/aVxJGo
h/qbk1VqjFHow6n8KpJsIvlAwvFyj2/U1VARH5+/CuU3oWINVfXKRnUPorbfgIqbUGlLrxQU
e3pfhUobUIh+rA8VI9kuXEEaaY3EeHVqeqAuF5YW2ZRg4k/M6ZMFQdIXyXO/wspEsc77gtH2
bT+UAjUMDq/gOCWpRyyY1L3iVlGaoV0Xheio5a80OZCLOE5pKRYVOVBgogzpNK9jU3ykL34k
5pAMi4qXtllslKPVuMUEZwrps5sJJW1eJwnhsri6QoRonuCq2CGnGFfhWIqMTDNqC9fdZovh
aPqt+Ii44qdx/LvwHJ8szsiWeC0duCuqmg9sneRiTwae+HRyiPPeT9nJfoXtyBAhng1sm7FH
fw2bdAm4UzfT6Wsj4AQRpt8gw5Y3F5fxKBd9qSz2IpVOPHUR4WSTqdMpFfSANJTxYkrW16cM
l+etM40YqiMDybzqHxqoEnSTqJhcTR+52L/r9EQ3mRbxCYL23OJZXzAKhUNoz6axKY4v1WTX
j+5aATJqd55apBW9DIvQVAUgnQ9F0z5lSxwx0l6hIRwbU3RniPF0Lg3mCKenOzMv557jbD+B
x8HD80mSZzO4a+omWEHlQT/dvR16PUVCm+L3JWytz/MM9WaU9tW5JY2D/zzrIMNKa5cFSwiZ
vsyyl1pWFogT7ZTZU9dq96wXxAuhpCdLR+MtB5GqNNVAgmpA3fxPoYr3sBzq0VY4nRYmPG6N
EdRNs1+0xdqqrGo2TmkOnlx1cFJPFoCZShdUDMhW8yoGu8EQFrl3BoOPuX5LPeBQgNMzY4DR
ZnF+biPhxCOrwnmD2DaII1K8kZjxOE564n/Orj6L0y+nnbubqwNxfA9tqX96WHyj3oZi9Lp+
4Pu+VTByJitt/+L24sYVz/Ec51z0WXreHsqCdNZkZOzDvaiqm9FPlgYKXGQ2MtDVrzQMsqxZ
Oq2KrSnC0EZwPB5XjZTKKbQnwQGMNx+KHNRa2zVYAmT24KELFs71swNmCTSLV7GQwYkIFmLR
fsMlR2sUic6YBUMcY6LM2+SHUj5WyjTHly+LwUfkZ5kySGo53gVbUro5Oyya6zyMy7VCMzHU
FGQHRooiqSi8rmUZFNH/s3bt3Ykjuf6r1O4/nZwbwO8Hd3vPEEI6dIeECenH3Dl9WGMc8ATb
tG0S0p/+SirbVUCSTs3Z2Z0JIdav5HqoJJWkwvhO/kSX9yQfPesb2xm9E5SC96eM4kQFvemg
AhDOcyw2Uq/IvkSXM2ELmW1DatqxMP7isjIHYzrjEbE2PO/mAYzNFuxFbUHm+qjB3qXYu/24
CDN23s8G7OK0V3kEyFKFjnDamLwtCNEhWhNO5FT7oVQu5DbHqX5Knk5B6lOlhV+Qnven/dvL
m+chfI0S7AuE4FzT+14N+ztcg07V3hlCX9fwhJfoOPB5EPJ7zQc7uo14docBNvk/rMYzxkol
0pMG1XCYpVsDA65/v8Tdnfdj5VXhf8L+1/W2x46uwzLDAybdPsHyxvaxwDJtPDn8sxGG8A7f
u3/+iOZ33DAxQRv8vttIff9s7QL32qbZxpIiEouwnEwxPXrzYF1GIRsa1+ymhwXjvjTuCIuu
f58ze5EJctdCzZtXRXwOQBL6RSPVkNDT0PNePx4EIVa6EMsLOuRPW/Nc93srBPs4SwQltInF
auLQt7bbroDgX7BJb9KZwOLaP7rUcZ7uKEl220UdHSVWEcZVxbajm2PWB4MBcZ45RmhJeLBo
BJDuYFDGj1VgbIGJ3WHCq7ztLhODE8/yiPWrwDexpLpc26f/O637tkA3KNC0Ij+9aaEzC1Sj
0/MejHTnvH894BN9vsclCYO2YfOTF45lUs0PUB1gT0BLtr+MVvALnzLNAAALrftMUIHWBAM9
isM8K6IkZuPfhyJyH9ZS22rp0nx1sQIXWtLr0ixAz2t6zQXTt3rJg8GwfUzpNsklPAHeUF+X
hmDXX4ZCnBvY0LwBUghLCZlSn4HUdGs0X8MRVYA0akjdkiBdCmLgLjya3SYMdsfCEZdBGzcM
Dqeg9kzMvQAVDGYt7P0Jhp5M8AZ3kCT3bPDt4KiqeinsLGn8fFLLVvEs3C5mcbf+wONg+F4n
BjWWpwXFBOVPDS06Ivy2DuPMjnrrvL0rclywaVHNrKFuzQqtYhMhzJj2jlcwdMp8gAWG5xOS
Ciq2oCMOJNOQ4dy0a7VuncOmrYp9+8WmDQt9dL9s2pKb5od51UK7ispvZR4lERsOdxlAuU2v
jtO5rbOjj5sVwwvFgQVLhvPRr/4qCwQlkWDZv1+QgNCXKWwLj66/jGimj788KwhoRbu4pgWd
Y/D5KAl5EGNg8vsn7I7uMZ1t7iiHieK6T1jRwXCFRYGxzQ2MAQOMMMAvqZmgXeNn7qnoisgR
3fPYn1SyHwzw7/vkDJciZfFNk9l7aCtblwXob9oJJlImMLN/bKINFhU7oRBQ6JUY4zgFjumi
Y5vYALFL/2NnFBfc6pEqQdo8X97wj+CR8X+IwfHv6P7oXU2GXeYKbNtGJXUXu1eWAeUf0dd1
1Eyx0KqcZkENlo6JUmOTco88HnCBMrPAwD10yRVUk7iq32MZPlgrruHb6Fusf/M8AeeTIjCZ
nJ/1+Z0zWMKTnZNJfYuTZMUPlSmmpyEzNRN3umIFSjA3oqIUC17u+5irhz1s4yZIwPwaj/rw
/uTiHkU/fwYpniLBn6q10K4DwPwTKhp3hWVIV7h2MF5OBtUdFAXrJAQ4zsK8qqYsnjEMzM+9
mAw7E5jF4TJoZPTeZoF1vGC8R71+gerGYDBgHkhLvTcQj1hUOQqk3Xr51IVdF6f06Gx4DYpM
UR34SoCOg3IVDCHSsHHeBit2+/mqA4r67kZxgmqvIHQtjCsN8jDFyED+84Bdlyo4VQ/ld6Fu
YOrVzXkfP7B/FlUYwz/Z0X+Cd8cwOGGwLjbVUNb+mn1QMJ68BhR+TPPgkdvD8IEbaUf/yd8M
B/q3gAMCDgUfaqjwrVCWRuE0NVSW+Brqav3rEX6AceXxDhU1J3OwxK2JKTATkw5Vejd97Mlw
71iletJDD4zcQJyJBobXrSTASteVpVpxeTR7YmfBAyiaX7NsvszQXoQWolX7WCCbFHO1jzwA
wHjFYC+I7+jYJgjLDRXSpKAeOp+oZwe3Rv8hIC0bPT5Hm5RnagDwlE+oY/xSct4c04ujRc59
GZQJfc2qd6Ge+F/p0GgdhfHdE0WI8rqOPNRDatl2jb0ZEiewr9wMR2zIjqK0BAnJz52qDjs+
HBTH9N1nMH7ZI1HVzIvd4tIGdAD8AR5Pu1VRBm0JAn9J2Q/wCV0BmgTgYQDKAcBBFxIfL3Qc
B69O3CTmPF+j6I75fN0Ouw+ogzGvY3gd32WneTAHXJhGbfYxW6YFrIR//YUfTN/8LQnyLEvb
ZdjeJGk7mm/+3aDaGvnjCVWj4uOrqAxW963hGAxNWFhtPmFhnv79NnSquP4QBilmluQ4KKzf
uzrw+EkUPqZfPmwPSG43ZKLsP29YGJKAD+wq0DvhLPxRU1NydkZJIVydRO+gEvd2+mKO9IYA
gPWschKx2Gvf1jWV9u8fYIrnexCeqeKHhQenHvSrAHAoz/TNAEk4C3Y5cD0MB5sXQYuuASDl
rqV19TtQkSY9mHLh/WbdnIqjx07QemTH9WCpgOWH1vGlwQb4G8rmA6sY7CZ++MyJfRstOikK
KKwOGSo8TDsHYSOKihOZo1HQeUiOoEoXx19q+8ho223DIKUbc/Z3XCVIjvTc7bJt6G3X1bcd
6AnYHXStY2itD/EiwKo1+y9DdLDDwzbQNrWWxo5Qqe9oRkfXpEYwNB4bCbqHdrmufRCwv7LJ
Ecxz8Qg24geAjR9ifHPd0Umn4srUYXe7bcAC48trXfV48TCO5zuoRlV4u92PmhqGkziiQv3B
CFh4rZbxYrxS/4VQJyR1PctA3ZHa3ik+BTvtErg5wvw00xxd/OyaRgsG4JjZRte28DHd6JpW
tzYuCIxCpV8Ee7mr+k3BCwEGy6jmLHpTN+NAObXJRAiuaQqEpmPrfgUSnIqv9Cwmg+HQxIuZ
xMHBVHxxwO22JYw4gqMIToI7XGYtnLmvcsMDv2Iwg+Ue0bWGJZwCgy1eF1K8xpW+y5XrYwhI
Bfvs/NNfm38uCh0Y97+wTPhHcjql8LNvfPuGA7+zrmQD12sAMEcRXiwtPNMzNNjA2RU1gfcZ
RAmeiM43IZWbHdMTKBNgVPk8kMIsOZiuY7xTtcz1DnbPbIBTDB5bRPMOvQlYdFjTYl+cPNiw
Rh1HAqM6p7UrMChKWFe/M3QibXkVjqpYL1j5rPHYCnKDTsfhj3VAyvNI+2wgwctw4nfMuAEN
PFsF+d0KHQrnwQrPj+vetoTYcn3LwOiAMlpuyhgDV/BnY/nhRNqdMSeYseOL/QEAPExOrAGu
1xSs0mXLx2lYbBKJLdjGMcbwcjiWXAptr221rga38E66Dx++3t7+wY7mT6Bl447B/asFpae9
N2znWBpRR8Oadsv5CmYGhUnWJkJ1WNRcMqhXhXkqMpti/w17GhRgUn4DMY5pNmkocwUzqHc5
vui9xoqAdHV0wAMLjdPmAauJYtTkxwBvYvJdIIvvo3YSroJFkP62Qh9GO8sX0vu4FF962Ruf
Hmw8EmPSm3iapaIWBaWkUAC1hT74yuX0kGyhOZPCG1BxxNOWZ/xPMHNIdu1sVS7Gs8EcGgVY
dqt3O2IXWR7/xODbz6syD74fLnNDnoG+hUdvy/xnt8rLApkFhgzGkEmT3PfwcBa06cggwX1+
fTNo6tHAV4N640YGDliH4WgUWk/TTHQTBPNNkjx1ZekjPUIVY8439JfR+JYbZxUuTFZLWoGe
plNC/vObtMcuJ0NZREpkpBRKjZz3oe+K8sV2eCiQRIAnHK9SmBq+qkSRxEVYq/xHcRaWq+OX
iUmlSdYlPLWTwUZRa893jqC2yFdeU2Ngd4f/wn6rMs9OkjjN8ve6dmIYQi8DSl/f7ZdLNFNe
YBKPKWAwM5gTvWzAHjy7CaUoIuFuwBhn1EOyZRhPl3iEi5Xa9LbO3l2vo/Qd70bpCODo+qI/
PK7EnkDxKMMTUVrrKpACpB6W2Kr9h/XXBx3imxhPv9lhQLip9tt/LpCfcDD8V8UYeYQnW2BP
3EkIlq9YjG61lqip4sybqcN5OH2cJ4LeMCnRQ6H1Mgklck9TaT5B1aOM7r85AsIk2afCAQ89
r6MVBJKlO9y2LKrYeRxUHkff7EcSPHoyDjE8U0mOx3kYVAUNOYBtm54iE4cgjqFkJQf5vanr
Up+6WhVPpcDEAYarFJM1i1b3cTotAoHgUZilEhenhMI6eFlVgKHlHfYhu9jMCpmWH1FLi9C3
lCLQwqVpNXseKKu1S+XtbBJCaxMItx7AOL6KZyZcG7q2FeS6qStzsQdhUFXft3OAubd/BeG9
hOBUWszbmbiJ4pRynW9ZvwYkMvSuMl5vRDSAFe+VWCRLaZp4AoLX0FPi8Sy6hD0gYgMYsGWC
qaVAIyFSrJkS4sXwrPXv/vWI3UwM0ziYkWgFqEqBq+w+Dli/17IMvL7vEFIxt7CY8fM4geAY
hqbI1D4CXY+mhLDFLXY+EyLWcNVWa5xNI1BmZR+6Z3i6pvoqgwqEVfG1wX4HY43wv4tpPY9p
gjaqOg8aTO8FTNwxVTHHcV8qDsxxDE1pq4uSdbSQqB3lN9tDMA1LZYO5Q2XFkMjpQEGJgX0I
y1ZSPYDcrkPzkJwX5FLi4BxB79k5Ihmd831Az1cJxb4r55inmgkAx/ZUZeP57dlQfuxsb5a4
ltKBwyLIwZCYLtaFgPDoLgQlrj4QDPswniBdpyyfJDjPVRm1eB38EMS+5aryMuYphn02Pus1
QBbYfyriON5sputlFqXxVsLwlaXYszg6uafffqgSPRXrQNi+MMK26rT5xDEw0QEN0GxTsrs4
T9CBIYxHy9R9/28C689LP8v0PdVFV0O+IPgty1MehhryBbmP5bpVVvL9yr6Hh3XNFhCO4anq
Yp8u7U/wFMCcoQodrJLKbS9QMSBK6eyrnG5kmWm5rqO6gEagG37eAYEpq7KEsepOJh/BeVhU
U3XMRohCGUH0cJlVz0ugnlIBhiQrXM8S7g9bszXVdTTKCozeYAjUcdFzLsviXWeDrZtKh7fJ
drOjNdm6byp32vW3Hvs83oExqPDYm9nI1iUeEAh601A2uA4xfF1FecjWO94+Gwtrq25JkxEF
EyTsSG/hA0LOgc2vqUycH2Gw2UrUvvKetIfg1MrYGyuHBHfRtNid/LZLt84pcfEsjqcpbYzF
Olx7W1uid5TV28m4P97B8E1HLSWtyKRl5vvKk+MiSOfFmgoxfEGwSvyy60kD62h1DqfCi2Xp
E+uv4gjzXwSSbvmqDAoksy06yjHUojke42I5y9KDQXdM3VKdPC9j+ZaKxvm4jMtoGQVCQDmW
rax2VBslu43CJSg1XxH0YtC7RQVnncNj6Sapsr/Funfwkrr/UkMC1LE1FZfytojSYppIrw97
vKo8eQbEU9L7a09N+OSGjilgPNtTmWDhE562Cf+04xtKnRElseFAt9a6KA+kzCU831aLn4od
4xU8V3PxeIQssWiF4V6SbdbCb8SjOl64p2bd7SNQsYC32xzzBEMyBb1hK7mV4wIP0Kb1uwsc
ky5kUjqyCOcSua+0W67msubngm6tlK8cZ7YmZKdrG0o6FLrRomURlVRsTsCANFeEKaKHQnJ/
uK5mqiCsHoRF7XomVbjAM1M8vhKfsPo1rnY8wPqfD3gIXLJBgtHFWX5SQ2kGGwUY6SWZGy5f
aC9AnuEvPOtVJKBJtJ79Mjv4NsgSv3m0fskThpXBKWYf/wDSlfL0Gkx0iPOFiv/qXXZVwVTH
pRS/fAJT/EuUzvHccu7M8NdxnmEkynuseHHCZuGc+zPeM6utuwLdrEXk8+gF1ZIsumx0l783
T1iNCpBcjl4Rv+8lfq36FKFCrEh+1Xdo5zky3ShIN3cY+ptj7CDPr0De21orD01MfdP11sIN
tMjxItHTAtCutfMKUGa4Kw+NIHEcdGQtNzOmYxhjPYnwi6b6EH8Ss2P2nqwM9d3cA3zWJ1Mz
9jQLrzK5GsN/Jh1DPlb9s7oLpfvp9Oykus2kO7r+/J3nLjvaCfzH4gnLJ7qwH31d86rSVlmX
t8AAorLFD0glOsfz9+h6n7+9RNc06Numjq7z6IFycKotHKYuny5dXkBNY0e7FdRKVhdL68zo
q6pU2rHAtU1TZTtCaQS/hsFcQDi6rSJNg3hdRvcSuWeriKFFGWaC2LUtFT17GaSPQboQ9OjF
VXGTzMqg2Ql8R6PreYN1kOLNTeebv+Ky2LDTIV5uDaIloLLV784/fhr8Mbw6f0cpMjzvod2W
UCg3J0x0ze+iXwfDXciZkiWbNL7H06JPwzEFsq2XoK/u5GYggK7WCdSSoDYoYrBqvj+CH1Uz
dfgwhq0gj5QX1FvdIfCgzS6ixQJLZkuMmKaSQz1Oiuk63Ah6S1MyBio34jSPkqyMBIxN0dFV
TUHQoOskKsCZRHj8AoS8VpRcY7CO1OjQsuzQGt2pMKiLFhz/16tRZ0evt12CfhNgMaOdtqTF
6RoU0xXPI5hi82mxgk+zAEbkbDRk8yziZbUSLN8oaPj1ubER0pvV15fshY34rqWhwY7lOKxp
kci33fBbiSejU/huPwyFRJSLBTubeDpNYGIlXWq6tQ4wwKlsrVB/69beSZ5It0l5tkYsTWHX
NZS0YmyjjNOnlqSY+a5HO+Dwhl0N+qKudl3C86CkCpHYeKYJJDd9+2jbKX4ev5HQ1zGHhgid
t5JQnVsg+fjljex5Gl1dDyST3tUf128l8jzezqg/QHlC061DmvgbEXTH4L3ybTR+IwlIEQxb
zqdxkqVTfoknzFTAiEfXV28EMTW1gxVsKg8eJQBKz327ah7NwaI2Bb3lKFn+eIlJkPwM1gLB
Nn0VDuJFlq9Xm4U8j73mmPytGJsgDeJcAvB8FTlcYiyoTO/SMWAV5RTn4hOqW6SraFi6M1hh
dMUTlvuWrDwfNECqvfE8Oc7Cd2DO8C95JCCW7/zGMJoFCxhG7wSUb2I1/xegMAIlS9ZYMJES
vzjiWiooCfK9iv8NhBLp+3j99IuoSXCPCYZ44QTVKOT08Kmqkw/WqLDDfF/XHRlLqjssoT5X
eViEOvm+QfeUF7h88qqHoy2OWRpW915wgBMW0t2EpMiDZh5JED5qpGei8IHeeozhJc6C1Qq6
Ia0Ct+uFKPQP6GIcrrOJ/nXEHnW0hpIAp4sInK3SDyw2+RnMslVYsA9Pm/xe6GE+L2H9qE/v
tHlVqJn/0cWcRdrGAsyNKxIsJM9dQNAfK9gXsrXQi/4hEVGFJ0HUZKTFZVNBOo/K9y3dP27I
dF+3cTjWIRj5Dl4H1ccP253k5JN6TPHLOIVhaqwGt21gjXrcxTADYLpGdTpcBckatvnxZ7Hp
1l6s0dfe8LahNUzTUQpZCxNDM7eC3tJsJfp10MRfIbntmiryc3bXiB2khj1Yxa8xK3epfSU/
WVAuzfuG2sTiet8ZDCpoK4tWuN7slkrAopzzOKSa/Hg/F9bxwTLr48+FwPB91MZ/gEzvUn3k
7IGIMRNUwtLYDRb+utukoaC1NDrNebVIQwwT5VhQ6DYmiV+Pe01+5WE2TRNEjgQmVUNexrDl
PPJ87ovhGeiQoKHV6hlp2B/jPAbdv4jTQBC7rtLBIDwIDQlyz64cXvBt5Z+hUj75bjwxPur7
KIpQroLs4uuzy0YZekW53spvSg2zRUrlm47+yDbVHaplzjNw+fJ6hzneeRi1moIEovdsnS6n
n0erFWqfcVbItc7zTYqji7Vs6aJZfp2PRExZ8kT8mMTTIOY1e+9TLMTwFXTjD5/h7STHARIZ
dDEx9FGORHjPG/TTJZc/WCq8hYSDLQy4mBZgdVM+ckMErYBkBQ22kWD/T96zdrdtK/ldvwJ7
9kPlriUR4Ftn07Op46a5TWLXcrPpycnRofiwdSNLuqRsx/31OzMASMgiKUtR0tuuqtPQ4jyA
wWDwGswgVin+Y3ilK4GjRUXIoewI1zAPLp5k/wTm3bVLjCcZP+G6Ds7bMrkOLRtPb7phZC+Z
k0SH4TIXkojvCTyevSmmsraXRoxeMn3z71YwgbsDy5lOUSHYm9Gr3vVihQsxqERO+f9ozg96
kFM0CpBPRd+n/AJQKEyBVZaPkqGmJPlyr/FRwQKKuyVt8iL6BKAY17SMXXgQlQzp+JFiGOuI
xYj57s2pzif1ePcM0xX5AU5QEOgqXVzJXBBgC9TFfSSkkphXlsALKLTUycXgZHSBMb0oAZXx
HoZT0G+87o45RHDKRKHIQdMwS5W6lY03OPsljm95lHD30+oKr9qfR5Q1krJ64M6rjJAnf1yC
roLQIj21wGQcOmAMLPb7vltR5QE6UL98fnJJ05poIkOo6YNsBIExD6/7THFSMwCDJDM3RjI1
uQmI67OPOA9Jb8xrNnYJEWDEFrBStpBR7HCJmBtvKcYifp4TcTNPaAXFOV5Q/rwao6iGOrYt
/vEH7mlAe+AOpmUgUC7KV+fvRrVpmQrWvTw5P0b34vNKWdAZNtBY1c1UM2+omcQUw+A8k8F9
ZWTvZ57zS5U7VJK06dRNkjyFTmemeMdV/APILk0KJgKVkRVX4xiBYVXRcGyZ1QFpTJd3hZn+
REH4ooT4kOcfjexG1aBiwLu2VVb0w/1TEHz0QlcI2WIrfOCFZbU/zCazeCsGZmBcw9heqJCC
iyiU5HobPEYdLJXiQ/EEeApOrOHTZCsCd4KqQPN/bYUXtP17hWP/y4tThlMbwL5zYBS8wTiu
MEv+vMgfD+Yh2Bq8trsc12CuKBTEekoBieVy7KlreRDe/3TxBvvuDK+My5y0BjyNx1uz3pad
zrYscrEYpVeUNf5icUuxBml1BGXzKkDu42XKAq/F4otjWXSc0r05fz16Qm1syyZ/senS2xSC
14LmUsyBrZVyDQwPu8qP+RRvPsIqMb1XGfaqFq2AfYp0v428Qd2nzEbbEMIKIaBzxvfC1Yc4
78rrj8KAkvnr8ODYCOcbwcK+XDLSNLGLIX0FtoeDV2QnUxYeVVRCJ3xC3mNRlY5bFm74EV+t
Vlcwvb+PHtZZHVFErWuYMuizLsL2cYvrx9ltulrA1HSI09lz1v359gazMZSzYXnwiB4TKrZp
VXG8pOluklDplmX6vI09KsQTDq4yHidBzjG9fW3GY4klExvUYm3NmawoBHiYtTV7oF1hOA43
00Lmn/Pl48SBCjDw3MeA46IW1HVwgToTq+VYrkRei8tzcyFxzN6JatVjc5nshhDoKgemiyQc
9dd6dCLCoMswWytadQ3h07Q3sAT/11AGDfuVvcNboiMdFp3rSAIILqdfL04w7bjK9gwMTk5g
zSBotO/Npp/SSrtFaFNSsXi1bM5TTmnJYQY9qC6DAypYOuwYYJ9jk1f3rsoJ07dMcNp421r3
Sr4gLlzWSAYjmVgW9+NwxjhTeevQZ7BCEDa2YLik2GZGGtDwnKK9PW4OEFfwhCT2tl9hYJg2
Q52SedGUvlTCOxauCkp4zKVZCwerByHjZK5n21zMB4tCFQkM8kA4hkQDgdOLxTKd38mscBiV
IJ2zuxH9pVLF0QAQraJltLqucENP0J3lWTG+KmCNSUPOy9HZhpAcizKkUGJftpxNMVpWWhjv
A9qQTUFFat56Nulvv99nz89fnTCM0isjGKoP6xo64slo8yX0u9OL0auzt7CA4DBmWToUN0JC
scBUWV/42UIvPjC9nT58jZ5HW1DKk2ORQXvJBFWUDRnsDncre+r5tFFfAb8665E8/9MqlQ9Q
hGOihJyCW8h0Lrg4fHVGjdCv/1SYAa1dFDSw2HhP/iv4W8kcoKxhKZwKNCTPG8UBtWTIltcP
Ba06iTru8Kwh0OWCNYQXMOWB3vjALqHDGUtP27eE95j668sRKz/rwHRB93GpObKHwdvi1YCt
XM8MumxI4ev1glEvcqbUTr6BSKvGdcRzaNQpdMsUZ49pslYmQeuVdXgt9zu9yDVLBrOkmkqI
GtH7NkWKWKcd5ZPpSifmXgMOrFDRRSU0K0rDx7AChWmOh9pBhbTMFxS7hS2nczxy1QnWjhle
R2TH7Hp6dQ3jbdeyjjAV20UX/x3R/7VKHLMX8vUb04b4MvoKEebHZeynDcLC3yCsE5oQYb5B
2KNLxERYtBC2N0u8hbBPyR2JsH1QUQQUz5gIOwclHNINUSLsHpIwRizRMvYOS5hiYhBh/6CE
eYAeQkQ4OChh6LxaxqGpbrP0Lp0Zesx3VDcMIcUV4aiNsL0rYcfnWo8nbYTFroRdj+vGi9u6
tLcrYc91NeHkoI3nO+hCQYTTthI7u5Y4sEOtFVkbYXdXwjDzUnrMD2qPQ4uGRyLMD0qYW1rG
XByUsLCEGpr4Qe1xKEJLWTd+UHscQt/TjXdQexw6NNIT4YPaY/Ru1KI4qD0OPToswGkJrJiA
PMUjJn/jCsanZMgAY7HeDzArEcYrBzcj4RWXr7jxinJ5wStbvrKNV2FIbkm/OvJVtVAJA4rj
CK9c+co1XrkB+Vn96slXnvEq8OQrX76qZo1hyB1yYPo1kK8C45XjkpPYr6F8FRqvfEeWkKs6
V1uWsFSxPFlGrmvNjZe2L4vChXopjJeU9B5fKqFw23gZ6pdKLNUCzrG47ck24Eow1XYjvPSM
KXXrhyWLebWV5EDPxdXI83fvRXkOAwugq/hmnM7jQZLGYDOvoitjA9rBzBFQ/eenI3ZyeaFj
Ggd0rfFm+kekJvBlAmCJ5AlsIdraHseYFQ69y/NPuHoq5ClJFwABzgKNssGkWke9H+AndMB0
MBASqH3Pw4WiZ1v+UUUYL6t+XDunj4pPmEbASExSQQc2HmnrlDjKZSjpgd6/77tWyOI0X00z
ci8oDKwQr/BhjsHx4n5Ot1HWchxLqNDBk8lPz3+i46OE/RytGPzB4tkUt7YxM2hZTp32njA5
fDCu2ahHqaHwBsAqK9h3UVZ89/hyVExnsFcGro9aU497OzexMQXBBrpLuiwLnZV5TzXakPVC
vwL2LNooXeWZPk46ZnEe2yJ+Jv/p0bks3acAQT5bzI/phPIqn64eepRzNM3p1zzNetA80+zh
WXUw6HDfRS3ZPZgx4gYUDl1nBAAarJjhAXWB59dmQgAEDsnMvFSR2c5//p2YWn1ye2WRzv9A
L+Q59AcD+CPr3kyn48ltMQRmYzzhfVbhUyjzZ+dnr19Xaio47bXVMuRfyJDXMrQ5rpJqGYov
ZChqGcqMDLUM7S9kaNcy9AJ01AG9GLIVZke18Hz9dlkB+ALHNsyEivfs5+rWiRjargsmOzAA
Q9xnvsJN3ZeX5+tJN1l3mSxZvPrMKF0Ktxy2flzr4LYo1Bx38Mf553T4yGXBsS0bd37pLsDp
ixfQzVT6MbQIHnnTYSLwnsDEYJuptiUNJ8TTr5+gnmi4bueUGVana6WD5CHjgRP8UqH4HPfb
KT8s7YiqNF64WaUQqxQjCaVqdm3hBJ8qCiGlk2pnCrM/gyl2YWcriisMDLlH/DnwBpii+ISM
RML+97/eV1MRML1gUMDYzBf0Ai3xetoIJORQSqM1QlSGgm524yEQZYmVO/YGGuVSPQB/18cl
Qb5AWdINvSFlIMSngt2DDTY8biqskCLIQ/tQHhsR2KyLh01H2GPSmyVu4kfs/Gz06r1y+Sge
ihjp3l+jt+vJ2dufXr0cE8D48tWb04uRdlmB3tAZpKt4kMejfjIYWVY2oR4CGopuPNArB8Vk
Oh+AvpN9HFbeR53OuUy7eB/hgetksSDnkH6/QycLJNcyjn3Q94TPcc0pE1bjSFKspIsSzjdK
KC+ga+dvX72GYbF7l0yOhtI5B72JMjw2mU9nMLZQUvB0LUgUYPvcxZPyEjvaCTvgFKVDYWN2
3Yn1JAJlhX8EIcCqEPoK6PFcCgX+TobaExdaZUGOicsivU0WmLCe/MSg2a8Z+u+gx5jc+4N+
0NH4/c6JOj1CLvqotfQkK6pp2/W9mjoBQygyHmWw72QA1WkB7byKv2tjeHE7nyOL5QK3raGF
pHYsb3r6lwKDZGMr32dXQ1Z8mi5R3bCQnV+U+wxq85Bkwc5++Y9OgZuuAxh1B9JqFoPGC4Ia
op+ky7Zifo5y7HOVVjaD5mA2l9A8AE51kYamR4UcWLynaaAL9Uo7XeN9BMaF39lECa0e3rac
YsNRH+EBUL4tctlR4usc6m12k6eQ8NtJXEpohkkiMYNNyv4BjV2w/07g+Z//g6UFdfuUPlBY
6NtPP3SK6xvMrpuFlsezLLIo2Tj9mU4yL8FTIkfaKBikbqLp/GM111bG4ypdjUEwt8VqTKdQ
Xc+ZQEcXvsNsgU82F0foMw+TQRCfnuz2Nb0X6EEFkid3NGivW9x/1wmhwr7wg4CMobIHpUTW
MuKwW/mexiEss/Rlwr+Oykq6ExGkItWVdCe2G4motpLbCoVRKb0vKpRipPxhFCUwtNgJ0OcS
HbccvxXMFjwQgeuEoqMbJZKOrdgwBcq8Srku6chcCiUI0AicEogxz3n82rYrGk9l8oKa2NAR
9PfMcSiMqsUOJq+BRdMNet2QcstYNoWpZgC1XqJNZQM1I+VK0kgfhPcfkViv8yYJrZ91JGrk
VQrkmPFKm2tlJ2pBOy+ev315egEru9/evn319iV7PmIXZ2eX/c5v8xmO3JQlCcb4XBlZWFJG
Zdh05Tl7LO+RSH/UOML7L3Tf77agBcoMQ5aTpYOKoWPSPczdkNbJm7PRn18ADLIDK/xZRHFO
yCsRySxhZjlHPcdcU3hhZmX6Ct/OcZijBb6OzRZVESzyFCYk/Q466d6QrzCmr0abQ2tFhtC6
OmS6e70kXyyXsHwoWDe+zXPgDGzTz0uoBfb2aHbU73TiVT7rwYx/cQ/8S+FAF8Yyom84VAAW
51piyYKW4/8epVA6nN1SLlGL0YbD0NK//0bGbTlNxnhm+oyhK+k2nAuQcn6XJgPTzLkSnHIa
SzDoBHdjNLt4bmzRcmfIPbQ12SyCEdmfWGy5yoddmCUdbeO5RgxzTIaSoAg8XyiCvJbiGqaH
IawlJiWqVJiuAzOLbJfy7CMDuoUomaOY28SwhsfRK81TAhTopNtWX+WZjc1KE5wkLeJ8usS0
kfXUsUlcJU3LCaytMnkCh+cJLnW57RMEprJTOSsHepYvbAzaYuGtblpSgq1kl9CzZ7DuRD+q
MLRxpf158GaKx98DCxbeP5FvvsXWubhW4NobfHAF9Kg0MEjyDTiQRcfijHIG4dezqmcrMp6/
wheEG/sM2vNrM/rG3zWB+l9DoOLPr+SfJlDnawiC1/+O3SvGGfufLoKvKNC1Lh9+Zd5/U81d
F2hgvLPrEXjMIp/ZDnMcFk6q3wOPZLSJ5dTTcWA0hHl1wqxk7fcsU183+6KKJQ6L3Tq+PhI/
lPhUnwYZ6q7W3OXrSrPPN2n4/f+DhroHqbDZQkH97zXfhg7R9BXt1HYniN9J/e9ehF9Q+UdV
yGCl/leYomRB1e/NL8iw/D4WbwvBrZJf/zZrWLAboS2kvafr2hd+mwbDPTTub/M9nNF/yrfT
aGT+Db4d03Sasyh7q0n1N37ZVZE3KdBX2CwOWdjwVpqDA1T+y3uG1/C7y+wE14RgiEWKjHjI
/NJeB48nQmCXa03exGWZiw/+t1XYb/PtNL9omtg3aMTO34ZxMIC1PMxkg7/I/GmvYaOzNqgd
akLQVJQ6OaoNnZO1U1Z1sxJ9kVLc3unjdbJyj6rfqCt/oW+zWjesBqJdG7hhRuhHLEpZEG8s
ryaVqfmSiuHkzGaex1yXuSELXBbazOeMN8DjcqxhJVgvBx+/ipdXlXZt6DK3qLLwQNObuOH3
Jrt/6G/zJtyhtjh2aYe/wbdZoIeaDv8VllhfS6BrQ8uhxuqGvhZ52M1tu3kP5K/5bdbQr2x0
IkGi5N96dfTVBarmG3Ge0u169NaUsw3p8GdzvGtsoxdzshgncbwcY/xJgFgsV0OmHronP+NZ
+/j14OKIXL3TZZ6iY1cyRJdkPLHNMRyh5naqrhVxZ8Ad3HtZ5ou7aZLmRd8MHDHkTnnOeEqB
H9GBi1wy8yiGf8eLOWvzdvoQX09niRiGGDx2iWfzqeewLg+OWJ6ubnMMYH/69mz0++iYfDfI
7aOAIpCLBLr9EwEbCDgf0aUioYBzXX8PAuhHQ+dyEfpzeM6TKcj6Gw1TNhYmC0/Q+W46zxby
tG9jpmiUIPjIbjA+djfcvfQYW2qOkUZk6e29KJA75hjEiJ4S+e0cKGGQkp3k8G1VBwruYaiV
xfJhjDDjPJpfpaxrC29nCSAhKQHoQfiA1d9dkHj74DKfAnzw2G+HgutVIer6hosSugQ9gu4/
6h7LBcB0hc93K5JCp5jtswxmr10R7KhgikS2Ap0gd9Cu7+9FYYlOZ3cC22c/AhSJpOvs3kHw
Fgaozh11wq7zdK02uaOKjicPYxnneYxdzbaebijWZBmRHsjeul9zkLm8A3xrL/SbT9CZiL+7
u7VEccq+kqSzdEVdZY8e5+P1Fm2zdm8TjGOGGlXR2FGrsAwUDHqe3BRXoBc71kGVgXyYx1Hy
T2k1bGu/qswzvGR0F69mOATu3qoehfOM0+WKOvmOraoITBc4AKjIraBbe1KZL1bT7GGc34zv
MYQ/atme7bsag+lCwSbouQ+SEfsVCXu/bOTdTY8XVgYURSv2UrOrcmLGurtKQ2vqcoYZdGAU
2A8fWjdJi1W+eMC23a+3kBGnadqT8b///ns2uc0yjEYDU4tstrgvI1YzeDlkA+W7zFYp5ibG
6VPnmfywH6MYo6Ji8oln+tP5YH12hGs7/kd6dMModfUjPOtHEYfyUWByKvnoxRl3NIDtWiVs
lMhHbsdRIB+tNIgt/TgJhH50HMXCsgPHVo8TN+XqkU/iiXp0+CQqH9NMP/pxpJ6CCnSS6feW
L9SvPJxEtn5MheZrZQmQ1TJ6QzeR8IJPJaSOjvLS0+GEWH7fWzL9M6OcGIz2sh0N6GQeAfY+
PwLkjHshTOlaP7oZgaJHhHrAFzMAV6wl/T0oKkJEMWqrDPczLgF9VZlawK2fD9dptPzY0WSI
ni+F86X0fEkvCYJDlE+SQXrRAeihak2QHj7Eil6xTs9lthP6vJ0e3eP5I80XrCtnCckRELfD
QBK3wxDJ9WqJ+0LsRXziK+KTQBGvUxHoqokCnCRBYxVdbm8RW30pkiCVxJMgaybu2XvJL4kj
RTyeKGWskR/8tw/x1Mkk8dS1WrqYY2V+LAEzP2nuEh28PSkIEB7sNoo8SGS94GHSohehv0e9
eCxUKWJhtxSXLuf4yhbKPzwJslmaFJrQF2FDKaL5Yj6+vr1K6YZmVRRFNLUNDqnTIhgTpkRw
axE4CMjjfoOABndRPrhbYMzQWTpY3Sy1ZaVrXrh4tmvK6ZpstTEt6tg22PHtbEUNW89k67fV
tsFMbGfLa9j6Jtt6UyrZuk3tvpWtU8M2MNmGLUJ2g0O2bWiyrR9RFdu9VaqubSOT7aSN7UHb
dmKyrR/WJFvnoG0bm2yTltrae7Ota9vEZJu2sd1bperaNjXZZm1s91apurbNDLaZ1dK2tnfA
ts3MYSLjbWz3No41bSsnt/oP0SbkhjnAXm1LnEq29WO5ZCsOKmRzpMzqR0rF1j2kkM3xNqsf
b9cG6MwcKRuWHaqce7fKpuqrlYn+o2V10jFhSoTgCQiBiRBulUSQGeNKkLWt1EyYEkFP/toQ
JiZCbDXNFjHPTIOsa2aJkl6YGRY7zOottlmaKDNsbZTV21oTYZIZVhIW/E9AMOybDElcP+t3
RdiwXmmur6SniKeKeN1kF6OKNBBvn+ymZvumWf2Ib9Y3Nds3LZegzQiZ2WbZE9osM9ssK9us
br0R7KxBmdm+mWrf2kWa5zTNcFqIV7oQWKUuNFZVwSgE0YSA7es12u3W9lVEFQenjUOziW7n
4ASOwSHYao0VTIlA1rh+PWkHTdOupiZQ9EriW22uglEIrrXVhCqYEkGb0I3iq2u5tcUf/T56
V4I/roKkWTKYNDGQ94X3YjAxGTTuImEmjCar0tgAkl5JPGkj3lT6FuKJSbzRNCDxXU2DoqeI
++3Em7pKI3HfJB62E2+ajzYSD03ik3biTfObRuITk3jcTnxXi6noKeJJO/GGDblm4olJPG0n
vuvQrOiVxBu3EoG493+tXXtz47YR/9v6FGiSmfqak0zwBVITpc2dLxdP097Vl7SdufGwFAna
HImiTFJ+pNPv3l0AfMivHAF5PHpAwI8Adhe7ABaL0aOYxGvBqfUS+GgJlXgd+NNTIwU+WkIl
XgduvwQ+WogkXgf+9GKMBHdHc4vEa8Htl/r82dWA58HtYZ/b7CXw8X1usyH4S3zujO9ze8jn
zksEdUaLv8ST4CELnl7CVOBjJVThKfAsfEkT2aOEKEuTMFiqqa/4kr6wSPzs3+e6iZPVRQvY
zlHllxfmfs8D3sAktccLhnjSTHm0b/g7eGldXkyy7k8ut0+HCXQE7ucb5T118cDdpubNXdw0
FTkGGdTzl8kvq7jhkQyVeIxXIenAmPi7iJYkV2kOzQj03MCKMkW/jHWKnhSenu9ScS0uoEzR
bQYa4o70hmgbgmsbkYpMeuzQkZ52CkX6u5BjV6+4FLmuFmDSacEIV6gsHTgOBnpAWRdxESD0
GKRz4mxdGDWJvNpg3E9kdD33NB1/G+nQHFhOiJEtC+HN0C6CJTY5BuBXGP506MEM2JBPen8K
2Tx+1bpQzsgnzslpmYi4eSKO98lNcfKwwKy5awY+LniZnfB/ylJ4pD12uFAIkgzSExipMN5l
CFGAjCrWHkjIeHcdhABplZ7BKKojB42+FsKxGp1+bM1q6DumKQB0vpT8qOc6uuJ3PJFUx3DG
6IOqpwikEytyhp6ACm9DIRnOWA+sPRHX9rzc6xDZF7aG5yNi7I3hdKxTGoAwMeilN3ktPP9t
W0+tGbv2wlDVudaN9y+UXSFdHuM07X0e9cZecx9MRAGIXAZYPnb0qKsuaYZO1VTxMNKWN7wz
vPQUiRqLceTQ607QylHBi20JBEa/R0evP7edw3X45d2pNJrDQozlfxtXeMZh3kXH/k+v3f5I
RGRxGae5U26oyZp1d0m7CJONERsHY6Nr4svddpF8DJiEepwCXbypcUDTe7x0oN7Em7Jec75F
GumNzfXVrknL2w2wrIaWcQ+hJVqSGKjdbqoARIemeHo1qIfuxiMlR0FgpPks3q2F+Dkah2FE
PQx8lmU7NL3zVXlTGwqJKTUUDkFa5bNkg9LFNIxAV/dY2hBhXXMOjKhXebNTYZ2i94zPICHE
ASZszDvYJAkUdb1bFngswbY0D1XtsArqIJDeOJHFyvQQ9xPAIKwxXrABDGZFGI3JAuvnwn3n
BhpCx/plBlCFHH7FcVRvkn8woFYQ8QAb1VSU95tk76SirXmU7jAnbFhoeCZEYRxkAQSB6tt4
W2YZSLY/3pQQrTGakQDr4ZW85lRSQCYDhII49FlS7CSQCDyMxBtpmdsakyaEUQeaUCjAxBg/
eLH2WJZQ77bG/AARzA//trynb8SqTjVcFkUUjdNVe+WFOtlIfaJxhlANCEm8STieNqZ6EAbL
sljccOKIkkM1J2xDAKRkU0Ir9KyDy4fzTj3+BiN8nS+hG5zx1RB8ab5xwcIDzdEEh0uyiFPg
etPFDG9DjBuxYOTrLU1wPE0fbeWRUltzMyVLrgq1SK6hrRDBmLbXkbgzCYYbPWIYLfMrHXAI
JkcdEjXl/tF6vcFDP46IAjjAgpPRuGF6DnxvTqBpzO+JiaiJ7egZzXpzz1Y+zLTZYNnOYLgR
AEAK3cmHvoTKSYfYbaB600uzFZy+DabmYtsScqy5sKd/+r6ViMuBC4BeP5isqPU2wZbzSpnM
ei0xM5nFtvdu62BpE92pVKejh3GAkBnDjXf9xYaWtCbzTiEjukuE/VKSidGtzBGx9K3J3UaR
VAYY8ZWQc6pLifuir4WeqWq0X90aAWaaDyFMN1jFTMiMpjiL6gx/prlCKaxcqIKeAjyQZRd4
huGjEMAgZBIWP9AWL0JpBXobtkLHHsHCkqGkdOn1gqFni0IxcecQHWjI2RLDzBlO9CcqMnLM
NDjaV2png1pHrxc2/FZMhsGW0Cqva5Jh3Q05CRAKGc7NdvQab6hsEEJ3i3VvQNJzBcLyB/BM
EDxo7EqJ1MC1aiiFKzvWeGWF9TAJcKUgDBzvWqa6juQwjUpXQ6Z9Y4ckAWE0LGjuF6vSBwmZ
JhsB4tHNmcbzRIh+kFxsn+gVNtpgsOah75jxg4IwmrQpDJO9QwWhGwFUFTfxLW4hNJ3P2+L6
AUQVgra+7PpAP+xmC2G0+EwtK1QYWY3rviMls2uH2ZZ/z9iaEZNb4dLU4G0zDJwfepYcOztB
nzx7xhzqhd4jL3MLiGLB/GBO/lmcAqEJZa5t4ZW3/C7hgJ1i4m6d46auNSO/blNkaPG9xhDF
eAU13hCtbhIn+eWmrHhUiRwRln7QAqPllFYu9H2KFYJp5ONOOvQP2vRMqeu32vOErmW6RxPd
7SEFohesWBXWXKJr+UHbD1IBGBiDbRUM1nEUhIFTdssJBou+ewOM1iafQjBwo5bqQnuW15Fi
tHdvHWOs9ppHRb5JYPyaQzY0H9CNhVG0gbI4X++qx2aO1m5FOwhpGYtDxWyiVA8R3tsCkpmY
zu1lAjTwSN6IC6TKTT0jn3+c+45vk09zJ6CM/HQ2p5RiYFpUZu4shBcHA+HHeTbHlyjNa8V3
UbLOQckfg0oDo+EKn9mUpP9dYPjWzHJdi+J2F65speXlnLz59T1eIZE1BGczMBhMyduPv35t
kbrZwewmA21nO/UfyOfVbVmteHUCrZ/b4UWP6HseqFgohJemfzw7nRM7JG/LopiTQRnyd1CX
DbQcPd7dGWUza1olDoatpXR6yWKL+wEnX9MemLkeuyD/AojrHd8Be66qu2qbpES8RWiuRyvO
t/Ea+jWSj+pLB1bgXpDzs49QLYta80yEF47W+Yqv76OdUOnfWnf+iXVHY39QzofWkfNPopwF
5eAPY6/SNGMsDQPy7seff3j/Sf4KVoRPPpyfvY/Of/j3nGR7f9TpUUMX10lFJuvBHzl/8zjV
Iedvn8jbAXqWbWPzTh9nolD5s6dST8/6Gi5puISGBgNAMR08f/NRZuqbHEMNreCpelvhSzUE
oyoAQOj6/Uw2FqX04WP8AFLtQWqc8hiQekDbsxkCOg+fSqG3qDsHMw64yI6d2E7D0OMI6D2q
od0DOiD6F+RHoOWjZhzjyysCdO7qkwXDX1abNfz4fOtdyiyQColNLXKqOIa8az+8PR/0DGB7
QHVnAMBCBDi3+0y07fm358M+SG0MIkEh1R22FmD85aBGnof0OD1/SA8EPD2nT6baLxHYd1Bx
nZ4/ooco6vepGYZLyjJMZQ/yukNAZvnYZPRt/EXEAh/8hFHACYmq+Daqt/kmEnuLyyuQYDcG
EfbDQV6GJ85eGiWgFLU5FHP5QAICB2PAt+d2onIjs0Nmx8PMvjXMHDiYWeJFzRUqRVEZC3M6
SZ8ztG0YtcmfO+A6ueK4jJcK+BrxnRN8GZRheDiWrDpc6mMW6i+7POLQvMCNIpUvQms0KuIa
6xxjt8TxIL/HAuwW3kR4jC7KZNtsF59tDfKFgnPLFEZc0FAwW2IuXgmaZSQJSBDibYCpuJqc
hXg9mxuQhOE/DBQeJ35GlpSA8AHTL31CU7xj0UtJ4uDte65A4B5mSNjg/vRHGVxKPEa+c+n3
xPPFN5kGDwwxS5YSz8EU/OyLcg7hCaGBqLXIA0X6doGwAwv9lYOGXpMt2D4J6DrQlsITOMcT
W6gGpRack6sd6lDoynqAwHC8+F1N94vUcnPyfi9uwc/48kWaz3d9FFVNzed7NqVPi5EPowqK
0Xdn5//4fpDqhzD0w3Sk2EYimgSwRYp8TO20zwUMhGIlek4IEDKOze1BDgc9KjvjIpLzzWyD
XMZjwWbJIHdg+Yp/m3KXXEVtOQRP8OmDzAwmqyj/0VUlUavdJhKdg/JjWx6ih4MuZL7g9iez
UxqLxg3wA4rqlGA2XEBby7qLzCj6zB9k9cRQJC2IqBVqsciBVaGQ3RtkD4HMkL3J0bOyvPpN
mZ5iDIoZduGwU6SdQGqgRLzNE9WFyE9Vtds2WMjBJ1CeDQqJI7bkmQKZeEaXG3jYwp757mSP
CRiST8NeYtS27IPbS4yKIzyHs5eYzRz/kPYSczzbOqS9xFzbpYe0l5hn4XThcPYS82Ba8oVK
mPm2E2goYRBb1D5fpoQZo3hZyRcoYcZ8HBNHKWEGMwj2O0qYBa5vj1DCLAhd9wuUMAsdn3bK
6kOGS25AmTs7VeEdxUF4kG31FyjTkBxXXGwA4KqkOCoxH+ZSJJ32SUv1/moyebeOt+J0Mowg
yBvWZHLNi900Ly7VbXdkmpHrpLy1cWa5mt6XSVNO16vt9Kq+teiUAjCxPf/9+HJUlpusborF
8eRIlJfnoad3gR/57uRoysWtc1PIAl+S7Y78FNe3fL1+/W1d8C2krWRvfSPfIQGXe6uUnJR1
XsSX/EQ8WL5O28VgCT9LLn+DAgXxqA3vMPwSCu8pv8GlKRHq7PUGF9JvFvBmwU/ym/C9fJ2n
bapcFK5SXi02CeYqpxXHRPjcqjeSgyli8Xo5SJvi4gCQLOXL3SWkV00ibhZcCGWEFMHaVCA8
4pq8xbP9/7rgaR6L31/n2eImB/1XfllZ+lxZaGIer0ndpBIqr7fr+B5Mpw3WqiihH8uKbHbr
9QTYKN5u+SZFKlbQ7oWIfVXFBfQOmlQRmlSRsCEW0MOqvai5FuozkL26juL1bXxfR5LmKWAl
UgPN4EMExEc7ZS21dLlrFkCgyRHQYJZnuAVXL+DrFijcrGbw/FVRXy7KDSSJ507hwb2p11dm
U+SdDbIQqZOjstzW7Wf08oKxr8AOWtj4gLLYNl0KPDKtlumsyDdlFSXlbtMsAtEeYON0tgaD
aM1v+HoBmnlypLYMIFUkTo6SclOXQJ6muQckHlfre9kCTPlkvaYUb9nYyzdIvbmMFwBYxIBU
3U6OliD8ydVinW92d8jGfH0iXqcJNnC3ndoWDWDK6cMULJwcvfnw4Zfo7G8/vH+3ONmuLk9E
uRMpG1M8WQ1PzfLL6Q2wmAdTe99xTy6TZMpOlPlK2TKIY5fGsePwIEF95HHHT12WptwJrfjk
BpeKd79Nn7WAn+4+JDyvslm72g3dDEz21Tf/hXHg818u/vcVmUqOI5AmP33+EyRP/g9P2U47
L6oBAA==

--=_5aee5cdc.zEbxaqK9/iCmq7DlX0jmOWaUbrRh3+k4ZSE81n3dLGkkpD7B
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="reproduce-yocto-lkp-hsw01-100:20180506082503:x86_64-randconfig-v0-05051634:4.17.0-rc3-00012-g27e2ce5:1"

#!/bin/bash

kernel=$1
initrd=yocto-trinity-x86_64.cgz

wget --no-clobber https://github.com/fengguang/reproduce-kernel-bug/raw/master/yocto/$initrd

kvm=(
	qemu-system-x86_64
	-enable-kvm
	-cpu Haswell,+smep
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
	console=tty0
	earlyprintk=ttyS0,115200
	console=ttyS0,115200
	vga=normal
	rw
	drbd.minor_count=8
	rcuperf.shutdown=0
)

"${kvm[@]}" -append "${append[*]}"

--=_5aee5cdc.zEbxaqK9/iCmq7DlX0jmOWaUbrRh3+k4ZSE81n3dLGkkpD7B
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="config-4.17.0-rc3-00012-g27e2ce5"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 4.17.0-rc3 Kernel Configuration
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
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_ARCH_HAS_FILTER_PGPROT=y
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
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_PGTABLE_LEVELS=4
CONFIG_CONSTRUCTORS=y
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y
CONFIG_THREAD_INFO_IN_TASK=y

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
CONFIG_KERNEL_BZIP2=y
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
# CONFIG_SWAP is not set
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
# CONFIG_POSIX_MQUEUE is not set
CONFIG_CROSS_MEMORY_ATTACH=y
# CONFIG_USELIB is not set
CONFIG_AUDIT=y
CONFIG_HAVE_ARCH_AUDITSYSCALL=y
CONFIG_AUDITSYSCALL=y
CONFIG_AUDIT_WATCH=y
CONFIG_AUDIT_TREE=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_IRQ_EFFECTIVE_AFF_MASK=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_GENERIC_IRQ_MIGRATION=y
CONFIG_GENERIC_IRQ_CHIP=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_SIM=y
CONFIG_IRQ_DOMAIN_HIERARCHY=y
CONFIG_GENERIC_IRQ_MATRIX_ALLOCATOR=y
CONFIG_GENERIC_IRQ_RESERVATION_MODE=y
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_GENERIC_IRQ_DEBUGFS=y
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
CONFIG_NO_HZ=y
# CONFIG_HIGH_RES_TIMERS is not set

#
# CPU/Task time and stats accounting
#
CONFIG_VIRT_CPU_ACCOUNTING=y
CONFIG_VIRT_CPU_ACCOUNTING_GEN=y
CONFIG_IRQ_TIME_ACCOUNTING=y
CONFIG_BSD_PROCESS_ACCT=y
CONFIG_BSD_PROCESS_ACCT_V3=y
CONFIG_TASKSTATS=y
# CONFIG_TASK_DELAY_ACCT is not set
# CONFIG_TASK_XACCT is not set
CONFIG_CPU_ISOLATION=y

#
# RCU Subsystem
#
CONFIG_TREE_RCU=y
# CONFIG_RCU_EXPERT is not set
CONFIG_SRCU=y
CONFIG_TREE_SRCU=y
CONFIG_TASKS_RCU=y
CONFIG_RCU_STALL_COMMON=y
CONFIG_RCU_NEED_SEGCBLIST=y
CONFIG_CONTEXT_TRACKING=y
# CONFIG_CONTEXT_TRACKING_FORCE is not set
CONFIG_RCU_NOCB_CPU=y
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=20
CONFIG_LOG_CPU_MAX_BUF_SHIFT=12
CONFIG_PRINTK_SAFE_LOG_BUF_SHIFT=13
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH=y
CONFIG_ARCH_SUPPORTS_INT128=y
CONFIG_CGROUPS=y
CONFIG_PAGE_COUNTER=y
# CONFIG_MEMCG is not set
# CONFIG_BLK_CGROUP is not set
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
CONFIG_CFS_BANDWIDTH=y
# CONFIG_RT_GROUP_SCHED is not set
CONFIG_CGROUP_PIDS=y
CONFIG_CGROUP_RDMA=y
CONFIG_CGROUP_FREEZER=y
CONFIG_CGROUP_HUGETLB=y
CONFIG_CPUSETS=y
CONFIG_PROC_PID_CPUSET=y
# CONFIG_CGROUP_DEVICE is not set
# CONFIG_CGROUP_CPUACCT is not set
# CONFIG_CGROUP_PERF is not set
CONFIG_CGROUP_BPF=y
CONFIG_CGROUP_DEBUG=y
CONFIG_SOCK_CGROUP_DATA=y
# CONFIG_NAMESPACES is not set
CONFIG_SCHED_AUTOGROUP=y
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
# CONFIG_RD_BZIP2 is not set
# CONFIG_RD_LZMA is not set
# CONFIG_RD_XZ is not set
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
CONFIG_SYSFS_SYSCALL=y
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_FHANDLE=y
# CONFIG_POSIX_TIMERS is not set
CONFIG_PRINTK=y
CONFIG_PRINTK_NMI=y
CONFIG_BUG=y
# CONFIG_PCSPKR_PLATFORM is not set
# CONFIG_BASE_FULL is not set
CONFIG_FUTEX=y
CONFIG_FUTEX_PI=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
# CONFIG_EVENTFD is not set
CONFIG_SHMEM=y
# CONFIG_AIO is not set
# CONFIG_ADVISE_SYSCALLS is not set
CONFIG_MEMBARRIER=y
CONFIG_CHECKPOINT_RESTORE=y
CONFIG_KALLSYMS=y
# CONFIG_KALLSYMS_ALL is not set
CONFIG_KALLSYMS_ABSOLUTE_PERCPU=y
CONFIG_KALLSYMS_BASE_RELATIVE=y
CONFIG_BPF_SYSCALL=y
# CONFIG_USERFAULTFD is not set
CONFIG_ARCH_HAS_MEMBARRIER_SYNC_CORE=y
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y
# CONFIG_PC104 is not set

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=y
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
# CONFIG_SLUB is not set
CONFIG_SLOB=y
# CONFIG_SLAB_MERGE_DEFAULT is not set
CONFIG_PROFILING=y
CONFIG_TRACEPOINTS=y
CONFIG_OPROFILE=y
# CONFIG_OPROFILE_EVENT_MULTIPLEX is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_JUMP_LABEL is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_FUNCTION_ERROR_INJECTION=y
CONFIG_HAVE_NMI=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_CONTIGUOUS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_ARCH_HAS_FORTIFY_SOURCE=y
CONFIG_ARCH_HAS_SET_MEMORY=y
CONFIG_HAVE_ARCH_THREAD_STRUCT_WHITELIST=y
CONFIG_ARCH_WANTS_DYNAMIC_TASK_STRUCT=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_CLK=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_HARDLOCKUP_DETECTOR_PERF=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_HAVE_RCU_TABLE_FREE=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_HAVE_GCC_PLUGINS=y
CONFIG_GCC_PLUGINS=y
# CONFIG_GCC_PLUGIN_CYC_COMPLEXITY is not set
CONFIG_GCC_PLUGIN_SANCOV=y
# CONFIG_GCC_PLUGIN_LATENT_ENTROPY is not set
# CONFIG_GCC_PLUGIN_STRUCTLEAK is not set
# CONFIG_GCC_PLUGIN_RANDSTRUCT is not set
CONFIG_HAVE_CC_STACKPROTECTOR=y
CONFIG_CC_STACKPROTECTOR_NONE=y
# CONFIG_CC_STACKPROTECTOR_REGULAR is not set
# CONFIG_CC_STACKPROTECTOR_STRONG is not set
# CONFIG_CC_STACKPROTECTOR_AUTO is not set
CONFIG_HAVE_ARCH_WITHIN_STACK_FRAMES=y
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_VIRT_CPU_ACCOUNTING_GEN=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD=y
CONFIG_HAVE_ARCH_HUGE_VMAP=y
CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_HAVE_MOD_ARCH_SPECIFIC=y
CONFIG_MODULES_USE_ELF_RELA=y
CONFIG_HAVE_IRQ_EXIT_ON_IRQ_STACK=y
CONFIG_ARCH_HAS_ELF_RANDOMIZE=y
CONFIG_HAVE_ARCH_MMAP_RND_BITS=y
CONFIG_HAVE_EXIT_THREAD=y
CONFIG_ARCH_MMAP_RND_BITS=28
CONFIG_HAVE_ARCH_MMAP_RND_COMPAT_BITS=y
CONFIG_ARCH_MMAP_RND_COMPAT_BITS=8
CONFIG_HAVE_ARCH_COMPAT_MMAP_BASES=y
CONFIG_HAVE_COPY_THREAD_TLS=y
CONFIG_HAVE_STACK_VALIDATION=y
CONFIG_ISA_BUS_API=y
CONFIG_HAVE_ARCH_VMAP_STACK=y
# CONFIG_VMAP_STACK is not set
CONFIG_ARCH_HAS_STRICT_KERNEL_RWX=y
CONFIG_STRICT_KERNEL_RWX=y
CONFIG_ARCH_HAS_STRICT_MODULE_RWX=y
CONFIG_ARCH_HAS_REFCOUNT=y
CONFIG_REFCOUNT_FULL=y

#
# GCOV-based kernel profiling
#
CONFIG_GCOV_KERNEL=y
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
# CONFIG_GCOV_PROFILE_ALL is not set
CONFIG_GCOV_FORMAT_AUTODETECT=y
# CONFIG_GCOV_FORMAT_3_4 is not set
# CONFIG_GCOV_FORMAT_4_7 is not set
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=1
# CONFIG_MODULES is not set
CONFIG_MODULES_TREE_LOOKUP=y
CONFIG_BLOCK=y
CONFIG_BLK_SCSI_REQUEST=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
CONFIG_BLK_DEV_INTEGRITY=y
CONFIG_BLK_DEV_ZONED=y
CONFIG_BLK_CMDLINE_PARSER=y
CONFIG_BLK_WBT=y
CONFIG_BLK_WBT_SQ=y
# CONFIG_BLK_WBT_MQ is not set
CONFIG_BLK_DEBUG_FS=y
# CONFIG_BLK_SED_OPAL is not set

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
# CONFIG_ACORN_PARTITION is not set
# CONFIG_AIX_PARTITION is not set
CONFIG_OSF_PARTITION=y
# CONFIG_AMIGA_PARTITION is not set
# CONFIG_ATARI_PARTITION is not set
# CONFIG_MAC_PARTITION is not set
CONFIG_MSDOS_PARTITION=y
# CONFIG_BSD_DISKLABEL is not set
CONFIG_MINIX_SUBPARTITION=y
# CONFIG_SOLARIS_X86_PARTITION is not set
CONFIG_UNIXWARE_DISKLABEL=y
CONFIG_LDM_PARTITION=y
CONFIG_LDM_DEBUG=y
# CONFIG_SGI_PARTITION is not set
CONFIG_ULTRIX_PARTITION=y
# CONFIG_SUN_PARTITION is not set
CONFIG_KARMA_PARTITION=y
CONFIG_EFI_PARTITION=y
# CONFIG_SYSV68_PARTITION is not set
CONFIG_CMDLINE_PARTITION=y
CONFIG_BLOCK_COMPAT=y
CONFIG_BLK_MQ_PCI=y
CONFIG_BLK_MQ_VIRTIO=y
CONFIG_BLK_MQ_RDMA=y

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
CONFIG_MQ_IOSCHED_DEADLINE=y
CONFIG_MQ_IOSCHED_KYBER=y
CONFIG_IOSCHED_BFQ=y
CONFIG_PADATA=y
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
CONFIG_ARCH_HAS_SYNC_CORE_BEFORE_USERMODE=y
CONFIG_ARCH_HAS_SYSCALL_WRAPPER=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
CONFIG_SMP=y
CONFIG_X86_FEATURE_NAMES=y
# CONFIG_X86_X2APIC is not set
# CONFIG_X86_MPPARSE is not set
# CONFIG_GOLDFISH is not set
# CONFIG_RETPOLINE is not set
CONFIG_INTEL_RDT=y
# CONFIG_X86_EXTENDED_PLATFORM is not set
CONFIG_X86_INTEL_LPSS=y
CONFIG_X86_AMD_PLATFORM_DEVICE=y
CONFIG_IOSF_MBI=y
CONFIG_IOSF_MBI_DEBUG=y
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
# CONFIG_JAILHOUSE_GUEST is not set
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
# CONFIG_DMI is not set
# CONFIG_GART_IOMMU is not set
# CONFIG_CALGARY_IOMMU is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_MAXSMP=y
CONFIG_NR_CPUS_RANGE_BEGIN=8192
CONFIG_NR_CPUS_RANGE_END=8192
CONFIG_NR_CPUS_DEFAULT=8192
CONFIG_NR_CPUS=8192
CONFIG_SCHED_SMT=y
CONFIG_SCHED_MC=y
CONFIG_SCHED_MC_PRIO=y
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
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
# CONFIG_PERF_EVENTS_INTEL_CSTATE is not set
CONFIG_PERF_EVENTS_AMD_POWER=y
CONFIG_X86_VSYSCALL_EMULATION=y
# CONFIG_I8K is not set
# CONFIG_MICROCODE is not set
# CONFIG_X86_MSR is not set
CONFIG_X86_CPUID=y
# CONFIG_X86_5LEVEL is not set
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_ARCH_HAS_MEM_ENCRYPT=y
# CONFIG_AMD_MEM_ENCRYPT is not set
# CONFIG_NUMA is not set
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
# CONFIG_ARCH_MEMORY_PROBE is not set
CONFIG_ARCH_PROC_KCORE_TEXT=y
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
CONFIG_HAVE_GENERIC_GUP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
# CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE is not set
# CONFIG_MEMORY_HOTREMOVE is not set
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION=y
CONFIG_ARCH_ENABLE_THP_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
# CONFIG_BOUNCE is not set
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_TRANSPARENT_HUGEPAGE=y
CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y
# CONFIG_TRANSPARENT_HUGEPAGE_MADVISE is not set
CONFIG_ARCH_WANTS_THP_SWAP=y
CONFIG_THP_SWAP=y
CONFIG_TRANSPARENT_HUGE_PAGECACHE=y
# CONFIG_CLEANCACHE is not set
CONFIG_CMA=y
# CONFIG_CMA_DEBUG is not set
# CONFIG_CMA_DEBUGFS is not set
CONFIG_CMA_AREAS=7
CONFIG_MEM_SOFT_DIRTY=y
CONFIG_ZPOOL=y
# CONFIG_ZBUD is not set
CONFIG_Z3FOLD=y
CONFIG_ZSMALLOC=y
# CONFIG_PGTABLE_MAPPING is not set
CONFIG_ZSMALLOC_STAT=y
CONFIG_GENERIC_EARLY_IOREMAP=y
# CONFIG_DEFERRED_STRUCT_PAGE_INIT is not set
CONFIG_IDLE_PAGE_TRACKING=y
CONFIG_ARCH_HAS_ZONE_DEVICE=y
CONFIG_ARCH_USES_HIGH_VMA_FLAGS=y
CONFIG_ARCH_HAS_PKEYS=y
CONFIG_PERCPU_STATS=y
# CONFIG_GUP_BENCHMARK is not set
# CONFIG_X86_PMEM_LEGACY is not set
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
# CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
CONFIG_MTRR_SANITIZER=y
CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=0
CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_ARCH_RANDOM=y
# CONFIG_X86_SMAP is not set
# CONFIG_X86_INTEL_UMIP is not set
CONFIG_X86_INTEL_MPX=y
CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS=y
CONFIG_EFI=y
CONFIG_EFI_STUB=y
# CONFIG_EFI_MIXED is not set
# CONFIG_SECCOMP is not set
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
CONFIG_HZ_1000=y
CONFIG_HZ=1000
# CONFIG_KEXEC is not set
# CONFIG_KEXEC_FILE is not set
# CONFIG_CRASH_DUMP is not set
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
CONFIG_RANDOMIZE_BASE=y
CONFIG_X86_NEED_RELOCS=y
CONFIG_PHYSICAL_ALIGN=0x200000
# CONFIG_RANDOMIZE_MEMORY is not set
CONFIG_HOTPLUG_CPU=y
CONFIG_BOOTPARAM_HOTPLUG_CPU0=y
CONFIG_DEBUG_HOTPLUG_CPU0=y
CONFIG_LEGACY_VSYSCALL_EMULATE=y
# CONFIG_LEGACY_VSYSCALL_NONE is not set
# CONFIG_CMDLINE_BOOL is not set
# CONFIG_MODIFY_LDT_SYSCALL is not set
CONFIG_HAVE_LIVEPATCH=y
CONFIG_ARCH_HAS_ADD_PAGES=y
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_SUSPEND_SKIP_SYNC=y
CONFIG_PM_SLEEP=y
CONFIG_PM_SLEEP_SMP=y
# CONFIG_PM_AUTOSLEEP is not set
CONFIG_PM_WAKELOCKS=y
CONFIG_PM_WAKELOCKS_LIMIT=100
CONFIG_PM_WAKELOCKS_GC=y
CONFIG_PM=y
CONFIG_PM_DEBUG=y
# CONFIG_PM_ADVANCED_DEBUG is not set
CONFIG_PM_SLEEP_DEBUG=y
CONFIG_PM_TRACE=y
CONFIG_PM_TRACE_RTC=y
CONFIG_PM_CLK=y
CONFIG_WQ_POWER_EFFICIENT_DEFAULT=y
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=y
CONFIG_ACPI_DEBUGGER=y
# CONFIG_ACPI_DEBUGGER_USER is not set
# CONFIG_ACPI_SPCR_TABLE is not set
CONFIG_ACPI_LPIT=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS_POWER is not set
# CONFIG_ACPI_REV_OVERRIDE_POSSIBLE is not set
CONFIG_ACPI_EC_DEBUGFS=y
# CONFIG_ACPI_AC is not set
# CONFIG_ACPI_BATTERY is not set
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_VIDEO=y
CONFIG_ACPI_FAN=y
CONFIG_ACPI_TAD=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_CPU_FREQ_PSS=y
CONFIG_ACPI_PROCESSOR_CSTATE=y
CONFIG_ACPI_PROCESSOR_IDLE=y
CONFIG_ACPI_CPPC_LIB=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_IPMI=y
CONFIG_ACPI_HOTPLUG_CPU=y
CONFIG_ACPI_PROCESSOR_AGGREGATOR=y
# CONFIG_ACPI_THERMAL is not set
CONFIG_ACPI_CUSTOM_DSDT_FILE=""
CONFIG_ARCH_HAS_ACPI_TABLE_UPGRADE=y
# CONFIG_ACPI_TABLE_UPGRADE is not set
CONFIG_ACPI_DEBUG=y
CONFIG_ACPI_PCI_SLOT=y
CONFIG_ACPI_CONTAINER=y
CONFIG_ACPI_HOTPLUG_MEMORY=y
CONFIG_ACPI_HOTPLUG_IOAPIC=y
CONFIG_ACPI_SBS=y
CONFIG_ACPI_HED=y
# CONFIG_ACPI_CUSTOM_METHOD is not set
CONFIG_ACPI_BGRT=y
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
CONFIG_ACPI_NFIT=y
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
# CONFIG_ACPI_APEI is not set
CONFIG_DPTF_POWER=y
# CONFIG_PMIC_OPREGION is not set
# CONFIG_ACPI_CONFIGFS is not set
CONFIG_X86_PM_TIMER=y
# CONFIG_SFI is not set

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_GOV_ATTR_SET=y
CONFIG_CPU_FREQ_GOV_COMMON=y
# CONFIG_CPU_FREQ_STAT is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_SCHEDUTIL is not set
# CONFIG_CPU_FREQ_GOV_PERFORMANCE is not set
CONFIG_CPU_FREQ_GOV_POWERSAVE=y
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y
CONFIG_CPU_FREQ_GOV_SCHEDUTIL=y

#
# CPU frequency scaling drivers
#
CONFIG_X86_INTEL_PSTATE=y
CONFIG_X86_PCC_CPUFREQ=y
CONFIG_X86_ACPI_CPUFREQ=y
# CONFIG_X86_ACPI_CPUFREQ_CPB is not set
CONFIG_X86_POWERNOW_K8=y
CONFIG_X86_AMD_FREQ_SENSITIVITY=y
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
# CONFIG_CPU_IDLE_GOV_LADDER is not set
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_INTEL_IDLE is not set

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
CONFIG_PCI_QUIRKS=y
# CONFIG_PCI_DEBUG is not set
CONFIG_PCI_REALLOC_ENABLE_AUTO=y
# CONFIG_PCI_STUB is not set
CONFIG_PCI_ATS=y
CONFIG_PCI_LOCKLESS_CONFIG=y
CONFIG_PCI_IOV=y
CONFIG_PCI_PRI=y
CONFIG_PCI_PASID=y
CONFIG_PCI_LABEL=y
CONFIG_HOTPLUG_PCI=y
# CONFIG_HOTPLUG_PCI_ACPI is not set
CONFIG_HOTPLUG_PCI_CPCI=y
CONFIG_HOTPLUG_PCI_CPCI_ZT5550=y
CONFIG_HOTPLUG_PCI_CPCI_GENERIC=y
CONFIG_HOTPLUG_PCI_SHPC=y

#
# Cadence PCIe controllers support
#

#
# DesignWare PCI Core Support
#

#
# PCI host controller drivers
#

#
# PCI Endpoint
#
# CONFIG_PCI_ENDPOINT is not set

#
# PCI switch controller drivers
#
CONFIG_PCI_SW_SWITCHTEC=y
# CONFIG_ISA_BUS is not set
# CONFIG_ISA_DMA_API is not set
CONFIG_AMD_NB=y
# CONFIG_PCCARD is not set
# CONFIG_RAPIDIO is not set
# CONFIG_X86_SYSFB is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ELFCORE=y
CONFIG_BINFMT_SCRIPT=y
CONFIG_BINFMT_MISC=y
# CONFIG_COREDUMP is not set
# CONFIG_IA32_EMULATION is not set
CONFIG_X86_X32=y
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_SYSVIPC_COMPAT=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_NET=y
CONFIG_NET_INGRESS=y
CONFIG_NET_EGRESS=y

#
# Networking options
#
# CONFIG_PACKET is not set
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
# CONFIG_TLS is not set
CONFIG_XFRM=y
CONFIG_XFRM_OFFLOAD=y
CONFIG_XFRM_ALGO=y
CONFIG_XFRM_USER=y
CONFIG_XFRM_SUB_POLICY=y
CONFIG_XFRM_MIGRATE=y
# CONFIG_XFRM_STATISTICS is not set
CONFIG_XFRM_IPCOMP=y
CONFIG_NET_KEY=y
CONFIG_NET_KEY_MIGRATE=y
# CONFIG_SMC is not set
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
CONFIG_IP_ADVANCED_ROUTER=y
CONFIG_IP_FIB_TRIE_STATS=y
CONFIG_IP_MULTIPLE_TABLES=y
CONFIG_IP_ROUTE_MULTIPATH=y
CONFIG_IP_ROUTE_VERBOSE=y
CONFIG_IP_ROUTE_CLASSID=y
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
# CONFIG_IP_PNP_BOOTP is not set
# CONFIG_IP_PNP_RARP is not set
# CONFIG_NET_IPIP is not set
CONFIG_NET_IPGRE_DEMUX=y
CONFIG_NET_IP_TUNNEL=y
CONFIG_NET_IPGRE=y
# CONFIG_NET_IPGRE_BROADCAST is not set
CONFIG_IP_MROUTE_COMMON=y
# CONFIG_IP_MROUTE is not set
CONFIG_SYN_COOKIES=y
CONFIG_NET_UDP_TUNNEL=y
CONFIG_NET_FOU=y
# CONFIG_NET_FOU_IP_TUNNELS is not set
# CONFIG_INET_AH is not set
CONFIG_INET_ESP=y
CONFIG_INET_ESP_OFFLOAD=y
# CONFIG_INET_IPCOMP is not set
CONFIG_INET_TUNNEL=y
CONFIG_INET_XFRM_MODE_TRANSPORT=y
# CONFIG_INET_XFRM_MODE_TUNNEL is not set
# CONFIG_INET_XFRM_MODE_BEET is not set
# CONFIG_INET_DIAG is not set
# CONFIG_TCP_CONG_ADVANCED is not set
CONFIG_TCP_CONG_CUBIC=y
CONFIG_DEFAULT_TCP_CONG="cubic"
CONFIG_TCP_MD5SIG=y
CONFIG_IPV6=y
# CONFIG_IPV6_ROUTER_PREF is not set
# CONFIG_IPV6_OPTIMISTIC_DAD is not set
CONFIG_INET6_AH=y
CONFIG_INET6_ESP=y
CONFIG_INET6_ESP_OFFLOAD=y
CONFIG_INET6_IPCOMP=y
# CONFIG_IPV6_MIP6 is not set
CONFIG_IPV6_ILA=y
CONFIG_INET6_XFRM_TUNNEL=y
CONFIG_INET6_TUNNEL=y
CONFIG_INET6_XFRM_MODE_TRANSPORT=y
# CONFIG_INET6_XFRM_MODE_TUNNEL is not set
CONFIG_INET6_XFRM_MODE_BEET=y
CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION=y
CONFIG_IPV6_SIT=y
# CONFIG_IPV6_SIT_6RD is not set
CONFIG_IPV6_NDISC_NODETYPE=y
CONFIG_IPV6_TUNNEL=y
CONFIG_IPV6_GRE=y
CONFIG_IPV6_FOU=y
# CONFIG_IPV6_MULTIPLE_TABLES is not set
CONFIG_IPV6_MROUTE=y
CONFIG_IPV6_MROUTE_MULTIPLE_TABLES=y
# CONFIG_IPV6_PIMSM_V2 is not set
# CONFIG_IPV6_SEG6_LWTUNNEL is not set
CONFIG_IPV6_SEG6_HMAC=y
CONFIG_NETLABEL=y
# CONFIG_NETWORK_SECMARK is not set
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
CONFIG_NETFILTER=y
CONFIG_NETFILTER_ADVANCED=y
CONFIG_BRIDGE_NETFILTER=y

#
# Core Netfilter Configuration
#
# CONFIG_NETFILTER_INGRESS is not set
CONFIG_NETFILTER_NETLINK=y
CONFIG_NETFILTER_FAMILY_BRIDGE=y
# CONFIG_NETFILTER_NETLINK_ACCT is not set
CONFIG_NETFILTER_NETLINK_QUEUE=y
# CONFIG_NETFILTER_NETLINK_LOG is not set
# CONFIG_NF_CONNTRACK is not set
CONFIG_NF_LOG_COMMON=y
# CONFIG_NF_LOG_NETDEV is not set
# CONFIG_NF_TABLES is not set
CONFIG_NETFILTER_XTABLES=y

#
# Xtables combined modules
#
CONFIG_NETFILTER_XT_MARK=y
CONFIG_NETFILTER_XT_SET=y

#
# Xtables targets
#
CONFIG_NETFILTER_XT_TARGET_AUDIT=y
CONFIG_NETFILTER_XT_TARGET_CLASSIFY=y
CONFIG_NETFILTER_XT_TARGET_HMARK=y
CONFIG_NETFILTER_XT_TARGET_IDLETIMER=y
CONFIG_NETFILTER_XT_TARGET_LED=y
# CONFIG_NETFILTER_XT_TARGET_LOG is not set
CONFIG_NETFILTER_XT_TARGET_MARK=y
# CONFIG_NETFILTER_XT_TARGET_NFLOG is not set
CONFIG_NETFILTER_XT_TARGET_NFQUEUE=y
CONFIG_NETFILTER_XT_TARGET_RATEEST=y
CONFIG_NETFILTER_XT_TARGET_TEE=y
CONFIG_NETFILTER_XT_TARGET_TRACE=y
# CONFIG_NETFILTER_XT_TARGET_TCPMSS is not set

#
# Xtables matches
#
# CONFIG_NETFILTER_XT_MATCH_ADDRTYPE is not set
CONFIG_NETFILTER_XT_MATCH_BPF=y
# CONFIG_NETFILTER_XT_MATCH_CGROUP is not set
CONFIG_NETFILTER_XT_MATCH_COMMENT=y
CONFIG_NETFILTER_XT_MATCH_CPU=y
CONFIG_NETFILTER_XT_MATCH_DCCP=y
# CONFIG_NETFILTER_XT_MATCH_DEVGROUP is not set
# CONFIG_NETFILTER_XT_MATCH_DSCP is not set
CONFIG_NETFILTER_XT_MATCH_ECN=y
CONFIG_NETFILTER_XT_MATCH_ESP=y
CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=y
CONFIG_NETFILTER_XT_MATCH_HL=y
CONFIG_NETFILTER_XT_MATCH_IPCOMP=y
# CONFIG_NETFILTER_XT_MATCH_IPRANGE is not set
# CONFIG_NETFILTER_XT_MATCH_L2TP is not set
CONFIG_NETFILTER_XT_MATCH_LENGTH=y
CONFIG_NETFILTER_XT_MATCH_LIMIT=y
# CONFIG_NETFILTER_XT_MATCH_MAC is not set
# CONFIG_NETFILTER_XT_MATCH_MARK is not set
CONFIG_NETFILTER_XT_MATCH_MULTIPORT=y
# CONFIG_NETFILTER_XT_MATCH_NFACCT is not set
CONFIG_NETFILTER_XT_MATCH_OSF=y
CONFIG_NETFILTER_XT_MATCH_OWNER=y
CONFIG_NETFILTER_XT_MATCH_POLICY=y
CONFIG_NETFILTER_XT_MATCH_PHYSDEV=y
CONFIG_NETFILTER_XT_MATCH_PKTTYPE=y
CONFIG_NETFILTER_XT_MATCH_QUOTA=y
# CONFIG_NETFILTER_XT_MATCH_RATEEST is not set
# CONFIG_NETFILTER_XT_MATCH_REALM is not set
CONFIG_NETFILTER_XT_MATCH_RECENT=y
# CONFIG_NETFILTER_XT_MATCH_SCTP is not set
CONFIG_NETFILTER_XT_MATCH_SOCKET=y
# CONFIG_NETFILTER_XT_MATCH_STATISTIC is not set
CONFIG_NETFILTER_XT_MATCH_STRING=y
CONFIG_NETFILTER_XT_MATCH_TCPMSS=y
CONFIG_NETFILTER_XT_MATCH_TIME=y
# CONFIG_NETFILTER_XT_MATCH_U32 is not set
CONFIG_IP_SET=y
CONFIG_IP_SET_MAX=256
CONFIG_IP_SET_BITMAP_IP=y
# CONFIG_IP_SET_BITMAP_IPMAC is not set
CONFIG_IP_SET_BITMAP_PORT=y
CONFIG_IP_SET_HASH_IP=y
# CONFIG_IP_SET_HASH_IPMARK is not set
CONFIG_IP_SET_HASH_IPPORT=y
# CONFIG_IP_SET_HASH_IPPORTIP is not set
CONFIG_IP_SET_HASH_IPPORTNET=y
# CONFIG_IP_SET_HASH_IPMAC is not set
CONFIG_IP_SET_HASH_MAC=y
CONFIG_IP_SET_HASH_NETPORTNET=y
CONFIG_IP_SET_HASH_NET=y
# CONFIG_IP_SET_HASH_NETNET is not set
CONFIG_IP_SET_HASH_NETPORT=y
CONFIG_IP_SET_HASH_NETIFACE=y
# CONFIG_IP_SET_LIST_SET is not set
CONFIG_IP_VS=y
CONFIG_IP_VS_IPV6=y
CONFIG_IP_VS_DEBUG=y
CONFIG_IP_VS_TAB_BITS=12

#
# IPVS transport protocol load balancing support
#
CONFIG_IP_VS_PROTO_TCP=y
# CONFIG_IP_VS_PROTO_UDP is not set
# CONFIG_IP_VS_PROTO_ESP is not set
# CONFIG_IP_VS_PROTO_AH is not set
CONFIG_IP_VS_PROTO_SCTP=y

#
# IPVS scheduler
#
CONFIG_IP_VS_RR=y
CONFIG_IP_VS_WRR=y
# CONFIG_IP_VS_LC is not set
# CONFIG_IP_VS_WLC is not set
CONFIG_IP_VS_FO=y
# CONFIG_IP_VS_OVF is not set
CONFIG_IP_VS_LBLC=y
CONFIG_IP_VS_LBLCR=y
CONFIG_IP_VS_DH=y
CONFIG_IP_VS_SH=y
CONFIG_IP_VS_SED=y
CONFIG_IP_VS_NQ=y

#
# IPVS SH scheduler
#
CONFIG_IP_VS_SH_TAB_BITS=8

#
# IPVS application helper
#

#
# IP: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV4=y
CONFIG_NF_SOCKET_IPV4=y
CONFIG_NF_DUP_IPV4=y
# CONFIG_NF_LOG_ARP is not set
# CONFIG_NF_LOG_IPV4 is not set
CONFIG_NF_REJECT_IPV4=y
CONFIG_IP_NF_IPTABLES=y
# CONFIG_IP_NF_MATCH_AH is not set
# CONFIG_IP_NF_MATCH_ECN is not set
# CONFIG_IP_NF_MATCH_TTL is not set
CONFIG_IP_NF_FILTER=y
# CONFIG_IP_NF_TARGET_REJECT is not set
# CONFIG_IP_NF_MANGLE is not set
# CONFIG_IP_NF_RAW is not set
CONFIG_IP_NF_SECURITY=y
# CONFIG_IP_NF_ARPTABLES is not set

#
# IPv6: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV6=y
CONFIG_NF_SOCKET_IPV6=y
CONFIG_NF_DUP_IPV6=y
CONFIG_NF_REJECT_IPV6=y
CONFIG_NF_LOG_IPV6=y
CONFIG_IP6_NF_IPTABLES=y
CONFIG_IP6_NF_MATCH_AH=y
# CONFIG_IP6_NF_MATCH_EUI64 is not set
# CONFIG_IP6_NF_MATCH_FRAG is not set
CONFIG_IP6_NF_MATCH_OPTS=y
CONFIG_IP6_NF_MATCH_HL=y
CONFIG_IP6_NF_MATCH_IPV6HEADER=y
CONFIG_IP6_NF_MATCH_MH=y
CONFIG_IP6_NF_MATCH_RPFILTER=y
CONFIG_IP6_NF_MATCH_RT=y
# CONFIG_IP6_NF_MATCH_SRH is not set
# CONFIG_IP6_NF_FILTER is not set
# CONFIG_IP6_NF_MANGLE is not set
CONFIG_IP6_NF_RAW=y
CONFIG_IP6_NF_SECURITY=y
# CONFIG_BRIDGE_NF_EBTABLES is not set
CONFIG_IP_DCCP=y

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
# CONFIG_SCTP_DBG_OBJCNT is not set
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5 is not set
CONFIG_SCTP_DEFAULT_COOKIE_HMAC_SHA1=y
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_NONE is not set
CONFIG_SCTP_COOKIE_HMAC_MD5=y
CONFIG_SCTP_COOKIE_HMAC_SHA1=y
# CONFIG_RDS is not set
CONFIG_TIPC=y
# CONFIG_TIPC_MEDIA_IB is not set
CONFIG_TIPC_MEDIA_UDP=y
CONFIG_TIPC_DIAG=y
CONFIG_ATM=y
# CONFIG_ATM_CLIP is not set
# CONFIG_ATM_LANE is not set
CONFIG_ATM_BR2684=y
CONFIG_ATM_BR2684_IPFILTER=y
CONFIG_L2TP=y
CONFIG_L2TP_DEBUGFS=y
# CONFIG_L2TP_V3 is not set
CONFIG_STP=y
CONFIG_MRP=y
CONFIG_BRIDGE=y
# CONFIG_BRIDGE_IGMP_SNOOPING is not set
# CONFIG_BRIDGE_VLAN_FILTERING is not set
CONFIG_HAVE_NET_DSA=y
CONFIG_NET_DSA=y
# CONFIG_NET_DSA_LEGACY is not set
CONFIG_NET_DSA_TAG_DSA=y
CONFIG_NET_DSA_TAG_EDSA=y
CONFIG_NET_DSA_TAG_KSZ=y
CONFIG_NET_DSA_TAG_LAN9303=y
CONFIG_NET_DSA_TAG_MTK=y
CONFIG_VLAN_8021Q=y
# CONFIG_VLAN_8021Q_GVRP is not set
CONFIG_VLAN_8021Q_MVRP=y
# CONFIG_DECNET is not set
CONFIG_LLC=y
# CONFIG_LLC2 is not set
CONFIG_ATALK=y
CONFIG_DEV_APPLETALK=y
CONFIG_IPDDP=y
CONFIG_IPDDP_ENCAP=y
CONFIG_X25=y
CONFIG_LAPB=y
CONFIG_PHONET=y
CONFIG_6LOWPAN=y
# CONFIG_6LOWPAN_DEBUGFS is not set
# CONFIG_6LOWPAN_NHC is not set
CONFIG_IEEE802154=y
CONFIG_IEEE802154_NL802154_EXPERIMENTAL=y
# CONFIG_IEEE802154_SOCKET is not set
CONFIG_IEEE802154_6LOWPAN=y
CONFIG_MAC802154=y
CONFIG_NET_SCHED=y

#
# Queueing/Scheduling
#
CONFIG_NET_SCH_CBQ=y
CONFIG_NET_SCH_HTB=y
CONFIG_NET_SCH_HFSC=y
CONFIG_NET_SCH_ATM=y
CONFIG_NET_SCH_PRIO=y
CONFIG_NET_SCH_MULTIQ=y
CONFIG_NET_SCH_RED=y
CONFIG_NET_SCH_SFB=y
CONFIG_NET_SCH_SFQ=y
CONFIG_NET_SCH_TEQL=y
CONFIG_NET_SCH_TBF=y
CONFIG_NET_SCH_CBS=y
# CONFIG_NET_SCH_GRED is not set
CONFIG_NET_SCH_DSMARK=y
CONFIG_NET_SCH_NETEM=y
CONFIG_NET_SCH_DRR=y
# CONFIG_NET_SCH_MQPRIO is not set
CONFIG_NET_SCH_CHOKE=y
# CONFIG_NET_SCH_QFQ is not set
CONFIG_NET_SCH_CODEL=y
# CONFIG_NET_SCH_FQ_CODEL is not set
CONFIG_NET_SCH_FQ=y
# CONFIG_NET_SCH_HHF is not set
# CONFIG_NET_SCH_PIE is not set
CONFIG_NET_SCH_INGRESS=y
# CONFIG_NET_SCH_PLUG is not set
CONFIG_NET_SCH_DEFAULT=y
# CONFIG_DEFAULT_FQ is not set
CONFIG_DEFAULT_CODEL=y
# CONFIG_DEFAULT_SFQ is not set
# CONFIG_DEFAULT_PFIFO_FAST is not set
CONFIG_DEFAULT_NET_SCH="pfifo_fast"

#
# Classification
#
CONFIG_NET_CLS=y
# CONFIG_NET_CLS_BASIC is not set
CONFIG_NET_CLS_TCINDEX=y
CONFIG_NET_CLS_ROUTE4=y
CONFIG_NET_CLS_FW=y
CONFIG_NET_CLS_U32=y
# CONFIG_CLS_U32_PERF is not set
# CONFIG_CLS_U32_MARK is not set
# CONFIG_NET_CLS_RSVP is not set
CONFIG_NET_CLS_RSVP6=y
CONFIG_NET_CLS_FLOW=y
CONFIG_NET_CLS_CGROUP=y
CONFIG_NET_CLS_BPF=y
# CONFIG_NET_CLS_FLOWER is not set
CONFIG_NET_CLS_MATCHALL=y
CONFIG_NET_EMATCH=y
CONFIG_NET_EMATCH_STACK=32
# CONFIG_NET_EMATCH_CMP is not set
# CONFIG_NET_EMATCH_NBYTE is not set
# CONFIG_NET_EMATCH_U32 is not set
CONFIG_NET_EMATCH_META=y
CONFIG_NET_EMATCH_TEXT=y
CONFIG_NET_EMATCH_CANID=y
# CONFIG_NET_EMATCH_IPSET is not set
CONFIG_NET_EMATCH_IPT=y
CONFIG_NET_CLS_ACT=y
CONFIG_NET_ACT_POLICE=y
CONFIG_NET_ACT_GACT=y
CONFIG_GACT_PROB=y
CONFIG_NET_ACT_MIRRED=y
# CONFIG_NET_ACT_SAMPLE is not set
CONFIG_NET_ACT_IPT=y
# CONFIG_NET_ACT_NAT is not set
CONFIG_NET_ACT_PEDIT=y
# CONFIG_NET_ACT_SIMP is not set
# CONFIG_NET_ACT_SKBEDIT is not set
# CONFIG_NET_ACT_CSUM is not set
# CONFIG_NET_ACT_VLAN is not set
CONFIG_NET_ACT_BPF=y
# CONFIG_NET_ACT_SKBMOD is not set
CONFIG_NET_ACT_IFE=y
CONFIG_NET_ACT_TUNNEL_KEY=y
# CONFIG_NET_IFE_SKBMARK is not set
CONFIG_NET_IFE_SKBPRIO=y
CONFIG_NET_IFE_SKBTCINDEX=y
# CONFIG_NET_CLS_IND is not set
CONFIG_NET_SCH_FIFO=y
# CONFIG_DCB is not set
CONFIG_DNS_RESOLVER=y
# CONFIG_BATMAN_ADV is not set
CONFIG_OPENVSWITCH=y
# CONFIG_OPENVSWITCH_GRE is not set
CONFIG_OPENVSWITCH_GENEVE=y
CONFIG_VSOCKETS=y
# CONFIG_VSOCKETS_DIAG is not set
CONFIG_VIRTIO_VSOCKETS=y
CONFIG_VIRTIO_VSOCKETS_COMMON=y
# CONFIG_NETLINK_DIAG is not set
CONFIG_MPLS=y
CONFIG_NET_MPLS_GSO=y
# CONFIG_MPLS_ROUTING is not set
CONFIG_NET_NSH=y
# CONFIG_HSR is not set
CONFIG_NET_SWITCHDEV=y
CONFIG_NET_L3_MASTER_DEV=y
# CONFIG_NET_NCSI is not set
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
# CONFIG_CGROUP_NET_PRIO is not set
CONFIG_CGROUP_NET_CLASSID=y
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
# CONFIG_BPF_STREAM_PARSER is not set
CONFIG_NET_FLOW_LIMIT=y

#
# Network testing
#
CONFIG_NET_PKTGEN=y
# CONFIG_NET_DROP_MONITOR is not set
CONFIG_HAMRADIO=y

#
# Packet Radio protocols
#
# CONFIG_AX25 is not set
CONFIG_CAN=y
# CONFIG_CAN_RAW is not set
# CONFIG_CAN_BCM is not set
CONFIG_CAN_GW=y

#
# CAN Device Drivers
#
CONFIG_CAN_VCAN=y
CONFIG_CAN_VXCAN=y
# CONFIG_CAN_SLCAN is not set
CONFIG_CAN_DEV=y
CONFIG_CAN_CALC_BITTIMING=y
# CONFIG_CAN_LEDS is not set
# CONFIG_CAN_C_CAN is not set
# CONFIG_CAN_CC770 is not set
CONFIG_CAN_IFI_CANFD=y
CONFIG_CAN_M_CAN=y
CONFIG_CAN_PEAK_PCIEFD=y
# CONFIG_CAN_SJA1000 is not set
CONFIG_CAN_SOFTING=y

#
# CAN USB interfaces
#
CONFIG_CAN_EMS_USB=y
CONFIG_CAN_ESD_USB2=y
CONFIG_CAN_GS_USB=y
CONFIG_CAN_KVASER_USB=y
# CONFIG_CAN_PEAK_USB is not set
CONFIG_CAN_8DEV_USB=y
CONFIG_CAN_MCBA_USB=y
# CONFIG_CAN_DEBUG_DEVICES is not set
CONFIG_BT=y
CONFIG_BT_BREDR=y
# CONFIG_BT_RFCOMM is not set
# CONFIG_BT_BNEP is not set
CONFIG_BT_HIDP=y
# CONFIG_BT_HS is not set
CONFIG_BT_LE=y
# CONFIG_BT_6LOWPAN is not set
# CONFIG_BT_LEDS is not set
# CONFIG_BT_SELFTEST is not set
CONFIG_BT_DEBUGFS=y

#
# Bluetooth device drivers
#
CONFIG_BT_INTEL=y
CONFIG_BT_BCM=y
CONFIG_BT_RTL=y
CONFIG_BT_HCIBTUSB=y
CONFIG_BT_HCIBTUSB_AUTOSUSPEND=y
CONFIG_BT_HCIBTUSB_BCM=y
CONFIG_BT_HCIBTUSB_RTL=y
# CONFIG_BT_HCIUART is not set
CONFIG_BT_HCIBCM203X=y
CONFIG_BT_HCIBPA10X=y
CONFIG_BT_HCIBFUSB=y
# CONFIG_BT_HCIVHCI is not set
CONFIG_BT_MRVL=y
CONFIG_BT_ATH3K=y
CONFIG_AF_RXRPC=y
# CONFIG_AF_RXRPC_IPV6 is not set
CONFIG_AF_RXRPC_INJECT_LOSS=y
CONFIG_AF_RXRPC_DEBUG=y
# CONFIG_RXKAD is not set
# CONFIG_AF_KCM is not set
CONFIG_FIB_RULES=y
# CONFIG_WIRELESS is not set
# CONFIG_WIMAX is not set
CONFIG_RFKILL=y
CONFIG_RFKILL_LEDS=y
CONFIG_RFKILL_INPUT=y
CONFIG_RFKILL_GPIO=y
CONFIG_NET_9P=y
# CONFIG_NET_9P_VIRTIO is not set
CONFIG_NET_9P_RDMA=y
CONFIG_NET_9P_DEBUG=y
CONFIG_CAIF=y
CONFIG_CAIF_DEBUG=y
CONFIG_CAIF_NETDEV=y
CONFIG_CAIF_USB=y
CONFIG_CEPH_LIB=y
CONFIG_CEPH_LIB_PRETTYDEBUG=y
CONFIG_CEPH_LIB_USE_DNS_RESOLVER=y
CONFIG_NFC=y
CONFIG_NFC_DIGITAL=y
# CONFIG_NFC_NCI is not set
CONFIG_NFC_HCI=y
# CONFIG_NFC_SHDLC is not set

#
# Near Field Communication (NFC) devices
#
CONFIG_NFC_MEI_PHY=y
CONFIG_NFC_SIM=y
CONFIG_NFC_PORT100=y
CONFIG_NFC_PN544=y
CONFIG_NFC_PN544_MEI=y
CONFIG_NFC_PN533=y
CONFIG_NFC_PN533_USB=y
# CONFIG_NFC_PN533_I2C is not set
CONFIG_NFC_MICROREAD=y
CONFIG_NFC_MICROREAD_MEI=y
CONFIG_PSAMPLE=y
CONFIG_NET_IFE=y
CONFIG_LWTUNNEL=y
CONFIG_LWTUNNEL_BPF=y
CONFIG_DST_CACHE=y
CONFIG_GRO_CELLS=y
# CONFIG_NET_DEVLINK is not set
CONFIG_MAY_USE_DEVLINK=y
CONFIG_HAVE_EBPF_JIT=y

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER=y
CONFIG_UEVENT_HELPER_PATH=""
CONFIG_DEVTMPFS=y
# CONFIG_DEVTMPFS_MOUNT is not set
# CONFIG_STANDALONE is not set
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
CONFIG_FW_LOADER_USER_HELPER_FALLBACK=y
CONFIG_WANT_DEV_COREDUMP=y
# CONFIG_ALLOW_DEV_COREDUMP is not set
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_DEBUG_TEST_DRIVER_REMOVE is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_GENERIC_CPU_VULNERABILITIES=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_W1=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_REGMAP_SOUNDWIRE=y
CONFIG_DMA_SHARED_BUFFER=y
# CONFIG_DMA_FENCE_TRACE is not set
CONFIG_DMA_CMA=y

#
# Default contiguous memory area size:
#
CONFIG_CMA_SIZE_MBYTES=0
CONFIG_CMA_SIZE_SEL_MBYTES=y
# CONFIG_CMA_SIZE_SEL_PERCENTAGE is not set
# CONFIG_CMA_SIZE_SEL_MIN is not set
# CONFIG_CMA_SIZE_SEL_MAX is not set
CONFIG_CMA_ALIGNMENT=8

#
# Bus devices
#
CONFIG_CONNECTOR=y
CONFIG_PROC_EVENTS=y
CONFIG_MTD=y
CONFIG_MTD_REDBOOT_PARTS=y
CONFIG_MTD_REDBOOT_DIRECTORY_BLOCK=-1
CONFIG_MTD_REDBOOT_PARTS_UNALLOCATED=y
# CONFIG_MTD_REDBOOT_PARTS_READONLY is not set
# CONFIG_MTD_CMDLINE_PARTS is not set
# CONFIG_MTD_AR7_PARTS is not set

#
# Partition parsers
#

#
# User Modules And Translation Layers
#
CONFIG_MTD_BLKDEVS=y
CONFIG_MTD_BLOCK=y
CONFIG_FTL=y
# CONFIG_NFTL is not set
CONFIG_INFTL=y
# CONFIG_RFD_FTL is not set
CONFIG_SSFDC=y
CONFIG_SM_FTL=y
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
CONFIG_MTD_CFI_I1=y
CONFIG_MTD_CFI_I2=y
CONFIG_MTD_RAM=y
CONFIG_MTD_ROM=y
# CONFIG_MTD_ABSENT is not set

#
# Mapping drivers for chip access
#
# CONFIG_MTD_COMPLEX_MAPPINGS is not set
CONFIG_MTD_PHYSMAP=y
# CONFIG_MTD_PHYSMAP_COMPAT is not set
CONFIG_MTD_INTEL_VR_NOR=y
CONFIG_MTD_PLATRAM=y

#
# Self-contained MTD device drivers
#
CONFIG_MTD_PMC551=y
CONFIG_MTD_PMC551_BUGFIX=y
CONFIG_MTD_PMC551_DEBUG=y
CONFIG_MTD_SLRAM=y
CONFIG_MTD_PHRAM=y
# CONFIG_MTD_MTDRAM is not set
# CONFIG_MTD_BLOCK2MTD is not set

#
# Disk-On-Chip Device Drivers
#
CONFIG_MTD_DOCG3=y
CONFIG_BCH_CONST_M=14
CONFIG_BCH_CONST_T=4
CONFIG_MTD_ONENAND=y
CONFIG_MTD_ONENAND_VERIFY_WRITE=y
CONFIG_MTD_ONENAND_GENERIC=y
CONFIG_MTD_ONENAND_OTP=y
# CONFIG_MTD_ONENAND_2X_PROGRAM is not set
CONFIG_MTD_NAND_ECC=y
CONFIG_MTD_NAND_ECC_SMC=y
# CONFIG_MTD_NAND is not set

#
# LPDDR & LPDDR2 PCM memory drivers
#
CONFIG_MTD_LPDDR=y
CONFIG_MTD_QINFO_PROBE=y
CONFIG_MTD_SPI_NOR=y
# CONFIG_MTD_MT81xx_NOR is not set
# CONFIG_MTD_SPI_NOR_USE_4K_SECTORS is not set
CONFIG_SPI_INTEL_SPI=y
CONFIG_SPI_INTEL_SPI_PCI=y
CONFIG_SPI_INTEL_SPI_PLATFORM=y
# CONFIG_MTD_UBI is not set
# CONFIG_OF is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
# CONFIG_PARPORT is not set
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
CONFIG_BLK_DEV_NULL_BLK=y
CONFIG_CDROM=y
# CONFIG_BLK_DEV_PCIESSD_MTIP32XX is not set
# CONFIG_ZRAM is not set
CONFIG_BLK_DEV_DAC960=y
CONFIG_BLK_DEV_UMEM=y
CONFIG_BLK_DEV_LOOP=y
CONFIG_BLK_DEV_LOOP_MIN_COUNT=8
# CONFIG_BLK_DEV_CRYPTOLOOP is not set
# CONFIG_BLK_DEV_DRBD is not set
# CONFIG_BLK_DEV_NBD is not set
CONFIG_BLK_DEV_SKD=y
CONFIG_BLK_DEV_SX8=y
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=4096
# CONFIG_CDROM_PKTCDVD is not set
CONFIG_ATA_OVER_ETH=y
CONFIG_VIRTIO_BLK=y
CONFIG_VIRTIO_BLK_SCSI=y
# CONFIG_BLK_DEV_RBD is not set
CONFIG_BLK_DEV_RSXX=y

#
# NVME Support
#
CONFIG_NVME_CORE=y
CONFIG_BLK_DEV_NVME=y
# CONFIG_NVME_MULTIPATH is not set
CONFIG_NVME_FABRICS=y
CONFIG_NVME_RDMA=y
# CONFIG_NVME_FC is not set
CONFIG_NVME_TARGET=y
CONFIG_NVME_TARGET_LOOP=y
# CONFIG_NVME_TARGET_RDMA is not set
CONFIG_NVME_TARGET_FC=y

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=y
CONFIG_AD525X_DPOT=y
# CONFIG_AD525X_DPOT_I2C is not set
# CONFIG_DUMMY_IRQ is not set
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
CONFIG_SGI_IOC4=y
CONFIG_TIFM_CORE=y
CONFIG_TIFM_7XX1=y
CONFIG_ICS932S401=y
CONFIG_ENCLOSURE_SERVICES=y
CONFIG_HP_ILO=y
CONFIG_APDS9802ALS=y
CONFIG_ISL29003=y
# CONFIG_ISL29020 is not set
CONFIG_SENSORS_TSL2550=y
# CONFIG_SENSORS_BH1770 is not set
CONFIG_SENSORS_APDS990X=y
CONFIG_HMC6352=y
CONFIG_DS1682=y
CONFIG_USB_SWITCH_FSA9480=y
CONFIG_SRAM=y
# CONFIG_PCI_ENDPOINT_TEST is not set
CONFIG_MISC_RTSX=y
CONFIG_C2PORT=y
CONFIG_C2PORT_DURAMAR_2150=y

#
# EEPROM support
#
CONFIG_EEPROM_AT24=y
# CONFIG_EEPROM_LEGACY is not set
CONFIG_EEPROM_MAX6875=y
CONFIG_EEPROM_93CX6=y
CONFIG_EEPROM_IDT_89HPESX=y
CONFIG_CB710_CORE=y
CONFIG_CB710_DEBUG=y
CONFIG_CB710_DEBUG_ASSUMPTIONS=y

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
CONFIG_SENSORS_LIS3_I2C=y
CONFIG_ALTERA_STAPL=y
CONFIG_INTEL_MEI=y
CONFIG_INTEL_MEI_ME=y
# CONFIG_INTEL_MEI_TXE is not set
# CONFIG_VMWARE_VMCI is not set

#
# Intel MIC & related support
#

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
CONFIG_GENWQE=y
CONFIG_GENWQE_PLATFORM_ERROR_RECOVERY=0
CONFIG_ECHO=y
CONFIG_MISC_RTSX_PCI=y
CONFIG_MISC_RTSX_USB=y
CONFIG_HAVE_IDE=y
CONFIG_IDE=y

#
# Please see Documentation/ide/ide.txt for help/info on IDE drives
#
CONFIG_IDE_XFER_MODE=y
CONFIG_IDE_TIMINGS=y
CONFIG_IDE_ATAPI=y
# CONFIG_BLK_DEV_IDE_SATA is not set
CONFIG_IDE_GD=y
# CONFIG_IDE_GD_ATA is not set
CONFIG_IDE_GD_ATAPI=y
CONFIG_BLK_DEV_IDECD=y
# CONFIG_BLK_DEV_IDECD_VERBOSE_ERRORS is not set
CONFIG_BLK_DEV_IDETAPE=y
# CONFIG_BLK_DEV_IDEACPI is not set
CONFIG_IDE_TASK_IOCTL=y
CONFIG_IDE_PROC_FS=y

#
# IDE chipset support/bugfixes
#
CONFIG_IDE_GENERIC=y
CONFIG_BLK_DEV_PLATFORM=y
CONFIG_BLK_DEV_CMD640=y
# CONFIG_BLK_DEV_CMD640_ENHANCED is not set
# CONFIG_BLK_DEV_IDEPNP is not set
CONFIG_BLK_DEV_IDEDMA_SFF=y

#
# PCI IDE chipsets support
#
CONFIG_BLK_DEV_IDEPCI=y
CONFIG_IDEPCI_PCIBUS_ORDER=y
# CONFIG_BLK_DEV_OFFBOARD is not set
# CONFIG_BLK_DEV_GENERIC is not set
CONFIG_BLK_DEV_OPTI621=y
CONFIG_BLK_DEV_RZ1000=y
CONFIG_BLK_DEV_IDEDMA_PCI=y
CONFIG_BLK_DEV_AEC62XX=y
CONFIG_BLK_DEV_ALI15X3=y
# CONFIG_BLK_DEV_AMD74XX is not set
CONFIG_BLK_DEV_ATIIXP=y
CONFIG_BLK_DEV_CMD64X=y
# CONFIG_BLK_DEV_TRIFLEX is not set
CONFIG_BLK_DEV_HPT366=y
CONFIG_BLK_DEV_JMICRON=y
CONFIG_BLK_DEV_PIIX=y
CONFIG_BLK_DEV_IT8172=y
# CONFIG_BLK_DEV_IT8213 is not set
CONFIG_BLK_DEV_IT821X=y
# CONFIG_BLK_DEV_NS87415 is not set
# CONFIG_BLK_DEV_PDC202XX_OLD is not set
# CONFIG_BLK_DEV_PDC202XX_NEW is not set
CONFIG_BLK_DEV_SVWKS=y
# CONFIG_BLK_DEV_SIIMAGE is not set
CONFIG_BLK_DEV_SIS5513=y
# CONFIG_BLK_DEV_SLC90E66 is not set
# CONFIG_BLK_DEV_TRM290 is not set
CONFIG_BLK_DEV_VIA82CXXX=y
# CONFIG_BLK_DEV_TC86C001 is not set
CONFIG_BLK_DEV_IDEDMA=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=y
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
CONFIG_SCSI_NETLINK=y
# CONFIG_SCSI_MQ_DEFAULT is not set
# CONFIG_SCSI_PROC_FS is not set

#
# SCSI support type (disk, tape, CD-ROM)
#
# CONFIG_BLK_DEV_SD is not set
CONFIG_CHR_DEV_ST=y
# CONFIG_CHR_DEV_OSST is not set
# CONFIG_BLK_DEV_SR is not set
CONFIG_CHR_DEV_SG=y
# CONFIG_CHR_DEV_SCH is not set
CONFIG_SCSI_ENCLOSURE=y
CONFIG_SCSI_CONSTANTS=y
# CONFIG_SCSI_LOGGING is not set
CONFIG_SCSI_SCAN_ASYNC=y

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
CONFIG_SCSI_FC_ATTRS=y
CONFIG_SCSI_ISCSI_ATTRS=y
CONFIG_SCSI_SAS_ATTRS=y
CONFIG_SCSI_SAS_LIBSAS=y
CONFIG_SCSI_SAS_HOST_SMP=y
CONFIG_SCSI_SRP_ATTRS=y
CONFIG_SCSI_LOWLEVEL=y
# CONFIG_ISCSI_TCP is not set
CONFIG_ISCSI_BOOT_SYSFS=y
CONFIG_SCSI_CXGB3_ISCSI=y
CONFIG_SCSI_CXGB4_ISCSI=y
CONFIG_SCSI_BNX2_ISCSI=y
CONFIG_SCSI_BNX2X_FCOE=y
# CONFIG_BE2ISCSI is not set
CONFIG_BLK_DEV_3W_XXXX_RAID=y
# CONFIG_SCSI_HPSA is not set
CONFIG_SCSI_3W_9XXX=y
# CONFIG_SCSI_3W_SAS is not set
# CONFIG_SCSI_ACARD is not set
CONFIG_SCSI_AACRAID=y
# CONFIG_SCSI_AIC7XXX is not set
# CONFIG_SCSI_AIC79XX is not set
CONFIG_SCSI_AIC94XX=y
# CONFIG_AIC94XX_DEBUG is not set
CONFIG_SCSI_MVSAS=y
# CONFIG_SCSI_MVSAS_DEBUG is not set
CONFIG_SCSI_MVSAS_TASKLET=y
# CONFIG_SCSI_MVUMI is not set
CONFIG_SCSI_DPT_I2O=y
CONFIG_SCSI_ADVANSYS=y
CONFIG_SCSI_ARCMSR=y
CONFIG_SCSI_ESAS2R=y
# CONFIG_MEGARAID_NEWGEN is not set
CONFIG_MEGARAID_LEGACY=y
# CONFIG_MEGARAID_SAS is not set
CONFIG_SCSI_MPT3SAS=y
CONFIG_SCSI_MPT2SAS_MAX_SGE=128
CONFIG_SCSI_MPT3SAS_MAX_SGE=128
CONFIG_SCSI_MPT2SAS=y
CONFIG_SCSI_SMARTPQI=y
CONFIG_SCSI_UFSHCD=y
CONFIG_SCSI_UFSHCD_PCI=y
# CONFIG_SCSI_UFS_DWC_TC_PCI is not set
# CONFIG_SCSI_UFSHCD_PLATFORM is not set
CONFIG_SCSI_HPTIOP=y
CONFIG_VMWARE_PVSCSI=y
CONFIG_LIBFC=y
CONFIG_LIBFCOE=y
CONFIG_FCOE=y
CONFIG_FCOE_FNIC=y
CONFIG_SCSI_SNIC=y
CONFIG_SCSI_SNIC_DEBUG_FS=y
# CONFIG_SCSI_DMX3191D is not set
CONFIG_SCSI_ISCI=y
CONFIG_SCSI_IPS=y
CONFIG_SCSI_INITIO=y
CONFIG_SCSI_INIA100=y
CONFIG_SCSI_STEX=y
CONFIG_SCSI_SYM53C8XX_2=y
CONFIG_SCSI_SYM53C8XX_DMA_ADDRESSING_MODE=1
CONFIG_SCSI_SYM53C8XX_DEFAULT_TAGS=16
CONFIG_SCSI_SYM53C8XX_MAX_TAGS=64
CONFIG_SCSI_SYM53C8XX_MMIO=y
CONFIG_SCSI_QLOGIC_1280=y
CONFIG_SCSI_QLA_FC=y
CONFIG_TCM_QLA2XXX=y
# CONFIG_TCM_QLA2XXX_DEBUG is not set
# CONFIG_SCSI_QLA_ISCSI is not set
CONFIG_QEDI=y
CONFIG_QEDF=y
# CONFIG_SCSI_LPFC is not set
CONFIG_SCSI_DC395x=y
CONFIG_SCSI_AM53C974=y
CONFIG_SCSI_WD719X=y
CONFIG_SCSI_DEBUG=y
CONFIG_SCSI_PMCRAID=y
CONFIG_SCSI_PM8001=y
CONFIG_SCSI_BFA_FC=y
# CONFIG_SCSI_VIRTIO is not set
CONFIG_SCSI_CHELSIO_FCOE=y
# CONFIG_SCSI_DH is not set
# CONFIG_SCSI_OSD_INITIATOR is not set
# CONFIG_ATA is not set
CONFIG_MD=y
# CONFIG_BLK_DEV_MD is not set
CONFIG_BCACHE=y
CONFIG_BCACHE_DEBUG=y
CONFIG_BCACHE_CLOSURES_DEBUG=y
# CONFIG_BLK_DEV_DM is not set
CONFIG_TARGET_CORE=y
CONFIG_TCM_IBLOCK=y
CONFIG_TCM_FILEIO=y
# CONFIG_TCM_PSCSI is not set
CONFIG_TCM_USER2=y
# CONFIG_LOOPBACK_TARGET is not set
# CONFIG_TCM_FC is not set
CONFIG_ISCSI_TARGET=y
# CONFIG_ISCSI_TARGET_CXGB4 is not set
# CONFIG_SBP_TARGET is not set
CONFIG_FUSION=y
# CONFIG_FUSION_SPI is not set
CONFIG_FUSION_FC=y
CONFIG_FUSION_SAS=y
CONFIG_FUSION_MAX_SGE=128
CONFIG_FUSION_CTL=y
CONFIG_FUSION_LAN=y
CONFIG_FUSION_LOGGING=y

#
# IEEE 1394 (FireWire) support
#
CONFIG_FIREWIRE=y
CONFIG_FIREWIRE_OHCI=y
# CONFIG_FIREWIRE_SBP2 is not set
# CONFIG_FIREWIRE_NET is not set
CONFIG_FIREWIRE_NOSY=y
# CONFIG_MACINTOSH_DRIVERS is not set
CONFIG_NETDEVICES=y
CONFIG_MII=y
CONFIG_NET_CORE=y
# CONFIG_BONDING is not set
# CONFIG_DUMMY is not set
# CONFIG_EQUALIZER is not set
CONFIG_NET_FC=y
# CONFIG_IFB is not set
CONFIG_NET_TEAM=y
CONFIG_NET_TEAM_MODE_BROADCAST=y
CONFIG_NET_TEAM_MODE_ROUNDROBIN=y
CONFIG_NET_TEAM_MODE_RANDOM=y
# CONFIG_NET_TEAM_MODE_ACTIVEBACKUP is not set
# CONFIG_NET_TEAM_MODE_LOADBALANCE is not set
# CONFIG_MACVLAN is not set
CONFIG_IPVLAN=y
# CONFIG_IPVTAP is not set
# CONFIG_VXLAN is not set
CONFIG_GENEVE=y
CONFIG_GTP=y
CONFIG_MACSEC=y
# CONFIG_NETCONSOLE is not set
CONFIG_TUN=y
# CONFIG_TUN_VNET_CROSS_LE is not set
# CONFIG_VETH is not set
CONFIG_VIRTIO_NET=y
CONFIG_NLMON=y
CONFIG_ARCNET=y
CONFIG_ARCNET_1201=y
# CONFIG_ARCNET_1051 is not set
CONFIG_ARCNET_RAW=y
CONFIG_ARCNET_CAP=y
CONFIG_ARCNET_COM90xx=y
CONFIG_ARCNET_COM90xxIO=y
CONFIG_ARCNET_RIM_I=y
CONFIG_ARCNET_COM20020=y
# CONFIG_ARCNET_COM20020_PCI is not set
CONFIG_ATM_DRIVERS=y
CONFIG_ATM_DUMMY=y
CONFIG_ATM_TCP=y
CONFIG_ATM_LANAI=y
CONFIG_ATM_ENI=y
# CONFIG_ATM_ENI_DEBUG is not set
# CONFIG_ATM_ENI_TUNE_BURST is not set
# CONFIG_ATM_FIRESTREAM is not set
# CONFIG_ATM_ZATM is not set
# CONFIG_ATM_NICSTAR is not set
# CONFIG_ATM_IDT77252 is not set
# CONFIG_ATM_AMBASSADOR is not set
CONFIG_ATM_HORIZON=y
CONFIG_ATM_HORIZON_DEBUG=y
CONFIG_ATM_IA=y
# CONFIG_ATM_IA_DEBUG is not set
CONFIG_ATM_FORE200E=y
CONFIG_ATM_FORE200E_USE_TASKLET=y
CONFIG_ATM_FORE200E_TX_RETRY=16
CONFIG_ATM_FORE200E_DEBUG=0
CONFIG_ATM_HE=y
CONFIG_ATM_HE_USE_SUNI=y
# CONFIG_ATM_SOLOS is not set

#
# CAIF transport drivers
#
# CONFIG_CAIF_TTY is not set
CONFIG_CAIF_SPI_SLAVE=y
# CONFIG_CAIF_SPI_SYNC is not set
CONFIG_CAIF_HSI=y
# CONFIG_CAIF_VIRTIO is not set

#
# Distributed Switch Architecture drivers
#
# CONFIG_B53 is not set
CONFIG_NET_DSA_LOOP=y
CONFIG_NET_DSA_MT7530=y
CONFIG_MICROCHIP_KSZ=y
CONFIG_NET_DSA_MV88E6XXX=y
# CONFIG_NET_DSA_MV88E6XXX_GLOBAL2 is not set
# CONFIG_NET_DSA_QCA8K is not set
CONFIG_NET_DSA_SMSC_LAN9303=y
CONFIG_NET_DSA_SMSC_LAN9303_I2C=y
CONFIG_NET_DSA_SMSC_LAN9303_MDIO=y
CONFIG_ETHERNET=y
CONFIG_MDIO=y
# CONFIG_NET_VENDOR_3COM is not set
CONFIG_NET_VENDOR_ADAPTEC=y
CONFIG_ADAPTEC_STARFIRE=y
# CONFIG_NET_VENDOR_AGERE is not set
# CONFIG_NET_VENDOR_ALACRITECH is not set
CONFIG_NET_VENDOR_ALTEON=y
CONFIG_ACENIC=y
# CONFIG_ACENIC_OMIT_TIGON_I is not set
CONFIG_ALTERA_TSE=y
CONFIG_NET_VENDOR_AMAZON=y
CONFIG_NET_VENDOR_AMD=y
CONFIG_AMD8111_ETH=y
# CONFIG_PCNET32 is not set
CONFIG_AMD_XGBE=y
CONFIG_AMD_XGBE_HAVE_ECC=y
# CONFIG_NET_VENDOR_AQUANTIA is not set
# CONFIG_NET_VENDOR_ARC is not set
CONFIG_NET_VENDOR_ATHEROS=y
CONFIG_ATL2=y
CONFIG_ATL1=y
# CONFIG_ATL1E is not set
CONFIG_ATL1C=y
CONFIG_ALX=y
CONFIG_NET_VENDOR_AURORA=y
# CONFIG_AURORA_NB8800 is not set
# CONFIG_NET_CADENCE is not set
CONFIG_NET_VENDOR_BROADCOM=y
# CONFIG_B44 is not set
CONFIG_BNX2=y
CONFIG_CNIC=y
# CONFIG_TIGON3 is not set
CONFIG_BNX2X=y
# CONFIG_BNX2X_SRIOV is not set
# CONFIG_BNXT is not set
CONFIG_NET_VENDOR_BROCADE=y
CONFIG_BNA=y
# CONFIG_NET_VENDOR_CAVIUM is not set
CONFIG_NET_VENDOR_CHELSIO=y
CONFIG_CHELSIO_T1=y
# CONFIG_CHELSIO_T1_1G is not set
CONFIG_CHELSIO_T3=y
CONFIG_CHELSIO_T4=y
CONFIG_CHELSIO_T4VF=y
CONFIG_CHELSIO_LIB=y
# CONFIG_NET_VENDOR_CISCO is not set
CONFIG_NET_VENDOR_CORTINA=y
# CONFIG_CX_ECAT is not set
CONFIG_DNET=y
# CONFIG_NET_VENDOR_DEC is not set
# CONFIG_NET_VENDOR_DLINK is not set
CONFIG_NET_VENDOR_EMULEX=y
CONFIG_BE2NET=y
CONFIG_BE2NET_HWMON=y
CONFIG_NET_VENDOR_EZCHIP=y
CONFIG_NET_VENDOR_EXAR=y
CONFIG_S2IO=y
# CONFIG_VXGE is not set
# CONFIG_NET_VENDOR_HP is not set
CONFIG_NET_VENDOR_HUAWEI=y
CONFIG_NET_VENDOR_INTEL=y
# CONFIG_E100 is not set
CONFIG_E1000=y
CONFIG_E1000E=y
# CONFIG_E1000E_HWTS is not set
CONFIG_IGB=y
CONFIG_IGB_HWMON=y
# CONFIG_IGBVF is not set
# CONFIG_IXGB is not set
CONFIG_IXGBE=y
CONFIG_IXGBE_HWMON=y
# CONFIG_I40E is not set
# CONFIG_NET_VENDOR_I825XX is not set
CONFIG_JME=y
CONFIG_NET_VENDOR_MARVELL=y
CONFIG_MVMDIO=y
CONFIG_SKGE=y
CONFIG_SKGE_DEBUG=y
CONFIG_SKGE_GENESIS=y
# CONFIG_SKY2 is not set
CONFIG_NET_VENDOR_MELLANOX=y
# CONFIG_MLX4_EN is not set
CONFIG_MLX4_CORE=y
CONFIG_MLX4_DEBUG=y
# CONFIG_MLX4_CORE_GEN2 is not set
# CONFIG_MLX5_CORE is not set
# CONFIG_MLXSW_CORE is not set
CONFIG_MLXFW=y
# CONFIG_NET_VENDOR_MICREL is not set
# CONFIG_NET_VENDOR_MYRI is not set
CONFIG_FEALNX=y
CONFIG_NET_VENDOR_NATSEMI=y
# CONFIG_NATSEMI is not set
CONFIG_NS83820=y
# CONFIG_NET_VENDOR_NETRONOME is not set
CONFIG_NET_VENDOR_NI=y
CONFIG_NET_VENDOR_8390=y
CONFIG_NE2K_PCI=y
# CONFIG_NET_VENDOR_NVIDIA is not set
# CONFIG_NET_VENDOR_OKI is not set
CONFIG_ETHOC=y
CONFIG_NET_PACKET_ENGINE=y
# CONFIG_HAMACHI is not set
CONFIG_YELLOWFIN=y
CONFIG_NET_VENDOR_QLOGIC=y
CONFIG_QLA3XXX=y
CONFIG_QLCNIC=y
# CONFIG_QLCNIC_SRIOV is not set
# CONFIG_QLCNIC_HWMON is not set
# CONFIG_QLGE is not set
# CONFIG_NETXEN_NIC is not set
CONFIG_QED=y
CONFIG_QED_LL2=y
CONFIG_QED_SRIOV=y
CONFIG_QEDE=y
CONFIG_QED_RDMA=y
CONFIG_QED_ISCSI=y
CONFIG_QED_FCOE=y
CONFIG_QED_OOO=y
# CONFIG_NET_VENDOR_QUALCOMM is not set
CONFIG_NET_VENDOR_REALTEK=y
CONFIG_8139CP=y
CONFIG_8139TOO=y
# CONFIG_8139TOO_PIO is not set
# CONFIG_8139TOO_TUNE_TWISTER is not set
# CONFIG_8139TOO_8129 is not set
# CONFIG_8139_OLD_RX_RESET is not set
# CONFIG_R8169 is not set
# CONFIG_NET_VENDOR_RENESAS is not set
# CONFIG_NET_VENDOR_RDC is not set
# CONFIG_NET_VENDOR_ROCKER is not set
# CONFIG_NET_VENDOR_SAMSUNG is not set
CONFIG_NET_VENDOR_SEEQ=y
# CONFIG_NET_VENDOR_SILAN is not set
# CONFIG_NET_VENDOR_SIS is not set
CONFIG_NET_VENDOR_SOLARFLARE=y
# CONFIG_SFC is not set
CONFIG_SFC_FALCON=y
CONFIG_SFC_FALCON_MTD=y
CONFIG_NET_VENDOR_SMSC=y
CONFIG_EPIC100=y
CONFIG_SMSC911X=y
# CONFIG_SMSC9420 is not set
# CONFIG_NET_VENDOR_SOCIONEXT is not set
# CONFIG_NET_VENDOR_STMICRO is not set
# CONFIG_NET_VENDOR_SUN is not set
CONFIG_NET_VENDOR_TEHUTI=y
CONFIG_TEHUTI=y
# CONFIG_NET_VENDOR_TI is not set
# CONFIG_NET_VENDOR_VIA is not set
CONFIG_NET_VENDOR_WIZNET=y
CONFIG_WIZNET_W5100=y
CONFIG_WIZNET_W5300=y
# CONFIG_WIZNET_BUS_DIRECT is not set
# CONFIG_WIZNET_BUS_INDIRECT is not set
CONFIG_WIZNET_BUS_ANY=y
CONFIG_NET_VENDOR_SYNOPSYS=y
CONFIG_DWC_XLGMAC=y
CONFIG_DWC_XLGMAC_PCI=y
CONFIG_FDDI=y
CONFIG_DEFXX=y
# CONFIG_DEFXX_MMIO is not set
CONFIG_SKFP=y
CONFIG_HIPPI=y
# CONFIG_ROADRUNNER is not set
CONFIG_NET_SB1000=y
CONFIG_MDIO_DEVICE=y
CONFIG_MDIO_BUS=y
CONFIG_MDIO_BITBANG=y
CONFIG_MDIO_CAVIUM=y
CONFIG_MDIO_GPIO=y
CONFIG_MDIO_THUNDER=y
CONFIG_PHYLIB=y
CONFIG_SWPHY=y
CONFIG_LED_TRIGGER_PHY=y

#
# MII PHY device drivers
#
CONFIG_AMD_PHY=y
# CONFIG_AQUANTIA_PHY is not set
CONFIG_AT803X_PHY=y
CONFIG_BCM7XXX_PHY=y
# CONFIG_BCM87XX_PHY is not set
CONFIG_BCM_NET_PHYLIB=y
# CONFIG_BROADCOM_PHY is not set
CONFIG_CICADA_PHY=y
CONFIG_CORTINA_PHY=y
CONFIG_DAVICOM_PHY=y
CONFIG_DP83822_PHY=y
# CONFIG_DP83848_PHY is not set
# CONFIG_DP83867_PHY is not set
CONFIG_FIXED_PHY=y
CONFIG_ICPLUS_PHY=y
# CONFIG_INTEL_XWAY_PHY is not set
# CONFIG_LSI_ET1011C_PHY is not set
CONFIG_LXT_PHY=y
# CONFIG_MARVELL_PHY is not set
CONFIG_MARVELL_10G_PHY=y
CONFIG_MICREL_PHY=y
CONFIG_MICROCHIP_PHY=y
# CONFIG_MICROSEMI_PHY is not set
CONFIG_NATIONAL_PHY=y
CONFIG_QSEMI_PHY=y
# CONFIG_REALTEK_PHY is not set
# CONFIG_RENESAS_PHY is not set
CONFIG_ROCKCHIP_PHY=y
CONFIG_SMSC_PHY=y
# CONFIG_STE10XP is not set
# CONFIG_TERANETICS_PHY is not set
CONFIG_VITESSE_PHY=y
CONFIG_XILINX_GMII2RGMII=y
# CONFIG_PPP is not set
CONFIG_SLIP=y
# CONFIG_SLIP_COMPRESSED is not set
# CONFIG_SLIP_SMART is not set
# CONFIG_SLIP_MODE_SLIP6 is not set
# CONFIG_USB_NET_DRIVERS is not set
# CONFIG_WLAN is not set

#
# Enable WiMAX (Networking options) to see the WiMAX drivers
#
CONFIG_WAN=y
CONFIG_LANMEDIA=y
CONFIG_HDLC=y
# CONFIG_HDLC_RAW is not set
# CONFIG_HDLC_RAW_ETH is not set
CONFIG_HDLC_CISCO=y
CONFIG_HDLC_FR=y
CONFIG_HDLC_PPP=y
CONFIG_HDLC_X25=y
# CONFIG_PCI200SYN is not set
# CONFIG_WANXL is not set
CONFIG_PC300TOO=y
CONFIG_FARSYNC=y
CONFIG_DLCI=y
CONFIG_DLCI_MAX=8
CONFIG_LAPBETHER=y
CONFIG_X25_ASY=y
CONFIG_SBNI=y
CONFIG_SBNI_MULTILINE=y
CONFIG_IEEE802154_DRIVERS=y
# CONFIG_IEEE802154_FAKELB is not set
CONFIG_IEEE802154_ATUSB=y
CONFIG_VMXNET3=y
CONFIG_FUJITSU_ES=y
CONFIG_THUNDERBOLT_NET=y
# CONFIG_NETDEVSIM is not set
# CONFIG_ISDN is not set
# CONFIG_NVM is not set

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
CONFIG_INPUT_EVBUG=y

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ADP5520=y
# CONFIG_KEYBOARD_ADP5588 is not set
CONFIG_KEYBOARD_ADP5589=y
CONFIG_KEYBOARD_ATKBD=y
CONFIG_KEYBOARD_QT1070=y
CONFIG_KEYBOARD_QT2160=y
# CONFIG_KEYBOARD_DLINK_DIR685 is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_GPIO is not set
# CONFIG_KEYBOARD_GPIO_POLLED is not set
# CONFIG_KEYBOARD_TCA6416 is not set
CONFIG_KEYBOARD_TCA8418=y
CONFIG_KEYBOARD_MATRIX=y
CONFIG_KEYBOARD_LM8323=y
# CONFIG_KEYBOARD_LM8333 is not set
# CONFIG_KEYBOARD_MAX7359 is not set
CONFIG_KEYBOARD_MCS=y
CONFIG_KEYBOARD_MPR121=y
CONFIG_KEYBOARD_NEWTON=y
# CONFIG_KEYBOARD_OPENCORES is not set
CONFIG_KEYBOARD_SAMSUNG=y
CONFIG_KEYBOARD_STOWAWAY=y
# CONFIG_KEYBOARD_SUNKBD is not set
CONFIG_KEYBOARD_TM2_TOUCHKEY=y
CONFIG_KEYBOARD_XTKBD=y
CONFIG_KEYBOARD_CROS_EC=y
# CONFIG_INPUT_MOUSE is not set
CONFIG_INPUT_JOYSTICK=y
# CONFIG_JOYSTICK_ANALOG is not set
# CONFIG_JOYSTICK_A3D is not set
CONFIG_JOYSTICK_ADI=y
CONFIG_JOYSTICK_COBRA=y
# CONFIG_JOYSTICK_GF2K is not set
CONFIG_JOYSTICK_GRIP=y
# CONFIG_JOYSTICK_GRIP_MP is not set
CONFIG_JOYSTICK_GUILLEMOT=y
CONFIG_JOYSTICK_INTERACT=y
CONFIG_JOYSTICK_SIDEWINDER=y
CONFIG_JOYSTICK_TMDC=y
CONFIG_JOYSTICK_IFORCE=y
# CONFIG_JOYSTICK_IFORCE_USB is not set
# CONFIG_JOYSTICK_IFORCE_232 is not set
CONFIG_JOYSTICK_WARRIOR=y
# CONFIG_JOYSTICK_MAGELLAN is not set
CONFIG_JOYSTICK_SPACEORB=y
CONFIG_JOYSTICK_SPACEBALL=y
CONFIG_JOYSTICK_STINGER=y
CONFIG_JOYSTICK_TWIDJOY=y
CONFIG_JOYSTICK_ZHENHUA=y
# CONFIG_JOYSTICK_AS5011 is not set
CONFIG_JOYSTICK_JOYDUMP=y
# CONFIG_JOYSTICK_XPAD is not set
# CONFIG_JOYSTICK_PXRC is not set
CONFIG_INPUT_TABLET=y
CONFIG_TABLET_USB_ACECAD=y
CONFIG_TABLET_USB_AIPTEK=y
CONFIG_TABLET_USB_GTCO=y
CONFIG_TABLET_USB_HANWANG=y
CONFIG_TABLET_USB_KBTAB=y
# CONFIG_TABLET_USB_PEGASUS is not set
CONFIG_TABLET_SERIAL_WACOM4=y
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_TOUCHSCREEN_PROPERTIES=y
# CONFIG_TOUCHSCREEN_88PM860X is not set
CONFIG_TOUCHSCREEN_AD7879=y
# CONFIG_TOUCHSCREEN_AD7879_I2C is not set
# CONFIG_TOUCHSCREEN_ATMEL_MXT is not set
CONFIG_TOUCHSCREEN_AUO_PIXCIR=y
# CONFIG_TOUCHSCREEN_BU21013 is not set
# CONFIG_TOUCHSCREEN_CY8CTMG110 is not set
CONFIG_TOUCHSCREEN_CYTTSP_CORE=y
CONFIG_TOUCHSCREEN_CYTTSP_I2C=y
CONFIG_TOUCHSCREEN_CYTTSP4_CORE=y
# CONFIG_TOUCHSCREEN_CYTTSP4_I2C is not set
CONFIG_TOUCHSCREEN_DA9034=y
CONFIG_TOUCHSCREEN_DYNAPRO=y
# CONFIG_TOUCHSCREEN_HAMPSHIRE is not set
# CONFIG_TOUCHSCREEN_EETI is not set
# CONFIG_TOUCHSCREEN_EGALAX_SERIAL is not set
CONFIG_TOUCHSCREEN_EXC3000=y
CONFIG_TOUCHSCREEN_FUJITSU=y
CONFIG_TOUCHSCREEN_GOODIX=y
CONFIG_TOUCHSCREEN_HIDEEP=y
# CONFIG_TOUCHSCREEN_ILI210X is not set
CONFIG_TOUCHSCREEN_S6SY761=y
CONFIG_TOUCHSCREEN_GUNZE=y
# CONFIG_TOUCHSCREEN_EKTF2127 is not set
CONFIG_TOUCHSCREEN_ELAN=y
CONFIG_TOUCHSCREEN_ELO=y
CONFIG_TOUCHSCREEN_WACOM_W8001=y
CONFIG_TOUCHSCREEN_WACOM_I2C=y
# CONFIG_TOUCHSCREEN_MAX11801 is not set
# CONFIG_TOUCHSCREEN_MCS5000 is not set
CONFIG_TOUCHSCREEN_MMS114=y
# CONFIG_TOUCHSCREEN_MELFAS_MIP4 is not set
# CONFIG_TOUCHSCREEN_MTOUCH is not set
CONFIG_TOUCHSCREEN_INEXIO=y
# CONFIG_TOUCHSCREEN_MK712 is not set
# CONFIG_TOUCHSCREEN_PENMOUNT is not set
# CONFIG_TOUCHSCREEN_EDT_FT5X06 is not set
CONFIG_TOUCHSCREEN_TOUCHRIGHT=y
CONFIG_TOUCHSCREEN_TOUCHWIN=y
CONFIG_TOUCHSCREEN_PIXCIR=y
# CONFIG_TOUCHSCREEN_WDT87XX_I2C is not set
# CONFIG_TOUCHSCREEN_USB_COMPOSITE is not set
CONFIG_TOUCHSCREEN_MC13783=y
# CONFIG_TOUCHSCREEN_TOUCHIT213 is not set
# CONFIG_TOUCHSCREEN_TSC_SERIO is not set
CONFIG_TOUCHSCREEN_TSC200X_CORE=y
CONFIG_TOUCHSCREEN_TSC2004=y
# CONFIG_TOUCHSCREEN_TSC2007 is not set
CONFIG_TOUCHSCREEN_RM_TS=y
# CONFIG_TOUCHSCREEN_SILEAD is not set
# CONFIG_TOUCHSCREEN_SIS_I2C is not set
CONFIG_TOUCHSCREEN_ST1232=y
# CONFIG_TOUCHSCREEN_STMFTS is not set
# CONFIG_TOUCHSCREEN_SX8654 is not set
# CONFIG_TOUCHSCREEN_TPS6507X is not set
CONFIG_TOUCHSCREEN_ZET6223=y
# CONFIG_TOUCHSCREEN_ZFORCE is not set
# CONFIG_TOUCHSCREEN_ROHM_BU21023 is not set
CONFIG_INPUT_MISC=y
CONFIG_INPUT_88PM860X_ONKEY=y
CONFIG_INPUT_AD714X=y
# CONFIG_INPUT_AD714X_I2C is not set
# CONFIG_INPUT_BMA150 is not set
# CONFIG_INPUT_E3X0_BUTTON is not set
CONFIG_INPUT_MAX77693_HAPTIC=y
# CONFIG_INPUT_MAX8997_HAPTIC is not set
CONFIG_INPUT_MC13783_PWRBUTTON=y
CONFIG_INPUT_MMA8450=y
CONFIG_INPUT_APANEL=y
CONFIG_INPUT_GP2A=y
CONFIG_INPUT_GPIO_BEEPER=y
CONFIG_INPUT_GPIO_DECODER=y
# CONFIG_INPUT_ATLAS_BTNS is not set
# CONFIG_INPUT_ATI_REMOTE2 is not set
CONFIG_INPUT_KEYSPAN_REMOTE=y
CONFIG_INPUT_KXTJ9=y
CONFIG_INPUT_KXTJ9_POLLED_MODE=y
# CONFIG_INPUT_POWERMATE is not set
# CONFIG_INPUT_YEALINK is not set
CONFIG_INPUT_CM109=y
CONFIG_INPUT_REGULATOR_HAPTIC=y
CONFIG_INPUT_RETU_PWRBUTTON=y
CONFIG_INPUT_UINPUT=y
# CONFIG_INPUT_PCF50633_PMU is not set
CONFIG_INPUT_PCF8574=y
# CONFIG_INPUT_PWM_BEEPER is not set
# CONFIG_INPUT_PWM_VIBRA is not set
CONFIG_INPUT_GPIO_ROTARY_ENCODER=y
CONFIG_INPUT_DA9063_ONKEY=y
CONFIG_INPUT_ADXL34X=y
CONFIG_INPUT_ADXL34X_I2C=y
CONFIG_INPUT_IMS_PCU=y
CONFIG_INPUT_CMA3000=y
CONFIG_INPUT_CMA3000_I2C=y
CONFIG_INPUT_IDEAPAD_SLIDEBAR=y
CONFIG_INPUT_DRV260X_HAPTICS=y
CONFIG_INPUT_DRV2665_HAPTICS=y
CONFIG_INPUT_DRV2667_HAPTICS=y
# CONFIG_INPUT_RAVE_SP_PWRBUTTON is not set
CONFIG_RMI4_CORE=y
CONFIG_RMI4_I2C=y
# CONFIG_RMI4_SMB is not set
CONFIG_RMI4_F03=y
CONFIG_RMI4_F03_SERIO=y
CONFIG_RMI4_2D_SENSOR=y
CONFIG_RMI4_F11=y
CONFIG_RMI4_F12=y
CONFIG_RMI4_F30=y
CONFIG_RMI4_F34=y
CONFIG_RMI4_F55=y

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
# CONFIG_SERIO_RAW is not set
CONFIG_SERIO_ALTERA_PS2=y
CONFIG_SERIO_PS2MULT=y
CONFIG_SERIO_ARC_PS2=y
# CONFIG_SERIO_GPIO_PS2 is not set
# CONFIG_USERIO is not set
CONFIG_GAMEPORT=y
CONFIG_GAMEPORT_NS558=y
# CONFIG_GAMEPORT_L4 is not set
CONFIG_GAMEPORT_EMU10K1=y
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
# CONFIG_CYCLADES is not set
# CONFIG_MOXA_INTELLIO is not set
# CONFIG_MOXA_SMARTIO is not set
CONFIG_SYNCLINKMP=y
CONFIG_SYNCLINK_GT=y
CONFIG_NOZOMI=y
# CONFIG_ISI is not set
CONFIG_N_HDLC=y
# CONFIG_N_GSM is not set
CONFIG_TRACE_ROUTER=y
CONFIG_TRACE_SINK=y
# CONFIG_DEVMEM is not set
# CONFIG_DEVKMEM is not set

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
# CONFIG_SERIAL_8250_PNP is not set
CONFIG_SERIAL_8250_FINTEK=y
CONFIG_SERIAL_8250_CONSOLE=y
# CONFIG_SERIAL_8250_PCI is not set
# CONFIG_SERIAL_8250_MEN_MCB is not set
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set
CONFIG_SERIAL_8250_DW=y
CONFIG_SERIAL_8250_RT288X=y
CONFIG_SERIAL_8250_LPSS=y
CONFIG_SERIAL_8250_MID=y
CONFIG_SERIAL_8250_MOXA=y

#
# Non-8250 serial port support
#
CONFIG_SERIAL_UARTLITE=y
# CONFIG_SERIAL_UARTLITE_CONSOLE is not set
CONFIG_SERIAL_UARTLITE_NR_UARTS=1
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
CONFIG_SERIAL_JSM=y
CONFIG_SERIAL_SCCNXP=y
# CONFIG_SERIAL_SCCNXP_CONSOLE is not set
CONFIG_SERIAL_SC16IS7XX=y
# CONFIG_SERIAL_SC16IS7XX_I2C is not set
CONFIG_SERIAL_ALTERA_JTAGUART=y
CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE=y
# CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE_BYPASS is not set
# CONFIG_SERIAL_ALTERA_UART is not set
CONFIG_SERIAL_ARC=y
CONFIG_SERIAL_ARC_CONSOLE=y
CONFIG_SERIAL_ARC_NR_PORTS=1
CONFIG_SERIAL_RP2=y
CONFIG_SERIAL_RP2_NR_UARTS=32
# CONFIG_SERIAL_FSL_LPUART is not set
# CONFIG_SERIAL_MEN_Z135 is not set
CONFIG_SERIAL_DEV_BUS=y
# CONFIG_SERIAL_DEV_CTRL_TTYPORT is not set
# CONFIG_TTY_PRINTK is not set
# CONFIG_VIRTIO_CONSOLE is not set
CONFIG_IPMI_HANDLER=y
CONFIG_IPMI_PROC_INTERFACE=y
# CONFIG_IPMI_PANIC_EVENT is not set
CONFIG_IPMI_DEVICE_INTERFACE=y
CONFIG_IPMI_SI=y
CONFIG_IPMI_SSIF=y
CONFIG_IPMI_WATCHDOG=y
CONFIG_IPMI_POWEROFF=y
# CONFIG_HW_RANDOM is not set
CONFIG_NVRAM=y
CONFIG_R3964=y
CONFIG_APPLICOM=y
CONFIG_MWAVE=y
# CONFIG_RAW_DRIVER is not set
# CONFIG_HPET is not set
# CONFIG_HANGCHECK_TIMER is not set
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS_CORE=y
CONFIG_TCG_TIS=y
# CONFIG_TCG_TIS_I2C_ATMEL is not set
CONFIG_TCG_TIS_I2C_INFINEON=y
# CONFIG_TCG_TIS_I2C_NUVOTON is not set
CONFIG_TCG_NSC=y
CONFIG_TCG_ATMEL=y
CONFIG_TCG_INFINEON=y
CONFIG_TCG_CRB=y
CONFIG_TCG_VTPM_PROXY=y
CONFIG_TCG_TIS_ST33ZP24=y
CONFIG_TCG_TIS_ST33ZP24_I2C=y
CONFIG_TELCLOCK=y
# CONFIG_DEVPORT is not set
# CONFIG_XILLYBUS is not set

#
# I2C support
#
CONFIG_I2C=y
# CONFIG_ACPI_I2C_OPREGION is not set
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
CONFIG_I2C_CHARDEV=y
# CONFIG_I2C_MUX is not set
# CONFIG_I2C_HELPER_AUTO is not set
CONFIG_I2C_SMBUS=y

#
# I2C Algorithms
#
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_ALGOPCF=y
CONFIG_I2C_ALGOPCA=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
CONFIG_I2C_ALI1563=y
# CONFIG_I2C_ALI15X3 is not set
CONFIG_I2C_AMD756=y
CONFIG_I2C_AMD756_S4882=y
CONFIG_I2C_AMD8111=y
# CONFIG_I2C_I801 is not set
CONFIG_I2C_ISCH=y
CONFIG_I2C_ISMT=y
CONFIG_I2C_PIIX4=y
# CONFIG_I2C_CHT_WC is not set
CONFIG_I2C_NFORCE2=y
CONFIG_I2C_NFORCE2_S4985=y
CONFIG_I2C_SIS5595=y
CONFIG_I2C_SIS630=y
# CONFIG_I2C_SIS96X is not set
CONFIG_I2C_VIA=y
CONFIG_I2C_VIAPRO=y

#
# ACPI drivers
#
CONFIG_I2C_SCMI=y

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
CONFIG_I2C_CBUS_GPIO=y
CONFIG_I2C_DESIGNWARE_CORE=y
CONFIG_I2C_DESIGNWARE_PLATFORM=y
CONFIG_I2C_DESIGNWARE_SLAVE=y
CONFIG_I2C_DESIGNWARE_PCI=y
CONFIG_I2C_DESIGNWARE_BAYTRAIL=y
# CONFIG_I2C_EMEV2 is not set
CONFIG_I2C_GPIO=y
# CONFIG_I2C_GPIO_FAULT_INJECTOR is not set
CONFIG_I2C_OCORES=y
CONFIG_I2C_PCA_PLATFORM=y
CONFIG_I2C_SIMTEC=y
# CONFIG_I2C_XILINX is not set

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_DIOLAN_U2C is not set
CONFIG_I2C_DLN2=y
CONFIG_I2C_PARPORT_LIGHT=y
# CONFIG_I2C_ROBOTFUZZ_OSIF is not set
# CONFIG_I2C_TAOS_EVM is not set
CONFIG_I2C_TINY_USB=y
CONFIG_I2C_VIPERBOARD=y

#
# Other I2C/SMBus bus drivers
#
CONFIG_I2C_MLXCPLD=y
# CONFIG_I2C_CROS_EC_TUNNEL is not set
CONFIG_I2C_SLAVE=y
# CONFIG_I2C_SLAVE_EEPROM is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_SPI is not set
# CONFIG_SPMI is not set
CONFIG_HSI=y
CONFIG_HSI_BOARDINFO=y

#
# HSI controllers
#

#
# HSI clients
#
CONFIG_HSI_CHAR=y
# CONFIG_PPS is not set

#
# PTP clock support
#

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
CONFIG_PINCTRL=y
CONFIG_PINMUX=y
CONFIG_PINCONF=y
CONFIG_GENERIC_PINCONF=y
# CONFIG_DEBUG_PINCTRL is not set
CONFIG_PINCTRL_AMD=y
CONFIG_PINCTRL_MCP23S08=y
# CONFIG_PINCTRL_SX150X is not set
# CONFIG_PINCTRL_BAYTRAIL is not set
# CONFIG_PINCTRL_CHERRYVIEW is not set
CONFIG_PINCTRL_INTEL=y
# CONFIG_PINCTRL_BROXTON is not set
CONFIG_PINCTRL_CANNONLAKE=y
# CONFIG_PINCTRL_CEDARFORK is not set
# CONFIG_PINCTRL_DENVERTON is not set
CONFIG_PINCTRL_GEMINILAKE=y
CONFIG_PINCTRL_LEWISBURG=y
CONFIG_PINCTRL_SUNRISEPOINT=y
CONFIG_GPIOLIB=y
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
# CONFIG_DEBUG_GPIO is not set
CONFIG_GPIO_SYSFS=y
CONFIG_GPIO_GENERIC=y

#
# Memory mapped GPIO drivers
#
CONFIG_GPIO_AMDPT=y
CONFIG_GPIO_DWAPB=y
CONFIG_GPIO_GENERIC_PLATFORM=y
# CONFIG_GPIO_ICH is not set
CONFIG_GPIO_LYNXPOINT=y
# CONFIG_GPIO_MB86S7X is not set
CONFIG_GPIO_MENZ127=y
CONFIG_GPIO_MOCKUP=y
CONFIG_GPIO_VX855=y

#
# Port-mapped I/O GPIO drivers
#
# CONFIG_GPIO_F7188X is not set
# CONFIG_GPIO_IT87 is not set
# CONFIG_GPIO_SCH is not set
CONFIG_GPIO_SCH311X=y
# CONFIG_GPIO_WINBOND is not set
CONFIG_GPIO_WS16C48=y

#
# I2C GPIO expanders
#
# CONFIG_GPIO_ADP5588 is not set
# CONFIG_GPIO_MAX7300 is not set
CONFIG_GPIO_MAX732X=y
CONFIG_GPIO_MAX732X_IRQ=y
# CONFIG_GPIO_PCA953X is not set
CONFIG_GPIO_PCF857X=y
CONFIG_GPIO_TPIC2810=y

#
# MFD GPIO expanders
#
# CONFIG_GPIO_ADP5520 is not set
# CONFIG_GPIO_BD9571MWV is not set
CONFIG_GPIO_DLN2=y
# CONFIG_GPIO_LP3943 is not set
CONFIG_GPIO_LP873X=y
CONFIG_GPIO_TPS65912=y
# CONFIG_GPIO_WM8994 is not set

#
# PCI GPIO expanders
#
CONFIG_GPIO_AMD8111=y
CONFIG_GPIO_BT8XX=y
CONFIG_GPIO_ML_IOH=y
CONFIG_GPIO_PCI_IDIO_16=y
CONFIG_GPIO_PCIE_IDIO_24=y
# CONFIG_GPIO_RDC321X is not set

#
# USB GPIO expanders
#
CONFIG_GPIO_VIPERBOARD=y
CONFIG_W1=y
# CONFIG_W1_CON is not set

#
# 1-wire Bus Masters
#
# CONFIG_W1_MASTER_MATROX is not set
# CONFIG_W1_MASTER_DS2490 is not set
CONFIG_W1_MASTER_DS2482=y
CONFIG_W1_MASTER_DS1WM=y
CONFIG_W1_MASTER_GPIO=y

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
CONFIG_W1_SLAVE_SMEM=y
# CONFIG_W1_SLAVE_DS2405 is not set
# CONFIG_W1_SLAVE_DS2408 is not set
CONFIG_W1_SLAVE_DS2413=y
# CONFIG_W1_SLAVE_DS2406 is not set
# CONFIG_W1_SLAVE_DS2423 is not set
CONFIG_W1_SLAVE_DS2805=y
CONFIG_W1_SLAVE_DS2431=y
CONFIG_W1_SLAVE_DS2433=y
# CONFIG_W1_SLAVE_DS2433_CRC is not set
CONFIG_W1_SLAVE_DS2438=y
# CONFIG_W1_SLAVE_DS2760 is not set
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=y
# CONFIG_W1_SLAVE_DS28E04 is not set
CONFIG_W1_SLAVE_DS28E17=y
# CONFIG_POWER_AVS is not set
# CONFIG_POWER_RESET is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
CONFIG_PDA_POWER=y
# CONFIG_TEST_POWER is not set
CONFIG_BATTERY_88PM860X=y
CONFIG_BATTERY_DS2780=y
# CONFIG_BATTERY_DS2781 is not set
CONFIG_BATTERY_DS2782=y
CONFIG_BATTERY_SBS=y
# CONFIG_CHARGER_SBS is not set
CONFIG_BATTERY_BQ27XXX=y
CONFIG_BATTERY_BQ27XXX_I2C=y
CONFIG_BATTERY_BQ27XXX_HDQ=y
# CONFIG_BATTERY_BQ27XXX_DT_UPDATES_NVM is not set
# CONFIG_BATTERY_DA9030 is not set
CONFIG_BATTERY_DA9150=y
CONFIG_BATTERY_MAX17040=y
CONFIG_BATTERY_MAX17042=y
CONFIG_BATTERY_MAX1721X=y
CONFIG_CHARGER_88PM860X=y
# CONFIG_CHARGER_PCF50633 is not set
CONFIG_CHARGER_ISP1704=y
CONFIG_CHARGER_MAX8903=y
# CONFIG_CHARGER_LP8727 is not set
CONFIG_CHARGER_GPIO=y
# CONFIG_CHARGER_MANAGER is not set
CONFIG_CHARGER_LTC3651=y
# CONFIG_CHARGER_MAX14577 is not set
CONFIG_CHARGER_MAX77693=y
# CONFIG_CHARGER_MAX8997 is not set
CONFIG_CHARGER_BQ2415X=y
CONFIG_CHARGER_BQ24190=y
# CONFIG_CHARGER_BQ24257 is not set
CONFIG_CHARGER_BQ24735=y
CONFIG_CHARGER_BQ25890=y
CONFIG_CHARGER_SMB347=y
CONFIG_BATTERY_GAUGE_LTC2941=y
CONFIG_CHARGER_RT9455=y
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
# CONFIG_SENSORS_AD7414 is not set
CONFIG_SENSORS_AD7418=y
# CONFIG_SENSORS_ADM1021 is not set
CONFIG_SENSORS_ADM1025=y
CONFIG_SENSORS_ADM1026=y
# CONFIG_SENSORS_ADM1029 is not set
# CONFIG_SENSORS_ADM1031 is not set
CONFIG_SENSORS_ADM9240=y
CONFIG_SENSORS_ADT7X10=y
CONFIG_SENSORS_ADT7410=y
CONFIG_SENSORS_ADT7411=y
CONFIG_SENSORS_ADT7462=y
CONFIG_SENSORS_ADT7470=y
# CONFIG_SENSORS_ADT7475 is not set
CONFIG_SENSORS_ASC7621=y
CONFIG_SENSORS_K8TEMP=y
# CONFIG_SENSORS_K10TEMP is not set
CONFIG_SENSORS_FAM15H_POWER=y
CONFIG_SENSORS_APPLESMC=y
# CONFIG_SENSORS_ASB100 is not set
CONFIG_SENSORS_ASPEED=y
CONFIG_SENSORS_ATXP1=y
# CONFIG_SENSORS_DS620 is not set
CONFIG_SENSORS_DS1621=y
CONFIG_SENSORS_DELL_SMM=y
CONFIG_SENSORS_I5K_AMB=y
# CONFIG_SENSORS_F71805F is not set
CONFIG_SENSORS_F71882FG=y
CONFIG_SENSORS_F75375S=y
# CONFIG_SENSORS_MC13783_ADC is not set
# CONFIG_SENSORS_FSCHMD is not set
CONFIG_SENSORS_GL518SM=y
CONFIG_SENSORS_GL520SM=y
# CONFIG_SENSORS_G760A is not set
CONFIG_SENSORS_G762=y
# CONFIG_SENSORS_HIH6130 is not set
CONFIG_SENSORS_IBMAEM=y
CONFIG_SENSORS_IBMPEX=y
CONFIG_SENSORS_I5500=y
# CONFIG_SENSORS_CORETEMP is not set
# CONFIG_SENSORS_IT87 is not set
CONFIG_SENSORS_JC42=y
CONFIG_SENSORS_POWR1220=y
# CONFIG_SENSORS_LINEAGE is not set
CONFIG_SENSORS_LTC2945=y
CONFIG_SENSORS_LTC2990=y
# CONFIG_SENSORS_LTC4151 is not set
# CONFIG_SENSORS_LTC4215 is not set
CONFIG_SENSORS_LTC4222=y
# CONFIG_SENSORS_LTC4245 is not set
CONFIG_SENSORS_LTC4260=y
CONFIG_SENSORS_LTC4261=y
CONFIG_SENSORS_MAX16065=y
CONFIG_SENSORS_MAX1619=y
CONFIG_SENSORS_MAX1668=y
# CONFIG_SENSORS_MAX197 is not set
CONFIG_SENSORS_MAX6621=y
CONFIG_SENSORS_MAX6639=y
CONFIG_SENSORS_MAX6642=y
CONFIG_SENSORS_MAX6650=y
# CONFIG_SENSORS_MAX6697 is not set
CONFIG_SENSORS_MAX31790=y
CONFIG_SENSORS_MCP3021=y
# CONFIG_SENSORS_TC654 is not set
CONFIG_SENSORS_MENF21BMC_HWMON=y
# CONFIG_SENSORS_LM63 is not set
CONFIG_SENSORS_LM73=y
# CONFIG_SENSORS_LM75 is not set
CONFIG_SENSORS_LM77=y
CONFIG_SENSORS_LM78=y
CONFIG_SENSORS_LM80=y
CONFIG_SENSORS_LM83=y
CONFIG_SENSORS_LM85=y
# CONFIG_SENSORS_LM87 is not set
CONFIG_SENSORS_LM90=y
# CONFIG_SENSORS_LM92 is not set
CONFIG_SENSORS_LM93=y
# CONFIG_SENSORS_LM95234 is not set
CONFIG_SENSORS_LM95241=y
CONFIG_SENSORS_LM95245=y
CONFIG_SENSORS_PC87360=y
# CONFIG_SENSORS_PC87427 is not set
# CONFIG_SENSORS_NTC_THERMISTOR is not set
CONFIG_SENSORS_NCT6683=y
# CONFIG_SENSORS_NCT6775 is not set
# CONFIG_SENSORS_NCT7802 is not set
# CONFIG_SENSORS_NCT7904 is not set
CONFIG_SENSORS_PCF8591=y
CONFIG_PMBUS=y
CONFIG_SENSORS_PMBUS=y
# CONFIG_SENSORS_ADM1275 is not set
CONFIG_SENSORS_IBM_CFFPS=y
CONFIG_SENSORS_IR35221=y
CONFIG_SENSORS_LM25066=y
CONFIG_SENSORS_LTC2978=y
# CONFIG_SENSORS_LTC2978_REGULATOR is not set
# CONFIG_SENSORS_LTC3815 is not set
CONFIG_SENSORS_MAX16064=y
CONFIG_SENSORS_MAX20751=y
# CONFIG_SENSORS_MAX31785 is not set
# CONFIG_SENSORS_MAX34440 is not set
CONFIG_SENSORS_MAX8688=y
# CONFIG_SENSORS_TPS40422 is not set
# CONFIG_SENSORS_TPS53679 is not set
CONFIG_SENSORS_UCD9000=y
CONFIG_SENSORS_UCD9200=y
CONFIG_SENSORS_ZL6100=y
CONFIG_SENSORS_SHT15=y
# CONFIG_SENSORS_SHT21 is not set
CONFIG_SENSORS_SHT3x=y
# CONFIG_SENSORS_SHTC1 is not set
# CONFIG_SENSORS_SIS5595 is not set
# CONFIG_SENSORS_DME1737 is not set
CONFIG_SENSORS_EMC1403=y
CONFIG_SENSORS_EMC2103=y
CONFIG_SENSORS_EMC6W201=y
CONFIG_SENSORS_SMSC47M1=y
CONFIG_SENSORS_SMSC47M192=y
CONFIG_SENSORS_SMSC47B397=y
# CONFIG_SENSORS_STTS751 is not set
CONFIG_SENSORS_SMM665=y
CONFIG_SENSORS_ADC128D818=y
# CONFIG_SENSORS_ADS1015 is not set
CONFIG_SENSORS_ADS7828=y
# CONFIG_SENSORS_AMC6821 is not set
CONFIG_SENSORS_INA209=y
# CONFIG_SENSORS_INA2XX is not set
# CONFIG_SENSORS_INA3221 is not set
CONFIG_SENSORS_TC74=y
CONFIG_SENSORS_THMC50=y
CONFIG_SENSORS_TMP102=y
# CONFIG_SENSORS_TMP103 is not set
# CONFIG_SENSORS_TMP108 is not set
CONFIG_SENSORS_TMP401=y
# CONFIG_SENSORS_TMP421 is not set
CONFIG_SENSORS_VIA_CPUTEMP=y
# CONFIG_SENSORS_VIA686A is not set
# CONFIG_SENSORS_VT1211 is not set
CONFIG_SENSORS_VT8231=y
# CONFIG_SENSORS_W83773G is not set
CONFIG_SENSORS_W83781D=y
CONFIG_SENSORS_W83791D=y
CONFIG_SENSORS_W83792D=y
# CONFIG_SENSORS_W83793 is not set
CONFIG_SENSORS_W83795=y
CONFIG_SENSORS_W83795_FANCTRL=y
CONFIG_SENSORS_W83L785TS=y
# CONFIG_SENSORS_W83L786NG is not set
CONFIG_SENSORS_W83627HF=y
CONFIG_SENSORS_W83627EHF=y
# CONFIG_SENSORS_XGENE is not set

#
# ACPI drivers
#
CONFIG_SENSORS_ACPI_POWER=y
CONFIG_SENSORS_ATK0110=y
CONFIG_THERMAL=y
CONFIG_THERMAL_STATISTICS=y
CONFIG_THERMAL_EMERGENCY_POWEROFF_DELAY_MS=0
CONFIG_THERMAL_HWMON=y
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
# CONFIG_CLOCK_THERMAL is not set
# CONFIG_DEVFREQ_THERMAL is not set
CONFIG_THERMAL_EMULATION=y
CONFIG_INTEL_POWERCLAMP=y
CONFIG_INTEL_SOC_DTS_IOSF_CORE=y
CONFIG_INTEL_SOC_DTS_THERMAL=y

#
# ACPI INT340X thermal drivers
#
CONFIG_INT340X_THERMAL=y
CONFIG_ACPI_THERMAL_REL=y
# CONFIG_INT3406_THERMAL is not set
CONFIG_INTEL_PCH_THERMAL=y
# CONFIG_WATCHDOG is not set
CONFIG_SSB_POSSIBLE=y
# CONFIG_SSB is not set
CONFIG_BCMA_POSSIBLE=y
# CONFIG_BCMA is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
CONFIG_MFD_AS3711=y
CONFIG_PMIC_ADP5520=y
# CONFIG_MFD_AAT2870_CORE is not set
CONFIG_MFD_BCM590XX=y
CONFIG_MFD_BD9571MWV=y
# CONFIG_MFD_AXP20X_I2C is not set
CONFIG_MFD_CROS_EC=y
# CONFIG_MFD_CROS_EC_I2C is not set
CONFIG_MFD_CROS_EC_CHARDEV=y
CONFIG_PMIC_DA903X=y
# CONFIG_MFD_DA9052_I2C is not set
# CONFIG_MFD_DA9055 is not set
CONFIG_MFD_DA9062=y
CONFIG_MFD_DA9063=y
CONFIG_MFD_DA9150=y
CONFIG_MFD_DLN2=y
CONFIG_MFD_MC13XXX=y
CONFIG_MFD_MC13XXX_I2C=y
CONFIG_HTC_PASIC3=y
CONFIG_HTC_I2CPLD=y
# CONFIG_MFD_INTEL_QUARK_I2C_GPIO is not set
CONFIG_LPC_ICH=y
CONFIG_LPC_SCH=y
# CONFIG_INTEL_SOC_PMIC is not set
CONFIG_INTEL_SOC_PMIC_CHTWC=y
# CONFIG_INTEL_SOC_PMIC_CHTDC_TI is not set
CONFIG_MFD_INTEL_LPSS=y
CONFIG_MFD_INTEL_LPSS_ACPI=y
CONFIG_MFD_INTEL_LPSS_PCI=y
# CONFIG_MFD_JANZ_CMODIO is not set
# CONFIG_MFD_KEMPLD is not set
# CONFIG_MFD_88PM800 is not set
# CONFIG_MFD_88PM805 is not set
CONFIG_MFD_88PM860X=y
CONFIG_MFD_MAX14577=y
CONFIG_MFD_MAX77693=y
CONFIG_MFD_MAX77843=y
CONFIG_MFD_MAX8907=y
# CONFIG_MFD_MAX8925 is not set
CONFIG_MFD_MAX8997=y
CONFIG_MFD_MAX8998=y
CONFIG_MFD_MT6397=y
CONFIG_MFD_MENF21BMC=y
CONFIG_MFD_VIPERBOARD=y
CONFIG_MFD_RETU=y
CONFIG_MFD_PCF50633=y
CONFIG_PCF50633_ADC=y
CONFIG_PCF50633_GPIO=y
CONFIG_MFD_RDC321X=y
# CONFIG_MFD_RT5033 is not set
# CONFIG_MFD_RC5T583 is not set
CONFIG_MFD_SEC_CORE=y
CONFIG_MFD_SI476X_CORE=y
CONFIG_MFD_SM501=y
# CONFIG_MFD_SM501_GPIO is not set
CONFIG_MFD_SKY81452=y
# CONFIG_MFD_SMSC is not set
# CONFIG_ABX500_CORE is not set
CONFIG_MFD_SYSCON=y
# CONFIG_MFD_TI_AM335X_TSCADC is not set
CONFIG_MFD_LP3943=y
# CONFIG_MFD_LP8788 is not set
# CONFIG_MFD_TI_LMU is not set
# CONFIG_MFD_PALMAS is not set
CONFIG_TPS6105X=y
# CONFIG_TPS65010 is not set
CONFIG_TPS6507X=y
# CONFIG_MFD_TPS65086 is not set
# CONFIG_MFD_TPS65090 is not set
# CONFIG_MFD_TPS68470 is not set
CONFIG_MFD_TI_LP873X=y
# CONFIG_MFD_TPS6586X is not set
# CONFIG_MFD_TPS65910 is not set
CONFIG_MFD_TPS65912=y
CONFIG_MFD_TPS65912_I2C=y
CONFIG_MFD_TPS80031=y
# CONFIG_TWL4030_CORE is not set
# CONFIG_TWL6040_CORE is not set
CONFIG_MFD_WL1273_CORE=y
CONFIG_MFD_LM3533=y
CONFIG_MFD_VX855=y
# CONFIG_MFD_ARIZONA_I2C is not set
CONFIG_MFD_WM8400=y
# CONFIG_MFD_WM831X_I2C is not set
# CONFIG_MFD_WM8350_I2C is not set
CONFIG_MFD_WM8994=y
CONFIG_RAVE_SP_CORE=y
CONFIG_REGULATOR=y
# CONFIG_REGULATOR_DEBUG is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=y
CONFIG_REGULATOR_VIRTUAL_CONSUMER=y
CONFIG_REGULATOR_USERSPACE_CONSUMER=y
# CONFIG_REGULATOR_88PG86X is not set
# CONFIG_REGULATOR_88PM8607 is not set
CONFIG_REGULATOR_ACT8865=y
CONFIG_REGULATOR_AD5398=y
CONFIG_REGULATOR_ANATOP=y
CONFIG_REGULATOR_AS3711=y
CONFIG_REGULATOR_BCM590XX=y
# CONFIG_REGULATOR_BD9571MWV is not set
CONFIG_REGULATOR_DA903X=y
CONFIG_REGULATOR_DA9062=y
# CONFIG_REGULATOR_DA9063 is not set
# CONFIG_REGULATOR_DA9210 is not set
# CONFIG_REGULATOR_DA9211 is not set
CONFIG_REGULATOR_FAN53555=y
CONFIG_REGULATOR_GPIO=y
CONFIG_REGULATOR_ISL9305=y
CONFIG_REGULATOR_ISL6271A=y
CONFIG_REGULATOR_LP3971=y
CONFIG_REGULATOR_LP3972=y
# CONFIG_REGULATOR_LP872X is not set
CONFIG_REGULATOR_LP8755=y
CONFIG_REGULATOR_LTC3589=y
# CONFIG_REGULATOR_LTC3676 is not set
# CONFIG_REGULATOR_MAX14577 is not set
CONFIG_REGULATOR_MAX1586=y
CONFIG_REGULATOR_MAX8649=y
CONFIG_REGULATOR_MAX8660=y
CONFIG_REGULATOR_MAX8907=y
# CONFIG_REGULATOR_MAX8952 is not set
CONFIG_REGULATOR_MAX8997=y
# CONFIG_REGULATOR_MAX8998 is not set
CONFIG_REGULATOR_MAX77693=y
CONFIG_REGULATOR_MC13XXX_CORE=y
CONFIG_REGULATOR_MC13783=y
# CONFIG_REGULATOR_MC13892 is not set
# CONFIG_REGULATOR_MT6311 is not set
CONFIG_REGULATOR_MT6323=y
CONFIG_REGULATOR_MT6397=y
CONFIG_REGULATOR_PCF50633=y
# CONFIG_REGULATOR_PFUZE100 is not set
# CONFIG_REGULATOR_PV88060 is not set
CONFIG_REGULATOR_PV88080=y
CONFIG_REGULATOR_PV88090=y
CONFIG_REGULATOR_PWM=y
CONFIG_REGULATOR_S2MPA01=y
CONFIG_REGULATOR_S2MPS11=y
CONFIG_REGULATOR_S5M8767=y
CONFIG_REGULATOR_SKY81452=y
# CONFIG_REGULATOR_TPS51632 is not set
CONFIG_REGULATOR_TPS6105X=y
CONFIG_REGULATOR_TPS62360=y
CONFIG_REGULATOR_TPS65023=y
CONFIG_REGULATOR_TPS6507X=y
# CONFIG_REGULATOR_TPS65132 is not set
CONFIG_REGULATOR_TPS65912=y
CONFIG_REGULATOR_TPS80031=y
CONFIG_REGULATOR_WM8400=y
# CONFIG_REGULATOR_WM8994 is not set
CONFIG_RC_CORE=y
# CONFIG_RC_MAP is not set
# CONFIG_LIRC is not set
CONFIG_RC_DECODERS=y
CONFIG_IR_NEC_DECODER=y
CONFIG_IR_RC5_DECODER=y
CONFIG_IR_RC6_DECODER=y
CONFIG_IR_JVC_DECODER=y
# CONFIG_IR_SONY_DECODER is not set
CONFIG_IR_SANYO_DECODER=y
# CONFIG_IR_SHARP_DECODER is not set
CONFIG_IR_MCE_KBD_DECODER=y
CONFIG_IR_XMP_DECODER=y
CONFIG_IR_IMON_DECODER=y
CONFIG_RC_DEVICES=y
# CONFIG_RC_ATI_REMOTE is not set
CONFIG_IR_ENE=y
# CONFIG_IR_IMON is not set
CONFIG_IR_IMON_RAW=y
# CONFIG_IR_MCEUSB is not set
CONFIG_IR_ITE_CIR=y
CONFIG_IR_FINTEK=y
CONFIG_IR_NUVOTON=y
CONFIG_IR_REDRAT3=y
CONFIG_IR_STREAMZAP=y
# CONFIG_IR_WINBOND_CIR is not set
CONFIG_IR_IGORPLUGUSB=y
CONFIG_IR_IGUANA=y
CONFIG_IR_TTUSBIR=y
# CONFIG_RC_LOOPBACK is not set
CONFIG_IR_SERIAL=y
# CONFIG_IR_SERIAL_TRANSMITTER is not set
CONFIG_IR_SIR=y
# CONFIG_MEDIA_SUPPORT is not set

#
# Graphics support
#
CONFIG_AGP=y
CONFIG_AGP_AMD64=y
CONFIG_AGP_INTEL=y
CONFIG_AGP_SIS=y
CONFIG_AGP_VIA=y
CONFIG_INTEL_GTT=y
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
CONFIG_DRM=y
CONFIG_DRM_MIPI_DSI=y
CONFIG_DRM_DP_AUX_CHARDEV=y
CONFIG_DRM_DEBUG_MM=y
CONFIG_DRM_DEBUG_MM_SELFTEST=y
CONFIG_DRM_KMS_HELPER=y
CONFIG_DRM_KMS_FB_HELPER=y
CONFIG_DRM_FBDEV_EMULATION=y
CONFIG_DRM_FBDEV_OVERALLOC=100
# CONFIG_DRM_LOAD_EDID_FIRMWARE is not set
CONFIG_DRM_TTM=y
CONFIG_DRM_GEM_CMA_HELPER=y
CONFIG_DRM_KMS_CMA_HELPER=y
CONFIG_DRM_VM=y

#
# I2C encoder or helper chips
#
CONFIG_DRM_I2C_CH7006=y
CONFIG_DRM_I2C_SIL164=y
CONFIG_DRM_I2C_NXP_TDA998X=y
CONFIG_DRM_RADEON=y
# CONFIG_DRM_RADEON_USERPTR is not set
# CONFIG_DRM_AMDGPU is not set

#
# ACP (Audio CoProcessor) Configuration
#

#
# AMD Library routines
#
CONFIG_DRM_NOUVEAU=y
CONFIG_NOUVEAU_DEBUG=5
CONFIG_NOUVEAU_DEBUG_DEFAULT=3
# CONFIG_NOUVEAU_DEBUG_MMU is not set
# CONFIG_DRM_NOUVEAU_BACKLIGHT is not set
CONFIG_DRM_I915=y
# CONFIG_DRM_I915_ALPHA_SUPPORT is not set
CONFIG_DRM_I915_CAPTURE_ERROR=y
CONFIG_DRM_I915_COMPRESS_ERROR=y
# CONFIG_DRM_I915_USERPTR is not set
# CONFIG_DRM_I915_GVT is not set

#
# drm/i915 Debugging
#
# CONFIG_DRM_I915_WERROR is not set
# CONFIG_DRM_I915_DEBUG is not set
# CONFIG_DRM_I915_SW_FENCE_DEBUG_OBJECTS is not set
CONFIG_DRM_I915_SW_FENCE_CHECK_DAG=y
# CONFIG_DRM_I915_SELFTEST is not set
CONFIG_DRM_I915_LOW_LEVEL_TRACEPOINTS=y
CONFIG_DRM_I915_DEBUG_VBLANK_EVADE=y
# CONFIG_DRM_VGEM is not set
CONFIG_DRM_VMWGFX=y
# CONFIG_DRM_VMWGFX_FBCON is not set
CONFIG_DRM_GMA500=y
CONFIG_DRM_GMA600=y
# CONFIG_DRM_GMA3600 is not set
CONFIG_DRM_UDL=y
CONFIG_DRM_AST=y
# CONFIG_DRM_MGAG200 is not set
CONFIG_DRM_CIRRUS_QEMU=y
# CONFIG_DRM_QXL is not set
# CONFIG_DRM_BOCHS is not set
CONFIG_DRM_VIRTIO_GPU=y
CONFIG_DRM_PANEL=y

#
# Display Panels
#
CONFIG_DRM_PANEL_RASPBERRYPI_TOUCHSCREEN=y
CONFIG_DRM_BRIDGE=y
CONFIG_DRM_PANEL_BRIDGE=y

#
# Display Interface Bridges
#
# CONFIG_DRM_ANALOGIX_ANX78XX is not set
CONFIG_DRM_HISI_HIBMC=y
CONFIG_DRM_TINYDRM=y
# CONFIG_DRM_LEGACY is not set
CONFIG_DRM_PANEL_ORIENTATION_QUIRKS=y
CONFIG_DRM_LIB_RANDOM=y

#
# Frame buffer Devices
#
CONFIG_FB=y
CONFIG_FIRMWARE_EDID=y
CONFIG_FB_CMDLINE=y
CONFIG_FB_NOTIFY=y
CONFIG_FB_DDC=y
CONFIG_FB_BOOT_VESA_SUPPORT=y
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
CONFIG_FB_FOREIGN_ENDIAN=y
CONFIG_FB_BOTH_ENDIAN=y
# CONFIG_FB_BIG_ENDIAN is not set
# CONFIG_FB_LITTLE_ENDIAN is not set
CONFIG_FB_SYS_FOPS=y
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_HECUBA=y
CONFIG_FB_SVGALIB=y
CONFIG_FB_BACKLIGHT=y
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
CONFIG_FB_CIRRUS=y
CONFIG_FB_PM2=y
CONFIG_FB_PM2_FIFO_DISCONNECT=y
# CONFIG_FB_CYBER2000 is not set
CONFIG_FB_ARC=y
CONFIG_FB_ASILIANT=y
CONFIG_FB_IMSTT=y
# CONFIG_FB_VGA16 is not set
CONFIG_FB_UVESA=y
CONFIG_FB_VESA=y
# CONFIG_FB_EFI is not set
CONFIG_FB_N411=y
# CONFIG_FB_HGA is not set
CONFIG_FB_OPENCORES=y
CONFIG_FB_S1D13XXX=y
CONFIG_FB_NVIDIA=y
# CONFIG_FB_NVIDIA_I2C is not set
CONFIG_FB_NVIDIA_DEBUG=y
CONFIG_FB_NVIDIA_BACKLIGHT=y
CONFIG_FB_RIVA=y
# CONFIG_FB_RIVA_I2C is not set
CONFIG_FB_RIVA_DEBUG=y
# CONFIG_FB_RIVA_BACKLIGHT is not set
CONFIG_FB_I740=y
CONFIG_FB_LE80578=y
# CONFIG_FB_CARILLO_RANCH is not set
CONFIG_FB_MATROX=y
# CONFIG_FB_MATROX_MILLENIUM is not set
CONFIG_FB_MATROX_MYSTIQUE=y
CONFIG_FB_MATROX_G=y
# CONFIG_FB_MATROX_I2C is not set
CONFIG_FB_RADEON=y
# CONFIG_FB_RADEON_I2C is not set
# CONFIG_FB_RADEON_BACKLIGHT is not set
# CONFIG_FB_RADEON_DEBUG is not set
CONFIG_FB_ATY128=y
# CONFIG_FB_ATY128_BACKLIGHT is not set
CONFIG_FB_ATY=y
# CONFIG_FB_ATY_CT is not set
CONFIG_FB_ATY_GX=y
# CONFIG_FB_ATY_BACKLIGHT is not set
CONFIG_FB_S3=y
# CONFIG_FB_S3_DDC is not set
# CONFIG_FB_SAVAGE is not set
CONFIG_FB_SIS=y
CONFIG_FB_SIS_300=y
CONFIG_FB_SIS_315=y
CONFIG_FB_VIA=y
# CONFIG_FB_VIA_DIRECT_PROCFS is not set
# CONFIG_FB_VIA_X_COMPATIBILITY is not set
CONFIG_FB_NEOMAGIC=y
# CONFIG_FB_KYRO is not set
# CONFIG_FB_3DFX is not set
CONFIG_FB_VOODOO1=y
CONFIG_FB_VT8623=y
CONFIG_FB_TRIDENT=y
CONFIG_FB_ARK=y
CONFIG_FB_PM3=y
CONFIG_FB_CARMINE=y
CONFIG_FB_CARMINE_DRAM_EVAL=y
# CONFIG_CARMINE_DRAM_CUSTOM is not set
# CONFIG_FB_SM501 is not set
CONFIG_FB_SMSCUFX=y
CONFIG_FB_UDL=y
CONFIG_FB_IBM_GXT4500=y
CONFIG_FB_VIRTUAL=y
CONFIG_FB_METRONOME=y
# CONFIG_FB_MB862XX is not set
# CONFIG_FB_BROADSHEET is not set
# CONFIG_FB_AUO_K190X is not set
CONFIG_FB_SIMPLE=y
CONFIG_FB_SM712=y
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
# CONFIG_LCD_PLATFORM is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_GENERIC=y
CONFIG_BACKLIGHT_LM3533=y
# CONFIG_BACKLIGHT_CARILLO_RANCH is not set
CONFIG_BACKLIGHT_PWM=y
CONFIG_BACKLIGHT_DA903X=y
CONFIG_BACKLIGHT_APPLE=y
CONFIG_BACKLIGHT_PM8941_WLED=y
CONFIG_BACKLIGHT_SAHARA=y
CONFIG_BACKLIGHT_ADP5520=y
CONFIG_BACKLIGHT_ADP8860=y
CONFIG_BACKLIGHT_ADP8870=y
# CONFIG_BACKLIGHT_88PM860X is not set
# CONFIG_BACKLIGHT_PCF50633 is not set
# CONFIG_BACKLIGHT_LM3630A is not set
CONFIG_BACKLIGHT_LM3639=y
CONFIG_BACKLIGHT_LP855X=y
# CONFIG_BACKLIGHT_SKY81452 is not set
CONFIG_BACKLIGHT_AS3711=y
CONFIG_BACKLIGHT_GPIO=y
CONFIG_BACKLIGHT_LV5207LP=y
# CONFIG_BACKLIGHT_BD6107 is not set
CONFIG_BACKLIGHT_ARCXCNN=y
CONFIG_VGASTATE=y
CONFIG_HDMI=y
# CONFIG_LOGO is not set
# CONFIG_SOUND is not set

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
CONFIG_HIDRAW=y
# CONFIG_UHID is not set
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
# CONFIG_HID_A4TECH is not set
CONFIG_HID_ACCUTOUCH=y
# CONFIG_HID_ACRUX is not set
CONFIG_HID_APPLE=y
# CONFIG_HID_APPLEIR is not set
CONFIG_HID_ASUS=y
CONFIG_HID_AUREAL=y
CONFIG_HID_BELKIN=y
# CONFIG_HID_BETOP_FF is not set
CONFIG_HID_CHERRY=y
# CONFIG_HID_CHICONY is not set
CONFIG_HID_CORSAIR=y
CONFIG_HID_CMEDIA=y
CONFIG_HID_CP2112=y
# CONFIG_HID_CYPRESS is not set
CONFIG_HID_DRAGONRISE=y
CONFIG_DRAGONRISE_FF=y
CONFIG_HID_EMS_FF=y
CONFIG_HID_ELAN=y
CONFIG_HID_ELECOM=y
CONFIG_HID_ELO=y
CONFIG_HID_EZKEY=y
# CONFIG_HID_GEMBIRD is not set
CONFIG_HID_GFRM=y
CONFIG_HID_HOLTEK=y
# CONFIG_HOLTEK_FF is not set
CONFIG_HID_GOOGLE_HAMMER=y
CONFIG_HID_GT683R=y
# CONFIG_HID_KEYTOUCH is not set
CONFIG_HID_KYE=y
CONFIG_HID_UCLOGIC=y
CONFIG_HID_WALTOP=y
CONFIG_HID_GYRATION=y
# CONFIG_HID_ICADE is not set
CONFIG_HID_ITE=y
CONFIG_HID_JABRA=y
# CONFIG_HID_TWINHAN is not set
# CONFIG_HID_KENSINGTON is not set
CONFIG_HID_LCPOWER=y
CONFIG_HID_LED=y
# CONFIG_HID_LENOVO is not set
# CONFIG_HID_LOGITECH is not set
# CONFIG_HID_MAGICMOUSE is not set
CONFIG_HID_MAYFLASH=y
# CONFIG_HID_MICROSOFT is not set
CONFIG_HID_MONTEREY=y
# CONFIG_HID_MULTITOUCH is not set
# CONFIG_HID_NTI is not set
# CONFIG_HID_NTRIG is not set
CONFIG_HID_ORTEK=y
CONFIG_HID_PANTHERLORD=y
# CONFIG_PANTHERLORD_FF is not set
CONFIG_HID_PENMOUNT=y
CONFIG_HID_PETALYNX=y
CONFIG_HID_PICOLCD=y
# CONFIG_HID_PICOLCD_FB is not set
CONFIG_HID_PICOLCD_BACKLIGHT=y
# CONFIG_HID_PICOLCD_LCD is not set
# CONFIG_HID_PICOLCD_LEDS is not set
# CONFIG_HID_PICOLCD_CIR is not set
CONFIG_HID_PLANTRONICS=y
CONFIG_HID_PRIMAX=y
# CONFIG_HID_RETRODE is not set
# CONFIG_HID_ROCCAT is not set
CONFIG_HID_SAITEK=y
CONFIG_HID_SAMSUNG=y
# CONFIG_HID_SONY is not set
CONFIG_HID_SPEEDLINK=y
CONFIG_HID_STEELSERIES=y
CONFIG_HID_SUNPLUS=y
CONFIG_HID_RMI=y
# CONFIG_HID_GREENASIA is not set
# CONFIG_HID_SMARTJOYPLUS is not set
CONFIG_HID_TIVO=y
CONFIG_HID_TOPSEED=y
CONFIG_HID_THINGM=y
CONFIG_HID_THRUSTMASTER=y
# CONFIG_THRUSTMASTER_FF is not set
# CONFIG_HID_UDRAW_PS3 is not set
CONFIG_HID_WACOM=y
CONFIG_HID_WIIMOTE=y
CONFIG_HID_XINMO=y
# CONFIG_HID_ZEROPLUS is not set
CONFIG_HID_ZYDACRON=y
CONFIG_HID_SENSOR_HUB=y
CONFIG_HID_SENSOR_CUSTOM_SENSOR=y
# CONFIG_HID_ALPS is not set

#
# USB HID support
#
CONFIG_USB_HID=y
CONFIG_HID_PID=y
CONFIG_USB_HIDDEV=y

#
# I2C HID support
#
CONFIG_I2C_HID=y

#
# Intel ISH HID support
#
# CONFIG_INTEL_ISH_HID is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
CONFIG_USB_PCI=y
CONFIG_USB_ANNOUNCE_NEW_DEVICES=y

#
# Miscellaneous USB options
#
CONFIG_USB_DEFAULT_PERSIST=y
# CONFIG_USB_DYNAMIC_MINORS is not set
# CONFIG_USB_OTG is not set
CONFIG_USB_OTG_WHITELIST=y
CONFIG_USB_OTG_BLACKLIST_HUB=y
CONFIG_USB_LEDS_TRIGGER_USBPORT=y
# CONFIG_USB_MON is not set
CONFIG_USB_WUSB=y
CONFIG_USB_WUSB_CBAF=y
CONFIG_USB_WUSB_CBAF_DEBUG=y

#
# USB Host Controller Drivers
#
CONFIG_USB_C67X00_HCD=y
CONFIG_USB_XHCI_HCD=y
CONFIG_USB_XHCI_DBGCAP=y
CONFIG_USB_XHCI_PCI=y
CONFIG_USB_XHCI_PLATFORM=y
# CONFIG_USB_EHCI_HCD is not set
CONFIG_USB_OXU210HP_HCD=y
CONFIG_USB_ISP116X_HCD=y
# CONFIG_USB_FOTG210_HCD is not set
CONFIG_USB_OHCI_HCD=y
# CONFIG_USB_OHCI_HCD_PCI is not set
CONFIG_USB_OHCI_HCD_PLATFORM=y
CONFIG_USB_UHCI_HCD=y
# CONFIG_USB_U132_HCD is not set
# CONFIG_USB_SL811_HCD is not set
CONFIG_USB_R8A66597_HCD=y
CONFIG_USB_WHCI_HCD=y
# CONFIG_USB_HWA_HCD is not set
# CONFIG_USB_HCD_TEST_MODE is not set

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
# CONFIG_USB_MDC800 is not set
CONFIG_USB_MICROTEK=y
# CONFIG_USBIP_CORE is not set
CONFIG_USB_MUSB_HDRC=y
# CONFIG_USB_MUSB_HOST is not set
# CONFIG_USB_MUSB_GADGET is not set
CONFIG_USB_MUSB_DUAL_ROLE=y

#
# Platform Glue Layer
#

#
# MUSB DMA mode
#
# CONFIG_MUSB_PIO_ONLY is not set
CONFIG_USB_DWC3=y
# CONFIG_USB_DWC3_ULPI is not set
# CONFIG_USB_DWC3_HOST is not set
# CONFIG_USB_DWC3_GADGET is not set
CONFIG_USB_DWC3_DUAL_ROLE=y

#
# Platform Glue Driver Support
#
CONFIG_USB_DWC3_PCI=y
# CONFIG_USB_DWC2 is not set
CONFIG_USB_CHIPIDEA=y
CONFIG_USB_CHIPIDEA_PCI=y
CONFIG_USB_CHIPIDEA_UDC=y
# CONFIG_USB_CHIPIDEA_ULPI is not set
CONFIG_USB_ISP1760=y
CONFIG_USB_ISP1760_HCD=y
CONFIG_USB_ISP1760_HOST_ROLE=y
# CONFIG_USB_ISP1760_GADGET_ROLE is not set
# CONFIG_USB_ISP1760_DUAL_ROLE is not set

#
# USB port drivers
#
CONFIG_USB_SERIAL=y
CONFIG_USB_SERIAL_CONSOLE=y
CONFIG_USB_SERIAL_GENERIC=y
# CONFIG_USB_SERIAL_SIMPLE is not set
CONFIG_USB_SERIAL_AIRCABLE=y
CONFIG_USB_SERIAL_ARK3116=y
CONFIG_USB_SERIAL_BELKIN=y
CONFIG_USB_SERIAL_CH341=y
CONFIG_USB_SERIAL_WHITEHEAT=y
# CONFIG_USB_SERIAL_DIGI_ACCELEPORT is not set
CONFIG_USB_SERIAL_CP210X=y
CONFIG_USB_SERIAL_CYPRESS_M8=y
CONFIG_USB_SERIAL_EMPEG=y
CONFIG_USB_SERIAL_FTDI_SIO=y
CONFIG_USB_SERIAL_VISOR=y
CONFIG_USB_SERIAL_IPAQ=y
# CONFIG_USB_SERIAL_IR is not set
CONFIG_USB_SERIAL_EDGEPORT=y
# CONFIG_USB_SERIAL_EDGEPORT_TI is not set
CONFIG_USB_SERIAL_F81232=y
CONFIG_USB_SERIAL_F8153X=y
CONFIG_USB_SERIAL_GARMIN=y
# CONFIG_USB_SERIAL_IPW is not set
CONFIG_USB_SERIAL_IUU=y
# CONFIG_USB_SERIAL_KEYSPAN_PDA is not set
CONFIG_USB_SERIAL_KEYSPAN=y
CONFIG_USB_SERIAL_KLSI=y
# CONFIG_USB_SERIAL_KOBIL_SCT is not set
CONFIG_USB_SERIAL_MCT_U232=y
CONFIG_USB_SERIAL_METRO=y
# CONFIG_USB_SERIAL_MOS7720 is not set
CONFIG_USB_SERIAL_MOS7840=y
CONFIG_USB_SERIAL_MXUPORT=y
# CONFIG_USB_SERIAL_NAVMAN is not set
# CONFIG_USB_SERIAL_PL2303 is not set
# CONFIG_USB_SERIAL_OTI6858 is not set
CONFIG_USB_SERIAL_QCAUX=y
# CONFIG_USB_SERIAL_QUALCOMM is not set
CONFIG_USB_SERIAL_SPCP8X5=y
CONFIG_USB_SERIAL_SAFE=y
# CONFIG_USB_SERIAL_SAFE_PADDED is not set
# CONFIG_USB_SERIAL_SIERRAWIRELESS is not set
# CONFIG_USB_SERIAL_SYMBOL is not set
# CONFIG_USB_SERIAL_TI is not set
CONFIG_USB_SERIAL_CYBERJACK=y
# CONFIG_USB_SERIAL_XIRCOM is not set
CONFIG_USB_SERIAL_WWAN=y
CONFIG_USB_SERIAL_OPTION=y
# CONFIG_USB_SERIAL_OMNINET is not set
CONFIG_USB_SERIAL_OPTICON=y
CONFIG_USB_SERIAL_XSENS_MT=y
CONFIG_USB_SERIAL_WISHBONE=y
# CONFIG_USB_SERIAL_SSU100 is not set
# CONFIG_USB_SERIAL_QT2 is not set
# CONFIG_USB_SERIAL_UPD78F0730 is not set
CONFIG_USB_SERIAL_DEBUG=y

#
# USB Miscellaneous drivers
#
CONFIG_USB_EMI62=y
CONFIG_USB_EMI26=y
# CONFIG_USB_ADUTUX is not set
CONFIG_USB_SEVSEG=y
CONFIG_USB_RIO500=y
# CONFIG_USB_LEGOTOWER is not set
CONFIG_USB_LCD=y
CONFIG_USB_CYPRESS_CY7C63=y
CONFIG_USB_CYTHERM=y
CONFIG_USB_IDMOUSE=y
CONFIG_USB_FTDI_ELAN=y
# CONFIG_USB_APPLEDISPLAY is not set
# CONFIG_USB_SISUSBVGA is not set
CONFIG_USB_LD=y
# CONFIG_USB_TRANCEVIBRATOR is not set
# CONFIG_USB_IOWARRIOR is not set
# CONFIG_USB_TEST is not set
CONFIG_USB_EHSET_TEST_FIXTURE=y
CONFIG_USB_ISIGHTFW=y
# CONFIG_USB_YUREX is not set
CONFIG_USB_EZUSB_FX2=y
CONFIG_USB_HUB_USB251XB=y
CONFIG_USB_HSIC_USB3503=y
CONFIG_USB_HSIC_USB4604=y
CONFIG_USB_LINK_LAYER_TEST=y
# CONFIG_USB_ATM is not set

#
# USB Physical Layer drivers
#
CONFIG_USB_PHY=y
CONFIG_NOP_USB_XCEIV=y
# CONFIG_USB_GPIO_VBUS is not set
CONFIG_TAHVO_USB=y
CONFIG_TAHVO_USB_HOST_BY_DEFAULT=y
# CONFIG_USB_ISP1301 is not set
CONFIG_USB_GADGET=y
# CONFIG_USB_GADGET_DEBUG is not set
# CONFIG_USB_GADGET_DEBUG_FILES is not set
# CONFIG_USB_GADGET_DEBUG_FS is not set
CONFIG_USB_GADGET_VBUS_DRAW=2
CONFIG_USB_GADGET_STORAGE_NUM_BUFFERS=2
# CONFIG_U_SERIAL_CONSOLE is not set

#
# USB Peripheral Controller
#
CONFIG_USB_FOTG210_UDC=y
CONFIG_USB_GR_UDC=y
CONFIG_USB_R8A66597=y
CONFIG_USB_PXA27X=y
CONFIG_USB_MV_UDC=y
CONFIG_USB_MV_U3D=y
CONFIG_USB_SNP_CORE=y
CONFIG_USB_M66592=y
# CONFIG_USB_BDC_UDC is not set
CONFIG_USB_AMD5536UDC=y
CONFIG_USB_NET2272=y
CONFIG_USB_NET2272_DMA=y
# CONFIG_USB_NET2280 is not set
CONFIG_USB_GOKU=y
CONFIG_USB_EG20T=y
CONFIG_USB_DUMMY_HCD=y
CONFIG_USB_LIBCOMPOSITE=y
CONFIG_USB_F_ACM=y
CONFIG_USB_F_SS_LB=y
CONFIG_USB_U_SERIAL=y
CONFIG_USB_U_ETHER=y
CONFIG_USB_F_SERIAL=y
CONFIG_USB_F_OBEX=y
CONFIG_USB_F_NCM=y
CONFIG_USB_F_PHONET=y
CONFIG_USB_F_EEM=y
CONFIG_USB_F_RNDIS=y
CONFIG_USB_F_FS=y
CONFIG_USB_F_HID=y
CONFIG_USB_F_TCM=y
CONFIG_USB_CONFIGFS=y
CONFIG_USB_CONFIGFS_SERIAL=y
CONFIG_USB_CONFIGFS_ACM=y
CONFIG_USB_CONFIGFS_OBEX=y
CONFIG_USB_CONFIGFS_NCM=y
# CONFIG_USB_CONFIGFS_ECM is not set
# CONFIG_USB_CONFIGFS_ECM_SUBSET is not set
CONFIG_USB_CONFIGFS_RNDIS=y
CONFIG_USB_CONFIGFS_EEM=y
CONFIG_USB_CONFIGFS_PHONET=y
# CONFIG_USB_CONFIGFS_MASS_STORAGE is not set
CONFIG_USB_CONFIGFS_F_LB_SS=y
CONFIG_USB_CONFIGFS_F_FS=y
CONFIG_USB_CONFIGFS_F_HID=y
# CONFIG_USB_CONFIGFS_F_PRINTER is not set
CONFIG_USB_CONFIGFS_F_TCM=y
# CONFIG_TYPEC is not set
# CONFIG_USB_LED_TRIG is not set
CONFIG_USB_ULPI_BUS=y
CONFIG_UWB=y
# CONFIG_UWB_HWA is not set
CONFIG_UWB_WHCI=y
# CONFIG_MMC is not set
CONFIG_MEMSTICK=y
# CONFIG_MEMSTICK_DEBUG is not set

#
# MemoryStick drivers
#
CONFIG_MEMSTICK_UNSAFE_RESUME=y
# CONFIG_MSPRO_BLOCK is not set
CONFIG_MS_BLOCK=y

#
# MemoryStick Host Controller Drivers
#
CONFIG_MEMSTICK_TIFM_MS=y
# CONFIG_MEMSTICK_JMICRON_38X is not set
CONFIG_MEMSTICK_R592=y
# CONFIG_MEMSTICK_REALTEK_PCI is not set
CONFIG_MEMSTICK_REALTEK_USB=y
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y
CONFIG_LEDS_CLASS_FLASH=y
# CONFIG_LEDS_BRIGHTNESS_HW_CHANGED is not set

#
# LED drivers
#
CONFIG_LEDS_88PM860X=y
CONFIG_LEDS_AS3645A=y
CONFIG_LEDS_LM3530=y
# CONFIG_LEDS_LM3533 is not set
CONFIG_LEDS_LM3642=y
CONFIG_LEDS_MT6323=y
# CONFIG_LEDS_PCA9532 is not set
# CONFIG_LEDS_GPIO is not set
CONFIG_LEDS_LP3944=y
CONFIG_LEDS_LP3952=y
CONFIG_LEDS_LP55XX_COMMON=y
CONFIG_LEDS_LP5521=y
CONFIG_LEDS_LP5523=y
CONFIG_LEDS_LP5562=y
# CONFIG_LEDS_LP8501 is not set
# CONFIG_LEDS_PCA955X is not set
CONFIG_LEDS_PCA963X=y
CONFIG_LEDS_DA903X=y
# CONFIG_LEDS_PWM is not set
CONFIG_LEDS_REGULATOR=y
CONFIG_LEDS_BD2802=y
# CONFIG_LEDS_LT3593 is not set
CONFIG_LEDS_ADP5520=y
# CONFIG_LEDS_MC13783 is not set
CONFIG_LEDS_TCA6507=y
# CONFIG_LEDS_TLC591XX is not set
CONFIG_LEDS_MAX8997=y
CONFIG_LEDS_LM355x=y
# CONFIG_LEDS_MENF21BMC is not set

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
CONFIG_LEDS_BLINKM=y
CONFIG_LEDS_MLXREG=y
CONFIG_LEDS_USER=y
# CONFIG_LEDS_NIC78BX is not set

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
# CONFIG_LEDS_TRIGGER_TIMER is not set
CONFIG_LEDS_TRIGGER_ONESHOT=y
# CONFIG_LEDS_TRIGGER_MTD is not set
# CONFIG_LEDS_TRIGGER_HEARTBEAT is not set
CONFIG_LEDS_TRIGGER_BACKLIGHT=y
CONFIG_LEDS_TRIGGER_CPU=y
CONFIG_LEDS_TRIGGER_ACTIVITY=y
# CONFIG_LEDS_TRIGGER_GPIO is not set
# CONFIG_LEDS_TRIGGER_DEFAULT_ON is not set

#
# iptables trigger is under Netfilter config (LED target)
#
CONFIG_LEDS_TRIGGER_TRANSIENT=y
CONFIG_LEDS_TRIGGER_CAMERA=y
CONFIG_LEDS_TRIGGER_PANIC=y
CONFIG_LEDS_TRIGGER_NETDEV=y
# CONFIG_ACCESSIBILITY is not set
CONFIG_INFINIBAND=y
# CONFIG_INFINIBAND_USER_MAD is not set
CONFIG_INFINIBAND_USER_ACCESS=y
CONFIG_INFINIBAND_EXP_LEGACY_VERBS_NEW_UAPI=y
CONFIG_INFINIBAND_USER_MEM=y
# CONFIG_INFINIBAND_ON_DEMAND_PAGING is not set
CONFIG_INFINIBAND_ADDR_TRANS=y
CONFIG_INFINIBAND_ADDR_TRANS_CONFIGFS=y
CONFIG_INFINIBAND_MTHCA=y
# CONFIG_INFINIBAND_MTHCA_DEBUG is not set
CONFIG_INFINIBAND_QIB=y
CONFIG_INFINIBAND_CXGB3=y
CONFIG_INFINIBAND_CXGB4=y
CONFIG_MLX4_INFINIBAND=y
CONFIG_INFINIBAND_NES=y
# CONFIG_INFINIBAND_NES_DEBUG is not set
CONFIG_INFINIBAND_OCRDMA=y
# CONFIG_INFINIBAND_VMWARE_PVRDMA is not set
CONFIG_INFINIBAND_IPOIB=y
# CONFIG_INFINIBAND_IPOIB_CM is not set
# CONFIG_INFINIBAND_IPOIB_DEBUG is not set
CONFIG_INFINIBAND_SRP=y
CONFIG_INFINIBAND_SRPT=y
CONFIG_INFINIBAND_ISER=y
CONFIG_INFINIBAND_ISERT=y
CONFIG_INFINIBAND_OPA_VNIC=y
CONFIG_INFINIBAND_RDMAVT=y
CONFIG_RDMA_RXE=y
CONFIG_INFINIBAND_HFI1=y
# CONFIG_HFI1_DEBUG_SDMA_ORDER is not set
CONFIG_SDMA_VERBOSITY=y
CONFIG_INFINIBAND_QEDR=y
CONFIG_EDAC_ATOMIC_SCRUB=y
CONFIG_EDAC_SUPPORT=y
CONFIG_RTC_LIB=y
CONFIG_RTC_MC146818_LIB=y
# CONFIG_RTC_CLASS is not set
# CONFIG_DMADEVICES is not set

#
# DMABUF options
#
CONFIG_SYNC_FILE=y
CONFIG_SW_SYNC=y
CONFIG_AUXDISPLAY=y
# CONFIG_HD44780 is not set
CONFIG_IMG_ASCII_LCD=y
CONFIG_UIO=y
CONFIG_UIO_CIF=y
CONFIG_UIO_PDRV_GENIRQ=y
CONFIG_UIO_DMEM_GENIRQ=y
# CONFIG_UIO_AEC is not set
CONFIG_UIO_SERCOS3=y
CONFIG_UIO_PCI_GENERIC=y
CONFIG_UIO_NETX=y
# CONFIG_UIO_PRUSS is not set
CONFIG_UIO_MF624=y
# CONFIG_VIRT_DRIVERS is not set
CONFIG_VIRTIO=y
CONFIG_VIRTIO_MENU=y
CONFIG_VIRTIO_PCI=y
# CONFIG_VIRTIO_PCI_LEGACY is not set
# CONFIG_VIRTIO_BALLOON is not set
CONFIG_VIRTIO_INPUT=y
# CONFIG_VIRTIO_MMIO is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
# CONFIG_STAGING is not set
CONFIG_X86_PLATFORM_DEVICES=y
CONFIG_ACER_WMI=y
CONFIG_ACER_WIRELESS=y
# CONFIG_ACERHDF is not set
# CONFIG_ALIENWARE_WMI is not set
CONFIG_ASUS_LAPTOP=y
CONFIG_DELL_SMBIOS=y
CONFIG_DELL_SMBIOS_WMI=y
CONFIG_DELL_SMBIOS_SMM=y
CONFIG_DELL_WMI_DESCRIPTOR=y
CONFIG_DELL_WMI_AIO=y
CONFIG_DELL_WMI_LED=y
CONFIG_DELL_SMO8800=y
CONFIG_DELL_RBTN=y
CONFIG_FUJITSU_LAPTOP=y
CONFIG_FUJITSU_TABLET=y
CONFIG_AMILO_RFKILL=y
# CONFIG_GPD_POCKET_FAN is not set
CONFIG_HP_ACCEL=y
# CONFIG_HP_WIRELESS is not set
CONFIG_HP_WMI=y
CONFIG_MSI_LAPTOP=y
# CONFIG_PANASONIC_LAPTOP is not set
CONFIG_COMPAL_LAPTOP=y
CONFIG_SONY_LAPTOP=y
CONFIG_SONYPI_COMPAT=y
CONFIG_IDEAPAD_LAPTOP=y
CONFIG_SENSORS_HDAPS=y
# CONFIG_EEEPC_LAPTOP is not set
# CONFIG_ASUS_WMI is not set
CONFIG_ASUS_WIRELESS=y
CONFIG_ACPI_WMI=y
CONFIG_WMI_BMOF=y
CONFIG_INTEL_WMI_THUNDERBOLT=y
CONFIG_MSI_WMI=y
CONFIG_PEAQ_WMI=y
CONFIG_TOPSTAR_LAPTOP=y
# CONFIG_TOSHIBA_BT_RFKILL is not set
CONFIG_TOSHIBA_HAPS=y
# CONFIG_TOSHIBA_WMI is not set
CONFIG_ACPI_CMPC=y
CONFIG_INTEL_CHT_INT33FE=y
# CONFIG_INTEL_INT0002_VGPIO is not set
CONFIG_INTEL_HID_EVENT=y
CONFIG_INTEL_VBTN=y
CONFIG_INTEL_IPS=y
CONFIG_INTEL_PMC_CORE=y
# CONFIG_IBM_RTL is not set
CONFIG_SAMSUNG_LAPTOP=y
CONFIG_MXM_WMI=y
CONFIG_INTEL_OAKTRAIL=y
CONFIG_SAMSUNG_Q10=y
# CONFIG_APPLE_GMUX is not set
# CONFIG_INTEL_RST is not set
CONFIG_INTEL_SMARTCONNECT=y
CONFIG_PVPANIC=y
# CONFIG_INTEL_PMC_IPC is not set
CONFIG_SURFACE_PRO3_BUTTON=y
CONFIG_INTEL_PUNIT_IPC=y
CONFIG_MLX_PLATFORM=y
# CONFIG_INTEL_TURBO_MAX_3 is not set
CONFIG_PMC_ATOM=y
CONFIG_CHROME_PLATFORMS=y
CONFIG_CHROMEOS_PSTORE=y
CONFIG_CROS_EC_CTL=y
# CONFIG_CROS_EC_LPC is not set
CONFIG_CROS_EC_PROTO=y
CONFIG_CROS_KBD_LED_BACKLIGHT=y
# CONFIG_MELLANOX_PLATFORM is not set
CONFIG_CLKDEV_LOOKUP=y
CONFIG_HAVE_CLK_PREPARE=y
CONFIG_COMMON_CLK=y

#
# Common Clock Framework
#
# CONFIG_COMMON_CLK_SI5351 is not set
CONFIG_COMMON_CLK_SI544=y
# CONFIG_COMMON_CLK_CDCE706 is not set
# CONFIG_COMMON_CLK_CS2000_CP is not set
CONFIG_COMMON_CLK_S2MPS11=y
# CONFIG_COMMON_CLK_PWM is not set
CONFIG_HWSPINLOCK=y

#
# Clock Source drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_CLKBLD_I8253=y
CONFIG_MAILBOX=y
CONFIG_PCC=y
# CONFIG_ALTERA_MBOX is not set
CONFIG_IOMMU_SUPPORT=y

#
# Generic IOMMU Pagetable Support
#
# CONFIG_AMD_IOMMU is not set

#
# Remoteproc drivers
#
CONFIG_REMOTEPROC=y

#
# Rpmsg drivers
#
CONFIG_RPMSG=y
# CONFIG_RPMSG_CHAR is not set
CONFIG_RPMSG_QCOM_GLINK_NATIVE=y
CONFIG_RPMSG_QCOM_GLINK_RPM=y
CONFIG_RPMSG_VIRTIO=y
CONFIG_SOUNDWIRE=y

#
# SoundWire Devices
#
CONFIG_SOUNDWIRE_BUS=y
CONFIG_SOUNDWIRE_CADENCE=y
CONFIG_SOUNDWIRE_INTEL=y

#
# SOC (System On Chip) specific Drivers
#

#
# Amlogic SoC drivers
#

#
# Broadcom SoC drivers
#

#
# i.MX SoC drivers
#

#
# Qualcomm SoC drivers
#
CONFIG_SOC_TI=y

#
# Xilinx SoC drivers
#
CONFIG_XILINX_VCU=y
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND=y
CONFIG_DEVFREQ_GOV_PERFORMANCE=y
# CONFIG_DEVFREQ_GOV_POWERSAVE is not set
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
CONFIG_EXTCON_GPIO=y
CONFIG_EXTCON_INTEL_INT3496=y
CONFIG_EXTCON_INTEL_CHT_WC=y
CONFIG_EXTCON_MAX14577=y
CONFIG_EXTCON_MAX3355=y
CONFIG_EXTCON_MAX77693=y
CONFIG_EXTCON_MAX77843=y
# CONFIG_EXTCON_MAX8997 is not set
CONFIG_EXTCON_RT8973A=y
# CONFIG_EXTCON_SM5502 is not set
# CONFIG_EXTCON_USB_GPIO is not set
# CONFIG_EXTCON_USBC_CROS_EC is not set
CONFIG_MEMORY=y
# CONFIG_IIO is not set
# CONFIG_NTB is not set
CONFIG_VME_BUS=y

#
# VME Bridge Drivers
#
CONFIG_VME_CA91CX42=y
CONFIG_VME_TSI148=y
CONFIG_VME_FAKE=y

#
# VME Board Drivers
#
CONFIG_VMIVME_7805=y

#
# VME Device Drivers
#
CONFIG_PWM=y
CONFIG_PWM_SYSFS=y
CONFIG_PWM_CROS_EC=y
# CONFIG_PWM_LP3943 is not set
CONFIG_PWM_LPSS=y
CONFIG_PWM_LPSS_PCI=y
# CONFIG_PWM_LPSS_PLATFORM is not set
CONFIG_PWM_PCA9685=y

#
# IRQ chip support
#
CONFIG_ARM_GIC_MAX_NR=1
CONFIG_IPACK_BUS=y
# CONFIG_BOARD_TPCI200 is not set
CONFIG_SERIAL_IPOCTAL=y
CONFIG_RESET_CONTROLLER=y
# CONFIG_RESET_TI_SYSCON is not set
CONFIG_FMC=y
# CONFIG_FMC_FAKEDEV is not set
CONFIG_FMC_TRIVIAL=y
CONFIG_FMC_WRITE_EEPROM=y
CONFIG_FMC_CHARDEV=y

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
CONFIG_BCM_KONA_USB2_PHY=y
CONFIG_PHY_PXA_28NM_HSIC=y
CONFIG_PHY_PXA_28NM_USB2=y
CONFIG_PHY_QCOM_USB_HS=y
CONFIG_PHY_QCOM_USB_HSIC=y
CONFIG_PHY_TUSB1210=y
# CONFIG_POWERCAP is not set
CONFIG_MCB=y
CONFIG_MCB_PCI=y
CONFIG_MCB_LPC=y

#
# Performance monitor support
#
# CONFIG_RAS is not set
CONFIG_THUNDERBOLT=y

#
# Android
#
# CONFIG_ANDROID is not set
CONFIG_LIBNVDIMM=y
CONFIG_BLK_DEV_PMEM=y
CONFIG_ND_BLK=y
CONFIG_ND_CLAIM=y
CONFIG_ND_BTT=y
CONFIG_BTT=y
CONFIG_DAX_DRIVER=y
CONFIG_DAX=y
CONFIG_DEV_DAX=y
CONFIG_NVMEM=y

#
# HW tracing support
#
# CONFIG_STM is not set
CONFIG_INTEL_TH=y
# CONFIG_INTEL_TH_PCI is not set
CONFIG_INTEL_TH_ACPI=y
# CONFIG_INTEL_TH_GTH is not set
CONFIG_INTEL_TH_MSU=y
CONFIG_INTEL_TH_PTI=y
# CONFIG_INTEL_TH_DEBUG is not set
CONFIG_FPGA=y
CONFIG_ALTERA_PR_IP_CORE=y
CONFIG_FPGA_MGR_ALTERA_CVP=y
CONFIG_FPGA_BRIDGE=y
CONFIG_XILINX_PR_DECOUPLER=y
# CONFIG_FPGA_REGION is not set
CONFIG_PM_OPP=y
# CONFIG_UNISYS_VISORBUS is not set
CONFIG_SIOX=y
CONFIG_SIOX_BUS_GPIO=y
CONFIG_SLIMBUS=y
CONFIG_SLIM_QCOM_CTRL=y

#
# Firmware Drivers
#
CONFIG_EDD=y
# CONFIG_EDD_OFF is not set
# CONFIG_FIRMWARE_MEMMAP is not set
CONFIG_DELL_RBU=y
CONFIG_DCDBAS=y
# CONFIG_ISCSI_IBFT_FIND is not set
CONFIG_FW_CFG_SYSFS=y
CONFIG_FW_CFG_SYSFS_CMDLINE=y
# CONFIG_GOOGLE_FIRMWARE is not set

#
# EFI (Extensible Firmware Interface) Support
#
CONFIG_EFI_VARS=y
CONFIG_EFI_ESRT=y
CONFIG_EFI_FAKE_MEMMAP=y
CONFIG_EFI_MAX_FAKE_MEM=8
CONFIG_EFI_RUNTIME_WRAPPERS=y
CONFIG_EFI_BOOTLOADER_CONTROL=y
CONFIG_EFI_CAPSULE_LOADER=y
CONFIG_EFI_TEST=y
CONFIG_APPLE_PROPERTIES=y
# CONFIG_RESET_ATTACK_MITIGATION is not set
CONFIG_EFI_DEV_PATH_PARSER=y

#
# Tegra firmware driver
#

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_FS_IOMAP=y
# CONFIG_EXT2_FS is not set
CONFIG_EXT3_FS=y
CONFIG_EXT3_FS_POSIX_ACL=y
CONFIG_EXT3_FS_SECURITY=y
CONFIG_EXT4_FS=y
CONFIG_EXT4_USE_FOR_EXT2=y
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
CONFIG_EXT4_ENCRYPTION=y
CONFIG_EXT4_FS_ENCRYPTION=y
CONFIG_EXT4_DEBUG=y
CONFIG_JBD2=y
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=y
CONFIG_REISERFS_FS=y
CONFIG_REISERFS_CHECK=y
CONFIG_REISERFS_PROC_INFO=y
# CONFIG_REISERFS_FS_XATTR is not set
CONFIG_JFS_FS=y
# CONFIG_JFS_POSIX_ACL is not set
# CONFIG_JFS_SECURITY is not set
# CONFIG_JFS_DEBUG is not set
# CONFIG_JFS_STATISTICS is not set
CONFIG_XFS_FS=y
CONFIG_XFS_QUOTA=y
# CONFIG_XFS_POSIX_ACL is not set
# CONFIG_XFS_RT is not set
CONFIG_XFS_ONLINE_SCRUB=y
# CONFIG_XFS_WARN is not set
# CONFIG_XFS_DEBUG is not set
# CONFIG_GFS2_FS is not set
# CONFIG_OCFS2_FS is not set
CONFIG_BTRFS_FS=y
CONFIG_BTRFS_FS_POSIX_ACL=y
CONFIG_BTRFS_FS_CHECK_INTEGRITY=y
# CONFIG_BTRFS_FS_RUN_SANITY_TESTS is not set
# CONFIG_BTRFS_DEBUG is not set
CONFIG_BTRFS_ASSERT=y
CONFIG_BTRFS_FS_REF_VERIFY=y
CONFIG_NILFS2_FS=y
# CONFIG_F2FS_FS is not set
CONFIG_FS_DAX=y
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_EXPORTFS_BLOCK_OPS=y
CONFIG_FILE_LOCKING=y
CONFIG_MANDATORY_FILE_LOCKING=y
CONFIG_FS_ENCRYPTION=y
CONFIG_FSNOTIFY=y
# CONFIG_DNOTIFY is not set
CONFIG_INOTIFY_USER=y
# CONFIG_FANOTIFY is not set
# CONFIG_QUOTA is not set
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
CONFIG_QUOTACTL=y
CONFIG_QUOTACTL_COMPAT=y
CONFIG_AUTOFS4_FS=y
CONFIG_FUSE_FS=y
CONFIG_CUSE=y
CONFIG_OVERLAY_FS=y
# CONFIG_OVERLAY_FS_REDIRECT_DIR is not set
# CONFIG_OVERLAY_FS_REDIRECT_ALWAYS_FOLLOW is not set
# CONFIG_OVERLAY_FS_INDEX is not set
# CONFIG_OVERLAY_FS_XINO_AUTO is not set

#
# Caches
#
CONFIG_FSCACHE=y
CONFIG_FSCACHE_STATS=y
# CONFIG_FSCACHE_HISTOGRAM is not set
# CONFIG_FSCACHE_DEBUG is not set
# CONFIG_FSCACHE_OBJECT_LIST is not set
# CONFIG_CACHEFILES is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=y
CONFIG_JOLIET=y
# CONFIG_ZISOFS is not set
# CONFIG_UDF_FS is not set

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=y
# CONFIG_VFAT_FS is not set
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_NTFS_FS=y
CONFIG_NTFS_DEBUG=y
# CONFIG_NTFS_RW is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
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
CONFIG_ARCH_HAS_GIGANTIC_PAGE=y
CONFIG_CONFIGFS_FS=y
# CONFIG_EFIVAR_FS is not set
# CONFIG_MISC_FILESYSTEMS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=y
CONFIG_NFS_V2=y
CONFIG_NFS_V3=y
# CONFIG_NFS_V3_ACL is not set
CONFIG_NFS_V4=y
# CONFIG_NFS_SWAP is not set
# CONFIG_NFS_V4_1 is not set
# CONFIG_ROOT_NFS is not set
# CONFIG_NFS_FSCACHE is not set
# CONFIG_NFS_USE_LEGACY_DNS is not set
CONFIG_NFS_USE_KERNEL_DNS=y
CONFIG_NFS_DEBUG=y
CONFIG_NFSD=y
CONFIG_NFSD_V2_ACL=y
CONFIG_NFSD_V3=y
CONFIG_NFSD_V3_ACL=y
CONFIG_NFSD_V4=y
CONFIG_NFSD_PNFS=y
CONFIG_NFSD_BLOCKLAYOUT=y
# CONFIG_NFSD_SCSILAYOUT is not set
# CONFIG_NFSD_FLEXFILELAYOUT is not set
# CONFIG_NFSD_V4_SECURITY_LABEL is not set
# CONFIG_NFSD_FAULT_INJECTION is not set
CONFIG_GRACE_PERIOD=y
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_NFS_ACL_SUPPORT=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
CONFIG_SUNRPC_GSS=y
CONFIG_RPCSEC_GSS_KRB5=y
CONFIG_SUNRPC_DEBUG=y
CONFIG_SUNRPC_XPRT_RDMA=y
CONFIG_CEPH_FS=y
# CONFIG_CEPH_FSCACHE is not set
# CONFIG_CEPH_FS_POSIX_ACL is not set
CONFIG_CIFS=y
# CONFIG_CIFS_STATS is not set
# CONFIG_CIFS_WEAK_PW_HASH is not set
# CONFIG_CIFS_UPCALL is not set
# CONFIG_CIFS_XATTR is not set
CONFIG_CIFS_DEBUG=y
# CONFIG_CIFS_DEBUG2 is not set
# CONFIG_CIFS_DEBUG_DUMP_KEYS is not set
# CONFIG_CIFS_DFS_UPCALL is not set
# CONFIG_CIFS_SMB311 is not set
# CONFIG_CIFS_SMB_DIRECT is not set
# CONFIG_CIFS_FSCACHE is not set
CONFIG_CODA_FS=y
CONFIG_AFS_FS=y
CONFIG_AFS_DEBUG=y
CONFIG_AFS_FSCACHE=y
# CONFIG_9P_FS is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
CONFIG_NLS_CODEPAGE_737=y
# CONFIG_NLS_CODEPAGE_775 is not set
CONFIG_NLS_CODEPAGE_850=y
# CONFIG_NLS_CODEPAGE_852 is not set
# CONFIG_NLS_CODEPAGE_855 is not set
# CONFIG_NLS_CODEPAGE_857 is not set
CONFIG_NLS_CODEPAGE_860=y
# CONFIG_NLS_CODEPAGE_861 is not set
CONFIG_NLS_CODEPAGE_862=y
CONFIG_NLS_CODEPAGE_863=y
# CONFIG_NLS_CODEPAGE_864 is not set
CONFIG_NLS_CODEPAGE_865=y
CONFIG_NLS_CODEPAGE_866=y
CONFIG_NLS_CODEPAGE_869=y
CONFIG_NLS_CODEPAGE_936=y
CONFIG_NLS_CODEPAGE_950=y
# CONFIG_NLS_CODEPAGE_932 is not set
CONFIG_NLS_CODEPAGE_949=y
# CONFIG_NLS_CODEPAGE_874 is not set
CONFIG_NLS_ISO8859_8=y
CONFIG_NLS_CODEPAGE_1250=y
# CONFIG_NLS_CODEPAGE_1251 is not set
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=y
# CONFIG_NLS_ISO8859_2 is not set
CONFIG_NLS_ISO8859_3=y
CONFIG_NLS_ISO8859_4=y
CONFIG_NLS_ISO8859_5=y
CONFIG_NLS_ISO8859_6=y
CONFIG_NLS_ISO8859_7=y
CONFIG_NLS_ISO8859_9=y
CONFIG_NLS_ISO8859_13=y
CONFIG_NLS_ISO8859_14=y
# CONFIG_NLS_ISO8859_15 is not set
# CONFIG_NLS_KOI8_R is not set
CONFIG_NLS_KOI8_U=y
CONFIG_NLS_MAC_ROMAN=y
CONFIG_NLS_MAC_CELTIC=y
CONFIG_NLS_MAC_CENTEURO=y
CONFIG_NLS_MAC_CROATIAN=y
CONFIG_NLS_MAC_CYRILLIC=y
CONFIG_NLS_MAC_GAELIC=y
CONFIG_NLS_MAC_GREEK=y
# CONFIG_NLS_MAC_ICELAND is not set
CONFIG_NLS_MAC_INUIT=y
CONFIG_NLS_MAC_ROMANIAN=y
# CONFIG_NLS_MAC_TURKISH is not set
CONFIG_NLS_UTF8=y
CONFIG_DLM=y
# CONFIG_DLM_DEBUG is not set

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_CONSOLE_LOGLEVEL_DEFAULT=7
CONFIG_MESSAGE_LOGLEVEL_DEFAULT=4
# CONFIG_BOOT_PRINTK_DELAY is not set
# CONFIG_DYNAMIC_DEBUG is not set

#
# Compile-time checks and compiler options
#
CONFIG_DEBUG_INFO=y
CONFIG_DEBUG_INFO_REDUCED=y
# CONFIG_DEBUG_INFO_SPLIT is not set
# CONFIG_DEBUG_INFO_DWARF4 is not set
# CONFIG_GDB_SCRIPTS is not set
# CONFIG_ENABLE_WARN_DEPRECATED is not set
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=2048
# CONFIG_STRIP_ASM_SYMS is not set
CONFIG_READABLE_ASM=y
# CONFIG_UNUSED_SYMBOLS is not set
CONFIG_PAGE_OWNER=y
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_SECTION_MISMATCH_WARN_ONLY=y
CONFIG_FRAME_POINTER=y
# CONFIG_STACK_VALIDATION is not set
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
# CONFIG_MAGIC_SYSRQ_SERIAL is not set
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_PAGE_EXTENSION=y
CONFIG_DEBUG_PAGEALLOC=y
# CONFIG_DEBUG_PAGEALLOC_ENABLE_DEFAULT is not set
CONFIG_PAGE_POISONING=y
CONFIG_PAGE_POISONING_NO_SANITY=y
CONFIG_PAGE_POISONING_ZERO=y
# CONFIG_DEBUG_PAGE_REF is not set
CONFIG_DEBUG_RODATA_TEST=y
# CONFIG_DEBUG_OBJECTS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
# CONFIG_DEBUG_STACK_USAGE is not set
CONFIG_DEBUG_VM=y
CONFIG_DEBUG_VM_VMACACHE=y
# CONFIG_DEBUG_VM_RB is not set
CONFIG_DEBUG_VM_PGFLAGS=y
CONFIG_ARCH_HAS_DEBUG_VIRTUAL=y
# CONFIG_DEBUG_VIRTUAL is not set
# CONFIG_DEBUG_MEMORY_INIT is not set
# CONFIG_MEMORY_NOTIFIER_ERROR_INJECT is not set
# CONFIG_DEBUG_PER_CPU_MAPS is not set
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_HAVE_ARCH_KASAN=y
CONFIG_ARCH_HAS_KCOV=y
CONFIG_KCOV=y
# CONFIG_KCOV_ENABLE_COMPARISONS is not set
# CONFIG_KCOV_INSTRUMENT_ALL is not set
CONFIG_DEBUG_SHIRQ=y

#
# Debug Lockups and Hangs
#
CONFIG_LOCKUP_DETECTOR=y
CONFIG_SOFTLOCKUP_DETECTOR=y
# CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=0
CONFIG_HARDLOCKUP_DETECTOR_PERF=y
CONFIG_HARDLOCKUP_CHECK_TIMESTAMP=y
CONFIG_HARDLOCKUP_DETECTOR=y
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC=y
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=1
# CONFIG_DETECT_HUNG_TASK is not set
# CONFIG_WQ_WATCHDOG is not set
CONFIG_PANIC_ON_OOPS=y
CONFIG_PANIC_ON_OOPS_VALUE=1
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
# CONFIG_SCHEDSTATS is not set
# CONFIG_SCHED_STACK_END_CHECK is not set
CONFIG_DEBUG_TIMEKEEPING=y

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
CONFIG_LOCK_DEBUGGING_SUPPORT=y
# CONFIG_PROVE_LOCKING is not set
# CONFIG_LOCK_STAT is not set
# CONFIG_DEBUG_RT_MUTEXES is not set
# CONFIG_DEBUG_SPINLOCK is not set
# CONFIG_DEBUG_MUTEXES is not set
# CONFIG_DEBUG_WW_MUTEX_SLOWPATH is not set
CONFIG_DEBUG_RWSEMS=y
# CONFIG_DEBUG_LOCK_ALLOC is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
CONFIG_DEBUG_LOCKING_API_SELFTESTS=y
CONFIG_LOCK_TORTURE_TEST=y
CONFIG_WW_MUTEX_SELFTEST=y
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
# CONFIG_WARN_ALL_UNSEEDED_RANDOM is not set
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
# CONFIG_DEBUG_LIST is not set
CONFIG_DEBUG_PI_LIST=y
# CONFIG_DEBUG_SG is not set
# CONFIG_DEBUG_NOTIFIERS is not set
# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
CONFIG_TORTURE_TEST=y
# CONFIG_RCU_PERF_TEST is not set
CONFIG_RCU_TORTURE_TEST=y
CONFIG_RCU_CPU_STALL_TIMEOUT=21
CONFIG_RCU_TRACE=y
CONFIG_RCU_EQS_DEBUG=y
# CONFIG_DEBUG_WQ_FORCE_RR_CPU is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_CPU_HOTPLUG_STATE_CONTROL is not set
CONFIG_NOTIFIER_ERROR_INJECTION=y
# CONFIG_PM_NOTIFIER_ERROR_INJECT is not set
# CONFIG_NETDEV_NOTIFIER_ERROR_INJECT is not set
# CONFIG_FAULT_INJECTION is not set
# CONFIG_LATENCYTOP is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_FENTRY=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACER_MAX_TRACE=y
CONFIG_TRACE_CLOCK=y
CONFIG_RING_BUFFER=y
CONFIG_EVENT_TRACING=y
CONFIG_CONTEXT_SWITCH_TRACER=y
CONFIG_RING_BUFFER_ALLOW_SWAP=y
CONFIG_TRACING=y
CONFIG_GENERIC_TRACER=y
CONFIG_TRACING_SUPPORT=y
CONFIG_FTRACE=y
CONFIG_FUNCTION_TRACER=y
# CONFIG_FUNCTION_GRAPH_TRACER is not set
# CONFIG_PREEMPTIRQ_EVENTS is not set
CONFIG_IRQSOFF_TRACER=y
CONFIG_SCHED_TRACER=y
# CONFIG_HWLAT_TRACER is not set
CONFIG_FTRACE_SYSCALLS=y
CONFIG_TRACER_SNAPSHOT=y
CONFIG_TRACER_SNAPSHOT_PER_CPU_SWAP=y
CONFIG_TRACE_BRANCH_PROFILING=y
# CONFIG_BRANCH_PROFILE_NONE is not set
# CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
CONFIG_PROFILE_ALL_BRANCHES=y
CONFIG_TRACING_BRANCHES=y
CONFIG_BRANCH_TRACER=y
CONFIG_STACK_TRACER=y
CONFIG_BLK_DEV_IO_TRACE=y
# CONFIG_UPROBE_EVENTS is not set
# CONFIG_DYNAMIC_FTRACE is not set
# CONFIG_FUNCTION_PROFILER is not set
# CONFIG_FTRACE_STARTUP_TEST is not set
CONFIG_MMIOTRACE=y
CONFIG_TRACING_MAP=y
CONFIG_HIST_TRIGGERS=y
CONFIG_TRACEPOINT_BENCHMARK=y
# CONFIG_RING_BUFFER_BENCHMARK is not set
# CONFIG_RING_BUFFER_STARTUP_TEST is not set
CONFIG_TRACE_EVAL_MAP_FILE=y
# CONFIG_TRACING_EVENTS_GPIO is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_RUNTIME_TESTING_MENU is not set
# CONFIG_MEMTEST is not set
# CONFIG_BUG_ON_DATA_CORRUPTION is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
CONFIG_UBSAN=y
# CONFIG_UBSAN_SANITIZE_ALL is not set
# CONFIG_UBSAN_ALIGNMENT is not set
CONFIG_UBSAN_NULL=y
CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
CONFIG_EARLY_PRINTK_USB=y
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
CONFIG_EARLY_PRINTK_DBGP=y
# CONFIG_EARLY_PRINTK_EFI is not set
CONFIG_EARLY_PRINTK_USB_XDBC=y
CONFIG_X86_PTDUMP_CORE=y
# CONFIG_X86_PTDUMP is not set
CONFIG_EFI_PGT_DUMP=y
CONFIG_DEBUG_WX=y
CONFIG_DOUBLEFAULT=y
# CONFIG_DEBUG_TLBFLUSH is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
CONFIG_IO_DELAY_0XED=y
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=1
CONFIG_DEBUG_BOOT_PARAMS=y
# CONFIG_CPA_DEBUG is not set
# CONFIG_OPTIMIZE_INLINING is not set
CONFIG_DEBUG_ENTRY=y
CONFIG_DEBUG_NMI_SELFTEST=y
# CONFIG_X86_DEBUG_FPU is not set
# CONFIG_PUNIT_ATOM_DEBUG is not set
# CONFIG_UNWINDER_ORC is not set
CONFIG_UNWINDER_FRAME_POINTER=y

#
# Security options
#
CONFIG_KEYS=y
CONFIG_KEYS_COMPAT=y
CONFIG_PERSISTENT_KEYRINGS=y
# CONFIG_BIG_KEYS is not set
# CONFIG_TRUSTED_KEYS is not set
# CONFIG_ENCRYPTED_KEYS is not set
CONFIG_KEY_DH_OPERATIONS=y
# CONFIG_SECURITY_DMESG_RESTRICT is not set
CONFIG_SECURITY=y
CONFIG_SECURITYFS=y
CONFIG_SECURITY_NETWORK=y
CONFIG_PAGE_TABLE_ISOLATION=y
CONFIG_SECURITY_INFINIBAND=y
# CONFIG_SECURITY_NETWORK_XFRM is not set
CONFIG_SECURITY_PATH=y
# CONFIG_FORTIFY_SOURCE is not set
# CONFIG_STATIC_USERMODEHELPER is not set
# CONFIG_SECURITY_SELINUX is not set
# CONFIG_SECURITY_SMACK is not set
# CONFIG_SECURITY_TOMOYO is not set
CONFIG_SECURITY_APPARMOR=y
CONFIG_SECURITY_APPARMOR_BOOTPARAM_VALUE=1
# CONFIG_SECURITY_APPARMOR_HASH is not set
CONFIG_SECURITY_APPARMOR_DEBUG=y
# CONFIG_SECURITY_APPARMOR_DEBUG_ASSERTS is not set
CONFIG_SECURITY_APPARMOR_DEBUG_MESSAGES=y
CONFIG_SECURITY_LOADPIN=y
# CONFIG_SECURITY_LOADPIN_ENABLED is not set
CONFIG_SECURITY_YAMA=y
# CONFIG_INTEGRITY is not set
# CONFIG_DEFAULT_SECURITY_APPARMOR is not set
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
CONFIG_CRYPTO_ACOMP2=y
CONFIG_CRYPTO_RSA=y
CONFIG_CRYPTO_DH=y
CONFIG_CRYPTO_ECDH=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
CONFIG_CRYPTO_USER=y
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_NULL2=y
CONFIG_CRYPTO_PCRYPT=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_MCRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_SIMD=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y
CONFIG_CRYPTO_ENGINE=y

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
# CONFIG_CRYPTO_CFB is not set
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
CONFIG_CRYPTO_CMAC=y
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=y
CONFIG_CRYPTO_VMAC=y

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=y
CONFIG_CRYPTO_CRC32=y
CONFIG_CRYPTO_CRC32_PCLMUL=y
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_CRCT10DIF_PCLMUL=y
CONFIG_CRYPTO_GHASH=y
# CONFIG_CRYPTO_POLY1305 is not set
# CONFIG_CRYPTO_POLY1305_X86_64 is not set
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
# CONFIG_CRYPTO_MICHAEL_MIC is not set
# CONFIG_CRYPTO_RMD128 is not set
CONFIG_CRYPTO_RMD160=y
# CONFIG_CRYPTO_RMD256 is not set
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_SSSE3=y
CONFIG_CRYPTO_SHA256_SSSE3=y
CONFIG_CRYPTO_SHA512_SSSE3=y
CONFIG_CRYPTO_SHA1_MB=y
CONFIG_CRYPTO_SHA256_MB=y
# CONFIG_CRYPTO_SHA512_MB is not set
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
# CONFIG_CRYPTO_SHA3 is not set
# CONFIG_CRYPTO_SM3 is not set
CONFIG_CRYPTO_TGR192=y
# CONFIG_CRYPTO_WP512 is not set
CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
# CONFIG_CRYPTO_AES_TI is not set
CONFIG_CRYPTO_AES_X86_64=y
CONFIG_CRYPTO_AES_NI_INTEL=y
CONFIG_CRYPTO_ANUBIS=y
CONFIG_CRYPTO_ARC4=y
# CONFIG_CRYPTO_BLOWFISH is not set
# CONFIG_CRYPTO_BLOWFISH_X86_64 is not set
# CONFIG_CRYPTO_CAMELLIA is not set
CONFIG_CRYPTO_CAMELLIA_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64=y
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
# CONFIG_CRYPTO_CAST5_AVX_X86_64 is not set
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_CAST6_AVX_X86_64=y
CONFIG_CRYPTO_DES=y
CONFIG_CRYPTO_DES3_EDE_X86_64=y
# CONFIG_CRYPTO_FCRYPT is not set
# CONFIG_CRYPTO_KHAZAD is not set
# CONFIG_CRYPTO_SALSA20 is not set
# CONFIG_CRYPTO_SALSA20_X86_64 is not set
CONFIG_CRYPTO_CHACHA20=y
CONFIG_CRYPTO_CHACHA20_X86_64=y
CONFIG_CRYPTO_SEED=y
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX2_X86_64=y
# CONFIG_CRYPTO_SM4 is not set
# CONFIG_CRYPTO_SPECK is not set
CONFIG_CRYPTO_TEA=y
# CONFIG_CRYPTO_TWOFISH is not set
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y
CONFIG_CRYPTO_TWOFISH_AVX_X86_64=y

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
# CONFIG_CRYPTO_LZO is not set
CONFIG_CRYPTO_842=y
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
CONFIG_CRYPTO_USER_API=y
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
CONFIG_CRYPTO_USER_API_RNG=y
# CONFIG_CRYPTO_USER_API_AEAD is not set
CONFIG_CRYPTO_HASH_INFO=y
CONFIG_CRYPTO_HW=y
# CONFIG_CRYPTO_DEV_PADLOCK is not set
# CONFIG_CRYPTO_DEV_CCP is not set
CONFIG_CRYPTO_DEV_QAT=y
CONFIG_CRYPTO_DEV_QAT_DH895xCC=y
# CONFIG_CRYPTO_DEV_QAT_C3XXX is not set
# CONFIG_CRYPTO_DEV_QAT_C62X is not set
# CONFIG_CRYPTO_DEV_QAT_DH895xCCVF is not set
# CONFIG_CRYPTO_DEV_QAT_C3XXXVF is not set
# CONFIG_CRYPTO_DEV_QAT_C62XVF is not set
CONFIG_CRYPTO_DEV_CHELSIO=y
CONFIG_CHELSIO_IPSEC_INLINE=y
CONFIG_CRYPTO_DEV_VIRTIO=y
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
# CONFIG_X509_CERTIFICATE_PARSER is not set

#
# Certificates for signature checking
#
CONFIG_SYSTEM_TRUSTED_KEYRING=y
CONFIG_SYSTEM_TRUSTED_KEYS=""
CONFIG_SYSTEM_EXTRA_CERTIFICATE=y
CONFIG_SYSTEM_EXTRA_CERTIFICATE_SIZE=4096
CONFIG_SECONDARY_TRUSTED_KEYRING=y
# CONFIG_SYSTEM_BLACKLIST_KEYRING is not set
CONFIG_HAVE_KVM=y
CONFIG_VIRTUALIZATION=y
# CONFIG_VHOST_CROSS_ENDIAN_LEGACY is not set
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_RAID6_PQ=y
CONFIG_BITREVERSE=y
CONFIG_RATIONAL=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_ARCH_USE_CMPXCHG_LOCKREF=y
CONFIG_ARCH_HAS_FAST_MULTIPLIER=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
CONFIG_CRC32_SELFTEST=y
# CONFIG_CRC32_SLICEBY8 is not set
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
CONFIG_CRC32_BIT=y
CONFIG_CRC4=y
CONFIG_CRC7=y
CONFIG_LIBCRC32C=y
CONFIG_CRC8=y
CONFIG_XXHASH=y
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
CONFIG_ZSTD_COMPRESS=y
CONFIG_ZSTD_DECOMPRESS=y
CONFIG_XZ_DEC=y
# CONFIG_XZ_DEC_X86 is not set
CONFIG_XZ_DEC_POWERPC=y
CONFIG_XZ_DEC_IA64=y
# CONFIG_XZ_DEC_ARM is not set
CONFIG_XZ_DEC_ARMTHUMB=y
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
CONFIG_XZ_DEC_TEST=y
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_BCH=y
CONFIG_BCH_CONST_PARAMS=y
CONFIG_TEXTSEARCH=y
CONFIG_TEXTSEARCH_KMP=y
CONFIG_TEXTSEARCH_BM=y
CONFIG_TEXTSEARCH_FSM=y
CONFIG_BTREE=y
CONFIG_INTERVAL_TREE=y
CONFIG_RADIX_TREE_MULTIORDER=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_SGL_ALLOC=y
CONFIG_DMA_DIRECT_OPS=y
CONFIG_DMA_VIRT_OPS=y
CONFIG_CHECK_SIGNATURE=y
CONFIG_CPUMASK_OFFSTACK=y
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_GLOB=y
CONFIG_GLOB_SELFTEST=y
CONFIG_NLATTR=y
CONFIG_CLZ_TAB=y
CONFIG_CORDIC=y
# CONFIG_DDR is not set
CONFIG_IRQ_POLL=y
CONFIG_MPILIB=y
CONFIG_OID_REGISTRY=y
CONFIG_UCS2_STRING=y
CONFIG_SG_POOL=y
CONFIG_ARCH_HAS_SG_CHAIN=y
CONFIG_ARCH_HAS_PMEM_API=y
CONFIG_ARCH_HAS_UACCESS_FLUSHCACHE=y
CONFIG_STACKDEPOT=y
CONFIG_SBITMAP=y
CONFIG_PRIME_NUMBERS=y
CONFIG_STRING_SELFTEST=y

--=_5aee5cdc.zEbxaqK9/iCmq7DlX0jmOWaUbrRh3+k4ZSE81n3dLGkkpD7B--
