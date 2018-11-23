Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 595926B2D6B
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 07:52:22 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id s50so5701131edd.11
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 04:52:22 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y47si859600edb.330.2018.11.23.04.52.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 04:52:20 -0800 (PST)
Date: Fri, 23 Nov 2018 13:52:19 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH 3/3] lockdep: Use line-buffered printk() for lockdep
 messages.
Message-ID: <20181123125219.k5flkypofll7jwtr@pathway.suse.cz>
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1541165517-3557-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20181107151900.gxmdvx42qeanpoah@pathway.suse.cz>
 <20181108044510.GC2343@jagdpanzerIV>
 <9648a384-853c-942e-6a8d-80432d943aae@i-love.sakura.ne.jp>
 <20181109061204.GC599@jagdpanzerIV>
 <07dcbcb8-c5a7-8188-b641-c110ade1c5da@i-love.sakura.ne.jp>
 <20181109154326.apqkbsojmbg26o3b@pathway.suse.cz>
 <2d0d1f60-d8b6-41e0-6845-0eb62f211e40@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <2d0d1f60-d8b6-41e0-6845-0eb62f211e40@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

On Sat 2018-11-10 17:52:17, Tetsuo Handa wrote:
> On 2018/11/10 0:43, Petr Mladek wrote:
> > On Fri 2018-11-09 18:55:26, Tetsuo Handa wrote:
> >> How early_printk requirement affects line buffered printk() API?
> >>
> >> I don't think it is impossible to convert from
> >>
> >>      printk("Testing feature XYZ..");
> >>      this_may_blow_up_because_of_hw_bugs();
> >>      printk(KERN_CONT " ... ok\n");
> >>
> >> to
> >>
> >>      printk("Testing feature XYZ:\n");
> >>      this_may_blow_up_because_of_hw_bugs();
> >>      printk("Testing feature XYZ.. ... ok\n");
> >>
> >> in https://lore.kernel.org/lkml/CA+55aFwmwdY_mMqdEyFPpRhCKRyeqj=3D+aCq=
e5nN108v8ELFvPw@mail.gmail.com/ .
> >=20
> > I just wonder how this pattern is common. I have tried but I failed
> > to find any instance.
> >=20
> > This problem looks like a big argument against explicit buffers.
> > But I wonder if it is real.
>=20
> An example of boot up messages where buffering makes difference.
>=20
> Vanilla:
>=20
> [    0.260459] smp: Bringing up secondary CPUs ...
> [    0.269595] x86: Booting SMP configuration:
> [    0.270461] .... node  #0, CPUs:      #1
> [    0.066578] Disabled fast string operations
> [    0.066578] mce: CPU supports 0 MCE banks
> [    0.066578] smpboot: CPU 1 Converting physical 2 to logical package 1
> [    0.342569]  #2
> [    0.066578] Disabled fast string operations
> [    0.066578] mce: CPU supports 0 MCE banks
> [    0.066578] smpboot: CPU 2 Converting physical 4 to logical package 2
> [    0.413442]  #3
> [    0.066578] Disabled fast string operations
> [    0.066578] mce: CPU supports 0 MCE banks
> [    0.066578] smpboot: CPU 3 Converting physical 6 to logical package 3
> [    0.476562] smp: Brought up 1 node, 4 CPUs
> [    0.477477] smpboot: Max logical packages: 8
> [    0.477514] smpboot: Total of 4 processors activated (22691.70 BogoMIP=
S)
>=20
> With try_buffered_printk() patch:
>=20
> [    0.279768] smp: Bringing up secondary CPUs ...
> [    0.288825] x86: Booting SMP configuration:
> [    0.066748] Disabled fast string operations
> [    0.066748] mce: CPU supports 0 MCE banks
> [    0.066748] smpboot: CPU 1 Converting physical 2 to logical package 1
> [    0.066748] Disabled fast string operations
> [    0.066748] mce: CPU supports 0 MCE banks
> [    0.066748] smpboot: CPU 2 Converting physical 4 to logical package 2
> [    0.066748] Disabled fast string operations
> [    0.066748] mce: CPU supports 0 MCE banks
> [    0.066748] smpboot: CPU 3 Converting physical 6 to logical package 3
> [    0.495862] .... node  #0, CPUs:      #1 #2 #3=016smp: Brought up 1 no=
de, 4 CPUs
> [    0.496833] smpboot: Max logical packages: 8
> [    0.497609] smpboot: Total of 4 processors activated (22665.22 BogoMIP=
S)
>=20
>=20
>=20
> Hmm, arch/x86/kernel/smpboot.c is not emitting '\n' after #num
>=20
>         if (system_state < SYSTEM_RUNNING) {
>                 if (node !=3D current_node) {
>                         if (current_node > (-1))
>                                 pr_cont("\n");
>                         current_node =3D node;
>=20
>                         printk(KERN_INFO ".... node %*s#%d, CPUs:  ",
>                                node_width - num_digits(node), " ", node);
>                 }
>=20
>                 /* Add padding for the BSP */
>                 if (cpu =3D=3D 1)
>                         pr_cont("%*s", width + 1, " ");
>=20
>                 pr_cont("%*s#%d", width - num_digits(cpu), " ", cpu);
>=20
>         } else
>                 pr_info("Booting Node %d Processor %d APIC 0x%x\n",
>                         node, cpu, apicid);
>=20
> and causing
>=20
>         pr_info("Brought up %d node%s, %d CPU%s\n",
>                 num_nodes, (num_nodes > 1 ? "s" : ""),
>                 num_cpus,  (num_cpus  > 1 ? "s" : ""));
>=20
> line to be concatenated to previous line.
> Maybe disable try_buffered_printk() if system_state !=3D
> SYSTEM_RUNNING ?

We need to solve continuous lines also during boot. Also similar
problems might be in the code that is called in SYSTEM_RUNNING state.

This is yet another clue that try_buffered_printk() approach is not
that good idea.

Best Regards,
Petr
