Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6F0F36B0038
	for <linux-mm@kvack.org>; Tue, 18 Nov 2014 18:39:09 -0500 (EST)
Received: by mail-oi0-f41.google.com with SMTP id a3so6684968oib.14
        for <linux-mm@kvack.org>; Tue, 18 Nov 2014 15:39:09 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 9si767089oic.48.2014.11.18.15.39.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 18 Nov 2014 15:39:08 -0800 (PST)
Message-ID: <546BD866.5050101@oracle.com>
Date: Tue, 18 Nov 2014 18:38:14 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 00/11] Kernel address sanitizer - runtime memory debugger.
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com> <1415199241-5121-1-git-send-email-a.ryabinin@samsung.com>
In-Reply-To: <1415199241-5121-1-git-send-email-a.ryabinin@samsung.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>, akpm@linux-foundation.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Michal Marek <mmarek@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-mm@kvack.org, Randy Dunlap <rdunlap@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Jones <davej@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joe Perches <joe@perches.com>, linux-kernel@vger.kernel.org

Hi Andrey,

After the recent exchange of mails about kasan it came to me that I haven't
seen a kasan warning for a while now. To give kasan a quick test I added a rather
simple error which should generate a kasan warning about accessing userspace
memory (yes, I know kasan has a test module but my setup doesn't like modules):

	diff --git a/net/socket.c b/net/socket.c
	index fe20c31..794e9f4 100644
	--- a/net/socket.c
	+++ b/net/socket.c
	@@ -1902,7 +1902,7 @@ SYSCALL_DEFINE5(setsockopt, int, fd, int, level, int, optname,
	 {
	        int err, fput_needed;
	        struct socket *sock;
	-
	+       *((char *)10) = 5;
	        if (optlen < 0)
	                return -EINVAL;

A gfp was triggered, but no kasan warning was shown.

I remembered that one of the biggest changes in kasan was the introduction of
inline instrumentation, so I went ahead to disable it and see if it helps. But
the only result of that was having the boot process hang pretty early:

[...]
[    0.000000] IOAPIC[0]: apic_id 21, version 17, address 0xfec00000, GSI 0-23
[    0.000000] Processors: 20
[    0.000000] smpboot: Allowing 24 CPUs, 4 hotplug CPUs
[    0.000000] e820: [mem 0xd0000000-0xffffffff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] setup_percpu: NR_CPUS:8192 nr_cpumask_bits:24 nr_cpu_ids:24 nr_node_ids:1
[    0.000000] PERCPU: Embedded 491 pages/cpu @ffff8808dce00000 s1971864 r8192 d31080 u2097152
*HANG*

I'm using the latest gcc:

$ gcc --version
gcc (GCC) 5.0.0 20141117 (experimental)


I'll continue looking into it tomorrow, just hoping it rings a bell...


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
