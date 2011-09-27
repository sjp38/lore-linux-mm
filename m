Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 26A499000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 01:27:31 -0400 (EDT)
Received: by fxh17 with SMTP id 17so8770600fxh.14
        for <linux-mm@kvack.org>; Mon, 26 Sep 2011 22:27:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110926165024.GA21617@e102109-lin.cambridge.arm.com>
References: <CA+v9cxadZzWr35Q9RFzVgk_NZsbZ8PkVLJNxjBAMpargW9Lm4Q@mail.gmail.com>
	<1317054774.6363.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20110926165024.GA21617@e102109-lin.cambridge.arm.com>
Date: Tue, 27 Sep 2011 13:27:28 +0800
Message-ID: <CA+v9cxYtuY+TX_heoMEZXOvvQ6Q7xCsKWGZo67r7AbmHeeTd8w@mail.gmail.com>
Subject: Re: Question about memory leak detector giving false positive report
 for net/core/flow.c
From: Huajun Li <huajun.li.lee@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <Catalin.Marinas@arm.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, netdev <netdev@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Huajun Li <huajun.li.lee@gmail.com>

2011/9/27 Catalin Marinas <Catalin.Marinas@arm.com>:
> On Mon, Sep 26, 2011 at 05:32:54PM +0100, Eric Dumazet wrote:
>> Le lundi 26 septembre 2011 =E0 23:17 +0800, Huajun Li a =E9crit :
>> > Memory leak detector gives following memory leak report, it seems the
>> > report is triggered by net/core/flow.c, but actually, it should be a
>> > false positive report.
>> > So, is there any idea from kmemleak side to fix/disable this false
>> > positive report like this?
>> > Yes, kmemleak_not_leak(...) could disable it, but is it suitable for t=
his case ?
> ...
>> CC lkml and percpu maintainers (Tejun Heo & Christoph Lameter ) as well
>>
>> AFAIK this false positive only occurs if percpu data is allocated
>> outside of embedded pcu space.
>>
>> =A0(grep pcpu_get_vm_areas /proc/vmallocinfo)
>>
>> I suspect this is a percpu/kmemleak cooperation problem (a missing
>> kmemleak_alloc() ?)
>>
>> I am pretty sure kmemleak_not_leak() is not the right answer to this
>> problem.
>
> kmemleak_not_leak() definitely not the write answer. The alloc_percpu()
> call does not have any kmemleak_alloc() callback, so it doesn't scan
> them.
>
> Huajun, could you please try the patch below:
>
> 8<--------------------------------
> kmemleak: Handle percpu memory allocation
>
> From: Catalin Marinas <catalin.marinas@arm.com>
>
> This patch adds kmemleak callbacks from the percpu allocator, reducing a
> number of false positives caused by kmemleak not scanning such memory
> blocks.
>
> Reported-by: Huajun Li <huajun.li.lee@gmail.com>
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> ---
> =A0mm/percpu.c | =A0 11 +++++++++--
> =A01 files changed, 9 insertions(+), 2 deletions(-)
>
> diff --git a/mm/percpu.c b/mm/percpu.c
> index bf80e55..c47a90b 100644
> --- a/mm/percpu.c
> +++ b/mm/percpu.c
> @@ -67,6 +67,7 @@
> =A0#include <linux/spinlock.h>
> =A0#include <linux/vmalloc.h>
> =A0#include <linux/workqueue.h>
> +#include <linux/kmemleak.h>
>
> =A0#include <asm/cacheflush.h>
> =A0#include <asm/sections.h>
> @@ -833,7 +834,9 @@ fail_unlock_mutex:
> =A0*/
> =A0void __percpu *__alloc_percpu(size_t size, size_t align)
> =A0{
> - =A0 =A0 =A0 return pcpu_alloc(size, align, false);
> + =A0 =A0 =A0 void __percpu *ptr =3D pcpu_alloc(size, align, false);
> + =A0 =A0 =A0 kmemleak_alloc(ptr, size, 1, GFP_KERNEL);
> + =A0 =A0 =A0 return ptr;
> =A0}
> =A0EXPORT_SYMBOL_GPL(__alloc_percpu);
>
> @@ -855,7 +858,9 @@ EXPORT_SYMBOL_GPL(__alloc_percpu);
> =A0*/
> =A0void __percpu *__alloc_reserved_percpu(size_t size, size_t align)
> =A0{
> - =A0 =A0 =A0 return pcpu_alloc(size, align, true);
> + =A0 =A0 =A0 void __percpu *ptr =3D pcpu_alloc(size, align, true);
> + =A0 =A0 =A0 kmemleak_alloc(ptr, size, 1, GFP_KERNEL);
> + =A0 =A0 =A0 return ptr;
> =A0}
>
> =A0/**
> @@ -915,6 +920,8 @@ void free_percpu(void __percpu *ptr)
> =A0 =A0 =A0 =A0if (!ptr)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>
> + =A0 =A0 =A0 kmemleak_free(ptr);
> +
> =A0 =A0 =A0 =A0addr =3D __pcpu_ptr_to_addr(ptr);
>
> =A0 =A0 =A0 =A0spin_lock_irqsave(&pcpu_lock, flags);
>
> --
> Catalin
>

Applied the patch and found following msg after system boot up :
---------------------------------------------------------------------------=
-----------------------------
...
[   48.040027] eth0: no IPv6 routers present
[   69.240960] BUG: unable to handle kernel paging request at 00000000001d7=
270
[   69.241010] IP: [<ffffffff81256c62>] scan_block+0x62/0x220
[   69.241045] PGD 5f289067 PUD 5f292067 PMD 0
[   69.241074] Oops: 0000 [#1] SMP
[   69.241098] CPU 0
[   69.241110] Modules linked in: binfmt_misc dm_crypt
snd_hda_codec_analog snd_hda_intel snd_hda_codec usbhid hid snd_hwdep
snd_pcm snd_seq_midi snd_rawmidi i915 snd_seq_midi_event hp_wmi ppdev
sparse_keymap snd_seq snd_timer snd_seq_device ehci_hcd uhci_hcd
drm_kms_helper usbcore tpm_infineon psmouse snd e1000e drm serio_raw
soundcore tpm_tis snd_page_alloc tpm floppy tpm_bios parport_pc
i2c_algo_bit video lp parport
[   69.249303]
[   69.250246] Pid: 47, comm: kmemleak Tainted: G          I
3.1.0-rc7+ #24 Hewlett-Packard HP Compaq dc7800p Convertible
Minitower/0AACh
[   69.250246] RIP: 0010:[<ffffffff81256c62>]  [<ffffffff81256c62>]
scan_block+0x62/0x220
[   69.250246] RSP: 0018:ffff880073f69d90  EFLAGS: 00010012
[   69.250246] RAX: 0000000000000000 RBX: ffff880078750858 RCX: 00000000000=
00000
[   69.250246] RDX: ffff880078750858 RSI: 0000000000000001 RDI: 00000000001=
d7270
[   69.250246] RBP: ffff880073f69dd0 R08: 0000000000000000 R09: 00000000000=
00000
[   69.250246] R10: 0000000000000001 R11: 0000000000000000 R12: ffff8800787=
508b8
[   69.250246] R13: 00000000001d7270 R14: 00000000001d7431 R15: 00000000000=
00000
[   69.250246] FS:  0000000000000000(0000) GS:ffff88007a200000(0000)
knlGS:0000000000000000
[   69.250246] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   69.250246] CR2: 00000000001d7270 CR3: 000000006d735000 CR4: 00000000000=
006f0
[   69.250246] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000000=
00000
[   69.250246] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 00000000000=
00400
[   69.250246] Process kmemleak (pid: 47, threadinfo ffff880073f68000,
task ffff880073e4a460)
[   69.250246] Stack:
[   69.250246]  ffff880073f69dd0 ffffffff8194b49a ffffffff81256ed1
ffff880078750858
[   69.250246]  ffff8800787508b8 00000000001d8270 00000000001d7438
0000000000000206
[   69.250246]  ffff880073f69e10 ffffffff8125702a 000000000007d2af
ffffffff81e0d120
[   69.250246] Call Trace:
[   69.250246]  [<ffffffff8194b49a>] ? _raw_spin_lock_irqsave+0xfa/0x110
[   69.250246]  [<ffffffff81256ed1>] ? scan_gray_list+0xb1/0x280
[   69.250246]  [<ffffffff8125702a>] scan_gray_list+0x20a/0x280
[   69.250246]  [<ffffffff8125787a>] kmemleak_scan+0x44a/0xbd0
[   69.250246]  [<ffffffff81257430>] ? kmemleak_do_cleanup+0x210/0x210
[   69.250246]  [<ffffffff81258630>] ? kmemleak_write+0x630/0x630
[   69.250246]  [<ffffffff812586bf>] kmemleak_scan_thread+0x8f/0x150
[   69.250246]  [<ffffffff810dc4e6>] kthread+0xe6/0x100
[   69.250246]  [<ffffffff8195a4c4>] kernel_thread_helper+0x4/0x10
[   69.250246]  [<ffffffff8194ac50>] ? _raw_spin_unlock_irq+0x50/0x80
[   69.250246]  [<ffffffff8194b874>] ? retint_restore_args+0x13/0x13
[   69.250246]  [<ffffffff810dc400>] ? __init_kthread_worker+0x80/0x80
[   69.250246]  [<ffffffff8195a4c0>] ? gs_change+0x13/0x13
[   69.250246] Code: 00 00 e9 d2 01 00 00 66 90 e8 ab f4 ff ff 48 83
05 33 ef 06 02 01 85 c0 0f 85 bb 01 00 00 48 83 05 2b ef 06 02 01 be
01 00 00 00
[   69.250246]  8b 7d 00 e8 c5 fc ff ff 48 85 c0 49 89 c4 0f 84 69 01 00 00
[   69.250246] RIP  [<ffffffff81256c62>] scan_block+0x62/0x220
[   69.250246]  RSP <ffff880073f69d90>
[   69.250246] CR2: 00000000001d7270
[   69.360917] ---[ end trace a7919e7f17c0a727 ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
