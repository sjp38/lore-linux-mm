Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 53E3C6B00F6
	for <linux-mm@kvack.org>; Tue,  8 May 2012 03:29:31 -0400 (EDT)
Received: by yhr47 with SMTP id 47so7187514yhr.14
        for <linux-mm@kvack.org>; Tue, 08 May 2012 00:29:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201205080931539844949@gmail.com>
References: <201205080931539844949@gmail.com>
Date: Tue, 8 May 2012 10:29:29 +0300
Message-ID: <CAOtvUMctgcCrB_kCoKZki45_2i9XKzp-XLyfmNTxYwdFWSKYNQ@mail.gmail.com>
Subject: Re: [PATCH] slub: Using judgement !!c to judge per cpu has obj in
 fucntion has_cpu_slab().
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: majianpeng <majianpeng@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

Hi Majianpeng,

On Tue, May 8, 2012 at 4:31 AM, majianpeng <majianpeng@gmail.com> wrote:
> At present, I found some kernel message like:
> LUB raid5-md127: kmem_cache_destroy called for cache that still has objec=
ts.
> Pid: 6143, comm: mdadm Tainted: G =A0 =A0 =A0 =A0 =A0 O 3.4.0-rc6+ =A0 =
=A0 =A0 =A0#75
> Call Trace:
> [<ffffffff811227f8>] kmem_cache_destroy+0x328/0x400
> [<ffffffffa005ff1d>] free_conf+0x2d/0xf0 [raid456]
> [<ffffffffa0060791>] stop+0x41/0x60 [raid456]
> [<ffffffffa000276a>] md_stop+0x1a/0x60 [md_mod]
> [<ffffffffa000c974>] do_md_stop+0x74/0x470 [md_mod]
> [<ffffffffa000d0ff>] md_ioctl+0xff/0x11f0 [md_mod]
> [<ffffffff8127c958>] blkdev_ioctl+0xd8/0x7a0
> [<ffffffff8115ef6b>] block_ioctl+0x3b/0x40
> [<ffffffff8113b9c6>] do_vfs_ioctl+0x96/0x560
> [<ffffffff8113bf21>] sys_ioctl+0x91/0xa0
> [<ffffffff816e9d22>] system_call_fastpath+0x16/0x1b
>
> Then using kmemleak can found those messages:
> unreferenced object 0xffff8800b6db7380 (size 112):
> =A0comm "mdadm", pid 5783, jiffies 4294810749 (age 90.589s)
> =A0hex dump (first 32 bytes):
> =A0 =A001 01 db b6 ad 4e ad de ff ff ff ff ff ff ff ff =A0.....N.........=
.
> =A0 =A0ff ff ff ff ff ff ff ff 98 40 4a 82 ff ff ff ff =A0.........@J....=
.
> =A0backtrace:
> =A0 =A0[<ffffffff816b52c1>] kmemleak_alloc+0x21/0x50
> =A0 =A0[<ffffffff8111a11b>] kmem_cache_alloc+0xeb/0x1b0
> =A0 =A0[<ffffffff8111c431>] kmem_cache_open+0x2f1/0x430
> =A0 =A0[<ffffffff8111c6c8>] kmem_cache_create+0x158/0x320
> =A0 =A0[<ffffffffa008f979>] setup_conf+0x649/0x770 [raid456]
> =A0 =A0[<ffffffffa009044b>] run+0x68b/0x840 [raid456]
> =A0 =A0[<ffffffffa000bde9>] md_run+0x529/0x940 [md_mod]
> =A0 =A0[<ffffffffa000c218>] do_md_run+0x18/0xc0 [md_mod]
> =A0 =A0[<ffffffffa000dba8>] md_ioctl+0xba8/0x11f0 [md_mod]
> =A0 =A0[<ffffffff81272b28>] blkdev_ioctl+0xd8/0x7a0
> =A0 =A0[<ffffffff81155bfb>] block_ioctl+0x3b/0x40
> =A0 =A0[<ffffffff811326d6>] do_vfs_ioctl+0x96/0x560
> =A0 =A0[<ffffffff81132c31>] sys_ioctl+0x91/0xa0
> =A0 =A0[<ffffffff816dd3a2>] system_call_fastpath+0x16/0x1b
> =A0 =A0[<ffffffffffffffff>] 0xffffffffffffffff
>
> Because kmemleak don't detect page leak, so the pages of slabs did not pr=
int.
>
> Commit a8364d5555b2030d093cde0f0795 modify the code of flush_all.
>

Many thanks for your report.

If I understand correctly, you are seeing the above error messages in
3.4-rcX but not in 3.3, right?

> Signed-off-by: majianpeng <majianpeng@gmail.com>
> ---
> =A0mm/slub.c | =A0 =A02 +-
> =A01 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/mm/slub.c b/mm/slub.c
> index ffe13fd..6fce08f 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2040,7 +2040,7 @@ static bool has_cpu_slab(int cpu, void *info)
> =A0 =A0 =A0 =A0struct kmem_cache *s =3D info;
> =A0 =A0 =A0 =A0struct kmem_cache_cpu *c =3D per_cpu_ptr(s->cpu_slab, cpu)=
;
>
> - =A0 =A0 =A0 return !!(c->page);
> + =A0 =A0 =A0 return !!c;
> =A0}
>
> =A0static void flush_all(struct kmem_cache *s)
> --
> 1.7.5.4

I also understand that the above patch makes the errors disappear, correct?

If so, then very good catch, but I believe the patch can be refined.
This is because
!!c here will always be true and in effect, you are returning the
situation to that
of the state of Linux 3.3, where an IPI was sent to flush to all CPUs,
whether they
have something to flush or not.

Having said that, your patch shows that we are too aggressive in not
sending the IPI,
sometime failing to send it when we should. I think the following
patch fixes the issue.
I boot tested on 8 way x86 VM and forcing a flush using
/sys/kernel/slab/XXX/validate
and nothing exploded. Can you please test it and validate that it
indeed solves the issue?

From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: slub: missing test for partial pages flush work in flush_all

Commit a8364d5555b2030d093cde0f0795 modified flush_all to only
send IPI to flush per-cpu cache pages to CPUs that seems to have done.

However, the test for flush work to be done on CPU was too relaxed, causing
an IPI not to be sent for CPUs with partial pages with the result of log sh=
owing
errors such as the following:

LUB raid5-md127: kmem_cache_destroy called for cache that still has objects=
.
Pid: 6143, comm: mdadm Tainted: G           O 3.4.0-rc6+        #75
Call Trace:
[<ffffffff811227f8>] kmem_cache_destroy+0x328/0x400
[<ffffffffa005ff1d>] free_conf+0x2d/0xf0 [raid456]
[<ffffffffa0060791>] stop+0x41/0x60 [raid456]
[<ffffffffa000276a>] md_stop+0x1a/0x60 [md_mod]
[<ffffffffa000c974>] do_md_stop+0x74/0x470 [md_mod]
[<ffffffffa000d0ff>] md_ioctl+0xff/0x11f0 [md_mod]
[<ffffffff8127c958>] blkdev_ioctl+0xd8/0x7a0
[<ffffffff8115ef6b>] block_ioctl+0x3b/0x40
[<ffffffff8113b9c6>] do_vfs_ioctl+0x96/0x560
[<ffffffff8113bf21>] sys_ioctl+0x91/0xa0
[<ffffffff816e9d22>] system_call_fastpath+0x16/0x1b

Fix this by testing for partial pages presence as well.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
Reported-by: majianpeng <majianpeng@gmail.com>
CC: "Andrew Morton" <akpm@linux-foundation.org>
CC: "Christoph Lameter" <cl@linux.com>
CC: "Pekka Enberg" <penberg@kernel.org>
---
diff --git a/mm/slub.c b/mm/slub.c
index ffe13fd..d66afc4 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2040,7 +2040,7 @@ static bool has_cpu_slab(int cpu, void *info)
 	struct kmem_cache *s =3D info;
 	struct kmem_cache_cpu *c =3D per_cpu_ptr(s->cpu_slab, cpu);

-	return !!(c->page);
+	return !!(c->page && c->partial);
 }

 static void flush_all(struct kmem_cache *s)



Many thanks!
Gilad


--=20
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"If you take a class in large-scale robotics, can you end up in a
situation where the homework eats your dog?"
=A0-- Jean-Baptiste Queru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
