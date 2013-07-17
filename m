Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 83FE46B0032
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 06:04:44 -0400 (EDT)
From: Martin Steigerwald <Martin@lichtvoll.de>
Subject: zswap: How to determine whether it is compressing swap pages?
Date: Wed, 17 Jul 2013 12:04:38 +0200
Message-ID: <1674223.HVFdAhB7u5@merkaba>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="iso-8859-1"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Seth, hi everyone,

Yesterday I build 3.11-rc1 with CONFIG_ZSWAP and wanted to test it.

I added zswap.enabled=3D1 and get:

martin@merkaba:~> dmesg | grep zswap
[    0.000000] Command line: BOOT_IMAGE=3D/vmlinuz-3.11.0-rc1-tp520+=20=

root=3D/dev/mapper/merkaba-debian ro rootflags=3Dsubvol=3Droot init=3D/=
bin/systemd=20
cgroup_enable=3Dmemory threadirqs i915.i915_enable_rc6=3D7 zcache zswap=
.enabled=3D1
[    0.000000] Kernel command line: BOOT_IMAGE=3D/vmlinuz-3.11.0-rc1-tp=
520+=20
root=3D/dev/mapper/merkaba-debian ro rootflags=3Dsubvol=3Droot init=3D/=
bin/systemd=20
cgroup_enable=3Dmemory threadirqs i915.i915_enable_rc6=3D7 zcache zswap=
.enabled=3D1
[    1.452443] zswap: loading zswap
[    1.452465] zswap: using lzo compressor


I did a stress -m 1 --vm-keep --vm-bytes 4G on this 8 GB ThinkPad T520 =
in=20
order to allocate some swap.

Still I think zswap didn=B4t do anything:

merkaba:/sys/kernel/debug/zswap> grep . *
duplicate_entry:0
pool_limit_hit:0
pool_pages:0
reject_alloc_fail:0
reject_compress_poor:0
reject_kmemcache_fail:0
reject_reclaim_fail:0
stored_pages:0
written_back_pages:0


However:

merkaba:/sys/kernel/slab/zswap_entry> grep . *
aliases:9
align:8
grep: alloc_calls: Die angeforderte Funktion ist nicht implementiert
cache_dma:0
cpu_partial:0
cpu_slabs:4 N0=3D4
destroy_by_rcu:0
grep: free_calls: Die angeforderte Funktion ist nicht implementiert
hwcache_align:0
min_partial:5
objects:2550 N0=3D2550
object_size:48
objects_partial:0
objs_per_slab:85
order:0
partial:0
poison:0
reclaim_account:0
red_zone:0
remote_node_defrag_ratio:100
reserved:0
sanity_checks:0
slabs:30 N0=3D30
slabs_cpu_partial:0(0)
slab_size:48
store_user:0
total_objects:2550 N0=3D2550
trace:0

It has some objects it seems.


How do I know whether zswap actually does something?

Will zswap work even with zcache enabled? As I understand zcache compre=
sses=20
swap device pages on the block device level in addition to compressing =
read=20
cache pages of usual filesystems. Which one takes precedence, zcache or=
 zswap?=20
Can I disable zcache for swap device?



Here is dmesg for zcache:

martin@merkaba:~> dmesg | grep zcache
[    0.000000] Command line: BOOT_IMAGE=3D/vmlinuz-3.11.0-rc1-tp520+=20=

root=3D/dev/mapper/merkaba-debian ro rootflags=3Dsubvol=3Droot init=3D/=
bin/systemd=20
cgroup_enable=3Dmemory threadirqs i915.i915_enable_rc6=3D7 zcache zswap=
.enabled=3D1
[    0.000000] Kernel command line: BOOT_IMAGE=3D/vmlinuz-3.11.0-rc1-tp=
520+=20
root=3D/dev/mapper/merkaba-debian ro rootflags=3Dsubvol=3Droot init=3D/=
bin/systemd=20
cgroup_enable=3Dmemory threadirqs i915.i915_enable_rc6=3D7 zcache zswap=
.enabled=3D1
[    1.453531] zcache: using lzo compressor
[    1.453634] zcache: cleancache enabled using kernel transcendent mem=
ory and=20
compression buddies
[    1.453679] zcache: frontswap enabled using kernel transcendent memo=
ry and=20
compression buddies
[    1.453722] zcache: frontswap_ops overridden
[    5.358288] zcache: created ephemeral local tmem pool, id=3D0
[    8.155684] zcache: created persistent local tmem pool, id=3D1
[    8.331680] zcache: created ephemeral local tmem pool, id=3D2
[    8.593235] zcache: created ephemeral local tmem pool, id=3D3
[    8.743330] zcache: created ephemeral local tmem pool, id=3D4


Thanks,
--=20
Martin 'Helios' Steigerwald - http://www.Lichtvoll.de
GPG: 03B0 0D6C 0040 0710 4AFA  B82F 991B EAAC A599 84C7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
