Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id BAA276B01EE
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 03:00:37 -0400 (EDT)
Received: by gxk9 with SMTP id 9so5822403gxk.8
        for <linux-mm@kvack.org>; Fri, 23 Apr 2010 00:00:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100423142738.d0114946.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100423120148.9ffa5881.kamezawa.hiroyu@jp.fujitsu.com>
	 <m2l28c262361004222211j602f224bv60ffd381f524e78a@mail.gmail.com>
	 <20100423142738.d0114946.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 23 Apr 2010 16:00:31 +0900
Message-ID: <z2x28c262361004230000ubce8c5b0t759dceeee7b4ec19@mail.gmail.com>
Subject: Re: [BUGFIX][mm][PATCH] fix migration race in rmap_walk
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Apr 23, 2010 at 2:27 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 23 Apr 2010 14:11:37 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> On Fri, Apr 23, 2010 at 12:01 PM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> >
>> > This patch itself is for -mm ..but may need to go -stable tree for mem=
ory
>> > hotplug. (but we've got no report to hit this race...)
>> >
>> > This one is the simplest, I think and works well on my test set.
>> > =3D=3D
>> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> >
>> > In rmap.c, at checking rmap in vma chain in page->mapping, anon_vma->l=
ock
>> > or mapping->i_mmap_lock is held and enter following loop.
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0for_each_vma_in_this_rmap_link(list from pa=
ge->mapping) {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long a=
ddress =3D vma_address(page, vma);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (address =3D=
=3D -EFAULT)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0continue;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0....
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>> >
>> > vma_address is checking [start, end, pgoff] v.s. page->index.
>> >
>> > But vma's [start, end, pgoff] is updated without locks. vma_address()
>> > can hit a race and may return wrong result.
>> >
>> > This bahavior is no problem in usual routine as try_to_unmap() etc...
>> > But for page migration, rmap_walk() has to find all migration_ptes
>> > which migration code overwritten valid ptes. This race is critical and=
 cause
>> > BUG that a migration_pte is sometimes not removed.
>> >
>> > pr 21 17:27:47 localhost kernel: ------------[ cut here ]------------
>> > Apr 21 17:27:47 localhost kernel: kernel BUG at include/linux/swapops.=
h:105!
>> > Apr 21 17:27:47 localhost kernel: invalid opcode: 0000 [#1] SMP DEBUG_=
PAGEALLOC
>> > Apr 21 17:27:47 localhost kernel: last sysfs file: /sys/devices/virtua=
l/net/br0/statistics/collisions
>> > Apr 21 17:27:47 localhost kernel: CPU 3
>> > Apr 21 17:27:47 localhost kernel: Modules linked in: fuse sit tunnel4 =
ipt_MASQUERADE iptable_nat nf_nat bridge stp llc sunrpc cpufreq_ondemand ac=
pi_cpufreq freq_table mperf xt_physdev ip6t_REJECT nf_conntrack_ipv6 ip6tab=
le_filter ip6_tables ipv6 dm_multipath uinput ioatdma ppdev parport_pc i500=
0_edac bnx2 iTCO_wdt edac_core iTCO_vendor_support shpchp parport e1000e kv=
m_intel dca kvm i2c_i801 i2c_core i5k_amb pcspkr megaraid_sas [last unloade=
d: microcode]
>> > Apr 21 17:27:47 localhost kernel:
>> > Apr 21 17:27:47 localhost kernel: Pid: 27892, comm: cc1 Tainted: G =C2=
=A0 =C2=A0 =C2=A0 =C2=A0W =C2=A0 2.6.34-rc4-mm1+ #4 D2519/PRIMERGY
>> > Apr 21 17:27:47 localhost kernel: RIP: 0010:[<ffffffff8114e9cf>] =C2=
=A0[<ffffffff8114e9cf>] migration_entry_wait+0x16f/0x180
>> > Apr 21 17:27:47 localhost kernel: RSP: 0000:ffff88008d9efe08 =C2=A0EFL=
AGS: 00010246
>> > Apr 21 17:27:47 localhost kernel: RAX: ffffea0000000000 RBX: ffffea000=
0241100 RCX: 0000000000000001
>> > Apr 21 17:27:47 localhost kernel: RDX: 000000000000a4e0 RSI: ffff88062=
1a4ab00 RDI: 000000000149c03e
>> > Apr 21 17:27:47 localhost kernel: RBP: ffff88008d9efe38 R08: 000000000=
0000000 R09: 0000000000000000
>> > Apr 21 17:27:47 localhost kernel: R10: 0000000000000000 R11: 000000000=
0000001 R12: ffff880621a4aae8
>> > Apr 21 17:27:47 localhost kernel: R13: 00000000bf811000 R14: 000000000=
149c03e R15: 0000000000000000
>> > Apr 21 17:27:47 localhost kernel: FS: =C2=A000007fe6abc90700(0000) GS:=
ffff880005a00000(0000) knlGS:0000000000000000
>> > Apr 21 17:27:47 localhost kernel: CS: =C2=A00010 DS: 0000 ES: 0000 CR0=
: 0000000080050033
>> > Apr 21 17:27:47 localhost kernel: CR2: 00007fe6a37279a0 CR3: 000000008=
d942000 CR4: 00000000000006e0
>> > Apr 21 17:27:47 localhost kernel: DR0: 0000000000000000 DR1: 000000000=
0000000 DR2: 0000000000000000
>> > Apr 21 17:27:47 localhost kernel: DR3: 0000000000000000 DR6: 00000000f=
fff0ff0 DR7: 0000000000000400
>> > Apr 21 17:27:47 localhost kernel: Process cc1 (pid: 27892, threadinfo =
ffff88008d9ee000, task ffff8800b23ec820)
>> > Apr 21 17:27:47 localhost kernel: Stack:
>> > Apr 21 17:27:47 localhost kernel: ffffea000101aee8 ffff880621a4aae8 ff=
ff88008d9efe38 00007fe6a37279a0
>> > Apr 21 17:27:47 localhost kernel: <0> ffff8805d9706d90 ffff880621a4aa0=
0 ffff88008d9efef8 ffffffff81126d05
>> > Apr 21 17:27:47 localhost kernel: <0> ffff88008d9efec8 000000000000024=
6 0000000000000000 ffffffff81586533
>> > Apr 21 17:27:47 localhost kernel: Call Trace:
>> > Apr 21 17:27:47 localhost kernel: [<ffffffff81126d05>] handle_mm_fault=
+0x995/0x9b0
>> > Apr 21 17:27:47 localhost kernel: [<ffffffff81586533>] ? do_page_fault=
+0x103/0x330
>> > Apr 21 17:27:47 localhost kernel: [<ffffffff8104bf40>] ? finish_task_s=
witch+0x0/0xf0
>> > Apr 21 17:27:47 localhost kernel: [<ffffffff8158659e>] do_page_fault+0=
x16e/0x330
>> > Apr 21 17:27:47 localhost kernel: [<ffffffff81582f35>] page_fault+0x25=
/0x30
>> > Apr 21 17:27:47 localhost kernel: Code: 53 08 85 c9 0f 84 32 ff ff ff =
8d 41 01 89 4d d8 89 45 d4 8b 75 d4 8b 45 d8 f0 0f b1 32 89 45 dc 8b 45 dc =
39 c8 74 aa 89 c1 eb d7 <0f> 0b eb fe 66 66 66 66 2e 0f 1f 84 00 00 00 00 0=
0 55 48 89 e5
>> > Apr 21 17:27:47 localhost kernel: RIP =C2=A0[<ffffffff8114e9cf>] migra=
tion_entry_wait+0x16f/0x180
>> > Apr 21 17:27:47 localhost kernel: RSP <ffff88008d9efe08>
>> > Apr 21 17:27:47 localhost kernel: ---[ end trace 4860ab585c1fcddb ]---
>> >
>> >
>> >
>> > This patch adds vma_address_safe(). And update [start, end, pgoff]
>> > under seq counter.
>> >
>> > Cc: Mel Gorman <mel@csn.ul.ie>
>> > Cc: Minchan Kim <minchan.kim@gmail.com>
>> > Cc: Christoph Lameter <cl@linux-foundation.org>
>> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>
>> That's exactly same what I have in mind. :)
>> But I am hesitating. That's because AFAIR, we try to remove seqlock. Rig=
ht?
>
> Ah,..."don't use seqlock" is trend ?
>
>> But in this case, seqlock is good, I think. :)
>>
> BTW, this isn't seqlock but seq_counter :)
>
> I'm still testing. What I doubt other than vma_address() is fork().
> at fork(), followings _may_ happen. (but I'm not sure).
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0chain vma.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0copy page table.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 -> migration entry is copied, too.
>
> At remap,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for each vma
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0look into page table and replace=
.
>
> Then,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0rmap_walk().
> =C2=A0 =C2=A0 =C2=A0 =C2=A0fork(parent, child)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0look into child's page table.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0=3D> we fond nothing.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock(child's pagetable);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock(parant's page table);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0copy migration entry
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock(paranet's page table)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock(child's page table)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0update parent's paga table
>
> If we always find parant's page table before child's , there is no race.
> But I can't get prit_tree's list order as clear image. Hmm.
>
> Thanks,
> -Kame
>

That's good point, Kame.
I looked into prio_tree quickly.
If I understand it right, list order is backward.

dup_mmap calls vma_prio_tree_add.

 * prio_tree_root
 *      |
 *      A       vm_set.head
 *     / \      /
 *    L   R -> H-I-J-K-M-N-O-P-Q-S
 *    ^   ^    <-- vm_set.list -->
 *  tree nodes
 *

Maybe, parent and childs's vma are H~S.
Then, comment said.

"vma->shared.vm_set.parent !=3D NULL    =3D=3D> a tree node"
So vma_prio_tree_add call not list_add_tail but list_add.

Anyway, I think order isn't mixed.
So, could we traverse it by backward in rmap?

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
