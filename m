Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 75BC86B0038
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 14:01:22 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id n6so3022860pfg.19
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 11:01:22 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 11sor934911plb.118.2017.11.29.11.01.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Nov 2017 11:01:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171129052106.rhgbjhhis53hkgfn@wfg-t540p.sh.intel.com>
References: <20171129052106.rhgbjhhis53hkgfn@wfg-t540p.sh.intel.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 29 Nov 2017 20:00:59 +0100
Message-ID: <CACT4Y+bxW3HrYArjAbh+eriTnTzVsSaUf7d1ZY0_6HNnnsUYZw@mail.gmail.com>
Subject: Re: d17a1d97dc ("x86/mm/kasan: don't use vmemmap_populate() to
 initialize shadow"): BUG: KASAN: use-after-scope in __drm_mm_interval_first
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, wfg@linux.intel.com, Pavel Tatashin <pasha.tatashin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, LKP <lkp@01.org>, David Airlie <airlied@linux.ie>, Chris Wilson <chris@chris-wilson.co.uk>, Daniel Vetter <daniel.vetter@ffwll.ch>, joonas.lahtinen@linux.intel.com, christian.koenig@amd.com, dri-devel@lists.freedesktop.org

On Wed, Nov 29, 2017 at 6:21 AM, Fengguang Wu <fengguang.wu@intel.com> wrote:
> Greetings,
>
> 0day kernel testing robot got the below dmesg and the first bad commit is
>
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
>
> commit d17a1d97dc208d664c91cc387ffb752c7f85dc61
> Author:     Andrey Ryabinin <aryabinin@virtuozzo.com>
> AuthorDate: Wed Nov 15 17:36:35 2017 -0800
> Commit:     Linus Torvalds <torvalds@linux-foundation.org>
> CommitDate: Wed Nov 15 18:21:05 2017 -0800
>
>      x86/mm/kasan: don't use vmemmap_populate() to initialize shadow
>
>      The kasan shadow is currently mapped using vmemmap_populate() since that
>      provides a semi-convenient way to map pages into init_top_pgt.  However,
>      since that no longer zeroes the mapped pages, it is not suitable for
>      kasan, which requires zeroed shadow memory.
>
>      Add kasan_populate_shadow() interface and use it instead of
>      vmemmap_populate().  Besides, this allows us to take advantage of
>      gigantic pages and use them to populate the shadow, which should save us
>      some memory wasted on page tables and reduce TLB pressure.
>
>      Link: http://lkml.kernel.org/r/20171103185147.2688-2-pasha.tatashin@oracle.com
>      Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
>      Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
>      Cc: Steven Sistare <steven.sistare@oracle.com>
>      Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
>      Cc: Bob Picco <bob.picco@oracle.com>
>      Cc: Michal Hocko <mhocko@suse.com>
>      Cc: Alexander Potapenko <glider@google.com>
>      Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
>      Cc: Catalin Marinas <catalin.marinas@arm.com>
>      Cc: Christian Borntraeger <borntraeger@de.ibm.com>
>      Cc: David S. Miller <davem@davemloft.net>
>      Cc: Dmitry Vyukov <dvyukov@google.com>
>      Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
>      Cc: "H. Peter Anvin" <hpa@zytor.com>
>      Cc: Ingo Molnar <mingo@redhat.com>
>      Cc: Mark Rutland <mark.rutland@arm.com>
>      Cc: Matthew Wilcox <willy@infradead.org>
>      Cc: Mel Gorman <mgorman@techsingularity.net>
>      Cc: Michal Hocko <mhocko@kernel.org>
>      Cc: Sam Ravnborg <sam@ravnborg.org>
>      Cc: Thomas Gleixner <tglx@linutronix.de>
>      Cc: Will Deacon <will.deacon@arm.com>
>      Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>      Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
>
> a4a3ede213  mm: zero reserved and unavailable struct pages
> d17a1d97dc  x86/mm/kasan: don't use vmemmap_populate() to initialize shadow
> 43570f0383  Merge branch 'linus' of git://git.kernel.org/pub/scm/linux/kernel/git/herbert/crypto-2.6
> 5bef2980ad  Add linux-next specific files for 20171128
> +-------------------------------------------------------+------------+------------+------------+---------------+
> |                                                       | a4a3ede213 | d17a1d97dc | 43570f0383 | next-20171128 |
> +-------------------------------------------------------+------------+------------+------------+---------------+
> | boot_successes                                        | 30         | 0          | 0          | 0             |
> | boot_failures                                         | 8          | 15         | 19         | 2             |
> | WARNING:at_drivers/pci/pci-sysfs.c:#pci_mmap_resource | 8          |            |            |               |
> | RIP:pci_mmap_resource                                 | 8          |            |            |               |
> | BUG:KASAN:use-after-scope_in__drm_mm_interval_first   | 0          | 15         | 19         | 2             |
> +-------------------------------------------------------+------------+------------+------------+---------------+
>
> [   27.628251] AMD IOMMUv2 functionality not available on this system
> [   27.631925] drm_mm: Testing DRM range manger (struct drm_mm), with random_seed=0x248e657d max_iterations=8192 max_prime=128
> [   27.633191] drm_mm: igt_sanitycheck - ok!
> [   79.880445] Writes:  Total: 2  Max/Min: 0/0   Fail: 0
> [  103.749567] ==================================================================
> [  103.750064] BUG: KASAN: use-after-scope in __drm_mm_interval_first+0xbb/0x1bf
> [  103.750064] Read of size 8 at addr ffff880016577c08 by task swapper/0/1
> [  103.750064]
> [  103.750064] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.14.0-04319-gd17a1d9 #1
> [  103.750064] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
> [  103.750064] Call Trace:
> [  103.750064]  ? dump_stack+0xd1/0x16c
> [  103.750064]  ? _atomic_dec_and_lock+0x10f/0x10f
> [  103.750064]  ? print_address_description+0x93/0x22e
> [  103.750064]  ? __drm_mm_interval_first+0xbb/0x1bf
> [  103.750064]  ? kasan_report+0x219/0x23f
> [  103.750064]  ? __drm_mm_interval_first+0xbb/0x1bf
> [  103.750064]  ? assert_continuous+0x13c/0x22f
> [  103.750064]  ? drm_mm_replace_node+0x210/0x3ed
> [  103.750064]  ? __igt_insert+0x5af/0xb3a
> [  103.750064]  ? igt_bottomup+0x9e6/0x9e6
> [  103.750064]  ? kvm_clock_read+0x21/0x29
> [  103.750064]  ? kvm_sched_clock_read+0x5/0xd
> [  103.750064]  ? sched_clock+0x5/0x8
> [  103.750064]  ? sched_clock_local+0x36/0xe8
> [  103.750064]  ? sched_clock_cpu+0x123/0x13f
> [  103.750064]  ? rcu_irq_enter_disabled+0x8/0x8
> [  103.750064]  ? next_prime_number+0x33f/0x368
> [  103.750064]  ? rcu_note_context_switch+0x267/0x267
> [  103.750064]  ? igt_replace+0x45/0xa9
> [  103.750064]  ? test_drm_mm_init+0x112/0x164
> [  103.750064]  ? drm_kms_helper_init+0x5/0x5
> [  103.750064]  ? do_one_initcall+0xe7/0x1ef
> [  103.750064]  ? initcall_blacklisted+0x15d/0x15d
> [  103.750064]  ? up_read+0x2c/0x2c
> [  103.750064]  ? kasan_unpoison_shadow+0xf/0x2e
> [  103.750064]  ? kernel_init_freeable+0x2a8/0x33b
> [  103.750064]  ? rest_init+0x24f/0x24f
> [  103.750064]  ? kernel_init+0x7/0xfe
> [  103.750064]  ? rest_init+0x24f/0x24f
> [  103.750064]  ? ret_from_fork+0x24/0x30
> [  103.750064]
> [  103.750064] The buggy address belongs to the page:
> [  103.750064] page:ffff88001b1e3208 count:0 mapcount:0 mapping:          (null) index:0x0
> [  103.750064] flags: 0x401fff800000()
> [  103.750064] raw: 0000401fff800000 0000000000000000 0000000000000000 00000000ffffffff


Hi,

I hacked a quick prototype of improvemet for KASAN for printing frame info:

--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -289,6 +289,7 @@ static void print_shadow_for_address(const void *addr)
        int i;
        const void *shadow = kasan_mem_to_shadow(addr);
        const void *shadow_row;
+       unsigned long *ptr;

        shadow_row = (void *)round_down((unsigned long)shadow,
                                        SHADOW_BYTES_PER_ROW)
@@ -320,6 +321,18 @@ static void print_shadow_for_address(const void *addr)

                shadow_row += SHADOW_BYTES_PER_ROW;
        }
+
+
+       ptr = (unsigned long *)((unsigned long)addr & ~7);
+       for (i = 0; i < 1000; i++, ptr--) {
+               if (*ptr == 0x41b58ab3) {
+                       pr_err("\n");
+                       pr_err("frame offset: %lu\n", (unsigned
long)addr - (unsigned long)ptr);
+                       pr_err("desc: '%s'\n", (const char*)*(ptr+1));
+                       pr_err("func: %pS\n", (void*)*(ptr+2));
+                       break;
+               }
+       }
 }



And this gave me:


[   26.763495] ==================================================================
[   26.764454] BUG: KASAN: use-after-scope in __drm_mm_interval_first+0xc0/0x1e2
[   26.765297] Read of size 8 at addr ffff88006cb3fbe0 by task swapper/0/1
[   26.766081]
[   26.766278] CPU: 1 PID: 1 Comm: swapper/0 Not tainted
4.14.0-04319-gd17a1d97dc20-dirty #12
[   26.767760] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS Bochs 01/01/2011
[   26.769419] Call Trace:
[   26.769895]  dump_stack+0xdb/0x17a
[   26.770152]  ? _atomic_dec_and_lock+0x12f/0x12f
[   26.770152]  ? show_regs_print_info+0x5b/0x5b
[   26.770152]  ? kasan_report+0x4d/0x247
[   26.770152]  ? __drm_mm_interval_first+0xc0/0x1e2
[   26.770152]  print_address_description+0x9a/0x232
[   26.770152]  ? __drm_mm_interval_first+0xc0/0x1e2
[   26.770152]  kasan_report+0x21e/0x247
[   26.770152]  __asan_report_load8_noabort+0x14/0x16
[   26.770152]  __drm_mm_interval_first+0xc0/0x1e2
[   26.770152]  assert_continuous+0x13e/0x22f
[   26.770152]  __igt_insert+0x665/0xc87
[   26.770152]  ? igt_bottomup+0xaa0/0xaa0
[   26.770152]  ? sched_clock_local+0x3c/0xfb
[   26.770152]  ? find_held_lock+0x33/0x103
[   26.770152]  ? next_prime_number+0x318/0x362
[   26.770152]  ? rcu_irq_enter_disabled+0xd/0xd
[   26.770152]  ? next_prime_number+0x337/0x362
[   26.770152]  igt_replace+0x4b/0xb3
[   26.770152]  test_drm_mm_init+0x118/0x172
[   26.770152]  ? drm_kms_helper_init+0xb/0xb
[   26.770152]  do_one_initcall+0x10f/0x21f
[   26.770152]  ? initcall_blacklisted+0x185/0x185
[   26.770152]  ? down_write_nested+0xa1/0x164
[   26.770152]  ? kasan_poison_shadow+0x2f/0x31
[   26.770152]  ? kasan_unpoison_shadow+0x14/0x35
[   26.770152]  kernel_init_freeable+0x2ae/0x339
[   26.770152]  ? rest_init+0x250/0x250
[   26.770152]  kernel_init+0xc/0x105
[   26.770152]  ? rest_init+0x250/0x250
[   26.770152]  ret_from_fork+0x24/0x30
[   26.770152]
[   26.770152] The buggy address belongs to the page:
[   26.770152] page:ffff88007f39c5c8 count:0 mapcount:0 mapping:
   (null) index:0x0
[   26.770152] flags: 0x1a01fff800000()
[   26.770152] raw: 0001a01fff800000 0000000000000000 0000000000000000
00000000ffffffff
[   26.770152] raw: ffff88007f39c5e8 ffff88007f39c5e8 0000000000000000
[   26.770152] page dumped because: kasan: bad access detected
[   26.790299]
[   26.790299] Memory state around the buggy address:
[   26.790299]  ffff88006cb3fa80: 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 f1
[   26.790299]  ffff88006cb3fb00: f1 f1 f1 00 f2 f2 f2 f2 f2 f2 f2 00
00 f2 f2 f2
[   26.790299] >ffff88006cb3fb80: f2 f2 f2 f8 f8 f2 f2 f2 f2 f2 f2 f8
f8 f8 f8 f8
[   26.790299]                                                        ^
[   26.790299]  ffff88006cb3fc00: f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8 f8
f8 f8 f8 f2
[   26.790299]  ffff88006cb3fc80: f2 f2 f2 00 00 00 00 00 00 00 00 00
00 00 00 00
[   26.790299]
[   26.790299] frame offset: 232
[   26.790299] desc: '5 32 8 3 __u 96 16 4 prng 160 16 7 state__ 224
160 3 tmp 416 224 2 mm '
[   26.790299] func: __igt_insert+0x0/0xc87
[   26.790299] ==================================================================


That desc string is: number of local objects, then for each object:
offset, size, name length, name.

So that's variable tmp in __igt_insert.

Looks very much like a real use-after-scope.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
