Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f181.google.com (mail-qk0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id 701276B0073
	for <linux-mm@kvack.org>; Tue, 26 May 2015 09:56:27 -0400 (EDT)
Received: by qkdn188 with SMTP id n188so89296814qkd.2
        for <linux-mm@kvack.org>; Tue, 26 May 2015 06:56:27 -0700 (PDT)
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com. [209.85.192.52])
        by mx.google.com with ESMTPS id 74si11723989qhq.106.2015.05.26.06.56.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 May 2015 06:56:26 -0700 (PDT)
Received: by qgg60 with SMTP id 60so10315080qgg.2
        for <linux-mm@kvack.org>; Tue, 26 May 2015 06:56:25 -0700 (PDT)
Date: Tue, 26 May 2015 09:56:14 -0400
From: Jeff Layton <jeff.layton@primarydata.com>
Subject: Re: swap: nfs: Sleeping function called from an rcu read section in
 nfs_swap_activate
Message-ID: <20150526095614.5b3d0e84@synchrony.poochiereds.net>
In-Reply-To: <5564732E.4090607@redhat.com>
References: <5564732E.4090607@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/FWG1iURMp0MKzwwv0luehxu"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Jeff Layton <jlayton@primarydata.com>, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>

--Sig_/FWG1iURMp0MKzwwv0luehxu
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 26 May 2015 15:20:46 +0200
Jerome Marchand <jmarchan@redhat.com> wrote:

>=20
> Commit dad2b015 added an rcu read lock around the call to xs_swapper()
> in nfs_activate()/deactivate(), which can sleep, thus raising a bug at
> each swapon and swapoff over NFS.
> I'm not sure if this is related or not, but swapoff also triggers the
> WARN_ON(sk->sk_forward_alloc) in sk_clear_memalloc().
>=20
> [  243.668067] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> [  243.668665] [ INFO: suspicious RCU usage. ]
> [  243.669293] 4.1.0-rc1-lock_stat-dbg-next-20150430+ #235 Not tainted
> [  243.670301] -------------------------------
> [  243.670905] include/linux/rcupdate.h:570 Illegal context switch in RCU=
 read-side critical section!
> [  243.672163]=20
> other info that might help us debug this:
>=20
> [  243.673025]=20
> rcu_scheduler_active =3D 1, debug_locks =3D 0
> [  243.673565] 2 locks held by swapon/1176:
> [  243.673893]  #0:  (&sb->s_type->i_mutex_key#17){+.+.+.}, at: [<fffffff=
f812385e0>] SyS_swapon+0x2b0/0x1000
> [  243.674758]  #1:  (rcu_read_lock){......}, at: [<ffffffffa036fd75>] nf=
s_swap_activate+0x5/0x180 [nfs]
> [  243.675591]=20
> stack backtrace:
> [  243.675957] CPU: 0 PID: 1176 Comm: swapon Not tainted 4.1.0-rc1-lock_s=
tat-dbg-next-20150430+ #235
> [  243.676687] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> [  243.677179]  0000000000000000 00000000ef88d841 ffff88003327bcd8 ffffff=
ff818861f0
> [  243.677854]  0000000000000000 ffff880078e38000 ffff88003327bd08 ffffff=
ff8110d237
> [  243.678514]  0000000000000000 ffffffff81c650e4 0000000000000268 ffff88=
0078e38000
> [  243.679171] Call Trace:
> [  243.679383]  [<ffffffff818861f0>] dump_stack+0x4c/0x65
> [  243.679811]  [<ffffffff8110d237>] lockdep_rcu_suspicious+0xe7/0x120
> [  243.680348]  [<ffffffff810df1bf>] ___might_sleep+0xaf/0x250
> [  243.680815]  [<ffffffff810df3ad>] __might_sleep+0x4d/0x90
> [  243.681279]  [<ffffffff8188bc17>] mutex_lock_nested+0x47/0x430
> [  243.681762]  [<ffffffff811e409c>] static_key_slow_inc+0x7c/0xc0
> [  243.682264]  [<ffffffff8171afa7>] sk_set_memalloc+0x27/0x30
> [  243.682736]  [<ffffffffa012f824>] xs_swapper+0x54/0x60 [sunrpc]
> [  243.683238]  [<ffffffffa036fe03>] nfs_swap_activate+0x93/0x180 [nfs]
> [  243.683760]  [<ffffffffa036fd75>] ? nfs_swap_activate+0x5/0x180 [nfs]
> [  243.684316]  [<ffffffff81238e04>] SyS_swapon+0xad4/0x1000
> [  243.684766]  [<ffffffff818911b0>] ? syscall_return+0x16/0x59
> [  243.685245]  [<ffffffff81890f6e>] system_call_fastpath+0x12/0x76
> [  243.685743] BUG: sleeping function called from invalid context at kern=
el/locking/mutex.c:616
> [  243.686439] in_atomic(): 1, irqs_disabled(): 0, pid: 1176, name: swapon
> [  243.687053] INFO: lockdep is turned off.
> [  243.687429] CPU: 0 PID: 1176 Comm: swapon Not tainted 4.1.0-rc1-lock_s=
tat-dbg-next-20150430+ #235
> [  243.688313] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> [  243.688845]  0000000000000000 00000000ef88d841 ffff88003327bd08 ffffff=
ff818861f0
> [  243.689570]  0000000000000000 ffff880078e38000 ffff88003327bd38 ffffff=
ff810df29c
> [  243.690353]  ffff880000000001 ffffffff81c650e4 0000000000000268 000000=
0000000000
> [  243.691057] Call Trace:
> [  243.691315]  [<ffffffff818861f0>] dump_stack+0x4c/0x65
> [  243.691785]  [<ffffffff810df29c>] ___might_sleep+0x18c/0x250
> [  243.692306]  [<ffffffff810df3ad>] __might_sleep+0x4d/0x90
> [  243.692807]  [<ffffffff8188bc17>] mutex_lock_nested+0x47/0x430
> [  243.693346]  [<ffffffff811e409c>] static_key_slow_inc+0x7c/0xc0
> [  243.693887]  [<ffffffff8171afa7>] sk_set_memalloc+0x27/0x30
> [  243.694416]  [<ffffffffa012f824>] xs_swapper+0x54/0x60 [sunrpc]
> [  243.694959]  [<ffffffffa036fe03>] nfs_swap_activate+0x93/0x180 [nfs]
> [  243.695535]  [<ffffffffa036fd75>] ? nfs_swap_activate+0x5/0x180 [nfs]
> [  243.696193]  [<ffffffff81238e04>] SyS_swapon+0xad4/0x1000
> [  243.696699]  [<ffffffff818911b0>] ? syscall_return+0x16/0x59
> [  243.697299]  [<ffffffff81890f6e>] system_call_fastpath+0x12/0x76
> [  243.702101] Adding 524284k swap on /mnt/swapfile512.  Priority:-2 exte=
nts:1 across:524284k FS
> [  325.151350] BUG: sleeping function called from invalid context at kern=
el/locking/mutex.c:616
> [  325.152688] in_atomic(): 1, irqs_disabled(): 0, pid: 1199, name: swapo=
ff
> [  325.153737] INFO: lockdep is turned off.
> [  325.154457] CPU: 1 PID: 1199 Comm: swapoff Not tainted 4.1.0-rc1-lock_=
stat-dbg-next-20150430+ #235
> [  325.156204] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> [  325.157120]  0000000000000000 00000000a7682b83 ffff88007ac3fce8 ffffff=
ff818861f0
> [  325.158361]  0000000000000000 ffff880032434c00 ffff88007ac3fd18 ffffff=
ff810df29c
> [  325.159592]  0000000000000000 ffffffff81c650e4 0000000000000268 000000=
0000000000
> [  325.160798] Call Trace:
> [  325.161251]  [<ffffffff818861f0>] dump_stack+0x4c/0x65
> [  325.162071]  [<ffffffff810df29c>] ___might_sleep+0x18c/0x250
> [  325.163073]  [<ffffffff810df3ad>] __might_sleep+0x4d/0x90
> [  325.163934]  [<ffffffff8188bc17>] mutex_lock_nested+0x47/0x430
> [  325.164927]  [<ffffffff8110a00f>] atomic_dec_and_mutex_lock+0x4f/0x70
> [  325.166020]  [<ffffffff811e4107>] __static_key_slow_dec+0x27/0xc0
> [  325.166942]  [<ffffffff811e41c6>] static_key_slow_dec+0x26/0x50
> [  325.167955]  [<ffffffff8171db3f>] sk_clear_memalloc+0x2f/0x80
> [  325.169075]  [<ffffffffa012f811>] xs_swapper+0x41/0x60 [sunrpc]
> [  325.170241]  [<ffffffffa0370447>] nfs_swap_deactivate+0x87/0x170 [nfs]
> [  325.171276]  [<ffffffffa03703c5>] ? nfs_swap_deactivate+0x5/0x170 [nfs]
> [  325.172349]  [<ffffffff81237547>] destroy_swap_extents+0x77/0x90
> [  325.173754]  [<ffffffff8123b225>] SyS_swapoff+0x215/0x600
> [  325.174726]  [<ffffffff81434deb>] ? trace_hardirqs_on_thunk+0x17/0x19
> [  325.175971]  [<ffffffff81890f6e>] system_call_fastpath+0x12/0x76
> [  325.178052] ------------[ cut here ]------------
> [  325.178892] WARNING: CPU: 1 PID: 1199 at net/core/sock.c:364 sk_clear_=
memalloc+0x51/0x80()
> [  325.180363] Modules linked in: rpcsec_gss_krb5 nfsv4 dns_resolver nfs =
fscache ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 xt_conntrack ebtable_nat e=
btable_broute bridge stp llc ebtable_filter ebtables ip6table_nat nf_conntr=
ack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_security ip6ta=
ble_raw ip6table_filter ip6_tables iptable_nat nf_conntrack_ipv4 nf_defrag_=
ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_security iptabl=
e_raw iosf_mbi crct10dif_pclmul crc32_pclmul crc32c_intel ppdev ghash_clmul=
ni_intel joydev nfsd parport_pc pcspkr virtio_console serio_raw virtio_ball=
oon parport pvpanic i2c_piix4 acpi_cpufreq auth_rpcgss nfs_acl lockd grace =
sunrpc virtio_blk qxl virtio_net drm_kms_helper ttm drm virtio_pci virtio_r=
ing virtio ata_generic pata_acpi floppy
> [  325.192279] CPU: 1 PID: 1199 Comm: swapoff Not tainted 4.1.0-rc1-lock_=
stat-dbg-next-20150430+ #235
> [  325.193605] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> [  325.194491]  0000000000000000 00000000a7682b83 ffff88007ac3fdf8 ffffff=
ff818861f0
> [  325.195692]  0000000000000000 0000000000000000 ffff88007ac3fe38 ffffff=
ff810af5ca
> [  325.196891]  ffff88007ac3fe78 ffff88007b068000 ffff88007b484a00 ffff88=
007b484aa8
> [  325.198119] Call Trace:
> [  325.198555]  [<ffffffff818861f0>] dump_stack+0x4c/0x65
> [  325.199380]  [<ffffffff810af5ca>] warn_slowpath_common+0x8a/0xc0
> [  325.200601]  [<ffffffff810af6fa>] warn_slowpath_null+0x1a/0x20
> [  325.201536]  [<ffffffff8171db61>] sk_clear_memalloc+0x51/0x80
> [  325.202468]  [<ffffffffa012f811>] xs_swapper+0x41/0x60 [sunrpc]
> [  325.203398]  [<ffffffffa0370447>] nfs_swap_deactivate+0x87/0x170 [nfs]
> [  325.204426]  [<ffffffffa03703c5>] ? nfs_swap_deactivate+0x5/0x170 [nfs]
> [  325.205456]  [<ffffffff81237547>] destroy_swap_extents+0x77/0x90
> [  325.206406]  [<ffffffff8123b225>] SyS_swapoff+0x215/0x600
> [  325.207287]  [<ffffffff81434deb>] ? trace_hardirqs_on_thunk+0x17/0x19
> [  325.208300]  [<ffffffff81890f6e>] system_call_fastpath+0x12/0x76
> [  325.209248] ---[ end trace 13f1014b56e5e711 ]---
>=20

Ok. What I think we need to do here is take a reference to the cl_xprt
while holding the rcu_read_lock, and simply put it after we're done.

That said...what happens if this xprt is switched out from under the
clnt while we're swapping over it? It seems like
rpc_switch_client_transport ought to be swap deactivating the old one
and swap activating the new?

Mel, any thoughts?=20

--=20
Jeff Layton <jeff.layton@primarydata.com>

--Sig_/FWG1iURMp0MKzwwv0luehxu
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVZHt/AAoJEAAOaEEZVoIVg/YP/iVt1M3c2KjdjBFAsXB5UIPj
xkRGUlCmQ2NuseTm34JgrFbe+Hx3atGMTx5du8R0CY0kKRFXC5zjpdardVX47i8N
/fxdh0Q6JONKduX0zzFEYuN8nGrhHZIRU14j+hRUG5MGcQ+z3Ge06GELuCVFO6Ps
en0pjI/sb6MjA7AX4ClyMbs947l+3xIJVwumKrZXomOc6ejyLx6pm+6PLfge84kW
sK3ftIozrxiZqMOMZ8jjQqbh+vjAkbqjEMEYWF0H8rUGD3/+7TojErGuRd8m0HWo
8inIe9wTmWXrCSypuCEMT4xweDTW07/MKy2GHS3DnT8J1+zFzY7sv2YXhioRPMM4
hLmQXckHwK+dOdMQy3FPVVlbYrjgH1Zww0gwYOG0pmSdEaiz532JdC5SiL64btbH
cZ8QeP/FzUpfegQLQmEU1f6UCq14gCUGMGb2lHWdaFcGgzKaAB3bNGDeSmde1l+v
xiIM37qxImc0L1YqQW36bvsqMhUbhc6TEcKZZhsAzQGUZVYWbGzW8w3TvomorK/u
QI73w7eT4IK0gmB1vM8Y9WVGKhdQDSXluj1j94cstbEJP22zPvSUo/UeirIWl1jn
SJ5rvuYOgdvhK2e96pb6wtO1pI4OavbabNOLHepCo97bazN42OKyrfpDQul+BtCH
Mq5e97xLJXtBQsWPD7VP
=D/zb
-----END PGP SIGNATURE-----

--Sig_/FWG1iURMp0MKzwwv0luehxu--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
