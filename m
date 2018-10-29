Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2D2C36B04AA
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 17:48:17 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id j192-v6so3766169oih.11
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 14:48:17 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id y17si10007337otg.75.2018.10.29.14.48.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Oct 2018 14:48:16 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: Re: memcg oops:
 memcg_kmem_charge_memcg()->try_charge()->page_counter_try_charge()->BOOM
Date: Mon, 29 Oct 2018 21:47:58 +0000
Message-ID: <20181029214750.GA13325@tower.DHCP.thefacebook.com>
References: <1540792855.22373.34.camel@gmx.de>
 <20181029132035.GI32673@dhcp22.suse.cz> <1540830938.10478.4.camel@gmx.de>
 <20181029185412.GA15760@tower.DHCP.thefacebook.com>
 <20181029202634.GQ32673@dhcp22.suse.cz>
In-Reply-To: <20181029202634.GQ32673@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <D8A0BE3FDD0A9749992B0F819F80267B@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mike Galbraith <efault@gmx.de>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Mon, Oct 29, 2018 at 09:26:34PM +0100, Michal Hocko wrote:
> On Mon 29-10-18 18:54:19, Roman Gushchin wrote:
> > On Mon, Oct 29, 2018 at 05:35:38PM +0100, Mike Galbraith wrote:
> > > On Mon, 2018-10-29 at 14:20 +0100, Michal Hocko wrote:
> > > >=20
> > > > > [    4.420976] Code: f3 c3 0f 1f 00 0f 1f 44 00 00 48 85 ff 0f 84=
 a8 00 00 00 41 56 48 89 f8 41 55 49 89 fe 41 54 49 89 d5 55 49 89 f4 53 48=
 89 f3 <f0> 48 0f c1 1f 48 01 f3 48 39 5f 18 48 89 fd 73 17 eb 41 48 89 e8
> > > > > [    4.424162] RSP: 0018:ffffb27840c57cb0 EFLAGS: 00010202
> > > > > [    4.425236] RAX: 00000000000000f8 RBX: 0000000000000020 RCX: 0=
000000000000200
> > > > > [    4.426467] RDX: ffffb27840c57d08 RSI: 0000000000000020 RDI: 0=
0000000000000f8
> > > > > [    4.427652] RBP: 0000000000000001 R08: 0000000000000000 R09: f=
fffb278410bc000
> > > > > [    4.428883] R10: ffffb27840c57ed0 R11: 0000000000000040 R12: 0=
000000000000020
> > > > > [    4.430168] R13: ffffb27840c57d08 R14: 00000000000000f8 R15: 0=
0000000006000c0
> > > > > [    4.431411] FS:  00007f79081a3940(0000) GS:ffff92a4b7bc0000(00=
00) knlGS:0000000000000000
> > > > > [    4.432748] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > > > [    4.433836] CR2: 00000000000000f8 CR3: 00000002310ac002 CR4: 0=
0000000001606e0
> > > > > [    4.435500] Call Trace:
> > > > > [    4.436319]  try_charge+0x92/0x7b0
> > > > > [    4.437284]  ? unlazy_walk+0x4c/0xb0
> > > > > [    4.438676]  ? terminate_walk+0x91/0x100
> > > > > [    4.439984]  memcg_kmem_charge_memcg+0x28/0x80
> > > > > [    4.441059]  memcg_kmem_charge+0x88/0x1d0
> > > > > [    4.442105]  copy_process.part.37+0x23a/0x2070
> > > >=20
> > > > Could you faddr2line this please?
> > >=20
> > > homer:/usr/local/src/kernel/linux-master # ./scripts/faddr2line vmlin=
ux copy_process.part.37+0x23a
> > > copy_process.part.37+0x23a/0x2070:
> > > memcg_charge_kernel_stack at kernel/fork.c:401
> > > (inlined by) dup_task_struct at kernel/fork.c:850
> > > (inlined by) copy_process at kernel/fork.c:1750
> > >=20
> > > I bisected it this afternoon, and confirmed the result via revert.
> > >=20
> > > 9b6f7e163cd0f468d1b9696b785659d3c27c8667 is the first bad commit
> > > commit 9b6f7e163cd0f468d1b9696b785659d3c27c8667
> > > Author: Roman Gushchin <guro@fb.com>
> > > Date:   Fri Oct 26 15:03:19 2018 -0700
> > >=20
> > >     mm: rework memcg kernel stack accounting
> >=20
> >=20
> > Hi Mike!
> >=20
> > Thank you for the report!
> >=20
> > Do you see it reliable every time you boot up the machine?
> > How do you run kvm? Is there something special about your cgroup setup?
> >=20
> > I've made several attempts to reproduce the issue, but haven't got anyt=
hing
> > so far. I've used your config, and played with different cgroups setups=
.
> >=20
> > Do you know where in the page_counter_try_charge() it fails?
> >=20
> > Also, can you, please, check if the following patch mitigates the probl=
em?
>=20
> It's been a long day so I might be completely wrong but it seems that
> the task_struct is not initialized yet so tsk->mm is a complete garbage.
> I guess you want to move charging down after arch_dup_task_struct.

We take the memcg pointer from current, not from the new task.
So it's not the problem.
Anyway, I've found the problem, will send the fix in few minutes.

Thanks!
