Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 37B626B00E8
	for <linux-mm@kvack.org>; Wed, 16 May 2012 07:05:47 -0400 (EDT)
Date: Wed, 16 May 2012 07:05:16 -0400
From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] slub: missing test for partial pages flush work in
 flush_all
Message-ID: <20120516070516.406b2492@tlielax.poochiereds.net>
In-Reply-To: <CAOtvUMeVc+L4gHkvYVZ+T=K7T7r7EVfsyXdNCFF1NArA9uXyAg@mail.gmail.com>
References: <201205111008157652383@gmail.com>
	<alpine.DEB.2.00.1205111113460.31049@router.home>
	<CAOtvUMeVc+L4gHkvYVZ+T=K7T7r7EVfsyXdNCFF1NArA9uXyAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: Christoph Lameter <cl@linux.com>, majianpeng <majianpeng@gmail.com>, linux-mm <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Sun, 13 May 2012 09:53:15 +0300
Gilad Ben-Yossef <gilad@benyossef.com> wrote:

> On Fri, May 11, 2012 at 7:14 PM, Christoph Lameter <cl@linux.com> wrote:
> > Didn't I already ack this before?
> >
> > Acked-by: Christoph Lameter <cl@linux.com>
> >
>=20
> Yes, you did, but the patch description and title was lacking and
> Majianpeng kindly fixed it, hence the re-send, I guess.
>=20
> I've added Andrew, since he took my original commit that introduces
> the bug that this patch by Majianpeng  fixes (and also LKML).
>=20
> This fix really needs to get into 3.4, otherwise we'll be breaking
> slub. What's the best way to go about that?
>=20
> Thanks!
> Gilad
>=20
> > On Fri, 11 May 2012, majianpeng wrote:
> >
> >> Subject: [PATCH] slub: missing test for partial pages flush work in fl=
ush_all
> >>
> >> Find some kernel message like:
> >> SLUB raid5-md127: kmem_cache_destroy called for cache that still has o=
bjects.
> >> Pid: 6143, comm: mdadm Tainted: G =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 O=
 3.4.0-rc6+ =C2=A0 =C2=A0 =C2=A0 =C2=A0#75
> >> Call Trace:
> >> [<ffffffff811227f8>] kmem_cache_destroy+0x328/0x400
> >> [<ffffffffa005ff1d>] free_conf+0x2d/0xf0 [raid456]
> >> [<ffffffffa0060791>] stop+0x41/0x60 [raid456]
> >> [<ffffffffa000276a>] md_stop+0x1a/0x60 [md_mod]
> >> [<ffffffffa000c974>] do_md_stop+0x74/0x470 [md_mod]
> >> [<ffffffffa000d0ff>] md_ioctl+0xff/0x11f0 [md_mod]
> >> [<ffffffff8127c958>] blkdev_ioctl+0xd8/0x7a0
> >> [<ffffffff8115ef6b>] block_ioctl+0x3b/0x40
> >> [<ffffffff8113b9c6>] do_vfs_ioctl+0x96/0x560
> >> [<ffffffff8113bf21>] sys_ioctl+0x91/0xa0
> >> [<ffffffff816e9d22>] system_call_fastpath+0x16/0x1b
> >>
> >> Then using kmemleak can found those messages:
> >> unreferenced object 0xffff8800b6db7380 (size 112):
> >> =C2=A0 comm "mdadm", pid 5783, jiffies 4294810749 (age 90.589s)
> >> =C2=A0 hex dump (first 32 bytes):
> >> =C2=A0 =C2=A0 01 01 db b6 ad 4e ad de ff ff ff ff ff ff ff ff =C2=A0..=
...N..........
> >> =C2=A0 =C2=A0 ff ff ff ff ff ff ff ff 98 40 4a 82 ff ff ff ff =C2=A0..=
.......@J.....
> >> =C2=A0 backtrace:
> >> =C2=A0 =C2=A0 [<ffffffff816b52c1>] kmemleak_alloc+0x21/0x50
> >> =C2=A0 =C2=A0 [<ffffffff8111a11b>] kmem_cache_alloc+0xeb/0x1b0
> >> =C2=A0 =C2=A0 [<ffffffff8111c431>] kmem_cache_open+0x2f1/0x430
> >> =C2=A0 =C2=A0 [<ffffffff8111c6c8>] kmem_cache_create+0x158/0x320
> >> =C2=A0 =C2=A0 [<ffffffffa008f979>] setup_conf+0x649/0x770 [raid456]
> >> =C2=A0 =C2=A0 [<ffffffffa009044b>] run+0x68b/0x840 [raid456]
> >> =C2=A0 =C2=A0 [<ffffffffa000bde9>] md_run+0x529/0x940 [md_mod]
> >> =C2=A0 =C2=A0 [<ffffffffa000c218>] do_md_run+0x18/0xc0 [md_mod]
> >> =C2=A0 =C2=A0 [<ffffffffa000dba8>] md_ioctl+0xba8/0x11f0 [md_mod]
> >> =C2=A0 =C2=A0 [<ffffffff81272b28>] blkdev_ioctl+0xd8/0x7a0
> >> =C2=A0 =C2=A0 [<ffffffff81155bfb>] block_ioctl+0x3b/0x40
> >> =C2=A0 =C2=A0 [<ffffffff811326d6>] do_vfs_ioctl+0x96/0x560
> >> =C2=A0 =C2=A0 [<ffffffff81132c31>] sys_ioctl+0x91/0xa0
> >> =C2=A0 =C2=A0 [<ffffffff816dd3a2>] system_call_fastpath+0x16/0x1b
> >> =C2=A0 =C2=A0 [<ffffffffffffffff>] 0xffffffffffffffff
> >>
> >> This bug introduced by Commit a8364d5555b2030d093cde0f0795.The
> >> commit did not include checks for per cpu partial pages being present =
on a
> >> cpu.
> >>
> >> Signed-off-by: majianpeng <majianpeng@gmail.com>
> >> ---
> >> =C2=A0mm/slub.c | =C2=A0 =C2=A02 +-
> >> =C2=A01 files changed, 1 insertions(+), 1 deletions(-)
> >>
> >> diff --git a/mm/slub.c b/mm/slub.c
> >> index ffe13fd..6fce08f 100644
> >> --- a/mm/slub.c
> >> +++ b/mm/slub.c
> >> @@ -2040,7 +2040,7 @@ static bool has_cpu_slab(int cpu, void *info)
> >> =C2=A0 =C2=A0 =C2=A0 struct kmem_cache *s =3D info;
> >> =C2=A0 =C2=A0 =C2=A0 struct kmem_cache_cpu *c =3D per_cpu_ptr(s->cpu_s=
lab, cpu);
> >>
> >> - =C2=A0 =C2=A0 return !!(c->page);
> >> + =C2=A0 =C2=A0 return c->page || c->partial;
> >> =C2=A0}
> >>
> >> =C2=A0static void flush_all(struct kmem_cache *s)
> >>
>=20
>=20
>=20

FWIW, this patch fixed a similar warning that I was seeing on module
unload with cifs.ko. I agree it would be good to get it in for 3.4...

Tested-by: Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
