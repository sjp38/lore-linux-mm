Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f179.google.com (mail-vc0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id D7B9D6B0035
	for <linux-mm@kvack.org>; Thu, 10 Jul 2014 15:04:36 -0400 (EDT)
Received: by mail-vc0-f179.google.com with SMTP id id10so37663vcb.10
        for <linux-mm@kvack.org>; Thu, 10 Jul 2014 12:04:36 -0700 (PDT)
Received: from mail-vc0-x22a.google.com (mail-vc0-x22a.google.com [2607:f8b0:400c:c03::22a])
        by mx.google.com with ESMTPS id vw2si3310vcb.54.2014.07.10.12.04.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 10 Jul 2014 12:04:35 -0700 (PDT)
Received: by mail-vc0-f170.google.com with SMTP id hy10so44821vcb.1
        for <linux-mm@kvack.org>; Thu, 10 Jul 2014 12:04:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53BE9CED.4090103@oracle.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
	<1404905415-9046-2-git-send-email-a.ryabinin@samsung.com>
	<53BE7F29.20304@oracle.com>
	<53BE8EA5.2030402@samsung.com>
	<53BE959A.4010206@oracle.com>
	<53BE9786.4060700@samsung.com>
	<53BE9CED.4090103@oracle.com>
Date: Thu, 10 Jul 2014 23:04:34 +0400
Message-ID: <CAPAsAGy279XqO0Yq9v1q1OoW4TLv2iFKC0UjY+fOh31LxYOB+w@mail.gmail.com>
Subject: Re: [RFC/PATCH RESEND -next 01/21] Add kernel address sanitizer infrastructure.
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>

2014-07-10 18:02 GMT+04:00 Sasha Levin <sasha.levin@oracle.com>:
> On 07/10/2014 09:39 AM, Andrey Ryabinin wrote:
>>> Anyways, the machine won't boot with more than 1GB of RAM, is there a s=
olution to
>>> > get KASAN running on my machine?
>>> >
>> Could you share you .config? I'll try to boot it by myself. It could be =
that some options conflicting with kasan.
>> Also boot cmdline might help.
>>
>
> Sure. It's the .config I use for fuzzing so it's rather big (attached).
>
> The cmdline is:
>
> [    0.000000] Command line: noapic noacpi pci=3Dconf1 reboot=3Dk panic=
=3D1 i8042.direct=3D1 i8042.dumbkbd=3D1 i8042.nopnp=3D1 console=3DttyS0 ear=
lyprintk=3Dserial i8042.noaux=3D1 numa=3Dfake=3D32 init=3D/virt/init zcache=
 ftrace_dump_on_oops debugpat kvm.mmu_audit=3D1 slub_debug=3DFZPU rcutortur=
e.rcutorture_runnable=3D0 loop.max_loop=3D64 zram.num_devices=3D4 rcutortur=
e.nreaders=3D8 oops=3Dpanic nr_hugepages=3D1000 numa_balancing=3Denable sof=
tlockup_all_cpu_backtrace=3D1 root=3D/dev/root rw rootflags=3Drw,trans=3Dvi=
rtio,version=3D9p2000.L rootfstype=3D9p init=3D/virt/init
>
> And the memory map:
>
> [    0.000000] e820: BIOS-provided physical RAM map:
> [    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usa=
ble
> [    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] res=
erved
> [    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000ffffe] res=
erved
> [    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000cfffffff] usa=
ble
> [    0.000000] BIOS-e820: [mem 0x0000000100000000-0x0000000705ffffff] usa=
ble
>
>
> On 07/10/2014 09:50 AM, Andrey Ryabinin wrote:>> Anyways, the machine won=
't boot with more than 1GB of RAM, is there a solution to
>>> > get KASAN running on my machine?
>>> >
>> It's not boot with the same Failed to allocate error?
>
> I think I misunderstood your question here. With >1GB is triggers a panic=
() when
> KASAN fails the memblock allocation. With <=3D1GB it fails a bit later in=
 boot just
> because 1GB isn't enough to load everything - so it fails in some other r=
andom
> spot as it runs on out memory.
>
>
> Thanks,
> Sasha

Looks like I found where is a problem. memblock_alloc cannot allocate
accross numa nodes,
therefore kasan fails for numa=3Dfake>=3D8.
You should succeed with numa=3Dfake=3D7 or less.


--=20
Best regards,
Andrey Ryabinin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
