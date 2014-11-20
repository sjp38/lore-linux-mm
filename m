Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id D9B4D6B0069
	for <linux-mm@kvack.org>; Thu, 20 Nov 2014 11:32:52 -0500 (EST)
Received: by mail-lb0-f178.google.com with SMTP id f15so1183981lbj.9
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 08:32:52 -0800 (PST)
Received: from mail-la0-x236.google.com (mail-la0-x236.google.com. [2a00:1450:4010:c03::236])
        by mx.google.com with ESMTPS id sn3si2537142lbb.77.2014.11.20.08.32.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Nov 2014 08:32:51 -0800 (PST)
Received: by mail-la0-f54.google.com with SMTP id gf13so2666099lab.41
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 08:32:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141120090356.GA6690@gmail.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1415199241-5121-1-git-send-email-a.ryabinin@samsung.com> <5461B906.1040803@samsung.com>
 <20141118125843.434c216540def495d50f3a45@linux-foundation.org>
 <CAPAsAGwZtfzx5oM73bOi_kw5BqXrwGd_xmt=m6xxU6uECA+H9Q@mail.gmail.com> <20141120090356.GA6690@gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 20 Nov 2014 20:32:30 +0400
Message-ID: <CACT4Y+aOKzq0AzvSJrRC-iU9LmmtLzxY=pxzu8f4oT-OZk=oLA@mail.gmail.com>
Subject: Re: [PATCH v6 00/11] Kernel address sanitizer - runtime memory debugger.
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Randy Dunlap <rdunlap@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Jones <davej@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joe Perches <joe@perches.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Thu, Nov 20, 2014 at 12:03 PM, Ingo Molnar <mingo@kernel.org> wrote:
>
> * Andrey Ryabinin <ryabinin.a.a@gmail.com> wrote:
>
>> I've counted 16:
>>
>> aab515d (fib_trie: remove potential out of bound access)
>> 984f173 ([SCSI] sd: Fix potential out-of-bounds access)
>> 5e9ae2e (aio: fix use-after-free in aio_migratepage)
>> 2811eba (ipv6: udp packets following an UFO enqueued packet need also
>> be handled by UFO)
>> 057db84 (tracing: Fix potential out-of-bounds in trace_get_user())
>> 9709674 (ipv4: fix a race in ip4_datagram_release_cb())
>> 4e8d213 (ext4: fix use-after-free in ext4_mb_new_blocks)
>> 624483f (mm: rmap: fix use-after-free in __put_anon_vma)
>> 93b7aca (lib/idr.c: fix out-of-bounds pointer dereference)
>> b4903d6 (mm: debugfs: move rounddown_pow_of_two() out from do_fault path)
>> 40eea80 (net: sendmsg: fix NULL pointer dereference)
>> 10ec947 (ipv4: fix buffer overflow in ip_options_compile())
>> dbf20cb2 (f2fs: avoid use invalid mapping of node_inode when evict meta inode)
>> d6d86c0 (mm/balloon_compaction: redesign ballooned pages management)
>>
>> + 2 recently found, seems minor:
>>     http://lkml.kernel.org/r/1415372020-1871-1-git-send-email-a.ryabinin@samsung.com
>>     (sched/numa: Fix out of bounds read in sched_init_numa())
>>
>>     http://lkml.kernel.org/r/1415458085-12485-1-git-send-email-ryabinin.a.a@gmail.com
>>     (security: smack: fix out-of-bounds access in smk_parse_smack())
>>
>> Note that some functionality is not yet implemented in this
>> patch set. Kasan has possibility to detect out-of-bounds
>> accesses on global/stack variables. Neither
>> kmemcheck/debug_pagealloc or slub_debug could do that.
>>
>> > That's in a 20-year-old code base, so one new minor bug discovered per
>> > three years?  Not worth it!
>> >
>> > Presumably more bugs will be exposed as more people use kasan on
>> > different kernel configs, but will their number and seriousness justify
>> > the maintenance effort?
>> >
>>
>> Yes, AFAIK there are only few users of kasan now, and I guess that
>> only small part of kernel code
>> was covered by it.
>> IMO kasan shouldn't take a lot maintenance efforts, most part of code
>> is isolated and it doesn't
>> have some complex dependencies on in-kernel API.
>> And you could always just poke me, I'd be happy to sort out any issues.
>>
>> > If kasan will permit us to remove kmemcheck/debug_pagealloc/slub_debug
>> > then that tips the balance a little.  What's the feasibility of that?
>> >
>>
>> I think kasan could replace kmemcheck at some point.
>
> So that angle sounds interesting, because kmemcheck is
> essentially unmaintained right now: in the last 3 years since
> v3.0 arch/x86/mm/kmemcheck/ has not seen a single kmemcheck
> specific change, only 4 incidental changes.
>
> kmemcheck is also very architecture bound and somewhat fragile
> due to having to decode instructions, so if generic, compiler
> driven instrumentation can replace it, that would be a plus.

Hi Andrew, Ingo,

I understand your concerns about added complexity.

Let me provide some background first.
We've developed the set of tools, AddressSanitizer (Asan),
ThreadSanitizer and MemorySanitizer, for user space. We actively use
them for testing inside of Google (continuous testing, fuzzing,
running prod services). To date the tools have found more than 10'000
scary bugs in Chromium, Google internal codebase and various
open-source projects (Firefox, OpenSSL, gcc, clang, ffmpeg, MySQL and
lots of others):
https://code.google.com/p/address-sanitizer/wiki/FoundBugs
https://code.google.com/p/thread-sanitizer/wiki/FoundBugs
https://code.google.com/p/memory-sanitizer/wiki/FoundBugs
The tools are part of both gcc and clang compilers.

We have not yet done massive testing under the Kernel AddressSanitizer
(it's kind of chicken and egg problem, you need it to be upstream to
start applying it extensively). To date it has found about 50 bugs.
Bugs that we've found in upstream kernel are listed here:
https://code.google.com/p/address-sanitizer/wiki/AddressSanitizerForKernel#Trophies
We've also found ~20 bugs in out internal version of the kernel. Also
people from Samsung and Oracle have found some. It's somewhat expected
that when we boot the kernel and run a trivial workload, we do not
find hundreds of bugs -- most of the harmful bugs in kernel codebase
were already fixed the hard way (the kernel is quite stable, right).
Based on our experience with user-space version of the tool, most of
the bugs will be discovered by continuously testing new code (new bugs
discovered the easy way), running fuzzers (that can discover existing
bugs that are not hit frequently enough) and running end-to-end tests
of production systems.

As others noted, the main feature of AddressSanitizer is its
performance due to inline compiler instrumentation and simple linear
shadow memory. User-space Asan has ~2x slowdown on computational
programs and ~2x memory consumption increase. Taking into account that
kernel usually consumes only small fraction of CPU and memory when
running real user-space programs, I would expect that kernel Asan will
have ~10-30% slowdown and similar memory consumption increase (when we
finish all tuning).

I agree that Asan can well replace kmemcheck. We have plans to start
working on Kernel MemorySanitizer that finds uses of unitialized
memory. Asan+Msan will provide feature-parity with kmemcheck. As
others noted, Asan will unlikely replace debug slab and pagealloc that
can be enabled at runtime. Asan uses compiler instrumentation, so even
if it is disabled, it still incurs visible overheads.

Asan technology is easily portable to other architectures. Compiler
instrumentation is fully portable. Runtime has some arch-dependent
parts like shadow mapping and atomic operation interception. They are
relatively easy to port.

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
