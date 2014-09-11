Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 90A106B0035
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 19:24:58 -0400 (EDT)
Received: by mail-qg0-f42.google.com with SMTP id q107so11817042qgd.15
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 16:24:57 -0700 (PDT)
Received: from na01-bl2-obe.outbound.protection.outlook.com (mail-bl2on0122.outbound.protection.outlook.com. [65.55.169.122])
        by mx.google.com with ESMTPS id j4si3428366qab.100.2014.09.11.16.17.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 11 Sep 2014 16:17:09 -0700 (PDT)
From: KY Srinivasan <kys@microsoft.com>
Subject: RE: page fault in mem_cgroup_page_lruvec() due to memory hot-add
Date: Thu, 11 Sep 2014 23:17:08 +0000
Message-ID: <c5d21324ce1144e49979747a00643a83@BY2PR0301MB0711.namprd03.prod.outlook.com>
References: <EE124450C0AAF944A40DD71E61F878C99B0031@SINEX14MBXC418.southpacific.corp.microsoft.com>
 <20140911122923.GE22042@dhcp22.suse.cz>
In-Reply-To: <20140911122923.GE22042@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Dexuan Cui <decui@microsoft.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Hugh
 Dickins <hughd@google.com>



> -----Original Message-----
> From: Michal Hocko [mailto:mstsxfx@gmail.com] On Behalf Of Michal Hocko
> Sent: Thursday, September 11, 2014 5:29 AM
> To: Dexuan Cui
> Cc: linux-mm@kvack.org; linux-kernel@vger.kernel.org; Johannes Weiner;
> Hugh Dickins; KY Srinivasan
> Subject: Re: page fault in mem_cgroup_page_lruvec() due to memory hot-
> add
>=20
> On Thu 11-09-14 12:07:13, Dexuan Cui wrote:
> > Hi all,
> >
> > When I try to run Ubuntu 14.10 guest (the nightly build with the
> > kernel version 3.16.0-12-generic) on hyper-v, occasionally, I get the
> > below panic(see the end of the mail) suddenly.
> > (I suppose it's likely the upstream kernel has the issue too)
> >
> > When the panic happens, I'm running a memory stress program to test
> > the balloon driver drivers/hv/hv_balloon.c, which can hot-add memory
> > to the guest by invoking memory_add_physaddr_to_nid() and
> > add_memory(), if the feature "Dynamic Memory" is enabled.
> >
> > The issue here is: the memory hot-add seems successful, but
> > occasionally the page fault can happen and crash the whole guest.
> >
> > It looks the crash only happens to the guest in the SMP guest case. I
> > never get the crash when the guest is configured with 1 vCPU.
> >
> > Sometimes it's very difficult to reproduce the crash while sometimes
> > it's relatively easy.
> >
> > Can anybody please shed some light?
> >
> > Thanks!
> >
> > -- Dexuan
> >
> > [   99.211382] BUG: unable to handle kernel paging request at
> 0000000000c0b608
> > [   99.215308] IP: [<ffffffff811d2e9c>]
> mem_cgroup_page_lruvec+0x2c/0xa0
> > [   99.215308] PGD 37544067 PUD 393c2067 PMD 0
> > [   99.215308] Oops: 0000 [#1] SMP
> > [   99.215308] Modules linked in: bnep rfcomm bluetooth 6lowpan_iphc
> joydev hid_generic crct10dif_pclmul crc32_pclmul ghash_clmulni_intel
> aesni_intel aes_x86_64 lrw gf128mul glue_helper ablk_helper cryptd
> hyperv_keyboard hv_balloon hid_hyperv hid serio_raw i2c_piix4 mac_hid
> parport_pc ppdev lp parport hv_netvsc hv_utils hv_storvsc psmouse
> hv_vmbus pata_acpi floppy
> > [   99.215308] CPU: 3 PID: 1919 Comm: stressapptest Not tainted 3.16.0-=
12-
> generic #18-Ubuntu
> > [   99.215308] Hardware name: Microsoft Corporation Virtual
> Machine/Virtual Machine, BIOS 090006  05/23/2012
> > [   99.215308] task: ffff880034282880 ti: ffff8800415f8000 task.ti:
> ffff8800415f8000
> > [   99.215308] RIP: 0010:[<ffffffff811d2e9c>]  [<ffffffff811d2e9c>]
> mem_cgroup_page_lruvec+0x2c/0xa0
> > [   99.215308] RSP: 0000:ffff8800415fbc58  EFLAGS: 00010006
> > [   99.215308] RAX: 0000000000c0b600 RBX: ffff88003ffebf80 RCX:
> ffff88003ffea300
> > [   99.215308] RDX: 02ffff00000d0001 RSI: ffff88003ffebf80 RDI:
> ffffea000302d800
> > [   99.215308] RBP: ffff8800415fbc68 R08: 0000000000000008 R09:
> 0000000000000004
> > [   99.215308] R10: 00000000ffffffff R11: ffff880033ffd400 R12:
> ffffea000302d800
> > [   99.215308] R13: ffffea000302d800 R14: ffff88003b4703c0 R15:
> 0000000000000202
> > [   99.215308] FS:  00007fb0075fa700(0000) GS:ffff88003b460000(0000)
> knlGS:0000000000000000
> > [   99.215308] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > [   99.215308] CR2: 0000000000c0b608 CR3: 00000000389b4000 CR4:
> 00000000000006e0
> > [   99.215308] Stack:
> > [   99.215308]  ffff88003ffebf80 0000000000000002 ffff8800415fbcc0
> ffffffff81178604
> > [   99.215308]  0000000000000000 ffffffff81177bf0 0000000000000296
> ffff8800415fbc90
> > [   99.215308]  0000000000000003 000000000004b5d8 00000000000200da
> ffff880036db6480
> > [   99.215308] Call Trace:
> > [   99.215308]  [<ffffffff81178604>] pagevec_lru_move_fn+0xc4/0x130
> > [   99.215308]  [<ffffffff81177bf0>] ? __activate_page+0x1e0/0x1e0
> > [   99.215308]  [<ffffffff81178b7e>] lru_add_drain_cpu+0xce/0xe0
> > [   99.215308]  [<ffffffff81178c96>] lru_add_drain+0x16/0x20
> > [   99.215308]  [<ffffffff811aa2e6>] swapin_readahead+0x126/0x1a0
> > [   99.215308]  [<ffffffff81198c17>] handle_mm_fault+0xc87/0xf90
> > [   99.215308]  [<ffffffff8105ce42>] __do_page_fault+0x1c2/0x580
> > [   99.215308]  [<ffffffff810a9d18>] ? __enqueue_entity+0x78/0x80
> > [   99.215308]  [<ffffffff810ae8c4>] ? update_curr+0xf4/0x180
> > [   99.215308]  [<ffffffff810ab3f8>] ? pick_next_entity+0x88/0x180
> > [   99.215308]  [<ffffffff810b3b8e>] ? pick_next_task_fair+0x57e/0x8d0
> > [   99.215308]  [<ffffffff810a84e8>] ? sched_clock_cpu+0x88/0xb0
> > [   99.215308]  [<ffffffff8105d231>] do_page_fault+0x31/0x70
> > [   99.215308]  [<ffffffff81782908>] page_fault+0x28/0x30
> > [   99.215308] Code: 66 66 66 90 8b 15 15 2a b5 00 55 48 8d 86 48 05 00=
 00 48
> 89 e5 41 54 53 85 d2 48 89 f3 75 56 49 89 fc e8 18 44 00 00 49 8b 14 24 <=
48> 8b
> 48 08 83 e2 20 75 1b 48 8b 10 83 e2 02 75 13 48 8b 15 54
> > [   99.215308] RIP  [<ffffffff811d2e9c>]
> mem_cgroup_page_lruvec+0x2c/0xa0
> > [   99.215308]  RSP <ffff8800415fbc58>
> > [   99.215308] CR2: 0000000000c0b608
> > [   99.215308] ---[ end trace 24db5f2378e898cb ]---
>=20
> This decodes to:
> All code
> =3D=3D=3D=3D=3D=3D=3D=3D
>    0:   66 66 66 90             data16 data16 xchg %ax,%ax
>    4:   8b 15 15 2a b5 00       mov    0xb52a15(%rip),%edx        # 0xb52=
a1f
>    a:   55                      push   %rbp
>    b:   48 8d 86 48 05 00 00    lea    0x548(%rsi),%rax
>   12:   48 89 e5                mov    %rsp,%rbp
>   15:   41 54                   push   %r12
>   17:   53                      push   %rbx
>   18:   85 d2                   test   %edx,%edx
>   1a:   48 89 f3                mov    %rsi,%rbx
>   1d:   75 56                   jne    0x75
>   1f:   49 89 fc                mov    %rdi,%r12
>   22:   e8 18 44 00 00          callq  0x443f
>   27:   49 8b 14 24             mov    (%r12),%rdx
>   2b:*  48 8b 48 08             mov    0x8(%rax),%rcx           <-- trapp=
ing instruction
>   2f:   83 e2 20                and    $0x20,%edx
>   32:   75 1b                   jne    0x4f
>   34:   48 8b 10                mov    (%rax),%rdx
>   37:   83 e2 02                and    $0x2,%edx
>   3a:   75 13                   jne    0x4f
>   3c:   48                      rex.W
>   3d:   8b                      .byte 0x8b
>   3e:   15                      .byte 0x15
>   3f:   54                      push   %rsp
>=20
> and that matches to the following code:
>         pc =3D lookup_page_cgroup(page);
>         memcg =3D pc->mem_cgroup;		<<< BANG
>=20
> So the lookup_page_cgroup returned a garbage (rax is supposed to be pc
> pointer but the value is definitely not a kernel pointer. It looks like a=
n offset
> from zero base address). The page itself (rdi resp. r12 looks pretty norm=
al to
> me). I would strongly suspect that the HyperV is doing something nasty
> when offlining the memory. Because there shouldn't be any page left behin=
d
> when the node_data resp. mem_section (depending on the used memory
> model) is torn down.
>=20
> KY, any ideas?

I will take a look.

K. Y
> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
