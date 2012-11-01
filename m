Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 701776B006C
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 09:40:26 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so4480846ied.14
        for <linux-mm@kvack.org>; Thu, 01 Nov 2012 06:40:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0000013a934eed6d-a9c1b247-dbbc-485d-b7cf-89aa36dcca57-000000@email.amazonses.com>
References: <0000013a934eed6d-a9c1b247-dbbc-485d-b7cf-89aa36dcca57-000000@email.amazonses.com>
Date: Thu, 1 Nov 2012 10:40:25 -0300
Message-ID: <CALF0-+UUREQZT1NEBq-V_04WBDOt6GccDkHB+zPXW6u6uhvj=Q@mail.gmail.com>
Subject: Re: CK4 [00/15] Sl[auo]b: Common kmalloc caches V4
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Hi Christoph,

On Wed, Oct 24, 2012 at 12:05 PM, Christoph Lameter <cl@linux.com> wrote:
> V3->V4:
>  - Further fixes of issues pointed out by Joonsoo and Glauber.
>
> V2-V3:
> - Further cleanup and reordering as suggested by Glauber
>
> V1-V2:
> - Clean up numerous things as suggested by Glauber.
> - Add two more patches that extract more kmalloc stuff
>   into common files.
>
> This patchset cleans up the bootstrap of the allocators
> and creates a common functions to handle the kmalloc
> array. The results are more common data structures and
> functions that will simplify further work
> on having common functions for all allocators.
>
> This patchset is against Pekka's slab/next tree as of today.
>

While testing this patchset, I found a BUG.

All I did was "sudo mount -a" to mount my development partitions.

[   25.366266] BUG: unable to handle kernel paging request at ffffffc0
[   25.366419] IP: [<c10d93b2>] slab_unmergeable+0x12/0x30
[   25.366497] *pde = 016f5067 *pte = 00000000
[   25.366601] Oops: 0000 [#1] SMP
[   25.366703] Modules linked in: radeon snd_usb_audio snd_usbmidi_lib
snd_rawmidi snd_hda_intel snd_hda_codec snd_hwdep snd_pcm ttm
snd_timer snd pcspkr drm_kms_helper soundcore snd_page_alloc
cfbcopyarea cfbimgblt cfbfillrect evdev
[   25.367373] Pid: 1428, comm: mount Not tainted
3.7.0-rc1-athlon-full-preempt-gentoo-69954-g12ae62c #14 Gigabyte
Technology Co., Ltd. GA-MA74GMT-S2/GA-MA74GMT-S2
[   25.367451] EIP: 0060:[<c10d93b2>] EFLAGS: 00010246 CPU: 2
[   25.367498] EIP is at slab_unmergeable+0x12/0x30
[   25.367543] EAX: ffffffbc EBX: 00030d00 ECX: 00000000 EDX: 00000001
[   25.367588] ESI: 00000098 EDI: ffffffbc EBP: f47ddd00 ESP: f47ddd00
[   25.367635]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
[   25.367680] CR0: 8005003b CR2: ffffffc0 CR3: 34742000 CR4: 000007d0
[   25.367726] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[   25.367772] DR6: ffff0ff0 DR7: 00000400
[   25.367817] Process mount (pid: 1428, ti=f47dc000 task=f3998000
task.ti=f47dc000)
[   25.367877] Stack:
[   25.367922]  f47ddd24 c10dcad7 00000094 fffffff8 00000097 c15b924f
00000002 c15b924f
[   25.368214]  00000094 f47ddd4c c10c1ed0 00030d00 00000000 22222222
22222222 00000000
[   25.368506]  00000002 f4419770 0000000c f47ddd90 c117e64f 00020000
00000000 f34079a8
[   25.368798] Call Trace:
[   25.368843]  [<c10dcad7>] __kmem_cache_alias+0x97/0x130
[   25.368891]  [<c10c1ed0>] kmem_cache_create+0x40/0x1c0
[   25.368938]  [<c117e64f>] ext4_mb_init+0x2ef/0x520
[   25.368986]  [<c148434d>] ? _raw_spin_unlock+0x1d/0x20
[   25.369033]  [<c116cf2e>] ext4_fill_super+0x2c2e/0x3310
[   25.369081]  [<c1075df5>] ? mark_held_locks+0x85/0xe0
[   25.369128]  [<c1482329>] ? mutex_lock_nested+0x229/0x2d0
[   25.369175]  [<c110e06e>] ? sb_set_blocksize+0x1e/0x70
[   25.369222]  [<c10e3205>] mount_bdev+0x165/0x190
[   25.369269]  [<c10c2450>] ? slab_account_alloc+0xd0/0x1a0
[   25.369315]  [<c10dd171>] ? __kmalloc_track_caller+0xc1/0x160
[   25.369362]  [<c11650da>] ext4_mount+0x1a/0x20
[   25.369408]  [<c116a300>] ? ext4_calculate_overhead+0x460/0x460
[   25.369455]  [<c10e3c7c>] mount_fs+0x1c/0xc0
[   25.369501]  [<c10c1aba>] ? __alloc_percpu+0xa/0x10
[   25.369549]  [<c10fa13f>] ? alloc_vfsmnt+0x9f/0x140
[   25.369596]  [<c10fa259>] vfs_kern_mount+0x49/0xe0
[   25.369642]  [<c10faa47>] do_kern_mount+0x37/0xf0
[   25.369688]  [<c10fc1f4>] do_mount+0x3b4/0x700
[   25.369735]  [<c10bd7c9>] ? strndup_user+0x49/0x70
[   25.369782]  [<c10fc5a6>] sys_mount+0x66/0xa0
[   25.369828]  [<c1484d7a>] sysenter_do_call+0x12/0x32
[   25.369873] Code: 34 c7 43 2c 00 00 00 00 c7 43 30 00 00 00 00 89
43 34 89 43 38 5b 5d c3 90 8b 0d 90 70 c3 c1 ba 01 00 00 00 55 89 e5
85 c9 75 10 <f7> 40 04 00 0c a9 00 75 07 8b 48 30 85 c9 74 06 89 d0 5d
c3 66
[   25.371837] EIP: [<c10d93b2>] slab_unmergeable+0x12/0x30 SS:ESP 0068:f47ddd00
[   25.371942] CR2: 00000000ffffffc0
[   25.371987] ---[ end trace 278dfa9b282c605e ]---

Hope it helps,

    Ezequiel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
