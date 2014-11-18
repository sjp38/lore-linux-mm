Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f177.google.com (mail-vc0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id 971516B0038
	for <linux-mm@kvack.org>; Tue, 18 Nov 2014 18:53:27 -0500 (EST)
Received: by mail-vc0-f177.google.com with SMTP id ij19so7863358vcb.36
        for <linux-mm@kvack.org>; Tue, 18 Nov 2014 15:53:27 -0800 (PST)
Received: from mail-vc0-x22a.google.com (mail-vc0-x22a.google.com. [2607:f8b0:400c:c03::22a])
        by mx.google.com with ESMTPS id nv6si90797vcb.47.2014.11.18.15.53.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Nov 2014 15:53:26 -0800 (PST)
Received: by mail-vc0-f170.google.com with SMTP id hq12so9883705vcb.15
        for <linux-mm@kvack.org>; Tue, 18 Nov 2014 15:53:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141118125843.434c216540def495d50f3a45@linux-foundation.org>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
	<1415199241-5121-1-git-send-email-a.ryabinin@samsung.com>
	<5461B906.1040803@samsung.com>
	<20141118125843.434c216540def495d50f3a45@linux-foundation.org>
Date: Wed, 19 Nov 2014 03:53:26 +0400
Message-ID: <CAPAsAGwZtfzx5oM73bOi_kw5BqXrwGd_xmt=m6xxU6uECA+H9Q@mail.gmail.com>
Subject: Re: [PATCH v6 00/11] Kernel address sanitizer - runtime memory debugger.
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Randy Dunlap <rdunlap@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Jones <davej@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joe Perches <joe@perches.com>, LKML <linux-kernel@vger.kernel.org>

2014-11-18 23:58 GMT+03:00 Andrew Morton <akpm@linux-foundation.org>:
> On Tue, 11 Nov 2014 10:21:42 +0300 Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
>
>> Hi Andrew,
>>
>> Now we have stable GCC(4.9.2) which supports kasan and from my point of view patchset is ready for merging.
>> I could have sent v7 (it's just rebased v6), but I see no point in doing that and bothering people,
>> unless you are ready to take it.
>
> It's a huge pile of tricky code we'll need to maintain.  To justify its
> inclusion I think we need to be confident that kasan will find a
> significant number of significant bugs that
> kmemcheck/debug_pagealloc/slub_debug failed to detect.
>
> How do we get that confidence?  I've seen a small number of
> minorish-looking kasan-detected bug reports go past, maybe six or so.

I must admit that most bugs I've seen is a minor,
but there are  a bit more then six of them.

I've counted 16:

aab515d (fib_trie: remove potential out of bound access)
984f173 ([SCSI] sd: Fix potential out-of-bounds access)
5e9ae2e (aio: fix use-after-free in aio_migratepage)
2811eba (ipv6: udp packets following an UFO enqueued packet need also
be handled by UFO)
057db84 (tracing: Fix potential out-of-bounds in trace_get_user())
9709674 (ipv4: fix a race in ip4_datagram_release_cb())
4e8d213 (ext4: fix use-after-free in ext4_mb_new_blocks)
624483f (mm: rmap: fix use-after-free in __put_anon_vma)
93b7aca (lib/idr.c: fix out-of-bounds pointer dereference)
b4903d6 (mm: debugfs: move rounddown_pow_of_two() out from do_fault path)
40eea80 (net: sendmsg: fix NULL pointer dereference)
10ec947 (ipv4: fix buffer overflow in ip_options_compile())
dbf20cb2 (f2fs: avoid use invalid mapping of node_inode when evict meta inode)
d6d86c0 (mm/balloon_compaction: redesign ballooned pages management)

+ 2 recently found, seems minor:
    http://lkml.kernel.org/r/1415372020-1871-1-git-send-email-a.ryabinin@samsung.com
    (sched/numa: Fix out of bounds read in sched_init_numa())

    http://lkml.kernel.org/r/1415458085-12485-1-git-send-email-ryabinin.a.a@gmail.com
    (security: smack: fix out-of-bounds access in smk_parse_smack())

Note that some functionality is not yet implemented in this patch set.
Kasan has possibility
to detect out-of-bounds accesses on global/stack variables. Neither
kmemcheck/debug_pagealloc or slub_debug could do that.

> That's in a 20-year-old code base, so one new minor bug discovered per
> three years?  Not worth it!
>
> Presumably more bugs will be exposed as more people use kasan on
> different kernel configs, but will their number and seriousness justify
> the maintenance effort?
>

Yes, AFAIK there are only few users of kasan now, and I guess that
only small part of kernel code
was covered by it.
IMO kasan shouldn't take a lot maintenance efforts, most part of code
is isolated and it doesn't
have some complex dependencies on in-kernel API.
And you could always just poke me, I'd be happy to sort out any issues.

> If kasan will permit us to remove kmemcheck/debug_pagealloc/slub_debug
> then that tips the balance a little.  What's the feasibility of that?
>

I think kasan could replace kmemcheck at some point.
Unlike kmemcheck, kasan couldn't detect uninitialized memory reads now.
But It could be done  using the same compiler's instrumentation (I
have some proof-of-concept).
Though it will be a different Kconfig option, so you either enable
CONFIG_KASAN to detect out-of-bounds
and use-after-frees or CONFIG_DETECT_UNINITIALIZED_MEMORY to catch
only uninitialized memory reads.

Removing debug_pagealloc maybe is not so good idea, because it doesn't
eat much memory unlike kasan.

slub_debug could be enabled in production kernels without rebuilding,
so I wouldn't touch it too.

>
> Sorry to play the hardass here, but someone has to ;)
>


-- 
Best regards,
Andrey Ryabinin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
