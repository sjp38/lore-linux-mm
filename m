Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C7D076B0011
	for <linux-mm@kvack.org>; Tue, 10 May 2011 17:08:20 -0400 (EDT)
Received: by pvc12 with SMTP id 12so4169820pvc.14
        for <linux-mm@kvack.org>; Tue, 10 May 2011 14:08:17 -0700 (PDT)
Date: Wed, 11 May 2011 02:38:09 +0530
From: Raghavendra D Prabhu <raghu.prabhu13@gmail.com>
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback related.
Message-ID: <20110510210809.GB5110@Xye>
References: <20110503091320.GA4542@novell.com>
 <1304431982.2576.5.camel@mulgrave.site>
 <1304432553.2576.10.camel@mulgrave.site>
 <20110506074224.GB6591@suse.de>
 <20110506080728.GC6591@suse.de>
 <1304964980.4865.53.camel@mulgrave.site>
 <20110510102141.GA4149@novell.com>
 <1305036064.6737.8.camel@mulgrave.site>
 <20110510143509.GD4146@suse.de>
 <1305041397.6737.12.camel@mulgrave.site>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="S1BNGpv0yoYahz37"
Content-Disposition: inline
In-Reply-To: <1305041397.6737.12.camel@mulgrave.site>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Mel Gorman <mgorman@suse.de>, Mel Gorman <mgorman@novell.com>, Jan Kara <jack@suse.cz>, colin.king@canonical.com, Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>


--S1BNGpv0yoYahz37
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

* On Tue, May 10, 2011 at 10:29:57AM -0500, James Bottomley <James.Bottomle=
y@HansenPartnership.com> wrote:
>On Tue, 2011-05-10 at 15:35 +0100, Mel Gorman wrote:
>> On Tue, May 10, 2011 at 09:01:04AM -0500, James Bottomley wrote:
>> > On Tue, 2011-05-10 at 11:21 +0100, Mel Gorman wrote:
>> > > I really would like to hear if the fix makes a big difference or
>> > > if we need to consider forcing SLUB high-order allocations bailing
>> > > at the first sign of trouble (e.g. by masking out __GFP_WAIT in
>> > > allocate_slab). Even with the fix applied, kswapd might be waking up
>> > > less but processes will still be getting stalled in direct compaction
>> > > and direct reclaim so it would still be jittery.

>> > "the fix" being this

>> > https://lkml.org/lkml/2011/3/5/121


>> Drop this for the moment. It was a long shot at best and there is little
>> evidence the problem is in this area.

>> I'm attaching two patches. The first is the NO_KSWAPD one to stop
>> kswapd being woken up by SLUB using speculative high-orders. The second
>> one is more drastic and prevents slub entering direct reclaim or
>> compaction. It applies on top of patch 1. These are both untested and
>> afraid are a bit rushed as well :(
>
>Preliminary results with both patches applied still show kswapd
>periodically going up to 99% but it doesn't stay there, it comes back
>down again (and, obviously, the system doesn't hang).
>
>This is sysrq-M from a couple of times when it went up there:
>
>[  426.736958] SysRq : Show Memory
>[  426.736974] Mem-Info:
>[  426.736977] Node 0 DMA per-cpu:
>[  426.736983] CPU    0: hi:    0, btch:   1 usd:   0
>[  426.736986] CPU    1: hi:    0, btch:   1 usd:   0
>[  426.736989] CPU    2: hi:    0, btch:   1 usd:   0
>[  426.736993] CPU    3: hi:    0, btch:   1 usd:   0
>[  426.736996] Node 0 DMA32 per-cpu:
>[  426.737002] CPU    0: hi:  186, btch:  31 usd: 169
>[  426.737005] CPU    1: hi:  186, btch:  31 usd:  40
>[  426.737009] CPU    2: hi:  186, btch:  31 usd: 166
>[  426.737012] CPU    3: hi:  186, btch:  31 usd: 168
>[  426.737015] Node 0 Normal per-cpu:
>[  426.737020] CPU    0: hi:    0, btch:   1 usd:   0
>[  426.737024] CPU    1: hi:    0, btch:   1 usd:   0
>[  426.737027] CPU    2: hi:    0, btch:   1 usd:   0
>[  426.737030] CPU    3: hi:    0, btch:   1 usd:   0
>[  426.737036] active_anon:108658 inactive_anon:37031 isolated_anon:0
>[  426.737037]  active_file:32006 inactive_file:41051 isolated_file:32
>[  426.737038]  unevictable:8 dirty:41202 writeback:204 unstable:0
>[  426.737039]  free:191520 slab_reclaimable:8490 slab_unreclaimable:27477
>[  426.737039]  mapped:9176 shmem:26412 pagetables:5427 bounce:0
>[  426.737051] Node 0 DMA free:8140kB min:548kB low:684kB high:820kB activ=
e_anon:0kB inactive_anon:12kB active_file:240kB inactive_file:7280kB unevic=
table:0kB isolated(anon):0kB isolated(file):0kB present:15676kB mlocked:0kB=
 dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:180kB slab_u=
nreclaimable:16kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB w=
riteback_tmp:0kB pages_scanned:0 all_unreclaimable? no
>[  426.737064] lowmem_reserve[]: 0 1856 1862 1862
>[  426.737078] Node 0 DMA32 free:757892kB min:66820kB low:83524kB high:100=
228kB active_anon:434632kB inactive_anon:148112kB active_file:127784kB inac=
tive_file:156924kB unevictable:32kB isolated(anon):0kB isolated(file):0kB p=
resent:1901408kB mlocked:32kB dirty:164808kB writeback:816kB mapped:36704kB=
 shmem:105648kB slab_reclaimable:33676kB slab_unreclaimable:108372kB kernel=
_stack:2304kB pagetables:21708kB unstable:0kB bounce:0kB writeback_tmp:0kB =
pages_scanned:160 all_unreclaimable? no
>[  426.737092] lowmem_reserve[]: 0 0 5 5
>[  426.737106] Node 0 Normal free:48kB min:212kB low:264kB high:316kB acti=
ve_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable=
:0kB isolated(anon):0kB isolated(file):0kB present:6060kB mlocked:0kB dirty=
:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:104kB slab_unrecla=
imable:1520kB kernel_stack:176kB pagetables:0kB unstable:0kB bounce:0kB wri=
teback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
>[  426.737119] lowmem_reserve[]: 0 0 0 0
>[  426.737132] Node 0 DMA: 3*4kB 2*8kB 1*16kB 1*32kB 2*64kB 2*128kB 2*256k=
B 2*512kB 2*1024kB 2*2048kB 0*4096kB =3D 8140kB
>[  426.737174] Node 0 DMA32: 945*4kB 585*8kB 6469*16kB 4871*32kB 3189*64kB=
 1338*128kB 228*256kB 58*512kB 24*1024kB 1*2048kB 0*4096kB =3D 757884kB
>[  426.737227] Node 0 Normal: 2*4kB 5*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*2=
56kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 48kB
>[  426.737257] 99595 total pagecache pages
>[  426.737260] 0 pages in swap cache
>[  426.737263] Swap cache stats: add 0, delete 0, find 0/0
>[  426.737266] Free swap  =3D 3768316kB
>[  426.737268] Total swap =3D 3768316kB
>[  426.744603] 525808 pages RAM
>[  426.744612] 57618 pages reserved
>[  426.744614] 141551 pages shared
>[  426.744617] 186065 pages non-shared
>[  472.301810] SysRq : Show Memory
>[  472.301826] Mem-Info:
>[  472.301829] Node 0 DMA per-cpu:
>[  472.301835] CPU    0: hi:    0, btch:   1 usd:   0
>[  472.301839] CPU    1: hi:    0, btch:   1 usd:   0
>[  472.301842] CPU    2: hi:    0, btch:   1 usd:   0
>[  472.301845] CPU    3: hi:    0, btch:   1 usd:   0
>[  472.301848] Node 0 DMA32 per-cpu:
>[  472.301854] CPU    0: hi:  186, btch:  31 usd: 184
>[  472.301857] CPU    1: hi:  186, btch:  31 usd:  46
>[  472.301860] CPU    2: hi:  186, btch:  31 usd: 158
>[  472.301863] CPU    3: hi:  186, btch:  31 usd: 163
>[  472.301866] Node 0 Normal per-cpu:
>[  472.301871] CPU    0: hi:    0, btch:   1 usd:   0
>[  472.301874] CPU    1: hi:    0, btch:   1 usd:   0
>[  472.301878] CPU    2: hi:    0, btch:   1 usd:   0
>[  472.301881] CPU    3: hi:    0, btch:   1 usd:   0
>[  472.301886] active_anon:107673 inactive_anon:37031 isolated_anon:0
>[  472.301887]  active_file:31533 inactive_file:33323 isolated_file:32
>[  472.301888]  unevictable:8 dirty:26256 writeback:6475 unstable:0
>[  472.301889]  free:198742 slab_reclaimable:9347 slab_unreclaimable:28647
>[  472.301889]  mapped:8307 shmem:26412 pagetables:5427 bounce:0
>[  472.301901] Node 0 DMA free:8140kB min:548kB low:684kB high:820kB activ=
e_anon:0kB inactive_anon:12kB active_file:240kB inactive_file:7280kB unevic=
table:0kB isolated(anon):0kB isolated(file):0kB present:15676kB mlocked:0kB=
 dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:180kB slab_u=
nreclaimable:16kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB w=
riteback_tmp:0kB pages_scanned:0 all_unreclaimable? no
>[  472.301915] lowmem_reserve[]: 0 1856 1862 1862
>[  472.301928] Node 0 DMA32 free:786780kB min:66820kB low:83524kB high:100=
228kB active_anon:430692kB inactive_anon:148112kB active_file:125892kB inac=
tive_file:126012kB unevictable:32kB isolated(anon):0kB isolated(file):128kB=
 present:1901408kB mlocked:32kB dirty:105024kB writeback:25900kB mapped:332=
28kB shmem:105648kB slab_reclaimable:37104kB slab_unreclaimable:113052kB ke=
rnel_stack:2288kB pagetables:21708kB unstable:0kB bounce:0kB writeback_tmp:=
0kB pages_scanned:3196 all_unreclaimable? no
>[  472.301943] lowmem_reserve[]: 0 0 5 5
>[  472.301956] Node 0 Normal free:48kB min:212kB low:264kB high:316kB acti=
ve_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable=
:0kB isolated(anon):0kB isolated(file):0kB present:6060kB mlocked:0kB dirty=
:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:104kB slab_unrecla=
imable:1520kB kernel_stack:176kB pagetables:0kB unstable:0kB bounce:0kB wri=
teback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
>[  472.301968] lowmem_reserve[]: 0 0 0 0
>[  472.301982] Node 0 DMA: 3*4kB 2*8kB 1*16kB 1*32kB 2*64kB 2*128kB 2*256k=
B 2*512kB 2*1024kB 2*2048kB 0*4096kB =3D 8140kB
>[  472.302015] Node 0 DMA32: 6121*4kB 1912*8kB 5094*16kB 4920*32kB 3168*64=
kB 1381*128kB 262*256kB 68*512kB 24*1024kB 1*2048kB 0*4096kB =3D 786756kB
>[  472.302048] Node 0 Normal: 2*4kB 5*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*2=
56kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 48kB
>[  472.302090] 91312 total pagecache pages
>[  472.302093] 0 pages in swap cache
>[  472.302096] Swap cache stats: add 0, delete 0, find 0/0
>[  472.302099] Free swap  =3D 3768316kB
>[  472.302102] Total swap =3D 3768316kB
>[  472.309521] 525808 pages RAM
>[  472.309529] 57618 pages reserved
>[  472.309548] 142496 pages shared
>[  472.309551] 177182 pages non-shared
>
>I'll finish off this verification, and then re-run with the watch-highorde=
r script running.
>
>James
Hi,

     I saw similar lockups while doing a heavy copy routine (basically
     copying an entire partition). I don't think this may be related to
     ext4, since the source and destination filesystems were btrfs and
     xfs.

     =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

   9 00:04:58 localhost kernel: [39824.230679] INFO: task kswapd0:528 block=
ed for more than 120 seconds.
  May  9 00:04:58 localhost kernel: [39824.230684] "echo 0 > /proc/sys/kern=
el/hung_task_timeout_secs" disables this message.
  May  9 00:04:58 localhost kernel: [39824.230690] kswapd0         D ffff88=
00bb90d740     0   528      2 0x00000000
  May  9 00:04:58 localhost kernel: [39824.230699]  ffff88013f6a3750 000000=
0000000046 0000000000000246 ffff88013b290040
  May  9 00:04:58 localhost kernel: [39824.230708]  ffff88013b290000 000000=
0000000001 ffff88013f6ea210 ffff88013f6a3fd8
  May  9 00:04:58 localhost kernel: [39824.230716]  ffff88013f6a3fd8 ffff88=
013f6a3fd8 0000000000000004 ffff88013f6ea470
  May  9 00:04:58 localhost kernel: [39824.230724] Call Trace:
  May  9 00:04:58 localhost kernel: [39824.230738]  [<ffffffff81548aa3>] io=
_schedule+0x73/0xc0
  May  9 00:04:58 localhost kernel: [39824.230747]  [<ffffffff813343bb>] ge=
t_request_wait+0xdb/0x1e0
  May  9 00:04:58 localhost kernel: [39824.230757]  [<ffffffff810608f0>] ? =
autoremove_wake_function+0x0/0x40
  May  9 00:05:22 localhost kernel: [39824.230766]  [<ffffffff81334cb6>] __=
make_request+0x76/0x560
  May  9 00:05:22 localhost kernel: [39824.230774]  [<ffffffff810e1518>] ? =
account_page_writeback+0x28/0x30
  May  9 00:05:22 localhost kernel: [39824.230782]  [<ffffffff81332bce>] ge=
neric_make_request+0x28e/0x560
  May  9 00:05:22 localhost kernel: [39824.230790]  [<ffffffff81332f25>] su=
bmit_bio+0x85/0x110
  May  9 00:05:22 localhost kernel: [39824.230797]  [<ffffffff811552b2>] ? =
bio_alloc_bioset+0xb2/0xf0
  May  9 00:05:22 localhost kernel: [39824.230806]  [<ffffffff8127da17>] xf=
s_submit_ioend_bio.isra.11+0x57/0x80
  May  9 00:05:22 localhost kernel: [39824.230816]  [<ffffffff8127dafb>] xf=
s_submit_ioend+0xbb/0x110
  May  9 00:05:22 localhost kernel: [39824.230818]  [<ffffffff8127ed47>] xf=
s_vm_writepage+0x3f7/0x540
  May  9 00:05:22 localhost kernel: [39824.230821]  [<ffffffff810e90b0>] sh=
rink_page_list+0x650/0x8f0
  May  9 00:05:22 localhost kernel: [39824.230823]  [<ffffffff810e9758>] sh=
rink_inactive_list+0x178/0x410
  May  9 00:05:22 localhost kernel: [39824.230826]  [<ffffffff8104e89a>] ? =
del_timer_sync+0x3a/0x60
  May  9 00:05:22 localhost kernel: [39824.230828]  [<ffffffff810e9e6e>] sh=
rink_zone+0x47e/0x540
  May  9 00:05:22 localhost kernel: [39824.230831]  [<ffffffff810e7a25>] ? =
shrink_slab+0x145/0x180
*May  9 00:05:22 localhost kernel: [39824.230833]  [<ffffffff810ea5bd>] ksw=
apd+0x68d/0xa20
*May  9 00:05:22 localhost kernel: [39824.230835]  [<ffffffff810e9f30>] ? k=
swapd+0x0/0xa20
  May  9 00:05:22 localhost kernel: [39824.230837]  [<ffffffff8105fffc>] kt=
hread+0x8c/0xa0
  May  9 00:05:22 localhost kernel: [39824.230841]  [<ffffffff81039a7c>] ? =
schedule_tail+0x4c/0xf0
  May  9 00:05:22 localhost kernel: [39824.230843]  [<ffffffff81003c94>] ke=
rnel_thread_helper+0x4/0x10
  May  9 00:05:22 localhost kernel: [39824.230846]  [<ffffffff8105ff70>] ? =
kthread+0x0/0xa0
  May  9 00:05:22 localhost kernel: [39824.230848]  [<ffffffff81003c90>] ? =
kernel_thread_helper+0x0/0x10
  May  9 00:05:22 localhost kernel: [39824.230853] INFO: task xfsbufd/sda9:=
3757 blocked for more than 120 seconds.
  May  9 00:05:22 localhost kernel: [39824.230854] "echo 0 > /proc/sys/kern=
el/hung_task_timeout_secs" disables this message.
  May  9 00:05:22 localhost kernel: [39824.230856] xfsbufd/sda9    D ffff88=
00bb84d740     0  3757      2 0x00000000
  May  9 00:05:22 localhost kernel: [39824.230858]  ffff88013b12fb10 000000=
0000000046 0000000000000246 ffff88013f6736c0
  May  9 00:05:22 localhost kernel: [39824.230861]  ffff88013f673680 000000=
0000000001 ffff88013cec2210 ffff88013b12ffd8
  May  9 00:05:22 localhost kernel: [39824.230863]  ffff88013b12ffd8 ffff88=
013b12ffd8 0000000000000001 ffff88013cec2470
  May  9 00:05:22 localhost kernel: [39824.230866] Call Trace:
  May  9 00:05:22 localhost kernel: [39824.230868]  [<ffffffff81548aa3>] io=
_schedule+0x73/0xc0
  May  9 00:05:22 localhost kernel: [39824.230870]  [<ffffffff813343bb>] ge=
t_request_wait+0xdb/0x1e0
  May  9 00:05:22 localhost kernel: [39824.230873]  [<ffffffff810608f0>] ? =
autoremove_wake_function+0x0/0x40
  May  9 00:05:22 localhost kernel: [39824.230875]  [<ffffffff81334cb6>] __=
make_request+0x76/0x560
  May  9 00:05:22 localhost kernel: [39824.230878]  [<ffffffff81037434>] ? =
resched_best_mask.isra.60+0x114/0x130
  May  9 00:05:22 localhost kernel: [39824.230880]  [<ffffffff81332bce>] ge=
neric_make_request+0x28e/0x560
  May  9 00:05:22 localhost kernel: [39824.230883]  [<ffffffff8103640c>] ? =
update_cpu_clock+0x19c/0x3d0
  May  9 00:05:22 localhost kernel: [39824.230885]  [<ffffffff81332f25>] su=
bmit_bio+0x85/0x110
  May  9 00:05:22 localhost kernel: [39824.230887]  [<ffffffff8115525a>] ? =
bio_alloc_bioset+0x5a/0xf0
  May  9 00:05:22 localhost kernel: [39824.230889]  [<ffffffff8128159c>] _x=
fs_buf_ioapply+0x19c/0x300
  May  9 00:05:22 localhost kernel: [39824.230892]  [<ffffffff812825cd>] ? =
xfs_bdstrat_cb+0x5d/0x100
  May  9 00:05:22 localhost kernel: [39824.230894]  [<ffffffff8128194e>] xf=
s_buf_iorequest+0x5e/0x140
  May  9 00:05:22 localhost kernel: [39824.230896]  [<ffffffff812825cd>] xf=
s_bdstrat_cb+0x5d/0x100
  May  9 00:05:22 localhost kernel: [39824.230899]  [<ffffffff81282776>] xf=
sbufd+0x106/0x180
  May  9 00:05:22 localhost kernel: [39824.230901]  [<ffffffff81282670>] ? =
xfsbufd+0x0/0x180
  May  9 00:05:22 localhost kernel: [39824.230903]  [<ffffffff8105fffc>] kt=
hread+0x8c/0xa0
  May  9 00:05:22 localhost kernel: [39824.230905]  [<ffffffff81039a7c>] ? =
schedule_tail+0x4c/0xf0
  May  9 00:05:22 localhost kernel: [39824.230907]  [<ffffffff81003c94>] ke=
rnel_thread_helper+0x4/0x10
  May  9 00:05:22 localhost kernel: [39824.230909]  [<ffffffff8105ff70>] ? =
kthread+0x0/0xa0
  May  9 00:05:22 localhost kernel: [39824.230911]  [<ffffffff81003c90>] ? =
kernel_thread_helper+0x0/0x10
  May  9 00:05:22 localhost kernel: [39824.230913] INFO: task xfsbufd/sda11=
:3769 blocked for more than 120 seconds.
  May  9 00:05:22 localhost kernel: [39824.230914] "echo 0 > /proc/sys/kern=
el/hung_task_timeout_secs" disables this message.
  May  9 00:05:22 localhost kernel: [39824.230915] xfsbufd/sda11   D ffff88=
00bb84d740     0  3769      2 0x00000000
  May  9 00:05:22 localhost kernel: [39824.230918]  ffff88013b183b10 000000=
0000000046 0000000000000246 ffff88013f6736c0
  May  9 00:05:22 localhost kernel: [39824.230920]  ffff88013f673680 000000=
0000000001 ffff88013b299b40 ffff88013b183fd8
  May  9 00:05:22 localhost kernel: [39824.230923]  ffff88013b183fd8 ffff88=
013b183fd8 0000000000000001 ffff88013b299da0
  May  9 00:05:22 localhost kernel: [39824.230925] Call Trace:
  May  9 00:05:22 localhost kernel: [39824.230928]  [<ffffffff81548aa3>] io=
_schedule+0x73/0xc0
  May  9 00:05:22 localhost kernel: [39824.230930]  [<ffffffff813343bb>] ge=
t_request_wait+0xdb/0x1e0
  May  9 00:05:22 localhost kernel: [39824.230932]  [<ffffffff810608f0>] ? =
autoremove_wake_function+0x0/0x40
  May  9 00:05:22 localhost kernel: [39824.230935]  [<ffffffff81334cb6>] __=
make_request+0x76/0x560
  May  9 00:05:22 localhost kernel: [39824.230938]  [<ffffffff8135d7af>] ? =
__sg_alloc_table+0x7f/0x140
  May  9 00:05:22 localhost kernel: [39824.230941]  [<ffffffff81332bce>] ge=
neric_make_request+0x28e/0x560
  May  9 00:05:22 localhost kernel: [39824.230943]  [<ffffffff8103640c>] ? =
update_cpu_clock+0x19c/0x3d0
  May  9 00:05:22 localhost kernel: [39824.230946]  [<ffffffff81431a60>] ? =
ata_scsi_rw_xlat+0x0/0x210
  May  9 00:05:22 localhost kernel: [39824.230948]  [<ffffffff81332f25>] su=
bmit_bio+0x85/0x110
  May  9 00:05:22 localhost kernel: [39824.230950]  [<ffffffff8115525a>] ? =
bio_alloc_bioset+0x5a/0xf0
  May  9 00:05:22 localhost kernel: [39824.230953]  [<ffffffff8128159c>] _x=
fs_buf_ioapply+0x19c/0x300
  May  9 00:05:22 localhost kernel: [39824.230955]  [<ffffffff812825cd>] ? =
xfs_bdstrat_cb+0x5d/0x100
  May  9 00:05:22 localhost kernel: [39824.230957]  [<ffffffff8128194e>] xf=
s_buf_iorequest+0x5e/0x140
  May  9 00:05:22 localhost kernel: [39824.230959]  [<ffffffff812825cd>] xf=
s_bdstrat_cb+0x5d/0x100
  May  9 00:05:22 localhost kernel: [39824.230962]  [<ffffffff81282776>] xf=
sbufd+0x106/0x180
  May  9 00:05:22 localhost kernel: [39824.230964]  [<ffffffff81282670>] ? =
xfsbufd+0x0/0x180
  May  9 00:05:22 localhost kernel: [39824.230966]  [<ffffffff8105fffc>] kt=
hread+0x8c/0xa0
  May  9 00:05:22 localhost kernel: [39824.230968]  [<ffffffff81039a7c>] ? =
schedule_tail+0x4c/0xf0
  May  9 00:05:22 localhost kernel: [39824.230970]  [<ffffffff81003c94>] ke=
rnel_thread_helper+0x4/0x10
  May  9 00:05:22 localhost kernel: [39824.230972]  [<ffffffff8105ff70>] ? =
kthread+0x0/0xa0
  May  9 00:05:22 localhost kernel: [39824.230974]  [<ffffffff81003c90>] ? =
kernel_thread_helper+0x0/0x10
  May  9 00:05:22 localhost kernel: [39824.230989] INFO: task logrotate:174=
9 blocked for more than 120 seconds.
  May  9 00:05:22 localhost kernel: [39824.230990] "echo 0 > /proc/sys/kern=
el/hung_task_timeout_secs" disables this message.
  May  9 00:05:22 localhost kernel: [39824.230992] logrotate       D ffff88=
00bb90d740     0  1749   1748 0x00000000
  May  9 00:05:22 localhost kernel: [39824.230994]  ffff88000c6f3788 000000=
0000000082 ffff88000c6f3738 ffff88013f475890
  May  9 00:05:22 localhost kernel: [39824.230997]  0000000000000001 000000=
0000000001 0000000000000001 ffff88000c6f3fd8
  May  9 00:05:22 localhost kernel: [39824.230999]  ffff88000c6f3fd8 ffff88=
000c6f3fd8 0000000000000004 ffff88013f475af0
  May  9 00:05:22 localhost kernel: [39824.231002] Call Trace:
  May  9 00:05:22 localhost kernel: [39824.231004]  [<ffffffff81548aa3>] io=
_schedule+0x73/0xc0
  May  9 00:05:22 localhost kernel: [39824.231006]  [<ffffffff813343bb>] ge=
t_request_wait+0xdb/0x1e0
  May  9 00:05:22 localhost kernel: [39824.231008]  [<ffffffff810608f0>] ? =
autoremove_wake_function+0x0/0x40
  May  9 00:05:22 localhost kernel: [39824.231011]  [<ffffffff81334cb6>] __=
make_request+0x76/0x560
  May  9 00:05:22 localhost kernel: [39824.231014]  [<ffffffff81150af4>] ? =
__getblk+0x24/0x280
  May  9 00:05:22 localhost kernel: [39824.231016]  [<ffffffff81332bce>] ge=
neric_make_request+0x28e/0x560
  May  9 00:05:22 localhost kernel: [39824.231020]  [<ffffffff811ae4fc>] ? =
ext4_mark_iloc_dirty+0x39c/0x5a0
  May  9 00:05:22 localhost kernel: [39824.231022]  [<ffffffff81332f25>] su=
bmit_bio+0x85/0x110
  May  9 00:05:22 localhost kernel: [39824.231024]  [<ffffffff8115525a>] ? =
bio_alloc_bioset+0x5a/0xf0
  May  9 00:05:22 localhost kernel: [39824.231027]  [<ffffffff8114f66b>] su=
bmit_bh+0xeb/0x120
  May  9 00:05:22 localhost kernel: [39824.231029]  [<ffffffff81151720>] __=
block_write_full_page+0x210/0x390
  May  9 00:05:22 localhost kernel: [39824.231031]  [<ffffffff810605de>] ? =
wake_up_bit+0x2e/0x40
  May  9 00:05:22 localhost kernel: [39824.231034]  [<ffffffff811518a0>] ? =
end_buffer_async_write+0x0/0x200
  May  9 00:05:22 localhost kernel: [39824.231036]  [<ffffffff811b00c0>] ? =
noalloc_get_block_write+0x0/0x30
  May  9 00:05:22 localhost kernel: [39824.231038]  [<ffffffff811518a0>] ? =
end_buffer_async_write+0x0/0x200
  May  9 00:05:22 localhost kernel: [39824.231041]  [<ffffffff81151f65>] bl=
ock_write_full_page_endio+0xf5/0x140
  May  9 00:05:22 localhost kernel: [39824.231043]  [<ffffffff811b00c0>] ? =
noalloc_get_block_write+0x0/0x30
  May  9 00:05:22 localhost kernel: [39824.231045]  [<ffffffff81151fc5>] bl=
ock_write_full_page+0x15/0x20
  May  9 00:05:22 localhost kernel: [39824.231048]  [<ffffffff811add81>] mp=
age_da_submit_io+0x451/0x510
  May  9 00:05:22 localhost kernel: [39824.231050]  [<ffffffff811ae4fc>] ? =
ext4_mark_iloc_dirty+0x39c/0x5a0
  May  9 00:05:22 localhost kernel: [39824.231053]  [<ffffffff811ae822>] ? =
ext4_mark_inode_dirty+0x82/0x230
  May  9 00:05:22 localhost kernel: [39824.231055]  [<ffffffff811b26a6>] mp=
age_da_map_and_submit+0x1d6/0x410
  May  9 00:05:22 localhost kernel: [39824.231059]  [<ffffffff811e8983>] ? =
jbd2_journal_start+0x13/0x20
  May  9 00:05:22 localhost kernel: [39824.231061]  [<ffffffff811b31b1>] ex=
t4_da_writepages+0x3e1/0x750
  May  9 00:05:22 localhost kernel: [39824.231064]  [<ffffffff810e2e91>] do=
_writepages+0x21/0x40
  May  9 00:05:22 localhost kernel: [39824.231066]  [<ffffffff810da00b>] __=
filemap_fdatawrite_range+0x5b/0x60
  May  9 00:05:22 localhost kernel: [39824.231068]  [<ffffffff810da74c>] fi=
lemap_flush+0x1c/0x20
  May  9 00:05:22 localhost kernel: [39824.231070]  [<ffffffff811acafc>] ex=
t4_alloc_da_blocks+0x4c/0xe0
  May  9 00:05:22 localhost kernel: [39824.231073]  [<ffffffff811a78e9>] ex=
t4_release_file+0x79/0xc0
  May  9 00:05:22 localhost kernel: [39824.231075]  [<ffffffff81124d7a>] fp=
ut+0xda/0x200
  May  9 00:05:22 localhost kernel: [39824.231077]  [<ffffffff811214e5>] fi=
lp_close+0x55/0x80
  May  9 00:05:22 localhost kernel: [39824.231079]  [<ffffffff811215c6>] sy=
s_close+0xb6/0x120
  May  9 00:05:22 localhost kernel: [39824.231082]  [<ffffffff81002eeb>] sy=
stem_call_fastpath+0x16/0x1b
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D

The mv was basically frozen though after sometime it resumed. I also notice=
d that levels of dirty data were really high (=3D~ 1G) which I presumed may=
 have caused this.

The kernel is=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
Linux Xye 2.6.39-rc6 #78 SMP PREEMPT Mon May 9 14:38:17 IST 2011 x86_64 Int=
el(R) Core(TM) i7 CPU Q 740 @ 1.73GHz GenuineIntel GNU/Linux
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
Also, I am not using cgroups or systemd at the moment. Also, this is not a =
Fedora system. (Arch linux).=20

This happened only once. After which it has been fine, though I have not do=
ne such high throughput copying after that.


---------------------
Raghavendra D Prabhu

--S1BNGpv0yoYahz37
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQEcBAEBAgAGBQJNyak5AAoJEKYW3KHXK+l3z3YIAKzsT7v/7ihemlLHd5okli0l
jNTBUtQQJa3Me3dWG6T0gdy3etK7zFBetcSKHcBCFMs6ZhJBYg0+GoJWICrAuNL5
RlyART6dSvOal4guvCI8IXbFy+Tcwoy4b/fU8uDF85kroUQBxYriBxlGljo+hG7r
Vm3G8hCRZxokhotNC+6ckasJ+N6nHzHlgJuISPfNu0fQNtW1KUsfbskzOUKGlPNS
TaQSMIJi88s/shwWvSghxQ7aSe11U332HgffsMoYZN5RGDioUKwmvVPGLDWRROyn
6U9+83UszUNoqoa8aw+hQFIzTgzF1UaOwLdDQl/9UcKzJJ3oJzpDWY6yHxwftgI=
=DYXX
-----END PGP SIGNATURE-----

--S1BNGpv0yoYahz37--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
