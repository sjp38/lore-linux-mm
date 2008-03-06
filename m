From: Jens Osterkamp <Jens.Osterkamp@gmx.de>
Subject: [BUG] in 2.6.25-rc3 with 64k page size and SLUB_DEBUG_ON
Date: Thu, 6 Mar 2008 14:47:02 +0100
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2092686.1eSSy6HgVW";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Message-Id: <200803061447.05797.Jens.Osterkamp@gmx.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--nextPart2092686.1eSSy6HgVW
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline


Hi,

when booting 2.6.25-rc3 on powerpc64 with SLUB_DEBUG_ON and 64k page size, =
it drops into xmon=20
during boot with the following :

Console: colour dummy device 80x25
Dentry cache hash table entries: 262144 (order: 5, 2097152 bytes)
Inode-cache hash table entries: 131072 (order: 4, 1048576 bytes)
freeing bootmem node 0
freeing bootmem node 1
Memory: 2037184k/2097152k available (4864k kernel code, 59968k reserved, 76=
8k data, 419k bss, 384k init)
SLUB: Genslabs=3D17, HWalign=3D128, Order=3D0-2, MinObjects=3D8, CPUs=3D4, =
Nodes=3D16
Mount-cache hash table entries: 4096
BUG: scheduling while atomic: kthreadd/2/0x00056ef8
Call Trace:
[c00000003c187b68] [c00000000000f140] .show_stack+0x70/0x1bc (unreliable)
[c00000003c187c18] [c000000000052d0c] .__schedule_bug+0x64/0x80
[c00000003c187ca8] [c00000000036fa84] .schedule+0xc4/0x6b0
[c00000003c187d98] [c0000000003702d0] .schedule_timeout+0x3c/0xe8
[c00000003c187e68] [c00000000036f82c] .wait_for_common+0x150/0x22c
[c00000003c187f28] [c000000000074868] .kthreadd+0x12c/0x1f0
[c00000003c187fd8] [c000000000024864] .kernel_thread+0x4c/0x68
=2D-----------[ cut here ]------------
kernel BUG at /home/auto/jens/kernels/linux-2.6.25-rc3/kernel/sched.c:4532!
cpu 0x0: Vector: 700 (Program Check) at [c00000003c187bc8]
    pc: c000000000051f8c: .sched_setscheduler+0x5c/0x48c
    lr: c0000000000748b0: .kthreadd+0x174/0x1f0
    sp: c00000003c187e48
   msr: 9000000000029032
  current =3D 0xc00000007e0808a0
  paca    =3D 0xc0000000004cf880
    pid   =3D 2, comm =3D kthreadd
kernel BUG at /home/auto/jens/kernels/linux-2.6.25-rc3/kernel/sched.c:4532!
enter ? for help
[c00000003c187f28] c0000000000748b0 .kthreadd+0x174/0x1f0
[c00000003c187fd8] c000000000024864 .kernel_thread+0x4c/0x68
0:mon>=20

In the code this corresponds to

int sched_setscheduler(struct task_struct *p, int policy,
                       struct sched_param *param)
{
        int retval, oldprio, oldpolicy =3D -1, on_rq, running;
        unsigned long flags;
        const struct sched_class *prev_class =3D p->sched_class;
        struct rq *rq;

        /* may grab non-irq protected spin_locks */
        BUG_ON(in_interrupt());
recheck:
        /* double check policy once rq lock held */
        if (policy < 0)
                policy =3D oldpolicy =3D p->policy;
        else if (policy !=3D SCHED_FIFO && policy !=3D SCHED_RR &&
                        policy !=3D SCHED_NORMAL && policy !=3D SCHED_BATCH=
 &&
                        policy !=3D SCHED_IDLE)
                return -EINVAL;

With slub_debug=3D- on the kernel command line, the problem is gone.
With 4k page size the problem also does not occur.

Any ideas on why this occurs and how to debug this further ?

Gru=DF,
	Jens

--nextPart2092686.1eSSy6HgVW
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHz/XZP1aZ9bkt7XMRAqkHAKDZDru57KLHovmr1ntM39fpqUkGKQCg7Y1p
1s4dZR4SnsATQP2b+A3QPWQ=
=wyzA
-----END PGP SIGNATURE-----

--nextPart2092686.1eSSy6HgVW--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
