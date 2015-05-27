Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id 42BB36B007B
	for <linux-mm@kvack.org>; Tue, 26 May 2015 21:29:41 -0400 (EDT)
Received: by oihd6 with SMTP id d6so91734162oih.2
        for <linux-mm@kvack.org>; Tue, 26 May 2015 18:29:41 -0700 (PDT)
Received: from mail-oi0-f43.google.com (mail-oi0-f43.google.com. [209.85.218.43])
        by mx.google.com with ESMTPS id y11si9810558oep.41.2015.05.26.18.29.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 May 2015 18:29:40 -0700 (PDT)
Received: by oiww2 with SMTP id w2so91778073oiw.0
        for <linux-mm@kvack.org>; Tue, 26 May 2015 18:29:39 -0700 (PDT)
Date: Tue, 26 May 2015 21:29:29 -0400
From: Jeff Layton <jeff.layton@primarydata.com>
Subject: Re: swap: nfs: Sleeping function called from an rcu read section in
 nfs_swap_activate
Message-ID: <20150526212929.71b28344@synchrony.poochiereds.net>
In-Reply-To: <20150526095614.5b3d0e84@synchrony.poochiereds.net>
References: <5564732E.4090607@redhat.com>
	<20150526095614.5b3d0e84@synchrony.poochiereds.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/=.VGjj8jvUxtzFjGLNXJ=.b"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Jeff Layton <jlayton@primarydata.com>, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>

--Sig_/=.VGjj8jvUxtzFjGLNXJ=.b
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 26 May 2015 09:56:14 -0400
Jeff Layton <jeff.layton@primarydata.com> wrote:

> On Tue, 26 May 2015 15:20:46 +0200
> Jerome Marchand <jmarchan@redhat.com> wrote:
>=20
> >=20
> > Commit dad2b015 added an rcu read lock around the call to xs_swapper()
> > in nfs_activate()/deactivate(), which can sleep, thus raising a bug at
> > each swapon and swapoff over NFS.
> > I'm not sure if this is related or not, but swapoff also triggers the
> > WARN_ON(sk->sk_forward_alloc) in sk_clear_memalloc().
> >=20
> > [  243.668067] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > [  243.668665] [ INFO: suspicious RCU usage. ]
> > [  243.669293] 4.1.0-rc1-lock_stat-dbg-next-20150430+ #235 Not tainted
> > [  243.670301] -------------------------------
> > [  243.670905] include/linux/rcupdate.h:570 Illegal context switch in R=
CU read-side critical section!
> > [  243.672163]=20
> > other info that might help us debug this:
> >=20
> > [  243.673025]=20
> > rcu_scheduler_active =3D 1, debug_locks =3D 0
> > [  243.673565] 2 locks held by swapon/1176:
> > [  243.673893]  #0:  (&sb->s_type->i_mutex_key#17){+.+.+.}, at: [<fffff=
fff812385e0>] SyS_swapon+0x2b0/0x1000
> > [  243.674758]  #1:  (rcu_read_lock){......}, at: [<ffffffffa036fd75>] =
nfs_swap_activate+0x5/0x180 [nfs]
> > [  243.675591]=20
> > stack backtrace:
> > [  243.675957] CPU: 0 PID: 1176 Comm: swapon Not tainted 4.1.0-rc1-lock=
_stat-dbg-next-20150430+ #235
> > [  243.676687] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> > [  243.677179]  0000000000000000 00000000ef88d841 ffff88003327bcd8 ffff=
ffff818861f0
> > [  243.677854]  0000000000000000 ffff880078e38000 ffff88003327bd08 ffff=
ffff8110d237
> > [  243.678514]  0000000000000000 ffffffff81c650e4 0000000000000268 ffff=
880078e38000
> > [  243.679171] Call Trace:
> > [  243.679383]  [<ffffffff818861f0>] dump_stack+0x4c/0x65
> > [  243.679811]  [<ffffffff8110d237>] lockdep_rcu_suspicious+0xe7/0x120
> > [  243.680348]  [<ffffffff810df1bf>] ___might_sleep+0xaf/0x250
> > [  243.680815]  [<ffffffff810df3ad>] __might_sleep+0x4d/0x90
> > [  243.681279]  [<ffffffff8188bc17>] mutex_lock_nested+0x47/0x430
> > [  243.681762]  [<ffffffff811e409c>] static_key_slow_inc+0x7c/0xc0
> > [  243.682264]  [<ffffffff8171afa7>] sk_set_memalloc+0x27/0x30
> > [  243.682736]  [<ffffffffa012f824>] xs_swapper+0x54/0x60 [sunrpc]
> > [  243.683238]  [<ffffffffa036fe03>] nfs_swap_activate+0x93/0x180 [nfs]
> > [  243.683760]  [<ffffffffa036fd75>] ? nfs_swap_activate+0x5/0x180 [nfs]
> > [  243.684316]  [<ffffffff81238e04>] SyS_swapon+0xad4/0x1000
> > [  243.684766]  [<ffffffff818911b0>] ? syscall_return+0x16/0x59
> > [  243.685245]  [<ffffffff81890f6e>] system_call_fastpath+0x12/0x76
> > [  243.685743] BUG: sleeping function called from invalid context at ke=
rnel/locking/mutex.c:616
> > [  243.686439] in_atomic(): 1, irqs_disabled(): 0, pid: 1176, name: swa=
pon
> > [  243.687053] INFO: lockdep is turned off.
> > [  243.687429] CPU: 0 PID: 1176 Comm: swapon Not tainted 4.1.0-rc1-lock=
_stat-dbg-next-20150430+ #235
> > [  243.688313] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> > [  243.688845]  0000000000000000 00000000ef88d841 ffff88003327bd08 ffff=
ffff818861f0
> > [  243.689570]  0000000000000000 ffff880078e38000 ffff88003327bd38 ffff=
ffff810df29c
> > [  243.690353]  ffff880000000001 ffffffff81c650e4 0000000000000268 0000=
000000000000
> > [  243.691057] Call Trace:
> > [  243.691315]  [<ffffffff818861f0>] dump_stack+0x4c/0x65
> > [  243.691785]  [<ffffffff810df29c>] ___might_sleep+0x18c/0x250
> > [  243.692306]  [<ffffffff810df3ad>] __might_sleep+0x4d/0x90
> > [  243.692807]  [<ffffffff8188bc17>] mutex_lock_nested+0x47/0x430
> > [  243.693346]  [<ffffffff811e409c>] static_key_slow_inc+0x7c/0xc0
> > [  243.693887]  [<ffffffff8171afa7>] sk_set_memalloc+0x27/0x30
> > [  243.694416]  [<ffffffffa012f824>] xs_swapper+0x54/0x60 [sunrpc]
> > [  243.694959]  [<ffffffffa036fe03>] nfs_swap_activate+0x93/0x180 [nfs]
> > [  243.695535]  [<ffffffffa036fd75>] ? nfs_swap_activate+0x5/0x180 [nfs]
> > [  243.696193]  [<ffffffff81238e04>] SyS_swapon+0xad4/0x1000
> > [  243.696699]  [<ffffffff818911b0>] ? syscall_return+0x16/0x59
> > [  243.697299]  [<ffffffff81890f6e>] system_call_fastpath+0x12/0x76
> > [  243.702101] Adding 524284k swap on /mnt/swapfile512.  Priority:-2 ex=
tents:1 across:524284k FS
> > [  325.151350] BUG: sleeping function called from invalid context at ke=
rnel/locking/mutex.c:616
> > [  325.152688] in_atomic(): 1, irqs_disabled(): 0, pid: 1199, name: swa=
poff
> > [  325.153737] INFO: lockdep is turned off.
> > [  325.154457] CPU: 1 PID: 1199 Comm: swapoff Not tainted 4.1.0-rc1-loc=
k_stat-dbg-next-20150430+ #235
> > [  325.156204] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> > [  325.157120]  0000000000000000 00000000a7682b83 ffff88007ac3fce8 ffff=
ffff818861f0
> > [  325.158361]  0000000000000000 ffff880032434c00 ffff88007ac3fd18 ffff=
ffff810df29c
> > [  325.159592]  0000000000000000 ffffffff81c650e4 0000000000000268 0000=
000000000000
> > [  325.160798] Call Trace:
> > [  325.161251]  [<ffffffff818861f0>] dump_stack+0x4c/0x65
> > [  325.162071]  [<ffffffff810df29c>] ___might_sleep+0x18c/0x250
> > [  325.163073]  [<ffffffff810df3ad>] __might_sleep+0x4d/0x90
> > [  325.163934]  [<ffffffff8188bc17>] mutex_lock_nested+0x47/0x430
> > [  325.164927]  [<ffffffff8110a00f>] atomic_dec_and_mutex_lock+0x4f/0x70
> > [  325.166020]  [<ffffffff811e4107>] __static_key_slow_dec+0x27/0xc0
> > [  325.166942]  [<ffffffff811e41c6>] static_key_slow_dec+0x26/0x50
> > [  325.167955]  [<ffffffff8171db3f>] sk_clear_memalloc+0x2f/0x80
> > [  325.169075]  [<ffffffffa012f811>] xs_swapper+0x41/0x60 [sunrpc]
> > [  325.170241]  [<ffffffffa0370447>] nfs_swap_deactivate+0x87/0x170 [nf=
s]
> > [  325.171276]  [<ffffffffa03703c5>] ? nfs_swap_deactivate+0x5/0x170 [n=
fs]
> > [  325.172349]  [<ffffffff81237547>] destroy_swap_extents+0x77/0x90
> > [  325.173754]  [<ffffffff8123b225>] SyS_swapoff+0x215/0x600
> > [  325.174726]  [<ffffffff81434deb>] ? trace_hardirqs_on_thunk+0x17/0x19
> > [  325.175971]  [<ffffffff81890f6e>] system_call_fastpath+0x12/0x76
> > [  325.178052] ------------[ cut here ]------------
> > [  325.178892] WARNING: CPU: 1 PID: 1199 at net/core/sock.c:364 sk_clea=
r_memalloc+0x51/0x80()
> > [  325.180363] Modules linked in: rpcsec_gss_krb5 nfsv4 dns_resolver nf=
s fscache ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 xt_conntrack ebtable_nat=
 ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_nat nf_conn=
track_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_security ip6=
table_raw ip6table_filter ip6_tables iptable_nat nf_conntrack_ipv4 nf_defra=
g_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_security ipta=
ble_raw iosf_mbi crct10dif_pclmul crc32_pclmul crc32c_intel ppdev ghash_clm=
ulni_intel joydev nfsd parport_pc pcspkr virtio_console serio_raw virtio_ba=
lloon parport pvpanic i2c_piix4 acpi_cpufreq auth_rpcgss nfs_acl lockd grac=
e sunrpc virtio_blk qxl virtio_net drm_kms_helper ttm drm virtio_pci virtio=
_ring virtio ata_generic pata_acpi floppy
> > [  325.192279] CPU: 1 PID: 1199 Comm: swapoff Not tainted 4.1.0-rc1-loc=
k_stat-dbg-next-20150430+ #235
> > [  325.193605] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> > [  325.194491]  0000000000000000 00000000a7682b83 ffff88007ac3fdf8 ffff=
ffff818861f0
> > [  325.195692]  0000000000000000 0000000000000000 ffff88007ac3fe38 ffff=
ffff810af5ca
> > [  325.196891]  ffff88007ac3fe78 ffff88007b068000 ffff88007b484a00 ffff=
88007b484aa8
> > [  325.198119] Call Trace:
> > [  325.198555]  [<ffffffff818861f0>] dump_stack+0x4c/0x65
> > [  325.199380]  [<ffffffff810af5ca>] warn_slowpath_common+0x8a/0xc0
> > [  325.200601]  [<ffffffff810af6fa>] warn_slowpath_null+0x1a/0x20
> > [  325.201536]  [<ffffffff8171db61>] sk_clear_memalloc+0x51/0x80
> > [  325.202468]  [<ffffffffa012f811>] xs_swapper+0x41/0x60 [sunrpc]
> > [  325.203398]  [<ffffffffa0370447>] nfs_swap_deactivate+0x87/0x170 [nf=
s]
> > [  325.204426]  [<ffffffffa03703c5>] ? nfs_swap_deactivate+0x5/0x170 [n=
fs]
> > [  325.205456]  [<ffffffff81237547>] destroy_swap_extents+0x77/0x90
> > [  325.206406]  [<ffffffff8123b225>] SyS_swapoff+0x215/0x600
> > [  325.207287]  [<ffffffff81434deb>] ? trace_hardirqs_on_thunk+0x17/0x19
> > [  325.208300]  [<ffffffff81890f6e>] system_call_fastpath+0x12/0x76
> > [  325.209248] ---[ end trace 13f1014b56e5e711 ]---
> >=20
>=20
> Ok. What I think we need to do here is take a reference to the cl_xprt
> while holding the rcu_read_lock, and simply put it after we're done.
>=20
> That said...what happens if this xprt is switched out from under the
> clnt while we're swapping over it? It seems like
> rpc_switch_client_transport ought to be swap deactivating the old one
> and swap activating the new?
>=20
> Mel, any thoughts?=20
>=20

Ok, I had a look at this code and this looks a little suspicious to me:

------------------[snip]--------------------
int xs_swapper(struct rpc_xprt *xprt, int enable)
{
        struct sock_xprt *transport =3D container_of(xprt, struct sock_xprt,
                        xprt);
        int err =3D 0;

        if (enable) {
                xprt->swapper++;
                xs_set_memalloc(xprt);
        } else if (xprt->swapper) {
                xprt->swapper--;
                sk_clear_memalloc(transport->inet);
        }

        return err;
}
------------------[snip]--------------------

There are a number of problems here, I think...

1) this is not done under a lock, so the non-atomic ++/-- is racy if
there are multiple swapons/swapoffs running concurrently on the same
xprt. Shouldn't those use an atomic?

2) on enable, "swapper" is incremented and memalloc is set on the
socket. Do we need to do xs_set_memalloc every time swapon is called,
or only on a 0->1 swapper transition.

3) the !enable case also looks wrong. We decrement "swapper" and
then call sk_clear_memalloc, what if there are multiple swapfiles on
this xprt? Shouldn't that only be done when "swapper" goes to 0?

...and aside from that, there's no handling for rpc_clnt_set_transport.
When a rpc_clnt's xprt is replaced, we ought to ensure that the new one
is also set up for swapping. The "swapper" refcount is tied to the xprt
though, which is...tricky.

It's possible for the xprt to be associated with multiple clnts, each
of which might have different numbers of swapfiles. That information is
lost though since we're tracking the swapper count on a per-xprt basis.

I think we need to keep a refcount in the rpc_clnt too. The clnt's
swapper count would track the number of swapons/swapoffs, and the
xprt's refcount would keep track of clients that have active swapfiles.

Am I missing something in the above?
--=20
Jeff Layton <jlayton@primarydata.com>

--Sig_/=.VGjj8jvUxtzFjGLNXJ=.b
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVZR35AAoJEAAOaEEZVoIVTHgP/0+ZzJH9aVEqz+DjI27BLkIz
b/BLgAb11VwcyBAcBuu8PqFxXwehLJCNQQH6+LXkFoPzMkDPTEWoecCTo5bhDbx0
WfNf06x6LaonAok0Fs0cSF5ab6NNZf0n5eeHNuqODh3+yYctKTo034940tReZRRI
p/0A1erixuFrBooJqjWpdxSxtQed21gO2kqsPA4pRiUkoojwsiNEdwiPqeWM9sWd
3zsKxmh24Z21/M2IbKLPBu0qdRreJHMt2m1uSrzARFApaJjhUSEbOYZashkGjNmz
6A99CNcMkKMbvuqUiM1DI7ADy27ljVs2pFqPPHYqEZY+8teLYksx42rJcVF2Pm7+
UtGggM6r+H5+pDXUjMoOD2UieaSGU+Nv/ZUSch4LCdblHjpEQ24vcvOZhRI33CH6
C6kM9vHxWbT9RqlxIf1O4mF9GAs/qdY03/0DiM0HEr4ikGcioegDyERTVklanvIQ
+a5tErmIeRW+Y4Bzu06nt0vIErQHrasbvY77VoRQI8mJpyuM/jCWpltubcPYTV6Z
7lUrxNgtXN6QQmZCvIo56fyeje+ChcxtuEJd+/W2fFIftutVePW06NDAQDhVxf+G
7T6QP93z43T+mU7b3SE+6OeQrICHf5NPfOOYYmaDYqkBAm9OHjx36pWSdo7lj3M9
d23m3gDKFt1557lHYiI/
=wxwY
-----END PGP SIGNATURE-----

--Sig_/=.VGjj8jvUxtzFjGLNXJ=.b--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
