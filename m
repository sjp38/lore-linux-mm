Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id DBDA66B002B
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 10:14:48 -0500 (EST)
Received: by mail-ob0-f173.google.com with SMTP id xn12so7804142obc.4
        for <linux-mm@kvack.org>; Wed, 26 Dec 2012 07:14:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <50DAFA8C.2030906@redhat.com>
References: <535932623.34838584.1356410331076.JavaMail.root@redhat.com>
	<692539675.35132464.1356520940797.JavaMail.root@redhat.com>
	<CAJd=RBD0mjdUZA82UDv134w=TvNtgRNGXWON8CnG0FPexj7vXQ@mail.gmail.com>
	<50DAFA8C.2030906@redhat.com>
Date: Wed, 26 Dec 2012 23:14:47 +0800
Message-ID: <CAJd=RBB+hw3ybwtMkmLr8ef7FbktU0r0aHEn4qH0xpUObS0B1Q@mail.gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at 0000000000000500
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhouping Liu <zliu@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Johannes Weiner <jweiner@redhat.com>, mgorman@suse.de, hughd@google.com, Andrea Arcangeli <aarcange@redhat.com>, "devendra.aaru" <devendra.aaru@gmail.com>, Jongman Heo <jongman.heo@samsung.com>

On Wed, Dec 26, 2012 at 9:24 PM, Zhouping Liu <zliu@redhat.com> wrote:
> On 12/26/2012 08:01 PM, Hillf Danton wrote:
>>
>> On Wed, Dec 26, 2012 at 7:22 PM, Zhouping Liu <zliu@redhat.com> wrote:
>>>
>>> Hello everyone,
>>>
>>> The latest mainline(637704cbc95c) would trigger the following error when
>>> the system was under
>>> some pressure condition(in my testing, I used oom01 case inside LTP test
>>> suite to trigger the issue):
>>>
>>> [ 5462.920151] BUG: unable to handle kernel NULL pointer dereference at
>>> 0000000000000500
>>> [ 5462.927991] IP: [<ffffffff811542d9>] wait_iff_congested+0x59/0x140
>>> [ 5462.934176] PGD 0
>>> [ 5462.936191] Oops: 0000 [#2] SMP
>>> [ 5462.939428] Modules linked in: lockd sunrpc iptable_mangle ipt_REJECT
>>> nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_filter
>>> ebtables ip6table_filter ip6_tables iptable_filter ip_tabled
>>> [ 5462.984261] CPU 13
>>> [ 5462.986184] Pid: 117, comm: kswapd3 Tainted: G      D      3.8.0-rc1+
>>> #1 Dell Inc. PowerEdge M905/0D413F
>>> [ 5462.995814] RIP: 0010:[<ffffffff811542d9>]  [<ffffffff811542d9>]
>>> wait_iff_congested+0x59/0x140
>>> [ 5463.004411] RSP: 0018:ffff88007c97fd48  EFLAGS: 00010202
>>> [ 5463.009701] RAX: 0000000000000001 RBX: 0000000000000064 RCX:
>>> 0000000000000001
>>> [ 5463.016818] RDX: 0000000000000064 RSI: 0000000000000000 RDI:
>>> 0000000000000000
>>> [ 5463.023926] RBP: ffff88007c97fd98 R08: 0000000000000000 R09:
>>> ffff88022ffd9d80
>>> [ 5463.031033] R10: 0000000000003189 R11: 0000000000000000 R12:
>>> 00000001004ee87e
>>> [ 5463.038140] R13: 0000000000000002 R14: 0000000000000000 R15:
>>> ffff88022ffd9000
>>> [ 5463.045258] FS:  00007f3e570de740(0000) GS:ffff88022fcc0000(0000)
>>> knlGS:0000000000000000
>>> [ 5463.053317] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>>> [ 5463.059041] CR2: 0000000000000500 CR3: 00000000018dc000 CR4:
>>> 00000000000007e0
>>> [ 5463.066157] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
>>> 0000000000000000
>>> [ 5463.073276] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
>>> 0000000000000400
>>> [ 5463.080400] Process kswapd3 (pid: 117, threadinfo ffff88007c97e000,
>>> task ffff88007c981970)
>>> [ 5463.088633] Stack:
>>> [ 5463.090646]  ffff88007c97fd98 0000000000000000 ffff88007c981970
>>> ffffffff81086080
>>> [ 5463.098090]  ffff88007c97fd68 ffff88007c97fd68 ffff88022ffd9d80
>>> 0000000000000002
>>> [ 5463.105527]  0000000000000002 0000000000000000 ffff88007c97feb8
>>> ffffffff8114b0e3
>>> [ 5463.112998] Call Trace:
>>> [ 5463.115446]  [<ffffffff81086080>] ? wake_up_bit+0x40/0x40
>>> [ 5463.120826]  [<ffffffff8114b0e3>] kswapd+0x6c3/0xa50
>>> [ 5463.125775]  [<ffffffff8114aa20>] ? zone_reclaim+0x270/0x270
>>> [ 5463.131415]  [<ffffffff81085680>] kthread+0xc0/0xd0
>>> [ 5463.136278]  [<ffffffff810855c0>] ? kthread_create_on_node+0x120/0x120
>>> [ 5463.142786]  [<ffffffff8160a0ac>] ret_from_fork+0x7c/0xb0
>>> [ 5463.148166]  [<ffffffff810855c0>] ? kthread_create_on_node+0x120/0x120
>>> [ 5463.154668] Code: 4e 6d 88 00 48 c7 45 b8 00 00 00 00 48 83 c0 18 48
>>> c7 45 c8 80 60 08 81 48 89 45 d0 48 89 45 d8 8b 04 b5 a0 9a cd 81 85 c0 74
>>> 0f <48> 8b 87 00 05 00 00 a8 04 0f 85 98 00 00 00 e8 b3 c3
>>> [ 5463.174097] RIP  [<ffffffff811542d9>] wait_iff_congested+0x59/0x140
>>> [ 5463.180352]  RSP <ffff88007c97fd48>
>>> [ 5463.183824] CR2: 0000000000000500
>>> [ 5463.203717] ---[ end trace 9ff4ff9087c13a36 ]---
>>>
>>> I attached the config file, hope it can make some help.
>>
>> Hey Zhouping,
>>
>> Can you please run with the following commit reverted?
>>
>> Hillf
>>
>>     commit cda73a10eb3f
>>     mm: do not sleep in balance_pgdat if there's no i/o congestion
>
>
> Hello Hillf,
>
> Tested it with cda73a10eb3f reverted on two machines, no such issue occurred
> again.

It is really good news;) thank you a ton for testing.

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
