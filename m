Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id B04916B0038
	for <linux-mm@kvack.org>; Wed, 19 Nov 2014 07:41:13 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id y10so631428pdj.7
        for <linux-mm@kvack.org>; Wed, 19 Nov 2014 04:41:13 -0800 (PST)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id qa7si2570456pac.91.2014.11.19.04.41.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 19 Nov 2014 04:41:12 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NFA004CNE13EA70@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 19 Nov 2014 12:43:51 +0000 (GMT)
Message-id: <546C8FDE.1080803@samsung.com>
Date: Wed, 19 Nov 2014 15:41:02 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v6 00/11] Kernel address sanitizer - runtime memory
 debugger.
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1415199241-5121-1-git-send-email-a.ryabinin@samsung.com>
 <546BD866.5050101@oracle.com>
 <CAPAsAGxYF27pbNEgsr3PgNJ=uNFzR2qcviLB_7bp=nM3ZD5Jgw@mail.gmail.com>
 <546BE7F2.3070009@oracle.com>
In-reply-to: <546BE7F2.3070009@oracle.com>
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Michal Marek <mmarek@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Randy Dunlap <rdunlap@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Jones <davej@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joe Perches <joe@perches.com>, LKML <linux-kernel@vger.kernel.org>

On 11/19/2014 03:44 AM, Sasha Levin wrote:
> On 11/18/2014 07:09 PM, Andrey Ryabinin wrote:
>> Yes with CONFIG_KASAN_INLINE you will get GPF instead of kasan report.
>> For userspaces addresses we don't have shadow memory. In outline case
>> I just check address itself before checking shadow. In inline case compiler
>> just checks shadow, so there is no way to avoid GPF.
>>
>> To be able to print report instead of GPF, I need to treat GPFs in a special
>> way if inline instrumentation was enabled, but it's not done yet.
> 
> I went ahead and tested it with the test module, which worked perfectly. No
> more complaints here...
> 
>>>> I remembered that one of the biggest changes in kasan was the introduction of
>>>> inline instrumentation, so I went ahead to disable it and see if it helps. But
>>>> the only result of that was having the boot process hang pretty early:
>>>>
>>>> [...]
>>>> [    0.000000] IOAPIC[0]: apic_id 21, version 17, address 0xfec00000, GSI 0-23
>>>> [    0.000000] Processors: 20
>>>> [    0.000000] smpboot: Allowing 24 CPUs, 4 hotplug CPUs
>>>> [    0.000000] e820: [mem 0xd0000000-0xffffffff] available for PCI devices
>>>> [    0.000000] Booting paravirtualized kernel on KVM
>>>> [    0.000000] setup_percpu: NR_CPUS:8192 nr_cpumask_bits:24 nr_cpu_ids:24 nr_node_ids:1
>>>> [    0.000000] PERCPU: Embedded 491 pages/cpu @ffff8808dce00000 s1971864 r8192 d31080 u2097152
>>>> *HANG*
>>>>
>> This hang happens only with your error patch above or even without it?
> 
> It happens even without the patch.
> 

I took your config from "Replace _PAGE_NUMA with PAGE_NONE protections" thread.
I've noticed that you have both KASAN and UBSAN enabled.
I didn't try them together, though it could work with patch bellow.
But it should hang much earlier then you see, without this patch.

------------------------------------------------------
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH] kasan: don't use ubsan's instrumentation for kasan internals

kasan do unaligned access for checking shadow memory faster.
If ubsan is also enabled this will lead to unbound recursion:
__asan_load* -> __ubsan_handle_type_mismatch -> __asan_load* -> ...

Disable ubsan's instrumentation for kasan.c to avoid that.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 mm/kasan/Makefile | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/kasan/Makefile b/mm/kasan/Makefile
index ef2d313..2b53073 100644
--- a/mm/kasan/Makefile
+++ b/mm/kasan/Makefile
@@ -1,4 +1,5 @@
 KASAN_SANITIZE := n
+UBSAN_SANITIZE := n

 # Function splitter causes unnecessary splits in __asan_load1/__asan_store1
 # see: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=63533
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
