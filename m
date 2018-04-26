Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 300096B0008
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 16:29:22 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id o8-v6so26629669wra.12
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 13:29:22 -0700 (PDT)
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id c189si6676wmf.1.2018.04.26.13.29.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Apr 2018 13:29:20 -0700 (PDT)
Date: Thu, 26 Apr 2018 22:29:17 +0200
Message-ID: <20180426222917.Horde.cu42u5sTkcbGdcY0VUmclQ1@messagerie.si.c-s.fr>
From: LEROY Christophe <christophe.leroy@c-s.fr>
Subject: Re: OOM killer invoked while still one forth of mem is available
References: <df1a8c14-bda3-6271-d403-24b88a254b2c@c-s.fr>
 <alpine.DEB.2.21.1804251253240.151692@chino.kir.corp.google.com>
 <296ea83c-2c00-f1d2-3f62-d8ab8b8fb73c@c-s.fr>
 <20180426131154.GQ17484@dhcp22.suse.cz>
 <2706829f-6207-89f7-46e6-d32244305ccb@c-s.fr>
 <20180426190514.GU17484@dhcp22.suse.cz>
In-Reply-To: <20180426190514.GU17484@dhcp22.suse.cz>
Content-Type: text/plain; charset=UTF-8; format=flowed; DelSp=Yes
MIME-Version: 1.0
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Michal Hocko <mhocko@kernel.org> a =C3=A9crit=C2=A0:

> On Thu 26-04-18 15:28:46, Christophe LEROY wrote:
>>
>>
>> Le 26/04/2018 =C3=A0 15:11, Michal Hocko a =C3=A9crit=C2=A0:
>> > On Thu 26-04-18 08:10:30, Christophe LEROY wrote:
>> > >
>> > >
>> > > Le 25/04/2018 =C3=A0 21:57, David Rientjes a =C3=A9crit=C2=A0:
>> > > > On Tue, 24 Apr 2018, christophe leroy wrote:
>> > > >
>> > > > > Hi
>> > > > >
>> > > > > Allthough there is still about one forth of memory available (79=
76kB
>> > > > > among 32MB), oom-killer is invoked and makes a victim.
>> > > > >
>> > > > > What could be the reason and how could it be solved ?
>> > > > >
>> > > > > [   54.400754] S99watchdogd-ap invoked oom-killer:
>> > > > > gfp_mask=3D0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), nodemask=
=3D0,
>> > > > > order=3D1, oom_score_adj=3D0
>> > > > > [   54.400815] CPU: 0 PID: 777 Comm: S99watchdogd-ap Not tainted
>> > > > > 4.9.85-local-knld-998 #5
>> > > > > [   54.400830] Call Trace:
>> > > > > [   54.400910] [c1ca5d10] [c0327d28] dump_header.isra.4+0x54/0x1=
7c
>> > > > > (unreliable)
>> > > > > [   54.400998] [c1ca5d50] [c0079d88] oom_kill_process+0xc4/0x414
>> > > > > [   54.401067] [c1ca5d90] [c007a5c8] out_of_memory+0x35c/0x37c
>> > > > > [   54.401220] [c1ca5dc0] [c007d68c]=20=20
>>=20__alloc_pages_nodemask+0x8ec/0x9a8
>> > > > > [   54.401318] [c1ca5e70] [c00169d4]=20=20
>>=20copy_process.isra.9.part.10+0xdc/0x10d0
>> > > > > [   54.401398] [c1ca5f00] [c0017b30] _do_fork+0xcc/0x2a8
>> > > > > [   54.401473] [c1ca5f40] [c000a660] ret_from_syscall+0x0/0x38
>> > > >
>> > > > Looks like this is because the allocation is order-1, likely the
>> > > > allocation of a struct task_struct for a new process on fork.
>> > >
>> > > I'm not sure I understand what you mean. The allocation is order 1, =
yes,
>> > > does it explains why OOM killer is invoked ?
>> >
>> > Well, not really
>> > [   54.437414] DMA: 460*4kB (UH) 201*8kB (UH) 121*16kB (UH)=20=20
>>=2043*32kB (UH) 10*64kB (U) 4*128kB (UH) 0*256kB 0*512kB 0*1024kB=20=20
>>=200*2048kB 0*4096kB 0*8192kB =3D 7912kB`
>> >
>> > You should have enough order-1+ pages to proceed.
>> >
>>
>> So, order is 1 so order - 1 is 0,
>
> Not sure what you mean by order - 1, maybe I've confused you. order-1
> means that the order is 1. So free is not all that important. What you
> should look at though is how many order 1+ free blocks are available.

Oh, ok, i thought you were saying order minus one.
So we need an order one, ie a 8k block.

>
>> what's wrong then ? Do the (UH) and (U)
>> means anything special ?
>
> Yes, show_migration_types. But I do not see why unmovable pageblocks
> should block the allocation. This is a GFP_KERNEL allocation request
> essentially - thus unmovable itself. This smells like a bug. We are way
> above reserves which could block the allocation.

Any suggestion on how to investigate that bug ? Anything to trace ?

Christophe
>
>> Otherwise, just above it says 'free:1994', so with
>> 1994 pages free I should have enough to proceed, shouldn't I ?
>
> Not for high order pages as per above...
>
> --
> Michal Hocko
> SUSE Labs
