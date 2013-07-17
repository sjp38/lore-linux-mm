Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 261196B0032
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 07:41:48 -0400 (EDT)
From: Martin Steigerwald <Martin@lichtvoll.de>
Subject: Re: zswap: How to determine whether it is compressing swap pages?
Date: Wed, 17 Jul 2013 13:41:44 +0200
Message-ID: <3337744.IgTT2hGPE5@merkaba>
In-Reply-To: <51E6750A.9060900@oracle.com>
References: <1674223.HVFdAhB7u5@merkaba> <51E6750A.9060900@oracle.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Am Mittwoch, 17. Juli 2013, 18:42:18 schrieb Bob Liu:
> On 07/17/2013 06:04 PM, Martin Steigerwald wrote:
> > Hi Seth, hi everyone,
> >
> > Yesterday I build 3.11-rc1 with CONFIG_ZSWAP and wanted to test it.=

> >
> > I added zswap.enabled=3D1 and get:
> >
> > martin@merkaba:~> dmesg | grep zswap
> > [    0.000000] Command line: BOOT_IMAGE=3D/vmlinuz-3.11.0-rc1-tp520=
+
> > root=3D/dev/mapper/merkaba-debian ro rootflags=3Dsubvol=3Droot init=
=3D/bin/systemd
> > cgroup_enable=3Dmemory threadirqs i915.i915_enable_rc6=3D7 zcache z=
swap.enabled=3D1
> > [    0.000000] Kernel command line: BOOT_IMAGE=3D/vmlinuz-3.11.0-rc=
1-tp520+
> > root=3D/dev/mapper/merkaba-debian ro rootflags=3Dsubvol=3Droot init=
=3D/bin/systemd
> > cgroup_enable=3Dmemory threadirqs i915.i915_enable_rc6=3D7 zcache z=
swap.enabled=3D1
> > [    1.452443] zswap: loading zswap
> > [    1.452465] zswap: using lzo compressor
> >
> >
> > I did a stress -m 1 --vm-keep --vm-bytes 4G on this 8 GB ThinkPad T=
520 in
> > order to allocate some swap.
> >
>=20
> Thank you for your testing.
> I'm glad to see there is new people interested with memory compressio=
n.
>=20
> > Still I think zswap didn=C2=B4t do anything:
> >
> > merkaba:/sys/kernel/debug/zswap> grep . *
> > duplicate_entry:0
> > pool_limit_hit:0
> > pool_pages:0
> > reject_alloc_fail:0
> > reject_compress_poor:0
> > reject_kmemcache_fail:0
> > reject_reclaim_fail:0
> > stored_pages:0
> > written_back_pages:0
> >
> >
> > However:
> >
> > merkaba:/sys/kernel/slab/zswap_entry> grep . *
> > aliases:9
> > align:8
> > grep: alloc_calls: Die angeforderte Funktion ist nicht implementier=
t
> > cache_dma:0
> > cpu_partial:0
> > cpu_slabs:4 N0=3D4
> > destroy_by_rcu:0
> > grep: free_calls: Die angeforderte Funktion ist nicht implementiert=

> > hwcache_align:0
> > min_partial:5
> > objects:2550 N0=3D2550
> > object_size:48
> > objects_partial:0
> > objs_per_slab:85
> > order:0
> > partial:0
> > poison:0
> > reclaim_account:0
> > red_zone:0
> > remote_node_defrag_ratio:100
> > reserved:0
> > sanity_checks:0
> > slabs:30 N0=3D30
> > slabs_cpu_partial:0(0)
> > slab_size:48
> > store_user:0
> > total_objects:2550 N0=3D2550
> > trace:0
> >
> > It has some objects it seems.
> >
> >
> > How do I know whether zswap actually does something?
> >
> > Will zswap work even with zcache enabled? As I understand zcache co=
mpresses
> > swap device pages on the block device level in addition to compress=
ing read
> > cache pages of usual filesystems. Which one takes precedence, zcach=
e or zswap?
> > Can I disable zcache for swap device?
> >
>=20
> Please disable zcache and try again.

Okay, this seemed to work.

Shortly after starting stress I got:

merkaba:/sys/kernel/debug/zswap> grep . *
duplicate_entry:0
pool_limit_hit:0
pool_pages:170892
reject_alloc_fail:0
reject_compress_poor:0
reject_kmemcache_fail:0
reject_reclaim_fail:0
stored_pages:341791
written_back_pages:0


then zcache reduced pool size again =E2=80=93 while stress was still ru=
nning:

merkaba:/sys/kernel/debug/zswap> grep . *
duplicate_entry:0
pool_limit_hit:0
pool_pages:38
reject_alloc_fail:0
reject_compress_poor:0
reject_kmemcache_fail:0
reject_reclaim_fail:0
stored_pages:66
written_back_pages:0


I assume that on heavy memory pressure zcache shrinks pool again in ode=
r
to free memory for other activities? Is that correct?

So zswap would help most on moderate, not heavy and bulky memory pressu=
re?


I was not able to reproduce above behavior even while watching with

merkaba:/sys/kernel/debug/zswap#130> while true; do date; grep . * ; sl=
eep 1 ; done


Zswap just doesn=C2=B4t seem to store packages on that workload anymore=
.

I will keep it running in regular workloads (two KDE sessions with Akon=
adi
and Nepomuk) and observe it a bit.


Is there any way to run zcache concurrently with zswap? I.e. use zcache=
 only
for read caches for filesystem and zswap for swap?

What is better suited for swap? zswap or zcache?

Thanks,
--=20
Martin 'Helios' Steigerwald - http://www.Lichtvoll.de
GPG: 03B0 0D6C 0040 0710 4AFA  B82F 991B EAAC A599 84C7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
