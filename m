Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 238D76B01E3
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 00:00:44 -0400 (EDT)
Received: by qyk15 with SMTP id 15so1917230qyk.26
        for <linux-mm@kvack.org>; Sun, 25 Apr 2010 21:00:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100423155801.GA14351@csn.ul.ie>
References: <20100423120148.9ffa5881.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100423095922.GJ30306@csn.ul.ie> <20100423155801.GA14351@csn.ul.ie>
Date: Mon, 26 Apr 2010 13:00:40 +0900
Message-ID: <o2x28c262361004252100i1734ba3ek8e3b6363fe22f9b@mail.gmail.com>
Subject: Re: [BUGFIX][mm][PATCH] fix migration race in rmap_walk
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <cl@linux.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi, Mel.

On Sat, Apr 24, 2010 at 12:58 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Fri, Apr 23, 2010 at 10:59:22AM +0100, Mel Gorman wrote:
>> On Fri, Apr 23, 2010 at 12:01:48PM +0900, KAMEZAWA Hiroyuki wrote:
>> > This patch itself is for -mm ..but may need to go -stable tree for mem=
ory
>> > hotplug. (but we've got no report to hit this race...)
>> >
>>
>> Only because it's very difficult to hit. Even when running compaction
>> constantly, it can take anywhere between 10 minutes and 2 hours for me
>> to reproduce it.
>>
>> > This one is the simplest, I think and works well on my test set.
>> > =3D=3D
>> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> >
>> > In rmap.c, at checking rmap in vma chain in page->mapping, anon_vma->l=
ock
>> > or mapping->i_mmap_lock is held and enter following loop.
>> >
>> > =C2=A0 =C2=A0 for_each_vma_in_this_rmap_link(list from page->mapping) =
{
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long address =3D vm=
a_address(page, vma);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (address =3D=3D -EFAULT)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
continue;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ....
>> > =C2=A0 =C2=A0 }
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
>> > This patch adds vma_address_safe(). And update [start, end, pgoff]
>> > under seq counter.
>> >
>>
>> I had considered this idea as well as it is vaguely similar to how zones=
 get
>> resized with a seqlock. I was hoping that the existing locking on anon_v=
ma
>> would be usable by backing off until uncontended but maybe not so lets
>> check out this approach.
>>
>
> A possible combination of the two approaches is as follows. It uses the
> anon_vma lock mostly except where the anon_vma differs between the page
> and the VMAs being walked in which case it uses the seq counter. I've
> had it running a few hours now without problems but I'll leave it
> running at least 24 hours.
>
> =3D=3D=3D=3D CUT HERE =3D=3D=3D=3D
> =C2=A0mm,migration: Prevent rmap_walk_[anon|ksm] seeing the wrong VMA inf=
ormation by protecting against vma_adjust with a combination of locks and s=
eq counter
>
> vma_adjust() is updating anon VMA information without any locks taken.
> In constract, file-backed mappings use the i_mmap_lock. This lack of
> locking can result in races with page migration. During rmap_walk(),
> vma_address() can return -EFAULT for an address that will soon be valid.
> This leaves a dangling migration PTE behind which can later cause a
> BUG_ON to trigger when the page is faulted in.
>
> With the recent anon_vma changes, there is no single anon_vma->lock that
> can be taken that is safe for rmap_walk() to guard against changes by
> vma_adjust(). Instead, a lock can be taken on one VMA while changes
> happen to another.
>
> What this patch does is protect against updates with a combination of
> locks and seq counters. First, the vma->anon_vma lock is taken by
> vma_adjust() and the sequence counter starts. The lock is released and
> the sequence ended when the VMA updates are complete.
>
> The lock serialses rmap_walk_anon when the page and VMA share the same
> anon_vma. Where the anon_vmas do not match, the seq counter is checked.
> If a change is noticed, rmap_walk_anon drops its locks and starts again
> from scratch as the VMA list may have changed. The dangling migration
> PTE bug was not triggered after several hours of stress testing with
> this patch applied.
>
> [kamezawa.hiroyu@jp.fujitsu.com: Use of a seq counter]
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
> =C2=A0include/linux/mm_types.h | =C2=A0 13 +++++++++++++
> =C2=A0mm/ksm.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =
=C2=A0 17 +++++++++++++++--
> =C2=A0mm/mmap.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =
=C2=A0 30 ++++++++++++++++++++++++++++++
> =C2=A0mm/rmap.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =
=C2=A0 25 ++++++++++++++++++++++++-
> =C2=A04 files changed, 82 insertions(+), 3 deletions(-)
>
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index b8bb9a6..fcd5db2 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -12,6 +12,7 @@
> =C2=A0#include <linux/completion.h>
> =C2=A0#include <linux/cpumask.h>
> =C2=A0#include <linux/page-debug-flags.h>
> +#include <linux/seqlock.h>
> =C2=A0#include <asm/page.h>
> =C2=A0#include <asm/mmu.h>
>
> @@ -240,6 +241,18 @@ struct mm_struct {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct rw_semaphore mmap_sem;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spinlock_t page_table_lock; =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 /* Protects page tables and some counters */
>
> +#ifdef CONFIG_MIGRATION
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* During migration, rmap_walk walks all the =
VMAs mapping a particular
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* page to remove the migration ptes. It does=
n't this without mmap_sem
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* held and the semaphore is unnecessarily he=
avily to take in this case.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* File-backed VMAs are protected by the i_mm=
ap_lock and anon-VMAs are
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* protected by this seq counter. If the seq =
counter changes while
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* the migration PTE is being removed, the op=
eration restarts.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 seqcount_t span_seqcounter;
> +#endif
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct list_head mmlist; =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* List of maybe swapped mm's. =C2=A0Thes=
e are globally strung
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 * together off init_mm.mmlist, and are protected
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 * by mmlist_lock
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 3666d43..613c762 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -1671,11 +1671,24 @@ again:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct anon_vma_ch=
ain *vmac;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct vm_area_str=
uct *vma;
>
> +retry:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock(&anon_vm=
a->lock);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0list_for_each_entr=
y(vmac, &anon_vma->head, same_anon_vma) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 unsigned long update_race;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 bool outside;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0vma =3D vmac->vma;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 if (rmap_item->address < vma->vm_start ||
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 rmap_item->address >=3D vma->vm_end)
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 /* See comment in rmap_walk_anon about reading anon VMA info */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 update_race =3D read_seqcount_begin(&vma->vm_mm->span_seqcounter);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 outside =3D rmap_item->address < vma->vm_start ||
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 rmap_item->address >=3D vma->vm_end;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 if (anon_vma !=3D vma->anon_vma &&
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 read_seqcoun=
t_retry(&vma->vm_mm->span_seqcounter, update_race)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_unlock(&anon_vma->lock);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto retry;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 }
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 if (outside)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0continue;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 * Initially we examine only the vma which covers this
> diff --git a/mm/mmap.c b/mm/mmap.c
> index f90ea92..1508c43 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -491,6 +491,26 @@ __vma_unlink(struct mm_struct *mm, struct vm_area_st=
ruct *vma,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mm->mmap_cache =3D=
 prev;
> =C2=A0}
>
> +#ifdef CONFIG_MIGRATION
> +static void vma_span_seqbegin(struct vm_area_struct *vma)
> +{
> + =C2=A0 =C2=A0 =C2=A0 write_seqcount_begin(&vma->vm_mm->span_seqcounter)=
;
> +}
> +
> +static void vma_span_seqend(struct vm_area_struct *vma)
> +{
> + =C2=A0 =C2=A0 =C2=A0 write_seqcount_end(&vma->vm_mm->span_seqcounter);
> +}
> +#else
> +static inline void vma_span_seqbegin(struct vm_area_struct *vma)
> +{
> +}
> +
> +static void adjust_end_vma(struct vm_area_struct *vma)
> +{
> +}
> +#endif /* CONFIG_MIGRATION */
> +
> =C2=A0/*
> =C2=A0* We cannot adjust vm_start, vm_end, vm_pgoff fields of a vma that
> =C2=A0* is already present in an i_mmap tree without adjusting the tree.
> @@ -578,6 +598,11 @@ again: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 remove_next =3D 1 + (end > next->vm_end);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> + =C2=A0 =C2=A0 =C2=A0 if (vma->anon_vma) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_lock(&vma->anon_v=
ma->lock);


Actually, I can't understand why we need to hold lock of vma->anon_vma->loc=
k?
I think seqcounter is enough.

I looked at your scenarion.

More exactly, your scenario about unmap is following as.

1. VMA A-Lower - VMA A-Upper (include hole)
2. VMA A-Lower - VMA hole - VMA A-Upper(except hole)
3. VMA A-Lower -  hole is remove at last - VMA A-Upper.

I mean VMA A-upper is already linkeded at vma list through
__insert_vm_struct atomically(by seqcounter).
So rmap can find proper entry, I think.

What am I missing? :)

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
