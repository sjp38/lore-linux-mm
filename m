Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 55D476B0201
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 19:01:29 -0400 (EDT)
Received: by gxk6 with SMTP id 6so977691gxk.14
        for <linux-mm@kvack.org>; Wed, 21 Apr 2010 16:01:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1271868724.2100.169.camel@barrios-desktop>
References: <201004152210.o3FMA7KV001909@imap1.linux-foundation.org>
	 <20100419190133.50a13021.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100419181442.GA19264@csn.ul.ie> <20100419193919.GB19264@csn.ul.ie>
	 <20100421172838.0377e0cc.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100421184806.2c3ecc87.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100421102039.GG30306@csn.ul.ie>
	 <1271868724.2100.169.camel@barrios-desktop>
Date: Thu, 22 Apr 2010 08:01:27 +0900
Message-ID: <t2k28c262361004211601w3f42f5e0j79b53ecb43372e3d@mail.gmail.com>
Subject: Re: error at compaction (Re: mmotm 2010-04-15-14-42 uploaded
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 22, 2010 at 1:52 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
> Hi, Mel.
>
> On Wed, 2010-04-21 at 11:20 +0100, Mel Gorman wrote:
>> On Wed, Apr 21, 2010 at 06:48:06PM +0900, KAMEZAWA Hiroyuki wrote:
>> > On Wed, 21 Apr 2010 17:28:38 +0900
>> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> >
>> > > On Mon, 19 Apr 2010 20:39:19 +0100
>> > > Mel Gorman <mel@csn.ul.ie> wrote:
>> > >
>> > > > On Mon, Apr 19, 2010 at 07:14:42PM +0100, Mel Gorman wrote:
>> > > > =3D=3D=3D=3D CUT HERE =3D=3D=3D=3D
>> > > > mm,compaction: Map free pages in the address space after they get =
split for compaction
>> > > >
>> > > > split_free_page() is a helper function which takes a free page fro=
m the
>> > > > buddy lists and splits it into order-0 pages. It is used by memory
>> > > > compaction to build a list of destination pages. If
>> > > > CONFIG_DEBUG_PAGEALLOC is set, a kernel paging request bug is trig=
gered
>> > > > because split_free_page() did not call the arch-allocation hooks o=
r map
>> > > > the page into the kernel address space.
>> > > >
>> > > > This patch does not update split_free_page() as it is called with
>> > > > interrupts held. Instead it documents that callers of split_free_p=
age()
>> > > > are responsible for calling the arch hooks and to map the page and=
 fixes
>> > > > compaction.
>> > > >
>> > > > This is a fix to the patch mm-compaction-memory-compaction-core.pa=
tch.
>> > > >
>> > > > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
>> > >
>> > > Sorry, I think I hit another? error again. (sorry, no log.)
>> > > What I did was...
>> > > =C2=A0 =C2=A0Running 2 shells.
>> > > =C2=A0 =C2=A0while true; do make -j 16;make cleanl;done
>> > > =C2=A0 =C2=A0and
>> > > =C2=A0 =C2=A0while true; do echo 0 > /proc/sys/vm/compact_memory;don=
e
>> > >
>> > >
>> > > Using the same config.
>> > >
>> > > Apr 21 17:27:47 localhost kernel: ------------[ cut here ]----------=
--
>> > > Apr 21 17:27:47 localhost kernel: kernel BUG at include/linux/swapop=
s.h:105!
>> > > Apr 21 17:27:47 localhost kernel: invalid opcode: 0000 [#1] SMP DEBU=
G_PAGEALLOC
>> > > Apr 21 17:27:47 localhost kernel: last sysfs file: /sys/devices/virt=
ual/net/br0/statistics/collisions
>> > > Apr 21 17:27:47 localhost kernel: CPU 3
>> > > Apr 21 17:27:47 localhost kernel: Modules linked in: fuse sit tunnel=
4 ipt_MASQUERADE iptable_nat nf_nat bridge stp llc sunrpc cpufreq_ondemand =
acpi_cpufreq freq_table mperf xt_physdev ip6t_REJECT nf_conntrack_ipv6 ip6t=
able_filter ip6_tables ipv6 dm_multipath uinput ioatdma ppdev parport_pc i5=
000_edac bnx2 iTCO_wdt edac_core iTCO_vendor_support shpchp parport e1000e =
kvm_intel dca kvm i2c_i801 i2c_core i5k_amb pcspkr megaraid_sas [last unloa=
ded: microcode]
>> > > Apr 21 17:27:47 localhost kernel:
>> > > Apr 21 17:27:47 localhost kernel: Pid: 27892, comm: cc1 Tainted: G =
=C2=A0 =C2=A0 =C2=A0 =C2=A0W =C2=A0 2.6.34-rc4-mm1+ #4 D2519/PRIMERGY
>> > > Apr 21 17:27:47 localhost kernel: RIP: 0010:[<ffffffff8114e9cf>] =C2=
=A0[<ffffffff8114e9cf>] migration_entry_wait+0x16f/0x180
>> > > Apr 21 17:27:47 localhost kernel: RSP: 0000:ffff88008d9efe08 =C2=A0E=
FLAGS: 00010246
>> > > Apr 21 17:27:47 localhost kernel: RAX: ffffea0000000000 RBX: ffffea0=
000241100 RCX: 0000000000000001
>> > > Apr 21 17:27:47 localhost kernel: RDX: 000000000000a4e0 RSI: ffff880=
621a4ab00 RDI: 000000000149c03e
>> > > Apr 21 17:27:47 localhost kernel: RBP: ffff88008d9efe38 R08: 0000000=
000000000 R09: 0000000000000000
>> > > Apr 21 17:27:47 localhost kernel: R10: 0000000000000000 R11: 0000000=
000000001 R12: ffff880621a4aae8
>> > > Apr 21 17:27:47 localhost kernel: R13: 00000000bf811000 R14: 0000000=
00149c03e R15: 0000000000000000
>> > > Apr 21 17:27:47 localhost kernel: FS: =C2=A000007fe6abc90700(0000) G=
S:ffff880005a00000(0000) knlGS:0000000000000000
>> > > Apr 21 17:27:47 localhost kernel: CS: =C2=A00010 DS: 0000 ES: 0000 C=
R0: 0000000080050033
>> > > Apr 21 17:27:47 localhost kernel: CR2: 00007fe6a37279a0 CR3: 0000000=
08d942000 CR4: 00000000000006e0
>> > > Apr 21 17:27:47 localhost kernel: DR0: 0000000000000000 DR1: 0000000=
000000000 DR2: 0000000000000000
>> > > Apr 21 17:27:47 localhost kernel: DR3: 0000000000000000 DR6: 0000000=
0ffff0ff0 DR7: 0000000000000400
>> > > Apr 21 17:27:47 localhost kernel: Process cc1 (pid: 27892, threadinf=
o ffff88008d9ee000, task ffff8800b23ec820)
>> > > Apr 21 17:27:47 localhost kernel: Stack:
>> > > Apr 21 17:27:47 localhost kernel: ffffea000101aee8 ffff880621a4aae8 =
ffff88008d9efe38 00007fe6a37279a0
>> > > Apr 21 17:27:47 localhost kernel: <0> ffff8805d9706d90 ffff880621a4a=
a00 ffff88008d9efef8 ffffffff81126d05
>> > > Apr 21 17:27:47 localhost kernel: <0> ffff88008d9efec8 0000000000000=
246 0000000000000000 ffffffff81586533
>> > > Apr 21 17:27:47 localhost kernel: Call Trace:
>> > > Apr 21 17:27:47 localhost kernel: [<ffffffff81126d05>] handle_mm_fau=
lt+0x995/0x9b0
>> > > Apr 21 17:27:47 localhost kernel: [<ffffffff81586533>] ? do_page_fau=
lt+0x103/0x330
>> > > Apr 21 17:27:47 localhost kernel: [<ffffffff8104bf40>] ? finish_task=
_switch+0x0/0xf0
>> > > Apr 21 17:27:47 localhost kernel: [<ffffffff8158659e>] do_page_fault=
+0x16e/0x330
>> > > Apr 21 17:27:47 localhost kernel: [<ffffffff81582f35>] page_fault+0x=
25/0x30
>> > > Apr 21 17:27:47 localhost kernel: Code: 53 08 85 c9 0f 84 32 ff ff f=
f 8d 41 01 89 4d d8 89 45 d4 8b 75 d4 8b 45 d8 f0 0f b1 32 89 45 dc 8b 45 d=
c 39 c8 74 aa 89 c1 eb d7 <0f> 0b eb fe 66 66 66 66 2e 0f 1f 84 00 00 00 00=
 00 55 48 89 e5
>> > > Apr 21 17:27:47 localhost kernel: RIP =C2=A0[<ffffffff8114e9cf>] mig=
ration_entry_wait+0x16f/0x180
>> > > Apr 21 17:27:47 localhost kernel: RSP <ffff88008d9efe08>
>> > > Apr 21 17:27:47 localhost kernel: ---[ end trace 4860ab585c1fcddb ]-=
--
>> > >
>> >
>> > It seems that this is a new error.
>> >
>> >
>> > static inline struct page *migration_entry_to_page(swp_entry_t entry)
>> > {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct page *p =3D pfn_to_page(swp_offset(=
entry));
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* Any use of migration entries may o=
nly occur while the
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* corresponding page is locked
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 BUG_ON(!PageLocked(p));
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 return p;
>> > }
>> >
>> >
>> > Hits this BUG_ON()....then, the page migration_entry points to is unlo=
cked.
>> >
>> > But we always do
>> >
>> > =C2=A0 =C2=A0 lock_page(old_page);
>> > =C2=A0 =C2=A0 unamp(old_page);
>> > =C2=A0 =C2=A0 remap(new_page);
>> > =C2=A0 =C2=A0 unlock_page(old_page);
>> >
>> > So....some pte wasn't updated at remap ?
>> >
>>
>> I'm working on reproducing the problem. I've hit it only once. My stress
>> tests were using dd instead of make like yours did and my
>> compilation-orientated test would not have been hitting compaction as
>> hard.
>>
>> The theory I'm working on is that it's a PageSwapCache page that was
>> unmapped and not remapped (remap_swapcache =3D=3D 0) in move_to_new_page=
().
>> In this case, the page would be migrated, left in place and unlocked.
>> Later when a swap fault occurred, the migration PTE is found and the
>> bug_on triggers i.e. the bug check is no longer valid because it is
>> possible for an unlocked migration pte to be left behind.
>
> Hmm. How about the situation?
>
>
> CPU A =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 CPU B
>
> 1. unmap_and_move
> 2. lock_page
> 3. PageAnon && !page_mapped && PageSwapCache =C2=A0 =C2=A03' do_fork
> 4. remap_swapcache =3D 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A04' pte lock, page_dup_rmap <- rac=
e happens
> 5. try_to_unmap - make migration entry by 4'
> 6. move_to_newpage
> 7. don't call remove_migration due to 4
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A08. do_swap_page
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A09. migration_entry_wait
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A010. goto out
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A011. fault!
>
> In this case, process of CPU B will be killed although it passes PageLock=
ed
> So I think we have to find another method.
>
> I might be wrong since nearly falling asleep. :(

Yes. I was wrong.
I seem to miss detach_vma before  unmap_region.
Sorry, Ignore this, please. :(

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
