Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f171.google.com (mail-vc0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id EEA0B6B006E
	for <linux-mm@kvack.org>; Tue, 18 Nov 2014 19:10:00 -0500 (EST)
Received: by mail-vc0-f171.google.com with SMTP id id10so9143590vcb.30
        for <linux-mm@kvack.org>; Tue, 18 Nov 2014 16:10:00 -0800 (PST)
Received: from mail-vc0-x22a.google.com (mail-vc0-x22a.google.com. [2607:f8b0:400c:c03::22a])
        by mx.google.com with ESMTPS id az6si63493vdc.62.2014.11.18.16.09.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Nov 2014 16:09:59 -0800 (PST)
Received: by mail-vc0-f170.google.com with SMTP id hq12so9999069vcb.1
        for <linux-mm@kvack.org>; Tue, 18 Nov 2014 16:09:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <546BD866.5050101@oracle.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
	<1415199241-5121-1-git-send-email-a.ryabinin@samsung.com>
	<546BD866.5050101@oracle.com>
Date: Wed, 19 Nov 2014 04:09:59 +0400
Message-ID: <CAPAsAGxYF27pbNEgsr3PgNJ=uNFzR2qcviLB_7bp=nM3ZD5Jgw@mail.gmail.com>
Subject: Re: [PATCH v6 00/11] Kernel address sanitizer - runtime memory debugger.
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Michal Marek <mmarek@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Randy Dunlap <rdunlap@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Jones <davej@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joe Perches <joe@perches.com>, LKML <linux-kernel@vger.kernel.org>

2014-11-19 2:38 GMT+03:00 Sasha Levin <sasha.levin@oracle.com>:
> Hi Andrey,
>
> After the recent exchange of mails about kasan it came to me that I haven't
> seen a kasan warning for a while now. To give kasan a quick test I added a rather
> simple error which should generate a kasan warning about accessing userspace
> memory (yes, I know kasan has a test module but my setup doesn't like modules):
>
>         diff --git a/net/socket.c b/net/socket.c
>         index fe20c31..794e9f4 100644
>         --- a/net/socket.c
>         +++ b/net/socket.c
>         @@ -1902,7 +1902,7 @@ SYSCALL_DEFINE5(setsockopt, int, fd, int, level, int, optname,
>          {
>                 int err, fput_needed;
>                 struct socket *sock;
>         -
>         +       *((char *)10) = 5;
>                 if (optlen < 0)
>                         return -EINVAL;
>
> A gfp was triggered, but no kasan warning was shown.
>

Yes with CONFIG_KASAN_INLINE you will get GPF instead of kasan report.
For userspaces addresses we don't have shadow memory. In outline case
I just check address itself before checking shadow. In inline case compiler
just checks shadow, so there is no way to avoid GPF.

To be able to print report instead of GPF, I need to treat GPFs in a special
way if inline instrumentation was enabled, but it's not done yet.

> I remembered that one of the biggest changes in kasan was the introduction of
> inline instrumentation, so I went ahead to disable it and see if it helps. But
> the only result of that was having the boot process hang pretty early:
>
> [...]
> [    0.000000] IOAPIC[0]: apic_id 21, version 17, address 0xfec00000, GSI 0-23
> [    0.000000] Processors: 20
> [    0.000000] smpboot: Allowing 24 CPUs, 4 hotplug CPUs
> [    0.000000] e820: [mem 0xd0000000-0xffffffff] available for PCI devices
> [    0.000000] Booting paravirtualized kernel on KVM
> [    0.000000] setup_percpu: NR_CPUS:8192 nr_cpumask_bits:24 nr_cpu_ids:24 nr_node_ids:1
> [    0.000000] PERCPU: Embedded 491 pages/cpu @ffff8808dce00000 s1971864 r8192 d31080 u2097152
> *HANG*
>

This hang happens only with your error patch above or even without it?
In any case I'll look tomorrow.

> I'm using the latest gcc:
>
> $ gcc --version
> gcc (GCC) 5.0.0 20141117 (experimental)
>
>
> I'll continue looking into it tomorrow, just hoping it rings a bell...
>
>
> Thanks,
> Sasha
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



-- 
Best regards,
Andrey Ryabinin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
