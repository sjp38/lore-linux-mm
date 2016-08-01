Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 323EC6B0005
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 05:04:40 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id p129so77650586wmp.3
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 02:04:40 -0700 (PDT)
Received: from jowisz.mejor.pl (jowisz.mejor.pl. [2001:470:1f15:1b61::2])
        by mx.google.com with ESMTPS id fe8si30412301wjb.57.2016.08.01.02.04.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Aug 2016 02:04:34 -0700 (PDT)
From: =?UTF-8?Q?Marcin_Miros=c5=82aw?= <marcin@mejor.pl>
Subject: Choosing z3fold allocator in zswap gives WARNING: CPU: 0 PID: 5140 at
 mm/zswap.c:503 __zswap_pool_current+0x56/0x60
Message-ID: <2f8a65db-e5a8-75f0-8c08-daa41e1cd3ba@mejor.pl>
Date: Mon, 1 Aug 2016 11:03:50 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: vitaly.wool@konsulko.com

Hi!
I'm testing kernel-git
(git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git , at
07f00f06ba9a5533d6650d46d3e938f6cbeee97e ) because I noticed strange OOM
behavior in kernel 4.7.0. As for now I can't reproduce problems with
OOM, probably it's fixed now.
But now I wanted to try z3fold with zswap. When I did `echo z3fold >
/sys/module/zswap/parameters/zpool` I got trace from dmesg:

[  429.722411] ------------[ cut here ]------------
[  429.723476] WARNING: CPU: 0 PID: 5140 at mm/zswap.c:503
__zswap_pool_current+0x56/0x60
[  429.725161] Modules linked in: z3fold tun algif_skcipher af_alg
dm_crypt netconsole xt_policy ipt_REJECT nf_reject_ipv4 xt_TARPIT(OE)
xt_NFLOG ip_set_hash_ip ip_set_hash_net xt_SYSRQ(OE) xt_multiport
nfnetlink_queue sit ip_tunnel tunnel4 xt_set ip_set iptable_filter
xt_nat xt_comment xt_length iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4
nf_nat_ipv4 nf_nat iptable_mangle xt_CT iptable_raw ip_tables
nf_conntrack_ipv6 nf_defrag_ipv6 ip6t_rt xt_conntrack nf_conntrack
ip6table_filter ip6table_mangle ip6_tables ipv6 xfs libcrc32c btrfs xor
zlib_deflate raid6_pq tcp_diag inet_diag aesni_intel aes_x86_64
glue_helper lrw gf128mul ablk_helper cryptd button virtio_net
virtio_balloon crc32c_intel
[  429.738937] CPU: 0 PID: 5140 Comm: bash Tainted: G           OE
4.7.0+ #4
[  429.739880] Hardware name: Red Hat KVM, BIOS 0.5.1 01/01/2007
[  429.740048]  0000000000000286 000000002ea2eeca ffff8ecca91efcd8
ffffffffad255d43
[  429.740048]  0000000000000000 0000000000000000 ffff8ecca91efd18
ffffffffad04c997
[  429.740048]  000001f700000003 ffffffffad9b8a58 ffff8eccbd162b58
0000000000000000
[  429.740048] Call Trace:
[  429.740048]  [<ffffffffad255d43>] dump_stack+0x63/0x90
[  429.740048]  [<ffffffffad04c997>] __warn+0xc7/0xf0
[  429.740048]  [<ffffffffad04cac8>] warn_slowpath_null+0x18/0x20
[  429.740048]  [<ffffffffad1250c6>] __zswap_pool_current+0x56/0x60
[  429.740048]  [<ffffffffad1250e3>] zswap_pool_current+0x13/0x20
[  429.740048]  [<ffffffffad125efb>] __zswap_param_set+0x1db/0x2f0
[  429.740048]  [<ffffffffad126042>] zswap_zpool_param_set+0x12/0x20
[  429.740048]  [<ffffffffad06645f>] param_attr_store+0x5f/0xc0
[  429.740048]  [<ffffffffad065b69>] module_attr_store+0x19/0x30
[  429.740048]  [<ffffffffad1b0b02>] sysfs_kf_write+0x32/0x40
[  429.740048]  [<ffffffffad1b0663>] kernfs_fop_write+0x113/0x190
[  429.740048]  [<ffffffffad13fc52>] __vfs_write+0x32/0x150
[  429.740048]  [<ffffffffad15f0ae>] ? __fd_install+0x2e/0xe0
[  429.740048]  [<ffffffffad15ef11>] ? __alloc_fd+0x41/0x180
[  429.740048]  [<ffffffffad0838dd>] ? percpu_down_read+0xd/0x50
[  429.740048]  [<ffffffffad140d33>] vfs_write+0xb3/0x1a0
[  429.740048]  [<ffffffffad13db81>] ? filp_close+0x51/0x70
[  429.740048]  [<ffffffffad142140>] SyS_write+0x50/0xc0
[  429.740048]  [<ffffffffad413836>] entry_SYSCALL_64_fastpath+0x1e/0xa8
[  429.764069] ---[ end trace ff7835fbf4d983b9 ]---


Second issue:
Since 4.7.0 up to now I've got strange problem with starting BIND (dns).
It can't start, throws:
2016-08-01T10:42:21.449188+02:00 jowisz named[3730]: listening on IPv4
interface eth0, 81.4.122.249#53
2016-08-01T10:42:21.449412+02:00 jowisz named[3730]: could not listen on
UDP socket: out of memory
2016-08-01T10:42:21.449455+02:00 jowisz named[3730]: creating IPv4
interface eth0 failed; interface ignored
2016-08-01T10:42:21.449514+02:00 jowisz named[3730]: not listening on
any interfaces
2016-08-01T10:42:21.449670+02:00 jowisz named[3730]: generating session
key for dynamic DNS
2016-08-01T10:42:21.449910+02:00 jowisz named[3730]: sizing zone task
pool based on 69 zones
2016-08-01T10:42:21.450094+02:00 jowisz named[3730]: dns_master_load:
out of memory
2016-08-01T10:42:21.450668+02:00 jowisz named[3730]: could not configure
root hints from 'named.cache': out of memory
2016-08-01T10:42:21.451236+02:00 jowisz named[3730]: additionally
listening on IPv4 interface eth0, 81.4.122.249#53
2016-08-01T10:42:21.451298+02:00 jowisz named[3730]: could not listen on
UDP socket: out of memory
2016-08-01T10:42:21.451342+02:00 jowisz named[3730]: creating IPv4
interface eth0 failed; interface ignored
2016-08-01T10:42:21.451479+02:00 jowisz named[3730]: loading
configuration: out of memory
2016-08-01T10:42:21.451515+02:00 jowisz named[3730]: exiting (due to
fatal error)

strace shows:
[pid 26247] sendto(3, "<29>Aug  1 11:02:23 named[26230]"..., 80,
MSG_NOSIGNAL, NULL, 0) = 80
[pid 26247] mprotect(0x7f8828051000, 8192, PROT_READ|PROT_WRITE) = -1
ENOMEM (Cannot allocate memory)
[pid 26247] mmap(NULL, 134217728, PROT_NONE,
MAP_PRIVATE|MAP_ANONYMOUS|MAP_NORESERVE, -1, 0) = 0x7f8820000000
[pid 26247] munmap(0x7f8824000000, 67108864) = 0
[pid 26247] mprotect(0x7f8820000000, 143360, PROT_READ|PROT_WRITE) = -1
ENOMEM (Cannot allocate memory)
[pid 26247] munmap(0x7f8820000000, 67108864) = 0
[pid 26247] mmap(NULL, 12288, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = -1 ENOMEM (Cannot allocate memory)
[pid 26247] mprotect(0x7f8828051000, 8192, PROT_READ|PROT_WRITE) = -1
ENOMEM (Cannot allocate memory)
[pid 26247] mmap(0x7f8824000000, 67108864, PROT_NONE,
MAP_PRIVATE|MAP_ANONYMOUS|MAP_NORESERVE, -1, 0) = 0x7f8824000000
[pid 26247] mprotect(0x7f8824000000, 143360, PROT_READ|PROT_WRITE) = -1
ENOMEM (Cannot allocate memory)
[pid 26247] munmap(0x7f8824000000, 67108864) = 0


Thanks,
Marcin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
