Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2DF416B0055
	for <linux-mm@kvack.org>; Fri,  3 Jul 2009 05:00:55 -0400 (EDT)
Received: by qyk36 with SMTP id 36so1006246qyk.12
        for <linux-mm@kvack.org>; Fri, 03 Jul 2009 02:12:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090703173934.dc278fda.kamezawa.hiroyu@jp.fujitsu.com>
References: <4A4DBF16.1020509@gmail.com>
	 <20090703173934.dc278fda.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 3 Jul 2009 18:12:13 +0900
Message-ID: <28c262360907030212h5bd5457u842a8d805249583a@mail.gmail.com>
Subject: Re: BUG at mm/vmscan.c:904 [mmotm 2009-07-02-19-57]
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Jiri Slaby <jirislaby@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux kernel mailing list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi, kame.

Andrew already reverted it.
It's totally my fault.
I'll fix it on tomorrow.

Thanks for notifying me. :)

On Fri, Jul 3, 2009 at 5:39 PM, KAMEZAWA
Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 03 Jul 2009 10:19:34 +0200
> Jiri Slaby <jirislaby@gmail.com> wrote:
>
>> Hi,
>>
>> I don't know what exactly lead to this, but I got it when installing a
>> kernel rpm (io load) in qemu:
>>
> IIUC....
>
> plz revert this.
>
> =C2=A0vmscan-dont-attempt-to-reclaim-anon-page-in-lumpy-reclaim-when-no-s=
wap-space-is-available.patch
>
> or rewrite as following.
> =3D=3D
> + =C2=A0 =C2=A0 =C2=A0 if (nr_swap_pages <=3D 0 && (PageAnon(page) && !Pa=
geSwapCache(page)))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EBUSY;
> +
> =3D=3D
>
> CCed to Minchan and Kosaki.
>
> Regards,
> -Kame
>
>
>
>> ------------[ cut here ]------------
>> kernel BUG at mm/vmscan.c:904!
>> invalid opcode: 0000 [#1] PREEMPT SMP
>> last sysfs file: /sys/devices/pci0000:00/0000:00:05.0/modalias
>> CPU 0
>> Modules linked in: e1000
>> Pid: 290, comm: kswapd0 Tainted: G =C2=A0 =C2=A0 =C2=A0 AW =C2=A02.6.31-=
rc1-mm1 #103
>> RIP: 0010:[<ffffffff81095c96>] =C2=A0[<ffffffff81095c96>]
>> isolate_pages_global+0x196/0x260
>> RSP: 0018:ffff880011943c40 =C2=A0EFLAGS: 00010082
>> RAX: 00000000ffffffea RBX: ffffea0000050170 RCX: 0000000000000001
>> RDX: 0000000000000001 RSI: 0000000000000000 RDI: ffffea0000050170
>> RBP: ffff880011943cd0 R08: 0000000000000001 R09: ffffffff81668b00
>> R10: 00000000ffffffff R11: 0000000000000001 R12: ffffffff81669060
>> R13: ffffea0000050198 R14: ffff880011943d50 R15: ffffffff81668b00
>> FS: =C2=A00000000000000000(0000) GS:ffff88000176f000(0000) knlGS:0000000=
000000000
>> CS: =C2=A00010 DS: 0018 ES: 0018 CR0: 000000008005003b
>> CR2: 00007f5d32981000 CR3: 0000000011adb000 CR4: 00000000000006f0
>> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>> Process kswapd0 (pid: 290, threadinfo ffff880011942000, task
>> ffff88001254c840)
>> Stack:
>> =C2=A0ffff880011943d68 0000000000000020 0000000000000030 000000020177f4b=
0
>> <0> 0000000000000003 000000008103329b 0000000000000001 ffffffffffffffff
>> <0> 0000000100000003 0000000000000000 0000000000000000 0000000000000000
>> Call Trace:
>> =C2=A0[<ffffffff81096ae6>] shrink_active_list+0xa6/0x330
>> =C2=A0[<ffffffff81032fe8>] ? task_rq_lock+0x48/0x90
>> =C2=A0[<ffffffff810985c0>] ? kswapd+0x0/0x770
>> =C2=A0[<ffffffff81098ab5>] kswapd+0x4f5/0x770
>> =C2=A0[<ffffffff81037177>] ? pick_next_task_fair+0xd7/0xf0
>> =C2=A0[<ffffffff810985c0>] ? kswapd+0x0/0x770
>> =C2=A0[<ffffffff81095b00>] ? isolate_pages_global+0x0/0x260
>> =C2=A0[<ffffffff8103f1ed>] ? default_wake_function+0xd/0x10
>> =C2=A0[<ffffffff8105aa30>] ? autoremove_wake_function+0x0/0x40
>> =C2=A0[<ffffffff813f9978>] ? preempt_schedule+0x38/0x60
>> =C2=A0[<ffffffff813fbb40>] ? _spin_unlock_irqrestore+0x30/0x40
>> =C2=A0[<ffffffff810985c0>] ? kswapd+0x0/0x770
>> =C2=A0[<ffffffff8105a6b6>] kthread+0x96/0xa0
>> =C2=A0[<ffffffff8100ceaa>] child_rip+0xa/0x20
>> =C2=A0[<ffffffff8105a620>] ? kthread+0x0/0xa0
>> =C2=A0[<ffffffff8100cea0>] ? child_rip+0x0/0x20
>> Code: 80 75 12 8b 55 bc 8b 75 b4 4c 89 ef e8 f4 f9 ff ff 85 c0 74 79 49
>> ff c7 49 83 c5 38 4c 39 7d 98 77 cf 48 ff 45 c8 e9 e9 fe ff ff <0f> 0b
>> eb fe 48 8b 53 30 48 8b 4b 28 48 8d 43 28 48 89 51 08 48
>> RIP =C2=A0[<ffffffff81095c96>] isolate_pages_global+0x196/0x260
>> =C2=A0RSP <ffff880011943c40>
>> ---[ end trace fc1de39f3465335f ]---
>> note: kswapd0[290] exited with preempt_count 1
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>>
>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
