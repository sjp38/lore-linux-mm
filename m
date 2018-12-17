Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id E6CF18E0001
	for <linux-mm@kvack.org>; Sun, 16 Dec 2018 23:41:24 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id ay11so8193979plb.20
        for <linux-mm@kvack.org>; Sun, 16 Dec 2018 20:41:24 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e8si10295916pgn.325.2018.12.16.20.41.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Dec 2018 20:41:23 -0800 (PST)
Date: Mon, 17 Dec 2018 05:41:15 +0100
From: Jessica Yu <jeyu@kernel.org>
Subject: Re: [PATCH v9 RESEND 0/4] KASLR feature to randomize each loadable
 module
Message-ID: <20181217044115.GA19913@linux-8ccs>
References: <20181120232312.30037-1-rick.p.edgecombe@intel.com>
 <20181126153611.GA17169@linux-8ccs>
 <54dafdec825859afc85a3bd651f9e850e57a59dc.camel@intel.com>
 <76b6ffbc-8c44-75ab-382b-ad281c20c2bf@iogearbox.net>
 <8d2ba1f5c90ffb937e97741d68683de622f55843.camel@intel.com>
 <0975aa62d9649df56832b8e745c78d0fb83a3610.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <0975aa62d9649df56832b8e745c78d0fb83a3610.camel@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Cc: "daniel@iogearbox.net" <daniel@iogearbox.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "jannh@google.com" <jannh@google.com>, "arjan@linux.intel.com" <arjan@linux.intel.com>, "keescook@chromium.org" <keescook@chromium.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "willy@infradead.org" <willy@infradead.org>, "x86@kernel.org" <x86@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "kristen@linux.intel.com" <kristen@linux.intel.com>, "mingo@redhat.com" <mingo@redhat.com>, "alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "Hansen, Dave" <dave.hansen@intel.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>

+++ Edgecombe, Rick P [12/12/18 23:05 +0000]:
>On Wed, 2018-11-28 at 01:40 +0000, Edgecombe, Rick P wrote:
>> On Tue, 2018-11-27 at 11:21 +0100, Daniel Borkmann wrote:
>> > On 11/27/2018 01:19 AM, Edgecombe, Rick P wrote:
>> > > On Mon, 2018-11-26 at 16:36 +0100, Jessica Yu wrote:
>> > > > +++ Rick Edgecombe [20/11/18 15:23 -0800]:
>> > >
>> > > [snip]
>> > > > Hi Rick!
>> > > >
>> > > > Sorry for the delay. I'd like to take a step back and ask some broader
>> > > > questions -
>> > > >
>> > > > - Is the end goal of this patchset to randomize loading kernel modules,
>> > > > or
>> > > > most/all
>> > > >    executable kernel memory allocations, including bpf, kprobes, etc?
>> > >
>> > > Thanks for taking a look!
>> > >
>> > > It started with the goal of just randomizing modules (hence the name), but
>> > > I
>> > > think there is maybe value in randomizing the placement of all runtime
>> > > added
>> > > executable code. Beyond just trying to make executable code placement less
>> > > deterministic in general, today all of the usages have the property of
>> > > starting
>> > > with RW permissions and then becoming RO executable, so there is the
>> > > benefit
>> > > of
>> > > narrowing the chances a bug could successfully write to it during the RW
>> > > window.
>> > >
>> > > > - It seems that a lot of complexity and heuristics are introduced just
>> > > > to
>> > > >    accommodate the potential fragmentation that can happen when the
>> > > > module
>> > > > vmalloc
>> > > >    space starts to get fragmented with bpf filters. I'm partial to the
>> > > > idea of
>> > > >    splitting or having bpf own its own vmalloc space, similar to what
>> > > > Ard
>> > > > is
>> > > > already
>> > > >    implementing for arm64.
>> > > >
>> > > >    So a question for the bpf and x86 folks, is having a dedicated
>> > > > vmalloc
>> > > > region
>> > > >    (as well as a seperate bpf_alloc api) for bpf feasible or desirable
>> > > > on
>> > > > x86_64?
>> > >
>> > > I actually did some prototyping and testing on this. It seems there would
>> > > be
>> > > some slowdown from the required changes to the JITed code to support
>> > > calling
>> > > back from the vmalloc region into the kernel, and so module space would
>> > > still be
>> > > the preferred region.
>> >
>> > Yes, any runtime slow-down would be no-go as BPF sits in the middle of
>> > critical
>> > networking fast-path and e.g. on XDP or tc layer and is used in load-
>> > balancing,
>> > firewalling, DDoS protection scenarios, some recent examples in [0-3].
>> >
>> >   [0] http://vger.kernel.org/lpc-networking2018.html#session-10
>> >   [1] http://vger.kernel.org/lpc-networking2018.html#session-15
>> >   [2] https://blog.cloudflare.com/how-to-drop-10-million-packets/
>> >   [3] http://vger.kernel.org/lpc-bpf2018.html#session-1
>> >
>> > > >    If bpf filters need to be within 2 GB of the core kernel, would it
>> > > > make
>> > > > sense
>> > > >    to carve out a portion of the current module region for bpf
>> > > > filters?  According
>> > > >    to Documentation/x86/x86_64/mm.txt, the module region is ~1.5 GB. I
>> > > > am
>> > > > doubtful
>> > > >    that any real system will actually have 1.5 GB worth of kernel
>> > > > modules
>> > > > loaded.
>> > > >    Is there a specific reason why that much space is dedicated to kernel
>> > > > modules,
>> > > >    and would it be feasible to split that region cleanly with bpf?
>> > >
>> > > Hopefully someone from BPF side of things will chime in, but my
>> > > understanding
>> > > was that they would like even more space than today if possible and so
>> > > they
>> > > may
>> > > not like the reduced space.
>> >
>> > I wouldn't mind of the region is split as Jessica suggests but in a way
>> > where
>> > there would be _no_ runtime regressions for BPF. This might also allow to
>> > have
>> > more flexibility in sizing the area dedicated for BPF in future, and could
>> > potentially be done in similar way as Ard was proposing recently [4].
>> >
>> >   [4] https://patchwork.ozlabs.org/project/netdev/list/?series=77779
>>
>> CCing Ard.
>>
>> The benefit of sharing the space, for randomization at least, is that you can
>> spread the allocations over a larger area.
>>
>> I think there are also other benefits to unifying how this memory is managed
>> though, rather than spreading it further. Today there are various patterns and
>> techniques used like calling different combinations of set_memory_* before
>> freeing, zeroing in modules or setting invalid instructions like BPF does,
>> etc.
>> There is also special care to be taken on vfree-ing executable memory. So this
>> way things only have to be done right once and there is less duplication.
>>
>> Not saying there shouldn't be __weak alloc and free method in BPF for arch
>> specific behavior, just that there is quite a few other concerns that could be
>> good to centralize even more than today.
>>
>> What if there was a unified executable alloc API with support for things like:
>>  - Concepts of two regions for Ard's usage, near(modules) and far(vmalloc)
>> from
>>    kernel text. Won't apply for every arch, but maybe enough that some logic
>>    could be unified
>>  - Limits for each of the usages (modules, bpf, kprobes, ftrace)
>>  - Centralized logic for moving between RW and RO+X
>>  - Options for exclusive regions or all shared
>>  - Randomizing base, randomizing independently or none
>>  - Some cgroups hooks?
>>
>> Would there be any interest in that for the future?
>>
>> As a next step, if BPF doesn't want to use this by default, could BPF just
>> call
>> vmalloc_node_range directly from Ard's new __weak functions on x86? Then
>> modules
>> can randomize across the whole space and BPF can fill the gaps linearly from
>> the
>> beginning. Is that acceptable? Then the vmalloc optimizations could be dropped
>> for the time being since the BPFs would not be fragmented, but the separate
>> regions could come as part of future work.
>Jessica, Daniel,
>
>Any advice for me on how we could move this forward?

Hi Rick,

It would be good for the x86 folks to chime in if they find the
x86-related module changes agreeable (in particular, the partitioning
and sizing of the module space in separate randomization and backup
areas). Has that happened already or did I just miss that in the
previous versions?

I'm impartial towards the vmalloc optimizations, as I wouldn't
consider module loading performance-critical (For instance, you'd most
likely just load a driver once and be done with it, and it's not like
you'd very frequently be loading/unloading modules. And note I mean
loading a kernel module, not module_alloc() allocations. These two
concepts are starting to get conflated :-/ ). So, I'd leave the
optimizations up to the BPF folks if they consider that beneficial for
their module_alloc() allocations.

And it looks like there isn't really a strong push or interest on
having a separate vmalloc area for bpf, so I suppose we can drop that
idea for now (that would be a separate patchset on its own anyway).
I just suggested the idea because I was curious if that would have
helped with the potential fragmentation issues. In any case it sounded
like the potentially reduced space (should the module space be split
between bpf and modules) isn't desirable.

Thanks,

Jessica

>
>> Thanks,
>>
>> Rick
>>
>> > > Also with KASLR on x86 its actually only 1GB, so it would only be 500MB
>> > > per
>> > > section (assuming kprobes, etc would share the non-module region, so just
>> > > two
>> > > sections).
>> > >
>> > > > - If bpf gets its own dedicated vmalloc space, and we stick to the
>> > > > single
>> > > > task
>> > > >    of randomizing *just* kernel modules, could the vmalloc optimizations
>> > > > and
>> > > > the
>> > > >    "backup" area be dropped? The benefits of the vmalloc optimizations
>> > > > seem to
>> > > >    only be noticeable when we get to thousands of module_alloc
>> > > > allocations
>> > > > -
>> > > >    again, a concern caused by bpf filters sharing the same space with
>> > > > kernel
>> > > >    modules.
>> > >
>> > > I think the backup area may still be needed, for example if you have 200
>> > > modules
>> > > evenly spaced inside 500MB there is only average ~2.5MB gap between them.
>> > > So
>> > > a
>> > > late added large module could still get blocked.
>> > >
>> > > >    So tldr, it seems to me that the concern of fragmentation, the
>> > > > vmalloc
>> > > >    optimizations, and the main purpose of the backup area - basically,
>> > > > the
>> > > > more
>> > > >    complex parts of this patchset - stems squarely from the fact that
>> > > > bpf
>> > > > filters
>> > > >    share the same space as modules on x86. If we were to focus on
>> > > > randomizing
>> > > >    *just* kernel modules, and if bpf and modules had their own dedicated
>> > > > regions,
>> > > >    then I *think* the concrete use cases for the backup area and the
>> > > > vmalloc
>> > > >    optimizations (if we're strictly considering just kernel modules)
>> > > > would
>> > > >    mostly disappear (please correct me if I'm in the wrong here). Then
>> > > > tackling the
>> > > >    randomization of bpf allocations could potentially be a separate task
>> > > > on
>> > > > its own.
>> > >
>> > > Yes it seems then the vmalloc optimizations could be dropped then, but I
>> > > don't
>> > > think the backup area could be. Also the entropy would go down since there
>> > > would
>> > > be less possible positions and we would reduce the space available to BPF.
>> > > So
>> > > there are some downsides just to remove the vmalloc piece.
>> > >
>> > > Is your concern that vmalloc optimizations might regress something else?
>> > > There
>> > > is a middle ground vmalloc optimization where only the try_purge flag is
>> > > plumbed
>> > > through. The flag was most of the performance gained and with just that
>> > > piece it
>> > > should not change any behavior for the non-modules flows. Would that be
>> > > more
>> > > acceptable?
>> > >
>> > > > Thanks!
>> > > >
>> > > > Jessica
>> > > >
>> > >
>> > > [snip]
>> > >
>> >
>> >
