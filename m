Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id EB8A86B025E
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 01:46:51 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w84so32538692wmg.1
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 22:46:51 -0700 (PDT)
Received: from albireo.enyo.de (albireo.enyo.de. [5.158.152.32])
        by mx.google.com with ESMTPS id d128si9328028wmc.41.2016.09.20.22.46.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Sep 2016 22:46:50 -0700 (PDT)
Received: from [172.17.203.2] (helo=deneb.enyo.de)
	by albireo.enyo.de with esmtps (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
	id 1bmaMr-0007Ly-ND
	for linux-mm@kvack.org; Wed, 21 Sep 2016 07:46:49 +0200
Received: from fw by deneb.enyo.de with local (Exim 4.84_2)
	(envelope-from <fw@deneb.enyo.de>)
	id 1bmaMr-0002Tn-KF
	for linux-mm@kvack.org; Wed, 21 Sep 2016 07:46:49 +0200
From: Florian Weimer <fw@deneb.enyo.de>
Subject: Re: Excessive xfs_inode allocations trigger OOM killer
References: <87a8f2pd2d.fsf@mid.deneb.enyo.de> <20160920203039.GI340@dastard>
	<87mvj2mgsg.fsf@mid.deneb.enyo.de> <20160920214612.GJ340@dastard>
Date: Wed, 21 Sep 2016 07:45:20 +0200
In-Reply-To: <20160920214612.GJ340@dastard> (Dave Chinner's message of "Wed,
	21 Sep 2016 07:46:12 +1000")
Message-ID: <8737ktlsb3.fsf@mid.deneb.enyo.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: xfs@oss.sgi.com, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>

* Dave Chinner:

> [cc Michal, linux-mm@kvack.org]
>
> On Tue, Sep 20, 2016 at 10:56:31PM +0200, Florian Weimer wrote:
>> * Dave Chinner:
>>=20
>> >>   OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME=20
>> >> 4121208 4121177  99%    0.88K 1030302        4   4121208K xfs_inode
>> >> 986286 985229  99%    0.19K  46966       21    187864K dentry
>> >> 723255 723076  99%    0.10K  18545       39     74180K buffer_head
>> >> 270263 269251  99%    0.56K  38609        7    154436K radix_tree_node
>> >> 140310  67409  48%    0.38K  14031       10     56124K mnt_cache
>> >
>> > That's not odd at all. It means your workload is visiting millions
>> > on inodes in your filesystem between serious memory pressure events.
>>=20
>> Okay.
>>=20
>> >> (I have attached the /proc/meminfo contents in case it offers further
>> >> clues.)
>> >>=20
>> >> Confronted with large memory allocations (from =E2=80=9Cmake -j12=E2=
=80=9D and
>> >> compiling GCC, so perhaps ~8 GiB of memory), the OOM killer kicks in
>> >> and kills some random process.  I would have expected that some
>> >> xfs_inodes are freed instead.
>> >
>> > The oom killer is unreliable and often behaves very badly, and
>> > that's typicaly not an XFS problem.
>> >
>> > What is the full output off the oom killer invocations from dmesg?
>>=20
>> I've attached the dmesg output (two events).
>
> Copied from the traces you attached (I've left them intact below for
> reference):
>
>> [51669.515086] make invoked oom-killer: gfp_mask=3D0x27000c0(GFP_KERNEL_=
ACCOUNT|__GFP_NOTRACK), order=3D2, oom_score_adj=3D0
>> [51669.515092] CPU: 1 PID: 1202 Comm: make Tainted: G          I     4.7=
.1fw #1
>> [51669.515093] Hardware name: System manufacturer System Product Name/P6=
X58D-E, BIOS 0701    05/10/2011
>> [51669.515095]  0000000000000000 ffffffff812a7d39 0000000000000000 00000=
00000000000
>> [51669.515098]  ffffffff8114e4da ffff880018707d98 0000000000000000 00000=
0000066ca81
>> [51669.515100]  ffffffff8170e88d ffffffff810fe69e ffff88033fc38728 00000=
00200000006
>> [51669.515102] Call Trace:
>> [51669.515108]  [<ffffffff812a7d39>] ? dump_stack+0x46/0x5d
>> [51669.515113]  [<ffffffff8114e4da>] ? dump_header.isra.12+0x51/0x176
>> [51669.515116]  [<ffffffff810fe69e>] ? oom_kill_process+0x32e/0x420
>> [51669.515119]  [<ffffffff811003a0>] ? page_alloc_cpu_notify+0x40/0x40
>> [51669.515120]  [<ffffffff810fdcdc>] ? find_lock_task_mm+0x2c/0x70
>> [51669.515122]  [<ffffffff810fea6d>] ? out_of_memory+0x28d/0x2d0
>> [51669.515125]  [<ffffffff81103137>] ? __alloc_pages_nodemask+0xb97/0xc90
>> [51669.515128]  [<ffffffff81076d9c>] ? copy_process.part.54+0xec/0x17a0
>> [51669.515131]  [<ffffffff81123318>] ? handle_mm_fault+0xaa8/0x1900
>> [51669.515133]  [<ffffffff81078614>] ? _do_fork+0xd4/0x320
>> [51669.515137]  [<ffffffff81084ecc>] ? __set_current_blocked+0x2c/0x40
>> [51669.515140]  [<ffffffff810013ce>] ? do_syscall_64+0x3e/0x80
>> [51669.515144]  [<ffffffff8151433c>] ? entry_SYSCALL64_slow_path+0x25/0x=
25
> .....
>> [51669.515194] DMA: 1*4kB (U) 1*8kB (U) 1*16kB (U) 0*32kB 2*64kB (U) 1*1=
28kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) =3D 159=
00kB
>> [51669.515202] DMA32: 45619*4kB (UME) 73*8kB (UM) 0*16kB 0*32kB 0*64kB 0=
*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 183060kB
>> [51669.515209] Normal: 39979*4kB (UE) 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB=
 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 159916kB
> .....
>
> Alright, that's what I suspected. high order allocation for a new
> kernel stack and memory is so fragmented that a contiguous
> allocation fails. Really, this is a memory reclaim issue, not an XFS
> issue.  There is lots of reclaimable memory available, but memory
> reclaim is:
>
> 	a) not trying hard enough to reclaim reclaimable memory; and
> 	b) not waiting for memory compaction to rebuild contiguous
> 	   memory regions for high order allocations.
>
> Instead, it is declaring OOM and kicking the killer to free memory
> held busy userspace.

Thanks.

I have put the full kernel config here:

  <http://static.enyo.de/fw/volatile/config-4.7.1fw>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
