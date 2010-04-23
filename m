Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 314F36B01F2
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 01:11:39 -0400 (EDT)
Received: by iwn40 with SMTP id 40so839097iwn.1
        for <linux-mm@kvack.org>; Thu, 22 Apr 2010 22:11:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100423120148.9ffa5881.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100423120148.9ffa5881.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 23 Apr 2010 14:11:37 +0900
Message-ID: <m2l28c262361004222211j602f224bv60ffd381f524e78a@mail.gmail.com>
Subject: Re: [BUGFIX][mm][PATCH] fix migration race in rmap_walk
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Apr 23, 2010 at 12:01 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> This patch itself is for -mm ..but may need to go -stable tree for memory
> hotplug. (but we've got no report to hit this race...)
>
> This one is the simplest, I think and works well on my test set.
> =3D=3D
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> In rmap.c, at checking rmap in vma chain in page->mapping, anon_vma->lock
> or mapping->i_mmap_lock is held and enter following loop.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for_each_vma_in_this_rmap_link(list from page-=
>mapping) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long addr=
ess =3D vma_address(page, vma);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (address =3D=3D=
 -EFAULT)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0continue;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0....
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> vma_address is checking [start, end, pgoff] v.s. page->index.
>
> But vma's [start, end, pgoff] is updated without locks. vma_address()
> can hit a race and may return wrong result.
>
> This bahavior is no problem in usual routine as try_to_unmap() etc...
> But for page migration, rmap_walk() has to find all migration_ptes
> which migration code overwritten valid ptes. This race is critical and ca=
use
> BUG that a migration_pte is sometimes not removed.
>
> pr 21 17:27:47 localhost kernel: ------------[ cut here ]------------
> Apr 21 17:27:47 localhost kernel: kernel BUG at include/linux/swapops.h:1=
05!
> Apr 21 17:27:47 localhost kernel: invalid opcode: 0000 [#1] SMP DEBUG_PAG=
EALLOC
> Apr 21 17:27:47 localhost kernel: last sysfs file: /sys/devices/virtual/n=
et/br0/statistics/collisions
> Apr 21 17:27:47 localhost kernel: CPU 3
> Apr 21 17:27:47 localhost kernel: Modules linked in: fuse sit tunnel4 ipt=
_MASQUERADE iptable_nat nf_nat bridge stp llc sunrpc cpufreq_ondemand acpi_=
cpufreq freq_table mperf xt_physdev ip6t_REJECT nf_conntrack_ipv6 ip6table_=
filter ip6_tables ipv6 dm_multipath uinput ioatdma ppdev parport_pc i5000_e=
dac bnx2 iTCO_wdt edac_core iTCO_vendor_support shpchp parport e1000e kvm_i=
ntel dca kvm i2c_i801 i2c_core i5k_amb pcspkr megaraid_sas [last unloaded: =
microcode]
> Apr 21 17:27:47 localhost kernel:
> Apr 21 17:27:47 localhost kernel: Pid: 27892, comm: cc1 Tainted: G =C2=A0=
 =C2=A0 =C2=A0 =C2=A0W =C2=A0 2.6.34-rc4-mm1+ #4 D2519/PRIMERGY
> Apr 21 17:27:47 localhost kernel: RIP: 0010:[<ffffffff8114e9cf>] =C2=A0[<=
ffffffff8114e9cf>] migration_entry_wait+0x16f/0x180
> Apr 21 17:27:47 localhost kernel: RSP: 0000:ffff88008d9efe08 =C2=A0EFLAGS=
: 00010246
> Apr 21 17:27:47 localhost kernel: RAX: ffffea0000000000 RBX: ffffea000024=
1100 RCX: 0000000000000001
> Apr 21 17:27:47 localhost kernel: RDX: 000000000000a4e0 RSI: ffff880621a4=
ab00 RDI: 000000000149c03e
> Apr 21 17:27:47 localhost kernel: RBP: ffff88008d9efe38 R08: 000000000000=
0000 R09: 0000000000000000
> Apr 21 17:27:47 localhost kernel: R10: 0000000000000000 R11: 000000000000=
0001 R12: ffff880621a4aae8
> Apr 21 17:27:47 localhost kernel: R13: 00000000bf811000 R14: 000000000149=
c03e R15: 0000000000000000
> Apr 21 17:27:47 localhost kernel: FS: =C2=A000007fe6abc90700(0000) GS:fff=
f880005a00000(0000) knlGS:0000000000000000
> Apr 21 17:27:47 localhost kernel: CS: =C2=A00010 DS: 0000 ES: 0000 CR0: 0=
000000080050033
> Apr 21 17:27:47 localhost kernel: CR2: 00007fe6a37279a0 CR3: 000000008d94=
2000 CR4: 00000000000006e0
> Apr 21 17:27:47 localhost kernel: DR0: 0000000000000000 DR1: 000000000000=
0000 DR2: 0000000000000000
> Apr 21 17:27:47 localhost kernel: DR3: 0000000000000000 DR6: 00000000ffff=
0ff0 DR7: 0000000000000400
> Apr 21 17:27:47 localhost kernel: Process cc1 (pid: 27892, threadinfo fff=
f88008d9ee000, task ffff8800b23ec820)
> Apr 21 17:27:47 localhost kernel: Stack:
> Apr 21 17:27:47 localhost kernel: ffffea000101aee8 ffff880621a4aae8 ffff8=
8008d9efe38 00007fe6a37279a0
> Apr 21 17:27:47 localhost kernel: <0> ffff8805d9706d90 ffff880621a4aa00 f=
fff88008d9efef8 ffffffff81126d05
> Apr 21 17:27:47 localhost kernel: <0> ffff88008d9efec8 0000000000000246 0=
000000000000000 ffffffff81586533
> Apr 21 17:27:47 localhost kernel: Call Trace:
> Apr 21 17:27:47 localhost kernel: [<ffffffff81126d05>] handle_mm_fault+0x=
995/0x9b0
> Apr 21 17:27:47 localhost kernel: [<ffffffff81586533>] ? do_page_fault+0x=
103/0x330
> Apr 21 17:27:47 localhost kernel: [<ffffffff8104bf40>] ? finish_task_swit=
ch+0x0/0xf0
> Apr 21 17:27:47 localhost kernel: [<ffffffff8158659e>] do_page_fault+0x16=
e/0x330
> Apr 21 17:27:47 localhost kernel: [<ffffffff81582f35>] page_fault+0x25/0x=
30
> Apr 21 17:27:47 localhost kernel: Code: 53 08 85 c9 0f 84 32 ff ff ff 8d =
41 01 89 4d d8 89 45 d4 8b 75 d4 8b 45 d8 f0 0f b1 32 89 45 dc 8b 45 dc 39 =
c8 74 aa 89 c1 eb d7 <0f> 0b eb fe 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 5=
5 48 89 e5
> Apr 21 17:27:47 localhost kernel: RIP =C2=A0[<ffffffff8114e9cf>] migratio=
n_entry_wait+0x16f/0x180
> Apr 21 17:27:47 localhost kernel: RSP <ffff88008d9efe08>
> Apr 21 17:27:47 localhost kernel: ---[ end trace 4860ab585c1fcddb ]---
>
>
>
> This patch adds vma_address_safe(). And update [start, end, pgoff]
> under seq counter.
>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> Cc: Christoph Lameter <cl@linux-foundation.org>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

That's exactly same what I have in mind. :)
But I am hesitating. That's because AFAIR, we try to remove seqlock. Right?
But in this case, seqlock is good, I think. :)
--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
