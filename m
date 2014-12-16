Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 8286A6B0032
	for <linux-mm@kvack.org>; Mon, 15 Dec 2014 21:33:49 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id r10so10915065pdi.35
        for <linux-mm@kvack.org>; Mon, 15 Dec 2014 18:33:49 -0800 (PST)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id ln10si894874pbc.130.2014.12.15.18.33.45
        for <linux-mm@kvack.org>;
        Mon, 15 Dec 2014 18:33:47 -0800 (PST)
Date: Tue, 16 Dec 2014 11:38:00 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [LKP] [mm] INFO: rcu_sched detected stalls on CPUs/tasks: { 1}
 (detected by 0, t=10002 jiffies, g=945, c=944, q=0)
Message-ID: <20141216023800.GA23270@js1304-P5Q-DELUXE>
References: <1418284830.5745.72.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <1418284830.5745.72.camel@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Ying <ying.huang@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, LKML <linux-kernel@vger.kernel.org>, lkp@01.org, Marek Szyprowski <m.szyprowski@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

Ccing mm list.

On Thu, Dec 11, 2014 at 04:00:30PM +0800, Huang Ying wrote:
> FYI, we noticed the below changes on
>=20
> git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git master
> commit 6a7d22008b2294f1dacbc77632a26f2142f2d4b0 ("mm: Fix boot crash with=
 f7426b983a6a ("mm: cma: adjust address limit to avoid hitting low/high mem=
ory boundary")")
>=20
> The original boot failures are fixed, but there are some boot hang now.
> Sometimes because of OOM for trinity test.
>=20
> +----------------------+------------+------------+
> |                      | 12db936a10 | 6a7d22008b |
> +----------------------+------------+------------+
> | boot_successes       | 0          | 2          |
> | boot_failures        | 20         | 11         |
> | BUG:Int#:CR2(null)   | 20         |            |
> | BUG:kernel_boot_hang | 0          | 11         |
> +----------------------+------------+------------+
>=20
>=20
> [  400.841527] ??? Writer stall state 8 g945 c944 f0x0
> [  400.841532] rcu_sched: wait state: 2 ->state: 0x0
> [  400.841536] rcu_bh: wait state: 1 ->state: 0x1
> [  440.699265] INFO: rcu_sched detected stalls on CPUs/tasks: { 1} (detec=
ted by 0, t=3D10002 jiffies, g=3D945, c=3D944, q=3D0)
> [  440.699265] Task dump for CPU 1:
> [  440.699265] swapper/0       R running   6008     1      0 0x00000008
> [  440.699265]  00000050 d2145e4c cb4843c0 00000000 00000000 c8b08800 000=
0001e 00000005
> [  440.699265]  d2034c00 c1e70600 00000001 d2145e44 c15c9465 00000001 000=
00001 0000001e
> [  440.699265]  00000050 00000005 d2034c00 0000004f 00000000 d2145e54 c15=
c94a9 00000001
> [  440.699265] Call Trace:
> [  440.699265]  [<c15c9465>] ? scrup+0xb8/0xd3
> [  440.699265]  [<c15c94a9>] ? lf+0x29/0x61
> [  440.699265]  [<c15ca92f>] ? vt_console_print+0x1b2/0x2b6
> [  440.699265]  [<c15ca77d>] ? con_stop+0x25/0x25
> [  440.699265]  [<c107a4fa>] ? call_console_drivers+0x8c/0xbf
> [  440.699265]  [<c107b255>] ? console_unlock+0x2e2/0x393
> [  440.699265]  [<c107b729>] ? vprintk_emit+0x423/0x465
> [  440.699265]  [<c1d681a1>] ? printk+0x1c/0x1e
> [  440.699265]  [<c25dd311>] ? event_trace_self_tests+0x91/0x279
> [  440.699265]  [<c25dd616>] ? test_work+0x57/0x57
> [  440.699265]  [<c25dd616>] ? test_work+0x57/0x57
> [  440.699265]  [<c25dd627>] ? event_trace_self_tests_init+0x11/0x5b
> [  440.699265]  [<c25c4c7b>] ? do_one_initcall+0x15f/0x16e
> [  440.699265]  [<c25c44d5>] ? repair_env_string+0x12/0x54
> [  440.699265]  [<c105666f>] ? parse_args+0x1a6/0x286
> [  440.699265]  [<c25c4d86>] ? kernel_init_freeable+0xfc/0x179
> [  440.699265]  [<c1d664f6>] ? kernel_init+0xd/0xb8
> [  440.699265]  [<c1d87801>] ? ret_from_kernel_thread+0x21/0x30
> [  440.699265]  [<c1d664e9>] ? rest_init+0xaa/0xaa
> [  460.838635] rcu-torture: rtc: c2e29fc0 ver: 1 tfle: 0 rta: 1 rtaf: 0 r=
tf: 0 rtmbe: 0 rtbke: 0 rtbre: 0 rtbf: 0 rtb: 0 nt: 1 onoff: 0/0:0/0 -1,0:-=
1,0 0:0 (HZ=3D100) barrier: 0/0:0 cbflood: 1
> [  460.838654] rcu-torture: Reader Pipe:  2 0 0 0 0 0 0 0 0 0 0
> [  460.838664] rcu-torture: Reader Batch:  2 0 0 0 0 0 0 0 0 0 0
>=20
> Thanks,
> Huang, Ying
>=20
>=20
>=20
>=20

> _______________________________________________
> LKP mailing list
> LKP@linux.intel.com
> =0D

> early console in setup code
> early console in decompress_kernel
>=20
> Decompressing Linux... Parsing ELF... No relocation needed... done.
> Booting the kernel.
> [    0.000000] Initializing cgroup subsys cpu
> [    0.000000] Linux version 3.18.0-g6e20c9e (kbuild@roam) (gcc version 4=
=2E9.1 (Debian 4.9.1-19) ) #879 SMP Tue Dec 9 20:31:38 CST 2014
[Snip...]
> [ 1565.311928] irda_setsockopt: not allowed to set MAXSDUSIZE for this so=
cket type!
> [ 1573.296414] trinity-main invoked oom-killer: gfp_mask=3D0x2840d0, orde=
r=3D0, oom_score_adj=3D-1000
> [ 1573.296442] CPU: 0 PID: 3366 Comm: trinity-main Not tainted 3.18.0-g6e=
20c9e #879
> [ 1573.296443] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> [ 1573.296461]  00000000 00000000 c5735d0c c1d6d9a6 c8228370 c5735d54 c1d=
68686 c223656d
> [ 1573.296465]  c8228728 002840d0 00000000 fffffc18 c2447800 00000202 c57=
35d40 00000202
> [ 1573.296468]  c2447800 00000202 00000000 c149f5a4 002840d0 c8250670 000=
00000 c5735d78
> [ 1573.296473] Call Trace:
> [ 1573.296514]  [<c1d6d9a6>] dump_stack+0x48/0x60
> [ 1573.296517]  [<c1d68686>] dump_header+0x6b/0x1f9
> [ 1573.296534]  [<c149f5a4>] ? ___ratelimit+0xae/0xba
> [ 1573.296547]  [<c10d2969>] oom_kill_process+0x50/0x309
> [ 1573.296550]  [<c10d302d>] out_of_memory+0x27e/0x293
> [ 1573.296554]  [<c10d6734>] __alloc_pages_nodemask+0x70a/0x74f
> [ 1573.296560]  [<c1102164>] cache_alloc_refill+0x260/0x574
> [ 1573.296562]  [<c1101e4f>] kmem_cache_alloc+0xab/0x160
> [ 1573.296567]  [<c111a955>] ? __d_alloc+0x23/0x173
> [ 1573.296569]  [<c111a955>] __d_alloc+0x23/0x173
> [ 1573.296571]  [<c111aabd>] d_alloc+0x18/0x56
> [ 1573.296581]  [<c11522f3>] proc_fill_cache+0x48/0xb5
> [ 1573.296584]  [<c1154da3>] proc_readfd_common+0x1d7/0x22c
> [ 1573.296586]  [<c1154b65>] ? proc_fd_instantiate+0x79/0x79
> [ 1573.296588]  [<c1154b65>] ? proc_fd_instantiate+0x79/0x79
> [ 1573.296590]  [<c1154e1e>] proc_readfdinfo+0x12/0x14
> [ 1573.296592]  [<c111748e>] iterate_dir+0x88/0x10c
> [ 1573.296594]  [<c1117694>] SyS_getdents64+0x6e/0xb9
> [ 1573.296596]  [<c1117306>] ? filldir+0xef/0xef
> [ 1573.296602]  [<c1d87985>] syscall_call+0x7/0x7
> [ 1573.296605]  [<c1d80000>] ? stv090x_srate_srch_coarse+0x518/0x670
> [ 1573.296606] Mem-Info:
> [ 1573.296617] DMA per-cpu:
> [ 1573.296625] CPU    0: hi:    0, btch:   1 usd:   0
> [ 1573.296629] CPU    1: hi:    0, btch:   1 usd:   0
> [ 1573.296633] Normal per-cpu:
> [ 1573.296634] CPU    0: hi:   90, btch:  15 usd:  72
> [ 1573.296635] CPU    1: hi:   90, btch:  15 usd:  77
> [ 1573.296642] active_anon:3659 inactive_anon:209 isolated_anon:0
> [ 1573.296642]  active_file:0 inactive_file:0 isolated_file:0
> [ 1573.296642]  unevictable:4842 dirty:0 writeback:0 unstable:0
> [ 1573.296642]  free:4837 slab_reclaimable:46647 slab_unreclaimable:8914
> [ 1573.296642]  mapped:974 shmem:216 pagetables:83 bounce:0
> [ 1573.296642]  free_cma:4057
> [ 1573.296661] DMA free:1164kB min:116kB low:144kB high:172kB active_anon=
:888kB inactive_anon:84kB active_file:0kB inactive_file:0kB unevictable:16k=
B isolated(anon):0kB isolated(file):0kB present:15992kB managed:15916kB mlo=
cked:0kB dirty:0kB writeback:0kB mapped:80kB shmem:88kB slab_reclaimable:11=
404kB slab_unreclaimable:2076kB kernel_stack:24kB pagetables:32kB unstable:=
0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaim=
able? yes
> [ 1573.296666] lowmem_reserve[]: 0 262 262
> [ 1573.296673] Normal free:18184kB min:2012kB low:2512kB high:3016kB acti=
ve_anon:13748kB inactive_anon:752kB active_file:0kB inactive_file:0kB unevi=
ctable:19352kB isolated(anon):0kB isolated(file):0kB present:311288kB manag=
ed:269200kB mlocked:0kB dirty:0kB writeback:0kB mapped:3816kB shmem:776kB s=
lab_reclaimable:175184kB slab_unreclaimable:33580kB kernel_stack:760kB page=
tables:300kB unstable:0kB bounce:0kB free_cma:16228kB writeback_tmp:0kB pag=
es_scanned:0 all_unreclaimable? yes

I guess that this OOM isn't related to blamed patch.

It looks like shrink_slab() or SLAB allocator itself don't work well.
There are 175 MB reclaimable slab memory and no reclaimable file cache and
anonymous page.

Maybe some experts in this area have an insight of this problem.

Thanks.

> [ 1573.296674] lowmem_reserve[]: 0 0 0
> [ 1573.296697] DMA: 1*4kB (R) 0*8kB 1*16kB (R) 0*32kB 0*64kB 1*128kB (R) =
0*256kB 0*512kB 1*1024kB (R) 0*2048kB 0*4096kB =3D 1172kB
> [ 1573.296707] Normal: 41*4kB (C) 43*8kB (RC) 43*16kB (RC) 43*32kB (RC) 4=
2*64kB (C) 43*128kB (RC) 23*256kB (RC) 1*512kB (R) 1*1024kB (R) 0*2048kB 0*=
4096kB =3D 18188kB
> [ 1573.296708] 5058 total pagecache pages
> [ 1573.296721] 0 pages in swap cache
> [ 1573.296722] Swap cache stats: add 0, delete 0, find 0/0
> [ 1573.296723] Free swap  =3D 0kB
> [ 1573.296724] Total swap =3D 0kB
> [ 1573.296724] 81820 pages RAM
> [ 1573.296725] 0 pages HighMem/MovableOnly
> [ 1573.296726] 10541 pages reserved
> [ 1573.296727] [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom=
_score_adj name
> [ 1573.296970] [ 2839]     0  2839      577      367       4        0    =
     -1000 udevd
> [ 1573.297002] [ 3160]     0  3160      576      327       4        0    =
     -1000 udevd
> [ 1573.297018] [ 3161]     0  3161      576      327       4        0    =
     -1000 udevd
> [ 1573.297032] [ 3170]     0  3170      515       27       4        0    =
         0 bootlogd
> [ 1573.297042] [ 3339]     0  3339      717      546       5        0    =
         0 rc
> [ 1573.297053] [ 3346]     0  3346      707      497       5        0    =
     -1000 S99-rc.local
> [ 1573.297066] [ 3347]     0  3347      602      355       4        0    =
     -1000 run-parts
> [ 1573.297082] [ 3353]     0  3353      707      520       5        0    =
     -1000 90-trinity
> [ 1573.297096] [ 3358]     0  3358    14840     1582       7        0    =
     -1000 trinity
> [ 1573.297108] [ 3359]     0  3359    14840     1581       7        0    =
     -1000 trinity
> [ 1573.297120] [ 3362]     0  3362      569       79       4        0    =
     -1000 sleep
> [ 1573.297132] [ 3363]     0  3363    14840     1153       6        0    =
     -1000 trinity
> [ 1573.297141] [ 3364]     0  3364    15589     1993       7        0    =
     -1000 trinity-main
> [ 1573.297153] [ 3365]     0  3365    14840     1154       6        0    =
     -1000 trinity
> [ 1573.297158] [ 3366]     0  3366    15630     2000       7        0    =
     -1000 trinity-main
> [ 1573.297160] Out of memory: Kill process 3339 (rc) score 7 or sacrifice=
 child
> [ 1573.297169] Killed process 3339 (rc) total-vm:2868kB, anon-rss:184kB, =
file-rss:2000kB
> [ 1574.661678] trinity-main invoked oom-killer: gfp_mask=3D0x2840d0, orde=
r=3D0, oom_score_adj=3D-1000
> [ 1574.661695] CPU: 0 PID: 3364 Comm: trinity-main Not tainted 3.18.0-g6e=
20c9e #879
> [ 1574.661696] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> [ 1574.661706]  00000000 00000000 c82b5c4c c1d6d9a6 c83047d0 c82b5c94 c1d=
68686 c223656d
>=20
> Elapsed time: 1610
> qemu-system-i386 -enable-kvm -kernel /kernel/i386-randconfig-r2-1208/6e20=
c9e8345d5c805e9c444e528e7443d19d5e31/vmlinuz-3.18.0-g6e20c9e -append 'user=
=3Dlkp job=3D/lkp/scheduled/vm-kbuild-yocto-i386-36/rand_boot-1-yocto-minim=
al-i386.cgz-i386-randconfig-r2-1208-6e20c9e8345d5c805e9c444e528e7443d19d5e3=
1-1.yaml ARCH=3Di386 BOOT_IMAGE=3D/kernel/i386-randconfig-r2-1208/6e20c9e83=
45d5c805e9c444e528e7443d19d5e31/vmlinuz-3.18.0-g6e20c9e kconfig=3Di386-rand=
config-r2-1208 commit=3D6e20c9e8345d5c805e9c444e528e7443d19d5e31 branch=3Dt=
ip/master root=3D/dev/ram0 max_uptime=3D3600 RESULT_ROOT=3D/result/vm-kbuil=
d-yocto-i386/boot/1/yocto-minimal-i386.cgz/i386-randconfig-r2-1208/6e20c9e8=
345d5c805e9c444e528e7443d19d5e31/0 ip=3D::::vm-kbuild-yocto-i386-36::dhcp e=
arlyprintk=3DttyS0,115200 debug apic=3Ddebug sysrq_always_enabled rcupdate.=
rcu_cpu_stall_timeout=3D100 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3D=
panic oops=3Dpanic load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,1152=
00 console=3Dtty0 vga=3Dnormal rw drbd.minor_count=3D8'  -initrd /fs/sdg1/i=
nitrd-vm-kbuild-yocto-i386-36 -m 320 -smp 2 -net nic,vlan=3D1,model=3De1000=
 -net user,vlan=3D1 -boot order=3Dnc -no-reboot -watchdog i6300esb -rtc bas=
e=3Dlocaltime -drive file=3D/fs/sdg1/disk0-vm-kbuild-yocto-i386-36,media=3D=
disk,if=3Dvirtio -pidfile /dev/shm/kboot/pid-vm-kbuild-yocto-i386-36 -seria=
l file:/dev/shm/kboot/serial-vm-kbuild-yocto-i386-36 -daemonize -display no=
ne -monitor null=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
