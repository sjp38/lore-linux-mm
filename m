From: Jens Osterkamp <Jens.Osterkamp@gmx.de>
Subject: Re: [BUG] in 2.6.25-rc3 with 64k page size and SLUB_DEBUG_ON
Date: Fri, 7 Mar 2008 23:30:46 +0100
References: <200803061447.05797.Jens.Osterkamp@gmx.de> <200803071320.58439.Jens.Osterkamp@gmx.de> <Pine.LNX.4.64.0803071434240.9017@sbz-30.cs.Helsinki.FI>
In-Reply-To: <Pine.LNX.4.64.0803071434240.9017@sbz-30.cs.Helsinki.FI>
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2335005.dJJnT9Rtes";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Message-Id: <200803072330.46448.Jens.Osterkamp@gmx.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--nextPart2335005.dJJnT9Rtes
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

> But that's expected. It's the call-site of a kmalloc() or=20
> kmem_cache_alloc() call that stomps on the memory where the=20
> ->preempt_count of struct thread_info is. Is that anywhere near the=20
> dup_task_struct() call? I don't quite see how that could happen, however,=
=20
> alloc_thread_info() uses the page allocator to allocate memory for struct=
=20
> thread_info which is AFAICT 8 KB...

I compiled the kernel again with debug info and get the following info in t=
he BUG :

BUG: scheduling while atomic: kthreadd/2/0x00056f08
Call Trace:
[c00000007e107b68] [c00000000000f140] .show_stack+0x70/0x1bc (unreliable)
[c00000007e107c18] [c000000000052d1c] .__schedule_bug+0x64/0x80
[c00000007e107ca8] [c00000000036fae4] .schedule+0xc4/0x6b0
[c00000007e107d98] [c000000000370330] .schedule_timeout+0x3c/0xe8
[c00000007e107e68] [c00000000036f88c] .wait_for_common+0x150/0x22c
[c00000007e107f28] [c000000000074878] .kthreadd+0x12c/0x1f0
[c00000007e107fd8] [c000000000024864] .kernel_thread+0x4c/0x68
c00000007e104000
=2D-----------[ cut here ]------------
kernel BUG at /home/auto/jens/kernels/linux-2.6.25-rc3/kernel/sched.c:4533!
cpu 0x0: Vector: 700 (Program Check) at [c00000007e107bc8]
    pc: c000000000051f9c: .sched_setscheduler+0x6c/0x49c
    lr: c000000000051f90: .sched_setscheduler+0x60/0x49c
    sp: c00000007e107e48
   msr: 9000000000029032
  current =3D 0xc00000003c0f08a0
  paca    =3D 0xc0000000004cf880
    pid   =3D 2, comm =3D kthreadd
kernel BUG at /home/auto/jens/kernels/linux-2.6.25-rc3/kernel/sched.c:4533!
enter ? for help
[c00000007e107f28] c0000000000748c0 .kthreadd+0x174/0x1f0
[c00000007e107fd8] c000000000024864 .kernel_thread+0x4c/0x68

gdb shows

(gdb) l *0xc000000000056f08
0xc000000000056f08 is in copy_process (/home/auto/jens/kernels/linux-2.6.25=
=2Drc3/include/linux/slub_def.h:209).
204                             struct kmem_cache *s =3D kmalloc_slab(size);
205
206                             if (!s)
207                                     return ZERO_SIZE_PTR;
208
209                             return kmem_cache_alloc(s, flags);
210                     }
211             }
212             return __kmalloc(size, flags);
213     }

which is in the middle of kmalloc.

registers look as follows

0:mon> r
R00 =3D 0000000000056f00   R16 =3D 4000000001400000
R01 =3D c00000007e107e48   R17 =3D c0000000003e0ec0
R02 =3D c000000000583820   R18 =3D c0000000003df8e0
R03 =3D 0000000000000015   R19 =3D 0000000000000000
R04 =3D 0000000000000001   R20 =3D 0000000000000000
R05 =3D 0000000000000001   R21 =3D c0000000004f53a8
R06 =3D 0000000000000000   R22 =3D c00000007e107f98
R07 =3D 0000000000000001   R23 =3D c000000000494ca0
R08 =3D 0000000000000001   R24 =3D 0000000001894a30
R09 =3D 0000000000000000   R25 =3D 0000000000000060
R10 =3D c0000000005fdac4   R26 =3D c0000000005f41c0
R11 =3D c0000000005fdac0   R27 =3D 0000000000000000
R12 =3D 0000000000000002   R28 =3D c00000003c142b20
R13 =3D c0000000004cf880   R29 =3D c00000007e104000
R14 =3D 0000000000000000   R30 =3D c000000000533f10
R15 =3D 0000000000000000   R31 =3D 0000000000000003
pc  =3D c000000000051f9c .sched_setscheduler+0x6c/0x49c
lr  =3D c000000000051f90 .sched_setscheduler+0x60/0x49c
msr =3D 9000000000029032   cr  =3D 24000028
ctr =3D c0000000000268ac   xer =3D 0000000000000000   trap =3D  700

So stack pointer seems to be at c00000007e104000

Dumping in xmon

c00000007e104000 cccccccccccccccc c00000007e104048  |............~.@H|
				  ^^^
				  looks like a pointer to thread_info ?

c00000007e104010 c000000000056f08 0000000000000000  |......o.........|
                 ^^^
		  link register to jump back to copy_process ?!?

        prepare_to_copy(orig);

        tsk =3D alloc_task_struct();
c000000000056f00:       7f b6 eb 78     mr      r22,r29
c000000000056f04:       48 07 45 65     bl      c0000000000cb468 <.kmem_cac=
he_alloc>
c000000000056f08:       60 00 00 00     nop
        if (!tsk)
                return NULL;

        ti =3D alloc_thread_info(tsk);
        if (!ti) {
c000000000056f0c:       7c 7b 1b 79     mr.     r27,r3
c000000000056f10:       40 82 00 14     bne-    c000000000056f24 <.copy_pro=
cess+0x104>
                free_task_struct(tsk);

c00000007e104020 00000000fffedb3f 0000000000000000  |.......?........|
c00000007e104030 0000000000000000 0000000000000000  |................|

Then next in memory comes thread_info :

c00000007e104040 5a5a5a5a5a5a5a5a c00000003c1408a0  |ZZZZZZZZ....<...|
			   	  ^^^
				  pointer to task_struct

c00000007e104050 c0000000004ede10 0000000000000000  |.....N..........|
		 ^^^		  ^^^ cpu and preempt count
	         default_exec_domain

c00000007e104060 c00000000054e9a8 0000000000000000  |.....T..........|
	  	 ^^^
		  thread_info continued...

c00000007e104070 0000000000000000 0000000000000000  |................|
c00000007e104080 0000000000008000 0000000000000000  |................|

So everything looks shifted/misaligned by 48 bytes, but why ?

> It might we worth it to look at other obviously wrong preempt_counts to=20
> see if you can figure out a pattern of callers stomping on the memory.

How can I do that as I am quite early in boot ?

Gru=DF,
	Jens

--nextPart2335005.dJJnT9Rtes
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBH0cIWP1aZ9bkt7XMRAtbVAKDBhjeZbmoUOA5/+OYR1Uk8AfiJPgCfQgNT
fDxt8tLh02WHbT3ZOLg9y9Q=
=BvlN
-----END PGP SIGNATURE-----

--nextPart2335005.dJJnT9Rtes--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
