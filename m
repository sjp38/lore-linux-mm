Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 11BAE6B0103
	for <linux-mm@kvack.org>; Wed,  9 May 2012 10:10:41 -0400 (EDT)
Received: by vbbey12 with SMTP id ey12so485487vbb.14
        for <linux-mm@kvack.org>; Wed, 09 May 2012 07:10:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1205090846100.7720@router.home>
References: <201205080931539844949@gmail.com>
	<CAOtvUMctgcCrB_kCoKZki45_2i9XKzp-XLyfmNTxYwdFWSKYNQ@mail.gmail.com>
	<alpine.DEB.2.00.1205080909490.25669@router.home>
	<201205090918044843997@gmail.com>
	<alpine.DEB.2.00.1205090846100.7720@router.home>
Date: Wed, 9 May 2012 17:10:39 +0300
Message-ID: <CAOtvUMdJgkCzP_QuFhjXYzLqoNfBRkuRuDcW291gyQMhLXJ29g@mail.gmail.com>
Subject: Re: Re: [PATCH] slub: Using judgement !!c to judge per cpu has obj
 infucntion has_cpu_slab().
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: majianpeng <majianpeng@gmail.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>

On Wed, May 9, 2012 at 4:47 PM, Christoph Lameter <cl@linux.com> wrote:
> On Wed, 9 May 2012, majianpeng wrote:
>
>> Commit a8364d5555b2030d093cde0f0795 modified flush_all to only
>> send IPI to flush per-cpu cache pages to CPUs that seems to have done.
>
> Add some information as to why this happened to the changelog please. The
> commit did not include checks for per cpu partial pages being present on =
a
> cpu.

Feel free to use this for a commit message, majianeng:

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
