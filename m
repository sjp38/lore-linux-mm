Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id DA84A831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 02:02:58 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id n14so31314181uaj.3
        for <linux-mm@kvack.org>; Sun, 21 May 2017 23:02:58 -0700 (PDT)
Received: from mail-vk0-x233.google.com (mail-vk0-x233.google.com. [2607:f8b0:400c:c05::233])
        by mx.google.com with ESMTPS id u17si7203708uae.74.2017.05.21.23.02.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 May 2017 23:02:57 -0700 (PDT)
Received: by mail-vk0-x233.google.com with SMTP id y190so35428791vkc.1
        for <linux-mm@kvack.org>; Sun, 21 May 2017 23:02:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170519015348.GA1763@js1304-desktop>
References: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
 <ebcc02d9-fa2b-30b1-2260-99cdf7434487@virtuozzo.com> <20170519015348.GA1763@js1304-desktop>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 22 May 2017 08:02:36 +0200
Message-ID: <CACT4Y+bZVJpi++kfMkAc-3pXK165ZQyHaEU_6oN94+qQErJd8A@mail.gmail.com>
Subject: Re: [PATCH v1 00/11] mm/kasan: support per-page shadow memory to
 reduce memory consumption
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kernel-team@lge.com

On Fri, May 19, 2017 at 3:53 AM, Joonsoo Kim <js1304@gmail.com> wrote:
> On Wed, May 17, 2017 at 03:17:13PM +0300, Andrey Ryabinin wrote:
>> On 05/16/2017 04:16 AM, js1304@gmail.com wrote:
>> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> >
>> > Hello, all.
>> >
>> > This is an attempt to recude memory consumption of KASAN. Please see
>> > following description to get the more information.
>> >
>> > 1. What is per-page shadow memory
>> >
>> > This patch introduces infrastructure to support per-page shadow memory.
>> > Per-page shadow memory is the same with original shadow memory except
>> > the granualarity. It's one byte shows the shadow value for the page.
>> > The purpose of introducing this new shadow memory is to save memory
>> > consumption.
>> >
>> > 2. Problem of current approach
>> >
>> > Until now, KASAN needs shadow memory for all the range of the memory
>> > so the amount of statically allocated memory is so large. It causes
>> > the problem that KASAN cannot run on the system with hard memory
>> > constraint. Even if KASAN can run, large memory consumption due to
>> > KASAN changes behaviour of the workload so we cannot validate
>> > the moment that we want to check.
>> >
>> > 3. How does this patch fix the problem
>> >
>> > This patch tries to fix the problem by reducing memory consumption for
>> > the shadow memory. There are two observations.
>> >
>>
>>
>> I think that the best way to deal with your problem is to increase shadow scale size.
>>
>> You'll need to add tunable to gcc to control shadow size. I expect that gcc has some
>> places where 8-shadow scale size is hardcoded, but it should be fixable.
>>
>> The kernel also have some small amount of code written with KASAN_SHADOW_SCALE_SIZE == 8 in mind,
>> which should be easy to fix.
>>
>> Note that bigger shadow scale size requires bigger alignment of allocated memory and variables.
>> However, according to comments in gcc/asan.c gcc already aligns stack and global variables and at
>> 32-bytes boundary.
>> So we could bump shadow scale up to 32 without increasing current stack consumption.
>>
>> On a small machine (1Gb) 1/32 of shadow is just 32Mb which is comparable to yours 30Mb, but I expect it to be
>> much faster. More importantly, this will require only small amount of simple changes in code, which will be
>> a *lot* more easier to maintain.


Interesting option. We never considered increasing scale in user space
due to performance implications. But the algorithm always supported up
to 128x scale. Definitely worth considering as an option.


> I agree that it is also a good option to reduce memory consumption.
> Nevertheless, there are two reasons that justifies this patchset.
>
> 1) With this patchset, memory consumption isn't increased in
> proportional to total memory size. Please consider my 4Gb system
> example on the below. With increasing shadow scale size to 32, memory
> would be consumed by 128M. However, this patchset consumed 50MB. This
> difference can be larger if we run KASAN with bigger machine.
>
> 2) These two optimization can be applied simulatenously. It is just an
> orthogonal feature. If shadow scale size is increased to 32, memory
> consumption will be decreased in case of my patchset, too.
>
> Therefore, I think that this patchset is useful in any case.

It is definitely useful all else being equal. But it does considerably
increase code size and complexity, which is an important aspect.

Also note that there is also fixed size quarantine (1/32 of RAM) and
redzones. Reducing shadow overhead beyond some threshold has
diminishing returns, because overall overhead will be just dominated
by quarantine/redzones.

What's your target devices and constraints? We run KASAN on phones
today without any issues.


> Note that increasing shadow scale has it's own trade-off. It requires
> that the size of slab object is aligned to shadow scale. It will
> increase memory consumption due to slab.

I've tried to retest your latest change on top of
http://git.cmpxchg.org/cgit.cgi/linux-mmots.git
d9cd9c95cc3b2fed0f04d233ebf2f7056741858c, but now this version
https://codereview.appspot.com/325780043 always crashes during boot
for me. Report points to zero shadow.

[    0.123434] ==================================================================
[    0.125153] BUG: KASAN: double-free or invalid-free in
cleanup_uevent_env+0x2c/0x40
[    0.126900]
[    0.127318] CPU: 1 PID: 226 Comm: kworker/u8:0 Not tainted
4.12.0-rc1-mm1+ #376
[    0.128995] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS Bochs 01/01/2011
[    0.130896] Call Trace:
[    0.131202] kworker/u8:0 (277) used greatest stack depth: 22976 bytes left
[    0.133129]  dump_stack+0xb0/0x13d
[    0.133958]  ? _atomic_dec_and_lock+0x1e3/0x1e3
[    0.135020]  ? load_image_and_restore+0xf6/0xf6
[    0.136083]  ? kmemdup+0x31/0x40
[    0.136143] kworker/u8:0 (320) used greatest stack depth: 22112 bytes left
[    0.138294]  ? cleanup_uevent_env+0x2c/0x40
[    0.139255]  print_address_description+0x6a/0x270
[    0.140285]  ? cleanup_uevent_env+0x2c/0x40
[    0.141224]  ? cleanup_uevent_env+0x2c/0x40
[    0.142168]  kasan_report_double_free+0x55/0x80
[    0.143162]  kasan_slab_free+0xa4/0xc0
[    0.143934]  ? cleanup_uevent_env+0x2c/0x40
[    0.144882]  kfree+0x8f/0x190
[    0.145561]  cleanup_uevent_env+0x2c/0x40
[    0.146455]  umh_complete+0x3c/0x60
[    0.147180]  call_usermodehelper_exec_async+0x671/0x950
[    0.148334]  ? __asan_report_store_n_noabort+0x12/0x20
[    0.149460]  ? native_load_sp0+0xa3/0xb0
[    0.150213]  ? umh_complete+0x60/0x60
[    0.150990]  ? kasan_end_report+0x20/0x50
[    0.151829]  ? finish_task_switch+0x510/0x7d0
[    0.152760]  ? copy_user_overflow+0x20/0x20
[    0.153565]  ? umh_complete+0x60/0x60
[    0.154341]  ? umh_complete+0x60/0x60
[    0.155125]  ret_from_fork+0x2c/0x40
[    0.155888]
[    0.156190] Allocated by task 1:
[    0.156890]  save_stack_trace+0x16/0x20
[    0.157629]  save_stack+0x43/0xd0
[    0.158299]  kasan_kmalloc+0xad/0xe0
[    0.159068]  kmem_cache_alloc_trace+0x61/0x170
[    0.159920]  kobject_uevent_env+0x1b2/0xa20
[    0.160819]  kobject_uevent+0xb/0x10
[    0.161551]  param_sysfs_init+0x28e/0x2d2
[    0.162375]  do_one_initcall+0x8c/0x290
[    0.163083]  kernel_init_freeable+0x4a2/0x554
[    0.163958]  kernel_init+0xe/0x120
[    0.164669]  ret_from_fork+0x2c/0x40
[    0.165393]
[    0.165685] Freed by task 0:
[    0.166232] (stack is not available)
[    0.166954]
[    0.167247] The buggy address belongs to the object at ffff88007b45e818
[    0.167247]  which belongs to the cache kmalloc-4096 of size 4096
[    0.169709] The buggy address is located 0 bytes inside of
[    0.169709]  4096-byte region [ffff88007b45e818, ffff88007b45f818)
[    0.171897] The buggy address belongs to the page:
[    0.172833] page:ffffea0001ed1600 count:1 mapcount:0 mapping:
   (null) index:0x0 compound_mapcount: 0
[    0.174560] flags: 0x100000000008100(slab|head)
[    0.175410] raw: 0100000000008100 0000000000000000 0000000000000000
0000000100070007
[    0.176819] raw: ffffea0001ed0c20 ffffea0001ed3c20 ffff88007c80ed40
0000000000000000
[    0.178250] page dumped because: kasan: bad access detected
[    0.179312]
[    0.179586] Memory state around the buggy address:
[    0.180488]  ffff88007b45e700: fc fc fc fc fc fc fc fc fc fc fc fc
fc fc fc fc
[    0.181801]  ffff88007b45e780: fc fc fc fc fc fc fc fc fc fc fc fc
fc fc fc fc
[    0.183112] >ffff88007b45e800: fc fc fc 00 00 00 00 00 00 00 00 00
00 00 00 00
[    0.184518]                             ^
[    0.185177]  ffff88007b45e880: 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00
[    0.186420]  ffff88007b45e900: 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00
[    0.187723] ==================================================================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
